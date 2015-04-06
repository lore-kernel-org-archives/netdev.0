From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/4] netfilter: Pass socket pointer down through okfn().
Date: Sun, 05 Apr 2015 22:19:04 -0400 (EDT)
Message-ID: <20150405.221904.606225054570296194.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, pablo@netfilter.org,
	hannes@stressinduktion.org, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On the output paths in particular, we have to sometimes deal with two
socket contexts.  First, and usually skb->sk, is the local socket that
generated the frame.

And second, is potentially the socket used to control a tunneling
socket, such as one the encapsulates using UDP.

We do not want to disassociate skb->sk when encapsulating in order
to fix this, because that would break socket memory accounting.

The most extreme case where this can cause huge problems is an
AF_PACKET socket transmitting over a vxlan device.  We hit code
paths doing checks that assume they are dealing with an ipv4
socket, but are actually operating upon the AF_PACKET one.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h                 | 14 +++++--
 include/linux/netfilter.h                 | 62 +++++++++++++++++--------------
 include/linux/netfilter_bridge.h          |  2 +-
 include/net/dn_neigh.h                    |  6 +--
 include/net/ip.h                          |  3 +-
 include/net/ip6_route.h                   |  3 +-
 include/net/ipv6.h                        |  2 +-
 include/net/xfrm.h                        |  8 ++--
 net/bridge/br_forward.c                   | 13 ++++---
 net/bridge/br_input.c                     | 16 ++++----
 net/bridge/br_multicast.c                 |  3 +-
 net/bridge/br_netfilter.c                 | 56 +++++++++++++++-------------
 net/bridge/br_private.h                   |  6 +--
 net/bridge/br_stp_bpdu.c                  |  5 ++-
 net/core/dev.c                            | 10 ++---
 net/decnet/dn_neigh.c                     | 35 +++++++++--------
 net/decnet/dn_nsp_in.c                    |  5 ++-
 net/decnet/dn_route.c                     | 26 +++++++------
 net/ipv4/arp.c                            | 10 +++--
 net/ipv4/ip_forward.c                     |  8 ++--
 net/ipv4/ip_input.c                       | 10 +++--
 net/ipv4/ip_output.c                      | 45 ++++++++++++----------
 net/ipv4/ipmr.c                           |  7 ++--
 net/ipv4/raw.c                            |  4 +-
 net/ipv4/xfrm4_input.c                    |  5 ++-
 net/ipv4/xfrm4_output.c                   | 12 +++---
 net/ipv6/ip6_input.c                      | 11 +++---
 net/ipv6/ip6_output.c                     | 33 ++++++++--------
 net/ipv6/ip6mr.c                          |  7 ++--
 net/ipv6/mcast.c                          |  9 +++--
 net/ipv6/ndisc.c                          |  5 ++-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c |  2 +-
 net/ipv6/output_core.c                    |  4 +-
 net/ipv6/raw.c                            |  4 +-
 net/ipv6/xfrm6_input.c                    |  3 +-
 net/ipv6/xfrm6_output.c                   | 15 ++++----
 net/netfilter/ipvs/ip_vs_xmit.c           |  8 ++--
 net/netfilter/nf_queue.c                  |  2 +-
 net/xfrm/xfrm_output.c                    | 16 ++++----
 39 files changed, 277 insertions(+), 218 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a710d22..db0eb12 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2165,8 +2165,12 @@ int dev_open(struct net_device *dev);
 int dev_close(struct net_device *dev);
 int dev_close_many(struct list_head *head, bool unlink);
 void dev_disable_lro(struct net_device *dev);
-int dev_loopback_xmit(struct sk_buff *newskb);
-int dev_queue_xmit(struct sk_buff *skb);
+int dev_loopback_xmit(struct sock *sk, struct sk_buff *newskb);
+int dev_queue_xmit_sk(struct sock *sk, struct sk_buff *skb);
+static inline int dev_queue_xmit(struct sk_buff *skb)
+{
+	return dev_queue_xmit_sk(skb->sk, skb);
+}
 int dev_queue_xmit_accel(struct sk_buff *skb, void *accel_priv);
 int register_netdevice(struct net_device *dev);
 void unregister_netdevice_queue(struct net_device *dev, struct list_head *head);
@@ -2921,7 +2925,11 @@ static inline void dev_consume_skb_any(struct sk_buff *skb)
 
 int netif_rx(struct sk_buff *skb);
 int netif_rx_ni(struct sk_buff *skb);
-int netif_receive_skb(struct sk_buff *skb);
+int netif_receive_skb_sk(struct sock *sk, struct sk_buff *skb);
+static inline int netif_receive_skb(struct sk_buff *skb)
+{
+	return netif_receive_skb_sk(skb->sk, skb);
+}
 gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb);
 void napi_gro_flush(struct napi_struct *napi, bool flush_old);
 struct sk_buff *napi_get_frags(struct napi_struct *napi);
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index f8f58fa..63560d0 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -54,7 +54,7 @@ struct nf_hook_state {
 	struct net_device *in;
 	struct net_device *out;
 	struct sock *sk;
-	int (*okfn)(struct sk_buff *);
+	int (*okfn)(struct sock *, struct sk_buff *);
 };
 
 static inline void nf_hook_state_init(struct nf_hook_state *p,
@@ -63,7 +63,7 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
 				      struct net_device *indev,
 				      struct net_device *outdev,
 				      struct sock *sk,
-				      int (*okfn)(struct sk_buff *))
+				      int (*okfn)(struct sock *, struct sk_buff *))
 {
 	p->hook = hook;
 	p->thresh = thresh;
@@ -156,26 +156,29 @@ int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state);
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
 	if (nf_hooks_active(pf, hook)) {
 		struct nf_hook_state state;
 
 		nf_hook_state_init(&state, hook, thresh, pf,
-				   indev, outdev, NULL, okfn);
+				   indev, outdev, sk, okfn);
 		return nf_hook_slow(skb, &state);
 	}
 	return 1;
 }
 
-static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
-			  struct net_device *indev, struct net_device *outdev,
-			  int (*okfn)(struct sk_buff *))
+static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sock *sk,
+			  struct sk_buff *skb, struct net_device *indev,
+			  struct net_device *outdev,
+			  int (*okfn)(struct sock *, struct sk_buff *))
 {
-	return nf_hook_thresh(pf, hook, skb, indev, outdev, okfn, INT_MIN);
+	return nf_hook_thresh(pf, hook, sk, skb, indev, outdev, okfn, INT_MIN);
 }
                    
 /* Activate hook; either okfn or kfree_skb called, unless a hook
@@ -196,35 +199,36 @@ static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
 */
 
 static inline int
-NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct sk_buff *skb,
-	       struct net_device *in, struct net_device *out,
-	       int (*okfn)(struct sk_buff *), int thresh)
+NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct sock *sk,
+	       struct sk_buff *skb, struct net_device *in,
+	       struct net_device *out,
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
-	     struct net_device *in, struct net_device *out,
-	     int (*okfn)(struct sk_buff *), bool cond)
+NF_HOOK_COND(uint8_t pf, unsigned int hook, struct sock *sk,
+	     struct sk_buff *skb, struct net_device *in, struct net_device *out,
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
+NF_HOOK(uint8_t pf, unsigned int hook, struct sock *sk, struct sk_buff *skb,
 	struct net_device *in, struct net_device *out,
-	int (*okfn)(struct sk_buff *))
+	int (*okfn)(struct sock *, struct sk_buff *))
 {
-	return NF_HOOK_THRESH(pf, hook, skb, in, out, okfn, INT_MIN);
+	return NF_HOOK_THRESH(pf, hook, sk, skb, in, out, okfn, INT_MIN);
 }
 
 /* Call setsockopt() */
@@ -324,19 +328,21 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 }
 
 #else /* !CONFIG_NETFILTER */
-#define NF_HOOK(pf, hook, skb, indev, outdev, okfn) (okfn)(skb)
-#define NF_HOOK_COND(pf, hook, skb, indev, outdev, okfn, cond) (okfn)(skb)
+#define NF_HOOK(pf, hook, sk, skb, indev, outdev, okfn) (okfn)(sk, skb)
+#define NF_HOOK_COND(pf, hook, sk, skb, indev, outdev, okfn, cond) (okfn)(sk, skb)
 static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
+				 struct sock *sk,
 				 struct sk_buff *skb,
 				 struct net_device *indev,
 				 struct net_device *outdev,
-				 int (*okfn)(struct sk_buff *), int thresh)
+				 int (*okfn)(struct sock *sk, struct sk_buff *), int thresh)
 {
-	return okfn(skb);
+	return okfn(sk, skb);
 }
-static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sk_buff *skb,
-			  struct net_device *indev, struct net_device *outdev,
-			  int (*okfn)(struct sk_buff *))
+static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sock *sk,
+			  struct sk_buff *skb, struct net_device *indev,
+			  struct net_device *outdev,
+			  int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return 1;
 }
diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 2734977..5fc0a0f 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -30,7 +30,7 @@ static inline unsigned int nf_bridge_mtu_reduction(const struct sk_buff *skb)
 	return 0;
 }
 
-int br_handle_frame_finish(struct sk_buff *skb);
+int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb);
 
 static inline void br_drop_fake_rtable(struct sk_buff *skb)
 {
diff --git a/include/net/dn_neigh.h b/include/net/dn_neigh.h
index 0f26aa7..d042426 100644
--- a/include/net/dn_neigh.h
+++ b/include/net/dn_neigh.h
@@ -18,11 +18,11 @@ struct dn_neigh {
 
 void dn_neigh_init(void);
 void dn_neigh_cleanup(void);
-int dn_neigh_router_hello(struct sk_buff *skb);
-int dn_neigh_endnode_hello(struct sk_buff *skb);
+int dn_neigh_router_hello(struct sock *sk, struct sk_buff *skb);
+int dn_neigh_endnode_hello(struct sock *sk, struct sk_buff *skb);
 void dn_neigh_pointopoint_hello(struct sk_buff *skb);
 int dn_neigh_elist(struct net_device *dev, unsigned char *ptr, int n);
-int dn_to_neigh_output(struct sk_buff *skb);
+int dn_to_neigh_output(struct sock *sk, struct sk_buff *skb);
 
 extern struct neigh_table dn_neigh_table;
 
diff --git a/include/net/ip.h b/include/net/ip.h
index d0808a3..2b2a481 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -108,7 +108,8 @@ int ip_local_deliver(struct sk_buff *skb);
 int ip_mr_input(struct sk_buff *skb);
 int ip_output(struct sock *sk, struct sk_buff *skb);
 int ip_mc_output(struct sock *sk, struct sk_buff *skb);
-int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
+int ip_fragment(struct sock *sk, struct sk_buff *skb,
+		int (*output)(struct sock *, struct sk_buff *));
 int ip_do_nat(struct sk_buff *skb);
 void ip_send_check(struct iphdr *ip);
 int __ip_local_out(struct sk_buff *skb);
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
index 65142e6..b6ae959 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -769,7 +769,7 @@ static inline u8 ip6_tclass(__be32 flowinfo)
 int ipv6_rcv(struct sk_buff *skb, struct net_device *dev,
 	     struct packet_type *pt, struct net_device *orig_dev);
 
-int ip6_rcv_finish(struct sk_buff *skb);
+int ip6_rcv_finish(struct sock *sk, struct sk_buff *skb);
 
 /*
  *	upper-layer output functions
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 461f835..36ac102 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -332,7 +332,7 @@ struct xfrm_state_afinfo {
 	int			(*tmpl_sort)(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n);
 	int			(*state_sort)(struct xfrm_state **dst, struct xfrm_state **src, int n);
 	int			(*output)(struct sock *sk, struct sk_buff *skb);
-	int			(*output_finish)(struct sk_buff *skb);
+	int			(*output_finish)(struct sock *sk, struct sk_buff *skb);
 	int			(*extract_input)(struct xfrm_state *x,
 						 struct sk_buff *skb);
 	int			(*extract_output)(struct xfrm_state *x,
@@ -1503,7 +1503,7 @@ int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type);
 int xfrm_input_resume(struct sk_buff *skb, int nexthdr);
 int xfrm_output_resume(struct sk_buff *skb, int err);
-int xfrm_output(struct sk_buff *skb);
+int xfrm_output(struct sock *sk, struct sk_buff *skb);
 int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 void xfrm_local_error(struct sk_buff *skb, int mtu);
 int xfrm4_extract_header(struct sk_buff *skb);
@@ -1524,7 +1524,7 @@ static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 int xfrm4_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm4_output(struct sock *sk, struct sk_buff *skb);
-int xfrm4_output_finish(struct sk_buff *skb);
+int xfrm4_output_finish(struct sock *sk, struct sk_buff *skb);
 int xfrm4_rcv_cb(struct sk_buff *skb, u8 protocol, int err);
 int xfrm4_protocol_register(struct xfrm4_protocol *handler, unsigned char protocol);
 int xfrm4_protocol_deregister(struct xfrm4_protocol *handler, unsigned char protocol);
@@ -1549,7 +1549,7 @@ __be32 xfrm6_tunnel_spi_lookup(struct net *net, const xfrm_address_t *saddr);
 int xfrm6_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb);
 int xfrm6_output(struct sock *sk, struct sk_buff *skb);
-int xfrm6_output_finish(struct sk_buff *skb);
+int xfrm6_output_finish(struct sock *sk, struct sk_buff *skb);
 int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 			  u8 **prevhdr);
 
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 3304a54..e97572b 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -35,7 +35,7 @@ static inline int should_deliver(const struct net_bridge_port *p,
 		p->state == BR_STATE_FORWARDING;
 }
 
-int br_dev_queue_push_xmit(struct sk_buff *skb)
+int br_dev_queue_push_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	if (!is_skb_forwardable(skb->dev, skb)) {
 		kfree_skb(skb);
@@ -49,9 +49,10 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(br_dev_queue_push_xmit);
 
-int br_forward_finish(struct sk_buff *skb)
+int br_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
-	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING, skb, NULL, skb->dev,
+	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING, sk, skb,
+		       NULL, skb->dev,
 		       br_dev_queue_push_xmit);
 
 }
@@ -75,7 +76,8 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 		return;
 	}
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb,
+		NULL, skb->dev,
 		br_forward_finish);
 }
 
@@ -96,7 +98,8 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 	skb->dev = to->dev;
 	skb_forward_csum(skb);
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, indev, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, NULL, skb,
+		indev, skb->dev,
 		br_forward_finish);
 }
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 052c5eb..f921a5d 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -55,8 +55,9 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	if (!skb)
 		return NET_RX_DROP;
 
-	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
-		       netif_receive_skb);
+	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, NULL, skb,
+		       indev, NULL,
+		       netif_receive_skb_sk);
 }
 
 static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
@@ -119,7 +120,7 @@ static void br_do_proxy_arp(struct sk_buff *skb, struct net_bridge *br,
 }
 
 /* note: already called with rcu_read_lock */
-int br_handle_frame_finish(struct sk_buff *skb)
+int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb)
 {
 	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
@@ -207,7 +208,7 @@ drop:
 EXPORT_SYMBOL_GPL(br_handle_frame_finish);
 
 /* note: already called with rcu_read_lock */
-static int br_handle_local_finish(struct sk_buff *skb)
+static int br_handle_local_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_bridge_port *p = br_port_get_rcu(skb->dev);
 	u16 vid = 0;
@@ -277,8 +278,8 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		}
 
 		/* Deliver packet to local host only */
-		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-			    NULL, br_handle_local_finish)) {
+		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, NULL, skb,
+			    skb->dev, NULL, br_handle_local_finish)) {
 			return RX_HANDLER_CONSUMED; /* consumed by filter */
 		} else {
 			*pskb = skb;
@@ -302,7 +303,8 @@ forward:
 		if (ether_addr_equal(p->br->dev->dev_addr, dest))
 			skb->pkt_type = PACKET_HOST;
 
-		NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
+		NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, NULL, skb,
+			skb->dev, NULL,
 			br_handle_frame_finish);
 		break;
 	default:
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index c465876..4b6722f 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -814,7 +814,8 @@ static void __br_multicast_send_query(struct net_bridge *br,
 
 	if (port) {
 		skb->dev = port->dev;
-		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
+		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb,
+			NULL, skb->dev,
 			br_dev_queue_push_xmit);
 	} else {
 		br_multicast_select_own_querier(br, ip, skb);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 7527e94..acd31c9 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -261,7 +261,7 @@ static void nf_bridge_update_protocol(struct sk_buff *skb)
 /* PF_BRIDGE/PRE_ROUTING *********************************************/
 /* Undo the changes made for ip6tables PREROUTING and continue the
  * bridge PRE_ROUTING hook. */
-static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
+static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct rtable *rt;
@@ -282,7 +282,8 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, sk, skb,
+		       skb->dev, NULL,
 		       br_handle_frame_finish, 1);
 
 	return 0;
