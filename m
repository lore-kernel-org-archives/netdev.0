From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 1/5] ip_tunnel_core: iptunnel_handle_offloads
 returns int and doesn't free skb
Date: Thu, 14 Apr 2016 15:33:37 -0400
Message-ID: <20160414193337.12934.63569.stgit@ahduyck-xeon-server>
References: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: jesse@kernel.org, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36836 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbcDNTdo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 15:33:44 -0400
Received: by mail-pf0-f170.google.com with SMTP id e128so48734289pfe.3
        for <netdev@vger.kernel.org>; Thu, 14 Apr 2016 12:33:44 -0700 (PDT)
In-Reply-To: <20160414192709.12934.82858.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the IP tunnel core function iptunnel_handle_offloads so
that we return an int and do not free the skb inside the function.  This
actually allows us to clean up several paths in several tunnels so that we
can free the skb at one point in the path without having to have a
secondary path if we are supporting tunnel offloads.

In addition it should resolve some double-free issues I have found in the
tunnels paths as I believe it is possible for us to end up triggering such
an event in the case of fou or gue.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/geneve.c            |   32 ++++++++++++--------------------
 drivers/net/vxlan.c             |    6 +++---
 include/net/ip_tunnels.h        |    2 +-
 include/net/udp_tunnel.h        |    3 +--
 net/ipv4/fou.c                  |   16 ++++++++--------
 net/ipv4/ip_gre.c               |   20 ++++++--------------
 net/ipv4/ip_tunnel_core.c       |   13 +++++--------
 net/ipv4/ipip.c                 |    7 +++----
 net/ipv6/sit.c                  |   14 ++++++--------
 net/netfilter/ipvs/ip_vs_xmit.c |    6 ++----
 10 files changed, 47 insertions(+), 72 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index a9fbf17eb256..efbc7ceedc3a 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -696,16 +696,12 @@ static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct iphdr);
 	err = skb_cow_head(skb, min_headroom);
-	if (unlikely(err)) {
-		kfree_skb(skb);
+	if (unlikely(err))
 		goto free_rt;
-	}
 
-	skb = udp_tunnel_handle_offloads(skb, udp_sum);
-	if (IS_ERR(skb)) {
-		err = PTR_ERR(skb);
+	err = udp_tunnel_handle_offloads(skb, udp_sum);
+	if (err)
 		goto free_rt;
-	}
 
 	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
 	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
@@ -733,16 +729,12 @@ static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
 	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
 			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct ipv6hdr);
 	err = skb_cow_head(skb, min_headroom);
-	if (unlikely(err)) {
-		kfree_skb(skb);
+	if (unlikely(err))
 		goto free_dst;
-	}
 
-	skb = udp_tunnel_handle_offloads(skb, udp_sum);
-	if (IS_ERR(skb)) {
-		err = PTR_ERR(skb);
+	err = udp_tunnel_handle_offloads(skb, udp_sum);
+	if (IS_ERR(skb))
 		goto free_dst;
-	}
 
 	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
 	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
@@ -937,7 +929,7 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		err = geneve_build_skb(rt, skb, key->tun_flags, vni,
 				       info->options_len, opts, flags, xnet);
 		if (unlikely(err))
-			goto err;
+			goto tx_error;
 
 		tos = ip_tunnel_ecn_encap(key->tos, iip, skb);
 		ttl = key->ttl;
@@ -946,7 +938,7 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		err = geneve_build_skb(rt, skb, 0, geneve->vni,
 				       0, NULL, flags, xnet);
 		if (unlikely(err))
-			goto err;
+			goto tx_error;
 
 		tos = ip_tunnel_ecn_encap(fl4.flowi4_tos, iip, skb);
 		ttl = geneve->ttl;
@@ -964,7 +956,7 @@ static netdev_tx_t geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 
 tx_error:
 	dev_kfree_skb(skb);
-err:
+
 	if (err == -ELOOP)
 		dev->stats.collisions++;
 	else if (err == -ENETUNREACH)
@@ -1026,7 +1018,7 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 					info->options_len, opts,
 					flags, xnet);
 		if (unlikely(err))
-			goto err;
+			goto tx_error;
 
 		prio = ip_tunnel_ecn_encap(key->tos, iip, skb);
 		ttl = key->ttl;
@@ -1035,7 +1027,7 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 		err = geneve6_build_skb(dst, skb, 0, geneve->vni,
 					0, NULL, flags, xnet);
 		if (unlikely(err))
-			goto err;
+			goto tx_error;
 
 		prio = ip_tunnel_ecn_encap(ip6_tclass(fl6.flowlabel),
 					   iip, skb);
@@ -1054,7 +1046,7 @@ static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 
 tx_error:
 	dev_kfree_skb(skb);
