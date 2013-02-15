From: Pravin B Shelar <pshelar@nicira.com>
Subject: =?UTF-8?q?=5BPATCH=20net-next=203/3=5D=20v4=20GRE=3A=20Add=20TCP=20segmentation=20offload=20for=20GRE?=
Date: Thu, 14 Feb 2013 16:02:41 -0800
Message-ID: <1360886561-1630-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: edumazet@google.com, jesse@nicira.com, bhutchings@solarflare.com,
	mirqus@gmail.com, Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog105.obsmtp.com ([74.125.149.75]:33292 "HELO
	na3sys009aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932658Ab3BOEVl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 23:21:41 -0500
Received: by mail-da0-f71.google.com with SMTP id n41so2770371dak.10
        for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 20:21:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ollowing patch adds GRE protocol offload handler so that
skb_gso_segment() can segment GRE packets.
SKB GSO CB is added to keep track of total header length so that
skb_segment can push entire header. e.g. in case of GRE, skb_segment
need to push inner and outer headers to every segment.
New NETIF_F_GRE_GSO feature is added for devices which support HW
GRE TSO offload. Currently none of devices support it therefore GRE GSO
always fall backs to software GSO.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
=46ixed according to comments from Jesse, Eric and Micha=C5=82.
v3-v4:
 - Remove ipv4-id selection.
 - update error counter.
 - simplified features.

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
 net/ipv4/gre.c                  |  118 +++++++++++++++++++++++++++++++=
++++++++
 net/ipv4/ip_gre.c               |   81 ++++++++++++++++++++++++--
 net/ipv4/tcp.c                  |    1 +
 net/ipv4/udp.c                  |    3 +-
 net/ipv6/ip6_offload.c          |    1 +
 net/ipv6/udp_offload.c          |    3 +-
 12 files changed, 225 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_fea=
tures.h
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
 		=3D NETIF_F_GSO_LAST,
@@ -102,6 +102,7 @@ enum {
 #define NETIF_F_VLAN_CHALLENGED	__NETIF_F(VLAN_CHALLENGED)
 #define NETIF_F_RXFCS		__NETIF_F(RXFCS)
 #define NETIF_F_RXALL		__NETIF_F(RXALL)
+#define NETIF_F_GRE_GSO		__NETIF_F(GSO_GRE)
=20
 /* Features valid for ethtool to change */
 /* =3D all defined minus driver/device-class-related */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ca6ee7d..821c7f4 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -314,6 +314,8 @@ enum {
 	SKB_GSO_TCPV6 =3D 1 << 4,
=20
 	SKB_GSO_FCOE =3D 1 << 5,
+
+	SKB_GSO_GRE =3D 1 << 6,
 };
=20
 #if BITS_PER_LONG > 32
@@ -2732,6 +2734,21 @@ static inline struct sec_path *skb_sec_path(stru=
ct sk_buff *skb)
 }
 #endif
=20
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
index 5425e41..4cf2be8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2413,6 +2413,7 @@ struct sk_buff *__skb_gso_segment(struct sk_buff =
*skb,
 			return ERR_PTR(err);
 	}
=20
+	SKB_GSO_CB(skb)->mac_offset =3D skb_headroom(skb);
 	skb_reset_mac_header(skb);
 	skb->mac_len =3D skb->network_header - skb->mac_header;
=20
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d9d5520..3e9b2c3 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -77,6 +77,7 @@ static const char netdev_features_strings[NETDEV_FEAT=
URE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_TSO_ECN_BIT] =3D          "tx-tcp-ecn-segmentation",
 	[NETIF_F_TSO6_BIT] =3D             "tx-tcp6-segmentation",
 	[NETIF_F_FSO_BIT] =3D              "tx-fcoe-segmentation",
+	[NETIF_F_GSO_GRE_BIT] =3D		 "tx-gre-segmentation",
=20
 	[NETIF_F_FCOE_CRC_BIT] =3D         "tx-checksum-fcoe-crc",
 	[NETIF_F_SCTP_CSUM_BIT] =3D        "tx-checksum-sctp",
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6c1ad09..2a3ca33 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2738,6 +2738,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, =
netdev_features_t features)
 	unsigned int mss =3D skb_shinfo(skb)->gso_size;
 	unsigned int doffset =3D skb->data - skb_mac_header(skb);
 	unsigned int offset =3D doffset;
