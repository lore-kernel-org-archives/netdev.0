From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] net: propagate sock pointer through netfilter hooks
Date: Fri, 15 Aug 2014 20:32:54 +0200
Message-ID: <1408127576-11518-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, stephen@networkplumber.org,
	cwang@twopensource.com, pshelar@nicira.com,
	nicolas.dichtel@6wind.com, therbert@google.com,
	dborkman@redhat.com, edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:53696 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbaHOSdB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2014 14:33:01 -0400
Received: by mail-wi0-f172.google.com with SMTP id n3so1204028wiv.17
        for <netdev@vger.kernel.org>; Fri, 15 Aug 2014 11:32:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When output function (ip6_finish_output2 for example) needs to be called
with sock pointer, we need to push sock pointer through the netfilter
hooks. This patch does that.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h                      |  16 +++-
 include/linux/netfilter.h                      |  64 +++++++++------
 include/linux/netfilter_bridge.h               |   5 +-
 include/net/dn_neigh.h                         |   4 +-
 include/net/ip.h                               |  10 ++-
 include/net/ip6_route.h                        |   3 +-
 include/net/ipv6.h                             |   2 +-
 include/net/netfilter/nf_queue.h               |   3 +-
 net/bridge/br_forward.c                        |  12 +--
 net/bridge/br_input.c                          |  14 ++--
 net/bridge/br_multicast.c                      |   4 +-
 net/bridge/br_netfilter.c                      | 108 ++++++++++++++-----------
 net/bridge/br_private.h                        |   6 +-
 net/bridge/br_stp_bpdu.c                       |   4 +-
 net/bridge/netfilter/ebtable_filter.c          |  10 ++-
 net/bridge/netfilter/ebtable_nat.c             |  10 ++-
 net/bridge/netfilter/nf_tables_bridge.c        |   3 +-
 net/core/dev.c                                 |  10 +--
 net/decnet/dn_neigh.c                          |  14 ++--
 net/decnet/dn_nsp_in.c                         |   6 +-
 net/decnet/dn_route.c                          |  28 +++----
 net/decnet/netfilter/dn_rtmsg.c                |   9 ++-
 net/ipv4/arp.c                                 |  10 ++-
 net/ipv4/ip_forward.c                          |   4 +-
 net/ipv4/ip_input.c                            |  10 +--
 net/ipv4/ip_output.c                           |  43 +++++-----
 net/ipv4/ipmr.c                                |   6 +-
 net/ipv4/netfilter/arptable_filter.c           |   5 +-
 net/ipv4/netfilter/ipt_CLUSTERIP.c             |   3 +-
 net/ipv4/netfilter/ipt_SYNPROXY.c              |  11 +--
 net/ipv4/netfilter/iptable_filter.c            |   5 +-
 net/ipv4/netfilter/iptable_mangle.c            |   8 +-
 net/ipv4/netfilter/iptable_nat.c               |  22 ++---
 net/ipv4/netfilter/iptable_raw.c               |   5 +-
 net/ipv4/netfilter/iptable_security.c          |   5 +-
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |  30 +++----
 net/ipv4/netfilter/nf_defrag_ipv4.c            |  11 +--
 net/ipv4/netfilter/nf_tables_arp.c             |   8 +-
 net/ipv4/netfilter/nf_tables_ipv4.c            |  24 +++---
 net/ipv4/netfilter/nft_chain_nat_ipv4.c        |  36 +++++----
 net/ipv4/netfilter/nft_chain_route_ipv4.c      |  11 +--
 net/ipv4/raw.c                                 |   4 +-
 net/ipv4/xfrm4_input.c                         |   4 +-
 net/ipv4/xfrm4_output.c                        |   6 +-
 net/ipv6/ip6_input.c                           |  10 +--
 net/ipv6/ip6_output.c                          |  33 ++++----
 net/ipv6/ip6mr.c                               |   6 +-
 net/ipv6/mcast.c                               |   8 +-
 net/ipv6/ndisc.c                               |   4 +-
 net/ipv6/netfilter/ip6t_SYNPROXY.c             |  11 +--
 net/ipv6/netfilter/ip6table_filter.c           |   5 +-
 net/ipv6/netfilter/ip6table_mangle.c           |   5 +-
 net/ipv6/netfilter/ip6table_nat.c              |  22 ++---
 net/ipv6/netfilter/ip6table_raw.c              |   5 +-
 net/ipv6/netfilter/ip6table_security.c         |   5 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |  30 +++----
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |   6 +-
 net/ipv6/netfilter/nf_tables_ipv6.c            |  24 +++---
 net/ipv6/netfilter/nft_chain_nat_ipv6.c        |  48 ++++++-----
 net/ipv6/netfilter/nft_chain_route_ipv6.c      |  12 +--
 net/ipv6/output_core.c                         |   4 +-
 net/ipv6/raw.c                                 |   4 +-
 net/ipv6/xfrm6_input.c                         |   2 +-
 net/ipv6/xfrm6_output.c                        |   6 +-
 net/netfilter/core.c                           |  17 ++--
 net/netfilter/ipvs/ip_vs_core.c                |  56 +++++++------
 net/netfilter/ipvs/ip_vs_xmit.c                |   8 +-
 net/netfilter/nf_internals.h                   |  16 ++--
 net/netfilter/nf_queue.c                       |  24 +++---
 net/xfrm/xfrm_output.c                         |  10 +--
 security/selinux/hooks.c                       |  55 +++++++------
 71 files changed, 577 insertions(+), 475 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3837739..4d875aa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2083,8 +2083,13 @@ int dev_alloc_name(struct net_device *dev, const char *name);
 int dev_open(struct net_device *dev);
 int dev_close(struct net_device *dev);
 void dev_disable_lro(struct net_device *dev);
-int dev_loopback_xmit(struct sk_buff *newskb);
-int dev_queue_xmit(struct sk_buff *skb);
+int dev_loopback_xmit(struct sock *sk, struct sk_buff *newskb);
+int dev_queue_xmit_sk(struct sock *sk, struct sk_buff *skb);
+static inline int dev_queue_xmit(struct sk_buff *skb)
+{
+	return dev_queue_xmit_sk(NULL, skb);
+}
+
 int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv);
 int register_netdevice(struct net_device *dev);
 void unregister_netdevice_queue(struct net_device *dev, struct list_head *head);
@@ -2718,7 +2723,12 @@ static inline void dev_consume_skb_any(struct sk_buff *skb)
 
 int netif_rx(struct sk_buff *skb);
 int netif_rx_ni(struct sk_buff *skb);
-int netif_receive_skb(struct sk_buff *skb);
+int netif_receive_skb_sk(struct sock *sk, struct sk_buff *skb);
+static inline int netif_receive_skb(struct sk_buff *skb)
+{
+	return netif_receive_skb_sk(NULL, skb);
+}
+
 gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb);
 void napi_gro_flush(struct napi_struct *napi, bool flush_old);
 struct sk_buff *napi_get_frags(struct napi_struct *napi);
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 2077489..cd93edc 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -44,10 +44,11 @@ struct sk_buff;
 
 struct nf_hook_ops;
 typedef unsigned int nf_hookfn(const struct nf_hook_ops *ops,
+			       struct sock *sk,
 			       struct sk_buff *skb,
 			       const struct net_device *in,
 			       const struct net_device *out,
-			       int (*okfn)(struct sk_buff *));
+			       int (*okfn)(struct sock *, struct sk_buff *));
 
 struct nf_hook_ops {
 	struct list_head list;
@@ -117,9 +118,10 @@ static inline bool nf_hooks_active(u_int8_t pf, unsigned int hook)
 }
 #endif
 
-int nf_hook_slow(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
+int nf_hook_slow(u_int8_t pf, unsigned int hook,
+		 struct sock *sk, struct sk_buff *skb,
 		 struct net_device *indev, struct net_device *outdev,
-		 int (*okfn)(struct sk_buff *), int thresh);
+		 int (*okfn)(struct sock *, struct sk_buff *), int thresh);
 
 /**
  *	nf_hook_thresh - call a netfilter hook
@@ -129,23 +131,27 @@ int nf_hook_slow(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
  *	value indicates the packet has been consumed by the hook.
  */
 static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
+				 struct sock *sk,
 				 struct sk_buff *skb,
 				 struct net_device *indev,
 				 struct net_device *outdev,
-				 int (*okfn)(struct sk_buff *), int thresh)
+				 int (*okfn)(struct sock *, struct sk_buff *),
+				 int thresh)
 {
 	if (nf_hooks_active(pf, hook))
-		return nf_hook_slow(pf, hook, skb, indev, outdev, okfn, thresh);
+		return nf_hook_slow(pf, hook, sk, skb,
+				    indev, outdev, okfn, thresh);
 	return 1;
 }
 
-static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
+static inline int nf_hook(u_int8_t pf, unsigned int hook,
+			  struct sock *sk, struct sk_buff *skb,
 			  struct net_device *indev, struct net_device *outdev,
-			  int (*okfn)(struct sk_buff *))
+			  int (*okfn)(struct sock *, struct sk_buff *))
 {
-	return nf_hook_thresh(pf, hook, skb, indev, outdev, okfn, INT_MIN);
+	return nf_hook_thresh(pf, hook, sk, skb, indev, outdev, okfn, INT_MIN);
 }
-                   
+
 /* Activate hook; either okfn or kfree_skb called, unless a hook
    returns NF_STOLEN (in which case, it's up to the hook to deal with
    the consequences).
@@ -164,35 +170,38 @@ static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
 */
 
 static inline int
-NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct sk_buff *skb,
+NF_HOOK_THRESH(uint8_t pf, unsigned int hook,
+	       struct sock *sk, struct sk_buff *skb,
 	       struct net_device *in, struct net_device *out,
-	       int (*okfn)(struct sk_buff *), int thresh)
+	       int (*okfn)(struct sock *, struct sk_buff *), int thresh)
 {
-	int ret = nf_hook_thresh(pf, hook, skb, in, out, okfn, thresh);
+	int ret = nf_hook_thresh(pf, hook, sk, skb, in, out, okfn, thresh);
 	if (ret == 1)
-		ret = okfn(skb);
+		ret = okfn(sk, skb);
 	return ret;
 }
 
 static inline int
-NF_HOOK_COND(uint8_t pf, unsigned int hook, struct sk_buff *skb,
+NF_HOOK_COND(uint8_t pf, unsigned int hook,
+	     struct sock *sk, struct sk_buff *skb,
 	     struct net_device *in, struct net_device *out,
-	     int (*okfn)(struct sk_buff *), bool cond)
+	     int (*okfn)(struct sock *, struct sk_buff *), bool cond)
 {
 	int ret;
 
 	if (!cond ||
-	    ((ret = nf_hook_thresh(pf, hook, skb, in, out, okfn, INT_MIN)) == 1))
-		ret = okfn(skb);
+	    ((ret = nf_hook_thresh(pf, hook, sk, skb, in, out, okfn, INT_MIN)) == 1))
+		ret = okfn(sk, skb);
 	return ret;
 }
 
 static inline int
-NF_HOOK(uint8_t pf, unsigned int hook, struct sk_buff *skb,
+NF_HOOK(uint8_t pf, unsigned int hook,
+	struct sock *sk, struct sk_buff *skb,
 	struct net_device *in, struct net_device *out,
-	int (*okfn)(struct sk_buff *))
+	int (*okfn)(struct sock *, struct sk_buff *))
 {
-	return NF_HOOK_THRESH(pf, hook, skb, in, out, okfn, INT_MIN);
+	return NF_HOOK_THRESH(pf, hook, sk, skb, in, out, okfn, INT_MIN);
 }
 
 /* Call setsockopt() */
@@ -292,19 +301,24 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 }
 
 #else /* !CONFIG_NETFILTER */
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
-#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond) (okfn)(skb)
+#define NF_HOOK(pf, hook, sk, skb, indev, outdev, okfn) \
+	(okfn)(sk, skb)
+#define NF_HOOK_COND(pf, hook, sk, skb, indev, outdev, okfn, cond) \
+	(okfn)(sk, skb)
 static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
+				 struct sock *sk,
 				 struct sk_buff *skb,
 				 struct net_device *indev,
 				 struct net_device *outdev,
-				 int (*okfn)(struct sk_buff *), int thresh)
+				 int (*okfn)(struct sock *, struct sk_buff *),
+				 int thresh)
 {
 	return okfn(skb);
 }
-static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
+static inline int nf_hook(u_int8_t pf, unsigned int hook,
+			  struct sock *sk, struct sk_buff *skb,
 			  struct net_device *indev, struct net_device *outdev,
-			  int (*okfn)(struct sk_buff *))
+			  int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return 1;
 }
diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 8ab1c27..c3633a9 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -53,7 +53,8 @@ static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 	return 0;
 }
 
-int br_handle_frame_finish(struct sk_buff *skb);
+int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb);
+
 /* Only used in br_device.c */
 static inline int br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 {
@@ -64,7 +65,7 @@ static inline int br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN),
 				       skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
 	skb->dev = nf_bridge->physindev;