-err:
+
 	if (err == -ELOOP)
 		dev->stats.collisions++;
 	else if (err == -ENETUNREACH)
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 7f697a3f00a4..a3bd67dce0ce 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1784,9 +1784,9 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 	if (WARN_ON(!skb))
 		return -ENOMEM;
 
-	skb = iptunnel_handle_offloads(skb, type);
-	if (IS_ERR(skb))
-		return PTR_ERR(skb);
+	err = iptunnel_handle_offloads(skb, type);
+	if (err)
+		goto out_free;
 
 	vxh = (struct vxlanhdr *) __skb_push(skb, sizeof(*vxh));
 	vxh->vx_flags = VXLAN_HF_VNI;
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 9ae9fbbccd67..6d790910ebdf 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -309,7 +309,7 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
 					     gfp_t flags);
 
-struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb, int gso_type_mask);
+int iptunnel_handle_offloads(struct sk_buff *skb, int gso_type_mask);
 
 static inline int iptunnel_pull_offloads(struct sk_buff *skb)
 {
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 2dcf1de948ac..4f543262dd81 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -105,8 +105,7 @@ struct metadata_dst *udp_tun_rx_dst(struct sk_buff *skb, unsigned short family,
 				    __be16 flags, __be64 tunnel_id,
 				    int md_size);
 
-static inline struct sk_buff *udp_tunnel_handle_offloads(struct sk_buff *skb,
-							 bool udp_csum)
+static inline int udp_tunnel_handle_offloads(struct sk_buff *skb, bool udp_csum)
 {
 	int type = udp_csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index d039f8fff57f..7ac5ec87b004 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -802,11 +802,11 @@ int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM ? SKB_GSO_UDP_TUNNEL_CSUM :
 						       SKB_GSO_UDP_TUNNEL;
 	__be16 sport;
+	int err;
 
-	skb = iptunnel_handle_offloads(skb, type);
-
-	if (IS_ERR(skb))
-		return PTR_ERR(skb);
+	err = iptunnel_handle_offloads(skb, type);
+	if (err)
+		return err;
 
 	sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
 					       skb, 0, 0, false);
@@ -826,6 +826,7 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	__be16 sport;
 	void *data;
 	bool need_priv = false;
+	int err;
 
 	if ((e->flags & TUNNEL_ENCAP_FLAG_REMCSUM) &&
 	    skb->ip_summed == CHECKSUM_PARTIAL) {
@@ -836,10 +837,9 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 
 	optlen += need_priv ? GUE_LEN_PRIV : 0;
 
-	skb = iptunnel_handle_offloads(skb, type);
-
-	if (IS_ERR(skb))
-		return PTR_ERR(skb);
+	err = iptunnel_handle_offloads(skb, type);
+	if (err)
+		return err;
 
 	/* Get source port (based on flow hash) before skb_push */
 	sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index af5d1f38217f..eedd829a2f87 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -500,8 +500,7 @@ static void __gre_xmit(struct sk_buff *skb, struct net_device *dev,
 	ip_tunnel_xmit(skb, dev, tnl_params, tnl_params->protocol);
 }
 
-static struct sk_buff *gre_handle_offloads(struct sk_buff *skb,
-					   bool csum)
+static int gre_handle_offloads(struct sk_buff *skb, bool csum)
 {
 	return iptunnel_handle_offloads(skb, csum ? SKB_GSO_GRE_CSUM : SKB_GSO_GRE);
 }
@@ -568,11 +567,8 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	/* Push Tunnel header. */
-	skb = gre_handle_offloads(skb, !!(tun_info->key.tun_flags & TUNNEL_CSUM));
-	if (IS_ERR(skb)) {
-		skb = NULL;
+	if (gre_handle_offloads(skb, !!(tun_info->key.tun_flags & TUNNEL_CSUM)))
 		goto err_free_rt;
-	}
 
 	flags = tun_info->key.tun_flags & (TUNNEL_CSUM | TUNNEL_KEY);
 	build_header(skb, tunnel_hlen, flags, htons(ETH_P_TEB),
@@ -640,16 +636,14 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 		tnl_params = &tunnel->parms.iph;
 	}
 
-	skb = gre_handle_offloads(skb, !!(tunnel->parms.o_flags&TUNNEL_CSUM));
-	if (IS_ERR(skb))
-		goto out;
+	if (gre_handle_offloads(skb, !!(tunnel->parms.o_flags & TUNNEL_CSUM)))
+		goto free_skb;
 
 	__gre_xmit(skb, dev, tnl_params, skb->protocol);
 	return NETDEV_TX_OK;
 
 free_skb:
 	kfree_skb(skb);
-out:
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_OK;
 }
@@ -664,9 +658,8 @@ static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	skb = gre_handle_offloads(skb, !!(tunnel->parms.o_flags&TUNNEL_CSUM));
-	if (IS_ERR(skb))
-		goto out;
+	if (gre_handle_offloads(skb, !!(tunnel->parms.o_flags & TUNNEL_CSUM)))
+		goto free_skb;
 
 	if (skb_cow_head(skb, dev->needed_headroom))
 		goto free_skb;
@@ -676,7 +669,6 @@ static netdev_tx_t gre_tap_xmit(struct sk_buff *skb,
 
 free_skb:
 	kfree_skb(skb);
-out:
 	dev->stats.tx_dropped++;
 	return NETDEV_TX_OK;
 }
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 43445df61efd..f46c5c873831 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -146,8 +146,8 @@ struct metadata_dst *iptunnel_metadata_reply(struct metadata_dst *md,
 }
 EXPORT_SYMBOL_GPL(iptunnel_metadata_reply);
 
-struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
-					 int gso_type_mask)
+int iptunnel_handle_offloads(struct sk_buff *skb,
+			     int gso_type_mask)
 {
 	int err;
 
@@ -159,9 +159,9 @@ struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
 	if (skb_is_gso(skb)) {
 		err = skb_unclone(skb, GFP_ATOMIC);
 		if (unlikely(err))
-			goto error;
+			return err;
 		skb_shinfo(skb)->gso_type |= gso_type_mask;
-		return skb;
+		return 0;
 	}
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
@@ -174,10 +174,7 @@ struct sk_buff *iptunnel_handle_offloads(struct sk_buff *skb,
 		skb->encapsulation = 0;
 	}
 
-	return skb;
-error:
-	kfree_skb(skb);
-	return ERR_PTR(err);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(iptunnel_handle_offloads);
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index ec51d02166de..92827483ee3d 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -219,9 +219,8 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb->protocol != htons(ETH_P_IP)))
 		goto tx_error;
 
