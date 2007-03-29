From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 18/19] e1000: adapter struct changes, new phy/mac substructs
Date: Thu, 29 Mar 2007 09:40:36 -0700
Message-ID: <20070329164035.6595.64728.stgit@localhost.localdomain>
References: <20070329163304.6595.81963.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: auke-jan.h.kok@intel.com, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	cramerj@intel.com, john.ronciak@intel.com,
	arjan.van.de.ven@intel.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:3811 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030376AbXC2QlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 12:41:08 -0400
In-Reply-To: <20070329163304.6595.81963.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeb Cramer <cramerj@intel.com>

The adapter->hw struct now has separate mac and phy substructs, requiring
us to change all references to them appropriately.

Signed-off-by: Jeb Cramer <cramerj@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h         |    5 
 drivers/net/e1000/e1000_ethtool.c |  186 ++++++++---------
 drivers/net/e1000/e1000_main.c    |  414 ++++++++++++++++++++-----------------
 drivers/net/e1000/e1000_param.c   |   86 ++++----
 4 files changed, 368 insertions(+), 323 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index d896307..e88a204 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -349,6 +349,11 @@ struct e1000_adapter {
 	boolean_t quad_port_a;
 	unsigned long flags;
 	uint32_t eeprom_wol;
+
+	int rx_needs_kicking;
+	int bad_tx_carr_stats_fd;
+	int has_smbus;
+	int has_manc2h;
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index ef7166b..033cdb6 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -131,20 +131,20 @@ e1000_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		                   SUPPORTED_1000baseT_Full|
 		                   SUPPORTED_Autoneg |
 		                   SUPPORTED_TP);
-		if (hw->phy_type == e1000_phy_ife)
+		if (hw->phy.type == e1000_phy_ife)
 			ecmd->supported &= ~SUPPORTED_1000baseT_Full;
 		ecmd->advertising = ADVERTISED_TP;
 
-		if (hw->autoneg == 1) {
+		if (hw->mac.autoneg == 1) {
 			ecmd->advertising |= ADVERTISED_Autoneg;
 			/* the e1000 autoneg seems to match ethtool nicely */
-			ecmd->advertising |= hw->autoneg_advertised;
+			ecmd->advertising |= hw->phy.autoneg_advertised;
 		}
 
 		ecmd->port = PORT_TP;
-		ecmd->phy_address = hw->phy_addr;
+		ecmd->phy_address = hw->phy.addr;
 
-		if (hw->mac_type == e1000_82543)
+		if (hw->mac.type == e1000_82543)
 			ecmd->transceiver = XCVR_EXTERNAL;
 		else
 			ecmd->transceiver = XCVR_INTERNAL;
@@ -160,7 +160,7 @@ e1000_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 		ecmd->port = PORT_FIBRE;
 
-		if (hw->mac_type >= e1000_82545)
+		if (hw->mac.type >= e1000_82545)
 			ecmd->transceiver = XCVR_INTERNAL;
 		else
 			ecmd->transceiver = XCVR_EXTERNAL;
@@ -185,7 +185,7 @@ e1000_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	}
 
 	ecmd->autoneg = ((hw->media_type == e1000_media_type_fiber) ||
-			 hw->autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+			 hw->mac.autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
 	return 0;
 }
 
@@ -197,7 +197,7 @@ e1000_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 
 	/* When SoL/IDER sessions are active, autoneg/speed/duplex
 	 * cannot be changed */
