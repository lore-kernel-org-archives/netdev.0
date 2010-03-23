From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] igb: add support for Intel I350 Gigabit
	Network Connection
Date: Mon, 22 Mar 2010 17:08:06 -0700
Message-ID: <20100323000804.19939.27632.stgit@localhost.localdomain>
References: <20100323000724.19939.17642.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	James Hearn <james.r.hearn@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.westchester.pa.mail.comcast.net ([76.96.59.212]:46592
	"EHLO qmta14.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754328Ab0CWAI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 20:08:27 -0400
In-Reply-To: <20100323000724.19939.17642.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for the the I350 Gigabit network connection which
is the follow-on part to the 82580.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: James Hearn <james.r.hearn@intel.com>
---

 drivers/net/igb/e1000_82575.c   |   13 +++++++++-
 drivers/net/igb/e1000_82575.h   |    7 +++--
 drivers/net/igb/e1000_defines.h |    1 +
 drivers/net/igb/e1000_hw.h      |    5 ++++
 drivers/net/igb/igb_ethtool.c   |   50 +++++++++++++++++++++++++++++++++++++++
 drivers/net/igb/igb_main.c      |   12 +++++++++
 6 files changed, 83 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index ea944f5..430631f 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -105,6 +105,12 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	case E1000_DEV_ID_82580_COPPER_DUAL:
 		mac->type = e1000_82580;
 		break;
+	case E1000_DEV_ID_I350_COPPER:
+	case E1000_DEV_ID_I350_FIBER:
+	case E1000_DEV_ID_I350_SERDES:
+	case E1000_DEV_ID_I350_SGMII:
+		mac->type = e1000_i350;
+		break;
 	default:
 		return -E1000_ERR_MAC_INIT;
 		break;
@@ -154,8 +160,10 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		mac->rar_entry_count = E1000_RAR_ENTRIES_82576;
 	if (mac->type == e1000_82580)
 		mac->rar_entry_count = E1000_RAR_ENTRIES_82580;
+	if (mac->type == e1000_i350)
+		mac->rar_entry_count = E1000_RAR_ENTRIES_I350;
 	/* reset */
-	if (mac->type == e1000_82580)
+	if (mac->type >= e1000_82580)
 		mac->ops.reset_hw = igb_reset_hw_82580;
 	else
 		mac->ops.reset_hw = igb_reset_hw_82575;
@@ -226,7 +234,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		phy->ops.reset              = igb_phy_hw_reset_sgmii_82575;
 		phy->ops.read_reg           = igb_read_phy_reg_sgmii_82575;
 		phy->ops.write_reg          = igb_write_phy_reg_sgmii_82575;
-	} else if (hw->mac.type == e1000_82580) {
+	} else if (hw->mac.type >= e1000_82580) {
 		phy->ops.reset              = igb_phy_hw_reset;
 		phy->ops.read_reg           = igb_read_phy_reg_82580;
 		phy->ops.write_reg          = igb_write_phy_reg_82580;
@@ -262,6 +270,7 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 		phy->ops.set_d3_lplu_state  = igb_set_d3_lplu_state;
 		break;
 	case I82580_I_PHY_ID:
+	case I350_I_PHY_ID:
 		phy->type                   = e1000_phy_82580;
 		phy->ops.force_speed_duplex = igb_phy_force_speed_duplex_82580;
 		phy->ops.get_cable_length   = igb_get_cable_length_82580;
diff --git a/drivers/net/igb/e1000_82575.h b/drivers/net/igb/e1000_82575.h
index fbe1c99..c1cad8a 100644
--- a/drivers/net/igb/e1000_82575.h
+++ b/drivers/net/igb/e1000_82575.h
@@ -38,9 +38,10 @@ extern void igb_rx_fifo_flush_82575(struct e1000_hw *hw);
                                      (ID_LED_DEF1_DEF2 <<  4) | \
                                      (ID_LED_OFF1_ON2))
 
