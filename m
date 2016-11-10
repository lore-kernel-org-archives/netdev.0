From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 05/11] amd-xgbe: Add support for new DMA
 interrupt mode
Date: Thu, 10 Nov 2016 17:10:17 -0600
Message-ID: <20161110231017.20704.50782.stgit@tlendack-t1.amdoffice.net>
References: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0074.outbound.protection.outlook.com ([104.47.42.74]:42144
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S964802AbcKJXKX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 18:10:23 -0500
In-Reply-To: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current per channel DMA interrupt support is based on an edge
triggered interrupt that is not maskable. This results in having to call
the disable_irq/enable_irq functions in order to prevent interrupts
during napi processing. The hardware now has a way to configure the per
channel DMA interrupt that will allow for masking the interrupt which
prevents calling disable_irq/enable_irq now. This patch makes use of
this support.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-common.h   |    2 +
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c      |   15 +++-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c      |   99 +++++++++++++++++--------
 drivers/net/ethernet/amd/xgbe/xgbe-pci.c      |    2 +
 drivers/net/ethernet/amd/xgbe/xgbe-platform.c |    4 +
 drivers/net/ethernet/amd/xgbe/xgbe.h          |    5 +
 6 files changed, 91 insertions(+), 36 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index b54862b..516345c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -159,6 +159,8 @@
 #define DMA_ISR_MACIS_WIDTH		1
 #define DMA_ISR_MTLIS_INDEX		16
 #define DMA_ISR_MTLIS_WIDTH		1
+#define DMA_MR_INTM_INDEX		12
+#define DMA_MR_INTM_WIDTH		2
 #define DMA_MR_SWR_INDEX		0
 #define DMA_MR_SWR_WIDTH		1
 #define DMA_SBMR_EAME_INDEX		11
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 81d4780..ff7f5ab 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -646,6 +646,11 @@ static void xgbe_enable_dma_interrupts(struct xgbe_prv_data *pdata)
 	unsigned int dma_ch_isr, dma_ch_ier;
 	unsigned int i;
 
+	/* Set the interrupt mode if supported */
+	if (pdata->channel_irq_mode)
+		XGMAC_IOWRITE_BITS(pdata, DMA_MR, INTM,
+				   pdata->channel_irq_mode);
+
 	channel = pdata->channel;
 	for (i = 0; i < pdata->channel_count; i++, channel++) {
 		/* Clear all the interrupts which are set */
@@ -667,19 +672,21 @@ static void xgbe_enable_dma_interrupts(struct xgbe_prv_data *pdata)
 		if (channel->tx_ring) {
 			/* Enable the following Tx interrupts
 			 *   TIE  - Transmit Interrupt Enable (unless using
-			 *          per channel interrupts)
+			 *          per channel interrupts in edge triggered
+			 *          mode)
 			 */
-			if (!pdata->per_channel_irq)
+			if (!pdata->per_channel_irq || pdata->channel_irq_mode)
 				XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, TIE, 1);
 		}
 		if (channel->rx_ring) {
 			/* Enable following Rx interrupts
 			 *   RBUE - Receive Buffer Unavailable Enable
 			 *   RIE  - Receive Interrupt Enable (unless using
-			 *          per channel interrupts)
+			 *          per channel interrupts in edge triggered
+			 *          mode)
 			 */
 			XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, RBUE, 1);
-			if (!pdata->per_channel_irq)
+			if (!pdata->per_channel_irq || pdata->channel_irq_mode)
 				XGMAC_SET_BITS(dma_ch_ier, DMA_CH_IER, RIE, 1);
 		}
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index efa01a5..490fdb5 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -252,48 +252,60 @@ static int xgbe_calc_rx_buf_size(struct net_device *netdev, unsigned int mtu)
 	return rx_buf_size;
 }
 
