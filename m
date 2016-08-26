From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [RFC 7/9] ipv6: sr: add calls to verify and insert HMAC signatures
Date: Fri, 26 Aug 2016 17:54:10 +0200
Message-ID: <1472226852-10075-3-git-send-email-david.lebrun@uclouvain.be>
References: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:33405 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753974AbcHZQEi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 12:04:38 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id 3F4CE67DB2E
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 17:53:43 +0200 (CEST)
In-Reply-To: <1472226767-9904-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the verification of the HMAC signature for transiting
SR-enabled packets, and its insertion on encapsulated/injected SRH.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/exthdrs.c       | 10 ++++++++++
 net/ipv6/seg6_iptunnel.c | 17 +++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index e6f41fc..92b684a 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -49,6 +49,9 @@
 #endif
 #ifdef CONFIG_IPV6_SEG6
 #include <linux/seg6.h>
+#ifdef CONFIG_IPV6_SEG6_HMAC
+#include <net/seg6_hmac.h>
+#endif
 #endif
 
 #include <linux/uaccess.h>
@@ -313,6 +316,13 @@ static int ipv6_srh_rcv(struct sk_buff *skb)
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
 	last_addr = hdr->segments;
 
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index ce7218a..f115cc5 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -109,6 +109,14 @@ static int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 	hdr->daddr = isrh->segments[isrh->first_segment];
 	set_tun_src(net, skb->dev, &hdr->daddr, &hdr->saddr);
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	if (sr_get_flags(isrh) & SR6_FLAG_HMAC) {
+		err = seg6_push_hmac(net, &hdr->saddr, isrh);
+		if (unlikely(err))
+			return err;
+	}
+#endif
+
 	return 0;
 }
 
@@ -118,6 +126,7 @@ static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 	struct ipv6hdr *hdr, *oldhdr;
 	struct ipv6_sr_hdr *isrh;
 	int hdrlen, err;
+	struct net *net = dev_net(skb_dst(skb)->dev);
 
 	hdrlen = (osrh->hdrlen + 1) << 3;
 
@@ -144,6 +153,14 @@ static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 	isrh->segments[0] = hdr->daddr;
 	hdr->daddr = isrh->segments[isrh->first_segment];
 
+#ifdef CONFIG_IPV6_SEG6_HMAC
+	if (sr_get_flags(isrh) & SR6_FLAG_HMAC) {
+		err = seg6_push_hmac(net, &hdr->saddr, isrh);
+		if (unlikely(err))
+			return err;
+	}
+#endif
+
 	return 0;
 }
 
-- 
2.3.6
