From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH v3 1/3] net: irda: pxaficp_ir: use sched_clock() for time management
Date: Sat, 26 Sep 2015 20:49:18 +0200
Message-ID: <1443293360-16377-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Robert Jarzmik <robert.jarzmik@free.fr>
To: Samuel Ortiz <samuel@sortiz.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp09.smtpout.orange.fr ([80.12.242.131]:40692 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472AbbIZSyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 14:54:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of using directly the OS timer through direct register access,
use the standard sched_clock(), which will end up in OSCR reading
anyway.

This is a first step for direct access register removal and machine
specific code removal from this driver.

This commit changes the behavior, as previously the minimum turnaround
time was counted in 76ns steps, while with this patch it is counted in
microsecond steps. The strictly equal formula would have been :
	    while ((sched_clock() - si->last_clk) * 76 < mtt)

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
---
Since v2: fixed clock calculation as pointed out by David
---
 drivers/net/irda/pxaficp_ir.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 100454662e4b..6a81d3d1b312 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -29,7 +29,6 @@
 
 #include <mach/dma.h>
 #include <linux/platform_data/irda-pxaficp.h>
-#include <mach/regs-ost.h>
 #include <mach/regs-uart.h>
 
 #define FICP		__REG(0x40800000)  /* Start of FICP area */
@@ -102,7 +101,7 @@
 struct pxa_irda {
 	int			speed;
 	int			newspeed;
-	unsigned long		last_oscr;
+	unsigned long long	last_clk;
 
 	unsigned char		*dma_rx_buff;
 	unsigned char		*dma_tx_buff;
@@ -292,7 +291,7 @@ static irqreturn_t pxa_irda_sir_irq(int irq, void *dev_id)
 			}
 			lsr = STLSR;
 		}
-		si->last_oscr = readl_relaxed(OSCR);
+		si->last_clk = sched_clock();
 		break;
 
 	case 0x04: /* Received Data Available */
@@ -303,7 +302,7 @@ static irqreturn_t pxa_irda_sir_irq(int irq, void *dev_id)
 		    dev->stats.rx_bytes++;
 	            async_unwrap_char(dev, &dev->stats, &si->rx_buff, STRBR);
 	  	} while (STLSR & LSR_DR);
-		si->last_oscr = readl_relaxed(OSCR);
+		si->last_clk = sched_clock();
 	  	break;
 
 	case 0x02: /* Transmit FIFO Data Request */
@@ -319,7 +318,7 @@ static irqreturn_t pxa_irda_sir_irq(int irq, void *dev_id)
                         /* We need to ensure that the transmitter has finished. */
 			while ((STLSR & LSR_TEMT) == 0)
 				cpu_relax();
-			si->last_oscr = readl_relaxed(OSCR);
+			si->last_clk = sched_clock();
 
 			/*
 		 	* Ok, we've finished transmitting.  Now enable
@@ -373,7 +372,7 @@ static void pxa_irda_fir_dma_tx_irq(int channel, void *data)
 
 	while (ICSR1 & ICSR1_TBY)
 		cpu_relax();
-	si->last_oscr = readl_relaxed(OSCR);
+	si->last_clk = sched_clock();
 
 	/*
 	 * HACK: It looks like the TBY bit is dropped too soon.
@@ -473,8 +472,8 @@ static irqreturn_t pxa_irda_fir_irq(int irq, void *dev_id)
 
 	/* stop RX DMA */
 	DCSR(si->rxdma) &= ~DCSR_RUN;
-	si->last_oscr = readl_relaxed(OSCR);
 	icsr0 = ICSR0;
+	si->last_clk = sched_clock();
 
 	if (icsr0 & (ICSR0_FRE | ICSR0_RAB)) {
 		if (icsr0 & ICSR0_FRE) {
@@ -549,7 +548,7 @@ static int pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 		skb_copy_from_linear_data(skb, si->dma_tx_buff, skb->len);
 
 		if (mtt)
-			while ((unsigned)(readl_relaxed(OSCR) - si->last_oscr)/4 < mtt)
+			while ((sched_clock() - si->last_clk) * 1000 < mtt)
 				cpu_relax();
 
 		/* stop RX DMA,  disable FICP */
-- 
2.1.4