-#define E1000_RAR_ENTRIES_82575   16
-#define E1000_RAR_ENTRIES_82576   24
-#define E1000_RAR_ENTRIES_82580   24
+#define E1000_RAR_ENTRIES_82575        16
+#define E1000_RAR_ENTRIES_82576        24
+#define E1000_RAR_ENTRIES_82580        24
+#define E1000_RAR_ENTRIES_I350         32
 
 #define E1000_SW_SYNCH_MB              0x00000100
 #define E1000_STAT_DEV_RST_SET         0x00100000
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index fe6cf1b..31d24e0 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -629,6 +629,7 @@
 #define M88E1111_I_PHY_ID    0x01410CC0
 #define IGP03E1000_E_PHY_ID  0x02A80390
 #define I82580_I_PHY_ID      0x015403A0
+#define I350_I_PHY_ID        0x015403B0
 #define M88_VENDOR           0x0141
 
 /* M88E1000 Specific Registers */
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index 82a533f..593d5fa 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -53,6 +53,10 @@ struct e1000_hw;
 #define E1000_DEV_ID_82580_SERDES             0x1510
 #define E1000_DEV_ID_82580_SGMII              0x1511
 #define E1000_DEV_ID_82580_COPPER_DUAL        0x1516
+#define E1000_DEV_ID_I350_COPPER              0x1521
+#define E1000_DEV_ID_I350_FIBER               0x1522
+#define E1000_DEV_ID_I350_SERDES              0x1523
+#define E1000_DEV_ID_I350_SGMII               0x1524
 
 #define E1000_REVISION_2 2
 #define E1000_REVISION_4 4
