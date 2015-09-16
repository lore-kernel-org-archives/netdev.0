From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 30/30] netfilter: Pass net into okfn
Date: Tue, 15 Sep 2015 20:04:18 -0500
Message-ID: <1442365458-16349-30-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35225 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbbIPBNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:13:43 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is immediately motivated by the bridge code that chains functions that
call into netfilter.  Without passing net into the okfns the bridge code would
need to guess about the best expression for the network namespace to process
packets in.

As net is frequently one of the first things computed in continuation functions
after netfilter has done it's job passing in the desired network namespace is in
many cases a code simplification.

To support this change the function dst_output_okfn is introduced to
simplify passing dst_output as an okfn.  For the moment dst_output_okfn
just silently drops the struct net.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/vrf.c                    |  2 +-
 include/linux/netdevice.h            |  2 +-
 include/linux/netfilter.h            | 26 ++++++++++++++------------
 include/linux/netfilter_bridge.h     |  2 +-
 include/net/dn_neigh.h               |  6 +++---
 include/net/dst.h                    |  4 ++++
 include/net/ipv6.h                   |  2 +-
 include/net/netfilter/br_netfilter.h |  2 +-
 net/bridge/br_forward.c              |  5 ++---
 net/bridge/br_input.c                |  7 ++++---
 net/bridge/br_netfilter_hooks.c      | 21 +++++++++------------
 net/bridge/br_netfilter_ipv6.c       |  3 +--
 net/bridge/br_private.h              |  6 +++---
 net/bridge/br_stp_bpdu.c             |  3 ++-
 net/core/dev.c                       |  4 +++-
 net/decnet/dn_neigh.c                |  8 ++++----
 net/decnet/dn_nsp_in.c               |  3 ++-
 net/decnet/dn_route.c                |  6 +++---
 net/ipv4/arp.c                       |  7 +++----
 net/ipv4/ip_forward.c                |  3 +--
 net/ipv4/ip_input.c                  |  7 ++-----
 net/ipv4/ip_output.c                 |  4 ++--
 net/ipv4/ipmr.c                      |  4 ++--
 net/ipv4/raw.c                       |  2 +-
 net/ipv4/xfrm4_input.c               |  3 ++-
 net/ipv4/xfrm4_output.c              |  2 +-
 net/ipv6/ip6_input.c                 |  5 ++---
 net/ipv6/ip6_output.c                |  7 ++++---
 net/ipv6/ip6mr.c                     |  3 +--
 net/ipv6/mcast.c                     |  4 ++--
 net/ipv6/ndisc.c                     |  2 +-
 net/ipv6/output_core.c               |  2 +-
 net/ipv6/raw.c                       |  2 +-
 net/ipv6/xfrm6_output.c              |  2 +-
 net/netfilter/ipvs/ip_vs_xmit.c      |  4 ++--
 net/netfilter/nf_queue.c             |  2 +-
 net/xfrm/xfrm_output.c               | 12 ++++++------
 37 files changed, 95 insertions(+), 94 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index c82260341b72..4dd701d7b8e6 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -253,7 +253,7 @@ static netdev_tx_t vrf_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 /* modelled after ip_finish_output2 */
-static int vrf_finish_output(struct sock *sk, struct sk_buff *skb)
+static int vrf_finish_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct rtable *rt = (struct rtable *)dst;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 97ab5c9a7069..b791405958b4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2212,7 +2212,7 @@ int dev_open(struct net_device *dev);
 int dev_close(struct net_device *dev);
 int dev_close_many(struct list_head *head, bool unlink);
 void dev_disable_lro(struct net_device *dev);
