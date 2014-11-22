From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/17] i40e: implement ethtool RSS config
Date: Fri, 21 Nov 2014 21:55:05 -0800
Message-ID: <1416635708-4765-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:15262 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbaKVFzT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 00:55:19 -0500
In-Reply-To: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Support ethtool methods for getting and setting the RSS look-up table.

Change-ID: I52707fb371fc11fe9fd4c287e08542cde38f79d4
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 104 +++++++++++++++++++++++++
 1 file changed, 104 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index fcd815d..f9f68ea 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2237,6 +2237,106 @@ static int i40e_set_channels(struct net_device *dev,
 		return -EINVAL;
 }
 
+#define I40E_HLUT_ARRAY_SIZE ((I40E_PFQF_HLUT_MAX_INDEX + 1) * 4)
+#define I40E_HKEY_ARRAY_SIZE ((I40E_PFQF_HKEY_MAX_INDEX * 1) * 4)
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
+/**
+ * i40e_get_rxfh - get the rx flow hash indirection table
+ * @netdev: network interface device structure
+ * @indir: indirection table
+ * @key: hash key
+ *
+ * Reads the indirection table directly from the hardware. Always returns 0.
+ **/
+static int i40e_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	u32 reg_val;
+	int i, j;
+
+	for (i = 0, j = 0; i <= I40E_PFQF_HLUT_MAX_INDEX; i++) {
+		reg_val = rd32(hw, I40E_PFQF_HLUT(i));
+		indir[j++] = reg_val & 0xff;
+		indir[j++] = (reg_val >> 8) & 0xff;
+		indir[j++] = (reg_val >> 16) & 0xff;
+		indir[j++] = (reg_val >> 24) & 0xff;
+	}
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
+			 const u8 *key)
+{
+	struct i40e_netdev_priv *np = netdev_priv(netdev);
+	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	u32 reg_val;
+	int i, j;
+
+	if (indir) {
+		for (i = 0, j = 0; i <= I40E_PFQF_HLUT_MAX_INDEX; i++) {
+			reg_val = indir[j++];
+			reg_val |= indir[j++] << 8;
+			reg_val |= indir[j++] << 16;
+			reg_val |= indir[j++] << 24;
+			wr32(hw, I40E_PFQF_HLUT(i), reg_val);
+		}
+	}
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
 static const struct ethtool_ops i40e_ethtool_ops = {
 	.get_settings		= i40e_get_settings,
 	.set_settings		= i40e_set_settings,
@@ -2265,6 +2365,10 @@ static const struct ethtool_ops i40e_ethtool_ops = {
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
