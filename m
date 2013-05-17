From: Tony Prisk <linux@prisktech.co.nz>
Subject: [PATCHv6 3/3] net: velocity: Add platform device support to VIA velocity driver
Date: Fri, 17 May 2013 17:21:18 +1200
Message-ID: <1368768078-16121-4-git-send-email-linux@prisktech.co.nz>
References: <1368768078-16121-1-git-send-email-linux@prisktech.co.nz>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	romieu@fr.zoreil.com, netdev@vger.kernel.org,
	Tony Prisk <linux@prisktech.co.nz>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server.prisktech.co.nz ([115.188.14.127]:63038 "EHLO
	server.prisktech.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753040Ab3EQFV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 01:21:29 -0400
In-Reply-To: <1368768078-16121-1-git-send-email-linux@prisktech.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the VIA Velocity network driver to be bound to a
OF created platform device.

Signed-off-by: Tony Prisk <linux@prisktech.co.nz>
---
 .../devicetree/bindings/net/via-velocity.txt       |   20 +
 drivers/net/ethernet/via/Kconfig                   |    3 +-
 drivers/net/ethernet/via/via-velocity.c            |  388 ++++++++++++++------
 drivers/net/ethernet/via/via-velocity.h            |   32 +-
 4 files changed, 321 insertions(+), 122 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/via-velocity.txt

diff --git a/Documentation/devicetree/bindings/net/via-velocity.txt b/Documentation/devicetree/bindings/net/via-velocity.txt
new file mode 100644
index 0000000..b3db469
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/via-velocity.txt
@@ -0,0 +1,20 @@
+* VIA Velocity 10/100/1000 Network Controller
+
+Required properties:
+- compatible : Should be "via,velocity-vt6110"
+- reg : Address and length of the io space
+- interrupts : Should contain the controller interrupt line
+
+Optional properties:
+- no-eeprom : PCI network cards use an external EEPROM to store data. Embedded
+	devices quite often set this data in uboot and do not provide an eeprom.
+	Specify this option if you have no external eeprom.
+
+Examples:
+
+eth0@d8004000 {
+	compatible = "via,velocity-vt6110";
+	reg = <0xd8004000 0x400>;
+	interrupts = <10>;
+	no-eeprom;
+};
diff --git a/drivers/net/ethernet/via/Kconfig b/drivers/net/ethernet/via/Kconfig
index 68a9ba6..6a87097 100644
--- a/drivers/net/ethernet/via/Kconfig
+++ b/drivers/net/ethernet/via/Kconfig
@@ -5,7 +5,6 @@
 config NET_VENDOR_VIA
 	bool "VIA devices"
 	default y
-	depends on PCI
 	---help---
 	  If you have a network (Ethernet) card belonging to this class, say Y
 	  and read the Ethernet-HOWTO, available from
@@ -45,7 +44,7 @@ config VIA_RHINE_MMIO
 
 config VIA_VELOCITY
 	tristate "VIA Velocity support"
-	depends on PCI
+	depends on (PCI || USE_OF)
 	select CRC32
 	select CRC_CCITT
 	select NET_CORE
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 5996cee..b30ab62 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -65,7 +65,11 @@
 #include <linux/if.h>
 #include <linux/uaccess.h>
 #include <linux/proc_fs.h>
+#include <linux/of_address.h>
+#include <linux/of_device.h>
+#include <linux/of_irq.h>
 #include <linux/inetdevice.h>
+#include <linux/platform_device.h>
 #include <linux/reboot.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
@@ -84,6 +88,16 @@
 static int velocity_nics;
 static int msglevel = MSG_LEVEL_INFO;
 
+static void velocity_set_power_state(struct velocity_info *vptr, char state)
+{
+	void *addr = vptr->mac_regs;
+
+	if (vptr->bustype == BUS_PCI)
+		pci_set_power_state(vptr->pdev, state);
+	else
+		writeb(state, addr + 0x154);
+}
+
 /**
  *	mac_get_cam_mask	-	Read a CAM mask
  *	@regs: register block for this velocity
@@ -362,12 +376,23 @@ static struct velocity_info_tbl chip_info_table[] = {
  *	Describe the PCI device identifiers that we support in this
  *	device driver. Used for hotplug autoloading.
  */
-static DEFINE_PCI_DEVICE_TABLE(velocity_id_table) = {
+
+static DEFINE_PCI_DEVICE_TABLE(velocity_pci_id_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_VIA, PCI_DEVICE_ID_VIA_612X) },
 	{ }
 };
 
