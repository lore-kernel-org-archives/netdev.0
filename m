From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 14/14] gtp: GSO support
Date: Mon, 18 Sep 2017 17:39:04 -0700
Message-ID: <20170919003904.5124-15-tom@quantonium.net>
References: <20170919003904.5124-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:46875 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750925AbdISAkF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 20:40:05 -0400
Received: by mail-pg0-f44.google.com with SMTP id i130so1093747pgc.3
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 17:40:05 -0700 (PDT)
In-Reply-To: <20170919003904.5124-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Need to define a gtp_gso_segment since the GTP header includes a length
field that must be set per packet. Also, GPv0 header includes a sequence
number that is incremented per packet.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c            | 176 +++++++++++++++++++++++++++++++++++++++----
 include/uapi/linux/if_link.h |   1 -
 2 files changed, 163 insertions(+), 14 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 2f9d810cf19f..a2c4d9804a8f 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -120,6 +120,8 @@ static u32 gtp_h_initval;
 
 static void pdp_context_delete(struct pdp_ctx *pctx);
 
+static int gtp_gso_type;
+
 static inline u32 gtp0_hashfn(u64 tid)
 {
 	u32 *tid32 = (u32 *) &tid;
@@ -430,6 +432,69 @@ static int gtp1u_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	return 1;
 }
 
+static struct sk_buff *gtp_gso_segment(struct sk_buff *skb,
+				       netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	int tnl_hlen = skb->mac_len;
+	struct gtp0_header *gtp0;
+
+	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
+		return ERR_PTR(-EINVAL);
+
+	/* Make sure we have a mininal GTP header */
+	if (unlikely(tnl_hlen < min_t(size_t, sizeof(struct gtp0_header),
+				      sizeof(struct gtp1_header))))
+		return ERR_PTR(-EINVAL);
+
+	/* Determine version */
+	gtp0 = (struct gtp0_header *)skb->data;
+	switch (gtp0->flags >> 5) {
+	case GTP_V0: {
+		u16 tx_seq;
+
+		if (unlikely(tnl_hlen != sizeof(struct gtp0_header)))
+			return ERR_PTR(-EINVAL);
+
+		tx_seq = ntohs(gtp0->seq);
+
+		/* segment inner packet. */
+		segs = skb_mac_gso_segment(skb, features);
+		if (!IS_ERR_OR_NULL(segs)) {
+			skb = segs;
+			do {
+				gtp0 = (struct gtp0_header *)
+						skb_mac_header(skb);
+				gtp0->length = ntohs(skb->len - tnl_hlen);
+				gtp0->seq = htons(tx_seq);
+				tx_seq++;
+			} while ((skb = skb->next));
+		}
+		break;
+	}
+	case GTP_V1: {
+		struct gtp1_header *gtp1;
+
+		if (unlikely(tnl_hlen != sizeof(struct gtp1_header)))
+			return ERR_PTR(-EINVAL);
+
+		/* segment inner packet. */
+		segs = skb_mac_gso_segment(skb, features);
+		if (!IS_ERR_OR_NULL(segs)) {
+			skb = segs;
+			do {
+				gtp1 = (struct gtp1_header *)
+						skb_mac_header(skb);
+				gtp1->length = ntohs(skb->len - tnl_hlen);
+			} while ((skb = skb->next));
+		}
+		break;
+	}
+	}
+
+	return segs;
+}
+
 static struct sk_buff **gtp_gro_receive_finish(struct sock *sk,
 					       struct sk_buff **head,
 					       struct sk_buff *skb,
@@ -688,18 +753,25 @@ static inline void gtp0_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 {
 	int payload_len = skb->len;
 	struct gtp0_header *gtp0;
+	u32 tx_seq;
 
 	gtp0 = skb_push(skb, sizeof(*gtp0));
 
 	gtp0->flags	= 0x1e; /* v0, GTP-non-prime. */
 	gtp0->type	= GTP_TPDU;
 	gtp0->length	= htons(payload_len);
-	gtp0->seq	= htons((atomic_inc_return(&pctx->tx_seq) - 1) %
-				0xffff);
 	gtp0->flow	= htons(pctx->u.v0.flow);
 	gtp0->number	= 0xff;
 	gtp0->spare[0]	= gtp0->spare[1] = gtp0->spare[2] = 0xff;
 	gtp0->tid	= cpu_to_be64(pctx->u.v0.tid);
+
+	/* If skb is GSO allocate sequence numbers for all the segments */
+	tx_seq = skb_shinfo(skb)->gso_segs ?
+			atomic_add_return(skb_shinfo(skb)->gso_segs,
+					  &pctx->tx_seq) :
+			atomic_inc_return(&pctx->tx_seq);
+
+	gtp0->seq	= (htons((u16)tx_seq) - 1) & 0xffff;
 }
 
 static inline void gtp1_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
@@ -737,6 +809,59 @@ static void gtp_push_header(struct sk_buff *skb, struct pdp_ctx *pctx)
 	}
 }
 