@@ -293,7 +294,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
  * don't, we use the neighbour framework to find out. In both cases, we make
  * sure that br_handle_frame_finish() is called afterwards.
  */
-static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
+static int br_nf_pre_routing_finish_bridge(struct sock *sk, struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct neighbour *neigh;
@@ -310,7 +311,7 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 		if (neigh->hh.hh_len) {
 			neigh_hh_bridge(&neigh->hh, skb);
 			skb->dev = nf_bridge->physindev;
-			ret = br_handle_frame_finish(skb);
+			ret = br_handle_frame_finish(sk, skb);
 		} else {
 			/* the neighbour function below overwrites the complete
 			 * MAC header, so we save the Ethernet source address and
@@ -387,7 +388,7 @@ static bool dnat_took_place(const struct sk_buff *skb)
  * device, we proceed as if ip_route_input() succeeded. If it differs from the
  * logical bridge port or if ip_route_output_key() fails we drop the packet.
  */
-static int br_nf_pre_routing_finish(struct sk_buff *skb)
+static int br_nf_pre_routing_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	struct iphdr *iph = ip_hdr(skb);
@@ -440,7 +441,7 @@ bridged_dnat:
 				nf_bridge_push_encap_header(skb);
 				NF_HOOK_THRESH(NFPROTO_BRIDGE,
 					       NF_BR_PRE_ROUTING,
-					       skb, skb->dev, NULL,
+					       sk, skb, skb->dev, NULL,
 					       br_nf_pre_routing_finish_bridge,
 					       1);
 				return 0;
@@ -460,7 +461,8 @@ bridged_dnat:
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, sk, skb,
+		       skb->dev, NULL,
 		       br_handle_frame_finish, 1);
 
 	return 0;
@@ -596,7 +598,8 @@ static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
 		return NF_DROP;
 
 	skb->protocol = htons(ETH_P_IPV6);
-	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, state->sk, skb,
+		skb->dev, NULL,
 		br_nf_pre_routing_finish_ipv6);
 
 	return NF_STOLEN;
@@ -651,7 +654,8 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 
 	skb->protocol = htons(ETH_P_IP);
 
-	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, state->sk, skb,
+		skb->dev, NULL,
 		br_nf_pre_routing_finish);
 
 	return NF_STOLEN;
@@ -674,7 +678,7 @@ static unsigned int br_nf_local_in(const struct nf_hook_ops *ops,
 }
 
 /* PF_BRIDGE/FORWARD *************************************************/
