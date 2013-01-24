From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 2/2] v2 GRE: Add segmentation offload for GRE
Date: Thu, 24 Jan 2013 14:16:33 -0800
Message-ID: <1359065793-1796-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, eric.dumazet@gmail.com,
	Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:59636 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755873Ab3AXWPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 17:15:43 -0500
Received: by mail-oa0-f70.google.com with SMTP id k14so52169715oag.5
        for <netdev@vger.kernel.org>; Thu, 24 Jan 2013 14:15:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
Fixed according to comments from Jesse and Eric.
 - Factored a MAC layer handler out of skb_gso_segment().
 - Eliminated copy operation from gre_gso_segment().
 - Refresh header pointer after pskb_may_pull().
---
 include/linux/netdevice.h |    4 +-
 include/linux/skbuff.h    |    7 +++
 net/core/dev.c            |   58 ++++++++++++++----------
 net/core/skbuff.c         |    7 ++-
 net/ipv4/af_inet.c        |    1 +
 net/ipv4/gre.c            |  109 +++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/ip_gre.c         |   94 ++++++++++++++++++++++++++++++--------
 net/ipv4/tcp.c            |    1 +
 net/ipv4/udp.c            |    3 +-
 net/ipv6/ip6_offload.c    |    1 +
 net/ipv6/udp_offload.c    |    3 +-
 11 files changed, 243 insertions(+), 45 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 549f5ad..109d27b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2662,8 +2662,10 @@ extern int netdev_master_upper_dev_link(struct net_device *dev,
 extern void netdev_upper_dev_unlink(struct net_device *dev,
 				    struct net_device *upper_dev);
 extern int skb_checksum_help(struct sk_buff *skb);
+extern struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
+					  netdev_features_t features);
 extern struct sk_buff *skb_gso_segment(struct sk_buff *skb,
-	netdev_features_t features);
+				       netdev_features_t features);
 #ifdef CONFIG_BUG
 extern void netdev_rx_csum_fault(struct net_device *dev);
 #else
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 7c00664..7b98ee6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -307,6 +307,8 @@ enum {
 	SKB_GSO_TCPV6 = 1 << 4,
 
 	SKB_GSO_FCOE = 1 << 5,
+
+	SKB_GSO_GRE = 1 << 6,
 };
 
 #if BITS_PER_LONG > 32
@@ -2711,6 +2713,11 @@ static inline struct sec_path *skb_sec_path(struct sk_buff *skb)
 }
 #endif
 
+struct skb_gso_cb {
+	int tnl_hoffset;
+};
+#define NAPI_GSO_CB(skb) ((struct skb_gso_cb *)(skb)->cb)
+
 static inline bool skb_is_gso(const struct sk_buff *skb)
 {
 	return skb_shinfo(skb)->gso_size;
diff --git a/net/core/dev.c b/net/core/dev.c
index c69cd87..208eb8b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2293,18 +2293,8 @@ out:
 }
 EXPORT_SYMBOL(skb_checksum_help);
 
-/**
- *	skb_gso_segment - Perform segmentation on skb.
- *	@skb: buffer to segment
- *	@features: features for the output path (see dev->features)
- *
- *	This function segments the given skb and returns a list of segments.
- *
- *	It may return NULL if the skb requires no segmentation.  This is
- *	only possible when GSO is used for verifying header integrity.
- */
-struct sk_buff *skb_gso_segment(struct sk_buff *skb,
-	netdev_features_t features)
+struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
+				   netdev_features_t features)
 {
 	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
 	struct packet_offload *ptype;
@@ -2323,18 +2313,7 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 		vlan_depth += VLAN_HLEN;
 	}
 
-	skb_reset_mac_header(skb);
-	skb->mac_len = skb->network_header - skb->mac_header;
 	__skb_pull(skb, skb->mac_len);
