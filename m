From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 2/9] e1000: Use hw, er32, and ew32
Date: Fri, 11 Jul 2008 15:17:08 -0700
Message-ID: <20080711221708.3255.43873.stgit@localhost.localdomain>
References: <20080711221442.3255.16180.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Joe Perches <joe@perches.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:53062 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756326AbYGKWRM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 18:17:12 -0400
In-Reply-To: <20080711221442.3255.16180.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Use struct e1000_hw *hw = adapter->hw; where necessary
Change macros E1000_READ_REG and E1000_WRITE_REG to er32 and ew32

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Joe Perches <joe@perches.com>
---

 drivers/net/e1000/e1000_ethtool.c |  313 +++++++------
 drivers/net/e1000/e1000_hw.c      |  762 +++++++++++++++----------------
 drivers/net/e1000/e1000_main.c    |  918 +++++++++++++++++++------------------
 drivers/net/e1000/e1000_osdep.h   |   14 -
 4 files changed, 1033 insertions(+), 974 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 4bcfa37..966d52a 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -162,7 +162,7 @@ static int e1000_get_settings(struct net_device *netdev,
 			ecmd->transceiver = XCVR_EXTERNAL;
 	}
 
-	if (E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_LU) {
+	if (er32(STATUS) & E1000_STATUS_LU) {
 
 		e1000_get_speed_and_duplex(hw, &adapter->link_speed,
 		                                   &adapter->link_duplex);
@@ -313,8 +313,9 @@ static u32 e1000_get_tx_csum(struct net_device *netdev)
 static int e1000_set_tx_csum(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 
-	if (adapter->hw.mac_type < e1000_82543) {
+	if (hw->mac_type < e1000_82543) {
 		if (!data)
 			return -EINVAL;
 		return 0;
@@ -331,8 +332,10 @@ static int e1000_set_tx_csum(struct net_device *netdev, u32 data)
 static int e1000_set_tso(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	if ((adapter->hw.mac_type < e1000_82544) ||
-	    (adapter->hw.mac_type == e1000_82547))
+	struct e1000_hw *hw = &adapter->hw;
+
+	if ((hw->mac_type < e1000_82544) ||
+	    (hw->mac_type == e1000_82547))
 		return data ? -EINVAL : 0;
 
 	if (data)
@@ -380,22 +383,22 @@ static void e1000_get_regs(struct net_device *netdev, struct ethtool_regs *regs,
 
 	regs->version = (1 << 24) | (hw->revision_id << 16) | hw->device_id;
 
-	regs_buff[0]  = E1000_READ_REG(hw, CTRL);
-	regs_buff[1]  = E1000_READ_REG(hw, STATUS);
+	regs_buff[0]  = er32(CTRL);
+	regs_buff[1]  = er32(STATUS);
 
-	regs_buff[2]  = E1000_READ_REG(hw, RCTL);
-	regs_buff[3]  = E1000_READ_REG(hw, RDLEN);
-	regs_buff[4]  = E1000_READ_REG(hw, RDH);
-	regs_buff[5]  = E1000_READ_REG(hw, RDT);
-	regs_buff[6]  = E1000_READ_REG(hw, RDTR);
+	regs_buff[2]  = er32(RCTL);
+	regs_buff[3]  = er32(RDLEN);
+	regs_buff[4]  = er32(RDH);
+	regs_buff[5]  = er32(RDT);
+	regs_buff[6]  = er32(RDTR);
 
-	regs_buff[7]  = E1000_READ_REG(hw, TCTL);
-	regs_buff[8]  = E1000_READ_REG(hw, TDLEN);
-	regs_buff[9]  = E1000_READ_REG(hw, TDH);
-	regs_buff[10] = E1000_READ_REG(hw, TDT);
-	regs_buff[11] = E1000_READ_REG(hw, TIDV);
+	regs_buff[7]  = er32(TCTL);
+	regs_buff[8]  = er32(TDLEN);
+	regs_buff[9]  = er32(TDH);
+	regs_buff[10] = er32(TDT);
+	regs_buff[11] = er32(TIDV);
 
-	regs_buff[12] = adapter->hw.phy_type;  /* PHY type (IGP=1, M88=0) */
+	regs_buff[12] = hw->phy_type;  /* PHY type (IGP=1, M88=0) */
 	if (hw->phy_type == e1000_phy_igp) {
 		e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT,
 				    IGP01E1000_PHY_AGC_A);
@@ -453,14 +456,16 @@ static void e1000_get_regs(struct net_device *netdev, struct ethtool_regs *regs,
 	if (hw->mac_type >= e1000_82540 &&
 	    hw->mac_type < e1000_82571 &&
 	    hw->media_type == e1000_media_type_copper) {
-		regs_buff[26] = E1000_READ_REG(hw, MANC);
+		regs_buff[26] = er32(MANC);
 	}
 }
 
 static int e1000_get_eeprom_len(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	return adapter->hw.eeprom.word_size * 2;
+	struct e1000_hw *hw = &adapter->hw;
+
+	return hw->eeprom.word_size * 2;
 }
 
 static int e1000_get_eeprom(struct net_device *netdev,
@@ -574,6 +579,7 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 			      struct ethtool_drvinfo *drvinfo)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	char firmware_version[32];
 	u16 eeprom_data;
 
@@ -582,8 +588,8 @@ static void e1000_get_drvinfo(struct net_device *netdev,
 
 	/* EEPROM image version # is reported as firmware version # for
 	 * 8257{1|2|3} controllers */
-	e1000_read_eeprom(&adapter->hw, 5, 1, &eeprom_data);
-	switch (adapter->hw.mac_type) {
+	e1000_read_eeprom(hw, 5, 1, &eeprom_data);
+	switch (hw->mac_type) {
 	case e1000_82571:
 	case e1000_82572:
 	case e1000_82573:
@@ -608,7 +614,8 @@ static void e1000_get_ringparam(struct net_device *netdev,
 				struct ethtool_ringparam *ring)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	e1000_mac_type mac_type = adapter->hw.mac_type;
+	struct e1000_hw *hw = &adapter->hw;
+	e1000_mac_type mac_type = hw->mac_type;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	struct e1000_rx_ring *rxdr = adapter->rx_ring;
 
@@ -628,7 +635,8 @@ static int e1000_set_ringparam(struct net_device *netdev,
 			       struct ethtool_ringparam *ring)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	e1000_mac_type mac_type = adapter->hw.mac_type;
+	struct e1000_hw *hw = &adapter->hw;
+	e1000_mac_type mac_type = hw->mac_type;
 	struct e1000_tx_ring *txdr, *tx_old;
 	struct e1000_rx_ring *rxdr, *rx_old;
 	int i, err;
@@ -714,9 +722,10 @@ err_setup:
 static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data, int reg,
 			     u32 mask, u32 write)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	static const u32 test[] =
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
-	u8 __iomem *address = adapter->hw.hw_addr + reg;
+	u8 __iomem *address = hw->hw_addr + reg;
 	u32 read;
 	int i;
 
@@ -737,7 +746,8 @@ static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data, int reg,
 static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data, int reg,
 			      u32 mask, u32 write)
 {
-	u8 __iomem *address = adapter->hw.hw_addr + reg;
+	struct e1000_hw *hw = &adapter->hw;
+	u8 __iomem *address = hw->hw_addr + reg;
 	u32 read;
 
 	writel(write & mask, address);
@@ -755,7 +765,7 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data, int reg,
 #define REG_PATTERN_TEST(reg, mask, write)			     \
 	do {							     \
 		if (reg_pattern_test(adapter, data,		     \
-			     (adapter->hw.mac_type >= e1000_82543)   \
+			     (hw->mac_type >= e1000_82543)   \
 			     ? E1000_##reg : E1000_82542_##reg,	     \
 			     mask, write))			     \
 			return 1;				     \
@@ -764,7 +774,7 @@ static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data, int reg,
 #define REG_SET_AND_CHECK(reg, mask, write)			     \
 	do {							     \
 		if (reg_set_and_check(adapter, data,		     \
-			      (adapter->hw.mac_type >= e1000_82543)  \
+			      (hw->mac_type >= e1000_82543)  \
 			      ? E1000_##reg : E1000_82542_##reg,     \
 			      mask, write))			     \
 			return 1;				     \
@@ -774,11 +784,12 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 {
 	u32 value, before, after;
 	u32 i, toggle;
+	struct e1000_hw *hw = &adapter->hw;
 
 	/* The status register is Read Only, so a write should fail.
 	 * Some bits that get toggled are ignored.
 	 */
-	switch (adapter->hw.mac_type) {
+	switch (hw->mac_type) {
 	/* there are several bits on newer hardware that are r/w */
 	case e1000_82571:
 	case e1000_82572:
@@ -794,10 +805,10 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 		break;
 	}
 
-	before = E1000_READ_REG(&adapter->hw, STATUS);
-	value = (E1000_READ_REG(&adapter->hw, STATUS) & toggle);
-	E1000_WRITE_REG(&adapter->hw, STATUS, toggle);
-	after = E1000_READ_REG(&adapter->hw, STATUS) & toggle;
+	before = er32(STATUS);
+	value = (er32(STATUS) & toggle);
+	ew32(STATUS, toggle);
+	after = er32(STATUS) & toggle;
 	if (value != after) {
 		DPRINTK(DRV, ERR, "failed STATUS register test got: "
 		        "0x%08X expected: 0x%08X\n", after, value);
@@ -805,9 +816,9 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 		return 1;
 	}
 	/* restore previous status */
-	E1000_WRITE_REG(&adapter->hw, STATUS, before);
+	ew32(STATUS, before);
 
-	if (adapter->hw.mac_type != e1000_ich8lan) {
+	if (hw->mac_type != e1000_ich8lan) {
 		REG_PATTERN_TEST(FCAL, 0xFFFFFFFF, 0xFFFFFFFF);
 		REG_PATTERN_TEST(FCAH, 0x0000FFFF, 0xFFFFFFFF);
 		REG_PATTERN_TEST(FCT, 0x0000FFFF, 0xFFFFFFFF);
@@ -827,20 +838,20 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 
 	REG_SET_AND_CHECK(RCTL, 0xFFFFFFFF, 0x00000000);
 
-	before = (adapter->hw.mac_type == e1000_ich8lan ?
+	before = (hw->mac_type == e1000_ich8lan ?
 	          0x06C3B33E : 0x06DFB3FE);
 	REG_SET_AND_CHECK(RCTL, before, 0x003FFFFB);
 	REG_SET_AND_CHECK(TCTL, 0xFFFFFFFF, 0x00000000);
 
-	if (adapter->hw.mac_type >= e1000_82543) {
+	if (hw->mac_type >= e1000_82543) {
 
 		REG_SET_AND_CHECK(RCTL, before, 0xFFFFFFFF);
 		REG_PATTERN_TEST(RDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
-		if (adapter->hw.mac_type != e1000_ich8lan)
+		if (hw->mac_type != e1000_ich8lan)
 			REG_PATTERN_TEST(TXCW, 0xC000FFFF, 0x0000FFFF);
 		REG_PATTERN_TEST(TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
 		REG_PATTERN_TEST(TIDV, 0x0000FFFF, 0x0000FFFF);
-		value = (adapter->hw.mac_type == e1000_ich8lan ?
+		value = (hw->mac_type == e1000_ich8lan ?
 		         E1000_RAR_ENTRIES_ICH8LAN : E1000_RAR_ENTRIES);
 		for (i = 0; i < value; i++) {
 			REG_PATTERN_TEST(RA + (((i << 1) + 1) << 2), 0x8003FFFF,
@@ -856,7 +867,7 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 
 	}
 
-	value = (adapter->hw.mac_type == e1000_ich8lan ?
+	value = (hw->mac_type == e1000_ich8lan ?
 			E1000_MC_TBL_SIZE_ICH8LAN : E1000_MC_TBL_SIZE);
 	for (i = 0; i < value; i++)
 		REG_PATTERN_TEST(MTA + (i << 2), 0xFFFFFFFF, 0xFFFFFFFF);
@@ -867,6 +878,7 @@ static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
 
 static int e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u16 temp;
 	u16 checksum = 0;
 	u16 i;
@@ -874,7 +886,7 @@ static int e1000_eeprom_test(struct e1000_adapter *adapter, u64 *data)
 	*data = 0;
 	/* Read and add up the contents of the EEPROM */
 	for (i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++) {
-		if ((e1000_read_eeprom(&adapter->hw, i, 1, &temp)) < 0) {
+		if ((e1000_read_eeprom(hw, i, 1, &temp)) < 0) {
 			*data = 1;
 			break;
 		}
@@ -892,8 +904,9 @@ static irqreturn_t e1000_test_intr(int irq, void *data)
 {
 	struct net_device *netdev = (struct net_device *) data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 
-	adapter->test_icr |= E1000_READ_REG(&adapter->hw, ICR);
+	adapter->test_icr |= er32(ICR);
 
 	return IRQ_HANDLED;
 }
@@ -904,6 +917,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 	u32 mask, i = 0;
 	bool shared_int = true;
 	u32 irq = adapter->pdev->irq;
+	struct e1000_hw *hw = &adapter->hw;
 
 	*data = 0;
 
@@ -921,13 +935,13 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 	        (shared_int ? "shared" : "unshared"));
 
 	/* Disable all the interrupts */
-	E1000_WRITE_REG(&adapter->hw, IMC, 0xFFFFFFFF);
+	ew32(IMC, 0xFFFFFFFF);
 	msleep(10);
 
 	/* Test each interrupt */
 	for (; i < 10; i++) {
 
-		if (adapter->hw.mac_type == e1000_ich8lan && i == 8)
+		if (hw->mac_type == e1000_ich8lan && i == 8)
 			continue;
 
 		/* Interrupt to test */
@@ -941,8 +955,8 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 			 * test failed.
 			 */
 			adapter->test_icr = 0;
-			E1000_WRITE_REG(&adapter->hw, IMC, mask);
-			E1000_WRITE_REG(&adapter->hw, ICS, mask);
+			ew32(IMC, mask);
+			ew32(ICS, mask);
 			msleep(10);
 
 			if (adapter->test_icr & mask) {
@@ -958,8 +972,8 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		 * test failed.
 		 */
 		adapter->test_icr = 0;
-		E1000_WRITE_REG(&adapter->hw, IMS, mask);
-		E1000_WRITE_REG(&adapter->hw, ICS, mask);
+		ew32(IMS, mask);
+		ew32(ICS, mask);
 		msleep(10);
 
 		if (!(adapter->test_icr & mask)) {
@@ -975,8 +989,8 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 			 * test failed.
 			 */
 			adapter->test_icr = 0;
-			E1000_WRITE_REG(&adapter->hw, IMC, ~mask & 0x00007FFF);
-			E1000_WRITE_REG(&adapter->hw, ICS, ~mask & 0x00007FFF);
+			ew32(IMC, ~mask & 0x00007FFF);
+			ew32(ICS, ~mask & 0x00007FFF);
 			msleep(10);
 
 			if (adapter->test_icr) {
@@ -987,7 +1001,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 	}
 
 	/* Disable all the interrupts */
-	E1000_WRITE_REG(&adapter->hw, IMC, 0xFFFFFFFF);
+	ew32(IMC, 0xFFFFFFFF);
 	msleep(10);
 
 	/* Unhook test interrupt handler */
@@ -1044,6 +1058,7 @@ static void e1000_free_desc_rings(struct e1000_adapter *adapter)
 
 static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_tx_ring *txdr = &adapter->test_tx_ring;
 	struct e1000_rx_ring *rxdr = &adapter->test_rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
@@ -1072,17 +1087,14 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	memset(txdr->desc, 0, txdr->size);
 	txdr->next_to_use = txdr->next_to_clean = 0;
 
-	E1000_WRITE_REG(&adapter->hw, TDBAL,
-			((u64) txdr->dma & 0x00000000FFFFFFFF));
-	E1000_WRITE_REG(&adapter->hw, TDBAH, ((u64) txdr->dma >> 32));
-	E1000_WRITE_REG(&adapter->hw, TDLEN,
-			txdr->count * sizeof(struct e1000_tx_desc));
-	E1000_WRITE_REG(&adapter->hw, TDH, 0);
-	E1000_WRITE_REG(&adapter->hw, TDT, 0);
-	E1000_WRITE_REG(&adapter->hw, TCTL,
-			E1000_TCTL_PSP | E1000_TCTL_EN |
-			E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT |
-			E1000_FDX_COLLISION_DISTANCE << E1000_COLD_SHIFT);
+	ew32(TDBAL, ((u64) txdr->dma & 0x00000000FFFFFFFF));
+	ew32(TDBAH, ((u64) txdr->dma >> 32));
+	ew32(TDLEN, txdr->count * sizeof(struct e1000_tx_desc));
+	ew32(TDH, 0);
+	ew32(TDT, 0);
+	ew32(TCTL, E1000_TCTL_PSP | E1000_TCTL_EN |
+	     E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT |
+	     E1000_FDX_COLLISION_DISTANCE << E1000_COLD_SHIFT);
 
 	for (i = 0; i < txdr->count; i++) {
 		struct e1000_tx_desc *tx_desc = E1000_TX_DESC(*txdr, i);
@@ -1127,18 +1139,17 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	memset(rxdr->desc, 0, rxdr->size);
 	rxdr->next_to_use = rxdr->next_to_clean = 0;
 
-	rctl = E1000_READ_REG(&adapter->hw, RCTL);
-	E1000_WRITE_REG(&adapter->hw, RCTL, rctl & ~E1000_RCTL_EN);
-	E1000_WRITE_REG(&adapter->hw, RDBAL,
-			((u64) rxdr->dma & 0xFFFFFFFF));
-	E1000_WRITE_REG(&adapter->hw, RDBAH, ((u64) rxdr->dma >> 32));
-	E1000_WRITE_REG(&adapter->hw, RDLEN, rxdr->size);
-	E1000_WRITE_REG(&adapter->hw, RDH, 0);
-	E1000_WRITE_REG(&adapter->hw, RDT, 0);
+	rctl = er32(RCTL);
+	ew32(RCTL, rctl & ~E1000_RCTL_EN);
+	ew32(RDBAL, ((u64) rxdr->dma & 0xFFFFFFFF));
+	ew32(RDBAH, ((u64) rxdr->dma >> 32));
+	ew32(RDLEN, rxdr->size);
+	ew32(RDH, 0);
+	ew32(RDT, 0);
 	rctl = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_SZ_2048 |
 		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
-		(adapter->hw.mc_filter_type << E1000_RCTL_MO_SHIFT);
-	E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+		(hw->mc_filter_type << E1000_RCTL_MO_SHIFT);
+	ew32(RCTL, rctl);
 
 	for (i = 0; i < rxdr->count; i++) {
 		struct e1000_rx_desc *rx_desc = E1000_RX_DESC(*rxdr, i);
@@ -1168,68 +1179,72 @@ err_nomem:
 
 static void e1000_phy_disable_receiver(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
+
 	/* Write out to PHY registers 29 and 30 to disable the Receiver. */
-	e1000_write_phy_reg(&adapter->hw, 29, 0x001F);
-	e1000_write_phy_reg(&adapter->hw, 30, 0x8FFC);
-	e1000_write_phy_reg(&adapter->hw, 29, 0x001A);
-	e1000_write_phy_reg(&adapter->hw, 30, 0x8FF0);
+	e1000_write_phy_reg(hw, 29, 0x001F);
+	e1000_write_phy_reg(hw, 30, 0x8FFC);
+	e1000_write_phy_reg(hw, 29, 0x001A);
+	e1000_write_phy_reg(hw, 30, 0x8FF0);
 }
 
 static void e1000_phy_reset_clk_and_crs(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u16 phy_reg;
 
 	/* Because we reset the PHY above, we need to re-force TX_CLK in the
 	 * Extended PHY Specific Control Register to 25MHz clock.  This
 	 * value defaults back to a 2.5MHz clock when the PHY is reset.
 	 */
-	e1000_read_phy_reg(&adapter->hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_reg);
+	e1000_read_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_reg);
 	phy_reg |= M88E1000_EPSCR_TX_CLK_25;
-	e1000_write_phy_reg(&adapter->hw,
+	e1000_write_phy_reg(hw,
 		M88E1000_EXT_PHY_SPEC_CTRL, phy_reg);
 
 	/* In addition, because of the s/w reset above, we need to enable
 	 * CRS on TX.  This must be set for both full and half duplex
 	 * operation.
 	 */
-	e1000_read_phy_reg(&adapter->hw, M88E1000_PHY_SPEC_CTRL, &phy_reg);
+	e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_reg);
 	phy_reg |= M88E1000_PSCR_ASSERT_CRS_ON_TX;
-	e1000_write_phy_reg(&adapter->hw,
+	e1000_write_phy_reg(hw,
 		M88E1000_PHY_SPEC_CTRL, phy_reg);
 }
 
 static int e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl_reg;
 	u16 phy_reg;
 
 	/* Setup the Device Control Register for PHY loopback test. */
 
-	ctrl_reg = E1000_READ_REG(&adapter->hw, CTRL);
+	ctrl_reg = er32(CTRL);
 	ctrl_reg |= (E1000_CTRL_ILOS |		/* Invert Loss-Of-Signal */
 		     E1000_CTRL_FRCSPD |	/* Set the Force Speed Bit */
 		     E1000_CTRL_FRCDPX |	/* Set the Force Duplex Bit */
 		     E1000_CTRL_SPD_1000 |	/* Force Speed to 1000 */
 		     E1000_CTRL_FD);		/* Force Duplex to FULL */
 
-	E1000_WRITE_REG(&adapter->hw, CTRL, ctrl_reg);
+	ew32(CTRL, ctrl_reg);
 
 	/* Read the PHY Specific Control Register (0x10) */
-	e1000_read_phy_reg(&adapter->hw, M88E1000_PHY_SPEC_CTRL, &phy_reg);
+	e1000_read_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, &phy_reg);
 
 	/* Clear Auto-Crossover bits in PHY Specific Control Register
 	 * (bits 6:5).
 	 */
 	phy_reg &= ~M88E1000_PSCR_AUTO_X_MODE;
-	e1000_write_phy_reg(&adapter->hw, M88E1000_PHY_SPEC_CTRL, phy_reg);
+	e1000_write_phy_reg(hw, M88E1000_PHY_SPEC_CTRL, phy_reg);
 
 	/* Perform software reset on the PHY */
-	e1000_phy_reset(&adapter->hw);
+	e1000_phy_reset(hw);
 
 	/* Have to setup TX_CLK and TX_CRS after software reset */
 	e1000_phy_reset_clk_and_crs(adapter);
 
-	e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x8100);
+	e1000_write_phy_reg(hw, PHY_CTRL, 0x8100);
 
 	/* Wait for reset to complete. */
 	udelay(500);
@@ -1241,23 +1256,23 @@ static int e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 	e1000_phy_disable_receiver(adapter);
 
 	/* Set the loopback bit in the PHY control register. */
-	e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &phy_reg);
+	e1000_read_phy_reg(hw, PHY_CTRL, &phy_reg);
 	phy_reg |= MII_CR_LOOPBACK;
-	e1000_write_phy_reg(&adapter->hw, PHY_CTRL, phy_reg);
+	e1000_write_phy_reg(hw, PHY_CTRL, phy_reg);
 
 	/* Setup TX_CLK and TX_CRS one more time. */
 	e1000_phy_reset_clk_and_crs(adapter);
 
 	/* Check Phy Configuration */
-	e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &phy_reg);
+	e1000_read_phy_reg(hw, PHY_CTRL, &phy_reg);
 	if (phy_reg != 0x4100)
 		 return 9;
 
-	e1000_read_phy_reg(&adapter->hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_reg);
+	e1000_read_phy_reg(hw, M88E1000_EXT_PHY_SPEC_CTRL, &phy_reg);
 	if (phy_reg != 0x0070)
 		return 10;
 
-	e1000_read_phy_reg(&adapter->hw, 29, &phy_reg);
+	e1000_read_phy_reg(hw, 29, &phy_reg);
 	if (phy_reg != 0x001A)
 		return 11;
 
@@ -1266,29 +1281,30 @@ static int e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 
 static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl_reg = 0;
 	u32 stat_reg = 0;
 
-	adapter->hw.autoneg = false;
+	hw->autoneg = false;
 
-	if (adapter->hw.phy_type == e1000_phy_m88) {
+	if (hw->phy_type == e1000_phy_m88) {
 		/* Auto-MDI/MDIX Off */
-		e1000_write_phy_reg(&adapter->hw,
+		e1000_write_phy_reg(hw,
 				    M88E1000_PHY_SPEC_CTRL, 0x0808);
 		/* reset to update Auto-MDI/MDIX */
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x9140);
+		e1000_write_phy_reg(hw, PHY_CTRL, 0x9140);
 		/* autoneg off */
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x8140);
-	} else if (adapter->hw.phy_type == e1000_phy_gg82563)
-		e1000_write_phy_reg(&adapter->hw,
+		e1000_write_phy_reg(hw, PHY_CTRL, 0x8140);
+	} else if (hw->phy_type == e1000_phy_gg82563)
+		e1000_write_phy_reg(hw,
 		                    GG82563_PHY_KMRN_MODE_CTRL,
 		                    0x1CC);
 
-	ctrl_reg = E1000_READ_REG(&adapter->hw, CTRL);
+	ctrl_reg = er32(CTRL);
 
-	if (adapter->hw.phy_type == e1000_phy_ife) {
+	if (hw->phy_type == e1000_phy_ife) {
 		/* force 100, set loopback */
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x6100);
+		e1000_write_phy_reg(hw, PHY_CTRL, 0x6100);
 
 		/* Now set up the MAC to the same speed/duplex as the PHY. */
 		ctrl_reg &= ~E1000_CTRL_SPD_SEL; /* Clear the speed sel bits */
@@ -1298,10 +1314,10 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
 	} else {
 		/* force 1000, set loopback */
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, 0x4140);
+		e1000_write_phy_reg(hw, PHY_CTRL, 0x4140);
 
 		/* Now set up the MAC to the same speed/duplex as the PHY. */
-		ctrl_reg = E1000_READ_REG(&adapter->hw, CTRL);
+		ctrl_reg = er32(CTRL);
 		ctrl_reg &= ~E1000_CTRL_SPD_SEL; /* Clear the speed sel bits */
 		ctrl_reg |= (E1000_CTRL_FRCSPD | /* Set the Force Speed Bit */
 			     E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
@@ -1309,23 +1325,23 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
 	}
 
-	if (adapter->hw.media_type == e1000_media_type_copper &&
-	   adapter->hw.phy_type == e1000_phy_m88)
+	if (hw->media_type == e1000_media_type_copper &&
+	   hw->phy_type == e1000_phy_m88)
 		ctrl_reg |= E1000_CTRL_ILOS; /* Invert Loss of Signal */
 	else {
 		/* Set the ILOS bit on the fiber Nic is half
 		 * duplex link is detected. */
-		stat_reg = E1000_READ_REG(&adapter->hw, STATUS);
+		stat_reg = er32(STATUS);
 		if ((stat_reg & E1000_STATUS_FD) == 0)
 			ctrl_reg |= (E1000_CTRL_ILOS | E1000_CTRL_SLU);
 	}
 
-	E1000_WRITE_REG(&adapter->hw, CTRL, ctrl_reg);
+	ew32(CTRL, ctrl_reg);
 
 	/* Disable the receiver on the PHY so when a cable is plugged in, the
 	 * PHY does not begin to autoneg when a cable is reconnected to the NIC.
 	 */
-	if (adapter->hw.phy_type == e1000_phy_m88)
+	if (hw->phy_type == e1000_phy_m88)
 		e1000_phy_disable_receiver(adapter);
 
 	udelay(500);
@@ -1335,12 +1351,13 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 
 static int e1000_set_phy_loopback(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u16 phy_reg = 0;
 	u16 count = 0;
 
-	switch (adapter->hw.mac_type) {
+	switch (hw->mac_type) {
 	case e1000_82543:
-		if (adapter->hw.media_type == e1000_media_type_copper) {
+		if (hw->media_type == e1000_media_type_copper) {
 			/* Attempt to setup Loopback mode on Non-integrated PHY.
 			 * Some PHY registers get corrupted at random, so
 			 * attempt this 10 times.
@@ -1374,9 +1391,9 @@ static int e1000_set_phy_loopback(struct e1000_adapter *adapter)
 		/* Default PHY loopback work is to read the MII
 		 * control register and assert bit 14 (loopback mode).
 		 */
-		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &phy_reg);
+		e1000_read_phy_reg(hw, PHY_CTRL, &phy_reg);
 		phy_reg |= MII_CR_LOOPBACK;
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, phy_reg);
+		e1000_write_phy_reg(hw, PHY_CTRL, phy_reg);
 		return 0;
 		break;
 	}
@@ -1402,14 +1419,14 @@ static int e1000_setup_loopback_test(struct e1000_adapter *adapter)
 		case e1000_82572:
 #define E1000_SERDES_LB_ON 0x410
 			e1000_set_phy_loopback(adapter);
-			E1000_WRITE_REG(hw, SCTL, E1000_SERDES_LB_ON);
+			ew32(SCTL, E1000_SERDES_LB_ON);
 			msleep(10);
 			return 0;
 			break;
 		default:
-			rctl = E1000_READ_REG(hw, RCTL);
+			rctl = er32(RCTL);
 			rctl |= E1000_RCTL_LBM_TCVR;
-			E1000_WRITE_REG(hw, RCTL, rctl);
+			ew32(RCTL, rctl);
 			return 0;
 		}
 	} else if (hw->media_type == e1000_media_type_copper)
@@ -1424,9 +1441,9 @@ static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 	u32 rctl;
 	u16 phy_reg;
 
-	rctl = E1000_READ_REG(hw, RCTL);
+	rctl = er32(RCTL);
 	rctl &= ~(E1000_RCTL_LBM_TCVR | E1000_RCTL_LBM_MAC);
-	E1000_WRITE_REG(hw, RCTL, rctl);
+	ew32(RCTL, rctl);
 
 	switch (hw->mac_type) {
 	case e1000_82571:
@@ -1434,7 +1451,7 @@ static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 		if (hw->media_type == e1000_media_type_fiber ||
 		    hw->media_type == e1000_media_type_internal_serdes) {
 #define E1000_SERDES_LB_OFF 0x400
-			E1000_WRITE_REG(hw, SCTL, E1000_SERDES_LB_OFF);
+			ew32(SCTL, E1000_SERDES_LB_OFF);
 			msleep(10);
 			break;
 		}
@@ -1484,13 +1501,14 @@ static int e1000_check_lbtest_frame(struct sk_buff *skb,
 
 static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_tx_ring *txdr = &adapter->test_tx_ring;
 	struct e1000_rx_ring *rxdr = &adapter->test_rx_ring;
 	struct pci_dev *pdev = adapter->pdev;
 	int i, j, k, l, lc, good_cnt, ret_val=0;
 	unsigned long time;
 
-	E1000_WRITE_REG(&adapter->hw, RDT, rxdr->count - 1);
+	ew32(RDT, rxdr->count - 1);
 
 	/* Calculate the loop count based on the largest descriptor ring
 	 * The idea is to wrap the largest ring a number of times using 64
@@ -1513,7 +1531,7 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 				    	PCI_DMA_TODEVICE);
 			if (unlikely(++k == txdr->count)) k = 0;
 		}
-		E1000_WRITE_REG(&adapter->hw, TDT, k);
+		ew32(TDT, k);
 		msleep(200);
 		time = jiffies; /* set the start time for the receive */
 		good_cnt = 0;
@@ -1548,9 +1566,11 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 
 static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 {
+	struct e1000_hw *hw = &adapter->hw;
+
 	/* PHY loopback cannot be performed if SoL/IDER
 	 * sessions are active */
-	if (e1000_check_phy_reset_block(&adapter->hw)) {
+	if (e1000_check_phy_reset_block(hw)) {
 		DPRINTK(DRV, ERR, "Cannot do PHY loopback test "
 		        "when SoL/IDER is active.\n");
 		*data = 0;
@@ -1572,27 +1592,28 @@ out:
 
 static int e1000_link_test(struct e1000_adapter *adapter, u64 *data)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	*data = 0;
-	if (adapter->hw.media_type == e1000_media_type_internal_serdes) {
+	if (hw->media_type == e1000_media_type_internal_serdes) {
 		int i = 0;
-		adapter->hw.serdes_link_down = true;
+		hw->serdes_link_down = true;
 
 		/* On some blade server designs, link establishment
 		 * could take as long as 2-3 minutes */
 		do {
-			e1000_check_for_link(&adapter->hw);
-			if (!adapter->hw.serdes_link_down)
+			e1000_check_for_link(hw);
+			if (!hw->serdes_link_down)
 				return *data;
 			msleep(20);
 		} while (i++ < 3750);
 
 		*data = 1;
 	} else {
-		e1000_check_for_link(&adapter->hw);
-		if (adapter->hw.autoneg)  /* if auto_neg is set wait for it */
+		e1000_check_for_link(hw);
+		if (hw->autoneg)  /* if auto_neg is set wait for it */
 			msleep(4000);
 
-		if (!(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_LU)) {
+		if (!(er32(STATUS) & E1000_STATUS_LU)) {
 			*data = 1;
 		}
 	}
@@ -1615,6 +1636,7 @@ static void e1000_diag_test(struct net_device *netdev,
 			    struct ethtool_test *eth_test, u64 *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	bool if_running = netif_running(netdev);
 
 	set_bit(__E1000_TESTING, &adapter->flags);
@@ -1622,9 +1644,9 @@ static void e1000_diag_test(struct net_device *netdev,
 		/* Offline tests */
 
 		/* save speed, duplex, autoneg settings */
-		u16 autoneg_advertised = adapter->hw.autoneg_advertised;
-		u8 forced_speed_duplex = adapter->hw.forced_speed_duplex;
-		u8 autoneg = adapter->hw.autoneg;
+		u16 autoneg_advertised = hw->autoneg_advertised;
+		u8 forced_speed_duplex = hw->forced_speed_duplex;
+		u8 autoneg = hw->autoneg;
 
 		DPRINTK(HW, INFO, "offline testing starting\n");
 
@@ -1657,9 +1679,9 @@ static void e1000_diag_test(struct net_device *netdev,
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		/* restore speed, duplex, autoneg settings */
-		adapter->hw.autoneg_advertised = autoneg_advertised;
-		adapter->hw.forced_speed_duplex = forced_speed_duplex;
-		adapter->hw.autoneg = autoneg;
+		hw->autoneg_advertised = autoneg_advertised;
+		hw->forced_speed_duplex = forced_speed_duplex;
+		hw->autoneg = autoneg;
 
 		e1000_reset(adapter);
 		clear_bit(__E1000_TESTING, &adapter->flags);
@@ -1708,7 +1730,7 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter,
 	case E1000_DEV_ID_82571EB_SERDES:
 	case E1000_DEV_ID_82571EB_COPPER:
 		/* Wake events not supported on port B */
-		if (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1) {
+		if (er32(STATUS) & E1000_STATUS_FUNC_1) {
 			wol->supported = 0;
 			break;
 		}
@@ -1732,7 +1754,7 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter,
 		/* dual port cards only support WoL on port A from now on
 		 * unless it was enabled in the eeprom for port B
 		 * so exclude FUNC_1 ports from having WoL enabled */
-		if (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1 &&
+		if (er32(STATUS) & E1000_STATUS_FUNC_1 &&
 		    !adapter->eeprom_wol) {
 			wol->supported = 0;
 			break;
@@ -1748,6 +1770,7 @@ static void e1000_get_wol(struct net_device *netdev,
 			  struct ethtool_wolinfo *wol)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 
 	wol->supported = WAKE_UCAST | WAKE_MCAST |
 	                 WAKE_BCAST | WAKE_MAGIC;
@@ -1759,7 +1782,7 @@ static void e1000_get_wol(struct net_device *netdev,
 		return;
 
 	/* apply any specific unsupported masks here */
-	switch (adapter->hw.device_id) {
+	switch (hw->device_id) {
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		/* KSP3 does not suppport UCAST wake-ups */
 		wol->supported &= ~WAKE_UCAST;
@@ -1831,11 +1854,12 @@ static int e1000_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 static void e1000_led_blink_callback(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+	struct e1000_hw *hw = &adapter->hw;
 
 	if (test_and_change_bit(E1000_LED_ON, &adapter->led_status))
-		e1000_led_off(&adapter->hw);
+		e1000_led_off(hw);
 	else
-		e1000_led_on(&adapter->hw);
+		e1000_led_on(hw);
 
 	mod_timer(&adapter->blink_timer, jiffies + E1000_ID_INTERVAL);
 }
@@ -1843,21 +1867,22 @@ static void e1000_led_blink_callback(unsigned long data)
 static int e1000_phys_id(struct net_device *netdev, u32 data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 
 	if (!data)
 		data = INT_MAX;
 
-	if (adapter->hw.mac_type < e1000_82571) {
+	if (hw->mac_type < e1000_82571) {
 		if (!adapter->blink_timer.function) {
 			init_timer(&adapter->blink_timer);
 			adapter->blink_timer.function = e1000_led_blink_callback;
 			adapter->blink_timer.data = (unsigned long) adapter;
 		}
-		e1000_setup_led(&adapter->hw);
+		e1000_setup_led(hw);
 		mod_timer(&adapter->blink_timer, jiffies);
 		msleep_interruptible(data * 1000);
 		del_timer_sync(&adapter->blink_timer);
-	} else if (adapter->hw.phy_type == e1000_phy_ife) {
+	} else if (hw->phy_type == e1000_phy_ife) {
 		if (!adapter->blink_timer.function) {
 			init_timer(&adapter->blink_timer);
 			adapter->blink_timer.function = e1000_led_blink_callback;
@@ -1868,13 +1893,13 @@ static int e1000_phys_id(struct net_device *netdev, u32 data)
 		del_timer_sync(&adapter->blink_timer);
 		e1000_write_phy_reg(&(adapter->hw), IFE_PHY_SPECIAL_CONTROL_LED, 0);
 	} else {
-		e1000_blink_led_start(&adapter->hw);
+		e1000_blink_led_start(hw);
 		msleep_interruptible(data * 1000);
 	}
 
-	e1000_led_off(&adapter->hw);
+	e1000_led_off(hw);
 	clear_bit(E1000_LED_ON, &adapter->led_status);
-	e1000_cleanup_led(&adapter->hw);
+	e1000_cleanup_led(hw);
 
 	return 0;
 }
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index d6c272a..5d3c2bd 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -520,7 +520,7 @@ void e1000_set_media_type(struct e1000_hw *hw)
             hw->media_type = e1000_media_type_copper;
             break;
         default:
-            status = E1000_READ_REG(hw, STATUS);
+            status = er32(STATUS);
             if (status & E1000_STATUS_TBIMODE) {
                 hw->media_type = e1000_media_type_fiber;
                 /* tbi_compatibility not valid on fiber */
@@ -568,15 +568,15 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
 
     /* Clear interrupt mask to stop board from generating interrupts */
     DEBUGOUT("Masking off all interrupts\n");
-    E1000_WRITE_REG(hw, IMC, 0xffffffff);
+    ew32(IMC, 0xffffffff);
 
     /* Disable the Transmit and Receive units.  Then delay to allow
      * any pending transactions to complete before we hit the MAC with
      * the global reset.
      */
-    E1000_WRITE_REG(hw, RCTL, 0);
-    E1000_WRITE_REG(hw, TCTL, E1000_TCTL_PSP);
-    E1000_WRITE_FLUSH(hw);
+    ew32(RCTL, 0);
+    ew32(TCTL, E1000_TCTL_PSP);
+    E1000_WRITE_FLUSH();
 
     /* The tbi_compatibility_on Flag must be cleared when Rctl is cleared. */
     hw->tbi_compatibility_on = false;
@@ -586,11 +586,11 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
      */
     msleep(10);
 
-    ctrl = E1000_READ_REG(hw, CTRL);
+    ctrl = er32(CTRL);
 
     /* Must reset the PHY before resetting the MAC */
     if ((hw->mac_type == e1000_82541) || (hw->mac_type == e1000_82547)) {
-        E1000_WRITE_REG(hw, CTRL, (ctrl | E1000_CTRL_PHY_RST));
+        ew32(CTRL, (ctrl | E1000_CTRL_PHY_RST));
         msleep(5);
     }
 
@@ -599,12 +599,12 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
     if (hw->mac_type == e1000_82573) {
         timeout = 10;
 
-        extcnf_ctrl = E1000_READ_REG(hw, EXTCNF_CTRL);
+        extcnf_ctrl = er32(EXTCNF_CTRL);
         extcnf_ctrl |= E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP;
 
         do {
-            E1000_WRITE_REG(hw, EXTCNF_CTRL, extcnf_ctrl);
-            extcnf_ctrl = E1000_READ_REG(hw, EXTCNF_CTRL);
+            ew32(EXTCNF_CTRL, extcnf_ctrl);
+            extcnf_ctrl = er32(EXTCNF_CTRL);
 
             if (extcnf_ctrl & E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP)
                 break;
@@ -619,9 +619,9 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
     /* Workaround for ICH8 bit corruption issue in FIFO memory */
     if (hw->mac_type == e1000_ich8lan) {
         /* Set Tx and Rx buffer allocation to 8k apiece. */
-        E1000_WRITE_REG(hw, PBA, E1000_PBA_8K);
+        ew32(PBA, E1000_PBA_8K);
         /* Set Packet Buffer Size to 16k. */
-        E1000_WRITE_REG(hw, PBS, E1000_PBS_16K);
+        ew32(PBS, E1000_PBS_16K);
     }
 
     /* Issue a global reset to the MAC.  This will reset the chip's
@@ -645,7 +645,7 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
         case e1000_82545_rev_3:
         case e1000_82546_rev_3:
             /* Reset is performed on a shadow of the control register */
-            E1000_WRITE_REG(hw, CTRL_DUP, (ctrl | E1000_CTRL_RST));
+            ew32(CTRL_DUP, (ctrl | E1000_CTRL_RST));
             break;
         case e1000_ich8lan:
             if (!hw->phy_reset_disable &&
@@ -658,11 +658,11 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
             }
 
             e1000_get_software_flag(hw);
-            E1000_WRITE_REG(hw, CTRL, (ctrl | E1000_CTRL_RST));
+            ew32(CTRL, (ctrl | E1000_CTRL_RST));
             msleep(5);
             break;
         default:
-            E1000_WRITE_REG(hw, CTRL, (ctrl | E1000_CTRL_RST));
+            ew32(CTRL, (ctrl | E1000_CTRL_RST));
             break;
     }
 
@@ -677,10 +677,10 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
         case e1000_82544:
             /* Wait for reset to complete */
             udelay(10);
-            ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+            ctrl_ext = er32(CTRL_EXT);
             ctrl_ext |= E1000_CTRL_EXT_EE_RST;
-            E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
-            E1000_WRITE_FLUSH(hw);
+            ew32(CTRL_EXT, ctrl_ext);
+            E1000_WRITE_FLUSH();
             /* Wait for EEPROM reload */
             msleep(2);
             break;
@@ -694,10 +694,10 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
         case e1000_82573:
             if (!e1000_is_onboard_nvm_eeprom(hw)) {
                 udelay(10);
-                ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+                ctrl_ext = er32(CTRL_EXT);
                 ctrl_ext |= E1000_CTRL_EXT_EE_RST;
-                E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
-                E1000_WRITE_FLUSH(hw);
+                ew32(CTRL_EXT, ctrl_ext);
+                E1000_WRITE_FLUSH();
             }
             /* fall through */
         default:
@@ -710,27 +710,27 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
 
     /* Disable HW ARPs on ASF enabled adapters */
     if (hw->mac_type >= e1000_82540 && hw->mac_type <= e1000_82547_rev_2) {
-        manc = E1000_READ_REG(hw, MANC);
+        manc = er32(MANC);
         manc &= ~(E1000_MANC_ARP_EN);
-        E1000_WRITE_REG(hw, MANC, manc);
+        ew32(MANC, manc);
     }
 
     if ((hw->mac_type == e1000_82541) || (hw->mac_type == e1000_82547)) {
         e1000_phy_init_script(hw);
 
         /* Configure activity LED after PHY reset */
-        led_ctrl = E1000_READ_REG(hw, LEDCTL);
+        led_ctrl = er32(LEDCTL);
         led_ctrl &= IGP_ACTIVITY_LED_MASK;
         led_ctrl |= (IGP_ACTIVITY_LED_ENABLE | IGP_LED3_MODE);
-        E1000_WRITE_REG(hw, LEDCTL, led_ctrl);
+        ew32(LEDCTL, led_ctrl);
     }
 
     /* Clear interrupt mask to stop board from generating interrupts */
     DEBUGOUT("Masking off all interrupts\n");
-    E1000_WRITE_REG(hw, IMC, 0xffffffff);
+    ew32(IMC, 0xffffffff);
 
     /* Clear any pending interrupt events. */
-    icr = E1000_READ_REG(hw, ICR);
+    icr = er32(ICR);
 
     /* If MWI was previously enabled, reenable it. */
     if (hw->mac_type == e1000_82542_rev2_0) {
@@ -739,9 +739,9 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
     }
 
     if (hw->mac_type == e1000_ich8lan) {
-        u32 kab = E1000_READ_REG(hw, KABGTXD);
+        u32 kab = er32(KABGTXD);
         kab |= E1000_KABGTXD_BGSQLBIAS;
-        E1000_WRITE_REG(hw, KABGTXD, kab);
+        ew32(KABGTXD, kab);
     }
 
     return E1000_SUCCESS;
@@ -766,22 +766,22 @@ static void e1000_initialize_hardware_bits(struct e1000_hw *hw)
         u32 reg_txdctl, reg_txdctl1;
 
         /* link autonegotiation/sync workarounds */
-        reg_tarc0 = E1000_READ_REG(hw, TARC0);
+        reg_tarc0 = er32(TARC0);
         reg_tarc0 &= ~((1 << 30)|(1 << 29)|(1 << 28)|(1 << 27));
 
         /* Enable not-done TX descriptor counting */
-        reg_txdctl = E1000_READ_REG(hw, TXDCTL);
+        reg_txdctl = er32(TXDCTL);
         reg_txdctl |= E1000_TXDCTL_COUNT_DESC;
-        E1000_WRITE_REG(hw, TXDCTL, reg_txdctl);
-        reg_txdctl1 = E1000_READ_REG(hw, TXDCTL1);
+        ew32(TXDCTL, reg_txdctl);
+        reg_txdctl1 = er32(TXDCTL1);
         reg_txdctl1 |= E1000_TXDCTL_COUNT_DESC;
-        E1000_WRITE_REG(hw, TXDCTL1, reg_txdctl1);
+        ew32(TXDCTL1, reg_txdctl1);
 
         switch (hw->mac_type) {
             case e1000_82571:
             case e1000_82572:
                 /* Clear PHY TX compatible mode bits */
-                reg_tarc1 = E1000_READ_REG(hw, TARC1);
+                reg_tarc1 = er32(TARC1);
                 reg_tarc1 &= ~((1 << 30)|(1 << 29));
 
                 /* link autonegotiation/sync workarounds */
@@ -791,25 +791,25 @@ static void e1000_initialize_hardware_bits(struct e1000_hw *hw)
                 reg_tarc1 |= ((1 << 26)|(1 << 25)|(1 << 24));
 
                 /* Multiple read bit is reversed polarity */
-                reg_tctl = E1000_READ_REG(hw, TCTL);
+                reg_tctl = er32(TCTL);
                 if (reg_tctl & E1000_TCTL_MULR)
                     reg_tarc1 &= ~(1 << 28);
                 else
                     reg_tarc1 |= (1 << 28);
 
-                E1000_WRITE_REG(hw, TARC1, reg_tarc1);
+                ew32(TARC1, reg_tarc1);
                 break;
             case e1000_82573:
-                reg_ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+                reg_ctrl_ext = er32(CTRL_EXT);
                 reg_ctrl_ext &= ~(1 << 23);
                 reg_ctrl_ext |= (1 << 22);
 
                 /* TX byte count fix */
-                reg_ctrl = E1000_READ_REG(hw, CTRL);
+                reg_ctrl = er32(CTRL);
                 reg_ctrl &= ~(1 << 29);
 
-                E1000_WRITE_REG(hw, CTRL_EXT, reg_ctrl_ext);
-                E1000_WRITE_REG(hw, CTRL, reg_ctrl);
+                ew32(CTRL_EXT, reg_ctrl_ext);
+                ew32(CTRL, reg_ctrl);
                 break;
             case e1000_80003es2lan:
                 /* improve small packet performace for fiber/serdes */
@@ -819,14 +819,14 @@ static void e1000_initialize_hardware_bits(struct e1000_hw *hw)
                 }
 
                 /* Multiple read bit is reversed polarity */
-                reg_tctl = E1000_READ_REG(hw, TCTL);
-                reg_tarc1 = E1000_READ_REG(hw, TARC1);
+                reg_tctl = er32(TCTL);
+                reg_tarc1 = er32(TARC1);
                 if (reg_tctl & E1000_TCTL_MULR)
                     reg_tarc1 &= ~(1 << 28);
                 else
                     reg_tarc1 |= (1 << 28);
 
-                E1000_WRITE_REG(hw, TARC1, reg_tarc1);
+                ew32(TARC1, reg_tarc1);
                 break;
             case e1000_ich8lan:
                 /* Reduce concurrent DMA requests to 3 from 4 */
@@ -835,16 +835,16 @@ static void e1000_initialize_hardware_bits(struct e1000_hw *hw)
                      (hw->device_id != E1000_DEV_ID_ICH8_IGP_M)))
                     reg_tarc0 |= ((1 << 29)|(1 << 28));
 
-                reg_ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+                reg_ctrl_ext = er32(CTRL_EXT);
                 reg_ctrl_ext |= (1 << 22);
-                E1000_WRITE_REG(hw, CTRL_EXT, reg_ctrl_ext);
+                ew32(CTRL_EXT, reg_ctrl_ext);
 
                 /* workaround TX hang with TSO=on */
                 reg_tarc0 |= ((1 << 27)|(1 << 26)|(1 << 24)|(1 << 23));
 
                 /* Multiple read bit is reversed polarity */
-                reg_tctl = E1000_READ_REG(hw, TCTL);
-                reg_tarc1 = E1000_READ_REG(hw, TARC1);
+                reg_tctl = er32(TCTL);
+                reg_tarc1 = er32(TARC1);
                 if (reg_tctl & E1000_TCTL_MULR)
                     reg_tarc1 &= ~(1 << 28);
                 else
@@ -853,13 +853,13 @@ static void e1000_initialize_hardware_bits(struct e1000_hw *hw)
                 /* workaround TX hang with TSO=on */
                 reg_tarc1 |= ((1 << 30)|(1 << 26)|(1 << 24));
 
-                E1000_WRITE_REG(hw, TARC1, reg_tarc1);
+                ew32(TARC1, reg_tarc1);
                 break;
             default:
                 break;
         }
 
-        E1000_WRITE_REG(hw, TARC0, reg_tarc0);
+        ew32(TARC0, reg_tarc0);
     }
 }
 
@@ -890,9 +890,9 @@ s32 e1000_init_hw(struct e1000_hw *hw)
         ((hw->revision_id < 3) ||
          ((hw->device_id != E1000_DEV_ID_ICH8_IGP_M_AMT) &&
           (hw->device_id != E1000_DEV_ID_ICH8_IGP_M)))) {
-            reg_data = E1000_READ_REG(hw, STATUS);
+            reg_data = er32(STATUS);
             reg_data &= ~0x80000000;
-            E1000_WRITE_REG(hw, STATUS, reg_data);
+            ew32(STATUS, reg_data);
     }
 
     /* Initialize Identification LED */
@@ -913,7 +913,7 @@ s32 e1000_init_hw(struct e1000_hw *hw)
     /* VET hardcoded to standard value and VFTA removed in ICH8 LAN */
     if (hw->mac_type != e1000_ich8lan) {
         if (hw->mac_type < e1000_82545_rev_3)
-            E1000_WRITE_REG(hw, VET, 0);
+            ew32(VET, 0);
         e1000_clear_vfta(hw);
     }
 
@@ -921,8 +921,8 @@ s32 e1000_init_hw(struct e1000_hw *hw)
     if (hw->mac_type == e1000_82542_rev2_0) {
         DEBUGOUT("Disabling MWI on 82542 rev 2.0\n");
         e1000_pci_clear_mwi(hw);
-        E1000_WRITE_REG(hw, RCTL, E1000_RCTL_RST);
-        E1000_WRITE_FLUSH(hw);
+        ew32(RCTL, E1000_RCTL_RST);
+        E1000_WRITE_FLUSH();
         msleep(5);
     }
 
@@ -933,8 +933,8 @@ s32 e1000_init_hw(struct e1000_hw *hw)
 
     /* For 82542 (rev 2.0), take the receiver out of reset and enable MWI */
     if (hw->mac_type == e1000_82542_rev2_0) {
-        E1000_WRITE_REG(hw, RCTL, 0);
-        E1000_WRITE_FLUSH(hw);
+        ew32(RCTL, 0);
+        E1000_WRITE_FLUSH();
         msleep(1);
         if (hw->pci_cmd_word & PCI_COMMAND_INVALIDATE)
             e1000_pci_set_mwi(hw);
@@ -949,7 +949,7 @@ s32 e1000_init_hw(struct e1000_hw *hw)
         E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
         /* use write flush to prevent Memory Write Block (MWB) from
          * occuring when accessing our register space */
-        E1000_WRITE_FLUSH(hw);
+        E1000_WRITE_FLUSH();
     }
 
     /* Set the PCI priority bit correctly in the CTRL register.  This
@@ -958,8 +958,8 @@ s32 e1000_init_hw(struct e1000_hw *hw)
      * 82542 and 82543 silicon.
      */
     if (hw->dma_fairness && hw->mac_type <= e1000_82543) {
-        ctrl = E1000_READ_REG(hw, CTRL);
-        E1000_WRITE_REG(hw, CTRL, ctrl | E1000_CTRL_PRIOR);
+        ctrl = er32(CTRL);
+        ew32(CTRL, ctrl | E1000_CTRL_PRIOR);
     }
 
     switch (hw->mac_type) {
@@ -982,9 +982,9 @@ s32 e1000_init_hw(struct e1000_hw *hw)
 
     /* Set the transmit descriptor write-back policy */
     if (hw->mac_type > e1000_82544) {
-        ctrl = E1000_READ_REG(hw, TXDCTL);
+        ctrl = er32(TXDCTL);
         ctrl = (ctrl & ~E1000_TXDCTL_WTHRESH) | E1000_TXDCTL_FULL_TX_DESC_WB;
-        E1000_WRITE_REG(hw, TXDCTL, ctrl);
+        ew32(TXDCTL, ctrl);
     }
 
     if (hw->mac_type == e1000_82573) {
@@ -996,21 +996,21 @@ s32 e1000_init_hw(struct e1000_hw *hw)
         break;
     case e1000_80003es2lan:
         /* Enable retransmit on late collisions */
-        reg_data = E1000_READ_REG(hw, TCTL);
+        reg_data = er32(TCTL);
         reg_data |= E1000_TCTL_RTLC;
-        E1000_WRITE_REG(hw, TCTL, reg_data);
+        ew32(TCTL, reg_data);
 
         /* Configure Gigabit Carry Extend Padding */
-        reg_data = E1000_READ_REG(hw, TCTL_EXT);
+        reg_data = er32(TCTL_EXT);
         reg_data &= ~E1000_TCTL_EXT_GCEX_MASK;
         reg_data |= DEFAULT_80003ES2LAN_TCTL_EXT_GCEX;
-        E1000_WRITE_REG(hw, TCTL_EXT, reg_data);
+        ew32(TCTL_EXT, reg_data);
 
         /* Configure Transmit Inter-Packet Gap */
-        reg_data = E1000_READ_REG(hw, TIPG);
+        reg_data = er32(TIPG);
         reg_data &= ~E1000_TIPG_IPGT_MASK;
         reg_data |= DEFAULT_80003ES2LAN_TIPG_IPGT_1000;
-        E1000_WRITE_REG(hw, TIPG, reg_data);
+        ew32(TIPG, reg_data);
 
         reg_data = E1000_READ_REG_ARRAY(hw, FFLT, 0x0001);
         reg_data &= ~0x00100000;
@@ -1019,17 +1019,17 @@ s32 e1000_init_hw(struct e1000_hw *hw)
     case e1000_82571:
     case e1000_82572:
     case e1000_ich8lan:
-        ctrl = E1000_READ_REG(hw, TXDCTL1);
+        ctrl = er32(TXDCTL1);
         ctrl = (ctrl & ~E1000_TXDCTL_WTHRESH) | E1000_TXDCTL_FULL_TX_DESC_WB;
-        E1000_WRITE_REG(hw, TXDCTL1, ctrl);
+        ew32(TXDCTL1, ctrl);
         break;
     }
 
 
     if (hw->mac_type == e1000_82573) {
-        u32 gcr = E1000_READ_REG(hw, GCR);
+        u32 gcr = er32(GCR);
         gcr |= E1000_GCR_L1_ACT_WITHOUT_L0S_RX;
-        E1000_WRITE_REG(hw, GCR, gcr);
+        ew32(GCR, gcr);
     }
 
     /* Clear all of the statistics registers (clear on read).  It is
@@ -1046,11 +1046,11 @@ s32 e1000_init_hw(struct e1000_hw *hw)
 
     if (hw->device_id == E1000_DEV_ID_82546GB_QUAD_COPPER ||
         hw->device_id == E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3) {
-        ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+        ctrl_ext = er32(CTRL_EXT);
         /* Relaxed ordering must be disabled to avoid a parity
          * error crash in a PCI slot. */
         ctrl_ext |= E1000_CTRL_EXT_RO_DIS;
-        E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
+        ew32(CTRL_EXT, ctrl_ext);
     }
 
     return ret_val;
@@ -1181,7 +1181,7 @@ s32 e1000_setup_link(struct e1000_hw *hw)
         }
         ctrl_ext = ((eeprom_data & EEPROM_WORD0F_SWPDIO_EXT) <<
                     SWDPIO__EXT_SHIFT);
-        E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
+        ew32(CTRL_EXT, ctrl_ext);
     }
 
     /* Call the necessary subroutine to configure the link. */
@@ -1198,12 +1198,12 @@ s32 e1000_setup_link(struct e1000_hw *hw)
 
     /* FCAL/H and FCT are hardcoded to standard values in e1000_ich8lan. */
     if (hw->mac_type != e1000_ich8lan) {
-        E1000_WRITE_REG(hw, FCT, FLOW_CONTROL_TYPE);
-        E1000_WRITE_REG(hw, FCAH, FLOW_CONTROL_ADDRESS_HIGH);
-        E1000_WRITE_REG(hw, FCAL, FLOW_CONTROL_ADDRESS_LOW);
+        ew32(FCT, FLOW_CONTROL_TYPE);
+        ew32(FCAH, FLOW_CONTROL_ADDRESS_HIGH);
+        ew32(FCAL, FLOW_CONTROL_ADDRESS_LOW);
     }
 
-    E1000_WRITE_REG(hw, FCTTV, hw->fc_pause_time);
+    ew32(FCTTV, hw->fc_pause_time);
 
     /* Set the flow control receive threshold registers.  Normally,
      * these registers will be set to a default threshold that may be
@@ -1212,18 +1212,18 @@ s32 e1000_setup_link(struct e1000_hw *hw)
      * registers will be set to 0.
      */
     if (!(hw->fc & E1000_FC_TX_PAUSE)) {
-        E1000_WRITE_REG(hw, FCRTL, 0);
-        E1000_WRITE_REG(hw, FCRTH, 0);
+        ew32(FCRTL, 0);
+        ew32(FCRTH, 0);
     } else {
         /* We need to set up the Receive Threshold high and low water marks
          * as well as (optionally) enabling the transmission of XON frames.
          */
         if (hw->fc_send_xon) {
-            E1000_WRITE_REG(hw, FCRTL, (hw->fc_low_water | E1000_FCRTL_XONE));
-            E1000_WRITE_REG(hw, FCRTH, hw->fc_high_water);
+            ew32(FCRTL, (hw->fc_low_water | E1000_FCRTL_XONE));
+            ew32(FCRTH, hw->fc_high_water);
         } else {
-            E1000_WRITE_REG(hw, FCRTL, hw->fc_low_water);
-            E1000_WRITE_REG(hw, FCRTH, hw->fc_high_water);
+            ew32(FCRTL, hw->fc_low_water);
+            ew32(FCRTH, hw->fc_high_water);
         }
     }
     return ret_val;
@@ -1255,7 +1255,7 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
      * loopback mode is disabled during initialization.
      */
     if (hw->mac_type == e1000_82571 || hw->mac_type == e1000_82572)
-        E1000_WRITE_REG(hw, SCTL, E1000_DISABLE_SERDES_LOOPBACK);
+        ew32(SCTL, E1000_DISABLE_SERDES_LOOPBACK);
 
     /* On adapters with a MAC newer than 82544, SWDP 1 will be
      * set when the optics detect a signal. On older adapters, it will be
@@ -1263,7 +1263,7 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
      * If we're on serdes media, adjust the output amplitude to value
      * set in the EEPROM.
      */
-    ctrl = E1000_READ_REG(hw, CTRL);
+    ctrl = er32(CTRL);
     if (hw->media_type == e1000_media_type_fiber)
         signal = (hw->mac_type > e1000_82544) ? E1000_CTRL_SWDPIN1 : 0;
 
@@ -1334,9 +1334,9 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
      */
     DEBUGOUT("Auto-negotiation enabled\n");
 
-    E1000_WRITE_REG(hw, TXCW, txcw);
-    E1000_WRITE_REG(hw, CTRL, ctrl);
-    E1000_WRITE_FLUSH(hw);
+    ew32(TXCW, txcw);
+    ew32(CTRL, ctrl);
+    E1000_WRITE_FLUSH();
 
     hw->txcw = txcw;
     msleep(1);
@@ -1348,11 +1348,11 @@ static s32 e1000_setup_fiber_serdes_link(struct e1000_hw *hw)
      * For internal serdes, we just assume a signal is present, then poll.
      */
     if (hw->media_type == e1000_media_type_internal_serdes ||
-       (E1000_READ_REG(hw, CTRL) & E1000_CTRL_SWDPIN1) == signal) {
+       (er32(CTRL) & E1000_CTRL_SWDPIN1) == signal) {
         DEBUGOUT("Looking for Link\n");
         for (i = 0; i < (LINK_UP_TIMEOUT / 10); i++) {
             msleep(10);
-            status = E1000_READ_REG(hw, STATUS);
+            status = er32(STATUS);
             if (status & E1000_STATUS_LU) break;
         }
         if (i == (LINK_UP_TIMEOUT / 10)) {
@@ -1392,7 +1392,7 @@ static s32 e1000_copper_link_preconfig(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_copper_link_preconfig");
 
-    ctrl = E1000_READ_REG(hw, CTRL);
+    ctrl = er32(CTRL);
     /* With 82543, we need to force speed and duplex on the MAC equal to what
      * the PHY speed and duplex configuration is. In addition, we need to
      * perform a hardware reset on the PHY to take it out of reset.
@@ -1400,10 +1400,10 @@ static s32 e1000_copper_link_preconfig(struct e1000_hw *hw)
     if (hw->mac_type > e1000_82543) {
         ctrl |= E1000_CTRL_SLU;
         ctrl &= ~(E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
-        E1000_WRITE_REG(hw, CTRL, ctrl);
+        ew32(CTRL, ctrl);
     } else {
         ctrl |= (E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX | E1000_CTRL_SLU);
-        E1000_WRITE_REG(hw, CTRL, ctrl);
+        ew32(CTRL, ctrl);
         ret_val = e1000_phy_hw_reset(hw);
         if (ret_val)
             return ret_val;
@@ -1464,10 +1464,10 @@ static s32 e1000_copper_link_igp_setup(struct e1000_hw *hw)
     msleep(15);
     if (hw->mac_type != e1000_ich8lan) {
     /* Configure activity LED after PHY reset */
-    led_ctrl = E1000_READ_REG(hw, LEDCTL);
+    led_ctrl = er32(LEDCTL);
     led_ctrl &= IGP_ACTIVITY_LED_MASK;
     led_ctrl |= (IGP_ACTIVITY_LED_ENABLE | IGP_LED3_MODE);
-    E1000_WRITE_REG(hw, LEDCTL, led_ctrl);
+    ew32(LEDCTL, led_ctrl);
     }
 
     /* The NVM settings will configure LPLU in D3 for IGP2 and IGP3 PHYs */
@@ -1680,9 +1680,9 @@ static s32 e1000_copper_link_ggp_setup(struct e1000_hw *hw)
         if (ret_val)
             return ret_val;
 
-        reg_data = E1000_READ_REG(hw, CTRL_EXT);
+        reg_data = er32(CTRL_EXT);
         reg_data &= ~(E1000_CTRL_EXT_LINK_MODE_MASK);
-        E1000_WRITE_REG(hw, CTRL_EXT, reg_data);
+        ew32(CTRL_EXT, reg_data);
 
         ret_val = e1000_read_phy_reg(hw, GG82563_PHY_PWR_MGMT_CTRL,
                                           &phy_data);
@@ -2074,10 +2074,10 @@ static s32 e1000_configure_kmrn_for_10_100(struct e1000_hw *hw, u16 duplex)
         return ret_val;
 
     /* Configure Transmit Inter-Packet Gap */
-    tipg = E1000_READ_REG(hw, TIPG);
+    tipg = er32(TIPG);
     tipg &= ~E1000_TIPG_IPGT_MASK;
     tipg |= DEFAULT_80003ES2LAN_TIPG_IPGT_10_100;
-    E1000_WRITE_REG(hw, TIPG, tipg);
+    ew32(TIPG, tipg);
 
     ret_val = e1000_read_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
 
@@ -2109,10 +2109,10 @@ static s32 e1000_configure_kmrn_for_1000(struct e1000_hw *hw)
         return ret_val;
 
     /* Configure Transmit Inter-Packet Gap */
-    tipg = E1000_READ_REG(hw, TIPG);
+    tipg = er32(TIPG);
     tipg &= ~E1000_TIPG_IPGT_MASK;
     tipg |= DEFAULT_80003ES2LAN_TIPG_IPGT_1000;
-    E1000_WRITE_REG(hw, TIPG, tipg);
+    ew32(TIPG, tipg);
 
     ret_val = e1000_read_phy_reg(hw, GG82563_PHY_KMRN_MODE_CTRL, &reg_data);
 
@@ -2295,7 +2295,7 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
     DEBUGOUT1("hw->fc = %d\n", hw->fc);
 
     /* Read the Device Control Register. */
-    ctrl = E1000_READ_REG(hw, CTRL);
+    ctrl = er32(CTRL);
 
     /* Set the bits to Force Speed and Duplex in the Device Ctrl Reg. */
     ctrl |= (E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
@@ -2350,7 +2350,7 @@ static s32 e1000_phy_force_speed_duplex(struct e1000_hw *hw)
     e1000_config_collision_dist(hw);
 
     /* Write the configured values back to the Device Control Reg. */
-    E1000_WRITE_REG(hw, CTRL, ctrl);
+    ew32(CTRL, ctrl);
 
     if ((hw->phy_type == e1000_phy_m88) ||
         (hw->phy_type == e1000_phy_gg82563)) {
@@ -2539,13 +2539,13 @@ void e1000_config_collision_dist(struct e1000_hw *hw)
     else
         coll_dist = E1000_COLLISION_DISTANCE;
 
-    tctl = E1000_READ_REG(hw, TCTL);
+    tctl = er32(TCTL);
 
     tctl &= ~E1000_TCTL_COLD;
     tctl |= coll_dist << E1000_COLD_SHIFT;
 
-    E1000_WRITE_REG(hw, TCTL, tctl);
-    E1000_WRITE_FLUSH(hw);
+    ew32(TCTL, tctl);
+    E1000_WRITE_FLUSH();
 }
 
 /******************************************************************************
@@ -2573,7 +2573,7 @@ static s32 e1000_config_mac_to_phy(struct e1000_hw *hw)
     /* Read the Device Control Register and set the bits to Force Speed
      * and Duplex.
      */
-    ctrl = E1000_READ_REG(hw, CTRL);
+    ctrl = er32(CTRL);
     ctrl |= (E1000_CTRL_FRCSPD | E1000_CTRL_FRCDPX);
     ctrl &= ~(E1000_CTRL_SPD_SEL | E1000_CTRL_ILOS);
 
@@ -2600,7 +2600,7 @@ static s32 e1000_config_mac_to_phy(struct e1000_hw *hw)
         ctrl |= E1000_CTRL_SPD_100;
 
     /* Write the configured values back to the Device Control Reg. */
-    E1000_WRITE_REG(hw, CTRL, ctrl);
+    ew32(CTRL, ctrl);
     return E1000_SUCCESS;
 }
 
@@ -2622,7 +2622,7 @@ s32 e1000_force_mac_fc(struct e1000_hw *hw)
     DEBUGFUNC("e1000_force_mac_fc");
 
     /* Get the current configuration of the Device Control Register */
-    ctrl = E1000_READ_REG(hw, CTRL);
+    ctrl = er32(CTRL);
 
     /* Because we didn't get link via the internal auto-negotiation
      * mechanism (we either forced link or we got link via PHY
@@ -2666,7 +2666,7 @@ s32 e1000_force_mac_fc(struct e1000_hw *hw)
     if (hw->mac_type == e1000_82542_rev2_0)
         ctrl &= (~E1000_CTRL_TFCE);
 
-    E1000_WRITE_REG(hw, CTRL, ctrl);
+    ew32(CTRL, ctrl);
     return E1000_SUCCESS;
 }
 
@@ -2898,8 +2898,8 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_check_for_link");
 
-    ctrl = E1000_READ_REG(hw, CTRL);
-    status = E1000_READ_REG(hw, STATUS);
+    ctrl = er32(CTRL);
+    status = er32(STATUS);
 
     /* On adapters with a MAC newer than 82544, SW Defineable pin 1 will be
      * set when the optics detect a signal. On older adapters, it will be
@@ -2907,7 +2907,7 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
      */
     if ((hw->media_type == e1000_media_type_fiber) ||
         (hw->media_type == e1000_media_type_internal_serdes)) {
-        rxcw = E1000_READ_REG(hw, RXCW);
+        rxcw = er32(RXCW);
 
         if (hw->media_type == e1000_media_type_fiber) {
             signal = (hw->mac_type > e1000_82544) ? E1000_CTRL_SWDPIN1 : 0;
@@ -2953,11 +2953,11 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
                 (!hw->autoneg) &&
                 (hw->forced_speed_duplex == e1000_10_full ||
                  hw->forced_speed_duplex == e1000_10_half)) {
-                E1000_WRITE_REG(hw, IMC, 0xffffffff);
+                ew32(IMC, 0xffffffff);
                 ret_val = e1000_polarity_reversal_workaround(hw);
-                icr = E1000_READ_REG(hw, ICR);
-                E1000_WRITE_REG(hw, ICS, (icr & ~E1000_ICS_LSC));
-                E1000_WRITE_REG(hw, IMS, IMS_ENABLE_MASK);
+                icr = er32(ICR);
+                ew32(ICS, (icr & ~E1000_ICS_LSC));
+                ew32(IMS, IMS_ENABLE_MASK);
             }
 
         } else {
@@ -3022,9 +3022,9 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
                  */
                 if (hw->tbi_compatibility_on) {
                     /* If we previously were in the mode, turn it off. */
-                    rctl = E1000_READ_REG(hw, RCTL);
+                    rctl = er32(RCTL);
                     rctl &= ~E1000_RCTL_SBP;
-                    E1000_WRITE_REG(hw, RCTL, rctl);
+                    ew32(RCTL, rctl);
                     hw->tbi_compatibility_on = false;
                 }
             } else {
@@ -3035,9 +3035,9 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
                  */
                 if (!hw->tbi_compatibility_on) {
                     hw->tbi_compatibility_on = true;
-                    rctl = E1000_READ_REG(hw, RCTL);
+                    rctl = er32(RCTL);
                     rctl |= E1000_RCTL_SBP;
-                    E1000_WRITE_REG(hw, RCTL, rctl);
+                    ew32(RCTL, rctl);
                 }
             }
         }
@@ -3061,12 +3061,12 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
         DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\n");
 
         /* Disable auto-negotiation in the TXCW register */
-        E1000_WRITE_REG(hw, TXCW, (hw->txcw & ~E1000_TXCW_ANE));
+        ew32(TXCW, (hw->txcw & ~E1000_TXCW_ANE));
 
         /* Force link-up and also force full-duplex. */
-        ctrl = E1000_READ_REG(hw, CTRL);
+        ctrl = er32(CTRL);
         ctrl |= (E1000_CTRL_SLU | E1000_CTRL_FD);
-        E1000_WRITE_REG(hw, CTRL, ctrl);
+        ew32(CTRL, ctrl);
 
         /* Configure Flow Control after forcing link up. */
         ret_val = e1000_config_fc_after_link_up(hw);
@@ -3084,8 +3084,8 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
               (hw->media_type == e1000_media_type_internal_serdes)) &&
               (ctrl & E1000_CTRL_SLU) && (rxcw & E1000_RXCW_C)) {
         DEBUGOUT("RXing /C/, enable AutoNeg and stop forcing link.\n");
-        E1000_WRITE_REG(hw, TXCW, hw->txcw);
-        E1000_WRITE_REG(hw, CTRL, (ctrl & ~E1000_CTRL_SLU));
+        ew32(TXCW, hw->txcw);
+        ew32(CTRL, (ctrl & ~E1000_CTRL_SLU));
 
         hw->serdes_link_down = false;
     }
@@ -3093,10 +3093,10 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
      * based on MAC synchronization for internal serdes media type.
      */
     else if ((hw->media_type == e1000_media_type_internal_serdes) &&
-             !(E1000_TXCW_ANE & E1000_READ_REG(hw, TXCW))) {
+             !(E1000_TXCW_ANE & er32(TXCW))) {
         /* SYNCH bit and IV bit are sticky. */
         udelay(10);
-        if (E1000_RXCW_SYNCH & E1000_READ_REG(hw, RXCW)) {
+        if (E1000_RXCW_SYNCH & er32(RXCW)) {
             if (!(rxcw & E1000_RXCW_IV)) {
                 hw->serdes_link_down = false;
                 DEBUGOUT("SERDES: Link is up.\n");
@@ -3107,8 +3107,8 @@ s32 e1000_check_for_link(struct e1000_hw *hw)
         }
     }
     if ((hw->media_type == e1000_media_type_internal_serdes) &&
-        (E1000_TXCW_ANE & E1000_READ_REG(hw, TXCW))) {
-        hw->serdes_link_down = !(E1000_STATUS_LU & E1000_READ_REG(hw, STATUS));
+        (E1000_TXCW_ANE & er32(TXCW))) {
+        hw->serdes_link_down = !(E1000_STATUS_LU & er32(STATUS));
     }
     return E1000_SUCCESS;
 }
@@ -3129,7 +3129,7 @@ s32 e1000_get_speed_and_duplex(struct e1000_hw *hw, u16 *speed, u16 *duplex)
     DEBUGFUNC("e1000_get_speed_and_duplex");
 
     if (hw->mac_type >= e1000_82543) {
-        status = E1000_READ_REG(hw, STATUS);
+        status = er32(STATUS);
         if (status & E1000_STATUS_SPEED_1000) {
             *speed = SPEED_1000;
             DEBUGOUT("1000 Mbs, ");
@@ -3238,8 +3238,8 @@ static void e1000_raise_mdi_clk(struct e1000_hw *hw, u32 *ctrl)
     /* Raise the clock input to the Management Data Clock (by setting the MDC
      * bit), and then delay 10 microseconds.
      */
-    E1000_WRITE_REG(hw, CTRL, (*ctrl | E1000_CTRL_MDC));
-    E1000_WRITE_FLUSH(hw);
+    ew32(CTRL, (*ctrl | E1000_CTRL_MDC));
+    E1000_WRITE_FLUSH();
     udelay(10);
 }
 
@@ -3254,8 +3254,8 @@ static void e1000_lower_mdi_clk(struct e1000_hw *hw, u32 *ctrl)
     /* Lower the clock input to the Management Data Clock (by clearing the MDC
      * bit), and then delay 10 microseconds.
      */
-    E1000_WRITE_REG(hw, CTRL, (*ctrl & ~E1000_CTRL_MDC));
-    E1000_WRITE_FLUSH(hw);
+    ew32(CTRL, (*ctrl & ~E1000_CTRL_MDC));
+    E1000_WRITE_FLUSH();
     udelay(10);
 }
 
@@ -3280,7 +3280,7 @@ static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, u32 data, u16 count)
     mask = 0x01;
     mask <<= (count - 1);
 
-    ctrl = E1000_READ_REG(hw, CTRL);
+    ctrl = er32(CTRL);
 
     /* Set MDIO_DIR and MDC_DIR direction bits to be used as output pins. */
     ctrl |= (E1000_CTRL_MDIO_DIR | E1000_CTRL_MDC_DIR);
@@ -3296,8 +3296,8 @@ static void e1000_shift_out_mdi_bits(struct e1000_hw *hw, u32 data, u16 count)
         else
             ctrl &= ~E1000_CTRL_MDIO;
 
-        E1000_WRITE_REG(hw, CTRL, ctrl);
-        E1000_WRITE_FLUSH(hw);
+        ew32(CTRL, ctrl);
+        E1000_WRITE_FLUSH();
 
         udelay(10);
 
@@ -3328,14 +3328,14 @@ static u16 e1000_shift_in_mdi_bits(struct e1000_hw *hw)
      * by raising the input to the Management Data Clock (setting the MDC bit),
      * and then reading the value of the MDIO bit.
      */
-    ctrl = E1000_READ_REG(hw, CTRL);
+    ctrl = er32(CTRL);
 
     /* Clear MDIO_DIR (SWDPIO1) to indicate this bit is to be used as input. */
     ctrl &= ~E1000_CTRL_MDIO_DIR;
     ctrl &= ~E1000_CTRL_MDIO;
 
-    E1000_WRITE_REG(hw, CTRL, ctrl);
-    E1000_WRITE_FLUSH(hw);
+    ew32(CTRL, ctrl);
+    E1000_WRITE_FLUSH();
 
     /* Raise and Lower the clock before reading in the data. This accounts for
      * the turnaround bits. The first clock occurred when we clocked out the
@@ -3347,7 +3347,7 @@ static u16 e1000_shift_in_mdi_bits(struct e1000_hw *hw)
     for (data = 0, i = 0; i < 16; i++) {
         data = data << 1;
         e1000_raise_mdi_clk(hw, &ctrl);
-        ctrl = E1000_READ_REG(hw, CTRL);
+        ctrl = er32(CTRL);
         /* Check to see if we shifted in a "1". */
         if (ctrl & E1000_CTRL_MDIO)
             data |= 1;
@@ -3379,7 +3379,7 @@ static s32 e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask)
             if (e1000_get_hw_eeprom_semaphore(hw))
                 return -E1000_ERR_SWFW_SYNC;
 
-            swfw_sync = E1000_READ_REG(hw, SW_FW_SYNC);
+            swfw_sync = er32(SW_FW_SYNC);
             if (!(swfw_sync & (fwmask | swmask))) {
                 break;
             }
@@ -3397,7 +3397,7 @@ static s32 e1000_swfw_sync_acquire(struct e1000_hw *hw, u16 mask)
     }
 
     swfw_sync |= swmask;
-    E1000_WRITE_REG(hw, SW_FW_SYNC, swfw_sync);
+    ew32(SW_FW_SYNC, swfw_sync);
 
     e1000_put_hw_eeprom_semaphore(hw);
     return E1000_SUCCESS;
@@ -3425,9 +3425,9 @@ static void e1000_swfw_sync_release(struct e1000_hw *hw, u16 mask)
     while (e1000_get_hw_eeprom_semaphore(hw) != E1000_SUCCESS);
         /* empty */
 
-    swfw_sync = E1000_READ_REG(hw, SW_FW_SYNC);
+    swfw_sync = er32(SW_FW_SYNC);
     swfw_sync &= ~swmask;
-    E1000_WRITE_REG(hw, SW_FW_SYNC, swfw_sync);
+    ew32(SW_FW_SYNC, swfw_sync);
 
     e1000_put_hw_eeprom_semaphore(hw);
 }
@@ -3446,7 +3446,7 @@ s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data)
     DEBUGFUNC("e1000_read_phy_reg");
 
     if ((hw->mac_type == e1000_80003es2lan) &&
-        (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1)) {
+        (er32(STATUS) & E1000_STATUS_FUNC_1)) {
         swfw = E1000_SWFW_PHY1_SM;
     } else {
         swfw = E1000_SWFW_PHY0_SM;
@@ -3517,12 +3517,12 @@ static s32 e1000_read_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
                 (phy_addr << E1000_MDIC_PHY_SHIFT) |
                 (E1000_MDIC_OP_READ));
 
-        E1000_WRITE_REG(hw, MDIC, mdic);
+        ew32(MDIC, mdic);
 
         /* Poll the ready bit to see if the MDI read completed */
         for (i = 0; i < 64; i++) {
             udelay(50);
-            mdic = E1000_READ_REG(hw, MDIC);
+            mdic = er32(MDIC);
             if (mdic & E1000_MDIC_READY) break;
         }
         if (!(mdic & E1000_MDIC_READY)) {
@@ -3581,7 +3581,7 @@ s32 e1000_write_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 phy_data)
     DEBUGFUNC("e1000_write_phy_reg");
 
     if ((hw->mac_type == e1000_80003es2lan) &&
-        (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1)) {
+        (er32(STATUS) & E1000_STATUS_FUNC_1)) {
         swfw = E1000_SWFW_PHY1_SM;
     } else {
         swfw = E1000_SWFW_PHY0_SM;
@@ -3653,12 +3653,12 @@ static s32 e1000_write_phy_reg_ex(struct e1000_hw *hw, u32 reg_addr,
                 (phy_addr << E1000_MDIC_PHY_SHIFT) |
                 (E1000_MDIC_OP_WRITE));
 
-        E1000_WRITE_REG(hw, MDIC, mdic);
+        ew32(MDIC, mdic);
 
         /* Poll the ready bit to see if the MDI read completed */
         for (i = 0; i < 641; i++) {
             udelay(5);
-            mdic = E1000_READ_REG(hw, MDIC);
+            mdic = er32(MDIC);
             if (mdic & E1000_MDIC_READY) break;
         }
         if (!(mdic & E1000_MDIC_READY)) {
@@ -3697,7 +3697,7 @@ static s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 *data)
     DEBUGFUNC("e1000_read_kmrn_reg");
 
     if ((hw->mac_type == e1000_80003es2lan) &&
-        (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1)) {
+        (er32(STATUS) & E1000_STATUS_FUNC_1)) {
         swfw = E1000_SWFW_PHY1_SM;
     } else {
         swfw = E1000_SWFW_PHY0_SM;
@@ -3709,11 +3709,11 @@ static s32 e1000_read_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 *data)
     reg_val = ((reg_addr << E1000_KUMCTRLSTA_OFFSET_SHIFT) &
               E1000_KUMCTRLSTA_OFFSET) |
               E1000_KUMCTRLSTA_REN;
-    E1000_WRITE_REG(hw, KUMCTRLSTA, reg_val);
+    ew32(KUMCTRLSTA, reg_val);
     udelay(2);
 
     /* Read the data returned */
-    reg_val = E1000_READ_REG(hw, KUMCTRLSTA);
+    reg_val = er32(KUMCTRLSTA);
     *data = (u16)reg_val;
 
     e1000_swfw_sync_release(hw, swfw);
@@ -3727,7 +3727,7 @@ static s32 e1000_write_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 data)
     DEBUGFUNC("e1000_write_kmrn_reg");
 
     if ((hw->mac_type == e1000_80003es2lan) &&
-        (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1)) {
+        (er32(STATUS) & E1000_STATUS_FUNC_1)) {
         swfw = E1000_SWFW_PHY1_SM;
     } else {
         swfw = E1000_SWFW_PHY0_SM;
@@ -3737,7 +3737,7 @@ static s32 e1000_write_kmrn_reg(struct e1000_hw *hw, u32 reg_addr, u16 data)
 
     reg_val = ((reg_addr << E1000_KUMCTRLSTA_OFFSET_SHIFT) &
               E1000_KUMCTRLSTA_OFFSET) | data;
-    E1000_WRITE_REG(hw, KUMCTRLSTA, reg_val);
+    ew32(KUMCTRLSTA, reg_val);
     udelay(2);
 
     e1000_swfw_sync_release(hw, swfw);
@@ -3768,7 +3768,7 @@ s32 e1000_phy_hw_reset(struct e1000_hw *hw)
 
     if (hw->mac_type > e1000_82543) {
         if ((hw->mac_type == e1000_80003es2lan) &&
-            (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1)) {
+            (er32(STATUS) & E1000_STATUS_FUNC_1)) {
             swfw = E1000_SWFW_PHY1_SM;
         } else {
             swfw = E1000_SWFW_PHY0_SM;
@@ -3783,17 +3783,17 @@ s32 e1000_phy_hw_reset(struct e1000_hw *hw)
          * and deassert.  For e1000_82571 hardware and later, we instead delay
          * for 50us between and 10ms after the deassertion.
          */
-        ctrl = E1000_READ_REG(hw, CTRL);
-        E1000_WRITE_REG(hw, CTRL, ctrl | E1000_CTRL_PHY_RST);
-        E1000_WRITE_FLUSH(hw);
+        ctrl = er32(CTRL);
+        ew32(CTRL, ctrl | E1000_CTRL_PHY_RST);
+        E1000_WRITE_FLUSH();
 
         if (hw->mac_type < e1000_82571)
             msleep(10);
         else
             udelay(100);
 
-        E1000_WRITE_REG(hw, CTRL, ctrl);
-        E1000_WRITE_FLUSH(hw);
+        ew32(CTRL, ctrl);
+        E1000_WRITE_FLUSH();
 
         if (hw->mac_type >= e1000_82571)
             mdelay(10);
@@ -3803,24 +3803,24 @@ s32 e1000_phy_hw_reset(struct e1000_hw *hw)
         /* Read the Extended Device Control Register, assert the PHY_RESET_DIR
          * bit to put the PHY into reset. Then, take it out of reset.
          */
-        ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+        ctrl_ext = er32(CTRL_EXT);
         ctrl_ext |= E1000_CTRL_EXT_SDP4_DIR;
         ctrl_ext &= ~E1000_CTRL_EXT_SDP4_DATA;
-        E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
-        E1000_WRITE_FLUSH(hw);
+        ew32(CTRL_EXT, ctrl_ext);
+        E1000_WRITE_FLUSH();
         msleep(10);
         ctrl_ext |= E1000_CTRL_EXT_SDP4_DATA;
-        E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
-        E1000_WRITE_FLUSH(hw);
+        ew32(CTRL_EXT, ctrl_ext);
+        E1000_WRITE_FLUSH();
     }
     udelay(150);
 
     if ((hw->mac_type == e1000_82541) || (hw->mac_type == e1000_82547)) {
         /* Configure activity LED after PHY reset */
-        led_ctrl = E1000_READ_REG(hw, LEDCTL);
+        led_ctrl = er32(LEDCTL);
         led_ctrl &= IGP_ACTIVITY_LED_MASK;
         led_ctrl |= (IGP_ACTIVITY_LED_ENABLE | IGP_LED3_MODE);
-        E1000_WRITE_REG(hw, LEDCTL, led_ctrl);
+        ew32(LEDCTL, led_ctrl);
     }
 
     /* Wait for FW to finish PHY configuration. */
@@ -3906,8 +3906,8 @@ void e1000_phy_powerdown_workaround(struct e1000_hw *hw)
 
     do {
         /* Disable link */
-        reg = E1000_READ_REG(hw, PHY_CTRL);
-        E1000_WRITE_REG(hw, PHY_CTRL, reg | E1000_PHY_CTRL_GBE_DISABLE |
+        reg = er32(PHY_CTRL);
+        ew32(PHY_CTRL, reg | E1000_PHY_CTRL_GBE_DISABLE |
                         E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 
         /* Write VR power-down enable - bits 9:8 should be 10b */
@@ -3922,8 +3922,8 @@ void e1000_phy_powerdown_workaround(struct e1000_hw *hw)
             break;
 
         /* Issue PHY reset and repeat at most one more time */
-        reg = E1000_READ_REG(hw, CTRL);
-        E1000_WRITE_REG(hw, CTRL, reg | E1000_CTRL_PHY_RST);
+        reg = er32(CTRL);
+        ew32(CTRL, reg | E1000_CTRL_PHY_RST);
         retry++;
     } while (retry);
 
@@ -3981,8 +3981,8 @@ static s32 e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
             mdelay(5);
         }
         /* Disable GigE link negotiation */
-        reg = E1000_READ_REG(hw, PHY_CTRL);
-        E1000_WRITE_REG(hw, PHY_CTRL, reg | E1000_PHY_CTRL_GBE_DISABLE |
+        reg = er32(PHY_CTRL);
+        ew32(PHY_CTRL, reg | E1000_PHY_CTRL_GBE_DISABLE |
                         E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
 
         /* unable to acquire PCS lock */
@@ -4388,7 +4388,7 @@ s32 e1000_validate_mdi_setting(struct e1000_hw *hw)
 s32 e1000_init_eeprom_params(struct e1000_hw *hw)
 {
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
-    u32 eecd = E1000_READ_REG(hw, EECD);
+    u32 eecd = er32(EECD);
     s32 ret_val = E1000_SUCCESS;
     u16 eeprom_size;
 
@@ -4490,7 +4490,7 @@ s32 e1000_init_eeprom_params(struct e1000_hw *hw)
             /* Ensure that the Autonomous FLASH update bit is cleared due to
              * Flash update issue on parts which use a FLASH for NVM. */
             eecd &= ~E1000_EECD_AUPDEN;
-            E1000_WRITE_REG(hw, EECD, eecd);
+            ew32(EECD, eecd);
         }
         break;
     case e1000_80003es2lan:
@@ -4580,8 +4580,8 @@ static void e1000_raise_ee_clk(struct e1000_hw *hw, u32 *eecd)
      * wait <delay> microseconds.
      */
     *eecd = *eecd | E1000_EECD_SK;
-    E1000_WRITE_REG(hw, EECD, *eecd);
-    E1000_WRITE_FLUSH(hw);
+    ew32(EECD, *eecd);
+    E1000_WRITE_FLUSH();
     udelay(hw->eeprom.delay_usec);
 }
 
@@ -4597,8 +4597,8 @@ static void e1000_lower_ee_clk(struct e1000_hw *hw, u32 *eecd)
      * wait 50 microseconds.
      */
     *eecd = *eecd & ~E1000_EECD_SK;
-    E1000_WRITE_REG(hw, EECD, *eecd);
-    E1000_WRITE_FLUSH(hw);
+    ew32(EECD, *eecd);
+    E1000_WRITE_FLUSH();
     udelay(hw->eeprom.delay_usec);
 }
 
@@ -4620,7 +4620,7 @@ static void e1000_shift_out_ee_bits(struct e1000_hw *hw, u16 data, u16 count)
      * In order to do this, "data" must be broken down into bits.
      */
     mask = 0x01 << (count - 1);
-    eecd = E1000_READ_REG(hw, EECD);
+    eecd = er32(EECD);
     if (eeprom->type == e1000_eeprom_microwire) {
         eecd &= ~E1000_EECD_DO;
     } else if (eeprom->type == e1000_eeprom_spi) {
@@ -4637,8 +4637,8 @@ static void e1000_shift_out_ee_bits(struct e1000_hw *hw, u16 data, u16 count)
         if (data & mask)
             eecd |= E1000_EECD_DI;
 
-        E1000_WRITE_REG(hw, EECD, eecd);
-        E1000_WRITE_FLUSH(hw);
+        ew32(EECD, eecd);
+        E1000_WRITE_FLUSH();
 
         udelay(eeprom->delay_usec);
 
@@ -4651,7 +4651,7 @@ static void e1000_shift_out_ee_bits(struct e1000_hw *hw, u16 data, u16 count)
 
     /* We leave the "DI" bit set to "0" when we leave this routine. */
     eecd &= ~E1000_EECD_DI;
-    E1000_WRITE_REG(hw, EECD, eecd);
+    ew32(EECD, eecd);
 }
 
 /******************************************************************************
@@ -4672,7 +4672,7 @@ static u16 e1000_shift_in_ee_bits(struct e1000_hw *hw, u16 count)
      * always be clear.
      */
 
-    eecd = E1000_READ_REG(hw, EECD);
+    eecd = er32(EECD);
 
     eecd &= ~(E1000_EECD_DO | E1000_EECD_DI);
     data = 0;
@@ -4681,7 +4681,7 @@ static u16 e1000_shift_in_ee_bits(struct e1000_hw *hw, u16 count)
         data = data << 1;
         e1000_raise_ee_clk(hw, &eecd);
 
-        eecd = E1000_READ_REG(hw, EECD);
+        eecd = er32(EECD);
 
         eecd &= ~(E1000_EECD_DI);
         if (eecd & E1000_EECD_DO)
@@ -4710,23 +4710,23 @@ static s32 e1000_acquire_eeprom(struct e1000_hw *hw)
 
     if (e1000_swfw_sync_acquire(hw, E1000_SWFW_EEP_SM))
         return -E1000_ERR_SWFW_SYNC;
-    eecd = E1000_READ_REG(hw, EECD);
+    eecd = er32(EECD);
 
     if (hw->mac_type != e1000_82573) {
         /* Request EEPROM Access */
         if (hw->mac_type > e1000_82544) {
             eecd |= E1000_EECD_REQ;
-            E1000_WRITE_REG(hw, EECD, eecd);
-            eecd = E1000_READ_REG(hw, EECD);
+            ew32(EECD, eecd);
+            eecd = er32(EECD);
             while ((!(eecd & E1000_EECD_GNT)) &&
                   (i < E1000_EEPROM_GRANT_ATTEMPTS)) {
                 i++;
                 udelay(5);
-                eecd = E1000_READ_REG(hw, EECD);
+                eecd = er32(EECD);
             }
             if (!(eecd & E1000_EECD_GNT)) {
                 eecd &= ~E1000_EECD_REQ;
-                E1000_WRITE_REG(hw, EECD, eecd);
+                ew32(EECD, eecd);
                 DEBUGOUT("Could not acquire EEPROM grant\n");
                 e1000_swfw_sync_release(hw, E1000_SWFW_EEP_SM);
                 return -E1000_ERR_EEPROM;
@@ -4739,15 +4739,15 @@ static s32 e1000_acquire_eeprom(struct e1000_hw *hw)
     if (eeprom->type == e1000_eeprom_microwire) {
         /* Clear SK and DI */
         eecd &= ~(E1000_EECD_DI | E1000_EECD_SK);
-        E1000_WRITE_REG(hw, EECD, eecd);
+        ew32(EECD, eecd);
 
         /* Set CS */
         eecd |= E1000_EECD_CS;
-        E1000_WRITE_REG(hw, EECD, eecd);
+        ew32(EECD, eecd);
     } else if (eeprom->type == e1000_eeprom_spi) {
         /* Clear SK and CS */
         eecd &= ~(E1000_EECD_CS | E1000_EECD_SK);
-        E1000_WRITE_REG(hw, EECD, eecd);
+        ew32(EECD, eecd);
         udelay(1);
     }
 
@@ -4764,40 +4764,40 @@ static void e1000_standby_eeprom(struct e1000_hw *hw)
     struct e1000_eeprom_info *eeprom = &hw->eeprom;
     u32 eecd;
 
-    eecd = E1000_READ_REG(hw, EECD);
+    eecd = er32(EECD);
 
     if (eeprom->type == e1000_eeprom_microwire) {
         eecd &= ~(E1000_EECD_CS | E1000_EECD_SK);
-        E1000_WRITE_REG(hw, EECD, eecd);
-        E1000_WRITE_FLUSH(hw);
+        ew32(EECD, eecd);
+        E1000_WRITE_FLUSH();
         udelay(eeprom->delay_usec);
 
         /* Clock high */
         eecd |= E1000_EECD_SK;
-        E1000_WRITE_REG(hw, EECD, eecd);
-        E1000_WRITE_FLUSH(hw);
+        ew32(EECD, eecd);
+        E1000_WRITE_FLUSH();
         udelay(eeprom->delay_usec);
 
         /* Select EEPROM */
         eecd |= E1000_EECD_CS;
-        E1000_WRITE_REG(hw, EECD, eecd);
-        E1000_WRITE_FLUSH(hw);
+        ew32(EECD, eecd);
+        E1000_WRITE_FLUSH();
         udelay(eeprom->delay_usec);
 
         /* Clock low */
         eecd &= ~E1000_EECD_SK;
-        E1000_WRITE_REG(hw, EECD, eecd);
-        E1000_WRITE_FLUSH(hw);
+        ew32(EECD, eecd);
+        E1000_WRITE_FLUSH();
         udelay(eeprom->delay_usec);
     } else if (eeprom->type == e1000_eeprom_spi) {
         /* Toggle CS to flush commands */
         eecd |= E1000_EECD_CS;
-        E1000_WRITE_REG(hw, EECD, eecd);
-        E1000_WRITE_FLUSH(hw);
+        ew32(EECD, eecd);
+        E1000_WRITE_FLUSH();
         udelay(eeprom->delay_usec);
         eecd &= ~E1000_EECD_CS;
-        E1000_WRITE_REG(hw, EECD, eecd);
-        E1000_WRITE_FLUSH(hw);
+        ew32(EECD, eecd);
+        E1000_WRITE_FLUSH();
         udelay(eeprom->delay_usec);
     }
 }
@@ -4813,13 +4813,13 @@ static void e1000_release_eeprom(struct e1000_hw *hw)
 
     DEBUGFUNC("e1000_release_eeprom");
 
-    eecd = E1000_READ_REG(hw, EECD);
+    eecd = er32(EECD);
 
     if (hw->eeprom.type == e1000_eeprom_spi) {
         eecd |= E1000_EECD_CS;  /* Pull CS high */
         eecd &= ~E1000_EECD_SK; /* Lower SCK */
 
-        E1000_WRITE_REG(hw, EECD, eecd);
+        ew32(EECD, eecd);
 
         udelay(hw->eeprom.delay_usec);
     } else if (hw->eeprom.type == e1000_eeprom_microwire) {
@@ -4828,25 +4828,25 @@ static void e1000_release_eeprom(struct e1000_hw *hw)
         /* CS on Microwire is active-high */
         eecd &= ~(E1000_EECD_CS | E1000_EECD_DI);
 
-        E1000_WRITE_REG(hw, EECD, eecd);
+        ew32(EECD, eecd);
 
         /* Rising edge of clock */
         eecd |= E1000_EECD_SK;
-        E1000_WRITE_REG(hw, EECD, eecd);
-        E1000_WRITE_FLUSH(hw);
+        ew32(EECD, eecd);
+        E1000_WRITE_FLUSH();
         udelay(hw->eeprom.delay_usec);
 
         /* Falling edge of clock */
         eecd &= ~E1000_EECD_SK;
-        E1000_WRITE_REG(hw, EECD, eecd);
-        E1000_WRITE_FLUSH(hw);
+        ew32(EECD, eecd);
+        E1000_WRITE_FLUSH();
         udelay(hw->eeprom.delay_usec);
     }
 
     /* Stop requesting EEPROM access */
     if (hw->mac_type > e1000_82544) {
         eecd &= ~E1000_EECD_REQ;
-        E1000_WRITE_REG(hw, EECD, eecd);
+        ew32(EECD, eecd);
     }
 
     e1000_swfw_sync_release(hw, E1000_SWFW_EEP_SM);
@@ -5009,13 +5009,13 @@ static s32 e1000_read_eeprom_eerd(struct e1000_hw *hw, u16 offset, u16 words,
         eerd = ((offset+i) << E1000_EEPROM_RW_ADDR_SHIFT) +
                          E1000_EEPROM_RW_REG_START;
 
-        E1000_WRITE_REG(hw, EERD, eerd);
+        ew32(EERD, eerd);
         error = e1000_poll_eerd_eewr_done(hw, E1000_EEPROM_POLL_READ);
 
         if (error) {
             break;
         }
-        data[i] = (E1000_READ_REG(hw, EERD) >> E1000_EEPROM_RW_REG_DATA);
+        data[i] = (er32(EERD) >> E1000_EEPROM_RW_REG_DATA);
 
     }
 
@@ -5050,7 +5050,7 @@ static s32 e1000_write_eeprom_eewr(struct e1000_hw *hw, u16 offset, u16 words,
             break;
         }
 
-        E1000_WRITE_REG(hw, EEWR, register_value);
+        ew32(EEWR, register_value);
 
         error = e1000_poll_eerd_eewr_done(hw, E1000_EEPROM_POLL_WRITE);
 
@@ -5076,9 +5076,9 @@ static s32 e1000_poll_eerd_eewr_done(struct e1000_hw *hw, int eerd)
 
     for (i = 0; i < attempts; i++) {
         if (eerd == E1000_EEPROM_POLL_READ)
-            reg = E1000_READ_REG(hw, EERD);
+            reg = er32(EERD);
         else
-            reg = E1000_READ_REG(hw, EEWR);
+            reg = er32(EEWR);
 
         if (reg & E1000_EEPROM_RW_REG_DONE) {
             done = E1000_SUCCESS;
@@ -5105,7 +5105,7 @@ static bool e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw)
         return false;
 
     if (hw->mac_type == e1000_82573) {
-        eecd = E1000_READ_REG(hw, EECD);
+        eecd = er32(EECD);
 
         /* Isolate bits 15 & 16 */
         eecd = ((eecd >> 15) & 0x03);
@@ -5215,9 +5215,9 @@ s32 e1000_update_eeprom_checksum(struct e1000_hw *hw)
         e1000_commit_shadow_ram(hw);
         /* Reload the EEPROM, or else modifications will not appear
          * until after next adapter reset. */
-        ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+        ctrl_ext = er32(CTRL_EXT);
         ctrl_ext |= E1000_CTRL_EXT_EE_RST;
-        E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
+        ew32(CTRL_EXT, ctrl_ext);
         msleep(10);
     }
     return E1000_SUCCESS;
@@ -5395,7 +5395,7 @@ static s32 e1000_write_eeprom_microwire(struct e1000_hw *hw, u16 offset,
          * If DO does not go high in 10 milliseconds, then error out.
          */
         for (i = 0; i < 200; i++) {
-            eecd = E1000_READ_REG(hw, EECD);
+            eecd = er32(EECD);
             if (eecd & E1000_EECD_DO) break;
             udelay(50);
         }
@@ -5449,9 +5449,9 @@ static s32 e1000_commit_shadow_ram(struct e1000_hw *hw)
 
     if (hw->mac_type == e1000_82573) {
         /* The flop register will be used to determine if flash type is STM */
-        flop = E1000_READ_REG(hw, FLOP);
+        flop = er32(FLOP);
         for (i=0; i < attempts; i++) {
-            eecd = E1000_READ_REG(hw, EECD);
+            eecd = er32(EECD);
             if ((eecd & E1000_EECD_FLUPD) == 0) {
                 break;
             }
@@ -5464,14 +5464,14 @@ static s32 e1000_commit_shadow_ram(struct e1000_hw *hw)
 
         /* If STM opcode located in bits 15:8 of flop, reset firmware */
         if ((flop & 0xFF00) == E1000_STM_OPCODE) {
-            E1000_WRITE_REG(hw, HICR, E1000_HICR_FW_RESET);
+            ew32(HICR, E1000_HICR_FW_RESET);
         }
 
         /* Perform the flash update */
-        E1000_WRITE_REG(hw, EECD, eecd | E1000_EECD_FLUPD);
+        ew32(EECD, eecd | E1000_EECD_FLUPD);
 
         for (i=0; i < attempts; i++) {
-            eecd = E1000_READ_REG(hw, EECD);
+            eecd = er32(EECD);
             if ((eecd & E1000_EECD_FLUPD) == 0) {
                 break;
             }
@@ -5487,7 +5487,7 @@ static s32 e1000_commit_shadow_ram(struct e1000_hw *hw)
         /* We're writing to the opposite bank so if we're on bank 1,
          * write to bank 0 etc.  We also need to erase the segment that
          * is going to be written */
-        if (!(E1000_READ_REG(hw, EECD) & E1000_EECD_SEC1VAL)) {
+        if (!(er32(EECD) & E1000_EECD_SEC1VAL)) {
             new_bank_offset = hw->flash_bank_size * 2;
             old_bank_offset = 0;
             e1000_erase_ich8_4k_segment(hw, 1);
@@ -5621,7 +5621,7 @@ s32 e1000_read_mac_addr(struct e1000_hw *hw)
     case e1000_82546_rev_3:
     case e1000_82571:
     case e1000_80003es2lan:
-        if (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1)
+        if (er32(STATUS) & E1000_STATUS_FUNC_1)
             hw->perm_mac_addr[5] ^= 0x01;
         break;
     }
@@ -5666,9 +5666,9 @@ static void e1000_init_rx_addrs(struct e1000_hw *hw)
     DEBUGOUT("Clearing RAR[1-15]\n");
     for (i = 1; i < rar_num; i++) {
         E1000_WRITE_REG_ARRAY(hw, RA, (i << 1), 0);
-        E1000_WRITE_FLUSH(hw);
+        E1000_WRITE_FLUSH();
         E1000_WRITE_REG_ARRAY(hw, RA, ((i << 1) + 1), 0);
-        E1000_WRITE_FLUSH(hw);
+        E1000_WRITE_FLUSH();
     }
 }
 
@@ -5772,12 +5772,12 @@ void e1000_mta_set(struct e1000_hw *hw, u32 hash_value)
     if ((hw->mac_type == e1000_82544) && ((hash_reg & 0x1) == 1)) {
         temp = E1000_READ_REG_ARRAY(hw, MTA, (hash_reg - 1));
         E1000_WRITE_REG_ARRAY(hw, MTA, hash_reg, mta);
-        E1000_WRITE_FLUSH(hw);
+        E1000_WRITE_FLUSH();
         E1000_WRITE_REG_ARRAY(hw, MTA, (hash_reg - 1), temp);
-        E1000_WRITE_FLUSH(hw);
+        E1000_WRITE_FLUSH();
     } else {
         E1000_WRITE_REG_ARRAY(hw, MTA, hash_reg, mta);
-        E1000_WRITE_FLUSH(hw);
+        E1000_WRITE_FLUSH();
     }
 }
 
@@ -5831,9 +5831,9 @@ void e1000_rar_set(struct e1000_hw *hw, u8 *addr, u32 index)
     }
 
     E1000_WRITE_REG_ARRAY(hw, RA, (index << 1), rar_low);
-    E1000_WRITE_FLUSH(hw);
+    E1000_WRITE_FLUSH();
     E1000_WRITE_REG_ARRAY(hw, RA, ((index << 1) + 1), rar_high);
-    E1000_WRITE_FLUSH(hw);
+    E1000_WRITE_FLUSH();
 }
 
 /******************************************************************************
@@ -5853,12 +5853,12 @@ void e1000_write_vfta(struct e1000_hw *hw, u32 offset, u32 value)
     if ((hw->mac_type == e1000_82544) && ((offset & 0x1) == 1)) {
         temp = E1000_READ_REG_ARRAY(hw, VFTA, (offset - 1));
         E1000_WRITE_REG_ARRAY(hw, VFTA, offset, value);
-        E1000_WRITE_FLUSH(hw);
+        E1000_WRITE_FLUSH();
         E1000_WRITE_REG_ARRAY(hw, VFTA, (offset - 1), temp);
-        E1000_WRITE_FLUSH(hw);
+        E1000_WRITE_FLUSH();
     } else {
         E1000_WRITE_REG_ARRAY(hw, VFTA, offset, value);
-        E1000_WRITE_FLUSH(hw);
+        E1000_WRITE_FLUSH();
     }
 }
 
@@ -5896,7 +5896,7 @@ static void e1000_clear_vfta(struct e1000_hw *hw)
          * manageability unit */
         vfta_value = (offset == vfta_offset) ? vfta_bit_in_reg : 0;
         E1000_WRITE_REG_ARRAY(hw, VFTA, offset, vfta_value);
-        E1000_WRITE_FLUSH(hw);
+        E1000_WRITE_FLUSH();
     }
 }
 
@@ -5916,7 +5916,7 @@ static s32 e1000_id_led_init(struct e1000_hw *hw)
         return E1000_SUCCESS;
     }
 
-    ledctl = E1000_READ_REG(hw, LEDCTL);
+    ledctl = er32(LEDCTL);
     hw->ledctl_default = ledctl;
     hw->ledctl_mode1 = hw->ledctl_default;
     hw->ledctl_mode2 = hw->ledctl_default;
@@ -6013,7 +6013,7 @@ s32 e1000_setup_led(struct e1000_hw *hw)
         /* Fall Through */
     default:
         if (hw->media_type == e1000_media_type_fiber) {
-            ledctl = E1000_READ_REG(hw, LEDCTL);
+            ledctl = er32(LEDCTL);
             /* Save current LEDCTL settings */
             hw->ledctl_default = ledctl;
             /* Turn off LED0 */
@@ -6022,9 +6022,9 @@ s32 e1000_setup_led(struct e1000_hw *hw)
                         E1000_LEDCTL_LED0_MODE_MASK);
             ledctl |= (E1000_LEDCTL_MODE_LED_OFF <<
                        E1000_LEDCTL_LED0_MODE_SHIFT);
-            E1000_WRITE_REG(hw, LEDCTL, ledctl);
+            ew32(LEDCTL, ledctl);
         } else if (hw->media_type == e1000_media_type_copper)
-            E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_mode1);
+            ew32(LEDCTL, hw->ledctl_mode1);
         break;
     }
 
@@ -6064,7 +6064,7 @@ s32 e1000_blink_led_start(struct e1000_hw *hw)
                 ledctl_blink |= (E1000_LEDCTL_LED0_BLINK << (i * 8));
     }
 
-    E1000_WRITE_REG(hw, LEDCTL, ledctl_blink);
+    ew32(LEDCTL, ledctl_blink);
 
     return E1000_SUCCESS;
 }
@@ -6103,7 +6103,7 @@ s32 e1000_cleanup_led(struct e1000_hw *hw)
             break;
         }
         /* Restore LEDCTL settings */
-        E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_default);
+        ew32(LEDCTL, hw->ledctl_default);
         break;
     }
 
@@ -6117,7 +6117,7 @@ s32 e1000_cleanup_led(struct e1000_hw *hw)
  *****************************************************************************/
 s32 e1000_led_on(struct e1000_hw *hw)
 {
-    u32 ctrl = E1000_READ_REG(hw, CTRL);
+    u32 ctrl = er32(CTRL);
 
     DEBUGFUNC("e1000_led_on");
 
@@ -6149,13 +6149,13 @@ s32 e1000_led_on(struct e1000_hw *hw)
             e1000_write_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL_LED,
                  (IFE_PSCL_PROBE_MODE | IFE_PSCL_PROBE_LEDS_ON));
         } else if (hw->media_type == e1000_media_type_copper) {
-            E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_mode2);
+            ew32(LEDCTL, hw->ledctl_mode2);
             return E1000_SUCCESS;
         }
         break;
     }
 
-    E1000_WRITE_REG(hw, CTRL, ctrl);
+    ew32(CTRL, ctrl);
 
     return E1000_SUCCESS;
 }
@@ -6167,7 +6167,7 @@ s32 e1000_led_on(struct e1000_hw *hw)
  *****************************************************************************/
 s32 e1000_led_off(struct e1000_hw *hw)
 {
-    u32 ctrl = E1000_READ_REG(hw, CTRL);
+    u32 ctrl = er32(CTRL);
 
     DEBUGFUNC("e1000_led_off");
 
@@ -6199,13 +6199,13 @@ s32 e1000_led_off(struct e1000_hw *hw)
             e1000_write_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL_LED,
                  (IFE_PSCL_PROBE_MODE | IFE_PSCL_PROBE_LEDS_OFF));
         } else if (hw->media_type == e1000_media_type_copper) {
-            E1000_WRITE_REG(hw, LEDCTL, hw->ledctl_mode1);
+            ew32(LEDCTL, hw->ledctl_mode1);
             return E1000_SUCCESS;
         }
         break;
     }
 
-    E1000_WRITE_REG(hw, CTRL, ctrl);
+    ew32(CTRL, ctrl);
 
     return E1000_SUCCESS;
 }
@@ -6219,93 +6219,93 @@ static void e1000_clear_hw_cntrs(struct e1000_hw *hw)
 {
     volatile u32 temp;
 
-    temp = E1000_READ_REG(hw, CRCERRS);
-    temp = E1000_READ_REG(hw, SYMERRS);
-    temp = E1000_READ_REG(hw, MPC);
-    temp = E1000_READ_REG(hw, SCC);
-    temp = E1000_READ_REG(hw, ECOL);
-    temp = E1000_READ_REG(hw, MCC);
-    temp = E1000_READ_REG(hw, LATECOL);
-    temp = E1000_READ_REG(hw, COLC);
-    temp = E1000_READ_REG(hw, DC);
-    temp = E1000_READ_REG(hw, SEC);
-    temp = E1000_READ_REG(hw, RLEC);
-    temp = E1000_READ_REG(hw, XONRXC);
-    temp = E1000_READ_REG(hw, XONTXC);
-    temp = E1000_READ_REG(hw, XOFFRXC);
-    temp = E1000_READ_REG(hw, XOFFTXC);
-    temp = E1000_READ_REG(hw, FCRUC);
+    temp = er32(CRCERRS);
+    temp = er32(SYMERRS);
+    temp = er32(MPC);
+    temp = er32(SCC);
+    temp = er32(ECOL);
+    temp = er32(MCC);
+    temp = er32(LATECOL);
+    temp = er32(COLC);
+    temp = er32(DC);
+    temp = er32(SEC);
+    temp = er32(RLEC);
+    temp = er32(XONRXC);
+    temp = er32(XONTXC);
+    temp = er32(XOFFRXC);
+    temp = er32(XOFFTXC);
+    temp = er32(FCRUC);
 
     if (hw->mac_type != e1000_ich8lan) {
-    temp = E1000_READ_REG(hw, PRC64);
-    temp = E1000_READ_REG(hw, PRC127);
-    temp = E1000_READ_REG(hw, PRC255);
-    temp = E1000_READ_REG(hw, PRC511);
-    temp = E1000_READ_REG(hw, PRC1023);
-    temp = E1000_READ_REG(hw, PRC1522);
-    }
-
-    temp = E1000_READ_REG(hw, GPRC);
-    temp = E1000_READ_REG(hw, BPRC);
-    temp = E1000_READ_REG(hw, MPRC);
-    temp = E1000_READ_REG(hw, GPTC);
-    temp = E1000_READ_REG(hw, GORCL);
-    temp = E1000_READ_REG(hw, GORCH);
-    temp = E1000_READ_REG(hw, GOTCL);
-    temp = E1000_READ_REG(hw, GOTCH);
-    temp = E1000_READ_REG(hw, RNBC);
-    temp = E1000_READ_REG(hw, RUC);
-    temp = E1000_READ_REG(hw, RFC);
-    temp = E1000_READ_REG(hw, ROC);
-    temp = E1000_READ_REG(hw, RJC);
-    temp = E1000_READ_REG(hw, TORL);
-    temp = E1000_READ_REG(hw, TORH);
-    temp = E1000_READ_REG(hw, TOTL);
-    temp = E1000_READ_REG(hw, TOTH);
-    temp = E1000_READ_REG(hw, TPR);
-    temp = E1000_READ_REG(hw, TPT);
+    temp = er32(PRC64);
+    temp = er32(PRC127);
+    temp = er32(PRC255);
+    temp = er32(PRC511);
+    temp = er32(PRC1023);
+    temp = er32(PRC1522);
+    }
+
+    temp = er32(GPRC);
+    temp = er32(BPRC);
+    temp = er32(MPRC);
+    temp = er32(GPTC);
+    temp = er32(GORCL);
+    temp = er32(GORCH);
+    temp = er32(GOTCL);
+    temp = er32(GOTCH);
+    temp = er32(RNBC);
+    temp = er32(RUC);
+    temp = er32(RFC);
+    temp = er32(ROC);
+    temp = er32(RJC);
+    temp = er32(TORL);
+    temp = er32(TORH);
+    temp = er32(TOTL);
+    temp = er32(TOTH);
+    temp = er32(TPR);
+    temp = er32(TPT);
 
     if (hw->mac_type != e1000_ich8lan) {
-    temp = E1000_READ_REG(hw, PTC64);
-    temp = E1000_READ_REG(hw, PTC127);
-    temp = E1000_READ_REG(hw, PTC255);
-    temp = E1000_READ_REG(hw, PTC511);
-    temp = E1000_READ_REG(hw, PTC1023);
-    temp = E1000_READ_REG(hw, PTC1522);
+    temp = er32(PTC64);
+    temp = er32(PTC127);
+    temp = er32(PTC255);
+    temp = er32(PTC511);
+    temp = er32(PTC1023);
+    temp = er32(PTC1522);
     }
 
-    temp = E1000_READ_REG(hw, MPTC);
-    temp = E1000_READ_REG(hw, BPTC);
+    temp = er32(MPTC);
+    temp = er32(BPTC);
 
     if (hw->mac_type < e1000_82543) return;
 
-    temp = E1000_READ_REG(hw, ALGNERRC);
-    temp = E1000_READ_REG(hw, RXERRC);
-    temp = E1000_READ_REG(hw, TNCRS);
-    temp = E1000_READ_REG(hw, CEXTERR);
-    temp = E1000_READ_REG(hw, TSCTC);
-    temp = E1000_READ_REG(hw, TSCTFC);
+    temp = er32(ALGNERRC);
+    temp = er32(RXERRC);
+    temp = er32(TNCRS);
+    temp = er32(CEXTERR);
+    temp = er32(TSCTC);
+    temp = er32(TSCTFC);
 
     if (hw->mac_type <= e1000_82544) return;
 
-    temp = E1000_READ_REG(hw, MGTPRC);
-    temp = E1000_READ_REG(hw, MGTPDC);
-    temp = E1000_READ_REG(hw, MGTPTC);
+    temp = er32(MGTPRC);
+    temp = er32(MGTPDC);
+    temp = er32(MGTPTC);
 
     if (hw->mac_type <= e1000_82547_rev_2) return;
 
-    temp = E1000_READ_REG(hw, IAC);
-    temp = E1000_READ_REG(hw, ICRXOC);
+    temp = er32(IAC);
+    temp = er32(ICRXOC);
 
     if (hw->mac_type == e1000_ich8lan) return;
 
-    temp = E1000_READ_REG(hw, ICRXPTC);
-    temp = E1000_READ_REG(hw, ICRXATC);
-    temp = E1000_READ_REG(hw, ICTXPTC);
-    temp = E1000_READ_REG(hw, ICTXATC);
-    temp = E1000_READ_REG(hw, ICTXQEC);
-    temp = E1000_READ_REG(hw, ICTXQMTC);
-    temp = E1000_READ_REG(hw, ICRXDMTC);
+    temp = er32(ICRXPTC);
+    temp = er32(ICRXATC);
+    temp = er32(ICTXPTC);
+    temp = er32(ICTXATC);
+    temp = er32(ICTXQEC);
+    temp = er32(ICTXQMTC);
+    temp = er32(ICRXDMTC);
 }
 
 /******************************************************************************
@@ -6331,7 +6331,7 @@ void e1000_reset_adaptive(struct e1000_hw *hw)
             hw->ifs_ratio = IFS_RATIO;
         }
         hw->in_ifs_mode = false;
-        E1000_WRITE_REG(hw, AIT, 0);
+        ew32(AIT, 0);
     } else {
         DEBUGOUT("Not in Adaptive IFS mode!\n");
     }
@@ -6358,14 +6358,14 @@ void e1000_update_adaptive(struct e1000_hw *hw)
                         hw->current_ifs_val = hw->ifs_min_val;
                     else
                         hw->current_ifs_val += hw->ifs_step_size;
-                    E1000_WRITE_REG(hw, AIT, hw->current_ifs_val);
+                    ew32(AIT, hw->current_ifs_val);
                 }
             }
         } else {
             if (hw->in_ifs_mode && (hw->tx_packet_delta <= MIN_NUM_XMITS)) {
                 hw->current_ifs_val = 0;
                 hw->in_ifs_mode = false;
-                E1000_WRITE_REG(hw, AIT, 0);
+                ew32(AIT, 0);
             }
         }
     } else {
@@ -6489,7 +6489,7 @@ void e1000_get_bus_info(struct e1000_hw *hw)
         hw->bus_width = e1000_bus_width_pciex_1;
         break;
     default:
-        status = E1000_READ_REG(hw, STATUS);
+        status = er32(STATUS);
         hw->bus_type = (status & E1000_STATUS_PCIX_MODE) ?
                        e1000_bus_type_pcix : e1000_bus_type_pci;
 
@@ -7114,7 +7114,7 @@ static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
         /* MAC writes into PHY register based on the state transition
          * and start auto-negotiation. SW driver can overwrite the settings
          * in CSR PHY power control E1000_PHY_CTRL register. */
-        phy_ctrl = E1000_READ_REG(hw, PHY_CTRL);
+        phy_ctrl = er32(PHY_CTRL);
     } else {
         ret_val = e1000_read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, &phy_data);
         if (ret_val)
@@ -7131,7 +7131,7 @@ static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
         } else {
             if (hw->mac_type == e1000_ich8lan) {
                 phy_ctrl &= ~E1000_PHY_CTRL_NOND0A_LPLU;
-                E1000_WRITE_REG(hw, PHY_CTRL, phy_ctrl);
+                ew32(PHY_CTRL, phy_ctrl);
             } else {
                 phy_data &= ~IGP02E1000_PM_D3_LPLU;
                 ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
@@ -7182,7 +7182,7 @@ static s32 e1000_set_d3_lplu_state(struct e1000_hw *hw, bool active)
         } else {
             if (hw->mac_type == e1000_ich8lan) {
                 phy_ctrl |= E1000_PHY_CTRL_NOND0A_LPLU;
-                E1000_WRITE_REG(hw, PHY_CTRL, phy_ctrl);
+                ew32(PHY_CTRL, phy_ctrl);
             } else {
                 phy_data |= IGP02E1000_PM_D3_LPLU;
                 ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
@@ -7231,7 +7231,7 @@ static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
         return E1000_SUCCESS;
 
     if (hw->mac_type == e1000_ich8lan) {
-        phy_ctrl = E1000_READ_REG(hw, PHY_CTRL);
+        phy_ctrl = er32(PHY_CTRL);
     } else {
         ret_val = e1000_read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, &phy_data);
         if (ret_val)
@@ -7241,7 +7241,7 @@ static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
     if (!active) {
         if (hw->mac_type == e1000_ich8lan) {
             phy_ctrl &= ~E1000_PHY_CTRL_D0A_LPLU;
-            E1000_WRITE_REG(hw, PHY_CTRL, phy_ctrl);
+            ew32(PHY_CTRL, phy_ctrl);
         } else {
             phy_data &= ~IGP02E1000_PM_D0_LPLU;
             ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
@@ -7282,7 +7282,7 @@ static s32 e1000_set_d0_lplu_state(struct e1000_hw *hw, bool active)
 
         if (hw->mac_type == e1000_ich8lan) {
             phy_ctrl |= E1000_PHY_CTRL_D0A_LPLU;
-            E1000_WRITE_REG(hw, PHY_CTRL, phy_ctrl);
+            ew32(PHY_CTRL, phy_ctrl);
         } else {
             phy_data |= IGP02E1000_PM_D0_LPLU;
             ret_val = e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
@@ -7404,14 +7404,14 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
     u8 i;
 
     /* Check that the host interface is enabled. */
-    hicr = E1000_READ_REG(hw, HICR);
+    hicr = er32(HICR);
     if ((hicr & E1000_HICR_EN) == 0) {
         DEBUGOUT("E1000_HOST_EN bit disabled.\n");
         return -E1000_ERR_HOST_INTERFACE_COMMAND;
     }
     /* check the previous command is completed */
     for (i = 0; i < E1000_MNG_DHCP_COMMAND_TIMEOUT; i++) {
-        hicr = E1000_READ_REG(hw, HICR);
+        hicr = er32(HICR);
         if (!(hicr & E1000_HICR_C))
             break;
         mdelay(1);
@@ -7524,7 +7524,7 @@ static s32 e1000_mng_write_cmd_header(struct e1000_hw *hw,
     /* The device driver writes the relevant command block into the ram area. */
     for (i = 0; i < length; i++) {
         E1000_WRITE_REG_ARRAY_DWORD(hw, HOST_IF, i, *((u32 *) hdr + i));
-        E1000_WRITE_FLUSH(hw);
+        E1000_WRITE_FLUSH();
     }
 
     return E1000_SUCCESS;
@@ -7541,9 +7541,9 @@ static s32 e1000_mng_write_commit(struct e1000_hw *hw)
 {
     u32 hicr;
 
-    hicr = E1000_READ_REG(hw, HICR);
+    hicr = er32(HICR);
     /* Setting this bit tells the ARC that a new command is pending. */
-    E1000_WRITE_REG(hw, HICR, hicr | E1000_HICR_C);
+    ew32(HICR, hicr | E1000_HICR_C);
 
     return E1000_SUCCESS;
 }
@@ -7558,7 +7558,7 @@ bool e1000_check_mng_mode(struct e1000_hw *hw)
 {
     u32 fwsm;
 
-    fwsm = E1000_READ_REG(hw, FWSM);
+    fwsm = er32(FWSM);
 
     if (hw->mac_type == e1000_ich8lan) {
         if ((fwsm & E1000_FWSM_MODE_MASK) ==
@@ -7671,14 +7671,14 @@ u32 e1000_enable_mng_pass_thru(struct e1000_hw *hw)
     u32 fwsm, factps;
 
     if (hw->asf_firmware_present) {
-        manc = E1000_READ_REG(hw, MANC);
+        manc = er32(MANC);
 
         if (!(manc & E1000_MANC_RCV_TCO_EN) ||
             !(manc & E1000_MANC_EN_MAC_ADDR_FILTER))
             return false;
         if (e1000_arc_subsystem_valid(hw)) {
-            fwsm = E1000_READ_REG(hw, FWSM);
-            factps = E1000_READ_REG(hw, FACTPS);
+            fwsm = er32(FWSM);
+            factps = er32(FACTPS);
 
             if ((((fwsm & E1000_FWSM_MODE_MASK) >> E1000_FWSM_MODE_SHIFT) ==
                    e1000_mng_mode_pt) && !(factps & E1000_FACTPS_MNGCG))
@@ -7792,9 +7792,9 @@ static void e1000_set_pci_express_master_disable(struct e1000_hw *hw)
     if (hw->bus_type != e1000_bus_type_pci_express)
         return;
 
-    ctrl = E1000_READ_REG(hw, CTRL);
+    ctrl = er32(CTRL);
     ctrl |= E1000_CTRL_GIO_MASTER_DISABLE;
-    E1000_WRITE_REG(hw, CTRL, ctrl);
+    ew32(CTRL, ctrl);
 }
 
 /*******************************************************************************
@@ -7820,7 +7820,7 @@ s32 e1000_disable_pciex_master(struct e1000_hw *hw)
     e1000_set_pci_express_master_disable(hw);
 
     while (timeout) {
-        if (!(E1000_READ_REG(hw, STATUS) & E1000_STATUS_GIO_MASTER_ENABLE))
+        if (!(er32(STATUS) & E1000_STATUS_GIO_MASTER_ENABLE))
             break;
         else
             udelay(100);
@@ -7861,7 +7861,7 @@ static s32 e1000_get_auto_rd_done(struct e1000_hw *hw)
     case e1000_80003es2lan:
     case e1000_ich8lan:
         while (timeout) {
-            if (E1000_READ_REG(hw, EECD) & E1000_EECD_AUTO_RD)
+            if (er32(EECD) & E1000_EECD_AUTO_RD)
                 break;
             else msleep(1);
             timeout--;
@@ -7905,13 +7905,13 @@ static s32 e1000_get_phy_cfg_done(struct e1000_hw *hw)
         break;
     case e1000_80003es2lan:
         /* Separate *_CFG_DONE_* bit for each port */
-        if (E1000_READ_REG(hw, STATUS) & E1000_STATUS_FUNC_1)
+        if (er32(STATUS) & E1000_STATUS_FUNC_1)
             cfg_mask = E1000_EEPROM_CFG_DONE_PORT_1;
         /* Fall Through */
     case e1000_82571:
     case e1000_82572:
         while (timeout) {
-            if (E1000_READ_REG(hw, EEMNGCTL) & cfg_mask)
+            if (er32(EEMNGCTL) & cfg_mask)
                 break;
             else
                 msleep(1);
@@ -7957,11 +7957,11 @@ static s32 e1000_get_hw_eeprom_semaphore(struct e1000_hw *hw)
     /* Get the FW semaphore. */
     timeout = hw->eeprom.word_size + 1;
     while (timeout) {
-        swsm = E1000_READ_REG(hw, SWSM);
+        swsm = er32(SWSM);
         swsm |= E1000_SWSM_SWESMBI;
-        E1000_WRITE_REG(hw, SWSM, swsm);
+        ew32(SWSM, swsm);
         /* if we managed to set the bit we got the semaphore. */
-        swsm = E1000_READ_REG(hw, SWSM);
+        swsm = er32(SWSM);
         if (swsm & E1000_SWSM_SWESMBI)
             break;
 
@@ -7996,13 +7996,13 @@ static void e1000_put_hw_eeprom_semaphore(struct e1000_hw *hw)
     if (!hw->eeprom_semaphore_present)
         return;
 
-    swsm = E1000_READ_REG(hw, SWSM);
+    swsm = er32(SWSM);
     if (hw->mac_type == e1000_80003es2lan) {
         /* Release both semaphores. */
         swsm &= ~(E1000_SWSM_SMBI | E1000_SWSM_SWESMBI);
     } else
         swsm &= ~(E1000_SWSM_SWESMBI);
-    E1000_WRITE_REG(hw, SWSM, swsm);
+    ew32(SWSM, swsm);
 }
 
 /***************************************************************************
@@ -8027,7 +8027,7 @@ static s32 e1000_get_software_semaphore(struct e1000_hw *hw)
     }
 
     while (timeout) {
-        swsm = E1000_READ_REG(hw, SWSM);
+        swsm = er32(SWSM);
         /* If SMBI bit cleared, it is now set and we hold the semaphore */
         if (!(swsm & E1000_SWSM_SMBI))
             break;
@@ -8060,10 +8060,10 @@ static void e1000_release_software_semaphore(struct e1000_hw *hw)
         return;
     }
 
-    swsm = E1000_READ_REG(hw, SWSM);
+    swsm = er32(SWSM);
     /* Release the SW semaphores.*/
     swsm &= ~E1000_SWSM_SMBI;
-    E1000_WRITE_REG(hw, SWSM, swsm);
+    ew32(SWSM, swsm);
 }
 
 /******************************************************************************
@@ -8083,13 +8083,13 @@ s32 e1000_check_phy_reset_block(struct e1000_hw *hw)
     u32 fwsm = 0;
 
     if (hw->mac_type == e1000_ich8lan) {
-        fwsm = E1000_READ_REG(hw, FWSM);
+        fwsm = er32(FWSM);
         return (fwsm & E1000_FWSM_RSPCIPHY) ? E1000_SUCCESS
                                             : E1000_BLK_PHY_RESET;
     }
 
     if (hw->mac_type > e1000_82547_rev_2)
-        manc = E1000_READ_REG(hw, MANC);
+        manc = er32(MANC);
     return (manc & E1000_MANC_BLK_PHY_RST_ON_IDE) ?
         E1000_BLK_PHY_RESET : E1000_SUCCESS;
 }
@@ -8108,7 +8108,7 @@ static u8 e1000_arc_subsystem_valid(struct e1000_hw *hw)
     case e1000_82572:
     case e1000_82573:
     case e1000_80003es2lan:
-        fwsm = E1000_READ_REG(hw, FWSM);
+        fwsm = er32(FWSM);
         if ((fwsm & E1000_FWSM_MODE_MASK) != 0)
             return true;
         break;
@@ -8143,19 +8143,19 @@ static s32 e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, u32 no_snoop)
         return E1000_SUCCESS;
 
     if (no_snoop) {
-        gcr_reg = E1000_READ_REG(hw, GCR);
+        gcr_reg = er32(GCR);
         gcr_reg &= ~(PCI_EX_NO_SNOOP_ALL);
         gcr_reg |= no_snoop;
-        E1000_WRITE_REG(hw, GCR, gcr_reg);
+        ew32(GCR, gcr_reg);
     }
     if (hw->mac_type == e1000_ich8lan) {
         u32 ctrl_ext;
 
-        E1000_WRITE_REG(hw, GCR, PCI_EX_82566_SNOOP_ALL);
+        ew32(GCR, PCI_EX_82566_SNOOP_ALL);
 
-        ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+        ctrl_ext = er32(CTRL_EXT);
         ctrl_ext |= E1000_CTRL_EXT_RO_DIS;
-        E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
+        ew32(CTRL_EXT, ctrl_ext);
     }
 
     return E1000_SUCCESS;
@@ -8179,11 +8179,11 @@ static s32 e1000_get_software_flag(struct e1000_hw *hw)
 
     if (hw->mac_type == e1000_ich8lan) {
         while (timeout) {
-            extcnf_ctrl = E1000_READ_REG(hw, EXTCNF_CTRL);
+            extcnf_ctrl = er32(EXTCNF_CTRL);
             extcnf_ctrl |= E1000_EXTCNF_CTRL_SWFLAG;
-            E1000_WRITE_REG(hw, EXTCNF_CTRL, extcnf_ctrl);
+            ew32(EXTCNF_CTRL, extcnf_ctrl);
 
-            extcnf_ctrl = E1000_READ_REG(hw, EXTCNF_CTRL);
+            extcnf_ctrl = er32(EXTCNF_CTRL);
             if (extcnf_ctrl & E1000_EXTCNF_CTRL_SWFLAG)
                 break;
             mdelay(1);
@@ -8215,9 +8215,9 @@ static void e1000_release_software_flag(struct e1000_hw *hw)
     DEBUGFUNC("e1000_release_software_flag");
 
     if (hw->mac_type == e1000_ich8lan) {
-        extcnf_ctrl= E1000_READ_REG(hw, EXTCNF_CTRL);
+        extcnf_ctrl= er32(EXTCNF_CTRL);
         extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
-        E1000_WRITE_REG(hw, EXTCNF_CTRL, extcnf_ctrl);
+        ew32(EXTCNF_CTRL, extcnf_ctrl);
     }
 
     return;
@@ -8248,7 +8248,7 @@ static s32 e1000_read_eeprom_ich8(struct e1000_hw *hw, u16 offset, u16 words,
      * to be updated with each read.
      */
     /* Value of bit 22 corresponds to the flash bank we're on. */
-    flash_bank = (E1000_READ_REG(hw, EECD) & E1000_EECD_SEC1VAL) ? 1 : 0;
+    flash_bank = (er32(EECD) & E1000_EECD_SEC1VAL) ? 1 : 0;
 
     /* Adjust offset appropriately if we're on bank 1 - adjust for word size */
     bank_offset = flash_bank * (hw->flash_bank_size * 2);
@@ -8813,32 +8813,32 @@ static s32 e1000_init_lcd_from_nvm(struct e1000_hw *hw)
           return E1000_SUCCESS;
 
     /* Check if SW needs configure the PHY */
-    reg_data = E1000_READ_REG(hw, FEXTNVM);
+    reg_data = er32(FEXTNVM);
     if (!(reg_data & FEXTNVM_SW_CONFIG))
         return E1000_SUCCESS;
 
     /* Wait for basic configuration completes before proceeding*/
     loop = 0;
     do {
-        reg_data = E1000_READ_REG(hw, STATUS) & E1000_STATUS_LAN_INIT_DONE;
+        reg_data = er32(STATUS) & E1000_STATUS_LAN_INIT_DONE;
         udelay(100);
         loop++;
     } while ((!reg_data) && (loop < 50));
 
     /* Clear the Init Done bit for the next init event */
-    reg_data = E1000_READ_REG(hw, STATUS);
+    reg_data = er32(STATUS);
     reg_data &= ~E1000_STATUS_LAN_INIT_DONE;
-    E1000_WRITE_REG(hw, STATUS, reg_data);
+    ew32(STATUS, reg_data);
 
     /* Make sure HW does not configure LCD from PHY extended configuration
        before SW configuration */
-    reg_data = E1000_READ_REG(hw, EXTCNF_CTRL);
+    reg_data = er32(EXTCNF_CTRL);
     if ((reg_data & E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE) == 0x0000) {
-        reg_data = E1000_READ_REG(hw, EXTCNF_SIZE);
+        reg_data = er32(EXTCNF_SIZE);
         cnf_size = reg_data & E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH;
         cnf_size >>= 16;
         if (cnf_size) {
-            reg_data = E1000_READ_REG(hw, EXTCNF_CTRL);
+            reg_data = er32(EXTCNF_CTRL);
             cnf_base_addr = reg_data & E1000_EXTCNF_CTRL_EXT_CNF_POINTER;
             /* cnf_base_addr is in DWORD */
             cnf_base_addr >>= 16;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 09abaec..404c2d4 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -269,12 +269,13 @@ module_exit(e1000_exit_module);
 
 static int e1000_request_irq(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	irq_handler_t handler = e1000_intr;
 	int irq_flags = IRQF_SHARED;
 	int err;
 
-	if (adapter->hw.mac_type >= e1000_82571) {
+	if (hw->mac_type >= e1000_82571) {
 		adapter->have_msi = !pci_enable_msi(adapter->pdev);
 		if (adapter->have_msi) {
 			handler = e1000_intr_msi;
@@ -311,8 +312,10 @@ static void e1000_free_irq(struct e1000_adapter *adapter)
 
 static void e1000_irq_disable(struct e1000_adapter *adapter)
 {
-	E1000_WRITE_REG(&adapter->hw, IMC, ~0);
-	E1000_WRITE_FLUSH(&adapter->hw);
+	struct e1000_hw *hw = &adapter->hw;
+
+	ew32(IMC, ~0);
+	E1000_WRITE_FLUSH();
 	synchronize_irq(adapter->pdev->irq);
 }
 
@@ -323,18 +326,21 @@ static void e1000_irq_disable(struct e1000_adapter *adapter)
 
 static void e1000_irq_enable(struct e1000_adapter *adapter)
 {
-	E1000_WRITE_REG(&adapter->hw, IMS, IMS_ENABLE_MASK);
-	E1000_WRITE_FLUSH(&adapter->hw);
+	struct e1000_hw *hw = &adapter->hw;
+
+	ew32(IMS, IMS_ENABLE_MASK);
+	E1000_WRITE_FLUSH();
 }
 
 static void e1000_update_mng_vlan(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
-	u16 vid = adapter->hw.mng_cookie.vlan_id;
+	u16 vid = hw->mng_cookie.vlan_id;
 	u16 old_vid = adapter->mng_vlan_id;
 	if (adapter->vlgrp) {
 		if (!vlan_group_get_device(adapter->vlgrp, vid)) {
-			if (adapter->hw.mng_cookie.status &
+			if (hw->mng_cookie.status &
 				E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) {
 				e1000_vlan_rx_add_vid(netdev, vid);
 				adapter->mng_vlan_id = vid;
@@ -365,21 +371,20 @@ static void e1000_release_hw_control(struct e1000_adapter *adapter)
 {
 	u32 ctrl_ext;
 	u32 swsm;
+	struct e1000_hw *hw = &adapter->hw;
 
 	/* Let firmware taken over control of h/w */
-	switch (adapter->hw.mac_type) {
+	switch (hw->mac_type) {
 	case e1000_82573:
-		swsm = E1000_READ_REG(&adapter->hw, SWSM);
-		E1000_WRITE_REG(&adapter->hw, SWSM,
-				swsm & ~E1000_SWSM_DRV_LOAD);
+		swsm = er32(SWSM);
+		ew32(SWSM, swsm & ~E1000_SWSM_DRV_LOAD);
 		break;
 	case e1000_82571:
 	case e1000_82572:
 	case e1000_80003es2lan:
 	case e1000_ich8lan:
-		ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
-		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
-				ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
+		ctrl_ext = er32(CTRL_EXT);
+		ew32(CTRL_EXT, ctrl_ext & ~E1000_CTRL_EXT_DRV_LOAD);
 		break;
 	default:
 		break;
@@ -401,21 +406,20 @@ static void e1000_get_hw_control(struct e1000_adapter *adapter)
 {
 	u32 ctrl_ext;
 	u32 swsm;
+	struct e1000_hw *hw = &adapter->hw;
 
 	/* Let firmware know the driver has taken over */
-	switch (adapter->hw.mac_type) {
+	switch (hw->mac_type) {
 	case e1000_82573:
-		swsm = E1000_READ_REG(&adapter->hw, SWSM);
-		E1000_WRITE_REG(&adapter->hw, SWSM,
-				swsm | E1000_SWSM_DRV_LOAD);
+		swsm = er32(SWSM);
+		ew32(SWSM, swsm | E1000_SWSM_DRV_LOAD);
 		break;
 	case e1000_82571:
 	case e1000_82572:
 	case e1000_80003es2lan:
 	case e1000_ich8lan:
-		ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
-		E1000_WRITE_REG(&adapter->hw, CTRL_EXT,
-				ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
+		ctrl_ext = er32(CTRL_EXT);
+		ew32(CTRL_EXT, ctrl_ext | E1000_CTRL_EXT_DRV_LOAD);
 		break;
 	default:
 		break;
@@ -424,8 +428,10 @@ static void e1000_get_hw_control(struct e1000_adapter *adapter)
 
 static void e1000_init_manageability(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
+
 	if (adapter->en_mng_pt) {
-		u32 manc = E1000_READ_REG(&adapter->hw, MANC);
+		u32 manc = er32(MANC);
 
 		/* disable hardware interception of ARP */
 		manc &= ~(E1000_MANC_ARP_EN);
@@ -433,36 +439,38 @@ static void e1000_init_manageability(struct e1000_adapter *adapter)
 		/* enable receiving management packets to the host */
 		/* this will probably generate destination unreachable messages
 		 * from the host OS, but the packets will be handled on SMBUS */
-		if (adapter->hw.has_manc2h) {
-			u32 manc2h = E1000_READ_REG(&adapter->hw, MANC2H);
+		if (hw->has_manc2h) {
+			u32 manc2h = er32(MANC2H);
 
 			manc |= E1000_MANC_EN_MNG2HOST;
 #define E1000_MNG2HOST_PORT_623 (1 << 5)
 #define E1000_MNG2HOST_PORT_664 (1 << 6)
 			manc2h |= E1000_MNG2HOST_PORT_623;
 			manc2h |= E1000_MNG2HOST_PORT_664;
-			E1000_WRITE_REG(&adapter->hw, MANC2H, manc2h);
+			ew32(MANC2H, manc2h);
 		}
 
-		E1000_WRITE_REG(&adapter->hw, MANC, manc);
+		ew32(MANC, manc);
 	}
 }
 
 static void e1000_release_manageability(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
+
 	if (adapter->en_mng_pt) {
-		u32 manc = E1000_READ_REG(&adapter->hw, MANC);
+		u32 manc = er32(MANC);
 
 		/* re-enable hardware interception of ARP */
 		manc |= E1000_MANC_ARP_EN;
 
-		if (adapter->hw.has_manc2h)
+		if (hw->has_manc2h)
 			manc &= ~E1000_MANC_EN_MNG2HOST;
 
 		/* don't explicitly have to mess with MANC2H since
 		 * MANC has an enable disable that gates MANC2H */
 
-		E1000_WRITE_REG(&adapter->hw, MANC, manc);
+		ew32(MANC, manc);
 	}
 }
 
@@ -497,6 +505,8 @@ static void e1000_configure(struct e1000_adapter *adapter)
 
 int e1000_up(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
+
 	/* hardware has been reset, we need to reload some things */
 	e1000_configure(adapter);
 
@@ -508,7 +518,7 @@ int e1000_up(struct e1000_adapter *adapter)
 	e1000_irq_enable(adapter);
 
 	/* fire a link change interrupt to start the watchdog */
-	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
+	ew32(ICS, E1000_ICS_LSC);
 	return 0;
 }
 
@@ -524,30 +534,33 @@ int e1000_up(struct e1000_adapter *adapter)
 
 void e1000_power_up_phy(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u16 mii_reg = 0;
 
 	/* Just clear the power down bit to wake the phy back up */
-	if (adapter->hw.media_type == e1000_media_type_copper) {
+	if (hw->media_type == e1000_media_type_copper) {
 		/* according to the manual, the phy will retain its
 		 * settings across a power-down/up cycle */
-		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
+		e1000_read_phy_reg(hw, PHY_CTRL, &mii_reg);
 		mii_reg &= ~MII_CR_POWER_DOWN;
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, mii_reg);
+		e1000_write_phy_reg(hw, PHY_CTRL, mii_reg);
 	}
 }
 
 static void e1000_power_down_phy(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
+
 	/* Power down the PHY so no link is implied when interface is down *
 	 * The PHY cannot be powered down if any of the following is true *
 	 * (a) WoL is enabled
 	 * (b) AMT is active
 	 * (c) SoL/IDER session is active */
-	if (!adapter->wol && adapter->hw.mac_type >= e1000_82540 &&
-	   adapter->hw.media_type == e1000_media_type_copper) {
+	if (!adapter->wol && hw->mac_type >= e1000_82540 &&
+	   hw->media_type == e1000_media_type_copper) {
 		u16 mii_reg = 0;
 
-		switch (adapter->hw.mac_type) {
+		switch (hw->mac_type) {
 		case e1000_82540:
 		case e1000_82545:
 		case e1000_82545_rev_3:
@@ -557,8 +570,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 		case e1000_82541_rev_2:
 		case e1000_82547:
 		case e1000_82547_rev_2:
-			if (E1000_READ_REG(&adapter->hw, MANC) &
-			    E1000_MANC_SMBUS_EN)
+			if (er32(MANC) & E1000_MANC_SMBUS_EN)
 				goto out;
 			break;
 		case e1000_82571:
@@ -566,16 +578,16 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 		case e1000_82573:
 		case e1000_80003es2lan:
 		case e1000_ich8lan:
-			if (e1000_check_mng_mode(&adapter->hw) ||
-			    e1000_check_phy_reset_block(&adapter->hw))
+			if (e1000_check_mng_mode(hw) ||
+			    e1000_check_phy_reset_block(hw))
 				goto out;
 			break;
 		default:
 			goto out;
 		}
-		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
+		e1000_read_phy_reg(hw, PHY_CTRL, &mii_reg);
 		mii_reg |= MII_CR_POWER_DOWN;
-		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, mii_reg);
+		e1000_write_phy_reg(hw, PHY_CTRL, mii_reg);
 		mdelay(1);
 	}
 out:
@@ -622,6 +634,7 @@ void e1000_reinit_locked(struct e1000_adapter *adapter)
 
 void e1000_reset(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u32 pba = 0, tx_space, min_tx_space, min_rx_space;
 	u16 fc_high_water_mark = E1000_FC_HIGH_DIFF;
 	bool legacy_pba_adjust = false;
@@ -630,7 +643,7 @@ void e1000_reset(struct e1000_adapter *adapter)
 	 * To take effect CTRL.RST is required.
 	 */
 
-	switch (adapter->hw.mac_type) {
+	switch (hw->mac_type) {
 	case e1000_82542_rev2_0:
 	case e1000_82542_rev2_1:
 	case e1000_82543:
@@ -671,16 +684,16 @@ void e1000_reset(struct e1000_adapter *adapter)
 		if (adapter->netdev->mtu > E1000_RXBUFFER_8192)
 			pba -= 8; /* allocate more FIFO for Tx */
 
-		if (adapter->hw.mac_type == e1000_82547) {
+		if (hw->mac_type == e1000_82547) {
 			adapter->tx_fifo_head = 0;
 			adapter->tx_head_addr = pba << E1000_TX_HEAD_ADDR_SHIFT;
 			adapter->tx_fifo_size =
 				(E1000_PBA_40K - pba) << E1000_PBA_BYTES_SHIFT;
 			atomic_set(&adapter->tx_fifo_stall, 0);
 		}
-	} else if (adapter->hw.max_frame_size > MAXIMUM_ETHERNET_FRAME_SIZE) {
+	} else if (hw->max_frame_size > MAXIMUM_ETHERNET_FRAME_SIZE) {
 		/* adjust PBA for jumbo frames */
-		E1000_WRITE_REG(&adapter->hw, PBA, pba);
+		ew32(PBA, pba);
 
 		/* To maintain wire speed transmits, the Tx FIFO should be
 		 * large enough to accomodate two full transmit packets,
@@ -688,7 +701,7 @@ void e1000_reset(struct e1000_adapter *adapter)
 		 * the Rx FIFO should be large enough to accomodate at least
 		 * one full receive packet and is similarly rounded up and
 		 * expressed in KB. */
-		pba = E1000_READ_REG(&adapter->hw, PBA);
+		pba = er32(PBA);
 		/* upper 16 bits has Tx packet buffer allocation size in KB */
 		tx_space = pba >> 16;
 		/* lower 16 bits has Rx packet buffer allocation size in KB */
@@ -711,7 +724,7 @@ void e1000_reset(struct e1000_adapter *adapter)
 			pba = pba - (min_tx_space - tx_space);
 
 			/* PCI/PCIx hardware has PBA alignment constraints */
-			switch (adapter->hw.mac_type) {
+			switch (hw->mac_type) {
 			case e1000_82545 ... e1000_82546_rev_3:
 				pba &= ~(E1000_PBA_8K - 1);
 				break;
@@ -722,7 +735,7 @@ void e1000_reset(struct e1000_adapter *adapter)
 			/* if short on rx space, rx wins and must trump tx
 			 * adjustment or use Early Receive if available */
 			if (pba < min_rx_space) {
-				switch (adapter->hw.mac_type) {
+				switch (hw->mac_type) {
 				case e1000_82573:
 					/* ERT enabled in e1000_configure_rx */
 					break;
@@ -734,7 +747,7 @@ void e1000_reset(struct e1000_adapter *adapter)
 		}
 	}
 
-	E1000_WRITE_REG(&adapter->hw, PBA, pba);
+	ew32(PBA, pba);
 
 	/* flow control settings */
 	/* Set the FC high water mark to 90% of the FIFO size.
@@ -747,54 +760,54 @@ void e1000_reset(struct e1000_adapter *adapter)
 	if (pba < E1000_PBA_16K)
 		fc_high_water_mark = (pba * 1024) - 1600;
 
-	adapter->hw.fc_high_water = fc_high_water_mark;
-	adapter->hw.fc_low_water = fc_high_water_mark - 8;
-	if (adapter->hw.mac_type == e1000_80003es2lan)
-		adapter->hw.fc_pause_time = 0xFFFF;
+	hw->fc_high_water = fc_high_water_mark;
+	hw->fc_low_water = fc_high_water_mark - 8;
+	if (hw->mac_type == e1000_80003es2lan)
+		hw->fc_pause_time = 0xFFFF;
 	else
-		adapter->hw.fc_pause_time = E1000_FC_PAUSE_TIME;
-	adapter->hw.fc_send_xon = 1;
-	adapter->hw.fc = adapter->hw.original_fc;
+		hw->fc_pause_time = E1000_FC_PAUSE_TIME;
+	hw->fc_send_xon = 1;
+	hw->fc = hw->original_fc;
 
 	/* Allow time for pending master requests to run */
-	e1000_reset_hw(&adapter->hw);
-	if (adapter->hw.mac_type >= e1000_82544)
-		E1000_WRITE_REG(&adapter->hw, WUC, 0);
+	e1000_reset_hw(hw);
+	if (hw->mac_type >= e1000_82544)
+		ew32(WUC, 0);
 
-	if (e1000_init_hw(&adapter->hw))
+	if (e1000_init_hw(hw))
 		DPRINTK(PROBE, ERR, "Hardware Error\n");
 	e1000_update_mng_vlan(adapter);
 
 	/* if (adapter->hwflags & HWFLAGS_PHY_PWR_BIT) { */
-	if (adapter->hw.mac_type >= e1000_82544 &&
-	    adapter->hw.mac_type <= e1000_82547_rev_2 &&
-	    adapter->hw.autoneg == 1 &&
-	    adapter->hw.autoneg_advertised == ADVERTISE_1000_FULL) {
-		u32 ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+	if (hw->mac_type >= e1000_82544 &&
+	    hw->mac_type <= e1000_82547_rev_2 &&
+	    hw->autoneg == 1 &&
+	    hw->autoneg_advertised == ADVERTISE_1000_FULL) {
+		u32 ctrl = er32(CTRL);
 		/* clear phy power management bit if we are in gig only mode,
 		 * which if enabled will attempt negotiation to 100Mb, which
 		 * can cause a loss of link at power off or driver unload */
 		ctrl &= ~E1000_CTRL_SWDPIN3;
-		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
+		ew32(CTRL, ctrl);
 	}
 
 	/* Enable h/w to recognize an 802.1Q VLAN Ethernet packet */
-	E1000_WRITE_REG(&adapter->hw, VET, ETHERNET_IEEE_VLAN_TYPE);
+	ew32(VET, ETHERNET_IEEE_VLAN_TYPE);
 
-	e1000_reset_adaptive(&adapter->hw);
-	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
+	e1000_reset_adaptive(hw);
+	e1000_phy_get_info(hw, &adapter->phy_info);
 
 	if (!adapter->smart_power_down &&
-	    (adapter->hw.mac_type == e1000_82571 ||
-	     adapter->hw.mac_type == e1000_82572)) {
+	    (hw->mac_type == e1000_82571 ||
+	     hw->mac_type == e1000_82572)) {
 		u16 phy_data = 0;
 		/* speed up time to link by disabling smart power down, ignore
 		 * the return value of this function because there is nothing
 		 * different we would do if it failed */
-		e1000_read_phy_reg(&adapter->hw, IGP02E1000_PHY_POWER_MGMT,
+		e1000_read_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
 		                   &phy_data);
 		phy_data &= ~IGP02E1000_PM_SPD;
-		e1000_write_phy_reg(&adapter->hw, IGP02E1000_PHY_POWER_MGMT,
+		e1000_write_phy_reg(hw, IGP02E1000_PHY_POWER_MGMT,
 		                    phy_data);
 	}
 
@@ -871,12 +884,12 @@ static void e1000_dump_eeprom(struct e1000_adapter *adapter)
  * and a hardware reset occur.
  **/
 
-static int __devinit
-e1000_probe(struct pci_dev *pdev,
-            const struct pci_device_id *ent)
+static int __devinit e1000_probe(struct pci_dev *pdev,
+				 const struct pci_device_id *ent)
 {
 	struct net_device *netdev;
 	struct e1000_adapter *adapter;
+	struct e1000_hw *hw;
 
 	static int cards_found = 0;
 	static int global_quad_port_a = 0; /* global ksp3 port a indication */
@@ -916,20 +929,22 @@ e1000_probe(struct pci_dev *pdev,
 	adapter = netdev_priv(netdev);
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
-	adapter->hw.back = adapter;
 	adapter->msg_enable = (1 << debug) - 1;
 
+	hw = &adapter->hw;
+	hw->back = adapter;
+
 	err = -EIO;
-	adapter->hw.hw_addr = ioremap(pci_resource_start(pdev, BAR_0),
-				      pci_resource_len(pdev, BAR_0));
-	if (!adapter->hw.hw_addr)
+	hw->hw_addr = ioremap(pci_resource_start(pdev, BAR_0),
+			      pci_resource_len(pdev, BAR_0));
+	if (!hw->hw_addr)
 		goto err_ioremap;
 
 	for (i = BAR_1; i <= BAR_5; i++) {
 		if (pci_resource_len(pdev, i) == 0)
 			continue;
 		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
-			adapter->hw.io_base = pci_resource_start(pdev, i);
+			hw->io_base = pci_resource_start(pdev, i);
 			break;
 		}
 	}
@@ -966,43 +981,43 @@ e1000_probe(struct pci_dev *pdev,
 	err = -EIO;
 	/* Flash BAR mapping must happen after e1000_sw_init
 	 * because it depends on mac_type */
-	if ((adapter->hw.mac_type == e1000_ich8lan) &&
+	if ((hw->mac_type == e1000_ich8lan) &&
 	   (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
-		adapter->hw.flash_address =
+		hw->flash_address =
 			ioremap(pci_resource_start(pdev, 1),
 				pci_resource_len(pdev, 1));
-		if (!adapter->hw.flash_address)
+		if (!hw->flash_address)
 			goto err_flashmap;
 	}
 
-	if (e1000_check_phy_reset_block(&adapter->hw))
+	if (e1000_check_phy_reset_block(hw))
 		DPRINTK(PROBE, INFO, "PHY reset is blocked due to SOL/IDER session.\n");
 
-	if (adapter->hw.mac_type >= e1000_82543) {
+	if (hw->mac_type >= e1000_82543) {
 		netdev->features = NETIF_F_SG |
 				   NETIF_F_HW_CSUM |
 				   NETIF_F_HW_VLAN_TX |
 				   NETIF_F_HW_VLAN_RX |
 				   NETIF_F_HW_VLAN_FILTER;
-		if (adapter->hw.mac_type == e1000_ich8lan)
+		if (hw->mac_type == e1000_ich8lan)
 			netdev->features &= ~NETIF_F_HW_VLAN_FILTER;
 	}
 
-	if ((adapter->hw.mac_type >= e1000_82544) &&
-	   (adapter->hw.mac_type != e1000_82547))
+	if ((hw->mac_type >= e1000_82544) &&
+	   (hw->mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
 
-	if (adapter->hw.mac_type > e1000_82547_rev_2)
+	if (hw->mac_type > e1000_82547_rev_2)
 		netdev->features |= NETIF_F_TSO6;
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
 	netdev->features |= NETIF_F_LLTX;
 
-	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
+	adapter->en_mng_pt = e1000_enable_mng_pass_thru(hw);
 
 	/* initialize eeprom parameters */
-	if (e1000_init_eeprom_params(&adapter->hw)) {
+	if (e1000_init_eeprom_params(hw)) {
 		E1000_ERR("EEPROM initialization failed\n");
 		goto err_eeprom;
 	}
@@ -1010,10 +1025,10 @@ e1000_probe(struct pci_dev *pdev,
 	/* before reading the EEPROM, reset the controller to
 	 * put the device in a known good starting state */
 
-	e1000_reset_hw(&adapter->hw);
+	e1000_reset_hw(hw);
 
 	/* make sure the EEPROM is good */
-	if (e1000_validate_eeprom_checksum(&adapter->hw) < 0) {
+	if (e1000_validate_eeprom_checksum(hw) < 0) {
 		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
 		e1000_dump_eeprom(adapter);
 		/*
@@ -1024,20 +1039,20 @@ e1000_probe(struct pci_dev *pdev,
 		 * interface after manually setting a hw addr using
 		 * `ip set address`
 		 */
-		memset(adapter->hw.mac_addr, 0, netdev->addr_len);
+		memset(hw->mac_addr, 0, netdev->addr_len);
 	} else {
 		/* copy the MAC address out of the EEPROM */
-		if (e1000_read_mac_addr(&adapter->hw))
+		if (e1000_read_mac_addr(hw))
 			DPRINTK(PROBE, ERR, "EEPROM Read Error\n");
 	}
 	/* don't block initalization here due to bad MAC address */
-	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
-	memcpy(netdev->perm_addr, adapter->hw.mac_addr, netdev->addr_len);
+	memcpy(netdev->dev_addr, hw->mac_addr, netdev->addr_len);
+	memcpy(netdev->perm_addr, hw->mac_addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->perm_addr))
 		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
 
-	e1000_get_bus_info(&adapter->hw);
+	e1000_get_bus_info(hw);
 
 	init_timer(&adapter->tx_fifo_stall_timer);
 	adapter->tx_fifo_stall_timer.function = &e1000_82547_tx_fifo_stall;
@@ -1060,18 +1075,18 @@ e1000_probe(struct pci_dev *pdev,
 	 * enable the ACPI Magic Packet filter
 	 */
 
-	switch (adapter->hw.mac_type) {
+	switch (hw->mac_type) {
 	case e1000_82542_rev2_0:
 	case e1000_82542_rev2_1:
 	case e1000_82543:
 		break;
 	case e1000_82544:
-		e1000_read_eeprom(&adapter->hw,
+		e1000_read_eeprom(hw,
 			EEPROM_INIT_CONTROL2_REG, 1, &eeprom_data);
 		eeprom_apme_mask = E1000_EEPROM_82544_APM;
 		break;
 	case e1000_ich8lan:
-		e1000_read_eeprom(&adapter->hw,
+		e1000_read_eeprom(hw,
 			EEPROM_INIT_CONTROL1_REG, 1, &eeprom_data);
 		eeprom_apme_mask = E1000_EEPROM_ICH8_APME;
 		break;
@@ -1079,14 +1094,14 @@ e1000_probe(struct pci_dev *pdev,
 	case e1000_82546_rev_3:
 	case e1000_82571:
 	case e1000_80003es2lan:
-		if (E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_FUNC_1){
-			e1000_read_eeprom(&adapter->hw,
+		if (er32(STATUS) & E1000_STATUS_FUNC_1){
+			e1000_read_eeprom(hw,
 				EEPROM_INIT_CONTROL3_PORT_B, 1, &eeprom_data);
 			break;
 		}
 		/* Fall Through */
 	default:
-		e1000_read_eeprom(&adapter->hw,
+		e1000_read_eeprom(hw,
 			EEPROM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
 		break;
 	}
@@ -1105,7 +1120,7 @@ e1000_probe(struct pci_dev *pdev,
 	case E1000_DEV_ID_82571EB_FIBER:
 		/* Wake events only supported on port A for dual fiber
 		 * regardless of eeprom setting */
-		if (E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_FUNC_1)
+		if (er32(STATUS) & E1000_STATUS_FUNC_1)
 			adapter->eeprom_wol = 0;
 		break;
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
@@ -1128,8 +1143,6 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->wol = adapter->eeprom_wol;
 
 	/* print bus type/speed/width info */
-	{
-	struct e1000_hw *hw = &adapter->hw;
 	DPRINTK(PROBE, INFO, "(PCI%s:%s:%s) ",
 		((hw->bus_type == e1000_bus_type_pcix) ? "-X" :
 		 (hw->bus_type == e1000_bus_type_pci_express ? " Express":"")),
@@ -1142,11 +1155,10 @@ e1000_probe(struct pci_dev *pdev,
 		 (hw->bus_width == e1000_bus_width_pciex_4) ? "Width x4" :
 		 (hw->bus_width == e1000_bus_width_pciex_1) ? "Width x1" :
 		 "32-bit"));
-	}
 
 	printk("%s\n", print_mac(mac, netdev->dev_addr));
 
-	if (adapter->hw.bus_type == e1000_bus_type_pci_express) {
+	if (hw->bus_type == e1000_bus_type_pci_express) {
 		DPRINTK(PROBE, WARNING, "This device (id %04x:%04x) will no "
 			"longer be supported by this driver in the future.\n",
 			pdev->vendor, pdev->device);
@@ -1161,8 +1173,8 @@ e1000_probe(struct pci_dev *pdev,
 	 * DRV_LOAD until the interface is up.  For all other cases,
 	 * let the f/w know that the h/w is now under the control
 	 * of the driver. */
-	if (adapter->hw.mac_type != e1000_82573 ||
-	    !e1000_check_mng_mode(&adapter->hw))
+	if (hw->mac_type != e1000_82573 ||
+	    !e1000_check_mng_mode(hw))
 		e1000_get_hw_control(adapter);
 
 	/* tell the stack to leave us alone until e1000_open() is called */
@@ -1181,11 +1193,11 @@ e1000_probe(struct pci_dev *pdev,
 err_register:
 	e1000_release_hw_control(adapter);
 err_eeprom:
-	if (!e1000_check_phy_reset_block(&adapter->hw))
-		e1000_phy_hw_reset(&adapter->hw);
+	if (!e1000_check_phy_reset_block(hw))
+		e1000_phy_hw_reset(hw);
 
-	if (adapter->hw.flash_address)
-		iounmap(adapter->hw.flash_address);
+	if (hw->flash_address)
+		iounmap(hw->flash_address);
 err_flashmap:
 #ifdef CONFIG_E1000_NAPI
 	for (i = 0; i < adapter->num_rx_queues; i++)
@@ -1198,7 +1210,7 @@ err_flashmap:
 	kfree(adapter->polling_netdev);
 #endif
 err_sw_init:
-	iounmap(adapter->hw.hw_addr);
+	iounmap(hw->hw_addr);
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
@@ -1223,6 +1235,7 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 #ifdef CONFIG_E1000_NAPI
 	int i;
 #endif
@@ -1242,8 +1255,8 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 
-	if (!e1000_check_phy_reset_block(&adapter->hw))
-		e1000_phy_hw_reset(&adapter->hw);
+	if (!e1000_check_phy_reset_block(hw))
+		e1000_phy_hw_reset(hw);
 
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
@@ -1251,9 +1264,9 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	kfree(adapter->polling_netdev);
 #endif
 
-	iounmap(adapter->hw.hw_addr);
-	if (adapter->hw.flash_address)
-		iounmap(adapter->hw.flash_address);
+	iounmap(hw->hw_addr);
+	if (hw->flash_address)
+		iounmap(hw->flash_address);
 	pci_release_regions(pdev);
 
 	free_netdev(netdev);
@@ -1407,6 +1420,7 @@ static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
 static int e1000_open(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	int err;
 
 	/* disallow open during test */
@@ -1426,15 +1440,15 @@ static int e1000_open(struct net_device *netdev)
 	e1000_power_up_phy(adapter);
 
 	adapter->mng_vlan_id = E1000_MNG_VLAN_NONE;
-	if ((adapter->hw.mng_cookie.status &
+	if ((hw->mng_cookie.status &
 			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT)) {
 		e1000_update_mng_vlan(adapter);
 	}
 
 	/* If AMT is enabled, let the firmware know that the network
 	 * interface is now open */
-	if (adapter->hw.mac_type == e1000_82573 &&
-	    e1000_check_mng_mode(&adapter->hw))
+	if (hw->mac_type == e1000_82573 &&
+	    e1000_check_mng_mode(hw))
 		e1000_get_hw_control(adapter);
 
 	/* before we allocate an interrupt, we must be ready to handle it.
@@ -1457,7 +1471,7 @@ static int e1000_open(struct net_device *netdev)
 	e1000_irq_enable(adapter);
 
 	/* fire a link status change interrupt to start the watchdog */
-	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_LSC);
+	ew32(ICS, E1000_ICS_LSC);
 
 	return E1000_SUCCESS;
 
@@ -1488,6 +1502,7 @@ err_setup_tx:
 static int e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 
 	WARN_ON(test_bit(__E1000_RESETTING, &adapter->flags));
 	e1000_down(adapter);
@@ -1499,7 +1514,7 @@ static int e1000_close(struct net_device *netdev)
 
 	/* kill manageability vlan ID if supported, but not if a vlan with
 	 * the same ID is registered on the host OS (let 8021q kill it) */
-	if ((adapter->hw.mng_cookie.status &
+	if ((hw->mng_cookie.status &
 			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
 	     !(adapter->vlgrp &&
 	       vlan_group_get_device(adapter->vlgrp, adapter->mng_vlan_id))) {
@@ -1508,8 +1523,8 @@ static int e1000_close(struct net_device *netdev)
 
 	/* If AMT is enabled, let the firmware know that the network
 	 * interface is now closed */
-	if (adapter->hw.mac_type == e1000_82573 &&
-	    e1000_check_mng_mode(&adapter->hw))
+	if (hw->mac_type == e1000_82573 &&
+	    e1000_check_mng_mode(hw))
 		e1000_release_hw_control(adapter);
 
 	return 0;
@@ -1524,13 +1539,14 @@ static int e1000_close(struct net_device *netdev)
 static bool e1000_check_64k_bound(struct e1000_adapter *adapter, void *start,
 				  unsigned long len)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	unsigned long begin = (unsigned long) start;
 	unsigned long end = begin + len;
 
 	/* First rev 82545 and 82546 need to not allow any memory
 	 * write location to cross 64k boundary due to errata 23 */
-	if (adapter->hw.mac_type == e1000_82545 ||
-	    adapter->hw.mac_type == e1000_82546) {
+	if (hw->mac_type == e1000_82545 ||
+	    hw->mac_type == e1000_82546) {
 		return ((begin ^ (end - 1)) >> 16) != 0 ? false : true;
 	}
 
@@ -1661,18 +1677,18 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 		tdba = adapter->tx_ring[0].dma;
 		tdlen = adapter->tx_ring[0].count *
 			sizeof(struct e1000_tx_desc);
-		E1000_WRITE_REG(hw, TDLEN, tdlen);
-		E1000_WRITE_REG(hw, TDBAH, (tdba >> 32));
-		E1000_WRITE_REG(hw, TDBAL, (tdba & 0x00000000ffffffffULL));
-		E1000_WRITE_REG(hw, TDT, 0);
-		E1000_WRITE_REG(hw, TDH, 0);
+		ew32(TDLEN, tdlen);
+		ew32(TDBAH, (tdba >> 32));
+		ew32(TDBAL, (tdba & 0x00000000ffffffffULL));
+		ew32(TDT, 0);
+		ew32(TDH, 0);
 		adapter->tx_ring[0].tdh = ((hw->mac_type >= e1000_82543) ? E1000_TDH : E1000_82542_TDH);
 		adapter->tx_ring[0].tdt = ((hw->mac_type >= e1000_82543) ? E1000_TDT : E1000_82542_TDT);
 		break;
 	}
 
 	/* Set the default values for the Tx Inter Packet Gap timer */
-	if (adapter->hw.mac_type <= e1000_82547_rev_2 &&
+	if (hw->mac_type <= e1000_82547_rev_2 &&
 	    (hw->media_type == e1000_media_type_fiber ||
 	     hw->media_type == e1000_media_type_internal_serdes))
 		tipg = DEFAULT_82543_TIPG_IPGT_FIBER;
@@ -1697,34 +1713,34 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	}
 	tipg |= ipgr1 << E1000_TIPG_IPGR1_SHIFT;
 	tipg |= ipgr2 << E1000_TIPG_IPGR2_SHIFT;
-	E1000_WRITE_REG(hw, TIPG, tipg);
+	ew32(TIPG, tipg);
 
 	/* Set the Tx Interrupt Delay register */
 
-	E1000_WRITE_REG(hw, TIDV, adapter->tx_int_delay);
+	ew32(TIDV, adapter->tx_int_delay);
 	if (hw->mac_type >= e1000_82540)
-		E1000_WRITE_REG(hw, TADV, adapter->tx_abs_int_delay);
+		ew32(TADV, adapter->tx_abs_int_delay);
 
 	/* Program the Transmit Control Register */
 
-	tctl = E1000_READ_REG(hw, TCTL);
+	tctl = er32(TCTL);
 	tctl &= ~E1000_TCTL_CT;
 	tctl |= E1000_TCTL_PSP | E1000_TCTL_RTLC |
 		(E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT);
 
 	if (hw->mac_type == e1000_82571 || hw->mac_type == e1000_82572) {
-		tarc = E1000_READ_REG(hw, TARC0);
+		tarc = er32(TARC0);
 		/* set the speed mode bit, we'll clear it if we're not at
 		 * gigabit link later */
 		tarc |= (1 << 21);
-		E1000_WRITE_REG(hw, TARC0, tarc);
+		ew32(TARC0, tarc);
 	} else if (hw->mac_type == e1000_80003es2lan) {
-		tarc = E1000_READ_REG(hw, TARC0);
+		tarc = er32(TARC0);
 		tarc |= 1;
-		E1000_WRITE_REG(hw, TARC0, tarc);
-		tarc = E1000_READ_REG(hw, TARC1);
+		ew32(TARC0, tarc);
+		tarc = er32(TARC1);
 		tarc |= 1;
-		E1000_WRITE_REG(hw, TARC1, tarc);
+		ew32(TARC1, tarc);
 	}
 
 	e1000_config_collision_dist(hw);
@@ -1747,7 +1763,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	    hw->bus_type == e1000_bus_type_pcix)
 		adapter->pcix_82544 = 1;
 
-	E1000_WRITE_REG(hw, TCTL, tctl);
+	ew32(TCTL, tctl);
 
 }
 
@@ -1762,6 +1778,7 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 				    struct e1000_rx_ring *rxdr)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	int size, desc_len;
 
@@ -1794,7 +1811,7 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 		return -ENOMEM;
 	}
 
-	if (adapter->hw.mac_type <= e1000_82547_rev_2)
+	if (hw->mac_type <= e1000_82547_rev_2)
 		desc_len = sizeof(struct e1000_rx_desc);
 	else
 		desc_len = sizeof(union e1000_rx_desc_packet_split);
@@ -1890,21 +1907,22 @@ int e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
 			(((S) & (PAGE_SIZE - 1)) ? 1 : 0))
 static void e1000_setup_rctl(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl, rfctl;
 	u32 psrctl = 0;
 #ifndef CONFIG_E1000_DISABLE_PACKET_SPLIT
 	u32 pages = 0;
 #endif
 
-	rctl = E1000_READ_REG(&adapter->hw, RCTL);
+	rctl = er32(RCTL);
 
 	rctl &= ~(3 << E1000_RCTL_MO_SHIFT);
 
 	rctl |= E1000_RCTL_EN | E1000_RCTL_BAM |
 		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
-		(adapter->hw.mc_filter_type << E1000_RCTL_MO_SHIFT);
+		(hw->mc_filter_type << E1000_RCTL_MO_SHIFT);
 
-	if (adapter->hw.tbi_compatibility_on == 1)
+	if (hw->tbi_compatibility_on == 1)
 		rctl |= E1000_RCTL_SBP;
 	else
 		rctl &= ~E1000_RCTL_SBP;
@@ -1957,7 +1975,7 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	/* allocations using alloc_page take too long for regular MTU
 	 * so only enable packet split for jumbo frames */
 	pages = PAGE_USE_COUNT(adapter->netdev->mtu);
-	if ((adapter->hw.mac_type >= e1000_82571) && (pages <= 3) &&
+	if ((hw->mac_type >= e1000_82571) && (pages <= 3) &&
 	    PAGE_SIZE <= 16384 && (rctl & E1000_RCTL_LPE))
 		adapter->rx_ps_pages = pages;
 	else
@@ -1965,14 +1983,14 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 #endif
 	if (adapter->rx_ps_pages) {
 		/* Configure extra packet-split registers */
-		rfctl = E1000_READ_REG(&adapter->hw, RFCTL);
+		rfctl = er32(RFCTL);
 		rfctl |= E1000_RFCTL_EXTEN;
 		/* disable packet split support for IPv6 extension headers,
 		 * because some malformed IPv6 headers can hang the RX */
 		rfctl |= (E1000_RFCTL_IPV6_EX_DIS |
 		          E1000_RFCTL_NEW_IPV6_EXT_DIS);
 
-		E1000_WRITE_REG(&adapter->hw, RFCTL, rfctl);
+		ew32(RFCTL, rfctl);
 
 		rctl |= E1000_RCTL_DTYP_PS;
 
@@ -1992,10 +2010,10 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 			break;
 		}
 
-		E1000_WRITE_REG(&adapter->hw, PSRCTL, psrctl);
+		ew32(PSRCTL, psrctl);
 	}
 
-	E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+	ew32(RCTL, rctl);
 }
 
 /**
@@ -2025,30 +2043,29 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	}
 
 	/* disable receives while setting up the descriptors */
-	rctl = E1000_READ_REG(hw, RCTL);
-	E1000_WRITE_REG(hw, RCTL, rctl & ~E1000_RCTL_EN);
+	rctl = er32(RCTL);
+	ew32(RCTL, rctl & ~E1000_RCTL_EN);
 
 	/* set the Receive Delay Timer Register */
-	E1000_WRITE_REG(hw, RDTR, adapter->rx_int_delay);
+	ew32(RDTR, adapter->rx_int_delay);
 
 	if (hw->mac_type >= e1000_82540) {
-		E1000_WRITE_REG(hw, RADV, adapter->rx_abs_int_delay);
+		ew32(RADV, adapter->rx_abs_int_delay);
 		if (adapter->itr_setting != 0)
-			E1000_WRITE_REG(hw, ITR,
-				1000000000 / (adapter->itr * 256));
+			ew32(ITR, 1000000000 / (adapter->itr * 256));
 	}
 
 	if (hw->mac_type >= e1000_82571) {
-		ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+		ctrl_ext = er32(CTRL_EXT);
 		/* Reset delay timers after every interrupt */
 		ctrl_ext |= E1000_CTRL_EXT_INT_TIMER_CLR;
 #ifdef CONFIG_E1000_NAPI
 		/* Auto-Mask interrupts upon ICR access */
 		ctrl_ext |= E1000_CTRL_EXT_IAME;
-		E1000_WRITE_REG(hw, IAM, 0xffffffff);
+		ew32(IAM, 0xffffffff);
 #endif
-		E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
-		E1000_WRITE_FLUSH(hw);
+		ew32(CTRL_EXT, ctrl_ext);
+		E1000_WRITE_FLUSH();
 	}
 
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
@@ -2057,11 +2074,11 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	case 1:
 	default:
 		rdba = adapter->rx_ring[0].dma;
-		E1000_WRITE_REG(hw, RDLEN, rdlen);
-		E1000_WRITE_REG(hw, RDBAH, (rdba >> 32));
-		E1000_WRITE_REG(hw, RDBAL, (rdba & 0x00000000ffffffffULL));
-		E1000_WRITE_REG(hw, RDT, 0);
-		E1000_WRITE_REG(hw, RDH, 0);
+		ew32(RDLEN, rdlen);
+		ew32(RDBAH, (rdba >> 32));
+		ew32(RDBAL, (rdba & 0x00000000ffffffffULL));
+		ew32(RDT, 0);
+		ew32(RDH, 0);
 		adapter->rx_ring[0].rdh = ((hw->mac_type >= e1000_82543) ? E1000_RDH : E1000_82542_RDH);
 		adapter->rx_ring[0].rdt = ((hw->mac_type >= e1000_82543) ? E1000_RDT : E1000_82542_RDT);
 		break;
@@ -2069,7 +2086,7 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 
 	/* Enable 82543 Receive Checksum Offload for TCP and UDP */
 	if (hw->mac_type >= e1000_82543) {
-		rxcsum = E1000_READ_REG(hw, RXCSUM);
+		rxcsum = er32(RXCSUM);
 		if (adapter->rx_csum) {
 			rxcsum |= E1000_RXCSUM_TUOFL;
 
@@ -2083,17 +2100,17 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 			rxcsum &= ~E1000_RXCSUM_TUOFL;
 			/* don't need to clear IPPCSE as it defaults to 0 */
 		}
-		E1000_WRITE_REG(hw, RXCSUM, rxcsum);
+		ew32(RXCSUM, rxcsum);
 	}
 
 	/* enable early receives on 82573, only takes effect if using > 2048
 	 * byte total frame size.  for example only for jumbo frames */
 #define E1000_ERT_2048 0x100
 	if (hw->mac_type == e1000_82573)
-		E1000_WRITE_REG(hw, ERT, E1000_ERT_2048);
+		ew32(ERT, E1000_ERT_2048);
 
 	/* Enable Receives */
-	E1000_WRITE_REG(hw, RCTL, rctl);
+	ew32(RCTL, rctl);
 }
 
 /**
@@ -2160,6 +2177,7 @@ static void e1000_unmap_and_free_tx_resource(struct e1000_adapter *adapter,
 static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
 				struct e1000_tx_ring *tx_ring)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_buffer *buffer_info;
 	unsigned long size;
 	unsigned int i;
@@ -2182,8 +2200,8 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
 	tx_ring->next_to_clean = 0;
 	tx_ring->last_tx_tso = 0;
 
-	writel(0, adapter->hw.hw_addr + tx_ring->tdh);
-	writel(0, adapter->hw.hw_addr + tx_ring->tdt);
+	writel(0, hw->hw_addr + tx_ring->tdh);
+	writel(0, hw->hw_addr + tx_ring->tdt);
 }
 
 /**
@@ -2250,6 +2268,7 @@ void e1000_free_all_rx_resources(struct e1000_adapter *adapter)
 static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 				struct e1000_rx_ring *rx_ring)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_buffer *buffer_info;
 	struct e1000_ps_page *ps_page;
 	struct e1000_ps_page_dma *ps_page_dma;
@@ -2296,8 +2315,8 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 
-	writel(0, adapter->hw.hw_addr + rx_ring->rdh);
-	writel(0, adapter->hw.hw_addr + rx_ring->rdt);
+	writel(0, hw->hw_addr + rx_ring->rdh);
+	writel(0, hw->hw_addr + rx_ring->rdt);
 }
 
 /**
@@ -2318,15 +2337,16 @@ static void e1000_clean_all_rx_rings(struct e1000_adapter *adapter)
  */
 static void e1000_enter_82542_rst(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	u32 rctl;
 
-	e1000_pci_clear_mwi(&adapter->hw);
+	e1000_pci_clear_mwi(hw);
 
-	rctl = E1000_READ_REG(&adapter->hw, RCTL);
+	rctl = er32(RCTL);
 	rctl |= E1000_RCTL_RST;
-	E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
-	E1000_WRITE_FLUSH(&adapter->hw);
+	ew32(RCTL, rctl);
+	E1000_WRITE_FLUSH();
 	mdelay(5);
 
 	if (netif_running(netdev))
@@ -2335,17 +2355,18 @@ static void e1000_enter_82542_rst(struct e1000_adapter *adapter)
 
 static void e1000_leave_82542_rst(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	u32 rctl;
 
-	rctl = E1000_READ_REG(&adapter->hw, RCTL);
+	rctl = er32(RCTL);
 	rctl &= ~E1000_RCTL_RST;
-	E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
-	E1000_WRITE_FLUSH(&adapter->hw);
+	ew32(RCTL, rctl);
+	E1000_WRITE_FLUSH();
 	mdelay(5);
 
-	if (adapter->hw.pci_cmd_word & PCI_COMMAND_INVALIDATE)
-		e1000_pci_set_mwi(&adapter->hw);
+	if (hw->pci_cmd_word & PCI_COMMAND_INVALIDATE)
+		e1000_pci_set_mwi(hw);
 
 	if (netif_running(netdev)) {
 		/* No need to loop, because 82542 supports only 1 queue */
@@ -2366,6 +2387,7 @@ static void e1000_leave_82542_rst(struct e1000_adapter *adapter)
 static int e1000_set_mac(struct net_device *netdev, void *p)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
@@ -2373,19 +2395,19 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
 
 	/* 82542 2.0 needs to be in reset to write receive address registers */
 
-	if (adapter->hw.mac_type == e1000_82542_rev2_0)
+	if (hw->mac_type == e1000_82542_rev2_0)
 		e1000_enter_82542_rst(adapter);
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
+	memcpy(hw->mac_addr, addr->sa_data, netdev->addr_len);
 
-	e1000_rar_set(&adapter->hw, adapter->hw.mac_addr, 0);
+	e1000_rar_set(hw, hw->mac_addr, 0);
 
 	/* With 82571 controllers, LAA may be overwritten (with the default)
 	 * due to controller reset from the other port. */
-	if (adapter->hw.mac_type == e1000_82571) {
+	if (hw->mac_type == e1000_82571) {
 		/* activate the work around */
-		adapter->hw.laa_is_present = 1;
+		hw->laa_is_present = 1;
 
 		/* Hold a copy of the LAA in RAR[14] This is done so that
 		 * between the time RAR[0] gets clobbered  and the time it
@@ -2393,11 +2415,11 @@ static int e1000_set_mac(struct net_device *netdev, void *p)
 		 * of the RARs and no incoming packets directed to this port
 		 * are dropped. Eventaully the LAA will be in RAR[0] and
 		 * RAR[14] */
-		e1000_rar_set(&adapter->hw, adapter->hw.mac_addr,
+		e1000_rar_set(hw, hw->mac_addr,
 					E1000_RAR_ENTRIES - 1);
 	}
 
-	if (adapter->hw.mac_type == e1000_82542_rev2_0)
+	if (hw->mac_type == e1000_82542_rev2_0)
 		e1000_leave_82542_rst(adapter);
 
 	return 0;
@@ -2426,16 +2448,16 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 				E1000_NUM_MTA_REGISTERS_ICH8LAN :
 				E1000_NUM_MTA_REGISTERS;
 
-	if (adapter->hw.mac_type == e1000_ich8lan)
+	if (hw->mac_type == e1000_ich8lan)
 		rar_entries = E1000_RAR_ENTRIES_ICH8LAN;
 
 	/* reserve RAR[14] for LAA over-write work-around */
-	if (adapter->hw.mac_type == e1000_82571)
+	if (hw->mac_type == e1000_82571)
 		rar_entries--;
 
 	/* Check for Promiscuous and All Multicast modes */
 
-	rctl = E1000_READ_REG(hw, RCTL);
+	rctl = er32(RCTL);
 
 	if (netdev->flags & IFF_PROMISC) {
 		rctl |= (E1000_RCTL_UPE | E1000_RCTL_MPE);
@@ -2453,7 +2475,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 		uc_ptr = netdev->uc_list;
 	}
 
-	E1000_WRITE_REG(hw, RCTL, rctl);
+	ew32(RCTL, rctl);
 
 	/* 82542 2.0 needs to be in reset to write receive address registers */
 
@@ -2479,9 +2501,9 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 			mc_ptr = mc_ptr->next;
 		} else {
 			E1000_WRITE_REG_ARRAY(hw, RA, i << 1, 0);
-			E1000_WRITE_FLUSH(hw);
+			E1000_WRITE_FLUSH();
 			E1000_WRITE_REG_ARRAY(hw, RA, (i << 1) + 1, 0);
-			E1000_WRITE_FLUSH(hw);
+			E1000_WRITE_FLUSH();
 		}
 	}
 	WARN_ON(uc_ptr != NULL);
@@ -2490,7 +2512,7 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 
 	for (i = 0; i < mta_reg_count; i++) {
 		E1000_WRITE_REG_ARRAY(hw, MTA, i, 0);
-		E1000_WRITE_FLUSH(hw);
+		E1000_WRITE_FLUSH();
 	}
 
 	/* load any remaining addresses into the hash table */
@@ -2510,7 +2532,8 @@ static void e1000_set_rx_mode(struct net_device *netdev)
 static void e1000_update_phy_info(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
-	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
+	struct e1000_hw *hw = &adapter->hw;
+	e1000_phy_get_info(hw, &adapter->phy_info);
 }
 
 /**
@@ -2521,29 +2544,22 @@ static void e1000_update_phy_info(unsigned long data)
 static void e1000_82547_tx_fifo_stall(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	u32 tctl;
 
 	if (atomic_read(&adapter->tx_fifo_stall)) {
-		if ((E1000_READ_REG(&adapter->hw, TDT) ==
-		    E1000_READ_REG(&adapter->hw, TDH)) &&
-		   (E1000_READ_REG(&adapter->hw, TDFT) ==
-		    E1000_READ_REG(&adapter->hw, TDFH)) &&
-		   (E1000_READ_REG(&adapter->hw, TDFTS) ==
-		    E1000_READ_REG(&adapter->hw, TDFHS))) {
-			tctl = E1000_READ_REG(&adapter->hw, TCTL);
-			E1000_WRITE_REG(&adapter->hw, TCTL,
-					tctl & ~E1000_TCTL_EN);
-			E1000_WRITE_REG(&adapter->hw, TDFT,
-					adapter->tx_head_addr);
-			E1000_WRITE_REG(&adapter->hw, TDFH,
-					adapter->tx_head_addr);
-			E1000_WRITE_REG(&adapter->hw, TDFTS,
-					adapter->tx_head_addr);
-			E1000_WRITE_REG(&adapter->hw, TDFHS,
-					adapter->tx_head_addr);
-			E1000_WRITE_REG(&adapter->hw, TCTL, tctl);
-			E1000_WRITE_FLUSH(&adapter->hw);
+		if ((er32(TDT) == er32(TDH)) &&
+		   (er32(TDFT) == er32(TDFH)) &&
+		   (er32(TDFTS) == er32(TDFHS))) {
+			tctl = er32(TCTL);
+			ew32(TCTL, tctl & ~E1000_TCTL_EN);
+			ew32(TDFT, adapter->tx_head_addr);
+			ew32(TDFH, adapter->tx_head_addr);
+			ew32(TDFTS, adapter->tx_head_addr);
+			ew32(TDFHS, adapter->tx_head_addr);
+			ew32(TCTL, tctl);
+			E1000_WRITE_FLUSH();
 
 			adapter->tx_fifo_head = 0;
 			atomic_set(&adapter->tx_fifo_stall, 0);
@@ -2561,41 +2577,42 @@ static void e1000_82547_tx_fifo_stall(unsigned long data)
 static void e1000_watchdog(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
+	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	u32 link, tctl;
 	s32 ret_val;
 
-	ret_val = e1000_check_for_link(&adapter->hw);
+	ret_val = e1000_check_for_link(hw);
 	if ((ret_val == E1000_ERR_PHY) &&
-	    (adapter->hw.phy_type == e1000_phy_igp_3) &&
-	    (E1000_READ_REG(&adapter->hw, CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {
+	    (hw->phy_type == e1000_phy_igp_3) &&
+	    (er32(CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {
 		/* See e1000_kumeran_lock_loss_workaround() */
 		DPRINTK(LINK, INFO,
 			"Gigabit has been disabled, downgrading speed\n");
 	}
 
-	if (adapter->hw.mac_type == e1000_82573) {
-		e1000_enable_tx_pkt_filtering(&adapter->hw);
-		if (adapter->mng_vlan_id != adapter->hw.mng_cookie.vlan_id)
+	if (hw->mac_type == e1000_82573) {
+		e1000_enable_tx_pkt_filtering(hw);
+		if (adapter->mng_vlan_id != hw->mng_cookie.vlan_id)
 			e1000_update_mng_vlan(adapter);
 	}
 
-	if ((adapter->hw.media_type == e1000_media_type_internal_serdes) &&
-	   !(E1000_READ_REG(&adapter->hw, TXCW) & E1000_TXCW_ANE))
-		link = !adapter->hw.serdes_link_down;
+	if ((hw->media_type == e1000_media_type_internal_serdes) &&
+	   !(er32(TXCW) & E1000_TXCW_ANE))
+		link = !hw->serdes_link_down;
 	else
-		link = E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_LU;
+		link = er32(STATUS) & E1000_STATUS_LU;
 
 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
 			u32 ctrl;
 			bool txb2b = true;
-			e1000_get_speed_and_duplex(&adapter->hw,
+			e1000_get_speed_and_duplex(hw,
 			                           &adapter->link_speed,
 			                           &adapter->link_duplex);
 
-			ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+			ctrl = er32(CTRL);
 			DPRINTK(LINK, INFO, "NIC Link is Up %d Mbps %s, "
 			        "Flow Control: %s\n",
 			        adapter->link_speed,
@@ -2623,19 +2640,19 @@ static void e1000_watchdog(unsigned long data)
 				break;
 			}
 
-			if ((adapter->hw.mac_type == e1000_82571 ||
-			     adapter->hw.mac_type == e1000_82572) &&
+			if ((hw->mac_type == e1000_82571 ||
+			     hw->mac_type == e1000_82572) &&
 			    !txb2b) {
 				u32 tarc0;
-				tarc0 = E1000_READ_REG(&adapter->hw, TARC0);
+				tarc0 = er32(TARC0);
 				tarc0 &= ~(1 << 21);
-				E1000_WRITE_REG(&adapter->hw, TARC0, tarc0);
+				ew32(TARC0, tarc0);
 			}
 
 			/* disable TSO for pcie and 10/100 speeds, to avoid
 			 * some hardware issues */
 			if (!adapter->tso_force &&
-			    adapter->hw.bus_type == e1000_bus_type_pci_express){
+			    hw->bus_type == e1000_bus_type_pci_express){
 				switch (adapter->link_speed) {
 				case SPEED_10:
 				case SPEED_100:
@@ -2656,9 +2673,9 @@ static void e1000_watchdog(unsigned long data)
 
 			/* enable transmits in the hardware, need to do this
 			 * after setting TARC0 */
-			tctl = E1000_READ_REG(&adapter->hw, TCTL);
+			tctl = er32(TCTL);
 			tctl |= E1000_TCTL_EN;
-			E1000_WRITE_REG(&adapter->hw, TCTL, tctl);
+			ew32(TCTL, tctl);
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
@@ -2666,10 +2683,9 @@ static void e1000_watchdog(unsigned long data)
 			adapter->smartspeed = 0;
 		} else {
 			/* make sure the receive unit is started */
-			if (adapter->hw.rx_needs_kicking) {
-				struct e1000_hw *hw = &adapter->hw;
-				u32 rctl = E1000_READ_REG(hw, RCTL);
-				E1000_WRITE_REG(hw, RCTL, rctl | E1000_RCTL_EN);
+			if (hw->rx_needs_kicking) {
+				u32 rctl = er32(RCTL);
+				ew32(RCTL, rctl | E1000_RCTL_EN);
 			}
 		}
 	} else {
@@ -2686,7 +2702,7 @@ static void e1000_watchdog(unsigned long data)
 			 * disable receives in the ISR and
 			 * reset device here in the watchdog
 			 */
-			if (adapter->hw.mac_type == e1000_80003es2lan)
+			if (hw->mac_type == e1000_80003es2lan)
 				/* reset device */
 				schedule_work(&adapter->reset_task);
 		}
@@ -2696,9 +2712,9 @@ static void e1000_watchdog(unsigned long data)
 
 	e1000_update_stats(adapter);
 
-	adapter->hw.tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
+	hw->tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
 	adapter->tpt_old = adapter->stats.tpt;
-	adapter->hw.collision_delta = adapter->stats.colc - adapter->colc_old;
+	hw->collision_delta = adapter->stats.colc - adapter->colc_old;
 	adapter->colc_old = adapter->stats.colc;
 
 	adapter->gorcl = adapter->stats.gorcl - adapter->gorcl_old;
@@ -2706,7 +2722,7 @@ static void e1000_watchdog(unsigned long data)
 	adapter->gotcl = adapter->stats.gotcl - adapter->gotcl_old;
 	adapter->gotcl_old = adapter->stats.gotcl;
 
-	e1000_update_adaptive(&adapter->hw);
+	e1000_update_adaptive(hw);
 
 	if (!netif_carrier_ok(netdev)) {
 		if (E1000_DESC_UNUSED(txdr) + 1 < txdr->count) {
@@ -2720,15 +2736,15 @@ static void e1000_watchdog(unsigned long data)
 	}
 
 	/* Cause software interrupt to ensure rx ring is cleaned */
-	E1000_WRITE_REG(&adapter->hw, ICS, E1000_ICS_RXDMT0);
+	ew32(ICS, E1000_ICS_RXDMT0);
 
 	/* Force detection of hung controller every watchdog period */
 	adapter->detect_tx_hung = true;
 
 	/* With 82571 controllers, LAA may be overwritten due to controller
 	 * reset from the other port. Set the appropriate LAA in RAR[0] */
-	if (adapter->hw.mac_type == e1000_82571 && adapter->hw.laa_is_present)
-		e1000_rar_set(&adapter->hw, adapter->hw.mac_addr, 0);
+	if (hw->mac_type == e1000_82571 && hw->laa_is_present)
+		e1000_rar_set(hw, hw->mac_addr, 0);
 
 	/* Reset the timer */
 	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
@@ -2863,7 +2879,7 @@ set_itr_now:
 		             min(adapter->itr + (new_itr >> 2), new_itr) :
 		             new_itr;
 		adapter->itr = new_itr;
-		E1000_WRITE_REG(hw, ITR, 1000000000 / (new_itr * 256));
+		ew32(ITR, 1000000000 / (new_itr * 256));
 	}
 
 	return;
@@ -2992,6 +3008,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			unsigned int max_per_txd, unsigned int nr_frags,
 			unsigned int mss)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_buffer *buffer_info;
 	unsigned int len = skb->len;
 	unsigned int offset = 0, size, count = 0, i;
@@ -3022,7 +3039,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 		 * The fix is to make sure that the first descriptor of a
 		 * packet is smaller than 2048 - 16 - 16 (or 2016) bytes
 		 */
-		if (unlikely((adapter->hw.bus_type == e1000_bus_type_pcix) &&
+		if (unlikely((hw->bus_type == e1000_bus_type_pcix) &&
 		                (size > 2015) && count == 0))
 		        size = 2015;
 
@@ -3098,6 +3115,7 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 			   struct e1000_tx_ring *tx_ring, int tx_flags,
 			   int count)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_tx_desc *tx_desc = NULL;
 	struct e1000_buffer *buffer_info;
 	u32 txd_upper = 0, txd_lower = E1000_TXD_CMD_IFCS;
@@ -3143,7 +3161,7 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 	wmb();
 
 	tx_ring->next_to_use = i;
-	writel(i, adapter->hw.hw_addr + tx_ring->tdt);
+	writel(i, hw->hw_addr + tx_ring->tdt);
 	/* we need this if more than one processor can write to our tail
 	 * at a time, it syncronizes IO on IA64/Altix systems */
 	mmiowb();
@@ -3194,8 +3212,8 @@ static int e1000_transfer_dhcp_info(struct e1000_adapter *adapter,
 	struct e1000_hw *hw =  &adapter->hw;
 	u16 length, offset;
 	if (vlan_tx_tag_present(skb)) {
-		if (!((vlan_tx_tag_get(skb) == adapter->hw.mng_cookie.vlan_id) &&
-			( adapter->hw.mng_cookie.status &
+		if (!((vlan_tx_tag_get(skb) == hw->mng_cookie.vlan_id) &&
+			( hw->mng_cookie.status &
 			  E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT)) )
 			return 0;
 	}
@@ -3256,6 +3274,7 @@ static int e1000_maybe_stop_tx(struct net_device *netdev,
 static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_tx_ring *tx_ring;
 	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
@@ -3281,7 +3300,7 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	/* 82571 and newer doesn't need the workaround that limited descriptor
 	 * length to 4kB */
-	if (adapter->hw.mac_type >= e1000_82571)
+	if (hw->mac_type >= e1000_82571)
 		max_per_txd = 8192;
 
 	mss = skb_shinfo(skb)->gso_size;
@@ -3301,7 +3320,7 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		* frags into skb->data */
 		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		if (skb->data_len && hdr_len == len) {
-			switch (adapter->hw.mac_type) {
+			switch (hw->mac_type) {
 				unsigned int pull_size;
 			case e1000_82544:
 				/* Make sure we have room to chop off 4 bytes,
@@ -3350,7 +3369,7 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	/* work-around for errata 10 and it applies to all controllers
 	 * in PCI-X mode, so add one more descriptor to the count
 	 */
-	if (unlikely((adapter->hw.bus_type == e1000_bus_type_pcix) &&
+	if (unlikely((hw->bus_type == e1000_bus_type_pcix) &&
 			(len > 2015)))
 		count++;
 
@@ -3362,8 +3381,8 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		count += nr_frags;
 
 
-	if (adapter->hw.tx_pkt_filtering &&
-	    (adapter->hw.mac_type == e1000_82573))
+	if (hw->tx_pkt_filtering &&
+	    (hw->mac_type == e1000_82573))
 		e1000_transfer_dhcp_info(adapter, skb);
 
 	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
@@ -3377,7 +3396,7 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_BUSY;
 	}
 
-	if (unlikely(adapter->hw.mac_type == e1000_82547)) {
+	if (unlikely(hw->mac_type == e1000_82547)) {
 		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
@@ -3474,6 +3493,7 @@ static struct net_device_stats *e1000_get_stats(struct net_device *netdev)
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
 	u16 eeprom_data = 0;
 
@@ -3484,7 +3504,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	}
 
 	/* Adapter-specific max frame size limits. */
-	switch (adapter->hw.mac_type) {
+	switch (hw->mac_type) {
 	case e1000_undefined ... e1000_82542_rev2_1:
 	case e1000_ich8lan:
 		if (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
@@ -3496,9 +3516,9 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		/* Jumbo Frames not supported if:
 		 * - this is not an 82573L device
 		 * - ASPM is enabled in any way (0x1A bits 3:2) */
-		e1000_read_eeprom(&adapter->hw, EEPROM_INIT_3GIO_3, 1,
+		e1000_read_eeprom(hw, EEPROM_INIT_3GIO_3, 1,
 		                  &eeprom_data);
-		if ((adapter->hw.device_id != E1000_DEV_ID_82573L) ||
+		if ((hw->device_id != E1000_DEV_ID_82573L) ||
 		    (eeprom_data & EEPROM_WORD1A_ASPM_MASK)) {
 			if (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
 				DPRINTK(PROBE, ERR,
@@ -3545,13 +3565,13 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		adapter->rx_buffer_len = E1000_RXBUFFER_16384;
 
 	/* adjust allocation if LPE protects us, and we aren't using SBP */
-	if (!adapter->hw.tbi_compatibility_on &&
+	if (!hw->tbi_compatibility_on &&
 	    ((max_frame == MAXIMUM_ETHERNET_FRAME_SIZE) ||
 	     (max_frame == MAXIMUM_ETHERNET_VLAN_SIZE)))
 		adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 
 	netdev->mtu = new_mtu;
-	adapter->hw.max_frame_size = max_frame;
+	hw->max_frame_size = max_frame;
 
 	if (netif_running(netdev))
 		e1000_reinit_locked(adapter);
@@ -3589,89 +3609,89 @@ void e1000_update_stats(struct e1000_adapter *adapter)
 	 * be written while holding adapter->stats_lock
 	 */
 
-	adapter->stats.crcerrs += E1000_READ_REG(hw, CRCERRS);
-	adapter->stats.gprc += E1000_READ_REG(hw, GPRC);
-	adapter->stats.gorcl += E1000_READ_REG(hw, GORCL);
-	adapter->stats.gorch += E1000_READ_REG(hw, GORCH);
-	adapter->stats.bprc += E1000_READ_REG(hw, BPRC);
-	adapter->stats.mprc += E1000_READ_REG(hw, MPRC);
-	adapter->stats.roc += E1000_READ_REG(hw, ROC);
-
-	if (adapter->hw.mac_type != e1000_ich8lan) {
-		adapter->stats.prc64 += E1000_READ_REG(hw, PRC64);
-		adapter->stats.prc127 += E1000_READ_REG(hw, PRC127);
-		adapter->stats.prc255 += E1000_READ_REG(hw, PRC255);
-		adapter->stats.prc511 += E1000_READ_REG(hw, PRC511);
-		adapter->stats.prc1023 += E1000_READ_REG(hw, PRC1023);
-		adapter->stats.prc1522 += E1000_READ_REG(hw, PRC1522);
-	}
-
-	adapter->stats.symerrs += E1000_READ_REG(hw, SYMERRS);
-	adapter->stats.mpc += E1000_READ_REG(hw, MPC);
-	adapter->stats.scc += E1000_READ_REG(hw, SCC);
-	adapter->stats.ecol += E1000_READ_REG(hw, ECOL);
-	adapter->stats.mcc += E1000_READ_REG(hw, MCC);
-	adapter->stats.latecol += E1000_READ_REG(hw, LATECOL);
-	adapter->stats.dc += E1000_READ_REG(hw, DC);
-	adapter->stats.sec += E1000_READ_REG(hw, SEC);
-	adapter->stats.rlec += E1000_READ_REG(hw, RLEC);
-	adapter->stats.xonrxc += E1000_READ_REG(hw, XONRXC);
-	adapter->stats.xontxc += E1000_READ_REG(hw, XONTXC);
-	adapter->stats.xoffrxc += E1000_READ_REG(hw, XOFFRXC);
-	adapter->stats.xofftxc += E1000_READ_REG(hw, XOFFTXC);
-	adapter->stats.fcruc += E1000_READ_REG(hw, FCRUC);
-	adapter->stats.gptc += E1000_READ_REG(hw, GPTC);
-	adapter->stats.gotcl += E1000_READ_REG(hw, GOTCL);
-	adapter->stats.gotch += E1000_READ_REG(hw, GOTCH);
-	adapter->stats.rnbc += E1000_READ_REG(hw, RNBC);
-	adapter->stats.ruc += E1000_READ_REG(hw, RUC);
-	adapter->stats.rfc += E1000_READ_REG(hw, RFC);
-	adapter->stats.rjc += E1000_READ_REG(hw, RJC);
-	adapter->stats.torl += E1000_READ_REG(hw, TORL);
-	adapter->stats.torh += E1000_READ_REG(hw, TORH);
-	adapter->stats.totl += E1000_READ_REG(hw, TOTL);
-	adapter->stats.toth += E1000_READ_REG(hw, TOTH);
-	adapter->stats.tpr += E1000_READ_REG(hw, TPR);
-
-	if (adapter->hw.mac_type != e1000_ich8lan) {
-		adapter->stats.ptc64 += E1000_READ_REG(hw, PTC64);
-		adapter->stats.ptc127 += E1000_READ_REG(hw, PTC127);
-		adapter->stats.ptc255 += E1000_READ_REG(hw, PTC255);
-		adapter->stats.ptc511 += E1000_READ_REG(hw, PTC511);
-		adapter->stats.ptc1023 += E1000_READ_REG(hw, PTC1023);
-		adapter->stats.ptc1522 += E1000_READ_REG(hw, PTC1522);
-	}
-
-	adapter->stats.mptc += E1000_READ_REG(hw, MPTC);
-	adapter->stats.bptc += E1000_READ_REG(hw, BPTC);
+	adapter->stats.crcerrs += er32(CRCERRS);
+	adapter->stats.gprc += er32(GPRC);
+	adapter->stats.gorcl += er32(GORCL);
+	adapter->stats.gorch += er32(GORCH);
+	adapter->stats.bprc += er32(BPRC);
+	adapter->stats.mprc += er32(MPRC);
+	adapter->stats.roc += er32(ROC);
+
+	if (hw->mac_type != e1000_ich8lan) {
+		adapter->stats.prc64 += er32(PRC64);
+		adapter->stats.prc127 += er32(PRC127);
+		adapter->stats.prc255 += er32(PRC255);
+		adapter->stats.prc511 += er32(PRC511);
+		adapter->stats.prc1023 += er32(PRC1023);
+		adapter->stats.prc1522 += er32(PRC1522);
+	}
+
+	adapter->stats.symerrs += er32(SYMERRS);
+	adapter->stats.mpc += er32(MPC);
+	adapter->stats.scc += er32(SCC);
+	adapter->stats.ecol += er32(ECOL);
+	adapter->stats.mcc += er32(MCC);
+	adapter->stats.latecol += er32(LATECOL);
+	adapter->stats.dc += er32(DC);
+	adapter->stats.sec += er32(SEC);
+	adapter->stats.rlec += er32(RLEC);
+	adapter->stats.xonrxc += er32(XONRXC);
+	adapter->stats.xontxc += er32(XONTXC);
+	adapter->stats.xoffrxc += er32(XOFFRXC);
+	adapter->stats.xofftxc += er32(XOFFTXC);
+	adapter->stats.fcruc += er32(FCRUC);
+	adapter->stats.gptc += er32(GPTC);
+	adapter->stats.gotcl += er32(GOTCL);
+	adapter->stats.gotch += er32(GOTCH);
+	adapter->stats.rnbc += er32(RNBC);
+	adapter->stats.ruc += er32(RUC);
+	adapter->stats.rfc += er32(RFC);
+	adapter->stats.rjc += er32(RJC);
+	adapter->stats.torl += er32(TORL);
+	adapter->stats.torh += er32(TORH);
+	adapter->stats.totl += er32(TOTL);
+	adapter->stats.toth += er32(TOTH);
+	adapter->stats.tpr += er32(TPR);
+
+	if (hw->mac_type != e1000_ich8lan) {
+		adapter->stats.ptc64 += er32(PTC64);
+		adapter->stats.ptc127 += er32(PTC127);
+		adapter->stats.ptc255 += er32(PTC255);
+		adapter->stats.ptc511 += er32(PTC511);
+		adapter->stats.ptc1023 += er32(PTC1023);
+		adapter->stats.ptc1522 += er32(PTC1522);
+	}
+
+	adapter->stats.mptc += er32(MPTC);
+	adapter->stats.bptc += er32(BPTC);
 
 	/* used for adaptive IFS */
 
-	hw->tx_packet_delta = E1000_READ_REG(hw, TPT);
+	hw->tx_packet_delta = er32(TPT);
 	adapter->stats.tpt += hw->tx_packet_delta;
-	hw->collision_delta = E1000_READ_REG(hw, COLC);
+	hw->collision_delta = er32(COLC);
 	adapter->stats.colc += hw->collision_delta;
 
 	if (hw->mac_type >= e1000_82543) {
-		adapter->stats.algnerrc += E1000_READ_REG(hw, ALGNERRC);
-		adapter->stats.rxerrc += E1000_READ_REG(hw, RXERRC);
-		adapter->stats.tncrs += E1000_READ_REG(hw, TNCRS);
-		adapter->stats.cexterr += E1000_READ_REG(hw, CEXTERR);
-		adapter->stats.tsctc += E1000_READ_REG(hw, TSCTC);
-		adapter->stats.tsctfc += E1000_READ_REG(hw, TSCTFC);
+		adapter->stats.algnerrc += er32(ALGNERRC);
+		adapter->stats.rxerrc += er32(RXERRC);
+		adapter->stats.tncrs += er32(TNCRS);
+		adapter->stats.cexterr += er32(CEXTERR);
+		adapter->stats.tsctc += er32(TSCTC);
+		adapter->stats.tsctfc += er32(TSCTFC);
 	}
 	if (hw->mac_type > e1000_82547_rev_2) {
-		adapter->stats.iac += E1000_READ_REG(hw, IAC);
-		adapter->stats.icrxoc += E1000_READ_REG(hw, ICRXOC);
-
-		if (adapter->hw.mac_type != e1000_ich8lan) {
-			adapter->stats.icrxptc += E1000_READ_REG(hw, ICRXPTC);
-			adapter->stats.icrxatc += E1000_READ_REG(hw, ICRXATC);
-			adapter->stats.ictxptc += E1000_READ_REG(hw, ICTXPTC);
-			adapter->stats.ictxatc += E1000_READ_REG(hw, ICTXATC);
-			adapter->stats.ictxqec += E1000_READ_REG(hw, ICTXQEC);
-			adapter->stats.ictxqmtc += E1000_READ_REG(hw, ICTXQMTC);
-			adapter->stats.icrxdmtc += E1000_READ_REG(hw, ICRXDMTC);
+		adapter->stats.iac += er32(IAC);
+		adapter->stats.icrxoc += er32(ICRXOC);
+
+		if (hw->mac_type != e1000_ich8lan) {
+			adapter->stats.icrxptc += er32(ICRXPTC);
+			adapter->stats.icrxatc += er32(ICRXATC);
+			adapter->stats.ictxptc += er32(ICTXPTC);
+			adapter->stats.ictxatc += er32(ICTXATC);
+			adapter->stats.ictxqec += er32(ICTXQEC);
+			adapter->stats.ictxqmtc += er32(ICTXQMTC);
+			adapter->stats.icrxdmtc += er32(ICRXDMTC);
 		}
 	}
 
@@ -3699,7 +3719,7 @@ void e1000_update_stats(struct e1000_adapter *adapter)
 	adapter->net_stats.tx_aborted_errors = adapter->stats.ecol;
 	adapter->net_stats.tx_window_errors = adapter->stats.latecol;
 	adapter->net_stats.tx_carrier_errors = adapter->stats.tncrs;
-	if (adapter->hw.bad_tx_carr_stats_fd &&
+	if (hw->bad_tx_carr_stats_fd &&
 	    adapter->link_duplex == FULL_DUPLEX) {
 		adapter->net_stats.tx_carrier_errors = 0;
 		adapter->stats.tncrs = 0;
@@ -3722,10 +3742,10 @@ void e1000_update_stats(struct e1000_adapter *adapter)
 	}
 
 	/* Management Stats */
-	if (adapter->hw.has_smbus) {
-		adapter->stats.mgptc += E1000_READ_REG(hw, MGTPTC);
-		adapter->stats.mgprc += E1000_READ_REG(hw, MGTPRC);
-		adapter->stats.mgpdc += E1000_READ_REG(hw, MGTPDC);
+	if (hw->has_smbus) {
+		adapter->stats.mgptc += er32(MGTPTC);
+		adapter->stats.mgprc += er32(MGTPRC);
+		adapter->stats.mgpdc += er32(MGTPDC);
 	}
 
 	spin_unlock_irqrestore(&adapter->stats_lock, flags);
@@ -3745,7 +3765,7 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 #ifndef CONFIG_E1000_NAPI
 	int i;
 #endif
-	u32 icr = E1000_READ_REG(hw, ICR);
+	u32 icr = er32(ICR);
 
 	/* in NAPI mode read ICR disables interrupts using IAM */
 
@@ -3755,10 +3775,10 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 		 * link down event; disable receives here in the ISR and reset
 		 * adapter in watchdog */
 		if (netif_carrier_ok(netdev) &&
-		    (adapter->hw.mac_type == e1000_80003es2lan)) {
+		    (hw->mac_type == e1000_80003es2lan)) {
 			/* disable receives */
-			u32 rctl = E1000_READ_REG(hw, RCTL);
-			E1000_WRITE_REG(hw, RCTL, rctl & ~E1000_RCTL_EN);
+			u32 rctl = er32(RCTL);
+			ew32(RCTL, rctl & ~E1000_RCTL_EN);
 		}
 		/* guard against interrupt when we're going down */
 		if (!test_bit(__E1000_DOWN, &adapter->flags))
@@ -3803,7 +3823,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 rctl, icr = E1000_READ_REG(hw, ICR);
+	u32 rctl, icr = er32(ICR);
 #ifndef CONFIG_E1000_NAPI
 	int i;
 #endif
@@ -3829,10 +3849,10 @@ static irqreturn_t e1000_intr(int irq, void *data)
 		 * reset adapter in watchdog
 		 */
 		if (netif_carrier_ok(netdev) &&
-		    (adapter->hw.mac_type == e1000_80003es2lan)) {
+		    (hw->mac_type == e1000_80003es2lan)) {
 			/* disable receives */
-			rctl = E1000_READ_REG(hw, RCTL);
-			E1000_WRITE_REG(hw, RCTL, rctl & ~E1000_RCTL_EN);
+			rctl = er32(RCTL);
+			ew32(RCTL, rctl & ~E1000_RCTL_EN);
 		}
 		/* guard against interrupt when we're going down */
 		if (!test_bit(__E1000_DOWN, &adapter->flags))
@@ -3842,8 +3862,8 @@ static irqreturn_t e1000_intr(int irq, void *data)
 #ifdef CONFIG_E1000_NAPI
 	if (unlikely(hw->mac_type < e1000_82571)) {
 		/* disable interrupts, without the synchronize_irq bit */
-		E1000_WRITE_REG(hw, IMC, ~0);
-		E1000_WRITE_FLUSH(hw);
+		ew32(IMC, ~0);
+		E1000_WRITE_FLUSH();
 	}
 	if (likely(netif_rx_schedule_prep(netdev, &adapter->napi))) {
 		adapter->total_tx_bytes = 0;
@@ -3867,7 +3887,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	 * de-assertion state.
 	 */
 	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
-		E1000_WRITE_REG(hw, IMC, ~0);
+		ew32(IMC, ~0);
 
 	adapter->total_tx_bytes = 0;
 	adapter->total_rx_bytes = 0;
@@ -3940,6 +3960,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 			       struct e1000_tx_ring *tx_ring)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_desc *tx_desc, *eop_desc;
 	struct e1000_buffer *buffer_info;
@@ -4007,8 +4028,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		if (tx_ring->buffer_info[eop].dma &&
 		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
 		               (adapter->tx_timeout_factor * HZ))
-		    && !(E1000_READ_REG(&adapter->hw, STATUS) &
-		         E1000_STATUS_TXOFF)) {
+		    && !(er32(STATUS) & E1000_STATUS_TXOFF)) {
 
 			/* detected Tx unit hang */
 			DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
@@ -4024,8 +4044,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 					"  next_to_watch.status <%x>\n",
 				(unsigned long)((tx_ring - adapter->tx_ring) /
 					sizeof(struct e1000_tx_ring)),
-				readl(adapter->hw.hw_addr + tx_ring->tdh),
-				readl(adapter->hw.hw_addr + tx_ring->tdt),
+				readl(hw->hw_addr + tx_ring->tdh),
+				readl(hw->hw_addr + tx_ring->tdt),
 				tx_ring->next_to_use,
 				tx_ring->next_to_clean,
 				tx_ring->buffer_info[eop].time_stamp,
@@ -4053,12 +4073,13 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 			      u32 csum, struct sk_buff *skb)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u16 status = (u16)status_err;
 	u8 errors = (u8)(status_err >> 24);
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/* 82543 or newer only */
-	if (unlikely(adapter->hw.mac_type < e1000_82543)) return;
+	if (unlikely(hw->mac_type < e1000_82543)) return;
 	/* Ignore Checksum bit is set */
 	if (unlikely(status & E1000_RXD_STAT_IXSM)) return;
 	/* TCP/UDP checksum error bit is set */
@@ -4068,7 +4089,7 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 		return;
 	}
 	/* TCP/UDP Checksum has not been calculated */
-	if (adapter->hw.mac_type <= e1000_82547_rev_2) {
+	if (hw->mac_type <= e1000_82547_rev_2) {
 		if (!(status & E1000_RXD_STAT_TCPCS))
 			return;
 	} else {
@@ -4079,7 +4100,7 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 	if (likely(status & E1000_RXD_STAT_TCPCS)) {
 		/* TCP checksum is good */
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	} else if (adapter->hw.mac_type > e1000_82547_rev_2) {
+	} else if (hw->mac_type > e1000_82547_rev_2) {
 		/* IP fragment with UDP payload */
 		/* Hardware complements the payload checksum, so we undo it
 		 * and then put the value in host order for further stack use.
@@ -4104,6 +4125,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			       struct e1000_rx_ring *rx_ring)
 #endif
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc, *next_rxd;
@@ -4161,11 +4183,10 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 
 		if (unlikely(rx_desc->errors & E1000_RXD_ERR_FRAME_ERR_MASK)) {
 			last_byte = *(skb->data + length - 1);
-			if (TBI_ACCEPT(&adapter->hw, status,
-			              rx_desc->errors, length, last_byte)) {
+			if (TBI_ACCEPT(hw, status, rx_desc->errors, length,
+				       last_byte)) {
 				spin_lock_irqsave(&adapter->stats_lock, flags);
-				e1000_tbi_adjust_stats(&adapter->hw,
-				                       &adapter->stats,
+				e1000_tbi_adjust_stats(hw, &adapter->stats,
 				                       length, skb->data);
 				spin_unlock_irqrestore(&adapter->stats_lock,
 				                       flags);
@@ -4455,6 +4476,7 @@ static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
 				   struct e1000_rx_ring *rx_ring,
 				   int cleaned_count)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_rx_desc *rx_desc;
@@ -4552,7 +4574,7 @@ map_skb:
 		 * applicable for weak-ordered memory model archs,
 		 * such as IA-64). */
 		wmb();
-		writel(i, adapter->hw.hw_addr + rx_ring->rdt);
+		writel(i, hw->hw_addr + rx_ring->rdt);
 	}
 }
 
@@ -4565,6 +4587,7 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 				      struct e1000_rx_ring *rx_ring,
 				      int cleaned_count)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union e1000_rx_desc_packet_split *rx_desc;
@@ -4649,7 +4672,7 @@ no_buffers:
 		 * descriptors are 32 bytes...so we increment tail
 		 * twice as much.
 		 */
-		writel(i<<1, adapter->hw.hw_addr + rx_ring->rdt);
+		writel(i<<1, hw->hw_addr + rx_ring->rdt);
 	}
 }
 
@@ -4660,46 +4683,47 @@ no_buffers:
 
 static void e1000_smartspeed(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	u16 phy_status;
 	u16 phy_ctrl;
 
-	if ((adapter->hw.phy_type != e1000_phy_igp) || !adapter->hw.autoneg ||
-	   !(adapter->hw.autoneg_advertised & ADVERTISE_1000_FULL))
+	if ((hw->phy_type != e1000_phy_igp) || !hw->autoneg ||
+	   !(hw->autoneg_advertised & ADVERTISE_1000_FULL))
 		return;
 
 	if (adapter->smartspeed == 0) {
 		/* If Master/Slave config fault is asserted twice,
 		 * we assume back-to-back */
-		e1000_read_phy_reg(&adapter->hw, PHY_1000T_STATUS, &phy_status);
+		e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_status);
 		if (!(phy_status & SR_1000T_MS_CONFIG_FAULT)) return;
-		e1000_read_phy_reg(&adapter->hw, PHY_1000T_STATUS, &phy_status);
+		e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_status);
 		if (!(phy_status & SR_1000T_MS_CONFIG_FAULT)) return;
-		e1000_read_phy_reg(&adapter->hw, PHY_1000T_CTRL, &phy_ctrl);
+		e1000_read_phy_reg(hw, PHY_1000T_CTRL, &phy_ctrl);
 		if (phy_ctrl & CR_1000T_MS_ENABLE) {
 			phy_ctrl &= ~CR_1000T_MS_ENABLE;
-			e1000_write_phy_reg(&adapter->hw, PHY_1000T_CTRL,
+			e1000_write_phy_reg(hw, PHY_1000T_CTRL,
 					    phy_ctrl);
 			adapter->smartspeed++;
-			if (!e1000_phy_setup_autoneg(&adapter->hw) &&
-			   !e1000_read_phy_reg(&adapter->hw, PHY_CTRL,
+			if (!e1000_phy_setup_autoneg(hw) &&
+			   !e1000_read_phy_reg(hw, PHY_CTRL,
 				   	       &phy_ctrl)) {
 				phy_ctrl |= (MII_CR_AUTO_NEG_EN |
 					     MII_CR_RESTART_AUTO_NEG);
-				e1000_write_phy_reg(&adapter->hw, PHY_CTRL,
+				e1000_write_phy_reg(hw, PHY_CTRL,
 						    phy_ctrl);
 			}
 		}
 		return;
 	} else if (adapter->smartspeed == E1000_SMARTSPEED_DOWNSHIFT) {
 		/* If still no link, perhaps using 2/3 pair cable */
-		e1000_read_phy_reg(&adapter->hw, PHY_1000T_CTRL, &phy_ctrl);
+		e1000_read_phy_reg(hw, PHY_1000T_CTRL, &phy_ctrl);
 		phy_ctrl |= CR_1000T_MS_ENABLE;
-		e1000_write_phy_reg(&adapter->hw, PHY_1000T_CTRL, phy_ctrl);
-		if (!e1000_phy_setup_autoneg(&adapter->hw) &&
-		   !e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &phy_ctrl)) {
+		e1000_write_phy_reg(hw, PHY_1000T_CTRL, phy_ctrl);
+		if (!e1000_phy_setup_autoneg(hw) &&
+		   !e1000_read_phy_reg(hw, PHY_CTRL, &phy_ctrl)) {
 			phy_ctrl |= (MII_CR_AUTO_NEG_EN |
 				     MII_CR_RESTART_AUTO_NEG);
-			e1000_write_phy_reg(&adapter->hw, PHY_CTRL, phy_ctrl);
+			e1000_write_phy_reg(hw, PHY_CTRL, phy_ctrl);
 		}
 	}
 	/* Restart process after E1000_SMARTSPEED_MAX iterations */
@@ -4737,24 +4761,25 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 			   int cmd)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	struct mii_ioctl_data *data = if_mii(ifr);
 	int retval;
 	u16 mii_reg;
 	u16 spddplx;
 	unsigned long flags;
 
-	if (adapter->hw.media_type != e1000_media_type_copper)
+	if (hw->media_type != e1000_media_type_copper)
 		return -EOPNOTSUPP;
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
-		data->phy_id = adapter->hw.phy_addr;
+		data->phy_id = hw->phy_addr;
 		break;
 	case SIOCGMIIREG:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 		spin_lock_irqsave(&adapter->stats_lock, flags);
-		if (e1000_read_phy_reg(&adapter->hw, data->reg_num & 0x1F,
+		if (e1000_read_phy_reg(hw, data->reg_num & 0x1F,
 				   &data->val_out)) {
 			spin_unlock_irqrestore(&adapter->stats_lock, flags);
 			return -EIO;
@@ -4768,20 +4793,20 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 			return -EFAULT;
 		mii_reg = data->val_in;
 		spin_lock_irqsave(&adapter->stats_lock, flags);
-		if (e1000_write_phy_reg(&adapter->hw, data->reg_num,
+		if (e1000_write_phy_reg(hw, data->reg_num,
 					mii_reg)) {
 			spin_unlock_irqrestore(&adapter->stats_lock, flags);
 			return -EIO;
 		}
 		spin_unlock_irqrestore(&adapter->stats_lock, flags);
-		if (adapter->hw.media_type == e1000_media_type_copper) {
+		if (hw->media_type == e1000_media_type_copper) {
 			switch (data->reg_num) {
 			case PHY_CTRL:
 				if (mii_reg & MII_CR_POWER_DOWN)
 					break;
 				if (mii_reg & MII_CR_AUTO_NEG_EN) {
-					adapter->hw.autoneg = 1;
-					adapter->hw.autoneg_advertised = 0x2F;
+					hw->autoneg = 1;
+					hw->autoneg_advertised = 0x2F;
 				} else {
 					if (mii_reg & 0x40)
 						spddplx = SPEED_1000;
@@ -4804,7 +4829,7 @@ static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 				break;
 			case M88E1000_PHY_SPEC_CTRL:
 			case M88E1000_EXT_PHY_SPEC_CTRL:
-				if (e1000_phy_reset(&adapter->hw))
+				if (e1000_phy_reset(hw))
 					return -EIO;
 				break;
 			}
@@ -4878,6 +4903,7 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 				   struct vlan_group *grp)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl, rctl;
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
@@ -4886,29 +4912,29 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 
 	if (grp) {
 		/* enable VLAN tag insert/strip */
-		ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+		ctrl = er32(CTRL);
 		ctrl |= E1000_CTRL_VME;
-		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
+		ew32(CTRL, ctrl);
 
-		if (adapter->hw.mac_type != e1000_ich8lan) {
+		if (hw->mac_type != e1000_ich8lan) {
 			/* enable VLAN receive filtering */
-			rctl = E1000_READ_REG(&adapter->hw, RCTL);
+			rctl = er32(RCTL);
 			rctl |= E1000_RCTL_VFE;
 			rctl &= ~E1000_RCTL_CFIEN;
-			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+			ew32(RCTL, rctl);
 			e1000_update_mng_vlan(adapter);
 		}
 	} else {
 		/* disable VLAN tag insert/strip */
-		ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+		ctrl = er32(CTRL);
 		ctrl &= ~E1000_CTRL_VME;
-		E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
+		ew32(CTRL, ctrl);
 
-		if (adapter->hw.mac_type != e1000_ich8lan) {
+		if (hw->mac_type != e1000_ich8lan) {
 			/* disable VLAN filtering */
-			rctl = E1000_READ_REG(&adapter->hw, RCTL);
+			rctl = er32(RCTL);
 			rctl &= ~E1000_RCTL_VFE;
-			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+			ew32(RCTL, rctl);
 			if (adapter->mng_vlan_id !=
 			    (u16)E1000_MNG_VLAN_NONE) {
 				e1000_vlan_rx_kill_vid(netdev,
@@ -4925,22 +4951,24 @@ static void e1000_vlan_rx_register(struct net_device *netdev,
 static void e1000_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	u32 vfta, index;
 
-	if ((adapter->hw.mng_cookie.status &
+	if ((hw->mng_cookie.status &
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
 	    (vid == adapter->mng_vlan_id))
 		return;
 	/* add VID to filter table */
 	index = (vid >> 5) & 0x7F;
-	vfta = E1000_READ_REG_ARRAY(&adapter->hw, VFTA, index);
+	vfta = E1000_READ_REG_ARRAY(hw, VFTA, index);
 	vfta |= (1 << (vid & 0x1F));
-	e1000_write_vfta(&adapter->hw, index, vfta);
+	e1000_write_vfta(hw, index, vfta);
 }
 
 static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	u32 vfta, index;
 
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
@@ -4949,7 +4977,7 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 	if (!test_bit(__E1000_DOWN, &adapter->flags))
 		e1000_irq_enable(adapter);
 
-	if ((adapter->hw.mng_cookie.status &
+	if ((hw->mng_cookie.status &
 	     E1000_MNG_DHCP_COOKIE_STATUS_VLAN_SUPPORT) &&
 	    (vid == adapter->mng_vlan_id)) {
 		/* release control to f/w */
@@ -4959,9 +4987,9 @@ static void e1000_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 
 	/* remove VID from filter table */
 	index = (vid >> 5) & 0x7F;
-	vfta = E1000_READ_REG_ARRAY(&adapter->hw, VFTA, index);
+	vfta = E1000_READ_REG_ARRAY(hw, VFTA, index);
 	vfta &= ~(1 << (vid & 0x1F));
-	e1000_write_vfta(&adapter->hw, index, vfta);
+	e1000_write_vfta(hw, index, vfta);
 }
 
 static void e1000_restore_vlan(struct e1000_adapter *adapter)
@@ -4980,10 +5008,12 @@ static void e1000_restore_vlan(struct e1000_adapter *adapter)
 
 int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 {
-	adapter->hw.autoneg = 0;
+	struct e1000_hw *hw = &adapter->hw;
+
+	hw->autoneg = 0;
 
 	/* Fiber NICs only allow 1000 gbps Full duplex */
-	if ((adapter->hw.media_type == e1000_media_type_fiber) &&
+	if ((hw->media_type == e1000_media_type_fiber) &&
 		spddplx != (SPEED_1000 + DUPLEX_FULL)) {
 		DPRINTK(PROBE, ERR, "Unsupported Speed/Duplex configuration\n");
 		return -EINVAL;
@@ -4991,20 +5021,20 @@ int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 
 	switch (spddplx) {
 	case SPEED_10 + DUPLEX_HALF:
-		adapter->hw.forced_speed_duplex = e1000_10_half;
+		hw->forced_speed_duplex = e1000_10_half;
 		break;
 	case SPEED_10 + DUPLEX_FULL:
-		adapter->hw.forced_speed_duplex = e1000_10_full;
+		hw->forced_speed_duplex = e1000_10_full;
 		break;
 	case SPEED_100 + DUPLEX_HALF:
-		adapter->hw.forced_speed_duplex = e1000_100_half;
+		hw->forced_speed_duplex = e1000_100_half;
 		break;
 	case SPEED_100 + DUPLEX_FULL:
-		adapter->hw.forced_speed_duplex = e1000_100_full;
+		hw->forced_speed_duplex = e1000_100_full;
 		break;
 	case SPEED_1000 + DUPLEX_FULL:
-		adapter->hw.autoneg = 1;
-		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
+		hw->autoneg = 1;
+		hw->autoneg_advertised = ADVERTISE_1000_FULL;
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
@@ -5018,6 +5048,7 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	u32 ctrl, ctrl_ext, rctl, status;
 	u32 wufc = adapter->wol;
 #ifdef CONFIG_PM
@@ -5037,7 +5068,7 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 		return retval;
 #endif
 
-	status = E1000_READ_REG(&adapter->hw, STATUS);
+	status = er32(STATUS);
 	if (status & E1000_STATUS_LU)
 		wufc &= ~E1000_WUFC_LNKC;
 
@@ -5047,40 +5078,40 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 
 		/* turn on all-multi mode if wake on multicast is enabled */
 		if (wufc & E1000_WUFC_MC) {
-			rctl = E1000_READ_REG(&adapter->hw, RCTL);
+			rctl = er32(RCTL);
 			rctl |= E1000_RCTL_MPE;
-			E1000_WRITE_REG(&adapter->hw, RCTL, rctl);
+			ew32(RCTL, rctl);
 		}
 
-		if (adapter->hw.mac_type >= e1000_82540) {
-			ctrl = E1000_READ_REG(&adapter->hw, CTRL);
+		if (hw->mac_type >= e1000_82540) {
+			ctrl = er32(CTRL);
 			/* advertise wake from D3Cold */
 			#define E1000_CTRL_ADVD3WUC 0x00100000
 			/* phy power management enable */
 			#define E1000_CTRL_EN_PHY_PWR_MGMT 0x00200000
 			ctrl |= E1000_CTRL_ADVD3WUC |
 				E1000_CTRL_EN_PHY_PWR_MGMT;
-			E1000_WRITE_REG(&adapter->hw, CTRL, ctrl);
+			ew32(CTRL, ctrl);
 		}
 
-		if (adapter->hw.media_type == e1000_media_type_fiber ||
-		   adapter->hw.media_type == e1000_media_type_internal_serdes) {
+		if (hw->media_type == e1000_media_type_fiber ||
+		   hw->media_type == e1000_media_type_internal_serdes) {
 			/* keep the laser running in D3 */
-			ctrl_ext = E1000_READ_REG(&adapter->hw, CTRL_EXT);
+			ctrl_ext = er32(CTRL_EXT);
 			ctrl_ext |= E1000_CTRL_EXT_SDP7_DATA;
-			E1000_WRITE_REG(&adapter->hw, CTRL_EXT, ctrl_ext);
+			ew32(CTRL_EXT, ctrl_ext);
 		}
 
 		/* Allow time for pending master requests to run */
-		e1000_disable_pciex_master(&adapter->hw);
+		e1000_disable_pciex_master(hw);
 
-		E1000_WRITE_REG(&adapter->hw, WUC, E1000_WUC_PME_EN);
-		E1000_WRITE_REG(&adapter->hw, WUFC, wufc);
+		ew32(WUC, E1000_WUC_PME_EN);
+		ew32(WUFC, wufc);
 		pci_enable_wake(pdev, PCI_D3hot, 1);
 		pci_enable_wake(pdev, PCI_D3cold, 1);
 	} else {
-		E1000_WRITE_REG(&adapter->hw, WUC, 0);
-		E1000_WRITE_REG(&adapter->hw, WUFC, 0);
+		ew32(WUC, 0);
+		ew32(WUFC, 0);
 		pci_enable_wake(pdev, PCI_D3hot, 0);
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
@@ -5093,8 +5124,8 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 		pci_enable_wake(pdev, PCI_D3cold, 1);
 	}
 
-	if (adapter->hw.phy_type == e1000_phy_igp_3)
-		e1000_phy_powerdown_workaround(&adapter->hw);
+	if (hw->phy_type == e1000_phy_igp_3)
+		e1000_phy_powerdown_workaround(hw);
 
 	if (netif_running(netdev))
 		e1000_free_irq(adapter);
@@ -5115,6 +5146,7 @@ static int e1000_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
 	u32 err;
 
 	pci_set_power_state(pdev, PCI_D0);
@@ -5133,7 +5165,7 @@ static int e1000_resume(struct pci_dev *pdev)
 
 	e1000_power_up_phy(adapter);
 	e1000_reset(adapter);
-	E1000_WRITE_REG(&adapter->hw, WUS, ~0);
+	ew32(WUS, ~0);
 
 	e1000_init_manageability(adapter);
 
@@ -5146,8 +5178,8 @@ static int e1000_resume(struct pci_dev *pdev)
 	 * DRV_LOAD until the interface is up.  For all other cases,
 	 * let the f/w know that the h/w is now under the control
 	 * of the driver. */
-	if (adapter->hw.mac_type != e1000_82573 ||
-	    !e1000_check_mng_mode(&adapter->hw))
+	if (hw->mac_type != e1000_82573 ||
+	    !e1000_check_mng_mode(hw))
 		e1000_get_hw_control(adapter);
 
 	return 0;
@@ -5213,6 +5245,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_hw *hw = &adapter->hw;
 
 	if (pci_enable_device(pdev)) {
 		printk(KERN_ERR "e1000: Cannot re-enable PCI device after reset.\n");
@@ -5224,7 +5257,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
 	e1000_reset(adapter);
-	E1000_WRITE_REG(&adapter->hw, WUS, ~0);
+	ew32(WUS, ~0);
 
 	return PCI_ERS_RESULT_RECOVERED;
 }
@@ -5241,6 +5274,7 @@ static void e1000_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev->priv;
+	struct e1000_hw *hw = &adapter->hw;
 
 	e1000_init_manageability(adapter);
 
@@ -5257,8 +5291,8 @@ static void e1000_io_resume(struct pci_dev *pdev)
 	 * DRV_LOAD until the interface is up.  For all other cases,
 	 * let the f/w know that the h/w is now under the control
 	 * of the driver. */
-	if (adapter->hw.mac_type != e1000_82573 ||
-	    !e1000_check_mng_mode(&adapter->hw))
+	if (hw->mac_type != e1000_82573 ||
+	    !e1000_check_mng_mode(hw))
 		e1000_get_hw_control(adapter);
 
 }
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 365626d..acb5134 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -55,13 +55,13 @@
 #define DEBUGOUT7 DEBUGOUT3
 
 
-#define E1000_WRITE_REG(a, reg, value) ( \
-    writel((value), ((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg))))
+#define er32(reg)\
+	(readl(hw->hw_addr + ((hw->mac_type >= e1000_82543)		\
+			       ? E1000_##reg : E1000_82542_##reg)))
 
-#define E1000_READ_REG(a, reg) ( \
-    readl((a)->hw_addr + \
-        (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg)))
+#define ew32(reg, value)						\
+	(writel((value), (hw->hw_addr + ((hw->mac_type >= e1000_82543)	\
+					 ? E1000_##reg : E1000_82542_##reg))))
 
 #define E1000_WRITE_REG_ARRAY(a, reg, offset, value) ( \
     writel((value), ((a)->hw_addr + \
@@ -96,7 +96,7 @@
         (((a)->mac_type >= e1000_82543) ? E1000_##reg : E1000_82542_##reg) + \
         (offset)))
 
-#define E1000_WRITE_FLUSH(a) E1000_READ_REG(a, STATUS)
+#define E1000_WRITE_FLUSH() er32(STATUS)
 
 #define E1000_WRITE_ICH_FLASH_REG(a, reg, value) ( \
     writel((value), ((a)->flash_address + reg)))

