From: akpm@linux-foundation.org
Subject: [patch 4/4] e100: add non-MII PHY support
Date: Wed, 10 Jun 2009 12:55:04 -0700
Message-ID: <200906101955.n5AJt4pV008252@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andim2@users.sourceforge.net, andi@lisas.de,
	bruce.w.allan@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	peter.p.waskiewicz.jr@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54323 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761062AbZFJTzK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:55:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Mohr <andim2@users.sourceforge.net>

Restore support for cards with MII-lacking PHYs as compared to removed
pre-2.6.29 eepro100 driver: use full low-level MII I/O access abstraction
by providing clean PHY-specific mdio_ctrl() functions for either standard
MII-compliant cards, slightly special ones or non-MII PHY ones.

We now have another netdev_priv member for mdio_ctrl(), thus we have some
array indirection, but we save some additional opcodes for specific
phy_82552_v handling in the common case.

[akpm@linux-foundation.org: cleanups]
Signed-off-by: Andreas Mohr <andi@lisas.de>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Cc: John Ronciak <john.ronciak@intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/e100.c |  188 +++++++++++++++++++++++++++++++++++++------
 1 file changed, 162 insertions(+), 26 deletions(-)

diff -puN drivers/net/e100.c~e100-add-non-mii-phy-support drivers/net/e100.c
--- a/drivers/net/e100.c~e100-add-non-mii-phy-support
+++ a/drivers/net/e100.c
@@ -143,6 +143,8 @@
  *	FIXES:
  * 2005/12/02 - Michael O'Donnell <Michael.ODonnell at stratus dot com>
  *	- Stratus87247: protect MDI control register manipulations
+ * 2009/06/01 - Andreas Mohr <andi at lisas dot de>
+ *      - add clean lowlevel I/O emulation for cards with MII-lacking PHYs
  */
 
 #include <linux/module.h>