-	return br_handle_frame_finish(skb);
+	return br_handle_frame_finish(NULL, skb);
 }
 
 /* This is called by the IP fragmenting code and it ensures there is
diff --git a/include/net/dn_neigh.h b/include/net/dn_neigh.h
index fac4e3f..1c229ea 100644
--- a/include/net/dn_neigh.h
+++ b/include/net/dn_neigh.h
@@ -18,8 +18,8 @@ struct dn_neigh {
 
 void dn_neigh_init(void);
 void dn_neigh_cleanup(void);
-int dn_neigh_router_hello(struct sk_buff *skb);
-int dn_neigh_endnode_hello(struct sk_buff *skb);
+int dn_neigh_router_hello(struct sock *sk, struct sk_buff *skb);
+int dn_neigh_endnode_hello(struct sock *sk, struct sk_buff *skb);
 void dn_neigh_pointopoint_hello(struct sk_buff *skb);
 int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n);
 
diff --git a/include/net/ip.h b/include/net/ip.h
index db4a771..8306ce9 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -107,10 +107,16 @@ int ip_local_deliver(struct sk_buff *skb);
 int ip_mr_input(struct sk_buff *skb);
 int ip_output(struct sock *sk, struct sk_buff *skb);
 int ip_mc_output(struct sock *sk, struct sk_buff *skb);
-int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
+int ip_fragment(struct sock *sk, struct sk_buff *skb,
+		int (*output)(struct sock *sk, struct sk_buff *));
 int ip_do_nat(struct sk_buff *skb);
 void ip_send_check(struct iphdr *ip);
-int __ip_local_out(struct sk_buff *skb);
+int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
+static inline int __ip_local_out(struct sk_buff *skb)
+{
+	return __ip_local_out_sk(NULL, skb);
+}
+
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb);
 static inline int ip_local_out(struct sk_buff *skb)
 {
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 1d09b46..e0f7fd6 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -170,7 +170,8 @@ static inline bool ipv6_anycast_destination(const struct sk_buff *skb)
 	return rt->rt6i_flags & RTF_ANYCAST;
 }
 
-int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
+int ip6_fragment(struct sock *sk, struct sk_buff *skb,
+		 int (*output)(struct sock *, struct sk_buff *));
 
 static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
 {
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index a2db816..e8ac138 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -763,7 +763,7 @@ static inline u8 ip6_tclass(__be32 flowinfo)
 int ipv6_rcv(struct sk_buff *skb, struct net_device *dev,
 	     struct packet_type *pt, struct net_device *orig_dev);
 
-int ip6_rcv_finish(struct sk_buff *skb);
+int ip6_rcv_finish(struct sock *sk, struct sk_buff *skb);
 
 /*
  *	upper-layer output functions
diff --git a/include/net/netfilter/nf_queue.h b/include/net/netfilter/nf_queue.h
index 84a53d7..bdc3890 100644
--- a/include/net/netfilter/nf_queue.h
+++ b/include/net/netfilter/nf_queue.h
@@ -8,6 +8,7 @@
 /* Each queued (to userspace) skbuff has one of these. */
 struct nf_queue_entry {
 	struct list_head	list;
+	struct sock		*sk;
 	struct sk_buff		*skb;
 	unsigned int		id;
 
@@ -17,7 +18,7 @@ struct nf_queue_entry {
 	unsigned int		hook;
 	struct net_device	*indev;
 	struct net_device	*outdev;
-	int			(*okfn)(struct sk_buff *);
+	int			(*okfn)(struct sock *, struct sk_buff *);
 
 	/* extra space to store route keys */
 };
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 056b67b..81c63cb 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -35,7 +35,7 @@ static inline int should_deliver(const struct net_bridge_port *p,
 		p->state == BR_STATE_FORWARDING;
 }
 
-int br_dev_queue_push_xmit(struct sk_buff *skb)
+int br_dev_queue_push_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	/* ip_fragment doesn't copy the MAC header */
 	if (nf_bridge_maybe_copy_header(skb) ||
@@ -50,10 +50,10 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
 	return 0;
 }
 
-int br_forward_finish(struct sk_buff *skb)
+int br_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
-	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING, skb, NULL, skb->dev,
-		       br_dev_queue_push_xmit);
+	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING, sk, skb, NULL,
+		       skb->dev, br_dev_queue_push_xmit);
 
 }
 
@@ -75,7 +75,7 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 		return;
 	}
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb, NULL, skb->dev,
 		br_forward_finish);
 }
 
@@ -96,7 +96,7 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 	skb->dev = to->dev;
 	skb_forward_csum(skb);
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, indev, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, NULL, skb, indev, skb->dev,
 		br_forward_finish);
 }
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 366c436..e7c7e32 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -53,12 +53,12 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	if (!skb)
 		return NET_RX_DROP;
 
-	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
-		       netif_receive_skb);
+	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, NULL, skb, indev, NULL,
+		       netif_receive_skb_sk);
 }
 
 /* note: already called with rcu_read_lock */
-int br_handle_frame_finish(struct sk_buff *skb)
+int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb)
 {
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
@@ -142,7 +142,7 @@ drop:
 }
 
 /* note: already called with rcu_read_lock */
-static int br_handle_local_finish(struct sk_buff *skb)
+static int br_handle_local_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 	u16 vid = 0;
@@ -212,7 +212,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		}
 
 		/* Deliver packet to local host only */
-		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
+		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, NULL, skb, skb->dev,
 			    NULL, br_handle_local_finish)) {
 			return RX_HANDLER_CONSUMED; /* consumed by filter */
 		} else {
@@ -237,8 +237,8 @@ forward:
 		if (ether_addr_equal(p->br->dev->dev_addr, dest))
 			skb->pkt_type = PACKET_HOST;
 
-		NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
-			br_handle_frame_finish);
+		NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, NULL, skb, skb->dev,
+			NULL, br_handle_frame_finish);
 		break;
 	default:
 drop:
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 7751c92..60a5beb 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -815,8 +815,8 @@ static void __br_multicast_send_query(struct net_bridge *br,
 	if (port) {
 		__skb_push(skb, sizeof(struct ethhdr));
 		skb->dev = port->dev;
-		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
-			dev_queue_xmit);
+		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb, NULL,
+			skb->dev, dev_queue_xmit_sk);
 	} else {
 		br_multicast_select_own_querier(br, ip, skb);
 		netif_rx(skb);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index a615264..f6f7a4b 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -343,7 +343,7 @@ int nf_bridge_copy_header(struct sk_buff *skb)
 /* PF_BRIDGE/PRE_ROUTING *********************************************/
 /* Undo the changes made for ip6tables PREROUTING and continue the
  * bridge PRE_ROUTING hook. */
-static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
+static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct rtable *rt;
@@ -364,8 +364,8 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
-		       br_handle_frame_finish, 1);
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, sk, skb, skb->dev,
+		       NULL, br_handle_frame_finish, 1);
 
 	return 0;
 }
@@ -375,7 +375,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
  * don't, we use the neighbour framework to find out. In both cases, we make
  * sure that br_handle_frame_finish() is called afterwards.
  */
-static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
+static int br_nf_pre_routing_finish_bridge(struct sock *sk, struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct neighbour *neigh;
@@ -392,7 +392,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 		if (neigh->hh.hh_len) {
 			neigh_hh_bridge(&neigh->hh, skb);
 			skb->dev = nf_bridge->physindev;
-			ret = br_handle_frame_finish(skb);
+			ret = br_handle_frame_finish(sk, skb);
 		} else {
 			/* the neighbour function below overwrites the complete
 			 * MAC header, so we save the Ethernet source address and
@@ -452,7 +452,7 @@ free_skb:
  * device, we proceed as if ip_route_input() succeeded. If it differs from the
  * logical bridge port or if ip_route_output_key() fails we drop the packet.
  */
-static int br_nf_pre_routing_finish(struct sk_buff *skb)
+static int br_nf_pre_routing_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	struct iphdr *iph = ip_hdr(skb);
@@ -501,7 +501,7 @@ bridged_dnat:
 				nf_bridge_push_encap_header(skb);
 				NF_HOOK_THRESH(NFPROTO_BRIDGE,
 					       NF_BR_PRE_ROUTING,
-					       skb, skb->dev, NULL,
+					       sk, skb, skb->dev, NULL,
 					       br_nf_pre_routing_finish_bridge,
 					       1);
 				return 0;
@@ -521,8 +521,8 @@ bridged_dnat:
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
-		       br_handle_frame_finish, 1);
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, sk, skb, skb->dev,
+		       NULL, br_handle_frame_finish, 1);
 
 	return 0;
 }
@@ -621,11 +621,13 @@ bad:
 
 /* Replicate the checks that IPv6 does on packet reception and pass the packet
  * to ip6tables, which doesn't support NAT, so things are fairly simple. */
-static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
-					   struct sk_buff *skb,
-					   const struct net_device *in,
-					   const struct net_device *out,
-					   int (*okfn)(struct sk_buff *))
+static unsigned int
+br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
+		       struct sock *sk,
+		       struct sk_buff *skb,
+		       const struct net_device *in,
+		       const struct net_device *out,
+		       int (*okfn)(struct sock *, struct sk_buff *))
 {
 	const struct ipv6hdr *hdr;
 	u32 pkt_len;
@@ -659,7 +661,7 @@ static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
 		return NF_DROP;
 
 	skb->protocol = htons(ETH_P_IPV6);
-	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, sk, skb, skb->dev, NULL,
 		br_nf_pre_routing_finish_ipv6);
 
 	return NF_STOLEN;
@@ -671,11 +673,13 @@ static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
  * receiving device) to make netfilter happy, the REDIRECT
  * target in particular.  Save the original destination IP
  * address to be able to detect DNAT afterwards. */
-static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
-				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+static unsigned int
+br_nf_pre_routing(const struct nf_hook_ops *ops,
+		  struct sock *sk,
+		  struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct net_bridge_port *p;
 	struct net_bridge *br;
@@ -694,7 +698,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 			return NF_ACCEPT;
 
 		nf_bridge_pull_encap_header_rcsum(skb);
-		return br_nf_pre_routing_ipv6(ops, skb, in, out, okfn);
+		return br_nf_pre_routing_ipv6(ops, sk, skb, in, out, okfn);
 	}
 
 	if (!brnf_call_iptables && !br->nf_call_iptables)
@@ -716,7 +720,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 	store_orig_dstaddr(skb);
 	skb->protocol = htons(ETH_P_IP);
 
-	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, sk, skb, skb->dev, NULL,
 		br_nf_pre_routing_finish);
 
 	return NF_STOLEN;
@@ -731,17 +735,18 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
  * register an IPv4 PRE_ROUTING 'sabotage' hook that will
  * prevent this from happening. */
 static unsigned int br_nf_local_in(const struct nf_hook_ops *ops,
+				   struct sock *sk,
 				   struct sk_buff *skb,
 				   const struct net_device *in,
 				   const struct net_device *out,
-				   int (*okfn)(struct sk_buff *))
+				   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	br_drop_fake_rtable(skb);
 	return NF_ACCEPT;
 }
 
 /* PF_BRIDGE/FORWARD *************************************************/
-static int br_nf_forward_finish(struct sk_buff *skb)
+static int br_nf_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct net_device *in;
@@ -758,7 +763,7 @@ static int br_nf_forward_finish(struct sk_buff *skb)
 	}
 	nf_bridge_push_encap_header(skb);
 
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, in,
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, sk, skb, in,
 		       skb->dev, br_forward_finish, 1);
 	return 0;
 }
@@ -769,11 +774,13 @@ static int br_nf_forward_finish(struct sk_buff *skb)
  * but we are still able to filter on the 'real' indev/outdev
  * because of the physdev module. For ARP, indev and outdev are the
  * bridge ports. */
-static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
-				     struct sk_buff *skb,
-				     const struct net_device *in,
-				     const struct net_device *out,
-				     int (*okfn)(struct sk_buff *))
+static unsigned int
+br_nf_forward_ip(const struct nf_hook_ops *ops,
+		 struct sock *sk,
+		 struct sk_buff *skb,
+		 const struct net_device *in,
+		 const struct net_device *out,
+		 int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct nf_bridge_info *nf_bridge;
 	struct net_device *parent;
@@ -817,17 +824,19 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	else
 		skb->protocol = htons(ETH_P_IPV6);
 
-	NF_HOOK(pf, NF_INET_FORWARD, skb, brnf_get_logical_dev(skb, in), parent,
-		br_nf_forward_finish);
+	NF_HOOK(pf, NF_INET_FORWARD, sk, skb, brnf_get_logical_dev(skb, in),
+		parent, br_nf_forward_finish);
 
 	return NF_STOLEN;
 }
 
-static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
-				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+static unsigned int
+br_nf_forward_arp(const struct nf_hook_ops *ops,
+		  struct sock *sk,
+		  struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct net_bridge_port *p;
 	struct net_bridge *br;
@@ -853,14 +862,14 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 	}
 	*d = (struct net_device *)in;
-	NF_HOOK(NFPROTO_ARP, NF_ARP_FORWARD, skb, (struct net_device *)in,
+	NF_HOOK(NFPROTO_ARP, NF_ARP_FORWARD, sk, skb, (struct net_device *)in,
 		(struct net_device *)out, br_nf_forward_finish);
 
 	return NF_STOLEN;
 }
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV4)
-static int br_nf_dev_queue_xmit(struct sk_buff *skb)
+static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	int ret;
 
@@ -870,9 +879,9 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 		if (br_parse_ip_options(skb))
 			/* Drop invalid packet */
 			return NF_DROP;
-		ret = ip_fragment(skb, br_dev_queue_push_xmit);
+		ret = ip_fragment(sk, skb, br_dev_queue_push_xmit);
 	} else
-		ret = br_dev_queue_push_xmit(skb);
+		ret = br_dev_queue_push_xmit(sk, skb);
 
 	return ret;
 }
@@ -884,11 +893,13 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 #endif
 
 /* PF_BRIDGE/POST_ROUTING ********************************************/
