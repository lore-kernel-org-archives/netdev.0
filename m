From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] igb: Fix for devices using ethtool for EEE settings
Date: Tue, 11 Mar 2014 22:53:28 -0700
Message-ID: <1394603618-1044-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33779 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754837AbaCLFxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 01:53:41 -0400
In-Reply-To: <1394603618-1044-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem where using ethtool for EEE setting was not
working correctly.  This patch also fixes a problem where
the function that checks for EEE status on i354 devices was not being
called and was causing warnings with static analysis tools.

Reported-by: Rashika Kheria <rashika.kheria@gmail.com>
Reported-by: Josh Triplett <josh@joshtriplett.org>
Reported-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.h |  1 +
 drivers/net/ethernet/intel/igb/igb.h         |  3 ++
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 45 +++++++++++-------
 drivers/net/ethernet/intel/igb/igb_main.c    | 69 ++++++++++++++++++++++------
 4 files changed, 88 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.h b/drivers/net/ethernet/intel/igb/e1000_82575.h
index f12b086..2a721a1 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.h
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.h
@@ -265,6 +265,7 @@ u16 igb_rxpbs_adjust_82580(u32 data);
 s32 igb_read_emi_reg(struct e1000_hw *, u16 addr, u16 *data);
 s32 igb_set_eee_i350(struct e1000_hw *);
 s32 igb_set_eee_i354(struct e1000_hw *);
+s32 igb_get_eee_status_i354(struct e1000_hw *hw, bool *status);
 
 #define E1000_I2C_THERMAL_SENSOR_ADDR	0xF8
 #define E1000_EMC_INTERNAL_DATA		0x00
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index fc3fc2c..a202c96 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -41,6 +41,7 @@
 #include <linux/i2c.h>
 #include <linux/i2c-algo-bit.h>
 #include <linux/pci.h>
+#include <linux/mdio.h>
 
 struct igb_adapter;
 
@@ -455,6 +456,7 @@ struct igb_adapter {
 	unsigned long link_check_timeout;
 	int copper_tries;
 	struct e1000_info ei;
+	u16 eee_advert;
 };
 
 #define IGB_FLAG_HAS_MSI		(1 << 0)
@@ -471,6 +473,7 @@ struct igb_adapter {
 #define IGB_FLAG_MAS_CAPABLE		(1 << 11)
 #define IGB_FLAG_MAS_ENABLE		(1 << 12)
 #define IGB_FLAG_HAS_MSIX		(1 << 13)
+#define IGB_FLAG_EEE			(1 << 14)
 
 /* Media Auto Sense */
 #define IGB_MAS_ENABLE_0		0X0001
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index c7f5741..170e4db 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2587,7 +2587,7 @@ static int igb_get_eee(struct net_device *netdev, struct ethtool_eee *edata)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-	u32 ipcnfg, eeer, ret_val;
+	u32 ret_val;
 	u16 phy_data;
 
 	if ((hw->mac.type < e1000_i350) ||
@@ -2596,16 +2596,25 @@ static int igb_get_eee(struct net_device *netdev, struct ethtool_eee *edata)
 
 	edata->supported = (SUPPORTED_1000baseT_Full |
 			    SUPPORTED_100baseT_Full);
+	if (!hw->dev_spec._82575.eee_disable)
+		edata->advertised =
+			mmd_eee_adv_to_ethtool_adv_t(adapter->eee_advert);
 
-	ipcnfg = rd32(E1000_IPCNFG);
-	eeer = rd32(E1000_EEER);
+	/* The IPCNFG and EEER registers are not supported on I354. */
+	if (hw->mac.type == e1000_i354) {
+		igb_get_eee_status_i354(hw, (bool *)&edata->eee_active);
+	} else {
+		u32 eeer;
+
+		eeer = rd32(E1000_EEER);
 
-	/* EEE status on negotiated link */
-	if (ipcnfg & E1000_IPCNFG_EEE_1G_AN)
-		edata->advertised = ADVERTISED_1000baseT_Full;
+		/* EEE status on negotiated link */
+		if (eeer & E1000_EEER_EEE_NEG)
+			edata->eee_active = true;
 
-	if (ipcnfg & E1000_IPCNFG_EEE_100M_AN)
-		edata->advertised |= ADVERTISED_100baseT_Full;
+		if (eeer & E1000_EEER_TX_LPI_EN)
+			edata->tx_lpi_enabled = true;
+	}
 
 	/* EEE Link Partner Advertised */
 	switch (hw->mac.type) {
@@ -2616,8 +2625,8 @@ static int igb_get_eee(struct net_device *netdev, struct ethtool_eee *edata)
 			return -ENODATA;
 
 		edata->lp_advertised = mmd_eee_adv_to_ethtool_adv_t(phy_data);
-
 		break;
+	case e1000_i354:
 	case e1000_i210:
 	case e1000_i211:
 		ret_val = igb_read_xmdio_reg(hw, E1000_EEE_LP_ADV_ADDR_I210,
@@ -2633,12 +2642,10 @@ static int igb_get_eee(struct net_device *netdev, struct ethtool_eee *edata)
 		break;
 	}
 
-	if (eeer & E1000_EEER_EEE_NEG)
-		edata->eee_active = true;
-
 	edata->eee_enabled = !hw->dev_spec._82575.eee_disable;
 
-	if (eeer & E1000_EEER_TX_LPI_EN)
+	if ((hw->mac.type == e1000_i354) &&
+	    (edata->eee_enabled))
 		edata->tx_lpi_enabled = true;
 
 	/* Report correct negotiated EEE status for devices that
@@ -2686,9 +2693,10 @@ static int igb_set_eee(struct net_device *netdev,
 			return -EINVAL;
 		}
 
-		if (eee_curr.advertised != edata->advertised) {
+		if (edata->advertised &
+		    ~(ADVERTISE_100_FULL | ADVERTISE_1000_FULL)) {
 			dev_err(&adapter->pdev->dev,
-				"Setting EEE Advertisement is not supported\n");
+				"EEE Advertisement supports only 100Tx and or 100T full duplex\n");
 			return -EINVAL;
 		}
 
@@ -2698,9 +2706,14 @@ static int igb_set_eee(struct net_device *netdev,
 			return -EINVAL;
 		}
 
+	adapter->eee_advert = ethtool_adv_to_mmd_eee_adv_t(edata->advertised);
 	if (hw->dev_spec._82575.eee_disable != !edata->eee_enabled) {
 		hw->dev_spec._82575.eee_disable = !edata->eee_enabled;
-		igb_set_eee_i350(hw);
+		adapter->flags |= IGB_FLAG_EEE;
+		if (hw->mac.type == e1000_i350)
+			igb_set_eee_i350(hw);
+		else
+			igb_set_eee_i354(hw);
 
 		/* reset link */
 		if (netif_running(netdev))
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a96beb6..340a344 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1726,6 +1726,10 @@ int igb_up(struct igb_adapter *adapter)
 	hw->mac.get_link_status = 1;
 	schedule_work(&adapter->watchdog_task);
 
+	if ((adapter->flags & IGB_FLAG_EEE) &&
+	    (!hw->dev_spec._82575.eee_disable))
+		adapter->eee_advert = MDIO_EEE_100TX | MDIO_EEE_1000T;
+
 	return 0;
 }
 
@@ -1974,6 +1978,21 @@ void igb_reset(struct igb_adapter *adapter)
 		}
 	}
 #endif
