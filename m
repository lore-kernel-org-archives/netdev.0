From: Andreas Mohr <andim2@users.sourceforge.net>
Subject: [PATCH] Add non-MII PHY support to e100 (Re: 2.6.29 e100.c non-MII
	support status? (Re: [GIT]: Networking))
Date: Tue, 2 Jun 2009 23:48:52 +0200
Message-ID: <20090602214852.GA3095@rhlx01.hs-esslingen.de>
References: <20081228.000118.121541932.davem@davemloft.net> <20081229102515.GA17171@rhlx01.hs-esslingen.de> <20081229091728.d869f1c1.akpm@linux-foundation.org> <9929d2390812291515y623d6a51yed1bef021ab6847e@mail.gmail.com> <20081230120756.GA5393@rhlx01.hs-esslingen.de> <20090228203757.GA18850@rhlx01.hs-esslingen.de> <9929d2390903010257p7c6fb367ga974767605033bc9@mail.gmail.com> <20090301212412.GA13210@rhlx01.hs-esslingen.de>
Reply-To: andi@lisas.de
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, bunk@kernel.org,
	auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andi@lisas.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754226AbZFBVtH@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090301212412.GA13210@rhlx01.hs-esslingen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Sun, Mar 01, 2009 at 10:24:12PM +0100, Andreas Mohr wrote:
> The whole thing has been somewhat low-priority indeed
> given the probable age of some non-MII contenders. OTOH it would be quite sad
> (and locally problematic) to see support for those non-MII cards vanish
> come 2.6.29.
> Subsequently it would then be nice to devise non-MII support
> in some structured way that enables us to support them without
> much burden (code-wise) on proper standards-supporting MII cards.

OK, so.......

Frankly, I didn't want to see my card slowly and painfully getting unsupported
(which, conversely, results in a PC cut off from ANY kernel upgrades...).
Thus I decided to clean up my previous still-too-messy patch
by removing all dirty "are we MII?" - noooo - skip it! barriers.

ChangeLog:
Restore support for cards with MII-lacking PHYs as compared to
removed pre-2.6.29 eepro100 driver:
use full low-level MII I/O access abstraction by providing clean
PHY-specific mdio_ctrl() functions for either standard MII-compliant cards,
slightly special ones or non-MII PHY ones.



We now have another netdev_priv member for mdio_ctrl(),
thus we have some array indirection, but we save some additional opcodes
for specific phy_82552_v handling in the common case.


Patch tested on 2.6.30-rc7 (cold boot results in working network
access - this mail typed.....), checkpatch.pl'ed.

Obviously this patch needs quite some testing (-mmotm?),
since it also touches phy_82552_v functionality.

Oh, and this will be my very ultimately last attempt at this,
if there's no serious inclusion of something similar to this,
then I'll just give up.
[and install my nice WGA'd DRM'd and billed/invaded-by-the-minute Windows...]

Thanks!

Signed-off-by: Andreas Mohr <andi@lisas.de>

--- linux-2.6.30-rc7/drivers/net/e100.c.orig	2009-06-02 19:27:19.000000000 +0200
+++ linux-2.6.30-rc7/drivers/net/e100.c	2009-06-02 23:31:25.000000000 +0200
@@ -143,6 +143,8 @@
  *	FIXES:
  * 2005/12/02 - Michael O'Donnell <Michael.ODonnell at stratus dot com>
  *	- Stratus87247: protect MDI control register manipulations
+ * 2009/06/01 - Andreas Mohr <andi at lisas dot de>
+ *      - add clean lowlevel I/O emulation for cards with MII-lacking PHYs
  */
 
 #include <linux/module.h>
@@ -372,6 +374,7 @@
 
 enum eeprom_offsets {
 	eeprom_cnfg_mdix  = 0x03,
+	eeprom_phy_iface  = 0x06,
 	eeprom_id         = 0x0A,
 	eeprom_config_asf = 0x0D,
 	eeprom_smbus_addr = 0x90,
@@ -381,6 +384,18 @@
 	eeprom_mdix_enabled = 0x0080,
 };
 
+enum eeprom_phy_iface {
+	NonSuchPhy = 0,
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
@@ -545,6 +560,7 @@
 	u32 msg_enable				____cacheline_aligned;
 	struct net_device *netdev;
 	struct pci_dev *pdev;
+	u16 (*mdio_ctrl)(struct nic *nic, u32 addr, u32 dir, u32 reg, u16 data);
 
 	struct rx *rxs				____cacheline_aligned;
 	struct rx *rx_to_use;
@@ -899,7 +915,21 @@
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
@@ -938,30 +968,83 @@
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
@@ -1013,7 +1096,8 @@
 	config->standard_stat_counter = 0x1;	/* 1=standard, 0=extended */
 	config->rx_discard_short_frames = 0x1;	/* 1=discard, 0=pass */
 	config->tx_underrun_retry = 0x3;	/* # of underrun retries */
-	config->mii_mode = 0x1;			/* 1=MII mode, 0=503 mode */
+	if (e100_phy_supports_mii(nic))
+		config->mii_mode = 1;           /* 1=MII mode, 0=i82503 mode */
 	config->pad10 = 0x6;
 	config->no_source_addr_insertion = 0x1;	/* 1=no, 0=yes */
 	config->preamble_length = 0x2;		/* 0=1, 1=3, 2=7, 3=15 bytes */
@@ -1270,6 +1354,44 @@
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
+	case NonSuchPhy: /* Non-MII PHY; UNTESTED! */
+	case I82503: /* Non-MII PHY; UNTESTED! */
+	case S80C24: /* Non-MII PHY; tested and working */
+	{
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
+	}
+	break;
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
@@ -1290,9 +1412,21 @@
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
@@ -1320,6 +1454,9 @@
 	if (nic->phy == phy_82552_v) {
 		u16 advert = mdio_read(netdev, nic->mii.phy_id, MII_ADVERTISE);
 
+		/* assign special tweaked mdio_ctrl() function */
+		nic->mdio_ctrl = mdio_ctrl_phy_82552_v;
+
 		/* Workaround Si not advertising flow-control during autoneg */
 		advert |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 		mdio_write(netdev, nic->mii.phy_id, MII_ADVERTISE, advert);
@@ -2585,6 +2722,7 @@
 	nic->netdev = netdev;
 	nic->pdev = pdev;
 	nic->msg_enable = (1 << debug) - 1;
+	nic->mdio_ctrl = mdio_ctrl_hw;
 	pci_set_drvdata(pdev, netdev);
 
 	if ((err = pci_enable_device(pdev))) {