-static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
-				       struct sk_buff *skb,
-				       const struct net_device *in,
-				       const struct net_device *out,
-				       int (*okfn)(struct sk_buff *))
+static unsigned int
+br_nf_post_routing(const struct nf_hook_ops *ops,
+		   struct sock *sk,
+		   struct sk_buff *skb,
+		   const struct net_device *in,
+		   const struct net_device *out,
+		   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct net_device *realoutdev = bridge_parent(skb->dev);
@@ -921,7 +932,7 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 	else
 		skb->protocol = htons(ETH_P_IPV6);
 
-	NF_HOOK(pf, NF_INET_POST_ROUTING, skb, NULL, realoutdev,
+	NF_HOOK(pf, NF_INET_POST_ROUTING, sk, skb, NULL, realoutdev,
 		br_nf_dev_queue_xmit);
 
 	return NF_STOLEN;
@@ -931,10 +942,11 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 /* Don't hand locally destined packets to PF_INET(6)/PRE_ROUTING
  * for the second time. */
 static unsigned int ip_sabotage_in(const struct nf_hook_ops *ops,
+				   struct sock *sk,
 				   struct sk_buff *skb,
 				   const struct net_device *in,
 				   const struct net_device *out,
-				   int (*okfn)(struct sk_buff *))
+				   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	if (skb->nf_bridge &&
 	    !(skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)) {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 62a7fa2..c01c14a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -405,10 +405,10 @@ void br_fdb_unsync_static(struct net_bridge *br, struct net_bridge_port *p);
 
 /* br_forward.c */
 void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
-int br_dev_queue_push_xmit(struct sk_buff *skb);
+int br_dev_queue_push_xmit(struct sock *sk, struct sk_buff *skb);
 void br_forward(const struct net_bridge_port *to,
 		struct sk_buff *skb, struct sk_buff *skb0);
-int br_forward_finish(struct sk_buff *skb);
+int br_forward_finish(struct sock *sk, struct sk_buff *skb);
 void br_flood_deliver(struct net_bridge *br, struct sk_buff *skb, bool unicast);
 void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
 		      struct sk_buff *skb2, bool unicast);
@@ -426,7 +426,7 @@ void br_port_flags_change(struct net_bridge_port *port, unsigned long mask);
 void br_manage_promisc(struct net_bridge *br);
 
 /* br_input.c */
-int br_handle_frame_finish(struct sk_buff *skb);
+int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb);
 rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
 
 static inline bool br_rx_handler_check_rcu(const struct net_device *dev)
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index bdb459d..087b980 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -54,8 +54,8 @@ static void br_send_bpdu(struct net_bridge_port *p,
 
 	skb_reset_mac_header(skb);
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
-		dev_queue_xmit);
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb, NULL, skb->dev,
+		dev_queue_xmit_sk);
 }
 
 static inline void br_set_ticks(unsigned char *dest, int j)
diff --git a/net/bridge/netfilter/ebtable_filter.c b/net/bridge/netfilter/ebtable_filter.c
index ce205aa..8025b7c 100644
--- a/net/bridge/netfilter/ebtable_filter.c
+++ b/net/bridge/netfilter/ebtable_filter.c
@@ -57,18 +57,20 @@ static const struct ebt_table frame_filter = {
 };
 
 static unsigned int
-ebt_in_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ebt_in_hook(const struct nf_hook_ops *ops,
+	    struct sock *sk, struct sk_buff *skb,
 	    const struct net_device *in, const struct net_device *out,
-	    int (*okfn)(struct sk_buff *))
+	    int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return ebt_do_table(ops->hooknum, skb, in, out,
 			    dev_net(in)->xt.frame_filter);
 }
 
 static unsigned int
-ebt_out_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ebt_out_hook(const struct nf_hook_ops *ops,
+	     struct sock *sk, struct sk_buff *skb,
 	     const struct net_device *in, const struct net_device *out,
-	     int (*okfn)(struct sk_buff *))
+	     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return ebt_do_table(ops->hooknum, skb, in, out,
 			    dev_net(out)->xt.frame_filter);
diff --git a/net/bridge/netfilter/ebtable_nat.c b/net/bridge/netfilter/ebtable_nat.c
index a0ac298..b51280c 100644
--- a/net/bridge/netfilter/ebtable_nat.c
+++ b/net/bridge/netfilter/ebtable_nat.c
@@ -57,18 +57,20 @@ static struct ebt_table frame_nat = {
 };
 
 static unsigned int
-ebt_nat_in(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ebt_nat_in(const struct nf_hook_ops *ops,
+	   struct sock *sk, struct sk_buff *skb,
 	   const struct net_device *in, const struct net_device *out,
-	   int (*okfn)(struct sk_buff *))
+	   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return ebt_do_table(ops->hooknum, skb, in, out,
 			    dev_net(in)->xt.frame_nat);
 }
 
 static unsigned int
-ebt_nat_out(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ebt_nat_out(const struct nf_hook_ops *ops,
+	    struct sock *sk, struct sk_buff *skb,
 	    const struct net_device *in, const struct net_device *out,
-	    int (*okfn)(struct sk_buff *))
+	    int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return ebt_do_table(ops->hooknum, skb, in, out,
 			    dev_net(out)->xt.frame_nat);
diff --git a/net/bridge/netfilter/nf_tables_bridge.c b/net/bridge/netfilter/nf_tables_bridge.c
index 5bcc0d8..a9e48cf 100644
--- a/net/bridge/netfilter/nf_tables_bridge.c
+++ b/net/bridge/netfilter/nf_tables_bridge.c
@@ -16,10 +16,11 @@
 
 static unsigned int
 nft_do_chain_bridge(const struct nf_hook_ops *ops,
+		    struct sock *sk,
 		    struct sk_buff *skb,
 		    const struct net_device *in,
 		    const struct net_device *out,
-		    int (*okfn)(struct sk_buff *))
+		    int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct nft_pktinfo pkt;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index b65a505..b71c762 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2829,7 +2829,7 @@ static DEFINE_PER_CPU(int, xmit_recursion);
  *	dev_loopback_xmit - loop back @skb
  *	@skb: buffer to transmit
  */
-int dev_loopback_xmit(struct sk_buff *skb)
+int dev_loopback_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	skb_reset_mac_header(skb);
 	__skb_pull(skb, skb_network_offset(skb));
@@ -2954,11 +2954,11 @@ out:
 	return rc;
 }
 
-int dev_queue_xmit(struct sk_buff *skb)
+int dev_queue_xmit_sk(struct sock *sk, struct sk_buff *skb)
 {
 	return __dev_queue_xmit(skb, NULL);
 }
-EXPORT_SYMBOL(dev_queue_xmit);
+EXPORT_SYMBOL(dev_queue_xmit_sk);
 
 int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv)
 {
@@ -3780,13 +3780,13 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
  *	NET_RX_SUCCESS: no congestion
  *	NET_RX_DROP: packet was dropped
  */
-int netif_receive_skb(struct sk_buff *skb)
+int netif_receive_skb_sk(struct sock *sk, struct sk_buff *skb)
 {
 	trace_netif_receive_skb_entry(skb);
 
 	return netif_receive_skb_internal(skb);
 }
-EXPORT_SYMBOL(netif_receive_skb);
+EXPORT_SYMBOL(netif_receive_skb_sk);
 
 /* Network device is going away, flush any packets still pending
  * Called with irqs disabled.
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index c8121ce..8d8cab1 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -200,7 +200,7 @@ static void dn_short_error_report(struct neighbour *neigh, struct sk_buff *skb)
 	kfree_skb(skb);
 }
 
-static int dn_neigh_output_packet(struct sk_buff *skb)
+static int dn_neigh_output_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *)dst;
@@ -218,7 +218,7 @@ static int dn_neigh_output_packet(struct sk_buff *skb)
 	} while (read_seqretry(&neigh->ha_lock, seq));
 
 	if (err >= 0)
-		err = dev_queue_xmit(skb);
+		err = dev_queue_xmit_sk(sk, skb);
 	else {
 		kfree_skb(skb);
 		err = -EINVAL;
@@ -265,7 +265,7 @@ static int dn_long_output(struct neighbour *neigh, struct sk_buff *skb)
 
 	skb_reset_network_header(skb);
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, skb, NULL,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, NULL, skb, NULL,
 		       neigh->dev, dn_neigh_output_packet);
 }
 
@@ -301,7 +301,7 @@ static int dn_short_output(struct neighbour *neigh, struct sk_buff *skb)
 
 	skb_reset_network_header(skb);
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, skb, NULL,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, NULL, skb, NULL,
 		       neigh->dev, dn_neigh_output_packet);
 }
 
@@ -340,7 +340,7 @@ static int dn_phase3_output(struct neighbour *neigh, struct sk_buff *skb)
 
 	skb_reset_network_header(skb);
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, skb, NULL,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, NULL, skb, NULL,
 		       neigh->dev, dn_neigh_output_packet);
 }
 
@@ -362,7 +362,7 @@ void dn_neigh_pointopoint_hello(struct sk_buff *skb)
 /*
  * Ethernet router hello message received
  */
-int dn_neigh_router_hello(struct sk_buff *skb)
+int dn_neigh_router_hello(struct sock *sk, struct sk_buff *skb)
 {
 	struct rtnode_hello_message *msg = (struct rtnode_hello_message *)skb->data;
 
@@ -424,7 +424,7 @@ int dn_neigh_router_hello(struct sk_buff *skb)
 /*
  * Endnode hello message received
  */
-int dn_neigh_endnode_hello(struct sk_buff *skb)
+int dn_neigh_endnode_hello(struct sock *sk, struct sk_buff *skb)
 {
 	struct endnode_hello_message *msg = (struct endnode_hello_message *)skb->data;
 	struct neighbour *neigh;
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index fe5f014..0fe6872 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -714,7 +714,7 @@ out:
 	return ret;
 }
 
-static int dn_nsp_rx_packet(struct sk_buff *skb)
+static int dn_nsp_rx_packet(struct sock *sk2, struct sk_buff *skb)
 {
 	struct dn_skb_cb *cb = DN_SKB_CB(skb);
 	struct sock *sk = NULL;
@@ -814,8 +814,8 @@ free_out:
 
 int dn_nsp_rx(struct sk_buff *skb)
 {
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_IN, skb, skb->dev, NULL,
-		       dn_nsp_rx_packet);
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_IN, NULL, skb, skb->dev,
+		       NULL, dn_nsp_rx_packet);
 }
 
 /*
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index daccc4a..191860c 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -513,7 +513,7 @@ static int dn_return_long(struct sk_buff *skb)
  *
  * Returns: result of input function if route is found, error code otherwise
  */
-static int dn_route_rx_packet(struct sk_buff *skb)
+static int dn_route_rx_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct dn_skb_cb *cb;
 	int err;
@@ -574,8 +574,8 @@ static int dn_route_rx_long(struct sk_buff *skb)
 	ptr++;
 	cb->hops = *ptr++; /* Visit Count */
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_PRE_ROUTING, skb, skb->dev, NULL,
-		       dn_route_rx_packet);
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_PRE_ROUTING, NULL, skb, skb->dev,
+		       NULL, dn_route_rx_packet);
 
 drop_it:
 	kfree_skb(skb);
@@ -601,15 +601,15 @@ static int dn_route_rx_short(struct sk_buff *skb)
 	ptr += 2;
 	cb->hops = *ptr & 0x3f;
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_PRE_ROUTING, skb, skb->dev, NULL,
-		       dn_route_rx_packet);
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_PRE_ROUTING, NULL, skb, skb->dev,
+		       NULL, dn_route_rx_packet);
 
 drop_it:
 	kfree_skb(skb);
 	return NET_RX_DROP;
 }
 
