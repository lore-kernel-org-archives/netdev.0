From: kan.liang@intel.com
Subject: [RFC V2 PATCH 19/25] net/netpolicy: set Rx queues according to policy
Date: Wed, 31 Dec 2014 20:39:08 -0500
Message-ID: <1420076354-4861-20-git-send-email-kan.liang@intel.com>
References: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Cc: jeffrey.t.kirsher@intel.com, mingo@redhat.com,
	peterz@infradead.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	akpm@linux-foundation.org, keescook@chromium.org,
	viro@zeniv.linux.org.uk, gorcunov@openvz.org,
	john.stultz@linaro.org, aduyck@mirantis.com, ben@decadent.org.uk,
	decot@googlers.com, fw@strlen.de, alexander.duyck@gmail.com,
	daniel@iogearbox.net, tom@herbertland.com, rdunlap@infradead.org,
	xiyou.wangcong@gmail.com, hannes@stressinduktion.org,
	jesse.brandeburg@intel.com, andi@firstfloor.org,
	Kan Liang <kan.liang@intel.com>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420076354-4861-1-git-send-email-kan.liang@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kan Liang <kan.liang@intel.com>

For setting Rx queues, this patch configure Rx network flow
classification rules to redirect the packets to the assigned queue.

Since we may not get all the information required for rule until the
first packet arrived, it will add the rule after recvmsg. Also, to
avoid destroying the connection rates, the configuration will be done
asynchronized by work queue. So the first several packets may not use
the assigned queue.

The dev information will be discarded in udp_queue_rcv_skb, so we record
it in netpolicy struct in advance.

This patch only support INET tcp4 and udp4. It can be extend to other
socket type and V6 later shortly.

For each sk, it only supports one rule. If the port/address changed, the
previos rule will be replaced.

Signed-off-by: Kan Liang <kan.liang@intel.com>
---
 include/linux/netpolicy.h |  33 +++++++++++-
 net/core/netpolicy.c      | 131 +++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/af_inet.c        |  71 +++++++++++++++++++++++++
 net/ipv4/udp.c            |   4 ++
 4 files changed, 236 insertions(+), 3 deletions(-)

diff --git a/include/linux/netpolicy.h b/include/linux/netpolicy.h
index a522015..df962de 100644
--- a/include/linux/netpolicy.h
+++ b/include/linux/netpolicy.h
@@ -37,6 +37,8 @@ enum netpolicy_traffic {
 	NETPOLICY_RXTX,
 };
 
+#define NETPOLICY_INVALID_QUEUE	-1
+#define NETPOLICY_INVALID_LOC	NETPOLICY_INVALID_QUEUE
 #define POLICY_NAME_LEN_MAX	64
 extern const char *policy_name[];
 
@@ -80,10 +82,32 @@ struct netpolicy_info {
 	struct list_head		obj_list[NETPOLICY_RXTX][NET_POLICY_MAX];
 };
 
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
+};
+
 struct netpolicy_instance {
 	struct net_device	*dev;
-	enum netpolicy_name	policy; /* required policy */
-	void			*ptr;   /* pointers */
+	enum netpolicy_name	policy;		/* required policy */
+	void			*ptr;		/* pointers */
+	int			location;	/* rule location */
+	atomic_t		rule_queue;	/* queue set by rule */
+	struct work_struct	fc_wk;		/* flow classification work */
+	atomic_t		fc_wk_cnt;	/* flow classification work number */
+	struct netpolicy_flow_spec flow;	/* flow information */
 };
 
 /* check if policy is valid */
@@ -98,6 +122,7 @@ extern int netpolicy_register(struct netpolicy_instance *instance,
 			      enum netpolicy_name policy);
 extern void netpolicy_unregister(struct netpolicy_instance *instance);
 extern int netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx);
