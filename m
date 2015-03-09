From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 9/9] i40e: add ethtool RSS support
Date: Mon,  9 Mar 2015 10:55:42 -0700
Message-ID: <1425923742-4488-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch A Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56922 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753458AbbCIRzr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 13:55:47 -0400
In-Reply-To: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch A Williams <mitch.a.williams@intel.com>

Add support for setting the RSS hash table and hash key through ethtool.
This patch incorporates suggestions from Ben Hutchings
<ben.hutchings@codethink.co.uk>.

Reported-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |   2 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 108 +++++++++++++++++++++++++
 2 files changed, 110 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index cc3f236..1c8bd7c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -177,6 +177,8 @@ struct i40e_lump_tracking {
 #define I40E_FDIR_BUFFER_HEAD_ROOM	32
 #define I40E_FDIR_BUFFER_HEAD_ROOM_FOR_ATR (I40E_FDIR_BUFFER_HEAD_ROOM * 4)
 
+#define I40E_HKEY_ARRAY_SIZE ((I40E_PFQF_HKEY_MAX_INDEX + 1) * 4)
+
 enum i40e_fd_stat_idx {
 	I40E_FD_STAT_ATR,
 	I40E_FD_STAT_SB,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 9ff3dc1..b7d0aaa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2375,6 +2375,110 @@ static int i40e_set_channels(struct net_device *dev,
 		return -EINVAL;
 }
 
+#define I40E_HLUT_ARRAY_SIZE ((I40E_PFQF_HLUT_MAX_INDEX + 1) * 4)
+/**
+ * i40e_get_rxfh_key_size - get the RSS hash key size
+ * @netdev: network interface device structure
+ *
+ * Returns the table size.
+ **/
+static u32 i40e_get_rxfh_key_size(struct net_device *netdev)
+{
+	return I40E_HKEY_ARRAY_SIZE;
+}
+
+/**
+ * i40e_get_rxfh_indir_size - get the rx flow hash indirection table size
+ * @netdev: network interface device structure
+ *
+ * Returns the table size.
+ **/
+static u32 i40e_get_rxfh_indir_size(struct net_device *netdev)
+{
+	return I40E_HLUT_ARRAY_SIZE;
+}
+
+static int i40e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
+			 u8 *hfunc)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	u32 reg_val;
+	int i, j;
+
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_TOP;
+
+	if (!indir)
+		return 0;
+
+	for (i = 0, j = 0; i <= I40E_PFQF_HLUT_MAX_INDEX; i++) {
+		reg_val = rd32(hw, I40E_PFQF_HLUT(i));
+		indir[j++] = reg_val & 0xff;
+		indir[j++] = (reg_val >> 8) & 0xff;
+		indir[j++] = (reg_val >> 16) & 0xff;
+		indir[j++] = (reg_val >> 24) & 0xff;
+	}
+
+	if (key) {
+		for (i = 0, j = 0; i <= I40E_PFQF_HKEY_MAX_INDEX; i++) {
+			reg_val = rd32(hw, I40E_PFQF_HKEY(i));
+			key[j++] = (u8)(reg_val & 0xff);
+			key[j++] = (u8)((reg_val >> 8) & 0xff);
+			key[j++] = (u8)((reg_val >> 16) & 0xff);
+			key[j++] = (u8)((reg_val >> 24) & 0xff);
+		}
+	}
+	return 0;
+}
+
+/**
+ * i40e_set_rxfh - set the rx flow hash indirection table
+ * @netdev: network interface device structure
+ * @indir: indirection table
+ * @key: hash key
+ *
+ * Returns -EINVAL if the table specifies an inavlid queue id, otherwise
+ * returns 0 after programming the table.
+ **/
+static int i40e_set_rxfh(struct net_device *netdev, const u32 *indir,
+			 const u8 *key, const u8 hfunc)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	u32 reg_val;
+	int i, j;
+
+	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
+		return -EOPNOTSUPP;
+
+	if (!indir)
+		return 0;
+
+	for (i = 0, j = 0; i <= I40E_PFQF_HLUT_MAX_INDEX; i++) {
+		reg_val = indir[j++];
+		reg_val |= indir[j++] << 8;
+		reg_val |= indir[j++] << 16;
+		reg_val |= indir[j++] << 24;
+		wr32(hw, I40E_PFQF_HLUT(i), reg_val);
+	}
+
+	if (key) {
+		for (i = 0, j = 0; i <= I40E_PFQF_HKEY_MAX_INDEX; i++) {
+			reg_val = key[j++];
+			reg_val |= key[j++] << 8;
+			reg_val |= key[j++] << 16;
+			reg_val |= key[j++] << 24;
+			wr32(hw, I40E_PFQF_HKEY(i), reg_val);
+		}
+	}
+	return 0;
+}
+
 /**
  * i40e_get_priv_flags - report device private flags
  * @dev: network interface device structure
@@ -2426,6 +2530,10 @@ static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_ethtool_stats	= i40e_get_ethtool_stats,
 	.get_coalesce		= i40e_get_coalesce,
 	.set_coalesce		= i40e_set_coalesce,
+	.get_rxfh_key_size	= i40e_get_rxfh_key_size,
+	.get_rxfh_indir_size	= i40e_get_rxfh_indir_size,
+	.get_rxfh		= i40e_get_rxfh,
+	.set_rxfh		= i40e_set_rxfh,
 	.get_channels		= i40e_get_channels,
 	.set_channels		= i40e_set_channels,
 	.get_ts_info		= i40e_get_ts_info,
-- 
1.9.3