-static int dn_route_discard(struct sk_buff *skb)
+static int dn_route_discard(struct sock *sk, struct sk_buff *skb)
 {
 	/*
 	 * I know we drop the packet here, but thats considered success in
@@ -619,7 +619,7 @@ static int dn_route_discard(struct sk_buff *skb)
 	return NET_RX_SUCCESS;
 }
 
-static int dn_route_ptp_hello(struct sk_buff *skb)
+static int dn_route_ptp_hello(struct sock *sk, struct sk_buff *skb)
 {
 	dn_dev_hello(skb);
 	dn_neigh_pointopoint_hello(skb);
@@ -705,22 +705,22 @@ int dn_route_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type
 		switch (flags & DN_RT_CNTL_MSK) {
 		case DN_RT_PKT_HELO:
 			return NF_HOOK(NFPROTO_DECNET, NF_DN_HELLO,
-				       skb, skb->dev, NULL,
+				       NULL, skb, skb->dev, NULL,
 				       dn_route_ptp_hello);
 
 		case DN_RT_PKT_L1RT:
 		case DN_RT_PKT_L2RT:
 			return NF_HOOK(NFPROTO_DECNET, NF_DN_ROUTE,
-				       skb, skb->dev, NULL,
+				       NULL, skb, skb->dev, NULL,
 				       dn_route_discard);
 		case DN_RT_PKT_ERTH:
 			return NF_HOOK(NFPROTO_DECNET, NF_DN_HELLO,
-				       skb, skb->dev, NULL,
+				       NULL, skb, skb->dev, NULL,
 				       dn_neigh_router_hello);
 
 		case DN_RT_PKT_EEDH:
 			return NF_HOOK(NFPROTO_DECNET, NF_DN_HELLO,
-				       skb, skb->dev, NULL,
+				       NULL, skb, skb->dev, NULL,
 				       dn_neigh_endnode_hello);
 		}
 	} else {
@@ -743,7 +743,7 @@ out:
 	return NET_RX_DROP;
 }
 
-static int dn_to_neigh_output(struct sk_buff *skb)
+static int dn_to_neigh_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *) dst;
@@ -778,7 +778,7 @@ static int dn_output(struct sock *sk, struct sk_buff *skb)
 	cb->rt_flags |= DN_RT_F_IE;
 	cb->hops = 0;
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_OUT, skb, NULL, dev,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_OUT, NULL, skb, NULL, dev,
 		       dn_to_neigh_output);
 
 error:
@@ -826,7 +826,7 @@ static int dn_forward(struct sk_buff *skb)
 	if (rt->rt_flags & RTCF_DOREDIRECT)
 		cb->rt_flags |= DN_RT_F_IE;
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_FORWARD, skb, dev, skb->dev,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_FORWARD, NULL, skb, dev, skb->dev,
 		       dn_to_neigh_output);
 
 drop:
diff --git a/net/decnet/netfilter/dn_rtmsg.c b/net/decnet/netfilter/dn_rtmsg.c
index e4d9560..2231e19 100644
--- a/net/decnet/netfilter/dn_rtmsg.c
+++ b/net/decnet/netfilter/dn_rtmsg.c
@@ -88,10 +88,11 @@ static void dnrmg_send_peer(struct sk_buff *skb)
 
 
 static unsigned int dnrmg_hook(const struct nf_hook_ops *ops,
-			struct sk_buff *skb,
-			const struct net_device *in,
-			const struct net_device *out,
-			int (*okfn)(struct sk_buff *))
+			       struct sock *sk,
+			       struct sk_buff *skb,
+			       const struct net_device *in,
+			       const struct net_device *out,
+			       int (*okfn)(struct sock *, struct sk_buff *))
 {
 	dnrmg_send_peer(skb);
 	return NF_ACCEPT;
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 1a9b99e..d86fd89 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -685,7 +685,8 @@ EXPORT_SYMBOL(arp_create);
 void arp_xmit(struct sk_buff *skb)
 {
 	/* Send it off, maybe filter it using firewalling first.  */
-	NF_HOOK(NFPROTO_ARP, NF_ARP_OUT, skb, NULL, skb->dev, dev_queue_xmit);
+	NF_HOOK(NFPROTO_ARP, NF_ARP_OUT, NULL, skb, NULL, skb->dev,
+		dev_queue_xmit_sk);
 }
 EXPORT_SYMBOL(arp_xmit);
 
@@ -719,7 +720,7 @@ EXPORT_SYMBOL(arp_send);
  *	Process an arp request.
  */
 
-static int arp_process(struct sk_buff *skb)
+static int arp_process(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
@@ -940,7 +941,7 @@ out:
 
 static void parp_redo(struct sk_buff *skb)
 {
-	arp_process(skb);
+	arp_process(NULL, skb);
 }
 
 
@@ -972,7 +973,8 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	memset(NEIGH_CB(skb), 0, sizeof(struct neighbour_cb));
 
-	return NF_HOOK(NFPROTO_ARP, NF_ARP_IN, skb, dev, NULL, arp_process);
+	return NF_HOOK(NFPROTO_ARP, NF_ARP_IN, NULL, skb, dev, NULL,
+		       arp_process);
 
 freeskb:
 	kfree_skb(skb);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 3a83ce5..4de5ceb 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -57,7 +57,7 @@ static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
 }
 
 
-static int ip_forward_finish(struct sk_buff *skb)
+static int ip_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct ip_options *opt	= &(IPCB(skb)->opt);
 
@@ -134,7 +134,7 @@ int ip_forward(struct sk_buff *skb)
 
 	skb->priority = rt_tos2priority(iph->tos);
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, skb, skb->dev,
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, NULL, skb, skb->dev,
 		       rt->dst.dev, ip_forward_finish);
 
 sr_failed:
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 3d4da2c..ba63e2c 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -187,7 +187,7 @@ bool ip_call_ra_chain(struct sk_buff *skb)
 	return false;
 }
 
-static int ip_local_deliver_finish(struct sk_buff *skb)
+static int ip_local_deliver_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
 
@@ -253,8 +253,8 @@ int ip_local_deliver(struct sk_buff *skb)
 			return 0;
 	}
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
-		       ip_local_deliver_finish);
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN, NULL, skb, skb->dev,
+		       NULL, ip_local_deliver_finish);
 }
 
 static inline bool ip_rcv_options(struct sk_buff *skb)
@@ -309,7 +309,7 @@ drop:
 int sysctl_ip_early_demux __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_ip_early_demux);
 
-static int ip_rcv_finish(struct sk_buff *skb)
+static int ip_rcv_finish(struct sock *sk, struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
@@ -450,7 +450,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, dev, NULL,
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, NULL, skb, dev, NULL,
 		       ip_rcv_finish);
 
 csum_error:
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 215af2b..f3ce43f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -91,21 +91,21 @@ void ip_send_check(struct iphdr *iph)
 }
 EXPORT_SYMBOL(ip_send_check);
 
-int __ip_local_out(struct sk_buff *skb)
+int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
 	struct iphdr *iph = ip_hdr(skb);
 
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
-	return nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT, skb, NULL,
-		       skb_dst(skb)->dev, dst_output);
+	return nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT, sk, skb, NULL,
+		       skb_dst(skb)->dev, dst_output_sk);
 }
 
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
 	int err;
 
-	err = __ip_local_out(skb);
+	err = __ip_local_out_sk(sk, skb);
 	if (likely(err == 1))
 		err = dst_output_sk(sk, skb);
 
@@ -163,7 +163,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
 
-static inline int ip_finish_output2(struct sk_buff *skb)
+static inline int ip_finish_output2(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct rtable *rt = (struct rtable *)dst;
@@ -211,7 +211,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	return -EINVAL;
 }
 
-static int ip_finish_output_gso(struct sk_buff *skb)
+static int ip_finish_output_gso(struct sock *sk, struct sk_buff *skb)
 {
 	netdev_features_t features;
 	struct sk_buff *segs;
@@ -220,7 +220,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 	/* common case: locally created skb or seglen is <= mtu */
 	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
 	      skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
-		return ip_finish_output2(skb);
+		return ip_finish_output2(sk, skb);
 
 	/* Slowpath -  GSO segment length is exceeding the dst MTU.
 	 *
@@ -243,7 +243,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 		int err;
 
 		segs->next = NULL;
-		err = ip_fragment(segs, ip_finish_output2);
+		err = ip_fragment(sk, segs, ip_finish_output2);
 
 		if (err && ret == 0)
 			ret = err;
@@ -253,22 +253,22 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 	return ret;
 }
 
-static int ip_finish_output(struct sk_buff *skb)
+static int ip_finish_output(struct sock *sk, struct sk_buff *skb)
 {
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
 	/* Policy lookup after SNAT yielded a new policy */
 	if (skb_dst(skb)->xfrm != NULL) {
 		IPCB(skb)->flags |= IPSKB_REROUTED;
-		return dst_output(skb);
+		return dst_output_sk(sk, skb);
 	}
 #endif
 	if (skb_is_gso(skb))
-		return ip_finish_output_gso(skb);
+		return ip_finish_output_gso(sk, skb);
 
 	if (skb->len > ip_skb_dst_mtu(skb))
-		return ip_fragment(skb, ip_finish_output2);
+		return ip_fragment(sk, skb, ip_finish_output2);
 
-	return ip_finish_output2(skb);
+	return ip_finish_output2(sk, skb);
 }
 
 int ip_mc_output(struct sock *sk, struct sk_buff *skb)
@@ -307,7 +307,7 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb)
 			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 			if (newskb)
 				NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING,
-					newskb, NULL, newskb->dev,
+					sk, newskb, NULL, newskb->dev,
 					dev_loopback_xmit);
 		}
 
@@ -322,11 +322,11 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb)
 	if (rt->rt_flags&RTCF_BROADCAST) {
 		struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 		if (newskb)
-			NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING, newskb,
+			NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, newskb,
 				NULL, newskb->dev, dev_loopback_xmit);
 	}
 
-	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb, NULL,
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb, NULL,
 			    skb->dev, ip_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
@@ -340,8 +340,8 @@ int ip_output(struct sock *sk, struct sk_buff *skb)
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
-	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb, NULL, dev,
-			    ip_finish_output,
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb, NULL,
+			    dev, ip_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
@@ -479,7 +479,8 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
  *	single device frame, and queue such a frame for sending.
  */
 
-int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
+int ip_fragment(struct sock *sk, struct sk_buff *skb,
+		int (*output)(struct sock *, struct sk_buff *))
 {
 	struct iphdr *iph;
 	int ptr;
@@ -592,7 +593,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 				ip_send_check(iph);
 			}
 
-			err = output(skb);
+			err = output(sk, skb);
 
 			if (!err)
 				IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
@@ -734,7 +735,7 @@ slow_path:
 
 		ip_send_check(iph);
 
-		err = output(skb2);
+		err = output(sk, skb2);
 		if (err)
 			goto fail;
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c803458..a0c5a05 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1670,7 +1670,7 @@ static void ip_encap(struct sk_buff *skb, __be32 saddr, __be32 daddr)
 	nf_reset(skb);
 }
 
-static inline int ipmr_forward_finish(struct sk_buff *skb)
+static inline int ipmr_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct ip_options *opt = &(IPCB(skb)->opt);
 
@@ -1680,7 +1680,7 @@ static inline int ipmr_forward_finish(struct sk_buff *skb)
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	return dst_output(skb);
+	return dst_output_sk(sk, skb);
 }
 
 /*
@@ -1779,7 +1779,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 	 * not mrouter) cannot join to more than one interface - it will
 	 * result in receiving multiple packets.
 	 */
