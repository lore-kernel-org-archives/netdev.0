From: Herbert Valerio Riedel <hvr@gnu.org>
Subject: [PATCH netdev-2.6#upstream] net: au1000_eth: PHY framework conversion
Date: Thu, 1 Jun 2006 09:41:04 +0200
Message-ID: <E1Fli0i-0006o2-Tb@fencepost.gnu.org>
Cc: linux-mips@linux-mips.org, jgarzik@pobox.com,
	ppopov@embeddedalley.com, sshtylyov@ru.mvista.com,
	ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:43210 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1750769AbWFAHyd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jun 2006 03:54:33 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

convert au1000_eth driver to use PHY framework and garbage collected
functions and identifiers that became unused/obsolete in the process

Signed-off-by: Herbert Valerio Riedel <hvr@gnu.org>

---

this is a resend of
http://marc.theaimsgroup.com/?l=linux-netdev&m=114746547301867&w=2
rebased&handmerged to netdev-2.6#upstream (i.e. on top of sergei's
probe code cleanup patch)

 drivers/net/Kconfig      |    1 
 drivers/net/au1000_eth.c | 1602 +++++++++++-----------------------------------
 drivers/net/au1000_eth.h |  134 ----
 3 files changed, 378 insertions(+), 1359 deletions(-)

616e5a012a927d401befcbed37b77c3ea42da5a5
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f499a3b..520765d 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -447,6 +447,7 @@ config MIPS_GT96100ETH
 config MIPS_AU1X00_ENET
 	bool "MIPS AU1000 Ethernet support"
 	depends on NET_ETHERNET && SOC_AU1X00
+	select PHYLIB
 	select CRC32
 	help
 	  If you have an Alchemy Semi AU1X00 based system
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index e1fe960..038d5fc 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -9,6 +9,9 @@
  * Update: 2004 Bjoern Riemer, riemer@fokus.fraunhofer.de 
  * or riemer@riemer-nt.de: fixed the link beat detection with 
  * ioctls (SIOCGMIIPHY)
+ * Copyright 2006 Herbert Valerio Riedel <hvr@gnu.org>
+ *  converted to use linux-2.6.x's PHY framework
+ *
  * Author: MontaVista Software, Inc.
  *         	ppopov@mvista.com or source@mvista.com
  *
@@ -53,6 +56,7 @@ #include <linux/mii.h>
 #include <linux/skbuff.h>
 #include <linux/delay.h>
 #include <linux/crc32.h>
+#include <linux/phy.h>
 #include <asm/mipsregs.h>
 #include <asm/irq.h>
 #include <asm/io.h>
@@ -88,17 +92,15 @@ static int au1000_tx(struct sk_buff *, s
 static int au1000_rx(struct net_device *);
 static irqreturn_t au1000_interrupt(int, void *, struct pt_regs *);
 static void au1000_tx_timeout(struct net_device *);
-static int au1000_set_config(struct net_device *dev, struct ifmap *map);
 static void set_rx_mode(struct net_device *);
 static struct net_device_stats *au1000_get_stats(struct net_device *);
-static void au1000_timer(unsigned long);
 static int au1000_ioctl(struct net_device *, struct ifreq *, int);
 static int mdio_read(struct net_device *, int, int);
 static void mdio_write(struct net_device *, int, int, u16);
-static void dump_mii(struct net_device *dev, int phy_id);
+static void au1000_adjust_link(struct net_device *);
+static void enable_mac(struct net_device *, int);
 
 // externs
-extern  void ack_rise_edge_irq(unsigned int);
 extern int get_ethernet_addr(char *ethernet_addr);
 extern void str2eaddr(unsigned char *ea, unsigned char *str);
 extern char * __init prom_getcmdline(void);
@@ -126,705 +128,83 @@ static unsigned char au1000_mac_addr[6] 
 	0x00, 0x50, 0xc2, 0x0c, 0x30, 0x00
 };
 
-#define nibswap(x) ((((x) >> 4) & 0x0f) | (((x) << 4) & 0xf0))
-#define RUN_AT(x) (jiffies + (x))
-
-// For reading/writing 32-bit words from/to DMA memory
-#define cpu_to_dma32 cpu_to_be32
-#define dma32_to_cpu be32_to_cpu
-
 struct au1000_private *au_macs[NUM_ETH_INTERFACES];
 
-/* FIXME 
- * All of the PHY code really should be detached from the MAC 
- * code.
+/*
+ * board-specific configurations
+ *
+ * PHY detection algorithm
+ *
+ * If AU1XXX_PHY_STATIC_CONFIG is undefined, the PHY setup is
+ * autodetected:
+ *
+ * mii_probe() first searches the current MAC's MII bus for a PHY,
+ * selecting the first (or last, if AU1XXX_PHY_SEARCH_HIGHEST_ADDR is
+ * defined) PHY address not already claimed by another netdev.
+ *
+ * If nothing was found that way when searching for the 2nd ethernet
+ * controller's PHY and AU1XXX_PHY1_SEARCH_ON_MAC0 is defined, then
+ * the first MII bus is searched as well for an unclaimed PHY; this is
+ * needed in case of a dual-PHY accessible only through the MAC0's MII
+ * bus.
+ *
+ * Finally, if no PHY is found, then the corresponding ethernet
+ * controller is not registered to the network subsystem.
  */
 