-MODULE_DEVICE_TABLE(pci, velocity_id_table);
+MODULE_DEVICE_TABLE(pci, velocity_pci_id_table);
+
+/**
+ *	Describe the OF device identifiers that we support in this
+ *	device driver. Used for devicetree nodes.
+ */
+static struct of_device_id velocity_of_ids[] = {
+	{ .compatible = "via,velocity-vt6110", .data = &chip_info_table[0] },
+	{ /* Sentinel */ },
+};
+MODULE_DEVICE_TABLE(of, velocity_of_ids);
 
 /**
  *	get_chip_name	- 	identifier to name
@@ -386,29 +411,6 @@ static const char *get_chip_name(enum chip_type chip_id)
 }
 
 /**
- *	velocity_remove1	-	device unplug
- *	@pdev: PCI device being removed
- *
- *	Device unload callback. Called on an unplug or on module
- *	unload for each active device that is present. Disconnects
- *	the device from the network layer and frees all the resources
- */
-static void velocity_remove1(struct pci_dev *pdev)
-{
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct velocity_info *vptr = netdev_priv(dev);
-
-	unregister_netdev(dev);
-	iounmap(vptr->mac_regs);
-	pci_release_regions(pdev);
-	pci_disable_device(pdev);
-	pci_set_drvdata(pdev, NULL);
-	free_netdev(dev);
-
-	velocity_nics--;
-}
-
-/**
  *	velocity_set_int_opt	-	parser for integer options
  *	@opt: pointer to option value
  *	@val: value the user requested (or -1 for default)
@@ -1181,6 +1183,17 @@ static void mii_init(struct velocity_info *vptr, u32 mii_status)
 	u16 BMCR;
 
 	switch (PHYID_GET_PHY_ID(vptr->phy_id)) {
+	case PHYID_ICPLUS_IP101A:
+		MII_REG_BITS_ON((ADVERTISE_PAUSE_ASYM | ADVERTISE_PAUSE_CAP),
+						MII_ADVERTISE, vptr->mac_regs);
+		if (vptr->mii_status & VELOCITY_DUPLEX_FULL)
+			MII_REG_BITS_ON(TCSR_ECHODIS, MII_SREVISION,
+								vptr->mac_regs);
+		else
+			MII_REG_BITS_OFF(TCSR_ECHODIS, MII_SREVISION,
+								vptr->mac_regs);
+		MII_REG_BITS_ON(PLED_LALBE, MII_TPISTATUS, vptr->mac_regs);
+		break;
 	case PHYID_CICADA_CS8201:
 		/*
 		 *	Reset to hardware default
@@ -1353,9 +1366,12 @@ static void velocity_init_registers(struct velocity_info *vptr,
 		velocity_soft_reset(vptr);
 		mdelay(5);
 
-		mac_eeprom_reload(regs);
-		for (i = 0; i < 6; i++)
-			writeb(vptr->netdev->dev_addr[i], &(regs->PAR[i]));
+		if (!vptr->no_eeprom) {
+			mac_eeprom_reload(regs);
+			for (i = 0; i < 6; i++)
+				writeb(vptr->netdev->dev_addr[i],
+							&(regs->PAR[i]));
+		}
 
 		/*
 		 *	clear Pre_ACPI bit.
@@ -2233,15 +2249,15 @@ static int velocity_open(struct net_device *dev)
 		goto out;
 
 	/* Ensure chip is running */
-	pci_set_power_state(vptr->pdev, PCI_D0);
+	velocity_set_power_state(vptr, PCI_D0);
 
 	velocity_init_registers(vptr, VELOCITY_INIT_COLD);
 
