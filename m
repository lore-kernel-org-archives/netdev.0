From: Alexey Charkov <alchark@gmail.com>
Subject: [PATCH 3/3] net: via-rhine: add OF bus binding
Date: Mon, 27 Jan 2014 15:51:43 +0400
Message-ID: <1390823503-24087-4-git-send-email-alchark@gmail.com>
References: <1385227995-3956-1-git-send-email-alchark@gmail.com>
 <1390823503-24087-1-git-send-email-alchark@gmail.com>
Cc: Alexey Charkov <alchark@gmail.com>
To: netdev@vger.kernel.org, linux@prisktech.co.nz,
	devicetree@vger.kernel.org, rl@hellgate.ch,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390823503-24087-1-git-send-email-alchark@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This should make the driver usable with VIA/WonderMedia ARM-based
Systems-on-Chip integrated Rhine III adapters. Note that these
are always in MMIO mode, and don't have any known EEPROM.

Signed-off-by: Alexey Charkov <alchark@gmail.com>
Signed-off-by: Roger Luethi <rl@hellgate.ch>
---
 .../devicetree/bindings/net/via-rhine.txt          |  18 ++
 drivers/net/ethernet/via/Kconfig                   |   2 +-
 drivers/net/ethernet/via/via-rhine.c               | 293 +++++++++++++--------
 3 files changed, 200 insertions(+), 113 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/via-rhine.txt

diff --git a/Documentation/devicetree/bindings/net/via-rhine.txt b/Documentation/devicetree/bindings/net/via-rhine.txt
new file mode 100644
index 0000000..684dd3a
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/via-rhine.txt
@@ -0,0 +1,18 @@
+* VIA Rhine 10/100 Network Controller
+
+Required properties:
+- compatible : Should be "via,rhine"
+- reg : Address and length of the io space
+- interrupts : Should contain the controller interrupt line
+- rhine,revision : Rhine core revision, used to inform the
+	driver of quirks and capabilities to expect from
+	the device. Mimics the respective PCI attribute.
+
+Examples:
+
+ethernet@d8004000 {
+	compatible = "via,rhine";
+	reg = <0xd8004000 0x100>;
+	interrupts = <10>;
+	rhine,revision = <0x84>;
+};
diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kconfig
index 8a049a2..f66ddae 100644
--- a/drivers/net/ethernet/via/Kconfig
+++ b/drivers/net/ethernet/via/Kconfig
@@ -19,7 +19,7 @@ if NET_VENDOR_VIA
 
 config VIA_RHINE
 	tristate "VIA Rhine support"
-	depends on PCI
+	depends on (PCI || USE_OF)
 	select CRC32
 	select MII
 	---help---
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 95c2e93..1c609c0 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -94,6 +94,10 @@ static const int multicast_filter_limit = 32;
 #include <linux/ioport.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
+#include <linux/of_address.h>
+#include <linux/of_device.h>
+#include <linux/of_irq.h>
+#include <linux/platform_device.h>
 #include <linux/dma-mapping.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -279,6 +283,11 @@ static DEFINE_PCI_DEVICE_TABLE(rhine_pci_tbl) = {
 };
 MODULE_DEVICE_TABLE(pci, rhine_pci_tbl);
 
