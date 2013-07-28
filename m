From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/12] e1000e: ethtool unnecessarily takes device out of RPM suspend
Date: Sun, 28 Jul 2013 04:41:13 -0700
Message-ID: <1375011676-30739-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50676 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753441Ab3G1Lla (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jul 2013 07:41:30 -0400
In-Reply-To: <1375011676-30739-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

A previous patch (commit e60b22c5b7 e1000e: fix accessing to suspended
device) added .begin and .complete ethtool driver callbacks so that the
device was resumed from Runtime Power Management (RPM) suspend state for
all ethtool operations.  This is overkill for operations which do not need
to access any registers in the device.  This patch makes it so that the
device is taken out of RPM suspend only for those ethtool operations that
must access device registers.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ethtool.c | 105 ++++++++++++++++++++--------
 1 file changed, 77 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 59c22bf..e4ebd7d 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -173,7 +173,7 @@ static int e1000_get_settings(struct net_device *netdev,
 			speed = adapter->link_speed;
 			ecmd->duplex = adapter->link_duplex - 1;
 		}
-	} else {
+	} else if (!pm_runtime_suspended(netdev->dev.parent)) {
 		u32 status = er32(STATUS);
 		if (status & E1000_STATUS_LU) {
 			if (status & E1000_STATUS_SPEED_1000)
@@ -264,6 +264,9 @@ static int e1000_set_settings(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	int ret_val = 0;
+
+	pm_runtime_get_sync(netdev->dev.parent);
 
 	/* When SoL/IDER sessions are active, autoneg/speed/duplex
 	 * cannot be changed
@@ -271,7 +274,8 @@ static int e1000_set_settings(struct net_device *netdev,
 	if (hw->phy.ops.check_reset_block &&
 	    hw->phy.ops.check_reset_block(hw)) {
 		e_err("Cannot change link characteristics when SoL/IDER is active.\n");
-		return -EINVAL;
+		ret_val = -EINVAL;
+		goto out;
 	}
 
 	/* MDI setting is only allowed when autoneg enabled because
@@ -279,13 +283,16 @@ static int e1000_set_settings(struct net_device *netdev,
 	 * duplex is forced.
 	 */
 	if (ecmd->eth_tp_mdix_ctrl) {
-		if (hw->phy.media_type != e1000_media_type_copper)
-			return -EOPNOTSUPP;
+		if (hw->phy.media_type != e1000_media_type_copper) {
+			ret_val = -EOPNOTSUPP;
+			goto out;
+		}
 
 		if ((ecmd->eth_tp_mdix_ctrl != ETH_TP_MDI_AUTO) &&
 		    (ecmd->autoneg != AUTONEG_ENABLE)) {
 			e_err("forcing MDI/MDI-X state is not supported when link speed and/or duplex are forced\n");
-			return -EINVAL;
+			ret_val = -EINVAL;
+			goto out;
 		}
 	}
 
@@ -307,8 +314,8 @@ static int e1000_set_settings(struct net_device *netdev,
 		u32 speed = ethtool_cmd_speed(ecmd);
 		/* calling this overrides forced MDI setting */
 		if (e1000_set_spd_dplx(adapter, speed, ecmd->duplex)) {
-			clear_bit(__E1000_RESETTING, &adapter->state);
-			return -EINVAL;
+			ret_val = -EINVAL;
+			goto out;
 		}
 	}
 
@@ -331,8 +338,10 @@ static int e1000_set_settings(struct net_device *netdev,
 		e1000e_reset(adapter);
 	}
 
+out:
+	pm_runtime_put_sync(netdev->dev.parent);
 	clear_bit(__E1000_RESETTING, &adapter->state);
-	return 0;
+	return ret_val;
 }
 
 static void e1000_get_pauseparam(struct net_device *netdev,
@@ -366,6 +375,8 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 	while (test_and_set_bit(__E1000_RESETTING, &adapter->state))
 		usleep_range(1000, 2000);
 
+	pm_runtime_get_sync(netdev->dev.parent);
+
 	if (adapter->fc_autoneg == AUTONEG_ENABLE) {
 		hw->fc.requested_mode = e1000_fc_default;
 		if (netif_running(adapter->netdev)) {
@@ -398,6 +409,7 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 	}
 
 out:
+	pm_runtime_put_sync(netdev->dev.parent);
 	clear_bit(__E1000_RESETTING, &adapter->state);
 	return retval;
 }
@@ -428,6 +440,8 @@ static void e1000_get_regs(struct net_device *netdev,
 	u32 *regs_buff = p;
 	u16 phy_data;
 
+	pm_runtime_get_sync(netdev->dev.parent);
+
 	memset(p, 0, E1000_REGS_LEN * sizeof(u32));
 
 	regs->version = (1 << 24) | (adapter->pdev->revision << 16) |
@@ -472,6 +486,8 @@ static void e1000_get_regs(struct net_device *netdev,
 	e1e_rphy(hw, MII_STAT1000, &phy_data);
 	regs_buff[24] = (u32)phy_data;	/* phy local receiver status */
 	regs_buff[25] = regs_buff[24];	/* phy remote receiver status */
+
+	pm_runtime_put_sync(netdev->dev.parent);
 }
 
 static int e1000_get_eeprom_len(struct net_device *netdev)
@@ -504,6 +520,8 @@ static int e1000_get_eeprom(struct net_device *netdev,
 	if (!eeprom_buff)
 		return -ENOMEM;
 
+	pm_runtime_get_sync(netdev->dev.parent);
+
 	if (hw->nvm.type == e1000_nvm_eeprom_spi) {
 		ret_val = e1000_read_nvm(hw, first_word,
 					 last_word - first_word + 1,
@@ -517,6 +535,8 @@ static int e1000_get_eeprom(struct net_device *netdev,
 		}
 	}
 
+	pm_runtime_put_sync(netdev->dev.parent);
+
 	if (ret_val) {
 		/* a read error occurred, throw away the result */
 		memset(eeprom_buff, 0xff, sizeof(u16) *
@@ -566,6 +586,8 @@ static int e1000_set_eeprom(struct net_device *netdev,
 
 	ptr = (void *)eeprom_buff;
 
+	pm_runtime_get_sync(netdev->dev.parent);
+
 	if (eeprom->offset & 1) {
 		/* need read/modify/write of first changed EEPROM word */
 		/* only the second byte of the word is being modified */
@@ -606,6 +628,7 @@ static int e1000_set_eeprom(struct net_device *netdev,
 		ret_val = e1000e_update_nvm_checksum(hw);
 
 out:
+	pm_runtime_put_sync(netdev->dev.parent);
 	kfree(eeprom_buff);
 	return ret_val;
 }
@@ -701,6 +724,8 @@ static int e1000_set_ringparam(struct net_device *netdev,
 		}
 	}
 
+	pm_runtime_get_sync(netdev->dev.parent);
+
 	e1000e_down(adapter);
 
 	/* We can't just free everything and then setup again, because the
@@ -739,6 +764,7 @@ err_setup_rx:
 		e1000e_free_tx_resources(temp_tx);
 err_setup:
 	e1000e_up(adapter);
+	pm_runtime_put_sync(netdev->dev.parent);
 free_temp:
 	vfree(temp_tx);
 	vfree(temp_rx);
@@ -1732,6 +1758,8 @@ static void e1000_diag_test(struct net_device *netdev,
 	u8 autoneg;
 	bool if_running = netif_running(netdev);
 
+	pm_runtime_get_sync(netdev->dev.parent);
+
 	set_bit(__E1000_TESTING, &adapter->state);
 
 	if (!if_running) {
@@ -1817,6 +1845,8 @@ static void e1000_diag_test(struct net_device *netdev,
 	}
 
 	msleep_interruptible(4 * 1000);
+
+	pm_runtime_put_sync(netdev->dev.parent);
 }
 
 static void e1000_get_wol(struct net_device *netdev,
@@ -1891,6 +1921,8 @@ static int e1000_set_phys_id(struct net_device *netdev,
 
 	switch (state) {
 	case ETHTOOL_ID_ACTIVE:
+		pm_runtime_get_sync(netdev->dev.parent);
+
 		if (!hw->mac.ops.blink_led)
 			return 2;	/* cycle on/off twice per second */
 
@@ -1902,6 +1934,7 @@ static int e1000_set_phys_id(struct net_device *netdev,
 			e1e_wphy(hw, IFE_PHY_SPECIAL_CONTROL_LED, 0);
 		hw->mac.ops.led_off(hw);
 		hw->mac.ops.cleanup_led(hw);
+		pm_runtime_put_sync(netdev->dev.parent);
 		break;
 
 	case ETHTOOL_ID_ON:
@@ -1912,6 +1945,7 @@ static int e1000_set_phys_id(struct net_device *netdev,
 		hw->mac.ops.led_off(hw);
 		break;
 	}
+
 	return 0;
 }
 
@@ -1950,11 +1984,15 @@ static int e1000_set_coalesce(struct net_device *netdev,
 		adapter->itr_setting = adapter->itr & ~3;
 	}
 
+	pm_runtime_get_sync(netdev->dev.parent);
+
 	if (adapter->itr_setting != 0)
 		e1000e_write_itr(adapter, adapter->itr);
 	else
 		e1000e_write_itr(adapter, 0);
 
+	pm_runtime_put_sync(netdev->dev.parent);
+
 	return 0;
 }
 
@@ -1968,7 +2006,9 @@ static int e1000_nway_reset(struct net_device *netdev)
 	if (!adapter->hw.mac.autoneg)
 		return -EINVAL;
 
+	pm_runtime_get_sync(netdev->dev.parent);
 	e1000e_reinit_locked(adapter);
+	pm_runtime_put_sync(netdev->dev.parent);
 
 	return 0;
 }
@@ -1982,7 +2022,12 @@ static void e1000_get_ethtool_stats(struct net_device *netdev,
 	int i;
 	char *p = NULL;
 
+	pm_runtime_get_sync(netdev->dev.parent);
+
 	e1000e_get_stats64(netdev, &net_stats);
+
+	pm_runtime_put_sync(netdev->dev.parent);
+
 	for (i = 0; i < E1000_GLOBAL_STATS_LEN; i++) {
 		switch (e1000_gstrings_stats[i].type) {
 		case NETDEV_STATS:
@@ -2033,7 +2078,11 @@ static int e1000_get_rxnfc(struct net_device *netdev,
 	case ETHTOOL_GRXFH: {
 		struct e1000_adapter *adapter = netdev_priv(netdev);
 		struct e1000_hw *hw = &adapter->hw;
-		u32 mrqc = er32(MRQC);
+		u32 mrqc;
+
+		pm_runtime_get_sync(netdev->dev.parent);
+		mrqc = er32(MRQC);
+		pm_runtime_put_sync(netdev->dev.parent);
 
 		if (!(mrqc & E1000_MRQC_RSS_FIELD_MASK))
 			return 0;
@@ -2096,9 +2145,13 @@ static int e1000e_get_eee(struct net_device *netdev, struct ethtool_eee *edata)
 		return -EOPNOTSUPP;
 	}
 
+	pm_runtime_get_sync(netdev->dev.parent);
+
 	ret_val = hw->phy.ops.acquire(hw);
-	if (ret_val)
+	if (ret_val) {
+		pm_runtime_put_sync(netdev->dev.parent);
 		return -EBUSY;
+	}
 
 	/* EEE Capability */
 	ret_val = e1000_read_emi_reg_locked(hw, cap_addr, &phy_data);
@@ -2117,14 +2170,11 @@ static int e1000e_get_eee(struct net_device *netdev, struct ethtool_eee *edata)
 
 	/* EEE PCS Status */
 	ret_val = e1000_read_emi_reg_locked(hw, pcs_stat_addr, &phy_data);
+	if (ret_val)
+		goto release;
 	if (hw->phy.type == e1000_phy_82579)
 		phy_data <<= 8;
 
-release:
-	hw->phy.ops.release(hw);
-	if (ret_val)
-		return -ENODATA;
-
 	/* Result of the EEE auto negotiation - there is no register that
 	 * has the status of the EEE negotiation so do a best-guess based
 	 * on whether Tx or Rx LPI indications have been received.
@@ -2136,7 +2186,14 @@ release:
 	edata->tx_lpi_enabled = true;
 	edata->tx_lpi_timer = er32(LPIC) >> E1000_LPIC_LPIET_SHIFT;
 
-	return 0;
+release:
+	hw->phy.ops.release(hw);
+	if (ret_val)
+		ret_val = -ENODATA;
+
+	pm_runtime_put_sync(netdev->dev.parent);
+
+	return ret_val;
 }
 
 static int e1000e_set_eee(struct net_device *netdev, struct ethtool_eee *edata)
@@ -2169,12 +2226,16 @@ static int e1000e_set_eee(struct net_device *netdev, struct ethtool_eee *edata)
 
 	hw->dev_spec.ich8lan.eee_disable = !edata->eee_enabled;
 
+	pm_runtime_get_sync(netdev->dev.parent);
+
 	/* reset the link */
 	if (netif_running(netdev))
 		e1000e_reinit_locked(adapter);
 	else
 		e1000e_reset(adapter);
 
+	pm_runtime_put_sync(netdev->dev.parent);
+
 	return 0;
 }
 
@@ -2212,19 +2273,7 @@ static int e1000e_get_ts_info(struct net_device *netdev,
 	return 0;
 }
 
-static int e1000e_ethtool_begin(struct net_device *netdev)
-{
-	return pm_runtime_get_sync(netdev->dev.parent);
-}
-
-static void e1000e_ethtool_complete(struct net_device *netdev)
-{
-	pm_runtime_put_sync(netdev->dev.parent);
-}
-
 static const struct ethtool_ops e1000_ethtool_ops = {
-	.begin			= e1000e_ethtool_begin,
-	.complete		= e1000e_ethtool_complete,
 	.get_settings		= e1000_get_settings,
 	.set_settings		= e1000_set_settings,
 	.get_drvinfo		= e1000_get_drvinfo,
-- 
1.7.11.7
