From: kan.liang@intel.com
Subject: [RFC PATCH 24/30] net/netpolicy: set rx queues according to policy
Date: Sun, 17 Jul 2016 23:56:18 -0700
Message-ID: <1468824984-65318-25-git-send-email-kan.liang@intel.com>
References: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, jesse.brandeburg@intel.com,
	andi@firstfloor.org, Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468824984-65318-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

For setting rx queues, this patch add rules for Flow Director filters.
Since we may not get all the information required for rule until the
first package arrived, it will add the rule after recvmsg. The first
several packages may not use the assigned queue.
The dev information will be discarded in udp_queue_rcv_skb, so we record
it in netpolicy struct in advance.
This patch only support INET tcp4 and udp4. It can be extend to other
socket type and V6 later shortly.
For each sk, it only supports one rule. If the port/address changed, the
previos rule will be replaced.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h | 33 ++++++++++++++++--
 net/core/netpolicy.c      | 89 +++++++++++++++++++++++++++++++++++++++++++++++
 net/core/sock.c           |  4 +++
 net/ipv4/af_inet.c        | 55 +++++++++++++++++++++++++++++
 net/ipv4/udp.c            |  4 +++
 5 files changed, 183 insertions(+), 2 deletions(-)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index e20820d..1cd5ac4 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -82,8 +82,27 @@ struct netpolicy_info {
 
 struct netpolicy_reg {
 	struct net_device	*dev;
-	enum netpolicy_name	policy; /* required policy */
-	void			*ptr;   /* pointers */
+	enum netpolicy_name	policy;		/* required policy */
+	void			*ptr;		/* pointers */
+	u32			location;	/* rule location */
+	u32			rule_queue;	/* queue set by rule */
+};
+
+struct netpolicy_tcpudpip4_spec {
+	/* source and Destination host and port */
+	__be32	ip4src;
+	__be32	ip4dst;
+	__be16	psrc;
+	__be16	pdst;
+};
+
+union netpolicy_flow_union {
+	struct netpolicy_tcpudpip4_spec		tcp_udp_ip4_spec;
+};
+
+struct netpolicy_flow_spec {
+	__u32	flow_type;
+	union netpolicy_flow_union	spec;
 };
 
 /* check if policy is valid */
@@ -98,6 +117,9 @@ extern int netpolicy_register(struct netpolicy_reg *reg,
 			      enum netpolicy_name policy);
 extern void netpolicy_unregister(struct netpolicy_reg *reg);
 extern int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx);
