From: Paul Bolle <pebolle@tiscali.nl>
Subject: [PATCH] w83977af_ir: remove two faux Kconfig macros
Date: Sun, 04 May 2014 13:03:12 +0200
Message-ID: <1399201392.8729.7.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpsmtpb-ews07.kpnxchange.com ([213.75.39.10]:55775 "EHLO
	cpsmtpb-ews07.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753553AbaEDLDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 07:03:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ever since v2.3.5 the driver for "Winbond W83977AF (IR)" contains two
unneeded preprocessor macros.

CONFIG_NETWINDER_TX_DMA_PROBLEMS is never defined and can safely be
removed. And CONFIG_NETWINDER_RX_DMA_PROBLEMS is just an alias for
CONFIG_ARCH_NETWINDER, so that (valid) Kconfig macro can be used
instead.

Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
---
Compile tested only (on x86_64, that is).

I sneaked in a related whitespace fix.

 drivers/net/irda/w83977af_ir.c | 33 ++++-----------------------------
 1 file changed, 4 insertions(+), 29 deletions(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index e641bb240362..11dbdf36d9c1 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -62,10 +62,6 @@
 #include "w83977af.h"
 #include "w83977af_ir.h"
 
-#ifdef  CONFIG_ARCH_NETWINDER            /* Adjust to NetWinder differences */
-#undef  CONFIG_NETWINDER_TX_DMA_PROBLEMS /* Not needed */
-#define CONFIG_NETWINDER_RX_DMA_PROBLEMS /* Must have this one! */
-#endif
 #define CONFIG_USE_W977_PNP        /* Currently needed */
 #define PIO_MAX_SPEED       115200 
 
@@ -332,7 +328,7 @@ static int w83977af_probe(int iobase, int irq, int dma)
  		w977_write_reg(0x74, dma+1, efbase[i]);
 #else
  		w977_write_reg(0x74, dma, efbase[i]);   
-#endif /*CONFIG_ARCH_NETWINDER */
+#endif /* CONFIG_ARCH_NETWINDER */
  		w977_write_reg(0x75, 0x04, efbase[i]);  /* Disable Tx DMA */
   	
  		/* Set append hardware CRC, enable IR bank selection */	
@@ -563,10 +559,6 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 static void w83977af_dma_write(struct w83977af_ir *self, int iobase)
 {
 	__u8 set;
-#ifdef CONFIG_NETWINDER_TX_DMA_PROBLEMS
-	unsigned long flags;
-	__u8 hcr;
-#endif
         IRDA_DEBUG(4, "%s(), len=%d\n", __func__ , self->tx_buff.len);
 
 	/* Save current set */
@@ -579,30 +571,13 @@ static void w83977af_dma_write(struct w83977af_ir *self, int iobase)
 	/* Choose transmit DMA channel  */ 
 	switch_bank(iobase, SET2);
 	outb(ADCR1_D_CHSW|/*ADCR1_DMA_F|*/ADCR1_ADV_SL, iobase+ADCR1);
-#ifdef CONFIG_NETWINDER_TX_DMA_PROBLEMS
-	spin_lock_irqsave(&self->lock, flags);
-
-	disable_dma(self->io.dma);
-	clear_dma_ff(self->io.dma);
-	set_dma_mode(self->io.dma, DMA_MODE_READ);
-	set_dma_addr(self->io.dma, self->tx_buff_dma);
-	set_dma_count(self->io.dma, self->tx_buff.len);
-#else
 	irda_setup_dma(self->io.dma, self->tx_buff_dma, self->tx_buff.len,
 		       DMA_MODE_WRITE);	
-#endif
 	self->io.direction = IO_XMIT;
 	
 	/* Enable DMA */
  	switch_bank(iobase, SET0);
-#ifdef CONFIG_NETWINDER_TX_DMA_PROBLEMS
-	hcr = inb(iobase+HCR);
-	outb(hcr | HCR_EN_DMA, iobase+HCR);
-	enable_dma(self->io.dma);
-	spin_unlock_irqrestore(&self->lock, flags);
-#else	
 	outb(inb(iobase+HCR) | HCR_EN_DMA | HCR_TX_WT, iobase+HCR);
-#endif
 
 	/* Restore set register */
 	outb(set, iobase+SSR);
@@ -711,7 +686,7 @@ static int w83977af_dma_receive(struct w83977af_ir *self)
 {
 	int iobase;
 	__u8 set;
-#ifdef CONFIG_NETWINDER_RX_DMA_PROBLEMS
+#ifdef CONFIG_ARCH_NETWINDER
 	unsigned long flags;
 	__u8 hcr;
 #endif
@@ -736,7 +711,7 @@ static int w83977af_dma_receive(struct w83977af_ir *self)
 	self->io.direction = IO_RECV;
 	self->rx_buff.data = self->rx_buff.head;
 
-#ifdef CONFIG_NETWINDER_RX_DMA_PROBLEMS
+#ifdef CONFIG_ARCH_NETWINDER
 	spin_lock_irqsave(&self->lock, flags);
 
 	disable_dma(self->io.dma);
@@ -759,7 +734,7 @@ static int w83977af_dma_receive(struct w83977af_ir *self)
 	
 	/* Enable DMA */
 	switch_bank(iobase, SET0);
-#ifdef CONFIG_NETWINDER_RX_DMA_PROBLEMS
+#ifdef CONFIG_ARCH_NETWINDER
 	hcr = inb(iobase+HCR);
 	outb(hcr | HCR_EN_DMA, iobase+HCR);
 	enable_dma(self->io.dma);
-- 
1.9.0
