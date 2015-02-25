From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: Use ethtool private flags to display NPAR status
Date: Wed, 25 Feb 2015 00:58:38 -0800
Message-ID: <1424854720-18825-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:20292 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841AbbBYI6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 03:58:50 -0500
In-Reply-To: <1424854720-18825-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Allow an application to query the i40e driver's private flags to get the
status of NPAR enablement.  This will be used by applications to determine
if there are NPAR specific features available.

Change-ID: Ia6d9477a48f9c4cb41ca022bd433f77da3f2146c
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  3 ++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 41 ++++++++++++++++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 71092a9..1e9576b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -96,6 +96,9 @@
 #define I40E_QUEUE_WAIT_RETRY_LIMIT   10
 #define I40E_INT_NAME_STR_LEN        (IFNAMSIZ + 9)
 
+/* Ethtool Private Flags */
+#define I40E_PRIV_FLAGS_NPAR_FLAG	(1 << 0)
+
 #define I40E_NVM_VERSION_LO_SHIFT  0
 #define I40E_NVM_VERSION_LO_MASK   (0xff << I40E_NVM_VERSION_LO_SHIFT)
 #define I40E_NVM_VERSION_HI_SHIFT  12
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 5ef77dd..309bd1c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -217,6 +217,13 @@ static const char i40e_gstrings_test[][ETH_GSTRING_LEN] = {
 
 #define I40E_TEST_LEN (sizeof(i40e_gstrings_test) / ETH_GSTRING_LEN)
 
+static const char i40e_priv_flags_strings[][ETH_GSTRING_LEN] = {
+	"NPAR",
+};
+
+#define I40E_PRIV_FLAGS_STR_LEN \
+	(sizeof(i40e_priv_flags_strings) / ETH_GSTRING_LEN)
+
 /**
  * i40e_partition_setting_complaint - generic complaint for MFP restriction
  * @pf: the PF struct
@@ -1036,6 +1043,7 @@ static void i40e_get_drvinfo(struct net_device *netdev,
 		sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, pci_name(pf->pdev),
 		sizeof(drvinfo->bus_info));
+	drvinfo->n_priv_flags = I40E_PRIV_FLAGS_STR_LEN;
 }
 
 static void i40e_get_ringparam(struct net_device *netdev,
@@ -1223,6 +1231,8 @@ static int i40e_get_sset_count(struct net_device *netdev, int sset)
 		} else {
 			return I40E_VSI_STATS_LEN(netdev);
 		}
+	case ETH_SS_PRIV_FLAGS:
+		return I40E_PRIV_FLAGS_STR_LEN;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -1396,6 +1406,13 @@ static void i40e_get_strings(struct net_device *netdev, u32 stringset,
 		}
 		/* BUG_ON(p - data != I40E_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
+	case ETH_SS_PRIV_FLAGS:
+		for (i = 0; i < I40E_PRIV_FLAGS_STR_LEN; i++) {
+			memcpy(data, i40e_priv_flags_strings[i],
+			       ETH_GSTRING_LEN);
+			data += ETH_GSTRING_LEN;
+		}
+		break;
 	}
 }
 
@@ -2341,6 +2358,29 @@ static int i40e_set_channels(struct net_device *dev,
 		return -EINVAL;
 }
 
+/**
+ * i40e_get_priv_flags - report device private flags
+ * @dev: network interface device structure
+ *
+ * The get string set count and the string set should be matched for each
+ * flag returned.  Add new strings for each flag to the i40e_priv_flags_strings
+ * array.
+ *
+ * Returns a u32 bitmap of flags.
+ **/
+u32 i40e_get_priv_flags(struct net_device *dev)
+{
+	struct i40e_netdev_priv *np = netdev_priv(dev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	u32 ret_flags = 0;
+
+	ret_flags |= pf->hw.func_caps.npar_enable ?
+		I40E_PRIV_FLAGS_NPAR_FLAG : 0;
+
+	return ret_flags;
+}
+
 static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_settings		= i40e_get_settings,
 	.set_settings		= i40e_set_settings,
@@ -2372,6 +2412,7 @@ static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_channels		= i40e_get_channels,
 	.set_channels		= i40e_set_channels,
 	.get_ts_info		= i40e_get_ts_info,
+	.get_priv_flags		= i40e_get_priv_flags,
 };
 
 void i40e_set_ethtool_ops(struct net_device *netdev)
-- 
1.9.3
