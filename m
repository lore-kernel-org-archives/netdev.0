From: Andrew Grover <andrew.grover@intel.com>
Subject: [PATCH 2b/2] [IOAT] Driver for the I/OAT DMA engine
Date: Thu, 20 Apr 2006 14:06:44 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0604201405250.23021-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:27026 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751316AbWDTVGq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 17:06:46 -0400
Received: from orsfmr101.jf.intel.com (orsfmr101.jf.intel.com [10.7.209.17])
	by orsfmr003.jf.intel.com (8.12.10/8.12.10/d: major-outer.mc,v 1.1 2004/09/17 17:50:56 root Exp $) with ESMTP id k3KL6jS4001944
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 21:06:45 GMT
Received: from nwlxmail01.jf.intel.com (nwlxmail01.jf.intel.com [10.7.171.40])
	by orsfmr101.jf.intel.com (8.12.10/8.12.10/d: major-inner.mc,v 1.2 2004/09/17 18:05:01 root Exp $) with ESMTP id k3KL6jtH020911
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 21:06:45 GMT
Received: from isotope.jf.intel.com (isotope.jf.intel.com [10.23.35.8])
	by nwlxmail01.jf.intel.com (8.12.10/8.12.9/MailSET/Hub) with ESMTP id k3KL6ihF022261
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 14:06:45 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Second half of the ioatdma.c diff, split up to make it past netdev size 
block -- Andy

Adds a new ioatdma driver, ioatdma.c

Signed-off-by: Chris Leech <christopher.leech@intel.com>

---

 drivers/dma/ioatdma.c           |  805 +++++++++++++++++++++++++++++++++++++++

diff --git a/drivers/dma/ioatdma.c b/drivers/dma/ioatdma.c
new file mode 100644
index 0000000..ffe47dd
--- /dev/null
+++ b/drivers/dma/ioatdma.c

[see previous post for first half of file. sorry]

