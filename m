From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 3/6] gre: call skb_gro_checksum_simple_validate
Date: Fri, 22 Aug 2014 13:34:22 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408221316100.1634@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:46316 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbaHVUeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 16:34:23 -0400
Received: by mail-pd0-f201.google.com with SMTP id g10so2932927pdj.4
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 13:34:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/gre_offload.c | 43 +++++++------------------------------------
 1 file changed, 7 insertions(+), 36 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 6556263..d1bd169 100644
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
@@ -192,22 +170,15 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
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
+
+	/* Don't bother verifying checksum if we're going to flush anyway. */
+	if (greh->flags & GRE_CSUM) {
+		if (!NAPI_GRO_CB(skb)->flush &&
+		    skb_gro_checksum_simple_validate(skb))
 			goto out_unlock;
+		NAPI_GRO_CB(skb)->encapsulation++;
 	}
+
 	flush = 0;
 
 	for (p = *head; p; p = p->next) {
-- 
2.1.0.rc2.206.gedb03e5