-static void xgbe_enable_rx_tx_ints(struct xgbe_prv_data *pdata)
+static void xgbe_enable_rx_tx_int(struct xgbe_prv_data *pdata,
+				  struct xgbe_channel *channel)
 {
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
-	struct xgbe_channel *channel;
 	enum xgbe_int int_id;
+
+	if (channel->tx_ring && channel->rx_ring)
+		int_id = XGMAC_INT_DMA_CH_SR_TI_RI;
+	else if (channel->tx_ring)
+		int_id = XGMAC_INT_DMA_CH_SR_TI;
+	else if (channel->rx_ring)
+		int_id = XGMAC_INT_DMA_CH_SR_RI;
+	else
+		return;
+
+	hw_if->enable_int(channel, int_id);
+}
+
+static void xgbe_enable_rx_tx_ints(struct xgbe_prv_data *pdata)
+{
+	struct xgbe_channel *channel;
 	unsigned int i;
 
 	channel = pdata->channel;
-	for (i = 0; i < pdata->channel_count; i++, channel++) {
-		if (channel->tx_ring && channel->rx_ring)
-			int_id = XGMAC_INT_DMA_CH_SR_TI_RI;
-		else if (channel->tx_ring)
-			int_id = XGMAC_INT_DMA_CH_SR_TI;
-		else if (channel->rx_ring)
-			int_id = XGMAC_INT_DMA_CH_SR_RI;
-		else
-			continue;
+	for (i = 0; i < pdata->channel_count; i++, channel++)
+		xgbe_enable_rx_tx_int(pdata, channel);
+}
 
-		hw_if->enable_int(channel, int_id);
-	}
+static void xgbe_disable_rx_tx_int(struct xgbe_prv_data *pdata,
+				   struct xgbe_channel *channel)
+{
+	struct xgbe_hw_if *hw_if = &pdata->hw_if;
+	enum xgbe_int int_id;
+
+	if (channel->tx_ring && channel->rx_ring)
+		int_id = XGMAC_INT_DMA_CH_SR_TI_RI;
+	else if (channel->tx_ring)
+		int_id = XGMAC_INT_DMA_CH_SR_TI;
+	else if (channel->rx_ring)
+		int_id = XGMAC_INT_DMA_CH_SR_RI;
+	else
+		return;
+
+	hw_if->disable_int(channel, int_id);
 }
 
 static void xgbe_disable_rx_tx_ints(struct xgbe_prv_data *pdata)
 {
-	struct xgbe_hw_if *hw_if = &pdata->hw_if;
 	struct xgbe_channel *channel;
-	enum xgbe_int int_id;
 	unsigned int i;
 
 	channel = pdata->channel;
-	for (i = 0; i < pdata->channel_count; i++, channel++) {
-		if (channel->tx_ring && channel->rx_ring)
-			int_id = XGMAC_INT_DMA_CH_SR_TI_RI;
-		else if (channel->tx_ring)
-			int_id = XGMAC_INT_DMA_CH_SR_TI;
-		else if (channel->rx_ring)
-			int_id = XGMAC_INT_DMA_CH_SR_RI;
-		else
-			continue;
-
-		hw_if->disable_int(channel, int_id);
-	}
+	for (i = 0; i < pdata->channel_count; i++, channel++)
+		xgbe_disable_rx_tx_int(pdata, channel);
 }
 
 static irqreturn_t xgbe_isr(int irq, void *data)
@@ -339,6 +351,13 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 				/* Turn on polling */
 				__napi_schedule_irqoff(&pdata->napi);
 			}
+		} else {
+			/* Don't clear Rx/Tx status if doing per channel DMA
+			 * interrupts, these will be cleared by the ISR for
+			 * per channel DMA interrupts.
+			 */
+			XGMAC_SET_BITS(dma_ch_isr, DMA_CH_SR, TI, 0);
+			XGMAC_SET_BITS(dma_ch_isr, DMA_CH_SR, RI, 0);
 		}
 
 		if (XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, RBU))
@@ -348,7 +367,7 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 		if (XGMAC_GET_BITS(dma_ch_isr, DMA_CH_SR, FBE))
 			schedule_work(&pdata->restart_work);
 
-		/* Clear all interrupt signals */
+		/* Clear interrupt signals */
 		XGMAC_DMA_IOWRITE(channel, DMA_CH_SR, dma_ch_isr);
 	}
 
@@ -385,18 +404,29 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 static irqreturn_t xgbe_dma_isr(int irq, void *data)
 {
 	struct xgbe_channel *channel = data;
+	struct xgbe_prv_data *pdata = channel->pdata;
+	unsigned int dma_status;
 
 	/* Per channel DMA interrupts are enabled, so we use the per
 	 * channel napi structure and not the private data napi structure
 	 */
 	if (napi_schedule_prep(&channel->napi)) {
 		/* Disable Tx and Rx interrupts */
-		disable_irq_nosync(channel->dma_irq);
+		if (pdata->channel_irq_mode)
+			xgbe_disable_rx_tx_int(pdata, channel);
+		else
+			disable_irq_nosync(channel->dma_irq);
 
 		/* Turn on polling */
 		__napi_schedule_irqoff(&channel->napi);
 	}
 
+	/* Clear Tx/Rx signals */
+	dma_status = 0;
+	XGMAC_SET_BITS(dma_status, DMA_CH_SR, TI, 1);
+	XGMAC_SET_BITS(dma_status, DMA_CH_SR, RI, 1);
+	XGMAC_DMA_IOWRITE(channel, DMA_CH_SR, dma_status);
+
 	return IRQ_HANDLED;
 }
 
