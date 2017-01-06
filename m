From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: [next PATCH 09/11] ixgbe: Add private flag to control buffer mode
Date: Fri, 06 Jan 2017 08:07:37 -0800
Message-ID: <20170106160735.1501.50042.stgit@localhost.localdomain>
References: <20170106155448.1501.31298.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36219 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967113AbdAFQHo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 11:07:44 -0500
Received: by mail-pg0-f67.google.com with SMTP id 75so6191272pgf.3
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 08:07:44 -0800 (PST)
In-Reply-To: <20170106155448.1501.31298.stgit@localhost.localdomain>
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
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   47 ++++++++++++++++++++++
 1 file changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index aa80ece9ea96..6466d828bc6f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -151,6 +151,13 @@ struct ixgbe_stats {
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
@@ -1002,6 +1009,8 @@ static void ixgbe_get_drvinfo(struct net_device *netdev,
 
 	strlcpy(drvinfo->bus_info, pci_name(adapter->pdev),
 		sizeof(drvinfo->bus_info));
+
+	drvinfo->n_priv_flags = IXGBE_PRIV_FLAGS_STR_LEN;
 }
 
 static void ixgbe_get_ringparam(struct net_device *netdev,
@@ -1141,6 +1150,8 @@ static int ixgbe_get_sset_count(struct net_device *netdev, int sset)
 		return IXGBE_TEST_LEN;
 	case ETH_SS_STATS:
 		return IXGBE_STATS_LEN;
+	case ETH_SS_PRIV_FLAGS:
+		return IXGBE_PRIV_FLAGS_STR_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -1305,6 +1316,9 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 		}
 		/* BUG_ON(p - data != IXGBE_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
+	case ETH_SS_PRIV_FLAGS:
+		memcpy(data, ixgbe_priv_flags_strings,
+		       IXGBE_PRIV_FLAGS_STR_LEN * ETH_GSTRING_LEN);
 	}
 }
 
@@ -3386,6 +3400,37 @@ static int ixgbe_set_eee(struct net_device *netdev, struct ethtool_eee *edata)
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
@@ -3422,6 +3467,8 @@ static int ixgbe_set_eee(struct net_device *netdev, struct ethtool_eee *edata)
 	.set_eee		= ixgbe_set_eee,
 	.get_channels		= ixgbe_get_channels,
 	.set_channels		= ixgbe_set_channels,
+	.get_priv_flags		= ixgbe_get_priv_flags,
+	.set_priv_flags		= ixgbe_set_priv_flags,
 	.get_ts_info		= ixgbe_get_ts_info,
 	.get_module_info	= ixgbe_get_module_info,
 	.get_module_eeprom	= ixgbe_get_module_eeprom,
