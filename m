From: Ahmed Abdelsalam <amsalam20@gmail.com>
Subject: [PATCH] ipv6: sr: fix get_srh() to comply with IPv6 standard "RFC 8200"
Date: Mon, 28 Aug 2017 20:20:42 +0200
Message-ID: <1503944442-8994-1-git-send-email-amsalam20@gmail.com>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
        amsalam20@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:38301 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751918AbdH1SUw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 14:20:52 -0400
Received: by mail-wr0-f196.google.com with SMTP id j3so840671wrb.5
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 11:20:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 packet may carry more than one extension header, and IPv6 nodes must
acceptand attempt to process extension headers in any order and occurring
any number of times in the same packet. Hence, there should be no
assumption that Segment Routing extension header is to appear immediately
after the IPv6 header.

Moreover, section 4.1 of RFC 8200 gives a recommendation on the order of
appearance of those extension headers within an IPv6 packet. According to
this recommendation, Segment Routing extension header should appear after
Hop-by-Hop and Destination Options headers (if they present).

This patch fixes the get_srh(), so it gets the segment routing header
regardless of its position in the chain of the extension headers in IPv6
packet, and makes sure that the IPv6 routing extension header is of
Type 4.

Signed-off-by: Ahmed Abdelsalam <amsalam20@gmail.com>
---
 net/ipv6/seg6_local.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/seg6_local.c b/net/ipv6/seg6_local.c
index 9c1a885..ae97fd9 100644
--- a/net/ipv6/seg6_local.c
+++ b/net/ipv6/seg6_local.c
@@ -62,17 +62,19 @@ static struct seg6_local_lwt *seg6_local_lwtunnel(struct lwtunnel_state *lwt)
 static struct ipv6_sr_hdr *get_srh(struct sk_buff *skb)
 {
 	struct ipv6_sr_hdr *srh;
-	struct ipv6hdr *hdr;
-	int len;
+	int len, srhoff;
 
-	hdr = ipv6_hdr(skb);
-	if (hdr->nexthdr != IPPROTO_ROUTING)
+	if (ipv6_find_hdr(skb, &srhoff, IPPROTO_ROUTING, NULL, NULL) < 0)
 		return NULL;
 
-	srh = (struct ipv6_sr_hdr *)(hdr + 1);
-	len = (srh->hdrlen + 1) << 3;
+	srh = (struct ipv6_sr_hdr *)(skb->data + srhoff);
 
-	if (!pskb_may_pull(skb, sizeof(*hdr) + len))
+	/* make sure it's a Segment Routing header (Routing Type 4) */
+	if (srh->type != IPV6_SRCRT_TYPE_4)
+		return NULL;
+
+	len = (srh->hdrlen + 1) << 3;
+	if (!pskb_may_pull(skb, srhoff + len))
 		return NULL;
 
 	if (!seg6_validate_srh(srh, len))
-- 
2.7.4