-int dev_loopback_xmit(struct sock *sk, struct sk_buff *newskb);
+int dev_loopback_xmit(struct net *net, struct sock *sk, struct sk_buff *newskb);
 int dev_queue_xmit(struct sk_buff *skb);
 int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv);
 int register_netdevice(struct net_device *dev);
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 295f2650b5dc..0b4d4560f33d 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -56,7 +56,7 @@ struct nf_hook_state {
 	struct sock *sk;
 	struct net *net;
 	struct list_head *hook_list;
-	int (*okfn)(struct sock *, struct sk_buff *);
+	int (*okfn)(struct net *, struct sock *, struct sk_buff *);
 };
 
 static inline void nf_hook_state_init(struct nf_hook_state *p,
@@ -67,7 +67,7 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
 				      struct net_device *outdev,
 				      struct sock *sk,
 				      struct net *net,
-				      int (*okfn)(struct sock *, struct sk_buff *))
+				      int (*okfn)(struct net *, struct sock *, struct sk_buff *))
 {
 	p->hook = hook;
 	p->thresh = thresh;
@@ -175,7 +175,7 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 				 struct sk_buff *skb,
 				 struct net_device *indev,
 				 struct net_device *outdev,
-				 int (*okfn)(struct sock *, struct sk_buff *),
+				 int (*okfn)(struct net *, struct sock *, struct sk_buff *),
 				 int thresh)
 {
 	struct list_head *hook_list = &net->nf.hooks[pf][hook];
@@ -193,7 +193,7 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
 			  struct sock *sk, struct sk_buff *skb,
 			  struct net_device *indev, struct net_device *outdev,
-			  int (*okfn)(struct sock *, struct sk_buff *))
+			  int (*okfn)(struct net *, struct sock *, struct sk_buff *))
 {
 	return nf_hook_thresh(pf, hook, net, sk, skb, indev, outdev, okfn, INT_MIN);
 }
@@ -219,31 +219,33 @@ static inline int
 NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
 	       struct sk_buff *skb, struct net_device *in,
 	       struct net_device *out,
-	       int (*okfn)(struct sock *, struct sk_buff *), int thresh)
+	       int (*okfn)(struct net *, struct sock *, struct sk_buff *),
+	       int thresh)
 {
 	int ret = nf_hook_thresh(pf, hook, net, sk, skb, in, out, okfn, thresh);
 	if (ret == 1)
-		ret = okfn(sk, skb);
+		ret = okfn(net, sk, skb);
 	return ret;
 }
 
 static inline int
 NF_HOOK_COND(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
 	     struct sk_buff *skb, struct net_device *in, struct net_device *out,
-	     int (*okfn)(struct sock *, struct sk_buff *), bool cond)
+	     int (*okfn)(struct net *, struct sock *, struct sk_buff *),
+	     bool cond)
 {
 	int ret;
 
 	if (!cond ||
 	    ((ret = nf_hook_thresh(pf, hook, net, sk, skb, in, out, okfn, INT_MIN)) == 1))
-		ret = okfn(sk, skb);
+		ret = okfn(net, sk, skb);
 	return ret;
 }
 
 static inline int
 NF_HOOK(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk, struct sk_buff *skb,
 	struct net_device *in, struct net_device *out,
-	int (*okfn)(struct sock *, struct sk_buff *))
+	int (*okfn)(struct net *, struct sock *, struct sk_buff *))
 {
 	return NF_HOOK_THRESH(pf, hook, net, sk, skb, in, out, okfn, INT_MIN);
 }
@@ -345,12 +347,12 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 }
 
 #else /* !CONFIG_NETFILTER */
-#define NF_HOOK(pf, hook, net, sk, skb, indev, outdev, okfn) (okfn)(sk, skb)
-#define NF_HOOK_COND(pf, hook, net, sk, skb, indev, outdev, okfn, cond) (okfn)(sk, skb)
+#define NF_HOOK(pf, hook, net, sk, skb, indev, outdev, okfn) (okfn)(net, sk, skb)
+#define NF_HOOK_COND(pf, hook, net, sk, skb, indev, outdev, okfn, cond) (okfn)(net, sk, skb)
 static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
 			  struct sock *sk, struct sk_buff *skb,
 			  struct net_device *indev, struct net_device *outdev,
-			  int (*okfn)(struct sock *, struct sk_buff *))
+			  int (*okfn)(struct net *, struct sock *, struct sk_buff *))
 {
 	return 1;
 }
diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 2437b8a5d7a9..2ed40c402b5e 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -17,7 +17,7 @@ enum nf_br_hook_priorities {
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 
-int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb);
+int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb);
 
 static inline void br_drop_fake_rtable(struct sk_buff *skb)
 {
diff --git a/include/net/dn_neigh.h b/include/net/dn_neigh.h
index d0424269313f..5e902fc3f4eb 100644
--- a/include/net/dn_neigh.h
+++ b/include/net/dn_neigh.h
@@ -18,11 +18,11 @@ struct dn_neigh {
 
 void dn_neigh_init(void);
 void dn_neigh_cleanup(void);
-int dn_neigh_router_hello(struct sock *sk, struct sk_buff *skb);
-int dn_neigh_endnode_hello(struct sock *sk, struct sk_buff *skb);
+int dn_neigh_router_hello(struct net *net, struct sock *sk, struct sk_buff *skb);
+int dn_neigh_endnode_hello(struct net *net, struct sock *sk, struct sk_buff *skb);
 void dn_neigh_pointopoint_hello(struct sk_buff *skb);
 int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n);
-int dn_to_neigh_output(struct sock *sk, struct sk_buff *skb);
+int dn_to_neigh_output(struct net *net, struct sock *sk, struct sk_buff *skb);
 
 extern struct neigh_table dn_neigh_table;
 
diff --git a/include/net/dst.h b/include/net/dst.h
index c72e58474e52..df0481a07029 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -458,6 +458,10 @@ static inline int dst_output(struct sock *sk, struct sk_buff *skb)
 {
 	return skb_dst(skb)->output(sk, skb);
 }
+static inline int dst_output_okfn(struct net *net, struct sock *sk, struct sk_buff *skb)
+{
+	return dst_output(sk, skb);
+}
 
 /* Input packet from network to transport.  */
 static inline int dst_input(struct sk_buff *skb)
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 711cca428cc8..384a93cf07d6 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -807,7 +807,7 @@ static inline u8 ip6_tclass(__be32 flowinfo)
 int ipv6_rcv(struct sk_buff *skb, struct net_device *dev,
 	     struct packet_type *pt, struct net_device *orig_dev);
 
-int ip6_rcv_finish(struct sock *sk, struct sk_buff *skb);
+int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb);
 
 /*
  *	upper-layer output functions
diff --git a/include/net/netfilter/br_netfilter.h b/include/net/netfilter/br_netfilter.h
index d4c6b5f30acd..8fe266504900 100644
--- a/include/net/netfilter/br_netfilter.h
+++ b/include/net/netfilter/br_netfilter.h
@@ -31,7 +31,7 @@ static inline void nf_bridge_push_encap_header(struct sk_buff *skb)
 	skb->network_header -= len;
 }
 
-int br_nf_pre_routing_finish_bridge(struct sock *sk, struct sk_buff *skb);
+int br_nf_pre_routing_finish_bridge(struct net *net, struct sock *sk, struct sk_buff *skb);
 
 static inline struct rtable *bridge_parent_rtable(const struct net_device *dev)
 {
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 2dd2a23ce707..48afca729ed7 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -35,7 +35,7 @@ static inline int should_deliver(const struct net_bridge_port *p,
 		p->state == BR_STATE_FORWARDING;
 }
 
-int br_dev_queue_push_xmit(struct sock *sk, struct sk_buff *skb)
+int br_dev_queue_push_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	if (!is_skb_forwardable(skb->dev, skb))
 		goto drop;
@@ -65,9 +65,8 @@ drop:
 }
 EXPORT_SYMBOL_GPL(br_dev_queue_push_xmit);
 
-int br_forward_finish(struct sock *sk, struct sk_buff *skb)
+int br_forward_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb->dev);
 	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING,
 		       net, sk, skb, NULL, skb->dev,
 		       br_dev_queue_push_xmit);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 78fa7acd836e..223f4040d9df 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -26,7 +26,8 @@
 br_should_route_hook_t __rcu *br_should_route_hook __read_mostly;
 EXPORT_SYMBOL(br_should_route_hook);
 
-static int br_netif_receive_skb(struct sock *sk, struct sk_buff *skb)
+static int
+br_netif_receive_skb(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	return netif_receive_skb(skb);
 }
@@ -125,7 +126,7 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 }
 
 /* note: already called with rcu_read_lock */
-int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb)
+int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
@@ -213,7 +214,7 @@ drop:
 EXPORT_SYMBOL_GPL(br_handle_frame_finish);
 
 /* note: already called with rcu_read_lock */