-static int br_nf_forward_finish(struct sk_buff *skb)
+static int br_nf_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct net_device *in;
@@ -691,8 +695,8 @@ static int br_nf_forward_finish(struct sk_buff *skb)
 	}
 	nf_bridge_push_encap_header(skb);
 
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, in,
-		       skb->dev, br_forward_finish, 1);
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, sk, skb,
+		       in, skb->dev, br_forward_finish, 1);
 	return 0;
 }
 
@@ -746,7 +750,8 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	else
 		skb->protocol = htons(ETH_P_IPV6);
 
-	NF_HOOK(pf, NF_INET_FORWARD, skb, brnf_get_logical_dev(skb, state->in),
+	NF_HOOK(pf, NF_INET_FORWARD, NULL, skb,
+		brnf_get_logical_dev(skb, state->in),
 		parent,	br_nf_forward_finish);
 
 	return NF_STOLEN;
@@ -780,8 +785,8 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 	}
 	*d = state->in;
-	NF_HOOK(NFPROTO_ARP, NF_ARP_FORWARD, skb, state->in,
-		state->out, br_nf_forward_finish);
+	NF_HOOK(NFPROTO_ARP, NF_ARP_FORWARD, state->sk, skb,
+		state->in, state->out, br_nf_forward_finish);
 
 	return NF_STOLEN;
 }
@@ -804,24 +809,24 @@ static bool nf_bridge_copy_header(struct sk_buff *skb)
 	return true;
 }
 
-static int br_nf_push_frag_xmit(struct sk_buff *skb)
+static int br_nf_push_frag_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	if (!nf_bridge_copy_header(skb)) {
 		kfree_skb(skb);
 		return 0;
 	}
 
-	return br_dev_queue_push_xmit(skb);
+	return br_dev_queue_push_xmit(sk, skb);
 }
 
-static int br_nf_dev_queue_xmit(struct sk_buff *skb)
+static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	int ret;
 	int frag_max_size;
 	unsigned int mtu_reserved;
 
 	if (skb_is_gso(skb) || skb->protocol != htons(ETH_P_IP))
-		return br_dev_queue_push_xmit(skb);
+		return br_dev_queue_push_xmit(sk, skb);
 
 	mtu_reserved = nf_bridge_mtu_reduction(skb);
 	/* This is wrong! We should preserve the original fragment
@@ -833,16 +838,16 @@ static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 			/* Drop invalid packet */
 			return NF_DROP;
 		IPCB(skb)->frag_max_size = frag_max_size;
-		ret = ip_fragment(skb, br_nf_push_frag_xmit);
+		ret = ip_fragment(sk, skb, br_nf_push_frag_xmit);
 	} else
-		ret = br_dev_queue_push_xmit(skb);
+		ret = br_dev_queue_push_xmit(sk, skb);
 
 	return ret;
 }
 #else
-static int br_nf_dev_queue_xmit(struct sk_buff *skb)
+static int br_nf_dev_queue_xmit(struct sock *sk, struct sk_buff *skb)
 {
-        return br_dev_queue_push_xmit(skb);
+        return br_dev_queue_push_xmit(sk, skb);
 }
 #endif
 
@@ -887,7 +892,8 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 	else
 		skb->protocol = htons(ETH_P_IPV6);
 
-	NF_HOOK(pf, NF_INET_POST_ROUTING, skb, NULL, realoutdev,
+	NF_HOOK(pf, NF_INET_POST_ROUTING, state->sk, skb,
+		NULL, realoutdev,
 		br_nf_dev_queue_xmit);
 
 	return NF_STOLEN;
@@ -927,7 +933,7 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN),
 				       skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
 	skb->dev = nf_bridge->physindev;
-	br_handle_frame_finish(skb);
+	br_handle_frame_finish(NULL, skb);
 }
 
 static int br_nf_dev_xmit(struct sk_buff *skb)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index b46fa0c..6ca0251 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -410,10 +410,10 @@ int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
 
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
@@ -431,7 +431,7 @@ void br_port_flags_change(struct net_bridge_port *port, unsigned long mask);
 void br_manage_promisc(struct net_bridge *br);
 
 /* br_input.c */
-int br_handle_frame_finish(struct sk_buff *skb);
+int br_handle_frame_finish(struct sock *sk, struct sk_buff *skb);
 rx_handler_result_t br_handle_frame(struct sk_buff **pskb);
 
 static inline bool br_rx_handler_check_rcu(const struct net_device *dev)
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index bdb459d..534fc4c 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -54,8 +54,9 @@ static void br_send_bpdu(struct net_bridge_port *p,
 
 	skb_reset_mac_header(skb);
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
-		dev_queue_xmit);
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb,
+		NULL, skb->dev,
+		dev_queue_xmit_sk);
 }
 
 static inline void br_set_ticks(unsigned char *dest, int j)
diff --git a/net/core/dev.c b/net/core/dev.c
index 26622d6..2f0b457 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2877,7 +2877,7 @@ static DEFINE_PER_CPU(int, xmit_recursion);
  *	dev_loopback_xmit - loop back @skb
  *	@skb: buffer to transmit
  */
-int dev_loopback_xmit(struct sk_buff *skb)
+int dev_loopback_xmit(struct sock *sk, struct sk_buff *skb)
 {
 	skb_reset_mac_header(skb);
 	__skb_pull(skb, skb_network_offset(skb));
@@ -3015,11 +3015,11 @@ out:
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
@@ -3851,13 +3851,13 @@ static int netif_receive_skb_internal(struct sk_buff *skb)
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
index be1f08c..4507b18 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -194,7 +194,7 @@ static int dn_neigh_output(struct neighbour *neigh, struct sk_buff *skb)
 	return err;
 }
 
-static int dn_neigh_output_packet(struct sk_buff *skb)
+static int dn_neigh_output_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *)dst;
@@ -206,7 +206,8 @@ static int dn_neigh_output_packet(struct sk_buff *skb)
 /*
  * For talking to broadcast devices: Ethernet & PPP
  */
-static int dn_long_output(struct neighbour *neigh, struct sk_buff *skb)
+static int dn_long_output(struct neighbour *neigh, struct sock *sk,
+			  struct sk_buff *skb)
 {
 	struct net_device *dev = neigh->dev;
 	int headroom = dev->hard_header_len + sizeof(struct dn_long_packet) + 3;
@@ -245,14 +246,15 @@ static int dn_long_output(struct neighbour *neigh, struct sk_buff *skb)
 
 	skb_reset_network_header(skb);
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, skb, NULL,
-		       neigh->dev, dn_neigh_output_packet);
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, sk, skb,
+		       NULL, neigh->dev, dn_neigh_output_packet);
 }
 
 /*
  * For talking to pointopoint and multidrop devices: DDCMP and X.25
  */
