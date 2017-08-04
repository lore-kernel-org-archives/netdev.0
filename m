From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next 2/5] ipv6: sr: export SRH insertion functions
Date: Fri, 4 Aug 2017 15:24:12 +0200
Message-ID: <20170804132415.9701-3-david.lebrun@uclouvain.be>
References: <20170804132415.9701-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:38109 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751382AbdHDNYL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 09:24:11 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id F249D67E06E
        for <netdev@vger.kernel.org>; Fri,  4 Aug 2017 15:24:01 +0200 (CEST)
In-Reply-To: <20170804132415.9701-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch exports the seg6_do_srh_encap() and seg6_do_srh_inline()
functions. It also removes the CONFIG_IPV6_SEG6_INLINE knob
that enabled the compilation of seg6_do_srh_inline(). This function
is now built-in.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 include/net/seg6.h       |  2 ++
 net/ipv6/Kconfig         | 12 ------------
 net/ipv6/seg6_iptunnel.c | 12 ++++--------
 3 files changed, 6 insertions(+), 20 deletions(-)

diff --git a/include/net/seg6.h b/include/net/seg6.h
index 4e03575..a32abb0 100644
--- a/include/net/seg6.h
+++ b/include/net/seg6.h
@@ -58,5 +58,7 @@ extern int seg6_iptunnel_init(void);
 extern void seg6_iptunnel_exit(void);
 
 extern bool seg6_validate_srh(struct ipv6_sr_hdr *srh, int len);
+extern int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh);
+extern int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh);
 
 #endif
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 48c4529..50181a9 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -315,18 +315,6 @@ config IPV6_SEG6_LWTUNNEL
 
 	  If unsure, say N.
 
-config IPV6_SEG6_INLINE
-	bool "IPv6: direct Segment Routing Header insertion "
-	depends on IPV6_SEG6_LWTUNNEL
-	---help---
-	  Support for direct insertion of the Segment Routing Header,
-	  also known as inline mode. Be aware that direct insertion of
-	  extension headers (as opposed to encapsulation) may break
-	  multiple mechanisms such as PMTUD or IPSec AH. Use this feature
-	  only if you know exactly what you are doing.
-
-	  If unsure, say N.
-
 config IPV6_SEG6_HMAC
 	bool "IPv6: Segment Routing HMAC support"
 	depends on IPV6
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index 264d772..20b1ba8 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -91,7 +91,7 @@ static void set_tun_src(struct net *net, struct net_device *dev,
 }
 
 /* encapsulate an IPv6 packet within an outer IPv6 header with a given SRH */
-static int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
+int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 {
 	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct ipv6hdr *hdr, *inner_hdr;
@@ -141,10 +141,10 @@ static int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 
 	return 0;
 }
+EXPORT_SYMBOL(seg6_do_srh_encap);
 
 /* insert an SRH within an IPv6 packet, just after the IPv6 header */
-#ifdef CONFIG_IPV6_SEG6_INLINE
-static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
+int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 {
 	struct ipv6hdr *hdr, *oldhdr;
 	struct ipv6_sr_hdr *isrh;
@@ -193,7 +193,7 @@ static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 
 	return 0;
 }
-#endif
+EXPORT_SYMBOL(seg6_do_srh_inline);
 
 static int seg6_do_srh(struct sk_buff *skb)
 {
@@ -209,12 +209,10 @@ static int seg6_do_srh(struct sk_buff *skb)
 	}
 
 	switch (tinfo->mode) {
-#ifdef CONFIG_IPV6_SEG6_INLINE
 	case SEG6_IPTUN_MODE_INLINE:
 		err = seg6_do_srh_inline(skb, tinfo->srh);
 		skb_reset_inner_headers(skb);
 		break;
-#endif
 	case SEG6_IPTUN_MODE_ENCAP:
 		err = seg6_do_srh_encap(skb, tinfo->srh);
 		break;
@@ -357,10 +355,8 @@ static int seg6_build_state(struct nlattr *nla,
 		return -EINVAL;
 
 	switch (tuninfo->mode) {
-#ifdef CONFIG_IPV6_SEG6_INLINE
 	case SEG6_IPTUN_MODE_INLINE:
 		break;
-#endif
 	case SEG6_IPTUN_MODE_ENCAP:
 		break;
 	default:
-- 
2.10.2