-static int br_handle_local_finish(struct sock *sk, struct sk_buff *skb)
+static int br_handle_local_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 	u16 vid = 0;
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 7886c9d7e23d..e6e76bbdc82f 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -256,7 +256,7 @@ void nf_bridge_update_protocol(struct sk_buff *skb)
  * don't, we use the neighbour framework to find out. In both cases, we make
  * sure that br_handle_frame_finish() is called afterwards.
  */
-int br_nf_pre_routing_finish_bridge(struct sock *sk, struct sk_buff *skb)
+int br_nf_pre_routing_finish_bridge(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct neighbour *neigh;
 	struct dst_entry *dst;
@@ -273,7 +273,7 @@ int br_nf_pre_routing_finish_bridge(struct sock *sk, struct sk_buff *skb)
 		if (neigh->hh.hh_len) {
 			neigh_hh_bridge(&neigh->hh, skb);
 			skb->dev = nf_bridge->physindev;
-			ret = br_handle_frame_finish(sk, skb);
+			ret = br_handle_frame_finish(net, sk, skb);
 		} else {
 			/* the neighbour function below overwrites the complete
 			 * MAC header, so we save the Ethernet source address and
@@ -342,11 +342,10 @@ br_nf_ipv4_daddr_was_changed(const struct sk_buff *skb,
  * device, we proceed as if ip_route_input() succeeded. If it differs from the
  * logical bridge port or if ip_route_output_key() fails we drop the packet.
  */
-static int br_nf_pre_routing_finish(struct sock *sk, struct sk_buff *skb)
+static int br_nf_pre_routing_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	struct iphdr *iph = ip_hdr(skb);
-	struct net *net = dev_net(dev);
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct rtable *rt;
 	int err;
@@ -536,10 +535,9 @@ static unsigned int br_nf_local_in(const struct nf_hook_ops *ops,
 }
 
 /* PF_BRIDGE/FORWARD *************************************************/
-static int br_nf_forward_finish(struct sock *sk, struct sk_buff *skb)
+static int br_nf_forward_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
-	struct net *net = dev_net(skb->dev);
 	struct net_device *in;
 
 	if (!IS_ARP(skb) && !IS_VLAN_ARP(skb)) {
@@ -692,7 +690,7 @@ static int br_nf_push_frag_xmit(struct net *net, struct sock *sk, struct sk_buff
 	__skb_push(skb, data->encap_size);
 
 	nf_bridge_info_free(skb);
-	return br_dev_queue_push_xmit(sk, skb);
+	return br_dev_queue_push_xmit(net, sk, skb);
 }
 static int br_nf_push_frag_xmit_sk(struct sock *sk, struct sk_buff *skb)
 {
@@ -728,17 +726,16 @@ static unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 	return 0;
 }
 
-static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
+static int br_nf_dev_queue_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge;
 	unsigned int mtu_reserved;
-	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	mtu_reserved = nf_bridge_mtu_reduction(skb);
 
 	if (skb_is_gso(skb) || skb->len + mtu_reserved <= skb->dev->mtu) {
 		nf_bridge_info_free(skb);
-		return br_dev_queue_push_xmit(sk, skb);
+		return br_dev_queue_push_xmit(net, sk, skb);
 	}
 
 	nf_bridge = nf_bridge_info_get(skb);
@@ -797,7 +794,7 @@ static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 	}
 #endif
 	nf_bridge_info_free(skb);
-	return br_dev_queue_push_xmit(sk, skb);
+	return br_dev_queue_push_xmit(net, sk, skb);
  drop:
 	kfree_skb(skb);
 	return 0;
@@ -887,7 +884,7 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 	skb->dev = nf_bridge->physindev;
 
 	nf_bridge->physoutdev = NULL;
-	br_handle_frame_finish(NULL, skb);
+	br_handle_frame_finish(dev_net(skb->dev), NULL, skb);
 }
 
 static int br_nf_dev_xmit(struct sk_buff *skb)
diff --git a/net/bridge/br_netfilter_ipv6.c b/net/bridge/br_netfilter_ipv6.c
index 5d19361ad5d3..e4dbbe44c724 100644
--- a/net/bridge/br_netfilter_ipv6.c
+++ b/net/bridge/br_netfilter_ipv6.c
@@ -161,12 +161,11 @@ br_nf_ipv6_daddr_was_changed(const struct sk_buff *skb,
  * for br_nf_pre_routing_finish(), same logic is used here but
  * equivalent IPv6 function ip6_route_input() called indirectly.
  */
-static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
+static int br_nf_pre_routing_finish_ipv6(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct rtable *rt;
 	struct net_device *dev = skb->dev;
-	struct net *net = dev_net(dev);
 	const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
 
 	nf_bridge->frag_max_size = IP6CB(skb)->frag_max_size;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 213baf7aaa93..74e99c75c8e4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -413,10 +413,10 @@ int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 
 /* br_forward.c */
 void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
-int br_dev_queue_push_xmit(struct sock *sk, struct sk_buff *skb);
+int br_dev_queue_push_xmit(struct net *net, struct sock *sk, struct sk_buff *skb);
 void br_forward(const struct net_bridge_port *to,
 		struct sk_buff *skb, struct sk_buff *skb0);
-int br_forward_finish(struct sock *sk, struct sk_buff *skb);
+int br_forward_finish(struct net *net, struct sock *sk, struct sk_buff *skb);
 void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, bool unicast);
 void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
 		      struct sk_buff *skb2, bool unicast);
@@ -434,7 +434,7 @@ void br_port_flags_change(struct net_bridge_port *port, unsigned long mask);
 void br_manage_promisc(struct net_bridge *br);
 
 /* br_input.c */
-int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb);
+int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb);
 rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
 
 static inline bool br_rx_handler_check_rcu(const struct net_device *dev)
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 8e2e8c352198..5881fbc114a9 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -30,7 +30,8 @@
 
 #define LLC_RESERVE sizeof(struct llc_pdu_un)
 
