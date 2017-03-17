From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] igb: Add support for ethtool private flag to allow use of legacy Rx
Date: Fri, 17 Mar 2017 12:58:13 -0700
Message-ID: <20170317195818.74912-9-jeffrey.t.kirsher@intel.com>
References: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:63132 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751251AbdCQT61 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Mar 2017 15:58:27 -0400
In-Reply-To: <20170317195818.74912-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Since there are potential drawbacks to the new Rx allocation approach I
thought it best to add a "chicken bit" so that we can turn the feature off
if in the event that a problem is found.

It also provides a means of validating the legacy Rx path in the event that
we are forced to fall back.  At some point in the future when we are
convinced we don't need it anymore we might be able to drop the legacy-rx
flag.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |  1 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 48 ++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 6a88a08c021c..bffdfe65a0b6 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -557,6 +557,7 @@ struct igb_adapter {
 #define IGB_FLAG_HAS_MSIX		BIT(13)
 #define IGB_FLAG_EEE			BIT(14)
 #define IGB_FLAG_VLAN_PROMISC		BIT(15)
+#define IGB_FLAG_RX_LEGACY		BIT(16)
 
 /* Media Auto Sense */
 #define IGB_MAS_ENABLE_0		0X0001
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index d5966feb7b96..797b9daba224 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -144,6 +144,13 @@ static const char igb_gstrings_test[][ETH_GSTRING_LEN] = {
 };
 #define IGB_TEST_LEN (sizeof(igb_gstrings_test) / ETH_GSTRING_LEN)
 
+static const char igb_priv_flags_strings[][ETH_GSTRING_LEN] = {
+#define IGB_PRIV_FLAGS_LEGACY_RX	BIT(0)
+	"legacy-rx",
+};
+
+#define IGB_PRIV_FLAGS_STR_LEN ARRAY_SIZE(igb_priv_flags_strings)
+
 static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
@@ -852,6 +859,8 @@ static void igb_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
+
+	drvinfo->n_priv_flags = IGB_PRIV_FLAGS_STR_LEN;
 }
 
 static void igb_get_ringparam(struct net_device *netdev,
@@ -2280,6 +2289,8 @@ static int igb_get_sset_count(struct net_device *netdev, int sset)
 		return IGB_STATS_LEN;
 	case ETH_SS_TEST:
 		return IGB_TEST_LEN;
+	case ETH_SS_PRIV_FLAGS:
+		return IGB_PRIV_FLAGS_STR_LEN;
 	default:
 		return -ENOTSUPP;
 	}
@@ -2385,6 +2396,10 @@ static void igb_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 		}
 		/* BUG_ON(p - data != IGB_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
+	case ETH_SS_PRIV_FLAGS:
+		memcpy(data, igb_priv_flags_strings,
+		       IGB_PRIV_FLAGS_STR_LEN * ETH_GSTRING_LEN);
+		break;
 	}
 }
 
@@ -3397,6 +3412,37 @@ static int igb_set_channels(struct net_device *netdev,
 	return 0;
 }
 
+static u32 igb_get_priv_flags(struct net_device *netdev)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	u32 priv_flags = 0;
+
+	if (adapter->flags & IGB_FLAG_RX_LEGACY)
+		priv_flags |= IGB_PRIV_FLAGS_LEGACY_RX;
+
+	return priv_flags;
+}
+
+static int igb_set_priv_flags(struct net_device *netdev, u32 priv_flags)
+{
+	struct igb_adapter *adapter = netdev_priv(netdev);
+	unsigned int flags = adapter->flags;
+
+	flags &= ~IGB_FLAG_RX_LEGACY;
+	if (priv_flags & IGB_PRIV_FLAGS_LEGACY_RX)
+		flags |= IGB_FLAG_RX_LEGACY;
+
+	if (flags != adapter->flags) {
+		adapter->flags = flags;
+
+		/* reset interface to repopulate queues */
+		if (netif_running(netdev))
+			igb_reinit_locked(adapter);
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops igb_ethtool_ops = {
 	.get_settings		= igb_get_settings,
 	.set_settings		= igb_set_settings,
@@ -3435,6 +3481,8 @@ static const struct ethtool_ops igb_ethtool_ops = {
 	.set_rxfh		= igb_set_rxfh,
 	.get_channels		= igb_get_channels,
 	.set_channels		= igb_set_channels,
+	.get_priv_flags		= igb_get_priv_flags,
+	.set_priv_flags		= igb_set_priv_flags,
 	.begin			= igb_ethtool_begin,
 	.complete		= igb_ethtool_complete,
 };
-- 
2.12.0
