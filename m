From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v5 6/9] ipv6: sr: add calls to verify and insert HMAC signatures
Date: Tue, 8 Nov 2016 14:59:19 +0100
Message-ID: <1478613562-27947-2-git-send-email-david.lebrun@uclouvain.be>
References: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:56920 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752436AbcKHN5j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 08:57:39 -0500
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp2.sgsi.ucl.ac.be (Postfix) with ESMTPS id 685EC67DE4D
        for <netdev@vger.kernel.org>; Tue,  8 Nov 2016 14:57:23 +0100 (CET)
In-Reply-To: <1478613467-27712-1-git-send-email-david.lebrun@uclouvain.be>
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
index b8ba396..541cfa6 100644
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
index 39762b2..bbfca22 100644
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
@@ -172,6 +183,16 @@ static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
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