@@ -72,6 +76,7 @@ enum e1000_mac_type {
 	e1000_82575,
 	e1000_82576,
 	e1000_82580,
+	e1000_i350,
 	e1000_num_macs  /* List is 1-based, so subtract 1 for true count. */
 };
 
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index a4cead1..1d4ee41 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -901,6 +901,49 @@ struct igb_reg_test {
 #define TABLE64_TEST_LO	5
 #define TABLE64_TEST_HI	6
 
+/* i350 reg test */
+static struct igb_reg_test reg_test_i350[] = {
+	{ E1000_FCAL,	   0x100, 1,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_FCAH,	   0x100, 1,  PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
+	{ E1000_FCT,	   0x100, 1,  PATTERN_TEST, 0x0000FFFF, 0xFFFFFFFF },
+	{ E1000_VET,	   0x100, 1,  PATTERN_TEST, 0xFFFF0000, 0xFFFF0000 },
+	{ E1000_RDBAL(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_RDBAH(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDLEN(0),  0x100, 4,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_RDBAL(4),  0x40,  4,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_RDBAH(4),  0x40,  4,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RDLEN(4),  0x40,  4,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	/* RDH is read-only for i350, only test RDT. */
+	{ E1000_RDT(0),	   0x100, 4,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_RDT(4),	   0x40,  4,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_FCRTH,	   0x100, 1,  PATTERN_TEST, 0x0000FFF0, 0x0000FFF0 },
+	{ E1000_FCTTV,	   0x100, 1,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_TIPG,	   0x100, 1,  PATTERN_TEST, 0x3FFFFFFF, 0x3FFFFFFF },
+	{ E1000_TDBAL(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_TDBAH(0),  0x100, 4,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_TDLEN(0),  0x100, 4,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_TDBAL(4),  0x40,  4,  PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ E1000_TDBAH(4),  0x40,  4,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_TDLEN(4),  0x40,  4,  PATTERN_TEST, 0x000FFFF0, 0x000FFFFF },
+	{ E1000_TDT(0),	   0x100, 4,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_TDT(4),	   0x40,  4,  PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ E1000_RCTL,	   0x100, 1,  SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
+	{ E1000_RCTL, 	   0x100, 1,  SET_READ_TEST, 0x04CFB0FE, 0x003FFFFB },
+	{ E1000_RCTL, 	   0x100, 1,  SET_READ_TEST, 0x04CFB0FE, 0xFFFFFFFF },
+	{ E1000_TCTL,	   0x100, 1,  SET_READ_TEST, 0xFFFFFFFF, 0x00000000 },
+	{ E1000_RA,	   0, 16, TABLE64_TEST_LO,
+						0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RA,	   0, 16, TABLE64_TEST_HI,
+						0xC3FFFFFF, 0xFFFFFFFF },
+	{ E1000_RA2,	   0, 16, TABLE64_TEST_LO,
+						0xFFFFFFFF, 0xFFFFFFFF },
+	{ E1000_RA2,	   0, 16, TABLE64_TEST_HI,
+						0xC3FFFFFF, 0xFFFFFFFF },
+	{ E1000_MTA,	   0, 128, TABLE32_TEST,
+						0xFFFFFFFF, 0xFFFFFFFF },
+	{ 0, 0, 0, 0 }
+};
+
 /* 82580 reg test */
 static struct igb_reg_test reg_test_82580[] = {
 	{ E1000_FCAL,	   0x100, 1,  PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
@@ -1076,6 +1119,10 @@ static int igb_reg_test(struct igb_adapter *adapter, u64 *data)
 	u32 i, toggle;
 
 	switch (adapter->hw.mac.type) {
+	case e1000_i350:
+		test = reg_test_i350;
+		toggle = 0x7FEFF3FF;
+		break;
 	case e1000_82580:
 		test = reg_test_82580;
 		toggle = 0x7FEFF3FF;
@@ -1237,6 +1284,9 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 	case e1000_82580:
 		ics_mask = 0x77DCFED5;
 		break;
+	case e1000_i350:
+		ics_mask = 0x77DCFED5;
+		break;
 	default:
 		ics_mask = 0x7FFFFFFF;
 		break;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 61029e8..d732280 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -61,6 +61,10 @@ static const struct e1000_info *igb_info_tbl[] = {
 };
 
 static DEFINE_PCI_DEVICE_TABLE(igb_pci_tbl) = {
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I350_COPPER), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I350_FIBER), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I350_SERDES), board_82575 },
+	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_I350_SGMII), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_COPPER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_FIBER), board_82575 },
 	{ PCI_VDEVICE(INTEL, E1000_DEV_ID_82580_SERDES), board_82575 },
@@ -327,6 +331,7 @@ static void igb_cache_ring_register(struct igb_adapter *adapter)
 		}
 	case e1000_82575:
 	case e1000_82580:
+	case e1000_i350:
 	default:
 		for (; i < adapter->num_rx_queues; i++)
 			adapter->rx_ring[i]->reg_idx = rbase_offset + i;
@@ -470,6 +475,7 @@ static void igb_assign_vector(struct igb_q_vector *q_vector, int msix_vector)
 		q_vector->eims_value = 1 << msix_vector;
 		break;
 	case e1000_82580:
+	case e1000_i350:
 		/* 82580 uses the same table-based approach as 82576 but has fewer
 		   entries as a result we carry over for queues greater than 4. */
 		if (rx_queue > IGB_N0_QUEUE) {
@@ -550,6 +556,7 @@ static void igb_configure_msix(struct igb_adapter *adapter)
 
 	case e1000_82576:
 	case e1000_82580:
+	case e1000_i350:
 		/* Turn on MSI-X capability first, or our settings
 		 * won't stick.  And it will take days to debug. */
 		wr32(E1000_GPIE, E1000_GPIE_MSIX_MODE |
@@ -1271,6 +1278,7 @@ void igb_reset(struct igb_adapter *adapter)
 	 * To take effect CTRL.RST is required.
 	 */
 	switch (mac->type) {
+	case e1000_i350:
 	case e1000_82580:
 		pba = rd32(E1000_RXPBS);
 		pba = igb_rxpbs_adjust_82580(pba);
@@ -1847,6 +1855,7 @@ static void igb_init_hw_timer(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 
 	switch (hw->mac.type) {
+	case e1000_i350:
 	case e1000_82580:
 		memset(&adapter->cycles, 0, sizeof(adapter->cycles));
 		adapter->cycles.read = igb_read_clock;
@@ -2362,6 +2371,7 @@ static void igb_setup_mrqc(struct igb_adapter *adapter)
 	if (adapter->vfs_allocated_count) {
 		/* 82575 and 82576 supports 2 RSS queues for VMDq */
 		switch (hw->mac.type) {
+		case e1000_i350:
 		case e1000_82580:
 			num_rx_queues = 1;
 			shift = 0;
@@ -6173,6 +6183,8 @@ static void igb_vmm_control(struct igb_adapter *adapter)
 		reg = rd32(E1000_RPLOLR);
 		reg |= E1000_RPLOLR_STRVLAN;
 		wr32(E1000_RPLOLR, reg);
+	case e1000_i350:
+		/* none of the above registers are supported by i350 */
 		break;
 	}
 