-
-	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
-		skb_warn_bad_offload(skb);
-
-		if (skb_header_cloned(skb) &&
-		    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
-			return ERR_PTR(err);
-	}
-
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &offload_base, list) {
 		if (ptype->type == type && ptype->callbacks.gso_segment) {
@@ -2356,6 +2335,39 @@ struct sk_buff *skb_gso_segment(struct sk_buff *skb,
 
 	return segs;
 }
+EXPORT_SYMBOL(skb_mac_gso_segment);
+
+/**
+ *	skb_gso_segment - Perform segmentation on skb.
+ *	@skb: buffer to segment
+ *	@features: features for the output path (see dev->features)
+ *
+ *	This function segments the given skb and returns a list of segments.
+ *
+ *	It may return NULL if the skb requires no segmentation.  This is
+ *	only possible when GSO is used for verifying header integrity.
+ */
+struct sk_buff *skb_gso_segment(struct sk_buff *skb,
+				netdev_features_t features)
+{
+	int err;
+
+	if (unlikely(skb->ip_summed != CHECKSUM_PARTIAL)) {
+		skb_warn_bad_offload(skb);
+
+		if (skb_header_cloned(skb)) {
+			err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
+			if (err)
+				return ERR_PTR(err);
+		}
+	}
+	NAPI_GSO_CB(skb)->tnl_hoffset = skb_headroom(skb);
+
+	skb_reset_mac_header(skb);
+	skb->mac_len = skb->network_header - skb->mac_header;
+
+	return skb_mac_gso_segment(skb, features);
+}
 EXPORT_SYMBOL(skb_gso_segment);
 
 /* Take action when hardware reception checksum errors are detected. */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 2568c44..c12b6f3 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2752,6 +2752,8 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 	unsigned int doffset = skb->data - skb_mac_header(skb);
 	unsigned int offset = doffset;
 	unsigned int headroom;
+	unsigned int tnl_hlen = (skb_mac_header(skb) - skb->head) -
+				 NAPI_GSO_CB(skb)->tnl_hoffset;
 	unsigned int len;
 	int sg = !!(features & NETIF_F_SG);
 	int nfrags = skb_shinfo(skb)->nr_frags;
@@ -2827,7 +2829,10 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
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
index 4b70539..2bd9998 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1306,6 +1306,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		       SKB_GSO_UDP |
 		       SKB_GSO_DODGY |
 		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_GRE |
 		       0)))
 		goto out;
 
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index 42a4910..1f86421 100644
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
@@ -112,12 +118,108 @@ static void gre_err(struct sk_buff *skb, u32 info)
 	rcu_read_unlock();
 }
 
+static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
+				       netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	int ghl = GRE_HEADER_SECTION;
+	struct gre_base_hdr *greh;
+	int mac_len = skb->mac_len;
+	int hlen;
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
+	hlen = mac_len + sizeof(struct iphdr);
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
+	segs = skb_mac_gso_segment(skb, 0);
+	if (!segs || IS_ERR(segs))
+		goto out;
+
+	skb = segs;
+	do {
+		__skb_push(skb, ghl + hlen);
+		if (csum) {
+			__be32 *pcsum;
+
+			greh = (struct gre_base_hdr *)(skb->data + hlen);
+			pcsum = (__be32 *)(greh + 1);
+			*pcsum = 0;
+			*(__sum16 *)pcsum = csum_fold(skb_checksum(skb, hlen,
+								   skb->len - hlen, 0));
+		}
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
+	struct gre_base_hdr *greh;
+
+	if (!skb->encapsulation)
+		return -EINVAL;
+
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
+	if (greh->flags & GRE_SEQ)
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
@@ -127,11 +229,18 @@ static int __init gre_init(void)
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
index 303012a..ac8cb5e 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -735,6 +735,42 @@ drop:
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
+		/* Pages aren't locked and could change at any time.
+		 * If this happens after we compute the checksum, the
+		 * checksum will be wrong.  We linearize now to avoid
+		 * this problem.
+		 */
+		if (skb_is_nonlinear(skb)) {
+			err = __skb_linearize(skb);
+			if (unlikely(err))
+				goto error;
+		}
+
+		err = skb_checksum_help(skb);
+		if (unlikely(err))
+			goto error;
+	}
+
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
 	struct ip_tunnel *tunnel = netdev_priv(dev);
@@ -751,10 +787,9 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	__be32 dst;
 	int    mtu;
 	u8     ttl;
