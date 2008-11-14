From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 09/13] atmel-mci: convert to dma_request_channel and
	down-level dma_slave
Date: Fri, 14 Nov 2008 14:35:03 -0700
Message-ID: <20081114213503.32354.21080.stgit@dwillia2-linux.ch.intel.com>
References: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: maciej.sosnowski@intel.com, hskinnemoen@atmel.com,
	g.liakhovetski@gmx.de, nicolas.ferre@atmel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30395 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754801AbYKNVfQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 16:35:16 -0500
In-Reply-To: <20081114213300.32354.1154.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dma_request_channel provides an exclusive channel, so we no longer need to
pass slave data through dmaengine.

Cc: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 arch/avr32/include/asm/atmel-mci.h  |    6 +-
 arch/avr32/mach-at32ap/at32ap700x.c |   15 +----
 drivers/dma/dmaengine.c             |    8 ---
 drivers/dma/dw_dmac.c               |   25 ++-------
 drivers/mmc/host/atmel-mci.c        |   98 ++++++++++-------------------------
 include/linux/dmaengine.h           |   38 --------------
 include/linux/dw_dmac.h             |   31 ++++++++---
 7 files changed, 62 insertions(+), 159 deletions(-)

diff --git a/arch/avr32/include/asm/atmel-mci.h b/arch/avr32/include/asm/atmel-mci.h
index 59f3fad..e5e54c6 100644
--- a/arch/avr32/include/asm/atmel-mci.h
+++ b/arch/avr32/include/asm/atmel-mci.h
@@ -3,7 +3,7 @@
 
 #define ATMEL_MCI_MAX_NR_SLOTS	2
 
-struct dma_slave;
+#include <linux/dw_dmac.h>
 
 /**
  * struct mci_slot_pdata - board-specific per-slot configuration
@@ -28,11 +28,11 @@ struct mci_slot_pdata {
 
 /**
  * struct mci_platform_data - board-specific MMC/SDcard configuration
- * @dma_slave: DMA slave interface to use in data transfers, or NULL.
+ * @dma_slave: DMA slave interface to use in data transfers.
  * @slot: Per-slot configuration data.
  */
 struct mci_platform_data {
-	struct dma_slave	*dma_slave;
+	struct dw_dma_slave	dma_slave;
 	struct mci_slot_pdata	slot[ATMEL_MCI_MAX_NR_SLOTS];
 };
 
diff --git a/arch/avr32/mach-at32ap/at32ap700x.c b/arch/avr32/mach-at32ap/at32ap700x.c
index 0c6e02f..359c01f 100644
--- a/arch/avr32/mach-at32ap/at32ap700x.c
+++ b/arch/avr32/mach-at32ap/at32ap700x.c
@@ -1305,7 +1305,7 @@ struct platform_device *__init
 at32_add_device_mci(unsigned int id, struct mci_platform_data *data)
 {
 	struct platform_device		*pdev;
-	struct dw_dma_slave		*dws;
+	struct dw_dma_slave		*dws = &data->dma_slave;
 	u32				pioa_mask;
 	u32				piob_mask;
 
@@ -1324,22 +1324,13 @@ at32_add_device_mci(unsigned int id, struct mci_platform_data *data)
 				ARRAY_SIZE(atmel_mci0_resource)))
 		goto fail;
 
-	if (data->dma_slave)
-		dws = kmemdup(to_dw_dma_slave(data->dma_slave),
-				sizeof(struct dw_dma_slave), GFP_KERNEL);
-	else
-		dws = kzalloc(sizeof(struct dw_dma_slave), GFP_KERNEL);
-
-	dws->slave.dev = &pdev->dev;
-	dws->slave.dma_dev = &dw_dmac0_device.dev;
-	dws->slave.reg_width = DMA_SLAVE_WIDTH_32BIT;
+	dws->dma_dev = &dw_dmac0_device.dev;
+	dws->reg_width = DW_DMA_SLAVE_WIDTH_32BIT;
 	dws->cfg_hi = (DWC_CFGH_SRC_PER(0)
 				| DWC_CFGH_DST_PER(1));
 	dws->cfg_lo &= ~(DWC_CFGL_HS_DST_POL
 				| DWC_CFGL_HS_SRC_POL);
 
