From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 3/3] GRE: Add TCP segmentation offload for GRE
Date: Thu, 14 Feb 2013 11:45:01 -0800
Message-ID: <1360871101-2086-1-git-send-email-pshelar@nicira.com>
Cc: edumazet@google.com, jesse@nicira.com, bhutchings@solarflare.com,
	mirqus@gmail.com, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:48787 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S935136Ab3BOAD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 19:03:59 -0500
Received: by mail-ie0-f198.google.com with SMTP id 17so14703735iea.5
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 16:03:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch adds GRE protocol offload handler so that
skb_gso_segment() can segment GRE packets.
SKB GSO CB is added to keep track of total header length so that
skb_segment can push entire header. e.g. in case of GRE, skb_segment
need to push inner and outer headers to every segment.
New NETIF_F_GRE_GSO feature is added for devices which support HW
GRE TSO offload. Currently none of devices support it therefore GRE GSO
always fall backs to software GSO.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
Fixed according to comments from Jesse and Eric.
v2-v3:
 - Use device features to segment inner packet.
 - Moved skb_mac_gso_segment to separate patch.
 - simplified gre_gso_segment().
 - Added NETIF_F_GRE_GSO feature.

v1-v2:
 - Factored a MAC layer handler out of skb_gso_segment().
 - Eliminated copy operation from gre_gso_segment().
 - Refresh header pointer after pskb_may_pull().
---
 include/linux/netdev_features.h |    3 +-
 include/linux/skbuff.h          |   17 ++++++
 net/core/dev.c                  |    1 +
 net/core/ethtool.c              |    1 +
 net/core/skbuff.c               |    6 ++-
 net/ipv4/af_inet.c              |    1 +
 net/ipv4/gre.c                  |  118 +++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_gre.c               |   83 +++++++++++++++++++++++++--
 net/ipv4/tcp.c                  |    1 +
 net/ipv4/udp.c                  |    3 +-
 net/ipv6/ip6_offload.c          |    1 +
 net/ipv6/udp_offload.c          |    3 +-
 12 files changed, 227 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 5ac3212..3dd3934 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -41,7 +41,7 @@ enum {
 	NETIF_F_TSO_ECN_BIT,		/* ... TCP ECN support */
 	NETIF_F_TSO6_BIT,		/* ... TCPv6 segmentation */
 	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
-	NETIF_F_GSO_RESERVED1,		/* ... free (fill GSO_MASK to 8 bits) */
+	NETIF_F_GSO_GRE_BIT,		/* ... GRE with TSO */
 	/**/NETIF_F_GSO_LAST,		/* [can't be last bit, see GSO_MASK] */
 	NETIF_F_GSO_RESERVED2		/* ... free (fill GSO_MASK to 8 bits) */
 		= NETIF_F_GSO_LAST,
@@ -102,6 +102,7 @@ enum {
 #define NETIF_F_VLAN_CHALLENGED	__NETIF_F(VLAN_CHALLENGED)
 #define NETIF_F_RXFCS		__NETIF_F(RXFCS)
 #define NETIF_F_RXALL		__NETIF_F(RXALL)
+#define NETIF_F_GRE_GSO		__NETIF_F(GSO_GRE)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ca6ee7d..12c8b99 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -314,6 +314,8 @@ enum {
 	SKB_GSO_TCPV6 = 1 << 4,
 
 	SKB_GSO_FCOE = 1 << 5,
+
+	SKB_GSO_GRE = 1 << 6,
 };
 
 #if BITS_PER_LONG > 32
@@ -2732,6 +2734,21 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
 }
 #endif
 
+/* Keeps track of mac header offset relative to skb->head.
+ * It is useful for TSO of Tunneling protocol. e.g. GRE.
+ * For non-tunnel skb it points to skb_mac_header() and for
+ * tunnel skb it points to outer mac header. */
+struct skb_gso_cb {
+	int mac_offset;
+};
+#define SKB_GSO_CB(skb) ((struct skb_gso_cb *)(skb)->cb)
+
+static inline int skb_tnl_header_len(const struct sk_buff *inner_skb)
+{
+	return (skb_mac_header(inner_skb) - inner_skb->head) -
+		SKB_GSO_CB(inner_skb)->mac_offset;
+}
+
 static inline bool skb_is_gso(const struct sk_buff *skb)
 {
 	return skb_shinfo(skb)->gso_size;
diff --git a/net/core/dev.c b/net/core/dev.c
index 5425e41..a184f24 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2413,6 +2413,7 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 			return ERR_PTR(err);
 	}
 