-static int dn_short_output(struct neighbour *neigh, struct sk_buff *skb)
+static int dn_short_output(struct neighbour *neigh, struct sock *sk,
+			   struct sk_buff *skb)
 {
 	struct net_device *dev = neigh->dev;
 	int headroom = dev->hard_header_len + sizeof(struct dn_short_packet) + 2;
@@ -284,8 +286,8 @@ static int dn_short_output(struct neighbour *neigh, struct sk_buff *skb)
 
 	skb_reset_network_header(skb);
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, skb, NULL,
-		       neigh->dev, dn_neigh_output_packet);
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, sk, skb,
+		       NULL, neigh->dev, dn_neigh_output_packet);
 }
 
 /*
@@ -293,7 +295,8 @@ static int dn_short_output(struct neighbour *neigh, struct sk_buff *skb)
  * Phase 3 output is the same as short output, execpt that
  * it clears the area bits before transmission.
  */
-static int dn_phase3_output(struct neighbour *neigh, struct sk_buff *skb)
+static int dn_phase3_output(struct neighbour *neigh, struct sock *sk,
+			    struct sk_buff *skb)
 {
 	struct net_device *dev = neigh->dev;
 	int headroom = dev->hard_header_len + sizeof(struct dn_short_packet) + 2;
@@ -324,11 +327,11 @@ static int dn_phase3_output(struct neighbour *neigh, struct sk_buff *skb)
 
 	skb_reset_network_header(skb);
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, skb, NULL,
-		       neigh->dev, dn_neigh_output_packet);
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, sk, skb,
+		       NULL, neigh->dev, dn_neigh_output_packet);
 }
 
-int dn_to_neigh_output(struct sk_buff *skb)
+int dn_to_neigh_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct dn_route *rt = (struct dn_route *) dst;
@@ -347,11 +350,11 @@ int dn_to_neigh_output(struct sk_buff *skb)
 	rcu_read_unlock();
 
 	if (dn->flags & DN_NDFLAG_P3)
-		return dn_phase3_output(neigh, skb);
+		return dn_phase3_output(neigh, sk, skb);
 	if (use_long)
-		return dn_long_output(neigh, skb);
+		return dn_long_output(neigh, sk, skb);
 	else
-		return dn_short_output(neigh, skb);
+		return dn_short_output(neigh, sk, skb);
 }
 
 /*
@@ -372,7 +375,7 @@ void dn_neigh_pointopoint_hello(struct sk_buff *skb)
 /*
  * Ethernet router hello message received
  */
-int dn_neigh_router_hello(struct sk_buff *skb)
+int dn_neigh_router_hello(struct sock *sk, struct sk_buff *skb)
 {
 	struct rtnode_hello_message *msg = (struct rtnode_hello_message *)skb->data;
 
@@ -434,7 +437,7 @@ int dn_neigh_router_hello(struct sk_buff *skb)
 /*
  * Endnode hello message received
  */
-int dn_neigh_endnode_hello(struct sk_buff *skb)
+int dn_neigh_endnode_hello(struct sock *sk, struct sk_buff *skb)
 {
 	struct endnode_hello_message *msg = (struct endnode_hello_message *)skb->data;
 	struct neighbour *neigh;
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index fe5f014..a321eac 100644
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
@@ -814,7 +814,8 @@ free_out:
 
 int dn_nsp_rx(struct sk_buff *skb)
 {
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_IN, skb, skb->dev, NULL,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_IN, NULL, skb,
+		       skb->dev, NULL,
 		       dn_nsp_rx_packet);
 }
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 9ab0c4b..03227ff 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -512,7 +512,7 @@ static int dn_return_long(struct sk_buff *skb)
  *
  * Returns: result of input function if route is found, error code otherwise
  */
-static int dn_route_rx_packet(struct sk_buff *skb)
+static int dn_route_rx_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct dn_skb_cb *cb;
 	int err;
@@ -573,7 +573,8 @@ static int dn_route_rx_long(struct sk_buff *skb)
 	ptr++;
 	cb->hops = *ptr++; /* Visit Count */
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_PRE_ROUTING, skb, skb->dev, NULL,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_PRE_ROUTING, NULL, skb,
+		       skb->dev, NULL,
 		       dn_route_rx_packet);
 
 drop_it:
@@ -600,7 +601,8 @@ static int dn_route_rx_short(struct sk_buff *skb)
 	ptr += 2;
 	cb->hops = *ptr & 0x3f;
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_PRE_ROUTING, skb, skb->dev, NULL,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_PRE_ROUTING, NULL, skb,
+		       skb->dev, NULL,
 		       dn_route_rx_packet);
 
 drop_it:
@@ -608,7 +610,7 @@ drop_it:
 	return NET_RX_DROP;
 }
 
-static int dn_route_discard(struct sk_buff *skb)
+static int dn_route_discard(struct sock *sk, struct sk_buff *skb)
 {
 	/*
 	 * I know we drop the packet here, but thats considered success in
@@ -618,7 +620,7 @@ static int dn_route_discard(struct sk_buff *skb)
 	return NET_RX_SUCCESS;
 }
 
-static int dn_route_ptp_hello(struct sk_buff *skb)
+static int dn_route_ptp_hello(struct sock *sk, struct sk_buff *skb)
 {
 	dn_dev_hello(skb);
 	dn_neigh_pointopoint_hello(skb);
@@ -704,22 +706,22 @@ int dn_route_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type
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
@@ -768,7 +770,8 @@ static int dn_output(struct sock *sk, struct sk_buff *skb)
 	cb->rt_flags |= DN_RT_F_IE;
 	cb->hops = 0;
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_OUT, skb, NULL, dev,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_OUT, sk, skb,
+		       NULL, dev,
 		       dn_to_neigh_output);
 
 error:
@@ -816,7 +819,8 @@ static int dn_forward(struct sk_buff *skb)
 	if (rt->rt_flags & RTCF_DOREDIRECT)
 		cb->rt_flags |= DN_RT_F_IE;
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_FORWARD, skb, dev, skb->dev,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_FORWARD, NULL, skb,
+		       dev, skb->dev,
 		       dn_to_neigh_output);
 
 drop:
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index c6e67aa..933a928 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -591,7 +591,8 @@ EXPORT_SYMBOL(arp_create);
 void arp_xmit(struct sk_buff *skb)
 {
 	/* Send it off, maybe filter it using firewalling first.  */
-	NF_HOOK(NFPROTO_ARP, NF_ARP_OUT, skb, NULL, skb->dev, dev_queue_xmit);
+	NF_HOOK(NFPROTO_ARP, NF_ARP_OUT, NULL, skb,
+		NULL, skb->dev, dev_queue_xmit_sk);
 }
 EXPORT_SYMBOL(arp_xmit);
 
