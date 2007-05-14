From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 6/6] sky2: memory barriers change
Date: Mon, 14 May 2007 12:38:15 -0700
Message-ID: <20070514193945.951381977@linux-foundation.org>
References: <20070514193809.867470364@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:40564 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754546AbXENTmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 15:42:49 -0400
Content-Disposition: inline; filename=sky2-more-mb.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do some memory barrier changes for safety/perfomance:
Don't need read after update to index, mmiowb() followed by read at end
of irq is sufficient.

Signed-off-by: Stephn Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

--- 2.6.21-rc1.orig/drivers/net/sky2.c	2007-05-14 12:10:22.000000000 -0700
+++ 2.6.21-rc1/drivers/net/sky2.c	2007-05-14 12:10:24.000000000 -0700
@@ -844,10 +844,12 @@ static inline struct tx_ring_info *tx_le
 /* Update chip's next pointer */
 static inline void sky2_put_idx(struct sky2_hw *hw, unsigned q, u16 idx)
 {
-	q = Y2_QADDR(q, PREF_UNIT_PUT_IDX);
+	/* Make sure write' to descriptors are complete before we tell hardware */
 	wmb();
-	sky2_write16(hw, q, idx);
-	sky2_read16(hw, q);
+	sky2_write16(hw, Y2_QADDR(q, PREF_UNIT_PUT_IDX), idx);
+
+	/* Synchronize I/O on since next processor may write to tail */
+	mmiowb();
 }
 
 
@@ -979,6 +981,7 @@ stopped:
 
 	/* reset the Rx prefetch unit */
 	sky2_write32(hw, Y2_QADDR(rxq, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
+	mmiowb();
 }
 
 /* Clean out receive buffer area, assumes receiver hardware stopped */
@@ -1198,7 +1201,7 @@ static int sky2_rx_start(struct sky2_por
 	}
 
 	/* Tell chip about available buffers */
-	sky2_write16(hw, Y2_QADDR(rxq, PREF_UNIT_PUT_IDX), sky2->rx_put);
+	sky2_put_idx(hw, rxq, sky2->rx_put);
 	return 0;
 nomem:
 	sky2_rx_clean(sky2);
@@ -1540,6 +1543,8 @@ static void sky2_tx_complete(struct sky2
 	}
 
 	sky2->tx_cons = idx;
+	smp_mb();
+
 	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
 		netif_wake_queue(dev);
 }
@@ -2218,6 +2223,7 @@ force_update:
 
 	/* Fully processed status ring so clear irq */
 	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
+	mmiowb();
 
 exit_loop:
 	if (buf_write[0]) {
@@ -2442,6 +2448,7 @@ static int sky2_poll(struct net_device *
 	if (work_done < work_limit) {
 		netif_rx_complete(dev0);
 
+		/* end of interrupt, re-enables also acts as I/O synchronization */
 		sky2_read32(hw, B0_Y2_SP_LISR);
 		return 0;
 	} else {

--
Stephen Hemminger <shemminger@linux-foundation.org>

