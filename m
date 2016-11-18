From: Pravin B Shelar <pshelar@ovn.org>
Subject: [PATCH net-next 2/4] geneve: Merge ipv4 and ipv6 geneve_build_skb()
Date: Thu, 17 Nov 2016 23:10:27 -0800
Message-ID: <1479453029-29619-3-git-send-email-pshelar@ovn.org>
References: <1479453029-29619-1-git-send-email-pshelar@ovn.org>
Cc: Pravin B Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:53262 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752147AbcKRHKj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 02:10:39 -0500
In-Reply-To: <1479453029-29619-1-git-send-email-pshelar@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are minimal difference in building Geneve header
between ipv4 and ipv6 geneve tunnels. Following patch
refactors code to unify it.

Signed-off-by: Pravin B Shelar <pshelar@ovn.org>
---
 drivers/net/geneve.c | 100 ++++++++++++++-------------------------------------
 1 file changed, 26 insertions(+), 74 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 622cf3b..9a4351c 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -630,67 +630,34 @@ static int geneve_stop(struct net_device *dev)
 }
 
 static void geneve_build_header(struct genevehdr *geneveh,
-				__be16 tun_flags, u8 vni[3],
-				u8 options_len, u8 *options)
+				const struct ip_tunnel_info *info)
 {
 	geneveh->ver = GENEVE_VER;
-	geneveh->opt_len = options_len / 4;
-	geneveh->oam = !!(tun_flags & TUNNEL_OAM);
-	geneveh->critical = !!(tun_flags & TUNNEL_CRIT_OPT);
+	geneveh->opt_len = info->options_len / 4;
+	geneveh->oam = !!(info->key.tun_flags & TUNNEL_OAM);
+	geneveh->critical = !!(info->key.tun_flags & TUNNEL_CRIT_OPT);
 	geneveh->rsvd1 = 0;
-	memcpy(geneveh->vni, vni, 3);
+	tunnel_id_to_vni(info->key.tun_id, geneveh->vni);
 	geneveh->proto_type = htons(ETH_P_TEB);
 	geneveh->rsvd2 = 0;
 
-	memcpy(geneveh->options, options, options_len);
+	ip_tunnel_info_opts_get(geneveh->options, info);
 }
 
-static int geneve_build_skb(struct rtable *rt, struct sk_buff *skb,
-			    __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
-			    bool xnet)
-{
-	bool udp_sum = !!(tun_flags & TUNNEL_CSUM);
-	struct genevehdr *gnvh;
-	int min_headroom;
-	int err;
-
-	skb_scrub_packet(skb, xnet);
-
-	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
-			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct iphdr);
-	err = skb_cow_head(skb, min_headroom);
-	if (unlikely(err))
-		goto free_rt;
-
-	err = udp_tunnel_handle_offloads(skb, udp_sum);
-	if (err)
-		goto free_rt;
-
-	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
-	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
-
-	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
-	return 0;
-
-free_rt:
-	ip_rt_put(rt);
-	return err;
-}
-
-#if IS_ENABLED(CONFIG_IPV6)
-static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
-			     __be16 tun_flags, u8 vni[3], u8 opt_len, u8 *opt,
-			     bool xnet)
+static int geneve_build_skb(struct dst_entry *dst, struct sk_buff *skb,
+			    const struct ip_tunnel_info *info,
+			    bool xnet, int ip_hdr_len)
 {
-	bool udp_sum = !!(tun_flags & TUNNEL_CSUM);
+	bool udp_sum = !!(info->key.tun_flags & TUNNEL_CSUM);
 	struct genevehdr *gnvh;
 	int min_headroom;
 	int err;
 
+	skb_reset_mac_header(skb);
 	skb_scrub_packet(skb, xnet);
 
-	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
-			+ GENEVE_BASE_HLEN + opt_len + sizeof(struct ipv6hdr);
+	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len +
+		       GENEVE_BASE_HLEN + info->options_len + ip_hdr_len;
 	err = skb_cow_head(skb, min_headroom);
 	if (unlikely(err))
 		goto free_dst;
@@ -699,9 +666,9 @@ static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
 	if (err)
 		goto free_dst;
 
-	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) + opt_len);
-	geneve_build_header(gnvh, tun_flags, vni, opt_len, opt);
-
+	gnvh = (struct genevehdr *)__skb_push(skb, sizeof(*gnvh) +
+						   info->options_len);
+	geneve_build_header(gnvh, info);
 	skb_set_inner_protocol(skb, htons(ETH_P_TEB));
 	return 0;
 
