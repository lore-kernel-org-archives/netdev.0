From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v3 6/9] ipv6: sr: add calls to verify and insert HMAC signatures
Date: Thu, 27 Oct 2016 15:35:01 +0200
Message-ID: <1477575304-11375-2-git-send-email-david.lebrun@uclouvain.be>
References: <1477575239-11228-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33367 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934030AbcJ0Nwi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 09:52:38 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp1.sgsi.ucl.ac.be (Postfix) with ESMTPS id 1B96067DA9E
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2016 15:33:19 +0200 (CEST)
In-Reply-To: <1477575239-11228-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the verification of the HMAC signature for transiting
SR-enabled packets, and its insertion on encapsulated/injected SRH.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/exthdrs.c       | 10 ++++++++++
 net/ipv6/seg6_iptunnel.c | 18 ++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index cf9f338..9b63932 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -48,6 +48,9 @@
 #include <net/xfrm.h>
 #endif
 #include <linux/seg6.h>
+#ifdef CONFIG_IPV6_SEG6_HMAC
+#include <net/seg6_hmac.h>
+#endif
 
 #include <linux/uaccess.h>
 
@@ -358,6 +361,13 @@ static int ipv6_srh_rcv(struct sk_buff *skb)
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
index e0ae54b..eb57d14 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -126,6 +126,14 @@ static int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
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
@@ -167,6 +175,16 @@ static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
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
