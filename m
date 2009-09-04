From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 06/29] ioat: split ioat_dma_probe into core/version-specific
	routines
Date: Thu, 03 Sep 2009 19:31:00 -0700
Message-ID: <20090904023100.32667.59699.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:46513 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932609AbZIDCa6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 22:30:58 -0400
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Towards the removal of ioatdma_device.version split the initialization
path into distinct versions.  This conversion:
1/ moves version specific probe code to version specific routines
2/ removes the need for ioat_device
3/ turns off the ioat1 msi quirk if the device is reinitialized for intx

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c |  253 +++++++++++++++++++++++++++++-------------------
 drivers/dma/ioat/dma.h |   23 ++--
 drivers/dma/ioat/pci.c |   79 +++++++--------
 3 files changed, 200 insertions(+), 155 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index 462dae6..b750804 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -121,52 +121,21 @@ static int ioat_dma_enumerate_channels(struct ioatdma_device *device)
 	int i;
 	struct ioat_dma_chan *ioat_chan;
 	struct device *dev = &device->pdev->dev;
+	struct dma_device *dma = &device->common;
 
-	/*
-	 * IOAT ver.3 workarounds
-	 */
-	if (device->version == IOAT_VER_3_0) {
-		u32 chan_err_mask;
-		u16 dev_id;
-		u32 dmauncerrsts;
-
-		/*
-		 * Write CHANERRMSK_INT with 3E07h to mask out the errors
-		 * that can cause stability issues for IOAT ver.3
-		 */
-		chan_err_mask = 0x3E07;
-		pci_write_config_dword(device->pdev,
-			IOAT_PCI_CHANERRMASK_INT_OFFSET,
-			chan_err_mask);
-
-		/*
-		 * Clear DMAUNCERRSTS Cfg-Reg Parity Error status bit
-		 * (workaround for spurious config parity error after restart)
-		 */
-		pci_read_config_word(device->pdev,
-			IOAT_PCI_DEVICE_ID_OFFSET,
-			&dev_id);
-		if (dev_id == PCI_DEVICE_ID_INTEL_IOAT_TBG0) {
-			dmauncerrsts = 0x10;
-			pci_write_config_dword(device->pdev,
-				IOAT_PCI_DMAUNCERRSTS_OFFSET,
-				dmauncerrsts);
-		}
-	}
-
-	device->common.chancnt = readb(device->reg_base + IOAT_CHANCNT_OFFSET);
+	INIT_LIST_HEAD(&dma->channels);
+	dma->chancnt = readb(device->reg_base + IOAT_CHANCNT_OFFSET);
 	xfercap_scale = readb(device->reg_base + IOAT_XFERCAP_OFFSET);
 	xfercap = (xfercap_scale == 0 ? -1 : (1UL << xfercap_scale));
 
 #ifdef  CONFIG_I7300_IDLE_IOAT_CHANNEL
-	if (i7300_idle_platform_probe(NULL, NULL, 1) == 0) {
-		device->common.chancnt--;
-	}
+	if (i7300_idle_platform_probe(NULL, NULL, 1) == 0)
+		dma->chancnt--;
 #endif
