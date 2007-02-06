From: akpm@linux-foundation.org
Subject: [patch 04/11] z85230: spinlock logic
Date: Mon, 05 Feb 2007 16:31:03 -0800
Message-ID: <200702060032.l160W75a004627@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, jeff@garzik.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:41474 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965147AbXBFAcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 19:32:20 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan@lxorguk.ukuu.org.uk>

At some point someone added a spin_lock(&dev->lock) to the IRQ handler for
the Z85230 driver.  This actually correctly fixes a bug but the necessary
changes to remove the chan->lock calls in the event handlers were not made
(c->lock is the same lock).

Simona Dascenzo reported the problem with the driver and this patch should
fix the problem he found.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/wan/z85230.c |   14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

diff -puN drivers/net/wan/z85230.c~z85230-spinlock-logic drivers/net/wan/z85230.c
--- a/drivers/net/wan/z85230.c~z85230-spinlock-logic
+++ a/drivers/net/wan/z85230.c
@@ -331,8 +331,7 @@ static void z8530_rtsdtr(struct z8530_ch
 static void z8530_rx(struct z8530_channel *c)
 {
 	u8 ch,stat;
-	spin_lock(c->lock);
- 
+
 	while(1)
 	{
 		/* FIFO empty ? */
@@ -390,7 +389,6 @@ static void z8530_rx(struct z8530_channe
 	 */
 	write_zsctrl(c, ERR_RES);
 	write_zsctrl(c, RES_H_IUS);
-	spin_unlock(c->lock);
 }
 
 
@@ -406,7 +404,6 @@ static void z8530_rx(struct z8530_channe
  
 static void z8530_tx(struct z8530_channel *c)
 {
-	spin_lock(c->lock);
 	while(c->txcount) {
 		/* FIFO full ? */
 		if(!(read_zsreg(c, R0)&4))
@@ -434,7 +431,6 @@ static void z8530_tx(struct z8530_channe
 
 	z8530_tx_done(c);	 
 	write_zsctrl(c, RES_H_IUS);
-	spin_unlock(c->lock);
 }
 
 /**
@@ -452,7 +448,6 @@ static void z8530_status(struct z8530_ch
 {
 	u8 status, altered;
 
-	spin_lock(chan->lock);
 	status=read_zsreg(chan, R0);
 	altered=chan->status^status;
 	
@@ -487,7 +482,6 @@ static void z8530_status(struct z8530_ch
 	}	
 	write_zsctrl(chan, RES_EXT_INT);
 	write_zsctrl(chan, RES_H_IUS);
-	spin_unlock(chan->lock);
 }
 
 struct z8530_irqhandler z8530_sync=
@@ -511,7 +505,6 @@ EXPORT_SYMBOL(z8530_sync);
  
 static void z8530_dma_rx(struct z8530_channel *chan)
 {
-	spin_lock(chan->lock);
 	if(chan->rxdma_on)
 	{
 		/* Special condition check only */
@@ -534,7 +527,6 @@ static void z8530_dma_rx(struct z8530_ch
 		/* DMA is off right now, drain the slow way */
 		z8530_rx(chan);
 	}	
-	spin_unlock(chan->lock);
 }
 
 /**
@@ -547,7 +539,6 @@ static void z8530_dma_rx(struct z8530_ch
  
 static void z8530_dma_tx(struct z8530_channel *chan)
 {
-	spin_lock(chan->lock);
 	if(!chan->dma_tx)
 	{
 		printk(KERN_WARNING "Hey who turned the DMA off?\n");
@@ -557,7 +548,6 @@ static void z8530_dma_tx(struct z8530_ch
 	/* This shouldnt occur in DMA mode */
 	printk(KERN_ERR "DMA tx - bogus event!\n");
 	z8530_tx(chan);
-	spin_unlock(chan->lock);
 }
 
 /**
@@ -596,7 +586,6 @@ static void z8530_dma_status(struct z853
 		}
 	}
 
-	spin_lock(chan->lock);
 	if(altered&chan->dcdcheck)
 	{
 		if(status&chan->dcdcheck)
@@ -618,7 +607,6 @@ static void z8530_dma_status(struct z853
 
 	write_zsctrl(chan, RES_EXT_INT);
 	write_zsctrl(chan, RES_H_IUS);
-	spin_unlock(chan->lock);
 }
 
 struct z8530_irqhandler z8530_dma_sync=
_