+	SKB_GSO_CB(skb)->mac_offset = skb_headroom(skb);
 	skb_reset_mac_header(skb);
 	skb->mac_len = skb->network_header - skb->mac_header;
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d9d5520..3e9b2c3 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -77,6 +77,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_TSO_ECN_BIT] =          "tx-tcp-ecn-segmentation",
 	[NETIF_F_TSO6_BIT] =             "tx-tcp6-segmentation",
 	[NETIF_F_FSO_BIT] =              "tx-fcoe-segmentation",
+	[NETIF_F_GSO_GRE_BIT] =		 "tx-gre-segmentation",
 
 	[NETIF_F_FCOE_CRC_BIT] =         "tx-checksum-fcoe-crc",
 	[NETIF_F_SCTP_CSUM_BIT] =        "tx-checksum-sctp",
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6c1ad09..2a3ca33 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2738,6 +2738,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 	unsigned int mss = skb_shinfo(skb)->gso_size;
 	unsigned int doffset = skb->data - skb_mac_header(skb);
 	unsigned int offset = doffset;
+	unsigned int tnl_hlen = skb_tnl_header_len(skb);
 	unsigned int headroom;
 	unsigned int len;
 	int sg = !!(features & NETIF_F_SG);
@@ -2814,7 +2815,10 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 		skb_set_network_header(nskb, skb->mac_len);
 		nskb->transport_header = (nskb->network_header +
 					  skb_network_header_len(skb));
-		skb_copy_from_linear_data(skb, nskb->data, doffset);
+
+		skb_copy_from_linear_data_offset(skb, -tnl_hlen,
+						 nskb->data - tnl_hlen,
+						 doffset + tnl_hlen);
 
 		if (fskb != skb_shinfo(skb)->frag_list)
 			continue;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e6e5d85..e225a4e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1287,6 +1287,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_GRE |
 		       0)))
 		goto out;
 
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index 42a4910..7a4c710 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -19,6 +19,7 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/netdevice.h>
+#include <linux/if_tunnel.h>
 #include <linux/spinlock.h>
 #include <net/protocol.h>
 #include <net/gre.h>
@@ -26,6 +27,11 @@
 
 static const struct gre_protocol __rcu *gre_proto[GREPROTO_MAX] __read_mostly;
 static DEFINE_SPINLOCK(gre_proto_lock);
+struct gre_base_hdr {
+	__be16 flags;
+	__be16 protocol;
+};
+#define GRE_HEADER_SECTION 4
 
 int gre_add_protocol(const struct gre_protocol *proto, u8 version)
 {
@@ -112,12 +118,117 @@ static void gre_err(struct sk_buff *skb, u32 info)
 	rcu_read_unlock();
 }
 
