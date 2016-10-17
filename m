From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH 6/9] ipv6: sr: add calls to verify and insert HMAC signatures
Date: Mon, 17 Oct 2016 16:43:39 +0200
Message-ID: <1476715422-19151-2-git-send-email-david.lebrun@uclouvain.be>
References: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:34207 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755177AbcJQOvf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 10:51:35 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp6.sgsi.ucl.ac.be (Postfix) with ESMTPS id EA1C067DAFD
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 16:42:06 +0200 (CEST)
In-Reply-To: <1476715350-18983-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables the verification of the HMAC signature for transiting
SR-enabled packets, and its insertion on encapsulated/injected SRH.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/exthdrs.c       |  6 ++++++
 net/ipv6/seg6_iptunnel.c | 13 +++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index b31f811..73b3743 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -49,6 +49,7 @@
 #endif
 #ifdef CONFIG_IPV6_SEG6
 #include <linux/seg6.h>
+#include <net/seg6_hmac.h>
 #endif
 
 #include <linux/uaccess.h>
@@ -313,6 +314,11 @@ static int ipv6_srh_rcv(struct sk_buff *skb)
 		return -1;
 	}
 
+	if (!seg6_hmac_validate_skb(skb)) {
+		kfree_skb(skb);
+		return -1;
+	}
+
 looped_back:
 	last_addr = hdr->segments;
 
diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index 461375c..a32a7ff 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -109,12 +109,19 @@ static int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 	hdr->daddr = isrh->segments[isrh->first_segment];
 	set_tun_src(net, skb->dev, &hdr->daddr, &hdr->saddr);
 
+	if (sr_get_flags(isrh) & SR6_FLAG_HMAC) {
+		err = seg6_push_hmac(net, &hdr->saddr, isrh);
+		if (unlikely(err))
+			return err;
+	}
+
 	return 0;
 }
 
 /* insert an SRH within an IPv6 packet, just after the IPv6 header */
 static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 {
+	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct ipv6hdr *hdr, *oldhdr;
 	struct ipv6_sr_hdr *isrh;
 	int hdrlen, err;
@@ -144,6 +151,12 @@ static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 	isrh->segments[0] = hdr->daddr;
 	hdr->daddr = isrh->segments[isrh->first_segment];
 
+	if (sr_get_flags(isrh) & SR6_FLAG_HMAC) {
+		err = seg6_push_hmac(net, &hdr->saddr, isrh);
+		if (unlikely(err))
+			return err;
+	}
+
 	return 0;
 }
 
-- 
2.7.3
