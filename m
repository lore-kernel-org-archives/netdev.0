From: Kim Phillips <kim.phillips@freescale.com>
Subject: [PATCH 1/2] ucc_geth: migrate ucc_geth to phylib
Date: Tue, 10 Apr 2007 16:56:59 -0500
Message-ID: <20070410165659.6a892041.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Jeff Garzik <jgarzik@pobox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:57077 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913AbXDJV5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 17:57:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

migrate ucc_geth to use the common phylib code.

There are several side effects from doing this:

o deprecate 'interface' property specification present
  in some old device tree source files in
  favour of a split 'max-speed' and 'interface-type'
  description to appropriately match definitions
  in include/linux/phy.h.  Note that 'interface' property
  is still honoured if max-speed or interface-type
  are not present (backward compatible).
o compile-time CONFIG_UGETH_HAS_GIGA is eliminated
  in favour of using the max-speed property in the dt.
o adjust_link streamlined to only operate on maccfg2
  and upsmr.r10m, instead of reapplying static initial
  values related to the interface-type.
o Addition of UEC MDIO of_platform driver requires
  platform code add 'mdio' type to id list
  prior to calling of_platform_bus_probe (in separate
  patch).
o ucc_struct_init introduced to reduce ucc_geth_startup
  complexity.

Signed-off-by: Li Yang <leoli@freescale.com>
Signed-off-by: Kim Phillips <kim.phillips@freescale.com>
---
please consider for 2.6.22

 drivers/net/Kconfig         |    4 -
 drivers/net/Makefile        |    2 +-
 drivers/net/ucc_geth.c      |  799 ++++++++++++++-----------------------------
 drivers/net/ucc_geth.h      |  108 +------
 drivers/net/ucc_geth_mii.c  |  279 +++++++++++++++
 drivers/net/ucc_geth_mii.h  |  100 ++++++
 drivers/net/ucc_geth_phy.c  |  785 ------------------------------------------
 drivers/net/ucc_geth_phy.h  |  217 ------------
 include/linux/fsl_devices.h |   39 ---
 9 files changed, 644 insertions(+), 1689 deletions(-)
 create mode 100644 drivers/net/ucc_geth_mii.c
 create mode 100644 drivers/net/ucc_geth_mii.h
 delete mode 100644 drivers/net/ucc_geth_phy.c
 delete mode 100644 drivers/net/ucc_geth_phy.h

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 753695b..ee88838 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2295,10 +2295,6 @@ config UGETH_TX_ON_DEMOND
 	bool "Transmit on Demond support"
 	depends on UCC_GETH
 
-config UGETH_HAS_GIGA
-	bool
-	depends on UCC_GETH && PPC_MPC836x
-
 config MV643XX_ETH
 	tristate "MV-643XX Ethernet support"
 	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX || MV64360 || MOMENCO_OCELOT_3 || (PPC_MULTIPLATFORM && PPC32)
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 33af833..d961e0e 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -18,7 +18,7 @@ gianfar_driver-objs := gianfar.o \
 		gianfar_sysfs.o
 
 obj-$(CONFIG_UCC_GETH) += ucc_geth_driver.o
-ucc_geth_driver-objs := ucc_geth.o ucc_geth_phy.o
+ucc_geth_driver-objs := ucc_geth.o ucc_geth_mii.o
 
 #
 # link order important here
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 639e1e6..1b943e6 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -29,6 +29,7 @@
 #include <linux/fsl_devices.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
+#include <linux/phy.h>
 #include <linux/workqueue.h>
 
 #include <asm/of_platform.h>
@@ -41,7 +42,7 @@
 #include <asm/ucc_fast.h>
 
 #include "ucc_geth.h"
-#include "ucc_geth_phy.h"
+#include "ucc_geth_mii.h"
 
 #undef DEBUG
 
@@ -73,22 +74,13 @@ static struct ucc_geth_info ugeth_primary_info = {
 		    .bd_mem_part = MEM_PART_SYSTEM,
 		    .rtsm = UCC_FAST_SEND_IDLES_BETWEEN_FRAMES,
 		    .max_rx_buf_length = 1536,
-/* FIXME: should be changed in run time for 1G and 100M */
-#ifdef CONFIG_UGETH_HAS_GIGA
-		    .urfs = UCC_GETH_URFS_GIGA_INIT,
-		    .urfet = UCC_GETH_URFET_GIGA_INIT,
-		    .urfset = UCC_GETH_URFSET_GIGA_INIT,
-		    .utfs = UCC_GETH_UTFS_GIGA_INIT,
-		    .utfet = UCC_GETH_UTFET_GIGA_INIT,
-		    .utftt = UCC_GETH_UTFTT_GIGA_INIT,
-#else
+		    /* adjusted at startup if max-speed 1000 */
 		    .urfs = UCC_GETH_URFS_INIT,
 		    .urfet = UCC_GETH_URFET_INIT,
 		    .urfset = UCC_GETH_URFSET_INIT,
 		    .utfs = UCC_GETH_UTFS_INIT,
 		    .utfet = UCC_GETH_UTFET_INIT,
 		    .utftt = UCC_GETH_UTFTT_INIT,
-#endif
 		    .ufpt = 256,
 		    .mode = UCC_FAST_PROTOCOL_MODE_ETHERNET,
 		    .ttx_trx = UCC_FAST_GUMR_TRANSPARENT_TTX_TRX_NORMAL,
@@ -217,70 +209,6 @@ static struct list_head *dequeue(struct list_head *lh)
 	}
 }
 