+	unsigned int tnl_hlen =3D skb_tnl_header_len(skb);
 	unsigned int headroom;
 	unsigned int len;
 	int sg =3D !!(features & NETIF_F_SG);
@@ -2814,7 +2815,10 @@ struct sk_buff *skb_segment(struct sk_buff *skb,=
 netdev_features_t features)
 		skb_set_network_header(nskb, skb->mac_len);
 		nskb->transport_header =3D (nskb->network_header +
 					  skb_network_header_len(skb));
-		skb_copy_from_linear_data(skb, nskb->data, doffset);
+
+		skb_copy_from_linear_data_offset(skb, -tnl_hlen,
+						 nskb->data - tnl_hlen,
+						 doffset + tnl_hlen);
=20
 		if (fskb !=3D skb_shinfo(skb)->frag_list)
 			continue;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e6e5d85..e225a4e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1287,6 +1287,7 @@ static struct sk_buff *inet_gso_segment(struct sk=
_buff *skb,
 		       SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_GRE |
 		       0)))
 		goto out;
=20
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
=20
 static const struct gre_protocol __rcu *gre_proto[GREPROTO_MAX] __read=
_mostly;
 static DEFINE_SPINLOCK(gre_proto_lock);
+struct gre_base_hdr {
+	__be16 flags;
+	__be16 protocol;
+};
+#define GRE_HEADER_SECTION 4
=20
 int gre_add_protocol(const struct gre_protocol *proto, u8 version)
 {
@@ -112,12 +118,117 @@ static void gre_err(struct sk_buff *skb, u32 inf=
o)
 	rcu_read_unlock();
 }
=20
+static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
+				       netdev_features_t features)
+{
+	struct sk_buff *segs =3D ERR_PTR(-EINVAL);
+	netdev_features_t enc_features;
+	int ghl =3D GRE_HEADER_SECTION;
+	struct gre_base_hdr *greh;
+	int mac_len =3D skb->mac_len;
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
+	greh =3D (struct gre_base_hdr *)skb_transport_header(skb);
+
+	if (greh->flags & GRE_KEY)
+		ghl +=3D GRE_HEADER_SECTION;
+	if (greh->flags & GRE_SEQ)
+		ghl +=3D GRE_HEADER_SECTION;
+	if (greh->flags & GRE_CSUM) {
+		ghl +=3D GRE_HEADER_SECTION;
+		csum =3D true;
+	} else
+		csum =3D false;
+
+	/* setup inner skb. */
+	if (greh->protocol =3D=3D htons(ETH_P_TEB)) {
+		struct ethhdr *eth =3D eth_hdr(skb);
+		skb->protocol =3D eth->h_proto;
+	} else {
+		skb->protocol =3D greh->protocol;
+	}
+
+	skb->encapsulation =3D 0;
+
+	if (unlikely(!pskb_may_pull(skb, ghl)))
+		goto out;
+	__skb_pull(skb, ghl);
+	skb_reset_mac_header(skb);
+	skb_set_network_header(skb, skb_inner_network_offset(skb));
+	skb->mac_len =3D skb_inner_network_offset(skb);
+
+	/* segment inner packet. */
+	enc_features =3D skb->dev->hw_enc_features & netif_skb_features(skb);
+	segs =3D skb_mac_gso_segment(skb, enc_features);
+	if (!segs || IS_ERR(segs))
+		goto out;
+
+	skb =3D segs;
+	tnl_hlen =3D skb_tnl_header_len(skb);
+	do {
+		__skb_push(skb, ghl);
+		if (csum) {
+			__be32 *pcsum;
+
+			if (skb_has_shared_frag(skb)) {
+				int err;
+
+				err =3D __skb_linearize(skb);
+				if (err) {
+					kfree_skb(segs);
+					segs =3D ERR_PTR(err);
+					goto out;
+				}
+			}
+
+			greh =3D (struct gre_base_hdr *)(skb->data);
+			pcsum =3D (__be32 *)(greh + 1);
+			*pcsum =3D 0;
+			*(__sum16 *)pcsum =3D csum_fold(skb_checksum(skb, 0, skb->len, 0));
+		}
+		__skb_push(skb, tnl_hlen - ghl);
+
+		skb_reset_mac_header(skb);
+		skb_set_network_header(skb, mac_len);
+		skb->mac_len =3D mac_len;
+	} while ((skb =3D skb->next));
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
 static const struct net_protocol net_gre_protocol =3D {
 	.handler     =3D gre_rcv,
 	.err_handler =3D gre_err,
 	.netns_ok    =3D 1,
 };
=20
+static const struct net_offload gre_offload =3D {
+	.callbacks =3D {
+		.gso_send_check =3D	gre_gso_send_check,
+		.gso_segment    =3D	gre_gso_segment,
+	},
+};
+
 static int __init gre_init(void)
 {
 	pr_info("GRE over IPv4 demultiplexor driver\n");
@@ -127,11 +238,18 @@ static int __init gre_init(void)
 		return -EAGAIN;
 	}
=20
+	if (inet_add_offload(&gre_offload, IPPROTO_GRE)) {
+		pr_err("can't add protocol offload\n");
+		inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
+		return -EAGAIN;
+	}
+
 	return 0;
 }
