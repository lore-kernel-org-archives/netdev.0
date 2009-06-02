From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 5/7] e1000e: add support for 82577/82578 GbE LOM parts
Date: Tue, 02 Jun 2009 14:29:18 -0700
Message-ID: <20090602212917.24614.36902.stgit@localhost.localdomain>
References: <20090602212800.24614.45798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.westchester.pa.mail.comcast.net ([76.96.62.40]:56993
	"EHLO QMTA04.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752232AbZFBV3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 17:29:34 -0400
In-Reply-To: <20090602212800.24614.45798.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

This patch provides support for the next generation Intel desktop
and mobile gigabit ethernet LOM adapters.  These adapters are the
follow-on parts to the LOMs tied to the prior ICH chipsets and are
comprised of a MAC in the PCH chipset and an external PHY (82577 for
mobile and 82578 for desktop versions).  New features consist of PHY
wakeup to save power by completely turning off the MAC while in Sx
state, and 4K jumbo frames.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |    2 
 drivers/net/e1000e/defines.h |   21 +
 drivers/net/e1000e/e1000.h   |   57 +++
 drivers/net/e1000e/es2lan.c  |    2 
 drivers/net/e1000e/ethtool.c |   37 +-
 drivers/net/e1000e/hw.h      |   16 +
 drivers/net/e1000e/ich8lan.c |  431 +++++++++++++++++++++++++-
 drivers/net/e1000e/lib.c     |   38 ++
 drivers/net/e1000e/netdev.c  |  206 ++++++++++++
 drivers/net/e1000e/phy.c     |  699 +++++++++++++++++++++++++++++++++++++++++-
 10 files changed, 1441 insertions(+), 68 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 8203964..c4b3f4f 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -1587,6 +1587,7 @@ static void e1000_clear_hw_cntrs_82571(struct e1000_hw *hw)
 static struct e1000_mac_operations e82571_mac_ops = {
 	/* .check_mng_mode: mac type dependent */
 	/* .check_for_link: media type dependent */
+	.id_led_init		= e1000e_id_led_init,
 	.cleanup_led		= e1000e_cleanup_led_generic,
 	.clear_hw_cntrs		= e1000_clear_hw_cntrs_82571,
 	.get_bus_info		= e1000e_get_bus_info_pcie,
@@ -1598,6 +1599,7 @@ static struct e1000_mac_operations e82571_mac_ops = {
 	.init_hw		= e1000_init_hw_82571,
 	.setup_link		= e1000_setup_link_82571,
 	/* .setup_physical_interface: media type dependent */
+	.setup_led		= e1000e_setup_led_generic,
 };
 
 static struct e1000_phy_operations e82_phy_ops_igp = {
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 9acfecd..674a47e 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -56,6 +56,7 @@
 /* Wake Up Control */
 #define E1000_WUC_APME       0x00000001 /* APM Enable */
 #define E1000_WUC_PME_EN     0x00000002 /* PME Enable */
+#define E1000_WUC_PHY_WAKE   0x00000100 /* if PHY supports wakeup */
 
 /* Wake Up Filter Control */
 #define E1000_WUFC_LNKC 0x00000001 /* Link Status Change Wakeup Enable */
@@ -65,6 +66,13 @@
 #define E1000_WUFC_BC   0x00000010 /* Broadcast Wakeup Enable */
 #define E1000_WUFC_ARP  0x00000020 /* ARP Request Packet Wakeup Enable */
 
+/* Wake Up Status */
+#define E1000_WUS_LNKC         E1000_WUFC_LNKC
+#define E1000_WUS_MAG          E1000_WUFC_MAG
+#define E1000_WUS_EX           E1000_WUFC_EX
+#define E1000_WUS_MC           E1000_WUFC_MC
+#define E1000_WUS_BC           E1000_WUFC_BC
+
 /* Extended Device Control */
 #define E1000_CTRL_EXT_SDP7_DATA 0x00000080 /* Value of SW Definable Pin 7 */
 #define E1000_CTRL_EXT_EE_RST    0x00002000 /* Reinitialize from EEPROM */
@@ -77,6 +85,7 @@
 #define E1000_CTRL_EXT_IAME           0x08000000 /* Interrupt acknowledge Auto-mask */
 #define E1000_CTRL_EXT_INT_TIMER_CLR  0x20000000 /* Clear Interrupt timers after IMS clear */
 #define E1000_CTRL_EXT_PBA_CLR        0x80000000 /* PBA Clear */
+#define E1000_CTRL_EXT_PHYPDEN        0x00100000
 
 /* Receive Descriptor bit definitions */
 #define E1000_RXD_STAT_DD       0x01    /* Descriptor Done */
@@ -140,6 +149,7 @@
 #define E1000_RCTL_DTYP_PS        0x00000400    /* Packet Split descriptor */
 #define E1000_RCTL_RDMTS_HALF     0x00000000    /* Rx desc min threshold size */
 #define E1000_RCTL_MO_SHIFT       12            /* multicast offset shift */
+#define E1000_RCTL_MO_3           0x00003000    /* multicast offset 15:4 */
 #define E1000_RCTL_BAM            0x00008000    /* broadcast enable */
 /* these buffer sizes are valid if E1000_RCTL_BSEX is 0 */
 #define E1000_RCTL_SZ_2048        0x00000000    /* Rx buffer size 2048 */
@@ -153,6 +163,7 @@
 #define E1000_RCTL_VFE            0x00040000    /* vlan filter enable */
 #define E1000_RCTL_CFIEN          0x00080000    /* canonical form enable */
 #define E1000_RCTL_CFI            0x00100000    /* canonical form indicator */
+#define E1000_RCTL_PMCF           0x00800000    /* pass MAC control frames */
 #define E1000_RCTL_BSEX           0x02000000    /* Buffer size extension */
 #define E1000_RCTL_SECRC          0x04000000    /* Strip Ethernet CRC */
 
@@ -255,11 +266,16 @@
 #define AUTONEG_ADVERTISE_SPEED_DEFAULT   E1000_ALL_SPEED_DUPLEX
 
 /* LED Control */
+#define E1000_PHY_LED0_MODE_MASK          0x00000007
+#define E1000_PHY_LED0_IVRT               0x00000008
+#define E1000_PHY_LED0_MASK               0x0000001F
+
 #define E1000_LEDCTL_LED0_MODE_MASK       0x0000000F
 #define E1000_LEDCTL_LED0_MODE_SHIFT      0
 #define E1000_LEDCTL_LED0_IVRT            0x00000040
 #define E1000_LEDCTL_LED0_BLINK           0x00000080
 
+#define E1000_LEDCTL_MODE_LINK_UP       0x2
 #define E1000_LEDCTL_MODE_LED_ON        0xE
 #define E1000_LEDCTL_MODE_LED_OFF       0xF
 
@@ -676,6 +692,8 @@
 #define IFE_C_E_PHY_ID       0x02A80310
 #define BME1000_E_PHY_ID     0x01410CB0
 #define BME1000_E_PHY_ID_R2  0x01410CB1
+#define I82577_E_PHY_ID      0x01540050
+#define I82578_E_PHY_ID      0x004DD040
 
 /* M88E1000 Specific Registers */
 #define M88E1000_PHY_SPEC_CTRL     0x10  /* PHY Specific Control Register */
@@ -729,6 +747,9 @@
 #define M88EC018_EPSCR_DOWNSHIFT_COUNTER_MASK  0x0E00
 #define M88EC018_EPSCR_DOWNSHIFT_COUNTER_5X    0x0800
 
+#define I82578_EPSCR_DOWNSHIFT_ENABLE          0x0020
+#define I82578_EPSCR_DOWNSHIFT_COUNTER_MASK    0x001C
+
 /* BME1000 PHY Specific Control Register */
 #define BME1000_PSCR_ENABLE_DOWNSHIFT   0x0800 /* 1 = enable downshift */
 
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index b9dc612..d6e491b 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -98,6 +98,49 @@ struct e1000_info;
 
 #define DEFAULT_JUMBO			9234
 
+/* BM/HV Specific Registers */
+#define BM_PORT_CTRL_PAGE                 769
+
+#define PHY_UPPER_SHIFT                   21
+#define BM_PHY_REG(page, reg) \
+	(((reg) & MAX_PHY_REG_ADDRESS) |\
+	 (((page) & 0xFFFF) << PHY_PAGE_SHIFT) |\
+	 (((reg) & ~MAX_PHY_REG_ADDRESS) << (PHY_UPPER_SHIFT - PHY_PAGE_SHIFT)))
+
+/* PHY Wakeup Registers and defines */
+#define BM_RCTL         PHY_REG(BM_WUC_PAGE, 0)
+#define BM_WUC          PHY_REG(BM_WUC_PAGE, 1)
+#define BM_WUFC         PHY_REG(BM_WUC_PAGE, 2)
+#define BM_WUS          PHY_REG(BM_WUC_PAGE, 3)
+#define BM_RAR_L(_i)    (BM_PHY_REG(BM_WUC_PAGE, 16 + ((_i) << 2)))
+#define BM_RAR_M(_i)    (BM_PHY_REG(BM_WUC_PAGE, 17 + ((_i) << 2)))
+#define BM_RAR_H(_i)    (BM_PHY_REG(BM_WUC_PAGE, 18 + ((_i) << 2)))
+#define BM_RAR_CTRL(_i) (BM_PHY_REG(BM_WUC_PAGE, 19 + ((_i) << 2)))
+#define BM_MTA(_i)      (BM_PHY_REG(BM_WUC_PAGE, 128 + ((_i) << 1)))
+
+#define BM_RCTL_UPE           0x0001          /* Unicast Promiscuous Mode */
+#define BM_RCTL_MPE           0x0002          /* Multicast Promiscuous Mode */
+#define BM_RCTL_MO_SHIFT      3               /* Multicast Offset Shift */
+#define BM_RCTL_MO_MASK       (3 << 3)        /* Multicast Offset Mask */
+#define BM_RCTL_BAM           0x0020          /* Broadcast Accept Mode */
+#define BM_RCTL_PMCF          0x0040          /* Pass MAC Control Frames */
+#define BM_RCTL_RFCE          0x0080          /* Rx Flow Control Enable */
+
+#define HV_SCC_UPPER		PHY_REG(778, 16) /* Single Collision Count */
+#define HV_SCC_LOWER		PHY_REG(778, 17)
+#define HV_ECOL_UPPER		PHY_REG(778, 18) /* Excessive Collision Count */
+#define HV_ECOL_LOWER		PHY_REG(778, 19)
+#define HV_MCC_UPPER		PHY_REG(778, 20) /* Multiple Collision Count */
+#define HV_MCC_LOWER		PHY_REG(778, 21)
+#define HV_LATECOL_UPPER	PHY_REG(778, 23) /* Late Collision Count */
+#define HV_LATECOL_LOWER	PHY_REG(778, 24)
+#define HV_COLC_UPPER		PHY_REG(778, 25) /* Collision Count */
+#define HV_COLC_LOWER		PHY_REG(778, 26)
+#define HV_DC_UPPER		PHY_REG(778, 27) /* Defer Count */
+#define HV_DC_LOWER		PHY_REG(778, 28)
+#define HV_TNCRS_UPPER		PHY_REG(778, 29) /* Transmit with no CRS */
+#define HV_TNCRS_LOWER		PHY_REG(778, 30)
+
 enum e1000_boards {
 	board_82571,
 	board_82572,
@@ -108,6 +151,7 @@ enum e1000_boards {
 	board_ich8lan,
 	board_ich9lan,
 	board_ich10lan,
+	board_pchlan,
 };
 
 struct e1000_queue_stats {
@@ -305,6 +349,7 @@ struct e1000_adapter {
 	unsigned int flags2;
 	struct work_struct downshift_task;
 	struct work_struct update_phy_task;
+	struct work_struct led_blink_task;
 };
 
 struct e1000_info {
@@ -355,6 +400,7 @@ struct e1000_info {
 
 /* CRC Stripping defines */
 #define FLAG2_CRC_STRIPPING               (1 << 0)
+#define FLAG2_HAS_PHY_WAKEUP              (1 << 1)
 
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
@@ -408,6 +454,7 @@ extern struct e1000_info e1000_82583_info;
 extern struct e1000_info e1000_ich8_info;
 extern struct e1000_info e1000_ich9_info;
 extern struct e1000_info e1000_ich10_info;
+extern struct e1000_info e1000_pch_info;
 extern struct e1000_info e1000_es2_info;
 
 extern s32 e1000e_read_pba_num(struct e1000_hw *hw, u32 *pba_num);
@@ -429,6 +476,7 @@ extern void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw);
 extern s32 e1000e_check_for_copper_link(struct e1000_hw *hw);
 extern s32 e1000e_check_for_fiber_link(struct e1000_hw *hw);
 extern s32 e1000e_check_for_serdes_link(struct e1000_hw *hw);
+extern s32 e1000e_setup_led_generic(struct e1000_hw *hw);
 extern s32 e1000e_cleanup_led_generic(struct e1000_hw *hw);
 extern s32 e1000e_led_on_generic(struct e1000_hw *hw);
 extern s32 e1000e_led_off_generic(struct e1000_hw *hw);
@@ -497,6 +545,15 @@ extern s32 e1000e_phy_reset_dsp(struct e1000_hw *hw);
 extern s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data);
 extern s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data);
 extern s32 e1000e_check_downshift(struct e1000_hw *hw);
+extern s32 e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data);
+extern s32 e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data);
+extern s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw, bool slow);
+extern s32 e1000_link_stall_workaround_hv(struct e1000_hw *hw);
+extern s32 e1000_copper_link_setup_82577(struct e1000_hw *hw);
+extern s32 e1000_check_polarity_82577(struct e1000_hw *hw);
+extern s32 e1000_get_phy_info_82577(struct e1000_hw *hw);
+extern s32 e1000_phy_force_speed_duplex_82577(struct e1000_hw *hw);
+extern s32 e1000_get_cable_length_82577(struct e1000_hw *hw);
 
 static inline s32 e1000_phy_hw_reset(struct e1000_hw *hw)
 {
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 6cc3bdf..ae5d736 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1366,6 +1366,7 @@ static void e1000_clear_hw_cntrs_80003es2lan(struct e1000_hw *hw)
 }
 
 static struct e1000_mac_operations es2_mac_ops = {
+	.id_led_init		= e1000e_id_led_init,
 	.check_mng_mode		= e1000e_check_mng_mode_generic,
 	/* check_for_link dependent on media type */
 	.cleanup_led		= e1000e_cleanup_led_generic,
@@ -1379,6 +1380,7 @@ static struct e1000_mac_operations es2_mac_ops = {
 	.init_hw		= e1000_init_hw_80003es2lan,
 	.setup_link		= e1000e_setup_link,
 	/* setup_physical_interface dependent on media type */
+	.setup_led		= e1000e_setup_led_generic,
 };
 
 static struct e1000_phy_operations es2_phy_ops = {
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 4d25ede..3d64356 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -776,6 +776,7 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	u32 after;
 	u32 i;
 	u32 toggle;
+	u32 mask;
 
 	/*
 	 * The status register is Read Only, so a write should fail.
@@ -788,17 +789,9 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 	case e1000_80003es2lan:
 		toggle = 0x7FFFF3FF;
 		break;
-	case e1000_82573:
-	case e1000_82574:
-	case e1000_82583:
-	case e1000_ich8lan:
-	case e1000_ich9lan:
-	case e1000_ich10lan:
+        default:
 		toggle = 0x7FFFF033;
 		break;
-	default:
-		toggle = 0xFFFFF833;
-		break;
 	}
 
 	before = er32(STATUS);
@@ -844,11 +837,18 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 		REG_PATTERN_TEST(E1000_TXCW, 0xC000FFFF, 0x0000FFFF);
 	REG_PATTERN_TEST(E1000_TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
 	REG_PATTERN_TEST(E1000_TIDV, 0x0000FFFF, 0x0000FFFF);
+	mask = 0x8003FFFF;
+	switch (mac->type) {
+	case e1000_ich10lan:
+	case e1000_pchlan:
+		mask |= (1 << 18);
+		break;
+	default:
+		break;
+	}
 	for (i = 0; i < mac->rar_entry_count; i++)
 		REG_PATTERN_TEST_ARRAY(E1000_RA, ((i << 1) + 1),
-				       ((mac->type == e1000_ich10lan) ?
-					   0x8007FFFF : 0x8003FFFF),
-				       0xFFFFFFFF);
+		                       mask, 0xFFFFFFFF);
 
 	for (i = 0; i < mac->mta_reg_count; i++)
 		REG_PATTERN_TEST_ARRAY(E1000_MTA, i, 0xFFFFFFFF, 0xFFFFFFFF);
@@ -1786,15 +1786,22 @@ static int e1000_set_wol(struct net_device *netdev,
 /* bit defines for adapter->led_status */
 #define E1000_LED_ON		0
 
-static void e1000_led_blink_callback(unsigned long data)
+static void e1000e_led_blink_task(struct work_struct *work)
 {
-	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+	struct e1000_adapter *adapter = container_of(work,
+	                                struct e1000_adapter, led_blink_task);
 
 	if (test_and_change_bit(E1000_LED_ON, &adapter->led_status))
 		adapter->hw.mac.ops.led_off(&adapter->hw);
 	else
 		adapter->hw.mac.ops.led_on(&adapter->hw);
+}
+
+static void e1000_led_blink_callback(unsigned long data)
+{
+	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 
+	schedule_work(&adapter->led_blink_task);
 	mod_timer(&adapter->blink_timer, jiffies + E1000_ID_INTERVAL);
 }
 
@@ -1807,7 +1814,9 @@ static int e1000_phys_id(struct net_device *netdev, u32 data)
 		data = INT_MAX;
 
 	if ((hw->phy.type == e1000_phy_ife) ||
+	    (hw->mac.type == e1000_pchlan) ||
 	    (hw->mac.type == e1000_82574)) {
+		INIT_WORK(&adapter->led_blink_task, e1000e_led_blink_task);
 		if (!adapter->blink_timer.function) {
 			init_timer(&adapter->blink_timer);
 			adapter->blink_timer.function =
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index 6cdb703..fce3f05 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -193,7 +193,11 @@ enum e1e_registers {
 	E1000_RXCSUM   = 0x05000, /* Rx Checksum Control - RW */
 	E1000_RFCTL    = 0x05008, /* Receive Filter Control */
 	E1000_MTA      = 0x05200, /* Multicast Table Array - RW Array */
-	E1000_RA       = 0x05400, /* Receive Address - RW Array */
+	E1000_RAL_BASE = 0x05400, /* Receive Address Low - RW */
+#define E1000_RAL(_n)   (E1000_RAL_BASE + ((_n) * 8))
+#define E1000_RA        (E1000_RAL(0))
+	E1000_RAH_BASE = 0x05404, /* Receive Address High - RW */
+#define E1000_RAH(_n)   (E1000_RAH_BASE + ((_n) * 8))
 	E1000_VFTA     = 0x05600, /* VLAN Filter Table Array - RW Array */
 	E1000_WUC      = 0x05800, /* Wakeup Control - RW */
 	E1000_WUFC     = 0x05808, /* Wakeup Filter Control - RW */
@@ -368,6 +372,10 @@ enum e1e_registers {
 #define E1000_DEV_ID_ICH10_R_BM_V		0x10CE
 #define E1000_DEV_ID_ICH10_D_BM_LM		0x10DE
 #define E1000_DEV_ID_ICH10_D_BM_LF		0x10DF
+#define E1000_DEV_ID_PCH_M_HV_LM		0x10EA
+#define E1000_DEV_ID_PCH_M_HV_LC		0x10EB
+#define E1000_DEV_ID_PCH_D_HV_DM		0x10EF
+#define E1000_DEV_ID_PCH_D_HV_DC		0x10F0
 
 #define E1000_REVISION_4 4
 
@@ -383,6 +391,7 @@ enum e1000_mac_type {
 	e1000_ich8lan,
 	e1000_ich9lan,
 	e1000_ich10lan,
+	e1000_pchlan,
 };
 
 enum e1000_media_type {
@@ -417,6 +426,8 @@ enum e1000_phy_type {
 	e1000_phy_igp_3,
 	e1000_phy_ife,
 	e1000_phy_bm,
+	e1000_phy_82578,
+	e1000_phy_82577,
 };
 
 enum e1000_bus_width {
@@ -720,6 +731,7 @@ struct e1000_host_mng_command_info {
 
 /* Function pointers and static data for the MAC. */
 struct e1000_mac_operations {
+	s32  (*id_led_init)(struct e1000_hw *);
 	bool (*check_mng_mode)(struct e1000_hw *);
 	s32  (*check_for_link)(struct e1000_hw *);
 	s32  (*cleanup_led)(struct e1000_hw *);
@@ -733,11 +745,13 @@ struct e1000_mac_operations {
 	s32  (*init_hw)(struct e1000_hw *);
 	s32  (*setup_link)(struct e1000_hw *);
 	s32  (*setup_physical_interface)(struct e1000_hw *);
+	s32  (*setup_led)(struct e1000_hw *);
 };
 
 /* Function pointers for the PHY. */
 struct e1000_phy_operations {
 	s32  (*acquire_phy)(struct e1000_hw *);
+	s32  (*check_polarity)(struct e1000_hw *);
 	s32  (*check_reset_block)(struct e1000_hw *);
 	s32  (*commit_phy)(struct e1000_hw *);
 	s32  (*force_speed_duplex)(struct e1000_hw *);
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index b63d987..b69c819 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -48,6 +48,10 @@
  * 82567LF-3 Gigabit Network Connection
  * 82567LM-3 Gigabit Network Connection
  * 82567LM-4 Gigabit Network Connection
+ * 82577LM Gigabit Network Connection
+ * 82577LC Gigabit Network Connection
+ * 82578DM Gigabit Network Connection
+ * 82578DC Gigabit Network Connection
  */
 
 #include <linux/netdevice.h>
@@ -116,6 +120,8 @@
 #define IGP3_VR_CTRL_DEV_POWERDOWN_MODE_MASK 0x0300
 #define IGP3_VR_CTRL_MODE_SHUTDOWN	0x0200
 
+#define HV_LED_CONFIG		PHY_REG(768, 30) /* LED Configuration */
+
 /* ICH GbE Flash Hardware Sequencing Flash Status Register bit breakdown */
 /* Offset 04h HSFSTS */
 union ich8_hws_flash_status {
@@ -186,6 +192,14 @@ static s32 e1000_read_flash_data_ich8lan(struct e1000_hw *hw, u32 offset,
 static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw);
 static s32 e1000_kmrn_lock_loss_workaround_ich8lan(struct e1000_hw *hw);
 static s32 e1000_get_cfg_done_ich8lan(struct e1000_hw *hw);
+static s32 e1000_cleanup_led_ich8lan(struct e1000_hw *hw);
+static s32 e1000_led_on_ich8lan(struct e1000_hw *hw);
+static s32 e1000_led_off_ich8lan(struct e1000_hw *hw);
+static s32 e1000_id_led_init_pchlan(struct e1000_hw *hw);
+static s32 e1000_setup_led_pchlan(struct e1000_hw *hw);
+static s32 e1000_cleanup_led_pchlan(struct e1000_hw *hw);
+static s32 e1000_led_on_pchlan(struct e1000_hw *hw);
+static s32 e1000_led_off_pchlan(struct e1000_hw *hw);
 
 static inline u16 __er16flash(struct e1000_hw *hw, unsigned long reg)
 {
@@ -213,6 +227,41 @@ static inline void __ew32flash(struct e1000_hw *hw, unsigned long reg, u32 val)
 #define ew32flash(reg,val)	__ew32flash(hw, (reg), (val))
 
 /**
+ *  e1000_init_phy_params_pchlan - Initialize PHY function pointers
+ *  @hw: pointer to the HW structure
+ *
+ *  Initialize family-specific PHY parameters and function pointers.
+ **/
+static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val = 0;
+
+	phy->addr                     = 1;
+	phy->reset_delay_us           = 100;
+
+	phy->ops.check_polarity       = e1000_check_polarity_ife_ich8lan;
+	phy->ops.read_phy_reg         = e1000_read_phy_reg_hv;
+	phy->ops.write_phy_reg        = e1000_write_phy_reg_hv;
+	phy->autoneg_mask             = AUTONEG_ADVERTISE_SPEED_DEFAULT;
+
+	phy->id = e1000_phy_unknown;
+	e1000e_get_phy_id(hw);
+	phy->type = e1000e_get_phy_type_from_id(phy->id);
+
+	if (phy->type == e1000_phy_82577) {
+		phy->ops.check_polarity = e1000_check_polarity_82577;
+		phy->ops.force_speed_duplex =
+			e1000_phy_force_speed_duplex_82577;
+		phy->ops.get_cable_length   = e1000_get_cable_length_82577;
+		phy->ops.get_phy_info = e1000_get_phy_info_82577;
+		phy->ops.commit_phy = e1000e_phy_sw_reset;
+	}
+
+	return ret_val;
+}
+
+/**
  *  e1000_init_phy_params_ich8lan - Initialize PHY function pointers
  *  @hw: pointer to the HW structure
  *
@@ -273,6 +322,8 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 		break;
 	}
 
+	phy->ops.check_polarity = e1000_check_polarity_ife_ich8lan;
+
 	return 0;
 }
 
@@ -358,6 +409,36 @@ static s32 e1000_init_mac_params_ich8lan(struct e1000_adapter *adapter)
 	/* Set if manageability features are enabled. */
 	mac->arc_subsystem_valid = 1;
 
+	/* LED operations */
+	switch (mac->type) {
+	case e1000_ich8lan:
+	case e1000_ich9lan:
+	case e1000_ich10lan:
+		/* ID LED init */
+		mac->ops.id_led_init = e1000e_id_led_init;
+		/* setup LED */
+		mac->ops.setup_led = e1000e_setup_led_generic;
+		/* cleanup LED */
+		mac->ops.cleanup_led = e1000_cleanup_led_ich8lan;
+		/* turn on/off LED */
+		mac->ops.led_on = e1000_led_on_ich8lan;
+		mac->ops.led_off = e1000_led_off_ich8lan;
+		break;
+	case e1000_pchlan:
+		/* ID LED init */
+		mac->ops.id_led_init = e1000_id_led_init_pchlan;
+		/* setup LED */
+		mac->ops.setup_led = e1000_setup_led_pchlan;
+		/* cleanup LED */
+		mac->ops.cleanup_led = e1000_cleanup_led_pchlan;
+		/* turn on/off LED */
+		mac->ops.led_on = e1000_led_on_pchlan;
+		mac->ops.led_off = e1000_led_off_pchlan;
+		break;
+	default:
+		break;
+	}
+
 	/* Enable PCS Lock-loss workaround for ICH8 */
 	if (mac->type == e1000_ich8lan)
 		e1000e_set_kmrn_lock_loss_workaround_ich8lan(hw, 1);
@@ -378,7 +459,10 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 	if (rc)
 		return rc;
 
-	rc = e1000_init_phy_params_ich8lan(hw);
+	if (hw->mac.type == e1000_pchlan)
+		rc = e1000_init_phy_params_pchlan(hw);
+	else
+		rc = e1000_init_phy_params_ich8lan(hw);
 	if (rc)
 		return rc;
 
@@ -415,12 +499,15 @@ static s32 e1000_acquire_swflag_ich8lan(struct e1000_hw *hw)
 
 	while (timeout) {
 		extcnf_ctrl = er32(EXTCNF_CTRL);
-		extcnf_ctrl |= E1000_EXTCNF_CTRL_SWFLAG;
-		ew32(EXTCNF_CTRL, extcnf_ctrl);
 
-		extcnf_ctrl = er32(EXTCNF_CTRL);
-		if (extcnf_ctrl & E1000_EXTCNF_CTRL_SWFLAG)
-			break;
+		if (!(extcnf_ctrl & E1000_EXTCNF_CTRL_SWFLAG)) {
+			extcnf_ctrl |= E1000_EXTCNF_CTRL_SWFLAG;
+			ew32(EXTCNF_CTRL, extcnf_ctrl);
+
+			extcnf_ctrl = er32(EXTCNF_CTRL);
+			if (extcnf_ctrl & E1000_EXTCNF_CTRL_SWFLAG)
+				break;
+		}
 		mdelay(1);
 		timeout--;
 	}
@@ -560,6 +647,53 @@ static s32 e1000_phy_force_speed_duplex_ich8lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_hv_phy_workarounds_ich8lan - A series of Phy workarounds to be
+ *  done after every PHY reset.
+ **/
+static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
+{
+	s32 ret_val = 0;
+
+	if (hw->mac.type != e1000_pchlan)
+		return ret_val;
+
+	if (((hw->phy.type == e1000_phy_82577) &&
+	     ((hw->phy.revision == 1) || (hw->phy.revision == 2))) ||
+	    ((hw->phy.type == e1000_phy_82578) && (hw->phy.revision == 1))) {
+		/* Disable generation of early preamble */
+		ret_val = e1e_wphy(hw, PHY_REG(769, 25), 0x4431);
+		if (ret_val)
+			return ret_val;
+
+		/* Preamble tuning for SSC */
+		ret_val = e1e_wphy(hw, PHY_REG(770, 16), 0xA204);
+		if (ret_val)
+			return ret_val;
+	}
+
+	if (hw->phy.type == e1000_phy_82578) {
+		/*
+		 * Return registers to default by doing a soft reset then
+		 * writing 0x3140 to the control register.
+		 */
+		if (hw->phy.revision < 2) {
+			e1000e_phy_sw_reset(hw);
+			ret_val = e1e_wphy(hw, PHY_CONTROL, 0x3140);
+		}
+	}
+
+	/* Select page 0 */
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		return ret_val;
+	hw->phy.addr = 1;
+	e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT, 0);
+	hw->phy.ops.release_phy(hw);
+
+	return ret_val;
+}
+
+/**
  *  e1000_phy_hw_reset_ich8lan - Performs a PHY reset
  *  @hw: pointer to the HW structure
  *
@@ -580,6 +714,12 @@ static s32 e1000_phy_hw_reset_ich8lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
+	if (hw->mac.type == e1000_pchlan) {
+		ret_val = e1000_hv_phy_workarounds_ich8lan(hw);
+		if (ret_val)
+			return ret_val;
+	}
+
 	/*
 	 * Initialize the PHY from the NVM on ICH platforms.  This
 	 * is needed due to an issue where the NVM configuration is
@@ -706,7 +846,7 @@ static s32 e1000_get_phy_info_ife_ich8lan(struct e1000_hw *hw)
 	phy->polarity_correction = (!(data & IFE_PSC_AUTO_POLARITY_DISABLE));
 
 	if (phy->polarity_correction) {
-		ret_val = e1000_check_polarity_ife_ich8lan(hw);
+		ret_val = phy->ops.check_polarity(hw);
 		if (ret_val)
 			return ret_val;
 	} else {
@@ -746,6 +886,8 @@ static s32 e1000_get_phy_info_ich8lan(struct e1000_hw *hw)
 		break;
 	case e1000_phy_igp_3:
 	case e1000_phy_bm:
+	case e1000_phy_82578:
+	case e1000_phy_82577:
 		return e1000e_get_phy_info_igp(hw);
 		break;
 	default:
@@ -1857,6 +1999,79 @@ static s32 e1000_valid_led_default_ich8lan(struct e1000_hw *hw, u16 *data)
 }
 
 /**
+ *  e1000_id_led_init_pchlan - store LED configurations
+ *  @hw: pointer to the HW structure
+ *
+ *  PCH does not control LEDs via the LEDCTL register, rather it uses
+ *  the PHY LED configuration register.
+ *
+ *  PCH also does not have an "always on" or "always off" mode which
+ *  complicates the ID feature.  Instead of using the "on" mode to indicate
+ *  in ledctl_mode2 the LEDs to use for ID (see e1000e_id_led_init()),
+ *  use "link_up" mode.  The LEDs will still ID on request if there is no
+ *  link based on logic in e1000_led_[on|off]_pchlan().
+ **/
+static s32 e1000_id_led_init_pchlan(struct e1000_hw *hw)
+{
+	struct e1000_mac_info *mac = &hw->mac;
+	s32 ret_val;
+	const u32 ledctl_on = E1000_LEDCTL_MODE_LINK_UP;
+	const u32 ledctl_off = E1000_LEDCTL_MODE_LINK_UP | E1000_PHY_LED0_IVRT;
+	u16 data, i, temp, shift;
+
+	/* Get default ID LED modes */
+	ret_val = hw->nvm.ops.valid_led_default(hw, &data);
+	if (ret_val)
+		goto out;
+
+	mac->ledctl_default = er32(LEDCTL);
+	mac->ledctl_mode1 = mac->ledctl_default;
+	mac->ledctl_mode2 = mac->ledctl_default;
+
+	for (i = 0; i < 4; i++) {
+		temp = (data >> (i << 2)) & E1000_LEDCTL_LED0_MODE_MASK;
+		shift = (i * 5);
+		switch (temp) {
+		case ID_LED_ON1_DEF2:
+		case ID_LED_ON1_ON2:
+		case ID_LED_ON1_OFF2:
+			mac->ledctl_mode1 &= ~(E1000_PHY_LED0_MASK << shift);
+			mac->ledctl_mode1 |= (ledctl_on << shift);
+			break;
+		case ID_LED_OFF1_DEF2:
+		case ID_LED_OFF1_ON2:
+		case ID_LED_OFF1_OFF2:
+			mac->ledctl_mode1 &= ~(E1000_PHY_LED0_MASK << shift);
+			mac->ledctl_mode1 |= (ledctl_off << shift);
+			break;
+		default:
+			/* Do nothing */
+			break;
+		}
+		switch (temp) {
+		case ID_LED_DEF1_ON2:
+		case ID_LED_ON1_ON2:
+		case ID_LED_OFF1_ON2:
+			mac->ledctl_mode2 &= ~(E1000_PHY_LED0_MASK << shift);
+			mac->ledctl_mode2 |= (ledctl_on << shift);
+			break;
+		case ID_LED_DEF1_OFF2:
+		case ID_LED_ON1_OFF2:
+		case ID_LED_OFF1_OFF2:
+			mac->ledctl_mode2 &= ~(E1000_PHY_LED0_MASK << shift);
+			mac->ledctl_mode2 |= (ledctl_off << shift);
+			break;
+		default:
+			/* Do nothing */
+			break;
+		}
+	}
+
+out:
+	return ret_val;
+}
+
+/**
  *  e1000_get_bus_info_ich8lan - Get/Set the bus type and width
  *  @hw: pointer to the HW structure
  *
@@ -1965,6 +2180,9 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	kab |= E1000_KABGTXD_BGSQLBIAS;
 	ew32(KABGTXD, kab);
 
+	if (hw->mac.type == e1000_pchlan)
+		ret_val = e1000_hv_phy_workarounds_ich8lan(hw);
+
 	return ret_val;
 }
 
@@ -1990,7 +2208,7 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	e1000_initialize_hw_bits_ich8lan(hw);
 
 	/* Initialize identification LED */
-	ret_val = e1000e_id_led_init(hw);
+	ret_val = mac->ops.id_led_init(hw);
 	if (ret_val) {
 		hw_dbg(hw, "Error initializing identification LED\n");
 		return ret_val;
@@ -2036,6 +2254,16 @@ static s32 e1000_init_hw_ich8lan(struct e1000_hw *hw)
 	ew32(CTRL_EXT, ctrl_ext);
 
 	/*
+	 * The 82578 Rx buffer will stall if wakeup is enabled in host and
+	 * the ME.  Reading the BM_WUC register will clear the host wakeup bit.
+	 * Reset the phy after disabling host wakeup to reset the Rx buffer.
+	 */
+	if (hw->phy.type == e1000_phy_82578) {
+		e1e_rphy(hw, BM_WUC, &i);
+		e1000e_phy_hw_reset_generic(hw);
+	}
+
+	/*
 	 * Clear all of the statistics registers (clear on read).  It is
 	 * important that we do this after we have tried to establish link
 	 * because the symbol error count will increment wildly if there
@@ -2059,6 +2287,9 @@ static void e1000_initialize_hw_bits_ich8lan(struct e1000_hw *hw)
 	/* Extended Device Control */
 	reg = er32(CTRL_EXT);
 	reg |= (1 << 22);
+	/* Enable PHY low-power state when MAC is at D3 w/o WoL */
+	if (hw->mac.type >= e1000_pchlan)
+		reg |= E1000_CTRL_EXT_PHYPDEN;
 	ew32(CTRL_EXT, reg);
 
 	/* Transmit Descriptor Control 0 */
@@ -2135,6 +2366,14 @@ static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 		return ret_val;
 
 	ew32(FCTTV, hw->fc.pause_time);
+	if ((hw->phy.type == e1000_phy_82578) ||
+	    (hw->phy.type == e1000_phy_82577)) {
+		ret_val = hw->phy.ops.write_phy_reg(hw,
+		                             PHY_REG(BM_PORT_CTRL_PAGE, 27),
+		                             hw->fc.pause_time);
+		if (ret_val)
+			return ret_val;
+	}
 
 	return e1000e_set_fc_watermarks(hw);
 }
@@ -2174,18 +2413,26 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	if (hw->phy.type == e1000_phy_igp_3) {
+	switch (hw->phy.type) {
+	case e1000_phy_igp_3:
 		ret_val = e1000e_copper_link_setup_igp(hw);
 		if (ret_val)
 			return ret_val;
-	} else if (hw->phy.type == e1000_phy_bm) {
+		break;
+	case e1000_phy_bm:
+	case e1000_phy_82578:
 		ret_val = e1000e_copper_link_setup_m88(hw);
 		if (ret_val)
 			return ret_val;
-	}
-
-	if (hw->phy.type == e1000_phy_ife) {
-		ret_val = e1e_rphy(hw, IFE_PHY_MDIX_CONTROL, &reg_data);
+		break;
+	case e1000_phy_82577:
+		ret_val = e1000_copper_link_setup_82577(hw);
+		if (ret_val)
+			return ret_val;
+		break;
+	case e1000_phy_ife:
+		ret_val = hw->phy.ops.read_phy_reg(hw, IFE_PHY_MDIX_CONTROL,
+		                               &reg_data);
 		if (ret_val)
 			return ret_val;
 
@@ -2203,9 +2450,13 @@ static s32 e1000_setup_copper_link_ich8lan(struct e1000_hw *hw)
 			reg_data |= IFE_PMC_AUTO_MDIX;
 			break;
 		}
-		ret_val = e1e_wphy(hw, IFE_PHY_MDIX_CONTROL, reg_data);
+		ret_val = hw->phy.ops.write_phy_reg(hw, IFE_PHY_MDIX_CONTROL,
+		                                reg_data);
 		if (ret_val)
 			return ret_val;
+		break;
+	default:
+		break;
 	}
 	return e1000e_setup_copper_link(hw);
 }
@@ -2422,18 +2673,26 @@ void e1000e_gig_downshift_workaround_ich8lan(struct e1000_hw *hw)
  *  'LPLU Enabled' and 'Gig Disable' to force link speed negotiation
  *  to a lower speed.
  *
- *  Should only be called for ICH9 and ICH10 devices.
+ *  Should only be called for applicable parts.
  **/
 void e1000e_disable_gig_wol_ich8lan(struct e1000_hw *hw)
 {
 	u32 phy_ctrl;
 
-	if ((hw->mac.type == e1000_ich10lan) ||
-	    (hw->mac.type == e1000_ich9lan)) {
+	switch (hw->mac.type) {
+	case e1000_ich9lan:
+	case e1000_ich10lan:
+	case e1000_pchlan:
 		phy_ctrl = er32(PHY_CTRL);
 		phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU |
 		            E1000_PHY_CTRL_GBE_DISABLE;
 		ew32(PHY_CTRL, phy_ctrl);
+
+		/* Workaround SWFLAG unexpectedly set during S0->Sx */
+		if (hw->mac.type == e1000_pchlan)
+			udelay(500);
+	default:
+		break;
 	}
 
 	return;
@@ -2487,13 +2746,99 @@ static s32 e1000_led_off_ich8lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_setup_led_pchlan - Configures SW controllable LED
+ *  @hw: pointer to the HW structure
+ *
+ *  This prepares the SW controllable LED for use.
+ **/
+static s32 e1000_setup_led_pchlan(struct e1000_hw *hw)
+{
+	return hw->phy.ops.write_phy_reg(hw, HV_LED_CONFIG,
+					(u16)hw->mac.ledctl_mode1);
+}
+
+/**
+ *  e1000_cleanup_led_pchlan - Restore the default LED operation
+ *  @hw: pointer to the HW structure
+ *
+ *  Return the LED back to the default configuration.
+ **/
+static s32 e1000_cleanup_led_pchlan(struct e1000_hw *hw)
+{
+	return hw->phy.ops.write_phy_reg(hw, HV_LED_CONFIG,
+					(u16)hw->mac.ledctl_default);
+}
+
+/**
+ *  e1000_led_on_pchlan - Turn LEDs on
+ *  @hw: pointer to the HW structure
+ *
+ *  Turn on the LEDs.
+ **/
+static s32 e1000_led_on_pchlan(struct e1000_hw *hw)
+{
+	u16 data = (u16)hw->mac.ledctl_mode2;
+	u32 i, led;
+
+	/*
+	 * If no link, then turn LED on by setting the invert bit
+	 * for each LED that's mode is "link_up" in ledctl_mode2.
+	 */
+	if (!(er32(STATUS) & E1000_STATUS_LU)) {
+		for (i = 0; i < 3; i++) {
+			led = (data >> (i * 5)) & E1000_PHY_LED0_MASK;
+			if ((led & E1000_PHY_LED0_MODE_MASK) !=
+			    E1000_LEDCTL_MODE_LINK_UP)
+				continue;
+			if (led & E1000_PHY_LED0_IVRT)
+				data &= ~(E1000_PHY_LED0_IVRT << (i * 5));
+			else
+				data |= (E1000_PHY_LED0_IVRT << (i * 5));
+		}
+	}
+
+	return hw->phy.ops.write_phy_reg(hw, HV_LED_CONFIG, data);
+}
+
+/**
+ *  e1000_led_off_pchlan - Turn LEDs off
+ *  @hw: pointer to the HW structure
+ *
+ *  Turn off the LEDs.
+ **/
+static s32 e1000_led_off_pchlan(struct e1000_hw *hw)
+{
+	u16 data = (u16)hw->mac.ledctl_mode1;
+	u32 i, led;
+
+	/*
+	 * If no link, then turn LED off by clearing the invert bit
+	 * for each LED that's mode is "link_up" in ledctl_mode1.
+	 */
+	if (!(er32(STATUS) & E1000_STATUS_LU)) {
+		for (i = 0; i < 3; i++) {
+			led = (data >> (i * 5)) & E1000_PHY_LED0_MASK;
+			if ((led & E1000_PHY_LED0_MODE_MASK) !=
+			    E1000_LEDCTL_MODE_LINK_UP)
+				continue;
+			if (led & E1000_PHY_LED0_IVRT)
+				data &= ~(E1000_PHY_LED0_IVRT << (i * 5));
+			else
+				data |= (E1000_PHY_LED0_IVRT << (i * 5));
+		}
+	}
+
+	return hw->phy.ops.write_phy_reg(hw, HV_LED_CONFIG, data);
+}
+
+/**
  *  e1000_get_cfg_done_ich8lan - Read config done bit
  *  @hw: pointer to the HW structure
  *
  *  Read the management control register for the config done bit for
  *  completion status.  NOTE: silicon which is EEPROM-less will fail trying
  *  to read the config done bit, so an error is *ONLY* logged and returns
- *  E1000_SUCCESS.  If we were to return with error, EEPROM-less silicon
+ *  0.  If we were to return with error, EEPROM-less silicon
  *  would not be able to be reset or change link.
  **/
 static s32 e1000_get_cfg_done_ich8lan(struct e1000_hw *hw)
@@ -2503,7 +2848,8 @@ static s32 e1000_get_cfg_done_ich8lan(struct e1000_hw *hw)
 	e1000e_get_cfg_done(hw);
 
 	/* If EEPROM is not marked present, init the IGP 3 PHY manually */
-	if (hw->mac.type != e1000_ich10lan) {
+	if ((hw->mac.type != e1000_ich10lan) &&
+	    (hw->mac.type != e1000_pchlan)) {
 		if (((er32(EECD) & E1000_EECD_PRES) == 0) &&
 		    (hw->phy.type == e1000_phy_igp_3)) {
 			e1000e_phy_init_script_igp3(hw);
@@ -2529,6 +2875,7 @@ static s32 e1000_get_cfg_done_ich8lan(struct e1000_hw *hw)
 static void e1000_clear_hw_cntrs_ich8lan(struct e1000_hw *hw)
 {
 	u32 temp;
+	u16 phy_data;
 
 	e1000e_clear_hw_cntrs_base(hw);
 
@@ -2546,22 +2893,42 @@ static void e1000_clear_hw_cntrs_ich8lan(struct e1000_hw *hw)
 	temp = er32(IAC);
 	temp = er32(ICRXOC);
 
+	/* Clear PHY statistics registers */
+	if ((hw->phy.type == e1000_phy_82578) ||
+	    (hw->phy.type == e1000_phy_82577)) {
+		hw->phy.ops.read_phy_reg(hw, HV_SCC_UPPER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_SCC_LOWER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_ECOL_UPPER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_ECOL_LOWER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_MCC_UPPER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_MCC_LOWER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_LATECOL_UPPER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_LATECOL_LOWER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_COLC_UPPER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_COLC_LOWER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_DC_UPPER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_DC_LOWER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_TNCRS_UPPER, &phy_data);
+		hw->phy.ops.read_phy_reg(hw, HV_TNCRS_LOWER, &phy_data);
+	}
 }
 
 static struct e1000_mac_operations ich8_mac_ops = {
+	.id_led_init		= e1000e_id_led_init,
 	.check_mng_mode		= e1000_check_mng_mode_ich8lan,
 	.check_for_link		= e1000e_check_for_copper_link,
-	.cleanup_led		= e1000_cleanup_led_ich8lan,
+	/* cleanup_led dependent on mac type */
 	.clear_hw_cntrs		= e1000_clear_hw_cntrs_ich8lan,
 	.get_bus_info		= e1000_get_bus_info_ich8lan,
 	.get_link_up_info	= e1000_get_link_up_info_ich8lan,
-	.led_on			= e1000_led_on_ich8lan,
-	.led_off		= e1000_led_off_ich8lan,
+	/* led_on dependent on mac type */
+	/* led_off dependent on mac type */
 	.update_mc_addr_list	= e1000e_update_mc_addr_list_generic,
 	.reset_hw		= e1000_reset_hw_ich8lan,
 	.init_hw		= e1000_init_hw_ich8lan,
 	.setup_link		= e1000_setup_link_ich8lan,
 	.setup_physical_interface= e1000_setup_copper_link_ich8lan,
+	/* id_led_init dependent on mac type */
 };
 
 static struct e1000_phy_operations ich8_phy_ops = {
@@ -2644,3 +3011,21 @@ struct e1000_info e1000_ich10_info = {
 	.phy_ops		= &ich8_phy_ops,
 	.nvm_ops		= &ich8_nvm_ops,
 };
+
+struct e1000_info e1000_pch_info = {
+	.mac			= e1000_pchlan,
+	.flags			= FLAG_IS_ICH
+				  | FLAG_HAS_WOL
+				  | FLAG_RX_CSUM_ENABLED
+				  | FLAG_HAS_CTRLEXT_ON_LOAD
+				  | FLAG_HAS_AMT
+				  | FLAG_HAS_FLASH
+				  | FLAG_HAS_JUMBO_FRAMES
+				  | FLAG_APME_IN_WUC,
+	.pba			= 26,
+	.max_hw_frame_size	= 4096,
+	.get_variants		= e1000_get_variants_ich8lan,
+	.mac_ops		= &ich8_mac_ops,
+	.phy_ops		= &ich8_phy_ops,
+	.nvm_ops		= &ich8_nvm_ops,
+};
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 18a4f59..be6d9e9 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -378,6 +378,12 @@ s32 e1000e_check_for_copper_link(struct e1000_hw *hw)
 
 	mac->get_link_status = 0;
 
+	if (hw->phy.type == e1000_phy_82578) {
+		ret_val = e1000_link_stall_workaround_hv(hw);
+		if (ret_val)
+			return ret_val;
+	}
+
 	/*
 	 * Check if there was DownShift, must be checked
 	 * immediately after link-up
@@ -1406,6 +1412,38 @@ s32 e1000e_id_led_init(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000e_setup_led_generic - Configures SW controllable LED
+ *  @hw: pointer to the HW structure
+ *
+ *  This prepares the SW controllable LED for use and saves the current state
+ *  of the LED so it can be later restored.
+ **/
+s32 e1000e_setup_led_generic(struct e1000_hw *hw)
+{
+	u32 ledctl;
+
+	if (hw->mac.ops.setup_led != e1000e_setup_led_generic) {
+		return -E1000_ERR_CONFIG;
+	}
+
+	if (hw->phy.media_type == e1000_media_type_fiber) {
+		ledctl = er32(LEDCTL);
+		hw->mac.ledctl_default = ledctl;
+		/* Turn off LED0 */
+		ledctl &= ~(E1000_LEDCTL_LED0_IVRT |
+		            E1000_LEDCTL_LED0_BLINK |
+		            E1000_LEDCTL_LED0_MODE_MASK);
+		ledctl |= (E1000_LEDCTL_MODE_LED_OFF <<
+		           E1000_LEDCTL_LED0_MODE_SHIFT);
+		ew32(LEDCTL, ledctl);
+	} else if (hw->phy.media_type == e1000_media_type_copper) {
+		ew32(LEDCTL, hw->mac.ledctl_mode1);
+	}
+
+	return 0;
+}
+
+/**
  *  e1000e_cleanup_led_generic - Set LED config to default operation
  *  @hw: pointer to the HW structure
  *
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4072fbb..2cb704d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -62,6 +62,7 @@ static const struct e1000_info *e1000_info_tbl[] = {
 	[board_ich8lan]		= &e1000_ich8_info,
 	[board_ich9lan]		= &e1000_ich9_info,
 	[board_ich10lan]	= &e1000_ich10_info,
+	[board_pchlan]		= &e1000_pch_info,
 };
 
 #ifdef DEBUG
@@ -2308,6 +2309,23 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	if (adapter->flags2 & FLAG2_CRC_STRIPPING)
 		rctl |= E1000_RCTL_SECRC;
 
+	/* Workaround Si errata on 82577 PHY - configure IPG for jumbos */
+	if ((hw->phy.type == e1000_phy_82577) && (rctl & E1000_RCTL_LPE)) {
+		u16 phy_data;
+
+		e1e_rphy(hw, PHY_REG(770, 26), &phy_data);
+		phy_data &= 0xfff8;
+		phy_data |= (1 << 2);
+		e1e_wphy(hw, PHY_REG(770, 26), phy_data);
+
+		e1e_rphy(hw, 22, &phy_data);
+		phy_data &= 0x0fff;
+		phy_data |= (1 << 14);
+		e1e_wphy(hw, 0x10, 0x2823);
+		e1e_wphy(hw, 0x11, 0x0003);
+		e1e_wphy(hw, 22, phy_data);
+	}
+
 	/* Setup buffer sizes */
 	rctl &= ~E1000_RCTL_SZ_4096;
 	rctl |= E1000_RCTL_BSEX;
@@ -2789,6 +2807,8 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		e1000_get_hw_control(adapter);
 
 	ew32(WUC, 0);
+	if (adapter->flags2 & FLAG2_HAS_PHY_WAKEUP)
+		e1e_wphy(&adapter->hw, BM_WUC, 0);
 
 	if (mac->ops.init_hw(hw))
 		e_err("Hardware Error\n");
@@ -3269,6 +3289,7 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
+	u16 phy_data;
 
 	/*
 	 * Prevent stats update while adapter is being reset, or if the pci
@@ -3288,11 +3309,34 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 	adapter->stats.roc += er32(ROC);
 
 	adapter->stats.mpc += er32(MPC);
-	adapter->stats.scc += er32(SCC);
-	adapter->stats.ecol += er32(ECOL);
-	adapter->stats.mcc += er32(MCC);
-	adapter->stats.latecol += er32(LATECOL);
-	adapter->stats.dc += er32(DC);
+	if ((hw->phy.type == e1000_phy_82578) ||
+	    (hw->phy.type == e1000_phy_82577)) {
+		e1e_rphy(hw, HV_SCC_UPPER, &phy_data);
+		e1e_rphy(hw, HV_SCC_LOWER, &phy_data);
+		adapter->stats.scc += phy_data;
+
+		e1e_rphy(hw, HV_ECOL_UPPER, &phy_data);
+		e1e_rphy(hw, HV_ECOL_LOWER, &phy_data);
+		adapter->stats.ecol += phy_data;
+
+		e1e_rphy(hw, HV_MCC_UPPER, &phy_data);
+		e1e_rphy(hw, HV_MCC_LOWER, &phy_data);
+		adapter->stats.mcc += phy_data;
+
+		e1e_rphy(hw, HV_LATECOL_UPPER, &phy_data);
+		e1e_rphy(hw, HV_LATECOL_LOWER, &phy_data);
+		adapter->stats.latecol += phy_data;
+
+		e1e_rphy(hw, HV_DC_UPPER, &phy_data);
+		e1e_rphy(hw, HV_DC_LOWER, &phy_data);
+		adapter->stats.dc += phy_data;
+	} else {
+		adapter->stats.scc += er32(SCC);
+		adapter->stats.ecol += er32(ECOL);
+		adapter->stats.mcc += er32(MCC);
+		adapter->stats.latecol += er32(LATECOL);
+		adapter->stats.dc += er32(DC);
+	}
 	adapter->stats.xonrxc += er32(XONRXC);
 	adapter->stats.xontxc += er32(XONTXC);
 	adapter->stats.xoffrxc += er32(XOFFRXC);
@@ -3310,13 +3354,28 @@ void e1000e_update_stats(struct e1000_adapter *adapter)
 
 	hw->mac.tx_packet_delta = er32(TPT);
 	adapter->stats.tpt += hw->mac.tx_packet_delta;
-	hw->mac.collision_delta = er32(COLC);
+	if ((hw->phy.type == e1000_phy_82578) ||
+	    (hw->phy.type == e1000_phy_82577)) {
+		e1e_rphy(hw, HV_COLC_UPPER, &phy_data);
+		e1e_rphy(hw, HV_COLC_LOWER, &phy_data);
+		hw->mac.collision_delta = phy_data;
+	} else {
+		hw->mac.collision_delta = er32(COLC);
+	}
 	adapter->stats.colc += hw->mac.collision_delta;
 
 	adapter->stats.algnerrc += er32(ALGNERRC);
 	adapter->stats.rxerrc += er32(RXERRC);
-	if ((hw->mac.type != e1000_82574) && (hw->mac.type != e1000_82583))
-		adapter->stats.tncrs += er32(TNCRS);
+	if ((hw->phy.type == e1000_phy_82578) ||
+	    (hw->phy.type == e1000_phy_82577)) {
+		e1e_rphy(hw, HV_TNCRS_UPPER, &phy_data);
+		e1e_rphy(hw, HV_TNCRS_LOWER, &phy_data);
+		adapter->stats.tncrs += phy_data;
+	} else {
+		if ((hw->mac.type != e1000_82574) &&
+		    (hw->mac.type != e1000_82583))
+			adapter->stats.tncrs += er32(TNCRS);
+	}
 	adapter->stats.cexterr += er32(CEXTERR);
 	adapter->stats.tsctc += er32(TSCTC);
 	adapter->stats.tsctfc += er32(TSCTFC);
@@ -4342,6 +4401,81 @@ static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	}
 }
 
+static int e1000_init_phy_wakeup(struct e1000_adapter *adapter, u32 wufc)
+{
+	struct e1000_hw *hw = &adapter->hw;
+	u32 i, mac_reg;
+	u16 phy_reg;
+	int retval = 0;
+
+	/* copy MAC RARs to PHY RARs */
+	for (i = 0; i < adapter->hw.mac.rar_entry_count; i++) {
+		mac_reg = er32(RAL(i));
+		e1e_wphy(hw, BM_RAR_L(i), (u16)(mac_reg & 0xFFFF));
+		e1e_wphy(hw, BM_RAR_M(i), (u16)((mac_reg >> 16) & 0xFFFF));
+		mac_reg = er32(RAH(i));
+		e1e_wphy(hw, BM_RAR_H(i), (u16)(mac_reg & 0xFFFF));
+		e1e_wphy(hw, BM_RAR_CTRL(i), (u16)((mac_reg >> 16) & 0xFFFF));
+	}
+
+	/* copy MAC MTA to PHY MTA */
+	for (i = 0; i < adapter->hw.mac.mta_reg_count; i++) {
+		mac_reg = E1000_READ_REG_ARRAY(hw, E1000_MTA, i);
+		e1e_wphy(hw, BM_MTA(i), (u16)(mac_reg & 0xFFFF));
+		e1e_wphy(hw, BM_MTA(i) + 1, (u16)((mac_reg >> 16) & 0xFFFF));
+	}
+
+	/* configure PHY Rx Control register */
+	e1e_rphy(&adapter->hw, BM_RCTL, &phy_reg);
+	mac_reg = er32(RCTL);
+	if (mac_reg & E1000_RCTL_UPE)
+		phy_reg |= BM_RCTL_UPE;
+	if (mac_reg & E1000_RCTL_MPE)
+		phy_reg |= BM_RCTL_MPE;
+	phy_reg &= ~(BM_RCTL_MO_MASK);
+	if (mac_reg & E1000_RCTL_MO_3)
+		phy_reg |= (((mac_reg & E1000_RCTL_MO_3) >> E1000_RCTL_MO_SHIFT)
+				<< BM_RCTL_MO_SHIFT);
+	if (mac_reg & E1000_RCTL_BAM)
+		phy_reg |= BM_RCTL_BAM;
+	if (mac_reg & E1000_RCTL_PMCF)
+		phy_reg |= BM_RCTL_PMCF;
+	mac_reg = er32(CTRL);
+	if (mac_reg & E1000_CTRL_RFCE)
+		phy_reg |= BM_RCTL_RFCE;
+	e1e_wphy(&adapter->hw, BM_RCTL, phy_reg);
+
+	/* enable PHY wakeup in MAC register */
+	ew32(WUFC, wufc);
+	ew32(WUC, E1000_WUC_PHY_WAKE | E1000_WUC_PME_EN);
+
+	/* configure and enable PHY wakeup in PHY registers */
+	e1e_wphy(&adapter->hw, BM_WUFC, wufc);
+	e1e_wphy(&adapter->hw, BM_WUC, E1000_WUC_PME_EN);
+
+	/* activate PHY wakeup */
+	retval = hw->phy.ops.acquire_phy(hw);
+	if (retval) {
+		e_err("Could not acquire PHY\n");
+		return retval;
+	}
+	e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
+	                         (BM_WUC_ENABLE_PAGE << IGP_PAGE_SHIFT));
+	retval = e1000e_read_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, &phy_reg);
+	if (retval) {
+		e_err("Could not read PHY page 769\n");
+		goto out;
+	}
+	phy_reg |= BM_WUC_ENABLE_BIT | BM_WUC_HOST_WU_BIT;
+	retval = e1000e_write_phy_reg_mdic(hw, BM_WUC_ENABLE_REG, phy_reg);
+	if (retval)
+		e_err("Could not set PHY Host Wakeup bit\n");
+out:
+	hw->phy.ops.release_phy(hw);
+
+	return retval;
+}
+
 static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -4384,8 +4518,9 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		#define E1000_CTRL_ADVD3WUC 0x00100000
 		/* phy power management enable */
 		#define E1000_CTRL_EN_PHY_PWR_MGMT 0x00200000
-		ctrl |= E1000_CTRL_ADVD3WUC |
-			E1000_CTRL_EN_PHY_PWR_MGMT;
+		ctrl |= E1000_CTRL_ADVD3WUC;
+		if (!(adapter->flags2 & FLAG2_HAS_PHY_WAKEUP))
+			ctrl |= E1000_CTRL_EN_PHY_PWR_MGMT;
 		ew32(CTRL, ctrl);
 
 		if (adapter->hw.phy.media_type == e1000_media_type_fiber ||
@@ -4403,8 +4538,17 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		/* Allow time for pending master requests to run */
 		e1000e_disable_pcie_master(&adapter->hw);
 
-		ew32(WUC, E1000_WUC_PME_EN);
-		ew32(WUFC, wufc);
+		if ((adapter->flags2 & FLAG2_HAS_PHY_WAKEUP) &&
+		    !(hw->mac.ops.check_mng_mode(hw))) {
+			/* enable wakeup by the PHY */
+			retval = e1000_init_phy_wakeup(adapter, wufc);
+			if (retval)
+				return retval;
+		} else {
+			/* enable wakeup by the MAC */
+			ew32(WUFC, wufc);
+			ew32(WUC, E1000_WUC_PME_EN);
+		}
 	} else {
 		ew32(WUC, 0);
 		ew32(WUFC, 0);
@@ -4547,8 +4691,37 @@ static int e1000_resume(struct pci_dev *pdev)
 	}
 
 	e1000e_power_up_phy(adapter);
+
+	/* report the system wakeup cause from S3/S4 */
+	if (adapter->flags2 & FLAG2_HAS_PHY_WAKEUP) {
+		u16 phy_data;
+
+		e1e_rphy(&adapter->hw, BM_WUS, &phy_data);
+		if (phy_data) {
+			e_info("PHY Wakeup cause - %s\n",
+				phy_data & E1000_WUS_EX ? "Unicast Packet" :
+				phy_data & E1000_WUS_MC ? "Multicast Packet" :
+				phy_data & E1000_WUS_BC ? "Broadcast Packet" :
+				phy_data & E1000_WUS_MAG ? "Magic Packet" :
+				phy_data & E1000_WUS_LNKC ? "Link Status "
+				" Change" : "other");
+		}
+		e1e_wphy(&adapter->hw, BM_WUS, ~0);
+	} else {
+		u32 wus = er32(WUS);
+		if (wus) {
+			e_info("MAC Wakeup cause - %s\n",
+				wus & E1000_WUS_EX ? "Unicast Packet" :
+				wus & E1000_WUS_MC ? "Multicast Packet" :
+				wus & E1000_WUS_BC ? "Broadcast Packet" :
+				wus & E1000_WUS_MAG ? "Magic Packet" :
+				wus & E1000_WUS_LNKC ? "Link Status Change" :
+				"other");
+		}
+		ew32(WUS, ~0);
+	}
+
 	e1000e_reset(adapter);
-	ew32(WUS, ~0);
 
 	e1000_init_manageability(adapter);
 
@@ -4994,6 +5167,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		/* APME bit in EEPROM is mapped to WUC.APME */
 		eeprom_data = er32(WUC);
 		eeprom_apme_mask = E1000_WUC_APME;
+		if (eeprom_data & E1000_WUC_PHY_WAKE)
+			adapter->flags2 |= FLAG2_HAS_PHY_WAKEUP;
 	} else if (adapter->flags & FLAG_APME_IN_CTRL3) {
 		if (adapter->flags & FLAG_APME_CHECK_PORT_B &&
 		    (adapter->hw.bus.func == 1))
@@ -5195,6 +5370,11 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_D_BM_LM), board_ich10lan },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_ICH10_D_BM_LF), board_ich10lan },
 
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_M_HV_LM), board_pchlan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_M_HV_LC), board_pchlan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_D_HV_DM), board_pchlan },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_PCH_D_HV_DC), board_pchlan },
+
 	{ }	/* terminate list */
 };
 MODULE_DEVICE_TABLE(pci, e1000_pci_tbl);
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index dc4a9cb..e23459c 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -37,6 +37,9 @@ static s32 e1000_wait_autoneg(struct e1000_hw *hw);
 static u32 e1000_get_phy_addr_for_bm_page(u32 page, u32 reg);
 static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 					  u16 *data, bool read);
+static u32 e1000_get_phy_addr_for_hv_page(u32 page);
+static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
+                                          u16 *data, bool read);
 
 /* Cable length tables */
 static const u16 e1000_m88_cable_length_table[] =
@@ -54,6 +57,55 @@ static const u16 e1000_igp_2_cable_length_table[] =
 #define IGP02E1000_CABLE_LENGTH_TABLE_SIZE \
 		ARRAY_SIZE(e1000_igp_2_cable_length_table)
 
+#define BM_PHY_REG_PAGE(offset) \
+	((u16)(((offset) >> PHY_PAGE_SHIFT) & 0xFFFF))
+#define BM_PHY_REG_NUM(offset) \
+	((u16)(((offset) & MAX_PHY_REG_ADDRESS) |\
+	 (((offset) >> (PHY_UPPER_SHIFT - PHY_PAGE_SHIFT)) &\
+		~MAX_PHY_REG_ADDRESS)))
+
+#define HV_INTC_FC_PAGE_START             768
+#define I82578_ADDR_REG                   29
+#define I82577_ADDR_REG                   16
+#define I82577_CFG_REG                    22
+#define I82577_CFG_ASSERT_CRS_ON_TX       (1 << 15)
+#define I82577_CFG_ENABLE_DOWNSHIFT       (3 << 10) /* auto downshift 100/10 */
+#define I82577_CTRL_REG                   23
+#define I82577_CTRL_DOWNSHIFT_MASK        (7 << 10)
+
+/* 82577 specific PHY registers */
+#define I82577_PHY_CTRL_2            18
+#define I82577_PHY_STATUS_2          26
+#define I82577_PHY_DIAG_STATUS       31
+
+/* I82577 PHY Status 2 */
+#define I82577_PHY_STATUS2_REV_POLARITY   0x0400
+#define I82577_PHY_STATUS2_MDIX           0x0800
+#define I82577_PHY_STATUS2_SPEED_MASK     0x0300
+#define I82577_PHY_STATUS2_SPEED_1000MBPS 0x0200
+
+/* I82577 PHY Control 2 */
+#define I82577_PHY_CTRL2_AUTO_MDIX        0x0400
+#define I82577_PHY_CTRL2_FORCE_MDI_MDIX   0x0200
+
+/* I82577 PHY Diagnostics Status */
+#define I82577_DSTATUS_CABLE_LENGTH       0x03FC
+#define I82577_DSTATUS_CABLE_LENGTH_SHIFT 2
+
+/* BM PHY Copper Specific Control 1 */
+#define BM_CS_CTRL1                       16
+
+/* BM PHY Copper Specific Status */
+#define BM_CS_STATUS                      17
+#define BM_CS_STATUS_LINK_UP              0x0400
+#define BM_CS_STATUS_RESOLVED             0x0800
+#define BM_CS_STATUS_SPEED_MASK           0xC000
+#define BM_CS_STATUS_SPEED_1000           0x8000
+
+#define HV_MUX_DATA_CTRL               PHY_REG(776, 16)
+#define HV_MUX_DATA_CTRL_GEN_TO_MAC    0x0400
+#define HV_MUX_DATA_CTRL_FORCE_SPEED   0x0004
+
 /**
  *  e1000e_check_reset_block_generic - Check if PHY reset is blocked
  *  @hw: pointer to the HW structure
@@ -82,23 +134,48 @@ s32 e1000e_check_reset_block_generic(struct e1000_hw *hw)
 s32 e1000e_get_phy_id(struct e1000_hw *hw)
 {
 	struct e1000_phy_info *phy = &hw->phy;
-	s32 ret_val;
+	s32 ret_val = 0;
 	u16 phy_id;
+	u16 retry_count = 0;
 
-	ret_val = e1e_rphy(hw, PHY_ID1, &phy_id);
-	if (ret_val)
-		return ret_val;
+	if (!(phy->ops.read_phy_reg))
+		goto out;
 
-	phy->id = (u32)(phy_id << 16);
-	udelay(20);
-	ret_val = e1e_rphy(hw, PHY_ID2, &phy_id);
-	if (ret_val)
-		return ret_val;
+	while (retry_count < 2) {
+		ret_val = e1e_rphy(hw, PHY_ID1, &phy_id);
+		if (ret_val)
+			goto out;
 
-	phy->id |= (u32)(phy_id & PHY_REVISION_MASK);
-	phy->revision = (u32)(phy_id & ~PHY_REVISION_MASK);
+		phy->id = (u32)(phy_id << 16);
+		udelay(20);
+		ret_val = e1e_rphy(hw, PHY_ID2, &phy_id);
+		if (ret_val)
+			goto out;
 
-	return 0;
+		phy->id |= (u32)(phy_id & PHY_REVISION_MASK);
+		phy->revision = (u32)(phy_id & ~PHY_REVISION_MASK);
+
+		if (phy->id != 0 && phy->id != PHY_REVISION_MASK)
+			goto out;
+
+		/*
+		 * If the PHY ID is still unknown, we may have an 82577i
+		 * without link.  We will try again after setting Slow
+		 * MDIC mode. No harm in trying again in this case since
+		 * the PHY ID is unknown at this point anyway
+		 */
+		ret_val = e1000_set_mdio_slow_mode_hv(hw, true);
+		if (ret_val)
+			goto out;
+
+		retry_count++;
+	}
+out:
+	/* Revert to MDIO fast mode, if applicable */
+	if (retry_count)
+		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
+
+	return ret_val;
 }
 
 /**
@@ -410,6 +487,43 @@ s32 e1000e_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data)
 }
 
 /**
+ *  e1000_copper_link_setup_82577 - Setup 82577 PHY for copper link
+ *  @hw: pointer to the HW structure
+ *
+ *  Sets up Carrier-sense on Transmit and downshift values.
+ **/
+s32 e1000_copper_link_setup_82577(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 phy_data;
+
+	/* Enable CRS on TX. This must be set for half-duplex operation. */
+	ret_val = phy->ops.read_phy_reg(hw, I82577_CFG_REG, &phy_data);
+	if (ret_val)
+		goto out;
+
+	phy_data |= I82577_CFG_ASSERT_CRS_ON_TX;
+
+	/* Enable downshift */
+	phy_data |= I82577_CFG_ENABLE_DOWNSHIFT;
+
+	ret_val = phy->ops.write_phy_reg(hw, I82577_CFG_REG, phy_data);
+	if (ret_val)
+		goto out;
+
+	/* Set number of link attempts before downshift */
+	ret_val = phy->ops.read_phy_reg(hw, I82577_CTRL_REG, &phy_data);
+	if (ret_val)
+		goto out;
+	phy_data &= ~I82577_CTRL_DOWNSHIFT_MASK;
+	ret_val = phy->ops.write_phy_reg(hw, I82577_CTRL_REG, phy_data);
+
+out:
+	return ret_val;
+}
+
+/**
  *  e1000e_copper_link_setup_m88 - Setup m88 PHY's for copper link
  *  @hw: pointer to the HW structure
  *
@@ -427,8 +541,8 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 	if (ret_val)
 		return ret_val;
 
-	/* For newer PHYs this bit is downshift enable */
-	if (phy->type == e1000_phy_m88)
+	/* For BM PHY this bit is downshift enable */
+	if (phy->type != e1000_phy_bm)
 		phy_data |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
 
 	/*
@@ -520,10 +634,27 @@ s32 e1000e_copper_link_setup_m88(struct e1000_hw *hw)
 
 	/* Commit the changes. */
 	ret_val = e1000e_commit_phy(hw);
