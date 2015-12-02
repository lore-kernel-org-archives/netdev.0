From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/17] i40e: add new fields to store user configuration
Date: Wed,  2 Dec 2015 00:25:19 -0800
Message-ID: <1449044735-68599-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Helin Zhang <helin.zhang@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:44579 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755759AbbLBIZk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 03:25:40 -0500
In-Reply-To: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helin Zhang <helin.zhang@intel.com>

This patch adds new fields to i40e_vsi to store user configured
RSS config data and code to use it.

Change-ID: I73886469dca9e9f6b16d842182a87f3f4009f95d
Signed-off-by: Helin Zhang <helin.zhang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  2 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 31 +++++++++------
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 52 +++++++++++++++++++++++---
 3 files changed, 68 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 89f5323..6efab66 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -508,6 +508,8 @@ struct i40e_vsi {
 
 	u16 rss_table_size;
 	u16 rss_size;
+	u8  *rss_hkey_user; /* User configured hash keys */
+	u8  *rss_lut_user;  /* User configured lookup table entries */
 
 	u16 max_frame;
 	u16 rx_hdr_len;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 6cb2b34..b52c509 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2651,10 +2651,8 @@ static int i40e_set_rxfh(struct net_device *netdev, const u32 *indir,
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
-	u8 seed_def[I40E_HKEY_ARRAY_SIZE];
-	u8 *lut, *seed = NULL;
+	u8 *seed = NULL;
 	u16 i;
-	int ret;
 
 	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
 		return -EOPNOTSUPP;
@@ -2663,18 +2661,27 @@ static int i40e_set_rxfh(struct net_device *netdev, const u32 *indir,
 		return 0;
 
 	if (key) {
-		memcpy(seed_def, key, I40E_HKEY_ARRAY_SIZE);
-		seed = seed_def;
+		if (!vsi->rss_hkey_user) {
+			vsi->rss_hkey_user = kzalloc(I40E_HKEY_ARRAY_SIZE,
+						     GFP_KERNEL);
+			if (!vsi->rss_hkey_user)
+				return -ENOMEM;
+		}
+		memcpy(vsi->rss_hkey_user, key, I40E_HKEY_ARRAY_SIZE);
+		seed = vsi->rss_hkey_user;
 	}
-	lut = kzalloc(I40E_HLUT_ARRAY_SIZE, GFP_KERNEL);
-	if (!lut)
-		return -ENOMEM;
+	if (!vsi->rss_lut_user) {
+		vsi->rss_lut_user = kzalloc(I40E_HLUT_ARRAY_SIZE, GFP_KERNEL);
+		if (!vsi->rss_lut_user)
+			return -ENOMEM;
+	}
+
+	/* Each 32 bits pointed by 'indir' is stored with a lut entry */
 	for (i = 0; i < I40E_HLUT_ARRAY_SIZE; i++)
-		lut[i] = (u8)(indir[i]);
-	ret = i40e_config_rss(vsi, seed, lut, I40E_HLUT_ARRAY_SIZE);
-	kfree(lut);
+		vsi->rss_lut_user[i] = (u8)(indir[i]);
 
-	return ret;
+	return i40e_config_rss(vsi, seed, vsi->rss_lut_user,
+			       I40E_HLUT_ARRAY_SIZE);
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4b7d874..c0a784f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7301,6 +7301,23 @@ static void i40e_vsi_free_arrays(struct i40e_vsi *vsi, bool free_qvectors)
 }
 
 /**
+ * i40e_clear_rss_config_user - clear the user configured RSS hash keys
+ * and lookup table
+ * @vsi: Pointer to VSI structure
+ */
+static void i40e_clear_rss_config_user(struct i40e_vsi *vsi)
+{
+	if (!vsi)
+		return;
+
+	kfree(vsi->rss_hkey_user);
+	vsi->rss_hkey_user = NULL;
+
+	kfree(vsi->rss_lut_user);
+	vsi->rss_lut_user = NULL;
+}
+
+/**
  * i40e_vsi_clear - Deallocate the VSI provided
  * @vsi: the VSI being un-configured
  **/
@@ -7337,6 +7354,7 @@ static int i40e_vsi_clear(struct i40e_vsi *vsi)
 	i40e_put_lump(pf->irq_pile, vsi->base_vector, vsi->idx);
 
 	i40e_vsi_free_arrays(vsi, true);
+	i40e_clear_rss_config_user(vsi);
 
 	pf->vsi[vsi->idx] = NULL;
 	if (vsi->idx < pf->next_vsi)
@@ -8015,8 +8033,6 @@ static int i40e_pf_config_rss(struct i40e_pf *pf)
 	wr32(hw, I40E_PFQF_HENA(0), (u32)hena);
 	wr32(hw, I40E_PFQF_HENA(1), (u32)(hena >> 32));
 
-	vsi->rss_size = min_t(int, pf->rss_size, vsi->num_queue_pairs);
-
 	/* Determine the RSS table size based on the hardware capabilities */
 	reg_val = rd32(hw, I40E_PFQF_CTL_0);
 	reg_val = (pf->rss_table_size == 512) ?
@@ -8024,15 +8040,28 @@ static int i40e_pf_config_rss(struct i40e_pf *pf)
 			(reg_val & ~I40E_PFQF_CTL_0_HASHLUTSIZE_512);
 	wr32(hw, I40E_PFQF_CTL_0, reg_val);
 
+	/* Determine the RSS size of the VSI */
+	if (!vsi->rss_size)
+		vsi->rss_size = min_t(int, pf->rss_size, vsi->num_queue_pairs);
+
 	lut = kzalloc(vsi->rss_table_size, GFP_KERNEL);
 	if (!lut)
 		return -ENOMEM;
 
-	i40e_fill_rss_lut(pf, lut, vsi->rss_table_size, vsi->rss_size);
+	/* Use user configured lut if there is one, otherwise use default */
+	if (vsi->rss_lut_user)
+		memcpy(lut, vsi->rss_lut_user, vsi->rss_table_size);
+	else
+		i40e_fill_rss_lut(pf, lut, vsi->rss_table_size, vsi->rss_size);
 
-	netdev_rss_key_fill((void *)seed, I40E_HKEY_ARRAY_SIZE);
+	/* Use user configured hash key if there is one, otherwise
+	 * use default.
+	 */
+	if (vsi->rss_hkey_user)
+		memcpy(seed, vsi->rss_hkey_user, I40E_HKEY_ARRAY_SIZE);
+	else
+		netdev_rss_key_fill((void *)seed, I40E_HKEY_ARRAY_SIZE);
 	ret = i40e_config_rss(vsi, seed, lut, vsi->rss_table_size);
-
 	kfree(lut);
 
 	return ret;
@@ -8063,6 +8092,19 @@ int i40e_reconfig_rss_queues(struct i40e_pf *pf, int queue_count)
 		pf->rss_size = new_rss_size;
 
 		i40e_reset_and_rebuild(pf, true);
+
+		/* Discard the user configured hash keys and lut, if less
+		 * queues are enabled.
+		 */
+		if (queue_count < vsi->rss_size) {
+			i40e_clear_rss_config_user(vsi);
+			dev_dbg(&pf->pdev->dev,
+				"discard user configured hash keys and lut\n");
+		}
+
+		/* Reset vsi->rss_size, as number of enabled queues changed */
+		vsi->rss_size = min_t(int, pf->rss_size, vsi->num_queue_pairs);
+
 		i40e_pf_config_rss(pf);
 	}
 	dev_info(&pf->pdev->dev, "RSS count:  %d\n", pf->rss_size);
-- 
2.5.0
