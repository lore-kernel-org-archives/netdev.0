From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/17] i40evf: create a generic get RSS function
Date: Wed,  2 Dec 2015 00:25:25 -0800
Message-ID: <1449044735-68599-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Helin Zhang <helin.zhang@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13263 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757551AbbLBIZl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 03:25:41 -0500
In-Reply-To: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helin Zhang <helin.zhang@intel.com>

There are two ways to get RSS, this patch implements two functions
with the same input parameters, and creates a more generic function
for getting RSS configuration.

Change-ID: I12d3b712c21455d47dd0a5aae58fc9b7c680db59
Signed-off-by: Helin Zhang <helin.zhang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  2 +
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 35 +++++---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 97 ++++++++++++++++++++++
 3 files changed, 121 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index b5aa377..5f2e61d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -316,4 +316,6 @@ void i40evf_virtchnl_completion(struct i40evf_adapter *adapter,
 				i40e_status v_retval, u8 *msg, u16 msglen);
 int i40evf_config_rss(struct i40e_vsi *vsi, const u8 *seed, u8 *lut,
 		      u16 lut_size);
+int i40evf_get_rss(struct i40e_vsi *vsi, const u8 *seed, u8 *lut,
+		   u16 lut_size);
 #endif /* _I40EVF_H_ */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index cf253df..a520970 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -634,25 +634,34 @@ static int i40evf_get_rxfh(struct net_device *netdev, u32 *indir, u8 *key,
 			   u8 *hfunc)
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
-	struct i40e_hw *hw = &adapter->hw;
-	u32 hlut_val;
-	int i, j;
+	struct i40e_vsi *vsi = &adapter->vsi;
+	u8 *seed = NULL, *lut;
+	int ret;
+	u16 i;
 
 	if (hfunc)
 		*hfunc = ETH_RSS_HASH_TOP;
 	if (!indir)
 		return 0;
 
-	if (indir) {
-		for (i = 0, j = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++) {
-			hlut_val = rd32(hw, I40E_VFQF_HLUT(i));
-			indir[j++] = hlut_val & 0xff;
-			indir[j++] = (hlut_val >> 8) & 0xff;
-			indir[j++] = (hlut_val >> 16) & 0xff;
-			indir[j++] = (hlut_val >> 24) & 0xff;
-		}
-	}
-	return 0;
+	seed = key;
+
+	lut = kzalloc(I40EVF_HLUT_ARRAY_SIZE, GFP_KERNEL);
+	if (!lut)
+		return -ENOMEM;
+
+	ret = i40evf_get_rss(vsi, seed, lut, I40EVF_HLUT_ARRAY_SIZE);
+	if (ret)
+		goto out;
+
+	/* Each 32 bits pointed by 'indir' is stored with a lut entry */
+	for (i = 0; i < I40EVF_HLUT_ARRAY_SIZE; i++)
+		indir[i] = (u32)lut[i];
+
+out:
+	kfree(lut);
+
+	return ret;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 63d7e47..68251fa 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1300,6 +1300,84 @@ static int i40evf_config_rss_reg(struct i40e_vsi *vsi, const u8 *seed,
 }
 
 /**
+ *  * i40evf_get_rss_aq - Get RSS keys and lut by using AQ commands
+ *  @vsi: Pointer to vsi structure
+ *  @seed: RSS hash seed
+ *  @lut: Lookup table
+ *  @lut_size: Lookup table size
+ *
+ *  Return 0 on success, negative on failure
+ **/
+static int i40evf_get_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
+			     u8 *lut, u16 lut_size)
+{
+	struct i40evf_adapter *adapter = vsi->back;
+	struct i40e_hw *hw = &adapter->hw;
+	int ret = 0;
+
+	if (seed) {
+		ret = i40evf_aq_get_rss_key(hw, vsi->id,
+			(struct i40e_aqc_get_set_rss_key_data *)seed);
+		if (ret) {
+			dev_err(&adapter->pdev->dev,
+				"Cannot get RSS key, err %s aq_err %s\n",
+				i40evf_stat_str(hw, ret),
+				i40evf_aq_str(hw, hw->aq.asq_last_status));
+			return ret;
+		}
+	}
+
+	if (lut) {
+		ret = i40evf_aq_get_rss_lut(hw, vsi->id, seed, lut, lut_size);
+		if (ret) {
+			dev_err(&adapter->pdev->dev,
+				"Cannot get RSS lut, err %s aq_err %s\n",
+				i40evf_stat_str(hw, ret),
+				i40evf_aq_str(hw, hw->aq.asq_last_status));
+			return ret;
+		}
+	}
+
+	return ret;
+}
+
+/**
+ *  * i40evf_get_rss_reg - Get RSS keys and lut by reading registers
+ *  @vsi: Pointer to vsi structure
+ *  @seed: RSS hash seed
+ *  @lut: Lookup table
+ *  @lut_size: Lookup table size
+ *
+ *  Returns 0 on success, negative on failure
+ **/
+static int i40evf_get_rss_reg(struct i40e_vsi *vsi, const u8 *seed,
+			      const u8 *lut, u16 lut_size)
+{
+	struct i40evf_adapter *adapter = vsi->back;
+	struct i40e_hw *hw = &adapter->hw;
+	u16 i;
+
+	if (seed) {
+		u32 *seed_dw = (u32 *)seed;
+
+		for (i = 0; i <= I40E_VFQF_HKEY_MAX_INDEX; i++)
+			seed_dw[i] = rd32(hw, I40E_VFQF_HKEY(i));
+	}
+
+	if (lut) {
+		u32 *lut_dw = (u32 *)lut;
+
+		if (lut_size != I40EVF_HLUT_ARRAY_SIZE)
+			return -EINVAL;
+
+		for (i = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++)
+			lut_dw[i] = rd32(hw, I40E_VFQF_HLUT(i));
+	}
+
+	return 0;
+}
+
+/**
  * i40evf_config_rss - Configure RSS keys and lut
  * @vsi: Pointer to vsi structure
  * @seed: RSS hash seed
@@ -1320,6 +1398,25 @@ int i40evf_config_rss(struct i40e_vsi *vsi, const u8 *seed,
 }
 
 /**
+ * i40evf_get_rss - Get RSS keys and lut
+ * @vsi: Pointer to vsi structure
+ * @seed: RSS hash seed
+ * @lut: Lookup table
+ * @lut_size: Lookup table size
+ *
+ * Returns 0 on success, negative on failure
+ **/
+int i40evf_get_rss(struct i40e_vsi *vsi, const u8 *seed, u8 *lut, u16 lut_size)
+{
+	struct i40evf_adapter *adapter = vsi->back;
+
+	if (RSS_AQ(adapter))
+		return i40evf_get_rss_aq(vsi, seed, lut, lut_size);
+	else
+		return i40evf_get_rss_reg(vsi, seed, lut, lut_size);
+}
+
+/**
  * i40evf_fill_rss_lut - Fill the lut with default values
  * @lut: Lookup table to be filled with
  * @rss_table_size: Lookup table size
-- 
2.5.0
