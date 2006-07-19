From: Rodolfo Giometti <giometti@linux.it>
Subject: [PATCH] au1000_eth.c power management and driver registration support
Date: Wed, 19 Jul 2006 10:29:40 +0200
Message-ID: <20060719082940.GC6887@enneenne.com>
References: <20060713163200.GA7186@gundam.enneenne.com> <20060714.103521.25910483.nemoto@toshiba-tops.co.jp> <20060714075441.GE7186@gundam.enneenne.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="BI5RvnYi6R4T2M87"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 81-174-11-161.f5.ngi.it ([81.174.11.161]:12701 "EHLO
	mail.enneenne.com") by vger.kernel.org with ESMTP id S932480AbWGSIaA
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jul 2006 04:30:00 -0400
To: linux-mips@linux-mips.org
Content-Disposition: inline
In-Reply-To: <20060714075441.GE7186@gundam.enneenne.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--BI5RvnYi6R4T2M87
Content-Type: multipart/mixed; boundary="Clx92ZfkiYIKRjnr"
Content-Disposition: inline


--Clx92ZfkiYIKRjnr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

Attached you can find my patch to add power managament and driver
registration to the new version of file "drivers/net/au1000_eth.c"
that implements the PHY-layer support.

Ciao,

Rodolfo Giometti

Signed-off-by: Rodolfo Giometti <giometti@linux.it

--=20

GNU/Linux Solutions                  e-mail:    giometti@enneenne.com
Linux Device Driver                             giometti@gnudd.com
Embedded Systems                     		giometti@linux.it
UNIX programming                     phone:     +39 349 2432127

--Clx92ZfkiYIKRjnr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=patch-au1000_eth-pm-and-registration
Content-Transfer-Encoding: quoted-printable

diff --git a/arch/mips/au1000/common/au1xxx_irqmap.c b/arch/mips/au1000/com=
mon/au1xxx_irqmap.c
index 7acfe9b..d94bde1 100644
--- a/arch/mips/au1000/common/au1xxx_irqmap.c
+++ b/arch/mips/au1000/common/au1xxx_irqmap.c
@@ -117,7 +117,7 @@ #elif defined(CONFIG_SOC_AU1500)
 	{ AU1000_USB_DEV_SUS_INT, INTC_INT_RISE_EDGE, 0 },
 	{ AU1000_USB_HOST_INT, INTC_INT_LOW_LEVEL, 0 },
 	{ AU1000_ACSYNC_INT, INTC_INT_RISE_EDGE, 0 },
-	{ AU1500_MAC0_DMA_INT, INTC_INT_HIGH_LEVEL, 0},
+	{ AU1000_MAC0_DMA_INT, INTC_INT_HIGH_LEVEL, 0},
 	{ AU1500_MAC1_DMA_INT, INTC_INT_HIGH_LEVEL, 0},
 	{ AU1000_AC97C_INT, INTC_INT_RISE_EDGE, 0 },
=20
@@ -151,7 +151,7 @@ #elif defined(CONFIG_SOC_AU1100)
 	{ AU1000_USB_DEV_SUS_INT, INTC_INT_RISE_EDGE, 0 },
 	{ AU1000_USB_HOST_INT, INTC_INT_LOW_LEVEL, 0 },
 	{ AU1000_ACSYNC_INT, INTC_INT_RISE_EDGE, 0 },
-	{ AU1100_MAC0_DMA_INT, INTC_INT_HIGH_LEVEL, 0},
+	{ AU1000_MAC0_DMA_INT, INTC_INT_HIGH_LEVEL, 0},
 	/*{ AU1000_GPIO215_208_INT, INTC_INT_HIGH_LEVEL, 0},*/
 	{ AU1100_LCD_INT, INTC_INT_HIGH_LEVEL, 0},
 	{ AU1000_AC97C_INT, INTC_INT_RISE_EDGE, 0 },
diff --git a/arch/mips/au1000/common/platform.c b/arch/mips/au1000/common/p=
latform.c
index 8fd203d..ec81d4b 100644
--- a/arch/mips/au1000/common/platform.c
+++ b/arch/mips/au1000/common/platform.c
@@ -15,6 +15,78 @@ #include <linux/resource.h>
=20
 #include <asm/mach-au1x00/au1xxx.h>
=20
+#if defined(CONFIG_MIPS_AU1X00_ENET) || defined(CONFIG_MIPS_AU1X00_ENET_MO=
DULE)
+/* Ethernet controllers */
+static struct resource au1xxx_eth0_resources[] =3D {
+	[0] =3D {
+		.name	=3D "eth-base",
+		.start	=3D ETH0_BASE,
+		.end	=3D ETH0_BASE + MAC_IOSIZE - 1,
+		.flags	=3D IORESOURCE_MEM,
+	},
+	[1] =3D {
+		.name	=3D "eth-mac",
+		.start	=3D MAC0_ENABLE,
+		.end	=3D MAC0_ENABLE + 4 - 1,
+		.flags	=3D IORESOURCE_MEM,
+	},
+	[2] =3D {
+		.name	=3D "eth-irq",
+#if defined(CONFIG_SOC_AU1550)
+		.start	=3D AU1550_MAC0_DMA_INT,
+		.end	=3D AU1550_MAC0_DMA_INT,
+#else
+		.start	=3D AU1000_MAC0_DMA_INT,
+		.end	=3D AU1000_MAC0_DMA_INT,
+#endif
+		.flags	=3D IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device au1xxx_eth0_device =3D {
+	.name		=3D "au1000_eth",
+ 	.id		=3D 0,
+	.num_resources	=3D ARRAY_SIZE(au1xxx_eth0_resources),
+	.resource	=3D au1xxx_eth0_resources,
+};
+
+#if defined(CONFIG_SOC_AU1000) || \
+    defined(CONFIG_SOC_AU1500) || defined(CONFIG_SOC_AU1550)
+static struct resource au1xxx_eth1_resources[] =3D {
+	[0] =3D {
+		.name	=3D "eth-base",
+		.start	=3D ETH1_BASE,
+		.end	=3D ETH1_BASE + MAC_IOSIZE - 1,
+		.flags	=3D IORESOURCE_MEM,
+	},
+	[1] =3D {
+		.name	=3D "eth-mac",
+		.start	=3D MAC1_ENABLE,
+		.end	=3D MAC1_ENABLE + 4 - 1,
+		.flags	=3D IORESOURCE_MEM,
+	},
+	[2] =3D {
+		.name	=3D "eth-irq",
+#if defined(CONFIG_SOC_AU1550)
+		.start	=3D AU1550_MAC1_DMA_INT,
+		.end	=3D AU1550_MAC1_DMA_INT,
+#else
+		.start	=3D AU1000_MAC1_DMA_INT,
+		.end	=3D AU1000_MAC1_DMA_INT,
+#endif
+		.flags	=3D IORESOURCE_IRQ,
+	},
+};
+
+static struct platform_device au1xxx_eth1_device =3D {
+	.name		=3D "au1000_eth",
+ 	.id		=3D 1,
+	.num_resources	=3D ARRAY_SIZE(au1xxx_eth1_resources),
+	.resource	=3D au1xxx_eth1_resources,
+};
+#endif
+#endif
+
 /* OHCI (USB full speed host controller) */
 static struct resource au1xxx_usb_ohci_resources[] =3D {
 	[0] =3D {
@@ -270,7 +367,14 @@ static struct platform_device smc91x_dev
=20
 #endif
=20
 static struct platform_device *au1xxx_platform_devices[] __initdata =3D {
+#if defined(CONFIG_MIPS_AU1X00_ENET) || defined(CONFIG_MIPS_AU1X00_ENET_MO=
DULE)
+	&au1xxx_eth0_device,
+#if defined(CONFIG_SOC_AU1000) || \
+    defined(CONFIG_SOC_AU1500) || defined(CONFIG_SOC_AU1550)
+	&au1xxx_eth1_device,
+#endif
+#endif
 	&au1xxx_usb_ohci_device,
 	&au1x00_pcmcia_device,
 #ifdef CONFIG_FB_AU1100
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 27d465f..47c624b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -453,13 +453,13 @@ config MIPS_GT96100ETH
 	  Say Y here to support the Ethernet subsystem on your GT96100 card.
=20
 config MIPS_AU1X00_ENET
-	bool "MIPS AU1000 Ethernet support"
+	tristate "MIPS AU1000 Ethernet support"
 	depends on NET_ETHERNET && SOC_AU1X00
 	select PHYLIB
 	select CRC32
 	help
 	  If you have an Alchemy Semi AU1X00 based system
-	  say Y.  Otherwise, say N.
+	  say Y or M.  Otherwise, say N.
=20
 config SGI_IOC3_ETH
 	bool "SGI IOC3 Ethernet"
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 55f6e3f..004452f 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -11,6 +11,8 @@
  * ioctls (SIOCGMIIPHY)
  * Copyright 2006 Herbert Valerio Riedel <hvr@gnu.org>
  *  converted to use linux-2.6.x's PHY framework
+ * Copyright 2006 Rodolfo Giometti <giometti@linux.it>
+ *  power management, driver registration and module support.
  *
  * Author: MontaVista Software, Inc.
  *         	ppopov@mvista.com or source@mvista.com
@@ -61,6 +63,7 @@ #include <asm/irq.h>
 #include <asm/io.h>
 #include <asm/processor.h>
=20
+#include <linux/platform_device.h>
 #include <asm/mach-au1x00/au1000.h>
 #include <asm/cpu.h>
 #include "au1000_eth.h"
@@ -83,7 +86,8 @@ MODULE_LICENSE("GPL");
 // prototypes
 static void hard_stop(struct net_device *);
 static void enable_rx_tx(struct net_device *dev);
-static struct net_device * au1000_probe(int port_num);
+static int au1000_lowlevel_probe(struct net_device *ndev, void *ioaddr, vo=
id *macen_addr, int port_num, int skip_prom);
+static void au1000_lowlevel_remove(struct net_device *ndev);
 static int au1000_init(struct net_device *);
 static int au1000_open(struct net_device *);
 static int au1000_close(struct net_device *);
@@ -520,59 +524,6 @@ setup_hw_rings(struct au1000_private *au
 	}
 }
=20
-static struct {
-	u32 base_addr;
-	u32 macen_addr;
-	int irq;
-	struct net_device *dev;
-} iflist[2] =3D {
-#ifdef CONFIG_SOC_AU1000
-	{AU1000_ETH0_BASE, AU1000_MAC0_ENABLE, AU1000_MAC0_DMA_INT},
-	{AU1000_ETH1_BASE, AU1000_MAC1_ENABLE, AU1000_MAC1_DMA_INT}
-#endif
-#ifdef CONFIG_SOC_AU1100
-	{AU1100_ETH0_BASE, AU1100_MAC0_ENABLE, AU1100_MAC0_DMA_INT}
-#endif
-#ifdef CONFIG_SOC_AU1500
-	{AU1500_ETH0_BASE, AU1500_MAC0_ENABLE, AU1500_MAC0_DMA_INT},
-	{AU1500_ETH1_BASE, AU1500_MAC1_ENABLE, AU1500_MAC1_DMA_INT}
-#endif
-#ifdef CONFIG_SOC_AU1550
-	{AU1550_ETH0_BASE, AU1550_MAC0_ENABLE, AU1550_MAC0_DMA_INT},
-	{AU1550_ETH1_BASE, AU1550_MAC1_ENABLE, AU1550_MAC1_DMA_INT}
-#endif
-};
-
-static int num_ifs;
-
-/*
- * Setup the base address and interupt of the Au1xxx ethernet macs
- * based on cpu type and whether the interface is enabled in sys_pinfunc
- * register. The last interface is enabled if SYS_PF_NI2 (bit 4) is 0.
- */
-static int __init au1000_init_module(void)
-{
-	int ni =3D (int)((au_readl(SYS_PINFUNC) & (u32)(SYS_PF_NI2)) >> 4);
-	struct net_device *dev;
-	int i, found_one =3D 0;
-
-	num_ifs =3D NUM_ETH_INTERFACES - ni;
-
-	for(i =3D 0; i < num_ifs; i++) {
-		dev =3D au1000_probe(i);
-		iflist[i].dev =3D dev;
-		if (dev)
-			found_one++;
-	}
-	if (!found_one)
-		return -ENODEV;
-	return 0;
-}
-
-/*
- * ethtool operations
- */
-
 static int au1000_get_settings(struct net_device *dev, struct ethtool_cmd =
*cmd)
 {
 	struct au1000_private *aup =3D (struct au1000_private *)dev->priv;
@@ -615,48 +566,14 @@ static struct ethtool_ops au1000_ethtool
 	.get_link =3D ethtool_op_get_link,
 };
=20
-static struct net_device * au1000_probe(int port_num)
+static int=20
+au1000_lowlevel_probe(struct net_device *ndev, void *ioaddr, void *macen_a=
ddr, int port_num, int skip_prom)
 {
-	static unsigned version_printed =3D 0;
-	struct au1000_private *aup =3D NULL;
-	struct net_device *dev =3D NULL;
+	struct au1000_private *aup =3D ndev->priv;
 	db_dest_t *pDB, *pDBfree;
 	char *pmac, *argptr;
 	char ethaddr[6];
-	int irq, i, err;
-	u32 base, macen;
-
-	if (port_num >=3D NUM_ETH_INTERFACES)
- 		return NULL;
-
-	base  =3D CPHYSADDR(iflist[port_num].base_addr );
-	macen =3D CPHYSADDR(iflist[port_num].macen_addr);
-	irq =3D iflist[port_num].irq;
-
-	if (!request_mem_region( base, MAC_IOSIZE, "Au1x00 ENET") ||
-	    !request_mem_region(macen, 4, "Au1x00 ENET"))
-		return NULL;
-
-	if (version_printed++ =3D=3D 0)
-		printk("%s version %s %s\n", DRV_NAME, DRV_VERSION, DRV_AUTHOR);
-
-	dev =3D alloc_etherdev(sizeof(struct au1000_private));
-	if (!dev) {
-		printk(KERN_ERR "%s: alloc_etherdev failed\n", DRV_NAME);
-		return NULL;
-	}
-
-	if ((err =3D register_netdev(dev)) !=3D 0) {
-		printk(KERN_ERR "%s: Cannot register net device, error %d\n",
-				DRV_NAME, err);
-		free_netdev(dev);
-		return NULL;
-	}
-
-	printk("%s: Au1xx0 Ethernet found at 0x%x, irq %d\n",
-		dev->name, base, irq);
-
-	aup =3D dev->priv;
+	int i, ret;
=20
 	/* Allocate the data buffers */
 	/* Snooping works fine with eth on all au1xxx */
@@ -664,79 +581,61 @@ static struct net_device * au1000_probe(
 						(NUM_TX_BUFFS + NUM_RX_BUFFS),
 						&aup->dma_addr,	0);
 	if (!aup->vaddr) {
-		free_netdev(dev);
-		release_mem_region( base, MAC_IOSIZE);
-		release_mem_region(macen, 4);
-		return NULL;
+		printk(KERN_ERR "%s: cannot dma_alloc_noncoherent\n",
+		       ndev->name);
+		ret =3D -ENOMEM;
+		goto out;
 	}
=20
 	/* aup->mac is the base address of the MAC's registers */
-	aup->mac =3D (volatile mac_reg_t *)iflist[port_num].base_addr;
-
+	aup->mac =3D (volatile mac_reg_t *)((unsigned long)ioaddr);
 	/* Setup some variables for quick register address access */
-	aup->enable =3D (volatile u32 *)iflist[port_num].macen_addr;
-	aup->mac_id =3D port_num;
-	au_macs[port_num] =3D aup;
-
-	if (port_num =3D=3D 0) {
-		/* Check the environment variables first */
-		if (get_ethernet_addr(ethaddr) =3D=3D 0)
-			memcpy(au1000_mac_addr, ethaddr, sizeof(au1000_mac_addr));
-		else {
-			/* Check command line */
-			argptr =3D prom_getcmdline();
-			if ((pmac =3D strstr(argptr, "ethaddr=3D")) =3D=3D NULL)
-				printk(KERN_INFO "%s: No MAC address found\n",
-						 dev->name);
-				/* Use the hard coded MAC addresses */
-			else {
-				str2eaddr(ethaddr, pmac + strlen("ethaddr=3D"));
-				memcpy(au1000_mac_addr, ethaddr,=20
-				       sizeof(au1000_mac_addr));
+	if (port_num =3D=3D 0)
+	{
+		if (!skip_prom) {
+			/* check env variables first */
+			if (!get_ethernet_addr(ethaddr)) {=20
+				memcpy(au1000_mac_addr, ethaddr, sizeof(au1000_mac_addr));
+			} else {
+				/* Check command line */
+				argptr =3D prom_getcmdline();
+				if ((pmac =3D strstr(argptr, "ethaddr=3D")) =3D=3D NULL) {
+					printk(KERN_INFO "%s: No mac address found\n",=20
+							ndev->name);
+					/* use the hard coded mac addresses */
+				} else {
+					str2eaddr(ethaddr, pmac + strlen("ethaddr=3D"));
+					memcpy(au1000_mac_addr, ethaddr,=20
+							sizeof(au1000_mac_addr));
+				}
 			}
 		}
=20
+		aup->enable =3D (volatile u32 *) ((unsigned long) macen_addr);
+		memcpy(ndev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
 		setup_hw_rings(aup, MAC0_RX_DMA_ADDR, MAC0_TX_DMA_ADDR);
-	} else if (port_num =3D=3D 1)
-		setup_hw_rings(aup, MAC1_RX_DMA_ADDR, MAC1_TX_DMA_ADDR);
+		aup->mac_id =3D 0;
+		au_macs[0] =3D aup;
+	}
+		else
+	if (port_num =3D=3D 1)
+	{
+		aup->enable =3D (volatile u32 *) ((unsigned long) macen_addr);
+		memcpy(ndev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
+		ndev->dev_addr[5] +=3D 0x01;
=20
-	/*
-	 * Assign to the Ethernet ports two consecutive MAC addresses
-	 * to match those that are printed on their stickers
-	 */
-	memcpy(dev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
-	dev->dev_addr[5] +=3D port_num;
+		setup_hw_rings(aup, MAC1_RX_DMA_ADDR, MAC1_TX_DMA_ADDR);
+		aup->mac_id =3D 1;
+		au_macs[1] =3D aup;
+	}
+	else
+	{
+		printk(KERN_ERR "%s: bad ioaddr\n", ndev->name);
+	}
=20
 	*aup->enable =3D 0;
 	aup->mac_enabled =3D 0;
=20
-	aup->mii_bus.priv =3D dev;
-	aup->mii_bus.read =3D mdiobus_read;
-	aup->mii_bus.write =3D mdiobus_write;
-	aup->mii_bus.reset =3D mdiobus_reset;
-	aup->mii_bus.name =3D "au1000_eth_mii";
-	aup->mii_bus.id =3D aup->mac_id;
-	aup->mii_bus.irq =3D kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
-	for(i =3D 0; i < PHY_MAX_ADDR; ++i)
-		aup->mii_bus.irq[i] =3D PHY_POLL;
-
-	/* if known, set corresponding PHY IRQs */
-#if defined(AU1XXX_PHY_STATIC_CONFIG)
-# if defined(AU1XXX_PHY0_IRQ)
-	if (AU1XXX_PHY0_BUSID =3D=3D aup->mii_bus.id)
-		aup->mii_bus.irq[AU1XXX_PHY0_ADDR] =3D AU1XXX_PHY0_IRQ;
-# endif
-# if defined(AU1XXX_PHY1_IRQ)
-	if (AU1XXX_PHY1_BUSID =3D=3D aup->mii_bus.id)
-		aup->mii_bus.irq[AU1XXX_PHY1_ADDR] =3D AU1XXX_PHY1_IRQ;
-# endif
-#endif
-	mdiobus_register(&aup->mii_bus);
-
-	if (mii_probe(dev) !=3D 0) {
-		goto err_out;
-	}
-
 	pDBfree =3D NULL;
 	/* setup the data buffer descriptors and attach a buffer to each one */
 	pDB =3D aup->db;
@@ -752,6 +651,7 @@ #endif
 	for (i =3D 0; i < NUM_RX_DMA; i++) {
 		pDB =3D GetFreeDB(aup);
 		if (!pDB) {
+			ret =3D -ENOMEM;
 			goto err_out;
 		}
 		aup->rx_dma_ring[i]->buff_stat =3D (unsigned)pDB->dma_addr;
@@ -760,6 +660,7 @@ #endif
 	for (i =3D 0; i < NUM_TX_DMA; i++) {
 		pDB =3D GetFreeDB(aup);
 		if (!pDB) {
+			ret =3D -ENOMEM;
 			goto err_out;
 		}
 		aup->tx_dma_ring[i]->buff_stat =3D (unsigned)pDB->dma_addr;
@@ -767,31 +668,23 @@ #endif
 		aup->tx_db_inuse[i] =3D pDB;
 	}
=20
-	spin_lock_init(&aup->lock);
-	dev->base_addr =3D base;
-	dev->irq =3D irq;
-	dev->open =3D au1000_open;
-	dev->hard_start_xmit =3D au1000_tx;
-	dev->stop =3D au1000_close;
-	dev->get_stats =3D au1000_get_stats;
-	dev->set_multicast_list =3D &set_rx_mode;
-	dev->do_ioctl =3D &au1000_ioctl;
-	SET_ETHTOOL_OPS(dev, &au1000_ethtool_ops);
-	dev->tx_timeout =3D au1000_tx_timeout;
-	dev->watchdog_timeo =3D ETH_TX_TIMEOUT;
+	return 0;
=20
-	/*=20
-	 * The boot code uses the ethernet controller, so reset it to start=20
-	 * fresh.  au1000_init() expects that the device is in reset state.
-	 */
-	reset_mac(dev);
+err_out :
+	au1000_lowlevel_remove(ndev);
+out :
+	return ret;
+}
=20
-	return dev;
+static void
+au1000_lowlevel_remove(struct net_device *ndev)
+{
+	struct au1000_private *aup =3D ndev->priv;
+	int i;
=20
-err_out:
 	/* here we should have a valid dev plus aup-> register addresses
 	 * so we can reset the mac properly.*/
-	reset_mac(dev);
+	reset_mac(ndev);
=20
 	for (i =3D 0; i < NUM_RX_DMA; i++) {
 		if (aup->rx_db_inuse[i])
@@ -801,13 +694,10 @@ err_out:
 		if (aup->tx_db_inuse[i])
 			ReleaseDB(aup, aup->tx_db_inuse[i]);
 	}
-	dma_free_noncoherent(NULL, MAX_BUF_SIZE * (NUM_TX_BUFFS + NUM_RX_BUFFS),
-			     (void *)aup->vaddr, aup->dma_addr);
-	unregister_netdev(dev);
-	free_netdev(dev);
-	release_mem_region( base, MAC_IOSIZE);
-	release_mem_region(macen, 4);
-	return NULL;
+	dma_free_noncoherent(NULL,
+			MAX_BUF_SIZE * (NUM_TX_BUFFS+NUM_RX_BUFFS),
+			(void *)aup->vaddr,
+			aup->dma_addr);
 }
=20
 /*=20
@@ -1009,38 +899,15 @@ static int au1000_close(struct net_devic
 	return 0;
 }
=20
-static void __exit au1000_cleanup_module(void)
-{
-	int i, j;
-	struct net_device *dev;
-	struct au1000_private *aup;
-
-	for (i =3D 0; i < num_ifs; i++) {
-		dev =3D iflist[i].dev;
-		if (dev) {
-			aup =3D (struct au1000_private *) dev->priv;
-			unregister_netdev(dev);
-			for (j =3D 0; j < NUM_RX_DMA; j++)
-				if (aup->rx_db_inuse[j])
-					ReleaseDB(aup, aup->rx_db_inuse[j]);
-			for (j =3D 0; j < NUM_TX_DMA; j++)
-				if (aup->tx_db_inuse[j])
-					ReleaseDB(aup, aup->tx_db_inuse[j]);
- 			dma_free_noncoherent(NULL, MAX_BUF_SIZE *
- 					     (NUM_TX_BUFFS + NUM_RX_BUFFS),
- 					     (void *)aup->vaddr, aup->dma_addr);
- 			release_mem_region(dev->base_addr, MAC_IOSIZE);
- 			release_mem_region(CPHYSADDR(iflist[i].macen_addr), 4);
-			free_netdev(dev);
-		}
-	}
-}
-
-static void update_tx_stats(struct net_device *dev, u32 status)
+static inline void
+update_tx_stats(struct net_device *dev, u32 status, u32 pkt_len)
 {
 	struct au1000_private *aup =3D (struct au1000_private *) dev->priv;
 	struct net_device_stats *ps =3D &aup->stats;
=20
+	ps->tx_packets++;
+	ps->tx_bytes +=3D pkt_len;
+
 	if (status & TX_FRAME_ABORTED) {
 		if (!aup->phy_dev || (DUPLEX_FULL =3D=3D aup->phy_dev->duplex)) {
 			if (status & (TX_JAB_TIMEOUT | TX_UNDERRUN)) {
@@ -1073,7 +940,7 @@ static void au1000_tx_ack(struct net_dev
 	ptxd =3D aup->tx_dma_ring[aup->tx_tail];
=20
 	while (ptxd->buff_stat & TX_T_DONE) {
-		update_tx_stats(dev, ptxd->status);
+		update_tx_stats(dev, ptxd->status, ptxd->len & 0x3ff);
 		ptxd->buff_stat &=3D ~TX_T_DONE;
 		ptxd->len =3D 0;
 		au_sync();
@@ -1095,7 +962,6 @@ static void au1000_tx_ack(struct net_dev
 static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 {
 	struct au1000_private *aup =3D (struct au1000_private *) dev->priv;
-	struct net_device_stats *ps =3D &aup->stats;
 	volatile tx_dma_t *ptxd;
 	u32 buff_stat;
 	db_dest_t *pDB;
@@ -1115,7 +981,7 @@ static int au1000_tx(struct sk_buff *skb
 		return 1;
 	}
 	else if (buff_stat & TX_T_DONE) {
-		update_tx_stats(dev, ptxd->status);
+		update_tx_stats(dev, ptxd->status, ptxd->len & 0x3ff);
 		ptxd->len =3D 0;
 	}
=20
@@ -1135,9 +1001,6 @@ static int au1000_tx(struct sk_buff *skb
 	else
 		ptxd->len =3D skb->len;
=20
-	ps->tx_packets++;
-	ps->tx_bytes +=3D ptxd->len;
-
 	ptxd->buff_stat =3D pDB->dma_addr | TX_DMA_ENABLE;
 	au_sync();
 	dev_kfree_skb(skb);
@@ -1340,5 +1203,251 @@ static struct net_device_stats *au1000_g
 	return 0;
 }
=20
-module_init(au1000_init_module);
-module_exit(au1000_cleanup_module);
+/*
+ * Setup the base address and interupt of the Au1xxx ethernet macs
+ * based on cpu type and whether the interface is enabled in sys_pinfunc
+ * register. The last interface is enabled if SYS_PF_NI2 (bit 4) is 0.
+ */
+static int au1000_drv_probe(struct device *dev)
+{
+	struct platform_device *pdev =3D to_platform_device(dev);
+	struct net_device *ndev;
+	struct au1000_private *aup;
+	struct resource *res;
+	static unsigned version_printed =3D 0;
+	u32 base_addr_phys;
+	void *base_addr, *macen_addr;
+	int i, irq, ret;
+
+	if (pdev->id =3D=3D 1 && (au_readl(SYS_PINFUNC) & SYS_PF_NI2) !=3D 0)
+		return -ENODEV;
+
+	/* Get the resource info */
+	res =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, "eth-base");
+	if (!res) {
+		ret =3D -ENODEV;
+		goto out;
+	}
+	base_addr_phys =3D res->start;
+	base_addr =3D ioremap(res->start, res->end - res->start);
+	if (!base_addr) {
+		printk (KERN_ERR "%s: unable to remap address %lx\n",
+		        DRV_NAME, (long unsigned int) res->start); =20
+		ret =3D -EINVAL;
+		goto out;
+	}
+	res =3D platform_get_resource_byname(pdev, IORESOURCE_MEM, "eth-mac");
+	if (!res) {
+		ret =3D -ENODEV;
+		goto out_release_io;
+	}
+	macen_addr =3D ioremap(res->start, res->end - res->start);
+	if (!macen_addr) {
+		printk (KERN_ERR "%s: unable to remap address %lx\n",
+		        DRV_NAME, (long unsigned int) res->start); =20
+		ret =3D -ENOMEM;
+		goto out_release_io;
+	}
+	res =3D platform_get_resource_byname(pdev, IORESOURCE_IRQ, "eth-irq");
+	if (!res) {
+		ret =3D -ENODEV;
+		goto out_release_iomac;
+	}
+	irq =3D res->start;
+
+	if (version_printed++ =3D=3D 0)=20
+		printk("%s version %s %s\n", DRV_NAME, DRV_VERSION, DRV_AUTHOR);
+
+	ndev =3D alloc_etherdev(sizeof(struct au1000_private));
+	if (!ndev) {
+		printk (KERN_ERR "%s: alloc etherdev failed\n", DRV_NAME); =20
+		ret =3D -ENOMEM;
+		goto out_release_iomac;
+	}
+	SET_MODULE_OWNER(ndev);
+	SET_NETDEV_DEV(ndev, dev);
+
+	/* Force the device name to a know state... */
+	sprintf(ndev->name, "au1xxx_eth(%d)", pdev->id);
+	ret =3D au1000_lowlevel_probe(ndev, base_addr, macen_addr, pdev->id, 0);
+	if (ret < 0) {
+		printk (KERN_ERR "%s: low level probe failed\n", DRV_NAME); =20
+		goto out_free_netdev;
+	}
+
+	aup =3D ndev->priv;
+
+	/* Register the MII bus */
+	aup->mii_bus.priv =3D ndev;
+	aup->mii_bus.read =3D mdiobus_read;
+	aup->mii_bus.write =3D mdiobus_write;
+	aup->mii_bus.reset =3D mdiobus_reset;
+	aup->mii_bus.name =3D "au1000_eth_mii";
+	aup->mii_bus.id =3D aup->mac_id;
+	aup->mii_bus.irq =3D kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	for(i =3D 0; i < PHY_MAX_ADDR; ++i)
+		aup->mii_bus.irq[i] =3D PHY_POLL;
+
+	/* if known, set corresponding PHY IRQs */
+#if defined(AU1XXX_PHY_STATIC_CONFIG)
+# if defined(AU1XXX_PHY0_IRQ)
+	if (AU1XXX_PHY0_BUSID =3D=3D aup->mii_bus.id)
+		aup->mii_bus.irq[AU1XXX_PHY0_ADDR] =3D AU1XXX_PHY0_IRQ;
+# endif
+# if defined(AU1XXX_PHY1_IRQ)
+	if (AU1XXX_PHY1_BUSID =3D=3D aup->mii_bus.id)
+		aup->mii_bus.irq[AU1XXX_PHY1_ADDR] =3D AU1XXX_PHY1_IRQ;
+# endif
+#endif
+	mdiobus_register(&aup->mii_bus);
+
+	if (mii_probe(ndev) !=3D 0) {
+		ret =3D -EBUSY;
+		goto out_lowlevel_remove;
+	}
+
+	/* Came back to a more standard name before registering the
+	 * net device... */
+	strcpy(ndev->name, "eth%d");
+
+	/* Setup base info */
+	spin_lock_init(&aup->lock);
+	ndev->base_addr =3D base_addr_phys;
+	ndev->irq =3D irq;
+	ndev->open =3D au1000_open;
+	ndev->hard_start_xmit =3D au1000_tx;
+	ndev->stop =3D au1000_close;
+	ndev->get_stats =3D au1000_get_stats;
+	ndev->set_multicast_list =3D &set_rx_mode;
+	ndev->do_ioctl =3D &au1000_ioctl;
+	SET_ETHTOOL_OPS(ndev, &au1000_ethtool_ops);
+	ndev->tx_timeout =3D au1000_tx_timeout;
+	ndev->watchdog_timeo =3D ETH_TX_TIMEOUT;
+
+	/*=20
+	 * The boot code uses the ethernet controller, so reset it to start=20
+	 * fresh.  au1000_init() expects that the device is in reset state.
+	 */
+	reset_mac(ndev);
+
+	ret =3D register_netdev(ndev);
+	if (ret) {
+		printk(KERN_ERR "%s: cannot register net device err %d\n",
+		       DRV_NAME, ret);
+		goto out_mdiobus_unregister;
+	}
+
+	printk("%s: Au1x Ethernet found at 0x%x, irq %d\n",=20
+			ndev->name, base_addr_phys, irq);
+
+	dev_set_drvdata(dev, ndev);
+
+	return 0;
+
+out_mdiobus_unregister :
+	mdiobus_unregister(&aup->mii_bus);
+out_lowlevel_remove :
+	au1000_lowlevel_remove(ndev);
+out_free_netdev :
+	free_netdev(ndev);
+out_release_iomac :
+	iounmap(macen_addr);
+out_release_io :
+	iounmap(base_addr);
+out :
+	printk("%s: not found (%d).\n", DRV_NAME, ret);
+
+	return ret;
+}
+
+static int au1000_drv_remove(struct device *dev)
+{
+	struct net_device *ndev =3D dev_get_drvdata(dev);
+	struct au1000_private *aup =3D (struct au1000_private *) ndev->priv;
+
+	dev_set_drvdata(dev, NULL);
+
+	unregister_netdev(ndev);
+	mdiobus_unregister(&aup->mii_bus);
+	au1000_lowlevel_remove(ndev);
+	free_netdev(ndev);
+
+	return 0;
+}
+
+#ifdef CONFIG_PM
+static int au1000_drv_suspend(struct device *dev, pm_message_t state)
+{
+	struct net_device *ndev =3D dev_get_drvdata(dev);
+	struct au1000_private *aup;
+	struct phy_device *phydev;
+
+	if (!ndev)
+		return 0;
+
+	aup =3D (struct au1000_private *) ndev->priv;
+	phydev =3D aup->phy_dev;
+
+	if (netif_running(ndev))
+		netif_device_detach(ndev);
+
+	au1000_lowlevel_remove(ndev);
+
+	return 0;
+}
+
+static int au1000_drv_resume(struct device *dev)
+{
+	struct net_device *ndev =3D dev_get_drvdata(dev);
+	struct au1000_private *aup;
+	struct phy_device *phydev;
+	int ret;
+
+	if (!ndev)
+		return 0;
+
+	aup =3D (struct au1000_private *) ndev->priv;
+	phydev =3D aup->phy_dev;
+
+	ret =3D au1000_lowlevel_probe(ndev, (void *) aup->mac, (void *) aup->enab=
le, aup->mac_id, ~0);
+	if (ret < 0) {
+		printk (KERN_ERR "%s: low level probe failed\n", DRV_NAME); =20
+		return ret;
+	}
+
+	/* au1000_init() expects that the device is in reset state.
+	 */
+	aup->mii_bus.reset(&aup->mii_bus);
+	reset_mac(ndev);
+	au1000_init(ndev);
+
+	if (netif_running(ndev))
+		netif_device_attach(ndev);
+
+	return 0;
+}
+#endif
+
+static struct device_driver au1000_driver =3D {
+	.name		=3D DRV_NAME,
+	.bus		=3D &platform_bus_type,
+	.probe          =3D au1000_drv_probe,
+	.remove         =3D au1000_drv_remove,
+#ifdef CONFIG_PM
+	.suspend        =3D au1000_drv_suspend,
+	.resume         =3D au1000_drv_resume,
+#endif
+};
+
+static int __init au1000_eth_init(void)
+{
+	return driver_register(&au1000_driver);
+}
+
+static void __exit au1000_eth_cleanup(void)
+{
+	driver_unregister(&au1000_driver);
+}
+
+module_init(au1000_eth_init);
+module_exit(au1000_eth_cleanup);
diff --git a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
index 41c2f84..056ecdc 100644
--- a/drivers/net/au1000_eth.h
+++ b/drivers/net/au1000_eth.h
@@ -27,7 +27,6 @@
  */
=20
=20
-#define MAC_IOSIZE 0x10000
 #define NUM_RX_DMA 4       /* Au1x00 has 4 rx hardware descriptors */
 #define NUM_TX_DMA 4       /* Au1x00 has 4 tx hardware descriptors */
=20
diff --git a/include/asm-mips/mach-au1x00/au1000.h b/include/asm-mips/mach-=
au1x00/au1000.h
index 582acd8..5d58ce6 100644
--- a/include/asm-mips/mach-au1x00/au1000.h
+++ b/include/asm-mips/mach-au1x00/au1000.h
@@ -605,11 +605,11 @@ #define UART3_ADDR                0xB140
 #define USB_OHCI_BASE             0x10100000 // phys addr for ioremap
 #define USB_HOST_CONFIG           0xB017fffc
=20
-#define AU1000_ETH0_BASE      0xB0500000
-#define AU1000_ETH1_BASE      0xB0510000
-#define AU1000_MAC0_ENABLE       0xB0520000
-#define AU1000_MAC1_ENABLE       0xB0520004
-#define NUM_ETH_INTERFACES 2
+#define ETH0_BASE                 0x10500000
+#define ETH1_BASE                 0x10510000
+#define MAC0_ENABLE               0x10520000
+#define MAC1_ENABLE               0x10520004
+#define NUM_ETH_INTERFACES        2
 #endif /* CONFIG_SOC_AU1000 */
=20
 /* Au1500 */
@@ -634,8 +634,8 @@ #define AU1000_USB_DEV_REQ_INT    24
 #define AU1000_USB_DEV_SUS_INT    25
 #define AU1000_USB_HOST_INT       26
 #define AU1000_ACSYNC_INT         27
-#define AU1500_MAC0_DMA_INT       28
-#define AU1500_MAC1_DMA_INT       29
+#define AU1000_MAC0_DMA_INT       28
+#define AU1000_MAC1_DMA_INT       29
 #define AU1000_AC97C_INT          31
 #define AU1000_GPIO_0             32
 #define AU1000_GPIO_1             33
@@ -682,11 +682,11 @@ #define UART3_ADDR                0xB140
 #define USB_OHCI_BASE             0x10100000 // phys addr for ioremap
 #define USB_HOST_CONFIG           0xB017fffc
=20
-#define AU1500_ETH0_BASE	  0xB1500000
-#define AU1500_ETH1_BASE	  0xB1510000
-#define AU1500_MAC0_ENABLE       0xB1520000
-#define AU1500_MAC1_ENABLE       0xB1520004
-#define NUM_ETH_INTERFACES 2
+#define ETH0_BASE	          0x11500000
+#define ETH1_BASE	          0x11510000
+#define MAC0_ENABLE               0x11520000
+#define MAC1_ENABLE               0x11520004
+#define NUM_ETH_INTERFACES        2
 #endif /* CONFIG_SOC_AU1500 */
=20
 /* Au1100 */
@@ -712,7 +712,7 @@ #define AU1000_USB_DEV_REQ_INT    24
 #define AU1000_USB_DEV_SUS_INT    25
 #define AU1000_USB_HOST_INT       26
 #define AU1000_ACSYNC_INT         27
-#define AU1100_MAC0_DMA_INT       28
+#define AU1000_MAC0_DMA_INT       28
 #define	AU1100_GPIO_208_215	29
 #define	AU1100_LCD_INT            30
 #define AU1000_AC97C_INT          31
@@ -756,9 +756,9 @@ #define UART3_ADDR                0xB140
 #define USB_OHCI_BASE             0x10100000 // phys addr for ioremap
 #define USB_HOST_CONFIG           0xB017fffc
=20
-#define AU1100_ETH0_BASE	  0xB0500000
-#define AU1100_MAC0_ENABLE       0xB0520000
-#define NUM_ETH_INTERFACES 1
+#define ETH0_BASE	          0x10500000
+#define MAC0_ENABLE               0x10520000
+#define NUM_ETH_INTERFACES        1
 #endif /* CONFIG_SOC_AU1100 */
=20
 #ifdef CONFIG_SOC_AU1550
@@ -791,8 +791,8 @@ #define AU1550_USB_HOST_INT       26
 #define AU1000_USB_DEV_REQ_INT    AU1550_USB_DEV_REQ_INT
 #define AU1000_USB_DEV_SUS_INT    AU1550_USB_DEV_SUS_INT
 #define AU1000_USB_HOST_INT       AU1550_USB_HOST_INT
-#define AU1550_MAC0_DMA_INT       27
-#define AU1550_MAC1_DMA_INT       28
+#define AU1000_MAC0_DMA_INT       27
+#define AU1000_MAC1_DMA_INT       28
 #define AU1000_GPIO_0             32
 #define AU1000_GPIO_1             33
 #define AU1000_GPIO_2             34
@@ -840,11 +840,11 @@ #define USB_OHCI_BASE             0x1402
 #define USB_OHCI_LEN              0x00060000
 #define USB_HOST_CONFIG           0xB4027ffc
=20
-#define AU1550_ETH0_BASE      0xB0500000
-#define AU1550_ETH1_BASE      0xB0510000
-#define AU1550_MAC0_ENABLE       0xB0520000
-#define AU1550_MAC1_ENABLE       0xB0520004
-#define NUM_ETH_INTERFACES 2
+#define ETH0_BASE                 0x10500000
+#define ETH1_BASE                 0x10510000
+#define MAC0_ENABLE               0x10520000
+#define MAC1_ENABLE               0x10520004
+#define NUM_ETH_INTERFACES        2
 #endif /* CONFIG_SOC_AU1550 */
=20
 #ifdef CONFIG_SOC_AU1200
@@ -1069,6 +1069,7 @@ #define USBD_ENABLE               0xB020
 #endif /* !CONFIG_SOC_AU1200 */
=20
 /* Ethernet Controllers  */
+#define MAC_IOSIZE                      0x10000
=20
 /* 4 byte offsets from AU1000_ETH_BASE */
 #define MAC_CONTROL                     0x0

--Clx92ZfkiYIKRjnr--

--BI5RvnYi6R4T2M87
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFEve10QaTCYNJaVjMRAlLBAJ4neCWWLsTpZWC3+GjBaAFCw8PzMwCfVRJt
9Bzh6yRSkLGmkwfswhetgTg=
=OKxn
-----END PGP SIGNATURE-----

--BI5RvnYi6R4T2M87--
