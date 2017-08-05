From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next v2 1/5] ipv6: sr: allow SRH insertion with arbitrary segments_left value
Date: Sat, 5 Aug 2017 12:38:24 +0200
Message-ID: <20170805103828.21458-2-david.lebrun@uclouvain.be>
References: <20170805103828.21458-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:40305 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751250AbdHEKi2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 06:38:28 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp6.sgsi.ucl.ac.be (Postfix) with ESMTPS id 2023D67DC56
        for <netdev@vger.kernel.org>; Sat,  5 Aug 2017 12:38:19 +0200 (CEST)
In-Reply-To: <20170805103828.21458-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The seg6_validate_srh() function only allows SRHs whose active segment is
the first segment of the path. However, an application may insert an SRH
whose active segment is not the first one. Such an application might be
for example an SR-aware Virtual Network Function.

This patch enables to insert SRHs with an arbitrary active segment.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/exthdrs.c | 4 ++--
 net/ipv6/seg6.c    | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 3cec529..9551613 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -882,7 +882,7 @@ static void ipv6_push_rthdr4(struct sk_buff *skb, u8 *proto,
 	       (hops - 1) * sizeof(struct in6_addr));
 
 	sr_phdr->segments[0] = **addr_p;
-	*addr_p = &sr_ihdr->segments[hops - 1];
+	*addr_p = &sr_ihdr->segments[sr_ihdr->segments_left];
 
 #ifdef CONFIG_IPV6_SEG6_HMAC
 	if (sr_has_hmac(sr_phdr)) {
@@ -1174,7 +1174,7 @@ struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
 	{
 		struct ipv6_sr_hdr *srh = (struct ipv6_sr_hdr *)opt->srcrt;
 
-		fl6->daddr = srh->segments[srh->first_segment];
+		fl6->daddr = srh->segments[srh->segments_left];
 		break;
 	}
 	default:
diff --git a/net/ipv6/seg6.c b/net/ipv6/seg6.c
index 15fba55..81c2339 100644
--- a/net/ipv6/seg6.c
+++ b/net/ipv6/seg6.c
@@ -40,7 +40,7 @@ bool seg6_validate_srh(struct ipv6_sr_hdr *srh, int len)
 	if (((srh->hdrlen + 1) << 3) != len)
 		return false;
 
-	if (srh->segments_left != srh->first_segment)
+	if (srh->segments_left > srh->first_segment)
 		return false;
 
 	tlv_offset = sizeof(*srh) + ((srh->first_segment + 1) << 4);
-- 
2.10.2
