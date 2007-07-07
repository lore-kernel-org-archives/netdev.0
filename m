From: "Michael Chan" <mchan@broadcom.com>
Subject: [2.6.23 6/9][BNX2]: Reduce spurious INTA interrupts.
Date: Fri, 06 Jul 2007 20:29:59 -0700
Message-ID: <1183778999.5182.23.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3919 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753843AbXGGChp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 22:37:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Reduce spurious INTA interrupts.

Spurious interrupts are often encountered especially on systems
using the 8259 PIC mode.  This is because the I/O write to deassert
the interrupt is posted and won't get to the chip immediately.  As
a result, the IRQ may remain asserted after the IRQ handler exits,
causing spurious interrupts.

Add read back to flush the I/O write to deassert the IRQ immediately.
We also store the last_status_idx immediately in the IRQ handler to
help detect whether the interrupt is ours or not when the IRQ is
entered again before ->poll gets called.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index dc6dcf5..48f5151 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2547,6 +2547,7 @@ bnx2_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
 	struct bnx2 *bp = netdev_priv(dev);
+	struct status_block *sblk = bp->status_blk;
 
 	/* When using INTx, it is possible for the interrupt to arrive
 	 * at the CPU before the status block posted prior to the
@@ -2554,7 +2555,7 @@ bnx2_interrupt(int irq, void *dev_instance)
 	 * When using MSI, the MSI message will always complete after
 	 * the status block write.
 	 */
-	if ((bp->status_blk->status_idx == bp->last_status_idx) &&
+	if ((sblk->status_idx == bp->last_status_idx) &&
 	    (REG_RD(bp, BNX2_PCICFG_MISC_STATUS) &
 	     BNX2_PCICFG_MISC_STATUS_INTA_VALUE))
 		return IRQ_NONE;
@@ -2563,11 +2564,19 @@ bnx2_interrupt(int irq, void *dev_instance)
 		BNX2_PCICFG_INT_ACK_CMD_USE_INT_HC_PARAM |
 		BNX2_PCICFG_INT_ACK_CMD_MASK_INT);
 
+	/* Read back to deassert IRQ immediately to avoid too many
+	 * spurious interrupts.
+	 */
+	REG_RD(bp, BNX2_PCICFG_INT_ACK_CMD);
+
 	/* Return here if interrupt is shared and is disabled. */
 	if (unlikely(atomic_read(&bp->intr_sem) != 0))
 		return IRQ_HANDLED;
 
-	netif_rx_schedule(dev);
+	if (netif_rx_schedule_prep(dev)) {
+		bp->last_status_idx = sblk->status_idx;
+		__netif_rx_schedule(dev);
+	}
 
 	return IRQ_HANDLED;
 }