-	ret = request_irq(vptr->pdev->irq, velocity_intr, IRQF_SHARED,
+	ret = request_irq(dev->irq, velocity_intr, IRQF_SHARED,
 			  dev->name, dev);
 	if (ret < 0) {
 		/* Power down the chip */
-		pci_set_power_state(vptr->pdev, PCI_D3hot);
+		velocity_set_power_state(vptr, PCI_D3hot);
 		velocity_free_rings(vptr);
 		goto out;
 	}
@@ -2314,6 +2330,7 @@ static int velocity_change_mtu(struct net_device *dev, int new_mtu)
 
 		tmp_vptr->netdev = dev;
 		tmp_vptr->pdev = vptr->pdev;
+		tmp_vptr->dev = vptr->dev;
 		tmp_vptr->options = vptr->options;
 		tmp_vptr->tx.numq = vptr->tx.numq;
 
@@ -2413,7 +2430,7 @@ static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	   saving then we need to bring the device back up to talk to it */
 
 	if (!netif_running(dev))
-		pci_set_power_state(vptr->pdev, PCI_D0);
+		velocity_set_power_state(vptr, PCI_D0);
 
 	switch (cmd) {
 	case SIOCGMIIPHY:	/* Get address of MII PHY in use. */
@@ -2426,7 +2443,7 @@ static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		ret = -EOPNOTSUPP;
 	}
 	if (!netif_running(dev))
-		pci_set_power_state(vptr->pdev, PCI_D3hot);
+		velocity_set_power_state(vptr, PCI_D3hot);
 
 
 	return ret;
@@ -2492,7 +2509,7 @@ static int velocity_close(struct net_device *dev)
 	if (vptr->flags & VELOCITY_FLAGS_WOL_ENABLED)
 		velocity_get_ip(vptr);
 
-	free_irq(vptr->pdev->irq, dev);
+	free_irq(dev->irq, dev);
 
 	velocity_free_rings(vptr);
 
@@ -2631,13 +2648,9 @@ static const struct net_device_ops velocity_netdev_ops = {
  *	Set up the initial velocity_info struct for the device that has been
  *	discovered.
  */
-static void velocity_init_info(struct pci_dev *pdev, struct velocity_info *vptr,
-			       const struct velocity_info_tbl *info)
+static void velocity_init_info(struct velocity_info *vptr,
+				const struct velocity_info_tbl *info)
 {
-	memset(vptr, 0, sizeof(struct velocity_info));
-
-	vptr->dev = &pdev->dev;
-	vptr->pdev = pdev;
 	vptr->chip_id = info->chip_id;
 	vptr->tx.numq = info->txqueue;
 	vptr->multicast_limit = MCAM_SIZE;
@@ -2652,10 +2665,9 @@ static void velocity_init_info(struct pci_dev *pdev, struct velocity_info *vptr,
  *	Retrieve the PCI configuration space data that interests us from
  *	the kernel PCI layer
  */
-static int velocity_get_pci_info(struct velocity_info *vptr,
-				 struct pci_dev *pdev)
+static int velocity_get_pci_info(struct velocity_info *vptr)
 {
-	vptr->rev_id = pdev->revision;
+	struct pci_dev *pdev = vptr->pdev;
 
 	pci_set_master(pdev);
 
@@ -2678,7 +2690,37 @@ static int velocity_get_pci_info(struct velocity_info *vptr,
 		dev_err(&pdev->dev, "region #1 is too small.\n");
 		return -EINVAL;
 	}
-	vptr->pdev = pdev;
+
+	return 0;
+}
+
+/**
+ *	velocity_get_platform_info - retrieve platform info for device
+ *	@vptr: velocity device
+ *	@pdev: platform device it matches
+ *
+ *	Retrieve the Platform configuration data that interests us
+ */
+static int velocity_get_platform_info(struct velocity_info *vptr)
+{
+	struct resource res;
+	int ret;
+
+	if (of_get_property(vptr->dev->of_node, "no-eeprom", NULL))
+		vptr->no_eeprom = 1;
+
+	ret = of_address_to_resource(vptr->dev->of_node, 0, &res);
+	if (ret) {
+		dev_err(vptr->dev, "unable to find memory address\n");
+		return ret;
+	}
+
+	vptr->memaddr = res.start;
+
+	if (resource_size(&res) < VELOCITY_IO_SIZE) {
+		dev_err(vptr->dev, "memory region is too small.\n");
+		return -EINVAL;
+	}
 
 	return 0;
 }
@@ -2707,21 +2749,22 @@ static u32 velocity_get_link(struct net_device *dev)
 }
 
 /**
- *	velocity_found1		-	set up discovered velocity card
+ *	velocity_probe - set up discovered velocity device
  *	@pdev: PCI device
  *	@ent: PCI device table entry that matched
+ *	@bustype: bus that device is connected to
  *
  *	Configure a discovered adapter from scratch. Return a negative
  *	errno error code on failure paths.
  */
-static int velocity_found1(struct pci_dev *pdev,
-			   const struct pci_device_id *ent)
+static int velocity_probe(struct device *dev, int irq,
+			   const struct velocity_info_tbl *info,
+			   enum velocity_bus_type bustype)
 {
 	static int first = 1;
-	struct net_device *dev;
+	struct net_device *netdev;
 	int i;
 	const char *drv_string;
-	const struct velocity_info_tbl *info = &chip_info_table[ent->driver_data];
 	struct velocity_info *vptr;
 	struct mac_regs __iomem *regs;
 	int ret = -ENOMEM;
@@ -2730,19 +2773,19 @@ static int velocity_found1(struct pci_dev *pdev,
 	 * can support more than MAX_UNITS.
 	 */
 	if (velocity_nics >= MAX_UNITS) {
-		dev_notice(&pdev->dev, "already found %d NICs.\n",
-			   velocity_nics);
+		dev_notice(dev, "already found %d NICs.\n", velocity_nics);
 		return -ENODEV;
 	}
 
-	dev = alloc_etherdev(sizeof(struct velocity_info));
-	if (!dev)
+	netdev = alloc_etherdev(sizeof(struct velocity_info));
+	if (!netdev)
 		goto out;
 
 	/* Chain it all together */
 
-	SET_NETDEV_DEV(dev, &pdev->dev);
-	vptr = netdev_priv(dev);
+	SET_NETDEV_DEV(netdev, dev);
+	vptr = netdev_priv(netdev);
+	memset(vptr, 0, sizeof(struct velocity_info));
 
 	if (first) {
 		printk(KERN_INFO "%s Ver. %s\n",
@@ -2752,41 +2795,41 @@ static int velocity_found1(struct pci_dev *pdev,
 		first = 0;
 	}
 
-	velocity_init_info(pdev, vptr, info);
-
-	vptr->netdev = dev;
+	netdev->irq = irq;
+	vptr->bustype = bustype;
+	vptr->netdev = netdev;
+	vptr->dev = dev;
 
-	ret = pci_enable_device(pdev);
-	if (ret < 0)
-		goto err_free_dev;
+	velocity_init_info(vptr, info);
 
-	ret = velocity_get_pci_info(vptr, pdev);
-	if (ret < 0) {
-		/* error message already printed */
-		goto err_disable;
-	}
+	if (vptr->bustype == BUS_PCI) {
+		vptr->pdev = to_pci_dev(dev);
 
-	ret = pci_request_regions(pdev, VELOCITY_NAME);
-	if (ret < 0) {
-		dev_err(&pdev->dev, "No PCI resources.\n");
-		goto err_disable;
+		ret = velocity_get_pci_info(vptr);
+		if (ret < 0)
+			goto err_free_dev;
+	} else {
+		ret = velocity_get_platform_info(vptr);
+		if (ret < 0)
+			goto err_free_dev;
 	}
 
 	regs = ioremap(vptr->memaddr, VELOCITY_IO_SIZE);
 	if (regs == NULL) {
 		ret = -EIO;
-		goto err_release_res;
+		goto err_free_dev;
 	}
 
 	vptr->mac_regs = regs;
+	vptr->rev_id = readb(&regs->rev_id);
 
 	mac_wol_reset(regs);
 
 	for (i = 0; i < 6; i++)
-		dev->dev_addr[i] = readb(&regs->PAR[i]);
+		netdev->dev_addr[i] = readb(&regs->PAR[i]);
 
 
-	drv_string = dev_driver_string(&pdev->dev);
+	drv_string = dev_driver_string(dev);
 
 	velocity_get_options(&vptr->options, velocity_nics, drv_string);
 
@@ -2807,46 +2850,125 @@ static int velocity_found1(struct pci_dev *pdev,
 
 	vptr->phy_id = MII_GET_PHY_ID(vptr->mac_regs);
 
-	dev->netdev_ops = &velocity_netdev_ops;
-	dev->ethtool_ops = &velocity_ethtool_ops;
-	netif_napi_add(dev, &vptr->napi, velocity_poll, VELOCITY_NAPI_WEIGHT);
+	netdev->netdev_ops = &velocity_netdev_ops;
+	netdev->ethtool_ops = &velocity_ethtool_ops;
+	netif_napi_add(netdev, &vptr->napi, velocity_poll,
+							VELOCITY_NAPI_WEIGHT);
 
-	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
+	netdev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
 			   NETIF_F_HW_VLAN_CTAG_TX;
-	dev->features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_FILTER |
-			 NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_IP_CSUM;
+	netdev->features |= NETIF_F_HW_VLAN_CTAG_TX |
+			NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_CTAG_RX |
+			NETIF_F_IP_CSUM;
 
-	ret = register_netdev(dev);
+	ret = register_netdev(netdev);
 	if (ret < 0)
 		goto err_iounmap;
 
-	if (!velocity_get_link(dev)) {
-		netif_carrier_off(dev);
+	if (!velocity_get_link(netdev)) {
+		netif_carrier_off(netdev);
 		vptr->mii_status |= VELOCITY_LINK_FAIL;
 	}
 
 	velocity_print_info(vptr);
-	pci_set_drvdata(pdev, dev);
+	dev_set_drvdata(vptr->dev, netdev);
 
 	/* and leave the chip powered down */
 
-	pci_set_power_state(pdev, PCI_D3hot);
+	velocity_set_power_state(vptr, PCI_D3hot);
 	velocity_nics++;
 out:
 	return ret;
 
 err_iounmap:
 	iounmap(regs);
-err_release_res:
-	pci_release_regions(pdev);
-err_disable:
-	pci_disable_device(pdev);
 err_free_dev:
-	free_netdev(dev);
+	free_netdev(netdev);
 	goto out;
 }
 
-#ifdef CONFIG_PM
+/**
+ *	velocity_remove	- device unplug
+ *	@dev: device being removed
+ *
+ *	Device unload callback. Called on an unplug or on module
+ *	unload for each active device that is present. Disconnects
+ *	the device from the network layer and frees all the resources
+ */
+static int velocity_remove(struct device *dev)
+{
+	struct net_device *netdev = dev_get_drvdata(dev);
+	struct velocity_info *vptr = netdev_priv(netdev);
+
+	unregister_netdev(netdev);
+	iounmap(vptr->mac_regs);
+	free_netdev(netdev);
+	velocity_nics--;
+
+	return 0;
+}
+
+static int velocity_pci_probe(struct pci_dev *pdev,
+			   const struct pci_device_id *ent)
+{
+	int ret;
+	const struct velocity_info_tbl *info =
+					&chip_info_table[ent->driver_data];
+
+	ret = pci_enable_device(pdev);
+	if (ret < 0)
+		return ret;
+
+	ret = pci_request_regions(pdev, VELOCITY_NAME);
+	if (ret < 0) {
+		dev_err(&pdev->dev, "No PCI resources.\n");
+		pci_disable_device(pdev);
+		return ret;
+	}
+
+	ret = velocity_probe(&pdev->dev, pdev->irq, info, BUS_PCI);
+	if (ret < 0) {
+		pci_release_regions(pdev);
+		pci_disable_device(pdev);
+	}
+
+	return ret;
+}
+
+static void velocity_pci_remove(struct pci_dev *pdev)
+{
+	velocity_remove(&pdev->dev);
+
+	pci_release_regions(pdev);
+	pci_disable_device(pdev);
+}
+
+static int velocity_platform_probe(struct platform_device *pdev)
+{
+	const struct of_device_id *of_id;
+	const struct velocity_info_tbl *info;
+	int irq;
+
+	of_id = of_match_device(velocity_of_ids, &pdev->dev);
+	if (!of_id)
+		return -EINVAL;
+	info = of_id->data;
+
+	irq = irq_of_parse_and_map(pdev->dev.of_node, 0);
+	if (!irq)
+		return -EINVAL;
+
+	return velocity_probe(&pdev->dev, irq, info, BUS_PLATFORM);
+}
+
+static int velocity_platform_remove(struct platform_device *pdev)
+{
+	velocity_remove(&pdev->dev);
+
+	return 0;
+}
+
+#ifdef CONFIG_PM_SLEEP
 /**
  *	wol_calc_crc		-	WOL CRC
  *	@pattern: data pattern
@@ -3003,10 +3125,10 @@ static void velocity_save_context(struct velocity_info *vptr, struct velocity_co
 
 }
 
-static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
+static int velocity_suspend(struct device *dev, pm_message_t state)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct velocity_info *vptr = netdev_priv(dev);
+	struct net_device *netdev = dev_get_drvdata(dev);
+	struct velocity_info *vptr = netdev_priv(netdev);
 	unsigned long flags;
 
 	if (!netif_running(vptr->netdev))
@@ -3015,20 +3137,24 @@ static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
 	netif_device_detach(vptr->netdev);
 
 	spin_lock_irqsave(&vptr->lock, flags);
-	pci_save_state(pdev);
+	if (vptr->bustype == BUS_PCI)
+		pci_save_state(vptr->pdev);
 
 	if (vptr->flags & VELOCITY_FLAGS_WOL_ENABLED) {
 		velocity_get_ip(vptr);
 		velocity_save_context(vptr, &vptr->context);
 		velocity_shutdown(vptr);
 		velocity_set_wol(vptr);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_set_power_state(pdev, PCI_D3hot);
+		if (vptr->bustype == BUS_PCI)
+			pci_enable_wake(vptr->pdev, PCI_D3hot, 1);
+		velocity_set_power_state(vptr, PCI_D3hot);
 	} else {
 		velocity_save_context(vptr, &vptr->context);
 		velocity_shutdown(vptr);
-		pci_disable_device(pdev);
-		pci_set_power_state(pdev, pci_choose_state(pdev, state));
+		if (vptr->bustype == BUS_PCI)
+			pci_disable_device(vptr->pdev);
+		velocity_set_power_state(vptr,
+				velocity_choose_state(vptr->dev, state));
 	}
 
 	spin_unlock_irqrestore(&vptr->lock, flags);
@@ -3070,19 +3196,22 @@ static void velocity_restore_context(struct velocity_info *vptr, struct velocity
 		writeb(*((u8 *) (context->mac_reg + i)), ptr + i);
 }
 
-static int velocity_resume(struct pci_dev *pdev)
+static int velocity_resume(struct device *dev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct velocity_info *vptr = netdev_priv(dev);
+	struct net_device *netdev = dev_get_drvdata(dev);
+	struct velocity_info *vptr = netdev_priv(netdev);
 	unsigned long flags;
 	int i;
 
 	if (!netif_running(vptr->netdev))
 		return 0;
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_enable_wake(pdev, 0, 0);
-	pci_restore_state(pdev);
+	velocity_set_power_state(vptr, PCI_D0);
+
+	if (vptr->bustype == BUS_PCI) {
+		pci_enable_wake(vptr->pdev, 0, 0);
+		pci_restore_state(vptr->pdev);
+	}
 
 	mac_wol_reset(vptr->mac_regs);
 
@@ -3104,23 +3233,34 @@ static int velocity_resume(struct pci_dev *pdev)
 
 	return 0;
 }
-#endif
+#endif	/* CONFIG_PM_SLEEP */
+
+static SIMPLE_DEV_PM_OPS(velocity_pm_ops, velocity_suspend, velocity_resume);
 
 /*
  *	Definition for our device driver. The PCI layer interface
  *	uses this to handle all our card discover and plugging
  */
-static struct pci_driver velocity_driver = {
+static struct pci_driver velocity_pci_driver = {
 	.name		= VELOCITY_NAME,
-	.id_table	= velocity_id_table,
-	.probe		= velocity_found1,
-	.remove		= velocity_remove1,
-#ifdef CONFIG_PM
-	.suspend	= velocity_suspend,
-	.resume		= velocity_resume,
-#endif
+	.id_table	= velocity_pci_id_table,
+	.probe		= velocity_pci_probe,
+	.remove		= velocity_pci_remove,
+	.driver = {
+		.pm = &velocity_pm_ops,
+	},
 };
 
+static struct platform_driver velocity_platform_driver = {
+	.probe		= velocity_platform_probe,
+	.remove		= velocity_platform_remove,
+	.driver = {
+		.name = "via-velocity",
+		.owner = THIS_MODULE,
+		.of_match_table = velocity_of_ids,
+		.pm = &velocity_pm_ops,
+	},
+};
 
 /**
  *	velocity_ethtool_up	-	pre hook for ethtool
@@ -3133,7 +3273,7 @@ static int velocity_ethtool_up(struct net_device *dev)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
 	if (!netif_running(dev))
-		pci_set_power_state(vptr->pdev, PCI_D0);
+		velocity_set_power_state(vptr, PCI_D0);
 	return 0;
 }
 
@@ -3148,7 +3288,7 @@ static void velocity_ethtool_down(struct net_device *dev)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
 	if (!netif_running(dev))
-		pci_set_power_state(vptr->pdev, PCI_D3hot);
+		velocity_set_power_state(vptr, PCI_D3hot);
 }
 
 static int velocity_get_settings(struct net_device *dev,
@@ -3270,7 +3410,11 @@ static void velocity_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo
 	struct velocity_info *vptr = netdev_priv(dev);
 	strlcpy(info->driver, VELOCITY_NAME, sizeof(info->driver));
 	strlcpy(info->version, VELOCITY_VERSION, sizeof(info->version));
-	strlcpy(info->bus_info, pci_name(vptr->pdev), sizeof(info->bus_info));
+	if (vptr->bustype == BUS_PCI)
+		strlcpy(info->bus_info, pci_name(vptr->pdev),
+						sizeof(info->bus_info));
+	else
+		strlcpy(info->bus_info, "platform", sizeof(info->bus_info));
 }
 
 static void velocity_ethtool_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
@@ -3563,9 +3707,15 @@ static int __init velocity_init_module(void)
 	int ret;
 
 	velocity_register_notifier();
-	ret = pci_register_driver(&velocity_driver);
+
+	ret = pci_register_driver(&velocity_pci_driver);
+	if (ret < 0)
+		velocity_unregister_notifier();
+
+	ret = platform_driver_register(&velocity_platform_driver);
 	if (ret < 0)
 		velocity_unregister_notifier();
+
 	return ret;
 }
 
@@ -3580,7 +3730,9 @@ static int __init velocity_init_module(void)
 static void __exit velocity_cleanup_module(void)
 {
 	velocity_unregister_notifier();
-	pci_unregister_driver(&velocity_driver);
+
+	pci_unregister_driver(&velocity_pci_driver);
+	platform_driver_unregister(&velocity_platform_driver);
 }
 
 module_init(velocity_init_module);
diff --git a/drivers/net/ethernet/via/via-velocity.h b/drivers/net/ethernet/via/via-velocity.h
index c38bbae..6be7e46 100644
--- a/drivers/net/ethernet/via/via-velocity.h
+++ b/drivers/net/ethernet/via/via-velocity.h
@@ -1265,7 +1265,7 @@ struct velocity_context {
 #define PHYID_VT3216_64BIT  0x000FC600UL
 #define PHYID_MARVELL_1000  0x01410C50UL
 #define PHYID_MARVELL_1000S 0x01410C40UL
-
+#define PHYID_ICPLUS_IP101A 0x02430C54UL
 #define PHYID_REV_ID_MASK   0x0000000FUL
 
 #define PHYID_GET_PHY_ID(i)         ((i) & ~PHYID_REV_ID_MASK)
@@ -1433,10 +1433,38 @@ struct velocity_opt {
 
 #define GET_RD_BY_IDX(vptr, idx)   (vptr->rd_ring[idx])
 
+static inline char velocity_choose_state(struct device *dev,
+					   pm_message_t state)
+
+{
+	switch (state.event) {
+	case PM_EVENT_ON:
+		return PCI_D0;
+	case PM_EVENT_FREEZE:
+	case PM_EVENT_PRETHAW:
+		/* REVISIT both freeze and pre-thaw "should" use D0 */
+	case PM_EVENT_SUSPEND:
+	case PM_EVENT_HIBERNATE:
+		return PCI_D3hot;
+	default:
+		dev_info(dev, "unrecognized suspend event %d\n", state.event);
+		BUG();
+	}
+
+	return PCI_D0;
+}
+
+enum velocity_bus_type {
+	BUS_PCI,
+	BUS_PLATFORM,
+};
+
 struct velocity_info {
-	struct device *dev;
 	struct pci_dev *pdev;
+	struct device *dev;
 	struct net_device *netdev;
+	enum velocity_bus_type bustype;
+	int no_eeprom;
 
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u8 ip_addr[4];
-- 
1.7.9.5