@@ -625,7 +626,7 @@ EXPORT_SYMBOL(arp_send);
  *	Process an arp request.
  */
 
-static int arp_process(struct sk_buff *skb)
+static int arp_process(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
@@ -846,7 +847,7 @@ out:
 
 static void parp_redo(struct sk_buff *skb)
 {
-	arp_process(skb);
+	arp_process(NULL, skb);
 }
 
 
@@ -879,7 +880,8 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	memset(NEIGH_CB(skb), 0, sizeof(struct neighbour_cb));
 
-	return NF_HOOK(NFPROTO_ARP, NF_ARP_IN, skb, dev, NULL, arp_process);
+	return NF_HOOK(NFPROTO_ARP, NF_ARP_IN, NULL, skb,
+		       dev, NULL, arp_process);
 
 consumeskb:
 	consume_skb(skb);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index d9bc28a..939992c 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -57,7 +57,7 @@ static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
 }
 
 
-static int ip_forward_finish(struct sk_buff *skb)
+static int ip_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct ip_options *opt	= &(IPCB(skb)->opt);
 
@@ -68,7 +68,7 @@ static int ip_forward_finish(struct sk_buff *skb)
 		ip_forward_options(skb);
 
 	skb_sender_cpu_clear(skb);
-	return dst_output(skb);
+	return dst_output_sk(sk, skb);
 }
 
 int ip_forward(struct sk_buff *skb)
@@ -136,8 +136,8 @@ int ip_forward(struct sk_buff *skb)
 
 	skb->priority = rt_tos2priority(iph->tos);
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, skb, skb->dev,
-		       rt->dst.dev, ip_forward_finish);
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, NULL, skb,
+		       skb->dev, rt->dst.dev, ip_forward_finish);
 
 sr_failed:
 	/*
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 2e0410e..2db4c87 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -187,7 +187,7 @@ bool ip_call_ra_chain(struct sk_buff *skb)
 	return false;
 }
 
-static int ip_local_deliver_finish(struct sk_buff *skb)
+static int ip_local_deliver_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb->dev);
 
@@ -253,7 +253,8 @@ int ip_local_deliver(struct sk_buff *skb)
 			return 0;
 	}
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN, NULL, skb,
+		       skb->dev, NULL,
 		       ip_local_deliver_finish);
 }
 
@@ -309,7 +310,7 @@ drop:
 int sysctl_ip_early_demux __read_mostly = 1;
 EXPORT_SYMBOL(sysctl_ip_early_demux);
 
-static int ip_rcv_finish(struct sk_buff *skb)
+static int ip_rcv_finish(struct sock *sk, struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
@@ -451,7 +452,8 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, dev, NULL,
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, NULL, skb,
+		       dev, NULL,
 		       ip_rcv_finish);
 
 csum_error:
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 26f6f79..5da4d15 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -91,14 +91,19 @@ void ip_send_check(struct iphdr *iph)
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
+}
+
+int __ip_local_out(struct sk_buff *skb)
+{
+	return __ip_local_out_sk(skb->sk, skb);
 }
 
 int ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
@@ -163,7 +168,7 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 }
 EXPORT_SYMBOL_GPL(ip_build_and_send_pkt);
 
-static inline int ip_finish_output2(struct sk_buff *skb)
+static inline int ip_finish_output2(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct rtable *rt = (struct rtable *)dst;
@@ -211,7 +216,7 @@ static inline int ip_finish_output2(struct sk_buff *skb)
 	return -EINVAL;
 }
 
-static int ip_finish_output_gso(struct sk_buff *skb)
+static int ip_finish_output_gso(struct sock *sk, struct sk_buff *skb)
 {
 	netdev_features_t features;
 	struct sk_buff *segs;
@@ -220,7 +225,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 	/* common case: locally created skb or seglen is <= mtu */
 	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
 	      skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
-		return ip_finish_output2(skb);
+		return ip_finish_output2(sk, skb);
 
 	/* Slowpath -  GSO segment length is exceeding the dst MTU.
 	 *
@@ -243,7 +248,7 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 		int err;
 
 		segs->next = NULL;
-		err = ip_fragment(segs, ip_finish_output2);
+		err = ip_fragment(sk, segs, ip_finish_output2);
 
 		if (err && ret == 0)
 			ret = err;
@@ -253,22 +258,22 @@ static int ip_finish_output_gso(struct sk_buff *skb)
 	return ret;
 }
 
-static int ip_finish_output(struct sk_buff *skb)
+static int ip_finish_output(struct sock *sk, struct sk_buff *skb)
 {
 #if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
 	/* Policy lookup after SNAT yielded a new policy */
 	if (skb_dst(skb)->xfrm) {
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
@@ -307,7 +312,7 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb)
 			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 			if (newskb)
 				NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING,
-					newskb, NULL, newskb->dev,
+					sk, newskb, NULL, newskb->dev,
 					dev_loopback_xmit);
 		}
 
@@ -322,11 +327,11 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb)
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
@@ -340,7 +345,8 @@ int ip_output(struct sock *sk, struct sk_buff *skb)
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
-	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb, NULL, dev,
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb,
+			    NULL, dev,
 			    ip_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
@@ -480,7 +486,8 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
  *	single device frame, and queue such a frame for sending.
  */
 
-int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
+int ip_fragment(struct sock *sk, struct sk_buff *skb,
+		int (*output)(struct sock *, struct sk_buff *))
 {
 	struct iphdr *iph;
 	int ptr;
@@ -593,7 +600,7 @@ int ip_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 				ip_send_check(iph);
 			}
 
-			err = output(skb);
+			err = output(sk, skb);
 
 			if (!err)
 				IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGCREATES);
@@ -730,7 +737,7 @@ slow_path:
 
 		ip_send_check(iph);
 
-		err = output(skb2);
+		err = output(sk, skb2);
 		if (err)
 			goto fail;
 
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c204b72..8ebc14a 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1674,7 +1674,7 @@ static void ip_encap(struct net *net, struct sk_buff *skb,
 	nf_reset(skb);
 }
 
-static inline int ipmr_forward_finish(struct sk_buff *skb)
+static inline int ipmr_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct ip_options *opt = &(IPCB(skb)->opt);
 
@@ -1684,7 +1684,7 @@ static inline int ipmr_forward_finish(struct sk_buff *skb)
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
 
-	return dst_output(skb);
+	return dst_output_sk(sk, skb);
 }
 
 /*
@@ -1783,7 +1783,8 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 	 * not mrouter) cannot join to more than one interface - it will
 	 * result in receiving multiple packets.
 	 */
