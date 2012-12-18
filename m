From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH] ksz884x: fix receive polling race condition
Date: Tue, 18 Dec 2012 14:57:00 +0100
Message-ID: <20121218135700.GT23447@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Healy <cphealy@gmail.com>
To: Tristram Ha <Tristram.Ha@micrel.com>,
	Xiaotian Feng <dannyfeng@tencent.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:62801 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754843Ab2LRN5G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 08:57:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ksz884x driver does receive processing in a custom tasklet, and
seems to be assuming that since it takes its private interface spinlock
with spin_lock_irq(), it won't be running concurrently with its own
interrupt handler, as it cannot be preempted by it, but since its
interrupt handler doesn't do any locking whatsoever, the receive
processing tasklet and interrupt handler can end up running concurrently
on different CPUs.

As a result of this, the ksz884x receive path ends up locking up fairly
easily, when the receive processing tasklet's reenabling of receive
interrupts (due to it being done with polling the receive ring) races
with the interrupt handler's disabling of receive interrupts (due to a
new receive interrupt coming in) resulting in the receive interrupt
being masked but the receive processing tasklet not being scheduled.

Fix this by making the ksz884x interrupt handler take its private
interface spinlock.  This requires upgrading the spin_lock() in the
transmit cleanup tasklet to a spin_lock_irq(), as otherwise the IRQ
handler can preempt transmit cleanup and deadlock the system, but
with those two changes, no more receive lockups have been observed.

Reported-by: Chris Healy <cphealy@gmail.com>
Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 69e0197..f131962 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4761,7 +4761,7 @@ static void transmit_cleanup(struct dev_info *hw_priv, int normal)
 	struct ksz_dma_buf *dma_buf;
 	struct net_device *dev = NULL;
 
-	spin_lock(&hw_priv->hwlock);
+	spin_lock_irq(&hw_priv->hwlock);
 	last = info->last;
 
 	while (info->avail < info->alloc) {
@@ -4795,7 +4795,7 @@ static void transmit_cleanup(struct dev_info *hw_priv, int normal)
 		info->avail++;
 	}
 	info->last = last;
-	spin_unlock(&hw_priv->hwlock);
+	spin_unlock_irq(&hw_priv->hwlock);
 
 	/* Notify the network subsystem that the packet has been sent. */
 	if (dev)
@@ -5259,11 +5259,15 @@ static irqreturn_t netdev_intr(int irq, void *dev_id)
 	struct dev_info *hw_priv = priv->adapter;
 	struct ksz_hw *hw = &hw_priv->hw;
 
+	spin_lock(&hw_priv->hwlock);
+
 	hw_read_intr(hw, &int_enable);
 
 	/* Not our interrupt! */
-	if (!int_enable)
+	if (!int_enable) {
+		spin_unlock(&hw_priv->hwlock);
 		return IRQ_NONE;
+	}
 
 	do {
 		hw_ack_intr(hw, int_enable);
@@ -5310,6 +5314,8 @@ static irqreturn_t netdev_intr(int irq, void *dev_id)
 
 	hw_ena_intr(hw);
 
+	spin_unlock(&hw_priv->hwlock);
+
 	return IRQ_HANDLED;
 }
 
----
