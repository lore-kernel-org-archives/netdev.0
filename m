From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 03/29] ioat: convert ioat_probe to pcim/devm
Date: Thu, 03 Sep 2009 19:30:45 -0700
Message-ID: <20090904023045.32667.54791.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932600AbZIDCat@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver currently duplicates much of what these routines offer, so
just use the common code.  For example ->irq_mode tracks what interrupt
mode was initialized, which duplicates the ->msix_enabled and
->msi_enabled handling in pcim_release.

This also adds a check to the return value of dma_async_device_register,
which can fail.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c |  130 ++++++++++++++++--------------------------------
 drivers/dma/ioat/dma.h |   11 ----
 drivers/dma/ioat/hw.h  |    1 
 drivers/dma/ioat/pci.c |   67 +++++++++----------------
 4 files changed, 68 insertions(+), 141 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index 16c0807..65f8b74 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -121,6 +121,7 @@ static int ioat_dma_enumerate_channels(struct ioatdma_device *device)
 	u32 xfercap;
 	int i;
 	struct ioat_dma_chan *ioat_chan;
+	struct device *dev = &device->pdev->dev;
 
 	/*
 	 * IOAT ver.3 workarounds
@@ -164,7 +165,7 @@ static int ioat_dma_enumerate_channels(struct ioatdma_device *device)
 	}
 #endif
 	for (i = 0; i < device->common.chancnt; i++) {
-		ioat_chan = kzalloc(sizeof(*ioat_chan), GFP_KERNEL);
+		ioat_chan = devm_kzalloc(dev, sizeof(*ioat_chan), GFP_KERNEL);
 		if (!ioat_chan) {
 			device->common.chancnt = i;
 			break;
@@ -1450,7 +1451,11 @@ MODULE_PARM_DESC(ioat_interrupt_style,
 static int ioat_dma_setup_interrupts(struct ioatdma_device *device)
 {
 	struct ioat_dma_chan *ioat_chan;
-	int err, i, j, msixcnt;
+	struct pci_dev *pdev = device->pdev;
+	struct device *dev = &pdev->dev;
+	struct msix_entry *msix;
+	int i, j, msixcnt;
+	int err = -EINVAL;
 	u8 intrctrl = 0;
 
 	if (!strcmp(ioat_interrupt_style, "msix"))
@@ -1461,8 +1466,7 @@ static int ioat_dma_setup_interrupts(struct ioatdma_device *device)
 		goto msi;
 	if (!strcmp(ioat_interrupt_style, "intx"))
 		goto intx;
-	dev_err(&device->pdev->dev, "invalid ioat_interrupt_style %s\n",
-		ioat_interrupt_style);
+	dev_err(dev, "invalid ioat_interrupt_style %s\n", ioat_interrupt_style);
 	goto err_no_irq;
 
 msix:
@@ -1471,55 +1475,55 @@ msix:
 	for (i = 0; i < msixcnt; i++)
 		device->msix_entries[i].entry = i;
 
-	err = pci_enable_msix(device->pdev, device->msix_entries, msixcnt);
+	err = pci_enable_msix(pdev, device->msix_entries, msixcnt);
 	if (err < 0)
 		goto msi;
 	if (err > 0)
 		goto msix_single_vector;
 
 	for (i = 0; i < msixcnt; i++) {
+		msix = &device->msix_entries[i];
 		ioat_chan = ioat_lookup_chan_by_index(device, i);
-		err = request_irq(device->msix_entries[i].vector,
-				  ioat_dma_do_interrupt_msix,
-				  0, "ioat-msix", ioat_chan);
+		err = devm_request_irq(dev, msix->vector,
+				       ioat_dma_do_interrupt_msix, 0,
+				       "ioat-msix", ioat_chan);
 		if (err) {
 			for (j = 0; j < i; j++) {
+				msix = &device->msix_entries[j];
 				ioat_chan =
 					ioat_lookup_chan_by_index(device, j);
-				free_irq(device->msix_entries[j].vector,
-					 ioat_chan);
+				devm_free_irq(dev, msix->vector, ioat_chan);
 			}
 			goto msix_single_vector;
 		}
 	}
 	intrctrl |= IOAT_INTRCTRL_MSIX_VECTOR_CONTROL;
-	device->irq_mode = msix_multi_vector;
 	goto done;
 
 msix_single_vector:
-	device->msix_entries[0].entry = 0;
-	err = pci_enable_msix(device->pdev, device->msix_entries, 1);
+	msix = &device->msix_entries[0];
+	msix->entry = 0;
+	err = pci_enable_msix(pdev, device->msix_entries, 1);
 	if (err)
 		goto msi;
 
-	err = request_irq(device->msix_entries[0].vector, ioat_dma_do_interrupt,
-			  0, "ioat-msix", device);
+	err = devm_request_irq(dev, msix->vector, ioat_dma_do_interrupt, 0,
+			       "ioat-msix", device);
 	if (err) {
-		pci_disable_msix(device->pdev);
+		pci_disable_msix(pdev);
 		goto msi;
 	}
-	device->irq_mode = msix_single_vector;
 	goto done;
 
 msi:
-	err = pci_enable_msi(device->pdev);
+	err = pci_enable_msi(pdev);
 	if (err)
 		goto intx;
 
-	err = request_irq(device->pdev->irq, ioat_dma_do_interrupt,
-			  0, "ioat-msi", device);
+	err = devm_request_irq(dev, pdev->irq, ioat_dma_do_interrupt, 0,
+			       "ioat-msi", device);
 	if (err) {
-		pci_disable_msi(device->pdev);
+		pci_disable_msi(pdev);
 		goto intx;
 	}
 	/*
@@ -1527,21 +1531,17 @@ msi:
 	 */
 	if (device->version == IOAT_VER_1_2) {
 		u32 dmactrl;
-		pci_read_config_dword(device->pdev,
-				      IOAT_PCI_DMACTRL_OFFSET, &dmactrl);
+		pci_read_config_dword(pdev, IOAT_PCI_DMACTRL_OFFSET, &dmactrl);
 		dmactrl |= IOAT_PCI_DMACTRL_MSI_EN;
-		pci_write_config_dword(device->pdev,
-				       IOAT_PCI_DMACTRL_OFFSET, dmactrl);
+		pci_write_config_dword(pdev, IOAT_PCI_DMACTRL_OFFSET, dmactrl);
 	}