=20
 static void __exit gre_exit(void)
 {
+	inet_del_offload(&gre_offload, IPPROTO_GRE);
 	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
 }
=20
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 00a14b9..fe66977 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -735,8 +735,33 @@ drop:
 	return 0;
 }
=20
+static struct sk_buff *handle_offloads(struct sk_buff *skb)
+{
+	int err;
+
+	if (skb_is_gso(skb)) {
+		err =3D skb_unclone(skb, GFP_ATOMIC);
+		if (unlikely(err))
+			goto error;
+		skb_shinfo(skb)->gso_type |=3D SKB_GSO_GRE;
+		return skb;
+	} else if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL) {
+		err =3D skb_checksum_help(skb);
+		if (unlikely(err))
+			goto error;
+	}
+	skb->ip_summed =3D CHECKSUM_NONE;
+
+	return skb;
+
+error:
+	kfree_skb(skb);
+	return ERR_PTR(err);
+}
+
 static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_d=
evice *dev)
 {
+	struct pcpu_tstats *tstats =3D this_cpu_ptr(dev->tstats);
 	struct ip_tunnel *tunnel =3D netdev_priv(dev);
 	const struct iphdr  *old_iph;
 	const struct iphdr  *tiph;
@@ -751,10 +776,18 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_bu=
ff *skb, struct net_device *dev
 	__be32 dst;
 	int    mtu;
 	u8     ttl;
+	int    err;
=20
-	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL &&
-	    skb_checksum_help(skb))
-		goto tx_error;
+	skb =3D handle_offloads(skb);
+	if (IS_ERR(skb)) {
+		dev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+
+	if (!skb->encapsulation) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation =3D 1;
+	}
=20
 	old_iph =3D ip_hdr(skb);
