From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] ixgbe: Add private flag to control buffer mode
Date: Thu, 16 Feb 2017 04:50:39 -0800
Message-ID: <20170216125041.46668-13-jeffrey.t.kirsher@intel.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:29436 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754277AbdBPMut (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:49 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
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
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 47 ++++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 51a1695a75ee..68500881cbc0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -151,6 +151,13 @@ static const char ixgbe_gstrings_test[][ETH_GSTRING_LEN] = {
 };
 #define IXGBE_TEST_LEN sizeof(ixgbe_gstrings_test) / ETH_GSTRING_LEN
 
+static const char ixgbe_priv_flags_strings[][ETH_GSTRING_LEN] = {
+#define IXGBE_PRIV_FLAGS_LEGACY_RX	BIT(0)
+	"legacy-rx",
+};
+
+#define IXGBE_PRIV_FLAGS_STR_LEN ARRAY_SIZE(ixgbe_priv_flags_strings)
+
 /* currently supported speeds for 10G */
 #define ADVRTSD_MSK_10G (SUPPORTED_10000baseT_Full | \
 			 SUPPORTED_10000baseKX4_Full | \
@@ -1001,6 +1008,8 @@ static void ixgbe_get_drvinfo(struct net_device *netdev,
 
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
+
+	drvinfo->n_priv_flags = IXGBE_PRIV_FLAGS_STR_LEN;
 }
 
 static void ixgbe_get_ringparam(struct net_device *netdev,
@@ -1140,6 +1149,8 @@ static int ixgbe_get_sset_count(struct net_device *netdev, int sset)
 		return IXGBE_TEST_LEN;
 	case ETH_SS_STATS:
 		return IXGBE_STATS_LEN;
+	case ETH_SS_PRIV_FLAGS:
+		return IXGBE_PRIV_FLAGS_STR_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -1264,6 +1275,9 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 		}
 		/* BUG_ON(p - data != IXGBE_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
+	case ETH_SS_PRIV_FLAGS:
+		memcpy(data, ixgbe_priv_flags_strings,
+		       IXGBE_PRIV_FLAGS_STR_LEN * ETH_GSTRING_LEN);
 	}
 }
 
@@ -3345,6 +3359,37 @@ static int ixgbe_set_eee(struct net_device *netdev, struct ethtool_eee *edata)
 	return 0;
 }
 
+static u32 ixgbe_get_priv_flags(struct net_device *netdev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	u32 priv_flags = 0;
+
+	if (adapter->flags2 & IXGBE_FLAG2_RX_LEGACY)
+		priv_flags |= IXGBE_PRIV_FLAGS_LEGACY_RX;
+
+	return priv_flags;
+}
+
+static int ixgbe_set_priv_flags(struct net_device *netdev, u32 priv_flags)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	unsigned int flags2 = adapter->flags2;
+
+	flags2 &= ~IXGBE_FLAG2_RX_LEGACY;
+	if (priv_flags & IXGBE_PRIV_FLAGS_LEGACY_RX)
+		flags2 |= IXGBE_FLAG2_RX_LEGACY;
+
+	if (flags2 != adapter->flags2) {
+		adapter->flags2 = flags2;
+
+		/* reset interface to repopulate queues */
+		if (netif_running(netdev))
+			ixgbe_reinit_locked(adapter);
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
 	.set_settings           = ixgbe_set_settings,
@@ -3381,6 +3426,8 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_eee		= ixgbe_set_eee,
 	.get_channels		= ixgbe_get_channels,
 	.set_channels		= ixgbe_set_channels,
+	.get_priv_flags		= ixgbe_get_priv_flags,
+	.set_priv_flags		= ixgbe_set_priv_flags,
 	.get_ts_info		= ixgbe_get_ts_info,
 	.get_module_info	= ixgbe_get_module_info,
 	.get_module_eeprom	= ixgbe_get_module_eeprom,
-- 
2.11.0