-static int br_send_bpdu_finish(struct sock *sk, struct sk_buff *skb)
+static int br_send_bpdu_finish(struct net *net, struct sock *sk,
+			       struct sk_buff *skb)
 {
 	return dev_queue_xmit(skb);
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 7db9b012dfb7..00dccfac8939 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2915,9 +2915,11 @@ EXPORT_SYMBOL(xmit_recursion);
 
 /**
  *	dev_loopback_xmit - loop back @skb
+ *	@net: network namespace this loopback is happening in
+ *	@sk:  sk needed to be a netfilter okfn
  *	@skb: buffer to transmit
  */
-int dev_loopback_xmit(struct sock *sk, struct sk_buff *skb)
+int dev_loopback_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	skb_reset_mac_header(skb);
 	__skb_pull(skb, skb_network_offset(skb));
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 305ab2fe25cd..482730cd8a56 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -194,7 +194,7 @@ static int dn_neigh_output(struct neighbour *neigh, struct sk_buff *skb)
 	return err;
 }
 
-static int dn_neigh_output_packet(struct sock *sk, struct sk_buff *skb)
+static int dn_neigh_output_packet(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *)dst;
@@ -334,7 +334,7 @@ static int dn_phase3_output(struct neighbour *neigh, struct sock *sk,
 		       dn_neigh_output_packet);
 }
 
-int dn_to_neigh_output(struct sock *sk, struct sk_buff *skb)
+int dn_to_neigh_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *) dst;
@@ -378,7 +378,7 @@ void dn_neigh_pointopoint_hello(struct sk_buff *skb)
 /*
  * Ethernet router hello message received
  */
