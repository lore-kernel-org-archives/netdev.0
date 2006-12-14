From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/3][BNX2]: Fix panic in bnx2_tx_int().
Date: Wed, 13 Dec 2006 18:30:33 -0800
Message-ID: <1166063433.30522.5.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: cjk@techma.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2155 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751942AbWLNBr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Dec 2006 20:47:59 -0500
To: davem@davemloft.net, agospoda@redhat.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Fix panic in bnx2_tx_int().

There was an off-by-one bug in bnx2_tx_avail().  If the tx ring is
completely full, the producer and consumer indices may be apart by
256 even though the ring size is only 255.  One entry in the ring is
unused and must be properly accounted for when calculating the number
of available entries.  The bug caused the tx ring entries to be
reused by mistake, overwriting active entries, and ultimately causing
it to crash.

This bug rarely occurs because the tx ring is rarely completely full.
We always stop when there is less than MAX_SKB_FRAGS entries available
in the ring.

Thanks to Corey Kovacs <cjk@techma.com> and Andy Gospodarek
<agospoda@redhat.com> for reporting the problem and helping to collect
debug information.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7d824cf..f296c37 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -217,9 +217,16 @@ static inline u32 bnx2_tx_avail(struct b
 	u32 diff;
 
 	smp_mb();
-	diff = TX_RING_IDX(bp->tx_prod) - TX_RING_IDX(bp->tx_cons);
-	if (diff > MAX_TX_DESC_CNT)
-		diff = (diff & MAX_TX_DESC_CNT) - 1;
+
+	/* The ring uses 256 indices for 255 entries, one of them
+	 * needs to be skipped.
+	 */
+	diff = bp->tx_prod - bp->tx_cons;
+	if (unlikely(diff >= TX_DESC_CNT)) {
+		diff &= 0xffff;
+		if (diff == TX_DESC_CNT)
+			diff = MAX_TX_DESC_CNT;
+	}
 	return (bp->tx_ring_size - diff);
 }
 