-static int get_interface_details(enum enet_interface enet_interface,
-				 enum enet_speed *speed,
-				 int *r10m,
-				 int *rmm,
-				 int *rpm,
-				 int *tbi, int *limited_to_full_duplex)
-{
-	/* Analyze enet_interface according to Interface Mode
-	Configuration table */
-	switch (enet_interface) {
-	case ENET_10_MII:
-		*speed = ENET_SPEED_10BT;
-		break;
-	case ENET_10_RMII:
-		*speed = ENET_SPEED_10BT;
-		*r10m = 1;
-		*rmm = 1;
-		break;
-	case ENET_10_RGMII:
-		*speed = ENET_SPEED_10BT;
-		*rpm = 1;
-		*r10m = 1;
-		*limited_to_full_duplex = 1;
-		break;
-	case ENET_100_MII:
-		*speed = ENET_SPEED_100BT;
-		break;
-	case ENET_100_RMII:
-		*speed = ENET_SPEED_100BT;
-		*rmm = 1;
-		break;
-	case ENET_100_RGMII:
-		*speed = ENET_SPEED_100BT;
-		*rpm = 1;
-		*limited_to_full_duplex = 1;
-		break;
-	case ENET_1000_GMII:
-		*speed = ENET_SPEED_1000BT;
-		*limited_to_full_duplex = 1;
-		break;
-	case ENET_1000_RGMII:
-		*speed = ENET_SPEED_1000BT;
-		*rpm = 1;
-		*limited_to_full_duplex = 1;
-		break;
-	case ENET_1000_TBI:
-		*speed = ENET_SPEED_1000BT;
-		*tbi = 1;
-		*limited_to_full_duplex = 1;
-		break;
-	case ENET_1000_RTBI:
-		*speed = ENET_SPEED_1000BT;
-		*rpm = 1;
-		*tbi = 1;
-		*limited_to_full_duplex = 1;
-		break;
-	default:
-		return -EINVAL;
-		break;
-	}
-
-	return 0;
-}
-
 static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth, u8 *bd)
 {
 	struct sk_buff *skb = NULL;
@@ -758,24 +686,6 @@ static void dump_regs(struct ucc_geth_private *ugeth)
 	ugeth_info("hafdup     : addr - 0x%08x, val - 0x%08x",
 		   (u32) & ugeth->ug_regs->hafdup,
 		   in_be32(&ugeth->ug_regs->hafdup));
-	ugeth_info("miimcfg    : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->miimng.miimcfg,
-		   in_be32(&ugeth->ug_regs->miimng.miimcfg));
-	ugeth_info("miimcom    : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->miimng.miimcom,
-		   in_be32(&ugeth->ug_regs->miimng.miimcom));
-	ugeth_info("miimadd    : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->miimng.miimadd,
-		   in_be32(&ugeth->ug_regs->miimng.miimadd));
-	ugeth_info("miimcon    : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->miimng.miimcon,
-		   in_be32(&ugeth->ug_regs->miimng.miimcon));
-	ugeth_info("miimstat   : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->miimng.miimstat,
-		   in_be32(&ugeth->ug_regs->miimng.miimstat));
-	ugeth_info("miimmind   : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->miimng.miimind,
-		   in_be32(&ugeth->ug_regs->miimng.miimind));
 	ugeth_info("ifctl      : addr - 0x%08x, val - 0x%08x",
 		   (u32) & ugeth->ug_regs->ifctl,
 		   in_be32(&ugeth->ug_regs->ifctl));
@@ -1425,27 +1335,6 @@ static int init_mac_station_addr_regs(u8 address_byte_0,
 	return 0;
 }
 
-static int init_mac_duplex_mode(int full_duplex,
-				int limited_to_full_duplex,
-				volatile u32 *maccfg2_register)
-{
-	u32 value = 0;
-
-	/* some interfaces must work in full duplex mode */
-	if ((full_duplex == 0) && (limited_to_full_duplex == 1))
-		return -EINVAL;
-
-	value = in_be32(maccfg2_register);
-
-	if (full_duplex)
-		value |= MACCFG2_FDX;
-	else
-		value &= ~MACCFG2_FDX;
-
-	out_be32(maccfg2_register, value);
-	return 0;
-}
-
 static int init_check_frame_length_mode(int length_check,
 					volatile u32 *maccfg2_register)
 {
@@ -1477,40 +1366,6 @@ static int init_preamble_length(u8 preamble_length,
 	return 0;
 }
 
-static int init_mii_management_configuration(int reset_mgmt,
-					     int preamble_supress,
-					     volatile u32 *miimcfg_register,
-					     volatile u32 *miimind_register)
-{
-	unsigned int timeout = PHY_INIT_TIMEOUT;
-	u32 value = 0;
-
-	value = in_be32(miimcfg_register);
-	if (reset_mgmt) {
-		value |= MIIMCFG_RESET_MANAGEMENT;
-		out_be32(miimcfg_register, value);
-	}
-
-	value = 0;
-
-	if (preamble_supress)
-		value |= MIIMCFG_NO_PREAMBLE;
-
-	value |= UCC_GETH_MIIMCFG_MNGMNT_CLC_DIV_INIT;
-	out_be32(miimcfg_register, value);
-
-	/* Wait until the bus is free */
-	while ((in_be32(miimind_register) & MIIMIND_BUSY) && timeout--)
-		cpu_relax();
-
-	if (timeout <= 0) {
-		ugeth_err("%s: The MII Bus is stuck!", __FUNCTION__);
-		return -ETIMEDOUT;
-	}
-
-	return 0;
-}
-
 static int init_rx_parameters(int reject_broadcast,
 			      int receive_short_frames,
 			      int promiscuous, volatile u32 *upsmr_register)
@@ -1570,10 +1425,8 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	struct ucc_geth_info *ug_info;
 	struct ucc_geth *ug_regs;
 	struct ucc_fast *uf_regs;
-	enum enet_speed speed;
-	int ret_val, rpm = 0, tbi = 0, r10m = 0, rmm =
-	    0, limited_to_full_duplex = 0;
-	u32 upsmr, maccfg2, utbipar, tbiBaseAddress;
+	int ret_val;
+	u32 upsmr, maccfg2, tbiBaseAddress;
 	u16 value;
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
@@ -1582,24 +1435,13 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	ug_regs = ugeth->ug_regs;
 	uf_regs = ugeth->uccf->uf_regs;
 
-	/* Analyze enet_interface according to Interface Mode Configuration
-	table */
-	ret_val =
-	    get_interface_details(ug_info->enet_interface, &speed, &r10m, &rmm,
-				  &rpm, &tbi, &limited_to_full_duplex);
-	if (ret_val != 0) {
-		ugeth_err
-		  ("%s: half duplex not supported in requested configuration.",
-		     __FUNCTION__);
-		return ret_val;
-	}
-
 	/*                    Set MACCFG2                    */
 	maccfg2 = in_be32(&ug_regs->maccfg2);
 	maccfg2 &= ~MACCFG2_INTERFACE_MODE_MASK;
-	if ((speed == ENET_SPEED_10BT) || (speed == ENET_SPEED_100BT))
+	if ((ugeth->max_speed == SPEED_10) ||
+	    (ugeth->max_speed == SPEED_100))
 		maccfg2 |= MACCFG2_INTERFACE_MODE_NIBBLE;
-	else if (speed == ENET_SPEED_1000BT)
+	else if (ugeth->max_speed == SPEED_1000)
 		maccfg2 |= MACCFG2_INTERFACE_MODE_BYTE;
 	maccfg2 |= ug_info->padAndCrc;
 	out_be32(&ug_regs->maccfg2, maccfg2);
@@ -1607,54 +1449,38 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	/*                    Set UPSMR                      */
 	upsmr = in_be32(&uf_regs->upsmr);
 	upsmr &= ~(UPSMR_RPM | UPSMR_R10M | UPSMR_TBIM | UPSMR_RMM);
-	if (rpm)
+	if ((ugeth->phy_interface == PHY_INTERFACE_MODE_RMII) ||
+	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII) ||
+	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
 		upsmr |= UPSMR_RPM;
-	if (r10m)
-		upsmr |= UPSMR_R10M;
-	if (tbi)
+		switch (ugeth->max_speed) {
+		case SPEED_10:
+			upsmr |= UPSMR_R10M;
+			/* FALLTHROUGH */
+		case SPEED_100:
+			if (ugeth->phy_interface != PHY_INTERFACE_MODE_RTBI)
+				upsmr |= UPSMR_RMM;
+		}
+	}
+	if ((ugeth->phy_interface == PHY_INTERFACE_MODE_TBI) ||
+	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
 		upsmr |= UPSMR_TBIM;
-	if (rmm)
-		upsmr |= UPSMR_RMM;
+	}
 	out_be32(&uf_regs->upsmr, upsmr);
 
-	/*                    Set UTBIPAR                    */
-	utbipar = in_be32(&ug_regs->utbipar);
-	utbipar &= ~UTBIPAR_PHY_ADDRESS_MASK;
-	if (tbi)
-		utbipar |=
-		    (ug_info->phy_address +
-		     ugeth->ug_info->uf_info.
-		     ucc_num) << UTBIPAR_PHY_ADDRESS_SHIFT;
-	else
-		utbipar |=
-		    (0x10 +
-		     ugeth->ug_info->uf_info.
-		     ucc_num) << UTBIPAR_PHY_ADDRESS_SHIFT;
-	out_be32(&ug_regs->utbipar, utbipar);
-
 	/* Disable autonegotiation in tbi mode, because by default it
 	comes up in autonegotiation mode. */
 	/* Note that this depends on proper setting in utbipar register. */
-	if (tbi) {
+	if ((ugeth->phy_interface == PHY_INTERFACE_MODE_TBI) ||
+	    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
 		tbiBaseAddress = in_be32(&ug_regs->utbipar);
 		tbiBaseAddress &= UTBIPAR_PHY_ADDRESS_MASK;
 		tbiBaseAddress >>= UTBIPAR_PHY_ADDRESS_SHIFT;
-		value =
-		    ugeth->mii_info->mdio_read(ugeth->dev, (u8) tbiBaseAddress,
-					       ENET_TBI_MII_CR);
+		value = ugeth->phydev->bus->read(ugeth->phydev->bus,
+				(u8) tbiBaseAddress, ENET_TBI_MII_CR);
 		value &= ~0x1000;	/* Turn off autonegotiation */
-		ugeth->mii_info->mdio_write(ugeth->dev, (u8) tbiBaseAddress,
-					    ENET_TBI_MII_CR, value);
-	}
-
-	ret_val = init_mac_duplex_mode(1,
-				       limited_to_full_duplex,
-				       &ug_regs->maccfg2);
-	if (ret_val != 0) {
-		ugeth_err
-		("%s: half duplex not supported in requested configuration.",
-		     __FUNCTION__);
-		return ret_val;
+		ugeth->phydev->bus->write(ugeth->phydev->bus,
+				(u8) tbiBaseAddress, ENET_TBI_MII_CR, value);
 	}
 
 	init_check_frame_length_mode(ug_info->lengthCheckRx, &ug_regs->maccfg2);
@@ -1676,76 +1502,87 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
  * function converts those variables into the appropriate
  * register values, and can bring down the device if needed.
  */
+
 static void adjust_link(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 	struct ucc_geth *ug_regs;
-	u32 tempval;
-	struct ugeth_mii_info *mii_info = ugeth->mii_info;
+	struct ucc_fast *uf_regs;
+	struct phy_device *phydev = ugeth->phydev;
+	unsigned long flags;
+	int new_state = 0;
 
 	ug_regs = ugeth->ug_regs;
+	uf_regs = ugeth->uccf->uf_regs;
+
+	spin_lock_irqsave(&ugeth->lock, flags);
 
-	if (mii_info->link) {
+	if (phydev->link) {
+		u32 tempval = in_be32(&ug_regs->maccfg2);
+		u32 upsmr = in_be32(&uf_regs->upsmr);
 		/* Now we make sure that we can be in full duplex mode.
 		 * If not, we operate in half-duplex mode. */
-		if (mii_info->duplex != ugeth->oldduplex) {
-			if (!(mii_info->duplex)) {
-				tempval = in_be32(&ug_regs->maccfg2);
+		if (phydev->duplex != ugeth->oldduplex) {
+			new_state = 1;
+			if (!(phydev->duplex))
 				tempval &= ~(MACCFG2_FDX);
-				out_be32(&ug_regs->maccfg2, tempval);
-
-				ugeth_info("%s: Half Duplex", dev->name);
-			} else {
-				tempval = in_be32(&ug_regs->maccfg2);
+			else
 				tempval |= MACCFG2_FDX;
-				out_be32(&ug_regs->maccfg2, tempval);
-
-				ugeth_info("%s: Full Duplex", dev->name);
-			}
-
-			ugeth->oldduplex = mii_info->duplex;
+			ugeth->oldduplex = phydev->duplex;
 		}
 
-		if (mii_info->speed != ugeth->oldspeed) {
-			switch (mii_info->speed) {
-			case 1000:
-				ugeth->ug_info->enet_interface = ENET_1000_RGMII;
+		if (phydev->speed != ugeth->oldspeed) {
+			new_state = 1;
+			switch (phydev->speed) {
+			case SPEED_1000:
+				tempval = ((tempval &
+					    ~(MACCFG2_INTERFACE_MODE_MASK)) |
+					    MACCFG2_INTERFACE_MODE_BYTE);
 				break;
-			case 100:
-				ugeth->ug_info->enet_interface = ENET_100_RGMII;
-				break;
-			case 10:
-				ugeth->ug_info->enet_interface = ENET_10_RGMII;
+			case SPEED_100:
+			case SPEED_10:
+				tempval = ((tempval &
+					    ~(MACCFG2_INTERFACE_MODE_MASK)) |
+					    MACCFG2_INTERFACE_MODE_NIBBLE);
+				/* if reduced mode, re-set UPSMR.R10M */
+				if ((ugeth->phy_interface == PHY_INTERFACE_MODE_RMII) ||
+				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RGMII) ||
+				    (ugeth->phy_interface == PHY_INTERFACE_MODE_RTBI)) {
+					if (phydev->speed == SPEED_10)
+						upsmr |= UPSMR_R10M;
+					else
+						upsmr &= ~(UPSMR_R10M);
+				}
 				break;
 			default:
-				ugeth_warn
-				    ("%s: Ack!  Speed (%d) is not 10/100/1000!",
-				     dev->name, mii_info->speed);
+				if (netif_msg_link(ugeth))
+					ugeth_warn(
+						"%s: Ack!  Speed (%d) is not 10/100/1000!",
+						dev->name, phydev->speed);
 				break;
 			}
-			adjust_enet_interface(ugeth);
-
-			ugeth_info("%s: Speed %dBT", dev->name,
-				   mii_info->speed);
-
-			ugeth->oldspeed = mii_info->speed;
+			ugeth->oldspeed = phydev->speed;
 		}
 
+		out_be32(&ug_regs->maccfg2, tempval);
+		out_be32(&uf_regs->upsmr, upsmr);
+
 		if (!ugeth->oldlink) {
-			ugeth_info("%s: Link is up", dev->name);
+			new_state = 1;
 			ugeth->oldlink = 1;
-			netif_carrier_on(dev);
 			netif_schedule(dev);
 		}
-	} else {
-		if (ugeth->oldlink) {
-			ugeth_info("%s: Link is down", dev->name);
+	} else if (ugeth->oldlink) {
+			new_state = 1;
 			ugeth->oldlink = 0;
 			ugeth->oldspeed = 0;
 			ugeth->oldduplex = -1;
-			netif_carrier_off(dev);
-		}
 	}
+
+	if (new_state && netif_msg_link(ugeth))
+		phy_print_status(phydev);
+
+	spin_unlock_irqrestore(&ugeth->lock, flags);
 }
 
 /* Configure the PHY for dev.
@@ -1753,94 +1590,40 @@ static void adjust_link(struct net_device *dev)
  */
 static int init_phy(struct net_device *dev)
 {
-	struct ucc_geth_private *ugeth = netdev_priv(dev);
-	struct phy_info *curphy;
-	struct ucc_mii_mng *mii_regs;
-	struct ugeth_mii_info *mii_info;
-	int err;
+	struct ucc_geth_private *priv = netdev_priv(dev);
+	struct phy_device *phydev;
+	char phy_id[BUS_ID_SIZE];
 
-	mii_regs = &ugeth->ug_regs->miimng;
+	priv->oldlink = 0;
+	priv->oldspeed = 0;
+	priv->oldduplex = -1;
 
-	ugeth->oldlink = 0;
-	ugeth->oldspeed = 0;
-	ugeth->oldduplex = -1;
+	snprintf(phy_id, BUS_ID_SIZE, PHY_ID_FMT, priv->ug_info->mdio_bus,
+			priv->ug_info->phy_address);
 
-	mii_info = kmalloc(sizeof(struct ugeth_mii_info), GFP_KERNEL);
+	phydev = phy_connect(dev, phy_id, &adjust_link, 0, priv->phy_interface);
 
-	if (NULL == mii_info) {
-		ugeth_err("%s: Could not allocate mii_info", dev->name);
-		return -ENOMEM;
+	if (IS_ERR(phydev)) {
+		printk("%s: Could not attach to PHY\n", dev->name);
+		return PTR_ERR(phydev);
 	}
 
-	mii_info->mii_regs = mii_regs;
-	mii_info->speed = SPEED_1000;
-	mii_info->duplex = DUPLEX_FULL;
-	mii_info->pause = 0;
-	mii_info->link = 0;
-
-	mii_info->advertising = (ADVERTISED_10baseT_Half |
+	phydev->supported &= (ADVERTISED_10baseT_Half |
 				 ADVERTISED_10baseT_Full |
 				 ADVERTISED_100baseT_Half |
-				 ADVERTISED_100baseT_Full |
-				 ADVERTISED_1000baseT_Full);
-	mii_info->autoneg = 1;
-
-	mii_info->mii_id = ugeth->ug_info->phy_address;
-
-	mii_info->dev = dev;
-
-	mii_info->mdio_read = &read_phy_reg;
-	mii_info->mdio_write = &write_phy_reg;
-
-	spin_lock_init(&mii_info->mdio_lock);
+				 ADVERTISED_100baseT_Full);
 
-	ugeth->mii_info = mii_info;
+	if (priv->max_speed == SPEED_1000)
+		phydev->supported |= ADVERTISED_1000baseT_Full;
 
-	spin_lock_irq(&ugeth->lock);
-
-	/* Set this UCC to be the master of the MII managment */
-	ucc_set_qe_mux_mii_mng(ugeth->ug_info->uf_info.ucc_num);
-
-	if (init_mii_management_configuration(1,
-					      ugeth->ug_info->
-					      miiPreambleSupress,
-					      &mii_regs->miimcfg,
-					      &mii_regs->miimind)) {
-		ugeth_err("%s: The MII Bus is stuck!", dev->name);
-		err = -1;
-		goto bus_fail;
-	}
-
-	spin_unlock_irq(&ugeth->lock);
-
-	/* get info for this PHY */
-	curphy = get_phy_info(ugeth->mii_info);
-
-	if (curphy == NULL) {
-		ugeth_err("%s: No PHY found", dev->name);
-		err = -1;
-		goto no_phy;
-	}
+	phydev->advertising = phydev->supported;
 
-	mii_info->phyinfo = curphy;
-
-	/* Run the commands which initialize the PHY */
-	if (curphy->init) {
-		err = curphy->init(ugeth->mii_info);
-		if (err)
-			goto phy_init_fail;
-	}
+	priv->phydev = phydev;
 
 	return 0;
-
-      phy_init_fail:
-      no_phy:
-      bus_fail:
-	kfree(mii_info);
-
-	return err;
 }
 
+
 #ifdef CONFIG_UGETH_TX_ON_DEMOND
 static int ugeth_transmit_on_demand(struct ucc_geth_private *ugeth)
 {
@@ -2487,6 +2270,7 @@ static void ucc_geth_set_multi(struct net_device *dev)
 static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 {
 	struct ucc_geth *ug_regs = ugeth->ug_regs;
+	struct phy_device *phydev = ugeth->phydev;
 	u32 tempval;
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
@@ -2495,8 +2279,7 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 	ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
 
 	/* Tell the kernel the link is down */
-	ugeth->mii_info->link = 0;
-	adjust_link(ugeth->dev);
+	phy_stop(phydev);
 
 	/* Mask all interrupts */
 	out_be32(ugeth->uccf->p_ucce, 0x00000000);
@@ -2509,46 +2292,16 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 	tempval &= ~(MACCFG1_ENABLE_RX | MACCFG1_ENABLE_TX);
 	out_be32(&ug_regs->maccfg1, tempval);
 
-	if (ugeth->ug_info->board_flags & FSL_UGETH_BRD_HAS_PHY_INTR) {
-		/* Clear any pending interrupts */
-		mii_clear_phy_interrupt(ugeth->mii_info);
-
-		/* Disable PHY Interrupts */
-		mii_configure_phy_interrupt(ugeth->mii_info,
-					    MII_INTERRUPT_DISABLED);
-	}
-
 	free_irq(ugeth->ug_info->uf_info.irq, ugeth->dev);
 
-	if (ugeth->ug_info->board_flags & FSL_UGETH_BRD_HAS_PHY_INTR) {
-		free_irq(ugeth->ug_info->phy_interrupt, ugeth->dev);
-	} else {
-		del_timer_sync(&ugeth->phy_info_timer);
-	}
-
 	ucc_geth_memclean(ugeth);
 }
 
-static int ucc_geth_startup(struct ucc_geth_private *ugeth)
+static int ucc_struct_init(struct ucc_geth_private *ugeth)
 {
-	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
-	struct ucc_geth_init_pram *p_init_enet_pram;
-	struct ucc_fast_private *uccf;
 	struct ucc_geth_info *ug_info;
 	struct ucc_fast_info *uf_info;
-	struct ucc_fast *uf_regs;
-	struct ucc_geth *ug_regs;
-	int ret_val = -EINVAL;
-	u32 remoder = UCC_GETH_REMODER_INIT;
-	u32 init_enet_pram_offset, cecr_subblock, command, maccfg1;
-	u32 ifstat, i, j, size, l2qt, l3qt, length;
-	u16 temoder = UCC_GETH_TEMODER_INIT;
-	u16 test;
-	u8 function_code = 0;
-	u8 *bd, *endOfRing;
-	u8 numThreadsRxNumerical, numThreadsTxNumerical;
-
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	int i;
 
 	ug_info = ugeth->ug_info;
 	uf_info = &ug_info->uf_info;
@@ -2647,12 +2400,42 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	for (i = 0; i < ug_info->numQueuesTx; i++)
 		uf_info->uccm_mask |= (UCCE_TXBF_SINGLE_MASK << i);
 	/* Initialize the general fast UCC block. */
-	if (ucc_fast_init(uf_info, &uccf)) {
+	if (ucc_fast_init(uf_info, &ugeth->uccf)) {
 		ugeth_err("%s: Failed to init uccf.", __FUNCTION__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
-	ugeth->uccf = uccf;
+
+	ugeth->ug_regs = (struct ucc_geth *) ioremap(uf_info->regs, sizeof(struct ucc_geth));
+
+	return 0;
+}
+
+static int ucc_geth_startup(struct ucc_geth_private *ugeth)
+{
+	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
+	struct ucc_geth_init_pram *p_init_enet_pram;
+	struct ucc_fast_private *uccf;
+	struct ucc_geth_info *ug_info;
+	struct ucc_fast_info *uf_info;
+	struct ucc_fast *uf_regs;
+	struct ucc_geth *ug_regs;
+	int ret_val = -EINVAL;
+	u32 remoder = UCC_GETH_REMODER_INIT;
+	u32 init_enet_pram_offset, cecr_subblock, command, maccfg1;
+	u32 ifstat, i, j, size, l2qt, l3qt, length;
+	u16 temoder = UCC_GETH_TEMODER_INIT;
+	u16 test;
+	u8 function_code = 0;
+	u8 *bd, *endOfRing;
+	u8 numThreadsRxNumerical, numThreadsTxNumerical;
+
+	ugeth_vdbg("%s: IN", __FUNCTION__);
+	uccf = ugeth->uccf;
+	ug_info = ugeth->ug_info;
+	uf_info = &ug_info->uf_info;
+	uf_regs = uccf->uf_regs;
+	ug_regs = ugeth->ug_regs;
 
 	switch (ug_info->numThreadsRx) {
 	case UCC_GETH_NUM_OF_THREADS_1:
@@ -2711,10 +2494,6 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    || (ug_info->vlanOperationNonTagged !=
 		UCC_GETH_VLAN_OPERATION_NON_TAGGED_NOP);
 
-	uf_regs = uccf->uf_regs;
-	ug_regs = (struct ucc_geth *) (uccf->uf_regs);
-	ugeth->ug_regs = ug_regs;
-
 	init_default_reg_vals(&uf_regs->upsmr,
 			      &ug_regs->maccfg1, &ug_regs->maccfg2);
 
@@ -3841,128 +3620,6 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t phy_interrupt(int irq, void *dev_id)
-{
-	struct net_device *dev = (struct net_device *)dev_id;
-	struct ucc_geth_private *ugeth = netdev_priv(dev);
-
-	ugeth_vdbg("%s: IN", __FUNCTION__);
-
-	/* Clear the interrupt */
-	mii_clear_phy_interrupt(ugeth->mii_info);
-
-	/* Disable PHY interrupts */
-	mii_configure_phy_interrupt(ugeth->mii_info, MII_INTERRUPT_DISABLED);
-
-	/* Schedule the phy change */
-	schedule_work(&ugeth->tq);
-
-	return IRQ_HANDLED;
-}
-
-/* Scheduled by the phy_interrupt/timer to handle PHY changes */
-static void ugeth_phy_change(struct work_struct *work)
-{
-	struct ucc_geth_private *ugeth =
-		container_of(work, struct ucc_geth_private, tq);
-	struct net_device *dev = ugeth->dev;
-	struct ucc_geth *ug_regs;
-	int result = 0;
-
-	ugeth_vdbg("%s: IN", __FUNCTION__);
-
-	ug_regs = ugeth->ug_regs;
-
-	/* Delay to give the PHY a chance to change the
-	 * register state */
-	msleep(1);
-
-	/* Update the link, speed, duplex */
-	result = ugeth->mii_info->phyinfo->read_status(ugeth->mii_info);
-
-	/* Adjust the known status as long as the link
-	 * isn't still coming up */
-	if ((0 == result) || (ugeth->mii_info->link == 0))
-		adjust_link(dev);
-
-	/* Reenable interrupts, if needed */
-	if (ugeth->ug_info->board_flags & FSL_UGETH_BRD_HAS_PHY_INTR)
-		mii_configure_phy_interrupt(ugeth->mii_info,
-					    MII_INTERRUPT_ENABLED);
-}
-
-/* Called every so often on systems that don't interrupt
- * the core for PHY changes */
-static void ugeth_phy_timer(unsigned long data)
-{
-	struct net_device *dev = (struct net_device *)data;
-	struct ucc_geth_private *ugeth = netdev_priv(dev);
-
-	schedule_work(&ugeth->tq);
-
-	mod_timer(&ugeth->phy_info_timer, jiffies + PHY_CHANGE_TIME * HZ);
-}
-
-/* Keep trying aneg for some time
- * If, after GFAR_AN_TIMEOUT seconds, it has not
- * finished, we switch to forced.
- * Either way, once the process has completed, we either
- * request the interrupt, or switch the timer over to
- * using ugeth_phy_timer to check status */
-static void ugeth_phy_startup_timer(unsigned long data)
-{
-	struct ugeth_mii_info *mii_info = (struct ugeth_mii_info *)data;
-	struct ucc_geth_private *ugeth = netdev_priv(mii_info->dev);
-	static int secondary = UGETH_AN_TIMEOUT;
-	int result;
-
-	/* Configure the Auto-negotiation */
-	result = mii_info->phyinfo->config_aneg(mii_info);
-
-	/* If autonegotiation failed to start, and
-	 * we haven't timed out, reset the timer, and return */
-	if (result && secondary--) {
-		mod_timer(&ugeth->phy_info_timer, jiffies + HZ);
-		return;
-	} else if (result) {
-		/* Couldn't start autonegotiation.
-		 * Try switching to forced */
-		mii_info->autoneg = 0;
-		result = mii_info->phyinfo->config_aneg(mii_info);
-
-		/* Forcing failed!  Give up */
-		if (result) {
-			ugeth_err("%s: Forcing failed!", mii_info->dev->name);
-			return;
-		}
-	}
-
-	/* Kill the timer so it can be restarted */
-	del_timer_sync(&ugeth->phy_info_timer);
-
-	/* Grab the PHY interrupt, if necessary/possible */
-	if (ugeth->ug_info->board_flags & FSL_UGETH_BRD_HAS_PHY_INTR) {
-		if (request_irq(ugeth->ug_info->phy_interrupt,
-				phy_interrupt, IRQF_SHARED,
-				"phy_interrupt", mii_info->dev) < 0) {
-			ugeth_err("%s: Can't get IRQ %d (PHY)",
-				  mii_info->dev->name,
-				  ugeth->ug_info->phy_interrupt);
-		} else {
-			mii_configure_phy_interrupt(ugeth->mii_info,
-						    MII_INTERRUPT_ENABLED);
-			return;
-		}
-	}
-
-	/* Start the timer again, this time in order to
-	 * handle a change in status */
-	init_timer(&ugeth->phy_info_timer);
-	ugeth->phy_info_timer.function = &ugeth_phy_timer;
-	ugeth->phy_info_timer.data = (unsigned long)mii_info->dev;
-	mod_timer(&ugeth->phy_info_timer, jiffies + PHY_CHANGE_TIME * HZ);
-}
-
 /* Called when something needs to use the ethernet device */
 /* Returns 0 for success. */
 static int ucc_geth_open(struct net_device *dev)
@@ -3979,6 +3636,12 @@ static int ucc_geth_open(struct net_device *dev)
 		return -EINVAL;
 	}
 
+	err = ucc_struct_init(ugeth);
+	if (err) {
+		ugeth_err("%s: Cannot configure internal struct, aborting.", dev->name);
+		return err;
+	}
+
 	err = ucc_geth_startup(ugeth);
 	if (err) {
 		ugeth_err("%s: Cannot configure net device, aborting.",
@@ -4006,9 +3669,12 @@ static int ucc_geth_open(struct net_device *dev)
 
 	err = init_phy(dev);
 	if (err) {
-		ugeth_err("%s: Cannot initialzie PHY, aborting.", dev->name);
+		ugeth_err("%s: Cannot initialize PHY, aborting.", dev->name);
 		return err;
 	}
+
+	phy_start(ugeth->phydev);
+
 #ifndef CONFIG_UGETH_NAPI
 	err =
 	    request_irq(ugeth->ug_info->uf_info.irq, ucc_geth_irq_handler, 0,
@@ -4021,14 +3687,6 @@ static int ucc_geth_open(struct net_device *dev)
 	}
 #endif				/* CONFIG_UGETH_NAPI */
 
-	/* Set up the PHY change work queue */
-	INIT_WORK(&ugeth->tq, ugeth_phy_change);
-
-	init_timer(&ugeth->phy_info_timer);
-	ugeth->phy_info_timer.function = &ugeth_phy_startup_timer;
-	ugeth->phy_info_timer.data = (unsigned long)ugeth->mii_info;
-	mod_timer(&ugeth->phy_info_timer, jiffies + HZ);
-
 	err = ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
 	if (err) {
 		ugeth_err("%s: Cannot enable net device, aborting.", dev->name);
@@ -4050,11 +3708,8 @@ static int ucc_geth_close(struct net_device *dev)
 
 	ucc_geth_stop(ugeth);
 
-	/* Shutdown the PHY */
-	if (ugeth->mii_info->phyinfo->close)
-		ugeth->mii_info->phyinfo->close(ugeth->mii_info);
-
-	kfree(ugeth->mii_info);
+	phy_disconnect(ugeth->phydev);
+	ugeth->phydev = NULL;
 
 	netif_stop_queue(dev);
 
@@ -4063,20 +3718,53 @@ static int ucc_geth_close(struct net_device *dev)
 
 const struct ethtool_ops ucc_geth_ethtool_ops = { };
 
+static phy_interface_t to_phy_interface(const char *interface_type)
+{
+	if (strcasecmp(interface_type, "mii") == 0)
+		return PHY_INTERFACE_MODE_MII;
+	if (strcasecmp(interface_type, "gmii") == 0)
+		return PHY_INTERFACE_MODE_GMII;
+	if (strcasecmp(interface_type, "sgmii") == 0)
+		return PHY_INTERFACE_MODE_SGMII;
+	if (strcasecmp(interface_type, "tbi") == 0)
+		return PHY_INTERFACE_MODE_TBI;
+	if (strcasecmp(interface_type, "rmii") == 0)
+		return PHY_INTERFACE_MODE_RMII;
+	if (strcasecmp(interface_type, "rgmii") == 0)
+		return PHY_INTERFACE_MODE_RGMII;
+	if (strcasecmp(interface_type, "rtbi") == 0)
+		return PHY_INTERFACE_MODE_RTBI;
+
+	return PHY_INTERFACE_MODE_MII;
+}
+
 static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *match)
 {
 	struct device *device = &ofdev->dev;
 	struct device_node *np = ofdev->node;
+	struct device_node *mdio;
 	struct net_device *dev = NULL;
 	struct ucc_geth_private *ugeth = NULL;
 	struct ucc_geth_info *ug_info;
 	struct resource res;
 	struct device_node *phy;
-	int err, ucc_num, phy_interface;
-	static int mii_mng_configured = 0;
+	int err, ucc_num, max_speed;
 	const phandle *ph;
 	const unsigned int *prop;
 	const void *mac_addr;
+	phy_interface_t phy_interface;
+	static const int enet_to_speed[] = {
+		SPEED_10, SPEED_10, SPEED_10,
+		SPEED_100, SPEED_100, SPEED_100,
+		SPEED_1000, SPEED_1000, SPEED_1000, SPEED_1000,
+	};
+	static const phy_interface_t enet_to_phy_interface[] = {
+		PHY_INTERFACE_MODE_MII, PHY_INTERFACE_MODE_RMII,
+		PHY_INTERFACE_MODE_RGMII, PHY_INTERFACE_MODE_MII,
+		PHY_INTERFACE_MODE_RMII, PHY_INTERFACE_MODE_RGMII,
+		PHY_INTERFACE_MODE_GMII, PHY_INTERFACE_MODE_RGMII,
+		PHY_INTERFACE_MODE_TBI, PHY_INTERFACE_MODE_RTBI,
+	};
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
@@ -4087,6 +3775,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 
 	ug_info = &ugeth_info[ucc_num];
 	ug_info->uf_info.ucc_num = ucc_num;
+
 	prop = get_property(np, "rx-clock", NULL);
 	ug_info->uf_info.rx_clock = *prop;
 	prop = get_property(np, "tx-clock", NULL);
@@ -4104,13 +3793,59 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	if (phy == NULL)
 		return -ENODEV;
 
+	/* speed settings */
+	prop = get_property(np, "max-speed", NULL);
+	if (!prop) {
+		/* handle interface property present in old trees */
+		prop = get_property(phy, "interface", NULL);
+		if (prop != NULL)
+			max_speed = enet_to_speed[*prop];
+		else
+			return -ENODEV;
+	} else {
+		max_speed = *prop;
+	}
+	if (max_speed == SPEED_1000) {
+		ug_info->uf_info.urfs = UCC_GETH_URFS_GIGA_INIT;
+		ug_info->uf_info.urfet = UCC_GETH_URFET_GIGA_INIT;
+		ug_info->uf_info.urfset = UCC_GETH_URFSET_GIGA_INIT;
+		ug_info->uf_info.utfs = UCC_GETH_UTFS_GIGA_INIT;
+		ug_info->uf_info.utfet = UCC_GETH_UTFET_GIGA_INIT;
+		ug_info->uf_info.utftt = UCC_GETH_UTFTT_GIGA_INIT;
+	}
+
+	/* set the PHY address */
 	prop = get_property(phy, "reg", NULL);
+	if (prop == NULL)
+		return -1;
 	ug_info->phy_address = *prop;
-	prop = get_property(phy, "interface", NULL);
-	ug_info->enet_interface = *prop;
-	ug_info->phy_interrupt = irq_of_parse_and_map(phy, 0);
-	ug_info->board_flags = (ug_info->phy_interrupt == NO_IRQ)?
-			0:FSL_UGETH_BRD_HAS_PHY_INTR;
+
+	/* get the phy interface type */
+	prop = get_property(np, "interface-type", NULL);
+	if (!prop) {
+		/* handle interface property present in old trees */
+		prop = get_property(phy, "interface", NULL);
+		if (prop != NULL)
+			phy_interface = enet_to_phy_interface[*prop];
+		else
+			return -EINVAL;
+	} else {
+		phy_interface = to_phy_interface((const char *)prop);
+	}
+
+	/* Set the bus id */
+	mdio = of_get_parent(phy);
+
+	if (mdio == NULL)
+		return -1;
+
+	err = of_address_to_resource(mdio, 0, &res);
+	of_node_put(mdio);
+
+	if (err)
+		return -1;
+
+	ug_info->mdio_bus = res.start;
 
 	printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d) \n",
 		ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
@@ -4122,43 +3857,6 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		return -ENODEV;
 	}
 
-	/* FIXME: Work around for early chip rev.               */
-	/* There's a bug in initial chip rev(s) in the RGMII ac */
-	/* timing.						*/
-	/* The following compensates by writing to the reserved */
-	/* QE Port Output Hold Registers (CPOH1?).              */
-	prop = get_property(phy, "interface", NULL);
-	phy_interface = *prop;
-	if ((phy_interface == ENET_1000_RGMII) ||
-			(phy_interface == ENET_100_RGMII) ||
-			(phy_interface == ENET_10_RGMII)) {
-		struct device_node *soc;
-		phys_addr_t immrbase = -1;
-		u32 *tmp_reg;
-		u32 tmp_val;
-
-		soc = of_find_node_by_type(NULL, "soc");
-		if (soc) {
-			unsigned int size;
-			const void *prop = get_property(soc, "reg", &size);
-			immrbase = of_translate_address(soc, prop);
-			of_node_put(soc);
-		};
-
-		tmp_reg = (u32 *) ioremap(immrbase + 0x14A8, 0x4);
-		tmp_val = in_be32(tmp_reg);
-		if (ucc_num == 1)
-			out_be32(tmp_reg, tmp_val | 0x00003000);
-		else if (ucc_num == 2)
-			out_be32(tmp_reg, tmp_val | 0x0c000000);
-		iounmap(tmp_reg);
-	}
-
-	if (!mii_mng_configured) {
-		ucc_set_qe_mux_mii_mng(ucc_num);
-		mii_mng_configured = 1;
-	}
-
 	/* Create an ethernet device instance */
 	dev = alloc_etherdev(sizeof(*ugeth));
 
@@ -4192,6 +3890,10 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	dev->set_multicast_list = ucc_geth_set_multi;
 	dev->ethtool_ops = &ucc_geth_ethtool_ops;
 
+	ugeth->msg_enable = (NETIF_MSG_IFUP << 1 ) - 1;
+	ugeth->phy_interface = phy_interface;
+	ugeth->max_speed = max_speed;
+
 	err = register_netdev(dev);
 	if (err) {
 		ugeth_err("%s: Cannot register net device, aborting.",
@@ -4200,13 +3902,13 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		return err;
 	}
 
-	ugeth->ug_info = ug_info;
-	ugeth->dev = dev;
-
 	mac_addr = of_get_mac_address(np);
 	if (mac_addr)
 		memcpy(dev->dev_addr, mac_addr, 6);
 
+	ugeth->ug_info = ug_info;
+	ugeth->dev = dev;
+
 	return 0;
 }
 
@@ -4242,19 +3944,30 @@ static struct of_platform_driver ucc_geth_driver = {
 
 static int __init ucc_geth_init(void)
 {
-	int i;
+	int i, ret;
+
+	ret = uec_mdio_init();
+
+	if (ret)
+		return ret;
 
 	printk(KERN_INFO "ucc_geth: " DRV_DESC "\n");
 	for (i = 0; i < 8; i++)
 		memcpy(&(ugeth_info[i]), &ugeth_primary_info,
 		       sizeof(ugeth_primary_info));
 
-	return of_register_platform_driver(&ucc_geth_driver);
+	ret = of_register_platform_driver(&ucc_geth_driver);
+
+	if (ret)
+		uec_mdio_exit();
+
+	return ret;
 }
 
 static void __exit ucc_geth_exit(void)
 {
 	of_unregister_platform_driver(&ucc_geth_driver);
+	uec_mdio_exit();
 }
 
 module_init(ucc_geth_init);
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h
index a665612..6e97c20 100644
--- a/drivers/net/ucc_geth.h
+++ b/drivers/net/ucc_geth.h
@@ -28,6 +28,8 @@
 #include <asm/ucc.h>
 #include <asm/ucc_fast.h>
 
+#include "ucc_geth_mii.h"
+
 #define NUM_TX_QUEUES                   8
 #define NUM_RX_QUEUES                   8
 #define NUM_BDS_IN_PREFETCHED_BDS       4
@@ -36,15 +38,6 @@
 #define ENET_INIT_PARAM_MAX_ENTRIES_RX  9
 #define ENET_INIT_PARAM_MAX_ENTRIES_TX  8
 
-struct ucc_mii_mng {
-	u32 miimcfg;		/* MII management configuration reg */
-	u32 miimcom;		/* MII management command reg */
-	u32 miimadd;		/* MII management address reg */
-	u32 miimcon;		/* MII management control reg */
-	u32 miimstat;		/* MII management status reg */
-	u32 miimind;		/* MII management indication reg */
-} __attribute__ ((packed));
-
 struct ucc_geth {
 	struct ucc_fast uccf;
 
@@ -53,7 +46,7 @@ struct ucc_geth {
 	u32 ipgifg;		/* interframe gap reg.  */
 	u32 hafdup;		/* half-duplex reg.  */
 	u8 res1[0x10];
-	struct ucc_mii_mng miimng;	/* MII management structure */
+	u8 miimng[0x18];	/* MII management structure moved to _mii.h */
 	u32 ifctl;		/* interface control reg */
 	u32 ifstat;		/* interface statux reg */
 	u32 macstnaddr1;	/* mac station address part 1 reg */
@@ -381,66 +374,6 @@ struct ucc_geth {
 #define UCCS_MPD                                0x01	/* Magic Packet
 							   Detected */
 
-/* UCC GETH MIIMCFG (MII Management Configuration Register) */
-#define MIIMCFG_RESET_MANAGEMENT                0x80000000	/* Reset
-								   management */
-#define MIIMCFG_NO_PREAMBLE                     0x00000010	/* Preamble
-								   suppress */
-#define MIIMCFG_CLOCK_DIVIDE_SHIFT              (31 - 31)	/* clock divide
-								   << shift */
-#define MIIMCFG_CLOCK_DIVIDE_MAX                0xf	/* clock divide max val
-							 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_2    0x00000000	/* divide by 2 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_4    0x00000001	/* divide by 4 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_6    0x00000002	/* divide by 6 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_8    0x00000003	/* divide by 8 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_10   0x00000004	/* divide by 10
-								 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_14   0x00000005	/* divide by 14
-								 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_16   0x00000008	/* divide by 16
-								 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_20   0x00000006	/* divide by 20
-								 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_28   0x00000007	/* divide by 28
-								 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_32   0x00000009	/* divide by 32
-								 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_48   0x0000000a	/* divide by 48
-								 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_64   0x0000000b	/* divide by 64
-								 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_80   0x0000000c	/* divide by 80
-								 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_112  0x0000000d	/* divide by
-								   112 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_160  0x0000000e	/* divide by
-								   160 */
-#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_224  0x0000000f	/* divide by
-								   224 */
-
-/* UCC GETH MIIMCOM (MII Management Command Register) */
-#define MIIMCOM_SCAN_CYCLE                      0x00000002	/* Scan cycle */
-#define MIIMCOM_READ_CYCLE                      0x00000001	/* Read cycle */
-
-/* UCC GETH MIIMADD (MII Management Address Register) */
-#define MIIMADD_PHY_ADDRESS_SHIFT               (31 - 23)	/* PHY Address
-								   << shift */
-#define MIIMADD_PHY_REGISTER_SHIFT              (31 - 31)	/* PHY Register
-								   << shift */
-
-/* UCC GETH MIIMCON (MII Management Control Register) */
-#define MIIMCON_PHY_CONTROL_SHIFT               (31 - 31)	/* PHY Control
-								   << shift */
-#define MIIMCON_PHY_STATUS_SHIFT                (31 - 31)	/* PHY Status
-								   << shift */
-
-/* UCC GETH MIIMIND (MII Management Indicator Register) */
-#define MIIMIND_NOT_VALID                       0x00000004	/* Not valid */
-#define MIIMIND_SCAN                            0x00000002	/* Scan in
-								   progress */
-#define MIIMIND_BUSY                            0x00000001
-
 /* UCC GETH IFSTAT (Interface Status Register) */
 #define IFSTAT_EXCESS_DEFER                     0x00000200	/* Excessive
 								   transmission
@@ -1009,15 +942,6 @@ struct ucc_geth_hardware_statistics {
 								   register */
 #define UCC_GETH_MACCFG1_INIT                   0
 #define UCC_GETH_MACCFG2_INIT                   (MACCFG2_RESERVED_1)
-#define UCC_GETH_MIIMCFG_MNGMNT_CLC_DIV_INIT    \
-				(MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_112)
-
-/* Ethernet speed */
-enum enet_speed {
-	ENET_SPEED_10BT,	/* 10 Base T */
-	ENET_SPEED_100BT,	/* 100 Base T */
-	ENET_SPEED_1000BT	/* 1000 Base T */
-};
 
 /* Ethernet Address Type. */
 enum enet_addr_type {
@@ -1026,22 +950,6 @@ enum enet_addr_type {
 	ENET_ADDR_TYPE_BROADCAST
 };
 
-/* TBI / MII Set Register */
-enum enet_tbi_mii_reg {
-	ENET_TBI_MII_CR = 0x00,	/* Control (CR ) */
-	ENET_TBI_MII_SR = 0x01,	/* Status (SR ) */
-	ENET_TBI_MII_ANA = 0x04,	/* AN advertisement (ANA ) */
-	ENET_TBI_MII_ANLPBPA = 0x05,	/* AN link partner base page ability
-					   (ANLPBPA) */
-	ENET_TBI_MII_ANEX = 0x06,	/* AN expansion (ANEX ) */
-	ENET_TBI_MII_ANNPT = 0x07,	/* AN next page transmit (ANNPT ) */
-	ENET_TBI_MII_ANLPANP = 0x08,	/* AN link partner ability next page
-					   (ANLPANP) */
-	ENET_TBI_MII_EXST = 0x0F,	/* Extended status (EXST ) */
-	ENET_TBI_MII_JD = 0x10,	/* Jitter diagnostics (JD ) */
-	ENET_TBI_MII_TBICON = 0x11	/* TBI control (TBICON ) */
-};
-
 /* UCC GETH 82xx Ethernet Address Recognition Location */
 enum ucc_geth_enet_address_recognition_location {
 	UCC_GETH_ENET_ADDRESS_RECOGNITION_LOCATION_STATION_ADDRESS,/* station
@@ -1239,8 +1147,7 @@ struct ucc_geth_info {
 	u16 pausePeriod;
 	u16 extensionField;
 	u8 phy_address;
-	u32 board_flags;
-	u32 phy_interrupt;
+	u32 mdio_bus;
 	u8 weightfactor[NUM_TX_QUEUES];
 	u8 interruptcoalescingmaxvalue[NUM_RX_QUEUES];
 	u8 l2qt[UCC_GETH_VLAN_PRIORITY_MAX];
@@ -1249,7 +1156,6 @@ struct ucc_geth_info {
 	u8 iphoffset[TX_IP_OFFSET_ENTRY_MAX];
 	u16 bdRingLenTx[NUM_TX_QUEUES];
 	u16 bdRingLenRx[NUM_RX_QUEUES];
-	enum enet_interface enet_interface;
 	enum ucc_geth_num_of_station_addresses numStationAddresses;
 	enum qe_fltr_largest_external_tbl_lookup_key_size
 	    largestexternallookupkeysize;
@@ -1326,9 +1232,11 @@ struct ucc_geth_private {
 	/* index of the first skb which hasn't been transmitted yet. */
 	u16 skb_dirtytx[NUM_TX_QUEUES];
 
-	struct work_struct tq;
-	struct timer_list phy_info_timer;
 	struct ugeth_mii_info *mii_info;
+	struct phy_device *phydev;
+	phy_interface_t phy_interface;
+	int max_speed;
+	uint32_t msg_enable;
 	int oldspeed;
 	int oldduplex;
 	int oldlink;
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
new file mode 100644
index 0000000..73b5a53
--- /dev/null
+++ b/drivers/net/ucc_geth_mii.c
@@ -0,0 +1,279 @@
+/*
+ * drivers/net/ucc_geth_mii.c
+ *
+ * Gianfar Ethernet Driver -- MIIM bus implementation
+ * Provides Bus interface for MIIM regs
+ *
+ * Author: Li Yang
+ *
+ * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/unistd.h>
+#include <linux/slab.h>
+#include <linux/interrupt.h>
+#include <linux/init.h>
+#include <linux/delay.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/module.h>
+#include <linux/platform_device.h>
+#include <asm/ocp.h>
+#include <linux/crc32.h>
+#include <linux/mii.h>
+#include <linux/phy.h>
+#include <linux/fsl_devices.h>
+
+#include <asm/of_platform.h>
+#include <asm/io.h>
+#include <asm/irq.h>
+#include <asm/uaccess.h>
+#include <asm/ucc.h>
+
+#include "ucc_geth_mii.h"
+#include "ucc_geth.h"
+
+#define DEBUG
+#ifdef DEBUG
+#define vdbg(format, arg...) printk(KERN_DEBUG , format "\n" , ## arg)
+#else
+#define vdbg(format, arg...) do {} while(0)
+#endif
+
+#define DRV_DESC "QE UCC Ethernet Controller MII Bus"
+#define DRV_NAME "fsl-uec_mdio"
+
+/* Write value to the PHY for this device to the register at regnum, */
+/* waiting until the write is done before it returns.  All PHY */
+/* configuration has to be done through the master UEC MIIM regs */
+int uec_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value)
+{
+	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
+
+	/* Setting up the MII Mangement Address Register */
+	out_be32(&regs->miimadd,
+		 (mii_id << MIIMADD_PHY_ADDRESS_SHIFT) | regnum);
+
+	/* Setting up the MII Mangement Control Register with the value */
+	out_be32(&regs->miimcon, value);
+
+	/* Wait till MII management write is complete */
+	while ((in_be32(&regs->miimind)) & MIIMIND_BUSY)
+		cpu_relax();
+
+	return 0;
+}
+
+/* Reads from register regnum in the PHY for device dev, */
+/* returning the value.  Clears miimcom first.  All PHY */
+/* configuration has to be done through the TSEC1 MIIM regs */
+int uec_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
+{
+	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
+	u16 value;
+
+	/* Setting up the MII Mangement Address Register */
+	out_be32(&regs->miimadd,
+		 (mii_id << MIIMADD_PHY_ADDRESS_SHIFT) | regnum);
+
+	/* Clear miimcom, perform an MII management read cycle */
+	out_be32(&regs->miimcom, 0);
+	out_be32(&regs->miimcom, MIIMCOM_READ_CYCLE);
+
+	/* Wait till MII management write is complete */
+	while ((in_be32(&regs->miimind)) & (MIIMIND_BUSY | MIIMIND_NOT_VALID))
+		cpu_relax();
+
+	/* Read MII management status  */
+	value = in_be32(&regs->miimstat);
+
+	return value;
+}
+
+/* Reset the MIIM registers, and wait for the bus to free */
+int uec_mdio_reset(struct mii_bus *bus)
+{
+	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
+	unsigned int timeout = PHY_INIT_TIMEOUT;
+
+	spin_lock_bh(&bus->mdio_lock);
+
+	/* Reset the management interface */
+	out_be32(&regs->miimcfg, MIIMCFG_RESET_MANAGEMENT);
+
+	/* Setup the MII Mgmt clock speed */
+	out_be32(&regs->miimcfg, MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_112);
+
+	/* Wait until the bus is free */
+	while ((in_be32(&regs->miimind) & MIIMIND_BUSY) && timeout--)
+		cpu_relax();
+
+	spin_unlock_bh(&bus->mdio_lock);
+
+	if (timeout <= 0) {
+		printk(KERN_ERR "%s: The MII Bus is stuck!\n", bus->name);
+		return -EBUSY;
+	}
+
+	return 0;
+}
+
+static int uec_mdio_probe(struct of_device *ofdev, const struct of_device_id *match)
+{
+	struct device *device = &ofdev->dev;
+	struct device_node *np = ofdev->node, *tempnp = NULL;
+	struct device_node *child = NULL;
+	struct ucc_mii_mng __iomem *regs;
+	struct mii_bus *new_bus;
+	struct resource res;
+	int k, err = 0;
+
+	new_bus = kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
+
+	if (NULL == new_bus)
+		return -ENOMEM;
+
+	new_bus->name = "UCC Ethernet Controller MII Bus";
+	new_bus->read = &uec_mdio_read;
+	new_bus->write = &uec_mdio_write;
+	new_bus->reset = &uec_mdio_reset;
+
+	memset(&res, 0, sizeof(res));
+
+	err = of_address_to_resource(np, 0, &res);
+	if (err)
+		goto reg_map_fail;
+
+	new_bus->id = res.start;
+
+	new_bus->irq = kmalloc(32 * sizeof(int), GFP_KERNEL);
+
+	if (NULL == new_bus->irq) {
+		err = -ENOMEM;
+		goto reg_map_fail;
+	}
+
+	for (k = 0; k < 32; k++)
+		new_bus->irq[k] = PHY_POLL;
+
+	while ((child = of_get_next_child(np, child)) != NULL) {
+		int irq = irq_of_parse_and_map(child, 0);
+		if (irq != NO_IRQ) {
+			const u32 *id = get_property(child, "reg", NULL);
+			new_bus->irq[*id] = irq;
+		}
+	}
+
+	/* Set the base address */
+	regs = ioremap(res.start, sizeof(struct ucc_mii_mng));
+
+	if (NULL == regs) {
+		err = -ENOMEM;
+		goto ioremap_fail;
+	}
+
+	new_bus->priv = (void __force *)regs;
+
+	new_bus->dev = device;
+	dev_set_drvdata(device, new_bus);
+
+	/* Read MII management master from device tree */
+	while ((tempnp = of_find_compatible_node(tempnp, "network", "ucc_geth"))
+	       != NULL) {
+		struct resource tempres;
+
+		err = of_address_to_resource(tempnp, 0, &tempres);
+		if (err)
+			goto bus_register_fail;
+
+		/* if our mdio regs fall within this UCC regs range */
+		if ((res.start >= tempres.start) &&
+		    (res.end <= tempres.end)) {
+			/* set this UCC to be the MII master */
+			const u32 *id = get_property(tempnp, "device-id", NULL);
+			if (id == NULL)
+				goto bus_register_fail;
+
+			ucc_set_qe_mux_mii_mng(*id - 1);
+
+			/* assign the TBI an address which won't
+			 * conflict with the PHYs */
+			out_be32(&regs->utbipar, UTBIPAR_INIT_TBIPA);
+			break;
+		}
+	}
+
+	err = mdiobus_register(new_bus);
+	if (0 != err) {
+		printk(KERN_ERR "%s: Cannot register as MDIO bus\n",
+		       new_bus->name);
+		goto bus_register_fail;
+	}
+
+	return 0;
+
+bus_register_fail:
+	iounmap(regs);
+ioremap_fail:
+	kfree(new_bus->irq);
+reg_map_fail:
+	kfree(new_bus);
+
+	return err;
+}
+
+int uec_mdio_remove(struct of_device *ofdev)
+{
+	struct device *device = &ofdev->dev;
+	struct mii_bus *bus = dev_get_drvdata(device);
+
+	mdiobus_unregister(bus);
+
+	dev_set_drvdata(device, NULL);
+
+	iounmap((void __iomem *)bus->priv);
+	bus->priv = NULL;
+	kfree(bus);
+
+	return 0;
+}
+
+static struct of_device_id uec_mdio_match[] = {
+	{
+		.type = "mdio",
+		.compatible = "ucc_geth_phy",
+	},
+	{},
+};
+
+MODULE_DEVICE_TABLE(of, uec_mdio_match);
+
+static struct of_platform_driver uec_mdio_driver = {
+	.name	= DRV_NAME,
+	.probe	= uec_mdio_probe,
+	.remove	= uec_mdio_remove,
+	.match_table	= uec_mdio_match,
+};
+
+int __init uec_mdio_init(void)
+{
+	return of_register_platform_driver(&uec_mdio_driver);
+}
+
+void __exit uec_mdio_exit(void)
+{
+	of_unregister_platform_driver(&uec_mdio_driver);
+}
diff --git a/drivers/net/ucc_geth_mii.h b/drivers/net/ucc_geth_mii.h
new file mode 100644
index 0000000..98430fe
--- /dev/null
+++ b/drivers/net/ucc_geth_mii.h
@@ -0,0 +1,100 @@
+/*
+ * drivers/net/ucc_geth_mii.h
+ *
+ * Gianfar Ethernet Driver -- MII Management Bus Implementation
+ * Driver for the MDIO bus controller in the Gianfar register space
+ *
+ * Author: Andy Fleming
+ * Maintainer: Kumar Gala
+ *
+ * Copyright (c) 2002-2004 Freescale Semiconductor, Inc.
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ */
+#ifndef __UEC_MII_H
+#define __UEC_MII_H
+
+/* UCC GETH MIIMCFG (MII Management Configuration Register) */
+#define MIIMCFG_RESET_MANAGEMENT                0x80000000	/* Reset
+								   management */
+#define MIIMCFG_NO_PREAMBLE                     0x00000010	/* Preamble
+								   suppress */
+#define MIIMCFG_CLOCK_DIVIDE_SHIFT              (31 - 31)	/* clock divide
+								   << shift */
+#define MIIMCFG_CLOCK_DIVIDE_MAX                0xf	/* max clock divide */
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_2    0x00000000
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_4    0x00000001
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_6    0x00000002
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_8    0x00000003
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_10   0x00000004
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_14   0x00000005
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_16   0x00000008
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_20   0x00000006
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_28   0x00000007
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_32   0x00000009
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_48   0x0000000a
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_64   0x0000000b
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_80   0x0000000c
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_112  0x0000000d
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_160  0x0000000e
+#define MIIMCFG_MANAGEMENT_CLOCK_DIVIDE_BY_224  0x0000000f
+
+/* UCC GETH MIIMCOM (MII Management Command Register) */
+#define MIIMCOM_SCAN_CYCLE                      0x00000002	/* Scan cycle */
+#define MIIMCOM_READ_CYCLE                      0x00000001	/* Read cycle */
+
+/* UCC GETH MIIMADD (MII Management Address Register) */
+#define MIIMADD_PHY_ADDRESS_SHIFT               (31 - 23)	/* PHY Address
+								   << shift */
+#define MIIMADD_PHY_REGISTER_SHIFT              (31 - 31)	/* PHY Register
+								   << shift */
+
+/* UCC GETH MIIMCON (MII Management Control Register) */
+#define MIIMCON_PHY_CONTROL_SHIFT               (31 - 31)	/* PHY Control
+								   << shift */
+#define MIIMCON_PHY_STATUS_SHIFT                (31 - 31)	/* PHY Status
+								   << shift */
+
+/* UCC GETH MIIMIND (MII Management Indicator Register) */
+#define MIIMIND_NOT_VALID                       0x00000004	/* Not valid */
+#define MIIMIND_SCAN                            0x00000002	/* Scan in
+								   progress */
+#define MIIMIND_BUSY                            0x00000001
+
+/* Initial TBI Physical Address */
+#define UTBIPAR_INIT_TBIPA			0x1f
+
+struct ucc_mii_mng {
+	u32 miimcfg;		/* MII management configuration reg */
+	u32 miimcom;		/* MII management command reg */
+	u32 miimadd;		/* MII management address reg */
+	u32 miimcon;		/* MII management control reg */
+	u32 miimstat;		/* MII management status reg */
+	u32 miimind;		/* MII management indication reg */
+	u8 notcare[28];		/* Space holder */
+	u32 utbipar;		/* TBI phy address reg */
+} __attribute__ ((packed));
+
+/* TBI / MII Set Register */
+enum enet_tbi_mii_reg {
+	ENET_TBI_MII_CR = 0x00,	/* Control */
+	ENET_TBI_MII_SR = 0x01,	/* Status */
+	ENET_TBI_MII_ANA = 0x04,	/* AN advertisement */
+	ENET_TBI_MII_ANLPBPA = 0x05,	/* AN link partner base page ability */
+	ENET_TBI_MII_ANEX = 0x06,	/* AN expansion */
+	ENET_TBI_MII_ANNPT = 0x07,	/* AN next page transmit */
+	ENET_TBI_MII_ANLPANP = 0x08,	/* AN link partner ability next page */
+	ENET_TBI_MII_EXST = 0x0F,	/* Extended status */
+	ENET_TBI_MII_JD = 0x10,	/* Jitter diagnostics */
+	ENET_TBI_MII_TBICON = 0x11	/* TBI control */
+};
+
+int uec_mdio_read(struct mii_bus *bus, int mii_id, int regnum);
+int uec_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
+int __init uec_mdio_init(void);
+void __exit uec_mdio_exit(void);
+#endif				/* __UEC_MII_H */
diff --git a/drivers/net/ucc_geth_phy.c b/drivers/net/ucc_geth_phy.c
deleted file mode 100644
index 9373d89..0000000
--- a/drivers/net/ucc_geth_phy.c
+++ /dev/null
@@ -1,785 +0,0 @@
-/*
- * Copyright (C) Freescale Semicondutor, Inc. 2006. All rights reserved.
- *
- * Author: Shlomi Gridish <gridish@freescale.com>
- *
- * Description:
- * UCC GETH Driver -- PHY handling
- *
- * Changelog:
- * Jun 28, 2006 Li Yang <LeoLi@freescale.com>
- * - Rearrange code and style fixes
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/errno.h>
-#include <linux/slab.h>
-#include <linux/interrupt.h>
-#include <linux/init.h>
-#include <linux/delay.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
-#include <linux/spinlock.h>
-#include <linux/mm.h>
-#include <linux/module.h>
-#include <linux/version.h>
-#include <linux/crc32.h>
-#include <linux/mii.h>
-#include <linux/ethtool.h>
-
-#include <asm/io.h>
-#include <asm/irq.h>
-#include <asm/uaccess.h>
-
-#include "ucc_geth.h"
-#include "ucc_geth_phy.h"
-
-#define ugphy_printk(level, format, arg...)  \
-        printk(level format "\n", ## arg)
-
-#define ugphy_dbg(format, arg...)            \
-        ugphy_printk(KERN_DEBUG, format , ## arg)
-#define ugphy_err(format, arg...)            \
-        ugphy_printk(KERN_ERR, format , ## arg)
-#define ugphy_info(format, arg...)           \
-        ugphy_printk(KERN_INFO, format , ## arg)
-#define ugphy_warn(format, arg...)           \
-        ugphy_printk(KERN_WARNING, format , ## arg)
-
-#ifdef UGETH_VERBOSE_DEBUG
-#define ugphy_vdbg ugphy_dbg
-#else
-#define ugphy_vdbg(fmt, args...) do { } while (0)
-#endif				/* UGETH_VERBOSE_DEBUG */
-
-static void config_genmii_advert(struct ugeth_mii_info *mii_info);
-static void genmii_setup_forced(struct ugeth_mii_info *mii_info);
-static void genmii_restart_aneg(struct ugeth_mii_info *mii_info);
-static int gbit_config_aneg(struct ugeth_mii_info *mii_info);
-static int genmii_config_aneg(struct ugeth_mii_info *mii_info);
-static int genmii_update_link(struct ugeth_mii_info *mii_info);
-static int genmii_read_status(struct ugeth_mii_info *mii_info);
-
-static u16 ucc_geth_phy_read(struct ugeth_mii_info *mii_info, u16 regnum)
-{
-	u16 retval;
-	unsigned long flags;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	spin_lock_irqsave(&mii_info->mdio_lock, flags);
-	retval = mii_info->mdio_read(mii_info->dev, mii_info->mii_id, regnum);
-	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
-
-	return retval;
-}
-
-static void ucc_geth_phy_write(struct ugeth_mii_info *mii_info, u16 regnum, u16 val)
-{
-	unsigned long flags;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	spin_lock_irqsave(&mii_info->mdio_lock, flags);
-	mii_info->mdio_write(mii_info->dev, mii_info->mii_id, regnum, val);
-	spin_unlock_irqrestore(&mii_info->mdio_lock, flags);
-}
-
-/* Write value to the PHY for this device to the register at regnum, */
-/* waiting until the write is done before it returns.  All PHY */
-/* configuration has to be done through the TSEC1 MIIM regs */
-void write_phy_reg(struct net_device *dev, int mii_id, int regnum, int value)
-{
-	struct ucc_geth_private *ugeth = netdev_priv(dev);
-	struct ucc_mii_mng *mii_regs;
-	enum enet_tbi_mii_reg mii_reg = (enum enet_tbi_mii_reg) regnum;
-	u32 tmp_reg;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	spin_lock_irq(&ugeth->lock);
-
-	mii_regs = ugeth->mii_info->mii_regs;
-
-	/* Set this UCC to be the master of the MII managment */
-	ucc_set_qe_mux_mii_mng(ugeth->ug_info->uf_info.ucc_num);
-
-	/* Stop the MII management read cycle */
-	out_be32(&mii_regs->miimcom, 0);
-	/* Setting up the MII Mangement Address Register */
-	tmp_reg = ((u32) mii_id << MIIMADD_PHY_ADDRESS_SHIFT) | mii_reg;
-	out_be32(&mii_regs->miimadd, tmp_reg);
-
-	/* Setting up the MII Mangement Control Register with the value */
-	out_be32(&mii_regs->miimcon, (u32) value);
-
-	/* Wait till MII management write is complete */
-	while ((in_be32(&mii_regs->miimind)) & MIIMIND_BUSY)
-		cpu_relax();
-
-	spin_unlock_irq(&ugeth->lock);
-
-	udelay(10000);
-}
-
-/* Reads from register regnum in the PHY for device dev, */
-/* returning the value.  Clears miimcom first.  All PHY */
-/* configuration has to be done through the TSEC1 MIIM regs */
-int read_phy_reg(struct net_device *dev, int mii_id, int regnum)
-{
-	struct ucc_geth_private *ugeth = netdev_priv(dev);
-	struct ucc_mii_mng *mii_regs;
-	enum enet_tbi_mii_reg mii_reg = (enum enet_tbi_mii_reg) regnum;
-	u32 tmp_reg;
-	u16 value;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	spin_lock_irq(&ugeth->lock);
-
-	mii_regs = ugeth->mii_info->mii_regs;
-
-	/* Setting up the MII Mangement Address Register */
-	tmp_reg = ((u32) mii_id << MIIMADD_PHY_ADDRESS_SHIFT) | mii_reg;
-	out_be32(&mii_regs->miimadd, tmp_reg);
-
-	/* Perform an MII management read cycle */
-	out_be32(&mii_regs->miimcom, MIIMCOM_READ_CYCLE);
-
-	/* Wait till MII management write is complete */
-	while ((in_be32(&mii_regs->miimind)) & MIIMIND_BUSY)
-		cpu_relax();
-
-	udelay(10000);
-
-	/* Read MII management status  */
-	value = (u16) in_be32(&mii_regs->miimstat);
-	out_be32(&mii_regs->miimcom, 0);
-	if (value == 0xffff)
-		ugphy_warn("read wrong value : mii_id %d,mii_reg %d, base %08x",
-			   mii_id, mii_reg, (u32) & (mii_regs->miimcfg));
-
-	spin_unlock_irq(&ugeth->lock);
-
-	return (value);
-}
-
-void mii_clear_phy_interrupt(struct ugeth_mii_info *mii_info)
-{
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	if (mii_info->phyinfo->ack_interrupt)
-		mii_info->phyinfo->ack_interrupt(mii_info);
-}
-
-void mii_configure_phy_interrupt(struct ugeth_mii_info *mii_info,
-				 u32 interrupts)
-{
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	mii_info->interrupts = interrupts;
-	if (mii_info->phyinfo->config_intr)
-		mii_info->phyinfo->config_intr(mii_info);
-}
-
-/* Writes MII_ADVERTISE with the appropriate values, after
- * sanitizing advertise to make sure only supported features
- * are advertised
- */
-static void config_genmii_advert(struct ugeth_mii_info *mii_info)
-{
-	u32 advertise;
-	u16 adv;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	/* Only allow advertising what this PHY supports */
-	mii_info->advertising &= mii_info->phyinfo->features;
-	advertise = mii_info->advertising;
-
-	/* Setup standard advertisement */
-	adv = ucc_geth_phy_read(mii_info, MII_ADVERTISE);
-	adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4);
-	if (advertise & ADVERTISED_10baseT_Half)
-		adv |= ADVERTISE_10HALF;
-	if (advertise & ADVERTISED_10baseT_Full)
-		adv |= ADVERTISE_10FULL;
-	if (advertise & ADVERTISED_100baseT_Half)
-		adv |= ADVERTISE_100HALF;
-	if (advertise & ADVERTISED_100baseT_Full)
-		adv |= ADVERTISE_100FULL;
-	ucc_geth_phy_write(mii_info, MII_ADVERTISE, adv);
-}
-
-static void genmii_setup_forced(struct ugeth_mii_info *mii_info)
-{
-	u16 ctrl;
-	u32 features = mii_info->phyinfo->features;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	ctrl = ucc_geth_phy_read(mii_info, MII_BMCR);
-
-	ctrl &=
-	    ~(BMCR_FULLDPLX | BMCR_SPEED100 | BMCR_SPEED1000 | BMCR_ANENABLE);
-	ctrl |= BMCR_RESET;
-
-	switch (mii_info->speed) {
-	case SPEED_1000:
-		if (features & (SUPPORTED_1000baseT_Half
-				| SUPPORTED_1000baseT_Full)) {
-			ctrl |= BMCR_SPEED1000;
-			break;
-		}
-		mii_info->speed = SPEED_100;
-	case SPEED_100:
-		if (features & (SUPPORTED_100baseT_Half
-				| SUPPORTED_100baseT_Full)) {
-			ctrl |= BMCR_SPEED100;
-			break;
-		}
-		mii_info->speed = SPEED_10;
-	case SPEED_10:
-		if (features & (SUPPORTED_10baseT_Half
-				| SUPPORTED_10baseT_Full))
-			break;
-	default:		/* Unsupported speed! */
-		ugphy_err("%s: Bad speed!", mii_info->dev->name);
-		break;
-	}
-
-	ucc_geth_phy_write(mii_info, MII_BMCR, ctrl);
-}
-
-/* Enable and Restart Autonegotiation */
-static void genmii_restart_aneg(struct ugeth_mii_info *mii_info)
-{
-	u16 ctl;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	ctl = ucc_geth_phy_read(mii_info, MII_BMCR);
-	ctl |= (BMCR_ANENABLE | BMCR_ANRESTART);
-	ucc_geth_phy_write(mii_info, MII_BMCR, ctl);
-}
-
-static int gbit_config_aneg(struct ugeth_mii_info *mii_info)
-{
-	u16 adv;
-	u32 advertise;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	if (mii_info->autoneg) {
-		/* Configure the ADVERTISE register */
-		config_genmii_advert(mii_info);
-		advertise = mii_info->advertising;
-
-		adv = ucc_geth_phy_read(mii_info, MII_1000BASETCONTROL);
-		adv &= ~(MII_1000BASETCONTROL_FULLDUPLEXCAP |
-			 MII_1000BASETCONTROL_HALFDUPLEXCAP);
-		if (advertise & SUPPORTED_1000baseT_Half)
-			adv |= MII_1000BASETCONTROL_HALFDUPLEXCAP;
-		if (advertise & SUPPORTED_1000baseT_Full)
-			adv |= MII_1000BASETCONTROL_FULLDUPLEXCAP;
-		ucc_geth_phy_write(mii_info, MII_1000BASETCONTROL, adv);
-
-		/* Start/Restart aneg */
-		genmii_restart_aneg(mii_info);
-	} else
-		genmii_setup_forced(mii_info);
-
-	return 0;
-}
-
-static int genmii_config_aneg(struct ugeth_mii_info *mii_info)
-{
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	if (mii_info->autoneg) {
-		config_genmii_advert(mii_info);
-		genmii_restart_aneg(mii_info);
-	} else
-		genmii_setup_forced(mii_info);
-
-	return 0;
-}
-
-static int genmii_update_link(struct ugeth_mii_info *mii_info)
-{
-	u16 status;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	/* Do a fake read */
-	ucc_geth_phy_read(mii_info, MII_BMSR);
-
-	/* Read link and autonegotiation status */
-	status = ucc_geth_phy_read(mii_info, MII_BMSR);
-	if ((status & BMSR_LSTATUS) == 0)
-		mii_info->link = 0;
-	else
-		mii_info->link = 1;
-
-	/* If we are autonegotiating, and not done,
-	 * return an error */
-	if (mii_info->autoneg && !(status & BMSR_ANEGCOMPLETE))
-		return -EAGAIN;
-
-	return 0;
-}
-
-static int genmii_read_status(struct ugeth_mii_info *mii_info)
-{
-	u16 status;
-	int err;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	/* Update the link, but return if there
-	 * was an error */
-	err = genmii_update_link(mii_info);
-	if (err)
-		return err;
-
-	if (mii_info->autoneg) {
-		status = ucc_geth_phy_read(mii_info, MII_LPA);
-
-		if (status & (LPA_10FULL | LPA_100FULL))
-			mii_info->duplex = DUPLEX_FULL;
-		else
-			mii_info->duplex = DUPLEX_HALF;
-		if (status & (LPA_100FULL | LPA_100HALF))
-			mii_info->speed = SPEED_100;
-		else
-			mii_info->speed = SPEED_10;
-		mii_info->pause = 0;
-	}
-	/* On non-aneg, we assume what we put in BMCR is the speed,
-	 * though magic-aneg shouldn't prevent this case from occurring
-	 */
-
-	return 0;
-}
-
-static int marvell_init(struct ugeth_mii_info *mii_info)
-{
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	ucc_geth_phy_write(mii_info, 0x14, 0x0cd2);
-	ucc_geth_phy_write(mii_info, 0x1b,
-		(ucc_geth_phy_read(mii_info, 0x1b) & ~0x000f) | 0x000b);
-	ucc_geth_phy_write(mii_info, MII_BMCR,
-		  ucc_geth_phy_read(mii_info, MII_BMCR) | BMCR_RESET);
-	msleep(4000);
-
-	return 0;
-}
-
-static int marvell_config_aneg(struct ugeth_mii_info *mii_info)
-{
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	/* The Marvell PHY has an errata which requires
-	 * that certain registers get written in order
-	 * to restart autonegotiation */
-	ucc_geth_phy_write(mii_info, MII_BMCR, BMCR_RESET);
-
-	ucc_geth_phy_write(mii_info, 0x1d, 0x1f);
-	ucc_geth_phy_write(mii_info, 0x1e, 0x200c);
-	ucc_geth_phy_write(mii_info, 0x1d, 0x5);
-	ucc_geth_phy_write(mii_info, 0x1e, 0);
-	ucc_geth_phy_write(mii_info, 0x1e, 0x100);
-
-	gbit_config_aneg(mii_info);
-
-	return 0;
-}
-
-static int marvell_read_status(struct ugeth_mii_info *mii_info)
-{
-	u16 status;
-	int err;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	/* Update the link, but return if there
-	 * was an error */
-	err = genmii_update_link(mii_info);
-	if (err)
-		return err;
-
-	/* If the link is up, read the speed and duplex */
-	/* If we aren't autonegotiating, assume speeds
-	 * are as set */
-	if (mii_info->autoneg && mii_info->link) {
-		int speed;
-		status = ucc_geth_phy_read(mii_info, MII_M1011_PHY_SPEC_STATUS);
-
-		/* Get the duplexity */
-		if (status & MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX)
-			mii_info->duplex = DUPLEX_FULL;
-		else
-			mii_info->duplex = DUPLEX_HALF;
-
-		/* Get the speed */
-		speed = status & MII_M1011_PHY_SPEC_STATUS_SPD_MASK;
-		switch (speed) {
-		case MII_M1011_PHY_SPEC_STATUS_1000:
-			mii_info->speed = SPEED_1000;
-			break;
-		case MII_M1011_PHY_SPEC_STATUS_100:
-			mii_info->speed = SPEED_100;
-			break;
-		default:
-			mii_info->speed = SPEED_10;
-			break;
-		}
-		mii_info->pause = 0;
-	}
-
-	return 0;
-}
-
-static int marvell_ack_interrupt(struct ugeth_mii_info *mii_info)
-{
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	/* Clear the interrupts by reading the reg */
-	ucc_geth_phy_read(mii_info, MII_M1011_IEVENT);
-
-	return 0;
-}
-
-static int marvell_config_intr(struct ugeth_mii_info *mii_info)
-{
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	if (mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		ucc_geth_phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_INIT);
-	else
-		ucc_geth_phy_write(mii_info, MII_M1011_IMASK, MII_M1011_IMASK_CLEAR);
-
-	return 0;
-}
-
-static int cis820x_init(struct ugeth_mii_info *mii_info)
-{
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	ucc_geth_phy_write(mii_info, MII_CIS8201_AUX_CONSTAT,
-		  MII_CIS8201_AUXCONSTAT_INIT);
-	ucc_geth_phy_write(mii_info, MII_CIS8201_EXT_CON1, MII_CIS8201_EXTCON1_INIT);
-
-	return 0;
-}
-
-static int cis820x_read_status(struct ugeth_mii_info *mii_info)
-{
-	u16 status;
-	int err;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	/* Update the link, but return if there
-	 * was an error */
-	err = genmii_update_link(mii_info);
-	if (err)
-		return err;
-
-	/* If the link is up, read the speed and duplex */
-	/* If we aren't autonegotiating, assume speeds
-	 * are as set */
-	if (mii_info->autoneg && mii_info->link) {
-		int speed;
-
-		status = ucc_geth_phy_read(mii_info, MII_CIS8201_AUX_CONSTAT);
-		if (status & MII_CIS8201_AUXCONSTAT_DUPLEX)
-			mii_info->duplex = DUPLEX_FULL;
-		else
-			mii_info->duplex = DUPLEX_HALF;
-
-		speed = status & MII_CIS8201_AUXCONSTAT_SPEED;
-
-		switch (speed) {
-		case MII_CIS8201_AUXCONSTAT_GBIT:
-			mii_info->speed = SPEED_1000;
-			break;
-		case MII_CIS8201_AUXCONSTAT_100:
-			mii_info->speed = SPEED_100;
-			break;
-		default:
-			mii_info->speed = SPEED_10;
-			break;
-		}
-	}
-
-	return 0;
-}
-
-static int cis820x_ack_interrupt(struct ugeth_mii_info *mii_info)
-{
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	ucc_geth_phy_read(mii_info, MII_CIS8201_ISTAT);
-
-	return 0;
-}
-
-static int cis820x_config_intr(struct ugeth_mii_info *mii_info)
-{
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	if (mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		ucc_geth_phy_write(mii_info, MII_CIS8201_IMASK, MII_CIS8201_IMASK_MASK);
-	else
-		ucc_geth_phy_write(mii_info, MII_CIS8201_IMASK, 0);
-
-	return 0;
-}
-
-#define DM9161_DELAY 10
-
-static int dm9161_read_status(struct ugeth_mii_info *mii_info)
-{
-	u16 status;
-	int err;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	/* Update the link, but return if there
-	 * was an error */
-	err = genmii_update_link(mii_info);
-	if (err)
-		return err;
-
-	/* If the link is up, read the speed and duplex */
-	/* If we aren't autonegotiating, assume speeds
-	 * are as set */
-	if (mii_info->autoneg && mii_info->link) {
-		status = ucc_geth_phy_read(mii_info, MII_DM9161_SCSR);
-		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_100H))
-			mii_info->speed = SPEED_100;
-		else
-			mii_info->speed = SPEED_10;
-
-		if (status & (MII_DM9161_SCSR_100F | MII_DM9161_SCSR_10F))
-			mii_info->duplex = DUPLEX_FULL;
-		else
-			mii_info->duplex = DUPLEX_HALF;
-	}
-
-	return 0;
-}
-
-static int dm9161_config_aneg(struct ugeth_mii_info *mii_info)
-{
-	struct dm9161_private *priv = mii_info->priv;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	if (0 == priv->resetdone)
-		return -EAGAIN;
-
-	return 0;
-}
-
-static void dm9161_timer(unsigned long data)
-{
-	struct ugeth_mii_info *mii_info = (struct ugeth_mii_info *)data;
-	struct dm9161_private *priv = mii_info->priv;
-	u16 status = ucc_geth_phy_read(mii_info, MII_BMSR);
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	if (status & BMSR_ANEGCOMPLETE) {
-		priv->resetdone = 1;
-	} else
-		mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
-}
-
-static int dm9161_init(struct ugeth_mii_info *mii_info)
-{
-	struct dm9161_private *priv;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	/* Allocate the private data structure */
-	priv = kmalloc(sizeof(struct dm9161_private), GFP_KERNEL);
-
-	if (NULL == priv)
-		return -ENOMEM;
-
-	mii_info->priv = priv;
-
-	/* Reset is not done yet */
-	priv->resetdone = 0;
-
-	ucc_geth_phy_write(mii_info, MII_BMCR,
-		  ucc_geth_phy_read(mii_info, MII_BMCR) | BMCR_RESET);
-
-	ucc_geth_phy_write(mii_info, MII_BMCR,
-		  ucc_geth_phy_read(mii_info, MII_BMCR) & ~BMCR_ISOLATE);
-
-	config_genmii_advert(mii_info);
-	/* Start/Restart aneg */
-	genmii_config_aneg(mii_info);
-
-	/* Start a timer for DM9161_DELAY seconds to wait
-	 * for the PHY to be ready */
-	init_timer(&priv->timer);
-	priv->timer.function = &dm9161_timer;
-	priv->timer.data = (unsigned long)mii_info;
-	mod_timer(&priv->timer, jiffies + DM9161_DELAY * HZ);
-
-	return 0;
-}
-
-static void dm9161_close(struct ugeth_mii_info *mii_info)
-{
-	struct dm9161_private *priv = mii_info->priv;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	del_timer_sync(&priv->timer);
-	kfree(priv);
-}
-
-static int dm9161_ack_interrupt(struct ugeth_mii_info *mii_info)
-{
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	/* Clear the interrupts by reading the reg */
-	ucc_geth_phy_read(mii_info, MII_DM9161_INTR);
-
-
-	return 0;
-}
-
-static int dm9161_config_intr(struct ugeth_mii_info *mii_info)
-{
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	if (mii_info->interrupts == MII_INTERRUPT_ENABLED)
-		ucc_geth_phy_write(mii_info, MII_DM9161_INTR, MII_DM9161_INTR_INIT);
-	else
-		ucc_geth_phy_write(mii_info, MII_DM9161_INTR, MII_DM9161_INTR_STOP);
-
-	return 0;
-}
-
-/* Cicada 820x */
-static struct phy_info phy_info_cis820x = {
-	.phy_id = 0x000fc440,
-	.name = "Cicada Cis8204",
-	.phy_id_mask = 0x000fffc0,
-	.features = MII_GBIT_FEATURES,
-	.init = &cis820x_init,
-	.config_aneg = &gbit_config_aneg,
-	.read_status = &cis820x_read_status,
-	.ack_interrupt = &cis820x_ack_interrupt,
-	.config_intr = &cis820x_config_intr,
-};
-
-static struct phy_info phy_info_dm9161 = {
-	.phy_id = 0x0181b880,
-	.phy_id_mask = 0x0ffffff0,
-	.name = "Davicom DM9161E",
-	.init = dm9161_init,
-	.config_aneg = dm9161_config_aneg,
-	.read_status = dm9161_read_status,
-	.close = dm9161_close,
-};
-
-static struct phy_info phy_info_dm9161a = {
-	.phy_id = 0x0181b8a0,
-	.phy_id_mask = 0x0ffffff0,
-	.name = "Davicom DM9161A",
-	.features = MII_BASIC_FEATURES,
-	.init = dm9161_init,
-	.config_aneg = dm9161_config_aneg,
-	.read_status = dm9161_read_status,
-	.ack_interrupt = dm9161_ack_interrupt,
-	.config_intr = dm9161_config_intr,
-	.close = dm9161_close,
-};
-
-static struct phy_info phy_info_marvell = {
-	.phy_id = 0x01410c00,
-	.phy_id_mask = 0xffffff00,
-	.name = "Marvell 88E11x1",
-	.features = MII_GBIT_FEATURES,
-	.init = &marvell_init,
-	.config_aneg = &marvell_config_aneg,
-	.read_status = &marvell_read_status,
-	.ack_interrupt = &marvell_ack_interrupt,
-	.config_intr = &marvell_config_intr,
-};
-
-static struct phy_info phy_info_genmii = {
-	.phy_id = 0x00000000,
-	.phy_id_mask = 0x00000000,
-	.name = "Generic MII",
-	.features = MII_BASIC_FEATURES,
-	.config_aneg = genmii_config_aneg,
-	.read_status = genmii_read_status,
-};
-
-static struct phy_info *phy_info[] = {
-	&phy_info_cis820x,
-	&phy_info_marvell,
-	&phy_info_dm9161,
-	&phy_info_dm9161a,
-	&phy_info_genmii,
-	NULL
-};
-
-/* Use the PHY ID registers to determine what type of PHY is attached
- * to device dev.  return a struct phy_info structure describing that PHY
- */
-struct phy_info *get_phy_info(struct ugeth_mii_info *mii_info)
-{
-	u16 phy_reg;
-	u32 phy_ID;
-	int i;
-	struct phy_info *theInfo = NULL;
-	struct net_device *dev = mii_info->dev;
-
-	ugphy_vdbg("%s: IN", __FUNCTION__);
-
-	/* Grab the bits from PHYIR1, and put them in the upper half */
-	phy_reg = ucc_geth_phy_read(mii_info, MII_PHYSID1);
-	phy_ID = (phy_reg & 0xffff) << 16;
-
-	/* Grab the bits from PHYIR2, and put them in the lower half */
-	phy_reg = ucc_geth_phy_read(mii_info, MII_PHYSID2);
-	phy_ID |= (phy_reg & 0xffff);
-
-	/* loop through all the known PHY types, and find one that */
-	/* matches the ID we read from the PHY. */
-	for (i = 0; phy_info[i]; i++)
-		if (phy_info[i]->phy_id == (phy_ID & phy_info[i]->phy_id_mask)){
-			theInfo = phy_info[i];
-			break;
-		}
-
-	/* This shouldn't happen, as we have generic PHY support */
-	if (theInfo == NULL) {
-		ugphy_info("%s: PHY id %x is not supported!", dev->name,
-			   phy_ID);
-		return NULL;
-	} else {
-		ugphy_info("%s: PHY is %s (%x)", dev->name, theInfo->name,
-			   phy_ID);
-	}
-
-	return theInfo;
-}
diff --git a/drivers/net/ucc_geth_phy.h b/drivers/net/ucc_geth_phy.h
deleted file mode 100644
index f574078..0000000
--- a/drivers/net/ucc_geth_phy.h
+++ /dev/null
@@ -1,217 +0,0 @@
-/*
- * Copyright (C) Freescale Semicondutor, Inc. 2006. All rights reserved.
- *
- * Author: Shlomi Gridish <gridish@freescale.com>
- *
- * Description:
- * UCC GETH Driver -- PHY handling
- *
- * Changelog:
- * Jun 28, 2006 Li Yang <LeoLi@freescale.com>
- * - Rearrange code and style fixes
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#ifndef __UCC_GETH_PHY_H__
-#define __UCC_GETH_PHY_H__
-
-#define MII_end ((u32)-2)
-#define MII_read ((u32)-1)
-
-#define MIIMIND_BUSY            0x00000001
-#define MIIMIND_NOTVALID        0x00000004
-
-#define UGETH_AN_TIMEOUT        2000
-
-/* 1000BT control (Marvell & BCM54xx at least) */
-#define MII_1000BASETCONTROL                  0x09
-#define MII_1000BASETCONTROL_FULLDUPLEXCAP    0x0200
-#define MII_1000BASETCONTROL_HALFDUPLEXCAP    0x0100
-
-/* Cicada Extended Control Register 1 */
-#define MII_CIS8201_EXT_CON1        0x17
-#define MII_CIS8201_EXTCON1_INIT    0x0000
-
-/* Cicada Interrupt Mask Register */
-#define MII_CIS8201_IMASK           0x19
-#define MII_CIS8201_IMASK_IEN       0x8000
-#define MII_CIS8201_IMASK_SPEED     0x4000
-#define MII_CIS8201_IMASK_LINK      0x2000
-#define MII_CIS8201_IMASK_DUPLEX    0x1000
-#define MII_CIS8201_IMASK_MASK      0xf000
-
-/* Cicada Interrupt Status Register */
-#define MII_CIS8201_ISTAT           0x1a
-#define MII_CIS8201_ISTAT_STATUS    0x8000
-#define MII_CIS8201_ISTAT_SPEED     0x4000
-#define MII_CIS8201_ISTAT_LINK      0x2000
-#define MII_CIS8201_ISTAT_DUPLEX    0x1000
-
-/* Cicada Auxiliary Control/Status Register */
-#define MII_CIS8201_AUX_CONSTAT        0x1c
-#define MII_CIS8201_AUXCONSTAT_INIT    0x0004
-#define MII_CIS8201_AUXCONSTAT_DUPLEX  0x0020
-#define MII_CIS8201_AUXCONSTAT_SPEED   0x0018
-#define MII_CIS8201_AUXCONSTAT_GBIT    0x0010
-#define MII_CIS8201_AUXCONSTAT_100     0x0008
-
-/* 88E1011 PHY Status Register */
-#define MII_M1011_PHY_SPEC_STATUS               0x11
-#define MII_M1011_PHY_SPEC_STATUS_1000          0x8000
-#define MII_M1011_PHY_SPEC_STATUS_100           0x4000
-#define MII_M1011_PHY_SPEC_STATUS_SPD_MASK      0xc000
-#define MII_M1011_PHY_SPEC_STATUS_FULLDUPLEX    0x2000
-#define MII_M1011_PHY_SPEC_STATUS_RESOLVED      0x0800
-#define MII_M1011_PHY_SPEC_STATUS_LINK          0x0400
-
-#define MII_M1011_IEVENT                0x13
-#define MII_M1011_IEVENT_CLEAR          0x0000
-
-#define MII_M1011_IMASK                 0x12
-#define MII_M1011_IMASK_INIT            0x6400
-#define MII_M1011_IMASK_CLEAR           0x0000
-
-#define MII_DM9161_SCR                  0x10
-#define MII_DM9161_SCR_INIT             0x0610
-
-/* DM9161 Specified Configuration and Status Register */
-#define MII_DM9161_SCSR                 0x11
-#define MII_DM9161_SCSR_100F            0x8000
-#define MII_DM9161_SCSR_100H            0x4000
-#define MII_DM9161_SCSR_10F             0x2000
-#define MII_DM9161_SCSR_10H             0x1000
-
-/* DM9161 Interrupt Register */
-#define MII_DM9161_INTR                 0x15
-#define MII_DM9161_INTR_PEND            0x8000
-#define MII_DM9161_INTR_DPLX_MASK       0x0800
-#define MII_DM9161_INTR_SPD_MASK        0x0400
-#define MII_DM9161_INTR_LINK_MASK       0x0200
-#define MII_DM9161_INTR_MASK            0x0100
-#define MII_DM9161_INTR_DPLX_CHANGE     0x0010
-#define MII_DM9161_INTR_SPD_CHANGE      0x0008
-#define MII_DM9161_INTR_LINK_CHANGE     0x0004
-#define MII_DM9161_INTR_INIT            0x0000
-#define MII_DM9161_INTR_STOP    \
-(MII_DM9161_INTR_DPLX_MASK | MII_DM9161_INTR_SPD_MASK \
- | MII_DM9161_INTR_LINK_MASK | MII_DM9161_INTR_MASK)
-
-/* DM9161 10BT Configuration/Status */
-#define MII_DM9161_10BTCSR              0x12
-#define MII_DM9161_10BTCSR_INIT         0x7800
-
-#define MII_BASIC_FEATURES    (SUPPORTED_10baseT_Half | \
-                 SUPPORTED_10baseT_Full | \
-                 SUPPORTED_100baseT_Half | \
-                 SUPPORTED_100baseT_Full | \
-                 SUPPORTED_Autoneg | \
-                 SUPPORTED_TP | \
-                 SUPPORTED_MII)
-
-#define MII_GBIT_FEATURES    (MII_BASIC_FEATURES | \
-                 SUPPORTED_1000baseT_Half | \
-                 SUPPORTED_1000baseT_Full)
-
-#define MII_READ_COMMAND                0x00000001
-
-#define MII_INTERRUPT_DISABLED          0x0
-#define MII_INTERRUPT_ENABLED           0x1
-/* Taken from mii_if_info and sungem_phy.h */
-struct ugeth_mii_info {
-	/* Information about the PHY type */
-	/* And management functions */
-	struct phy_info *phyinfo;
-
-	struct ucc_mii_mng *mii_regs;
-
-	/* forced speed & duplex (no autoneg)
-	 * partner speed & duplex & pause (autoneg)
-	 */
-	int speed;
-	int duplex;
-	int pause;
-
-	/* The most recently read link state */
-	int link;
-
-	/* Enabled Interrupts */
-	u32 interrupts;
-
-	u32 advertising;
-	int autoneg;
-	int mii_id;
-
-	/* private data pointer */
-	/* For use by PHYs to maintain extra state */
-	void *priv;
-
-	/* Provided by host chip */
-	struct net_device *dev;
-
-	/* A lock to ensure that only one thing can read/write
-	 * the MDIO bus at a time */
-	spinlock_t mdio_lock;
-
-	/* Provided by ethernet driver */
-	int (*mdio_read) (struct net_device * dev, int mii_id, int reg);
-	void (*mdio_write) (struct net_device * dev, int mii_id, int reg,
-			    int val);
-};
-
-/* struct phy_info: a structure which defines attributes for a PHY
- *
- * id will contain a number which represents the PHY.  During
- * startup, the driver will poll the PHY to find out what its
- * UID--as defined by registers 2 and 3--is.  The 32-bit result
- * gotten from the PHY will be ANDed with phy_id_mask to
- * discard any bits which may change based on revision numbers
- * unimportant to functionality
- *
- * There are 6 commands which take a ugeth_mii_info structure.
- * Each PHY must declare config_aneg, and read_status.
- */
-struct phy_info {
-	u32 phy_id;
-	char *name;
-	unsigned int phy_id_mask;
-	u32 features;
-
-	/* Called to initialize the PHY */
-	int (*init) (struct ugeth_mii_info * mii_info);
-
-	/* Called to suspend the PHY for power */
-	int (*suspend) (struct ugeth_mii_info * mii_info);
-
-	/* Reconfigures autonegotiation (or disables it) */
-	int (*config_aneg) (struct ugeth_mii_info * mii_info);
-
-	/* Determines the negotiated speed and duplex */
-	int (*read_status) (struct ugeth_mii_info * mii_info);
-
-	/* Clears any pending interrupts */
-	int (*ack_interrupt) (struct ugeth_mii_info * mii_info);
-
-	/* Enables or disables interrupts */
-	int (*config_intr) (struct ugeth_mii_info * mii_info);
-
-	/* Clears up any memory if needed */
-	void (*close) (struct ugeth_mii_info * mii_info);
-};
-
-struct phy_info *get_phy_info(struct ugeth_mii_info *mii_info);
-void write_phy_reg(struct net_device *dev, int mii_id, int regnum, int value);
-int read_phy_reg(struct net_device *dev, int mii_id, int regnum);
-void mii_clear_phy_interrupt(struct ugeth_mii_info *mii_info);
-void mii_configure_phy_interrupt(struct ugeth_mii_info *mii_info,
-				 u32 interrupts);
-
-struct dm9161_private {
-	struct timer_list timer;
-	int resetdone;
-};
-
-#endif				/* __UCC_GETH_PHY_H__ */
diff --git a/include/linux/fsl_devices.h b/include/linux/fsl_devices.h
index abb64c4..73710d6 100644
--- a/include/linux/fsl_devices.h
+++ b/include/linux/fsl_devices.h
@@ -120,44 +120,5 @@ struct fsl_spi_platform_data {
 	u32	sysclk;
 };
 
-/* Ethernet interface (phy management and speed)
-*/
-enum enet_interface {
-	ENET_10_MII,		/* 10 Base T,   MII interface */
-	ENET_10_RMII,		/* 10 Base T,  RMII interface */
-	ENET_10_RGMII,		/* 10 Base T, RGMII interface */
-	ENET_100_MII,		/* 100 Base T,   MII interface */
-	ENET_100_RMII,		/* 100 Base T,  RMII interface */
-	ENET_100_RGMII,		/* 100 Base T, RGMII interface */
-	ENET_1000_GMII,		/* 1000 Base T,  GMII interface */
-	ENET_1000_RGMII,	/* 1000 Base T, RGMII interface */
-	ENET_1000_TBI,		/* 1000 Base T,   TBI interface */
-	ENET_1000_RTBI		/* 1000 Base T,  RTBI interface */
-};
-
-struct ucc_geth_platform_data {
-	/* device specific information */
-	u32			device_flags;
-	u32			phy_reg_addr;
-
-	/* board specific information */
-	u32			board_flags;
-	u8			rx_clock;
-	u8			tx_clock;
-	u32			phy_id;
-	enum enet_interface	phy_interface;
-	u32			phy_interrupt;
-	u8			mac_addr[6];
-};
-
-/* Flags related to UCC Gigabit Ethernet device features */
-#define FSL_UGETH_DEV_HAS_GIGABIT		0x00000001
-#define FSL_UGETH_DEV_HAS_COALESCE		0x00000002
-#define FSL_UGETH_DEV_HAS_RMON			0x00000004
-
-/* Flags in ucc_geth_platform_data */
-#define FSL_UGETH_BRD_HAS_PHY_INTR		0x00000001
-				/* if not set use a timer */
-
 #endif /* _FSL_DEVICE_H_ */
 #endif /* __KERNEL__ */
-- 
1.5.0.1

