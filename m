From: Bryan Wu <bryan.wu-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] Blackfin EMAC driver: Add phy
	abstraction layer supporting in bfin_emac driver
Date: Sun, 16 Sep 2007 10:57:55 +0800
Message-ID: <1189911475.9901.8.camel@roc-laptop>
Reply-To: bryan.wu-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Return-path: <uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=unsubscribe>
List-Archive: <http://blackfin.uclinux.org/pipermail/uclinux-dist-devel>
List-Post: <mailto:uclinux-dist-devel-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org>
List-Help: <mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=help>
List-Subscribe: <http://blackfin.uclinux.org/mailman/listinfo/uclinux-dist-devel>,
	<mailto:uclinux-dist-devel-request-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org?subject=subscribe>
Sender: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
Errors-To: uclinux-dist-devel-bounces-ZG0+EudsQA8dtHy/vicBwGD2FQJk+8+b@public.gmane.org
List-Id: netdev.vger.kernel.org


 - add MDIO functions and register mdio bus
 - add phy abstraction layer (PAL) functions and use PAL API
 - test on STAMP537 board

Signed-off-by: Bryan Wu <bryan.wu-OyLXuOCK7orQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/bfin_mac.c |  311 +++++++++++++++++++++++++++++-------------------
 drivers/net/bfin_mac.h |   53 ++-------
 2 files changed, 195 insertions(+), 169 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 3015385..c9808a1 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -47,6 +47,7 @@
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
+#include <linux/phy.h>
 
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -99,6 +100,9 @@ static struct net_dma_desc_tx *current_tx_ptr;
 static struct net_dma_desc_tx *tx_desc;
 static struct net_dma_desc_rx *rx_desc;
 
+static void bf537mac_disable(void);
+static void bf537mac_enable(void);
+
 static void desc_list_free(void)
 {
 	struct net_dma_desc_rx *r;
@@ -287,8 +291,11 @@ static int setup_pin_mux(int action)
 	return 0;
 }
 
+/*
+ * MII operations
+ */
 /* Wait until the previous MDC/MDIO transaction has completed */
-static void poll_mdc_done(void)
+static void mdio_poll(void)
 {
 	int timeout_cnt = MAX_TIMEOUT_CNT;
 
@@ -304,154 +311,201 @@ static void poll_mdc_done(void)
 }
 
 /* Read an off-chip register in a PHY through the MDC/MDIO port */
