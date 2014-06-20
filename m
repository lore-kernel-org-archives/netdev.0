From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/5] gre: call skb_gro_checksum_simple_validate
Date: Fri, 20 Jun 2014 16:37:52 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406201631250.11820@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:59021 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846AbaFTXhy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 19:37:54 -0400
Received: by mail-oa0-f74.google.com with SMTP id i7so1105942oag.3
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 16:37:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/gre_offload.c | 43 +++++--------------------------------------
 1 file changed, 5 insertions(+), 38 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index eb92deb..60c08b6 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -119,28 +119,6 @@ out:
 	return segs;
 }
 
-/* Compute the whole skb csum in s/w and store it, then verify GRO csum
- * starting from gro_offset.
- */
-static __sum16 gro_skb_checksum(struct sk_buff *skb)
-{
-	__sum16 sum;
-
-	skb->csum = skb_checksum(skb, 0, skb->len, 0);
-	NAPI_GRO_CB(skb)->csum = csum_sub(skb->csum,
-		csum_partial(skb->data, skb_gro_offset(skb), 0));
-	sum = csum_fold(NAPI_GRO_CB(skb)->csum);
-	if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE)) {
-		if (unlikely(!sum) && !skb->csum_complete_sw)
-			netdev_rx_csum_fault(skb->dev);
-	} else {
-		skb->ip_summed = CHECKSUM_COMPLETE;
-		skb->csum_complete_sw = 1;
-	}
-
-	return sum;
-}
-
 static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 					struct sk_buff *skb)
 {
@@ -192,22 +170,11 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 		if (unlikely(!greh))
 			goto out_unlock;
 	}
-	if (greh->flags & GRE_CSUM) { /* Need to verify GRE csum first */
-		__sum16 csum = 0;
-
-		if (skb->ip_summed == CHECKSUM_COMPLETE)
-			csum = csum_fold(NAPI_GRO_CB(skb)->csum);
-		/* Don't trust csum error calculated/reported by h/w */
-		if (skb->ip_summed == CHECKSUM_NONE || csum != 0)
-			csum = gro_skb_checksum(skb);
-
-		/* GRE CSUM is the 1's complement of the 1's complement sum
-		 * of the GRE hdr plus payload so it should add up to 0xffff
-		 * (and 0 after csum_fold()) just like the IPv4 hdr csum.
-		 */
-		if (csum)
-			goto out_unlock;
-	}
+
+	if ((greh->flags & GRE_CSUM) &&
+	    skb_gro_checksum_simple_validate(skb))
+		goto out_unlock;
+
 	flush = 0;
 
 	for (p = *head; p; p = p->next) {
-- 
2.0.0.526.g5318336