@@ -413,7 +443,10 @@ static void xgbe_tx_timer(unsigned long data)
 	if (napi_schedule_prep(napi)) {
 		/* Disable Tx and Rx interrupts */
 		if (pdata->per_channel_irq)
-			disable_irq_nosync(channel->dma_irq);
+			if (pdata->channel_irq_mode)
+				xgbe_disable_rx_tx_int(pdata, channel);
+			else
+				disable_irq_nosync(channel->dma_irq);
 		else
 			xgbe_disable_rx_tx_ints(pdata);
 
@@ -2030,6 +2063,7 @@ static int xgbe_one_poll(struct napi_struct *napi, int budget)
 {
 	struct xgbe_channel *channel = container_of(napi, struct xgbe_channel,
 						    napi);
+	struct xgbe_prv_data *pdata = channel->pdata;
 	int processed = 0;
 
 	DBGPR("-->xgbe_one_poll: budget=%d\n", budget);
@@ -2046,7 +2080,10 @@ static int xgbe_one_poll(struct napi_struct *napi, int budget)
 		napi_complete_done(napi, processed);
 
 		/* Enable Tx and Rx interrupts */
-		enable_irq(channel->dma_irq);
+		if (pdata->channel_irq_mode)
+			xgbe_enable_rx_tx_int(pdata, channel);
+		else
+			enable_irq(channel->dma_irq);
 	}
 
 	DBGPR("<--xgbe_one_poll: received = %d\n", processed);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-pci.c b/drivers/net/ethernet/amd/xgbe/xgbe-pci.c
index fe77945..61eb6613 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-pci.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-pci.c
@@ -163,6 +163,7 @@ static int xgbe_config_msi(struct xgbe_prv_data *pdata)
 		pdata->channel_irq_count = j;
 
 		pdata->per_channel_irq = 1;
+		pdata->channel_irq_mode = XGBE_IRQ_MODE_LEVEL;
 	} else {
 		pdata->ecc_irq = pdata->pcidev->irq;
 		pdata->i2c_irq = pdata->pcidev->irq;
@@ -215,6 +216,7 @@ static int xgbe_config_msix(struct xgbe_prv_data *pdata)
 	pdata->channel_irq_count = j;
 
 	pdata->per_channel_irq = 1;
+	pdata->channel_irq_mode = XGBE_IRQ_MODE_LEVEL;
 
 	if (netif_msg_probe(pdata))
 		dev_dbg(pdata->dev, "MSI-X interrupts enabled\n");
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-platform.c b/drivers/net/ethernet/amd/xgbe/xgbe-platform.c
index 8d438c3..8c530dc 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-platform.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-platform.c
@@ -426,8 +426,10 @@ static int xgbe_platform_probe(struct platform_device *pdev)
 	pdata->phy_mode = PHY_INTERFACE_MODE_XGMII;
 
 	/* Check for per channel interrupt support */
-	if (device_property_present(dev, XGBE_DMA_IRQS_PROPERTY))
+	if (device_property_present(dev, XGBE_DMA_IRQS_PROPERTY)) {
 		pdata->per_channel_irq = 1;
+		pdata->channel_irq_mode = XGBE_IRQ_MODE_EDGE;
+	}
 
 	/* Obtain device settings unique to ACPI/OF */
 	if (pdata->use_acpi)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index e22156e..381144b 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -171,6 +171,10 @@
 #define XGBE_DMA_SYS_ARCACHE	0x0
 #define XGBE_DMA_SYS_AWCACHE	0x0
 
+/* DMA channel interrupt modes */
+#define XGBE_IRQ_MODE_EDGE	0
+#define XGBE_IRQ_MODE_LEVEL	1
+
 #define XGBE_DMA_INTERRUPT_MASK	0x31c7
 
 #define XGMAC_MIN_PACKET	60
@@ -874,6 +878,7 @@ struct xgbe_prv_data {
 	unsigned int irq_shared;
 	unsigned int irq_count;
 	unsigned int channel_irq_count;
+	unsigned int channel_irq_mode;
 
 	struct xgbe_hw_if hw_if;
 	struct xgbe_phy_if phy_if;