-	for (i = 0; i < device->common.chancnt; i++) {
+	for (i = 0; i < dma->chancnt; i++) {
 		ioat_chan = devm_kzalloc(dev, sizeof(*ioat_chan), GFP_KERNEL);
 		if (!ioat_chan) {
-			device->common.chancnt = i;
+			dma->chancnt = i;
 			break;
 		}
 
@@ -175,28 +144,20 @@ static int ioat_dma_enumerate_channels(struct ioatdma_device *device)
 		ioat_chan->xfercap = xfercap;
 		ioat_chan->desccount = 0;
 		INIT_DELAYED_WORK(&ioat_chan->work, ioat_dma_chan_reset_part2);
-		if (ioat_chan->device->version == IOAT_VER_2_0)
-			writel(IOAT_DCACTRL_CMPL_WRITE_ENABLE |
-			       IOAT_DMA_DCA_ANY_CPU,
-			       ioat_chan->reg_base + IOAT_DCACTRL_OFFSET);
-		else if (ioat_chan->device->version == IOAT_VER_3_0)
-			writel(IOAT_DMA_DCA_ANY_CPU,
-			       ioat_chan->reg_base + IOAT_DCACTRL_OFFSET);
 		spin_lock_init(&ioat_chan->cleanup_lock);
 		spin_lock_init(&ioat_chan->desc_lock);
 		INIT_LIST_HEAD(&ioat_chan->free_desc);
 		INIT_LIST_HEAD(&ioat_chan->used_desc);
 		/* This should be made common somewhere in dmaengine.c */
 		ioat_chan->common.device = &device->common;
-		list_add_tail(&ioat_chan->common.device_node,
-			      &device->common.channels);
+		list_add_tail(&ioat_chan->common.device_node, &dma->channels);
 		device->idx[i] = ioat_chan;
 		tasklet_init(&ioat_chan->cleanup_task,
 			     ioat_dma_cleanup_tasklet,
 			     (unsigned long) ioat_chan);
 		tasklet_disable(&ioat_chan->cleanup_task);
 	}
-	return device->common.chancnt;
+	return dma->chancnt;
 }
 
 /**
@@ -1504,15 +1465,6 @@ msi:
 		pci_disable_msi(pdev);
 		goto intx;
 	}
-	/*
-	 * CB 1.2 devices need a bit set in configuration space to enable MSI
-	 */
-	if (device->version == IOAT_VER_1_2) {
-		u32 dmactrl;
-		pci_read_config_dword(pdev, IOAT_PCI_DMACTRL_OFFSET, &dmactrl);
-		dmactrl |= IOAT_PCI_DMACTRL_MSI_EN;
-		pci_write_config_dword(pdev, IOAT_PCI_DMACTRL_OFFSET, dmactrl);
-	}
 	goto done;
 
 intx:
@@ -1522,6 +1474,8 @@ intx:
 		goto err_no_irq;
 
 done:
+	if (device->intr_quirk)
+		device->intr_quirk(device);
 	intrctrl |= IOAT_INTRCTRL_MASTER_INT_EN;
 	writeb(intrctrl, device->reg_base + IOAT_INTRCTRL_OFFSET);
 	return 0;
@@ -1539,21 +1493,12 @@ static void ioat_disable_interrupts(struct ioatdma_device *device)
 	writeb(0, device->reg_base + IOAT_INTRCTRL_OFFSET);
 }
 
