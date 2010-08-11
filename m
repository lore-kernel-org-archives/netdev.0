From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] Fix deadlock between boomerang_interrupt and
 boomerang_start_tx in 3c59x
Date: Wed, 11 Aug 2010 11:12:57 -0400
Message-ID: <20100811151257.GB23317@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48071 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931Ab0HKPRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 11:17:20 -0400
Received: from cpe-076-182-075-229.nc.res.rr.com ([76.182.75.229] helo=localhost)
	by smtp.tuxdriver.com with esmtpsa (TLSv1:AES128-SHA:128)
	(Exim 4.63)
	(envelope-from <nhorman@tuxdriver.com>)
	id 1OjD3N-0000rB-9P
	for netdev@vger.kernel.org; Wed, 11 Aug 2010 11:17:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If netconsole is in use, there is a possibility for deadlock in 3c59x between
boomerang_interrupt and boomerang_start_xmit.  Both routines take the vp->lock,
and if netconsole is in use, a pr_* call from the boomerang_interrupt routine
will result in the netconsole code attempting to trnasmit an skb, which can try
to take the same spin lock, resulting in deadlock.

The fix is pretty straightforward.  This patch allocats a bit in the 3c59x
private structure to indicate that its handling an interrupt.  If we get into
the transmit routine and that bit is set, we can be sure that we have recursed
and will deadlock if we continue, so instead we just return NETDEV_TX_BUSY, so
the stack requeues the skb to try again later.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
---
 drivers/net/3c59x.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index c754d88..c685a55 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -633,7 +633,8 @@ struct vortex_private {
 		open:1,
 		medialock:1,
 		must_free_region:1,				/* Flag: if zero, Cardbus owns the I/O region */
-		large_frames:1;			/* accept large frames */
+		large_frames:1,			/* accept large frames */
+		handling_irq:1;			/* private in_irq indicator */
 	int drv_flags;
 	u16 status_enable;
 	u16 intr_enable;
@@ -2133,6 +2134,15 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			   dev->name, vp->cur_tx);
 	}
 
+	/*
+	 * We can't allow a recursion from our interrupt handler back into the
+	 * tx routine, as they take the same spin lock, and that causes
+	 * deadlock.  Just return NETDEV_TX_BUSY and let the stack try again in
+	 * a bit
+	 */
+	if (vp->handling_irq)
+		return NETDEV_TX_BUSY;
+
 	if (vp->cur_tx - vp->dirty_tx >= TX_RING_SIZE) {
 		if (vortex_debug > 0)
 			pr_warning("%s: BUG! Tx Ring full, refusing to send buffer.\n",
@@ -2335,11 +2345,13 @@ boomerang_interrupt(int irq, void *dev_id)
 
 	ioaddr = vp->ioaddr;
 
+
 	/*
 	 * It seems dopey to put the spinlock this early, but we could race against vortex_tx_timeout
 	 * and boomerang_start_xmit
 	 */
 	spin_lock(&vp->lock);
+	vp->handling_irq = 1;
 
 	status = ioread16(ioaddr + EL3_STATUS);
 
@@ -2447,6 +2459,7 @@ boomerang_interrupt(int irq, void *dev_id)
 		pr_debug("%s: exiting interrupt, status %4.4x.\n",
 			   dev->name, status);
 handler_exit:
+	vp->handling_irq = 0;
 	spin_unlock(&vp->lock);
 	return IRQ_HANDLED;
 }