+	/*Re-establish EEE setting */
+	if (hw->phy.media_type == e1000_media_type_copper) {
+		switch (mac->type) {
+		case e1000_i350:
+		case e1000_i210:
+		case e1000_i211:
+			igb_set_eee_i350(hw);
+			break;
+		case e1000_i354:
+			igb_set_eee_i354(hw);
+			break;
+		default:
+			break;
+		}
+	}
 	if (!netif_running(adapter->netdev))
 		igb_power_down_link(adapter);
 
@@ -2560,23 +2579,36 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		(adapter->flags & IGB_FLAG_HAS_MSIX) ? "MSI-X" :
 		(adapter->flags & IGB_FLAG_HAS_MSI) ? "MSI" : "legacy",
 		adapter->num_rx_queues, adapter->num_tx_queues);
-	switch (hw->mac.type) {
-	case e1000_i350:
-	case e1000_i210:
-	case e1000_i211:
-		igb_set_eee_i350(hw);
-		break;
-	case e1000_i354:
-		if (hw->phy.media_type == e1000_media_type_copper) {
+	if (hw->phy.media_type == e1000_media_type_copper) {
+		switch (hw->mac.type) {
+		case e1000_i350:
+		case e1000_i210:
+		case e1000_i211:
+			/* Enable EEE for internal copper PHY devices */
+			err = igb_set_eee_i350(hw);
+			if ((!err) &&
+			    (!hw->dev_spec._82575.eee_disable)) {
+				adapter->eee_advert =
+					MDIO_EEE_100TX | MDIO_EEE_1000T;
+				adapter->flags |= IGB_FLAG_EEE;
+			}
+			break;
+		case e1000_i354:
 			if ((rd32(E1000_CTRL_EXT) &
-			    E1000_CTRL_EXT_LINK_MODE_SGMII))
-				igb_set_eee_i354(hw);
+			    E1000_CTRL_EXT_LINK_MODE_SGMII)) {
+				err = igb_set_eee_i354(hw);
+				if ((!err) &&
+					(!hw->dev_spec._82575.eee_disable)) {
+					adapter->eee_advert =
+					   MDIO_EEE_100TX | MDIO_EEE_1000T;
+					adapter->flags |= IGB_FLAG_EEE;
+				}
+			}
+			break;
+		default:
+			break;
 		}
-		break;
-	default:
-		break;
 	}
-
 	pm_runtime_put_noidle(&pdev->dev);
 	return 0;
 
@@ -4158,6 +4190,15 @@ static void igb_watchdog_task(struct work_struct *work)
 			       (ctrl & E1000_CTRL_RFCE) ?  "RX" :
 			       (ctrl & E1000_CTRL_TFCE) ?  "TX" : "None");
 
+			/* disable EEE if enabled */
+			if ((adapter->flags & IGB_FLAG_EEE) &&
+				(adapter->link_duplex == HALF_DUPLEX)) {
+				dev_info(&adapter->pdev->dev,
+				"EEE Disabled: unsupported at half duplex. Re-enable using ethtool when at full duplex.\n");
+				adapter->hw.dev_spec._82575.eee_disable = true;
+				adapter->flags &= ~IGB_FLAG_EEE;
+			}
+
 			/* check if SmartSpeed worked */
 			igb_check_downshift(hw);
 			if (phy->speed_downgraded)
-- 
1.8.3.1