-
-	if (skb->ip_summed == CHECKSUM_PARTIAL &&
-	    skb_checksum_help(skb))
-		goto tx_error;
+	int pkt_len;
+	struct pcpu_tstats *tstats;
+	int err;
 
 	if (dev->type == ARPHRD_ETHER)
 		IPCB(skb)->flags = 0;
@@ -852,13 +887,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 
 	if (skb->protocol == htons(ETH_P_IP)) {
 		df |= (old_iph->frag_off&htons(IP_DF));
-
-		if ((old_iph->frag_off&htons(IP_DF)) &&
-		    mtu < ntohs(old_iph->tot_len)) {
-			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
-			ip_rt_put(rt);
-			goto tx_error;
-		}
 	}
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (skb->protocol == htons(ETH_P_IPV6)) {
@@ -873,11 +901,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			}
 		}
 
-		if (mtu >= IPV6_MIN_MTU && mtu < skb->len - tunnel->hlen + gre_hlen) {
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-			ip_rt_put(rt);
-			goto tx_error;
-		}
 	}
 #endif
 
@@ -908,10 +931,19 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			skb_set_owner_w(new_skb, skb->sk);
 		dev_kfree_skb(skb);
 		skb = new_skb;
-		old_iph = ip_hdr(skb);
 		/* Warning : tiph value might point to freed memory */
 	}
 
+	if (!skb->encapsulation) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+
+	skb = handle_offloads(skb);
+	if (IS_ERR(skb))
+		return NETDEV_TX_OK;
+
+	old_iph = ip_hdr(skb);
 	skb_push(skb, gre_hlen);
 	skb_reset_network_header(skb);
 	skb_set_transport_header(skb, sizeof(*iph));
@@ -967,8 +999,23 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			*(__sum16 *)ptr = ip_compute_csum((void *)(iph+1), skb->len - sizeof(struct iphdr));
 		}
 	}
+	pkt_len = skb->len - skb_transport_offset(skb);
+	tstats = this_cpu_ptr(dev->tstats);
+
+	nf_reset(skb);
+	ip_select_ident(iph, skb_dst(skb), NULL);
+
+	err = ip_local_out(skb);
+	if (likely(net_xmit_eval(err) == 0)) {
+		u64_stats_update_begin(&tstats->syncp);
+		tstats->tx_bytes += pkt_len;
+		tstats->tx_packets++;
+		u64_stats_update_end(&tstats->syncp);
+	} else {
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
+	}
 
-	iptunnel_xmit(skb, dev);
 	return NETDEV_TX_OK;
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1374,6 +1421,10 @@ static int ipgre_tunnel_init(struct net_device *dev)
 		return err;
 	}
 
+	if (!(tunnel->parms.o_flags & GRE_SEQ)) {
+		dev->features |= NETIF_F_GSO_SOFTWARE;
+		dev->hw_features |= NETIF_F_GSO_SOFTWARE;
+	}
 	return 0;
 }
 
@@ -1564,6 +1615,10 @@ static int ipgre_tap_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	if (!(tunnel->parms.o_flags & GRE_SEQ)) {
+		dev->features |= NETIF_F_GSO_SOFTWARE;
+		dev->hw_features |= NETIF_F_GSO_SOFTWARE;
+	}
 	return 0;
 }
 
@@ -1587,6 +1642,9 @@ static void ipgre_tap_setup(struct net_device *dev)
 
 	dev->iflink		= 0;
 	dev->features		|= NETIF_F_NETNS_LOCAL;
+
+	dev->features		|= GRE_FEATURES;
+	dev->hw_features	|= GRE_FEATURES;
 }
 
 static int ipgre_newlink(struct net *src_net, struct net_device *dev, struct nlattr *tb[],
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5227194..8c47b7d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3032,6 +3032,7 @@ struct sk_buff *tcp_tso_segment(struct sk_buff *skb,
 			       SKB_GSO_DODGY |
 			       SKB_GSO_TCP_ECN |
 			       SKB_GSO_TCPV6 |
+			       SKB_GSO_GRE |
 			       0) ||
 			     !(type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6))))
 			goto out;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e0610e4..6824272 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2304,7 +2304,8 @@ struct sk_buff *udp4_ufo_fragment(struct sk_buff *skb,
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
1.7.10