+static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
+				       netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	netdev_features_t enc_features;
+	int ghl = GRE_HEADER_SECTION;
+	struct gre_base_hdr *greh;
+	int mac_len = skb->mac_len;
+	int tnl_hlen;
+	bool csum;
+
+	if (unlikely(skb_shinfo(skb)->gso_type &
+				~(SKB_GSO_TCPV4 |
+				  SKB_GSO_TCPV6 |
+				  SKB_GSO_UDP |
+				  SKB_GSO_DODGY |
+				  SKB_GSO_TCP_ECN |
+				  SKB_GSO_GRE)))
+		goto out;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(*greh))))
+		goto out;
+
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
+
+	if (greh->flags & GRE_KEY)
+		ghl += GRE_HEADER_SECTION;
+	if (greh->flags & GRE_SEQ)
+		ghl += GRE_HEADER_SECTION;
+	if (greh->flags & GRE_CSUM) {
+		ghl += GRE_HEADER_SECTION;
+		csum = true;
+	} else
+		csum = false;
+
+	/* setup inner skb. */
+	if (greh->protocol == htons(ETH_P_TEB)) {
+		struct ethhdr *eth = eth_hdr(skb);
+		skb->protocol = eth->h_proto;
+	} else {
+		skb->protocol = greh->protocol;
+	}
+
+	skb->encapsulation = 0;
+
+	if (unlikely(!pskb_may_pull(skb, ghl)))
+		goto out;
+	__skb_pull(skb, ghl);
+	skb_reset_mac_header(skb);
+	skb_set_network_header(skb, skb_inner_network_offset(skb));
+	skb->mac_len = skb_inner_network_offset(skb);
+
+	/* segment inner packet. */
+	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
+	segs = skb_mac_gso_segment(skb, enc_features);
+	if (!segs || IS_ERR(segs))
+		goto out;
+
+	skb = segs;
+	tnl_hlen = skb_tnl_header_len(skb);
+	do {
+		__skb_push(skb, ghl);
+		if (csum) {
+			__be32 *pcsum;
+
+			if (skb_has_shared_frag(skb)) {
+				int err;
+
+				err = __skb_linearize(skb);
+				if (err) {
+					kfree_skb(segs);
+					segs = ERR_PTR(err);
+					goto out;
+				}
+			}
+
+			greh = (struct gre_base_hdr *)(skb->data);
+			pcsum = (__be32 *)(greh + 1);
+			*pcsum = 0;
+			*(__sum16 *)pcsum = csum_fold(skb_checksum(skb, 0, skb->len, 0));
+		}
+		__skb_push(skb, tnl_hlen - ghl);
+
+		skb_reset_mac_header(skb);
+		skb_set_network_header(skb, mac_len);
+		skb->mac_len = mac_len;
+	} while ((skb = skb->next));
+out:
+	return segs;
+}
+
+static int gre_gso_send_check(struct sk_buff *skb)
+{
+	if (!skb->encapsulation)
+		return -EINVAL;
+	return 0;
+}
+
 static const struct net_protocol net_gre_protocol = {
 	.handler     = gre_rcv,
 	.err_handler = gre_err,
 	.netns_ok    = 1,
 };
 
+static const struct net_offload gre_offload = {
+	.callbacks = {
+		.gso_send_check =	gre_gso_send_check,
+		.gso_segment    =	gre_gso_segment,
+	},
+};
+
 static int __init gre_init(void)
 {
 	pr_info("GRE over IPv4 demultiplexor driver\n");
@@ -127,11 +238,18 @@ static int __init gre_init(void)
 		return -EAGAIN;
 	}
 
+	if (inet_add_offload(&gre_offload, IPPROTO_GRE)) {
+		pr_err("can't add protocol offload\n");
+		inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
+		return -EAGAIN;
+	}
+
 	return 0;
 }
 
 static void __exit gre_exit(void)
 {
+	inet_del_offload(&gre_offload, IPPROTO_GRE);
 	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
 }
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 00a14b9..5e0c5f1 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -735,8 +735,33 @@ drop:
 	return 0;
 }
 
+static struct sk_buff *handle_offloads(struct sk_buff *skb)
+{
+	int err;
+
+	if (skb_is_gso(skb)) {
+		err = skb_unclone(skb, GFP_ATOMIC);
+		if (unlikely(err))
+			goto error;
+		skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
+		return skb;
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		err = skb_checksum_help(skb);
+		if (unlikely(err))
+			goto error;
+	}
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return skb;
+
+error:
+	kfree_skb(skb);
+	return ERR_PTR(err);
+}
+
 static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	struct pcpu_tstats *tstats = this_cpu_ptr(dev->tstats);
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr  *old_iph;
 	const struct iphdr  *tiph;
@@ -751,10 +776,16 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	__be32 dst;
 	int    mtu;
 	u8     ttl;
+	int    err;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL &&
-	    skb_checksum_help(skb))
-		goto tx_error;
+	skb = handle_offloads(skb);
+	if (IS_ERR(skb))
+		return NETDEV_TX_OK;
+
+	if (!skb->encapsulation) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
 
 	old_iph = ip_hdr(skb);
 
