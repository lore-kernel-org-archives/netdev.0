From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v4 6/9] ipv6: sr: add calls to verify and insert HMAC signatures
Date: Fri, 4 Nov 2016 11:32:20 +0100
Message-ID: <1478255543-32588-2-git-send-email-david.lebrun@uclouvain.be>
References: <1478255388-32213-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:34723 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760185AbcKDKaj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2016 06:30:39 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp5.sgsi.ucl.ac.be (Postfix) with ESMTPS id 2910D67DA9A
        for <netdev@vger.kernel.org>; Fri,  4 Nov 2016 11:30:27 +0100 (CET)
In-Reply-To: <1478255388-32213-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the verification of the HMAC signature for transiting
SR-enabled packets, and its insertion on encapsulated/injected SRH.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/exthdrs.c       | 10 ++++++++++
 net/ipv6/seg6_iptunnel.c | 21 +++++++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 21a86cf..973a128e 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -49,6 +49,9 @@
 #endif
 #include <linux/seg6.h>
 #include <net/seg6.h>
+#ifdef CONFIG_IPV6_SEG6_HMAC
+#include <net/seg6_hmac.h>
+#endif
 
 #include <linux/uaccess.h>
 
@@ -340,6 +343,13 @@ static int ipv6_srh_rcv(struct sk_buff *skb)
 		return -1;
 	}
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	if (!seg6_hmac_validate_skb(skb)) {
+		kfree_skb(skb);
+		return -1;
+	}
+#endif
+
 looped_back:
 	if (hdr->segments_left > 0) {
 		if (hdr->nexthdr != NEXTHDR_IPV6 && hdr->segments_left == 1 &&
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index 9abeb45..4a3f1ba 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -29,6 +29,9 @@
 #ifdef CONFIG_DST_CACHE
 #include <net/dst_cache.h>
 #endif
+#ifdef CONFIG_IPV6_SEG6_HMAC
+#include <net/seg6_hmac.h>
+#endif
 
 struct seg6_lwt {
 #ifdef CONFIG_DST_CACHE
@@ -130,6 +133,14 @@ static int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 	hdr->daddr = isrh->segments[isrh->first_segment];
 	set_tun_src(net, skb->dev, &hdr->daddr, &hdr->saddr);
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	if (sr_has_hmac(isrh)) {
+		err = seg6_push_hmac(net, &hdr->saddr, isrh);
+		if (unlikely(err))
+			return err;
+	}
+#endif
+
 	skb_postpush_rcsum(skb, hdr, tot_len);
 
 	return 0;
@@ -171,6 +182,16 @@ static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 	isrh->segments[0] = hdr->daddr;
 	hdr->daddr = isrh->segments[isrh->first_segment];
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	if (sr_has_hmac(isrh)) {
+		struct net *net = dev_net(skb_dst(skb)->dev);
+
+		err = seg6_push_hmac(net, &hdr->saddr, isrh);
+		if (unlikely(err))
+			return err;
+	}
+#endif
+
 	skb_postpush_rcsum(skb, hdr, sizeof(struct ipv6hdr) + hdrlen);
 
 	return 0;
-- 
2.7.3
