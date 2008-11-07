From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: net: struct device - replace bus_id with dev_name(),
 dev_set_name()
Date: Fri, 07 Nov 2008 12:30:16 +0100
Message-ID: <1226057416.4100.18.camel@nga>
References: <1225329299.5970.67.camel@nga.site>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.189]:58822 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbYKGLaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 06:30:18 -0500
In-Reply-To: <1225329299.5970.67.camel@nga.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-10-30 at 02:15 +0100, Kay Sievers wrote:
> This patch is part of a larger patch series which will remove
> the "char bus_id[20]" name string from struct device. The device
> name is managed in the kobject anyway, and without any size
> limitation, and just needlessly copied into "struct device".
> 
> To set and read the device name dev_name(dev) and dev_set_name(dev)
> must be used. If your code uses static kobjects, which it shouldn't
> do, "const char *init_name" can be used to statically provide the
> name the registered device should have. At registration time, the
> init_name field is cleared, to enforce the use of dev_name(dev) to
> access the device name at a later time.
> 
> We need to get rid of all occurrences of bus_id in the entire tree
> to be able to enable the new interface. Please apply this patch,
> and possibly convert any remaining remaining occurrences of bus_id.
> 
> We want to submit a patch to -next, which will remove bus_id from
> "struct device", to find the remaining pieces to convert, and finally
> switch over to the new api, which will remove the 20 bytes array
> and does no longer have a size limitation.

Updated patch, which does not replace BUS_ID_SIZE for now.

(BUS_ID_SIZE will go away from the driver core after the API switch, and
it has to be replaced by a local definition in the network tree, or the
limit can be removed entirely.)

Thanks,
Kay


From: Kay Sievers <kay.sievers@vrfy.org>
Subject: net: struct device - replace bus_id with dev_name(), dev_set_name()

CC: David S. Miller <davem@davemloft.net>
Acked-by: Marcel Holtmann <marcel@holtmann.org>
Acked-by: Greg Kroah-Hartman <gregkh@suse.de>
Signed-off-by: Kay Sievers <kay.sievers@vrfy.org>
---
 drivers/net/3c59x.c                  |    4 ++--
 drivers/net/defxx.c                  |    2 +-
 drivers/net/enc28j60.c               |    2 +-
 drivers/net/fec_mpc52xx.c            |    2 +-
 drivers/net/gianfar.c                |    2 +-
 drivers/net/mlx4/mlx4_en.h           |    8 ++++----
 drivers/net/pasemi_mac.c             |    3 ++-
 drivers/net/phy/mdio_bus.c           |    4 ++--
 drivers/net/phy/phy.c                |    2 +-
 drivers/net/phy/phy_device.c         |    4 ++--
 drivers/net/sh_eth.c                 |    2 +-
 drivers/net/tg3.c                    |    4 ++--
 drivers/net/tulip/de4x5.c            |    4 ++--
 drivers/net/ucc_geth.c               |    4 ++--
 drivers/net/wireless/libertas/defs.h |    2 +-
 drivers/net/wireless/orinoco.c       |    2 +-
 drivers/net/wireless/orinoco_cs.c    |    2 +-
 drivers/net/wireless/spectrum_cs.c   |    2 +-
 include/net/wireless.h               |    4 ++--
 net/atm/atm_sysfs.c                  |    2 +-
 net/bluetooth/hci_sysfs.c            |    7 +++----
 net/core/net-sysfs.c                 |    2 +-
 net/dsa/slave.c                      |    2 +-
 net/rfkill/rfkill.c                  |    5 ++---
 net/wireless/core.c                  |    3 +--
 25 files changed, 39 insertions(+), 41 deletions(-)

--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1025,7 +1025,7 @@ static int __devinit vortex_probe1(struc
 		}
 
 		if ((edev = DEVICE_EISA(gendev))) {
-			print_name = edev->dev.bus_id;
+			print_name = dev_name(&edev->dev);
 		}
 	}
 