-	if (e1000_check_phy_reset_block(hw)) {
+	if (e1000_check_reset_block(hw)) {
 		DPRINTK(DRV, ERR, "Cannot change link characteristics "
 		        "when SoL/IDER is active.\n");
 		return -EINVAL;
@@ -207,16 +207,16 @@ e1000_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		msleep(1);
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
-		hw->autoneg = 1;
+		hw->mac.autoneg = 1;
 		if (hw->media_type == e1000_media_type_fiber)
-			hw->autoneg_advertised = ADVERTISED_1000baseT_Full |
-				     ADVERTISED_FIBRE |
-				     ADVERTISED_Autoneg;
+			hw->phy.autoneg_advertised = ADVERTISED_1000baseT_Full |
+			                             ADVERTISED_FIBRE |
+			                             ADVERTISED_Autoneg;
 		else
-			hw->autoneg_advertised = ecmd->advertising |
-			                         ADVERTISED_TP |
-			                         ADVERTISED_Autoneg;
-		ecmd->advertising = hw->autoneg_advertised;
+			hw->phy.autoneg_advertised = ecmd->advertising |
+			                             ADVERTISED_TP |
+			                             ADVERTISED_Autoneg;
+		ecmd->advertising = hw->phy.autoneg_advertised;
 	} else
 		if (e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex)) {
 			clear_bit(__E1000_RESETTING, &adapter->flags);
@@ -245,11 +245,11 @@ e1000_get_pauseparam(struct net_device *netdev,
 	pause->autoneg =
 		(adapter->fc_autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE);
 
-	if (hw->fc == e1000_fc_rx_pause)
+	if (hw->mac.fc == e1000_fc_rx_pause)
 		pause->rx_pause = 1;
-	else if (hw->fc == e1000_fc_tx_pause)
+	else if (hw->mac.fc == e1000_fc_tx_pause)
 		pause->tx_pause = 1;
-	else if (hw->fc == e1000_fc_full) {
+	else if (hw->mac.fc == e1000_fc_full) {
 		pause->rx_pause = 1;
 		pause->tx_pause = 1;
 	}
@@ -269,15 +269,15 @@ e1000_set_pauseparam(struct net_device *netdev,
 		msleep(1);
 
 	if (pause->rx_pause && pause->tx_pause)
-		hw->fc = e1000_fc_full;
+		hw->mac.fc = e1000_fc_full;
 	else if (pause->rx_pause && !pause->tx_pause)
-		hw->fc = e1000_fc_rx_pause;
+		hw->mac.fc = e1000_fc_rx_pause;
 	else if (!pause->rx_pause && pause->tx_pause)
-		hw->fc = e1000_fc_tx_pause;
+		hw->mac.fc = e1000_fc_tx_pause;
 	else if (!pause->rx_pause && !pause->tx_pause)
-		hw->fc = e1000_fc_none;
+		hw->mac.fc = e1000_fc_none;
 
-	hw->original_fc = hw->fc;
+	hw->mac.original_fc = hw->mac.fc;
 
 	if (adapter->fc_autoneg == AUTONEG_ENABLE) {
 		if (netif_running(adapter->netdev)) {
@@ -324,7 +324,7 @@ e1000_set_tx_csum(struct net_device *netdev, uint32_t data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 
-	if (adapter->hw.mac_type < e1000_82543) {
+	if (adapter->hw.mac.type < e1000_82543) {
 		if (!data)
 			return -EINVAL;
 		return 0;
@@ -342,8 +342,8 @@ static int
 e1000_set_tso(struct net_device *netdev, uint32_t data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	if ((adapter->hw.mac_type < e1000_82544) ||
-	    (adapter->hw.mac_type == e1000_82547))
+	if ((adapter->hw.mac.type < e1000_82544) ||
+	    (adapter->hw.mac.type == e1000_82547))
 		return data ? -EINVAL : 0;
 
 	if (data)
@@ -410,8 +410,8 @@ e1000_get_regs(struct net_device *netdev,
 	regs_buff[10] = E1000_READ_REG(hw, E1000_TDT);
 	regs_buff[11] = E1000_READ_REG(hw, E1000_TIDV);
 
-	regs_buff[12] = adapter->hw.phy_type;  /* PHY type (IGP=1, M88=0) */
-	if (hw->phy_type == e1000_phy_igp) {
+	regs_buff[12] = adapter->hw.phy.type;  /* PHY type (IGP=1, M88=0) */
+	if (hw->phy.type == e1000_phy_igp) {
 		e1000_write_phy_reg(hw, IGP01E1000_PHY_PAGE_SELECT,
 				    IGP01E1000_PHY_AGC_A);
 		e1000_read_phy_reg(hw, IGP01E1000_PHY_AGC_A &
@@ -465,8 +465,8 @@ e1000_get_regs(struct net_device *netdev,
 	e1000_read_phy_reg(hw, PHY_1000T_STATUS, &phy_data);
 	regs_buff[24] = (uint32_t)phy_data;  /* phy local receiver status */
 	regs_buff[25] = regs_buff[24];  /* phy remote receiver status */
-	if (hw->mac_type >= e1000_82540 &&
-	    hw->mac_type < e1000_82571 &&
+	if (hw->mac.type >= e1000_82540 &&
+	    hw->mac.type < e1000_82571 &&
 	    hw->media_type == e1000_media_type_copper) {
 		regs_buff[26] = E1000_READ_REG(hw, E1000_MANC);
 	}
@@ -476,7 +476,7 @@ static int
 e1000_get_eeprom_len(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	return adapter->hw.eeprom.word_size * 2;
+	return adapter->hw.nvm.word_size * 2;
 }
 
 static int
@@ -503,14 +503,14 @@ e1000_get_eeprom(struct net_device *netdev,
 	if (!eeprom_buff)
 		return -ENOMEM;
 
-	if (hw->eeprom.type == e1000_eeprom_spi)
-		ret_val = e1000_read_eeprom(hw, first_word,
-					    last_word - first_word + 1,
-					    eeprom_buff);
+	if (hw->nvm.type == e1000_nvm_eeprom_spi)
+		ret_val = e1000_read_nvm(hw, first_word,
+		                         last_word - first_word + 1,
+		                         eeprom_buff);
 	else {
 		for (i = 0; i < last_word - first_word + 1; i++)
-			if ((ret_val = e1000_read_eeprom(hw, first_word + i, 1,
-							&eeprom_buff[i])))
+			if ((ret_val = e1000_read_nvm(hw, first_word + i, 1,
+			                              &eeprom_buff[i])))
 				break;
 	}
 
@@ -542,7 +542,7 @@ e1000_set_eeprom(struct net_device *netdev,
 	if (eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
 		return -EFAULT;
 
-	max_len = hw->eeprom.word_size * 2;
+	max_len = hw->nvm.word_size * 2;
 
 	first_word = eeprom->offset >> 1;
 	last_word = (eeprom->offset + eeprom->len - 1) >> 1;
@@ -555,14 +555,14 @@ e1000_set_eeprom(struct net_device *netdev,
 	if (eeprom->offset & 1) {
 		/* need read/modify/write of first changed EEPROM word */
 		/* only the second byte of the word is being modified */
-		ret_val = e1000_read_eeprom(hw, first_word, 1,
+		ret_val = e1000_read_nvm(hw, first_word, 1,
 					    &eeprom_buff[0]);
 		ptr++;
 	}
 	if (((eeprom->offset + eeprom->len) & 1) && (ret_val == 0)) {
 		/* need read/modify/write of last changed EEPROM word */
 		/* only the first byte of the word is being modified */
-		ret_val = e1000_read_eeprom(hw, last_word, 1,
+		ret_val = e1000_read_nvm(hw, last_word, 1,
 		                  &eeprom_buff[last_word - first_word]);
 	}
 
@@ -575,14 +575,14 @@ e1000_set_eeprom(struct net_device *netdev,
 	for (i = 0; i < last_word - first_word + 1; i++)
 		eeprom_buff[i] = cpu_to_le16(eeprom_buff[i]);
 
-	ret_val = e1000_write_eeprom(hw, first_word,
-				     last_word - first_word + 1, eeprom_buff);
+	ret_val = e1000_write_nvm(hw, first_word,
+	                          last_word - first_word + 1, eeprom_buff);
 
 	/* Update the checksum over the first part of the EEPROM if needed
-	 * and flush shadow RAM for 82573 conrollers */
-	if ((ret_val == 0) && ((first_word <= EEPROM_CHECKSUM_REG) ||
-				(hw->mac_type == e1000_82573)))
-		e1000_update_eeprom_checksum(hw);
+	 * and flush shadow RAM for 82573 controllers */
+	if ((ret_val == 0) && ((first_word <= NVM_CHECKSUM_REG) ||
+				(hw->mac.type == e1000_82573)))
+		e1000_update_nvm_checksum(hw);
 
 	kfree(eeprom_buff);
 	return ret_val;
@@ -601,8 +601,8 @@ e1000_get_drvinfo(struct net_device *netdev,
 
 	/* EEPROM image version # is reported as firmware version # for
 	 * 8257{1|2|3} controllers */
-	e1000_read_eeprom(&adapter->hw, 5, 1, &eeprom_data);
-	switch (adapter->hw.mac_type) {
+	e1000_read_nvm(&adapter->hw, 5, 1, &eeprom_data);
+	switch (adapter->hw.mac.type) {
 	case e1000_82571:
 	case e1000_82572:
 	case e1000_82573:
@@ -630,7 +630,7 @@ e1000_get_ringparam(struct net_device *netdev,
                     struct ethtool_ringparam *ring)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	e1000_mac_type mac_type = adapter->hw.mac_type;
+	e1000_mac_type mac_type = adapter->hw.mac.type;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	struct e1000_rx_ring *rxdr = adapter->rx_ring;
 
@@ -651,7 +651,7 @@ e1000_set_ringparam(struct net_device *netdev,
                     struct ethtool_ringparam *ring)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	e1000_mac_type mac_type = adapter->hw.mac_type;
+	e1000_mac_type mac_type = adapter->hw.mac.type;
 	struct e1000_tx_ring *txdr, *tx_old;
 	struct e1000_rx_ring *rxdr, *rx_old;
 	int i, err;
@@ -768,13 +768,14 @@ err_setup:
 static int
 e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 {
+	struct e1000_mac_info *mac = &adapter->hw.mac;
 	uint32_t value, before, after;
 	uint32_t i, toggle;
 
 	/* The status register is Read Only, so a write should fail.
 	 * Some bits that get toggled are ignored.
 	 */
-	switch (adapter->hw.mac_type) {
+	switch (mac->type) {
 	/* there are several bits on newer hardware that are r/w */
 	case e1000_82571:
 	case e1000_82572:
@@ -803,7 +804,7 @@ e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 	/* restore previous status */
 	E1000_WRITE_REG(&adapter->hw, E1000_STATUS, before);
 
-	if (adapter->hw.mac_type != e1000_ich8lan) {
+	if (mac->type != e1000_ich8lan) {
 		REG_PATTERN_TEST(E1000_FCAL, 0xFFFFFFFF, 0xFFFFFFFF);
 		REG_PATTERN_TEST(E1000_FCAH, 0x0000FFFF, 0xFFFFFFFF);
 		REG_PATTERN_TEST(E1000_FCT, 0x0000FFFF, 0xFFFFFFFF);
@@ -823,22 +824,19 @@ e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 
 	REG_SET_AND_CHECK(E1000_RCTL, 0xFFFFFFFF, 0x00000000);
 
-	before = (adapter->hw.mac_type == e1000_ich8lan ?
-	          0x06C3B33E : 0x06DFB3FE);
+	before = (mac->type == e1000_ich8lan ? 0x06C3B33E : 0x06DFB3FE);
 	REG_SET_AND_CHECK(E1000_RCTL, before, 0x003FFFFB);
 	REG_SET_AND_CHECK(E1000_TCTL, 0xFFFFFFFF, 0x00000000);
 
-	if (adapter->hw.mac_type >= e1000_82543) {
+	if (mac->type >= e1000_82543) {
 
 		REG_SET_AND_CHECK(E1000_RCTL, before, 0xFFFFFFFF);
 		REG_PATTERN_TEST(E1000_RDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
-		if (adapter->hw.mac_type != e1000_ich8lan)
+		if (mac->type != e1000_ich8lan)
 			REG_PATTERN_TEST(E1000_TXCW, 0xC000FFFF, 0x0000FFFF);
 		REG_PATTERN_TEST(E1000_TDBAL, 0xFFFFFFF0, 0xFFFFFFFF);
 		REG_PATTERN_TEST(E1000_TIDV, 0x0000FFFF, 0x0000FFFF);
-		value = (adapter->hw.mac_type == e1000_ich8lan ?
-		         E1000_RAR_ENTRIES_ICH8LAN : E1000_RAR_ENTRIES);
-		for (i = 0; i < value; i++) {
+		for (i = 0; i < mac->rar_entry_count; i++) {
 			REG_PATTERN_TEST(E1000_RA + (((i << 1) + 1) << 2), 0x8003FFFF,
 			                 0xFFFFFFFF);
 		}
@@ -852,9 +850,7 @@ e1000_reg_test(struct e1000_adapter *adapter, uint64_t *data)
 
 	}
 
-	value = (adapter->hw.mac_type == e1000_ich8lan ?
-			E1000_MC_TBL_SIZE_ICH8LAN : E1000_MC_TBL_SIZE);
-	for (i = 0; i < value; i++)
+	for (i = 0; i < mac->mta_reg_count; i++)
 		REG_PATTERN_TEST(E1000_MTA + (i << 2), 0xFFFFFFFF, 0xFFFFFFFF);
 
 	*data = 0;
@@ -870,8 +866,8 @@ e1000_eeprom_test(struct e1000_adapter *adapter, uint64_t *data)
 
 	*data = 0;
 	/* Read and add up the contents of the EEPROM */
-	for (i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++) {
-		if ((e1000_read_eeprom(&adapter->hw, i, 1, &temp)) < 0) {
+	for (i = 0; i < (NVM_CHECKSUM_REG + 1); i++) {
+		if ((e1000_read_nvm(&adapter->hw, i, 1, &temp)) < 0) {
 			*data = 1;
 			break;
 		}
@@ -879,7 +875,7 @@ e1000_eeprom_test(struct e1000_adapter *adapter, uint64_t *data)
 	}
 
 	/* If Checksum is not Correct return error else test passed */
-	if ((checksum != (uint16_t) EEPROM_SUM) && !(*data))
+	if ((checksum != (u16) NVM_SUM) && !(*data))
 		*data = 2;
 
 	return *data;
@@ -925,7 +921,7 @@ e1000_intr_test(struct e1000_adapter *adapter, uint64_t *data)
 	/* Test each interrupt */
 	for (; i < 10; i++) {
 
-		if (adapter->hw.mac_type == e1000_ich8lan && i == 8)
+		if (adapter->hw.mac.type == e1000_ich8lan && i == 8)
 			continue;
 
 		/* Interrupt to test */
@@ -1137,7 +1133,7 @@ e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	E1000_WRITE_REG(&adapter->hw, E1000_RDT, 0);
 	rctl = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_SZ_2048 |
 		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
-		(adapter->hw.mc_filter_type << E1000_RCTL_MO_SHIFT);
+		(adapter->hw.mac.mc_filter_type << E1000_RCTL_MO_SHIFT);
 	E1000_WRITE_REG(&adapter->hw, E1000_RCTL, rctl);
 
 	for (i = 0; i < rxdr->count; i++) {
@@ -1227,7 +1223,7 @@ e1000_nonintegrated_phy_loopback(struct e1000_adapter *adapter)
 	e1000_write_phy_reg(&adapter->hw, M88E1000_PHY_SPEC_CTRL, phy_reg);
 
 	/* Perform software reset on the PHY */
-	e1000_phy_reset(&adapter->hw);
+	e1000_phy_commit(&adapter->hw);
 
 	/* Have to setup TX_CLK and TX_CRS after software reset */
 	e1000_phy_reset_clk_and_crs(adapter);
@@ -1273,9 +1269,9 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	uint32_t ctrl_reg = 0;
 	uint32_t stat_reg = 0;
 
-	adapter->hw.autoneg = FALSE;
+	adapter->hw.mac.autoneg = FALSE;
 
-	if (adapter->hw.phy_type == e1000_phy_m88) {
+	if (adapter->hw.phy.type == e1000_phy_m88) {
 		/* Auto-MDI/MDIX Off */
 		e1000_write_phy_reg(&adapter->hw,
 				    M88E1000_PHY_SPEC_CTRL, 0x0808);
@@ -1283,14 +1279,14 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 		e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, 0x9140);
 		/* autoneg off */
 		e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, 0x8140);
-	} else if (adapter->hw.phy_type == e1000_phy_gg82563)
+	} else if (adapter->hw.phy.type == e1000_phy_gg82563)
 		e1000_write_phy_reg(&adapter->hw,
 		                    GG82563_PHY_KMRN_MODE_CTRL,
 		                    0x1CC);
 
 	ctrl_reg = E1000_READ_REG(&adapter->hw, E1000_CTRL);
 
-	if (adapter->hw.phy_type == e1000_phy_ife) {
+	if (adapter->hw.phy.type == e1000_phy_ife) {
 		/* force 100, set loopback */
 		e1000_write_phy_reg(&adapter->hw, PHY_CONTROL, 0x6100);
 
@@ -1314,7 +1310,7 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	}
 
 	if (adapter->hw.media_type == e1000_media_type_copper &&
-	   adapter->hw.phy_type == e1000_phy_m88)
+	   adapter->hw.phy.type == e1000_phy_m88)
 		ctrl_reg |= E1000_CTRL_ILOS; /* Invert Loss of Signal */
 	else {
 		/* Set the ILOS bit on the fiber Nic is half
@@ -1329,7 +1325,7 @@ e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 	/* Disable the receiver on the PHY so when a cable is plugged in, the
 	 * PHY does not begin to autoneg when a cable is reconnected to the NIC.
 	 */
-	if (adapter->hw.phy_type == e1000_phy_m88)
+	if (adapter->hw.phy.type == e1000_phy_m88)
 		e1000_phy_disable_receiver(adapter);
 
 	udelay(500);
@@ -1343,7 +1339,7 @@ e1000_set_phy_loopback(struct e1000_adapter *adapter)
 	uint16_t phy_reg = 0;
 	uint16_t count = 0;
 
-	switch (adapter->hw.mac_type) {
+	switch (adapter->hw.mac.type) {
 	case e1000_82543:
 		if (adapter->hw.media_type == e1000_media_type_copper) {
 			/* Attempt to setup Loopback mode on Non-integrated PHY.
@@ -1397,7 +1393,7 @@ e1000_setup_loopback_test(struct e1000_adapter *adapter)
 
 	if (hw->media_type == e1000_media_type_fiber ||
 	    hw->media_type == e1000_media_type_internal_serdes) {
-		switch (hw->mac_type) {
+		switch (hw->mac.type) {
 		case e1000_82545:
 		case e1000_82546:
 		case e1000_82545_rev_3:
@@ -1435,7 +1431,7 @@ e1000_loopback_cleanup(struct e1000_adapter *adapter)
 	rctl &= ~(E1000_RCTL_LBM_TCVR | E1000_RCTL_LBM_MAC);
 	E1000_WRITE_REG(hw, E1000_RCTL, rctl);
 
-	switch (hw->mac_type) {
+	switch (hw->mac.type) {
 	case e1000_82571:
 	case e1000_82572:
 		if (hw->media_type == e1000_media_type_fiber ||
@@ -1451,8 +1447,8 @@ e1000_loopback_cleanup(struct e1000_adapter *adapter)
 	case e1000_82545_rev_3:
 	case e1000_82546_rev_3:
 	default:
-		hw->autoneg = TRUE;
-		if (hw->phy_type == e1000_phy_gg82563)
+		hw->mac.autoneg = TRUE;
+		if (hw->phy.type == e1000_phy_gg82563)
 			e1000_write_phy_reg(hw,
 					    GG82563_PHY_KMRN_MODE_CTRL,
 					    0x180);
@@ -1460,7 +1456,7 @@ e1000_loopback_cleanup(struct e1000_adapter *adapter)
 		if (phy_reg & MII_CR_LOOPBACK) {
 			phy_reg &= ~MII_CR_LOOPBACK;
 			e1000_write_phy_reg(hw, PHY_CONTROL, phy_reg);
-			e1000_phy_reset(hw);
+			e1000_phy_commit(hw);
 		}
 		break;
 	}
@@ -1559,7 +1555,7 @@ e1000_loopback_test(struct e1000_adapter *adapter, uint64_t *data)
 {
 	/* PHY loopback cannot be performed if SoL/IDER
 	 * sessions are active */
-	if (e1000_check_phy_reset_block(&adapter->hw)) {
+	if (e1000_check_reset_block(&adapter->hw)) {
 		DPRINTK(DRV, ERR, "Cannot do PHY loopback test "
 		        "when SoL/IDER is active.\n");
 		*data = 0;
@@ -1585,13 +1581,13 @@ e1000_link_test(struct e1000_adapter *adapter, uint64_t *data)
 	*data = 0;
 	if (adapter->hw.media_type == e1000_media_type_internal_serdes) {
 		int i = 0;
-		adapter->hw.serdes_link_down = TRUE;
+		adapter->hw.mac.serdes_has_link = FALSE;
 
 		/* On some blade server designs, link establishment
 		 * could take as long as 2-3 minutes */
 		do {
 			e1000_check_for_link(&adapter->hw);
-			if (adapter->hw.serdes_link_down == FALSE)
+			if (adapter->hw.mac.serdes_has_link == TRUE)
 				return *data;
 			msleep(20);
 		} while (i++ < 3750);
@@ -1599,7 +1595,7 @@ e1000_link_test(struct e1000_adapter *adapter, uint64_t *data)
 		*data = 1;
 	} else {
 		e1000_check_for_link(&adapter->hw);
-		if (adapter->hw.autoneg)  /* if auto_neg is set wait for it */
+		if (adapter->hw.mac.autoneg)  /* if auto_neg is set wait for it */
 			msleep(4000);
 
 		if (!(E1000_READ_REG(&adapter->hw, E1000_STATUS) & E1000_STATUS_LU)) {
@@ -1622,6 +1618,8 @@ e1000_diag_test(struct net_device *netdev,
 		   struct ethtool_test *eth_test, uint64_t *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	uint16_t autoneg_advertised;
+	uint8_t forced_speed_duplex, autoneg;
 	boolean_t if_running = netif_running(netdev);
 
 	set_bit(__E1000_TESTING, &adapter->flags);
@@ -1629,9 +1627,9 @@ e1000_diag_test(struct net_device *netdev,
 		/* Offline tests */
 
 		/* save speed, duplex, autoneg settings */
-		uint16_t autoneg_advertised = adapter->hw.autoneg_advertised;
-		uint8_t forced_speed_duplex = adapter->hw.forced_speed_duplex;
-		uint8_t autoneg = adapter->hw.autoneg;
+		autoneg_advertised = adapter->hw.phy.autoneg_advertised;
+		forced_speed_duplex = adapter->hw.mac.forced_speed_duplex;
+		autoneg = adapter->hw.mac.autoneg;
 
 		DPRINTK(HW, INFO, "offline testing starting\n");
 
@@ -1664,9 +1662,9 @@ e1000_diag_test(struct net_device *netdev,
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		/* restore speed, duplex, autoneg settings */
-		adapter->hw.autoneg_advertised = autoneg_advertised;
-		adapter->hw.forced_speed_duplex = forced_speed_duplex;
-		adapter->hw.autoneg = autoneg;
+		adapter->hw.phy.autoneg_advertised = autoneg_advertised;
+		adapter->hw.mac.forced_speed_duplex = forced_speed_duplex;
+		adapter->hw.mac.autoneg = autoneg;
 
 		e1000_reset(adapter);
 		clear_bit(__E1000_TESTING, &adapter->flags);
@@ -1853,7 +1851,7 @@ e1000_phys_id(struct net_device *netdev, uint32_t data)
 	if (!data || data > (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ))
 		data = (uint32_t)(MAX_SCHEDULE_TIMEOUT / HZ);
 
-	if (adapter->hw.mac_type < e1000_82571) {
+	if (adapter->hw.mac.type < e1000_82571) {
 		if (!adapter->blink_timer.function) {
 			init_timer(&adapter->blink_timer);
 			adapter->blink_timer.function = e1000_led_blink_callback;
@@ -1863,7 +1861,7 @@ e1000_phys_id(struct net_device *netdev, uint32_t data)
 		mod_timer(&adapter->blink_timer, jiffies);
 		msleep_interruptible(data * 1000);
 		del_timer_sync(&adapter->blink_timer);
-	} else if (adapter->hw.phy_type == e1000_phy_ife) {
+	} else if (adapter->hw.phy.type == e1000_phy_ife) {
 		if (!adapter->blink_timer.function) {
 			init_timer(&adapter->blink_timer);
 			adapter->blink_timer.function = e1000_led_blink_callback;
@@ -1874,7 +1872,7 @@ e1000_phys_id(struct net_device *netdev, uint32_t data)
 		del_timer_sync(&adapter->blink_timer);
 		e1000_write_phy_reg(&(adapter->hw), IFE_PHY_SPECIAL_CONTROL_LED, 0);
 	} else {
-		e1000_blink_led_start(&adapter->hw);
+		e1000_blink_led(&adapter->hw);
 		msleep_interruptible(data * 1000);
 	}
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 690d475..ecc41b7 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -304,7 +304,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 
 	flags = IRQF_SHARED;
 #ifdef CONFIG_PCI_MSI
-	if (adapter->hw.mac_type >= e1000_82571) {
+	if (adapter->hw.mac.type >= e1000_82571) {
 		adapter->have_msi = TRUE;
 		if ((err = pci_enable_msi(adapter->pdev))) {
 			DPRINTK(PROBE, ERR,
@@ -411,7 +411,7 @@ e1000_release_hw_control(struct e1000_adapter *adapter)
 	uint32_t swsm;
 
 	/* Let firmware taken over control of h/w */
-	switch (adapter->hw.mac_type) {
+	switch (adapter->hw.mac.type) {
 	case e1000_82573:
 		swsm = E1000_READ_REG(&adapter->hw, E1000_SWSM);
 		E1000_WRITE_REG(&adapter->hw, E1000_SWSM,
@@ -448,7 +448,7 @@ e1000_get_hw_control(struct e1000_adapter *adapter)
 	uint32_t swsm;
 
 	/* Let firmware know the driver has taken over */
-	switch (adapter->hw.mac_type) {
+	switch (adapter->hw.mac.type) {
 	case e1000_82573:
 		swsm = E1000_READ_REG(&adapter->hw, E1000_SWSM);
 		E1000_WRITE_REG(&adapter->hw, E1000_SWSM,
@@ -590,11 +590,11 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 	 * (a) WoL is enabled
 	 * (b) AMT is active
 	 * (c) SoL/IDER session is active */
-	if (!adapter->wol && adapter->hw.mac_type >= e1000_82540 &&
+	if (!adapter->wol && adapter->hw.mac.type >= e1000_82540 &&
 	   adapter->hw.media_type == e1000_media_type_copper) {
 		uint16_t mii_reg = 0;
 
-		switch (adapter->hw.mac_type) {
+		switch (adapter->hw.mac.type) {
 		case e1000_82540:
 		case e1000_82545:
 		case e1000_82545_rev_3:
@@ -614,7 +614,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 		case e1000_80003es2lan:
 		case e1000_ich8lan:
 			if (e1000_check_mng_mode(&adapter->hw) ||
-			    e1000_check_phy_reset_block(&adapter->hw))
+			    e1000_check_reset_block(&adapter->hw))
 				goto out;
 			break;
 		default:
@@ -672,6 +672,7 @@ e1000_reinit_locked(struct e1000_adapter *adapter)
 void
 e1000_reset(struct e1000_adapter *adapter)
 {
+	struct e1000_mac_info *mac = &adapter->hw.mac;
 	uint32_t pba = 0, tx_space, min_tx_space, min_rx_space;
 	uint16_t fc_high_water_mark = E1000_FC_HIGH_DIFF;
 	boolean_t legacy_pba_adjust = FALSE;
@@ -680,7 +681,7 @@ e1000_reset(struct e1000_adapter *adapter)
 	 * To take effect CTRL.RST is required.
 	 */
 
-	switch (adapter->hw.mac_type) {
+	switch (mac->type) {
 	case e1000_82542:
 	case e1000_82543:
 	case e1000_82544:
@@ -717,17 +718,17 @@ e1000_reset(struct e1000_adapter *adapter)
 	}
 
 	if (legacy_pba_adjust == TRUE) {
-		if (adapter->netdev->mtu > E1000_RXBUFFER_8192)
+		if (mac->max_frame_size > E1000_RXBUFFER_8192)
 			pba -= 8; /* allocate more FIFO for Tx */
 
-		if (adapter->hw.mac_type == e1000_82547) {
+		if (mac->type == e1000_82547) {
 			adapter->tx_fifo_head = 0;
 			adapter->tx_head_addr = pba << E1000_TX_HEAD_ADDR_SHIFT;
 			adapter->tx_fifo_size =
 				(E1000_PBA_40K - pba) << E1000_PBA_BYTES_SHIFT;
 			atomic_set(&adapter->tx_fifo_stall, 0);
 		}
-	} else if (adapter->hw.max_frame_size > MAXIMUM_ETHERNET_FRAME_SIZE) {
+	} else if (mac->max_frame_size > ETH_FRAME_LEN + ETHERNET_FCS_SIZE) {
 		/* adjust PBA for jumbo frames */
 		E1000_WRITE_REG(&adapter->hw, E1000_PBA, pba);
 
@@ -743,9 +744,8 @@ e1000_reset(struct e1000_adapter *adapter)
 		/* lower 16 bits has Rx packet buffer allocation size in KB */
 		pba &= 0xffff;
 		/* don't include ethernet FCS because hardware appends/strips */
-		min_rx_space = adapter->netdev->mtu + ENET_HEADER_SIZE +
-		               VLAN_TAG_SIZE;
-		min_tx_space = min_rx_space;
+		min_tx_space =
+		min_rx_space = mac->max_frame_size - ETHERNET_FCS_SIZE;
 		min_tx_space *= 2;
 		E1000_ROUNDUP(min_tx_space, 1024);
 		min_tx_space >>= 10;
@@ -760,7 +760,7 @@ e1000_reset(struct e1000_adapter *adapter)
 			pba = pba - (min_tx_space - tx_space);
 
 			/* PCI/PCIx hardware has PBA alignment constraints */
-			switch (adapter->hw.mac_type) {
+			switch (mac->type) {
 			case e1000_82545 ... e1000_82546_rev_3:
 				pba &= ~(E1000_PBA_8K - 1);
 				break;
@@ -771,7 +771,7 @@ e1000_reset(struct e1000_adapter *adapter)
 			/* if short on rx space, rx wins and must trump tx
 			 * adjustment or use Early Receive if available */
 			if (pba < min_rx_space) {
-				switch (adapter->hw.mac_type) {
+				switch (mac->type) {
 				case e1000_82573:
 					/* ERT enabled in e1000_configure_rx */
 					break;
@@ -796,18 +796,18 @@ e1000_reset(struct e1000_adapter *adapter)
 	if (pba < E1000_PBA_16K)
 		fc_high_water_mark = (pba * 1024) - 1600;
 
-	adapter->hw.fc_high_water = fc_high_water_mark;
-	adapter->hw.fc_low_water = fc_high_water_mark - 8;
-	if (adapter->hw.mac_type == e1000_80003es2lan)
-		adapter->hw.fc_pause_time = 0xFFFF;
+	mac->fc_high_water = fc_high_water_mark;
+	mac->fc_low_water = fc_high_water_mark - 8;
+	if (mac->type == e1000_80003es2lan)
+		mac->fc_pause_time = 0xFFFF;
 	else
-		adapter->hw.fc_pause_time = E1000_FC_PAUSE_TIME;
-	adapter->hw.fc_send_xon = 1;
-	adapter->hw.fc = adapter->hw.original_fc;
+		mac->fc_pause_time = E1000_FC_PAUSE_TIME;
+	mac->fc_send_xon = 1;
+	mac->fc = mac->original_fc;
 
 	/* Allow time for pending master requests to run */
 	e1000_reset_hw(&adapter->hw);
-	if (adapter->hw.mac_type >= e1000_82544)
+	if (mac->type >= e1000_82544)
 		E1000_WRITE_REG(&adapter->hw, E1000_WUC, 0);
 
 	if (e1000_init_hw(&adapter->hw))
@@ -815,10 +815,10 @@ e1000_reset(struct e1000_adapter *adapter)
 	e1000_update_mng_vlan(adapter);
 
 	/* if (adapter->hwflags & HWFLAGS_PHY_PWR_BIT) { */
-	if (adapter->hw.mac_type >= e1000_82544 &&
-	    adapter->hw.mac_type <= e1000_82547_rev_2 &&
-	    adapter->hw.autoneg == 1 &&
-	    adapter->hw.autoneg_advertised == ADVERTISE_1000_FULL) {
+	if (mac->type >= e1000_82544 &&
+	    mac->type <= e1000_82547_rev_2 &&
+	    mac->autoneg == 1 &&
+	    adapter->hw.phy.autoneg_advertised == ADVERTISE_1000_FULL) {
 		uint32_t ctrl = E1000_READ_REG(&adapter->hw, E1000_CTRL);
 		/* clear phy power management bit if we are in gig only mode,
 		 * which if enabled will attempt negotiation to 100Mb, which
@@ -831,11 +831,11 @@ e1000_reset(struct e1000_adapter *adapter)
 	E1000_WRITE_REG(&adapter->hw, E1000_VET, ETHERNET_IEEE_VLAN_TYPE);
 
 	e1000_reset_adaptive(&adapter->hw);
-	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
+	e1000_get_phy_info(&adapter->hw);
 
 	if (!adapter->smart_power_down &&
-	    (adapter->hw.mac_type == e1000_82571 ||
-	     adapter->hw.mac_type == e1000_82572)) {
+	    (mac->type == e1000_82571 ||
+	     mac->type == e1000_82572)) {
 		uint16_t phy_data = 0;
 		/* speed up time to link by disabling smart power down, ignore
 		 * the return value of this function because there is nothing
@@ -964,8 +964,8 @@ e1000_probe(struct pci_dev *pdev,
 
 	err = -EIO;
 	/* Flash BAR mapping must happen after e1000_sw_init
-	 * because it depends on mac_type */
-	if ((adapter->hw.mac_type == e1000_ich8lan) &&
+	 * because it depends on mac.type */
+	if ((adapter->hw.mac.type == e1000_ich8lan) &&
 	   (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
 		flash_start = pci_resource_start(pdev, 1);
 		flash_len = pci_resource_len(pdev, 1);
@@ -974,30 +974,48 @@ e1000_probe(struct pci_dev *pdev,
 			goto err_flashmap;
 	}
 
-	if (e1000_check_phy_reset_block(&adapter->hw))
+	if (e1000_check_reset_block(&adapter->hw))
 		DPRINTK(PROBE, INFO, "PHY reset is blocked due to SOL/IDER session.\n");
 
-	if (adapter->hw.mac_type >= e1000_82543) {
+	if (adapter->hw.mac.type >= e1000_82543) {
 		netdev->features = NETIF_F_SG |
 				   NETIF_F_HW_CSUM |
 				   NETIF_F_HW_VLAN_TX |
 				   NETIF_F_HW_VLAN_RX |
 				   NETIF_F_HW_VLAN_FILTER;
-		if (adapter->hw.mac_type == e1000_ich8lan)
+		if (adapter->hw.mac.type == e1000_ich8lan)
 			netdev->features &= ~NETIF_F_HW_VLAN_FILTER;
 	}
 
-	if ((adapter->hw.mac_type >= e1000_82544) &&
-	   (adapter->hw.mac_type != e1000_82547))
+	if ((adapter->hw.mac.type >= e1000_82544) &&
+	   (adapter->hw.mac.type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
 
-	if (adapter->hw.mac_type > e1000_82547_rev_2)
+	if (adapter->hw.mac.type > e1000_82547_rev_2)
 		netdev->features |= NETIF_F_TSO6;
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
 	netdev->features |= NETIF_F_LLTX;
 
+	/*
+	 * Hardware features that are incremental - IOW from chipset X and on,
+	 * all chipsets support this feature or have this workaround
+	 */
+	if (adapter->hw.mac.type >= e1000_82571)
+		adapter->has_manc2h = TRUE;
+
+	if (adapter->hw.mac.type >= e1000_82540)
+		adapter->has_smbus = TRUE;
+
+	if (adapter->hw.mac.type == e1000_82543)
+		adapter->bad_tx_carr_stats_fd = TRUE;
+
+	/* In rare occasions, ESB2 systems would end up started without
+	 * the RX unit being turned on. */
+	if (adapter->hw.mac.type == e1000_80003es2lan)
+		adapter->rx_needs_kicking = TRUE;
+
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
 	/* initialize eeprom parameters */
@@ -1007,27 +1025,29 @@ e1000_probe(struct pci_dev *pdev,
 		goto err_eeprom;
 	}
 
-	/* before reading the EEPROM, reset the controller to
+	/* before reading the NVM, reset the controller to
 	 * put the device in a known good starting state */
 
 	e1000_reset_hw(&adapter->hw);
 
-	/* make sure the EEPROM is good */
+	/* make sure the NVM is good */
 
-	if (e1000_validate_eeprom_checksum(&adapter->hw) < 0) {
-		DPRINTK(PROBE, ERR, "The EEPROM Checksum Is Not Valid\n");
+	if (e1000_validate_nvm_checksum(&adapter->hw) < 0) {
+		DPRINTK(PROBE, ERR, "The NVM Checksum Is Not Valid\n");
+		err = -EIO;
 		goto err_eeprom;
 	}
 
-	/* copy the MAC address out of the EEPROM */
+	/* copy the MAC address out of the NVM */
 
 	if (e1000_read_mac_addr(&adapter->hw))
-		DPRINTK(PROBE, ERR, "EEPROM Read Error\n");
-	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
-	memcpy(netdev->perm_addr, adapter->hw.mac_addr, netdev->addr_len);
+		DPRINTK(PROBE, ERR, "NVM Read Error\n");
+	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
+	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->perm_addr)) {
 		DPRINTK(PROBE, ERR, "Invalid MAC Address\n");
+		err = -EIO;
 		goto err_eeprom;
 	}
 
@@ -1054,33 +1074,33 @@ e1000_probe(struct pci_dev *pdev,
 	 * enable the ACPI Magic Packet filter
 	 */
 
-	switch (adapter->hw.mac_type) {
+	switch (adapter->hw.mac.type) {
 	case e1000_82542:
 	case e1000_82543:
 		break;
 	case e1000_82544:
-		e1000_read_eeprom(&adapter->hw,
-			EEPROM_INIT_CONTROL2_REG, 1, &eeprom_data);
+		e1000_read_nvm(&adapter->hw,
+			NVM_INIT_CONTROL2_REG, 1, &eeprom_data);
 		eeprom_apme_mask = E1000_EEPROM_82544_APM;
 		break;
 	case e1000_ich8lan:
-		e1000_read_eeprom(&adapter->hw,
-			EEPROM_INIT_CONTROL1_REG, 1, &eeprom_data);
+		e1000_read_nvm(&adapter->hw,
+			NVM_INIT_CONTROL1_REG, 1, &eeprom_data);
 		eeprom_apme_mask = E1000_EEPROM_ICH8_APME;
 		break;
 	case e1000_82546:
 	case e1000_82546_rev_3:
 	case e1000_82571:
 	case e1000_80003es2lan:
-		if (E1000_READ_REG(&adapter->hw, E1000_STATUS) & E1000_STATUS_FUNC_1){
-			e1000_read_eeprom(&adapter->hw,
-				EEPROM_INIT_CONTROL3_PORT_B, 1, &eeprom_data);
+		if (adapter->hw.bus.func == 1) {
+			e1000_read_nvm(&adapter->hw,
+				NVM_INIT_CONTROL3_PORT_B, 1, &eeprom_data);
 			break;
 		}
 		/* Fall Through */
 	default:
-		e1000_read_eeprom(&adapter->hw,
-			EEPROM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
+		e1000_read_nvm(&adapter->hw,
+			NVM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
 		break;
 	}
 	if (eeprom_data & eeprom_apme_mask)
@@ -1122,16 +1142,16 @@ e1000_probe(struct pci_dev *pdev,
 	{
 	struct e1000_hw *hw = &adapter->hw;
 	DPRINTK(PROBE, INFO, "(PCI%s:%s:%s) ",
-		((hw->bus_type == e1000_bus_type_pcix) ? "-X" :
-		 (hw->bus_type == e1000_bus_type_pci_express ? " Express":"")),
-		((hw->bus_speed == e1000_bus_speed_2500) ? "2.5Gb/s" :
-		 (hw->bus_speed == e1000_bus_speed_133) ? "133MHz" :
-		 (hw->bus_speed == e1000_bus_speed_120) ? "120MHz" :
-		 (hw->bus_speed == e1000_bus_speed_100) ? "100MHz" :
-		 (hw->bus_speed == e1000_bus_speed_66) ? "66MHz" : "33MHz"),
-		((hw->bus_width == e1000_bus_width_64) ? "64-bit" :
-		 (hw->bus_width == e1000_bus_width_pcie_x4) ? "Width x4" :
-		 (hw->bus_width == e1000_bus_width_pcie_x1) ? "Width x1" :
+		((hw->bus.type == e1000_bus_type_pcix) ? "-X" :
+		 (hw->bus.type == e1000_bus_type_pci_express ? " Express":"")),
+		((hw->bus.speed == e1000_bus_speed_2500) ? "2.5Gb/s" :
+		 (hw->bus.speed == e1000_bus_speed_133) ? "133MHz" :
+		 (hw->bus.speed == e1000_bus_speed_120) ? "120MHz" :
+		 (hw->bus.speed == e1000_bus_speed_100) ? "100MHz" :
+		 (hw->bus.speed == e1000_bus_speed_66) ? "66MHz" : "33MHz"),
+		((hw->bus.width == e1000_bus_width_64) ? "64-bit" :
+		 (hw->bus.width == e1000_bus_width_pcie_x4) ? "Width x4" :
+		 (hw->bus.width == e1000_bus_width_pcie_x1) ? "Width x1" :
 		 "32-bit"));
 	}
 
@@ -1145,7 +1165,7 @@ e1000_probe(struct pci_dev *pdev,
 	 * DRV_LOAD until the interface is up.  For all other cases,
 	 * let the f/w know that the h/w is now under the control
 	 * of the driver. */
-	if (adapter->hw.mac_type != e1000_82573 ||
+	if (adapter->hw.mac.type != e1000_82573 ||
 	    !e1000_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
@@ -1165,7 +1185,7 @@ e1000_probe(struct pci_dev *pdev,
 err_register:
 	e1000_release_hw_control(adapter);
 err_eeprom:
-	if (!e1000_check_phy_reset_block(&adapter->hw))
+	if (!e1000_check_reset_block(&adapter->hw))
 		e1000_phy_hw_reset(&adapter->hw);
 
 	if (adapter->hw.flash_address)
@@ -1226,7 +1246,7 @@ e1000_remove(struct pci_dev *pdev)
 		dev_put(&adapter->polling_netdev[i]);
 #endif
 
-	if (!e1000_check_phy_reset_block(&adapter->hw))
+	if (!e1000_check_reset_block(&adapter->hw))
 		e1000_phy_hw_reset(&adapter->hw);
 
 	kfree(adapter->tx_ring);
@@ -1269,17 +1289,16 @@ e1000_sw_init(struct e1000_adapter *adapter)
 	hw->vendor_id = pdev->vendor;
 	hw->device_id = pdev->device;
 	hw->subsystem_vendor_id = pdev->subsystem_vendor;
-	hw->subsystem_id = pdev->subsystem_device;
+	hw->subsystem_device_id = pdev->subsystem_device;
 
 	pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
 
-	pci_read_config_word(pdev, PCI_COMMAND, &hw->pci_cmd_word);
+	pci_read_config_word(pdev, PCI_COMMAND, &hw->bus.pci_cmd_word);
 
 	adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 	adapter->rx_ps_bsize0 = E1000_RXBUFFER_128;
-	hw->max_frame_size = netdev->mtu +
-			     ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
-	hw->min_frame_size = MINIMUM_ETHERNET_FRAME_SIZE;
+	hw->mac.max_frame_size = netdev->mtu + ETH_HLEN + ETHERNET_FCS_SIZE;
+	hw->mac.min_frame_size = ETH_ZLEN + ETHERNET_FCS_SIZE;
 
 	/* identify the MAC */
 
@@ -1421,7 +1440,7 @@ e1000_open(struct net_device *netdev)
 
 	/* If AMT is enabled, let the firmware know that the network
 	 * interface is now open */
-	if (adapter->hw.mac_type == e1000_82573 &&
+	if (adapter->hw.mac.type == e1000_82573 &&
 	    e1000_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
@@ -1497,7 +1516,7 @@ e1000_close(struct net_device *netdev)
 
 	/* If AMT is enabled, let the firmware know that the network
 	 * interface is now closed */
-	if (adapter->hw.mac_type == e1000_82573 &&
+	if (adapter->hw.mac.type == e1000_82573 &&
 	    e1000_check_mng_mode(&adapter->hw))
 		e1000_release_hw_control(adapter);
 
@@ -1519,8 +1538,8 @@ e1000_check_64k_bound(struct e1000_adapter *adapter,
 
 	/* First rev 82545 and 82546 need to not allow any memory
 	 * write location to cross 64k boundary due to errata 23 */
-	if (adapter->hw.mac_type == e1000_82545 ||
-	    adapter->hw.mac_type == e1000_82546) {
+	if (adapter->hw.mac.type == e1000_82545 ||
+	    adapter->hw.mac.type == e1000_82546) {
 		return ((begin ^ (end - 1)) >> 16) != 0 ? FALSE : TRUE;
 	}
 
@@ -1665,14 +1684,14 @@ e1000_configure_tx(struct e1000_adapter *adapter)
 	}
 
 	/* Set the default values for the Tx Inter Packet Gap timer */
-	if (adapter->hw.mac_type <= e1000_82547_rev_2 &&
+	if (adapter->hw.mac.type <= e1000_82547_rev_2 &&
 	    (hw->media_type == e1000_media_type_fiber ||
 	     hw->media_type == e1000_media_type_internal_serdes))
 		tipg = DEFAULT_82543_TIPG_IPGT_FIBER;
 	else
 		tipg = DEFAULT_82543_TIPG_IPGT_COPPER;
 
-	switch (hw->mac_type) {
+	switch (hw->mac.type) {
 	case e1000_82542:
 		tipg = DEFAULT_82542_TIPG_IPGT;
 		ipgr1 = DEFAULT_82542_TIPG_IPGR1;
@@ -1694,7 +1713,7 @@ e1000_configure_tx(struct e1000_adapter *adapter)
 	/* Set the Tx Interrupt Delay register */
 
 	E1000_WRITE_REG(hw, E1000_TIDV, adapter->tx_int_delay);
-	if (hw->mac_type >= e1000_82540)
+	if (hw->mac.type >= e1000_82540)
 		E1000_WRITE_REG(hw, E1000_TADV, adapter->tx_abs_int_delay);
 
 	/* Program the Transmit Control Register */
@@ -1704,13 +1723,13 @@ e1000_configure_tx(struct e1000_adapter *adapter)
 	tctl |= E1000_TCTL_PSP | E1000_TCTL_RTLC |
 		(E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT);
 
-	if (hw->mac_type == e1000_82571 || hw->mac_type == e1000_82572) {
+	if (hw->mac.type == e1000_82571 || hw->mac.type == e1000_82572) {
 		tarc = E1000_READ_REG(hw, E1000_TARC0);
 		/* set the speed mode bit, we'll clear it if we're not at
 		 * gigabit link later */
 		tarc |= (1 << 21);
 		E1000_WRITE_REG(hw, E1000_TARC0, tarc);
-	} else if (hw->mac_type == e1000_80003es2lan) {
+	} else if (hw->mac.type == e1000_80003es2lan) {
 		tarc = E1000_READ_REG(hw, E1000_TARC0);
 		tarc |= 1;
 		E1000_WRITE_REG(hw, E1000_TARC0, tarc);
@@ -1728,15 +1747,15 @@ e1000_configure_tx(struct e1000_adapter *adapter)
 	if (adapter->tx_int_delay)
 		adapter->txd_cmd |= E1000_TXD_CMD_IDE;
 
-	if (hw->mac_type < e1000_82543)
+	if (hw->mac.type < e1000_82543)
 		adapter->txd_cmd |= E1000_TXD_CMD_RPS;
 	else
 		adapter->txd_cmd |= E1000_TXD_CMD_RS;
 
 	/* Cache if we're 82544 running in PCI-X because we'll
 	 * need this to apply a workaround later in the send path. */
-	if (hw->mac_type == e1000_82544 &&
-	    hw->bus_type == e1000_bus_type_pcix)
+	if (hw->mac.type == e1000_82544 &&
+	    hw->bus.type == e1000_bus_type_pcix)
 		adapter->pcix_82544 = 1;
 
 	E1000_WRITE_REG(hw, E1000_TCTL, tctl);
@@ -1787,7 +1806,7 @@ e1000_setup_rx_resources(struct e1000_adapter *adapter,
 		return -ENOMEM;
 	}
 
-	if (adapter->hw.mac_type <= e1000_82547_rev_2)
+	if (adapter->hw.mac.type <= e1000_82547_rev_2)
 		desc_len = sizeof(struct e1000_rx_desc);
 	else
 		desc_len = sizeof(union e1000_rx_desc_packet_split);
@@ -1897,7 +1916,7 @@ e1000_setup_rctl(struct e1000_adapter *adapter)
 
 	rctl |= E1000_RCTL_EN | E1000_RCTL_BAM |
 		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
-		(adapter->hw.mc_filter_type << E1000_RCTL_MO_SHIFT);
+		(adapter->hw.mac.mc_filter_type << E1000_RCTL_MO_SHIFT);
 
 	if (adapter->hw.tbi_compatibility_on == 1)
 		rctl |= E1000_RCTL_SBP;
@@ -1952,7 +1971,7 @@ e1000_setup_rctl(struct e1000_adapter *adapter)
 	/* allocations using alloc_page take too long for regular MTU
 	 * so only enable packet split for jumbo frames */
 	pages = PAGE_USE_COUNT(adapter->netdev->mtu);
-	if ((adapter->hw.mac_type >= e1000_82571) && (pages <= 3) &&
+	if ((adapter->hw.mac.type >= e1000_82571) && (pages <= 3) &&
 	    PAGE_SIZE <= 16384 && (rctl & E1000_RCTL_LPE))
 		adapter->rx_ps_pages = pages;
 	else
@@ -2027,14 +2046,14 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 	/* set the Receive Delay Timer Register */
 	E1000_WRITE_REG(hw, E1000_RDTR, adapter->rx_int_delay);
 
-	if (hw->mac_type >= e1000_82540) {
+	if (hw->mac.type >= e1000_82540) {
 		E1000_WRITE_REG(hw, E1000_RADV, adapter->rx_abs_int_delay);
 		if (adapter->itr_setting != 0)
 			E1000_WRITE_REG(hw, E1000_ITR,
 				1000000000 / (adapter->itr * 256));
 	}
 
-	if (hw->mac_type >= e1000_82571) {
+	if (hw->mac.type >= e1000_82571) {
 		ctrl_ext = E1000_READ_REG(hw, E1000_CTRL_EXT);
 		/* Reset delay timers after every interrupt */
 		ctrl_ext |= E1000_CTRL_EXT_INT_TIMER_CLR;
@@ -2064,14 +2083,14 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 	}
 
 	/* Enable 82543 Receive Checksum Offload for TCP and UDP */
-	if (hw->mac_type >= e1000_82543) {
+	if (hw->mac.type >= e1000_82543) {
 		rxcsum = E1000_READ_REG(hw, E1000_RXCSUM);
 		if (adapter->rx_csum == TRUE) {
 			rxcsum |= E1000_RXCSUM_TUOFL;
 
 			/* Enable 82571 IPv4 payload checksum for UDP fragments
 			 * Must be used in conjunction with packet-split. */
-			if ((hw->mac_type >= e1000_82571) &&
+			if ((hw->mac.type >= e1000_82571) &&
 			    (adapter->rx_ps_pages)) {
 				rxcsum |= E1000_RXCSUM_IPPCSE;
 			}
@@ -2085,7 +2104,7 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 	/* enable early receives on 82573, only takes effect if using > 2048
 	 * byte total frame size.  for example only for jumbo frames */
 #define E1000_ERT_2048 0x100
-	if (hw->mac_type == e1000_82573)
+	if (hw->mac.type == e1000_82573)
 		E1000_WRITE_REG(hw, E1000_ERT, E1000_ERT_2048);
 
 	/* Enable Receives */
@@ -2327,6 +2346,11 @@ e1000_enter_82542_rst(struct e1000_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	uint32_t rctl;
 
+	if (adapter->hw.mac.type != e1000_82542)
+		return;
+	if (adapter->hw.revision_id != E1000_REVISION_2)
+		return;
+
 	e1000_pci_clear_mwi(&adapter->hw);
 
 	rctl = E1000_READ_REG(&adapter->hw, E1000_RCTL);
@@ -2345,13 +2369,18 @@ e1000_leave_82542_rst(struct e1000_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	uint32_t rctl;
 
+	if (adapter->hw.mac.type != e1000_82542)
+		return;
+	if (adapter->hw.revision_id != E1000_REVISION_2)
+		return;
+
 	rctl = E1000_READ_REG(&adapter->hw, E1000_RCTL);
 	rctl &= ~E1000_RCTL_RST;
 	E1000_WRITE_REG(&adapter->hw, E1000_RCTL, rctl);
 	E1000_WRITE_FLUSH(&adapter->hw);
 	mdelay(5);
 
-	if (adapter->hw.pci_cmd_word & PCI_COMMAND_INVALIDATE)
+	if (adapter->hw.bus.pci_cmd_word & PCI_COMMAND_INVALIDATE)
 		e1000_pci_set_mwi(&adapter->hw);
 
 	if (netif_running(netdev)) {
@@ -2381,19 +2410,19 @@ e1000_set_mac(struct net_device *netdev, void *p)
 
 	/* 82542 2.0 needs to be in reset to write receive address registers */
 
-	if (adapter->hw.mac_type == e1000_82542)
+	if (adapter->hw.mac.type == e1000_82542)
 		e1000_enter_82542_rst(adapter);
 
 	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
+	memcpy(adapter->hw.mac.addr, addr->sa_data, netdev->addr_len);
 
-	e1000_rar_set(&adapter->hw, adapter->hw.mac_addr, 0);
+	e1000_rar_set(&adapter->hw, adapter->hw.mac.addr, 0);
 
 	/* With 82571 controllers, LAA may be overwritten (with the default)
 	 * due to controller reset from the other port. */
-	if (adapter->hw.mac_type == e1000_82571) {
+	if (adapter->hw.mac.type == e1000_82571) {
 		/* activate the work around */
-		adapter->hw.laa_is_present = 1;
+		e1000_set_laa_state_82571(&adapter->hw, TRUE);
 
 		/* Hold a copy of the LAA in RAR[14] This is done so that
 		 * between the time RAR[0] gets clobbered  and the time it
@@ -2401,11 +2430,12 @@ e1000_set_mac(struct net_device *netdev, void *p)
 		 * of the RARs and no incoming packets directed to this port
 		 * are dropped. Eventaully the LAA will be in RAR[0] and
 		 * RAR[14] */
-		e1000_rar_set(&adapter->hw, adapter->hw.mac_addr,
-					E1000_RAR_ENTRIES - 1);
+		e1000_rar_set(&adapter->hw,
+		              adapter->hw.mac.addr,
+		              adapter->hw.mac.rar_entry_count - 1);
 	}
 
-	if (adapter->hw.mac_type == e1000_82542)
+	if (adapter->hw.mac.type == e1000_82542)
 		e1000_leave_82542_rst(adapter);
 
 	return 0;
@@ -2426,6 +2456,7 @@ e1000_set_multi(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	struct e1000_mac_info *mac = &hw->mac;
 	struct dev_mc_list *mc_ptr;
 	uint32_t rctl;
 	uint32_t hash_value;
@@ -2434,11 +2465,11 @@ e1000_set_multi(struct net_device *netdev)
 				E1000_NUM_MTA_REGISTERS_ICH8LAN :
 				E1000_NUM_MTA_REGISTERS;
 
-	if (adapter->hw.mac_type == e1000_ich8lan)
+	if (adapter->hw.mac.type == e1000_ich8lan)
 		rar_entries = E1000_RAR_ENTRIES_ICH8LAN;
 
 	/* reserve RAR[14] for LAA over-write work-around */
-	if (adapter->hw.mac_type == e1000_82571)
+	if (adapter->hw.mac.type == e1000_82571)
 		rar_entries--;
 
 	/* Check for Promiscuous and All Multicast modes */
@@ -2458,7 +2489,7 @@ e1000_set_multi(struct net_device *netdev)
 
 	/* 82542 2.0 needs to be in reset to write receive address registers */
 
-	if (hw->mac_type == e1000_82542)
+	if (hw->mac.type == e1000_82542)
 		e1000_enter_82542_rst(adapter);
 
 	/* load the first 14 multicast address into the exact filters 1-14
@@ -2505,7 +2536,7 @@ static void
 e1000_update_phy_info(unsigned long data)
 {
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
-	e1000_phy_get_info(&adapter->hw, &adapter->phy_info);
+	e1000_get_phy_info(&adapter->hw);
 }
 
 /**
@@ -2560,19 +2591,20 @@ e1000_watchdog(unsigned long data)
 	struct e1000_adapter *adapter = (struct e1000_adapter *) data;
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
+	struct e1000_mac_info *mac = &adapter->hw.mac;
 	uint32_t link, tctl;
 	int32_t ret_val;
 
 	ret_val = e1000_check_for_link(&adapter->hw);
 	if ((ret_val == E1000_ERR_PHY) &&
-	    (adapter->hw.phy_type == e1000_phy_igp_3) &&
+	    (adapter->hw.phy.type == e1000_phy_igp_3) &&
 	    (E1000_READ_REG(&adapter->hw, E1000_CTRL) & E1000_PHY_CTRL_GBE_DISABLE)) {
-		/* See e1000_kumeran_lock_loss_workaround() */
+		/* See e1000_kmrn_lock_loss_workaround_ich8lan() */
 		DPRINTK(LINK, INFO,
 			"Gigabit has been disabled, downgrading speed\n");
 	}
 
-	if (adapter->hw.mac_type == e1000_82573) {
+	if (mac->type == e1000_82573) {
 		e1000_enable_tx_pkt_filtering(&adapter->hw);
 		if (adapter->mng_vlan_id != adapter->hw.mng_cookie.vlan_id)
 			e1000_update_mng_vlan(adapter);
@@ -2580,7 +2612,7 @@ e1000_watchdog(unsigned long data)
 
 	if ((adapter->hw.media_type == e1000_media_type_internal_serdes) &&
 	   !(E1000_READ_REG(&adapter->hw, E1000_TXCW) & E1000_TXCW_ANE))
-		link = !adapter->hw.serdes_link_down;
+		link = adapter->hw.mac.serdes_has_link;
 	else
 		link = E1000_READ_REG(&adapter->hw, E1000_STATUS) & E1000_STATUS_LU;
 
@@ -2620,8 +2652,8 @@ e1000_watchdog(unsigned long data)
 				break;
 			}
 
-			if ((adapter->hw.mac_type == e1000_82571 ||
-			     adapter->hw.mac_type == e1000_82572) &&
+			if ((mac->type == e1000_82571 ||
+			     mac->type == e1000_82572) &&
 			    txb2b == 0) {
 				uint32_t tarc0;
 				tarc0 = E1000_READ_REG(&adapter->hw, E1000_TARC0);
@@ -2632,7 +2664,7 @@ e1000_watchdog(unsigned long data)
 			/* disable TSO for pcie and 10/100 speeds, to avoid
 			 * some hardware issues */
 			if (!adapter->tso_force &&
-			    adapter->hw.bus_type == e1000_bus_type_pci_express){
+			    adapter->hw.bus.type == e1000_bus_type_pci_express){
 				switch (adapter->link_speed) {
 				case SPEED_10:
 				case SPEED_100:
@@ -2663,7 +2695,7 @@ e1000_watchdog(unsigned long data)
 			adapter->smartspeed = 0;
 		} else {
 			/* make sure the receive unit is started */
-			if (adapter->hw.rx_needs_kicking) {
+			if (adapter->rx_needs_kicking) {
 				struct e1000_hw *hw = &adapter->hw;
 				uint32_t rctl = E1000_READ_REG(hw, E1000_RCTL);
 				E1000_WRITE_REG(hw, E1000_RCTL, rctl | E1000_RCTL_EN);
@@ -2683,7 +2715,7 @@ e1000_watchdog(unsigned long data)
 			 * disable receives in the ISR and
 			 * reset device here in the watchdog
 			 */
-			if (adapter->hw.mac_type == e1000_80003es2lan)
+			if (adapter->hw.mac.type == e1000_80003es2lan)
 				/* reset device */
 				schedule_work(&adapter->reset_task);
 		}
@@ -2693,9 +2725,9 @@ e1000_watchdog(unsigned long data)
 
 	e1000_update_stats(adapter);
 
-	adapter->hw.tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
+	mac->tx_packet_delta = adapter->stats.tpt - adapter->tpt_old;
 	adapter->tpt_old = adapter->stats.tpt;
-	adapter->hw.collision_delta = adapter->stats.colc - adapter->colc_old;
+	mac->collision_delta = adapter->stats.colc - adapter->colc_old;
 	adapter->colc_old = adapter->stats.colc;
 
 	adapter->gorcl = adapter->stats.gorcl - adapter->gorcl_old;
@@ -2724,8 +2756,8 @@ e1000_watchdog(unsigned long data)
 
 	/* With 82571 controllers, LAA may be overwritten due to controller
 	 * reset from the other port. Set the appropriate LAA in RAR[0] */
-	if (adapter->hw.mac_type == e1000_82571 && adapter->hw.laa_is_present)
-		e1000_rar_set(&adapter->hw, adapter->hw.mac_addr, 0);
+	if (e1000_get_laa_state_82571(&adapter->hw) == TRUE)
+		e1000_rar_set(&adapter->hw, adapter->hw.mac.addr, 0);
 
 	/* Reset the timer */
 	mod_timer(&adapter->watchdog_timer, round_jiffies(jiffies + 2 * HZ));
@@ -2762,7 +2794,7 @@ static unsigned int e1000_update_itr(struct e1000_adapter *adapter,
 	unsigned int retval = itr_setting;
 	struct e1000_hw *hw = &adapter->hw;
 
-	if (unlikely(hw->mac_type < e1000_82540))
+	if (unlikely(hw->mac.type < e1000_82540))
 		goto update_itr_done;
 
 	if (packets == 0)
@@ -2810,7 +2842,7 @@ static void e1000_set_itr(struct e1000_adapter *adapter)
 	uint16_t current_itr;
 	uint32_t new_itr = adapter->itr;
 
-	if (unlikely(hw->mac_type < e1000_82540))
+	if (unlikely(hw->mac.type < e1000_82540))
 		return;
 
 	/* for non-gigabit speeds, just fix the interrupt rate at 4000 */
@@ -3024,7 +3056,7 @@ e1000_tx_map(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 		 * The fix is to make sure that the first descriptor of a
 		 * packet is smaller than 2048 - 16 - 16 (or 2016) bytes
 		 */
-		if (unlikely((adapter->hw.bus_type == e1000_bus_type_pcix) &&
+		if (unlikely((adapter->hw.bus.type == e1000_bus_type_pcix) &&
 		                (size > 2015) && count == 0))
 		        size = 2015;
 
@@ -3285,7 +3317,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	/* 82571 and newer doesn't need the workaround that limited descriptor
 	 * length to 4kB */
-	if (adapter->hw.mac_type >= e1000_82571)
+	if (adapter->hw.mac.type >= e1000_82571)
 		max_per_txd = 8192;
 
 	mss = skb_shinfo(skb)->gso_size;
@@ -3305,7 +3337,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		* frags into skb->data */
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
 		if (skb->data_len && (hdr_len == (skb->len - skb->data_len))) {
-			switch (adapter->hw.mac_type) {
+			switch (adapter->hw.mac.type) {
 				unsigned int pull_size;
 			case e1000_82544:
 				/* Make sure we have room to chop off 4 bytes,
@@ -3354,7 +3386,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	/* work-around for errata 10 and it applies to all controllers
 	 * in PCI-X mode, so add one more descriptor to the count
 	 */
-	if (unlikely((adapter->hw.bus_type == e1000_bus_type_pcix) &&
+	if (unlikely((adapter->hw.bus.type == e1000_bus_type_pcix) &&
 			(len > 2015)))
 		count++;
 
@@ -3366,8 +3398,8 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		count += nr_frags;
 
 
-	if (adapter->hw.tx_pkt_filtering &&
-	    (adapter->hw.mac_type == e1000_82573))
+	if (adapter->hw.mac.tx_pkt_filtering &&
+	    (adapter->hw.mac.type == e1000_82573))
 		e1000_transfer_dhcp_info(adapter, skb);
 
 	if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
@@ -3381,7 +3413,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_BUSY;
 	}
 
-	if (unlikely(adapter->hw.mac_type == e1000_82547)) {
+	if (unlikely(adapter->hw.mac.type == e1000_82547)) {
 		if (unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies + 1);
@@ -3482,20 +3514,21 @@ static int
 e1000_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	int max_frame = new_mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
+	int max_frame = new_mtu + ETH_HLEN + ETHERNET_FCS_SIZE;
 	uint16_t eeprom_data = 0;
 
-	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
+	if ((max_frame < ETH_ZLEN + ETHERNET_FCS_SIZE) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
 		DPRINTK(PROBE, ERR, "Invalid MTU setting\n");
 		return -EINVAL;
 	}
 
 	/* Adapter-specific max frame size limits. */
-	switch (adapter->hw.mac_type) {
-	case e1000_undefined ... e1000_82542_rev2_1:
+	switch (adapter->hw.mac.type) {
+	case e1000_undefined:
+	case e1000_82542:
 	case e1000_ich8lan:
-		if (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
+		if (max_frame > ETH_FRAME_LEN + ETHERNET_FCS_SIZE) {
 			DPRINTK(PROBE, ERR, "Jumbo Frames not supported.\n");
 			return -EINVAL;
 		}
@@ -3504,11 +3537,10 @@ e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		/* Jumbo Frames not supported if:
 		 * - this is not an 82573L device
 		 * - ASPM is enabled in any way (0x1A bits 3:2) */
-		e1000_read_eeprom(&adapter->hw, EEPROM_INIT_3GIO_3, 1,
-		                  &eeprom_data);
+		e1000_read_nvm(&adapter->hw, NVM_INIT_3GIO_3, 1, &eeprom_data);
 		if ((adapter->hw.device_id != E1000_DEV_ID_82573L) ||
-		    (eeprom_data & EEPROM_WORD1A_ASPM_MASK)) {
-			if (max_frame > MAXIMUM_ETHERNET_FRAME_SIZE) {
+		    (eeprom_data & NVM_WORD1A_ASPM_MASK)) {
+			if (max_frame > ETH_FRAME_LEN + ETHERNET_FCS_SIZE) {
 				DPRINTK(PROBE, ERR,
 			            	"Jumbo Frames not supported.\n");
 				return -EINVAL;
@@ -3553,13 +3585,13 @@ e1000_change_mtu(struct net_device *netdev, int new_mtu)
 		adapter->rx_buffer_len = E1000_RXBUFFER_16384;
 
 	/* adjust allocation if LPE protects us, and we aren't using SBP */
-	if (!adapter->hw.tbi_compatibility_on &&
-	    ((max_frame == MAXIMUM_ETHERNET_FRAME_SIZE) ||
+	if (!e1000_tbi_sbp_enabled_82543(&adapter->hw) &&
+	    ((max_frame == ETH_FRAME_LEN + ETHERNET_FCS_SIZE) ||
 	     (max_frame == MAXIMUM_ETHERNET_VLAN_SIZE)))
 		adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 
 	netdev->mtu = new_mtu;
-	adapter->hw.max_frame_size = max_frame;
+	adapter->hw.mac.max_frame_size = max_frame;
 
 	if (netif_running(netdev))
 		e1000_reinit_locked(adapter);
@@ -3606,7 +3638,7 @@ e1000_update_stats(struct e1000_adapter *adapter)
 	adapter->stats.mprc += E1000_READ_REG(hw, E1000_MPRC);
 	adapter->stats.roc += E1000_READ_REG(hw, E1000_ROC);
 
-	if (adapter->hw.mac_type != e1000_ich8lan) {
+	if (adapter->hw.mac.type != e1000_ich8lan) {
 		adapter->stats.prc64 += E1000_READ_REG(hw, E1000_PRC64);
 		adapter->stats.prc127 += E1000_READ_REG(hw, E1000_PRC127);
 		adapter->stats.prc255 += E1000_READ_REG(hw, E1000_PRC255);
@@ -3642,7 +3674,7 @@ e1000_update_stats(struct e1000_adapter *adapter)
 	adapter->stats.toth += E1000_READ_REG(hw, E1000_TOTH);
 	adapter->stats.tpr += E1000_READ_REG(hw, E1000_TPR);
 
-	if (adapter->hw.mac_type != e1000_ich8lan) {
+	if (adapter->hw.mac.type != e1000_ich8lan) {
 		adapter->stats.ptc64 += E1000_READ_REG(hw, E1000_PTC64);
 		adapter->stats.ptc127 += E1000_READ_REG(hw, E1000_PTC127);
 		adapter->stats.ptc255 += E1000_READ_REG(hw, E1000_PTC255);
@@ -3656,12 +3688,12 @@ e1000_update_stats(struct e1000_adapter *adapter)
 
 	/* used for adaptive IFS */
 
-	hw->tx_packet_delta = E1000_READ_REG(hw, E1000_TPT);
-	adapter->stats.tpt += hw->tx_packet_delta;
-	hw->collision_delta = E1000_READ_REG(hw, E1000_COLC);
-	adapter->stats.colc += hw->collision_delta;
+	hw->mac.tx_packet_delta = E1000_READ_REG(hw, E1000_TPT);
+	adapter->stats.tpt += hw->mac.tx_packet_delta;
+	hw->mac.collision_delta = E1000_READ_REG(hw, E1000_COLC);
+	adapter->stats.colc += hw->mac.collision_delta;
 
-	if (hw->mac_type >= e1000_82543) {
+	if (hw->mac.type >= e1000_82543) {
 		adapter->stats.algnerrc += E1000_READ_REG(hw, E1000_ALGNERRC);
 		adapter->stats.rxerrc += E1000_READ_REG(hw, E1000_RXERRC);
 		adapter->stats.tncrs += E1000_READ_REG(hw, E1000_TNCRS);
@@ -3669,11 +3701,11 @@ e1000_update_stats(struct e1000_adapter *adapter)
 		adapter->stats.tsctc += E1000_READ_REG(hw, E1000_TSCTC);
 		adapter->stats.tsctfc += E1000_READ_REG(hw, E1000_TSCTFC);
 	}
-	if (hw->mac_type > e1000_82547_rev_2) {
+	if (hw->mac.type > e1000_82547_rev_2) {
 		adapter->stats.iac += E1000_READ_REG(hw, E1000_IAC);
 		adapter->stats.icrxoc += E1000_READ_REG(hw, E1000_ICRXOC);
 
-		if (adapter->hw.mac_type != e1000_ich8lan) {
+		if (adapter->hw.mac.type != e1000_ich8lan) {
 			adapter->stats.icrxptc += E1000_READ_REG(hw, E1000_ICRXPTC);
 			adapter->stats.icrxatc += E1000_READ_REG(hw, E1000_ICRXATC);
 			adapter->stats.ictxptc += E1000_READ_REG(hw, E1000_ICTXPTC);
@@ -3712,7 +3744,7 @@ e1000_update_stats(struct e1000_adapter *adapter)
 	adapter->net_stats.tx_aborted_errors = adapter->stats.ecol;
 	adapter->net_stats.tx_window_errors = adapter->stats.latecol;
 	adapter->net_stats.tx_carrier_errors = adapter->stats.tncrs;
-	if (adapter->hw.bad_tx_carr_stats_fd &&
+	if (adapter->bad_tx_carr_stats_fd &&
 	    adapter->link_duplex == FULL_DUPLEX) {
 		adapter->net_stats.tx_carrier_errors = 0;
 		adapter->stats.tncrs = 0;
@@ -3728,14 +3760,14 @@ e1000_update_stats(struct e1000_adapter *adapter)
 			adapter->phy_stats.idle_errors += phy_tmp;
 		}
 
-		if ((hw->mac_type <= e1000_82546) &&
-		   (hw->phy_type == e1000_phy_m88) &&
+		if ((hw->mac.type <= e1000_82546) &&
+		   (hw->phy.type == e1000_phy_m88) &&
 		   !e1000_read_phy_reg(hw, M88E1000_RX_ERR_CNTR, &phy_tmp))
 			adapter->phy_stats.receive_errors += phy_tmp;
 	}
 
 	/* Management Stats */
-	if (adapter->hw.has_smbus) {
+	if (adapter->has_smbus) {
 		adapter->stats.mgptc += E1000_READ_REG(hw, E1000_MGTPTC);
 		adapter->stats.mgprc += E1000_READ_REG(hw, E1000_MGTPRC);
 		adapter->stats.mgpdc += E1000_READ_REG(hw, E1000_MGTPDC);
@@ -3768,12 +3800,12 @@ e1000_intr_msi(int irq, void *data)
 	atomic_inc(&adapter->irq_sem);
 #endif
 	if (icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC)) {
-		hw->get_link_status = 1;
+		hw->mac.get_link_status = 1;
 		/* 80003ES2LAN workaround-- For packet buffer work-around on
 		 * link down event; disable receives here in the ISR and reset
 		 * adapter in watchdog */
 		if (netif_carrier_ok(netdev) &&
-		    (adapter->hw.mac_type == e1000_80003es2lan)) {
+		    (hw->mac.type == e1000_80003es2lan)) {
 			/* disable receives */
 			uint32_t rctl = E1000_READ_REG(hw, E1000_RCTL);
 			E1000_WRITE_REG(hw, E1000_RCTL, rctl & ~E1000_RCTL_EN);
@@ -3833,7 +3865,7 @@ e1000_intr(int irq, void *data)
 #ifdef CONFIG_E1000_NAPI
 	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
 	 * not set, then the adapter didn't send an interrupt */
-	if (unlikely(hw->mac_type >= e1000_82571 &&
+	if (unlikely(hw->mac.type >= e1000_82571 &&
 	             !(icr & E1000_ICR_INT_ASSERTED)))
 		return IRQ_NONE;
 
@@ -3841,19 +3873,19 @@ e1000_intr(int irq, void *data)
 	 * interrupts are masked.  No need for the
 	 * IMC write, but it does mean we should
 	 * account for it ASAP. */
-	if (likely(hw->mac_type >= e1000_82571))
+	if (likely(hw->mac.type >= e1000_82571))
 		atomic_inc(&adapter->irq_sem);
 #endif
 
 	if (unlikely(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC))) {
-		hw->get_link_status = 1;
+		hw->mac.get_link_status = 1;
 		/* 80003ES2LAN workaround--
 		 * For packet buffer work-around on link down event;
 		 * disable receives here in the ISR and
 		 * reset adapter in watchdog
 		 */
 		if (netif_carrier_ok(netdev) &&
-		    (adapter->hw.mac_type == e1000_80003es2lan)) {
+		    (hw->mac.type == e1000_80003es2lan)) {
 			/* disable receives */
 			rctl = E1000_READ_REG(hw, E1000_RCTL);
 			E1000_WRITE_REG(hw, E1000_RCTL, rctl & ~E1000_RCTL_EN);
@@ -3864,7 +3896,7 @@ e1000_intr(int irq, void *data)
 	}
 
 #ifdef CONFIG_E1000_NAPI
-	if (unlikely(hw->mac_type < e1000_82571)) {
+	if (unlikely(hw->mac.type < e1000_82571)) {
 		/* disable interrupts, without the synchronize_irq bit */
 		atomic_inc(&adapter->irq_sem);
 		E1000_WRITE_REG(hw, E1000_IMC, ~0);
@@ -3891,7 +3923,7 @@ e1000_intr(int irq, void *data)
 	 * in dead lock. Writing IMC forces 82547 into
 	 * de-assertion state.
 	 */
-	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2) {
+	if (hw->mac.type == e1000_82547 || hw->mac.type == e1000_82547_rev_2) {
 		atomic_inc(&adapter->irq_sem);
 		E1000_WRITE_REG(hw, E1000_IMC, ~0);
 	}
@@ -3909,7 +3941,7 @@ e1000_intr(int irq, void *data)
 	if (likely(adapter->itr_setting & 3))
 		e1000_set_itr(adapter);
 
-	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
+	if (hw->mac.type == e1000_82547 || hw->mac.type == e1000_82547_rev_2)
 		e1000_irq_enable(adapter);
 
 #endif
@@ -4097,7 +4129,7 @@ e1000_rx_checksum(struct e1000_adapter *adapter,
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/* 82543 or newer only */
-	if (unlikely(adapter->hw.mac_type < e1000_82543)) return;
+	if (unlikely(adapter->hw.mac.type < e1000_82543)) return;
 	/* Ignore Checksum bit is set */
 	if (unlikely(status & E1000_RXD_STAT_IXSM)) return;
 	/* TCP/UDP checksum error bit is set */
@@ -4107,7 +4139,7 @@ e1000_rx_checksum(struct e1000_adapter *adapter,
 		return;
 	}
 	/* TCP/UDP Checksum has not been calculated */
-	if (adapter->hw.mac_type <= e1000_82547_rev_2) {
+	if (adapter->hw.mac.type <= e1000_82547_rev_2) {
 		if (!(status & E1000_RXD_STAT_TCPCS))
 			return;
 	} else {
@@ -4118,7 +4150,7 @@ e1000_rx_checksum(struct e1000_adapter *adapter,
 	if (likely(status & E1000_RXD_STAT_TCPCS)) {
 		/* TCP checksum is good */
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
-	} else if (adapter->hw.mac_type > e1000_82547_rev_2) {
+	} else if (adapter->hw.mac.type > e1000_82547_rev_2) {
 		/* IP fragment with UDP payload */
 		/* Hardware complements the payload checksum, so we undo it
 		 * and then put the value in host order for further stack use.
@@ -4205,9 +4237,9 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			if (TBI_ACCEPT(&adapter->hw, status,
 			              rx_desc->errors, length, last_byte)) {
 				spin_lock_irqsave(&adapter->stats_lock, flags);
-				e1000_tbi_adjust_stats(&adapter->hw,
-				                       &adapter->stats,
-				                       length, skb->data);
+				e1000_tbi_adjust_stats_82543(&adapter->hw,
+				                             &adapter->stats,
+				                             length, skb->data);
 				spin_unlock_irqrestore(&adapter->stats_lock,
 				                       flags);
 				length--;
@@ -4702,11 +4734,13 @@ no_buffers:
 static void
 e1000_smartspeed(struct e1000_adapter *adapter)
 {
+	struct e1000_mac_info *mac = &adapter->hw.mac;
+	struct e1000_phy_info *phy = &adapter->hw.phy;
 	uint16_t phy_status;
 	uint16_t phy_ctrl;
 
-	if ((adapter->hw.phy_type != e1000_phy_igp) || !adapter->hw.autoneg ||
-	   !(adapter->hw.autoneg_advertised & ADVERTISE_1000_FULL))
+	if ((phy->type != e1000_phy_igp) || !mac->autoneg ||
+	    !(phy->autoneg_advertised & ADVERTISE_1000_FULL))
 		return;
 
 	if (adapter->smartspeed == 0) {
@@ -4791,7 +4825,7 @@ e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 
 	switch (cmd) {
 	case SIOCGMIIPHY:
-		data->phy_id = adapter->hw.phy_addr;
+		data->phy_id = adapter->hw.phy.addr;
 		break;
 	case SIOCGMIIREG:
 		if (!capable(CAP_NET_ADMIN))
@@ -4850,7 +4884,7 @@ e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 				break;
 			case M88E1000_PHY_SPEC_CTRL:
 			case M88E1000_EXT_PHY_SPEC_CTRL:
-				if (e1000_phy_reset(&adapter->hw)) {
+				if (e1000_phy_hw_reset(&adapter->hw)) {
 					spin_unlock_irqrestore(
 						&adapter->stats_lock, flags);
 					return -EIO;
@@ -4914,7 +4948,7 @@ e1000_write_pci_cfg(struct e1000_hw *hw, uint32_t reg, uint16_t *value)
 int32_t
 e1000_read_pcie_cap_reg(struct e1000_hw *hw, uint32_t reg, uint16_t *value)
 {
-    struct e1000_adapter *adapter = hw->back;
+struct e1000_adapter *adapter = hw->back;
     uint16_t cap_offset;
 
     cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
@@ -4947,7 +4981,7 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		ctrl |= E1000_CTRL_VME;
 		E1000_WRITE_REG(&adapter->hw, E1000_CTRL, ctrl);
 
-		if (adapter->hw.mac_type != e1000_ich8lan) {
+		if (adapter->hw.mac.type != e1000_ich8lan) {
 			/* enable VLAN receive filtering */
 			rctl = E1000_READ_REG(&adapter->hw, E1000_RCTL);
 			rctl |= E1000_RCTL_VFE;
@@ -4961,7 +4995,7 @@ e1000_vlan_rx_register(struct net_device *netdev, struct vlan_group *grp)
 		ctrl &= ~E1000_CTRL_VME;
 		E1000_WRITE_REG(&adapter->hw, E1000_CTRL, ctrl);
 
-		if (adapter->hw.mac_type != e1000_ich8lan) {
+		if (adapter->hw.mac.type != e1000_ich8lan) {
 			/* disable VLAN filtering */
 			rctl = E1000_READ_REG(&adapter->hw, E1000_RCTL);
 			rctl &= ~E1000_RCTL_VFE;
@@ -5038,7 +5072,9 @@ e1000_restore_vlan(struct e1000_adapter *adapter)
 int
 e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx)
 {
-	adapter->hw.autoneg = 0;
+	struct e1000_mac_info *mac = &adapter->hw.mac;
+
+	mac->autoneg = 0;
 
 	/* Fiber NICs only allow 1000 gbps Full duplex */
 	if ((adapter->hw.media_type == e1000_media_type_fiber) &&
@@ -5049,20 +5085,20 @@ e1000_set_spd_dplx(struct e1000_adapter *adapter, uint16_t spddplx)
 
 	switch (spddplx) {
 	case SPEED_10 + DUPLEX_HALF:
-		adapter->hw.forced_speed_duplex = ADVERTISE_10_HALF;
+		mac->forced_speed_duplex = ADVERTISE_10_HALF;
 		break;
 	case SPEED_10 + DUPLEX_FULL:
-		adapter->hw.forced_speed_duplex = ADVERTISE_10_FULL;
+		mac->forced_speed_duplex = ADVERTISE_10_FULL;
 		break;
 	case SPEED_100 + DUPLEX_HALF:
-		adapter->hw.forced_speed_duplex = ADVERTISE_100_HALF;
+		mac->forced_speed_duplex = ADVERTISE_100_HALF;
 		break;
 	case SPEED_100 + DUPLEX_FULL:
-		adapter->hw.forced_speed_duplex = ADVERTISE_100_FULL;
+		mac->forced_speed_duplex = ADVERTISE_100_FULL;
 		break;
 	case SPEED_1000 + DUPLEX_FULL:
-		adapter->hw.autoneg = 1;
-		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
+		mac->autoneg = 1;
+		adapter->hw.phy.autoneg_advertised = ADVERTISE_1000_FULL;
 		break;
 	case SPEED_1000 + DUPLEX_HALF: /* not supported */
 	default:
@@ -5111,7 +5147,7 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 			E1000_WRITE_REG(&adapter->hw, E1000_RCTL, rctl);
 		}
 
-		if (adapter->hw.mac_type >= e1000_82540) {
+		if (adapter->hw.mac.type >= e1000_82540) {
 			ctrl = E1000_READ_REG(&adapter->hw, E1000_CTRL);
 			/* advertise wake from D3Cold */
 			#define E1000_CTRL_ADVD3WUC 0x00100000
@@ -5131,7 +5167,7 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 		}
 
 		/* Allow time for pending master requests to run */
-		e1000_disable_pciex_master(&adapter->hw);
+		e1000_disable_pcie_master(&adapter->hw);
 
 		E1000_WRITE_REG(&adapter->hw, E1000_WUC, E1000_WUC_PME_EN);
 		E1000_WRITE_REG(&adapter->hw, E1000_WUFC, wufc);
@@ -5152,8 +5188,8 @@ e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 		pci_enable_wake(pdev, PCI_D3cold, 1);
 	}
 
-	if (adapter->hw.phy_type == e1000_phy_igp_3)
-		e1000_phy_powerdown_workaround(&adapter->hw);
+	if (adapter->hw.phy.type == e1000_phy_igp_3)
+		e1000_igp3_phy_powerdown_workaround_ich8lan(&adapter->hw);
 
 	if (netif_running(netdev))
 		e1000_free_irq(adapter);
@@ -5206,7 +5242,7 @@ e1000_resume(struct pci_dev *pdev)
 	 * DRV_LOAD until the interface is up.  For all other cases,
 	 * let the f/w know that the h/w is now under the control
 	 * of the driver. */
-	if (adapter->hw.mac_type != e1000_82573 ||
+	if (adapter->hw.mac.type != e1000_82573 ||
 	    !e1000_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
@@ -5318,7 +5354,7 @@ static void e1000_io_resume(struct pci_dev *pdev)
 	 * DRV_LOAD until the interface is up.  For all other cases,
 	 * let the f/w know that the h/w is now under the control
 	 * of the driver. */
-	if (adapter->hw.mac_type != e1000_82573 ||
+	if (adapter->hw.mac.type != e1000_82573 ||
 	    !e1000_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
diff --git a/drivers/net/e1000/e1000_param.c b/drivers/net/e1000/e1000_param.c
index e01c993..eaedf29 100644
--- a/drivers/net/e1000/e1000_param.c
+++ b/drivers/net/e1000/e1000_param.c
@@ -280,6 +280,7 @@ static void e1000_check_copper_options(struct e1000_adapter *adapter);
 void __devinit
 e1000_check_options(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	int bd = adapter->bd_number;
 	if (bd >= E1000_MAX_NIC) {
 		DPRINTK(PROBE, NOTICE,
@@ -298,8 +299,7 @@ e1000_check_options(struct e1000_adapter *adapter)
 		};
 		struct e1000_tx_ring *tx_ring = adapter->tx_ring;
 		int i;
-		e1000_mac_type mac_type = adapter->hw.mac_type;
-		opt.arg.r.max = mac_type < e1000_82544 ?
+		opt.arg.r.max = hw->mac.type < e1000_82544 ?
 			E1000_MAX_TXD : E1000_MAX_82544_TXD;
 
 		if (num_TxDescriptors > bd) {
@@ -324,8 +324,7 @@ e1000_check_options(struct e1000_adapter *adapter)
 		};
 		struct e1000_rx_ring *rx_ring = adapter->rx_ring;
 		int i;
-		e1000_mac_type mac_type = adapter->hw.mac_type;
-		opt.arg.r.max = mac_type < e1000_82544 ? E1000_MAX_RXD :
+		opt.arg.r.max = hw->mac.type < e1000_82544 ? E1000_MAX_RXD :
 			E1000_MAX_82544_RXD;
 
 		if (num_RxDescriptors > bd) {
@@ -376,9 +375,11 @@ e1000_check_options(struct e1000_adapter *adapter)
 		if (num_FlowControl > bd) {
 			int fc = FlowControl[bd];
 			e1000_validate_option(&fc, &opt, adapter);
-			adapter->hw.fc = adapter->hw.original_fc = fc;
+			hw->mac.original_fc = fc;
+			hw->mac.fc = fc;
 		} else {
-			adapter->hw.fc = adapter->hw.original_fc = opt.def;
+			hw->mac.original_fc = opt.def;
+			hw->mac.fc = opt.def;
 		}
 	}
 	{ /* Transmit Interrupt Delay */
@@ -524,13 +525,17 @@ e1000_check_options(struct e1000_adapter *adapter)
 		if (num_KumeranLockLoss > bd) {
 			int kmrn_lock_loss = KumeranLockLoss[bd];
 			e1000_validate_option(&kmrn_lock_loss, &opt, adapter);
-			adapter->hw.kmrn_lock_loss_workaround_disabled = !kmrn_lock_loss;
+			if (hw->mac.type == e1000_ich8lan)
+				e1000_set_kmrn_lock_loss_workaround_ich8lan(hw,
+				                                kmrn_lock_loss);
 		} else {
-			adapter->hw.kmrn_lock_loss_workaround_disabled = !opt.def;
+			if (hw->mac.type == e1000_ich8lan)
+				e1000_set_kmrn_lock_loss_workaround_ich8lan(hw,
+				                                       opt.def);
 		}
 	}
 
-	switch (adapter->hw.media_type) {
+	switch (hw->media_type) {
 	case e1000_media_type_fiber:
 	case e1000_media_type_internal_serdes:
 		e1000_check_fiber_options(adapter);
@@ -581,6 +586,7 @@ e1000_check_fiber_options(struct e1000_adapter *adapter)
 static void __devinit
 e1000_check_copper_options(struct e1000_adapter *adapter)
 {
+	struct e1000_hw *hw = &adapter->hw;
 	int speed, dplx, an;
 	int bd = adapter->bd_number;
 
@@ -620,7 +626,7 @@ e1000_check_copper_options(struct e1000_adapter *adapter)
 					 .p = dplx_list }}
 		};
 
-		if (e1000_check_phy_reset_block(&adapter->hw)) {
+		if (e1000_check_reset_block(hw)) {
 			DPRINTK(PROBE, INFO,
 				"Link active due to SoL/IDER Session. "
 			        "Speed/Duplex/AutoNeg parameter ignored.\n");
@@ -638,7 +644,7 @@ e1000_check_copper_options(struct e1000_adapter *adapter)
 		DPRINTK(PROBE, INFO,
 		       "AutoNeg specified along with Speed or Duplex, "
 		       "parameter ignored\n");
-		adapter->hw.autoneg_advertised = AUTONEG_ADV_DEFAULT;
+		hw->phy.autoneg_advertised = AUTONEG_ADV_DEFAULT;
 	} else { /* Autoneg */
 		struct e1000_opt_list an_list[] =
 			#define AA "AutoNeg advertising "
@@ -689,12 +695,12 @@ e1000_check_copper_options(struct e1000_adapter *adapter)
 		} else {
 			an = opt.def;
 		}
-		adapter->hw.autoneg_advertised = an;
+		hw->phy.autoneg_advertised = an;
 	}
 
 	switch (speed + dplx) {
 	case 0:
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
+		hw->mac.autoneg = adapter->fc_autoneg = 1;
 		if ((num_Speed > bd) && (speed != 0 || dplx != 0))
 			DPRINTK(PROBE, INFO,
 			       "Speed and duplex autonegotiation enabled\n");
@@ -703,59 +709,59 @@ e1000_check_copper_options(struct e1000_adapter *adapter)
 		DPRINTK(PROBE, INFO, "Half Duplex specified without Speed\n");
 		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
 			"Half Duplex only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
-		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
-		                                 ADVERTISE_100_HALF;
+		hw->mac.autoneg = adapter->fc_autoneg = 1;
+		hw->phy.autoneg_advertised = ADVERTISE_10_HALF |
+		                             ADVERTISE_100_HALF;
 		break;
 	case FULL_DUPLEX:
 		DPRINTK(PROBE, INFO, "Full Duplex specified without Speed\n");
 		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
 			"Full Duplex only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
-		adapter->hw.autoneg_advertised = ADVERTISE_10_FULL |
-		                                 ADVERTISE_100_FULL |
-		                                 ADVERTISE_1000_FULL;
+		hw->mac.autoneg = adapter->fc_autoneg = 1;
+		hw->phy.autoneg_advertised = ADVERTISE_10_FULL |
+		                             ADVERTISE_100_FULL |
+		                             ADVERTISE_1000_FULL;
 		break;
 	case SPEED_10:
 		DPRINTK(PROBE, INFO, "10 Mbps Speed specified "
 			"without Duplex\n");
 		DPRINTK(PROBE, INFO, "Using Autonegotiation at 10 Mbps only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
-		adapter->hw.autoneg_advertised = ADVERTISE_10_HALF |
-		                                 ADVERTISE_10_FULL;
+		hw->mac.autoneg = adapter->fc_autoneg = 1;
+		hw->phy.autoneg_advertised = ADVERTISE_10_HALF |
+		                             ADVERTISE_10_FULL;
 		break;
 	case SPEED_10 + HALF_DUPLEX:
 		DPRINTK(PROBE, INFO, "Forcing to 10 Mbps Half Duplex\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 0;
-		adapter->hw.forced_speed_duplex = ADVERTISE_10_HALF;
-		adapter->hw.autoneg_advertised = 0;
+		hw->mac.autoneg = adapter->fc_autoneg = 0;
+		hw->mac.forced_speed_duplex = ADVERTISE_10_HALF;
+		hw->phy.autoneg_advertised = 0;
 		break;
 	case SPEED_10 + FULL_DUPLEX:
 		DPRINTK(PROBE, INFO, "Forcing to 10 Mbps Full Duplex\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 0;
-		adapter->hw.forced_speed_duplex = ADVERTISE_10_FULL;
-		adapter->hw.autoneg_advertised = 0;
+		hw->mac.autoneg = adapter->fc_autoneg = 0;
+		hw->mac.forced_speed_duplex = ADVERTISE_10_FULL;
+		hw->phy.autoneg_advertised = 0;
 		break;
 	case SPEED_100:
 		DPRINTK(PROBE, INFO, "100 Mbps Speed specified "
 			"without Duplex\n");
 		DPRINTK(PROBE, INFO, "Using Autonegotiation at "
 			"100 Mbps only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
-		adapter->hw.autoneg_advertised = ADVERTISE_100_HALF |
-		                                 ADVERTISE_100_FULL;
+		hw->mac.autoneg = adapter->fc_autoneg = 1;
+		hw->phy.autoneg_advertised = ADVERTISE_100_HALF |
+		                             ADVERTISE_100_FULL;
 		break;
 	case SPEED_100 + HALF_DUPLEX:
 		DPRINTK(PROBE, INFO, "Forcing to 100 Mbps Half Duplex\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 0;
-		adapter->hw.forced_speed_duplex = ADVERTISE_100_HALF;
-		adapter->hw.autoneg_advertised = 0;
+		hw->mac.autoneg = adapter->fc_autoneg = 0;
+		hw->mac.forced_speed_duplex = ADVERTISE_100_HALF;
+		hw->phy.autoneg_advertised = 0;
 		break;
 	case SPEED_100 + FULL_DUPLEX:
 		DPRINTK(PROBE, INFO, "Forcing to 100 Mbps Full Duplex\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 0;
-		adapter->hw.forced_speed_duplex = ADVERTISE_100_FULL;
-		adapter->hw.autoneg_advertised = 0;
+		hw->mac.autoneg = adapter->fc_autoneg = 0;
+		hw->mac.forced_speed_duplex = ADVERTISE_100_FULL;
+		hw->phy.autoneg_advertised = 0;
 		break;
 	case SPEED_1000:
 		DPRINTK(PROBE, INFO, "1000 Mbps Speed specified without "
@@ -769,8 +775,8 @@ e1000_check_copper_options(struct e1000_adapter *adapter)
 full_duplex_only:
 		DPRINTK(PROBE, INFO,
 		       "Using Autonegotiation at 1000 Mbps Full Duplex only\n");
-		adapter->hw.autoneg = adapter->fc_autoneg = 1;
-		adapter->hw.autoneg_advertised = ADVERTISE_1000_FULL;
+		hw->mac.autoneg = adapter->fc_autoneg = 1;
+		hw->phy.autoneg_advertised = ADVERTISE_1000_FULL;
 		break;
 	default:
 		BUG();
