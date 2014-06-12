From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/4] net: Fix save software checksum complete
Date: Thu, 12 Jun 2014 16:03:46 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406121554330.29951@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:59334 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbaFLXDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 19:03:47 -0400
Received: by mail-ob0-f202.google.com with SMTP id va2so408613obc.5
        for <netdev@vger.kernel.org>; Thu, 12 Jun 2014 16:03:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The logic introduced in commit 7e3cead5172927732f51fde
("net: Save software checksum complete") is not correct.

1) This patch restores code in __skb_checksum_complete_header except
   for setting CHECKSUM_UNNECESSARY. This function may be caluculating
   checksum on something less than skb->len
2) Adds saving checksum to __skb_checksum_complete. The full packet
   checksum 0..skb->len is calculated without adding in pseudo header.
   This value is saved in skb->csum and then the pseudo header is added
   to that to derive the checksum for validation.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/datagram.c | 34 ++++++++++++++++++++++++----------
 1 file changed, 24 insertions(+), 10 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 6b1c04c..cf6cc4e 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -739,22 +739,36 @@ __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len)
 	__sum16 sum;
 
 	sum = csum_fold(skb_checksum(skb, 0, len, skb->csum));
-	if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE) && !sum &&
-	    !skb->csum_complete_sw)
-		netdev_rx_csum_fault(skb->dev);
-
-	/* Save checksum complete for later use */
-	skb->csum = sum;
-	skb->ip_summed = CHECKSUM_COMPLETE;
-	skb->csum_complete_sw = 1;
-
+	if (likely(!sum)) {
+		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE) &&
+		    !skb->csum_complete_sw)
+			netdev_rx_csum_fault(skb->dev);
+	}
 	return sum;
 }
 EXPORT_SYMBOL(__skb_checksum_complete_head);
 
 __sum16 __skb_checksum_complete(struct sk_buff *skb)
 {
-	return __skb_checksum_complete_head(skb, skb->len);
+	__wsum csum;
+	__sum16 sum;
+
+	csum = skb_checksum(skb, 0, skb->len, 0);
+
+	/* skb->csum holds pseudo checksum */
+	sum = csum_fold(csum_add(skb->csum, csum));
+	if (likely(!sum)) {
+		if (unlikely(skb->ip_summed == CHECKSUM_COMPLETE) &&
+		    !skb->csum_complete_sw)
+			netdev_rx_csum_fault(skb->dev);
+	}
+
+	/* Save full packet checksum */
+	skb->csum = csum;
+	skb->ip_summed = CHECKSUM_COMPLETE;
+	skb->csum_complete_sw = 1;
+
+	return sum;
 }
 EXPORT_SYMBOL(__skb_checksum_complete);
 
-- 
2.0.0.526.g5318336
