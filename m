From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next] ipv6: sr: select DST_CACHE by default
Date: Mon, 27 Mar 2017 11:43:59 +0200
Message-ID: <20170327094359.28595-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:59489 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752067AbdC0Jol (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 05:44:41 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp1.sgsi.ucl.ac.be (Postfix) with ESMTPS id 038FE67DB09
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:44:05 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_IPV6_SEG6_LWTUNNEL is selected, automatically select DST_CACHE.
This allows to remove multiple ifdefs.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/Kconfig         |  1 +
 net/ipv6/seg6_iptunnel.c | 18 ------------------
 2 files changed, 1 insertion(+), 18 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index e2afe677..48c4529 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -307,6 +307,7 @@ config IPV6_SEG6_LWTUNNEL
 	bool "IPv6: Segment Routing Header encapsulation support"
 	depends on IPV6
 	select LWTUNNEL
+	select DST_CACHE
 	---help---
 	  Support for encapsulation of packets within an outer IPv6
 	  header and a Segment Routing Header using the lightweight
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index 30ef1d1..a644aae 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -26,17 +26,13 @@
 #include <linux/seg6_iptunnel.h>
 #include <net/addrconf.h>
 #include <net/ip6_route.h>
-#ifdef CONFIG_DST_CACHE
 #include <net/dst_cache.h>
-#endif
 #ifdef CONFIG_IPV6_SEG6_HMAC
 #include <net/seg6_hmac.h>
 #endif
 
 struct seg6_lwt {
-#ifdef CONFIG_DST_CACHE
 	struct dst_cache cache;
-#endif
 	struct seg6_iptunnel_encap tuninfo[0];
 };
 
@@ -250,17 +246,14 @@ static int seg6_input(struct sk_buff *skb)
 
 	slwt = seg6_lwt_lwtunnel(orig_dst->lwtstate);
 
-#ifdef CONFIG_DST_CACHE
 	preempt_disable();
 	dst = dst_cache_get(&slwt->cache);
 	preempt_enable();
-#endif
 
 	skb_dst_drop(skb);
 
 	if (!dst) {
 		ip6_route_input(skb);
-#ifdef CONFIG_DST_CACHE
 		dst = skb_dst(skb);
 		if (!dst->error) {
 			preempt_disable();
@@ -268,7 +261,6 @@ static int seg6_input(struct sk_buff *skb)
 					  &ipv6_hdr(skb)->saddr);
 			preempt_enable();
 		}
-#endif
 	} else {
 		skb_dst_set(skb, dst);
 	}
@@ -289,11 +281,9 @@ static int seg6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 
 	slwt = seg6_lwt_lwtunnel(orig_dst->lwtstate);
 
-#ifdef CONFIG_DST_CACHE
 	preempt_disable();
 	dst = dst_cache_get(&slwt->cache);
 	preempt_enable();
-#endif
 
 	if (unlikely(!dst)) {
 		struct ipv6hdr *hdr = ipv6_hdr(skb);
@@ -312,11 +302,9 @@ static int seg6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
 			goto drop;
 		}
 
-#ifdef CONFIG_DST_CACHE
 		preempt_disable();
 		dst_cache_set_ip6(&slwt->cache, dst, &fl6.saddr);
 		preempt_enable();
-#endif
 	}
 
 	skb_dst_drop(skb);
@@ -380,13 +368,11 @@ static int seg6_build_state(struct nlattr *nla,
 
 	slwt = seg6_lwt_lwtunnel(newts);
 
-#ifdef CONFIG_DST_CACHE
 	err = dst_cache_init(&slwt->cache, GFP_KERNEL);
 	if (err) {
 		kfree(newts);
 		return err;
 	}
-#endif
 
 	memcpy(&slwt->tuninfo, tuninfo, tuninfo_len);
 
@@ -400,12 +386,10 @@ static int seg6_build_state(struct nlattr *nla,
 	return 0;
 }
 
-#ifdef CONFIG_DST_CACHE
 static void seg6_destroy_state(struct lwtunnel_state *lwt)
 {
 	dst_cache_destroy(&seg6_lwt_lwtunnel(lwt)->cache);
 }
-#endif
 
 static int seg6_fill_encap_info(struct sk_buff *skb,
 				struct lwtunnel_state *lwtstate)
@@ -439,9 +423,7 @@ static int seg6_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
 
 static const struct lwtunnel_encap_ops seg6_iptun_ops = {
 	.build_state = seg6_build_state,
-#ifdef CONFIG_DST_CACHE
 	.destroy_state = seg6_destroy_state,
-#endif
 	.output = seg6_output,
 	.input = seg6_input,
 	.fill_encap = seg6_fill_encap_info,
-- 
2.10.2
