From: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
Subject: [PATCH] obsolete config in kernel source (USE_INTERNAL_TIMER)
Date: Fri, 5 Feb 2010 14:22:20 +0100
Message-ID: <20100205132219.GA6874@faui49.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vamos@i4.informatik.uni-erlangen.de
To: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Patrick McHardy <kabe
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:57350 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932309Ab0BENWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2010 08:22:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all!

	As part of the VAMOS[0] research project at the University of
Erlangen we're checking referential integrity between kernel KConfig
options and in-code Conditional blocks.

	USE_INTERNAL_TIMER is another candidate. As can be seen on the
comment of the #undef instruction this part was quite likely never
working and safeguards were added si it is never enabled.

	Please keep me informed of this patch getting confirmed /
merged so we can keep track of it.

Regards

	Christoph Egger

[0] http://vamos1.informatik.uni-erlangen.de/

----
>From f027b61661aaac1fd58536e17894e486d5fb3d3f Mon Sep 17 00:00:00 2001
From: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
Date: Fri, 5 Feb 2010 13:11:16 +0100
Subject: [PATCH] USE_INTERNAL_TIMER explicitely #undef-ed and not in kconfig

CONFIG_USE_INTERNAL_TIMER seems to be the remainings of some
experiment. It is explicitely #undef-ed as not working, only
referenced from one source file and rather aged.

Hereby cleaning it from the kernel tree.

Signed-off-by: Christoph Egger <siccegge@stud.informatik.uni-erlangen.de>
---
 drivers/net/irda/w83977af_ir.c |   36 ------------------------------------
 1 files changed, 0 insertions(+), 36 deletions(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 551810f..980625f 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -65,7 +65,6 @@
 #undef  CONFIG_NETWINDER_TX_DMA_PROBLEMS /* Not needed */
 #define CONFIG_NETWINDER_RX_DMA_PROBLEMS /* Must have this one! */
 #endif
-#undef  CONFIG_USE_INTERNAL_TIMER  /* Just cannot make that timer work */
 #define CONFIG_USE_W977_PNP        /* Currently needed */
 #define PIO_MAX_SPEED       115200 
 
@@ -533,25 +532,6 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 		self->tx_buff.len = skb->len;
 		
 		mtt = irda_get_mtt(skb);
-#ifdef CONFIG_USE_INTERNAL_TIMER
-	        if (mtt > 50) {
-			/* Adjust for timer resolution */
-			mtt /= 1000+1;
-
-			/* Setup timer */
-			switch_bank(iobase, SET4);
-			outb(mtt & 0xff, iobase+TMRL);
-			outb((mtt >> 8) & 0x0f, iobase+TMRH);
-			
-			/* Start timer */
-			outb(IR_MSL_EN_TMR, iobase+IR_MSL);
-			self->io.direction = IO_XMIT;
-			
-			/* Enable timer interrupt */
-			switch_bank(iobase, SET0);
-			outb(ICR_ETMRI, iobase+ICR);
-		} else {
-#endif
 			IRDA_DEBUG(4, "%s(%ld), mtt=%d\n", __func__ , jiffies, mtt);
 			if (mtt)
 				udelay(mtt);
@@ -560,9 +540,6 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 			switch_bank(iobase, SET0);
 	 		outb(ICR_EDMAI, iobase+ICR);
 	     		w83977af_dma_write(self, iobase);
-#ifdef CONFIG_USE_INTERNAL_TIMER
-		}
-#endif
 	} else {
 		self->tx_buff.data = self->tx_buff.head;
 		self->tx_buff.len = async_wrap_skb(skb, self->tx_buff.data, 
@@ -876,20 +853,7 @@ static int w83977af_dma_receive_complete(struct w83977af_ir *self)
 			/* Check if we have transferred all data to memory */
 			switch_bank(iobase, SET0);
 			if (inb(iobase+USR) & USR_RDR) {
-#ifdef CONFIG_USE_INTERNAL_TIMER
-				/* Put this entry back in fifo */
-				st_fifo->head--;
-				st_fifo->len++;
-				st_fifo->entries[st_fifo->head].status = status;
-				st_fifo->entries[st_fifo->head].len = len;
-				
-				/* Restore set register */
-				outb(set, iobase+SSR);
-			
-				return FALSE; 	/* I'll be back! */
-#else
 				udelay(80); /* Should be enough!? */
-#endif
 			}
 						
 			skb = dev_alloc_skb(len+1);
-- 
1.6.3.3