-	NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, skb, skb->dev, dev,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, NULL, skb,
+		skb->dev, dev,
 		ipmr_forward_finish);
 	return;
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 6d0fa8f..c0bb648 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -412,8 +412,8 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 		icmp_out_count(net, ((struct icmphdr *)
 			skb_transport_header(skb))->type);
 
-	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, skb, NULL,
-		      rt->dst.dev, dst_output);
+	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, sk, skb,
+		      NULL, rt->dst.dev, dst_output_sk);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index cac7468..60b032f 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -22,7 +22,7 @@ int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 	return xfrm4_extract_header(skb);
 }
 
-static inline int xfrm4_rcv_encap_finish(struct sk_buff *skb)
+static inline int xfrm4_rcv_encap_finish(struct sock *sk, struct sk_buff *skb)
 {
 	if (!skb_dst(skb)) {
 		const struct iphdr *iph = ip_hdr(skb);
@@ -52,7 +52,8 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
 
-	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, NULL, skb,
+		skb->dev, NULL,
 		xfrm4_rcv_encap_finish);
 	return 0;
 }
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index dab7381..2878dbf 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -69,7 +69,7 @@ int xfrm4_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(xfrm4_prepare_output);
 
-int xfrm4_output_finish(struct sk_buff *skb)
+int xfrm4_output_finish(struct sock *sk, struct sk_buff *skb)
 {
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
@@ -77,26 +77,26 @@ int xfrm4_output_finish(struct sk_buff *skb)
 	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 #endif
 
-	return xfrm_output(skb);
+	return xfrm_output(sk, skb);
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
 
-	return x->outer_mode->afinfo->output_finish(skb);
+	return x->outer_mode->afinfo->output_finish(sk, skb);
 }
 
 int xfrm4_output(struct sock *sk, struct sk_buff *skb)
 {
-	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, skb,
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb,
 			    NULL, skb_dst(skb)->dev, __xfrm4_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index fb97f7f..f2e464e 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -46,8 +46,7 @@
 #include <net/xfrm.h>
 #include <net/inet_ecn.h>
 
-
-int ip6_rcv_finish(struct sk_buff *skb)
+int ip6_rcv_finish(struct sock *sk, struct sk_buff *skb)
 {
 	if (sysctl_ip_early_demux && !skb_dst(skb) && skb->sk == NULL) {
 		const struct inet6_protocol *ipprot;
@@ -183,7 +182,8 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, skb, dev, NULL,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, NULL, skb,
+		       dev, NULL,
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
@@ -277,7 +277,8 @@ discard:
 
 int ip6_input(struct sk_buff *skb)
 {
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_IN, skb, skb->dev, NULL,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_IN, NULL, skb,
+		       skb->dev, NULL,
 		       ip6_input_finish);
 }
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 84c58da..6998eff 100644
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
@@ -70,7 +70,7 @@ static int ip6_finish_output2(struct sk_buff *skb)
 	if (ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr)) {
 		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
-		if (!(dev->flags & IFF_LOOPBACK) && sk_mc_loop(skb->sk) &&
+		if (!(dev->flags & IFF_LOOPBACK) && sk_mc_loop(sk) &&
 		    ((mroute6_socket(dev_net(dev), skb) &&
 		     !(IP6CB(skb)->flags & IP6SKB_FORWARDED)) ||
 		     ipv6_chk_mcast_addr(dev, &ipv6_hdr(skb)->daddr,
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
@@ -143,7 +143,8 @@ int ip6_output(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
-	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb, NULL, dev,
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, sk, skb,
+			    NULL, dev,
 			    ip6_finish_output,
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
@@ -223,8 +224,8 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	if ((skb->len <= mtu) || skb->ignore_df || skb_is_gso(skb)) {
 		IP6_UPD_PO_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_OUT, skb->len);
-		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
-			       dst->dev, dst_output);
+		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
+			       NULL, dst->dev, dst_output_sk);
 	}
 
 	skb->dev = dst->dev;
@@ -316,10 +317,10 @@ static int ip6_forward_proxy_check(struct sk_buff *skb)
 	return 0;
 }
 
-static inline int ip6_forward_finish(struct sk_buff *skb)
+static inline int ip6_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
 	skb_sender_cpu_clear(skb);
-	return dst_output(skb);
+	return dst_output_sk(sk, skb);
 }
 
 static unsigned int ip6_dst_mtu_forward(const struct dst_entry *dst)
@@ -511,7 +512,8 @@ int ip6_forward(struct sk_buff *skb)
 
 	IP6_INC_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
 	IP6_ADD_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTOCTETS, skb->len);
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, skb->dev, dst->dev,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, NULL, skb,
+		       skb->dev, dst->dev,
 		       ip6_forward_finish);
 
 error:
@@ -538,7 +540,8 @@ static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	skb_copy_secmark(to, from);
 }
 
-int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
+int ip6_fragment(struct sock *sk, struct sk_buff *skb,
+		 int (*output)(struct sock *, struct sk_buff *))
 {
 	struct sk_buff *frag;
 	struct rt6_info *rt = (struct rt6_info *)skb_dst(skb);
@@ -666,7 +669,7 @@ int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *))
 				ip6_copy_metadata(frag, skb);
 			}
 
-			err = output(skb);
+			err = output(sk, skb);
 			if (!err)
 				IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
 					      IPSTATS_MIB_FRAGCREATES);
@@ -799,7 +802,7 @@ slow_path:
 		/*
 		 *	Put this fragment into the sending queue.
 		 */
-		err = output(frag);
+		err = output(sk, frag);
 		if (err)
 			goto fail;
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 2645603..923c6f7 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1986,13 +1986,13 @@ int ip6mr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
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
@@ -2064,7 +2064,8 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 
 	IP6CB(skb)->flags |= IP6SKB_FORWARDED;
 
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, skb->dev, dev,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, NULL, skb,
+		       skb->dev, dev,
 		       ip6mr_forward2_finish);
 
 out_free:
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index fac1f27..083b292 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1644,8 +1644,9 @@ static void mld_sendpack(struct sk_buff *skb)
 
 	payload_len = skb->len;
 
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
-		      dst_output);
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
+		      net->ipv6.igmp_sk, skb, NULL, skb->dev,
+		      dst_output_sk);
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, ICMPV6_MLD2_REPORT);
@@ -2007,8 +2008,8 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	}
 
 	skb_dst_set(skb, dst);
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, skb->dev,
-		      dst_output);
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
+		      NULL, skb->dev, dst_output_sk);
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 71fde6c..96f153c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -463,8 +463,9 @@ static void ndisc_send_skb(struct sk_buff *skb,
 	idev = __in6_dev_get(dst->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
 
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
-		      dst_output);
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
+		      NULL, dst->dev,
+		      dst_output_sk);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
 		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index e2b8820..a45db0b 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -75,7 +75,7 @@ static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
 
 	nf_ct_frag6_consume_orig(reasm);
 