@@ -372,6 +374,7 @@ enum eeprom_op {
 
 enum eeprom_offsets {
 	eeprom_cnfg_mdix  = 0x03,
+	eeprom_phy_iface  = 0x06,
 	eeprom_id         = 0x0A,
 	eeprom_config_asf = 0x0D,
 	eeprom_smbus_addr = 0x90,
@@ -381,6 +384,18 @@ enum eeprom_cnfg_mdix {
 	eeprom_mdix_enabled = 0x0080,
 };
 
+enum eeprom_phy_iface {
+	NoSuchPhy = 0,
+	I82553AB,
+	I82553C,
+	I82503,
+	DP83840,
+	S80C240,
+	S80C24,
+	I82555,
+	DP83840A = 10,
+};
+
 enum eeprom_id {
 	eeprom_id_wol = 0x0020,
 };
@@ -545,6 +560,7 @@ struct nic {
 	u32 msg_enable				____cacheline_aligned;
 	struct net_device *netdev;
 	struct pci_dev *pdev;
+	u16 (*mdio_ctrl)(struct nic *nic, u32 addr, u32 dir, u32 reg, u16 data);
 
 	struct rx *rxs				____cacheline_aligned;
 	struct rx *rx_to_use;
@@ -899,7 +915,21 @@ err_unlock:
 	return err;
 }
 
-static u16 mdio_ctrl(struct nic *nic, u32 addr, u32 dir, u32 reg, u16 data)
+static int mdio_read(struct net_device *netdev, int addr, int reg)
+{
+	struct nic *nic = netdev_priv(netdev);
+	return nic->mdio_ctrl(nic, addr, mdi_read, reg, 0);
+}
+
+static void mdio_write(struct net_device *netdev, int addr, int reg, int data)
+{
+	struct nic *nic = netdev_priv(netdev);
+
+	nic->mdio_ctrl(nic, addr, mdi_write, reg, data);
+}
+
+/* the standard mdio_ctrl() function for usual MII-compliant hardware */
+static u16 mdio_ctrl_hw(struct nic *nic, u32 addr, u32 dir, u32 reg, u16 data)
 {
 	u32 data_out = 0;
 	unsigned int i;
@@ -938,30 +968,83 @@ static u16 mdio_ctrl(struct nic *nic, u3
 	return (u16)data_out;
 }
 
-static int mdio_read(struct net_device *netdev, int addr, int reg)
-{
-	return mdio_ctrl(netdev_priv(netdev), addr, mdi_read, reg, 0);
+/* slightly tweaked mdio_ctrl() function for phy_82552_v specifics */
+static u16 mdio_ctrl_phy_82552_v(struct nic *nic,
+				 u32 addr,
+				 u32 dir,
+				 u32 reg,
+				 u16 data)
+{
+	if ((reg == MII_BMCR) && (dir == mdi_write)) {
+		if (data & (BMCR_ANRESTART | BMCR_ANENABLE)) {
+			u16 advert = mdio_read(nic->netdev, nic->mii.phy_id,
+							MII_ADVERTISE);
+
+			/*
+			 * Workaround Si issue where sometimes the part will not
+			 * autoneg to 100Mbps even when advertised.
+			 */
+			if (advert & ADVERTISE_100FULL)
+				data |= BMCR_SPEED100 | BMCR_FULLDPLX;
+			else if (advert & ADVERTISE_100HALF)
+				data |= BMCR_SPEED100;
+		}
+	}
+	return mdio_ctrl_hw(nic, addr, dir, reg, data);
 }
 
-static void mdio_write(struct net_device *netdev, int addr, int reg, int data)
-{
-	struct nic *nic = netdev_priv(netdev);
-
-	if  ((nic->phy == phy_82552_v) && (reg == MII_BMCR) &&
-	     (data & (BMCR_ANRESTART | BMCR_ANENABLE))) {
-		u16 advert = mdio_read(netdev, nic->mii.phy_id, MII_ADVERTISE);
-
-		/*
-		 * Workaround Si issue where sometimes the part will not
-		 * autoneg to 100Mbps even when advertised.
-		 */
-		if (advert & ADVERTISE_100FULL)
-			data |= BMCR_SPEED100 | BMCR_FULLDPLX;
-		else if (advert & ADVERTISE_100HALF)
-			data |= BMCR_SPEED100;
+/* Fully software-emulated mdio_ctrl() function for cards without
+ * MII-compliant PHYs.
+ * For now, this is mainly geared towards 80c24 support; in case of further
+ * requirements for other types (i82503, ...?) either extend this mechanism
+ * or split it, whichever is cleaner.
+ */
+static u16 mdio_ctrl_phy_mii_emulated(struct nic *nic,
+				      u32 addr,
+				      u32 dir,
+				      u32 reg,
+				      u16 data)
+{
+	/* might need to allocate a netdev_priv'ed register array eventually
+	 * to be able to record state changes, but for now
+	 * some fully hardcoded register handling ought to be ok I guess. */
+
+	if (dir == mdi_read) {
+		switch (reg) {
+		case MII_BMCR:
+			/* Auto-negotiation, right? */
+			return  BMCR_ANENABLE |
+				BMCR_FULLDPLX;
+		case MII_BMSR:
+			return	BMSR_LSTATUS /* for mii_link_ok() */ |
+				BMSR_ANEGCAPABLE |
+				BMSR_10FULL;
+		case MII_ADVERTISE:
+			/* 80c24 is a "combo card" PHY, right? */
+			return	ADVERTISE_10HALF |
+				ADVERTISE_10FULL;
+		default:
+			DPRINTK(HW, DEBUG,
+		"%s:addr=%d, reg=%d, data=0x%04X: unimplemented emulation!\n",
+		dir == mdi_read ? "READ" : "WRITE", addr, reg, data);
+			return 0xFFFF;
+		}
+	} else {
+		switch (reg) {
+		default:
+			DPRINTK(HW, DEBUG,
+		"%s:addr=%d, reg=%d, data=0x%04X: unimplemented emulation!\n",
+		dir == mdi_read ? "READ" : "WRITE", addr, reg, data);
+			return 0xFFFF;
+		}
 	}
-
-	mdio_ctrl(netdev_priv(netdev), addr, mdi_write, reg, data);
+}
+static inline int e100_phy_supports_mii(struct nic *nic)
+{
+	/* for now, just check it by comparing whether we
+	   are using MII software emulation.
+	*/
+	return (nic->mdio_ctrl != mdio_ctrl_phy_mii_emulated);
 }
 
 static void e100_get_defaults(struct nic *nic)
@@ -1013,7 +1096,8 @@ static void e100_configure(struct nic *n
 	config->standard_stat_counter = 0x1;	/* 1=standard, 0=extended */
 	config->rx_discard_short_frames = 0x1;	/* 1=discard, 0=pass */
 	config->tx_underrun_retry = 0x3;	/* # of underrun retries */
-	config->mii_mode = 0x1;			/* 1=MII mode, 0=503 mode */
+	if (e100_phy_supports_mii(nic))
+		config->mii_mode = 1;           /* 1=MII mode, 0=i82503 mode */
 	config->pad10 = 0x6;
 	config->no_source_addr_insertion = 0x1;	/* 1=no, 0=yes */
 	config->preamble_length = 0x2;		/* 0=1, 1=3, 2=7, 3=15 bytes */
@@ -1270,6 +1354,42 @@ static void e100_dump(struct nic *nic, s
 		offsetof(struct mem, dump_buf));
 }
 
+static int e100_phy_check_without_mii(struct nic *nic)
+{
+	u8 phy_type;
+	int without_mii;
+
+	phy_type = (nic->eeprom[eeprom_phy_iface] >> 8) & 0x0f;
+
+	switch (phy_type) {
+	case NoSuchPhy: /* Non-MII PHY; UNTESTED! */
+	case I82503: /* Non-MII PHY; UNTESTED! */
+	case S80C24: /* Non-MII PHY; tested and working */
+		/* paragraph from the FreeBSD driver, "FXP_PHY_80C24":
+		 * The Seeq 80c24 AutoDUPLEX(tm) Ethernet Interface Adapter
+		 * doesn't have a programming interface of any sort.  The
+		 * media is sensed automatically based on how the link partner
+		 * is configured.  This is, in essence, manual configuration.
+		 */
+		DPRINTK(PROBE, INFO,
+			 "found MII-less i82503 or 80c24 or other PHY\n");
+
+		nic->mdio_ctrl = mdio_ctrl_phy_mii_emulated;
+		nic->mii.phy_id = 0; /* is this ok for an MII-less PHY? */
+
+		/* these might be needed for certain MII-less cards...
+		 * nic->flags |= ich;
+		 * nic->flags |= ich_10h_workaround; */
+
+		without_mii = 1;
+		break;
+	default:
+		without_mii = 0;
+		break;
+	}
+	return without_mii;
+}
+
 #define NCONFIG_AUTO_SWITCH	0x0080
 #define MII_NSC_CONG		MII_RESV1
 #define NSC_CONG_ENABLE		0x0100
@@ -1290,9 +1410,21 @@ static int e100_phy_init(struct nic *nic
 		if (!((bmcr == 0xFFFF) || ((stat == 0) && (bmcr == 0))))
 			break;
 	}
-	DPRINTK(HW, DEBUG, "phy_addr = %d\n", nic->mii.phy_id);
-	if (addr == 32)
-		return -EAGAIN;
+	if (addr == 32) {
+		/* uhoh, no PHY detected: check whether we seem to be some
+		 * weird, rare variant which is *known* to not have any MII.
+		 * But do this AFTER MII checking only, since this does
+		 * lookup of EEPROM values which may easily be unreliable. */
+		if (e100_phy_check_without_mii(nic))
+			return 0; /* simply return and hope for the best */
+		else {
+			/* for unknown cases log a fatal error */
+			DPRINTK(HW, ERR,
+				"Failed to locate any known PHY, aborting.\n");
+			return -EAGAIN;
+		}
+	} else
+		DPRINTK(HW, DEBUG, "phy_addr = %d\n", nic->mii.phy_id);
 
 	/* Isolate all the PHY ids */
 	for (addr = 0; addr < 32; addr++)
@@ -1320,6 +1452,9 @@ static int e100_phy_init(struct nic *nic
 	if (nic->phy == phy_82552_v) {
 		u16 advert = mdio_read(netdev, nic->mii.phy_id, MII_ADVERTISE);
 
+		/* assign special tweaked mdio_ctrl() function */
+		nic->mdio_ctrl = mdio_ctrl_phy_82552_v;
+
 		/* Workaround Si not advertising flow-control during autoneg */
 		advert |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 		mdio_write(netdev, nic->mii.phy_id, MII_ADVERTISE, advert);
@@ -2585,6 +2720,7 @@ static int __devinit e100_probe(struct p
 	nic->netdev = netdev;
 	nic->pdev = pdev;
 	nic->msg_enable = (1 << debug) - 1;
+	nic->mdio_ctrl = mdio_ctrl_hw;
 	pci_set_drvdata(pdev, netdev);
 
 	if ((err = pci_enable_device(pdev))) {
_