-	NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, skb, skb->dev, dev,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, NULL, skb, skb->dev, dev,
 		ipmr_forward_finish);
 	return;
 
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 802ddec..d144035 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -27,9 +27,10 @@ static const struct xt_table packet_filter = {
 
 /* The work comes in here from netfilter.c */
 static unsigned int
-arptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+arptable_filter_hook(const struct nf_hook_ops *ops,
+		     struct sock *sk, struct sk_buff *skb,
 		     const struct net_device *in, const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	const struct net *net = dev_net((in != NULL) ? in : out);
 
diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
index 2510c02..7502660 100644
--- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
+++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
@@ -496,10 +496,11 @@ static void arp_print(struct arp_payload *payload)
 
 static unsigned int
 arp_mangle(const struct nf_hook_ops *ops,
+	   struct sock *sk,
 	   struct sk_buff *skb,
 	   const struct net_device *in,
 	   const struct net_device *out,
-	   int (*okfn)(struct sk_buff *))
+	   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct arphdr *arp = arp_hdr(skb);
 	struct arp_payload *payload;
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
index a313c3f..e5f11a3 100644
--- a/net/ipv4/netfilter/ipt_SYNPROXY.c
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -298,11 +298,12 @@ synproxy_tg4(struct sk_buff *skb, const struct xt_action_param *par)
 	return XT_CONTINUE;
 }
 
-static unsigned int ipv4_synproxy_hook(const struct nf_hook_ops *ops,
-				       struct sk_buff *skb,
-				       const struct net_device *in,
-				       const struct net_device *out,
-				       int (*okfn)(struct sk_buff *))
+static unsigned int
+ipv4_synproxy_hook(const struct nf_hook_ops *ops,
+		   struct sock *sk, struct sk_buff *skb,
+		   const struct net_device *in,
+		   const struct net_device *out,
+		   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct synproxy_net *snet = synproxy_pernet(dev_net(in ? : out));
 	enum ip_conntrack_info ctinfo;
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index e08a74a..b812ca5 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -33,9 +33,10 @@ static const struct xt_table packet_filter = {
 };
 
 static unsigned int
-iptable_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+iptable_filter_hook(const struct nf_hook_ops *ops,
+		    struct sock *sk, struct sk_buff *skb,
 		    const struct net_device *in, const struct net_device *out,
-		    int (*okfn)(struct sk_buff *))
+		    int (*okfn)(struct sock *, struct sk_buff *))
 {
 	const struct net *net;
 
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 6a5079c..974bab4 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -80,10 +80,10 @@ ipt_mangle_out(struct sk_buff *skb, const struct net_device *out)
 /* The work comes in here from netfilter.c. */
 static unsigned int
 iptable_mangle_hook(const struct nf_hook_ops *ops,
-		     struct sk_buff *skb,
-		     const struct net_device *in,
-		     const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		    struct sock *sk, struct sk_buff *skb,
+		    const struct net_device *in,
+		    const struct net_device *out,
+		    int (*okfn)(struct sock *, struct sk_buff *))
 {
 	if (ops->hooknum == NF_INET_LOCAL_OUT)
 		return ipt_mangle_out(skb, out);
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index f1787c0..d45ef30 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -62,10 +62,10 @@ static unsigned int nf_nat_rule_find(struct sk_buff *skb, unsigned int hooknum,
 
 static unsigned int
 nf_nat_ipv4_fn(const struct nf_hook_ops *ops,
-	       struct sk_buff *skb,
+	       struct sock *sk, struct sk_buff *skb,
 	       const struct net_device *in,
 	       const struct net_device *out,
-	       int (*okfn)(struct sk_buff *))
+	       int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -142,15 +142,15 @@ oif_changed:
 
 static unsigned int
 nf_nat_ipv4_in(const struct nf_hook_ops *ops,
-	       struct sk_buff *skb,
+	       struct sock *sk, struct sk_buff *skb,
 	       const struct net_device *in,
 	       const struct net_device *out,
-	       int (*okfn)(struct sk_buff *))
+	       int (*okfn)(struct sock *, struct sk_buff *))
 {
 	unsigned int ret;
 	__be32 daddr = ip_hdr(skb)->daddr;
 
-	ret = nf_nat_ipv4_fn(ops, skb, in, out, okfn);
+	ret = nf_nat_ipv4_fn(ops, sk, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    daddr != ip_hdr(skb)->daddr)
 		skb_dst_drop(skb);
@@ -160,10 +160,10 @@ nf_nat_ipv4_in(const struct nf_hook_ops *ops,
 
 static unsigned int
 nf_nat_ipv4_out(const struct nf_hook_ops *ops,
-		struct sk_buff *skb,
+		struct sock *sk, struct sk_buff *skb,
 		const struct net_device *in,
 		const struct net_device *out,
-		int (*okfn)(struct sk_buff *))
+		int (*okfn)(struct sock *, struct sk_buff *))
 {
 #ifdef CONFIG_XFRM
 	const struct nf_conn *ct;
@@ -177,7 +177,7 @@ nf_nat_ipv4_out(const struct nf_hook_ops *ops,
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_ipv4_fn(ops, skb, in, out, okfn);
+	ret = nf_nat_ipv4_fn(ops, sk, skb, in, out, okfn);
 #ifdef CONFIG_XFRM
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    !(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
@@ -200,10 +200,10 @@ nf_nat_ipv4_out(const struct nf_hook_ops *ops,
 
 static unsigned int
 nf_nat_ipv4_local_fn(const struct nf_hook_ops *ops,
-		     struct sk_buff *skb,
+		     struct sock *sk, struct sk_buff *skb,
 		     const struct net_device *in,
 		     const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	const struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -215,7 +215,7 @@ nf_nat_ipv4_local_fn(const struct nf_hook_ops *ops,
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_ipv4_fn(ops, skb, in, out, okfn);
+	ret = nf_nat_ipv4_fn(ops, sk, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index b2f7e8f..6f84bd5 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -20,9 +20,10 @@ static const struct xt_table packet_raw = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-iptable_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+iptable_raw_hook(const struct nf_hook_ops *ops,
+		 struct sock *sk, struct sk_buff *skb,
 		 const struct net_device *in, const struct net_device *out,
-		 int (*okfn)(struct sk_buff *))
+		 int (*okfn)(struct sock *, struct sk_buff *))
 {
 	const struct net *net;
 
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index c86647e..7412b52 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -37,10 +37,11 @@ static const struct xt_table security_table = {
 };
 
 static unsigned int
-iptable_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+iptable_security_hook(const struct nf_hook_ops *ops,
+		      struct sock *sk, struct sk_buff *skb,
 		      const struct net_device *in,
 		      const struct net_device *out,
-		      int (*okfn)(struct sk_buff *))
+		      int (*okfn)(struct sock *, struct sk_buff *))
 {
 	const struct net *net;
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index a054fe0..05a2483 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -93,10 +93,10 @@ static int ipv4_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 }
 
 static unsigned int ipv4_helper(const struct nf_hook_ops *ops,
-				struct sk_buff *skb,
+				struct sock *sk, struct sk_buff *skb,
 				const struct net_device *in,
 				const struct net_device *out,
-				int (*okfn)(struct sk_buff *))
+				int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -122,10 +122,10 @@ static unsigned int ipv4_helper(const struct nf_hook_ops *ops,
 }
 
 static unsigned int ipv4_confirm(const struct nf_hook_ops *ops,
-				 struct sk_buff *skb,
+				 struct sock *sk, struct sk_buff *skb,
 				 const struct net_device *in,
 				 const struct net_device *out,
-				 int (*okfn)(struct sk_buff *))
+				 int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -147,20 +147,22 @@ out:
 	return nf_conntrack_confirm(skb);
 }
 
-static unsigned int ipv4_conntrack_in(const struct nf_hook_ops *ops,
-				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+static unsigned int
+ipv4_conntrack_in(const struct nf_hook_ops *ops,
+		  struct sock *sk, struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return nf_conntrack_in(dev_net(in), PF_INET, ops->hooknum, skb);
 }
 
-static unsigned int ipv4_conntrack_local(const struct nf_hook_ops *ops,
-					 struct sk_buff *skb,
-					 const struct net_device *in,
-					 const struct net_device *out,
-					 int (*okfn)(struct sk_buff *))
+static unsigned int
+ipv4_conntrack_local(const struct nf_hook_ops *ops,
+		     struct sock *sk, struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out,
+		     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr) ||
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 76bd1ae..9ec02c2 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -61,11 +61,12 @@ static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 		return IP_DEFRAG_CONNTRACK_OUT + zone;
 }
 
-static unsigned int ipv4_conntrack_defrag(const struct nf_hook_ops *ops,
-					  struct sk_buff *skb,
-					  const struct net_device *in,
-					  const struct net_device *out,
-					  int (*okfn)(struct sk_buff *))
+static unsigned int
+ipv4_conntrack_defrag(const struct nf_hook_ops *ops,
+		      struct sock *sk2, struct sk_buff *skb,
+		      const struct net_device *in,
+		      const struct net_device *out,
+		      int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(skb->sk);
diff --git a/net/ipv4/netfilter/nf_tables_arp.c b/net/ipv4/netfilter/nf_tables_arp.c
index 19412a4..32ff53b 100644
--- a/net/ipv4/netfilter/nf_tables_arp.c
+++ b/net/ipv4/netfilter/nf_tables_arp.c
@@ -16,10 +16,10 @@
 
 static unsigned int
 nft_do_chain_arp(const struct nf_hook_ops *ops,
-		  struct sk_buff *skb,
-		  const struct net_device *in,
-		  const struct net_device *out,
-		  int (*okfn)(struct sk_buff *))
+		 struct sock *sk, struct sk_buff *skb,
+		 const struct net_device *in,
+		 const struct net_device *out,
+		 int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct nft_pktinfo pkt;
 
diff --git a/net/ipv4/netfilter/nf_tables_ipv4.c b/net/ipv4/netfilter/nf_tables_ipv4.c
index 6820c8c..ea5ce1f 100644
--- a/net/ipv4/netfilter/nf_tables_ipv4.c
+++ b/net/ipv4/netfilter/nf_tables_ipv4.c
@@ -18,11 +18,12 @@
 #include <net/ip.h>
 #include <net/netfilter/nf_tables_ipv4.h>
 
-static unsigned int nft_do_chain_ipv4(const struct nf_hook_ops *ops,
-				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+static unsigned int
+nft_do_chain_ipv4(const struct nf_hook_ops *ops,
+		  struct sock *sk, struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct nft_pktinfo pkt;
 
@@ -31,11 +32,12 @@ static unsigned int nft_do_chain_ipv4(const struct nf_hook_ops *ops,
 	return nft_do_chain(&pkt, ops);
 }
 
-static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
-				    struct sk_buff *skb,
-				    const struct net_device *in,
-				    const struct net_device *out,
-				    int (*okfn)(struct sk_buff *))
+static unsigned int
+nft_ipv4_output(const struct nf_hook_ops *ops,
+		struct sock *sk, struct sk_buff *skb,
+		const struct net_device *in,
+		const struct net_device *out,
+		int (*okfn)(struct sock *, struct sk_buff *))
 {
 	if (unlikely(skb->len < sizeof(struct iphdr) ||
 		     ip_hdr(skb)->ihl < sizeof(struct iphdr) / 4)) {
@@ -45,7 +47,7 @@ static unsigned int nft_ipv4_output(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 	}
 
-	return nft_do_chain_ipv4(ops, skb, in, out, okfn);
+	return nft_do_chain_ipv4(ops, sk, skb, in, out, okfn);
 }
 
 struct nft_af_info nft_af_ipv4 __read_mostly = {
diff --git a/net/ipv4/netfilter/nft_chain_nat_ipv4.c b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
index 3964157..ee31aa9 100644
--- a/net/ipv4/netfilter/nft_chain_nat_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_nat_ipv4.c
@@ -31,10 +31,10 @@
  */
 
 static unsigned int nf_nat_fn(const struct nf_hook_ops *ops,
-			      struct sk_buff *skb,
+			      struct sock *sk, struct sk_buff *skb,
 			      const struct net_device *in,
 			      const struct net_device *out,
-			      int (*okfn)(struct sk_buff *))
+			      int (*okfn)(struct sock *, struct sk_buff *))
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
@@ -84,16 +84,17 @@ static unsigned int nf_nat_fn(const struct nf_hook_ops *ops,
 	return nf_nat_packet(ct, ctinfo, ops->hooknum, skb);
 }
 
-static unsigned int nf_nat_prerouting(const struct nf_hook_ops *ops,
-				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+static unsigned int
+nf_nat_prerouting(const struct nf_hook_ops *ops,
+		  struct sock *sk, struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  int (*okfn)(struct sock *sk, struct sk_buff *))
 {
 	__be32 daddr = ip_hdr(skb)->daddr;
 	unsigned int ret;
 
-	ret = nf_nat_fn(ops, skb, in, out, okfn);
+	ret = nf_nat_fn(ops, sk, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    ip_hdr(skb)->daddr != daddr) {
 		skb_dst_drop(skb);
@@ -101,17 +102,18 @@ static unsigned int nf_nat_prerouting(const struct nf_hook_ops *ops,
 	return ret;
 }
 
-static unsigned int nf_nat_postrouting(const struct nf_hook_ops *ops,
-				       struct sk_buff *skb,
-				       const struct net_device *in,
-				       const struct net_device *out,
-				       int (*okfn)(struct sk_buff *))
+static unsigned int
+nf_nat_postrouting(const struct nf_hook_ops *ops,
+		   struct sock *sk, struct sk_buff *skb,
+		   const struct net_device *in,
+		   const struct net_device *out,
+		   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	enum ip_conntrack_info ctinfo __maybe_unused;
 	const struct nf_conn *ct __maybe_unused;
 	unsigned int ret;
 
-	ret = nf_nat_fn(ops, skb, in, out, okfn);
+	ret = nf_nat_fn(ops, sk, skb, in, out, okfn);
 #ifdef CONFIG_XFRM
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
@@ -129,16 +131,16 @@ static unsigned int nf_nat_postrouting(const struct nf_hook_ops *ops,
 }
 
 static unsigned int nf_nat_output(const struct nf_hook_ops *ops,
-				  struct sk_buff *skb,
+				  struct sock *sk, struct sk_buff *skb,
 				  const struct net_device *in,
 				  const struct net_device *out,
-				  int (*okfn)(struct sk_buff *))
+				  int (*okfn)(struct sock *, struct sk_buff *))
 {
 	enum ip_conntrack_info ctinfo;
 	const struct nf_conn *ct;
 	unsigned int ret;
 
-	ret = nf_nat_fn(ops, skb, in, out, okfn);
+	ret = nf_nat_fn(ops, sk, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
diff --git a/net/ipv4/netfilter/nft_chain_route_ipv4.c b/net/ipv4/netfilter/nft_chain_route_ipv4.c
index 125b667..c3317a1 100644
--- a/net/ipv4/netfilter/nft_chain_route_ipv4.c
+++ b/net/ipv4/netfilter/nft_chain_route_ipv4.c
@@ -21,11 +21,12 @@
 #include <net/route.h>
 #include <net/ip.h>
 
-static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
-					struct sk_buff *skb,
-					const struct net_device *in,
-					const struct net_device *out,
-					int (*okfn)(struct sk_buff *))
+static unsigned int
+nf_route_table_hook(const struct nf_hook_ops *ops,
+		    struct sock *sk, struct sk_buff *skb,
+		    const struct net_device *in,
+		    const struct net_device *out,
+		    int (*okfn)(struct sock *, struct sk_buff *))
 {
 	unsigned int ret;
 	struct nft_pktinfo pkt;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 739db31..dbf68f0 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -402,8 +402,8 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 		icmp_out_count(net, ((struct icmphdr *)
 			skb_transport_header(skb))->type);
 
-	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, skb, NULL,
-		      rt->dst.dev, dst_output);
+	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, sk, skb, NULL,
+		      rt->dst.dev, dst_output_sk);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index aac6197..4960051 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -22,7 +22,7 @@ int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 	return xfrm4_extract_header(skb);
 }
 
-static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
+static inline int xfrm4_rcv_encap_finish(struct sock *sk, struct sk_buff *skb)
 {
 	if (skb_dst(skb) == NULL) {
 		const struct iphdr *iph = ip_hdr(skb);
@@ -52,7 +52,7 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
 
-	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, NULL, skb, skb->dev, NULL,
 		xfrm4_rcv_encap_finish);
 	return 0;
 }
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index d5f6bd9..84e24b6 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -80,14 +80,14 @@ int xfrm4_output_finish(struct sk_buff *skb)
 	return xfrm_output(skb);
 }
 
-static int __xfrm4_output(struct sk_buff *skb)
+static int __xfrm4_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct xfrm_state *x = skb_dst(skb)->xfrm;
 
 #ifdef CONFIG_NETFILTER
 	if (!x) {
 		IPCB(skb)->flags |= IPSKB_REROUTED;
-		return dst_output(skb);
+		return dst_output_sk(sk, skb);
 	}
 #endif
 
@@ -96,7 +96,7 @@ static int __xfrm4_output(struct sk_buff *skb)
 
 int xfrm4_output(struct sock *sk, struct sk_buff *skb)
 {
-	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb,
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb,
 			    NULL, skb_dst(skb)->dev, __xfrm4_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 51d54dc..18a22e7 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -47,7 +47,7 @@
 #include <net/inet_ecn.h>
 
 
-int ip6_rcv_finish(struct sk_buff *skb)
+int ip6_rcv_finish(struct sock *sk, struct sk_buff *skb)
 {
 	if (sysctl_ip_early_demux && !skb_dst(skb) && skb->sk == NULL) {
 		const struct inet6_protocol *ipprot;
@@ -183,7 +183,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, skb, dev, NULL,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, NULL, skb, dev, NULL,
 		       ip6_rcv_finish);
 err:
 	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
@@ -198,7 +198,7 @@ drop:
  */
 
 
-static int ip6_input_finish(struct sk_buff *skb)
+static int ip6_input_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	const struct inet6_protocol *ipprot;
@@ -276,8 +276,8 @@ discard:
 
 int ip6_input(struct sk_buff *skb)
 {
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
-		       ip6_input_finish);
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_IN, NULL, skb, skb->dev,
+		       NULL, ip6_input_finish);
 }
 
 int ip6_mc_input(struct sk_buff *skb)
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 315a55d..e2c93c6 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -56,7 +56,7 @@
 #include <net/checksum.h>
 #include <linux/mroute6.h>
 
-static int ip6_finish_output2(struct sk_buff *skb)
+static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *dev = dst->dev;
@@ -82,7 +82,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 			 */
 			if (newskb)
 				NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING,
-					newskb, NULL, newskb->dev,
+					sk, newskb, NULL, newskb->dev,
 					dev_loopback_xmit);
 
 			if (ipv6_hdr(skb)->hop_limit == 0) {
@@ -122,14 +122,14 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	return -EINVAL;
 }
 
-static int ip6_finish_output(struct sk_buff *skb)
+static int ip6_finish_output(struct sock *sk, struct sk_buff *skb)
 {
 	if ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
 	    dst_allfrag(skb_dst(skb)) ||
 	    (IP6CB(skb)->frag_max_size && skb->len > IP6CB(skb)->frag_max_size))
-		return ip6_fragment(skb, ip6_finish_output2);
+		return ip6_fragment(sk, skb, ip6_finish_output2);
 	else
-		return ip6_finish_output2(skb);
+		return ip6_finish_output2(sk, skb);
 }
 
 int ip6_output(struct sock *sk, struct sk_buff *skb)
@@ -143,8 +143,8 @@ int ip6_output(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
-	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL, dev,
-			    ip6_finish_output,
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, sk, skb, NULL,
+			    dev, ip6_finish_output,
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
 
@@ -223,8 +223,8 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	if ((skb->len <= mtu) || skb->ignore_df || skb_is_gso(skb)) {
 		IP6_UPD_PO_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_OUT, skb->len);
-		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
-			       dst->dev, dst_output);
+		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb, NULL,
+			       dst->dev, dst_output_sk);
 	}
 
 	skb->dev = dst->dev;
@@ -317,9 +317,9 @@ static int ip6_forward_proxy_check(struct sk_buff *skb)
 	return 0;
 }
 
-static inline int ip6_forward_finish(struct sk_buff *skb)
+static inline int ip6_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
-	return dst_output(skb);
+	return dst_output_sk(sk, skb);
 }
 
 static unsigned int ip6_dst_mtu_forward(const struct dst_entry *dst)
@@ -511,8 +511,8 @@ int ip6_forward(struct sk_buff *skb)
 
 	IP6_INC_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
 	IP6_ADD_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTOCTETS, skb->len);
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, skb->dev, dst->dev,
-		       ip6_forward_finish);
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, NULL, skb, skb->dev,
+		       dst->dev, ip6_forward_finish);
 
 error:
 	IP6_INC_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_INADDRERRORS);
@@ -552,7 +552,8 @@ static void ipv6_select_ident(struct frag_hdr *fhdr, struct rt6_info *rt)
 	fhdr->identification = htonl(id);
 }
 
-int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
+int ip6_fragment(struct sock *sk, struct sk_buff *skb,
+		 int (*output)(struct sock *, struct sk_buff *))
 {
 	struct sk_buff *frag;
 	struct rt6_info *rt = (struct rt6_info*)skb_dst(skb);
@@ -680,7 +681,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 				ip6_copy_metadata(frag, skb);
 			}
 
-			err = output(skb);
+			err = output(sk, skb);
 			if(!err)
 				IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
 					      IPSTATS_MIB_FRAGCREATES);
@@ -819,7 +820,7 @@ slow_path:
 		/*
 		 *	Put this fragment into the sending queue.
 		 */
-		err = output(frag);
+		err = output(sk, frag);
 		if (err)
 			goto fail;
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f9a3fd3..11b98d6 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1979,13 +1979,13 @@ int ip6mr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 }
 #endif
 
