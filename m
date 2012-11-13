From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/11] igb: Ethtool support to enable and disable EEE
Date: Tue, 13 Nov 2012 06:03:25 -0800
Message-ID: <1352815405-751-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33618 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754781Ab2KMOED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 09:04:03 -0500
In-Reply-To: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch allows users to enable and disable EEE using Ethtool.
It also allows users to get EEE settings, as supported by the device.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_defines.h |   1 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c   | 100 +++++++++++++++++++++++++
 2 files changed, 101 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index e647cff..198d148 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -874,6 +874,7 @@
 #define E1000_EEER_FRC_AN            0x10000000  /* Enable EEE in loopback */
 #define E1000_EEER_LPI_FC            0x00040000  /* EEE Enable on FC */
 #define E1000_EEE_SU_LPI_CLK_STP     0X00800000  /* EEE LPI Clock Stop */
+#define E1000_EEER_EEE_NEG           0x20000000  /* EEE capability nego */
 
 /* SerDes Control */
 #define E1000_GEN_CTL_READY             0x80000000
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 2b82a53..0acf590 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2529,6 +2529,104 @@ static int igb_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	return ret;
 }
 
+static int igb_get_eee(struct net_device *netdev, struct ethtool_eee *edata)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ipcnfg, eeer;
+
+	if ((hw->mac.type < e1000_i350) ||
+	    (hw->phy.media_type != e1000_media_type_copper))
+		return -EOPNOTSUPP;
+
+	edata->supported = (SUPPORTED_1000baseT_Full |
+			    SUPPORTED_100baseT_Full);
+
+	ipcnfg = rd32(E1000_IPCNFG);
+	eeer = rd32(E1000_EEER);
+
+	/* EEE status on negotiated link */
+	if (ipcnfg & E1000_IPCNFG_EEE_1G_AN)
+		edata->advertised = ADVERTISED_1000baseT_Full;
+
+	if (ipcnfg & E1000_IPCNFG_EEE_100M_AN)
+		edata->advertised |= ADVERTISED_100baseT_Full;
+
+	if (eeer & E1000_EEER_EEE_NEG)
+		edata->eee_active = true;
+
+	edata->eee_enabled = !hw->dev_spec._82575.eee_disable;
+
+	if (eeer & E1000_EEER_TX_LPI_EN)
+		edata->tx_lpi_enabled = true;
+
+	/* Report correct negotiated EEE status for devices that
+	 * wrongly report EEE at half-duplex
+	 */
+	if (adapter->link_duplex == HALF_DUPLEX) {
+		edata->eee_enabled = false;
+		edata->eee_active = false;
+		edata->tx_lpi_enabled = false;
+		edata->advertised &= ~edata->advertised;
+	}
+
+	return 0;
+}
+
+static int igb_set_eee(struct net_device *netdev,
+		       struct ethtool_eee *edata)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	struct ethtool_eee eee_curr;
+	s32 ret_val;
+
+	if ((hw->mac.type < e1000_i350) ||
+	    (hw->phy.media_type != e1000_media_type_copper))
+		return -EOPNOTSUPP;
+
+	ret_val = igb_get_eee(netdev, &eee_curr);
+	if (ret_val)
+		return ret_val;
+
+	if (eee_curr.eee_enabled) {
+		if (eee_curr.tx_lpi_enabled != edata->tx_lpi_enabled) {
+			dev_err(&adapter->pdev->dev,
+				"Setting EEE tx-lpi is not supported\n");
+			return -EINVAL;
+		}
+
+		/* Tx LPI timer is not implemented currently */
+		if (edata->tx_lpi_timer) {
+			dev_err(&adapter->pdev->dev,
+				"Setting EEE Tx LPI timer is not supported\n");
+			return -EINVAL;
+		}
+
+		if (eee_curr.advertised != edata->advertised) {
+			dev_err(&adapter->pdev->dev,
+				"Setting EEE Advertisement is not supported\n");
+			return -EINVAL;
+		}
+
+	} else if (!edata->eee_enabled) {
+		dev_err(&adapter->pdev->dev,
+			"Setting EEE options are not supported with EEE disabled\n");
+			return -EINVAL;
+		}
+
+	if (hw->dev_spec._82575.eee_disable != !edata->eee_enabled) {
+		hw->dev_spec._82575.eee_disable = !edata->eee_enabled;
+		igb_set_eee_i350(hw);
+
+		/* reset link */
+		if (!netif_running(netdev))
+			igb_reset(adapter);
+	}
+
+	return 0;
+}
+
 static int igb_ethtool_begin(struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
@@ -2571,6 +2669,8 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.get_ts_info            = igb_get_ts_info,
 	.get_rxnfc		= igb_get_rxnfc,
 	.set_rxnfc		= igb_set_rxnfc,
+	.get_eee		= igb_get_eee,
+	.set_eee		= igb_set_eee,
 	.begin			= igb_ethtool_begin,
 	.complete		= igb_ethtool_complete,
 };
-- 
1.7.11.7
