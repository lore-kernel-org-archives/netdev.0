From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/12] e1000e: EEE capability advertisement not set/disabled as required
Date: Thu, 28 Mar 2013 02:00:08 -0700
Message-ID: <1364461215-7793-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:61712 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091Ab3C1JAX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Mar 2013 05:00:23 -0400
In-Reply-To: <1364461215-7793-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Devices supported by the driver which support EEE (currently 82579, I217
and I218) are advertising EEE capabilities during auto-negotiation even
when EEE has been disabled.  In addition to not acting as expected, this
also caused the EEE status reported by 'ethtool --show-eee' to be wrong
when two of these devices are connected back-to-back and EEE is disabled
on one.  In addition to fixing this issue, the ability for the user to
specify which speeds (100 or 1000 full-duplex) to advertise EEE support
has been added.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   |  3 ++
 drivers/net/ethernet/intel/e1000e/ethtool.c | 63 +++++++++--------------------
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 55 ++++++++++++-------------
 drivers/net/ethernet/intel/e1000e/ich8lan.h |  3 +-
 drivers/net/ethernet/intel/e1000e/netdev.c  | 36 +++++++++++++++++
 5 files changed, 88 insertions(+), 72 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index e371f77..82f1c84 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -46,6 +46,7 @@
 #include <linux/ptp_clock_kernel.h>
 #include <linux/ptp_classify.h>
 #include <linux/mii.h>
+#include <linux/mdio.h>
 #include "hw.h"
 
 struct e1000_info;