-static inline int ip6mr_forward2_finish(struct sk_buff *skb)
+static inline int ip6mr_forward2_finish(struct sock *sk, struct sk_buff *skb)
 {
 	IP6_INC_STATS_BH(dev_net(skb_dst(skb)->dev), ip6_dst_idev(skb_dst(skb)),
 			 IPSTATS_MIB_OUTFORWDATAGRAMS);
 	IP6_ADD_STATS_BH(dev_net(skb_dst(skb)->dev), ip6_dst_idev(skb_dst(skb)),
 			 IPSTATS_MIB_OUTOCTETS, skb->len);
-	return dst_output(skb);
+	return dst_output_sk(sk, skb);
 }
 
 /*
@@ -2057,7 +2057,7 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 
 	IP6CB(skb)->flags |= IP6SKB_FORWARDED;
 
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, skb->dev, dev,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, NULL, skb, skb->dev, dev,
 		       ip6mr_forward2_finish);
 
 out_free:
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 617f095..50a2581 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1625,8 +1625,8 @@ static void mld_sendpack(struct sk_buff *skb)
 
 	payload_len = skb->len;
 
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
-		      dst_output);
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, NULL, skb, NULL,
+		      skb->dev, dst_output_sk);
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, ICMPV6_MLD2_REPORT);
@@ -1989,8 +1989,8 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	}
 
 	skb_dst_set(skb, dst);
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
-		      dst_output);
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, NULL, skb, NULL,
+		      skb->dev, dst_output_sk);
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 339078f..12ba617 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -455,8 +455,8 @@ static void ndisc_send_skb(struct sk_buff *skb,
 	idev = __in6_dev_get(dst->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
 
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
-		      dst_output);
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, NULL, skb, NULL,
+		      dst->dev, dst_output_sk);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index a0d1727..d3c7e94 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -313,11 +313,12 @@ synproxy_tg6(struct sk_buff *skb, const struct xt_action_param *par)
 	return XT_CONTINUE;
 }
 
-static unsigned int ipv6_synproxy_hook(const struct nf_hook_ops *ops,
-				       struct sk_buff *skb,
-				       const struct net_device *in,
-				       const struct net_device *out,
-				       int (*okfn)(struct sk_buff *))
+static unsigned int
+ipv6_synproxy_hook(const struct nf_hook_ops *ops,
+		   struct sock *sk, struct sk_buff *skb,
+		   const struct net_device *in,
+		   const struct net_device *out,
+		   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct synproxy_net *snet = synproxy_pernet(dev_net(in ? : out));
 	enum ip_conntrack_info ctinfo;
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index ca7f6c1..2e0d116 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -32,9 +32,10 @@ static const struct xt_table packet_filter = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ip6table_filter_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip6table_filter_hook(const struct nf_hook_ops *ops,
+		     struct sock *sk, struct sk_buff *skb,
 		     const struct net_device *in, const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	const struct net *net = dev_net((in != NULL) ? in : out);
 
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 307bbb7..8137e5a 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -76,9 +76,10 @@ ip6t_mangle_out(struct sk_buff *skb, const struct net_device *out)
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ip6table_mangle_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip6table_mangle_hook(const struct nf_hook_ops *ops,
+		     struct sock *sk, struct sk_buff *skb,
 		     const struct net_device *in, const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	if (ops->hooknum == NF_INET_LOCAL_OUT)
 		return ip6t_mangle_out(skb, out);
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index 387d8b8..8ba0ee6 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -64,10 +64,10 @@ static unsigned int nf_nat_rule_find(struct sk_buff *skb, unsigned int hooknum,
 
 static unsigned int
 nf_nat_ipv6_fn(const struct nf_hook_ops *ops,
-	       struct sk_buff *skb,
+	       struct sock *sk, struct sk_buff *skb,
 	       const struct net_device *in,
 	       const struct net_device *out,
-	       int (*okfn)(struct sk_buff *))
+	       int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -146,15 +146,15 @@ oif_changed:
 
 static unsigned int
 nf_nat_ipv6_in(const struct nf_hook_ops *ops,
-	       struct sk_buff *skb,
+	       struct sock *sk, struct sk_buff *skb,
 	       const struct net_device *in,
 	       const struct net_device *out,
-	       int (*okfn)(struct sk_buff *))
+	       int (*okfn)(struct sock *, struct sk_buff *))
 {
 	unsigned int ret;
 	struct in6_addr daddr = ipv6_hdr(skb)->daddr;
 
-	ret = nf_nat_ipv6_fn(ops, skb, in, out, okfn);
+	ret = nf_nat_ipv6_fn(ops, sk, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    ipv6_addr_cmp(&daddr, &ipv6_hdr(skb)->daddr))
 		skb_dst_drop(skb);
@@ -164,10 +164,10 @@ nf_nat_ipv6_in(const struct nf_hook_ops *ops,
 
 static unsigned int
 nf_nat_ipv6_out(const struct nf_hook_ops *ops,
-		struct sk_buff *skb,
+		struct sock *sk, struct sk_buff *skb,
 		const struct net_device *in,
 		const struct net_device *out,
-		int (*okfn)(struct sk_buff *))
+		int (*okfn)(struct sock *, struct sk_buff *))
 {
 #ifdef CONFIG_XFRM
 	const struct nf_conn *ct;
@@ -180,7 +180,7 @@ nf_nat_ipv6_out(const struct nf_hook_ops *ops,
 	if (skb->len < sizeof(struct ipv6hdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_ipv6_fn(ops, skb, in, out, okfn);
+	ret = nf_nat_ipv6_fn(ops, sk, skb, in, out, okfn);
 #ifdef CONFIG_XFRM
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    !(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
@@ -203,10 +203,10 @@ nf_nat_ipv6_out(const struct nf_hook_ops *ops,
 
 static unsigned int
 nf_nat_ipv6_local_fn(const struct nf_hook_ops *ops,
-		     struct sk_buff *skb,
+		     struct sock *sk, struct sk_buff *skb,
 		     const struct net_device *in,
 		     const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	const struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -217,7 +217,7 @@ nf_nat_ipv6_local_fn(const struct nf_hook_ops *ops,
 	if (skb->len < sizeof(struct ipv6hdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_ipv6_fn(ops, skb, in, out, okfn);
+	ret = nf_nat_ipv6_fn(ops, sk, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 5274740..92d980c 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -19,9 +19,10 @@ static const struct xt_table packet_raw = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ip6table_raw_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip6table_raw_hook(const struct nf_hook_ops *ops,
+		  struct sock *sk, struct sk_buff *skb,
 		  const struct net_device *in, const struct net_device *out,
-		  int (*okfn)(struct sk_buff *))
+		  int (*okfn)(struct sock *, struct sk_buff *))
 {
 	const struct net *net = dev_net((in != NULL) ? in : out);
 
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index ab3b021..353d82a 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -36,10 +36,11 @@ static const struct xt_table security_table = {
 };
 
 static unsigned int
-ip6table_security_hook(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip6table_security_hook(const struct nf_hook_ops *ops,
+		       struct sock *sk, struct sk_buff *skb,
 		       const struct net_device *in,
 		       const struct net_device *out,
-		       int (*okfn)(struct sk_buff *))
+		       int (*okfn)(struct sock *, struct sk_buff *))
 {
 	const struct net *net = dev_net((in != NULL) ? in : out);
 
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 4cbc6b2..76339d0 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -96,10 +96,10 @@ static int ipv6_get_l4proto(const struct sk_buff *skb, unsigned int nhoff,
 }
 
 static unsigned int ipv6_helper(const struct nf_hook_ops *ops,
-				struct sk_buff *skb,
+				struct sock *sk, struct sk_buff *skb,
 				const struct net_device *in,
 				const struct net_device *out,
-				int (*okfn)(struct sk_buff *))
+				int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct nf_conn *ct;
 	const struct nf_conn_help *help;
@@ -134,10 +134,10 @@ static unsigned int ipv6_helper(const struct nf_hook_ops *ops,
 }
 
 static unsigned int ipv6_confirm(const struct nf_hook_ops *ops,
-				 struct sk_buff *skb,
+				 struct sock *sk, struct sk_buff *skb,
 				 const struct net_device *in,
 				 const struct net_device *out,
-				 int (*okfn)(struct sk_buff *))
+				 int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -169,20 +169,22 @@ out:
 	return nf_conntrack_confirm(skb);
 }
 
-static unsigned int ipv6_conntrack_in(const struct nf_hook_ops *ops,
-				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+static unsigned int
+ipv6_conntrack_in(const struct nf_hook_ops *ops,
+		  struct sock *sk, struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return nf_conntrack_in(dev_net(in), PF_INET6, ops->hooknum, skb);
 }
 
-static unsigned int ipv6_conntrack_local(const struct nf_hook_ops *ops,
-					 struct sk_buff *skb,
-					 const struct net_device *in,
-					 const struct net_device *out,
-					 int (*okfn)(struct sk_buff *))
+static unsigned int
+ipv6_conntrack_local(const struct nf_hook_ops *ops,
+		     struct sock *sk, struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out,
+		     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct ipv6hdr)) {
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 7b9a748..3d934e8 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -53,10 +53,10 @@ static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 }
 
 static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
-				struct sk_buff *skb,
+				struct sock *sk, struct sk_buff *skb,
 				const struct net_device *in,
 				const struct net_device *out,
-				int (*okfn)(struct sk_buff *))
+				int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct sk_buff *reasm;
 
@@ -77,7 +77,7 @@ static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
 
 	nf_ct_frag6_consume_orig(reasm);
 
-	NF_HOOK_THRESH(NFPROTO_IPV6, ops->hooknum, reasm,
+	NF_HOOK_THRESH(NFPROTO_IPV6, ops->hooknum, sk, reasm,
 		       (struct net_device *) in, (struct net_device *) out,
 		       okfn, NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
 
diff --git a/net/ipv6/netfilter/nf_tables_ipv6.c b/net/ipv6/netfilter/nf_tables_ipv6.c
index 0d812b3..94ec2e9 100644
--- a/net/ipv6/netfilter/nf_tables_ipv6.c
+++ b/net/ipv6/netfilter/nf_tables_ipv6.c
@@ -16,11 +16,12 @@
 #include <net/netfilter/nf_tables.h>
 #include <net/netfilter/nf_tables_ipv6.h>
 
-static unsigned int nft_do_chain_ipv6(const struct nf_hook_ops *ops,
-				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+static unsigned int
+nft_do_chain_ipv6(const struct nf_hook_ops *ops,
+		  struct sock *sk, struct sk_buff *skb,
+		  const struct net_device *in,
+		  const struct net_device *out,
+		  int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct nft_pktinfo pkt;
 
@@ -31,11 +32,12 @@ static unsigned int nft_do_chain_ipv6(const struct nf_hook_ops *ops,
 	return nft_do_chain(&pkt, ops);
 }
 
-static unsigned int nft_ipv6_output(const struct nf_hook_ops *ops,
-				    struct sk_buff *skb,
-				    const struct net_device *in,
-				    const struct net_device *out,
-				    int (*okfn)(struct sk_buff *))
+static unsigned int
+nft_ipv6_output(const struct nf_hook_ops *ops,
+		struct sock *sk, struct sk_buff *skb,
+		const struct net_device *in,
+		const struct net_device *out,
+		int (*okfn)(struct sock *, struct sk_buff *))
 {
 	if (unlikely(skb->len < sizeof(struct ipv6hdr))) {
 		if (net_ratelimit())
@@ -44,7 +46,7 @@ static unsigned int nft_ipv6_output(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 	}
 
-	return nft_do_chain_ipv6(ops, skb, in, out, okfn);
+	return nft_do_chain_ipv6(ops, sk, skb, in, out, okfn);
 }
 
 struct nft_af_info nft_af_ipv6 __read_mostly = {
diff --git a/net/ipv6/netfilter/nft_chain_nat_ipv6.c b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
index d189fcb..df39cd8 100644
--- a/net/ipv6/netfilter/nft_chain_nat_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_nat_ipv6.c
@@ -29,10 +29,11 @@
  */
 
 static unsigned int nf_nat_ipv6_fn(const struct nf_hook_ops *ops,
-			      struct sk_buff *skb,
-			      const struct net_device *in,
-			      const struct net_device *out,
-			      int (*okfn)(struct sk_buff *))
+				   struct sock *sk,
+				   struct sk_buff *skb,
+				   const struct net_device *in,
+				   const struct net_device *out,
+				   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	enum ip_conntrack_info ctinfo;
 	struct nf_conn *ct = nf_ct_get(skb, &ctinfo);