+extern int netpolicy_set_rules(struct netpolicy_reg *reg,
+			       u32 queue_index,
+			       struct netpolicy_flow_spec *flow);
 #else
 static inline void update_netpolicy_sys_map(void)
 {
@@ -116,6 +138,13 @@ static inline int netpolicy_pick_queue(struct netpolicy_reg *reg, bool is_rx)
 {
 	return 0;
 }
+
+static inline int netpolicy_set_rules(struct netpolicy_reg *reg,
+				      u32 queue_index,
+				      struct netpolicy_flow_spec *flow)
+{
+	return 0;
+}
 #endif
 
 #endif /*__LINUX_NETPOLICY_H*/
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 6992d08..0ed3080 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -39,6 +39,7 @@
 #include <linux/ctype.h>
 #include <linux/cpu.h>
 #include <linux/hashtable.h>
+#include <net/rtnetlink.h>
 
 struct netpolicy_record {
 	struct hlist_node	hash_node;
@@ -474,6 +475,20 @@ void netpolicy_unregister(struct netpolicy_reg *reg)
 {
 	struct netpolicy_record *record;
 	unsigned long ptr_id = (uintptr_t)reg->ptr;
+	struct net_device *dev = reg->dev;
+
+	/* remove FD rules */
+	if (dev && reg->location != ~0) {
+		struct ethtool_rxnfc del_cmd;
+
+		del_cmd.cmd = ETHTOOL_SRXCLSRLDEL;
+		del_cmd.fs.location = reg->location;
+		rtnl_lock();
+		dev->ethtool_ops->set_rxnfc(dev, &del_cmd);
+		rtnl_unlock();
+		reg->location = ~0;
+		reg->rule_queue = ~0;
+	}
 
 	spin_lock_bh(&np_hashtable_lock);
 	/* del from hash table */
@@ -489,6 +504,80 @@ void netpolicy_unregister(struct netpolicy_reg *reg)
 }
 EXPORT_SYMBOL(netpolicy_unregister);
 
+/**
+ * netpolicy_set_rules() - Configure Rx network flow classification rules
+ * @reg:		NET policy register info
+ * @queue_index:	Rx queue which want to set rules
+ * @flow:		Target flow to apply rules
+ *
+ * This function intends to configure Rx network flow classification rules
+ * according to ip and port information.
+ *
+ * Currently, it only supports TCP and UDP V4. Other protocols will be
+ * supported later.
+ *
+ * Return: 0 on success, others on failure
+ */
+int netpolicy_set_rules(struct netpolicy_reg *reg,
+			u32 queue_index,
+			struct netpolicy_flow_spec *flow)
+{
+	int ret;
+	struct ethtool_rxnfc cmd;
+	struct net_device *dev = reg->dev;
+
+	if (!dev)
+		return -EINVAL;
+
+	/* Check if ntuple is supported */
+	if (!dev->ethtool_ops->set_rxnfc)
+		return -EOPNOTSUPP;
+
+	/* Only support TCP/UDP V4 by now */
+	if ((flow->flow_type != TCP_V4_FLOW) &&
+	    (flow->flow_type != UDP_V4_FLOW))
+		return -EOPNOTSUPP;
+
+	/* using flow-type (Flow Director filters) */
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.cmd = ETHTOOL_SRXCLSRLINS;
+	cmd.fs.flow_type = flow->flow_type;
+	cmd.fs.h_u.tcp_ip4_spec.ip4src = flow->spec.tcp_udp_ip4_spec.ip4src;
+	cmd.fs.h_u.tcp_ip4_spec.psrc = flow->spec.tcp_udp_ip4_spec.psrc;
+	cmd.fs.h_u.tcp_ip4_spec.ip4dst = flow->spec.tcp_udp_ip4_spec.ip4dst;
+	cmd.fs.h_u.tcp_ip4_spec.pdst = flow->spec.tcp_udp_ip4_spec.pdst;
+	cmd.fs.ring_cookie = queue_index;
+	cmd.fs.location = RX_CLS_LOC_ANY;
+	rtnl_lock();
+	ret = dev->ethtool_ops->set_rxnfc(dev, &cmd);
+	rtnl_unlock();
+	if (ret < 0) {
+		pr_warn("Failed to set rules ret %d\n", ret);
+		return ret;
+	}
+
+	/* TODO: now one sk only has one rule */
+	if (reg->location != ~0) {
+		/* delete the old rule */
+		struct ethtool_rxnfc del_cmd;
+
+		del_cmd.cmd = ETHTOOL_SRXCLSRLDEL;
+		del_cmd.fs.location = reg->location;
+		rtnl_lock();
+		ret = dev->ethtool_ops->set_rxnfc(dev, &del_cmd);
+		rtnl_unlock();
+		if (ret < 0)
+			pr_warn("Failed to delete rules ret %d\n", ret);
+	}
+
+	/* record rule location */
+	reg->location = cmd.fs.location;
+	reg->rule_queue = queue_index;
+
+	return ret;
+}
+EXPORT_SYMBOL(netpolicy_set_rules);
+
 const char *policy_name[NET_POLICY_MAX] = {
 	"NONE",
 	"CPU",
diff --git a/net/core/sock.c b/net/core/sock.c
index 6eaaa08..849274a 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1439,6 +1439,8 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		sk->sk_netpolicy.dev = NULL;
 		sk->sk_netpolicy.ptr = (void *)sk;
 		sk->sk_netpolicy.policy = NET_POLICY_INVALID;
+		sk->sk_netpolicy.location = ~0;
+		sk->sk_netpolicy.rule_queue = ~0;
 #endif
 	}
 
@@ -1620,6 +1622,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 
 #ifdef CONFIG_NETPOLICY
 		newsk->sk_netpolicy.ptr = (void *)newsk;
+		newsk->sk_netpolicy.location = ~0;
+		newsk->sk_netpolicy.rule_queue = ~0;
 		if (is_net_policy_valid(newsk->sk_netpolicy.policy))
 			netpolicy_register(&newsk->sk_netpolicy, newsk->sk_netpolicy.policy);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 55513e6..889ffdc 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -759,6 +759,55 @@ ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 }
 EXPORT_SYMBOL(inet_sendpage);
 
+static void sock_netpolicy_manage_flow(struct sock *sk, struct msghdr *msg)
+{
+#ifdef CONFIG_NETPOLICY
+	int queue_index;
+	struct netpolicy_flow_spec flow;
+
+	if (!sk->sk_netpolicy.dev)
+		return;
+
+	if (sk->sk_netpolicy.policy <= NET_POLICY_NONE)
+		return;
+
+	queue_index = netpolicy_pick_queue(&sk->sk_netpolicy, true);
+	if ((queue_index < 0) ||
+	    (queue_index == sk->sk_netpolicy.rule_queue))
+		return;
+
+	memset(&flow, 0, sizeof(flow));
+	/* TODO: need to change here and add more protocol support */
+	if (sk->sk_protocol == IPPROTO_TCP &&
+	    sk->sk_type == SOCK_STREAM) {
+		flow.flow_type = TCP_V4_FLOW;
+		flow.spec.tcp_udp_ip4_spec.ip4src = sk->sk_daddr;
+		flow.spec.tcp_udp_ip4_spec.psrc = sk->sk_dport;
+		flow.spec.tcp_udp_ip4_spec.ip4dst = sk->sk_rcv_saddr;
+		flow.spec.tcp_udp_ip4_spec.pdst = htons(sk->sk_num);
+	} else if (sk->sk_protocol == IPPROTO_UDP &&
+		   sk->sk_type == SOCK_DGRAM) {
+		DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
+
+		flow.flow_type = UDP_V4_FLOW;
+		if (sin && sin->sin_addr.s_addr)
+			flow.spec.tcp_udp_ip4_spec.ip4src = sin->sin_addr.s_addr;
+		else
+			return;
+		if (sin && sin->sin_port)
+			flow.spec.tcp_udp_ip4_spec.psrc = sin->sin_port;
+		else
+			return;
+		flow.spec.tcp_udp_ip4_spec.ip4dst = sk->sk_rcv_saddr;
+		flow.spec.tcp_udp_ip4_spec.pdst = htons(sk->sk_num);
+	} else {
+		return;
+	}
+	netpolicy_set_rules(&sk->sk_netpolicy, queue_index, &flow);
+
+#endif
+}
+
 int inet_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 		 int flags)
 {
@@ -772,6 +821,12 @@ int inet_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 				   flags & ~MSG_DONTWAIT, &addr_len);
 	if (err >= 0)
 		msg->msg_namelen = addr_len;
+
+	/* The dev info, src address and port information for UDP
+	 * can only be retrieved after processing the msg.
+	 */
+	sock_netpolicy_manage_flow(sk, msg);
+
 	return err;
 }
 EXPORT_SYMBOL(inet_recvmsg);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index ca5e8ea..13181c8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1785,6 +1785,10 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 	if (sk) {
 		int ret;
 
+#ifdef CONFIG_NETPOLICY
+		/* Record dev info before it's discarded in udp_queue_rcv_skb */
+		sk->sk_netpolicy.dev = skb->dev;
+#endif
 		if (inet_get_convert_csum(sk) && uh->check && !IS_UDPLITE(sk))
 			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
 						 inet_compute_pseudo);
-- 
2.5.5
