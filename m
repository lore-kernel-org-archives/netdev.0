From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] wan/z8530 deadlocks
Date: Fri, 26 Sep 2003 16:52:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030926165230.7baead12.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Existing code for drivers/net/wan/z8530 is riddled with self-deadlocks
and irq flag confusion.  For example:
	z8530_init -> do_z8530_init -> write_zsreg
self deadlocks on the channel lock.

Several places acquire both the channel and dma lock and then
reuse the same irq flags variable - ouch.

This code at least, correctly probes (for no device case) on SMP.
Other paths verified by inspection.

diff -Nru a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
--- a/drivers/net/wan/z85230.c	Fri Sep 26 16:41:22 2003
+++ b/drivers/net/wan/z85230.c	Fri Sep 26 16:41:22 2003
@@ -150,19 +150,15 @@
  *	Write a value to an indexed register. The caller must hold the lock
  *	to honour the irritating delay rules. We know about register 0
  *	being fast to access.
+ *
+ *      Assumes c->lock is held.
  */
- 
 static inline void write_zsreg(struct z8530_channel *c, u8 reg, u8 val)
 {
-	unsigned long flags;
-
-	spin_lock_irqsave(c->lock, flags);
-
 	if(reg)
 		z8530_write_port(c->ctrlio, reg);
 	z8530_write_port(c->ctrlio, val);
 
-	spin_unlock_irqrestore(c->lock, flags);
 }
 
 /**
@@ -335,6 +331,7 @@
 static void z8530_rx(struct z8530_channel *c)
 {
 	u8 ch,stat;
+	spin_lock(c->lock);
  
 	while(1)
 	{
@@ -393,6 +390,7 @@
 	 */
 	write_zsctrl(c, ERR_RES);
 	write_zsctrl(c, RES_H_IUS);
+	spin_unlock(c->lock);
 }
 
 
@@ -408,6 +406,7 @@
  
 static void z8530_tx(struct z8530_channel *c)
 {
+	spin_lock(c->lock);
 	while(c->txcount) {
 		/* FIFO full ? */
 		if(!(read_zsreg(c, R0)&4))
@@ -435,6 +434,7 @@
 
 	z8530_tx_done(c);	 
 	write_zsctrl(c, RES_H_IUS);
+	spin_unlock(c->lock);
 }
 
 /**
@@ -452,6 +452,7 @@
 {
 	u8 status, altered;
 
+	spin_lock(chan->lock);
 	status=read_zsreg(chan, R0);
 	altered=chan->status^status;
 	
@@ -486,6 +487,7 @@
 	}	
 	write_zsctrl(chan, RES_EXT_INT);
 	write_zsctrl(chan, RES_H_IUS);
+	spin_unlock(chan->lock);
 }
 
 struct z8530_irqhandler z8530_sync=
@@ -509,6 +511,7 @@
  
 static void z8530_dma_rx(struct z8530_channel *chan)
 {
+	spin_lock(chan->lock);
 	if(chan->rxdma_on)
 	{
 		/* Special condition check only */
@@ -531,6 +534,7 @@
 		/* DMA is off right now, drain the slow way */
 		z8530_rx(chan);
 	}	
+	spin_unlock(chan->lock);
 }
 
 /**
@@ -543,6 +547,7 @@
  
 static void z8530_dma_tx(struct z8530_channel *chan)
 {
+	spin_lock(chan->lock);
 	if(!chan->dma_tx)
 	{
 		printk(KERN_WARNING "Hey who turned the DMA off?\n");
@@ -552,6 +557,7 @@
 	/* This shouldnt occur in DMA mode */
 	printk(KERN_ERR "DMA tx - bogus event!\n");
 	z8530_tx(chan);
+	spin_unlock(chan->lock);
 }
 
 /**
@@ -589,6 +595,8 @@
 			z8530_tx_done(chan);
 		}
 	}
+
+	spin_lock(chan->lock);
 	if(altered&chan->dcdcheck)
 	{
 		if(status&chan->dcdcheck)
@@ -607,8 +615,10 @@
 			z8530_flush_fifo(chan);
 		}
 	}	
+
 	write_zsctrl(chan, RES_EXT_INT);
 	write_zsctrl(chan, RES_H_IUS);
+	spin_unlock(chan->lock);
 }
 
 struct z8530_irqhandler z8530_dma_sync=
@@ -868,7 +878,7 @@
  
 int z8530_sync_dma_open(struct net_device *dev, struct z8530_channel *c)
 {
-	unsigned long flags;
+	unsigned long cflags, dflags;
 	
 	c->sync = 1;
 	c->mtu = dev->mtu+64;
@@ -913,7 +923,7 @@
 	 *	Enable DMA control mode
 	 */
 