-	device->irq_mode = msi;
 	goto done;
 
 intx:
-	err = request_irq(device->pdev->irq, ioat_dma_do_interrupt,
-			  IRQF_SHARED, "ioat-intx", device);
+	err = devm_request_irq(dev, pdev->irq, ioat_dma_do_interrupt,
+			       IRQF_SHARED, "ioat-intx", device);
 	if (err)
 		goto err_no_irq;
-	device->irq_mode = intx;
 
 done:
 	intrctrl |= IOAT_INTRCTRL_MASTER_INT_EN;
@@ -1551,60 +1551,26 @@ done:
 err_no_irq:
 	/* Disable all interrupt generation */
 	writeb(0, device->reg_base + IOAT_INTRCTRL_OFFSET);
-	dev_err(&device->pdev->dev, "no usable interrupts\n");
-	device->irq_mode = none;
-	return -1;
+	dev_err(dev, "no usable interrupts\n");
+	return err;
 }
 
-/**
- * ioat_dma_remove_interrupts - remove whatever interrupts were set
- * @device: ioat device
- */
-static void ioat_dma_remove_interrupts(struct ioatdma_device *device)
+static void ioat_disable_interrupts(struct ioatdma_device *device)
 {
-	struct ioat_dma_chan *ioat_chan;
-	int i;
-
 	/* Disable all interrupt generation */
 	writeb(0, device->reg_base + IOAT_INTRCTRL_OFFSET);
-
-	switch (device->irq_mode) {
-	case msix_multi_vector:
-		for (i = 0; i < device->common.chancnt; i++) {
-			ioat_chan = ioat_lookup_chan_by_index(device, i);
-			free_irq(device->msix_entries[i].vector, ioat_chan);
-		}
-		pci_disable_msix(device->pdev);
-		break;
-	case msix_single_vector:
-		free_irq(device->msix_entries[0].vector, device);
-		pci_disable_msix(device->pdev);
-		break;
-	case msi:
-		free_irq(device->pdev->irq, device);
-		pci_disable_msi(device->pdev);
-		break;
-	case intx:
-		free_irq(device->pdev->irq, device);
-		break;
-	case none:
-		dev_warn(&device->pdev->dev,
-			 "call to %s without interrupts setup\n", __func__);
-	}
-	device->irq_mode = none;
 }
 
 struct ioatdma_device *ioat_dma_probe(struct pci_dev *pdev,
 				      void __iomem *iobase)
 {
 	int err;
+	struct device *dev = &pdev->dev;
 	struct ioatdma_device *device;
 
-	device = kzalloc(sizeof(*device), GFP_KERNEL);
-	if (!device) {
+	device = devm_kzalloc(dev, sizeof(*device), GFP_KERNEL);
+	if (!device)
 		err = -ENOMEM;
-		goto err_kzalloc;
-	}
 	device->pdev = pdev;
 	device->reg_base = iobase;
 	device->version = readb(device->reg_base + IOAT_VER_OFFSET);
@@ -1651,14 +1617,12 @@ struct ioatdma_device *ioat_dma_probe(struct pci_dev *pdev,
 		break;
 	}
 
-	dev_err(&device->pdev->dev,
-		"Intel(R) I/OAT DMA Engine found,"
+	dev_err(dev, "Intel(R) I/OAT DMA Engine found,"
 		" %d channels, device version 0x%02x, driver version %s\n",
 		device->common.chancnt, device->version, IOAT_DMA_VERSION);
 
 	if (!device->common.chancnt) {
-		dev_err(&device->pdev->dev,
-			"Intel(R) I/OAT DMA Engine problem found: "
+		dev_err(dev, "Intel(R) I/OAT DMA Engine problem found: "
 			"zero channels detected\n");
 		goto err_setup_interrupts;
 	}
@@ -1671,9 +1635,11 @@ struct ioatdma_device *ioat_dma_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_self_test;
 
-	ioat_set_tcp_copy_break(device);
+	err = dma_async_device_register(&device->common);
+	if (err)
+		goto err_self_test;
 
-	dma_async_device_register(&device->common);
+	ioat_set_tcp_copy_break(device);
 
 	if (device->version != IOAT_VER_3_0) {
 		INIT_DELAYED_WORK(&device->work, ioat_dma_chan_watchdog);
@@ -1684,16 +1650,12 @@ struct ioatdma_device *ioat_dma_probe(struct pci_dev *pdev,
 	return device;
 
 err_self_test:
-	ioat_dma_remove_interrupts(device);
+	ioat_disable_interrupts(device);
 err_setup_interrupts:
 	pci_pool_destroy(device->completion_pool);
 err_completion_pool:
 	pci_pool_destroy(device->dma_pool);
 err_dma_pool:
-	kfree(device);
-err_kzalloc:
-	dev_err(&pdev->dev,
-		"Intel(R) I/OAT DMA Engine initialization failed\n");
 	return NULL;
 }
 
@@ -1705,23 +1667,17 @@ void ioat_dma_remove(struct ioatdma_device *device)
 	if (device->version != IOAT_VER_3_0)
 		cancel_delayed_work(&device->work);
 
-	ioat_dma_remove_interrupts(device);
+	ioat_disable_interrupts(device);
 
 	dma_async_device_unregister(&device->common);
 
 	pci_pool_destroy(device->dma_pool);
 	pci_pool_destroy(device->completion_pool);
 
-	iounmap(device->reg_base);
-	pci_release_regions(device->pdev);
-	pci_disable_device(device->pdev);
-
 	list_for_each_entry_safe(chan, _chan,
 				 &device->common.channels, device_node) {
 		ioat_chan = to_ioat_chan(chan);
 		list_del(&chan->device_node);
-		kfree(ioat_chan);
 	}
-	kfree(device);
 }
 
diff --git a/drivers/dma/ioat/dma.h b/drivers/dma/ioat/dma.h
index ccb400f..5e8d7cf 100644
--- a/drivers/dma/ioat/dma.h
+++ b/drivers/dma/ioat/dma.h
@@ -31,14 +31,6 @@
 
 #define IOAT_DMA_VERSION  "3.64"
 
-enum ioat_interrupt {
-	none = 0,
-	msix_multi_vector = 1,
-	msix_single_vector = 2,
-	msi = 3,
-	intx = 4,
-};
-
 #define IOAT_LOW_COMPLETION_MASK	0xffffffc0
 #define IOAT_DMA_DCA_ANY_CPU		~0
 #define IOAT_WATCHDOG_PERIOD		(2 * HZ)
@@ -59,7 +51,6 @@ enum ioat_interrupt {
  */
 #define NULL_DESC_BUFFER_SIZE 1
 
-
 /**
  * struct ioatdma_device - internal representation of a IOAT device
  * @pdev: PCI-Express device
@@ -67,7 +58,6 @@ enum ioat_interrupt {
  * @dma_pool: for allocating DMA descriptors
  * @common: embedded struct dma_device
  * @version: version of ioatdma device
- * @irq_mode: which style irq to use
  * @msix_entries: irq handlers
  * @idx: per channel data
  */
@@ -79,7 +69,6 @@ struct ioatdma_device {
 	struct pci_pool *completion_pool;
 	struct dma_device common;
 	u8 version;
-	enum ioat_interrupt irq_mode;
 	struct delayed_work work;
 	struct msix_entry msix_entries[4];
 	struct ioat_dma_chan *idx[4];
diff --git a/drivers/dma/ioat/hw.h b/drivers/dma/ioat/hw.h
index afa57ee..1438fa5 100644
--- a/drivers/dma/ioat/hw.h
+++ b/drivers/dma/ioat/hw.h
@@ -23,6 +23,7 @@
 
 /* PCI Configuration Space Values */
 #define IOAT_PCI_VID            0x8086
+#define IOAT_MMIO_BAR		0
 
 /* CB device ID's */
 #define IOAT_PCI_DID_5000       0x1A38
diff --git a/drivers/dma/ioat/pci.c b/drivers/dma/ioat/pci.c
index d7948bf..982e38f 100644
--- a/drivers/dma/ioat/pci.c
+++ b/drivers/dma/ioat/pci.c
@@ -62,7 +62,6 @@ static struct pci_device_id ioat_pci_tbl[] = {
 
 struct ioat_device {
 	struct pci_dev		*pdev;
-	void __iomem		*iobase;
 	struct ioatdma_device	*dma;
 	struct dca_provider	*dca;
 };
@@ -75,8 +74,10 @@ static int ioat_dca_enabled = 1;
 module_param(ioat_dca_enabled, int, 0644);
 MODULE_PARM_DESC(ioat_dca_enabled, "control support of dca service (default: 1)");
 
+#define DRV_NAME "ioatdma"
+
 static struct pci_driver ioat_pci_driver = {
-	.name		= "ioatdma",
+	.name		= DRV_NAME,
 	.id_table	= ioat_pci_tbl,
 	.probe		= ioat_probe,
 	.remove		= __devexit_p(ioat_remove),
@@ -85,47 +86,42 @@ static struct pci_driver ioat_pci_driver = {
 static int __devinit ioat_probe(struct pci_dev *pdev,
 				const struct pci_device_id *id)
 {
+	void __iomem * const *iomap;
 	void __iomem *iobase;
+	struct device *dev = &pdev->dev;
 	struct ioat_device *device;
-	unsigned long mmio_start, mmio_len;
 	int err;
 
-	err = pci_enable_device(pdev);
+	err = pcim_enable_device(pdev);
 	if (err)
-		goto err_enable_device;
+		return err;
 
-	err = pci_request_regions(pdev, ioat_pci_driver.name);
+	err = pcim_iomap_regions(pdev, 1 << IOAT_MMIO_BAR, DRV_NAME);
 	if (err)
-		goto err_request_regions;
+		return err;
+	iomap = pcim_iomap_table(pdev);
+	if (!iomap)
+		return -ENOMEM;
 
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err)
 		err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err)
-		goto err_set_dma_mask;
+		return err;
 
 	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64));
 	if (err)
 		err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err)
-		goto err_set_dma_mask;
-
-	mmio_start = pci_resource_start(pdev, 0);
-	mmio_len = pci_resource_len(pdev, 0);
-	iobase = ioremap(mmio_start, mmio_len);
-	if (!iobase) {
-		err = -ENOMEM;
-		goto err_ioremap;
-	}
+		return err;
+
+	device = devm_kzalloc(dev, sizeof(*device), GFP_KERNEL);
+	if (!device)
+		return -ENOMEM;
 
-	device = kzalloc(sizeof(*device), GFP_KERNEL);
-	if (!device) {
-		err = -ENOMEM;
-		goto err_kzalloc;
-	}
 	device->pdev = pdev;
 	pci_set_drvdata(pdev, device);
-	device->iobase = iobase;
+	iobase = iomap[IOAT_MMIO_BAR];
 
 	pci_set_master(pdev);
 
@@ -146,28 +142,15 @@ static int __devinit ioat_probe(struct pci_dev *pdev,
 			device->dca = ioat3_dca_init(pdev, iobase);
 		break;
 	default:
-		err = -ENODEV;
-		break;
+		return -ENODEV;
 	}
-	if (!device->dma)
-		err = -ENODEV;
 
-	if (err)
-		goto err_version;
+	if (!device->dma) {
+		dev_err(dev, "Intel(R) I/OAT DMA Engine init failed\n");
+		return -ENODEV;
+	}
 
 	return 0;
-
-err_version:
-	kfree(device);
-err_kzalloc:
-	iounmap(iobase);
-err_ioremap:
-err_set_dma_mask:
-	pci_release_regions(pdev);
-	pci_disable_device(pdev);
-err_request_regions:
-err_enable_device:
-	return err;
 }
 
 static void __devexit ioat_remove(struct pci_dev *pdev)
@@ -185,8 +168,6 @@ static void __devexit ioat_remove(struct pci_dev *pdev)
 		ioat_dma_remove(device->dma);
 		device->dma = NULL;
 	}
-
-	kfree(device);
 }
 
 static int __init ioat_init_module(void)