-	NF_HOOK_THRESH(NFPROTO_IPV6, ops->hooknum, reasm,
+	NF_HOOK_THRESH(NFPROTO_IPV6, ops->hooknum, state->sk, reasm,
 		       state->in, state->out,
 		       state->okfn, NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
 
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 4016a6e..7d1131d 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -146,8 +146,8 @@ int __ip6_local_out(struct sk_buff *skb)
 	ipv6_hdr(skb)->payload_len = htons(len);
 	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
 
-	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
-		       skb_dst(skb)->dev, dst_output);
+	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb->sk, skb,
+		       NULL, skb_dst(skb)->dev, dst_output_sk);
 }
 EXPORT_SYMBOL_GPL(__ip6_local_out);
 
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 79ccdb4..8072bd4 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -652,8 +652,8 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 		goto error_fault;
 
 	IP6_UPD_PO_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL,
-		      rt->dst.dev, dst_output);
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
+		      NULL, rt->dst.dev, dst_output_sk);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index f48fbe4..74bd178 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -42,7 +42,8 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
 
-	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, NULL, skb,
+		skb->dev, NULL,
 		ip6_rcv_finish);
 	return -1;
 }
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 010f8bd..09c76a7 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -120,7 +120,7 @@ int xfrm6_prepare_output(struct xfrm_state *x, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(xfrm6_prepare_output);
 
-int xfrm6_output_finish(struct sk_buff *skb)
+int xfrm6_output_finish(struct sock *sk, struct sk_buff *skb)
 {
 	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
 
@@ -128,10 +128,10 @@ int xfrm6_output_finish(struct sk_buff *skb)
 	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
 #endif
 
-	return xfrm_output(skb);
+	return xfrm_output(sk, skb);
 }
 
-static int __xfrm6_output(struct sk_buff *skb)
+static int __xfrm6_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct xfrm_state *x = dst->xfrm;
@@ -140,7 +140,7 @@ static int __xfrm6_output(struct sk_buff *skb)
 #ifdef CONFIG_NETFILTER
 	if (!x) {
 		IP6CB(skb)->flags |= IP6SKB_REROUTED;
-		return dst_output(skb);
+		return dst_output_sk(sk, skb);
 	}
 #endif
 
@@ -160,14 +160,15 @@ static int __xfrm6_output(struct sk_buff *skb)
 	if (x->props.mode == XFRM_MODE_TUNNEL &&
 	    ((skb->len > mtu && !skb_is_gso(skb)) ||
 		dst_allfrag(skb_dst(skb)))) {
-			return ip6_fragment(skb, x->outer_mode->afinfo->output_finish);
+		return ip6_fragment(sk, skb,
+				    x->outer_mode->afinfo->output_finish);
 	}
-	return x->outer_mode->afinfo->output_finish(skb);
+	return x->outer_mode->afinfo->output_finish(sk, skb);
 }
 
 int xfrm6_output(struct sock *sk, struct sk_buff *skb)
 {
-	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, skb,
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, sk, skb,
 			    NULL, skb_dst(skb)->dev, __xfrm6_output,
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index bf02932..19986ec 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -536,8 +536,8 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 		ip_vs_update_conntrack(skb, cp, 1);
 	if (!local) {
 		skb_forward_csum(skb);
-		NF_HOOK(pf, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
-			dst_output);
+		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
+			NULL, skb_dst(skb)->dev, dst_output_sk);
 	} else
 		ret = NF_ACCEPT;
 	return ret;
@@ -554,8 +554,8 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 		ip_vs_notrack(skb);
 	if (!local) {
 		skb_forward_csum(skb);
-		NF_HOOK(pf, NF_INET_LOCAL_OUT, skb, NULL, skb_dst(skb)->dev,
-			dst_output);
+		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
+			NULL, skb_dst(skb)->dev, dst_output_sk);
 	} else
 		ret = NF_ACCEPT;
 	return ret;
diff --git a/net/netfilter/nf_queue.c b/net/netfilter/nf_queue.c
index c4a7066..3f3ac57 100644
--- a/net/netfilter/nf_queue.c
+++ b/net/netfilter/nf_queue.c
@@ -202,7 +202,7 @@ void nf_reinject(struct nf_queue_entry *entry, unsigned int verdict)
 	case NF_ACCEPT:
 	case NF_STOP:
 		local_bh_disable();
-		entry->state.okfn(skb);
+		entry->state.okfn(entry->state.sk, skb);
 		local_bh_enable();
 		break;
 	case NF_QUEUE:
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 7c53285..fbcedbe 100644
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
+			      NF_INET_POST_ROUTING, skb->sk, skb,
 			      NULL, skb_dst(skb)->dev, xfrm_output2);
 		if (unlikely(err != 1))
 			goto out;
@@ -144,12 +144,12 @@ out:
 }
 EXPORT_SYMBOL_GPL(xfrm_output_resume);
 
-static int xfrm_output2(struct sk_buff *skb)
+static int xfrm_output2(struct sock *sk, struct sk_buff *skb)
 {
 	return xfrm_output_resume(skb, 1);
 }
 
-static int xfrm_output_gso(struct sk_buff *skb)
+static int xfrm_output_gso(struct sock *sk, struct sk_buff *skb)
 {
 	struct sk_buff *segs;
 
@@ -165,7 +165,7 @@ static int xfrm_output_gso(struct sk_buff *skb)
 		int err;
 
 		segs->next = NULL;
-		err = xfrm_output2(segs);
+		err = xfrm_output2(sk, segs);
 
 		if (unlikely(err)) {
 			kfree_skb_list(nskb);
@@ -178,13 +178,13 @@ static int xfrm_output_gso(struct sk_buff *skb)
 	return 0;
 }
 
-int xfrm_output(struct sk_buff *skb)
+int xfrm_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	int err;
 
 	if (skb_is_gso(skb))
-		return xfrm_output_gso(skb);
+		return xfrm_output_gso(sk, skb);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		err = skb_checksum_help(skb);
@@ -195,7 +195,7 @@ int xfrm_output(struct sk_buff *skb)
 		}
 	}
 
-	return xfrm_output2(skb);
+	return xfrm_output2(sk, skb);
 }
 EXPORT_SYMBOL_GPL(xfrm_output);
 
-- 
2.1.0

