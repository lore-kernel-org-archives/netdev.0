From: Grant Likely <grant.likely@secretlab.ca>
Subject: [PATCH 05/37] arch/powerpc: use .dev.of_node instead of .node in
	struct of_device
Date: Thu, 11 Mar 2010 11:04:15 -0700
Message-ID: <20100311180415.4824.29410.stgit__38510.3372893811$1268331648$gmane$org@angua>
References: <20100311174830.4824.19820.stgit@angua>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: monstr@monstr.eu, gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, jgarzik@pobox.com, ben-linux@fluff.org,
	dwmw2@infrade
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:34774 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933553Ab0CKSET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 13:04:19 -0500
In-Reply-To: <20100311174830.4824.19820.stgit@angua>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

.node is being removed

Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
---

 arch/powerpc/include/asm/macio.h              |    2 +-
 arch/powerpc/kernel/ibmebus.c                 |    4 ++--
 arch/powerpc/kernel/of_device.c               |    8 ++++----
 arch/powerpc/kernel/of_platform.c             |   16 ++++++++--------
 arch/powerpc/platforms/52xx/mpc52xx_gpio.c    |    4 ++--
 arch/powerpc/platforms/52xx/mpc52xx_gpt.c     |   16 ++++++++--------
 arch/powerpc/platforms/52xx/mpc52xx_lpbfifo.c |    6 +++---
 arch/powerpc/platforms/82xx/ep8248e.c         |    6 +++---
 arch/powerpc/platforms/83xx/suspend.c         |    2 +-
 arch/powerpc/platforms/cell/axon_msi.c        |    2 +-
 arch/powerpc/platforms/pasemi/gpio_mdio.c     |    2 +-
 arch/powerpc/sysdev/axonram.c                 |    6 +++---
 arch/powerpc/sysdev/bestcomm/bestcomm.c       |    8 ++++----
 arch/powerpc/sysdev/fsl_msi.c                 |   14 +++++++-------
 arch/powerpc/sysdev/fsl_pmc.c                 |    2 +-
 arch/powerpc/sysdev/pmi.c                     |    2 +-
 16 files changed, 50 insertions(+), 50 deletions(-)

diff --git a/arch/powerpc/include/asm/macio.h b/arch/powerpc/include/asm/macio.h
index a062c57..19a661b 100644
--- a/arch/powerpc/include/asm/macio.h
+++ b/arch/powerpc/include/asm/macio.h
@@ -108,7 +108,7 @@ static inline void* macio_get_drvdata(struct macio_dev *dev)
 
 static inline struct device_node *macio_get_of_node(struct macio_dev *mdev)
 {
-	return mdev->ofdev.node;
+	return mdev->ofdev.dev.of_node;
 }
 
 #ifdef CONFIG_PCI
