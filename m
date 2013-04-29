From: Tony Prisk <linux@prisktech.co.nz>
Subject: [PATCHv2 3/3] net: velocity: Add platform device support to VIA velocity driver
Date: Mon, 29 Apr 2013 19:50:41 +1200
Message-ID: <1367221841-14563-4-git-send-email-linux@prisktech.co.nz>
References: <1367221841-14563-1-git-send-email-linux@prisktech.co.nz>
Cc: netdev@vger.kernel.org,
	vt8500-wm8505-linux-kernel@googlegroups.com,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Tony Prisk <linux@prisktech.co.nz>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1367221841-14563-1-git-send-email-linux@prisktech.co.nz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for the VIA Velocity network driver to be bound to a
OF created platform device.

Signed-off-by: Tony Prisk <linux@prisktech.co.nz>
---
 .../devicetree/bindings/net/via-velocity.txt       |   20 +
 drivers/net/ethernet/via/Kconfig                   |    3 +-
 drivers/net/ethernet/via/via-velocity.c            |  453 +++++++++++++++-----
 drivers/net/ethernet/via/via-velocity.h            |   30 +-
 4 files changed, 398 insertions(+), 108 deletions(-)
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
index e2c4887..03cc3ed 100644
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
@@ -362,12 +376,24 @@ static struct velocity_info_tbl chip_info_table[] = {
  *	Describe the PCI device identifiers that we support in this
  *	device driver. Used for hotplug autoloading.
  */
-static DEFINE_PCI_DEVICE_TABLE(velocity_id_table) = {
+#ifdef CONFIG_PCI
+static DEFINE_PCI_DEVICE_TABLE(velocity_pci_id_table) = {
 	{ PCI_DEVICE(PCI_VENDOR_ID_VIA, PCI_DEVICE_ID_VIA_612X) },
 	{ }
 };
 
-MODULE_DEVICE_TABLE(pci, velocity_id_table);
+MODULE_DEVICE_TABLE(pci, velocity_pci_id_table);
+#endif
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
@@ -386,29 +412,6 @@ static const char *get_chip_name(enum chip_type chip_id)
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
@@ -1179,6 +1182,14 @@ static void mii_init(struct velocity_info *vptr, u32 mii_status)
 	u16 BMCR;
 
 	switch (PHYID_GET_PHY_ID(vptr->phy_id)) {
+	case PHYID_ICPLUS_IP101A:
+		MII_REG_BITS_ON((ADVERTISE_PAUSE_ASYM | ADVERTISE_PAUSE_CAP), MII_ADVERTISE, vptr->mac_regs);
+		if (vptr->mii_status & VELOCITY_DUPLEX_FULL)
+			MII_REG_BITS_ON(TCSR_ECHODIS, MII_SREVISION, vptr->mac_regs);
+		else
+			MII_REG_BITS_OFF(TCSR_ECHODIS, MII_SREVISION, vptr->mac_regs);
+		MII_REG_BITS_ON(PLED_LALBE, MII_TPISTATUS, vptr->mac_regs);
+		break;
 	case PHYID_CICADA_CS8201:
 		/*
 		 *	Reset to hardware default
@@ -1351,9 +1362,12 @@ static void velocity_init_registers(struct velocity_info *vptr,
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
@@ -2231,15 +2245,15 @@ static int velocity_open(struct net_device *dev)
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
@@ -2411,7 +2425,7 @@ static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	   saving then we need to bring the device back up to talk to it */
 
 	if (!netif_running(dev))
-		pci_set_power_state(vptr->pdev, PCI_D0);
+		velocity_set_power_state(vptr, PCI_D0);
 
 	switch (cmd) {
 	case SIOCGMIIPHY:	/* Get address of MII PHY in use. */
@@ -2424,7 +2438,7 @@ static int velocity_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		ret = -EOPNOTSUPP;
 	}
 	if (!netif_running(dev))
-		pci_set_power_state(vptr->pdev, PCI_D3hot);
+		velocity_set_power_state(vptr, PCI_D3hot);
 
 
 	return ret;
@@ -2490,7 +2504,7 @@ static int velocity_close(struct net_device *dev)
 	if (vptr->flags & VELOCITY_FLAGS_WOL_ENABLED)
 		velocity_get_ip(vptr);
 
-	free_irq(vptr->pdev->irq, dev);
+	free_irq(dev->irq, dev);
 
 	velocity_free_rings(vptr);
 
@@ -2629,13 +2643,25 @@ static const struct net_device_ops velocity_netdev_ops = {
  *	Set up the initial velocity_info struct for the device that has been
  *	discovered.
  */
-static void velocity_init_info(struct pci_dev *pdev, struct velocity_info *vptr,
-			       const struct velocity_info_tbl *info)
+static void velocity_init_info(void *pdev,
+				struct velocity_info *vptr,
+				const struct velocity_info_tbl *info,
+				enum velocity_bus_type bustype)
 {
+	struct pci_dev *pci_dev;
+	struct platform_device *platform_dev;
+
 	memset(vptr, 0, sizeof(struct velocity_info));
 
-	vptr->dev = &pdev->dev;
-	vptr->pdev = pdev;
+	if (bustype == BUS_PCI) {
+		pci_dev = pdev;
+		vptr->pdev = pci_dev;
+		vptr->dev = &pci_dev->dev;
+	} else {
+		platform_dev = pdev;
+		vptr->dev = &platform_dev->dev;
+	}
+
 	vptr->chip_id = info->chip_id;
 	vptr->tx.numq = info->txqueue;
 	vptr->multicast_limit = MCAM_SIZE;
@@ -2653,8 +2679,6 @@ static void velocity_init_info(struct pci_dev *pdev, struct velocity_info *vptr,
 static int velocity_get_pci_info(struct velocity_info *vptr,
 				 struct pci_dev *pdev)
 {
-	vptr->rev_id = pdev->revision;
-
 	pci_set_master(pdev);
 
 	vptr->ioaddr = pci_resource_start(pdev, 0);
@@ -2676,12 +2700,45 @@ static int velocity_get_pci_info(struct velocity_info *vptr,
 		dev_err(&pdev->dev, "region #1 is too small.\n");
 		return -EINVAL;
 	}
+
 	vptr->pdev = pdev;
 
 	return 0;
 }
 
 /**
+ *	velocity_get_platform_info - retrieve platform info for device
+ *	@vptr: velocity device
+ *	@pdev: platform device it matches
+ *
+ *	Retrieve the Platform configuration data that interests us
+ */
+static int velocity_get_platform_info(struct velocity_info *vptr,
+					struct platform_device *pdev)
+{
+	int ret;
+	struct resource res;
+
+	if (of_get_property(pdev->dev.of_node, "no-eeprom", NULL))
+		vptr->no_eeprom = 1;
+
+	ret = of_address_to_resource(pdev->dev.of_node, 0, &res);
+	if (ret) {
+		dev_err(&pdev->dev, "unable to find memory address\n");
+		return ret;
+	}
+
+	vptr->memaddr = res.start;
+
+	if (resource_size(&res) < VELOCITY_IO_SIZE) {
+		dev_err(&pdev->dev, "memory region is too small.\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/**
  *	velocity_print_info	-	per driver data
  *	@vptr: velocity
  *
@@ -2705,42 +2762,59 @@ static u32 velocity_get_link(struct net_device *dev)
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
+static int velocity_probe(void *pdev,
+			   const struct pci_device_id *ent,
+			   enum velocity_bus_type bustype)
 {
 	static int first = 1;
-	struct net_device *dev;
+	struct pci_dev *pci_dev = NULL;
+	struct platform_device *platform_dev = NULL;
+	struct net_device *netdev;
+	struct device *dev;
+	const struct of_device_id *of_id;
 	int i;
 	const char *drv_string;
-	const struct velocity_info_tbl *info = &chip_info_table[ent->driver_data];
+	const struct velocity_info_tbl *info;
 	struct velocity_info *vptr;
 	struct mac_regs __iomem *regs;
+	int pci = (bustype == BUS_PCI) ? 1 : 0;
 	int ret = -ENOMEM;
 
+	if (pci) {
+		pci_dev = pdev;
+		dev = &pci_dev->dev;
+		info = &chip_info_table[ent->driver_data];
+	} else {
+		platform_dev = pdev;
+		dev = &platform_dev->dev;
+		of_id = of_match_device(velocity_of_ids, dev);
+		info = of_id->data;
+	}
+
 	/* FIXME: this driver, like almost all other ethernet drivers,
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
 
 	if (first) {
 		printk(KERN_INFO "%s Ver. %s\n",
@@ -2750,26 +2824,42 @@ static int velocity_found1(struct pci_dev *pdev,
 		first = 0;
 	}
 
-	velocity_init_info(pdev, vptr, info);
+	velocity_init_info(pdev, vptr, info, bustype);
+	vptr->bustype = bustype;
+	vptr->netdev = netdev;
 
-	vptr->netdev = dev;
-
-	ret = pci_enable_device(pdev);
-	if (ret < 0)
-		goto err_free_dev;
+	if (pci) {
+		ret = pci_enable_device(pci_dev);
+		if (ret < 0)
+			goto err_free_dev;
+		netdev->irq = pci_dev->irq;
+	} else {
+		netdev->irq =
+			irq_of_parse_and_map(platform_dev->dev.of_node, 0);
 
-	ret = velocity_get_pci_info(vptr, pdev);
-	if (ret < 0) {
-		/* error message already printed */
-		goto err_disable;
+		if (!netdev->irq) {
+			ret = -EINVAL;
+			goto err_free_dev;
+		}
 	}
 
-	ret = pci_request_regions(pdev, VELOCITY_NAME);
-	if (ret < 0) {
-		dev_err(&pdev->dev, "No PCI resources.\n");
-		goto err_disable;
+	if (pci) {
+		ret = velocity_get_pci_info(vptr, pci_dev);
+		if (ret < 0)
+			goto err_disable;
+
+		ret = pci_request_regions(pci_dev, VELOCITY_NAME);
+		if (ret < 0) {
+			dev_err(dev, "No PCI resources.\n");
+			goto err_disable;
+		}
+	} else {
+		ret = velocity_get_platform_info(vptr, platform_dev);
+		if (ret < 0)
+			goto err_disable;
 	}
 
+
 	regs = ioremap(vptr->memaddr, VELOCITY_IO_SIZE);
 	if (regs == NULL) {
 		ret = -EIO;
@@ -2778,13 +2868,18 @@ static int velocity_found1(struct pci_dev *pdev,
 
 	vptr->mac_regs = regs;
 
+	if (pci)
+		vptr->rev_id = pci_dev->revision;
+	else
+		vptr->rev_id = readb(&regs->rev_id);
+
 	mac_wol_reset(regs);
 
 	for (i = 0; i < 6; i++)
-		dev->dev_addr[i] = readb(&regs->PAR[i]);
+		netdev->dev_addr[i] = readb(&regs->PAR[i]);
 
 
-	drv_string = dev_driver_string(&pdev->dev);
+	drv_string = dev_driver_string(dev);
 
 	velocity_get_options(&vptr->options, velocity_nics, drv_string);
 
@@ -2805,29 +2900,32 @@ static int velocity_found1(struct pci_dev *pdev,
 
 	vptr->phy_id = MII_GET_PHY_ID(vptr->mac_regs);
 
-	dev->netdev_ops = &velocity_netdev_ops;
-	dev->ethtool_ops = &velocity_ethtool_ops;
-	netif_napi_add(dev, &vptr->napi, velocity_poll, VELOCITY_NAPI_WEIGHT);
+	netdev->netdev_ops = &velocity_netdev_ops;
+	netdev->ethtool_ops = &velocity_ethtool_ops;
+	netif_napi_add(netdev, &vptr->napi, velocity_poll, VELOCITY_NAPI_WEIGHT);
 
-	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_HW_VLAN_TX;
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
+	netdev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_HW_VLAN_TX;
+	netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER |
 		NETIF_F_HW_VLAN_RX | NETIF_F_IP_CSUM;
 
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
+	if (pci)
+		pci_set_drvdata(pci_dev, netdev);
+	else
+		platform_set_drvdata(platform_dev, netdev);
 
 	/* and leave the chip powered down */
 
-	pci_set_power_state(pdev, PCI_D3hot);
+	velocity_set_power_state(vptr, PCI_D3hot);
 	velocity_nics++;
 out:
 	return ret;
@@ -2835,14 +2933,79 @@ out:
 err_iounmap:
 	iounmap(regs);
 err_release_res:
-	pci_release_regions(pdev);
+	if (pci)
+		pci_release_regions(pci_dev);
 err_disable:
-	pci_disable_device(pdev);
+	if (pci)
+		pci_disable_device(pci_dev);
 err_free_dev:
-	free_netdev(dev);
+	free_netdev(netdev);
 	goto out;
 }
 
+/**
+ *	velocity_remove	- device unplug
+ *	@pdev: PCI device being removed
+ *	@bustype: bus that device is connected to
+ *
+ *	Device unload callback. Called on an unplug or on module
+ *	unload for each active device that is present. Disconnects
+ *	the device from the network layer and frees all the resources
+ */
+static int velocity_remove(void *pdev, enum velocity_bus_type bustype)
+{
+	struct net_device *netdev;
+	struct velocity_info *vptr;
+	int pci = (bustype == BUS_PCI) ? 1 : 0;
+
+	if (pci)
+		netdev = pci_get_drvdata(pdev);
+	else
+		netdev = platform_get_drvdata(pdev);
+
+	vptr = netdev_priv(netdev);
+
+	unregister_netdev(netdev);
+	iounmap(vptr->mac_regs);
+
+	if (pci) {
+		pci_release_regions(pdev);
+		pci_disable_device(pdev);
+		pci_set_drvdata(pdev, NULL);
+	} else {
+		platform_set_drvdata(pdev, NULL);
+	}
+
+	free_netdev(netdev);
+
+	velocity_nics--;
+
+	return 0;
+}
+
+#ifdef CONFIG_PCI
+static int velocity_pci_probe(struct pci_dev *pdev,
+			   const struct pci_device_id *ent)
+{
+	return velocity_probe(pdev, ent, BUS_PCI);
+}
+
+static void velocity_pci_remove(struct pci_dev *pdev)
+{
+	velocity_remove(pdev, BUS_PCI);
+}
+#endif
+
+static int velocity_platform_probe(struct platform_device *pdev)
+{
+	return velocity_probe(pdev, NULL, BUS_PLATFORM);
+}
+
+static int velocity_platform_remove(struct platform_device *pdev)
+{
+	return velocity_remove(pdev, BUS_PLATFORM);
+}
+
 #ifdef CONFIG_PM
 /**
  *	wol_calc_crc		-	WOL CRC
@@ -3000,11 +3163,20 @@ static void velocity_save_context(struct velocity_info *vptr, struct velocity_co
 
 }
 
-static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
+static int velocity_suspend(void *pdev, pm_message_t state,
+					enum velocity_bus_type bustype)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct velocity_info *vptr = netdev_priv(dev);
+	struct net_device *netdev;
+	struct velocity_info *vptr;
 	unsigned long flags;
+	int pci = (bustype == BUS_PCI) ? 1 : 0;
+
+	if (pci)
+		netdev = pci_get_drvdata(pdev)
+	else
+		netdev = platform_get_drvdata(pdev);
+
+	vptr = netdev_priv(netdev);
 
 	if (!netif_running(vptr->netdev))
 		return 0;
@@ -3012,20 +3184,24 @@ static int velocity_suspend(struct pci_dev *pdev, pm_message_t state)
 	netif_device_detach(vptr->netdev);
 
 	spin_lock_irqsave(&vptr->lock, flags);
-	pci_save_state(pdev);
+	if (pci)
+		pci_save_state(pdev);
 
 	if (vptr->flags & VELOCITY_FLAGS_WOL_ENABLED) {
 		velocity_get_ip(vptr);
 		velocity_save_context(vptr, &vptr->context);
 		velocity_shutdown(vptr);
 		velocity_set_wol(vptr);
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_set_power_state(pdev, PCI_D3hot);
+		if (pci)
+			pci_enable_wake(pdev, PCI_D3hot, 1);
+		velocity_set_power_state(vptr, PCI_D3hot);
 	} else {
 		velocity_save_context(vptr, &vptr->context);
 		velocity_shutdown(vptr);
-		pci_disable_device(pdev);
-		pci_set_power_state(pdev, pci_choose_state(pdev, state));
+		if (pci)
+			pci_disable_device(pdev);
+		velocity_set_power_state(vptr,
+					 velocity_choose_state(pdev, state));
 	}
 
 	spin_unlock_irqrestore(&vptr->lock, flags);
@@ -3067,19 +3243,30 @@ static void velocity_restore_context(struct velocity_info *vptr, struct velocity
 		writeb(*((u8 *) (context->mac_reg + i)), ptr + i);
 }
 
-static int velocity_resume(struct pci_dev *pdev)
+static int velocity_resume(void *pdev, enum velocity_bus_type bustype)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct velocity_info *vptr = netdev_priv(dev);
+	struct net_device *netdev;
+	struct velocity_info *vptr;
 	unsigned long flags;
+	int pci = (bustype == BUS_PCI) ? 1 : 0;
 	int i;
 
+	if (pci)
+		netdev = pci_get_devdata(pdev);
+	else
+		netdev = platform_get_drvdata(pdev);
+
+	vptr = netdev_priv(netdev);
+
 	if (!netif_running(vptr->netdev))
 		return 0;
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_enable_wake(pdev, 0, 0);
-	pci_restore_state(pdev);
+	velocity_set_power_state(vptr, PCI_D0);
+
+	if (pci) {
+		pci_enable_wake(pdev, 0, 0);
+		pci_restore_state(pdev);
+	}
 
 	mac_wol_reset(vptr->mac_regs);
 
@@ -3101,23 +3288,66 @@ static int velocity_resume(struct pci_dev *pdev)
 
 	return 0;
 }
+
+#ifdef CONFIG_PCI
+static int velocity_pci_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	return velocity_suspend(pdev, state, BUS_PCI);
+};
+
+static int velocity_pci_resume(struct pci_dev *pdev)
+{
+	return velocity_resume(pdev, BUS_PCI);
+};
 #endif
 
+static int velocity_platform_suspend(struct platform_device *pdev)
+{
+	return velocity_suspend(pdev, state, BUS_PLATFORM);
+}
+
+static int velocity_platform_resume(struct platform_device *pdev)
+{
+	return velocity_resume(pdev, BUS_PLATFORM);
+}
+
+static const struct dev_pm_ops velocity_platform_pm = {
+	.suspend        = velocity_platform_suspend,
+	.resume         = velocity_platform_resume,
+};
+
+#endif	/* !CONFIG_PM */
+
 /*
  *	Definition for our device driver. The PCI layer interface
  *	uses this to handle all our card discover and plugging
  */
-static struct pci_driver velocity_driver = {
+#ifdef CONFIG_PCI
+static struct pci_driver velocity_pci_driver = {
 	.name		= VELOCITY_NAME,
-	.id_table	= velocity_id_table,
-	.probe		= velocity_found1,
-	.remove		= velocity_remove1,
+	.id_table	= velocity_pci_id_table,
+	.probe		= velocity_pci_probe,
+	.remove		= velocity_pci_remove,
 #ifdef CONFIG_PM
-	.suspend	= velocity_suspend,
-	.resume		= velocity_resume,
+	.suspend	= velocity_pci_suspend,
+	.resume		= velocity_pci_resume,
 #endif
 };
+#endif
 
+static struct platform_driver velocity_platform_driver = {
+	.probe		= velocity_platform_probe,
+	.remove		= velocity_platform_remove,
+#ifdef CONFIG_PM
+	.suspend	= velocity_platform_suspend,
+	.resume		= velocity_platform_resume,
+#endif
+	.driver = {
+		.name = "via-velocity",
+		.owner = THIS_MODULE,
+		.of_match_table = velocity_of_ids,
+	},
+};
 
 /**
  *	velocity_ethtool_up	-	pre hook for ethtool
@@ -3130,7 +3360,7 @@ static int velocity_ethtool_up(struct net_device *dev)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
 	if (!netif_running(dev))
-		pci_set_power_state(vptr->pdev, PCI_D0);
+		velocity_set_power_state(vptr, PCI_D0);
 	return 0;
 }
 
@@ -3145,7 +3375,7 @@ static void velocity_ethtool_down(struct net_device *dev)
 {
 	struct velocity_info *vptr = netdev_priv(dev);
 	if (!netif_running(dev))
-		pci_set_power_state(vptr->pdev, PCI_D3hot);
+		velocity_set_power_state(vptr, PCI_D3hot);
 }
 
 static int velocity_get_settings(struct net_device *dev,
@@ -3267,7 +3497,11 @@ static void velocity_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo
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
@@ -3560,9 +3794,15 @@ static int __init velocity_init_module(void)
 	int ret;
 
 	velocity_register_notifier();
-	ret = pci_register_driver(&velocity_driver);
+#ifdef CONFIG_PCI
+	ret = pci_register_driver(&velocity_pci_driver);
 	if (ret < 0)
 		velocity_unregister_notifier();
+#endif
+	ret = platform_driver_register(&velocity_platform_driver);
+	if (ret < 0)
+		velocity_unregister_notifier();
+
 	return ret;
 }
 
@@ -3577,7 +3817,10 @@ static int __init velocity_init_module(void)
 static void __exit velocity_cleanup_module(void)
 {
 	velocity_unregister_notifier();
-	pci_unregister_driver(&velocity_driver);
+#ifdef CONFIG_PCI
+	pci_unregister_driver(&velocity_pci_driver);
+#endif
+	platform_driver_unregister(&velocity_platform_driver);
 }
 
 module_init(velocity_init_module);
diff --git a/drivers/net/ethernet/via/via-velocity.h b/drivers/net/ethernet/via/via-velocity.h
index c38bbae..7468765 100644
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
 	struct device *dev;
 	struct pci_dev *pdev;
 	struct net_device *netdev;
+	enum velocity_bus_type bustype;
+	int no_eeprom;
 
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u8 ip_addr[4];
-- 
1.7.9.5
