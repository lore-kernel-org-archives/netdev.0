From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/20] i40e: Extend ethtool RSS hooks for X722
Date: Thu,  4 Feb 2016 03:49:02 -0800
Message-ID: <1454586551-35919-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:41087 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965694AbcBDLtQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:16 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This patch adds another way to access the RSS keys and lut using the AQ
for X722 devices.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 53 ++++++++++++++++++++++++++++-
 1 file changed, 52 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b3e671b..bd81a97 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7937,6 +7937,52 @@ static int i40e_vsi_config_rss(struct i40e_vsi *vsi)
 }
 
 /**
+ * i40e_get_rss_aq - Get RSS keys and lut by using AQ commands
+ * @vsi: Pointer to vsi structure
+ * @seed: Buffer to store the hash keys
+ * @lut: Buffer to store the lookup table entries
+ * @lut_size: Size of buffer to store the lookup table entries
+ *
+ * Return 0 on success, negative on failure
+ */
+static int i40e_get_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
+			   u8 *lut, u16 lut_size)
+{
+	struct i40e_pf *pf = vsi->back;
+	struct i40e_hw *hw = &pf->hw;
+	int ret = 0;
+
+	if (seed) {
+		ret = i40e_aq_get_rss_key(hw, vsi->id,
+			(struct i40e_aqc_get_set_rss_key_data *)seed);
+		if (ret) {
+			dev_info(&pf->pdev->dev,
+				 "Cannot get RSS key, err %s aq_err %s\n",
+				 i40e_stat_str(&pf->hw, ret),
+				 i40e_aq_str(&pf->hw,
+					     pf->hw.aq.asq_last_status));
+			return ret;
+		}
+	}
+
+	if (lut) {
+		bool pf_lut = vsi->type == I40E_VSI_MAIN ? true : false;
+
+		ret = i40e_aq_get_rss_lut(hw, vsi->id, pf_lut, lut, lut_size);
+		if (ret) {
+			dev_info(&pf->pdev->dev,
+				 "Cannot get RSS lut, err %s aq_err %s\n",
+				 i40e_stat_str(&pf->hw, ret),
+				 i40e_aq_str(&pf->hw,
+					     pf->hw.aq.asq_last_status));
+			return ret;
+		}
+	}
+
+	return ret;
+}
+
+/**
  * i40e_config_rss_reg - Configure RSS keys and lut by writing registers
  * @vsi: Pointer to vsi structure
  * @seed: RSS hash seed
@@ -8038,7 +8084,12 @@ int i40e_config_rss(struct i40e_vsi *vsi, u8 *seed, u8 *lut, u16 lut_size)
  */
 int i40e_get_rss(struct i40e_vsi *vsi, u8 *seed, u8 *lut, u16 lut_size)
 {
-	return i40e_get_rss_reg(vsi, seed, lut, lut_size);
+	struct i40e_pf *pf = vsi->back;
+
+	if (pf->flags & I40E_FLAG_RSS_AQ_CAPABLE)
+		return i40e_get_rss_aq(vsi, seed, lut, lut_size);
+	else
+		return i40e_get_rss_reg(vsi, seed, lut, lut_size);
 }
 
 /**
-- 
2.5.0