@@ -350,6 +351,8 @@ struct e1000_adapter {
 	struct timecounter tc;
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_clock_info;
+
+	u16 eee_advert;
 };
 
 struct e1000_info {
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index e835e7b..7c8ca65 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -35,7 +35,6 @@
 #include <linux/slab.h>
 #include <linux/delay.h>
 #include <linux/vmalloc.h>
-#include <linux/mdio.h>
 #include <linux/pm_runtime.h>
 
 #include "e1000.h"
@@ -2076,23 +2075,20 @@ static int e1000e_get_eee(struct net_device *netdev, struct ethtool_eee *edata)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u16 cap_addr, adv_addr, lpa_addr, pcs_stat_addr, phy_data, lpi_ctrl;
-	u32 status, ret_val;
+	u16 cap_addr, lpa_addr, pcs_stat_addr, phy_data;
+	u32 ret_val;
 
-	if (!(adapter->flags & FLAG_IS_ICH) ||
-	    !(adapter->flags2 & FLAG2_HAS_EEE))
+	if (!(adapter->flags2 & FLAG2_HAS_EEE))
 		return -EOPNOTSUPP;
 
 	switch (hw->phy.type) {
 	case e1000_phy_82579:
 		cap_addr = I82579_EEE_CAPABILITY;
-		adv_addr = I82579_EEE_ADVERTISEMENT;
 		lpa_addr = I82579_EEE_LP_ABILITY;
 		pcs_stat_addr = I82579_EEE_PCS_STATUS;
 		break;
 	case e1000_phy_i217:
 		cap_addr = I217_EEE_CAPABILITY;
-		adv_addr = I217_EEE_ADVERTISEMENT;
 		lpa_addr = I217_EEE_LP_ABILITY;
 		pcs_stat_addr = I217_EEE_PCS_STATUS;
 		break;
@@ -2111,10 +2107,7 @@ static int e1000e_get_eee(struct net_device *netdev, struct ethtool_eee *edata)
 	edata->supported = mmd_eee_cap_to_ethtool_sup_t(phy_data);
 
 	/* EEE Advertised */
-	ret_val = e1000_read_emi_reg_locked(hw, adv_addr, &phy_data);
-	if (ret_val)
-		goto release;
-	edata->advertised = mmd_eee_adv_to_ethtool_adv_t(phy_data);
+	edata->advertised = mmd_eee_adv_to_ethtool_adv_t(adapter->eee_advert);
 
 	/* EEE Link Partner Advertised */
 	ret_val = e1000_read_emi_reg_locked(hw, lpa_addr, &phy_data);
@@ -2132,25 +2125,11 @@ release:
 	if (ret_val)
 		return -ENODATA;
 
-	e1e_rphy(hw, I82579_LPI_CTRL, &lpi_ctrl);
-	status = er32(STATUS);
-
 	/* Result of the EEE auto negotiation - there is no register that
 	 * has the status of the EEE negotiation so do a best-guess based
-	 * on whether both Tx and Rx LPI indications have been received or
-	 * base it on the link speed, the EEE advertised speeds on both ends
-	 * and the speeds on which EEE is enabled locally.
+	 * on whether Tx or Rx LPI indications have been received.
 	 */
-	if (((phy_data & E1000_EEE_TX_LPI_RCVD) &&
-	     (phy_data & E1000_EEE_RX_LPI_RCVD)) ||
-	    ((status & E1000_STATUS_SPEED_100) &&
-	     (edata->advertised & ADVERTISED_100baseT_Full) &&
-	     (edata->lp_advertised & ADVERTISED_100baseT_Full) &&
-	     (lpi_ctrl & I82579_LPI_CTRL_100_ENABLE)) ||
-	    ((status & E1000_STATUS_SPEED_1000) &&
-	     (edata->advertised & ADVERTISED_1000baseT_Full) &&
-	     (edata->lp_advertised & ADVERTISED_1000baseT_Full) &&
-	     (lpi_ctrl & I82579_LPI_CTRL_1000_ENABLE)))
+	if (phy_data & (E1000_EEE_TX_LPI_RCVD | E1000_EEE_RX_LPI_RCVD))
 		edata->eee_active = true;
 
 	edata->eee_enabled = !hw->dev_spec.ich8lan.eee_disable;
@@ -2167,19 +2146,10 @@ static int e1000e_set_eee(struct net_device *netdev, struct ethtool_eee *edata)
 	struct ethtool_eee eee_curr;
 	s32 ret_val;
 
-	if (!(adapter->flags & FLAG_IS_ICH) ||
-	    !(adapter->flags2 & FLAG2_HAS_EEE))
-		return -EOPNOTSUPP;
-
 	ret_val = e1000e_get_eee(netdev, &eee_curr);
 	if (ret_val)
 		return ret_val;
 
-	if (eee_curr.advertised != edata->advertised) {
-		e_err("Setting EEE advertisement is not supported\n");
-		return -EINVAL;
-	}
-
 	if (eee_curr.tx_lpi_enabled != edata->tx_lpi_enabled) {
 		e_err("Setting EEE tx-lpi is not supported\n");
 		return -EINVAL;
@@ -2190,16 +2160,21 @@ static int e1000e_set_eee(struct net_device *netdev, struct ethtool_eee *edata)
 		return -EINVAL;
 	}
 
-	if (hw->dev_spec.ich8lan.eee_disable != !edata->eee_enabled) {
-		hw->dev_spec.ich8lan.eee_disable = !edata->eee_enabled;
-
-		/* reset the link */
-		if (netif_running(netdev))
-			e1000e_reinit_locked(adapter);
-		else
-			e1000e_reset(adapter);
+	if (edata->advertised & ~(ADVERTISE_100_FULL | ADVERTISE_1000_FULL)) {
+		e_err("EEE advertisement supports only 100TX and/or 1000T full-duplex\n");
+		return -EINVAL;
 	}
 
+	adapter->eee_advert = ethtool_adv_to_mmd_eee_adv_t(edata->advertised);
+
+	hw->dev_spec.ich8lan.eee_disable = !edata->eee_enabled;
+
+	/* reset the link */
+	if (netif_running(netdev))
+		e1000e_reinit_locked(adapter);
+	else
+		e1000e_reset(adapter);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 3b1c1a7..174507c 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -695,7 +695,7 @@ s32 e1000_read_emi_reg_locked(struct e1000_hw *hw, u16 addr, u16 *data)
  *
  *  Assumes the SW/FW/HW Semaphore is already acquired.
  **/
-static s32 e1000_write_emi_reg_locked(struct e1000_hw *hw, u16 addr, u16 data)
+s32 e1000_write_emi_reg_locked(struct e1000_hw *hw, u16 addr, u16 data)
 {
 	return __e1000_access_emi_reg_locked(hw, addr, &data, false);
 }
@@ -712,11 +712,22 @@ static s32 e1000_set_eee_pchlan(struct e1000_hw *hw)
 {
 	struct e1000_dev_spec_ich8lan *dev_spec = &hw->dev_spec.ich8lan;
 	s32 ret_val;
-	u16 lpi_ctrl;
+	u16 lpa, pcs_status, adv, adv_addr, lpi_ctrl, data;
 
-	if ((hw->phy.type != e1000_phy_82579) &&
-	    (hw->phy.type != e1000_phy_i217))
+	switch (hw->phy.type) {
+	case e1000_phy_82579:
+		lpa = I82579_EEE_LP_ABILITY;
+		pcs_status = I82579_EEE_PCS_STATUS;
+		adv_addr = I82579_EEE_ADVERTISEMENT;
+		break;
+	case e1000_phy_i217:
+		lpa = I217_EEE_LP_ABILITY;
+		pcs_status = I217_EEE_PCS_STATUS;
+		adv_addr = I217_EEE_ADVERTISEMENT;
+		break;
+	default:
 		return 0;
+	}
 
 	ret_val = hw->phy.ops.acquire(hw);
 	if (ret_val)
@@ -731,34 +742,24 @@ static s32 e1000_set_eee_pchlan(struct e1000_hw *hw)
 
 	/* Enable EEE if not disabled by user */
 	if (!dev_spec->eee_disable) {
-		u16 lpa, pcs_status, data;
-
 		/* Save off link partner's EEE ability */
-		switch (hw->phy.type) {
-		case e1000_phy_82579:
-			lpa = I82579_EEE_LP_ABILITY;
-			pcs_status = I82579_EEE_PCS_STATUS;
-			break;
-		case e1000_phy_i217:
-			lpa = I217_EEE_LP_ABILITY;
-			pcs_status = I217_EEE_PCS_STATUS;
-			break;
-		default:
-			ret_val = -E1000_ERR_PHY;
-			goto release;
-		}
 		ret_val = e1000_read_emi_reg_locked(hw, lpa,
 						    &dev_spec->eee_lp_ability);
 		if (ret_val)
 			goto release;
 
+		/* Read EEE advertisement */
+		ret_val = e1000_read_emi_reg_locked(hw, adv_addr, &adv);
+		if (ret_val)
+			goto release;
+
 		/* Enable EEE only for speeds in which the link partner is
-		 * EEE capable.
+		 * EEE capable and for which we advertise EEE.
 		 */
-		if (dev_spec->eee_lp_ability & I82579_EEE_1000_SUPPORTED)
+		if (adv & dev_spec->eee_lp_ability & I82579_EEE_1000_SUPPORTED)
 			lpi_ctrl |= I82579_LPI_CTRL_1000_ENABLE;
 
-		if (dev_spec->eee_lp_ability & I82579_EEE_100_SUPPORTED) {
+		if (adv & dev_spec->eee_lp_ability & I82579_EEE_100_SUPPORTED) {
 			e1e_rphy_locked(hw, MII_LPA, &data);
 			if (data & LPA_100FULL)
 				lpi_ctrl |= I82579_LPI_CTRL_100_ENABLE;
@@ -770,13 +771,13 @@ static s32 e1000_set_eee_pchlan(struct e1000_hw *hw)
 				dev_spec->eee_lp_ability &=
 				    ~I82579_EEE_100_SUPPORTED;
 		}
-
-		/* R/Clr IEEE MMD 3.1 bits 11:10 - Tx/Rx LPI Received */
-		ret_val = e1000_read_emi_reg_locked(hw, pcs_status, &data);
-		if (ret_val)
-			goto release;
 	}
 
+	/* R/Clr IEEE MMD 3.1 bits 11:10 - Tx/Rx LPI Received */
+	ret_val = e1000_read_emi_reg_locked(hw, pcs_status, &data);
+	if (ret_val)
+		goto release;
+
 	ret_val = e1e_wphy_locked(hw, I82579_LPI_CTRL, lpi_ctrl);
 release:
 	hw->phy.ops.release(hw);
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.h b/drivers/net/ethernet/intel/e1000e/ich8lan.h
index 00ba6c9..21d21b9 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.h
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.h
@@ -212,7 +212,7 @@
 #define I82577_MSE_THRESHOLD	0x0887	/* 82577 Mean Square Error Threshold */
 #define I82579_MSE_LINK_DOWN	0x2411	/* MSE count before dropping link */
 #define I82579_RX_CONFIG		0x3412	/* Receive configuration */
-#define I82579_EEE_PCS_STATUS		0x182D	/* IEEE MMD Register 3.1 >> 8 */
+#define I82579_EEE_PCS_STATUS		0x182E	/* IEEE MMD Register 3.1 >> 8 */
 #define I82579_EEE_CAPABILITY		0x0410	/* IEEE MMD Register 3.20 */
 #define I82579_EEE_ADVERTISEMENT	0x040E	/* IEEE MMD Register 7.60 */
 #define I82579_EEE_LP_ABILITY		0x040F	/* IEEE MMD Register 7.61 */
@@ -268,4 +268,5 @@ s32 e1000_configure_k1_ich8lan(struct e1000_hw *hw, bool k1_enable);
 void e1000_copy_rx_addrs_to_phy_ich8lan(struct e1000_hw *hw);
 s32 e1000_lv_jumbo_workaround_ich8lan(struct e1000_hw *hw, bool enable);
 s32 e1000_read_emi_reg_locked(struct e1000_hw *hw, u16 addr, u16 *data);
+s32 e1000_write_emi_reg_locked(struct e1000_hw *hw, u16 addr, u16 data);
 #endif /* _E1000E_ICH8LAN_H_ */
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 142ca39..0459fe3 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3875,6 +3875,38 @@ void e1000e_reset(struct e1000_adapter *adapter)
 	/* initialize systim and reset the ns time counter */
 	e1000e_config_hwtstamp(adapter);
 
+	/* Set EEE advertisement as appropriate */
+	if (adapter->flags2 & FLAG2_HAS_EEE) {
+		s32 ret_val;
+		u16 adv_addr;
+
+		switch (hw->phy.type) {
+		case e1000_phy_82579:
+			adv_addr = I82579_EEE_ADVERTISEMENT;
+			break;
+		case e1000_phy_i217:
+			adv_addr = I217_EEE_ADVERTISEMENT;
+			break;
+		default:
+			dev_err(&adapter->pdev->dev,
+				"Invalid PHY type setting EEE advertisement\n");
+			return;
+		}
+
+		ret_val = hw->phy.ops.acquire(hw);
+		if (ret_val) {
+			dev_err(&adapter->pdev->dev,
+				"EEE advertisement - unable to acquire PHY\n");
+			return;
+		}
+
+		e1000_write_emi_reg_locked(hw, adv_addr,
+					   hw->dev_spec.ich8lan.eee_disable ?
+					   0 : adapter->eee_advert);
+
+		hw->phy.ops.release(hw);
+	}
+
 	if (!netif_running(adapter->netdev) &&
 	    !test_bit(__E1000_TESTING, &adapter->state)) {
 		e1000_power_down_phy(adapter);
@@ -6540,6 +6572,10 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			goto err_flashmap;
 	}
 
+	/* Set default EEE advertisement */
+	if (adapter->flags2 & FLAG2_HAS_EEE)
+		adapter->eee_advert = MDIO_EEE_100TX | MDIO_EEE_1000T;
+
 	/* construct the net_device struct */
 	netdev->netdev_ops		= &e1000e_netdev_ops;
 	e1000e_set_ethtool_ops(netdev);
-- 
1.7.11.7