@@ -709,12 +676,11 @@ static int geneve6_build_skb(struct dst_entry *dst, struct sk_buff *skb,
 	dst_release(dst);
 	return err;
 }
-#endif
 
 static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 				       struct net_device *dev,
 				       struct flowi4 *fl4,
-				       struct ip_tunnel_info *info)
+				       const struct ip_tunnel_info *info)
 {
 	bool use_cache = ip_tunnel_dst_cache_usable(skb, info);
 	struct geneve_dev *geneve = netdev_priv(dev);
@@ -738,7 +704,7 @@ static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 	}
 	fl4->flowi4_tos = RT_TOS(tos);
 
-	dst_cache = &info->dst_cache;
+	dst_cache = (struct dst_cache *)&info->dst_cache;
 	if (use_cache) {
 		rt = dst_cache_get_ip4(dst_cache, &fl4->saddr);
 		if (rt)
@@ -763,7 +729,7 @@ static struct rtable *geneve_get_v4_rt(struct sk_buff *skb,
 static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 					   struct net_device *dev,
 					   struct flowi6 *fl6,
-					   struct ip_tunnel_info *info)
+					   const struct ip_tunnel_info *info)
 {
 	bool use_cache = ip_tunnel_dst_cache_usable(skb, info);
 	struct geneve_dev *geneve = netdev_priv(dev);
@@ -789,7 +755,7 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 
 	fl6->flowlabel = ip6_make_flowinfo(RT_TOS(prio),
 					   info->key.label);
-	dst_cache = &info->dst_cache;
+	dst_cache = (struct dst_cache *)&info->dst_cache;
 	if (use_cache) {
 		dst = dst_cache_get_ip6(dst_cache, &fl6->saddr);
 		if (dst)
@@ -812,7 +778,8 @@ static struct dst_entry *geneve_get_v6_dst(struct sk_buff *skb,
 #endif
 
 static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
-			   struct geneve_dev *geneve, struct ip_tunnel_info *info)
+			   struct geneve_dev *geneve,
+			   const struct ip_tunnel_info *info)
 {
 	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
 	struct geneve_sock *gs4 = rcu_dereference(geneve->sock4);
@@ -820,11 +787,9 @@ static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	struct rtable *rt;
 	int err = -EINVAL;
 	struct flowi4 fl4;
-	u8 *opts = NULL;
 	__u8 tos, ttl;
 	__be16 sport;
 	__be16 df;
-	u8 vni[3];
 
 	if (!gs4)
 		return err;
@@ -843,13 +808,7 @@ static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	}
 	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ? htons(IP_DF) : 0;
 
-	tunnel_id_to_vni(key->tun_id, vni);
-	if (info->options_len)
-		opts = ip_tunnel_info_opts(info);
-
-	skb_reset_mac_header(skb);
-	err = geneve_build_skb(rt, skb, key->tun_flags, vni,
-			       info->options_len, opts, xnet);
+	err = geneve_build_skb(&rt->dst, skb, info, xnet, sizeof(struct iphdr));
 	if (unlikely(err))
 		return err;
 
@@ -862,7 +821,8 @@ static int geneve_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 
 #if IS_ENABLED(CONFIG_IPV6)
 static int geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
-			    struct geneve_dev *geneve, struct ip_tunnel_info *info)
+			    struct geneve_dev *geneve,
+			    const struct ip_tunnel_info *info)
 {
 	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
 	struct geneve_sock *gs6 = rcu_dereference(geneve->sock6);
@@ -870,10 +830,8 @@ static int geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 	struct dst_entry *dst = NULL;
 	int err = -EINVAL;
 	struct flowi6 fl6;
-	u8 *opts = NULL;
 	__u8 prio, ttl;
 	__be16 sport;
-	u8 vni[3];
 
 	if (!gs6)
 		return err;
@@ -891,13 +849,7 @@ static int geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 					   ip_hdr(skb), skb);
 		ttl = key->ttl ? : ip6_dst_hoplimit(dst);
 	}
-	tunnel_id_to_vni(key->tun_id, vni);
-	if (info->options_len)
-		opts = ip_tunnel_info_opts(info);
-
-	skb_reset_mac_header(skb);
-	err = geneve6_build_skb(dst, skb, key->tun_flags, vni,
-				info->options_len, opts, xnet);
+	err = geneve_build_skb(dst, skb, info, xnet, sizeof(struct iphdr));
 	if (unlikely(err))
 		return err;
 
-- 
1.8.3.1
