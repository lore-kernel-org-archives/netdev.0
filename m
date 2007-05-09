From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 09/17] sky2: memory barriers change
Date: Tue, 08 May 2007 20:49:58 -0700
Message-ID: <20070509035029.621237655@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:59809 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1033035AbXEIEDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:03:53 -0400
Cc: Greg KH <greg@kroah.com>
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

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 10:29:09.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 10:29:14.000000000 -0700
@@ -836,10 +836,12 @@ static inline struct tx_ring_info *tx_le
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
 
 
@@ -971,6 +973,7 @@ stopped:
 
 	/* reset the Rx prefetch unit */
 	sky2_write32(hw, Y2_QADDR(rxq, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
+	mmiowb();
 }
 
 /* Clean out receive buffer area, assumes receiver hardware stopped */
@@ -1190,7 +1193,7 @@ static int sky2_rx_start(struct sky2_por
 	}
 
 	/* Tell chip about available buffers */
-	sky2_write16(hw, Y2_QADDR(rxq, PREF_UNIT_PUT_IDX), sky2->rx_put);
+	sky2_put_idx(hw, rxq, sky2->rx_put);
 	return 0;
 nomem:
 	sky2_rx_clean(sky2);
@@ -1532,6 +1535,8 @@ static void sky2_tx_complete(struct sky2
 	}
 
 	sky2->tx_cons = idx;
+	smp_mb();
+
 	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
 		netif_wake_queue(dev);
 }
@@ -2210,6 +2215,7 @@ force_update:
 
 	/* Fully processed status ring so clear irq */
 	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
+	mmiowb();
 
 exit_loop:
 	if (buf_write[0]) {
@@ -2436,6 +2442,7 @@ static int sky2_poll(struct net_device *
 	if (work_done < work_limit) {
 		netif_rx_complete(dev0);
 
+		/* end of interrupt, re-enables also acts as I/O synchronization */
 		sky2_read32(hw, B0_Y2_SP_LISR);
 		return 0;
 	} else {

--

