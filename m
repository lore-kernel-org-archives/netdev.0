From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 2/3] ipv4: Pass struct net into ip_defrag and ip_check_defrag
Date: Fri,  9 Oct 2015 13:44:54 -0500
Message-ID: <1444416295-31683-2-git-send-email-ebiederm@xmission.com>
References: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87bnca4aie.fsf_-_@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function ip_defrag is called on both the input and the output
paths of the networking stack.  In particular conntrack when it is
tracking outbound packets from the local machine calls ip_defrag.

So add a struct net parameter and stop making ip_defrag guess which
network namespace it needs to defragment packets in.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/macvlan.c               | 2 +-
 include/net/ip.h                    | 6 +++---
 net/ipv4/ip_fragment.c              | 7 +++----
 net/ipv4/ip_input.c                 | 7 ++++---
 net/ipv4/netfilter/nf_defrag_ipv4.c | 7 ++++---
 net/netfilter/ipvs/ip_vs_core.c     | 2 +-
 net/openvswitch/conntrack.c         | 2 +-
 net/packet/af_packet.c              | 6 +++---
 8 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 47da43595ac2..86f6c6292c27 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -412,7 +412,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 
 	port = macvlan_port_get_rcu(skb->dev);
 	if (is_multicast_ether_addr(eth->h_dest)) {
-		skb = ip_check_defrag(skb, IP_DEFRAG_MACVLAN);
+		skb = ip_check_defrag(dev_net(skb->dev), skb, IP_DEFRAG_MACVLAN);
 		if (!skb)
 			return RX_HANDLER_CONSUMED;
 		eth = eth_hdr(skb);
diff --git a/include/net/ip.h b/include/net/ip.h
index 3c904a28d5e5..1a98f1ca1638 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -506,11 +506,11 @@ static inline bool ip_defrag_user_in_between(u32 user,
 	return user >= lower_bond && user <= upper_bond;
 }
 
-int ip_defrag(struct sk_buff *skb, u32 user);
+int ip_defrag(struct net *net, struct sk_buff *skb, u32 user);
 #ifdef CONFIG_INET
-struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user);
+struct sk_buff *ip_check_defrag(struct net *net, struct sk_buff *skb, u32 user);
 #else
-static inline struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
+static inline struct sk_buff *ip_check_defrag(struct net *net, struct sk_buff *skb, u32 user)
 {
 	return skb;
 }
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 9772b789adf3..5482745d5d68 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -654,11 +654,10 @@ out_fail:
 }
 
 /* Process an incoming IP datagram fragment. */
-int ip_defrag(struct sk_buff *skb, u32 user)
+int ip_defrag(struct net *net, struct sk_buff *skb, u32 user)
 {
 	struct net_device *dev = skb->dev ? : skb_dst(skb)->dev;
 	int vif = l3mdev_master_ifindex_rcu(dev);
-	struct net *net = dev_net(dev);
 	struct ipq *qp;
 
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
@@ -683,7 +682,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 }
 EXPORT_SYMBOL(ip_defrag);
 
-struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
+struct sk_buff *ip_check_defrag(struct net *net, struct sk_buff *skb, u32 user)
 {
 	struct iphdr iph;
 	int netoff;
@@ -712,7 +711,7 @@ struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
 			if (pskb_trim_rcsum(skb, netoff + len))
 				return skb;
 			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-			if (ip_defrag(skb, user))
+			if (ip_defrag(net, skb, user))
 				return NULL;
 			skb_clear_hash(skb);
 		}
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 804b86fd615f..b1209b63381f 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -170,7 +170,7 @@ bool ip_call_ra_chain(struct sk_buff *skb)
 		     sk->sk_bound_dev_if == dev->ifindex) &&
 		    net_eq(sock_net(sk), net)) {
 			if (ip_is_fragment(ip_hdr(skb))) {
-				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN))
+				if (ip_defrag(net, skb, IP_DEFRAG_CALL_RA_CHAIN))
 					return true;
 			}
 			if (last) {
@@ -247,14 +247,15 @@ int ip_local_deliver(struct sk_buff *skb)
 	/*
 	 *	Reassemble IP fragments.
 	 */
+	struct net *net = dev_net(skb->dev);
 
 	if (ip_is_fragment(ip_hdr(skb))) {
-		if (ip_defrag(skb, IP_DEFRAG_LOCAL_DELIVER))
+		if (ip_defrag(net, skb, IP_DEFRAG_LOCAL_DELIVER))
 			return 0;
 	}
 
 	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN,
-		       dev_net(skb->dev), NULL, skb, skb->dev, NULL,
+		       net, NULL, skb, skb->dev, NULL,
 		       ip_local_deliver_finish);
 }
 
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index b246346ee849..bf25f45b23d2 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -22,14 +22,15 @@
 #endif
 #include <net/netfilter/nf_conntrack_zones.h>
 
-static int nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
+static int nf_ct_ipv4_gather_frags(struct net *net, struct sk_buff *skb,
+				   u_int32_t user)
 {
 	int err;
 
 	skb_orphan(skb);
 
 	local_bh_disable();
-	err = ip_defrag(skb, user);
+	err = ip_defrag(net, skb, user);
 	local_bh_enable();
 
 	if (!err) {
@@ -85,7 +86,7 @@ static unsigned int ipv4_conntrack_defrag(void *priv,
 		enum ip_defrag_users user =
 			nf_ct_defrag_user(state->hook, skb);
 
-		if (nf_ct_ipv4_gather_frags(skb, user))
+		if (nf_ct_ipv4_gather_frags(state->net, skb, user))
 			return NF_STOLEN;
 	}
 	return NF_ACCEPT;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 37dd77a3d0fb..07a791ecdfba 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -694,7 +694,7 @@ static inline int ip_vs_gather_frags(struct netns_ipvs *ipvs,
 	int err;
 
 	local_bh_disable();
-	err = ip_defrag(skb, user);
+	err = ip_defrag(ipvs->net, skb, user);
 	local_bh_enable();
 	if (!err)
 		ip_send_check(ip_hdr(skb));
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index eb759e3a88ca..cb76076a7a42 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -304,7 +304,7 @@ static int handle_fragments(struct net *net, struct sw_flow_key *key,
 		int err;
 
 		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-		err = ip_defrag(skb, user);
+		err = ip_defrag(net, skb, user);
 		if (err)
 			return err;
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 81c900fbc4a4..7a9d69c1debc 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1439,17 +1439,17 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 {
 	struct packet_fanout *f = pt->af_packet_priv;
 	unsigned int num = READ_ONCE(f->num_members);
+	struct net *net = read_pnet(&f->net);
 	struct packet_sock *po;
 	unsigned int idx;
 
-	if (!net_eq(dev_net(dev), read_pnet(&f->net)) ||
-	    !num) {
+	if (!net_eq(dev_net(dev), net) || !num) {
 		kfree_skb(skb);
 		return 0;
 	}
 
 	if (fanout_has_flag(f, PACKET_FANOUT_FLAG_DEFRAG)) {
-		skb = ip_check_defrag(skb, IP_DEFRAG_AF_PACKET);
+		skb = ip_check_defrag(net, skb, IP_DEFRAG_AF_PACKET);
 		if (!skb)
 			return 0;
 	}
-- 
2.2.1

