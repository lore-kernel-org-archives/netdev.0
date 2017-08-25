From: William Tu <u9012063@gmail.com>
Subject: [PATCH net-next 1/3] gre: refactor the gre_fb_xmit
Date: Fri, 25 Aug 2017 09:21:27 -0700
Message-ID: <1503678089-27131-2-git-send-email-u9012063@gmail.com>
References: <1503678089-27131-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33173 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934389AbdHYQVl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 12:21:41 -0400
Received: by mail-pg0-f66.google.com with SMTP id q16so391114pgc.0
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 09:21:41 -0700 (PDT)
Received: from sc9-mailhost2.vmware.com ([208.91.1.34])
        by smtp.gmail.com with ESMTPSA id k197sm1051155pga.78.2017.08.25.09.21.40
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 25 Aug 2017 09:21:40 -0700 (PDT)
In-Reply-To: <1503678089-27131-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch refactors the gre_fb_xmit function, by creating
prepare_fb_xmit function for later ERSPAN collect_md mode patch.

Signed-off-by: William Tu <u9012063@gmail.com>
---
 net/ipv4/ip_gre.c | 55 ++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 40 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index f70674799fdd..453b7925b940 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -432,39 +432,33 @@ static struct rtable *gre_get_rt(struct sk_buff *skb,
 	return ip_route_output_key(net, fl);
 }
 
-static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev,
-			__be16 proto)
+static struct rtable *prepare_fb_xmit(struct sk_buff *skb,
+				      struct net_device *dev,
+				      struct flowi4 *fl,
+				      int tunnel_hlen)
 {
 	struct ip_tunnel_info *tun_info;
 	const struct ip_tunnel_key *key;
 	struct rtable *rt = NULL;
-	struct flowi4 fl;
 	int min_headroom;
-	int tunnel_hlen;
-	__be16 df, flags;
 	bool use_cache;
 	int err;
 
 	tun_info = skb_tunnel_info(skb);
-	if (unlikely(!tun_info || !(tun_info->mode & IP_TUNNEL_INFO_TX) ||
-		     ip_tunnel_info_af(tun_info) != AF_INET))
-		goto err_free_skb;
-
 	key = &tun_info->key;
 	use_cache = ip_tunnel_dst_cache_usable(skb, tun_info);
+
 	if (use_cache)
-		rt = dst_cache_get_ip4(&tun_info->dst_cache, &fl.saddr);
+		rt = dst_cache_get_ip4(&tun_info->dst_cache, &fl->saddr);
 	if (!rt) {
-		rt = gre_get_rt(skb, dev, &fl, key);
+		rt = gre_get_rt(skb, dev, fl, key);
 		if (IS_ERR(rt))
-				goto err_free_skb;
+			goto err_free_skb;
 		if (use_cache)
 			dst_cache_set_ip4(&tun_info->dst_cache, &rt->dst,
-					  fl.saddr);
+					  fl->saddr);
 	}
 
-	tunnel_hlen = gre_calc_hlen(key->tun_flags);
-
 	min_headroom = LL_RESERVED_SPACE(rt->dst.dev) + rt->dst.header_len
 			+ tunnel_hlen + sizeof(struct iphdr);
 	if (skb_headroom(skb) < min_headroom || skb_header_cloned(skb)) {
@@ -476,6 +470,37 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev,
 		if (unlikely(err))
 			goto err_free_rt;
 	}
+	return rt;
+
+err_free_rt:
+	ip_rt_put(rt);
+err_free_skb:
+	kfree_skb(skb);
+	dev->stats.tx_dropped++;
+	return NULL;
+}
+
+static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev,
+			__be16 proto)
+{
+	struct ip_tunnel_info *tun_info;
+	const struct ip_tunnel_key *key;
+	struct rtable *rt = NULL;
+	struct flowi4 fl;
+	int tunnel_hlen;
+	__be16 df, flags;
+
+	tun_info = skb_tunnel_info(skb);
+	if (unlikely(!tun_info || !(tun_info->mode & IP_TUNNEL_INFO_TX) ||
+		     ip_tunnel_info_af(tun_info) != AF_INET))
+		goto err_free_skb;
+
+	key = &tun_info->key;
+	tunnel_hlen = gre_calc_hlen(key->tun_flags);
+
+	rt = prepare_fb_xmit(skb, dev, &fl, tunnel_hlen);
+	if (!rt)
+		return;
 
 	/* Push Tunnel header. */
 	if (gre_handle_offloads(skb, !!(tun_info->key.tun_flags & TUNNEL_CSUM)))
-- 
2.7.4
