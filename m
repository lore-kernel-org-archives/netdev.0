From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH] macmace: disable only the dma interrupt
Date: Sun, 11 Sep 2011 01:02:16 +1000 (EST)
Message-ID: <alpine.LNX.2.00.1109110042210.5327@nippy.intranet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't disable all interrupts, just disable the relevant one.

Also move a couple of printk calls outside of local_irq_save/restore.

Tested on a Quadra 660av.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

Index: linux-m68k/drivers/net/macmace.c
===================================================================
--- linux-m68k.orig/drivers/net/macmace.c	2011-08-28 00:33:33.000000000 +1000
+++ linux-m68k/drivers/net/macmace.c	2011-08-28 00:36:10.000000000 +1000
@@ -458,8 +458,9 @@ static int mace_xmit_start(struct sk_buf
 	local_irq_save(flags);
 	netif_stop_queue(dev);
 	if (!mp->tx_count) {
-		printk(KERN_ERR "macmace: tx queue running but no free buffers.\n");
 		local_irq_restore(flags);
+		printk(KERN_ERR
+		       "macmace: tx queue running but no free buffers.\n");
 		return NETDEV_TX_BUSY;
 	}
 	mp->tx_count--;
@@ -563,10 +564,8 @@ static irqreturn_t mace_interrupt(int ir
 	struct mace_data *mp = netdev_priv(dev);
 	volatile struct mace *mb = mp->mace;
 	int intr, fs;
-	unsigned long flags;
 
-	/* don't want the dma interrupt handler to fire */
-	local_irq_save(flags);
+	disable_irq(mp->dma_intr);
 
 	intr = mb->ir; /* read interrupt register */
 	mace_handle_misc_intrs(dev, intr);
@@ -604,7 +603,7 @@ static irqreturn_t mace_interrupt(int ir
 	if (mp->tx_count)
 		netif_wake_queue(dev);
 
-	local_irq_restore(flags);
+	enable_irq(mp->dma_intr);
 
 	return IRQ_HANDLED;
 }
@@ -615,11 +614,12 @@ static void mace_tx_timeout(struct net_d
 	volatile struct mace *mb = mp->mace;
 	unsigned long flags;
 
+	printk(KERN_ERR "macmace: transmit timeout - resetting\n");
+
 	local_irq_save(flags);
 
 	/* turn off both tx and rx and reset the chip */
 	mb->maccc = 0;
-	printk(KERN_ERR "macmace: transmit timeout - resetting\n");
 	mace_txdma_reset(dev);
 	mace_reset(dev);
 