-	skb = iptunnel_handle_offloads(skb, SKB_GSO_IPIP);
-	if (IS_ERR(skb))
-		goto out;
+	if (iptunnel_handle_offloads(skb, SKB_GSO_IPIP))
+		goto tx_error;
 
 	skb_set_inner_ipproto(skb, IPPROTO_IPIP);
 
@@ -230,7 +229,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 tx_error:
 	kfree_skb(skb);
-out:
+
 	dev->stats.tx_errors++;
 	return NETDEV_TX_OK;
 }
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 83384308d032..a13d8c114ccb 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -913,10 +913,9 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		goto tx_error;
 	}
 
-	skb = iptunnel_handle_offloads(skb, SKB_GSO_SIT);
-	if (IS_ERR(skb)) {
+	if (iptunnel_handle_offloads(skb, SKB_GSO_SIT)) {
 		ip_rt_put(rt);
-		goto out;
+		goto tx_error;
 	}
 
 	if (df) {
@@ -992,7 +991,6 @@ tx_error_icmp:
 	dst_link_failure(skb);
 tx_error:
 	kfree_skb(skb);
-out:
 	dev->stats.tx_errors++;
 	return NETDEV_TX_OK;
 }
@@ -1002,15 +1000,15 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr  *tiph = &tunnel->parms.iph;
 
-	skb = iptunnel_handle_offloads(skb, SKB_GSO_IPIP);
-	if (IS_ERR(skb))
-		goto out;
+	if (iptunnel_handle_offloads(skb, SKB_GSO_IPIP))
+		goto tx_error;
 
 	skb_set_inner_ipproto(skb, IPPROTO_IPIP);
 
 	ip_tunnel_xmit(skb, dev, tiph, IPPROTO_IPIP);
 	return NETDEV_TX_OK;
-out:
+tx_error:
+	kfree_skb(skb);
 	dev->stats.tx_errors++;
 	return NETDEV_TX_OK;
 }
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index dc196a0f501d..6d19d2eeaa60 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -1013,8 +1013,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (IS_ERR(skb))
 		goto tx_error;
 
-	skb = iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET, cp->af));
-	if (IS_ERR(skb))
+	if (iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET, cp->af)))
 		goto tx_error;
 
 	skb->transport_header = skb->network_header;
@@ -1105,8 +1104,7 @@ ip_vs_tunnel_xmit_v6(struct sk_buff *skb, struct ip_vs_conn *cp,
 	if (IS_ERR(skb))
 		goto tx_error;
 
-	skb = iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET6, cp->af));
-	if (IS_ERR(skb))
+	if (iptunnel_handle_offloads(skb, __tun_gso_type_mask(AF_INET6, cp->af)))
 		goto tx_error;
 
 	skb->transport_header = skb->network_header;