=20
@@ -855,7 +888,8 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev
 	if (skb->protocol =3D=3D htons(ETH_P_IP)) {
 		df |=3D (old_iph->frag_off&htons(IP_DF));
=20
-		if ((old_iph->frag_off&htons(IP_DF)) &&
+		if (!skb_is_gso(skb) &&
+		    (old_iph->frag_off&htons(IP_DF)) &&
 		    mtu < ntohs(old_iph->tot_len)) {
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
 			ip_rt_put(rt);
@@ -875,7 +909,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev
 			}
 		}
=20
-		if (mtu >=3D IPV6_MIN_MTU && mtu < skb->len - tunnel->hlen + gre_hle=
n) {
+		if (!skb_is_gso(skb) &&
+		    mtu >=3D IPV6_MIN_MTU &&
+		    mtu < skb->len - tunnel->hlen + gre_hlen) {
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 			ip_rt_put(rt);
 			goto tx_error;
@@ -936,6 +972,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff=
 *skb, struct net_device *dev
 	iph->daddr		=3D	fl4.daddr;
 	iph->saddr		=3D	fl4.saddr;
 	iph->ttl		=3D	ttl;
+	iph->id			=3D	0;
=20
 	if (ttl =3D=3D 0) {
 		if (skb->protocol =3D=3D htons(ETH_P_IP))
@@ -964,9 +1001,19 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_bu=
ff *skb, struct net_device *dev
 			*ptr =3D tunnel->parms.o_key;
 			ptr--;
 		}
-		if (tunnel->parms.o_flags&GRE_CSUM) {
+		/* Skip GRE checksum if skb is getting offloaded. */
+		if (!(skb_shinfo(skb)->gso_type & SKB_GSO_GRE) &&
+		    (tunnel->parms.o_flags&GRE_CSUM)) {
 			int offset =3D skb_transport_offset(skb);
=20
+			if (skb_has_shared_frag(skb)) {
+				err =3D __skb_linearize(skb);
+				if (err) {
+					ip_rt_put(rt);
+					goto tx_error;
+				}
+			}
+
 			*ptr =3D 0;
 			*(__sum16 *)ptr =3D csum_fold(skb_checksum(skb, offset,
 								 skb->len - offset,
@@ -974,7 +1021,19 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_bu=
ff *skb, struct net_device *dev
 		}
 	}
=20
-	iptunnel_xmit(skb, dev);
+	nf_reset(skb);
+
+	err =3D ip_local_out(skb);
+	if (likely(net_xmit_eval(err) =3D=3D 0)) {
+		int pkt_len =3D skb->len - skb_transport_offset(skb);
+		u64_stats_update_begin(&tstats->syncp);
+		tstats->tx_bytes +=3D pkt_len;
+		tstats->tx_packets++;
+		u64_stats_update_end(&tstats->syncp);
+	} else {
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
+	}
 	return NETDEV_TX_OK;
=20
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1044,6 +1103,11 @@ static int ipgre_tunnel_bind_dev(struct net_devi=
ce *dev)
 		mtu =3D 68;
=20
 	tunnel->hlen =3D addend;
+	/* TCP offload with GRE SEQ is not supported. */
+	if (!(tunnel->parms.o_flags & GRE_SEQ)) {
+		dev->features		|=3D NETIF_F_GSO_SOFTWARE;
+		dev->hw_features	|=3D NETIF_F_GSO_SOFTWARE;
+	}
=20
 	return mtu;
 }
@@ -1593,6 +1657,9 @@ static void ipgre_tap_setup(struct net_device *de=
v)
=20
 	dev->iflink		=3D 0;
 	dev->features		|=3D NETIF_F_NETNS_LOCAL;
+
+	dev->features		|=3D GRE_FEATURES;
+	dev->hw_features	|=3D GRE_FEATURES;
 }
=20
 static int ipgre_newlink(struct net *src_net, struct net_device *dev, =
struct nlattr *tb[],
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1f0bedb..7a5ba48 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3043,6 +3043,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *s=
kb,
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
@@ -2305,7 +2305,8 @@ struct sk_buff *udp4_ufo_fragment(struct sk_buff =
*skb,
 		/* Packet is from an untrusted source, reset gso_segs. */
 		int type =3D skb_shinfo(skb)->gso_type;
=20
-		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY) ||
+		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
+				      SKB_GSO_GRE) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
=20
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index f26f0da..8234c1d 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -99,6 +99,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buf=
f *skb,
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
@@ -56,7 +56,8 @@ static struct sk_buff *udp6_ufo_fragment(struct sk_bu=
ff *skb,
 		/* Packet is from an untrusted source, reset gso_segs. */
 		int type =3D skb_shinfo(skb)->gso_type;
=20
-		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY) ||
+		if (unlikely(type & ~(SKB_GSO_UDP | SKB_GSO_DODGY |
+				      SKB_GSO_GRE) ||
 			     !(type & (SKB_GSO_UDP))))
 			goto out;
=20
--=20
1.7.1