+static struct of_device_id rhine_of_tbl[] = {
+	{ .compatible = "via,rhine" },
+	{ }	/* terminate list */
+};
+MODULE_DEVICE_TABLE(of, rhine_of_tbl);
 
 /* Offsets to the device registers. */
 enum register_offsets {
@@ -847,7 +856,8 @@ static void rhine_hw_init(struct net_device *dev, long pioaddr)
 		msleep(5);
 
 	/* Reload EEPROM controlled bytes cleared by soft reset */
-	rhine_reload_eeprom(pioaddr, dev);
+	if (!strncmp(dev->dev.parent->bus->name, "pci", 3))
+		rhine_reload_eeprom(pioaddr, dev);
 }
 
 static const struct net_device_ops rhine_netdev_ops = {
@@ -868,56 +878,13 @@ static const struct net_device_ops rhine_netdev_ops = {
 #endif
 };
 
-static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int rhine_init_one_common(struct device *hwdev, int revision,
+				 long pioaddr, void __iomem *ioaddr, int irq)
 {
 	struct net_device *dev;
 	struct rhine_private *rp;
-	struct device *hwdev = &pdev->dev;
-	int revision = pdev->revision;
-	int i, rc;
-	u32 quirks;
-	long pioaddr;
-	long memaddr;
-	void __iomem *ioaddr;
-	int io_size, phy_id;
+	int i, rc, phy_id;
 	const char *name;
-#ifdef USE_MMIO
-	int bar = 1;
-#else
-	int bar = 0;
-#endif
-
-/* when built into the kernel, we only print version if device is found */
-#ifndef MODULE
-	pr_info_once("%s\n", version);
-#endif
-
-	io_size = 256;
-	phy_id = 0;
-	quirks = 0;
-	name = "Rhine";
-	if (revision < VTunknown0) {
-		quirks = rqRhineI;
-		io_size = 128;
-	} else if (revision >= VT6102) {
-		quirks = rqWOL | rqForceReset;
-		if (revision < VT6105) {
-			name = "Rhine II";
-			quirks |= rqStatusWBRace;	/* Rhine-II exclusive */
-		} else {
-			phy_id = 1;	/* Integrated PHY, phy_id fixed to 1 */
-			if (revision >= VT6105_B0)
-				quirks |= rq6patterns;
-			if (revision < VT6105M)
-				name = "Rhine III";
-			else
-				name = "Rhine III (Management Adapter)";
-		}
-	}
-
-	rc = pci_enable_device(pdev);
-	if (rc)
-		goto err_out;
 
 	/* this should always be supported */
 	rc = dma_set_mask(hwdev, DMA_BIT_MASK(32));
@@ -926,19 +893,6 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out;
 	}
 
-	/* sanity check */
-	if ((pci_resource_len(pdev, 0) < io_size) ||
-	    (pci_resource_len(pdev, 1) < io_size)) {
-		rc = -EIO;
-		dev_err(hwdev, "Insufficient PCI resources, aborting\n");
-		goto err_out;
-	}
-
-	pioaddr = pci_resource_start(pdev, 0);
-	memaddr = pci_resource_start(pdev, 1);
-
-	pci_set_master(pdev);
-
 	dev = alloc_etherdev(sizeof(struct rhine_private));
 	if (!dev) {
 		rc = -ENOMEM;
@@ -949,44 +903,30 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	rp = netdev_priv(dev);
 	rp->dev = dev;
 	rp->revision = revision;
-	rp->quirks = quirks;
 	rp->pioaddr = pioaddr;
+	rp->base = ioaddr;
+	rp->irq = irq;
 	rp->msg_enable = netif_msg_init(debug, RHINE_MSG_DEFAULT);
 
-	rc = pci_request_regions(pdev, DRV_NAME);
-	if (rc)
-		goto err_out_free_netdev;
-
-	ioaddr = pci_iomap(pdev, bar, io_size);
-	if (!ioaddr) {
-		rc = -EIO;
-		dev_err(hwdev,
-			"ioremap failed for device %s, region 0x%X @ 0x%lX\n",
-			dev_name(hwdev), io_size, memaddr);
-		goto err_out_free_res;
-	}
-
-#ifdef USE_MMIO
-	enable_mmio(pioaddr, quirks);
-
-	/* Check that selected MMIO registers match the PIO ones */
-	i = 0;
-	while (mmio_verify_registers[i]) {
-		int reg = mmio_verify_registers[i++];
-		unsigned char a = inb(pioaddr+reg);
-		unsigned char b = readb(ioaddr+reg);
-		if (a != b) {
-			rc = -EIO;
-			dev_err(hwdev,
-				"MMIO do not match PIO [%02x] (%02x != %02x)\n",
-				reg, a, b);
-			goto err_out_unmap;
+	phy_id = 0;
+	name = "Rhine";
+	if (revision < VTunknown0) {
+		rp->quirks = rqRhineI;
+	} else if (revision >= VT6102) {
+		rp->quirks = rqWOL | rqForceReset;
+		if (revision < VT6105) {
+			name = "Rhine II";
+			rp->quirks |= rqStatusWBRace;	/* Rhine-II exclusive */
+		} else {
+			phy_id = 1;	/* Integrated PHY, phy_id fixed to 1 */
+			if (revision >= VT6105_B0)
+				rp->quirks |= rq6patterns;
+			if (revision < VT6105M)
+				name = "Rhine III";
+			else
+				name = "Rhine III (Management Adapter)";
 		}
 	}
-#endif /* USE_MMIO */
-
-	rp->base = ioaddr;
-	rp->irq = pdev->irq;
 
 	u64_stats_init(&rp->tx_stats.syncp);
 	u64_stats_init(&rp->rx_stats.syncp);
@@ -1039,16 +979,10 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* dev->name not defined before register_netdev()! */
 	rc = register_netdev(dev);
 	if (rc)
-		goto err_out_unmap;
+		goto err_out_free_netdev;
 
 	netdev_info(dev, "VIA %s at 0x%lx, %pM, IRQ %d\n",
-		    name,
-#ifdef USE_MMIO
-		    memaddr,
-#else
-		    (long)ioaddr,
-#endif
-		    dev->dev_addr, rp->irq);
+		    name, (long)ioaddr, dev->dev_addr, rp->irq);
 
 	dev_set_drvdata(hwdev, dev);
 
@@ -1079,16 +1013,118 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	return 0;
 
+err_out_free_netdev:
+	free_netdev(dev);
+err_out:
+	return rc;
+}
+
+static int rhine_init_one_pci(struct pci_dev *pdev,
+			      const struct pci_device_id *ent)
+{
+	struct device *hwdev = &pdev->dev;
+	int i, rc;
+	long pioaddr, memaddr;
+	void __iomem *ioaddr;
+	int io_size = pdev->revision < VTunknown0 ? 128 : 256;
+	u32 quirks = pdev->revision < VTunknown0 ? rqRhineI : 0;
+#ifdef USE_MMIO
+	int bar = 1;
+#else
+	int bar = 0;
+#endif
+
+/* when built into the kernel, we only print version if device is found */
+#ifndef MODULE
+	pr_info_once("%s\n", version);
+#endif
+
+	rc = pci_enable_device(pdev);
+	if (rc)
+		goto err_out;
+
+	/* sanity check */
+	if ((pci_resource_len(pdev, 0) < io_size) ||
+	    (pci_resource_len(pdev, 1) < io_size)) {
+		rc = -EIO;
+		dev_err(hwdev, "Insufficient PCI resources, aborting\n");
+		goto err_out;
+	}
+
+	pioaddr = pci_resource_start(pdev, 0);
+	memaddr = pci_resource_start(pdev, 1);
+
+	pci_set_master(pdev);
+
+	rc = pci_request_regions(pdev, DRV_NAME);
+	if (rc)
+		goto err_out;
+
+	ioaddr = pci_iomap(pdev, bar, io_size);
+	if (!ioaddr) {
+		rc = -EIO;
+		dev_err(hwdev,
+			"ioremap failed for device %s, region 0x%X @ 0x%lX\n",
+			dev_name(hwdev), io_size, memaddr);
+		goto err_out_free_res;
+	}
+
+#ifdef USE_MMIO
+	enable_mmio(pioaddr, quirks);
+
+	/* Check that selected MMIO registers match the PIO ones */
+	i = 0;
+	while (mmio_verify_registers[i]) {
+		int reg = mmio_verify_registers[i++];
+		unsigned char a = inb(pioaddr+reg);
+		unsigned char b = readb(ioaddr+reg);
+		if (a != b) {
+			rc = -EIO;
+			dev_err(hwdev,
+				"MMIO do not match PIO [%02x] (%02x != %02x)\n",
+				reg, a, b);
+			goto err_out_unmap;
+		}
+	}
+#endif /* USE_MMIO */
+
+	rc = rhine_init_one_common(&pdev->dev, pdev->revision,
+				   pioaddr, ioaddr, pdev->irq);
+	if (!rc)
+		return 0;
+
 err_out_unmap:
 	pci_iounmap(pdev, ioaddr);
 err_out_free_res:
 	pci_release_regions(pdev);
-err_out_free_netdev:
-	free_netdev(dev);
 err_out:
 	return rc;
 }
 
+static int rhine_init_one_platform(struct platform_device *pdev)
+{
+	const u32 *revision;
+	int irq;
+	struct resource *res;
+	void __iomem *ioaddr;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	ioaddr = devm_ioremap_resource(&pdev->dev, res);
+	if (IS_ERR(ioaddr))
+		return PTR_ERR(ioaddr);
+
+	irq = irq_of_parse_and_map(pdev->dev.of_node, 0);
+	if (!irq)
+		return -EINVAL;
+
+	revision = of_get_property(pdev->dev.of_node, "rhine,revision", NULL);
+	if (!revision)
+		return -EINVAL;
+
+	return rhine_init_one_common(&pdev->dev, *revision,
+				     (long)ioaddr, ioaddr, irq);
+}
+
 static int alloc_ring(struct net_device* dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
@@ -2295,7 +2331,7 @@ static int rhine_close(struct net_device *dev)
 }
 
 
-static void rhine_remove_one(struct pci_dev *pdev)
+static void rhine_remove_one_pci(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
@@ -2309,7 +2345,21 @@ static void rhine_remove_one(struct pci_dev *pdev)
 	pci_disable_device(pdev);
 }
 
-static void rhine_shutdown (struct pci_dev *pdev)
+static int rhine_remove_one_platform(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct rhine_private *rp = netdev_priv(dev);
+
+	unregister_netdev(dev);
+
+	iounmap(rp->base);
+
+	free_netdev(dev);
+
+	return 0;
+}
+
+static void rhine_shutdown_pci(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
@@ -2376,7 +2426,7 @@ static int rhine_suspend(struct device *device)
 	netif_device_detach(dev);
 
 	if (!strncmp(device->bus->name, "pci", 3))
-		rhine_shutdown(to_pci_dev(device));
+		rhine_shutdown_pci(to_pci_dev(device));
 
 	return 0;
 }
@@ -2416,15 +2466,26 @@ static SIMPLE_DEV_PM_OPS(rhine_pm_ops, rhine_suspend, rhine_resume);
 
 #endif /* !CONFIG_PM_SLEEP */
 
-static struct pci_driver rhine_driver = {
+static struct pci_driver rhine_driver_pci = {
 	.name		= DRV_NAME,
 	.id_table	= rhine_pci_tbl,
-	.probe		= rhine_init_one,
-	.remove		= rhine_remove_one,
-	.shutdown	= rhine_shutdown,
+	.probe		= rhine_init_one_pci,
+	.remove		= rhine_remove_one_pci,
+	.shutdown	= rhine_shutdown_pci,
 	.driver.pm	= RHINE_PM_OPS,
 };
 
+static struct platform_driver rhine_driver_platform = {
+	.probe		= rhine_init_one_platform,
+	.remove		= rhine_remove_one_platform,
+	.driver = {
+		.name	= DRV_NAME,
+		.owner	= THIS_MODULE,
+		.of_match_table	= rhine_of_tbl,
+		.pm		= RHINE_PM_OPS,
+	}
+};
+
 static struct dmi_system_id rhine_dmi_table[] __initdata = {
 	{
 		.ident = "EPIA-M",
@@ -2445,6 +2506,8 @@ static struct dmi_system_id rhine_dmi_table[] __initdata = {
 
 static int __init rhine_init(void)
 {
+	int ret_pci, ret_platform;
+
 /* when a module, this is printed whether or not devices are found in probe */
 #ifdef MODULE
 	pr_info("%s\n", version);
@@ -2457,13 +2520,19 @@ static int __init rhine_init(void)
 	else if (avoid_D3)
 		pr_info("avoid_D3 set\n");
 
-	return pci_register_driver(&rhine_driver);
+	ret_pci = pci_register_driver(&rhine_driver_pci);
+	ret_platform = platform_driver_register(&rhine_driver_platform);
+	if ((ret_pci < 0) && (ret_platform < 0))
+		return ret_pci;
+
+	return 0;
 }
 
 
 static void __exit rhine_cleanup(void)
 {
-	pci_unregister_driver(&rhine_driver);
+	platform_driver_unregister(&rhine_driver_platform);
+	pci_unregister_driver(&rhine_driver_pci);
 }
 
 
-- 
1.8.5.1