-int dn_neigh_router_hello(struct sock *sk, struct sk_buff *skb)
+int dn_neigh_router_hello(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct rtnode_hello_message *msg = (struct rtnode_hello_message *)skb->data;
 
@@ -440,7 +440,7 @@ int dn_neigh_router_hello(struct sock *sk, struct sk_buff *skb)
 /*
  * Endnode hello message received
  */
-int dn_neigh_endnode_hello(struct sock *sk, struct sk_buff *skb)
+int dn_neigh_endnode_hello(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct endnode_hello_message *msg = (struct endnode_hello_message *)skb->data;
 	struct neighbour *neigh;
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index e7b0605ca34a..7ac086d5c0c0 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -714,7 +714,8 @@ out:
 	return ret;
 }
 
-static int dn_nsp_rx_packet(struct sock *sk2, struct sk_buff *skb)
+static int dn_nsp_rx_packet(struct net *net, struct sock *sk2,
+			    struct sk_buff *skb)
 {
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
 	struct sock *sk = NULL;
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index fefcd2e85ef9..e930321e2c1d 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -512,7 +512,7 @@ static int dn_return_long(struct sk_buff *skb)
  *
  * Returns: result of input function if route is found, error code otherwise
  */
-static int dn_route_rx_packet(struct sock *sk, struct sk_buff *skb)
+static int dn_route_rx_packet(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dn_skb_cb *cb;
 	int err;
@@ -610,7 +610,7 @@ drop_it:
 	return NET_RX_DROP;
 }
 
-static int dn_route_discard(struct sock *sk, struct sk_buff *skb)
+static int dn_route_discard(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	/*
 	 * I know we drop the packet here, but thats considered success in
@@ -620,7 +620,7 @@ static int dn_route_discard(struct sock *sk, struct sk_buff *skb)
 	return NET_RX_SUCCESS;
 }
 
-static int dn_route_ptp_hello(struct sock *sk, struct sk_buff *skb)
+static int dn_route_ptp_hello(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	dn_dev_hello(skb);
 	dn_neigh_pointopoint_hello(skb);
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index ae71e9ade5f9..61ff5ea31283 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -621,7 +621,7 @@ out:
 }
 EXPORT_SYMBOL(arp_create);
 
-static int arp_xmit_finish(struct sock *sk, struct sk_buff *skb)
+static int arp_xmit_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	return dev_queue_xmit(skb);
 }
@@ -642,7 +642,7 @@ EXPORT_SYMBOL(arp_xmit);
  *	Process an arp request.
  */
 
-static int arp_process(struct sock *sk, struct sk_buff *skb)
+static int arp_process(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
@@ -654,7 +654,6 @@ static int arp_process(struct sock *sk, struct sk_buff *skb)
 	u16 dev_type = dev->type;
 	int addr_type;
 	struct neighbour *n;
-	struct net *net = dev_net(dev);
 	bool is_garp = false;
 
 	/* arp_rcv below verifies the ARP header and verifies the device
@@ -865,7 +864,7 @@ out:
 
 static void parp_redo(struct sk_buff *skb)
 {
-	arp_process(NULL, skb);
+	arp_process(dev_net(skb->dev), NULL, skb);
 }
 
 
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 0a3c45a2e757..d66cfb35ba74 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -61,9 +61,8 @@ static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
 }
 
 
-static int ip_forward_finish(struct sock *sk, struct sk_buff *skb)
+static int ip_forward_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct ip_options *opt	= &(IPCB(skb)->opt);
 
 	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTFORWDATAGRAMS);
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 991d082c7312..7cc9f7bb7fb7 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -188,10 +188,8 @@ bool ip_call_ra_chain(struct sk_buff *skb)
 	return false;
 }
 
-static int ip_local_deliver_finish(struct sock *sk, struct sk_buff *skb)
+static int ip_local_deliver_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb->dev);
-
 	__skb_pull(skb, skb_network_header_len(skb));
 
 	rcu_read_lock();
@@ -311,10 +309,9 @@ drop:
 int sysctl_ip_early_demux __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_ip_early_demux);
 
-static int ip_rcv_finish(struct sock *sk, struct sk_buff *skb)
+static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
-	struct net *net = dev_net(skb->dev);
 	struct rtable *rt;
 
 	if (sysctl_ip_early_demux && !skb_dst(skb) && !skb->sk) {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4c9532259a7f..09a6b7bb7ea3 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -104,7 +104,7 @@ static int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 	ip_send_check(iph);
 	return nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT,
 		       net, sk, skb, NULL, skb_dst(skb)->dev,
-		       dst_output);
+		       dst_output_okfn);
 }
 
 int __ip_local_out(struct sk_buff *skb)
@@ -266,7 +266,7 @@ static int ip_finish_output_gso(struct sock *sk, struct sk_buff *skb,
 	return ret;
 }
 
-static int ip_finish_output(struct sock *sk, struct sk_buff *skb)
+static int ip_finish_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	unsigned int mtu;
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a88c0c5374ff..cfcb996ec51b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1678,10 +1678,10 @@ static void ip_encap(struct net *net, struct sk_buff *skb,
 	nf_reset(skb);
 }
 
-static inline int ipmr_forward_finish(struct sock *sk, struct sk_buff *skb)
+static inline int ipmr_forward_finish(struct net *net, struct sock *sk,
+				      struct sk_buff *skb)
 {
 	struct ip_options *opt = &(IPCB(skb)->opt);
-	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	IP_INC_STATS_BH(net, IPSTATS_MIB_OUTFORWDATAGRAMS);
 	IP_ADD_STATS_BH(net, IPSTATS_MIB_OUTOCTETS, skb->len);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2045b1aaa6ef..28ef8a913130 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -413,7 +413,7 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT,
 		      net, sk, skb, NULL, rt->dst.dev,
-		      dst_output);
+		      dst_output_okfn);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 5093000d3d5e..62e1e72db461 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -22,7 +22,8 @@ int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 	return xfrm4_extract_header(skb);
 }
 
-static inline int xfrm4_rcv_encap_finish(struct sock *sk, struct sk_buff *skb)
+static inline int xfrm4_rcv_encap_finish(struct net *net, struct sock *sk,
+					 struct sk_buff *skb)
 {
 	if (!skb_dst(skb)) {
 		const struct iphdr *iph = ip_hdr(skb);
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index e4a85199e015..28ae2048b93a 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -80,7 +80,7 @@ int xfrm4_output_finish(struct sock *sk, struct sk_buff *skb)
 	return xfrm_output(sk, skb);
 }
 
-static int __xfrm4_output(struct sock *sk, struct sk_buff *skb)
+static int __xfrm4_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct xfrm_state *x = skb_dst(skb)->xfrm;
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 583cf959c23d..9075acf081dd 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -47,7 +47,7 @@
 #include <net/inet_ecn.h>
 #include <net/dst_metadata.h>
 
-int ip6_rcv_finish(struct sock *sk, struct sk_buff *skb)
+int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	if (sysctl_ip_early_demux && !skb_dst(skb) && skb->sk == NULL) {
 		const struct inet6_protocol *ipprot;
@@ -199,9 +199,8 @@ drop:
  */
 
 
-static int ip6_input_finish(struct sock *sk, struct sk_buff *skb)
+static int ip6_input_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
 	const struct inet6_protocol *ipprot;
 	struct inet6_dev *idev;
 	unsigned int nhoff;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 96e76ddd4a44..d8d68e81d123 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -121,7 +121,7 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 	return -EINVAL;
 }
 
-static int ip6_finish_output(struct sock *sk, struct sk_buff *skb)
+static int ip6_finish_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
 	    dst_allfrag(skb_dst(skb)) ||
@@ -225,7 +225,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 			      IPSTATS_MIB_OUT, skb->len);
 		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 			       net, sk, skb, NULL, dst->dev,
-			       dst_output);
+			       dst_output_okfn);
 	}
 
 	skb->dev = dst->dev;