+/**
+ * ioat_dma_memcpy_issue_pending - push potentially unrecognoized appended descriptors to hw
+ * @chan: DMA channel handle
+ */
+
+static void ioat_dma_memcpy_issue_pending(struct dma_chan *chan)
+{
+	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+
+	if (ioat_chan->pending != 0) {
+		ioat_chan->pending = 0;
+		ioatdma_chan_write8(ioat_chan,
+		                    IOAT_CHANCMD_OFFSET,
+		                    IOAT_CHANCMD_APPEND);
+	}
+}
+
+static void ioat_dma_memcpy_cleanup(struct ioat_dma_chan *chan)
+{
+	unsigned long phys_complete;
+	struct ioat_desc_sw *desc, *_desc;
+	dma_cookie_t cookie = 0;
+
+	prefetch(chan->completion_virt);
+
+	if (!spin_trylock(&chan->cleanup_lock))
+		return;
+
+	/* The completion writeback can happen at any time,
+	   so reads by the driver need to be atomic operations
+	   The descriptor physical addresses are limited to 32-bits
+	   when the CPU can only do a 32-bit mov */
+
+#if (BITS_PER_LONG == 64)
+	phys_complete = chan->completion_virt->full & IOAT_CHANSTS_COMPLETED_DESCRIPTOR_ADDR;
+#else
+	phys_complete = chan->completion_virt->low & IOAT_LOW_COMPLETION_MASK;
+#endif
+
+	if ((chan->completion_virt->full & IOAT_CHANSTS_DMA_TRANSFER_STATUS) ==
+		IOAT_CHANSTS_DMA_TRANSFER_STATUS_HALTED) {
+		printk("IOAT: Channel halted, chanerr = %x\n",
+			ioatdma_chan_read32(chan, IOAT_CHANERR_OFFSET));
+
+		/* TODO do something to salvage the situation */
+	}
+
+	if (phys_complete == chan->last_completion) {
+		spin_unlock(&chan->cleanup_lock);
+		return;
+	}
+
+	spin_lock_bh(&chan->desc_lock);
+	list_for_each_entry_safe(desc, _desc, &chan->used_desc, node) {
+
+		/*
+		 * Incoming DMA requests may use multiple descriptors, due to
+		 * exceeding xfercap, perhaps. If so, only the last one will
+		 * have a cookie, and require unmapping.
+		 */
+		if (desc->cookie) {
+			cookie = desc->cookie;
+
+			/* yes we are unmapping both _page and _single alloc'd
+			   regions with unmap_page. Is this *really* that bad?
+			*/
+			pci_unmap_page(chan->device->pdev,
+					pci_unmap_addr(desc, dst),
+					pci_unmap_len(desc, dst_len),
+					PCI_DMA_FROMDEVICE);
+			pci_unmap_page(chan->device->pdev,
+					pci_unmap_addr(desc, src),
+					pci_unmap_len(desc, src_len),
+					PCI_DMA_TODEVICE);
+		}
+
+		if (desc->phys != phys_complete) {
+			/* a completed entry, but not the last, so cleanup */
+			list_del(&desc->node);
+			list_add_tail(&desc->node, &chan->free_desc);
+		} else {
+			/* last used desc. Do not remove, so we can append from
+			   it, but don't look at it next time, either */
+			desc->cookie = 0;
+
+			/* TODO check status bits? */
+			break;
+		}
+	}
+
+	spin_unlock_bh(&chan->desc_lock);
+
+	chan->last_completion = phys_complete;
+	if (cookie != 0)
+		chan->completed_cookie = cookie;
+
+	spin_unlock(&chan->cleanup_lock);
+}
+
+/**
+ * ioat_dma_is_complete - poll the status of a IOAT DMA transaction
+ * @chan: IOAT DMA channel handle
+ * @cookie: DMA transaction identifier
+ */
+
+static enum dma_status ioat_dma_is_complete(struct dma_chan *chan, dma_cookie_t cookie, dma_cookie_t *done, dma_cookie_t *used)
+{
+	struct ioat_dma_chan *ioat_chan = to_ioat_chan(chan);
+	dma_cookie_t last_used;
+	dma_cookie_t last_complete;
+	enum dma_status ret;
+
+	last_used = chan->cookie;
+	last_complete = ioat_chan->completed_cookie;
+
+	if (done)
+		*done= last_complete;
+	if (used)
+		*used = last_used;
+
+	ret = dma_async_is_complete(cookie, last_complete, last_used);
+	if (ret == DMA_SUCCESS)
+		return ret;
+
+	ioat_dma_memcpy_cleanup(ioat_chan);
+
+	last_used = chan->cookie;
+	last_complete = ioat_chan->completed_cookie;
+
+	if (done)
+		*done= last_complete;
+	if (used)
+		*used = last_used;
+
+	return dma_async_is_complete(cookie, last_complete, last_used);
+}
+
+/* PCI API */
+
+static struct pci_device_id ioat_pci_tbl[] = {
+	{ PCI_DEVICE(PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_IOAT) },
+	{ 0, }
+};
+
+static struct pci_driver ioat_pci_drv = {
+	.name 	= "ioatdma",
+	.id_table = ioat_pci_tbl,
+	.probe	= ioat_probe,
+	.remove	= __devexit_p(ioat_remove),
+};
+
+static irqreturn_t ioat_do_interrupt(int irq, void *data, struct pt_regs *regs)
+{
+	struct ioat_device *instance = data;
+	unsigned long attnstatus;
+	u8 intrctrl;
+
+	intrctrl = ioatdma_read8(instance, IOAT_INTRCTRL_OFFSET);
+
+	if (!(intrctrl & IOAT_INTRCTRL_MASTER_INT_EN))
+		return IRQ_NONE;
+
+	if (!(intrctrl & IOAT_INTRCTRL_INT_STATUS)) {
+		ioatdma_write8(instance, IOAT_INTRCTRL_OFFSET, intrctrl);
+		return IRQ_NONE;
+	}
+
+	attnstatus = ioatdma_read32(instance, IOAT_ATTNSTATUS_OFFSET);
+
+	printk(KERN_ERR "ioatdma error: interrupt! status %lx\n", attnstatus);
+
+	ioatdma_write8(instance, IOAT_INTRCTRL_OFFSET, intrctrl);
+	return IRQ_HANDLED;
+}
+
+static void ioat_start_null_desc(struct ioat_dma_chan *ioat_chan)
+{
+	struct ioat_desc_sw *desc;
+
+	spin_lock_bh(&ioat_chan->desc_lock);
+
+	if (!list_empty(&ioat_chan->free_desc)) {
+		desc = to_ioat_desc(ioat_chan->free_desc.next);
+		list_del(&desc->node);
+	} else {
+		/* try to get another desc */
+		desc = ioat_dma_alloc_descriptor(ioat_chan, GFP_KERNEL);
+		/* will this ever happen? */
+		BUG_ON(!desc);
+	}
+
+	desc->hw->ctl = IOAT_DMA_DESCRIPTOR_NUL;
+	desc->hw->next = 0;
+
+	list_add_tail(&desc->node, &ioat_chan->used_desc);
+
+#if (BITS_PER_LONG == 64)
+	ioatdma_chan_write64(ioat_chan, IOAT_CHAINADDR_OFFSET, desc->phys);
+#else
+	ioatdma_chan_write32(ioat_chan, IOAT_CHAINADDR_OFFSET_LOW, (u32) desc->phys);
+	ioatdma_chan_write32(ioat_chan, IOAT_CHAINADDR_OFFSET_HIGH, 0);
+#endif
+	ioatdma_chan_write8(ioat_chan, IOAT_CHANCMD_OFFSET, IOAT_CHANCMD_START);
+
+	spin_unlock_bh(&ioat_chan->desc_lock);
+}
+
+/*
+ * Perform a IOAT transaction to verify the HW works.
+ */
+#define IOAT_TEST_SIZE 2000
+
+static int ioat_self_test(struct ioat_device *device)
+{
+	int i;
+	u8 *src;
+	u8 *dest;
+	struct dma_chan *dma_chan;
+	dma_cookie_t cookie;
+	int err = 0;
+
+	src = kzalloc(sizeof(u8) * IOAT_TEST_SIZE, SLAB_KERNEL);
+	if (!src)
+		return -ENOMEM;
+	dest = kzalloc(sizeof(u8) * IOAT_TEST_SIZE, SLAB_KERNEL);
+	if (!dest) {
+		kfree(src);
+		return -ENOMEM;
+	}
+
+	/* Fill in src buffer */
+	for (i = 0; i < IOAT_TEST_SIZE; i++)
+		src[i] = (u8)i;
+
+	/* Start copy, using first DMA channel */
+	dma_chan = container_of(device->common.channels.next,
+	                        struct dma_chan,
+	                        device_node);
+	if (ioat_dma_alloc_chan_resources(dma_chan) < 1) {
+		err = -ENODEV;
+		goto out;
+	}
+
+	cookie = ioat_dma_memcpy_buf_to_buf(dma_chan, dest, src, IOAT_TEST_SIZE);
+	ioat_dma_memcpy_issue_pending(dma_chan);
+	msleep(1);
+
+	if (ioat_dma_is_complete(dma_chan, cookie, NULL, NULL) != DMA_SUCCESS) {
+		printk(KERN_ERR "ioatdma: Self-test copy timed out, disabling\n");
+		err = -ENODEV;
+		goto free_resources;
+	}
+	if (memcmp(src, dest, IOAT_TEST_SIZE)) {
+		printk(KERN_ERR "ioatdma: Self-test copy failed compare, disabling\n");
+		err = -ENODEV;
+		goto free_resources;
+	}
+
+free_resources:
+	ioat_dma_free_chan_resources(dma_chan);
+out:
+	kfree(src);
+	kfree(dest);
+	return err;
+}
+
+static int __devinit ioat_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+{
+	int err;
+	unsigned long mmio_start, mmio_len;
+	void *reg_base;
+	struct ioat_device *device;
+
+	err = pci_enable_device(pdev);
+	if (err)
+		goto err_enable_device;
+
+	err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
+	if (err)
+		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+	if (err)
+		goto err_set_dma_mask;
+
+	err = pci_request_regions(pdev, ioat_pci_drv.name);
+	if (err)
+		goto err_request_regions;
+
+	mmio_start = pci_resource_start(pdev, 0);
+	mmio_len = pci_resource_len(pdev, 0);
+
+	reg_base = ioremap(mmio_start, mmio_len);
+	if (!reg_base) {
+		err = -ENOMEM;
+		goto err_ioremap;
+	}
+
+	device = kzalloc(sizeof(*device), GFP_KERNEL);
+	if (!device) {
+		err = -ENOMEM;
+		goto err_kzalloc;
+	}
+
+	/* DMA coherent memory pool for DMA descriptor allocations */
+	device->dma_pool = pci_pool_create("dma_desc_pool", pdev,
+		sizeof(struct ioat_dma_descriptor), 64, 0);
+	if (!device->dma_pool) {
+		err = -ENOMEM;
+		goto err_dma_pool;
+	}
+
+	device->completion_pool = pci_pool_create("completion_pool", pdev, sizeof(u64), SMP_CACHE_BYTES, SMP_CACHE_BYTES);
+	if (!device->completion_pool) {
+		err = -ENOMEM;
+		goto err_completion_pool;
+	}
+
+	device->pdev = pdev;
+	pci_set_drvdata(pdev, device);
+#ifdef CONFIG_PCI_MSI
+	if (pci_enable_msi(pdev) == 0) {
+		device->msi = 1;
+	} else {
+		device->msi = 0;
+	}
+#endif
+	err = request_irq(pdev->irq, &ioat_do_interrupt, SA_SHIRQ, "ioat",
+		device);
+	if (err)
+		goto err_irq;
+
+	device->reg_base = reg_base;
+
+	ioatdma_write8(device, IOAT_INTRCTRL_OFFSET, IOAT_INTRCTRL_MASTER_INT_EN);
+	pci_set_master(pdev);
+
+	INIT_LIST_HEAD(&device->common.channels);
+	enumerate_dma_channels(device);
+
+	device->common.device_alloc_chan_resources = ioat_dma_alloc_chan_resources;
+	device->common.device_free_chan_resources = ioat_dma_free_chan_resources;
+	device->common.device_memcpy_buf_to_buf = ioat_dma_memcpy_buf_to_buf;
+	device->common.device_memcpy_buf_to_pg = ioat_dma_memcpy_buf_to_pg;
+	device->common.device_memcpy_pg_to_pg = ioat_dma_memcpy_pg_to_pg;
+	device->common.device_memcpy_complete = ioat_dma_is_complete;
+	device->common.device_memcpy_issue_pending = ioat_dma_memcpy_issue_pending;
+	printk(KERN_INFO "Intel(R) I/OAT DMA Engine found, %d channels\n",
+		device->common.chancnt);
+
+	err = ioat_self_test(device);
+	if (err)
+		goto err_self_test;
+
+	dma_async_device_register(&device->common);
+
+	return 0;
+
+err_self_test:
+err_irq:
+	pci_pool_destroy(device->completion_pool);
+err_completion_pool:
+	pci_pool_destroy(device->dma_pool);
+err_dma_pool:
+	kfree(device);
+err_kzalloc:
+	iounmap(reg_base);
+err_ioremap:
+	pci_release_regions(pdev);
+err_request_regions:
+err_set_dma_mask:
+	pci_disable_device(pdev);
+err_enable_device:
+	return err;
+}
+
+static void __devexit ioat_remove(struct pci_dev *pdev)
+{
+	struct ioat_device *device;
+
+	device = pci_get_drvdata(pdev);
+	dma_async_device_unregister(&device->common);
+
+	free_irq(device->pdev->irq, device);
+#ifdef CONFIG_PCI_MSI
+	if (device->msi)
+		pci_disable_msi(device->pdev);
+#endif
+	pci_pool_destroy(device->dma_pool);
+	pci_pool_destroy(device->completion_pool);
+	iounmap(device->reg_base);
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+	kfree(device);
+}
+
+/* MODULE API */
+MODULE_VERSION("1.3");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Intel Corporation");
+
+static int __init ioat_init_module(void)
+{
+	/* it's currently unsafe to unload this module */
+	/* if forced, worst case is that rmmod hangs */
+	if (THIS_MODULE != NULL)
+		THIS_MODULE->unsafe = 1;
+
+	return pci_module_init(&ioat_pci_drv);
+}
+
+module_init(ioat_init_module);
+
+static void __exit ioat_exit_module(void)
+{
+	pci_unregister_driver(&ioat_pci_drv);
+}
+
+module_exit(ioat_exit_module);

