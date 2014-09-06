From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/2] igb: add flags to set eee advertisement mode
Date: Sat,  6 Sep 2014 05:34:02 -0700
Message-ID: <1410006842-26517-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1410006842-26517-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:23312 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751332AbaIFMeG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Sep 2014 08:34:06 -0400
In-Reply-To: <1410006842-26517-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Change e1000_set_eee and e1000_set_eee_i35(0|4) to allow
changes in the advertised EEE speeds from ethtool. Adds two boolean
flags to e1000_set_eee_i35(0|4) to pass in advertised speed data.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 31 +++++++++++++++++++++++-----
 drivers/net/ethernet/intel/igb/e1000_82575.h |  4 ++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 24 ++++++++++++++-------
 drivers/net/ethernet/intel/igb/igb_main.c    |  8 +++----
 4 files changed, 49 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 236a618..051ea94 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -2548,11 +2548,13 @@ s32 igb_read_emi_reg(struct e1000_hw *hw, u16 addr, u16 *data)
 /**
  *  igb_set_eee_i350 - Enable/disable EEE support
  *  @hw: pointer to the HW structure
+ *  @adv1G: boolean flag enabling 1G EEE advertisement
+ *  @adv100m: boolean flag enabling 100M EEE advertisement
  *
  *  Enable/disable EEE based on setting in dev_spec structure.
  *
  **/