-	spin_lock_irqsave(c->lock, flags);
+	spin_lock_irqsave(c->lock, cflags);
 	 
 	/*
 	 *	TX DMA via DIR/REQ
@@ -945,7 +955,7 @@
 	 *	Set up the DMA configuration
 	 */	
 	 
-	flags=claim_dma_lock();
+	dflags=claim_dma_lock();
 	 
 	disable_dma(c->rxdma);
 	clear_dma_ff(c->rxdma);
@@ -959,7 +969,7 @@
 	set_dma_mode(c->txdma, DMA_MODE_WRITE);
 	disable_dma(c->txdma);
 	
-	release_dma_lock(flags);
+	release_dma_lock(dflags);
 	
 	/*
 	 *	Select the DMA interrupt handlers
@@ -973,7 +983,7 @@
 	z8530_rtsdtr(c,1);
 	write_zsreg(c, R3, c->regs[R3]|RxENABLE);
 
-	spin_unlock_irqrestore(c->lock, flags);
+	spin_unlock_irqrestore(c->lock, cflags);
 	
 	return 0;
 }
@@ -1062,7 +1072,7 @@
 
 int z8530_sync_txdma_open(struct net_device *dev, struct z8530_channel *c)
 {
-	unsigned long flags;
+	unsigned long cflags, dflags;
 
 	printk("Opening sync interface for TX-DMA\n");
 	c->sync = 1;
@@ -1087,7 +1097,7 @@
 	c->tx_dma_buf[1] = c->tx_dma_buf[0] + PAGE_SIZE/2;
 
 
-	spin_lock_irqsave(c->lock, flags);
+	spin_lock_irqsave(c->lock, cflags);
 
 	/*
 	 *	Load the PIO receive ring
@@ -1125,14 +1135,14 @@
 	 *	Set up the DMA configuration
 	 */	
 	 
-	flags = claim_dma_lock();
+	dflags = claim_dma_lock();
 
 	disable_dma(c->txdma);
 	clear_dma_ff(c->txdma);
 	set_dma_mode(c->txdma, DMA_MODE_WRITE);
 	disable_dma(c->txdma);
 
-	release_dma_lock(flags);
+	release_dma_lock(dflags);
 	
 	/*
 	 *	Select the DMA interrupt handlers
@@ -1145,7 +1155,7 @@
 	c->irqs = &z8530_txdma_sync;
 	z8530_rtsdtr(c,1);
 	write_zsreg(c, R3, c->regs[R3]|RxENABLE);
-	spin_unlock_irqrestore(c->lock, flags);
+	spin_unlock_irqrestore(c->lock, cflags);
 	
 	return 0;
 }
@@ -1163,11 +1173,11 @@
 
 int z8530_sync_txdma_close(struct net_device *dev, struct z8530_channel *c)
 {
-	unsigned long flags;
+	unsigned long dflags, cflags;
 	u8 chk;
 
 	
-	spin_lock_irqsave(c->lock, flags);
+	spin_lock_irqsave(c->lock, cflags);
 	
 	c->irqs = &z8530_nop;
 	c->max = 0;
@@ -1177,14 +1187,14 @@
 	 *	Disable the PC DMA channels
 	 */
 	 
-	flags = claim_dma_lock();
+	dflags = claim_dma_lock();
 
 	disable_dma(c->txdma);
 	clear_dma_ff(c->txdma);
 	c->txdma_on = 0;
 	c->tx_dma_used = 0;
 
-	release_dma_lock(flags);
+	release_dma_lock(dflags);
 
 	/*
 	 *	Disable DMA control mode
@@ -1206,6 +1216,8 @@
 	chk=read_zsreg(c,R0);
 	write_zsreg(c, R3, c->regs[R3]);
 	z8530_rtsdtr(c,0);
+
+	spin_unlock_irqrestore(c->lock, cflags);
 	return 0;
 }
 
@@ -1251,7 +1263,7 @@
  *	Locked operation part of the z8530 init code
  */
  
-static int do_z8530_init(struct z8530_dev *dev)
+static inline int do_z8530_init(struct z8530_dev *dev)
 {
 	/* NOP the interrupt handlers first - we might get a
 	   floating IRQ transition when we reset the chip */
@@ -1259,10 +1271,6 @@
 	dev->chanB.irqs=&z8530_nop;
 	dev->chanA.dcdcheck=DCD;
 	dev->chanB.dcdcheck=DCD;
-
-	/* Set up the chip level lock */
-	dev->chanA.lock = &dev->lock;
-	dev->chanB.lock = &dev->lock;
 
 	/* Reset the chip */
 	write_zsreg(&dev->chanA, R9, 0xC0);