-/* Default advertise */
-#define GENMII_DEFAULT_ADVERTISE \
-	ADVERTISED_10baseT_Half | ADVERTISED_10baseT_Full | \
-	ADVERTISED_100baseT_Half | ADVERTISED_100baseT_Full | \
-	ADVERTISED_Autoneg
-
-#define GENMII_DEFAULT_FEATURES \
-	SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full | \
-	SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full | \
-	SUPPORTED_Autoneg
-
-int bcm_5201_init(struct net_device *dev, int phy_addr)
-{
-	s16 data;
-	
-	/* Stop auto-negotiation */
-	data = mdio_read(dev, phy_addr, MII_CONTROL);
-	mdio_write(dev, phy_addr, MII_CONTROL, data & ~MII_CNTL_AUTO);
-
-	/* Set advertisement to 10/100 and Half/Full duplex
-	 * (full capabilities) */
-	data = mdio_read(dev, phy_addr, MII_ANADV);
-	data |= MII_NWAY_TX | MII_NWAY_TX_FDX | MII_NWAY_T_FDX | MII_NWAY_T;
-	mdio_write(dev, phy_addr, MII_ANADV, data);
-	
-	/* Restart auto-negotiation */
-	data = mdio_read(dev, phy_addr, MII_CONTROL);
-	data |= MII_CNTL_RST_AUTO | MII_CNTL_AUTO;
-	mdio_write(dev, phy_addr, MII_CONTROL, data);
-
-	if (au1000_debug > 4) 
-		dump_mii(dev, phy_addr);
-	return 0;
-}
-
-int bcm_5201_reset(struct net_device *dev, int phy_addr)
-{
-	s16 mii_control, timeout;
-	
-	mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
-	mdio_write(dev, phy_addr, MII_CONTROL, mii_control | MII_CNTL_RESET);
-	mdelay(1);
-	for (timeout = 100; timeout > 0; --timeout) {
-		mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
-		if ((mii_control & MII_CNTL_RESET) == 0)
-			break;
-		mdelay(1);
-	}
-	if (mii_control & MII_CNTL_RESET) {
-		printk(KERN_ERR "%s PHY reset timeout !\n", dev->name);
-		return -1;
-	}
-	return 0;
-}
-
-int 
-bcm_5201_status(struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
-{
-	u16 mii_data;
-	struct au1000_private *aup;
-
-	if (!dev) {
-		printk(KERN_ERR "bcm_5201_status error: NULL dev\n");
-		return -1;
-	}
-	aup = (struct au1000_private *) dev->priv;
-
-	mii_data = mdio_read(dev, aup->phy_addr, MII_STATUS);
-	if (mii_data & MII_STAT_LINK) {
-		*link = 1;
-		mii_data = mdio_read(dev, aup->phy_addr, MII_AUX_CNTRL);
-		if (mii_data & MII_AUX_100) {
-			if (mii_data & MII_AUX_FDX) {
-				*speed = IF_PORT_100BASEFX;
-				dev->if_port = IF_PORT_100BASEFX;
-			}
-			else {
-				*speed = IF_PORT_100BASETX;
-				dev->if_port = IF_PORT_100BASETX;
-			}
-		}
-		else  {
-			*speed = IF_PORT_10BASET;
-			dev->if_port = IF_PORT_10BASET;
-		}
-
-	}
-	else {
-		*link = 0;
-		*speed = 0;
-		dev->if_port = IF_PORT_UNKNOWN;
-	}
-	return 0;
-}
-
-int lsi_80227_init(struct net_device *dev, int phy_addr)
-{
-	if (au1000_debug > 4)
-		printk("lsi_80227_init\n");
-
-	/* restart auto-negotiation */
-	mdio_write(dev, phy_addr, MII_CONTROL,
-		   MII_CNTL_F100 | MII_CNTL_AUTO | MII_CNTL_RST_AUTO); // | MII_CNTL_FDX);
-	mdelay(1);
-
-	/* set up LEDs to correct display */
-#ifdef CONFIG_MIPS_MTX1
-	mdio_write(dev, phy_addr, 17, 0xff80);
-#else
-	mdio_write(dev, phy_addr, 17, 0xffc0);
-#endif
-
-	if (au1000_debug > 4)
-		dump_mii(dev, phy_addr);
-	return 0;
-}
-
-int lsi_80227_reset(struct net_device *dev, int phy_addr)
-{
-	s16 mii_control, timeout;
-	
-	if (au1000_debug > 4) {
-		printk("lsi_80227_reset\n");
-		dump_mii(dev, phy_addr);
-	}
-
-	mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
-	mdio_write(dev, phy_addr, MII_CONTROL, mii_control | MII_CNTL_RESET);
-	mdelay(1);
-	for (timeout = 100; timeout > 0; --timeout) {
-		mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
-		if ((mii_control & MII_CNTL_RESET) == 0)
-			break;
-		mdelay(1);
-	}
-	if (mii_control & MII_CNTL_RESET) {
-		printk(KERN_ERR "%s PHY reset timeout !\n", dev->name);
-		return -1;
-	}
-	return 0;
-}
-
-int
-lsi_80227_status(struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
-{
-	u16 mii_data;
-	struct au1000_private *aup;
-
-	if (!dev) {
-		printk(KERN_ERR "lsi_80227_status error: NULL dev\n");
-		return -1;
-	}
-	aup = (struct au1000_private *) dev->priv;
-
-	mii_data = mdio_read(dev, aup->phy_addr, MII_STATUS);
-	if (mii_data & MII_STAT_LINK) {
-		*link = 1;
-		mii_data = mdio_read(dev, aup->phy_addr, MII_LSI_PHY_STAT);
-		if (mii_data & MII_LSI_PHY_STAT_SPD) {
-			if (mii_data & MII_LSI_PHY_STAT_FDX) {
-				*speed = IF_PORT_100BASEFX;
-				dev->if_port = IF_PORT_100BASEFX;
-			}
-			else {
-				*speed = IF_PORT_100BASETX;
-				dev->if_port = IF_PORT_100BASETX;
-			}
-		}
-		else  {
-			*speed = IF_PORT_10BASET;
-			dev->if_port = IF_PORT_10BASET;
-		}
-
-	}
-	else {
-		*link = 0;
-		*speed = 0;
-		dev->if_port = IF_PORT_UNKNOWN;
-	}
-	return 0;
-}
-
-int am79c901_init(struct net_device *dev, int phy_addr)
-{
-	printk("am79c901_init\n");
-	return 0;
-}
-
-int am79c901_reset(struct net_device *dev, int phy_addr)
-{
-	printk("am79c901_reset\n");
-	return 0;
-}
-
-int 
-am79c901_status(struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
-{
-	return 0;
-}
-
-int am79c874_init(struct net_device *dev, int phy_addr)
-{
-	s16 data;
-
-	/* 79c874 has quit resembled bit assignments to BCM5201 */
-	if (au1000_debug > 4)
-		printk("am79c847_init\n");
-
-	/* Stop auto-negotiation */
-	data = mdio_read(dev, phy_addr, MII_CONTROL);
-	mdio_write(dev, phy_addr, MII_CONTROL, data & ~MII_CNTL_AUTO);
-
-	/* Set advertisement to 10/100 and Half/Full duplex
-	 * (full capabilities) */
-	data = mdio_read(dev, phy_addr, MII_ANADV);
-	data |= MII_NWAY_TX | MII_NWAY_TX_FDX | MII_NWAY_T_FDX | MII_NWAY_T;
-	mdio_write(dev, phy_addr, MII_ANADV, data);
-	
-	/* Restart auto-negotiation */
-	data = mdio_read(dev, phy_addr, MII_CONTROL);
-	data |= MII_CNTL_RST_AUTO | MII_CNTL_AUTO;
-
-	mdio_write(dev, phy_addr, MII_CONTROL, data);
-
-	if (au1000_debug > 4) dump_mii(dev, phy_addr);
-	return 0;
-}
-
-int am79c874_reset(struct net_device *dev, int phy_addr)
-{
-	s16 mii_control, timeout;
-	
-	if (au1000_debug > 4)
-		printk("am79c874_reset\n");
-
-	mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
-	mdio_write(dev, phy_addr, MII_CONTROL, mii_control | MII_CNTL_RESET);
-	mdelay(1);
-	for (timeout = 100; timeout > 0; --timeout) {
-		mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
-		if ((mii_control & MII_CNTL_RESET) == 0)
-			break;
-		mdelay(1);
-	}
-	if (mii_control & MII_CNTL_RESET) {
-		printk(KERN_ERR "%s PHY reset timeout !\n", dev->name);
-		return -1;
-	}
-	return 0;
-}
-
-int 
-am79c874_status(struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
-{
-	u16 mii_data;
-	struct au1000_private *aup;
-
-	// printk("am79c874_status\n");
-	if (!dev) {
-		printk(KERN_ERR "am79c874_status error: NULL dev\n");
-		return -1;
-	}
-
-	aup = (struct au1000_private *) dev->priv;
-	mii_data = mdio_read(dev, aup->phy_addr, MII_STATUS);
+/* autodetection defaults */
+#undef  AU1XXX_PHY_SEARCH_HIGHEST_ADDR
+#define AU1XXX_PHY1_SEARCH_ON_MAC0
 
-	if (mii_data & MII_STAT_LINK) {
-		*link = 1;
-		mii_data = mdio_read(dev, aup->phy_addr, MII_AMD_PHY_STAT);
-		if (mii_data & MII_AMD_PHY_STAT_SPD) {
-			if (mii_data & MII_AMD_PHY_STAT_FDX) {
-				*speed = IF_PORT_100BASEFX;
-				dev->if_port = IF_PORT_100BASEFX;
-			}
-			else {
-				*speed = IF_PORT_100BASETX;
-				dev->if_port = IF_PORT_100BASETX;
-			}
-		}
-		else {
-			*speed = IF_PORT_10BASET;
-			dev->if_port = IF_PORT_10BASET;
-		}
-
-	}
-	else {
-		*link = 0;
-		*speed = 0;
-		dev->if_port = IF_PORT_UNKNOWN;
-	}
-	return 0;
-}
-
-int lxt971a_init(struct net_device *dev, int phy_addr)
-{
-	if (au1000_debug > 4)
-		printk("lxt971a_init\n");
-
-	/* restart auto-negotiation */
-	mdio_write(dev, phy_addr, MII_CONTROL,
-		   MII_CNTL_F100 | MII_CNTL_AUTO | MII_CNTL_RST_AUTO | MII_CNTL_FDX);
-
-	/* set up LEDs to correct display */
-	mdio_write(dev, phy_addr, 20, 0x0422);
-
-	if (au1000_debug > 4)
-		dump_mii(dev, phy_addr);
-	return 0;
-}
-
-int lxt971a_reset(struct net_device *dev, int phy_addr)
-{
-	s16 mii_control, timeout;
-	
-	if (au1000_debug > 4) {
-		printk("lxt971a_reset\n");
-		dump_mii(dev, phy_addr);
-	}
-
-	mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
-	mdio_write(dev, phy_addr, MII_CONTROL, mii_control | MII_CNTL_RESET);
-	mdelay(1);
-	for (timeout = 100; timeout > 0; --timeout) {
-		mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
-		if ((mii_control & MII_CNTL_RESET) == 0)
-			break;
-		mdelay(1);
-	}
-	if (mii_control & MII_CNTL_RESET) {
-		printk(KERN_ERR "%s PHY reset timeout !\n", dev->name);
-		return -1;
-	}
-	return 0;
-}
-
-int
-lxt971a_status(struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
-{
-	u16 mii_data;
-	struct au1000_private *aup;
-
-	if (!dev) {
-		printk(KERN_ERR "lxt971a_status error: NULL dev\n");
-		return -1;
-	}
-	aup = (struct au1000_private *) dev->priv;
-
-	mii_data = mdio_read(dev, aup->phy_addr, MII_STATUS);
-	if (mii_data & MII_STAT_LINK) {
-		*link = 1;
-		mii_data = mdio_read(dev, aup->phy_addr, MII_INTEL_PHY_STAT);
-		if (mii_data & MII_INTEL_PHY_STAT_SPD) {
-			if (mii_data & MII_INTEL_PHY_STAT_FDX) {
-				*speed = IF_PORT_100BASEFX;
-				dev->if_port = IF_PORT_100BASEFX;
-			}
-			else {
-				*speed = IF_PORT_100BASETX;
-				dev->if_port = IF_PORT_100BASETX;
-			}
-		}
-		else  {
-			*speed = IF_PORT_10BASET;
-			dev->if_port = IF_PORT_10BASET;
-		}
-
-	}
-	else {
-		*link = 0;
-		*speed = 0;
-		dev->if_port = IF_PORT_UNKNOWN;
-	}
-	return 0;
-}
-
-int ks8995m_init(struct net_device *dev, int phy_addr)
-{
-	s16 data;
-	
-//	printk("ks8995m_init\n");
-	/* Stop auto-negotiation */
-	data = mdio_read(dev, phy_addr, MII_CONTROL);
-	mdio_write(dev, phy_addr, MII_CONTROL, data & ~MII_CNTL_AUTO);
-
-	/* Set advertisement to 10/100 and Half/Full duplex
-	 * (full capabilities) */
-	data = mdio_read(dev, phy_addr, MII_ANADV);
-	data |= MII_NWAY_TX | MII_NWAY_TX_FDX | MII_NWAY_T_FDX | MII_NWAY_T;
-	mdio_write(dev, phy_addr, MII_ANADV, data);
-	
-	/* Restart auto-negotiation */
-	data = mdio_read(dev, phy_addr, MII_CONTROL);
-	data |= MII_CNTL_RST_AUTO | MII_CNTL_AUTO;
-	mdio_write(dev, phy_addr, MII_CONTROL, data);
-
-	if (au1000_debug > 4) dump_mii(dev, phy_addr);
-
-	return 0;
-}
-
-int ks8995m_reset(struct net_device *dev, int phy_addr)
-{
-	s16 mii_control, timeout;
-	
-//	printk("ks8995m_reset\n");
-	mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
-	mdio_write(dev, phy_addr, MII_CONTROL, mii_control | MII_CNTL_RESET);
-	mdelay(1);
-	for (timeout = 100; timeout > 0; --timeout) {
-		mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
-		if ((mii_control & MII_CNTL_RESET) == 0)
-			break;
-		mdelay(1);
-	}
-	if (mii_control & MII_CNTL_RESET) {
-		printk(KERN_ERR "%s PHY reset timeout !\n", dev->name);
-		return -1;
-	}
-	return 0;
-}
-
-int ks8995m_status(struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
-{
-	u16 mii_data;
-	struct au1000_private *aup;
-
-	if (!dev) {
-		printk(KERN_ERR "ks8995m_status error: NULL dev\n");
-		return -1;
-	}
-	aup = (struct au1000_private *) dev->priv;
-
-	mii_data = mdio_read(dev, aup->phy_addr, MII_STATUS);
-	if (mii_data & MII_STAT_LINK) {
-		*link = 1;
-		mii_data = mdio_read(dev, aup->phy_addr, MII_AUX_CNTRL);
-		if (mii_data & MII_AUX_100) {
-			if (mii_data & MII_AUX_FDX) {
-				*speed = IF_PORT_100BASEFX;
-				dev->if_port = IF_PORT_100BASEFX;
-			}
-			else {
-				*speed = IF_PORT_100BASETX;
-				dev->if_port = IF_PORT_100BASETX;
-			}
-		}
-		else  {											
-			*speed = IF_PORT_10BASET;
-			dev->if_port = IF_PORT_10BASET;
-		}
-
-	}
-	else {
-		*link = 0;
-		*speed = 0;
-		dev->if_port = IF_PORT_UNKNOWN;
-	}
-	return 0;
-}
-
-int
-smsc_83C185_init (struct net_device *dev, int phy_addr)
-{
-	s16 data;
-
-	if (au1000_debug > 4)
-		printk("smsc_83C185_init\n");
-
-	/* Stop auto-negotiation */
-	data = mdio_read(dev, phy_addr, MII_CONTROL);
-	mdio_write(dev, phy_addr, MII_CONTROL, data & ~MII_CNTL_AUTO);
-
-	/* Set advertisement to 10/100 and Half/Full duplex
-	 * (full capabilities) */
-	data = mdio_read(dev, phy_addr, MII_ANADV);
-	data |= MII_NWAY_TX | MII_NWAY_TX_FDX | MII_NWAY_T_FDX | MII_NWAY_T;
-	mdio_write(dev, phy_addr, MII_ANADV, data);
-	
-	/* Restart auto-negotiation */
-	data = mdio_read(dev, phy_addr, MII_CONTROL);
-	data |= MII_CNTL_RST_AUTO | MII_CNTL_AUTO;
-
-	mdio_write(dev, phy_addr, MII_CONTROL, data);
-
-	if (au1000_debug > 4) dump_mii(dev, phy_addr);
-	return 0;
-}
-
-int
-smsc_83C185_reset (struct net_device *dev, int phy_addr)
-{
-	s16 mii_control, timeout;
-	
-	if (au1000_debug > 4)
-		printk("smsc_83C185_reset\n");
-
-	mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
-	mdio_write(dev, phy_addr, MII_CONTROL, mii_control | MII_CNTL_RESET);
-	mdelay(1);
-	for (timeout = 100; timeout > 0; --timeout) {
-		mii_control = mdio_read(dev, phy_addr, MII_CONTROL);
-		if ((mii_control & MII_CNTL_RESET) == 0)
-			break;
-		mdelay(1);
-	}
-	if (mii_control & MII_CNTL_RESET) {
-		printk(KERN_ERR "%s PHY reset timeout !\n", dev->name);
-		return -1;
-	}
-	return 0;
-}
-
-int 
-smsc_83C185_status (struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
-{
-	u16 mii_data;
-	struct au1000_private *aup;
-
-	if (!dev) {
-		printk(KERN_ERR "smsc_83C185_status error: NULL dev\n");
-		return -1;
-	}
-
-	aup = (struct au1000_private *) dev->priv;
-	mii_data = mdio_read(dev, aup->phy_addr, MII_STATUS);
-
-	if (mii_data & MII_STAT_LINK) {
-		*link = 1;
-		mii_data = mdio_read(dev, aup->phy_addr, 0x1f);
-		if (mii_data & (1<<3)) {
-			if (mii_data & (1<<4)) {
-				*speed = IF_PORT_100BASEFX;
-				dev->if_port = IF_PORT_100BASEFX;
-			}
-			else {
-				*speed = IF_PORT_100BASETX;
-				dev->if_port = IF_PORT_100BASETX;
-			}
-		}
-		else {
-			*speed = IF_PORT_10BASET;
-			dev->if_port = IF_PORT_10BASET;
-		}
-	}
-	else {
-		*link = 0;
-		*speed = 0;
-		dev->if_port = IF_PORT_UNKNOWN;
-	}
-	return 0;
-}
-
-
-#ifdef CONFIG_MIPS_BOSPORUS
-int stub_init(struct net_device *dev, int phy_addr)
-{
-	//printk("PHY stub_init\n");
-	return 0;
-}
-
-int stub_reset(struct net_device *dev, int phy_addr)
-{
-	//printk("PHY stub_reset\n");
-	return 0;
-}
-
-int 
-stub_status(struct net_device *dev, int phy_addr, u16 *link, u16 *speed)
-{
-	//printk("PHY stub_status\n");
-	*link = 1;
-	/* hmmm, revisit */
-	*speed = IF_PORT_100BASEFX;
-	dev->if_port = IF_PORT_100BASEFX;
-	return 0;
-}
-#endif
-
-struct phy_ops bcm_5201_ops = {
-	bcm_5201_init,
-	bcm_5201_reset,
-	bcm_5201_status,
-};
-
-struct phy_ops am79c874_ops = {
-	am79c874_init,
-	am79c874_reset,
-	am79c874_status,
-};
-
-struct phy_ops am79c901_ops = {
-	am79c901_init,
-	am79c901_reset,
-	am79c901_status,
-};
-
-struct phy_ops lsi_80227_ops = { 
-	lsi_80227_init,
-	lsi_80227_reset,
-	lsi_80227_status,
-};
-
-struct phy_ops lxt971a_ops = { 
-	lxt971a_init,
-	lxt971a_reset,
-	lxt971a_status,
-};
+/* static PHY setup
+ *
+ * most boards PHY setup should be detectable properly with the
+ * autodetection algorithm in mii_probe(), but in some cases (e.g. if
+ * you have a switch attached, or want to use the PHY's interrupt
+ * notification capabilities) you can provide a static PHY
+ * configuration here
+ *
+ * IRQs may only be set, if a PHY address was configured
+ * If a PHY address is given, also a bus id is required to be set
+ *
+ * ps: make sure the used irqs are configured properly in the board
+ * specific irq-map
+ */
 
-struct phy_ops ks8995m_ops = {
-	ks8995m_init,
-	ks8995m_reset,
-	ks8995m_status,
-};
+#if defined(CONFIG_MIPS_BOSPORUS)
+/*
+ * Micrel/Kendin 5 port switch attached to MAC0,
+ * MAC0 is associated with PHY address 5 (== WAN port)
+ * MAC1 is not associated with any PHY, since it's connected directly
+ * to the switch.
+ * no interrupts are used
+ */
+# define AU1XXX_PHY_STATIC_CONFIG
 
-struct phy_ops smsc_83C185_ops = {
-	smsc_83C185_init,
-	smsc_83C185_reset,
-	smsc_83C185_status,
-};
+# define AU1XXX_PHY0_ADDR  5
+# define AU1XXX_PHY0_BUSID 0
+#  undef AU1XXX_PHY0_IRQ
 
-#ifdef CONFIG_MIPS_BOSPORUS
-struct phy_ops stub_ops = {
-	stub_init,
-	stub_reset,
-	stub_status,
-};
+#  undef AU1XXX_PHY1_ADDR
+#  undef AU1XXX_PHY1_BUSID
+#  undef AU1XXX_PHY1_IRQ
 #endif
 
-static struct mii_chip_info {
-	const char * name;
-	u16 phy_id0;
-	u16 phy_id1;
-	struct phy_ops *phy_ops;	
-	int dual_phy;
-} mii_chip_table[] = {
-	{"Broadcom BCM5201 10/100 BaseT PHY",0x0040,0x6212, &bcm_5201_ops,0},
-	{"Broadcom BCM5221 10/100 BaseT PHY",0x0040,0x61e4, &bcm_5201_ops,0},
-	{"Broadcom BCM5222 10/100 BaseT PHY",0x0040,0x6322, &bcm_5201_ops,1},
-	{"NS DP83847 PHY", 0x2000, 0x5c30, &bcm_5201_ops ,0},
-	{"AMD 79C901 HomePNA PHY",0x0000,0x35c8, &am79c901_ops,0},
-	{"AMD 79C874 10/100 BaseT PHY",0x0022,0x561b, &am79c874_ops,0},
-	{"LSI 80227 10/100 BaseT PHY",0x0016,0xf840, &lsi_80227_ops,0},
-	{"Intel LXT971A Dual Speed PHY",0x0013,0x78e2, &lxt971a_ops,0},
-	{"Kendin KS8995M 10/100 BaseT PHY",0x0022,0x1450, &ks8995m_ops,0},
-	{"SMSC LAN83C185 10/100 BaseT PHY",0x0007,0xc0a3, &smsc_83C185_ops,0},
-#ifdef CONFIG_MIPS_BOSPORUS
-	{"Stub", 0x1234, 0x5678, &stub_ops },
+#if defined(AU1XXX_PHY0_BUSID) && (AU1XXX_PHY0_BUSID > 0)
+# error MAC0-associated PHY attached 2nd MACs MII bus not supported yet
 #endif
-	{0,},
-};
 
-static int mdio_read(struct net_device *dev, int phy_id, int reg)
+/*
+ * MII operations
+ */
+static int mdio_read(struct net_device *dev, int phy_addr, int reg)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
-	volatile u32 *mii_control_reg;
-	volatile u32 *mii_data_reg;
+	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
+	volatile u32 *const mii_data_reg = &aup->mac->mii_data;
 	u32 timedout = 20;
 	u32 mii_control;
 
-	#ifdef CONFIG_BCM5222_DUAL_PHY
-	/* First time we probe, it's for the mac0 phy.
-	 * Since we haven't determined yet that we have a dual phy,
-	 * aup->mii->mii_control_reg won't be setup and we'll
-	 * default to the else statement.
-	 * By the time we probe for the mac1 phy, the mii_control_reg
-	 * will be setup to be the address of the mac0 phy control since
-	 * both phys are controlled through mac0.
-	 */
-	if (aup->mii && aup->mii->mii_control_reg) {
-		mii_control_reg = aup->mii->mii_control_reg;
-		mii_data_reg = aup->mii->mii_data_reg;
-	}
-	else if (au_macs[0]->mii && au_macs[0]->mii->mii_control_reg) {
-		/* assume both phys are controlled through mac0 */
-		mii_control_reg = au_macs[0]->mii->mii_control_reg;
-		mii_data_reg = au_macs[0]->mii->mii_data_reg;
-	}
-	else 
-	#endif
-	{
-		/* default control and data reg addresses */
-		mii_control_reg = &aup->mac->mii_control;
-		mii_data_reg = &aup->mac->mii_data;
-	}
-
 	while (*mii_control_reg & MAC_MII_BUSY) {
 		mdelay(1);
 		if (--timedout == 0) {
@@ -835,7 +215,7 @@ static int mdio_read(struct net_device *
 	}
 
 	mii_control = MAC_SET_MII_SELECT_REG(reg) | 
-		MAC_SET_MII_SELECT_PHY(phy_id) | MAC_MII_READ;
+		MAC_SET_MII_SELECT_PHY(phy_addr) | MAC_MII_READ;
 
 	*mii_control_reg = mii_control;
 
@@ -851,32 +231,14 @@ static int mdio_read(struct net_device *
 	return (int)*mii_data_reg;
 }
 
-static void mdio_write(struct net_device *dev, int phy_id, int reg, u16 value)
+static void mdio_write(struct net_device *dev, int phy_addr, int reg, u16 value)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
-	volatile u32 *mii_control_reg;
-	volatile u32 *mii_data_reg;
+	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
+	volatile u32 *const mii_data_reg = &aup->mac->mii_data;
 	u32 timedout = 20;
 	u32 mii_control;
 
-	#ifdef CONFIG_BCM5222_DUAL_PHY
-	if (aup->mii && aup->mii->mii_control_reg) {
-		mii_control_reg = aup->mii->mii_control_reg;
-		mii_data_reg = aup->mii->mii_data_reg;
-	}
-	else if (au_macs[0]->mii && au_macs[0]->mii->mii_control_reg) {
-		/* assume both phys are controlled through mac0 */
-		mii_control_reg = au_macs[0]->mii->mii_control_reg;
-		mii_data_reg = au_macs[0]->mii->mii_data_reg;
-	}
-	else 
-	#endif
-	{
-		/* default control and data reg addresses */
-		mii_control_reg = &aup->mac->mii_control;
-		mii_data_reg = &aup->mac->mii_data;
-	}
-
 	while (*mii_control_reg & MAC_MII_BUSY) {
 		mdelay(1);
 		if (--timedout == 0) {
@@ -887,165 +249,145 @@ static void mdio_write(struct net_device
 	}
 
 	mii_control = MAC_SET_MII_SELECT_REG(reg) | 
-		MAC_SET_MII_SELECT_PHY(phy_id) | MAC_MII_WRITE;
+		MAC_SET_MII_SELECT_PHY(phy_addr) | MAC_MII_WRITE;
 
 	*mii_data_reg = value;
 	*mii_control_reg = mii_control;
 }
 
+static int mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
+{
+	/* WARNING: bus->phy_map[phy_addr].attached_dev == dev does
+	 * _NOT_ hold (e.g. when PHY is accessed through other MAC's MII bus) */
+	struct net_device *const dev = bus->priv;
+
+	enable_mac(dev, 0); /* make sure the MAC associated with this
+			     * mii_bus is enabled */
+	return mdio_read(dev, phy_addr, regnum);
+}
 
-static void dump_mii(struct net_device *dev, int phy_id)
+static int mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
+			 u16 value)
 {
-	int i, val;
+	struct net_device *const dev = bus->priv;
 
-	for (i = 0; i < 7; i++) {
-		if ((val = mdio_read(dev, phy_id, i)) >= 0)
-			printk("%s: MII Reg %d=%x\n", dev->name, i, val);
-	}
-	for (i = 16; i < 25; i++) {
-		if ((val = mdio_read(dev, phy_id, i)) >= 0)
-			printk("%s: MII Reg %d=%x\n", dev->name, i, val);
-	}
+	enable_mac(dev, 0); /* make sure the MAC associated with this
+			     * mii_bus is enabled */
+	mdio_write(dev, phy_addr, regnum, value);
+	return 0;
 }
 
-static int mii_probe (struct net_device * dev)
+static int mdiobus_reset(struct mii_bus *bus)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
-	int phy_addr;
-#ifdef CONFIG_MIPS_BOSPORUS
-	int phy_found=0;
-#endif
+	struct net_device *const dev = bus->priv;
 
-	/* search for total of 32 possible mii phy addresses */
-	for (phy_addr = 0; phy_addr < 32; phy_addr++) {
-		u16 mii_status;
-		u16 phy_id0, phy_id1;
-		int i;
+	enable_mac(dev, 0); /* make sure the MAC associated with this
+			     * mii_bus is enabled */
+	return 0;
+}
 
-		#ifdef CONFIG_BCM5222_DUAL_PHY
-		/* Mask the already found phy, try next one */
-		if (au_macs[0]->mii && au_macs[0]->mii->mii_control_reg) {
-			if (au_macs[0]->phy_addr == phy_addr)
-				continue;
-		}
-		#endif
-
-		mii_status = mdio_read(dev, phy_addr, MII_STATUS);
-		if (mii_status == 0xffff || mii_status == 0x0000)
-			/* the mii is not accessable, try next one */
-			continue;
-
-		phy_id0 = mdio_read(dev, phy_addr, MII_PHY_ID0);
-		phy_id1 = mdio_read(dev, phy_addr, MII_PHY_ID1);
-
-		/* search our mii table for the current mii */ 
-		for (i = 0; mii_chip_table[i].phy_id1; i++) {
-			if (phy_id0 == mii_chip_table[i].phy_id0 &&
-			    phy_id1 == mii_chip_table[i].phy_id1) {
-				struct mii_phy * mii_phy = aup->mii;
-
-				printk(KERN_INFO "%s: %s at phy address %d\n",
-				       dev->name, mii_chip_table[i].name, 
-				       phy_addr);
-#ifdef CONFIG_MIPS_BOSPORUS
-				phy_found = 1;
-#endif
-				mii_phy->chip_info = mii_chip_table+i;
-				aup->phy_addr = phy_addr;
-				aup->want_autoneg = 1;
-				aup->phy_ops = mii_chip_table[i].phy_ops;
-				aup->phy_ops->phy_init(dev,phy_addr);
-
-				// Check for dual-phy and then store required 
-				// values and set indicators. We need to do 
-				// this now since mdio_{read,write} need the 
-				// control and data register addresses.
-				#ifdef CONFIG_BCM5222_DUAL_PHY
-				if ( mii_chip_table[i].dual_phy) {
-
-					/* assume both phys are controlled 
-					 * through MAC0. Board specific? */
-					
-					/* sanity check */
-					if (!au_macs[0] || !au_macs[0]->mii)
-						return -1;
-					aup->mii->mii_control_reg = (u32 *)
-						&au_macs[0]->mac->mii_control;
-					aup->mii->mii_data_reg = (u32 *)
-						&au_macs[0]->mac->mii_data;
-				}
-				#endif
-				goto found;
-			}
+static int mii_probe (struct net_device *dev)
+{
+	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct phy_device *phydev = NULL;
+
+#if defined(AU1XXX_PHY_STATIC_CONFIG)
+	BUG_ON(aup->mac_id < 0 || aup->mac_id > 1);
+
+	if(aup->mac_id == 0) { /* get PHY0 */
+# if defined(AU1XXX_PHY0_ADDR)
+		phydev = au_macs[AU1XXX_PHY0_BUSID]->mii_bus.phy_map[AU1XXX_PHY0_ADDR];
+# else
+		printk (KERN_INFO DRV_NAME ":%s: using PHY-less setup\n",
+			dev->name);
+		return 0;
+# endif /* defined(AU1XXX_PHY0_ADDR) */
+	} else if (aup->mac_id == 1) { /* get PHY1 */
+# if defined(AU1XXX_PHY1_ADDR)
+		phydev = au_macs[AU1XXX_PHY1_BUSID]->mii_bus.phy_map[AU1XXX_PHY1_ADDR];
+# else
+		printk (KERN_INFO DRV_NAME ":%s: using PHY-less setup\n",
+			dev->name);
+		return 0;
+# endif /* defined(AU1XXX_PHY1_ADDR) */
+	}
+
+#else /* defined(AU1XXX_PHY_STATIC_CONFIG) */
+	int phy_addr;
+
+	/* find the first (lowest address) PHY on the current MAC's MII bus */
+	for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++)
+		if (aup->mii_bus.phy_map[phy_addr]) {
+			phydev = aup->mii_bus.phy_map[phy_addr];
+# if !defined(AU1XXX_PHY_SEARCH_HIGHEST_ADDR)
+			break; /* break out with first one found */
+# endif
 		}
-	}
-found:
-
-#ifdef CONFIG_MIPS_BOSPORUS
-	/* This is a workaround for the Micrel/Kendin 5 port switch
-	   The second MAC doesn't see a PHY connected... so we need to
-	   trick it into thinking we have one.
-		
-	   If this kernel is run on another Au1500 development board
-	   the stub will be found as well as the actual PHY. However,
-	   the last found PHY will be used... usually at Addr 31 (Db1500).	
-	*/
-	if ( (!phy_found) )
-	{
-		u16 phy_id0, phy_id1;
-		int i;
 
-		phy_id0 = 0x1234;
-		phy_id1 = 0x5678;
-
-		/* search our mii table for the current mii */ 
-		for (i = 0; mii_chip_table[i].phy_id1; i++) {
-			if (phy_id0 == mii_chip_table[i].phy_id0 &&
-			    phy_id1 == mii_chip_table[i].phy_id1) {
-				struct mii_phy * mii_phy;
-
-				printk(KERN_INFO "%s: %s at phy address %d\n",
-				       dev->name, mii_chip_table[i].name, 
-				       phy_addr);
-				mii_phy = kmalloc(sizeof(struct mii_phy), 
-						GFP_KERNEL);
-				if (mii_phy) {
-					mii_phy->chip_info = mii_chip_table+i;
-					aup->phy_addr = phy_addr;
-					mii_phy->next = aup->mii;
-					aup->phy_ops = 
-						mii_chip_table[i].phy_ops;
-					aup->mii = mii_phy;
-					aup->phy_ops->phy_init(dev,phy_addr);
-				} else {
-					printk(KERN_ERR "%s: out of memory\n", 
-							dev->name);
-					return -1;
-				}
-				mii_phy->chip_info = mii_chip_table+i;
-				aup->phy_addr = phy_addr;
-				aup->phy_ops = mii_chip_table[i].phy_ops;
-				aup->phy_ops->phy_init(dev,phy_addr);
-				break;
-			}
+# if defined(AU1XXX_PHY1_SEARCH_ON_MAC0)
+	/* try harder to find a PHY */
+	if (!phydev && (aup->mac_id == 1)) {
+		/* no PHY found, maybe we have a dual PHY? */
+		printk (KERN_INFO DRV_NAME ": no PHY found on MAC1, "
+			"let's see if it's attached to MAC0...\n");
+
+		BUG_ON(!au_macs[0]);
+
+		/* find the first (lowest address) non-attached PHY on
+		 * the MAC0 MII bus */
+		for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
+			struct phy_device *const tmp_phydev =
+				au_macs[0]->mii_bus.phy_map[phy_addr];
+
+			if (!tmp_phydev)
+				continue; /* no PHY here... */
+
+			if (tmp_phydev->attached_dev)
+				continue; /* already claimed by MAC0 */
+
+			phydev = tmp_phydev;
+			break; /* found it */
 		}
 	}
-	if (aup->mac_id == 0) {
-		/* the Bosporus phy responds to addresses 0-5 but 
-		 * 5 is the correct one.
-		 */
-		aup->phy_addr = 5;
-	}
-#endif
+# endif /* defined(AU1XXX_PHY1_SEARCH_OTHER_BUS) */
 
-	if (aup->mii->chip_info == NULL) {
-		printk(KERN_ERR "%s: Au1x No known MII transceivers found!\n",
-				dev->name);
+#endif /* defined(AU1XXX_PHY_STATIC_CONFIG) */
+	if (!phydev) {
+		printk (KERN_ERR DRV_NAME ":%s: no PHY found\n", dev->name);
 		return -1;
 	}
 
-	printk(KERN_INFO "%s: Using %s as default\n", 
-			dev->name, aup->mii->chip_info->name);
+	/* now we are supposed to have a proper phydev, to attach to... */
+	BUG_ON(!phydev);
+	BUG_ON(phydev->attached_dev);
+
+	phydev = phy_connect(dev, phydev->dev.bus_id, &au1000_adjust_link, 0);
+
+	if (IS_ERR(phydev)) {
+		printk(KERN_ERR "%s: Could not attach to PHY\n", dev->name);
+		return PTR_ERR(phydev);
+	}
+
+	/* mask with MAC supported features */
+	phydev->supported &= (SUPPORTED_10baseT_Half
+			      | SUPPORTED_10baseT_Full
+			      | SUPPORTED_100baseT_Half
+			      | SUPPORTED_100baseT_Full
+			      | SUPPORTED_Autoneg
+			      /* | SUPPORTED_Pause | SUPPORTED_Asym_Pause */
+			      | SUPPORTED_MII
+			      | SUPPORTED_TP);
+
+	phydev->advertising = phydev->supported;
+
+	aup->old_link = 0;
+	aup->old_speed = 0;
+	aup->old_duplex = -1;
+	aup->phy_dev = phydev;
+
+	printk(KERN_INFO "%s: attached PHY driver [%s] "
+	       "(mii_bus:phy_addr=%s, irq=%d)\n",
+	       dev->name, phydev->drv->name, phydev->dev.bus_id, phydev->irq);
 
 	return 0;
 }
@@ -1097,35 +439,38 @@ static void hard_stop(struct net_device 
 	au_sync_delay(10);
 }
 
-
-static void reset_mac(struct net_device *dev)
+static void enable_mac(struct net_device *dev, int force_reset)
 {
-	int i;
-	u32 flags;
+	unsigned long flags;
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
 
-	if (au1000_debug > 4) 
-		printk(KERN_INFO "%s: reset mac, aup %x\n", 
-				dev->name, (unsigned)aup);
-
 	spin_lock_irqsave(&aup->lock, flags);
-	if (aup->timer.function == &au1000_timer) {/* check if timer initted */
-		del_timer(&aup->timer);
-	}
 
-	hard_stop(dev);
-	#ifdef CONFIG_BCM5222_DUAL_PHY
-	if (aup->mac_id != 0) {
-	#endif
-		/* If BCM5222, we can't leave MAC0 in reset because then 
-		 * we can't access the dual phy for ETH1 */
+	if(force_reset || (!aup->mac_enabled)) {
 		*aup->enable = MAC_EN_CLOCK_ENABLE;
 		au_sync_delay(2);
-		*aup->enable = 0;
+		*aup->enable = (MAC_EN_RESET0 | MAC_EN_RESET1 | MAC_EN_RESET2
+				| MAC_EN_CLOCK_ENABLE);
 		au_sync_delay(2);
-	#ifdef CONFIG_BCM5222_DUAL_PHY
+
+		aup->mac_enabled = 1;
 	}
-	#endif
+
+	spin_unlock_irqrestore(&aup->lock, flags);
+}
+
+static void reset_mac_unlocked(struct net_device *dev)
+{
+	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	int i;
+
+	hard_stop(dev);
+
+	*aup->enable = MAC_EN_CLOCK_ENABLE;
+	au_sync_delay(2);
+	*aup->enable = 0;
+	au_sync_delay(2);
+
 	aup->tx_full = 0;
 	for (i = 0; i < NUM_RX_DMA; i++) {
 		/* reset control bits */
@@ -1135,9 +480,26 @@ static void reset_mac(struct net_device 
 		/* reset control bits */
 		aup->tx_dma_ring[i]->buff_stat &= ~0xf;
 	}
-	spin_unlock_irqrestore(&aup->lock, flags);
+
+	aup->mac_enabled = 0;
+
 }
 
+static void reset_mac(struct net_device *dev)
+{
+	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	unsigned long flags;
+
+	if (au1000_debug > 4)
+		printk(KERN_INFO "%s: reset mac, aup %x\n",
+		       dev->name, (unsigned)aup);
+
+	spin_lock_irqsave(&aup->lock, flags);
+
+	reset_mac_unlocked (dev);
+
+	spin_unlock_irqrestore(&aup->lock, flags);
+}
 
 /* 
  * Setup the receive and transmit "rings".  These pointers are the addresses
@@ -1208,178 +570,31 @@ static int __init au1000_init_module(voi
 	return 0;
 }
 
-static int au1000_setup_aneg(struct net_device *dev, u32 advertise)
-{
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
-	u16 ctl, adv;
-
-	/* Setup standard advertise */
-	adv = mdio_read(dev, aup->phy_addr, MII_ADVERTISE);
-	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
-	if (advertise & ADVERTISED_10baseT_Half)
-		adv |= ADVERTISE_10HALF;
-	if (advertise & ADVERTISED_10baseT_Full)
-		adv |= ADVERTISE_10FULL;
-	if (advertise & ADVERTISED_100baseT_Half)
-		adv |= ADVERTISE_100HALF;
-	if (advertise & ADVERTISED_100baseT_Full)
-		adv |= ADVERTISE_100FULL;
-	mdio_write(dev, aup->phy_addr, MII_ADVERTISE, adv);
-
-	/* Start/Restart aneg */
-	ctl = mdio_read(dev, aup->phy_addr, MII_BMCR);
-	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
-	mdio_write(dev, aup->phy_addr, MII_BMCR, ctl);
-
-	return 0;
-}
+/*
+ * ethtool operations
+ */
 
-static int au1000_setup_forced(struct net_device *dev, int speed, int fd)
+static int au1000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct au1000_private *aup = (struct au1000_private *)dev->priv;
-	u16 ctl;
-
-	ctl = mdio_read(dev, aup->phy_addr, MII_BMCR);
-	ctl &= ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_ANENABLE);
-
-	/* First reset the PHY */
-	mdio_write(dev, aup->phy_addr, MII_BMCR, ctl | BMCR_RESET);
-
-	/* Select speed & duplex */
-	switch (speed) {
-		case SPEED_10:
-			break;
-		case SPEED_100:
-			ctl |= BMCR_SPEED100;
-			break;
-		case SPEED_1000:
-		default:
-			return -EINVAL;
-	}
-	if (fd == DUPLEX_FULL)
-		ctl |= BMCR_FULLDPLX;
-	mdio_write(dev, aup->phy_addr, MII_BMCR, ctl);
-
-	return 0;
-}
-
 
-static void
-au1000_start_link(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
-	u32 advertise;
-	int autoneg;
-	int forced_speed;
-	int forced_duplex;
-
-	/* Default advertise */
-	advertise = GENMII_DEFAULT_ADVERTISE;
-	autoneg = aup->want_autoneg;
-	forced_speed = SPEED_100;
-	forced_duplex = DUPLEX_FULL;
-
-	/* Setup link parameters */
-	if (cmd) {
-		if (cmd->autoneg == AUTONEG_ENABLE) {
-			advertise = cmd->advertising;
-			autoneg = 1;
-		} else {
-			autoneg = 0;
-
-			forced_speed = cmd->speed;
-			forced_duplex = cmd->duplex;
-		}
-	}
+	if (aup->phy_dev)
+		return phy_ethtool_gset(aup->phy_dev, cmd);
 
-	/* Configure PHY & start aneg */
-	aup->want_autoneg = autoneg;
-	if (autoneg)
-		au1000_setup_aneg(dev, advertise);
-	else
-		au1000_setup_forced(dev, forced_speed, forced_duplex);
-	mod_timer(&aup->timer, jiffies + HZ);
+	return -EINVAL;
 }
 
-static int au1000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int au1000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct au1000_private *aup = (struct au1000_private *)dev->priv;
-	u16 link, speed;
-
-	cmd->supported = GENMII_DEFAULT_FEATURES;
-	cmd->advertising = GENMII_DEFAULT_ADVERTISE;
-	cmd->port = PORT_MII;
-	cmd->transceiver = XCVR_EXTERNAL;
-	cmd->phy_address = aup->phy_addr;
-	spin_lock_irq(&aup->lock);
-	cmd->autoneg = aup->want_autoneg;
-	aup->phy_ops->phy_status(dev, aup->phy_addr, &link, &speed);
-	if ((speed == IF_PORT_100BASETX) || (speed == IF_PORT_100BASEFX))
-		cmd->speed = SPEED_100;
-	else if (speed == IF_PORT_10BASET)
-		cmd->speed = SPEED_10;
-	if (link && (dev->if_port == IF_PORT_100BASEFX))
-		cmd->duplex = DUPLEX_FULL;
-	else
-		cmd->duplex = DUPLEX_HALF;
-	spin_unlock_irq(&aup->lock);
-	return 0;
-}
 
-static int au1000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
-{
-	 struct au1000_private *aup = (struct au1000_private *)dev->priv;
-	  unsigned long features = GENMII_DEFAULT_FEATURES;
-
-	 if (!capable(CAP_NET_ADMIN))
-		 return -EPERM;
-
-	 if (cmd->autoneg != AUTONEG_ENABLE && cmd->autoneg != AUTONEG_DISABLE)
-		 return -EINVAL;
-	 if (cmd->autoneg == AUTONEG_ENABLE && cmd->advertising == 0)
-		 return -EINVAL;
-	 if (cmd->duplex != DUPLEX_HALF && cmd->duplex != DUPLEX_FULL)
-		 return -EINVAL;
-	 if (cmd->autoneg == AUTONEG_DISABLE)
-		 switch (cmd->speed) {
-		 case SPEED_10:
-			 if (cmd->duplex == DUPLEX_HALF &&
-				 (features & SUPPORTED_10baseT_Half) == 0)
-				 return -EINVAL;
-			 if (cmd->duplex == DUPLEX_FULL &&
-				 (features & SUPPORTED_10baseT_Full) == 0)
-				 return -EINVAL;
-			 break;
-		 case SPEED_100:
-			 if (cmd->duplex == DUPLEX_HALF &&
-				 (features & SUPPORTED_100baseT_Half) == 0)
-				 return -EINVAL;
-			 if (cmd->duplex == DUPLEX_FULL &&
-				 (features & SUPPORTED_100baseT_Full) == 0)
-				 return -EINVAL;
-			 break;
-		 default:
-			 return -EINVAL;
-		 }
-	 else if ((features & SUPPORTED_Autoneg) == 0)
-		 return -EINVAL;
-
-	 spin_lock_irq(&aup->lock);
-	 au1000_start_link(dev, cmd);
-	 spin_unlock_irq(&aup->lock);
-	 return 0;
-}
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
 
-static int au1000_nway_reset(struct net_device *dev)
-{
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	if (aup->phy_dev)
+		return phy_ethtool_sset(aup->phy_dev, cmd);
 
-	if (!aup->want_autoneg)
-		return -EINVAL;
-	spin_lock_irq(&aup->lock);
-	au1000_start_link(dev, NULL);
-	spin_unlock_irq(&aup->lock);
-	return 0;
+	return -EINVAL;
 }
 
 static void
@@ -1394,17 +609,11 @@ au1000_get_drvinfo(struct net_device *de
 	info->regdump_len = 0;
 }
 
-static u32 au1000_get_link(struct net_device *dev)
-{
-	return netif_carrier_ok(dev);
-}
-
 static struct ethtool_ops au1000_ethtool_ops = {
 	.get_settings = au1000_get_settings,
 	.set_settings = au1000_set_settings,
 	.get_drvinfo = au1000_get_drvinfo,
-	.nway_reset = au1000_nway_reset,
-	.get_link = au1000_get_link
+	.get_link = ethtool_op_get_link,
 };
 
 static struct net_device * au1000_probe(int port_num)
@@ -1499,23 +708,31 @@ static struct net_device * au1000_probe(
 	memcpy(dev->dev_addr, au1000_mac_addr, sizeof(au1000_mac_addr));
 	dev->dev_addr[5] += port_num;
 
-	/* Bring the device out of reset, otherwise probing the MII will hang */
-	*aup->enable = MAC_EN_CLOCK_ENABLE;
-	au_sync_delay(2);
-	*aup->enable = MAC_EN_RESET0 | MAC_EN_RESET1 | MAC_EN_RESET2 |
-		       MAC_EN_CLOCK_ENABLE;
-	au_sync_delay(2);
-
-	aup->mii = kmalloc(sizeof(struct mii_phy), GFP_KERNEL);
-	if (!aup->mii) {
-		printk(KERN_ERR "%s: out of memory\n", dev->name);
-		goto err_out;
-	}
-	aup->mii->next = NULL;
-	aup->mii->chip_info = NULL;
-	aup->mii->status = 0;
-	aup->mii->mii_control_reg = 0;
-	aup->mii->mii_data_reg = 0;
+	*aup->enable = 0;
+	aup->mac_enabled = 0;
+
+	aup->mii_bus.priv = dev;
+	aup->mii_bus.read = mdiobus_read;
+	aup->mii_bus.write = mdiobus_write;
+	aup->mii_bus.reset = mdiobus_reset;
+	aup->mii_bus.name = "au1000_eth_mii";
+	aup->mii_bus.id = aup->mac_id;
+	aup->mii_bus.irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	for(i = 0; i < PHY_MAX_ADDR; ++i)
+		aup->mii_bus.irq[i] = PHY_POLL;
+
+	/* if known, set corresponding PHY IRQs */
+#if defined(AU1XXX_PHY_STATIC_CONFIG)
+# if defined(AU1XXX_PHY0_IRQ)
+	if (AU1XXX_PHY0_BUSID == aup->mii_bus.id)
+		aup->mii_bus.irq[AU1XXX_PHY0_ADDR] = AU1XXX_PHY0_IRQ;
+# endif
+# if defined(AU1XXX_PHY1_IRQ)
+	if (AU1XXX_PHY1_BUSID == aup->mii_bus.id)
+		aup->mii_bus.irq[AU1XXX_PHY1_ADDR] = AU1XXX_PHY1_IRQ;
+# endif
+#endif
+	mdiobus_register(&aup->mii_bus);
 
 	if (mii_probe(dev) != 0) {
 		goto err_out;
@@ -1561,7 +778,6 @@ static struct net_device * au1000_probe(
 	dev->set_multicast_list = &set_rx_mode;
 	dev->do_ioctl = &au1000_ioctl;
 	SET_ETHTOOL_OPS(dev, &au1000_ethtool_ops);
-	dev->set_config = &au1000_set_config;
 	dev->tx_timeout = au1000_tx_timeout;
 	dev->watchdog_timeo = ETH_TX_TIMEOUT;
 
@@ -1577,7 +793,7 @@ err_out:
 	/* here we should have a valid dev plus aup-> register addresses
 	 * so we can reset the mac properly.*/
 	reset_mac(dev);
-	kfree(aup->mii);
+
 	for (i = 0; i < NUM_RX_DMA; i++) {
 		if (aup->rx_db_inuse[i])
 			ReleaseDB(aup, aup->rx_db_inuse[i]);
@@ -1610,19 +826,14 @@ static int au1000_init(struct net_device
 	u32 flags;
 	int i;
 	u32 control;
-	u16 link, speed;
 
 	if (au1000_debug > 4) 
 		printk("%s: au1000_init\n", dev->name);
 
-	spin_lock_irqsave(&aup->lock, flags);
-
 	/* bring the device out of reset */
-	*aup->enable = MAC_EN_CLOCK_ENABLE;
-        au_sync_delay(2);
-	*aup->enable = MAC_EN_RESET0 | MAC_EN_RESET1 | 
-		MAC_EN_RESET2 | MAC_EN_CLOCK_ENABLE;
-	au_sync_delay(20);
+	enable_mac(dev, 1);
+
+	spin_lock_irqsave(&aup->lock, flags);
 
 	aup->mac->control = 0;
 	aup->tx_head = (aup->tx_dma_ring[0]->buff_stat & 0xC) >> 2;
@@ -1638,12 +849,16 @@ static int au1000_init(struct net_device
 	}
 	au_sync();
 
-	aup->phy_ops->phy_status(dev, aup->phy_addr, &link, &speed);
-	control = MAC_DISABLE_RX_OWN | MAC_RX_ENABLE | MAC_TX_ENABLE;
+	control = MAC_RX_ENABLE | MAC_TX_ENABLE;
 #ifndef CONFIG_CPU_LITTLE_ENDIAN
 	control |= MAC_BIG_ENDIAN;
 #endif
-	if (link && (dev->if_port == IF_PORT_100BASEFX)) {
+	if (aup->phy_dev) {
+		if (aup->phy_dev->link && (DUPLEX_FULL == aup->phy_dev->duplex))
+			control |= MAC_FULL_DUPLEX;
+		else
+			control |= MAC_DISABLE_RX_OWN;
+	} else { /* PHY-less op, assume full-duplex */
 		control |= MAC_FULL_DUPLEX;
 	}
 
@@ -1655,57 +870,84 @@ #endif
 	return 0;
 }
 
-static void au1000_timer(unsigned long data)
+static void
+au1000_adjust_link(struct net_device *dev)
 {
-	struct net_device *dev = (struct net_device *)data;
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
-	unsigned char if_port;
-	u16 link, speed;
+	struct phy_device *phydev = aup->phy_dev;
+	unsigned long flags;
 
-	if (!dev) {
-		/* fatal error, don't restart the timer */
-		printk(KERN_ERR "au1000_timer error: NULL dev\n");
-		return;
-	}
+	int status_change = 0;
 
-	if_port = dev->if_port;
-	if (aup->phy_ops->phy_status(dev, aup->phy_addr, &link, &speed) == 0) {
-		if (link) {
-			if (!netif_carrier_ok(dev)) {
-				netif_carrier_on(dev);
-				printk(KERN_INFO "%s: link up\n", dev->name);
-			}
-		}
-		else {
-			if (netif_carrier_ok(dev)) {
-				netif_carrier_off(dev);
-				dev->if_port = 0;
-				printk(KERN_INFO "%s: link down\n", dev->name);
-			}
+	BUG_ON(!aup->phy_dev);
+
+	spin_lock_irqsave(&aup->lock, flags);
+
+	if (phydev->link && (aup->old_speed != phydev->speed)) {
+		// speed changed
+
+		switch(phydev->speed) {
+		case SPEED_10:
+		case SPEED_100:
+			break;
+		default:
+			printk(KERN_WARNING
+			       "%s: Speed (%d) is not 10/100 ???\n",
+			       dev->name, phydev->speed);
+			break;
 		}
+
+		aup->old_speed = phydev->speed;
+
+		status_change = 1;
 	}
 
-	if (link && (dev->if_port != if_port) && 
-			(dev->if_port != IF_PORT_UNKNOWN)) {
+	if (phydev->link && (aup->old_duplex != phydev->duplex)) {
+		// duplex mode changed
+
+		/* switching duplex mode requires to disable rx and tx! */
 		hard_stop(dev);
-		if (dev->if_port == IF_PORT_100BASEFX) {
-			printk(KERN_INFO "%s: going to full duplex\n", 
-					dev->name);
-			aup->mac->control |= MAC_FULL_DUPLEX;
-			au_sync_delay(1);
-		}
-		else {
-			aup->mac->control &= ~MAC_FULL_DUPLEX;
-			au_sync_delay(1);
-		}
+
+		if (DUPLEX_FULL == phydev->duplex)
+			aup->mac->control = ((aup->mac->control
+					     | MAC_FULL_DUPLEX)
+					     & ~MAC_DISABLE_RX_OWN);
+		else
+			aup->mac->control = ((aup->mac->control
+					      & ~MAC_FULL_DUPLEX)
+					     | MAC_DISABLE_RX_OWN);
+		au_sync_delay(1);
+
 		enable_rx_tx(dev);
+		aup->old_duplex = phydev->duplex;
+
+		status_change = 1;
+	}
+
+	if(phydev->link != aup->old_link) {
+		// link state changed
+
+		if (phydev->link) // link went up
+			netif_schedule(dev);
+		else { // link went down
+			aup->old_speed = 0;
+			aup->old_duplex = -1;
+		}
+
+		aup->old_link = phydev->link;
+		status_change = 1;
 	}
 
-	aup->timer.expires = RUN_AT((1*HZ)); 
-	aup->timer.data = (unsigned long)dev;
-	aup->timer.function = &au1000_timer; /* timer handler */
-	add_timer(&aup->timer);
+	spin_unlock_irqrestore(&aup->lock, flags);
 
+	if (status_change) {
+		if (phydev->link)
+			printk(KERN_INFO "%s: link up (%d/%s)\n",
+			       dev->name, phydev->speed,
+			       DUPLEX_FULL == phydev->duplex ? "Full" : "Half");
+		else
+			printk(KERN_INFO "%s: link down\n", dev->name);
+	}
 }
 
 static int au1000_open(struct net_device *dev)
@@ -1716,25 +958,26 @@ static int au1000_open(struct net_device
 	if (au1000_debug > 4)
 		printk("%s: open: dev=%p\n", dev->name, dev);
 
+	if ((retval = request_irq(dev->irq, &au1000_interrupt, 0,
+					dev->name, dev))) {
+		printk(KERN_ERR "%s: unable to get IRQ %d\n",
+				dev->name, dev->irq);
+		return retval;
+	}
+
 	if ((retval = au1000_init(dev))) {
 		printk(KERN_ERR "%s: error in au1000_init\n", dev->name);
 		free_irq(dev->irq, dev);
 		return retval;
 	}
-	netif_start_queue(dev);
 
-	if ((retval = request_irq(dev->irq, &au1000_interrupt, 0, 
-					dev->name, dev))) {
-		printk(KERN_ERR "%s: unable to get IRQ %d\n", 
-				dev->name, dev->irq);
-		return retval;
+	if (aup->phy_dev) {
+		/* cause the PHY state machine to schedule a link state check */
+		aup->phy_dev->state = PHY_CHANGELINK;
+		phy_start(aup->phy_dev);
 	}
 
-	init_timer(&aup->timer); /* used in ioctl() */
-	aup->timer.expires = RUN_AT((3*HZ)); 
-	aup->timer.data = (unsigned long)dev;
-	aup->timer.function = &au1000_timer; /* timer handler */
-	add_timer(&aup->timer);
+	netif_start_queue(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: open: Initialization done.\n", dev->name);
@@ -1744,16 +987,19 @@ static int au1000_open(struct net_device
 
 static int au1000_close(struct net_device *dev)
 {
-	u32 flags;
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	unsigned long flags;
+	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
 
 	if (au1000_debug > 4)
 		printk("%s: close: dev=%p\n", dev->name, dev);
 
-	reset_mac(dev);
+	if (aup->phy_dev)
+		phy_stop(aup->phy_dev);
 
 	spin_lock_irqsave(&aup->lock, flags);
-	
+
+	reset_mac_unlocked (dev);
+
 	/* stop the device */
 	netif_stop_queue(dev);
 
@@ -1775,7 +1021,6 @@ static void __exit au1000_cleanup_module
 		if (dev) {
 			aup = (struct au1000_private *) dev->priv;
 			unregister_netdev(dev);
-			kfree(aup->mii);
 			for (j = 0; j < NUM_RX_DMA; j++)
 				if (aup->rx_db_inuse[j])
 					ReleaseDB(aup, aup->rx_db_inuse[j]);
@@ -1798,7 +1043,7 @@ static void update_tx_stats(struct net_d
 	struct net_device_stats *ps = &aup->stats;
 
 	if (status & TX_FRAME_ABORTED) {
-		if (dev->if_port == IF_PORT_100BASEFX) {
+		if (!aup->phy_dev || (DUPLEX_FULL == aup->phy_dev->duplex)) {
 			if (status & (TX_JAB_TIMEOUT | TX_UNDERRUN)) {
 				/* any other tx errors are only valid
 				 * in half duplex mode */
@@ -2072,126 +1317,15 @@ static void set_rx_mode(struct net_devic
 	}
 }
 
-
 static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct au1000_private *aup = (struct au1000_private *)dev->priv;
-	u16 *data = (u16 *)&rq->ifr_ifru;
-
-	switch(cmd) { 
-		case SIOCDEVPRIVATE:	/* Get the address of the PHY in use. */
-		case SIOCGMIIPHY:
-		        if (!netif_running(dev)) return -EINVAL;
-			data[0] = aup->phy_addr;
-		case SIOCDEVPRIVATE+1:	/* Read the specified MII register. */
-		case SIOCGMIIREG:
-			data[3] =  mdio_read(dev, data[0], data[1]); 
-			return 0;
-		case SIOCDEVPRIVATE+2:	/* Write the specified MII register */
-		case SIOCSMIIREG: 
-			if (!capable(CAP_NET_ADMIN))
-				return -EPERM;
-			mdio_write(dev, data[0], data[1],data[2]);
-			return 0;
-		default:
-			return -EOPNOTSUPP;
-	}
-
-}
-
-
-static int au1000_set_config(struct net_device *dev, struct ifmap *map)
-{
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
-	u16 control;
 
-	if (au1000_debug > 4)  {
-		printk("%s: set_config called: dev->if_port %d map->port %x\n", 
-				dev->name, dev->if_port, map->port);
-	}
+	if (!netif_running(dev)) return -EINVAL;
 
-	switch(map->port){
-		case IF_PORT_UNKNOWN: /* use auto here */   
-			printk(KERN_INFO "%s: config phy for aneg\n", 
-					dev->name);
-			dev->if_port = map->port;
-			/* Link Down: the timer will bring it up */
-			netif_carrier_off(dev);
-	
-			/* read current control */
-			control = mdio_read(dev, aup->phy_addr, MII_CONTROL);
-			control &= ~(MII_CNTL_FDX | MII_CNTL_F100);
-
-			/* enable auto negotiation and reset the negotiation */
-			mdio_write(dev, aup->phy_addr, MII_CONTROL, 
-					control | MII_CNTL_AUTO | 
-					MII_CNTL_RST_AUTO);
+	if (!aup->phy_dev) return -EINVAL; // PHY not controllable
 
-			break;
-    
-		case IF_PORT_10BASET: /* 10BaseT */         
-			printk(KERN_INFO "%s: config phy for 10BaseT\n", 
-					dev->name);
-			dev->if_port = map->port;
-	
-			/* Link Down: the timer will bring it up */
-			netif_carrier_off(dev);
-
-			/* set Speed to 10Mbps, Half Duplex */
-			control = mdio_read(dev, aup->phy_addr, MII_CONTROL);
-			control &= ~(MII_CNTL_F100 | MII_CNTL_AUTO | 
-					MII_CNTL_FDX);
-	
-			/* disable auto negotiation and force 10M/HD mode*/
-			mdio_write(dev, aup->phy_addr, MII_CONTROL, control);
-			break;
-    
-		case IF_PORT_100BASET: /* 100BaseT */
-		case IF_PORT_100BASETX: /* 100BaseTx */ 
-			printk(KERN_INFO "%s: config phy for 100BaseTX\n", 
-					dev->name);
-			dev->if_port = map->port;
-	
-			/* Link Down: the timer will bring it up */
-			netif_carrier_off(dev);
-	
-			/* set Speed to 100Mbps, Half Duplex */
-			/* disable auto negotiation and enable 100MBit Mode */
-			control = mdio_read(dev, aup->phy_addr, MII_CONTROL);
-			control &= ~(MII_CNTL_AUTO | MII_CNTL_FDX);
-			control |= MII_CNTL_F100;
-			mdio_write(dev, aup->phy_addr, MII_CONTROL, control);
-			break;
-    
-		case IF_PORT_100BASEFX: /* 100BaseFx */
-			printk(KERN_INFO "%s: config phy for 100BaseFX\n", 
-					dev->name);
-			dev->if_port = map->port;
-	
-			/* Link Down: the timer will bring it up */
-			netif_carrier_off(dev);
-	
-			/* set Speed to 100Mbps, Full Duplex */
-			/* disable auto negotiation and enable 100MBit Mode */
-			control = mdio_read(dev, aup->phy_addr, MII_CONTROL);
-			control &= ~MII_CNTL_AUTO;
-			control |=  MII_CNTL_F100 | MII_CNTL_FDX;
-			mdio_write(dev, aup->phy_addr, MII_CONTROL, control);
-			break;
-		case IF_PORT_10BASE2: /* 10Base2 */
-		case IF_PORT_AUI: /* AUI */
-		/* These Modes are not supported (are they?)*/
-			printk(KERN_ERR "%s: 10Base2/AUI not supported", 
-					dev->name);
-			return -EOPNOTSUPP;
-			break;
-    
-		default:
-			printk(KERN_ERR "%s: Invalid media selected", 
-					dev->name);
-			return -EINVAL;
-	}
-	return 0;
+	return phy_mii_ioctl(aup->phy_dev, if_mii(rq), cmd);
 }
 
 static struct net_device_stats *au1000_get_stats(struct net_device *dev)
diff --git a/drivers/net/au1000_eth.h b/drivers/net/au1000_eth.h
index 7f9326e..41c2f84 100644
--- a/drivers/net/au1000_eth.h
+++ b/drivers/net/au1000_eth.h
@@ -40,120 +40,6 @@ #define MAC_MIN_PKT_SIZE 64
 
 #define MULTICAST_FILTER_LIMIT 64
 
-/* FIXME 
- * The PHY defines should be in a separate file.
- */
-
-/* MII register offsets */
-#define	MII_CONTROL 0x0000
-#define MII_STATUS  0x0001
-#define MII_PHY_ID0 0x0002
-#define	MII_PHY_ID1 0x0003
-#define MII_ANADV   0x0004
-#define MII_ANLPAR  0x0005
-#define MII_AEXP    0x0006
-#define MII_ANEXT   0x0007
-#define MII_LSI_PHY_CONFIG 0x0011
-/* Status register */
-#define MII_LSI_PHY_STAT   0x0012
-#define MII_AMD_PHY_STAT   MII_LSI_PHY_STAT
-#define MII_INTEL_PHY_STAT 0x0011
-
-#define MII_AUX_CNTRL  0x0018
-/* mii registers specific to AMD 79C901 */
-#define	MII_STATUS_SUMMARY = 0x0018
-
-/* MII Control register bit definitions. */
-#define	MII_CNTL_FDX      0x0100
-#define MII_CNTL_RST_AUTO 0x0200
-#define	MII_CNTL_ISOLATE  0x0400
-#define MII_CNTL_PWRDWN   0x0800
-#define	MII_CNTL_AUTO     0x1000
-#define MII_CNTL_F100     0x2000
-#define	MII_CNTL_LPBK     0x4000
-#define MII_CNTL_RESET    0x8000
-
-/* MII Status register bit  */
-#define	MII_STAT_EXT        0x0001 
-#define MII_STAT_JAB        0x0002
-#define	MII_STAT_LINK       0x0004
-#define MII_STAT_CAN_AUTO   0x0008
-#define	MII_STAT_FAULT      0x0010 
-#define MII_STAT_AUTO_DONE  0x0020
-#define	MII_STAT_CAN_T      0x0800
-#define MII_STAT_CAN_T_FDX  0x1000
-#define	MII_STAT_CAN_TX     0x2000 
-#define MII_STAT_CAN_TX_FDX 0x4000
-#define	MII_STAT_CAN_T4     0x8000
-
-
-#define		MII_ID1_OUI_LO		0xFC00	/* low bits of OUI mask */
-#define		MII_ID1_MODEL		0x03F0	/* model number */
-#define		MII_ID1_REV		0x000F	/* model number */
-
-/* MII NWAY Register Bits ...
-   valid for the ANAR (Auto-Negotiation Advertisement) and
-   ANLPAR (Auto-Negotiation Link Partner) registers */
-#define	MII_NWAY_NODE_SEL 0x001f
-#define MII_NWAY_CSMA_CD  0x0001
-#define	MII_NWAY_T	  0x0020
-#define MII_NWAY_T_FDX    0x0040
-#define	MII_NWAY_TX       0x0080
-#define MII_NWAY_TX_FDX   0x0100
-#define	MII_NWAY_T4       0x0200 
-#define MII_NWAY_PAUSE    0x0400 
-#define	MII_NWAY_RF       0x2000 /* Remote Fault */
-#define MII_NWAY_ACK      0x4000 /* Remote Acknowledge */
-#define	MII_NWAY_NP       0x8000 /* Next Page (Enable) */
-
-/* mii stsout register bits */
-#define	MII_STSOUT_LINK_FAIL 0x4000
-#define	MII_STSOUT_SPD       0x0080
-#define MII_STSOUT_DPLX      0x0040
-
-/* mii stsics register bits */
-#define	MII_STSICS_SPD       0x8000
-#define MII_STSICS_DPLX      0x4000
-#define	MII_STSICS_LINKSTS   0x0001
-
-/* mii stssum register bits */
-#define	MII_STSSUM_LINK  0x0008
-#define MII_STSSUM_DPLX  0x0004
-#define	MII_STSSUM_AUTO  0x0002
-#define MII_STSSUM_SPD   0x0001
-
-/* lsi phy status register */
-#define MII_LSI_PHY_STAT_FDX	0x0040
-#define MII_LSI_PHY_STAT_SPD	0x0080
-
-/* amd phy status register */
-#define MII_AMD_PHY_STAT_FDX	0x0800
-#define MII_AMD_PHY_STAT_SPD	0x0400
-
-/* intel phy status register */
-#define MII_INTEL_PHY_STAT_FDX	0x0200
-#define MII_INTEL_PHY_STAT_SPD	0x4000
-
-/* Auxilliary Control/Status Register */
-#define MII_AUX_FDX      0x0001
-#define MII_AUX_100      0x0002
-#define MII_AUX_F100     0x0004
-#define MII_AUX_ANEG     0x0008
-
-typedef struct mii_phy {
-	struct mii_phy * next;
-	struct mii_chip_info * chip_info;
-	u16 status;
-	u32 *mii_control_reg;
-	u32 *mii_data_reg;
-} mii_phy_t;
-
-struct phy_ops {
-	int (*phy_init) (struct net_device *, int);
-	int (*phy_reset) (struct net_device *, int);
-	int (*phy_status) (struct net_device *, int, u16 *, u16 *);
-};
-
 /* 
  * Data Buffer Descriptor. Data buffers must be aligned on 32 byte 
  * boundary for both, receive and transmit.
@@ -200,7 +86,6 @@ typedef struct mac_reg {
 
 
 struct au1000_private {
-	
 	db_dest_t *pDBfree;
 	db_dest_t db[NUM_RX_BUFFS+NUM_TX_BUFFS];
 	volatile rx_dma_t *rx_dma_ring[NUM_RX_DMA];
@@ -213,8 +98,15 @@ struct au1000_private {
 	u32 tx_full;
 
 	int mac_id;
-	mii_phy_t *mii;
-	struct phy_ops *phy_ops;
+
+	int mac_enabled;       /* whether MAC is currently enabled and running (req. for mdio) */
+
+	int old_link;          /* used by au1000_adjust_link */
+	int old_speed;
+	int old_duplex;
+
+	struct phy_device *phy_dev;
+	struct mii_bus mii_bus;
 	
 	/* These variables are just for quick access to certain regs addresses. */
 	volatile mac_reg_t *mac;  /* mac registers                      */   
@@ -223,14 +115,6 @@ struct au1000_private {
 	u32 vaddr;                /* virtual address of rx/tx buffers   */
 	dma_addr_t dma_addr;      /* dma address of rx/tx buffers       */
 
-	u8 *hash_table;
-	u32 hash_mode;
-	u32 intr_work_done; /* number of Rx and Tx pkts processed in the isr */
-	int phy_addr;          /* phy address */
-	u32 options;           /* User-settable misc. driver options. */
-	u32 drv_flags;
-	int want_autoneg;
 	struct net_device_stats stats;
-	struct timer_list timer;
 	spinlock_t lock;       /* Serialise access to device */
 };
-- 
1.3.2