@@ -317,7 +317,8 @@ static int ip6_forward_proxy_check(struct sk_buff *skb)
 	return 0;
 }
 
-static inline int ip6_forward_finish(struct sock *sk, struct sk_buff *skb)
+static inline int ip6_forward_finish(struct net *net, struct sock *sk,
+				     struct sk_buff *skb)
 {
 	skb_sender_cpu_clear(skb);
 	return dst_output(sk, skb);
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index e830942b2090..5e5d16e7ce85 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1985,9 +1985,8 @@ int ip6mr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 }
 #endif
 
-static inline int ip6mr_forward2_finish(struct sock *sk, struct sk_buff *skb)
+static inline int ip6mr_forward2_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
-	struct net *net = dev_net(skb_dst(skb)->dev);
 	IP6_INC_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
 			 IPSTATS_MIB_OUTFORWDATAGRAMS);
 	IP6_ADD_STATS_BH(net, ip6_dst_idev(skb_dst(skb)),
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 124338a39e29..a8bf57ca74d3 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1646,7 +1646,7 @@ static void mld_sendpack(struct sk_buff *skb)
 
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 		      net, net->ipv6.igmp_sk, skb, NULL, skb->dev,
-		      dst_output);
+		      dst_output_okfn);
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, ICMPV6_MLD2_REPORT);
@@ -2010,7 +2010,7 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	skb_dst_set(skb, dst);
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 		      net, sk, skb, NULL, skb->dev,
-		      dst_output);
+		      dst_output_okfn);
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index dd2b08d7c8d1..dde5a1e5875a 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -465,7 +465,7 @@ static void ndisc_send_skb(struct sk_buff *skb,
 
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 		      net, sk, skb, NULL, dst->dev,
-		      dst_output);
+		      dst_output_okfn);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 9cc9127fb5e7..e77102c4f804 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -151,7 +151,7 @@ static int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 
 	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
 		       net, sk, skb, NULL, skb_dst(skb)->dev,
