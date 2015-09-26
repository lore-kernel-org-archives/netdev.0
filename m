From: Robert Jarzmik <robert.jarzmik@free.fr>
Subject: [PATCH v3 3/3] net: irda: pxaficp_ir: dmaengine conversion
Date: Sat, 26 Sep 2015 20:49:20 +0200
Message-ID: <1443293360-16377-3-git-send-email-robert.jarzmik@free.fr>
References: <1443293360-16377-1-git-send-email-robert.jarzmik@free.fr>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Robert Jarzmik <robert.jarzmik@free.fr>
To: Samuel Ortiz <samuel@sortiz.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp09.smtpout.orange.fr ([80.12.242.131]:38941 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbbIZSyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 14:54:36 -0400
In-Reply-To: <1443293360-16377-1-git-send-email-robert.jarzmik@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert pxaficp_ir to dmaengine. As pxa architecture is shifting from
raw DMA registers access to pxa_dma dmaengine driver, convert this
driver to dmaengine.

Signed-off-by: Robert Jarzmik <robert.jarzmik@free.fr>
Tested-by: Petr Cvek <petr.cvek@tul.cz>
---
Since v1: removed mach/dma.h include, which is the goal
---
 drivers/net/irda/pxaficp_ir.c | 149 +++++++++++++++++++++++++++++-------------
 1 file changed, 102 insertions(+), 47 deletions(-)

diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 05a668216a0f..6e8f616be48e 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -19,6 +19,9 @@
 #include <linux/etherdevice.h>
 #include <linux/platform_device.h>
 #include <linux/clk.h>
+#include <linux/dmaengine.h>
+#include <linux/dma-mapping.h>
+#include <linux/dma/pxa-dma.h>
 #include <linux/gpio.h>
 #include <linux/slab.h>
 
@@ -27,7 +30,6 @@
 #include <net/irda/wrapper.h>
 #include <net/irda/irda_device.h>
 
-#include <mach/dma.h>
 #include <linux/platform_data/irda-pxaficp.h>
 #undef __REG
 #define __REG(x) ((x) & 0xffff)
@@ -146,8 +148,12 @@ struct pxa_irda {
 	dma_addr_t		dma_rx_buff_phy;
 	dma_addr_t		dma_tx_buff_phy;
 	unsigned int		dma_tx_buff_len;
-	int			txdma;
-	int			rxdma;
+	struct dma_chan		*txdma;
+	struct dma_chan		*rxdma;
+	dma_cookie_t		rx_cookie;
+	dma_cookie_t		tx_cookie;
+	int			drcmr_rx;
+	int			drcmr_tx;
 
 	int			uart_irq;
 	int			icp_irq;
@@ -165,6 +171,8 @@ struct pxa_irda {
 	struct clk		*cur_clk;
 };
 
+static int pxa_irda_set_speed(struct pxa_irda *si, int speed);
+
 static inline void pxa_irda_disable_clk(struct pxa_irda *si)
 {
 	if (si->cur_clk)
@@ -188,22 +196,41 @@ static inline void pxa_irda_enable_sirclk(struct pxa_irda *si)
 #define IS_FIR(si)		((si)->speed >= 4000000)
 #define IRDA_FRAME_SIZE_LIMIT	2047
 
+static void pxa_irda_fir_dma_rx_irq(void *data);
+static void pxa_irda_fir_dma_tx_irq(void *data);
+
 inline static void pxa_irda_fir_dma_rx_start(struct pxa_irda *si)
 {
-	DCSR(si->rxdma)  = DCSR_NODESC;
-	DSADR(si->rxdma) = (unsigned long)si->irda_base + ICDR;
-	DTADR(si->rxdma) = si->dma_rx_buff_phy;
-	DCMD(si->rxdma) = DCMD_INCTRGADDR | DCMD_FLOWSRC |  DCMD_WIDTH1 | DCMD_BURST32 | IRDA_FRAME_SIZE_LIMIT;
-	DCSR(si->rxdma) |= DCSR_RUN;
+	struct dma_async_tx_descriptor *tx;
+
+	tx = dmaengine_prep_slave_single(si->rxdma, si->dma_rx_buff_phy,
+					 IRDA_FRAME_SIZE_LIMIT, DMA_FROM_DEVICE,
+					 DMA_PREP_INTERRUPT);
+	if (!tx) {
+		dev_err(si->dev, "prep_slave_sg() failed\n");
+		return;
+	}
+	tx->callback = pxa_irda_fir_dma_rx_irq;
+	tx->callback_param = si;
+	si->rx_cookie = dmaengine_submit(tx);
+	dma_async_issue_pending(si->rxdma);
 }
 
 inline static void pxa_irda_fir_dma_tx_start(struct pxa_irda *si)
 {
-	DCSR(si->txdma)  = DCSR_NODESC;
-	DSADR(si->txdma) = si->dma_tx_buff_phy;
-	DTADR(si->txdma) = (unsigned long)si->irda_base + ICDR;
-	DCMD(si->txdma) = DCMD_INCSRCADDR | DCMD_FLOWTRG |  DCMD_ENDIRQEN | DCMD_WIDTH1 | DCMD_BURST32 | si->dma_tx_buff_len;
-	DCSR(si->txdma) |= DCSR_RUN;
+	struct dma_async_tx_descriptor *tx;
+
+	tx = dmaengine_prep_slave_single(si->txdma, si->dma_tx_buff_phy,
+					 si->dma_tx_buff_len, DMA_TO_DEVICE,
+					 DMA_PREP_INTERRUPT);
+	if (!tx) {
+		dev_err(si->dev, "prep_slave_sg() failed\n");
+		return;
+	}
+	tx->callback = pxa_irda_fir_dma_tx_irq;
+	tx->callback_param = si;
+	si->tx_cookie = dmaengine_submit(tx);
+	dma_async_issue_pending(si->rxdma);
 }
 
 /*
@@ -242,7 +269,7 @@ static int pxa_irda_set_speed(struct pxa_irda *si, int speed)
 
 		if (IS_FIR(si)) {
 			/* stop RX DMA */
-			DCSR(si->rxdma) &= ~DCSR_RUN;
+			dmaengine_terminate_all(si->rxdma);
 			/* disable FICP */
 			ficp_writel(si, 0, ICCR0);
 			pxa_irda_disable_clk(si);
@@ -388,30 +415,27 @@ static irqreturn_t pxa_irda_sir_irq(int irq, void *dev_id)
 }
 
 /* FIR Receive DMA interrupt handler */
-static void pxa_irda_fir_dma_rx_irq(int channel, void *data)
+static void pxa_irda_fir_dma_rx_irq(void *data)
 {
-	int dcsr = DCSR(channel);
-
-	DCSR(channel) = dcsr & ~DCSR_RUN;
+	struct net_device *dev = data;
+	struct pxa_irda *si = netdev_priv(dev);
 
-	printk(KERN_DEBUG "pxa_ir: fir rx dma bus error %#x\n", dcsr);
+	dmaengine_terminate_all(si->rxdma);
+	netdev_dbg(dev, "pxa_ir: fir rx dma bus error\n");
 }
 
 /* FIR Transmit DMA interrupt handler */
-static void pxa_irda_fir_dma_tx_irq(int channel, void *data)
+static void pxa_irda_fir_dma_tx_irq(void *data)
 {
 	struct net_device *dev = data;
 	struct pxa_irda *si = netdev_priv(dev);
-	int dcsr;
-
-	dcsr = DCSR(channel);
-	DCSR(channel) = dcsr & ~DCSR_RUN;
 
-	if (dcsr & DCSR_ENDINTR)  {
+	dmaengine_terminate_all(si->txdma);
+	if (dmaengine_tx_status(si->txdma, si->tx_cookie, NULL) == DMA_ERROR) {
+		dev->stats.tx_errors++;
+	} else {
 		dev->stats.tx_packets++;
 		dev->stats.tx_bytes += si->dma_tx_buff_len;
-	} else {
-		dev->stats.tx_errors++;
 	}
 
 	while (ficp_readl(si, ICSR1) & ICSR1_TBY)
@@ -446,9 +470,12 @@ static void pxa_irda_fir_dma_tx_irq(int channel, void *data)
 static void pxa_irda_fir_irq_eif(struct pxa_irda *si, struct net_device *dev, int icsr0)
 {
 	unsigned int len, stat, data;
+	struct dma_tx_state state;
 
 	/* Get the current data position. */
-	len = DTADR(si->rxdma) - si->dma_rx_buff_phy;
+
+	dmaengine_tx_status(si->rxdma, si->rx_cookie, &state);
+	len = IRDA_FRAME_SIZE_LIMIT - state.residue;
 
 	do {
 		/* Read Status, and then Data. 	 */
@@ -515,7 +542,7 @@ static irqreturn_t pxa_irda_fir_irq(int irq, void *dev_id)
 	int icsr0, i = 64;
 
 	/* stop RX DMA */
-	DCSR(si->rxdma) &= ~DCSR_RUN;
+	dmaengine_terminate_all(si->rxdma);
 	si->last_clk = sched_clock();
 	icsr0 = ficp_readl(si, ICSR0);
 
@@ -597,7 +624,7 @@ static int pxa_irda_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 				cpu_relax();
 
 		/* stop RX DMA,  disable FICP */
-		DCSR(si->rxdma) &= ~DCSR_RUN;
+		dmaengine_terminate_all(si->rxdma);
 		ficp_writel(si, 0, ICCR0);
 
 		pxa_irda_fir_dma_tx_start(si);
@@ -670,10 +697,6 @@ static void pxa_irda_startup(struct pxa_irda *si)
 	/* configure FICP ICCR2 */
 	ficp_writel(si, ICCR2_TXP | ICCR2_TRIG_32, ICCR2);
 
-	/* configure DMAC */
-	DRCMR(17) = si->rxdma | DRCMR_MAPVLD;
-	DRCMR(18) = si->txdma | DRCMR_MAPVLD;
-
 	/* force SIR reinitialization */
 	si->speed = 4000000;
 	pxa_irda_set_speed(si, 9600);
@@ -693,17 +716,14 @@ static void pxa_irda_shutdown(struct pxa_irda *si)
 	stuart_writel(si, 0, STISR);
 
 	/* disable DMA */
-	DCSR(si->txdma) &= ~DCSR_RUN;
-	DCSR(si->rxdma) &= ~DCSR_RUN;
+	dmaengine_terminate_all(si->rxdma);
+	dmaengine_terminate_all(si->txdma);
 	/* disable FICP */
 	ficp_writel(si, 0, ICCR0);
 
 	/* disable the STUART or FICP clocks */
 	pxa_irda_disable_clk(si);
 
-	DRCMR(17) = 0;
-	DRCMR(18) = 0;
-
 	local_irq_restore(flags);
 
 	/* power off board transceiver */
@@ -715,6 +735,9 @@ static void pxa_irda_shutdown(struct pxa_irda *si)
 static int pxa_irda_start(struct net_device *dev)
 {
 	struct pxa_irda *si = netdev_priv(dev);
+	dma_cap_mask_t mask;
+	struct dma_slave_config	config;
+	struct pxad_param param;
 	int err;
 
 	si->speed = 9600;
@@ -734,14 +757,37 @@ static int pxa_irda_start(struct net_device *dev)
 	disable_irq(si->icp_irq);
 
 	err = -EBUSY;
-	si->rxdma = pxa_request_dma("FICP_RX",DMA_PRIO_LOW, pxa_irda_fir_dma_rx_irq, dev);
-	if (si->rxdma < 0)
+	dma_cap_zero(mask);
+	dma_cap_set(DMA_SLAVE, mask);
+	param.prio = PXAD_PRIO_LOWEST;
+
+	memset(&config, 0, sizeof(config));
+	config.src_addr_width = DMA_SLAVE_BUSWIDTH_1_BYTE;
+	config.dst_addr_width = DMA_SLAVE_BUSWIDTH_1_BYTE;
+	config.src_addr = (dma_addr_t)si->irda_base + ICDR;
+	config.dst_addr = (dma_addr_t)si->irda_base + ICDR;
+	config.src_maxburst = 32;
+	config.dst_maxburst = 32;
+
+	param.drcmr = si->drcmr_rx;
+	si->rxdma = dma_request_slave_channel_compat(mask, pxad_filter_fn,
+						     &param, &dev->dev, "rx");
+	if (!si->rxdma)
 		goto err_rx_dma;
 
-	si->txdma = pxa_request_dma("FICP_TX",DMA_PRIO_LOW, pxa_irda_fir_dma_tx_irq, dev);
-	if (si->txdma < 0)
+	param.drcmr = si->drcmr_tx;
+	si->txdma = dma_request_slave_channel_compat(mask, pxad_filter_fn,
+						     &param, &dev->dev, "tx");
+	if (!si->txdma)
 		goto err_tx_dma;
 
+	err = dmaengine_slave_config(si->rxdma, &config);
+	if (err)
+		goto err_dma_rx_buff;
+	err = dmaengine_slave_config(si->txdma, &config);
+	if (err)
+		goto err_dma_rx_buff;
+
 	err = -ENOMEM;
 	si->dma_rx_buff = dma_alloc_coherent(si->dev, IRDA_FRAME_SIZE_LIMIT,
 					     &si->dma_rx_buff_phy, GFP_KERNEL);
@@ -781,9 +827,9 @@ err_irlap:
 err_dma_tx_buff:
 	dma_free_coherent(si->dev, IRDA_FRAME_SIZE_LIMIT, si->dma_rx_buff, si->dma_rx_buff_phy);
 err_dma_rx_buff:
-	pxa_free_dma(si->txdma);
+	dma_release_channel(si->txdma);
 err_tx_dma:
-	pxa_free_dma(si->rxdma);
+	dma_release_channel(si->rxdma);
 err_rx_dma:
 	free_irq(si->icp_irq, dev);
 err_irq2:
@@ -810,8 +856,10 @@ static int pxa_irda_stop(struct net_device *dev)
 	free_irq(si->uart_irq, dev);
 	free_irq(si->icp_irq, dev);
 
-	pxa_free_dma(si->rxdma);
-	pxa_free_dma(si->txdma);
+	dmaengine_terminate_all(si->rxdma);
+	dmaengine_terminate_all(si->txdma);
+	dma_release_channel(si->rxdma);
+	dma_release_channel(si->txdma);
 
 	if (si->dma_rx_buff)
 		dma_free_coherent(si->dev, IRDA_FRAME_SIZE_LIMIT, si->dma_tx_buff, si->dma_tx_buff_phy);
@@ -920,6 +968,13 @@ static int pxa_irda_probe(struct platform_device *pdev)
 		goto err_mem_4;
 	}
 
+	res = platform_get_resource(pdev, IORESOURCE_DMA, 0);
+	if (res)
+		si->drcmr_rx = res->start;
+	res = platform_get_resource(pdev, IORESOURCE_DMA, 1);
+	if (res)
+		si->drcmr_tx = res->start;
+
 	/*
 	 * Initialise the SIR buffers
 	 */
-- 
2.1.4
