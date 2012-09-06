From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH v2 2/6] net: pxaficp_ir: add irq resources
Date: Thu,  6 Sep 2012 14:42:39 -0500
Message-ID: <1346960563-18689-3-git-send-email-robherring2@gmail.com>
References: <1346960563-18689-1-git-send-email-robherring2@gmail.com>
Cc: Russell King <linux@arm.linux.org.uk>,
	Arnd Bergmann <arnd@arndb.de>, Olof Johansson <olof@lixom.net>,
	Linus Walleij <linus.walleij@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Eric Miao <eric.y.miao@gmail.com>,
	Haojian Zhuang <haojian.zhuang@gmail.com>,
	netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:63675 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791Ab2IFTnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 15:43:00 -0400
Received: by obbuo13 with SMTP id uo13so3285464obb.19
        for <netdev@vger.kernel.org>; Thu, 06 Sep 2012 12:42:59 -0700 (PDT)
In-Reply-To: <1346960563-18689-1-git-send-email-robherring2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Herring <rob.herring@calxeda.com>

In order to remove dependency on mach/irqs.h, add platform device
resources for irqs.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: Eric Miao <eric.y.miao@gmail.com>
Cc: Haojian Zhuang <haojian.zhuang@gmail.com>
Cc: netdev@vger.kernel.org
---
 arch/arm/mach-pxa/devices.c   |   15 +++++++++++++++
 drivers/net/irda/pxaficp_ir.c |   28 +++++++++++++++++-----------
 2 files changed, 32 insertions(+), 11 deletions(-)

diff --git a/arch/arm/mach-pxa/devices.c b/arch/arm/mach-pxa/devices.c
index 166eee5..339eb2a 100644
--- a/arch/arm/mach-pxa/devices.c
+++ b/arch/arm/mach-pxa/devices.c
@@ -384,9 +384,24 @@ struct platform_device pxa_device_asoc_platform = {
 
 static u64 pxaficp_dmamask = ~(u32)0;
 
+static struct resource pxa_ir_resources[] = {
+	[0] = {
+		.start  = IRQ_STUART,
+		.end    = IRQ_STUART,
+		.flags  = IORESOURCE_IRQ,
+	},
+	[1] = {
+		.start  = IRQ_ICP,
+		.end    = IRQ_ICP,
+		.flags  = IORESOURCE_IRQ,
+	},
+};
+
 struct platform_device pxa_device_ficp = {
 	.name		= "pxa2xx-ir",
 	.id		= -1,
+	.num_resources	= ARRAY_SIZE(pxa_ir_resources),
+	.resource	= pxa_ir_resources,
 	.dev		= {
 		.dma_mask = &pxaficp_dmamask,
 		.coherent_dma_mask = 0xffffffff,
diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 8d54767..cb0a5d3 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -29,8 +29,8 @@
 
 #include <mach/dma.h>
 #include <mach/irda.h>
-#include <mach/regs-uart.h>
 #include <mach/regs-ost.h>
+#include <mach/regs-uart.h>
 
 #define FICP		__REG(0x40800000)  /* Start of FICP area */
 #define ICCR0		__REG(0x40800000)  /* ICP Control Register 0 */
@@ -112,6 +112,9 @@ struct pxa_irda {
 	int			txdma;
 	int			rxdma;
 
+	int			uart_irq;
+	int			icp_irq;
+
 	struct irlap_cb		*irlap;
 	struct qos_info		qos;
 
@@ -672,19 +675,19 @@ static int pxa_irda_start(struct net_device *dev)
 
 	si->speed = 9600;
 
-	err = request_irq(IRQ_STUART, pxa_irda_sir_irq, 0, dev->name, dev);
+	err = request_irq(si->uart_irq, pxa_irda_sir_irq, 0, dev->name, dev);
 	if (err)
 		goto err_irq1;
 
-	err = request_irq(IRQ_ICP, pxa_irda_fir_irq, 0, dev->name, dev);
+	err = request_irq(si->icp_irq, pxa_irda_fir_irq, 0, dev->name, dev);
 	if (err)
 		goto err_irq2;
 
 	/*
 	 * The interrupt must remain disabled for now.
 	 */
-	disable_irq(IRQ_STUART);
-	disable_irq(IRQ_ICP);
+	disable_irq(si->uart_irq);
+	disable_irq(si->icp_irq);
 
 	err = -EBUSY;
 	si->rxdma = pxa_request_dma("FICP_RX",DMA_PRIO_LOW, pxa_irda_fir_dma_rx_irq, dev);
@@ -720,8 +723,8 @@ static int pxa_irda_start(struct net_device *dev)
 	/*
 	 * Now enable the interrupt and start the queue
 	 */
-	enable_irq(IRQ_STUART);
-	enable_irq(IRQ_ICP);
+	enable_irq(si->uart_irq);
+	enable_irq(si->icp_irq);
 	netif_start_queue(dev);
 
 	printk(KERN_DEBUG "pxa_ir: irda driver opened\n");
@@ -738,9 +741,9 @@ err_dma_rx_buff:
 err_tx_dma:
 	pxa_free_dma(si->rxdma);
 err_rx_dma:
-	free_irq(IRQ_ICP, dev);
+	free_irq(si->icp_irq, dev);
 err_irq2:
-	free_irq(IRQ_STUART, dev);
+	free_irq(si->uart_irq, dev);
 err_irq1:
 
 	return err;
@@ -760,8 +763,8 @@ static int pxa_irda_stop(struct net_device *dev)
 		si->irlap = NULL;
 	}
 
-	free_irq(IRQ_STUART, dev);
-	free_irq(IRQ_ICP, dev);
+	free_irq(si->uart_irq, dev);
+	free_irq(si->icp_irq, dev);
 
 	pxa_free_dma(si->rxdma);
 	pxa_free_dma(si->txdma);
@@ -851,6 +854,9 @@ static int pxa_irda_probe(struct platform_device *pdev)
 	si->dev = &pdev->dev;
 	si->pdata = pdev->dev.platform_data;
 
+	si->uart_irq = platform_get_irq(pdev, 0);
+	si->icp_irq = platform_get_irq(pdev, 1);
+
 	si->sir_clk = clk_get(&pdev->dev, "UARTCLK");
 	si->fir_clk = clk_get(&pdev->dev, "FICPCLK");
 	if (IS_ERR(si->sir_clk) || IS_ERR(si->fir_clk)) {
-- 
1.7.9.5