-s32 igb_set_eee_i350(struct e1000_hw *hw)
+s32 igb_set_eee_i350(struct e1000_hw *hw, bool adv1G, bool adv100M)
 {
 	u32 ipcnfg, eeer;
 
@@ -2566,7 +2568,16 @@ s32 igb_set_eee_i350(struct e1000_hw *hw)
 	if (!(hw->dev_spec._82575.eee_disable)) {
 		u32 eee_su = rd32(E1000_EEE_SU);
 
-		ipcnfg |= (E1000_IPCNFG_EEE_1G_AN | E1000_IPCNFG_EEE_100M_AN);
+		if (adv100M)
+			ipcnfg |= E1000_IPCNFG_EEE_100M_AN;
+		else
+			ipcnfg &= ~E1000_IPCNFG_EEE_100M_AN;
+
+		if (adv1G)
+			ipcnfg |= E1000_IPCNFG_EEE_1G_AN;
+		else
+			ipcnfg &= ~E1000_IPCNFG_EEE_1G_AN;
+
 		eeer |= (E1000_EEER_TX_LPI_EN | E1000_EEER_RX_LPI_EN |
 			E1000_EEER_LPI_FC);
 
@@ -2593,11 +2604,13 @@ out:
 /**
  *  igb_set_eee_i354 - Enable/disable EEE support
  *  @hw: pointer to the HW structure
+ *  @adv1G: boolean flag enabling 1G EEE advertisement
+ *  @adv100m: boolean flag enabling 100M EEE advertisement
  *
  *  Enable/disable EEE legacy mode based on setting in dev_spec structure.
  *
  **/
-s32 igb_set_eee_i354(struct e1000_hw *hw)
+s32 igb_set_eee_i354(struct e1000_hw *hw, bool adv1G, bool adv100M)
 {
 	struct e1000_phy_info *phy = &hw->phy;
 	s32 ret_val = 0;
@@ -2636,8 +2649,16 @@ s32 igb_set_eee_i354(struct e1000_hw *hw)
 		if (ret_val)
 			goto out;
 
-		phy_data |= E1000_EEE_ADV_100_SUPPORTED |
-			    E1000_EEE_ADV_1000_SUPPORTED;
+		if (adv100M)
+			phy_data |= E1000_EEE_ADV_100_SUPPORTED;
+		else
+			phy_data &= ~E1000_EEE_ADV_100_SUPPORTED;
+
+		if (adv1G)
+			phy_data |= E1000_EEE_ADV_1000_SUPPORTED;
+		else
+			phy_data &= ~E1000_EEE_ADV_1000_SUPPORTED;
+
 		ret_val = igb_write_xmdio_reg(hw, E1000_EEE_ADV_ADDR_I354,
 						E1000_EEE_ADV_DEV_I354,
 						phy_data);
diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index b407c55..2154aea 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -263,8 +263,8 @@ void igb_vmdq_set_loopback_pf(struct e1000_hw *, bool);
 void igb_vmdq_set_replication_pf(struct e1000_hw *, bool);
 u16 igb_rxpbs_adjust_82580(u32 data);
 s32 igb_read_emi_reg(struct e1000_hw *, u16 addr, u16 *data);
-s32 igb_set_eee_i350(struct e1000_hw *);
-s32 igb_set_eee_i354(struct e1000_hw *);
+s32 igb_set_eee_i350(struct e1000_hw *, bool adv1G, bool adv100M);
+s32 igb_set_eee_i354(struct e1000_hw *, bool adv1G, bool adv100M);
 s32 igb_get_eee_status_i354(struct e1000_hw *hw, bool *status);
 
 #define E1000_I2C_THERMAL_SENSOR_ADDR	0xF8
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index c737d1f..02cfd3b 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2675,6 +2675,7 @@ static int igb_set_eee(struct net_device *netdev,
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	struct ethtool_eee eee_curr;
+	bool adv1g_eee = true, adv100m_eee = true;
 	s32 ret_val;
 
 	if ((hw->mac.type < e1000_i350) ||
@@ -2701,12 +2702,14 @@ static int igb_set_eee(struct net_device *netdev,
 			return -EINVAL;
 		}
 
-		if (edata->advertised &
-		    ~(ADVERTISE_100_FULL | ADVERTISE_1000_FULL)) {
+		if (!edata->advertised || (edata->advertised &
+		    ~(ADVERTISE_100_FULL | ADVERTISE_1000_FULL))) {
 			dev_err(&adapter->pdev->dev,
-				"EEE Advertisement supports only 100Tx and or 100T full duplex\n");
+				"EEE Advertisement supports only 100Tx and/or 100T full duplex\n");
 			return -EINVAL;
 		}
+		adv100m_eee = !!(edata->advertised & ADVERTISE_100_FULL);
+		adv1g_eee = !!(edata->advertised & ADVERTISE_1000_FULL);
 
 	} else if (!edata->eee_enabled) {
 		dev_err(&adapter->pdev->dev,
@@ -2718,10 +2721,6 @@ static int igb_set_eee(struct net_device *netdev,
 	if (hw->dev_spec._82575.eee_disable != !edata->eee_enabled) {
 		hw->dev_spec._82575.eee_disable = !edata->eee_enabled;
 		adapter->flags |= IGB_FLAG_EEE;
-		if (hw->mac.type == e1000_i350)
-			igb_set_eee_i350(hw);
-		else
-			igb_set_eee_i354(hw);
 
 		/* reset link */
 		if (netif_running(netdev))
@@ -2730,6 +2729,17 @@ static int igb_set_eee(struct net_device *netdev,
 			igb_reset(adapter);
 	}
 
+	if (hw->mac.type == e1000_i354)
+		ret_val = igb_set_eee_i354(hw, adv1g_eee, adv100m_eee);
+	else
+		ret_val = igb_set_eee_i350(hw, adv1g_eee, adv100m_eee);
+
+	if (ret_val) {
+		dev_err(&adapter->pdev->dev,
+			"Problem setting EEE advertisement options\n");
+		return -EINVAL;
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 4c023f0..6cf0c17 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2012,10 +2012,10 @@ void igb_reset(struct igb_adapter *adapter)
 		case e1000_i350:
 		case e1000_i210:
 		case e1000_i211:
-			igb_set_eee_i350(hw);
+			igb_set_eee_i350(hw, true, true);
 			break;
 		case e1000_i354:
-			igb_set_eee_i354(hw);
+			igb_set_eee_i354(hw, true, true);
 			break;
 		default:
 			break;
@@ -2619,7 +2619,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		case e1000_i210:
 		case e1000_i211:
 			/* Enable EEE for internal copper PHY devices */
-			err = igb_set_eee_i350(hw);
+			err = igb_set_eee_i350(hw, true, true);
 			if ((!err) &&
 			    (!hw->dev_spec._82575.eee_disable)) {
 				adapter->eee_advert =
@@ -2630,7 +2630,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		case e1000_i354:
 			if ((rd32(E1000_CTRL_EXT) &
 			    E1000_CTRL_EXT_LINK_MODE_SGMII)) {
-				err = igb_set_eee_i354(hw);
+				err = igb_set_eee_i354(hw, true, true);
 				if ((!err) &&
 					(!hw->dev_spec._82575.eee_disable)) {
 					adapter->eee_advert =
-- 
1.9.3