-		       dst_output);
+		       dst_output_okfn);
 }
 
 int __ip6_local_out(struct sk_buff *skb)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index dc65ec198f7c..fec0151522a2 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -655,7 +655,7 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 
 	IP6_UPD_PO_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, net, sk, skb,
-		      NULL, rt->dst.dev, dst_output);
+		      NULL, rt->dst.dev, dst_output_okfn);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 431ae2c22234..68a996f8a044 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -131,7 +131,7 @@ int xfrm6_output_finish(struct sock *sk, struct sk_buff *skb)
 	return xfrm_output(sk, skb);
 }
 
-static int __xfrm6_output(struct sock *sk, struct sk_buff *skb)
+static int __xfrm6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct xfrm_state *x = dst->xfrm;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 65c996c14bca..cc7299033af8 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -574,7 +574,7 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 		if (!skb->sk)
 			skb_sender_cpu_clear(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, ip_vs_conn_net(cp), NULL, skb,
-			NULL, skb_dst(skb)->dev, dst_output);
+			NULL, skb_dst(skb)->dev, dst_output_okfn);
 	} else
 		ret = NF_ACCEPT;
 
@@ -596,7 +596,7 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 		if (!skb->sk)
 			skb_sender_cpu_clear(skb);
 		NF_HOOK(pf, NF_INET_LOCAL_OUT, ip_vs_conn_net(cp), NULL, skb,
-			NULL, skb_dst(skb)->dev, dst_output);
+			NULL, skb_dst(skb)->dev, dst_output_okfn);
 	} else
 		ret = NF_ACCEPT;
 	return ret;
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 96777f9a9350..9f3c3c25fa73 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -215,7 +215,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	case NF_ACCEPT:
 	case NF_STOP:
 		local_bh_disable();
-		entry->state.okfn(entry->state.sk, skb);
+		entry->state.okfn(entry->state.net, entry->state.sk, skb);
 		local_bh_enable();
 		break;
 	case NF_QUEUE:
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index c21f1a02ce13..61ba99f61dc8 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -19,7 +19,7 @@
 #include <net/dst.h>
 #include <net/xfrm.h>
 
-static int xfrm_output2(struct sock *sk, struct sk_buff *skb);
+static int xfrm_output2(struct net *net, struct sock *sk, struct sk_buff *skb);
 
 static int xfrm_skb_check_space(struct sk_buff *skb)
 {
@@ -157,12 +157,12 @@ out:
 }
 EXPORT_SYMBOL_GPL(xfrm_output_resume);
 
-static int xfrm_output2(struct sock *sk, struct sk_buff *skb)
+static int xfrm_output2(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	return xfrm_output_resume(skb, 1);
 }
 
-static int xfrm_output_gso(struct sock *sk, struct sk_buff *skb)
+static int xfrm_output_gso(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	struct sk_buff *segs;
 
@@ -178,7 +178,7 @@ static int xfrm_output_gso(struct sock *sk, struct sk_buff *skb)
 		int err;
 
 		segs->next = NULL;
-		err = xfrm_output2(sk, segs);
+		err = xfrm_output2(net, sk, segs);
 
 		if (unlikely(err)) {
 			kfree_skb_list(nskb);
@@ -197,7 +197,7 @@ int xfrm_output(struct sock *sk, struct sk_buff *skb)
 	int err;
 
 	if (skb_is_gso(skb))
-		return xfrm_output_gso(sk, skb);
+		return xfrm_output_gso(net, sk, skb);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		err = skb_checksum_help(skb);
@@ -208,7 +208,7 @@ int xfrm_output(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
-	return xfrm_output2(sk, skb);
+	return xfrm_output2(net, sk, skb);
 }
 EXPORT_SYMBOL_GPL(xfrm_output);
 
-- 
2.2.1