-	data->dma_slave = &dws->slave;
-
 	if (platform_device_add_data(pdev, data,
 				sizeof(struct mci_platform_data)))
 		goto fail;
diff --git a/drivers/dma/dmaengine.c b/drivers/dma/dmaengine.c
index 46fd5fa..1b694b8 100644
--- a/drivers/dma/dmaengine.c
+++ b/drivers/dma/dmaengine.c
@@ -223,10 +223,6 @@ static void dma_client_chan_alloc(struct dma_client *client)
 	list_for_each_entry(device, &dma_device_list, global_node) {
 		if (dma_has_cap(DMA_PRIVATE, device->cap_mask))
 			continue;
-		/* Does the client require a specific DMA controller? */
-		if (client->slave && client->slave->dma_dev
-				&& client->slave->dma_dev != device->dev)
-			continue;
 
 		list_for_each_entry(chan, &device->channels, device_node) {
 			if (!dma_chan_satisfies_mask(chan, client->cap_mask))
@@ -601,10 +597,6 @@ void dma_async_client_register(struct dma_client *client)
 	struct dma_chan *chan;
 	int err;
 
-	/* validate client data */
-	BUG_ON(dma_has_cap(DMA_SLAVE, client->cap_mask) &&
-		!client->slave);
-
 	mutex_lock(&dma_list_mutex);
 	dmaengine_ref_count++;
 
diff --git a/drivers/dma/dw_dmac.c b/drivers/dma/dw_dmac.c
index 377dafa..dbd5080 100644
--- a/drivers/dma/dw_dmac.c
+++ b/drivers/dma/dw_dmac.c
@@ -567,7 +567,7 @@ dwc_prep_slave_sg(struct dma_chan *chan, struct scatterlist *sgl,
 	if (unlikely(!dws || !sg_len))
 		return NULL;
 
-	reg_width = dws->slave.reg_width;
+	reg_width = dws->reg_width;
 	prev = first = NULL;
 
 	sg_len = dma_map_sg(chan->dev.parent, sgl, sg_len, direction);
@@ -579,7 +579,7 @@ dwc_prep_slave_sg(struct dma_chan *chan, struct scatterlist *sgl,
 				| DWC_CTLL_DST_FIX
 				| DWC_CTLL_SRC_INC
 				| DWC_CTLL_FC_M2P);
-		reg = dws->slave.tx_reg;
+		reg = dws->tx_reg;
 		for_each_sg(sgl, sg, sg_len, i) {
 			struct dw_desc	*desc;
 			u32		len;
@@ -625,7 +625,7 @@ dwc_prep_slave_sg(struct dma_chan *chan, struct scatterlist *sgl,
 				| DWC_CTLL_SRC_FIX
 				| DWC_CTLL_FC_P2M);
 
-		reg = dws->slave.rx_reg;
+		reg = dws->rx_reg;
 		for_each_sg(sgl, sg, sg_len, i) {
 			struct dw_desc	*desc;
 			u32		len;
@@ -764,7 +764,6 @@ static int dwc_alloc_chan_resources(struct dma_chan *chan,
 	struct dw_dma_chan	*dwc = to_dw_dma_chan(chan);
 	struct dw_dma		*dw = to_dw_dma(chan->device);
 	struct dw_desc		*desc;
-	struct dma_slave	*slave;
 	struct dw_dma_slave	*dws;
 	int			i;
 	u32			cfghi;
@@ -772,12 +771,6 @@ static int dwc_alloc_chan_resources(struct dma_chan *chan,
 
 	dev_vdbg(&chan->dev, "alloc_chan_resources\n");
 
-	/* Channels doing slave DMA can only handle one client. */
-	if (dwc->dws || (client && client->slave)) {
-		if (chan->client_count)
-			return -EBUSY;
-	}
-
 	/* ASSERT:  channel is idle */
 	if (dma_readl(dw, CH_EN) & dwc->mask) {
 		dev_dbg(&chan->dev, "DMA channel not idle?\n");
@@ -789,23 +782,17 @@ static int dwc_alloc_chan_resources(struct dma_chan *chan,
 	cfghi = DWC_CFGH_FIFO_MODE;
 	cfglo = 0;
 
-	slave = client->slave;
-	if (slave) {
+	dws = dwc->dws;
+	if (dws) {
 		/*
 		 * We need controller-specific data to set up slave
 		 * transfers.
 		 */
-		BUG_ON(!slave->dma_dev || slave->dma_dev != dw->dma.dev);
-
-		dws = container_of(slave, struct dw_dma_slave, slave);
+		BUG_ON(!dws->dma_dev || dws->dma_dev != dw->dma.dev);
 
-		dwc->dws = dws;
 		cfghi = dws->cfg_hi;
 		cfglo = dws->cfg_lo;
-	} else {
-		dwc->dws = NULL;
 	}
-
 	channel_writel(dwc, CFG_LO, cfglo);
 	channel_writel(dwc, CFG_HI, cfghi);
 
diff --git a/drivers/mmc/host/atmel-mci.c b/drivers/mmc/host/atmel-mci.c
index 6c11f4d..7a34118 100644
--- a/drivers/mmc/host/atmel-mci.c
+++ b/drivers/mmc/host/atmel-mci.c
@@ -1441,60 +1441,6 @@ static irqreturn_t atmci_detect_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
-#ifdef CONFIG_MMC_ATMELMCI_DMA
-
-static inline struct atmel_mci *
-dma_client_to_atmel_mci(struct dma_client *client)
-{
-	return container_of(client, struct atmel_mci, dma.client);
-}
-
-static enum dma_state_client atmci_dma_event(struct dma_client *client,
-		struct dma_chan *chan, enum dma_state state)
-{
-	struct atmel_mci	*host;
-	enum dma_state_client	ret = DMA_NAK;
-
-	host = dma_client_to_atmel_mci(client);
-
-	switch (state) {
-	case DMA_RESOURCE_AVAILABLE:
-		spin_lock_bh(&host->lock);
-		if (!host->dma.chan) {
-			host->dma.chan = chan;
-			ret = DMA_ACK;
-		}
-		spin_unlock_bh(&host->lock);
-
-		if (ret == DMA_ACK)
-			dev_info(&host->pdev->dev,
-					"Using %s for DMA transfers\n",
-					chan->dev.bus_id);
-		break;
-
-	case DMA_RESOURCE_REMOVED:
-		spin_lock_bh(&host->lock);
-		if (host->dma.chan == chan) {
-			host->dma.chan = NULL;
-			ret = DMA_ACK;
-		}
-		spin_unlock_bh(&host->lock);
-
-		if (ret == DMA_ACK)
-			dev_info(&host->pdev->dev,
-					"Lost %s, falling back to PIO\n",
-					chan->dev.bus_id);
-		break;
-
-	default:
-		break;
-	}
-
-
-	return ret;
-}
-#endif /* CONFIG_MMC_ATMELMCI_DMA */
-
 static int __init atmci_init_slot(struct atmel_mci *host,
 		struct mci_slot_pdata *slot_data, unsigned int id,
 		u32 sdc_reg)
@@ -1598,6 +1544,18 @@ static void __exit atmci_cleanup_slot(struct atmel_mci_slot *slot,
 	mmc_free_host(slot->mmc);
 }
 
+#ifdef CONFIG_MMC_ATMELMCI_DMA
+static enum dma_state_client filter(struct dma_chan *chan, void *slave)
+{
+	struct dw_dma_slave *dws = slave;
+
+	if (dws->dma_dev == chan->device->dev)
+		return DMA_ACK;
+	else
+		return DMA_DUP;
+}
+#endif
+
 static int __init atmci_probe(struct platform_device *pdev)
 {
 	struct mci_platform_data	*pdata;
@@ -1650,22 +1608,20 @@ static int __init atmci_probe(struct platform_device *pdev)
 		goto err_request_irq;
 
 #ifdef CONFIG_MMC_ATMELMCI_DMA
-	if (pdata->dma_slave) {
-		struct dma_slave *slave = pdata->dma_slave;
+	if (pdata->dma_slave.dma_dev) {
+		struct dw_dma_slave *dws = &pdata->dma_slave;
+		dma_cap_mask_t mask;
 
-		slave->tx_reg = regs->start + MCI_TDR;
-		slave->rx_reg = regs->start + MCI_RDR;
+		dws->tx_reg = regs->start + MCI_TDR;
+		dws->rx_reg = regs->start + MCI_RDR;
 
 		/* Try to grab a DMA channel */
-		host->dma.client.event_callback = atmci_dma_event;
-		dma_cap_set(DMA_SLAVE, host->dma.client.cap_mask);
-		host->dma.client.slave = slave;
-
-		dma_async_client_register(&host->dma.client);
-		dma_async_client_chan_request(&host->dma.client);
-	} else {
-		dev_notice(&pdev->dev, "DMA not available, using PIO\n");
+		dma_cap_zero(mask);
+		dma_cap_set(DMA_SLAVE, mask);
+		host->dma.chan = dma_request_channel(mask, filter, dws);
 	}
+	if (!host->dma.chan)
+		dev_notice(&pdev->dev, "DMA not available, using PIO\n");
 #endif /* CONFIG_MMC_ATMELMCI_DMA */
 
 	platform_set_drvdata(pdev, host);
@@ -1697,8 +1653,8 @@ static int __init atmci_probe(struct platform_device *pdev)
 
 err_init_slot:
 #ifdef CONFIG_MMC_ATMELMCI_DMA
-	if (pdata->dma_slave)
-		dma_async_client_unregister(&host->dma.client);
+	if (host->dma.chan)
+		dma_release_channel(host->dma.chan);
 #endif
 	free_irq(irq, host);
 err_request_irq:
@@ -1729,8 +1685,8 @@ static int __exit atmci_remove(struct platform_device *pdev)
 	clk_disable(host->mck);
 
 #ifdef CONFIG_MMC_ATMELMCI_DMA
-	if (host->dma.client.slave)
-		dma_async_client_unregister(&host->dma.client);
+	if (host->dma.chan)
+		dma_release_channel(host->dma.chan);
 #endif
 
 	free_irq(platform_get_irq(pdev, 0), host);
@@ -1759,7 +1715,7 @@ static void __exit atmci_exit(void)
 	platform_driver_unregister(&atmci_driver);
 }
 
-module_init(atmci_init);
+late_initcall(atmci_init); /* try to load after dma driver when built-in */
 module_exit(atmci_exit);
 
 MODULE_DESCRIPTION("Atmel Multimedia Card Interface driver");
diff --git a/include/linux/dmaengine.h b/include/linux/dmaengine.h
index 6f2d070..d63544c 100644
--- a/include/linux/dmaengine.h
+++ b/include/linux/dmaengine.h
@@ -96,17 +96,6 @@ enum dma_transaction_type {
 /* last transaction type for creation of the capabilities mask */
 #define DMA_TX_TYPE_END (DMA_SLAVE + 1)
 
-/**
- * enum dma_slave_width - DMA slave register access width.
- * @DMA_SLAVE_WIDTH_8BIT: Do 8-bit slave register accesses
- * @DMA_SLAVE_WIDTH_16BIT: Do 16-bit slave register accesses
- * @DMA_SLAVE_WIDTH_32BIT: Do 32-bit slave register accesses
- */
-enum dma_slave_width {
-	DMA_SLAVE_WIDTH_8BIT,
-	DMA_SLAVE_WIDTH_16BIT,
-	DMA_SLAVE_WIDTH_32BIT,
-};
 
 /**
  * enum dma_ctrl_flags - DMA flags to augment operation preparation,
@@ -133,32 +122,6 @@ enum dma_ctrl_flags {
 typedef struct { DECLARE_BITMAP(bits, DMA_TX_TYPE_END); } dma_cap_mask_t;
 
 /**
- * struct dma_slave - Information about a DMA slave
- * @dev: device acting as DMA slave
- * @dma_dev: required DMA master device. If non-NULL, the client can not be
- *	bound to other masters than this.
- * @tx_reg: physical address of data register used for
- *	memory-to-peripheral transfers
- * @rx_reg: physical address of data register used for
- *	peripheral-to-memory transfers
- * @reg_width: peripheral register width
- *
- * If dma_dev is non-NULL, the client can not be bound to other DMA
- * masters than the one corresponding to this device. The DMA master
- * driver may use this to determine if there is controller-specific
- * data wrapped around this struct. Drivers of platform code that sets
- * the dma_dev field must therefore make sure to use an appropriate
- * controller-specific dma slave structure wrapping this struct.
- */
-struct dma_slave {
-	struct device		*dev;
-	struct device		*dma_dev;
-	dma_addr_t		tx_reg;
-	dma_addr_t		rx_reg;
-	enum dma_slave_width	reg_width;
-};
-
-/**
  * struct dma_chan_percpu - the per-CPU part of struct dma_chan
  * @refcount: local_t used for open-coded "bigref" counting
  * @memcpy_count: transaction counter
@@ -248,7 +211,6 @@ typedef enum dma_state_client (*dma_filter_fn)(struct dma_chan *chan, void *filt
 struct dma_client {
 	dma_event_callback	event_callback;
 	dma_cap_mask_t		cap_mask;
-	struct dma_slave	*slave;
 	struct list_head	global_node;
 };
 
diff --git a/include/linux/dw_dmac.h b/include/linux/dw_dmac.h
index 04d217b..d797dde 100644
--- a/include/linux/dw_dmac.h
+++ b/include/linux/dw_dmac.h
@@ -22,14 +22,34 @@ struct dw_dma_platform_data {
 };
 
 /**
+ * enum dw_dma_slave_width - DMA slave register access width.
+ * @DMA_SLAVE_WIDTH_8BIT: Do 8-bit slave register accesses
+ * @DMA_SLAVE_WIDTH_16BIT: Do 16-bit slave register accesses
+ * @DMA_SLAVE_WIDTH_32BIT: Do 32-bit slave register accesses
+ */
+enum dw_dma_slave_width {
+	DW_DMA_SLAVE_WIDTH_8BIT,
+	DW_DMA_SLAVE_WIDTH_16BIT,
+	DW_DMA_SLAVE_WIDTH_32BIT,
+};
+
+/**
  * struct dw_dma_slave - Controller-specific information about a slave
- * @slave: Generic information about the slave
- * @ctl_lo: Platform-specific initializer for the CTL_LO register
+ *
+ * @dma_dev: required DMA master device
+ * @tx_reg: physical address of data register used for
+ *	memory-to-peripheral transfers
+ * @rx_reg: physical address of data register used for
+ *	peripheral-to-memory transfers
+ * @reg_width: peripheral register width
  * @cfg_hi: Platform-specific initializer for the CFG_HI register
  * @cfg_lo: Platform-specific initializer for the CFG_LO register
  */
 struct dw_dma_slave {
-	struct dma_slave	slave;
+	struct device		*dma_dev;
+	dma_addr_t		tx_reg;
+	dma_addr_t		rx_reg;
+	enum dw_dma_slave_width	reg_width;
 	u32			cfg_hi;
 	u32			cfg_lo;
 };
@@ -54,9 +74,4 @@ struct dw_dma_slave {
 #define DWC_CFGL_HS_DST_POL	(1 << 18)	/* dst handshake active low */
 #define DWC_CFGL_HS_SRC_POL	(1 << 19)	/* src handshake active low */
 
-static inline struct dw_dma_slave *to_dw_dma_slave(struct dma_slave *slave)
-{
-	return container_of(slave, struct dw_dma_slave, slave);
-}
-
 #endif /* DW_DMAC_H */