@@ -88,16 +89,17 @@ static unsigned int nf_nat_ipv6_fn(const struct nf_hook_ops *ops,
 	return nf_nat_packet(ct, ctinfo, ops->hooknum, skb);
 }
 
-static unsigned int nf_nat_ipv6_prerouting(const struct nf_hook_ops *ops,
-				      struct sk_buff *skb,
-				      const struct net_device *in,
-				      const struct net_device *out,
-				      int (*okfn)(struct sk_buff *))
+static unsigned int
+nf_nat_ipv6_prerouting(const struct nf_hook_ops *ops,
+		       struct sock *sk, struct sk_buff *skb,
+		       const struct net_device *in,
+		       const struct net_device *out,
+		       int (*okfn)(struct sock *, struct sk_buff *))
 {
 	struct in6_addr daddr = ipv6_hdr(skb)->daddr;
 	unsigned int ret;
 
-	ret = nf_nat_ipv6_fn(ops, skb, in, out, okfn);
+	ret = nf_nat_ipv6_fn(ops, sk, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    ipv6_addr_cmp(&daddr, &ipv6_hdr(skb)->daddr))
 		skb_dst_drop(skb);
@@ -105,17 +107,18 @@ static unsigned int nf_nat_ipv6_prerouting(const struct nf_hook_ops *ops,
 	return ret;
 }
 
-static unsigned int nf_nat_ipv6_postrouting(const struct nf_hook_ops *ops,
-				       struct sk_buff *skb,
-				       const struct net_device *in,
-				       const struct net_device *out,
-				       int (*okfn)(struct sk_buff *))
+static unsigned int
+nf_nat_ipv6_postrouting(const struct nf_hook_ops *ops,
+			struct sock *sk, struct sk_buff *skb,
+			const struct net_device *in,
+			const struct net_device *out,
+			int (*okfn)(struct sock *, struct sk_buff *))
 {
 	enum ip_conntrack_info ctinfo __maybe_unused;
 	const struct nf_conn *ct __maybe_unused;
 	unsigned int ret;
 
-	ret = nf_nat_ipv6_fn(ops, skb, in, out, okfn);
+	ret = nf_nat_ipv6_fn(ops, sk, skb, in, out, okfn);
 #ifdef CONFIG_XFRM
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    !(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
@@ -133,17 +136,18 @@ static unsigned int nf_nat_ipv6_postrouting(const struct nf_hook_ops *ops,
 	return ret;
 }
 
-static unsigned int nf_nat_ipv6_output(const struct nf_hook_ops *ops,
-				  struct sk_buff *skb,
-				  const struct net_device *in,
-				  const struct net_device *out,
-				  int (*okfn)(struct sk_buff *))
+static unsigned int
+nf_nat_ipv6_output(const struct nf_hook_ops *ops,
+		   struct sock *sk, struct sk_buff *skb,
+		   const struct net_device *in,
+		   const struct net_device *out,
+		   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	enum ip_conntrack_info ctinfo;
 	const struct nf_conn *ct;
 	unsigned int ret;
 
-	ret = nf_nat_ipv6_fn(ops, skb, in, out, okfn);
+	ret = nf_nat_ipv6_fn(ops, sk, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
diff --git a/net/ipv6/netfilter/nft_chain_route_ipv6.c b/net/ipv6/netfilter/nft_chain_route_ipv6.c
index 4203129..3a96a3d 100644
--- a/net/ipv6/netfilter/nft_chain_route_ipv6.c
+++ b/net/ipv6/netfilter/nft_chain_route_ipv6.c
@@ -22,11 +22,13 @@
 #include <net/netfilter/nf_tables_ipv6.h>
 #include <net/route.h>
 
-static unsigned int nf_route_table_hook(const struct nf_hook_ops *ops,
-					struct sk_buff *skb,
-					const struct net_device *in,
-					const struct net_device *out,
-					int (*okfn)(struct sk_buff *))
+static unsigned int
+nf_route_table_hook(const struct nf_hook_ops *ops,
+		    struct sock *sk,
+		    struct sk_buff *skb,
+		    const struct net_device *in,
+		    const struct net_device *out,
+		    int (*okfn)(struct sock *, struct sk_buff *))
 {
 	unsigned int ret;
 	struct nft_pktinfo pkt;
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 5ec867e..d746f75 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -80,8 +80,8 @@ int __ip6_local_out(struct sk_buff *skb)
 	ipv6_hdr(skb)->payload_len = htons(len);
 	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
 
-	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
-		       skb_dst(skb)->dev, dst_output);
+	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, NULL, skb, NULL,
+		       skb_dst(skb)->dev, dst_output_sk);
 }
 EXPORT_SYMBOL_GPL(__ip6_local_out);
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 39d4422..9426242 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -652,8 +652,8 @@ static int rawv6_send_hdrinc(struct sock *sk, void *from, int length,
 		goto error_fault;
 
 	IP6_UPD_PO_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
-		      rt->dst.dev, dst_output);
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb, NULL,
+		      rt->dst.dev, dst_output_sk);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index f8c3cf8..c66cd3c 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -42,7 +42,7 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
 
-	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, NULL, skb, skb->dev, NULL,
 		ip6_rcv_finish);
 	return -1;
 }
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 433672d..2ac8214 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -132,7 +132,7 @@ int xfrm6_output_finish(struct sk_buff *skb)
 	return xfrm_output(skb);
 }
 