@@ -855,7 +886,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	if (skb->protocol == htons(ETH_P_IP)) {
 		df |= (old_iph->frag_off&htons(IP_DF));
 
-		if ((old_iph->frag_off&htons(IP_DF)) &&
+		if (!skb_is_gso(skb) &&
+		    (old_iph->frag_off&htons(IP_DF)) &&
 		    mtu < ntohs(old_iph->tot_len)) {
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 			ip_rt_put(rt);
@@ -875,7 +907,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			}
 		}
 
-		if (mtu >= IPV6_MIN_MTU && mtu < skb->len - tunnel->hlen + gre_hlen) {
+		if (!skb_is_gso(skb) &&
+		    mtu >= IPV6_MIN_MTU &&
+		    mtu < skb->len - tunnel->hlen + gre_hlen) {
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 			ip_rt_put(rt);
 			goto tx_error;
@@ -964,9 +998,19 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			*ptr = tunnel->parms.o_key;
 			ptr--;
 		}
-		if (tunnel->parms.o_flags&GRE_CSUM) {
+		/* Skip GRE checksum if skb is getting offloaded. */
+		if (!(skb_shinfo(skb)->gso_type & SKB_GSO_GRE) &&
+		    (tunnel->parms.o_flags&GRE_CSUM)) {
 			int offset = skb_transport_offset(skb);
 
+			if (skb_has_shared_frag(skb)) {
+				err = __skb_linearize(skb);
+				if (err) {
+					ip_rt_put(rt);
+					goto tx_error;
+				}
+			}
+
 			*ptr = 0;
 			*(__sum16 *)ptr = csum_fold(skb_checksum(skb, offset,
 								 skb->len - offset,
@@ -974,7 +1018,21 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		}
 	}
 
-	iptunnel_xmit(skb, dev);
+
+	nf_reset(skb);
+	ip_select_ident(iph, skb_dst(skb), NULL);
+
+	err = ip_local_out(skb);
+	if (likely(net_xmit_eval(err) == 0)) {
+		int pkt_len = skb->len - skb_transport_offset(skb);
+		u64_stats_update_begin(&tstats->syncp);
+		tstats->tx_bytes += pkt_len;
+		tstats->tx_packets++;
+		u64_stats_update_end(&tstats->syncp);
+	} else {
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
+	}
 	return NETDEV_TX_OK;
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1044,6 +1102,14 @@ static int ipgre_tunnel_bind_dev(struct net_device *dev)
 		mtu = 68;
 
 	tunnel->hlen = addend;
+	if (tunnel->parms.o_flags & GRE_SEQ) {
+		/* TCP offload with GRE SEQ is not supported. */
+		dev->features &= ~NETIF_F_GSO_SOFTWARE;
+		dev->hw_features &= ~NETIF_F_GSO_SOFTWARE;
+	} else {
+		dev->features |= NETIF_F_GSO_SOFTWARE;
+		dev->hw_features |= NETIF_F_GSO_SOFTWARE;
+	}
 
 	return mtu;
 }
@@ -1593,6 +1659,9 @@ static void ipgre_tap_setup(struct net_device *dev)
 
 	dev->iflink		= 0;
 	dev->features		|= NETIF_F_NETNS_LOCAL;
+
+	dev->features		|= GRE_FEATURES;
+	dev->hw_features	|= GRE_FEATURES;
 }
 
 static int ipgre_newlink(struct net *src_net, struct net_device *dev, struct nlattr *tb[],
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1f0bedb..7a5ba48 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3043,6 +3043,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 			       SKB_GSO_DODGY |
 			       SKB_GSO_TCP_ECN |
 			       SKB_GSO_TCPV6 |
+			       SKB_GSO_GRE |
 			       0) ||
 			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
 			goto out;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6791aac..39a5e7a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2305,7 +2305,8 @@ struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
 		/* Packet is from an untrusted source, reset gso_segs. */
 		int type = skb_shinfo(skb)->gso_type;
 
-		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY) ||
+		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
+				      SKB_GSO_GRE) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
 
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index f26f0da..8234c1d 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -99,6 +99,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 		     ~(SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_GRE |
 		       SKB_GSO_TCPV6 |
 		       0)))
 		goto out;
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 0c8934a..cf05cf0 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -56,7 +56,8 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_buff *skb,
 		/* Packet is from an untrusted source, reset gso_segs. */
 		int type = skb_shinfo(skb)->gso_type;
 
-		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY) ||
+		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
+				      SKB_GSO_GRE) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
 
-- 
1.7.1