+extern void netpolicy_set_rules(struct netpolicy_instance *instance);
 #else
 static inline void update_netpolicy_sys_map(void)
 {
@@ -116,6 +141,10 @@ static inline int netpolicy_pick_queue(struct netpolicy_instance *instance, bool
 {
 	return 0;
 }
+
+static inline void netpolicy_set_rules(struct netpolicy_instance *instance)
+{
+}
 #endif
 
 #endif /*__LINUX_NETPOLICY_H*/
diff --git a/net/core/netpolicy.c b/net/core/netpolicy.c
index 98ca430..89c65d9 100644
--- a/net/core/netpolicy.c
+++ b/net/core/netpolicy.c
@@ -39,6 +39,7 @@
 #include <linux/ctype.h>
 #include <linux/cpu.h>
 #include <linux/hashtable.h>
+#include <net/rtnetlink.h>
 
 struct netpolicy_record {
 	struct hlist_node	hash_node;
@@ -52,6 +53,8 @@ struct netpolicy_record {
 static DEFINE_HASHTABLE(np_record_hash, 10);
 static DEFINE_SPINLOCK(np_hashtable_lock);
 
+struct workqueue_struct *np_fc_wq;
+
 static int netpolicy_get_dev_info(struct net_device *dev,
 				  struct netpolicy_dev_info *d_info)
 {
@@ -426,6 +429,90 @@ int netpolicy_pick_queue(struct netpolicy_instance *instance, bool is_rx)
 }
 EXPORT_SYMBOL(netpolicy_pick_queue);
 
+void np_flow_rule_set(struct work_struct *wk)
+{
+	struct netpolicy_instance *instance;
+	struct netpolicy_flow_spec *flow;
+	struct ethtool_rxnfc cmd;
+	struct net_device *dev;
+	int queue, ret;
+
+	instance = container_of(wk, struct netpolicy_instance,
+				fc_wk);
+	if (!instance)
+		return;
+
+	flow = &instance->flow;
+	if (WARN_ON(!flow))
+		goto done;
+	dev = instance->dev;
+	if (WARN_ON(!dev))
+		goto done;
+
+	/* Check if ntuple is supported */
+	if (!dev->ethtool_ops->set_rxnfc)
+		goto done;
+
+	/* Only support TCP/UDP V4 by now */
+	if ((flow->flow_type != TCP_V4_FLOW) &&
+	    (flow->flow_type != UDP_V4_FLOW))
+		goto done;
+
+	queue = get_avail_queue(instance, true);
+	if (queue < 0)
+		goto done;
+
+	/* using ethtool flow-type to configure
+	 * Rx network flow classification options or rules
+	 * RX_CLS_LOC_ANY must be supported by the driver
+	 */
+	memset(&cmd, 0, sizeof(cmd));
+	cmd.cmd = ETHTOOL_SRXCLSRLINS;
+	cmd.fs.flow_type = flow->flow_type;
+	cmd.fs.h_u.tcp_ip4_spec.ip4src = flow->spec.tcp_udp_ip4_spec.ip4src;
+	cmd.fs.h_u.tcp_ip4_spec.psrc = flow->spec.tcp_udp_ip4_spec.psrc;
+	cmd.fs.h_u.tcp_ip4_spec.ip4dst = flow->spec.tcp_udp_ip4_spec.ip4dst;
+	cmd.fs.h_u.tcp_ip4_spec.pdst = flow->spec.tcp_udp_ip4_spec.pdst;
+	cmd.fs.ring_cookie = queue;
+	cmd.fs.location = RX_CLS_LOC_ANY;
+	rtnl_lock();
+	ret = dev->ethtool_ops->set_rxnfc(dev, &cmd);
+	rtnl_unlock();
+	if (ret < 0) {
+		pr_warn("Failed to set rules ret %d\n", ret);
+		atomic_set(&instance->rule_queue, NETPOLICY_INVALID_QUEUE);
+		goto done;
+	}
+
+	/* TODO: now one sk only has one rule */
+	if (instance->location != NETPOLICY_INVALID_LOC) {
+		/* delete the old rule */
+		struct ethtool_rxnfc del_cmd;
+
+		del_cmd.cmd = ETHTOOL_SRXCLSRLDEL;
+		del_cmd.fs.location = instance->location;
+		rtnl_lock();
+		ret = dev->ethtool_ops->set_rxnfc(dev, &del_cmd);
+		rtnl_unlock();
+		if (ret < 0)
+			pr_warn("Failed to delete rules ret %d\n", ret);
+	}
+
+	/* record rule location */
+	instance->location = cmd.fs.location;
+	atomic_set(&instance->rule_queue, queue);
+done:
+	atomic_set(&instance->fc_wk_cnt, 0);
+}
+
+static void init_instance(struct netpolicy_instance *instance)
+{
+	instance->location = NETPOLICY_INVALID_LOC;
+	atomic_set(&instance->rule_queue, NETPOLICY_INVALID_QUEUE);
+	atomic_set(&instance->fc_wk_cnt, 0);
+	INIT_WORK(&instance->fc_wk, np_flow_rule_set);
+}
+
 /**
  * netpolicy_register() - Register per socket/task policy request
  * @instance:	NET policy per socket/task instance info
@@ -470,6 +557,7 @@ int netpolicy_register(struct netpolicy_instance *instance,
 		}
 		kfree(new);
 	} else {
+		init_instance(instance);
 		new->ptr_id = ptr_id;
 		new->dev = instance->dev;
 		new->policy = policy;
@@ -492,8 +580,23 @@ EXPORT_SYMBOL(netpolicy_register);
  */
 void netpolicy_unregister(struct netpolicy_instance *instance)
 {
-	struct netpolicy_record *record;
 	unsigned long ptr_id = (uintptr_t)instance->ptr;
+	struct net_device *dev = instance->dev;
+	struct netpolicy_record *record;
+
+	cancel_work_sync(&instance->fc_wk);
+	/* remove FD rules */
+	if (dev && instance->location != NETPOLICY_INVALID_LOC) {
+		struct ethtool_rxnfc del_cmd;
+
+		del_cmd.cmd = ETHTOOL_SRXCLSRLDEL;
+		del_cmd.fs.location = instance->location;
+		rtnl_lock();
+		dev->ethtool_ops->set_rxnfc(dev, &del_cmd);
+		rtnl_unlock();
+		instance->location = NETPOLICY_INVALID_LOC;
+		atomic_set(&instance->rule_queue, NETPOLICY_INVALID_QUEUE);
+	}
 
 	spin_lock_bh(&np_hashtable_lock);
 	/* del from hash table */
@@ -509,6 +612,26 @@ void netpolicy_unregister(struct netpolicy_instance *instance)
 }
 EXPORT_SYMBOL(netpolicy_unregister);
 
+/**
+ * netpolicy_set_rules() - Configure Rx network flow classification rules
+ * @instance:	NET policy per socket/task instance info
+ *
+ * This function intends to configure Rx network flow classification rules
+ * according to ip and port information. The configuration will be done
+ * asynchronized by work queue. It avoids to destroy the connection rates.
+ *
+ * Currently, it only supports TCP and UDP V4. Other protocols will be
+ * supported later.
+ *
+ */
+void netpolicy_set_rules(struct netpolicy_instance *instance)
+{
+	/* There should be only one work to run at the same time */
+	if (!atomic_cmpxchg(&instance->fc_wk_cnt, 0, 1))
+		queue_work(np_fc_wq, &instance->fc_wk);
+}
+EXPORT_SYMBOL(netpolicy_set_rules);
+
 const char *policy_name[NET_POLICY_MAX] = {
 	"NONE",
 	"CPU",
@@ -1200,6 +1323,10 @@ static int __init netpolicy_init(void)
 {
 	int ret;
 
+	np_fc_wq = create_workqueue("np_fc");
+	if (!np_fc_wq)
+		return -ENOMEM;
+
 	ret = register_pernet_subsys(&netpolicy_net_ops);
 	if (!ret)
 		register_netdevice_notifier(&netpolicy_dev_notf);
@@ -1213,6 +1340,8 @@ static int __init netpolicy_init(void)
 
 static void __exit netpolicy_exit(void)
 {
+	destroy_workqueue(np_fc_wq);
+
 	unregister_netdevice_notifier(&netpolicy_dev_notf);
 	unregister_pernet_subsys(&netpolicy_net_ops);
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 55513e6..f536da3 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -759,6 +759,71 @@ ssize_t inet_sendpage(struct socket *sock, struct page *page, int offset,
 }
 EXPORT_SYMBOL(inet_sendpage);
 
+static void sock_netpolicy_manage_flow(struct sock *sk, struct msghdr *msg)
+{
+#ifdef CONFIG_NETPOLICY
+	struct netpolicy_instance *instance;
+	struct netpolicy_flow_spec *flow;
+	bool change = false;
+	int queue;
+
+	instance = netpolicy_find_instance(sk);
+	if (!instance)
+		return;
+
+	if (!instance->dev)
+		return;
+
+	flow = &instance->flow;
+	/* TODO: need to change here and add more protocol support */
+	if (sk->sk_family != AF_INET)
+		return;
+	if ((sk->sk_protocol == IPPROTO_TCP) &&
+	    (sk->sk_type == SOCK_STREAM)) {
+		if ((flow->flow_type != TCP_V4_FLOW) ||
+		    (flow->spec.tcp_udp_ip4_spec.ip4src != sk->sk_daddr) ||
+		    (flow->spec.tcp_udp_ip4_spec.psrc != sk->sk_dport) ||
+		    (flow->spec.tcp_udp_ip4_spec.ip4dst != sk->sk_rcv_saddr) ||
+		    (flow->spec.tcp_udp_ip4_spec.pdst != htons(sk->sk_num)))
+			change = true;
+		if (change) {
+			flow->flow_type = TCP_V4_FLOW;
+			flow->spec.tcp_udp_ip4_spec.ip4src = sk->sk_daddr;
+			flow->spec.tcp_udp_ip4_spec.psrc = sk->sk_dport;
+			flow->spec.tcp_udp_ip4_spec.ip4dst = sk->sk_rcv_saddr;
+			flow->spec.tcp_udp_ip4_spec.pdst = htons(sk->sk_num);
+		}
+	} else if ((sk->sk_protocol == IPPROTO_UDP) &&
+		   (sk->sk_type == SOCK_DGRAM)) {
+			DECLARE_SOCKADDR(struct sockaddr_in *, sin, msg->msg_name);
+
+			if (!sin || !sin->sin_addr.s_addr || !sin->sin_port)
+				return;
+			if ((flow->flow_type != UDP_V4_FLOW) ||
+			    (flow->spec.tcp_udp_ip4_spec.ip4src != sin->sin_addr.s_addr) ||
+			    (flow->spec.tcp_udp_ip4_spec.psrc != sin->sin_port) ||
+			    (flow->spec.tcp_udp_ip4_spec.ip4dst != sk->sk_rcv_saddr) ||
+			    (flow->spec.tcp_udp_ip4_spec.pdst != htons(sk->sk_num)))
+				change = true;
+			if (change) {
+				flow->flow_type = UDP_V4_FLOW;
+				flow->spec.tcp_udp_ip4_spec.ip4src = sin->sin_addr.s_addr;
+				flow->spec.tcp_udp_ip4_spec.psrc = sin->sin_port;
+				flow->spec.tcp_udp_ip4_spec.ip4dst = sk->sk_rcv_saddr;
+				flow->spec.tcp_udp_ip4_spec.pdst = htons(sk->sk_num);
+			}
+	} else {
+		return;
+	}
+
+	queue = netpolicy_pick_queue(instance, true);
+	if (queue < 0)
+		return;
+	if ((queue != atomic_read(&instance->rule_queue)) || change)
+		netpolicy_set_rules(instance);
+#endif
+}
+
 int inet_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 		 int flags)
 {
@@ -772,6 +837,12 @@ int inet_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
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
index e61f7cd..c495392 100644
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