-static int __xfrm6_output(struct sk_buff *skb)
+static int __xfrm6_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct xfrm_state *x = dst->xfrm;
@@ -161,14 +161,14 @@ static int __xfrm6_output(struct sk_buff *skb)
 	if (x->props.mode == XFRM_MODE_TUNNEL &&
 	    ((skb->len > mtu && !skb_is_gso(skb)) ||
 		dst_allfrag(skb_dst(skb)))) {
-			return ip6_fragment(skb, x->outer_mode->afinfo->output_finish);
+			return ip6_fragment(sk, skb, x->outer_mode->afinfo->output_finish);
 	}
 	return x->outer_mode->afinfo->output_finish(skb);
 }
 
 int xfrm6_output(struct sock *sk, struct sk_buff *skb)
 {
-	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb,
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, sk, skb,
 			    NULL, skb_dst(skb)->dev, __xfrm6_output,
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index a93c97f..9bde877 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -118,12 +118,12 @@ void nf_unregister_hooks(struct nf_hook_ops *reg, unsigned int n)
 EXPORT_SYMBOL(nf_unregister_hooks);
 
 unsigned int nf_iterate(struct list_head *head,
-			struct sk_buff *skb,
+			struct sock *sk, struct sk_buff *skb,
 			unsigned int hook,
 			const struct net_device *indev,
 			const struct net_device *outdev,
 			struct nf_hook_ops **elemp,
-			int (*okfn)(struct sk_buff *),
+			int (*okfn)(struct sock *, struct sk_buff *),
 			int hook_thresh)
 {
 	unsigned int verdict;
@@ -139,7 +139,7 @@ unsigned int nf_iterate(struct list_head *head,
 		/* Optimization: we don't need to hold module
 		   reference here, since function can't sleep. --RR */
 repeat:
-		verdict = (*elemp)->hook(*elemp, skb, indev, outdev, okfn);
+		verdict = (*elemp)->hook(*elemp, sk, skb, indev, outdev, okfn);
 		if (verdict != NF_ACCEPT) {
 #ifdef CONFIG_NETFILTER_DEBUG
 			if (unlikely((verdict & NF_VERDICT_MASK)
@@ -160,10 +160,11 @@ repeat:
 
 /* Returns 1 if okfn() needs to be executed by the caller,
  * -EPERM for NF_DROP, 0 otherwise. */
-int nf_hook_slow(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
+int nf_hook_slow(u_int8_t pf, unsigned int hook,
+		 struct sock *sk, struct sk_buff *skb,
 		 struct net_device *indev,
 		 struct net_device *outdev,
-		 int (*okfn)(struct sk_buff *),
+		 int (*okfn)(struct sock *, struct sk_buff *),
 		 int hook_thresh)
 {
 	struct nf_hook_ops *elem;
@@ -175,7 +176,7 @@ int nf_hook_slow(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
 
 	elem = list_entry_rcu(&nf_hooks[pf][hook], struct nf_hook_ops, list);
 next_hook:
-	verdict = nf_iterate(&nf_hooks[pf][hook], skb, hook, indev,
+	verdict = nf_iterate(&nf_hooks[pf][hook], sk, skb, hook, indev,
 			     outdev, &elem, okfn, hook_thresh);
 	if (verdict == NF_ACCEPT || verdict == NF_STOP) {
 		ret = 1;
@@ -185,8 +186,8 @@ next_hook:
 		if (ret == 0)
 			ret = -EPERM;
 	} else if ((verdict & NF_VERDICT_MASK) == NF_QUEUE) {
-		int err = nf_queue(skb, elem, pf, hook, indev, outdev, okfn,
-						verdict >> NF_VERDICT_QBITS);
+		int err = nf_queue(sk, skb, elem, pf, hook, indev, outdev, okfn,
+				   verdict >> NF_VERDICT_QBITS);
 		if (err < 0) {
 			if (err == -ECANCELED)
 				goto next_hook;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index e683675..6bbb51c 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -1233,9 +1233,10 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb, int af)
  *	Check if packet is reply for established ip_vs_conn.
  */
 static unsigned int
-ip_vs_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_reply4(const struct nf_hook_ops *ops,
+	     struct sock *sk, struct sk_buff *skb,
 	     const struct net_device *in, const struct net_device *out,
-	     int (*okfn)(struct sk_buff *))
+	     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return ip_vs_out(ops->hooknum, skb, AF_INET);
 }
@@ -1245,9 +1246,10 @@ ip_vs_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *	Check if packet is reply for established ip_vs_conn.
  */
 static unsigned int
-ip_vs_local_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_local_reply4(const struct nf_hook_ops *ops,
+		   struct sock *sk, struct sk_buff *skb,
 		   const struct net_device *in, const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
+		   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return ip_vs_out(ops->hooknum, skb, AF_INET);
 }
@@ -1260,9 +1262,10 @@ ip_vs_local_reply4(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *	Check if packet is reply for established ip_vs_conn.
  */
 static unsigned int
-ip_vs_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_reply6(const struct nf_hook_ops *ops,
+	     struct sock *sk, struct sk_buff *skb,
 	     const struct net_device *in, const struct net_device *out,
-	     int (*okfn)(struct sk_buff *))
+	     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return ip_vs_out(ops->hooknum, skb, AF_INET6);
 }
@@ -1272,9 +1275,10 @@ ip_vs_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *	Check if packet is reply for established ip_vs_conn.
  */
 static unsigned int
-ip_vs_local_reply6(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_local_reply6(const struct nf_hook_ops *ops,
+		   struct sock *sk, struct sk_buff *skb,
 		   const struct net_device *in, const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
+		   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return ip_vs_out(ops->hooknum, skb, AF_INET6);
 }
@@ -1725,10 +1729,10 @@ ip_vs_in(unsigned int hooknum, struct sk_buff *skb, int af)
  *	Schedule and forward packets from remote clients
  */
 static unsigned int
-ip_vs_remote_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		      const struct net_device *in,
-		      const struct net_device *out,
-		      int (*okfn)(struct sk_buff *))
+ip_vs_remote_request4(const struct nf_hook_ops *ops,
+		      struct sock *sk, struct sk_buff *skb,
+		      const struct net_device *in, const struct net_device *out,
+		      int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return ip_vs_in(ops->hooknum, skb, AF_INET);
 }
@@ -1738,9 +1742,10 @@ ip_vs_remote_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *	Schedule and forward packets from local clients
  */
 static unsigned int
-ip_vs_local_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_local_request4(const struct nf_hook_ops *ops,
+		     struct sock *sk, struct sk_buff *skb,
 		     const struct net_device *in, const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return ip_vs_in(ops->hooknum, skb, AF_INET);
 }
@@ -1752,10 +1757,10 @@ ip_vs_local_request4(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *	Schedule and forward packets from remote clients
  */
 static unsigned int
-ip_vs_remote_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
-		      const struct net_device *in,
-		      const struct net_device *out,
-		      int (*okfn)(struct sk_buff *))
+ip_vs_remote_request6(const struct nf_hook_ops *ops,
+		      struct sock *sk, struct sk_buff *skb,
+		      const struct net_device *in, const struct net_device *out,
+		      int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return ip_vs_in(ops->hooknum, skb, AF_INET6);
 }
@@ -1765,9 +1770,10 @@ ip_vs_remote_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *	Schedule and forward packets from local clients
  */
 static unsigned int
-ip_vs_local_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_local_request6(const struct nf_hook_ops *ops,
+		     struct sock *sk, struct sk_buff *skb,
 		     const struct net_device *in, const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
+		     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return ip_vs_in(ops->hooknum, skb, AF_INET6);
 }
@@ -1785,9 +1791,10 @@ ip_vs_local_request6(const struct nf_hook_ops *ops, struct sk_buff *skb,
  *      and send them to ip_vs_in_icmp.
  */
 static unsigned int
-ip_vs_forward_icmp(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_forward_icmp(const struct nf_hook_ops *ops,
+		   struct sock *sk, struct sk_buff *skb,
 		   const struct net_device *in, const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
+		   int (*okfn)(struct sock *, struct sk_buff *))
 {
 	int r;
 	struct net *net;
@@ -1807,9 +1814,10 @@ ip_vs_forward_icmp(const struct nf_hook_ops *ops, struct sk_buff *skb,
 
 #ifdef CONFIG_IP_VS_IPV6
 static unsigned int
-ip_vs_forward_icmp_v6(const struct nf_hook_ops *ops, struct sk_buff *skb,
+ip_vs_forward_icmp_v6(const struct nf_hook_ops *ops,
+		      struct sock *sk, struct sk_buff *skb,
 		      const struct net_device *in, const struct net_device *out,
-		      int (*okfn)(struct sk_buff *))
+		      int (*okfn)(struct sock *, struct sk_buff *))
 {
 	int r;
 	struct net *net;
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 6f70bdd..ba44591 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -503,8 +503,8 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 		ip_vs_update_conntrack(skb, cp, 1);
 	if (!local) {
 		skb_forward_csum(skb);
-		NF_HOOK(pf, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
-			dst_output);
+		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb, NULL,
+			skb_dst(skb)->dev, dst_output_sk);
 	} else
 		ret = NF_ACCEPT;
 	return ret;
@@ -521,8 +521,8 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 		ip_vs_notrack(skb);
 	if (!local) {
 		skb_forward_csum(skb);
-		NF_HOOK(pf, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
-			dst_output);
+		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb, NULL,
+			skb_dst(skb)->dev, dst_output_sk);
 	} else
 		ret = NF_ACCEPT;
 	return ret;
diff --git a/net/netfilter/nf_internals.h b/net/netfilter/nf_internals.h
index 61a3c92..6fef94d 100644
--- a/net/netfilter/nf_internals.h
+++ b/net/netfilter/nf_internals.h
@@ -13,16 +13,20 @@
 
 
 /* core.c */
-unsigned int nf_iterate(struct list_head *head, struct sk_buff *skb,
-			unsigned int hook, const struct net_device *indev,
+unsigned int nf_iterate(struct list_head *head,
+			struct sock *sk, struct sk_buff *skb,
+			unsigned int hook,
+			const struct net_device *indev,
 			const struct net_device *outdev,
 			struct nf_hook_ops **elemp,
-			int (*okfn)(struct sk_buff *), int hook_thresh);
+			int (*okfn)(struct sock *sk, struct sk_buff *),
+			int hook_thresh);
 
 /* nf_queue.c */
-int nf_queue(struct sk_buff *skb, struct nf_hook_ops *elem, u_int8_t pf,
-	     unsigned int hook, struct net_device *indev,
-	     struct net_device *outdev, int (*okfn)(struct sk_buff *),
+int nf_queue(struct sock *sk, struct sk_buff *skb,
+	     struct nf_hook_ops *elem, u_int8_t pf, unsigned int hook,
+	     struct net_device *indev, struct net_device *outdev,
+	     int (*okfn)(struct sock *, struct sk_buff *),
 	     unsigned int queuenum);
 int __init netfilter_queue_init(void);
 
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index 5d24b1f..5b3cd57 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -99,13 +99,11 @@ EXPORT_SYMBOL_GPL(nf_queue_entry_get_refs);
  * Any packet that leaves via this function must come back
  * through nf_reinject().
  */
-int nf_queue(struct sk_buff *skb,
-		      struct nf_hook_ops *elem,
-		      u_int8_t pf, unsigned int hook,
-		      struct net_device *indev,
-		      struct net_device *outdev,
-		      int (*okfn)(struct sk_buff *),
-		      unsigned int queuenum)
+int nf_queue(struct sock *sk, struct sk_buff *skb,
+	     struct nf_hook_ops *elem, u_int8_t pf, unsigned int hook,
+	     struct net_device *indev, struct net_device *outdev,
+	     int (*okfn)(struct sock *, struct sk_buff *),
+	     unsigned int queuenum)
 {
 	int status = -ENOENT;
 	struct nf_queue_entry *entry = NULL;
@@ -132,6 +130,7 @@ int nf_queue(struct sk_buff *skb,
 	}
 
 	*entry = (struct nf_queue_entry) {
+		.sk	= sk,
 		.skb	= skb,
 		.elem	= elem,
 		.pf	= pf,
@@ -168,6 +167,7 @@ err:
 
 void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 {
+	struct sock *sk = entry->sk;
 	struct sk_buff *skb = entry->skb;
 	struct nf_hook_ops *elem = entry->elem;
 	const struct nf_afinfo *afinfo;
@@ -192,7 +192,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	if (verdict == NF_ACCEPT) {
 	next_hook:
 		verdict = nf_iterate(&nf_hooks[entry->pf][entry->hook],
-				     skb, entry->hook,
+				     sk, skb, entry->hook,
 				     entry->indev, entry->outdev, &elem,
 				     entry->okfn, INT_MIN);
 	}
@@ -201,13 +201,13 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	case NF_ACCEPT:
 	case NF_STOP:
 		local_bh_disable();
-		entry->okfn(skb);
+		entry->okfn(sk, skb);
 		local_bh_enable();
 		break;
 	case NF_QUEUE:
-		err = nf_queue(skb, elem, entry->pf, entry->hook,
-				entry->indev, entry->outdev, entry->okfn,
-				verdict >> NF_VERDICT_QBITS);
+		err = nf_queue(sk, skb, elem, entry->pf, entry->hook,
+			       entry->indev, entry->outdev, entry->okfn,
+			       verdict >> NF_VERDICT_QBITS);
 		if (err < 0) {
 			if (err == -ECANCELED)
 				goto next_hook;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index c51e8f7b..8c0cca5 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -19,7 +19,7 @@
 #include <net/dst.h>
 #include <net/xfrm.h>
 
-static int xfrm_output2(struct sk_buff *skb);
+static int xfrm_output2(struct sock *sk, struct sk_buff *skb);
 
 static int xfrm_skb_check_space(struct sk_buff *skb)
 {
@@ -130,7 +130,7 @@ int xfrm_output_resume(struct sk_buff *skb, int err)
 			return dst_output(skb);
 
 		err = nf_hook(skb_dst(skb)->ops->family,
-			      NF_INET_POST_ROUTING, skb,
+			      NF_INET_POST_ROUTING, NULL, skb,
 			      NULL, skb_dst(skb)->dev, xfrm_output2);
 		if (unlikely(err != 1))
 			goto out;
@@ -144,7 +144,7 @@ out:
 }
 EXPORT_SYMBOL_GPL(xfrm_output_resume);
 
-static int xfrm_output2(struct sk_buff *skb)
+static int xfrm_output2(struct sock *sk, struct sk_buff *skb)
 {
 	return xfrm_output_resume(skb, 1);
 }
@@ -163,7 +163,7 @@ static int xfrm_output_gso(struct sk_buff *skb)
 		int err;
 
 		segs->next = NULL;
-		err = xfrm_output2(segs);
+		err = xfrm_output2(NULL, segs);
 
 		if (unlikely(err)) {
 			while ((segs = nskb)) {
@@ -197,7 +197,7 @@ int xfrm_output(struct sk_buff *skb)
 		}
 	}
 
-	return xfrm_output2(skb);
+	return xfrm_output2(NULL, skb);
 }
 EXPORT_SYMBOL_GPL(xfrm_output);
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index b0e9404..f5b067b 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -4769,21 +4769,23 @@ static unsigned int selinux_ip_forward(struct sk_buff *skb, int ifindex,
 	return NF_ACCEPT;
 }
 
-static unsigned int selinux_ipv4_forward(const struct nf_hook_ops *ops,
-					 struct sk_buff *skb,
-					 const struct net_device *in,
-					 const struct net_device *out,
-					 int (*okfn)(struct sk_buff *))
+static unsigned int
+selinux_ipv4_forward(const struct nf_hook_ops *ops,
+		     struct sock *sk, struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out,
+		     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return selinux_ip_forward(skb, in->ifindex, PF_INET);
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static unsigned int selinux_ipv6_forward(const struct nf_hook_ops *ops,
-					 struct sk_buff *skb,
-					 const struct net_device *in,
-					 const struct net_device *out,
-					 int (*okfn)(struct sk_buff *))
+static unsigned int
+selinux_ipv6_forward(const struct nf_hook_ops *ops,
+		     struct sock *sk, struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out,
+		     int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return selinux_ip_forward(skb, in->ifindex, PF_INET6);
 }
@@ -4831,11 +4833,12 @@ static unsigned int selinux_ip_output(struct sk_buff *skb,
 	return NF_ACCEPT;
 }
 
-static unsigned int selinux_ipv4_output(const struct nf_hook_ops *ops,
-					struct sk_buff *skb,
-					const struct net_device *in,
-					const struct net_device *out,
-					int (*okfn)(struct sk_buff *))
+static unsigned int
+selinux_ipv4_output(const struct nf_hook_ops *ops,
+		    struct sock *sk, struct sk_buff *skb,
+		    const struct net_device *in,
+		    const struct net_device *out,
+		    int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return selinux_ip_output(skb, PF_INET);
 }
@@ -5005,21 +5008,23 @@ static unsigned int selinux_ip_postroute(struct sk_buff *skb, int ifindex,
 	return NF_ACCEPT;
 }
 
-static unsigned int selinux_ipv4_postroute(const struct nf_hook_ops *ops,
-					   struct sk_buff *skb,
-					   const struct net_device *in,
-					   const struct net_device *out,
-					   int (*okfn)(struct sk_buff *))
+static unsigned int
+selinux_ipv4_postroute(const struct nf_hook_ops *ops,
+		       struct sock *sk, struct sk_buff *skb,
+		       const struct net_device *in,
+		       const struct net_device *out,
+		       int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return selinux_ip_postroute(skb, out->ifindex, PF_INET);
 }
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
-static unsigned int selinux_ipv6_postroute(const struct nf_hook_ops *ops,
-					   struct sk_buff *skb,
-					   const struct net_device *in,
-					   const struct net_device *out,
-					   int (*okfn)(struct sk_buff *))
+static unsigned int
+selinux_ipv6_postroute(const struct nf_hook_ops *ops,
+		       struct sock *sk, struct sk_buff *skb,
+		       const struct net_device *in,
+		       const struct net_device *out,
+		       int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return selinux_ip_postroute(skb, out->ifindex, PF_INET6);
 }
-- 
1.9.3
