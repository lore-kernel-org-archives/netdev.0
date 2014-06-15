From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 2/5] net: Fix save software checksum complete
Date: Sat, 14 Jun 2014 23:24:03 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406142315001.17124@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: geert@linux-m68k.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:51941 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752162AbaFOGYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 02:24:05 -0400
Received: by mail-oa0-f73.google.com with SMTP id eb12so826372oac.2
        for <netdev@vger.kernel.org>; Sat, 14 Jun 2014 23:24:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geert reported issues regarding checksum complete and UDP.
The logic introduced in commit 7e3cead5172927732f51fde
("net: Save software checksum complete") is not correct.

This patch:
1) Restores code in __skb_checksum_complete_header except for setting
   CHECKSUM_UNNECESSARY. This function may be calculating checksum on
   something less than skb->len.
2) Adds saving checksum to __skb_checksum_complete. The full packet
   checksum 0..skb->len is calculated without adding in pseudo header.
   This value is saved in skb->csum and then the pseudo header is added
   to that to derive the checksum for validation.
3) In both __skb_checksum_complete_header and __skb_checksum_complete,
   set skb->csum_valid to whether checksum of zero was computed. This
   allows skb_csum_unnecessary to return true without changing to
   CHECKSUM_UNNECESSARY which was done previously.
4) Copy new csum related bits in __copy_skb_header.

Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/datagram.c | 36 ++++++++++++++++++++++++++----------
 net/core/skbuff.c   |  3 +++
 2 files changed, 29 insertions(+), 10 deletions(-)

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 6b1c04c..488dd1a 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -739,22 +739,38 @@ __sum16 __skb_checksum_complete_head(struct sk_buff *skb, int len)
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
+	skb->csum_valid = !sum;
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
+	skb->csum_valid = !sum;
+
+	return sum;
 }
 EXPORT_SYMBOL(__skb_checksum_complete);
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index bf92824..9cd5344 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -689,6 +689,9 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->ooo_okay		= old->ooo_okay;
 	new->no_fcs		= old->no_fcs;
 	new->encapsulation	= old->encapsulation;
+	new->encap_hdr_csum	= old->encap_hdr_csum;
+	new->csum_valid		= old->csum_valid;
+	new->csum_complete_sw	= old->csum_complete_sw;
 #ifdef CONFIG_XFRM
 	new->sp			= secpath_get(old->sp);
 #endif
-- 
2.0.0.526.g5318336