@@ -2883,7 +2883,7 @@ static void vortex_get_drvinfo(struct ne
 		strcpy(info->bus_info, pci_name(VORTEX_PCI(vp)));
 	} else {
 		if (VORTEX_EISA(vp))
-			sprintf(info->bus_info, vp->gendev->bus_id);
+			sprintf(info->bus_info, dev_name(vp->gendev));
 		else
 			sprintf(info->bus_info, "EISA 0x%lx %d",
 					dev->base_addr, dev->irq);
--- a/drivers/net/defxx.c
+++ b/drivers/net/defxx.c
@@ -511,7 +511,7 @@ static int __devinit dfx_register(struct
 	int dfx_bus_pci = DFX_BUS_PCI(bdev);
 	int dfx_bus_tc = DFX_BUS_TC(bdev);
 	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;
-	char *print_name = bdev->bus_id;
+	const char *print_name = dev_name(bdev);
 	struct net_device *dev;
 	DFX_board_t	  *bp;			/* board pointer */
 	resource_size_t bar_start = 0;		/* pointer to port */
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -1448,7 +1448,7 @@ enc28j60_get_drvinfo(struct net_device *
 	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
 	strlcpy(info->bus_info,
-		dev->dev.parent->bus_id, sizeof(info->bus_info));
+		dev_name(dev->dev.parent), sizeof(info->bus_info));
 }
 
 static int
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -216,7 +216,7 @@ static int mpc52xx_fec_init_phy(struct n
 	struct phy_device *phydev;
 	char phy_id[BUS_ID_SIZE];
 
-	snprintf(phy_id, BUS_ID_SIZE, "%x:%02x",
+	snprintf(phy_id, sizeof(phy_id), "%x:%02x",
 			(unsigned int)dev->base_addr, priv->phy_addr);
 
 	priv->link = PHY_DOWN;
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -546,7 +546,7 @@ static int init_phy(struct net_device *d
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, priv->einfo->bus_id, priv->einfo->phy_id);
+	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT, priv->einfo->bus_id, priv->einfo->phy_id);
 
 	interface = gfar_get_interface(dev);
 
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -58,17 +58,17 @@
 #define mlx4_dbg(mlevel, priv, format, arg...)	\
 	if (NETIF_MSG_##mlevel & priv->msg_enable) \
 	printk(KERN_DEBUG "%s %s: " format , DRV_NAME ,\
-		(&priv->mdev->pdev->dev)->bus_id , ## arg)
+		(dev_name(&priv->mdev->pdev->dev)) , ## arg)
 
 #define mlx4_err(mdev, format, arg...) \
 	printk(KERN_ERR "%s %s: " format , DRV_NAME ,\
-		(&mdev->pdev->dev)->bus_id , ## arg)
+		(dev_name(&mdev->pdev->dev)) , ## arg)
 #define mlx4_info(mdev, format, arg...) \
 	printk(KERN_INFO "%s %s: " format , DRV_NAME ,\
-		(&mdev->pdev->dev)->bus_id , ## arg)
+		(dev_name(&mdev->pdev->dev)) , ## arg)
 #define mlx4_warn(mdev, format, arg...) \
 	printk(KERN_WARNING "%s %s: " format , DRV_NAME ,\
-		(&mdev->pdev->dev)->bus_id , ## arg)
+		(dev_name(&mdev->pdev->dev)) , ## arg)
 
 /*
  * Device constants
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1105,7 +1105,8 @@ static int pasemi_mac_phy_init(struct ne
 		goto err;
 
 	phy_id = *prop;
-	snprintf(mac->phy_id, BUS_ID_SIZE, "%x:%02x", (int)r.start, phy_id);
+	snprintf(mac->phy_id, sizeof(mac->phy_id), "%x:%02x",
+		 (int)r.start, phy_id);
 
 	of_node_put(phy_dn);
 
--- a/drivers/net/phy/mdio_bus.c
+++ b/drivers/net/phy/mdio_bus.c
@@ -97,7 +97,7 @@ int mdiobus_register(struct mii_bus *bus
 	bus->dev.parent = bus->parent;
 	bus->dev.class = &mdio_bus_class;
 	bus->dev.groups = NULL;
-	memcpy(bus->dev.bus_id, bus->id, MII_BUS_ID_SIZE);
+	dev_set_name(&bus->dev, bus->id);
 
 	err = device_register(&bus->dev);
 	if (err) {
@@ -191,7 +191,7 @@ struct phy_device *mdiobus_scan(struct m
 
 	phydev->dev.parent = bus->parent;
 	phydev->dev.bus = &mdio_bus_type;
-	snprintf(phydev->dev.bus_id, BUS_ID_SIZE, PHY_ID_FMT, bus->id, addr);
+	dev_set_name(&phydev->dev, PHY_ID_FMT, bus->id, addr);
 
 	phydev->bus = bus;
 
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -45,7 +45,7 @@
  */
 void phy_print_status(struct phy_device *phydev)
 {
-	pr_info("PHY: %s - Link is %s", phydev->dev.bus_id,
+	pr_info("PHY: %s - Link is %s", dev_name(&phydev->dev),
 			phydev->link ? "Up" : "Down");
 	if (phydev->link)
 		printk(" - %d/%s", phydev->speed,
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -74,7 +74,7 @@ int phy_register_fixup(const char *bus_i
 	if (!fixup)
 		return -ENOMEM;
 
-	strncpy(fixup->bus_id, bus_id, BUS_ID_SIZE);
+	strlcpy(fixup->bus_id, bus_id, sizeof(fixup->bus_id));
 	fixup->phy_uid = phy_uid;
 	fixup->phy_uid_mask = phy_uid_mask;
 	fixup->run = run;
@@ -109,7 +109,7 @@ EXPORT_SYMBOL(phy_register_fixup_for_id)
  */
 static int phy_needs_fixup(struct phy_device *phydev, struct phy_fixup *fixup)
 {
-	if (strcmp(fixup->bus_id, phydev->dev.bus_id) != 0)
+	if (strcmp(fixup->bus_id, dev_name(&phydev->dev)) != 0)
 		if (strcmp(fixup->bus_id, PHY_ANY_ID) != 0)
 			return 0;
 
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -799,7 +799,7 @@ static int sh_eth_phy_init(struct net_de
 	char phy_id[BUS_ID_SIZE];
 	struct phy_device *phydev = NULL;
 
-	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT,
+	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT,
 		mdp->mii_bus->id , mdp->phy_id);
 
 	mdp->link = PHY_DOWN;
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -1396,7 +1396,7 @@ static int tg3_phy_init(struct tg3 *tp)
 	phydev = tp->mdio_bus->phy_map[PHY_ADDR];
 
 	/* Attach the MAC to the PHY. */
-	phydev = phy_connect(tp->dev, phydev->dev.bus_id, tg3_adjust_link,
+	phydev = phy_connect(tp->dev, dev_name(&phydev->dev), tg3_adjust_link,
 			     phydev->dev_flags, phydev->interface);
 	if (IS_ERR(phydev)) {
 		printk(KERN_ERR "%s: Could not attach to PHY\n", tp->dev->name);
@@ -13645,7 +13645,7 @@ static int __devinit tg3_init_one(struct
 		       "%s: attached PHY driver [%s] (mii_bus:phy_addr=%s)\n",
 		       tp->dev->name,
 		       tp->mdio_bus->phy_map[PHY_ADDR]->drv->name,
-		       tp->mdio_bus->phy_map[PHY_ADDR]->dev.bus_id);
+		       dev_name(&tp->mdio_bus->phy_map[PHY_ADDR]->dev));
 	else
 		printk(KERN_INFO
 		       "%s: attached PHY is %s (%s Ethernet) (WireSpeed[%d])\n",
--- a/drivers/net/tulip/de4x5.c
+++ b/drivers/net/tulip/de4x5.c
@@ -1118,7 +1118,7 @@ de4x5_hw_init(struct net_device *dev, u_
     }
 
     dev->base_addr = iobase;
-    printk ("%s: %s at 0x%04lx", gendev->bus_id, name, iobase);
+    printk ("%s: %s at 0x%04lx", dev_name(gendev), name, iobase);
 
     status = get_hw_addr(dev);
     printk(", h/w address %pM\n", dev->dev_addr);
@@ -1153,7 +1153,7 @@ de4x5_hw_init(struct net_device *dev, u_
             }
         }
 	lp->fdx = lp->params.fdx;
-	sprintf(lp->adapter_name,"%s (%s)", name, gendev->bus_id);
+	sprintf(lp->adapter_name,"%s (%s)", name, dev_name(gendev));
 
 	lp->dma_size = (NUM_RX_DESC + NUM_TX_DESC) * sizeof(struct de4x5_desc);
 #if defined(__alpha__) || defined(__powerpc__) || defined(CONFIG_SPARC) || defined(DE4X5_DO_MEMCPY)
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1615,8 +1615,8 @@ static int init_phy(struct net_device *d
 	priv->oldspeed = 0;
 	priv->oldduplex = -1;
 
-	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, priv->ug_info->mdio_bus,
-			priv->ug_info->phy_address);
+	snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT, priv->ug_info->mdio_bus,
+		 priv->ug_info->phy_address);
 
 	phydev = phy_connect(dev, phy_id, &adjust_link, 0, priv->phy_interface);
 
--- a/drivers/net/wireless/libertas/defs.h
+++ b/drivers/net/wireless/libertas/defs.h
@@ -79,7 +79,7 @@ do { if ((lbs_debug & (grp)) == (grp)) \
 #define lbs_deb_tx(fmt, args...)        LBS_DEB_LL(LBS_DEB_TX, " tx", fmt, ##args)
 #define lbs_deb_fw(fmt, args...)        LBS_DEB_LL(LBS_DEB_FW, " fw", fmt, ##args)
 #define lbs_deb_usb(fmt, args...)       LBS_DEB_LL(LBS_DEB_USB, " usb", fmt, ##args)
-#define lbs_deb_usbd(dev, fmt, args...) LBS_DEB_LL(LBS_DEB_USB, " usbd", "%s:" fmt, (dev)->bus_id, ##args)
+#define lbs_deb_usbd(dev, fmt, args...) LBS_DEB_LL(LBS_DEB_USB, " usbd", "%s:" fmt, dev_name(dev), ##args)
 #define lbs_deb_cs(fmt, args...)        LBS_DEB_LL(LBS_DEB_CS, " cs", fmt, ##args)
 #define lbs_deb_thread(fmt, args...)    LBS_DEB_LL(LBS_DEB_THREAD, " thread", fmt, ##args)
 #define lbs_deb_sdio(fmt, args...)      LBS_DEB_LL(LBS_DEB_SDIO, " sdio", fmt, ##args)
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -5985,7 +5985,7 @@ static void orinoco_get_drvinfo(struct n
 	strncpy(info->version, DRIVER_VERSION, sizeof(info->version) - 1);
 	strncpy(info->fw_version, priv->fw_name, sizeof(info->fw_version) - 1);
 	if (dev->dev.parent)
-		strncpy(info->bus_info, dev->dev.parent->bus_id,
+		strncpy(info->bus_info, dev_name(dev->dev.parent),
 			sizeof(info->bus_info) - 1);
 	else
 		snprintf(info->bus_info, sizeof(info->bus_info) - 1,
--- a/drivers/net/wireless/orinoco_cs.c
+++ b/drivers/net/wireless/orinoco_cs.c
@@ -308,7 +308,7 @@ orinoco_cs_config(struct pcmcia_device *
 
 	/* Finally, report what we've done */
 	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s, irq %d, io "
-	       "0x%04x-0x%04x\n", dev->name, dev->dev.parent->bus_id,
+	       "0x%04x-0x%04x\n", dev->name, dev_name(dev->dev.parent),
 	       link->irq.AssignedIRQ, link->io.BasePort1,
 	       link->io.BasePort1 + link->io.NumPorts1 - 1);
 	return 0;
--- a/drivers/net/wireless/spectrum_cs.c
+++ b/drivers/net/wireless/spectrum_cs.c
@@ -383,7 +383,7 @@ spectrum_cs_config(struct pcmcia_device
 
 	/* Finally, report what we've done */
 	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s, irq %d, io "
-	       "0x%04x-0x%04x\n", dev->name, dev->dev.parent->bus_id,
+	       "0x%04x-0x%04x\n", dev->name, dev_name(dev->dev.parent),
 	       link->irq.AssignedIRQ, link->io.BasePort1,
 	       link->io.BasePort1 + link->io.NumPorts1 - 1);
 
--- a/include/net/wireless.h
+++ b/include/net/wireless.h
@@ -263,9 +263,9 @@ static inline struct device *wiphy_dev(s
 /**
  * wiphy_name - get wiphy name
  */
-static inline char *wiphy_name(struct wiphy *wiphy)
+static inline const char *wiphy_name(struct wiphy *wiphy)
 {
-	return wiphy->dev.bus_id;
+	return dev_name(&wiphy->dev);
 }
 
 /**
--- a/net/atm/atm_sysfs.c
+++ b/net/atm/atm_sysfs.c
@@ -149,7 +149,7 @@ int atm_register_sysfs(struct atm_dev *a
 	cdev->class = &atm_class;
 	dev_set_drvdata(cdev, adev);
 
-	snprintf(cdev->bus_id, BUS_ID_SIZE, "%s%d", adev->type, adev->number);
+	dev_set_name(cdev, "%s%d", adev->type, adev->number);
 	err = device_register(cdev);
 	if (err < 0)
 		return err;
--- a/net/bluetooth/hci_sysfs.c
+++ b/net/bluetooth/hci_sysfs.c
@@ -113,8 +113,7 @@ void hci_conn_add_sysfs(struct hci_conn
 	conn->dev.class = bt_class;
 	conn->dev.parent = &hdev->dev;
 
-	snprintf(conn->dev.bus_id, BUS_ID_SIZE, "%s:%d",
-					hdev->name, conn->handle);
+	dev_set_name(&conn->dev, "%s:%d", hdev->name, conn->handle);
 
 	dev_set_drvdata(&conn->dev, conn);
 
@@ -132,7 +131,7 @@ void hci_conn_add_sysfs(struct hci_conn
  */
 static int __match_tty(struct device *dev, void *data)
 {
-	return !strncmp(dev->bus_id, "rfcomm", 6);
+	return !strncmp(dev_name(dev), "rfcomm", 6);
 }
 
 static void del_conn(struct work_struct *work)
@@ -421,7 +420,7 @@ int hci_register_sysfs(struct hci_dev *h
 	dev->class = bt_class;
 	dev->parent = hdev->parent;
 
-	strlcpy(dev->bus_id, hdev->name, BUS_ID_SIZE);
+	dev_set_name(dev, hdev->name);
 
 	dev_set_drvdata(dev, hdev);
 
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -494,7 +494,7 @@ int netdev_register_kobject(struct net_d
 	dev->groups = groups;
 
 	BUILD_BUG_ON(BUS_ID_SIZE < IFNAMSIZ);
-	strlcpy(dev->bus_id, net->name, BUS_ID_SIZE);
+	dev_set_name(dev, net->name);
 
 #ifdef CONFIG_SYSFS
 	*groups++ = &netstat_group;
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -284,7 +284,7 @@ dsa_slave_create(struct dsa_switch *ds,
 	netif_carrier_off(slave_dev);
 
 	if (p->phy != NULL) {
-		phy_attach(slave_dev, p->phy->dev.bus_id,
+		phy_attach(slave_dev, dev_name(&p->phy->dev),
 			   0, PHY_INTERFACE_MODE_GMII);
 
 		p->phy->autoneg = AUTONEG_ENABLE;
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -774,7 +774,7 @@ static void rfkill_led_trigger_register(
 	int error;
 
 	if (!rfkill->led_trigger.name)
-		rfkill->led_trigger.name = rfkill->dev.bus_id;
+		rfkill->led_trigger.name = dev_name(&rfkill->dev);
 	if (!rfkill->led_trigger.activate)
 		rfkill->led_trigger.activate = rfkill_led_trigger_activate;
 	error = led_trigger_register(&rfkill->led_trigger);
@@ -815,8 +815,7 @@ int __must_check rfkill_register(struct
 			"badly initialized rfkill struct\n"))
 		return -EINVAL;
 
-	snprintf(dev->bus_id, sizeof(dev->bus_id),
-		 "rfkill%ld", (long)atomic_inc_return(&rfkill_no) - 1);
+	dev_set_name(dev, "rfkill%ld", (long)atomic_inc_return(&rfkill_no) - 1);
 
 	rfkill_led_trigger_register(rfkill);
 
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -236,8 +236,7 @@ struct wiphy *wiphy_new(struct cfg80211_
 	mutex_unlock(&cfg80211_drv_mutex);
 
 	/* give it a proper name */
-	snprintf(drv->wiphy.dev.bus_id, BUS_ID_SIZE,
-		 PHY_NAME "%d", drv->idx);
+	dev_set_name(&drv->wiphy.dev, PHY_NAME "%d", drv->idx);
 
 	mutex_init(&drv->mtx);
 	mutex_init(&drv->devlist_mtx);