+static size_t gtp_max_header_len(int version)
+
+{
+	switch (version) {
+	case GTP_V0:
+		return sizeof(struct gtp0_header);
+	case GTP_V1:
+		return sizeof(struct gtp1_header) + 4;
+	}
+
+	/* Should not happen */
+	return 0;
+}
+
+static int gtp_build_skb(struct sk_buff *skb, struct dst_entry *dst,
+			 struct pdp_ctx *pctx, bool xnet, int ip_hdr_len,
+			 bool udp_sum)
+{
+	int type = (udp_sum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL) |
+		   gtp_gso_type;
+	int min_headroom;
+	u16 protocol;
+	int err;
+
+	skb_scrub_packet(skb, xnet);
+
+	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len +
+		       gtp_max_header_len(pctx->gtp_version) + ip_hdr_len;
+
+	err = skb_cow_head(skb, min_headroom);
+	if (unlikely(err))
+		goto free_dst;
+
+	err = iptunnel_handle_offloads(skb, type);
+	if (err)
+		goto free_dst;
+
+	protocol = ipver_to_eth(ip_hdr(skb));
+
+	gtp_push_header(skb, pctx);
+
+	/* GTP header is treated as inner MAC header */
+	skb_reset_inner_mac_header(skb);
+
+	skb_set_inner_protocol(skb, protocol);
+
+	return 0;
+
+free_dst:
+	dst_release(dst);
+	return err;
+}
+
 static int gtp_xmit(struct sk_buff *skb, struct net_device *dev,
 		    struct pdp_ctx *pctx)
 {
@@ -746,13 +871,6 @@ static int gtp_xmit(struct sk_buff *skb, struct net_device *dev,
 	bool udp_csum;
 	int err = 0;
 
-	/* Ensure there is sufficient headroom. */
-	err = skb_cow_head(skb, dev->needed_headroom);
-	if (unlikely(err))
-		goto out_err;
-
-	skb_reset_inner_headers(skb);
-
 	if (pctx->peer_af == AF_INET) {
 		__be32 saddr = inet_sk(sk)->inet_saddr;
 		struct rtable *rt;
@@ -768,9 +886,13 @@ static int gtp_xmit(struct sk_buff *skb, struct net_device *dev,
 			goto out_err;
 		}
 
-		skb_dst_drop(skb);
+		err = gtp_build_skb(skb, &rt->dst, pctx, xnet,
+				    sizeof(struct iphdr),
+				    !(pctx->cfg_flags &
+				      GTP_F_UDP_ZERO_CSUM_TX));
+		if (err)
+			goto out_err;
 
-		gtp_push_header(skb, pctx);
 		udp_csum = !(pctx->cfg_flags & GTP_F_UDP_ZERO_CSUM_TX);
 		udp_tunnel_xmit_skb(rt, sk, skb, saddr,
 				    pctx->peer_addr_ip4.s_addr,
@@ -797,9 +919,13 @@ static int gtp_xmit(struct sk_buff *skb, struct net_device *dev,
 			goto out_err;
 		}
 
-		skb_dst_drop(skb);
+		err = gtp_build_skb(skb, dst, pctx, xnet,
+				    sizeof(struct ipv6hdr),
+				    !(pctx->cfg_flags &
+				      GTP_F_UDP_ZERO_CSUM6_TX));
+		if (err)
+			goto out_err;
 
-		gtp_push_header(skb, pctx);
 		udp_csum = !(pctx->cfg_flags & GTP_F_UDP_ZERO_CSUM6_TX);
 		udp_tunnel6_xmit_skb(dst, sk, skb, dev,
 				     &saddr, &pctx->peer_addr_ip6,
@@ -898,6 +1024,12 @@ static const struct net_device_ops gtp_netdev_ops = {
 	.ndo_get_stats64	= ip_tunnel_get_stats64,
 };
 
+#define GTP_FEATURES (NETIF_F_SG |		\
+		      NETIF_F_FRAGLIST |	\
+		      NETIF_F_HIGHDMA |		\
+		      NETIF_F_GSO_SOFTWARE |	\
+		      NETIF_F_HW_CSUM)
+
 static void gtp_link_setup(struct net_device *dev)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
@@ -912,7 +1044,13 @@ static void gtp_link_setup(struct net_device *dev)
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
 
 	dev->priv_flags	|= IFF_NO_QUEUE;
+
 	dev->features	|= NETIF_F_LLTX;
+	dev->features	|= GTP_FEATURES;
+
+	dev->hw_features |= GTP_FEATURES;
+	dev->hw_features |= NETIF_F_GSO_SOFTWARE;
+
 	netif_keep_dst(dev);
 
 	/* Assume largest header, ie. GTPv0. */
@@ -1903,6 +2041,11 @@ static struct pernet_operations gtp_net_ops = {
 	.size	= sizeof(struct gtp_net),
 };
 
+static const struct skb_gso_app gtp_gso_app = {
+	.check_flags = SKB_GSO_UDP_TUNNEL | SKB_GSO_UDP_TUNNEL_CSUM,
+	.gso_segment = gtp_gso_segment,
+};
+
 static int __init gtp_init(void)
 {
 	int err;
@@ -1921,6 +2064,10 @@ static int __init gtp_init(void)
 	if (err < 0)
 		goto unreg_genl_family;
 
+	gtp_gso_type = skb_gso_app_register(&gtp_gso_app);
+	if (!gtp_gso_type)
+		pr_warn("GTP unable to create UDP app gso type");
+
 	pr_info("GTP module loaded (pdp ctx size %zd bytes)\n",
 		sizeof(struct pdp_ctx));
 	return 0;
@@ -1937,6 +2084,9 @@ late_initcall(gtp_init);
 
 static void __exit gtp_fini(void)
 {
+	if (gtp_gso_type)
+		skb_gso_app_unregister(gtp_gso_type, &gtp_gso_app);
+
 	unregister_pernet_subsys(&gtp_net_ops);
 	genl_unregister_family(&gtp_genl_family);
 	rtnl_link_unregister(&gtp_link_ops);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 14a32d745e24..7c15db44eab3 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -558,7 +558,6 @@ enum {
 	IFLA_GTP_UDP_CSUM,
 	IFLA_GTP_UDP_ZERO_CSUM6_TX,
 	IFLA_GTP_UDP_ZERO_CSUM6_RX,
-
 	__IFLA_GTP_MAX,
 };
 #define IFLA_GTP_MAX (__IFLA_GTP_MAX - 1)
-- 
2.11.0