-struct ioatdma_device *
-ioat_dma_probe(struct pci_dev *pdev, void __iomem *iobase)
+static int ioat_probe(struct ioatdma_device *device)
 {
-	int err;
+	int err = -ENODEV;
+	struct dma_device *dma = &device->common;
+	struct pci_dev *pdev = device->pdev;
 	struct device *dev = &pdev->dev;
-	struct ioatdma_device *device;
-	struct dma_device *dma;
-
-	device = devm_kzalloc(dev, sizeof(*device), GFP_KERNEL);
-	if (!device)
-		err = -ENOMEM;
-	device->pdev = pdev;
-	device->reg_base = iobase;
-	device->version = readb(device->reg_base + IOAT_VER_OFFSET);
-	dma = &device->common;
 
 	/* DMA coherent memory pool for DMA descriptor allocations */
 	device->dma_pool = pci_pool_create("dma_desc_pool", pdev,
@@ -1572,26 +1517,13 @@ ioat_dma_probe(struct pci_dev *pdev, void __iomem *iobase)
 		goto err_completion_pool;
 	}
 
-	INIT_LIST_HEAD(&dma->channels);
 	ioat_dma_enumerate_channels(device);
 
+	dma_cap_set(DMA_MEMCPY, dma->cap_mask);
 	dma->device_alloc_chan_resources = ioat_dma_alloc_chan_resources;
 	dma->device_free_chan_resources = ioat_dma_free_chan_resources;
-	dma->dev = &pdev->dev;
-
-	dma_cap_set(DMA_MEMCPY, dma->cap_mask);
 	dma->device_is_tx_complete = ioat_dma_is_complete;
-	switch (device->version) {
-	case IOAT_VER_1_2:
-		dma->device_prep_dma_memcpy = ioat1_dma_prep_memcpy;
-		dma->device_issue_pending = ioat1_dma_memcpy_issue_pending;
-		break;
-	case IOAT_VER_2_0:
-	case IOAT_VER_3_0:
-		dma->device_prep_dma_memcpy = ioat2_dma_prep_memcpy;
-		dma->device_issue_pending = ioat2_dma_memcpy_issue_pending;
-		break;
-	}
+	dma->dev = &pdev->dev;
 
 	dev_err(dev, "Intel(R) I/OAT DMA Engine found,"
 		" %d channels, device version 0x%02x, driver version %s\n",
@@ -1611,19 +1543,7 @@ ioat_dma_probe(struct pci_dev *pdev, void __iomem *iobase)
 	if (err)
 		goto err_self_test;
 
-	err = dma_async_device_register(dma);
-	if (err)
-		goto err_self_test;
-
-	ioat_set_tcp_copy_break(device);
-
-	if (device->version != IOAT_VER_3_0) {
-		INIT_DELAYED_WORK(&device->work, ioat_dma_chan_watchdog);
-		schedule_delayed_work(&device->work,
-				      WATCHDOG_DELAY);
-	}
-
-	return device;
+	return 0;
 
 err_self_test:
 	ioat_disable_interrupts(device);
@@ -1632,7 +1552,142 @@ err_setup_interrupts:
 err_completion_pool:
 	pci_pool_destroy(device->dma_pool);
 err_dma_pool:
-	return NULL;
+	return err;
+}
+
+static int ioat_register(struct ioatdma_device *device)
+{
+	int err = dma_async_device_register(&device->common);
+
+	if (err) {
+		ioat_disable_interrupts(device);
+		pci_pool_destroy(device->completion_pool);
+		pci_pool_destroy(device->dma_pool);
+	}
+
+	return err;
+}
+
+/* ioat1_intr_quirk - fix up dma ctrl register to enable / disable msi */
+static void ioat1_intr_quirk(struct ioatdma_device *device)
+{
+	struct pci_dev *pdev = device->pdev;
+	u32 dmactrl;
+
+	pci_read_config_dword(pdev, IOAT_PCI_DMACTRL_OFFSET, &dmactrl);
+	if (pdev->msi_enabled)
+		dmactrl |= IOAT_PCI_DMACTRL_MSI_EN;
+	else
+		dmactrl &= ~IOAT_PCI_DMACTRL_MSI_EN;
+	pci_write_config_dword(pdev, IOAT_PCI_DMACTRL_OFFSET, dmactrl);
+}
+
+int ioat1_dma_probe(struct ioatdma_device *device, int dca)
+{
+	struct pci_dev *pdev = device->pdev;
+	struct dma_device *dma;
+	int err;
+
+	device->intr_quirk = ioat1_intr_quirk;
+	dma = &device->common;
+	dma->device_prep_dma_memcpy = ioat1_dma_prep_memcpy;
+	dma->device_issue_pending = ioat1_dma_memcpy_issue_pending;
+
+	err = ioat_probe(device);
+	if (err)
+		return err;
+	ioat_set_tcp_copy_break(4096);
+	err = ioat_register(device);
+	if (err)
+		return err;
+	if (dca)
+		device->dca = ioat_dca_init(pdev, device->reg_base);
+
+	INIT_DELAYED_WORK(&device->work, ioat_dma_chan_watchdog);
+	schedule_delayed_work(&device->work, WATCHDOG_DELAY);
+
+	return err;
+}
+
+int ioat2_dma_probe(struct ioatdma_device *device, int dca)
+{
+	struct pci_dev *pdev = device->pdev;
+	struct dma_device *dma;
+	struct dma_chan *chan;
+	struct ioat_dma_chan *ioat_chan;
+	int err;
+
+	dma = &device->common;
+	dma->device_prep_dma_memcpy = ioat2_dma_prep_memcpy;
+	dma->device_issue_pending = ioat2_dma_memcpy_issue_pending;
+
+	err = ioat_probe(device);
+	if (err)
+		return err;
+	ioat_set_tcp_copy_break(2048);
+
+	list_for_each_entry(chan, &dma->channels, device_node) {
+		ioat_chan = to_ioat_chan(chan);
+		writel(IOAT_DCACTRL_CMPL_WRITE_ENABLE | IOAT_DMA_DCA_ANY_CPU,
+		       ioat_chan->reg_base + IOAT_DCACTRL_OFFSET);
+	}
+
+	err = ioat_register(device);
+	if (err)
+		return err;
+	if (dca)
+		device->dca = ioat2_dca_init(pdev, device->reg_base);
+
+	INIT_DELAYED_WORK(&device->work, ioat_dma_chan_watchdog);
+	schedule_delayed_work(&device->work, WATCHDOG_DELAY);
+
+	return err;
+}
+
+int ioat3_dma_probe(struct ioatdma_device *device, int dca)
+{
+	struct pci_dev *pdev = device->pdev;
+	struct dma_device *dma;
+	struct dma_chan *chan;
+	struct ioat_dma_chan *ioat_chan;
+	int err;
+	u16 dev_id;
+
+	dma = &device->common;
+	dma->device_prep_dma_memcpy = ioat2_dma_prep_memcpy;
+	dma->device_issue_pending = ioat2_dma_memcpy_issue_pending;
+
+	/* -= IOAT ver.3 workarounds =- */
+	/* Write CHANERRMSK_INT with 3E07h to mask out the errors
+	 * that can cause stability issues for IOAT ver.3
+	 */
+	pci_write_config_dword(pdev, IOAT_PCI_CHANERRMASK_INT_OFFSET, 0x3e07);
+
+	/* Clear DMAUNCERRSTS Cfg-Reg Parity Error status bit
+	 * (workaround for spurious config parity error after restart)
+	 */
+	pci_read_config_word(pdev, IOAT_PCI_DEVICE_ID_OFFSET, &dev_id);
+	if (dev_id == PCI_DEVICE_ID_INTEL_IOAT_TBG0)
+		pci_write_config_dword(pdev, IOAT_PCI_DMAUNCERRSTS_OFFSET, 0x10);
+
+	err = ioat_probe(device);
+	if (err)
+		return err;
+	ioat_set_tcp_copy_break(262144);
+
+	list_for_each_entry(chan, &dma->channels, device_node) {
+		ioat_chan = to_ioat_chan(chan);
+		writel(IOAT_DMA_DCA_ANY_CPU,
+		       ioat_chan->reg_base + IOAT_DCACTRL_OFFSET);
+	}
+
+	err = ioat_register(device);
+	if (err)
+		return err;
+	if (dca)
+		device->dca = ioat3_dca_init(pdev, device->reg_base);
+
+	return err;
 }
 
 void ioat_dma_remove(struct ioatdma_device *device)
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index 6e27ddb..1226e35 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -61,6 +61,8 @@
  * @version: version of ioatdma device
  * @msix_entries: irq handlers
  * @idx: per channel data
+ * @dca: direct cache access context
+ * @intr_quirk: interrupt setup quirk (for ioat_v1 devices)
  */
 
 struct ioatdma_device {
@@ -73,6 +75,8 @@ struct ioatdma_device {
 	struct delayed_work work;
 	struct msix_entry msix_entries[4];
 	struct ioat_dma_chan *idx[4];
+	struct dca_provider *dca;
+	void (*intr_quirk)(struct ioatdma_device *device);
 };
 
 /**
@@ -136,25 +140,16 @@ struct ioat_desc_sw {
 	struct dma_async_tx_descriptor txd;
 };
 
-static inline void ioat_set_tcp_copy_break(struct ioatdma_device *dev)
+static inline void ioat_set_tcp_copy_break(unsigned long copybreak)
 {
 	#ifdef CONFIG_NET_DMA
-	switch (dev->version) {
-	case IOAT_VER_1_2:
-		sysctl_tcp_dma_copybreak = 4096;
-		break;
-	case IOAT_VER_2_0:
-		sysctl_tcp_dma_copybreak = 2048;
-		break;
-	case IOAT_VER_3_0:
-		sysctl_tcp_dma_copybreak = 262144;
-		break;
-	}
+	sysctl_tcp_dma_copybreak = copybreak;
 	#endif
 }
 
-struct ioatdma_device *ioat_dma_probe(struct pci_dev *pdev,
-				      void __iomem *iobase);
+int ioat1_dma_probe(struct ioatdma_device *dev, int dca);
+int ioat2_dma_probe(struct ioatdma_device *dev, int dca);
+int ioat3_dma_probe(struct ioatdma_device *dev, int dca);
 void ioat_dma_remove(struct ioatdma_device *device);
 struct dca_provider *ioat_dca_init(struct pci_dev *pdev, void __iomem *iobase);
 struct dca_provider *ioat2_dca_init(struct pci_dev *pdev, void __iomem *iobase);
diff --git a/drivers/dma/ioat/pci.c b/drivers/dma/ioat/pci.c
index 982e38f..55414d8 100644
--- a/drivers/dma/ioat/pci.c
+++ b/drivers/dma/ioat/pci.c
@@ -60,14 +60,8 @@ static struct pci_device_id ioat_pci_tbl[] = {
 	{ 0, }
 };
 
-struct ioat_device {
-	struct pci_dev		*pdev;
-	struct ioatdma_device	*dma;
-	struct dca_provider	*dca;
-};
-
-static int __devinit ioat_probe(struct pci_dev *pdev,
-				const struct pci_device_id *id);
+static int __devinit ioat_pci_probe(struct pci_dev *pdev,
+				    const struct pci_device_id *id);
 static void __devexit ioat_remove(struct pci_dev *pdev);
 
 static int ioat_dca_enabled = 1;
@@ -79,17 +73,28 @@ MODULE_PARM_DESC(ioat_dca_enabled, "control support of dca service (default: 1)"
 static struct pci_driver ioat_pci_driver = {
 	.name		= DRV_NAME,
 	.id_table	= ioat_pci_tbl,
-	.probe		= ioat_probe,
+	.probe		= ioat_pci_probe,
 	.remove		= __devexit_p(ioat_remove),
 };
 
-static int __devinit ioat_probe(struct pci_dev *pdev,
-				const struct pci_device_id *id)
+static struct ioatdma_device *
+alloc_ioatdma(struct pci_dev *pdev, void __iomem *iobase)
+{
+	struct device *dev = &pdev->dev;
+	struct ioatdma_device *d = devm_kzalloc(dev, sizeof(*d), GFP_KERNEL);
+
+	if (!d)
+		return NULL;
+	d->pdev = pdev;
+	d->reg_base = iobase;
+	return d;
+}
+
+static int __devinit ioat_pci_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 {
 	void __iomem * const *iomap;
-	void __iomem *iobase;
 	struct device *dev = &pdev->dev;
-	struct ioat_device *device;
+	struct ioatdma_device *device;
 	int err;
 
 	err = pcim_enable_device(pdev);
@@ -119,33 +124,24 @@ static int __devinit ioat_probe(struct pci_dev *pdev,
 	if (!device)
 		return -ENOMEM;
 
-	device->pdev = pdev;
-	pci_set_drvdata(pdev, device);
-	iobase = iomap[IOAT_MMIO_BAR];
-
 	pci_set_master(pdev);
 
-	switch (readb(iobase + IOAT_VER_OFFSET)) {
-	case IOAT_VER_1_2:
-		device->dma = ioat_dma_probe(pdev, iobase);
-		if (device->dma && ioat_dca_enabled)
-			device->dca = ioat_dca_init(pdev, iobase);
-		break;
-	case IOAT_VER_2_0:
-		device->dma = ioat_dma_probe(pdev, iobase);
-		if (device->dma && ioat_dca_enabled)
-			device->dca = ioat2_dca_init(pdev, iobase);
-		break;
-	case IOAT_VER_3_0:
-		device->dma = ioat_dma_probe(pdev, iobase);
-		if (device->dma && ioat_dca_enabled)
-			device->dca = ioat3_dca_init(pdev, iobase);
-		break;
-	default:
+	device = alloc_ioatdma(pdev, iomap[IOAT_MMIO_BAR]);
+	if (!device)
+		return -ENOMEM;
+	pci_set_drvdata(pdev, device);
+
+	device->version = readb(device->reg_base + IOAT_VER_OFFSET);
+	if (device->version == IOAT_VER_1_2)
+		err = ioat1_dma_probe(device, ioat_dca_enabled);
+	else if (device->version == IOAT_VER_2_0)
+		err = ioat2_dma_probe(device, ioat_dca_enabled);
+	else if (device->version >= IOAT_VER_3_0)
+		err = ioat3_dma_probe(device, ioat_dca_enabled);
+	else
 		return -ENODEV;
-	}
 
-	if (!device->dma) {
+	if (err) {
 		dev_err(dev, "Intel(R) I/OAT DMA Engine init failed\n");
 		return -ENODEV;
 	}
@@ -155,7 +151,10 @@ static int __devinit ioat_probe(struct pci_dev *pdev,
 
 static void __devexit ioat_remove(struct pci_dev *pdev)
 {
-	struct ioat_device *device = pci_get_drvdata(pdev);
+	struct ioatdma_device *device = pci_get_drvdata(pdev);
+
+	if (!device)
+		return;
 
 	dev_err(&pdev->dev, "Removing dma and dca services\n");
 	if (device->dca) {
@@ -163,11 +162,7 @@ static void __devexit ioat_remove(struct pci_dev *pdev)
 		free_dca_provider(device->dca);
 		device->dca = NULL;
 	}
-
-	if (device->dma) {
-		ioat_dma_remove(device->dma);
-		device->dma = NULL;
-	}
+	ioat_dma_remove(device);
 }
 
 static int __init ioat_init_module(void)