diff --git a/arch/powerpc/kernel/ibmebus.c b/arch/powerpc/kernel/ibmebus.c
index a4c8b38..797e9ac 100644
--- a/arch/powerpc/kernel/ibmebus.c
+++ b/arch/powerpc/kernel/ibmebus.c
@@ -139,14 +139,14 @@ static struct dma_map_ops ibmebus_dma_ops = {
 
 static int ibmebus_match_path(struct device *dev, void *data)
 {
-	struct device_node *dn = to_of_device(dev)->node;
+	struct device_node *dn = to_of_device(dev)->dev.of_node;
 	return (dn->full_name &&
 		(strcasecmp((char *)data, dn->full_name) == 0));
 }
 
 static int ibmebus_match_node(struct device *dev, void *data)
 {
-	return to_of_device(dev)->node == data;
+	return to_of_device(dev)->dev.of_node == data;
 }
 
 static int ibmebus_create_device(struct device_node *dn)
diff --git a/arch/powerpc/kernel/of_device.c b/arch/powerpc/kernel/of_device.c
index efbc262..55dafc7 100644
--- a/arch/powerpc/kernel/of_device.c
+++ b/arch/powerpc/kernel/of_device.c
@@ -13,7 +13,7 @@
 static void of_device_make_bus_id(struct of_device *dev)
 {
 	static atomic_t bus_no_reg_magic;
-	struct device_node *node = dev->node;
+	struct device_node *node = dev->dev.of_node;
 	const u32 *reg;
 	u64 addr;
 	int magic;
@@ -96,17 +96,17 @@ int of_device_uevent(struct device *dev, struct kobj_uevent_env *env)
 
 	ofdev = to_of_device(dev);
 
-	if (add_uevent_var(env, "OF_NAME=%s", ofdev->node->name))
+	if (add_uevent_var(env, "OF_NAME=%s", ofdev->dev.of_node->name))
 		return -ENOMEM;
 
-	if (add_uevent_var(env, "OF_TYPE=%s", ofdev->node->type))
+	if (add_uevent_var(env, "OF_TYPE=%s", ofdev->dev.of_node->type))
 		return -ENOMEM;
 
         /* Since the compatible field can contain pretty much anything
          * it's not really legal to split it out with commas. We split it
          * up using a number of environment variables instead. */
 
-	compat = of_get_property(ofdev->node, "compatible", &cplen);
+	compat = of_get_property(ofdev->dev.of_node, "compatible", &cplen);
 	while (compat && *compat && cplen > 0) {
 		if (add_uevent_var(env, "OF_COMPATIBLE_%d=%s", seen, compat))
 			return -ENOMEM;
diff --git a/arch/powerpc/kernel/of_platform.c b/arch/powerpc/kernel/of_platform.c
index 666d08d..5a5f624 100644
--- a/arch/powerpc/kernel/of_platform.c
+++ b/arch/powerpc/kernel/of_platform.c
@@ -196,7 +196,7 @@ EXPORT_SYMBOL(of_platform_bus_probe);
 
 static int of_dev_node_match(struct device *dev, void *data)
 {
-	return to_of_device(dev)->node == data;
+	return to_of_device(dev)->dev.of_node == data;
 }
 
 struct of_device *of_find_device_by_node(struct device_node *np)
@@ -214,7 +214,7 @@ EXPORT_SYMBOL(of_find_device_by_node);
 static int of_dev_phandle_match(struct device *dev, void *data)
 {
 	phandle *ph = data;
-	return to_of_device(dev)->node->phandle == *ph;
+	return to_of_device(dev)->dev.of_node->phandle == *ph;
 }
 
 struct of_device *of_find_device_by_phandle(phandle ph)
@@ -247,10 +247,10 @@ static int __devinit of_pci_phb_probe(struct of_device *dev,
 	if (ppc_md.pci_setup_phb == NULL)
 		return -ENODEV;
 
-	printk(KERN_INFO "Setting up PCI bus %s\n", dev->node->full_name);
+	pr_info("Setting up PCI bus %s\n", dev->dev.of_node->full_name);
 
 	/* Alloc and setup PHB data structure */
-	phb = pcibios_alloc_controller(dev->node);
+	phb = pcibios_alloc_controller(dev->dev.of_node);
 	if (!phb)
 		return -ENODEV;
 
@@ -264,19 +264,19 @@ static int __devinit of_pci_phb_probe(struct of_device *dev,
 	}
 
 	/* Process "ranges" property */
-	pci_process_bridge_OF_ranges(phb, dev->node, 0);
+	pci_process_bridge_OF_ranges(phb, dev->dev.of_node, 0);
 
 	/* Init pci_dn data structures */
 	pci_devs_phb_init_dynamic(phb);
 
 	/* Register devices with EEH */
 #ifdef CONFIG_EEH
-	if (dev->node->child)
-		eeh_add_device_tree_early(dev->node);
+	if (dev->dev.of_node->child)
+		eeh_add_device_tree_early(dev->dev.of_node);
 #endif /* CONFIG_EEH */
 
 	/* Scan the bus */
-	pcibios_scan_phb(phb, dev->node);
+	pcibios_scan_phb(phb, dev->dev.of_node);
 	if (phb->bus == NULL)
 		return -ENXIO;
 
diff --git a/arch/powerpc/platforms/52xx/mpc52xx_gpio.c b/arch/powerpc/platforms/52xx/mpc52xx_gpio.c
index 2b8d8ef..fce30e2 100644
--- a/arch/powerpc/platforms/52xx/mpc52xx_gpio.c
+++ b/arch/powerpc/platforms/52xx/mpc52xx_gpio.c
@@ -167,7 +167,7 @@ static int __devinit mpc52xx_wkup_gpiochip_probe(struct of_device *ofdev,
 	ofchip->gc.get              = mpc52xx_wkup_gpio_get;
 	ofchip->gc.set              = mpc52xx_wkup_gpio_set;
 
-	ret = of_mm_gpiochip_add(ofdev->node, &chip->mmchip);
+	ret = of_mm_gpiochip_add(ofdev->dev.of_node, &chip->mmchip);
 	if (ret)
 		return ret;
 
@@ -328,7 +328,7 @@ static int __devinit mpc52xx_simple_gpiochip_probe(struct of_device *ofdev,
 	ofchip->gc.get              = mpc52xx_simple_gpio_get;
 	ofchip->gc.set              = mpc52xx_simple_gpio_set;
 
-	ret = of_mm_gpiochip_add(ofdev->node, &chip->mmchip);
+	ret = of_mm_gpiochip_add(ofdev->dev.of_node, &chip->mmchip);
 	if (ret)
 		return ret;
 
diff --git a/arch/powerpc/platforms/52xx/mpc52xx_gpt.c b/arch/powerpc/platforms/52xx/mpc52xx_gpt.c
index 072b948..a34bffa 100644
--- a/arch/powerpc/platforms/52xx/mpc52xx_gpt.c
+++ b/arch/powerpc/platforms/52xx/mpc52xx_gpt.c
@@ -729,8 +729,8 @@ static int __devinit mpc52xx_gpt_probe(struct of_device *ofdev,
 
 	spin_lock_init(&gpt->lock);
 	gpt->dev = &ofdev->dev;
-	gpt->ipb_freq = mpc5xxx_get_bus_frequency(ofdev->node);
-	gpt->regs = of_iomap(ofdev->node, 0);
+	gpt->ipb_freq = mpc5xxx_get_bus_frequency(ofdev->dev.of_node);
+	gpt->regs = of_iomap(ofdev->dev.of_node, 0);
 	if (!gpt->regs) {
 		kfree(gpt);
 		return -ENOMEM;
@@ -738,21 +738,21 @@ static int __devinit mpc52xx_gpt_probe(struct of_device *ofdev,
 
 	dev_set_drvdata(&ofdev->dev, gpt);
 
-	mpc52xx_gpt_gpio_setup(gpt, ofdev->node);
-	mpc52xx_gpt_irq_setup(gpt, ofdev->node);
+	mpc52xx_gpt_gpio_setup(gpt, ofdev->dev.of_node);
+	mpc52xx_gpt_irq_setup(gpt, ofdev->dev.of_node);
 
 	mutex_lock(&mpc52xx_gpt_list_mutex);
 	list_add(&gpt->list, &mpc52xx_gpt_list);
 	mutex_unlock(&mpc52xx_gpt_list_mutex);
 
 	/* check if this device could be a watchdog */
-	if (of_get_property(ofdev->node, "fsl,has-wdt", NULL) ||
-	    of_get_property(ofdev->node, "has-wdt", NULL)) {
+	if (of_get_property(ofdev->dev.of_node, "fsl,has-wdt", NULL) ||
+	    of_get_property(ofdev->dev.of_node, "has-wdt", NULL)) {
 		const u32 *on_boot_wdt;
 
 		gpt->wdt_mode = MPC52xx_GPT_CAN_WDT;
-		on_boot_wdt = of_get_property(ofdev->node, "fsl,wdt-on-boot",
-					      NULL);
+		on_boot_wdt = of_get_property(ofdev->dev.of_node,
+					      "fsl,wdt-on-boot", NULL);
 		if (on_boot_wdt) {
 			dev_info(gpt->dev, "used as watchdog\n");
 			gpt->wdt_mode |= MPC52xx_GPT_IS_WDT;
diff --git a/arch/powerpc/platforms/52xx/mpc52xx_lpbfifo.c b/arch/powerpc/platforms/52xx/mpc52xx_lpbfifo.c
index 929d017..046d314 100644
--- a/arch/powerpc/platforms/52xx/mpc52xx_lpbfifo.c
+++ b/arch/powerpc/platforms/52xx/mpc52xx_lpbfifo.c
@@ -445,14 +445,14 @@ mpc52xx_lpbfifo_probe(struct of_device *op, const struct of_device_id *match)
 	if (lpbfifo.dev != NULL)
 		return -ENOSPC;
 
-	lpbfifo.irq = irq_of_parse_and_map(op->node, 0);
+	lpbfifo.irq = irq_of_parse_and_map(op->dev.of_node, 0);
 	if (!lpbfifo.irq)
 		return -ENODEV;
 
-	if (of_address_to_resource(op->node, 0, &res))
+	if (of_address_to_resource(op->dev.of_node, 0, &res))
 		return -ENODEV;
 	lpbfifo.regs_phys = res.start;
-	lpbfifo.regs = of_iomap(op->node, 0);
+	lpbfifo.regs = of_iomap(op->dev.of_node, 0);
 	if (!lpbfifo.regs)
 		return -ENOMEM;
 
diff --git a/arch/powerpc/platforms/82xx/ep8248e.c b/arch/powerpc/platforms/82xx/ep8248e.c
index f9aee18..3848500 100644
--- a/arch/powerpc/platforms/82xx/ep8248e.c
+++ b/arch/powerpc/platforms/82xx/ep8248e.c
@@ -118,12 +118,12 @@ static int __devinit ep8248e_mdio_probe(struct of_device *ofdev,
 	struct device_node *node;
 	int ret;
 
-	node = of_get_parent(ofdev->node);
+	node = of_get_parent(ofdev->dev.of_node);
 	of_node_put(node);
 	if (node != ep8248e_bcsr_node)
 		return -ENODEV;
 
-	ret = of_address_to_resource(ofdev->node, 0, &res);
+	ret = of_address_to_resource(ofdev->dev.of_node, 0, &res);
 	if (ret)
 		return ret;
 
@@ -141,7 +141,7 @@ static int __devinit ep8248e_mdio_probe(struct of_device *ofdev,
 	bus->parent = &ofdev->dev;
 	snprintf(bus->id, MII_BUS_ID_SIZE, "%x", res.start);
 
-	ret = of_mdiobus_register(bus, ofdev->node);
+	ret = of_mdiobus_register(bus, ofdev->dev.of_node);
 	if (ret)
 		goto err_free_irq;
 
diff --git a/arch/powerpc/platforms/83xx/suspend.c b/arch/powerpc/platforms/83xx/suspend.c
index 4380534..aa0b764 100644
--- a/arch/powerpc/platforms/83xx/suspend.c
+++ b/arch/powerpc/platforms/83xx/suspend.c
@@ -321,7 +321,7 @@ static struct platform_suspend_ops mpc83xx_suspend_ops = {
 static int pmc_probe(struct of_device *ofdev,
                      const struct of_device_id *match)
 {
-	struct device_node *np = ofdev->node;
+	struct device_node *np = ofdev->dev.of_node;
 	struct resource res;
 	struct pmc_type *type = match->data;
 	int ret = 0;
diff --git a/arch/powerpc/platforms/cell/axon_msi.c b/arch/powerpc/platforms/cell/axon_msi.c
index 96fe896..e341a70 100644
--- a/arch/powerpc/platforms/cell/axon_msi.c
+++ b/arch/powerpc/platforms/cell/axon_msi.c
@@ -344,7 +344,7 @@ static int axon_msi_shutdown(struct of_device *device)
 static int axon_msi_probe(struct of_device *device,
 			  const struct of_device_id *device_id)
 {
-	struct device_node *dn = device->node;
+	struct device_node *dn = device->dev.of_node;
 	struct axon_msic *msic;
 	unsigned int virq;
 	int dcr_base, dcr_len;
diff --git a/arch/powerpc/platforms/pasemi/gpio_mdio.c b/arch/powerpc/platforms/pasemi/gpio_mdio.c
index 3bf5467..b7027db 100644
--- a/arch/powerpc/platforms/pasemi/gpio_mdio.c
+++ b/arch/powerpc/platforms/pasemi/gpio_mdio.c
@@ -219,7 +219,7 @@ static int __devinit gpio_mdio_probe(struct of_device *ofdev,
 				     const struct of_device_id *match)
 {
 	struct device *dev = &ofdev->dev;
-	struct device_node *np = ofdev->node;
+	struct device_node *np = ofdev->dev.of_node;
 	struct mii_bus *new_bus;
 	struct gpio_priv *priv;
 	const unsigned int *prop;
diff --git a/arch/powerpc/sysdev/axonram.c b/arch/powerpc/sysdev/axonram.c
index 88f4ae7..88b21fc 100644
--- a/arch/powerpc/sysdev/axonram.c
+++ b/arch/powerpc/sysdev/axonram.c
@@ -185,7 +185,7 @@ axon_ram_probe(struct of_device *device, const struct of_device_id *device_id)
 	axon_ram_bank_id++;
 
 	dev_info(&device->dev, "Found memory controller on %s\n",
-			device->node->full_name);
+			device->dev.of_node->full_name);
 
 	bank = kzalloc(sizeof(struct axon_ram_bank), GFP_KERNEL);
 	if (bank == NULL) {
@@ -198,7 +198,7 @@ axon_ram_probe(struct of_device *device, const struct of_device_id *device_id)
 
 	bank->device = device;
 
-	if (of_address_to_resource(device->node, 0, &resource) != 0) {
+	if (of_address_to_resource(device->dev.of_node, 0, &resource) != 0) {
 		dev_err(&device->dev, "Cannot access device tree\n");
 		rc = -EFAULT;
 		goto failed;
@@ -253,7 +253,7 @@ axon_ram_probe(struct of_device *device, const struct of_device_id *device_id)
 	blk_queue_logical_block_size(bank->disk->queue, AXON_RAM_SECTOR_SIZE);
 	add_disk(bank->disk);
 
-	bank->irq_id = irq_of_parse_and_map(device->node, 0);
+	bank->irq_id = irq_of_parse_and_map(device->dev.of_node, 0);
 	if (bank->irq_id == NO_IRQ) {
 		dev_err(&device->dev, "Cannot access ECC interrupt ID\n");
 		rc = -EFAULT;
diff --git a/arch/powerpc/sysdev/bestcomm/bestcomm.c b/arch/powerpc/sysdev/bestcomm/bestcomm.c
index 378ebd9..d32d538 100644
--- a/arch/powerpc/sysdev/bestcomm/bestcomm.c
+++ b/arch/powerpc/sysdev/bestcomm/bestcomm.c
@@ -377,7 +377,7 @@ mpc52xx_bcom_probe(struct of_device *op, const struct of_device_id *match)
 	printk(KERN_INFO "DMA: MPC52xx BestComm driver\n");
 
 	/* Get the bestcomm node */
-	of_node_get(op->node);
+	of_node_get(op->dev.of_node);
 
 	/* Prepare SRAM */
 	ofn_sram = of_find_matching_node(NULL, mpc52xx_sram_ids);
@@ -406,10 +406,10 @@ mpc52xx_bcom_probe(struct of_device *op, const struct of_device_id *match)
 	}
 
 	/* Save the node */
-	bcom_eng->ofnode = op->node;
+	bcom_eng->ofnode = op->dev.of_node;
 
 	/* Get, reserve & map io */
-	if (of_address_to_resource(op->node, 0, &res_bcom)) {
+	if (of_address_to_resource(op->dev.of_node, 0, &res_bcom)) {
 		printk(KERN_ERR DRIVER_NAME ": "
 			"Can't get resource\n");
 		rv = -EINVAL;
@@ -453,7 +453,7 @@ error_sramclean:
 	kfree(bcom_eng);
 	bcom_sram_cleanup();
 error_ofput:
-	of_node_put(op->node);
+	of_node_put(op->dev.of_node);
 
 	printk(KERN_ERR "DMA: MPC52xx BestComm init failed !\n");
 
diff --git a/arch/powerpc/sysdev/fsl_msi.c b/arch/powerpc/sysdev/fsl_msi.c
index e094367..d17841f 100644
--- a/arch/powerpc/sysdev/fsl_msi.c
+++ b/arch/powerpc/sysdev/fsl_msi.c
@@ -248,7 +248,7 @@ static int __devinit fsl_of_msi_probe(struct of_device *dev,
 		goto error_out;
 	}
 
-	msi->irqhost = irq_alloc_host(dev->node, IRQ_HOST_MAP_LINEAR,
+	msi->irqhost = irq_alloc_host(dev->dev.of_node, IRQ_HOST_MAP_LINEAR,
 				      NR_MSI_IRQS, &fsl_msi_host_ops, 0);
 
 	if (msi->irqhost == NULL) {
@@ -258,10 +258,10 @@ static int __devinit fsl_of_msi_probe(struct of_device *dev,
 	}
 
 	/* Get the MSI reg base */
-	err = of_address_to_resource(dev->node, 0, &res);
+	err = of_address_to_resource(dev->dev.of_node, 0, &res);
 	if (err) {
 		dev_err(&dev->dev, "%s resource error!\n",
-				dev->node->full_name);
+				dev->dev.of_node->full_name);
 		goto error_out;
 	}
 
@@ -284,16 +284,16 @@ static int __devinit fsl_of_msi_probe(struct of_device *dev,
 		goto error_out;
 	}
 
-	p = of_get_property(dev->node, "interrupts", &count);
+	p = of_get_property(dev->dev.of_node, "interrupts", &count);
 	if (!p) {
 		dev_err(&dev->dev, "no interrupts property found on %s\n",
-				dev->node->full_name);
+				dev->dev.of_node->full_name);
 		err = -ENODEV;
 		goto error_out;
 	}
 	if (count % 8 != 0) {
 		dev_err(&dev->dev, "Malformed interrupts property on %s\n",
-				dev->node->full_name);
+				dev->dev.of_node->full_name);
 		err = -EINVAL;
 		goto error_out;
 	}
@@ -302,7 +302,7 @@ static int __devinit fsl_of_msi_probe(struct of_device *dev,
 	for (i = 0; i < count / 2; i++) {
 		if (i > NR_MSI_REG)
 			break;
-		virt_msir = irq_of_parse_and_map(dev->node, i);
+		virt_msir = irq_of_parse_and_map(dev->dev.of_node, i);
 		if (virt_msir != NO_IRQ) {
 			set_irq_data(virt_msir, (void *)i);
 			set_irq_chained_handler(virt_msir, fsl_msi_cascade);
diff --git a/arch/powerpc/sysdev/fsl_pmc.c b/arch/powerpc/sysdev/fsl_pmc.c
index a7635a9..2ebe817 100644
--- a/arch/powerpc/sysdev/fsl_pmc.c
+++ b/arch/powerpc/sysdev/fsl_pmc.c
@@ -60,7 +60,7 @@ static struct platform_suspend_ops pmc_suspend_ops = {
 
 static int pmc_probe(struct of_device *ofdev, const struct of_device_id *id)
 {
-	pmc_regs = of_iomap(ofdev->node, 0);
+	pmc_regs = of_iomap(ofdev->dev.of_node, 0);
 	if (!pmc_regs)
 		return -ENOMEM;
 
diff --git a/arch/powerpc/sysdev/pmi.c b/arch/powerpc/sysdev/pmi.c
index aaa9159..b92cb3a 100644
--- a/arch/powerpc/sysdev/pmi.c
+++ b/arch/powerpc/sysdev/pmi.c
@@ -123,7 +123,7 @@ static void pmi_notify_handlers(struct work_struct *work)
 static int pmi_of_probe(struct of_device *dev,
 			const struct of_device_id *match)
 {
-	struct device_node *np = dev->node;
+	struct device_node *np = dev->dev.of_node;
 	int rc;
 
 	if (data) {