-static u16 read_phy_reg(u16 PHYAddr, u16 RegAddr)
+static int mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 {
-	poll_mdc_done();
+	mdio_poll();
+
 	/* read mode */
-	bfin_write_EMAC_STAADD(SET_PHYAD(PHYAddr) |
-				SET_REGAD(RegAddr) |
+	bfin_write_EMAC_STAADD(SET_PHYAD((u16) phy_addr) |
+				SET_REGAD((u16) regnum) |
 				STABUSY);
-	poll_mdc_done();
 
-	return (u16) bfin_read_EMAC_STADAT();
+	mdio_poll();
+
+	return (int) bfin_read_EMAC_STADAT();
 }
 
 /* Write an off-chip register in a PHY through the MDC/MDIO port */
-static void raw_write_phy_reg(u16 PHYAddr, u16 RegAddr, u32 Data)
+static int mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
+			 u16 value)
 {
-	bfin_write_EMAC_STADAT(Data);
+	mdio_poll();
+
+	bfin_write_EMAC_STADAT((u32) value);
 
 	/* write mode */
-	bfin_write_EMAC_STAADD(SET_PHYAD(PHYAddr) |
-				SET_REGAD(RegAddr) |
+	bfin_write_EMAC_STAADD(SET_PHYAD((u16) phy_addr) |
+				SET_REGAD((u16) regnum) |
 				STAOP |
 				STABUSY);
 
-	poll_mdc_done();
+	mdio_poll();
+
+	return 0;
 }
 
-static void write_phy_reg(u16 PHYAddr, u16 RegAddr, u32 Data)
+static int mdiobus_reset(struct mii_bus *bus)
 {
-	poll_mdc_done();
-	raw_write_phy_reg(PHYAddr, RegAddr, Data);
+	return 0;
 }
 
-/* set up the phy */
-static void bf537mac_setphy(struct net_device *dev)
+static void bf537_adjust_link(struct net_device *dev)
 {
-	u16 phydat;
 	struct bf537mac_local *lp = netdev_priv(dev);
+	struct phy_device *phydev = lp->phydev;
+	unsigned long flags;
+	int new_state = 0;
+
+	spin_lock_irqsave(&lp->lock, flags);
+	if (phydev->link) {
+		/* Now we make sure that we can be in full duplex mode.
+		 * If not, we operate in half-duplex mode. */
+		if (phydev->duplex != lp->old_duplex) {
+			u32 opmode = bfin_read_EMAC_OPMODE();
+			new_state = 1;
+
+			if (phydev->duplex)
+				opmode |= FDMODE;
+			else
+				opmode &= ~(FDMODE);
+
+			bfin_write_EMAC_OPMODE(opmode);
+			lp->old_duplex = phydev->duplex;
+		}
 
-	/* Program PHY registers */
-	pr_debug("start setting up phy\n");
-
-	/* issue a reset */
-	raw_write_phy_reg(lp->PhyAddr, PHYREG_MODECTL, 0x8000);
-
-	/* wait half a second */
-	msleep(500);
-
-	phydat = read_phy_reg(lp->PhyAddr, PHYREG_MODECTL);
-
-	/* advertise flow control supported */
-	phydat = read_phy_reg(lp->PhyAddr, PHYREG_ANAR);
-	phydat |= (1 << 10);
-	write_phy_reg(lp->PhyAddr, PHYREG_ANAR, phydat);
+		if (phydev->speed != lp->old_speed) {
+#if defined(CONFIG_BFIN_MAC_RMII)
+			u32 opmode = bfin_read_EMAC_OPMODE();
+			bf537mac_disable();
+			switch (phydev->speed) {
+			case 10:
+				opmode |= RMII_10;
+				break;
+			case 100:
+				opmode &= ~(RMII_10);
+				break;
+			default:
+				printk(KERN_WARNING
+					"%s: Ack!  Speed (%d) is not 10/100!\n",
+					DRV_NAME, phydev->speed);
+				break;
+			}
+			bfin_write_EMAC_OPMODE(opmode);
+			bf537mac_enable();
+#endif
 
-	phydat = 0;
-	if (lp->Negotiate)
-		phydat |= 0x1000;	/* enable auto negotiation */
-	else {
-		if (lp->FullDuplex)
-			phydat |= (1 << 8);	/* full duplex */
-		else
-			phydat &= (~(1 << 8));	/* half duplex */
+			new_state = 1;
+			lp->old_speed = phydev->speed;
+		}
 
-		if (!lp->Port10)
-			phydat |= (1 << 13);	/* 100 Mbps */
-		else
-			phydat &= (~(1 << 13));	/* 10 Mbps */
+		if (!lp->old_link) {
+			new_state = 1;
+			lp->old_link = 1;
+			netif_schedule(dev);
+		}
+	} else if (lp->old_link) {
+		new_state = 1;
+		lp->old_link = 0;
+		lp->old_speed = 0;
+		lp->old_duplex = -1;
 	}
 
-	if (lp->Loopback)
-		phydat |= (1 << 14);	/* enable TX->RX loopback */
-
-	write_phy_reg(lp->PhyAddr, PHYREG_MODECTL, phydat);
-	msleep(500);
-
-	phydat = read_phy_reg(lp->PhyAddr, PHYREG_MODECTL);
-	/* check for SMSC PHY */
-	if ((read_phy_reg(lp->PhyAddr, PHYREG_PHYID1) == 0x7) &&
-	((read_phy_reg(lp->PhyAddr, PHYREG_PHYID2) & 0xfff0) == 0xC0A0)) {
-		/*
-		 * we have SMSC PHY so reqest interrupt
-		 * on link down condition
-		 */
-
-		/* enable interrupts */
-		write_phy_reg(lp->PhyAddr, 30, 0x0ff);
+	if (new_state) {
+		u32 opmode = bfin_read_EMAC_OPMODE();
+		phy_print_status(phydev);
+		pr_debug("EMAC_OPMODE = 0x%08x\n", opmode);
 	}
+
+	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
-/**************************************************************************/
-void setup_system_regs(struct net_device *dev)
+static int mii_probe(struct net_device *dev)
 {
-	int phyaddr;
-	unsigned short sysctl, phydat;
-	u32 opmode;
 	struct bf537mac_local *lp = netdev_priv(dev);
-	int count = 0;
-
-	phyaddr = lp->PhyAddr;
+	struct phy_device *phydev = NULL;
+	unsigned short sysctl;
+	int i;
 
-	/* Enable PHY output */
+	/* Enable PHY output early */
 	if (!(bfin_read_VR_CTL() & PHYCLKOE))
 		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
 
 	/* MDC  = 2.5 MHz */
-	sysctl = SET_MDCDIV(24);
-	/* Odd word alignment for Receive Frame DMA word */
-	/* Configure checksum support and rcve frame word alignment */
-#if defined(BFIN_MAC_CSUM_OFFLOAD)
-	sysctl |= RXDWA | RXCKS;
-#else
-	sysctl |= RXDWA;
-#endif
+	sysctl = bfin_read_EMAC_SYSCTL();
+	sysctl |= SET_MDCDIV(24);
 	bfin_write_EMAC_SYSCTL(sysctl);
-	/* auto negotiation on  */
-	/* full duplex          */
-	/* 100 Mbps             */
-	phydat = PHY_ANEG_EN | PHY_DUPLEX | PHY_SPD_SET;
-	write_phy_reg(phyaddr, PHYREG_MODECTL, phydat);
 
-	/* test if full duplex supported */
-	do {
-		msleep(100);
-		phydat = read_phy_reg(phyaddr, PHYREG_MODESTAT);
-		if (count > 30) {
-			printk(KERN_NOTICE DRV_NAME ": Link is down\n");
-			printk(KERN_NOTICE DRV_NAME
-				 "please check your network connection\n");
-			break;
-		}
-		count++;
-	} while (!(phydat & 0x0004));
+	/* search for connect PHY device */
+	for (i = 0; i < PHY_MAX_ADDR; i++) {
+		struct phy_device *const tmp_phydev = lp->mii_bus.phy_map[i];
 
-	phydat = read_phy_reg(phyaddr, PHYREG_ANLPAR);
+		if (!tmp_phydev)
+			continue; /* no PHY here... */
 
-	if ((phydat & 0x0100) || (phydat & 0x0040)) {
-		opmode = FDMODE;
-	} else {
-		opmode = 0;
-		printk(KERN_INFO DRV_NAME
-			": Network is set to half duplex\n");
+		phydev = tmp_phydev;
+		break; /* found it */
+	}
+
+	/* now we are supposed to have a proper phydev, to attach to... */
+	if (!phydev) {
+		printk(KERN_INFO "%s: Don't found any phy device at all\n",
+			dev->name);
+		return -ENODEV;
 	}
 
 #if defined(CONFIG_BFIN_MAC_RMII)
-	opmode |= RMII; /* For Now only 100MBit are supported */
+	phydev = phy_connect(dev, phydev->dev.bus_id, &bf537_adjust_link, 0,
+			PHY_INTERFACE_MODE_RMII);
+#else
+	phydev = phy_connect(dev, phydev->dev.bus_id, &bf537_adjust_link, 0,
+			PHY_INTERFACE_MODE_MII);
 #endif
 
-	bfin_write_EMAC_OPMODE(opmode);
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
+			      | SUPPORTED_Pause | SUPPORTED_Asym_Pause
+			      | SUPPORTED_MII
+			      | SUPPORTED_TP);
+
+	phydev->advertising = phydev->supported;
+
+	lp->old_link = 0;
+	lp->old_speed = 0;
+	lp->old_duplex = -1;
+	lp->phydev = phydev;
+
+	printk(KERN_INFO "%s: attached PHY driver [%s] "
+	       "(mii_bus:phy_addr=%s, irq=%d)\n",
+	       DRV_NAME, phydev->drv->name, phydev->dev.bus_id, phydev->irq);
+
+	return 0;
+}
+
+/**************************************************************************/
+void setup_system_regs(struct net_device *dev)
+{
+	unsigned short sysctl;
+
+	/*
+	 * Odd word alignment for Receive Frame DMA word
+	 * Configure checksum support and rcve frame word alignment
+	 */
+	sysctl = bfin_read_EMAC_SYSCTL();
+#if defined(BFIN_MAC_CSUM_OFFLOAD)
+	sysctl |= RXDWA | RXCKS;
+#else
+	sysctl |= RXDWA;
+#endif
+	bfin_write_EMAC_SYSCTL(sysctl);
 
 	bfin_write_EMAC_MMC_CTL(RSTC | CROLL);
 
@@ -691,18 +745,18 @@ static void bf537mac_disable(void)
 /*
  * Enable Interrupts, Receive, and Transmit
  */
-static int bf537mac_enable(struct net_device *dev)
+static void bf537mac_enable(void)
 {
 	u32 opmode;
 
-	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+	pr_debug("%s: %s\n", DRV_NAME, __FUNCTION__);
 
 	/* Set RX DMA */
 	bfin_write_DMA1_NEXT_DESC_PTR(&(rx_list_head->desc_a));
 	bfin_write_DMA1_CONFIG(rx_list_head->desc_a.config);
 
 	/* Wait MII done */
-	poll_mdc_done();
+	mdio_poll();
 
 	/* We enable only RX here */
 	/* ASTP   : Enable Automatic Pad Stripping
@@ -726,8 +780,6 @@ static int bf537mac_enable(struct net_device *dev)
 #endif
 	/* Turn on the EMAC rx */
 	bfin_write_EMAC_OPMODE(opmode);
-
-	return 0;
 }
 
 /* Our watchdog timed out. Called by the networking layer */
@@ -740,7 +792,7 @@ static void bf537mac_timeout(struct net_device *dev)
 	/* reset tx queue */
 	tx_list_tail = tx_list_head->next;
 
-	bf537mac_enable(dev);
+	bf537mac_enable();
 
 	/* We can accept TX packets again */
 	dev->trans_start = jiffies;
@@ -808,6 +860,7 @@ static void bf537mac_shutdown(struct net_device *dev)
  */
 static int bf537mac_open(struct net_device *dev)
 {
+	struct bf537mac_local *lp = netdev_priv(dev);
 	int retval;
 	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
 
@@ -827,10 +880,10 @@ static int bf537mac_open(struct net_device *dev)
 	if (retval)
 		return retval;
 
-	bf537mac_setphy(dev);
+	phy_start(lp->phydev);
 	setup_system_regs(dev);
 	bf537mac_disable();
-	bf537mac_enable(dev);
+	bf537mac_enable();
 
 	pr_debug("hardware init finished\n");
 	netif_start_queue(dev);
@@ -847,11 +900,14 @@ static int bf537mac_open(struct net_device *dev)
  */
 static int bf537mac_close(struct net_device *dev)
 {
+	struct bf537mac_local *lp = netdev_priv(dev);
 	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
 
+	phy_stop(lp->phydev);
+
 	/* clear everything */
 	bf537mac_shutdown(dev);
 
@@ -865,6 +921,7 @@ static int __init bf537mac_probe(struct net_device *dev)
 {
 	struct bf537mac_local *lp = netdev_priv(dev);
 	int retval;
+	int i;
 
 	/* Grab the MAC address in the MAC */
 	*(__le32 *) (&(dev->dev_addr[0])) = cpu_to_le32(bfin_read_EMAC_ADDRLO());
@@ -881,7 +938,6 @@ static int __init bf537mac_probe(struct net_device *dev)
 
 	/* set the GPIO pins to Ethernet mode */
 	retval = setup_pin_mux(1);
-
 	if (retval)
 		return retval;
 
@@ -899,6 +955,23 @@ static int __init bf537mac_probe(struct net_device *dev)
 
 	setup_mac_addr(dev->dev_addr);
 
+	/* MDIO bus initial */
+	lp->mii_bus.priv = dev;
+	lp->mii_bus.read = mdiobus_read;
+	lp->mii_bus.write = mdiobus_write;
+	lp->mii_bus.reset = mdiobus_reset;
+	lp->mii_bus.name = "bfin_mac_mdio";
+	lp->mii_bus.id = 0;
+	lp->mii_bus.irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
+	for (i = 0; i < PHY_MAX_ADDR; ++i)
+		lp->mii_bus.irq[i] = PHY_POLL;
+
+	mdiobus_register(&lp->mii_bus);
+
+	retval = mii_probe(dev);
+	if (retval)
+		return retval;
+
 	/* Fill in the fields of the device structure with ethernet values. */
 	ether_setup(dev);
 
@@ -913,13 +986,6 @@ static int __init bf537mac_probe(struct net_device *dev)
 	dev->poll_controller = bf537mac_poll;
 #endif
 
-	/* fill in some of the fields */
-	lp->version = 1;
-	lp->PhyAddr = 0x01;
-	lp->CLKIN = 25;
-	lp->FullDuplex = 0;
-	lp->Negotiate = 1;
-	lp->FlowControl = 0;
 	spin_lock_init(&lp->lock);
 
 	/* now, enable interrupts */
@@ -932,9 +998,6 @@ static int __init bf537mac_probe(struct net_device *dev)
 		return -EBUSY;
 	}
 
-	/* Enable PHY output early */
-	if (!(bfin_read_VR_CTL() & PHYCLKOE))
-		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
 
 	retval = register_netdev(dev);
 	if (retval == 0) {
diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index af87189..3a107ad 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -31,32 +31,6 @@
  * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
  */
 
-/*
- * PHY REGISTER NAMES
- */
-#define PHYREG_MODECTL		0x0000
-#define PHYREG_MODESTAT		0x0001
-#define PHYREG_PHYID1		0x0002
-#define PHYREG_PHYID2		0x0003
-#define PHYREG_ANAR		0x0004
-#define PHYREG_ANLPAR		0x0005
-#define PHYREG_ANER		0x0006
-#define PHYREG_NSR		0x0010
-#define PHYREG_LBREMR		0x0011
-#define PHYREG_REC		0x0012
-#define PHYREG_10CFG		0x0013
-#define PHYREG_PHY1_1		0x0014
-#define PHYREG_PHY1_2		0x0015
-#define PHYREG_PHY2		0x0016
-#define PHYREG_TW_1		0x0017
-#define PHYREG_TW_2		0x0018
-#define PHYREG_TEST		0x0019
-
-#define PHY_RESET		0x8000
-#define PHY_ANEG_EN		0x1000
-#define PHY_DUPLEX		0x0100
-#define PHY_SPD_SET		0x2000
-
 #define BFIN_MAC_CSUM_OFFLOAD
 
 struct dma_descriptor {
@@ -106,27 +80,16 @@ struct bf537mac_local {
 	 */
 	struct net_device_stats stats;
 
-	int version;
-
-	int FlowEnabled;	/* record if data flow is active */
-	int EtherIntIVG;	/* IVG for the ethernet interrupt */
-	int RXIVG;		/* IVG for the RX completion */
-	int TXIVG;		/* IVG for the TX completion */
-	int PhyAddr;		/* PHY address */
-	int OpMode;		/* set these bits n the OPMODE regs */
-	int Port10;		/* set port speed to 10 Mbit/s */
-	int GenChksums;		/* IP checksums to be calculated */
-	int NoRcveLnth;		/* dont insert recv length at start of buffer */
-	int StripPads;		/* remove trailing pad bytes */
-	int FullDuplex;		/* set full duplex mode */
-	int Negotiate;		/* enable auto negotiation */
-	int Loopback;		/* loopback at the PHY */
-	int Cache;		/* Buffers may be cached */
-	int FlowControl;	/* flow control active */
-	int CLKIN;		/* clock in value in MHZ */
-	unsigned short IntMask;	/* interrupt mask */
 	unsigned char Mac[6];	/* MAC address of the board */
 	spinlock_t lock;
+
+	/* MII and PHY stuffs */
+	int old_link;          /* used by bf537_adjust_link */
+	int old_speed;
+	int old_duplex;
+
+	struct phy_device *phydev;
+	struct mii_bus mii_bus;
 };
 
 extern void get_bf537_ether_addr(char *addr);
-- 
1.5.2