-	if (ret_val)
+	if (ret_val) {
 		hw_dbg(hw, "Error committing the PHY changes\n");
+		return ret_val;
+	}
 
-	return ret_val;
+	if (phy->type == e1000_phy_82578) {
+		ret_val = phy->ops.read_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
+		                            &phy_data);
+		if (ret_val)
+			return ret_val;
+
+		/* 82578 PHY - set the downshift count to 1x. */
+		phy_data |= I82578_EPSCR_DOWNSHIFT_ENABLE;
+		phy_data &= ~I82578_EPSCR_DOWNSHIFT_COUNTER_MASK;
+		ret_val = phy->ops.write_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL,
+		                             phy_data);
+		if (ret_val)
+			return ret_val;
+	}
+
+	return 0;
 }
 
 /**
@@ -1251,6 +1382,8 @@ s32 e1000e_check_downshift(struct e1000_hw *hw)
 	switch (phy->type) {
 	case e1000_phy_m88:
 	case e1000_phy_gg82563:
+	case e1000_phy_82578:
+	case e1000_phy_82577:
 		offset	= M88E1000_PHY_SPEC_STATUS;
 		mask	= M88E1000_PSSR_DOWNSHIFT;
 		break;
@@ -1886,6 +2019,12 @@ enum e1000_phy_type e1000e_get_phy_type_from_id(u32 phy_id)
 	case BME1000_E_PHY_ID_R2:
 		phy_type = e1000_phy_bm;
 		break;
+	case I82578_E_PHY_ID:
+		phy_type = e1000_phy_82578;
+		break;
+	case I82577_E_PHY_ID:
+		phy_type = e1000_phy_82577;
+		break;
 	default:
 		phy_type = e1000_phy_unknown;
 		break;
@@ -2181,11 +2320,16 @@ static s32 e1000_access_phy_wakeup_reg_bm(struct e1000_hw *hw, u32 offset,
 					  u16 *data, bool read)
 {
 	s32 ret_val;
-	u16 reg = ((u16)offset) & PHY_REG_MASK;
+	u16 reg = BM_PHY_REG_NUM(offset);
 	u16 phy_reg = 0;
 	u8  phy_acquired = 1;
 
 
+	/* Gig must be disabled for MDIO accesses to page 800 */
+	if ((hw->mac.type == e1000_pchlan) &&
+	   (!(er32(PHY_CTRL) & E1000_PHY_CTRL_GBE_DISABLE)))
+		hw_dbg(hw, "Attempting to access page 800 while gig enabled\n");
+
 	ret_val = hw->phy.ops.acquire_phy(hw);
 	if (ret_val) {
 		phy_acquired = 0;
@@ -2289,3 +2433,524 @@ static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
 
 	return 0;
 }
+
+s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw, bool slow)
+{
+	s32 ret_val = 0;
+	u16 data = 0;
+
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		return ret_val;
+
+	/* Set MDIO mode - page 769, register 16: 0x2580==slow, 0x2180==fast */
+	hw->phy.addr = 1;
+	ret_val = e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT,
+				         (BM_PORT_CTRL_PAGE << IGP_PAGE_SHIFT));
+	if (ret_val) {
+		hw->phy.ops.release_phy(hw);
+		return ret_val;
+	}
+	ret_val = e1000e_write_phy_reg_mdic(hw, BM_CS_CTRL1,
+	                                   (0x2180 | (slow << 10)));
+
+	/* dummy read when reverting to fast mode - throw away result */
+	if (!slow)
+		e1000e_read_phy_reg_mdic(hw, BM_CS_CTRL1, &data);
+
+	hw->phy.ops.release_phy(hw);
+
+	return ret_val;
+}
+
+/**
+ *  e1000_read_phy_reg_hv -  Read HV PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read
+ *  @data: pointer to the read data
+ *
+ *  Acquires semaphore, if necessary, then reads the PHY register at offset
+ *  and storing the retrieved information in data.  Release any acquired
+ *  semaphore before exiting.
+ **/
+s32 e1000_read_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 *data)
+{
+	s32 ret_val;
+	u16 page = BM_PHY_REG_PAGE(offset);
+	u16 reg = BM_PHY_REG_NUM(offset);
+	bool in_slow_mode = false;
+
+	/* Workaround failure in MDIO access while cable is disconnected */
+	if ((hw->phy.type == e1000_phy_82577) &&
+	    !(er32(STATUS) & E1000_STATUS_LU)) {
+		ret_val = e1000_set_mdio_slow_mode_hv(hw, true);
+		if (ret_val)
+			goto out;
+
+		in_slow_mode = true;
+	}
+
+	/* Page 800 works differently than the rest so it has its own func */
+	if (page == BM_WUC_PAGE) {
+		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset,
+		                                         data, true);
+		goto out;
+	}
+
+	if (page > 0 && page < HV_INTC_FC_PAGE_START) {
+		ret_val = e1000_access_phy_debug_regs_hv(hw, offset,
+		                                         data, true);
+		goto out;
+	}
+
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		goto out;
+
+	hw->phy.addr = e1000_get_phy_addr_for_hv_page(page);
+
+	if (page == HV_INTC_FC_PAGE_START)
+		page = 0;
+
+	if (reg > MAX_PHY_MULTI_PAGE_REG) {
+		if ((hw->phy.type != e1000_phy_82578) ||
+		    ((reg != I82578_ADDR_REG) &&
+		     (reg != I82578_ADDR_REG + 1))) {
+			u32 phy_addr = hw->phy.addr;
+
+			hw->phy.addr = 1;
+
+			/* Page is shifted left, PHY expects (page x 32) */
+			ret_val = e1000e_write_phy_reg_mdic(hw,
+			                             IGP01E1000_PHY_PAGE_SELECT,
+			                             (page << IGP_PAGE_SHIFT));
+			if (ret_val) {
+				hw->phy.ops.release_phy(hw);
+				goto out;
+			}
+			hw->phy.addr = phy_addr;
+		}
+	}
+
+	ret_val = e1000e_read_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & reg,
+	                                  data);
+	hw->phy.ops.release_phy(hw);
+
+out:
+	/* Revert to MDIO fast mode, if applicable */
+	if ((hw->phy.type == e1000_phy_82577) && in_slow_mode)
+		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
+
+	return ret_val;
+}
+
+/**
+ *  e1000_write_phy_reg_hv - Write HV PHY register
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to write to
+ *  @data: data to write at register offset
+ *
+ *  Acquires semaphore, if necessary, then writes the data to PHY register
+ *  at the offset.  Release any acquired semaphores before exiting.
+ **/
+s32 e1000_write_phy_reg_hv(struct e1000_hw *hw, u32 offset, u16 data)
+{
+	s32 ret_val;
+	u16 page = BM_PHY_REG_PAGE(offset);
+	u16 reg = BM_PHY_REG_NUM(offset);
+	bool in_slow_mode = false;
+
+	/* Workaround failure in MDIO access while cable is disconnected */
+	if ((hw->phy.type == e1000_phy_82577) &&
+	    !(er32(STATUS) & E1000_STATUS_LU)) {
+		ret_val = e1000_set_mdio_slow_mode_hv(hw, true);
+		if (ret_val)
+			goto out;
+
+		in_slow_mode = true;
+	}
+
+	/* Page 800 works differently than the rest so it has its own func */
+	if (page == BM_WUC_PAGE) {
+		ret_val = e1000_access_phy_wakeup_reg_bm(hw, offset,
+		                                         &data, false);
+		goto out;
+	}
+
+	if (page > 0 && page < HV_INTC_FC_PAGE_START) {
+		ret_val = e1000_access_phy_debug_regs_hv(hw, offset,
+		                                         &data, false);
+		goto out;
+	}
+
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val)
+		goto out;
+
+	hw->phy.addr = e1000_get_phy_addr_for_hv_page(page);
+
+	if (page == HV_INTC_FC_PAGE_START)
+		page = 0;
+
+	/*
+	 * Workaround MDIO accesses being disabled after entering IEEE Power
+	 * Down (whenever bit 11 of the PHY Control register is set)
+	 */
+	if ((hw->phy.type == e1000_phy_82578) &&
+	    (hw->phy.revision >= 1) &&
+	    (hw->phy.addr == 2) &&
+	    ((MAX_PHY_REG_ADDRESS & reg) == 0) &&
+	    (data & (1 << 11))) {
+		u16 data2 = 0x7EFF;
+		hw->phy.ops.release_phy(hw);
+		ret_val = e1000_access_phy_debug_regs_hv(hw, (1 << 6) | 0x3,
+		                                         &data2, false);
+		if (ret_val)
+			goto out;
+
+		ret_val = hw->phy.ops.acquire_phy(hw);
+		if (ret_val)
+			goto out;
+	}
+
+	if (reg > MAX_PHY_MULTI_PAGE_REG) {
+		if ((hw->phy.type != e1000_phy_82578) ||
+		    ((reg != I82578_ADDR_REG) &&
+		     (reg != I82578_ADDR_REG + 1))) {
+			u32 phy_addr = hw->phy.addr;
+
+			hw->phy.addr = 1;
+
+			/* Page is shifted left, PHY expects (page x 32) */
+			ret_val = e1000e_write_phy_reg_mdic(hw,
+			                             IGP01E1000_PHY_PAGE_SELECT,
+			                             (page << IGP_PAGE_SHIFT));
+			if (ret_val) {
+				hw->phy.ops.release_phy(hw);
+				goto out;
+			}
+			hw->phy.addr = phy_addr;
+		}
+	}
+
+	ret_val = e1000e_write_phy_reg_mdic(hw, MAX_PHY_REG_ADDRESS & reg,
+	                                  data);
+	hw->phy.ops.release_phy(hw);
+
+out:
+	/* Revert to MDIO fast mode, if applicable */
+	if ((hw->phy.type == e1000_phy_82577) && in_slow_mode)
+		ret_val = e1000_set_mdio_slow_mode_hv(hw, false);
+
+	return ret_val;
+}
+
+/**
+ *  e1000_get_phy_addr_for_hv_page - Get PHY adrress based on page
+ *  @page: page to be accessed
+ **/
+static u32 e1000_get_phy_addr_for_hv_page(u32 page)
+{
+	u32 phy_addr = 2;
+
+	if (page >= HV_INTC_FC_PAGE_START)
+		phy_addr = 1;
+
+	return phy_addr;
+}
+
+/**
+ *  e1000_access_phy_debug_regs_hv - Read HV PHY vendor specific high registers
+ *  @hw: pointer to the HW structure
+ *  @offset: register offset to be read or written
+ *  @data: pointer to the data to be read or written
+ *  @read: determines if operation is read or written
+ *
+ *  Acquires semaphore, if necessary, then reads the PHY register at offset
+ *  and storing the retreived information in data.  Release any acquired
+ *  semaphores before exiting.  Note that the procedure to read these regs
+ *  uses the address port and data port to read/write.
+ **/
+static s32 e1000_access_phy_debug_regs_hv(struct e1000_hw *hw, u32 offset,
+                                          u16 *data, bool read)
+{
+	s32 ret_val;
+	u32 addr_reg = 0;
+	u32 data_reg = 0;
+	u8  phy_acquired = 1;
+
+	/* This takes care of the difference with desktop vs mobile phy */
+	addr_reg = (hw->phy.type == e1000_phy_82578) ?
+	           I82578_ADDR_REG : I82577_ADDR_REG;
+	data_reg = addr_reg + 1;
+
+	ret_val = hw->phy.ops.acquire_phy(hw);
+	if (ret_val) {
+		hw_dbg(hw, "Could not acquire PHY\n");
+		phy_acquired = 0;
+		goto out;
+	}
+
+	/* All operations in this function are phy address 2 */
+	hw->phy.addr = 2;
+
+	/* masking with 0x3F to remove the page from offset */
+	ret_val = e1000e_write_phy_reg_mdic(hw, addr_reg, (u16)offset & 0x3F);
+	if (ret_val) {
+		hw_dbg(hw, "Could not write PHY the HV address register\n");
+		goto out;
+	}
+
+	/* Read or write the data value next */
+	if (read)
+		ret_val = e1000e_read_phy_reg_mdic(hw, data_reg, data);
+	else
+		ret_val = e1000e_write_phy_reg_mdic(hw, data_reg, *data);
+
+	if (ret_val) {
+		hw_dbg(hw, "Could not read data value from HV data register\n");
+		goto out;
+	}
+
+out:
+	if (phy_acquired == 1)
+		hw->phy.ops.release_phy(hw);
+	return ret_val;
+}
+
+/**
+ *  e1000_link_stall_workaround_hv - Si workaround
+ *  @hw: pointer to the HW structure
+ *
+ *  This function works around a Si bug where the link partner can get
+ *  a link up indication before the PHY does.  If small packets are sent
+ *  by the link partner they can be placed in the packet buffer without
+ *  being properly accounted for by the PHY and will stall preventing
+ *  further packets from being received.  The workaround is to clear the
+ *  packet buffer after the PHY detects link up.
+ **/
+s32 e1000_link_stall_workaround_hv(struct e1000_hw *hw)
+{
+	s32 ret_val = 0;
+	u16 data;
+
+	if (hw->phy.type != e1000_phy_82578)
+		goto out;
+
+	/* check if link is up and at 1Gbps */
+	ret_val = hw->phy.ops.read_phy_reg(hw, BM_CS_STATUS, &data);
+	if (ret_val)
+		goto out;
+
+	data &= BM_CS_STATUS_LINK_UP |
+	        BM_CS_STATUS_RESOLVED |
+	        BM_CS_STATUS_SPEED_MASK;
+
+	if (data != (BM_CS_STATUS_LINK_UP |
+	             BM_CS_STATUS_RESOLVED |
+	             BM_CS_STATUS_SPEED_1000))
+		goto out;
+
+	mdelay(200);
+
+	/* flush the packets in the fifo buffer */
+	ret_val = hw->phy.ops.write_phy_reg(hw, HV_MUX_DATA_CTRL,
+	                                HV_MUX_DATA_CTRL_GEN_TO_MAC |
+	                                HV_MUX_DATA_CTRL_FORCE_SPEED);
+	if (ret_val)
+		goto out;
+
+	ret_val = hw->phy.ops.write_phy_reg(hw, HV_MUX_DATA_CTRL,
+	                                HV_MUX_DATA_CTRL_GEN_TO_MAC);
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_check_polarity_82577 - Checks the polarity.
+ *  @hw: pointer to the HW structure
+ *
+ *  Success returns 0, Failure returns -E1000_ERR_PHY (-2)
+ *
+ *  Polarity is determined based on the PHY specific status register.
+ **/
+s32 e1000_check_polarity_82577(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 data;
+
+	ret_val = phy->ops.read_phy_reg(hw, I82577_PHY_STATUS_2, &data);
+
+	if (!ret_val)
+		phy->cable_polarity = (data & I82577_PHY_STATUS2_REV_POLARITY)
+		                      ? e1000_rev_polarity_reversed
+		                      : e1000_rev_polarity_normal;
+
+	return ret_val;
+}
+
+/**
+ *  e1000_phy_force_speed_duplex_82577 - Force speed/duplex for I82577 PHY
+ *  @hw: pointer to the HW structure
+ *
+ *  Calls the PHY setup function to force speed and duplex.  Clears the
+ *  auto-crossover to force MDI manually.  Waits for link and returns
+ *  successful if link up is successful, else -E1000_ERR_PHY (-2).
+ **/
+s32 e1000_phy_force_speed_duplex_82577(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 phy_data;
+	bool link;
+
+	ret_val = phy->ops.read_phy_reg(hw, PHY_CONTROL, &phy_data);
+	if (ret_val)
+		goto out;
+
+	e1000e_phy_force_speed_duplex_setup(hw, &phy_data);
+
+	ret_val = phy->ops.write_phy_reg(hw, PHY_CONTROL, phy_data);
+	if (ret_val)
+		goto out;
+
+	/*
+	 * Clear Auto-Crossover to force MDI manually.  82577 requires MDI
+	 * forced whenever speed and duplex are forced.
+	 */
+	ret_val = phy->ops.read_phy_reg(hw, I82577_PHY_CTRL_2, &phy_data);
+	if (ret_val)
+		goto out;
+
+	phy_data &= ~I82577_PHY_CTRL2_AUTO_MDIX;
+	phy_data &= ~I82577_PHY_CTRL2_FORCE_MDI_MDIX;
+
+	ret_val = phy->ops.write_phy_reg(hw, I82577_PHY_CTRL_2, phy_data);
+	if (ret_val)
+		goto out;
+
+	hw_dbg(hw, "I82577_PHY_CTRL_2: %X\n", phy_data);
+
+	udelay(1);
+
+	if (phy->autoneg_wait_to_complete) {
+		hw_dbg(hw, "Waiting for forced speed/duplex link on 82577 phy\n");
+
+		ret_val = e1000e_phy_has_link_generic(hw,
+		                                     PHY_FORCE_LIMIT,
+		                                     100000,
+		                                     &link);
+		if (ret_val)
+			goto out;
+
+		if (!link)
+			hw_dbg(hw, "Link taking longer than expected.\n");
+
+		/* Try once more */
+		ret_val = e1000e_phy_has_link_generic(hw,
+		                                     PHY_FORCE_LIMIT,
+		                                     100000,
+		                                     &link);
+		if (ret_val)
+			goto out;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_get_phy_info_82577 - Retrieve I82577 PHY information
+ *  @hw: pointer to the HW structure
+ *
+ *  Read PHY status to determine if link is up.  If link is up, then
+ *  set/determine 10base-T extended distance and polarity correction.  Read
+ *  PHY port status to determine MDI/MDIx and speed.  Based on the speed,
+ *  determine on the cable length, local and remote receiver.
+ **/
+s32 e1000_get_phy_info_82577(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 data;
+	bool link;
+
+	ret_val = e1000e_phy_has_link_generic(hw, 1, 0, &link);
+	if (ret_val)
+		goto out;
+
+	if (!link) {
+		hw_dbg(hw, "Phy info is only valid if link is up\n");
+		ret_val = -E1000_ERR_CONFIG;
+		goto out;
+	}
+
+	phy->polarity_correction = true;
+
+	ret_val = e1000_check_polarity_82577(hw);
+	if (ret_val)
+		goto out;
+
+	ret_val = phy->ops.read_phy_reg(hw, I82577_PHY_STATUS_2, &data);
+	if (ret_val)
+		goto out;
+
+	phy->is_mdix = (data & I82577_PHY_STATUS2_MDIX) ? true : false;
+
+	if ((data & I82577_PHY_STATUS2_SPEED_MASK) ==
+	    I82577_PHY_STATUS2_SPEED_1000MBPS) {
+		ret_val = hw->phy.ops.get_cable_length(hw);
+		if (ret_val)
+			goto out;
+
+		ret_val = phy->ops.read_phy_reg(hw, PHY_1000T_STATUS, &data);
+		if (ret_val)
+			goto out;
+
+		phy->local_rx = (data & SR_1000T_LOCAL_RX_STATUS)
+		                ? e1000_1000t_rx_status_ok
+		                : e1000_1000t_rx_status_not_ok;
+
+		phy->remote_rx = (data & SR_1000T_REMOTE_RX_STATUS)
+		                 ? e1000_1000t_rx_status_ok
+		                 : e1000_1000t_rx_status_not_ok;
+	} else {
+		phy->cable_length = E1000_CABLE_LENGTH_UNDEFINED;
+		phy->local_rx = e1000_1000t_rx_status_undefined;
+		phy->remote_rx = e1000_1000t_rx_status_undefined;
+	}
+
+out:
+	return ret_val;
+}
+
+/**
+ *  e1000_get_cable_length_82577 - Determine cable length for 82577 PHY
+ *  @hw: pointer to the HW structure
+ *
+ * Reads the diagnostic status register and verifies result is valid before
+ * placing it in the phy_cable_length field.
+ **/
+s32 e1000_get_cable_length_82577(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 phy_data, length;
+
+	ret_val = phy->ops.read_phy_reg(hw, I82577_PHY_DIAG_STATUS, &phy_data);
+	if (ret_val)
+		goto out;
+
+	length = (phy_data & I82577_DSTATUS_CABLE_LENGTH) >>
+	         I82577_DSTATUS_CABLE_LENGTH_SHIFT;
+
+	if (length == E1000_CABLE_LENGTH_UNDEFINED)
+		ret_val = E1000_ERR_PHY;
+
+	phy->cable_length = length;
+
+out:
+	return ret_val;
+}

