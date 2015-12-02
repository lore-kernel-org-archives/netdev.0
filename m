From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/17] i40evf: add new fields to store user configuration of RSS
Date: Wed,  2 Dec 2015 00:25:26 -0800
Message-ID: <1449044735-68599-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Helin Zhang <helin.zhang@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52886 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757569AbbLBIZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 03:25:42 -0500
In-Reply-To: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Helin Zhang <helin.zhang@intel.com>

This patch adds new fields to i40e_vsi to store user configured
RSS config data and code to use it.

Change-ID: Ic5d3db8d9df52182b560248f8cdca9c5c7546879
Signed-off-by: Helin Zhang <helin.zhang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h         |  2 ++
 drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c | 31 ++++++++++--------
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 37 ++++++++++++++++++++--
 3 files changed, 54 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 5f2e61d..090c604 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -67,6 +67,8 @@ struct i40e_vsi {
 	u16 rx_itr_setting;
 	u16 tx_itr_setting;
 	u16 qs_handle;
+	u8 *rss_hkey_user; /* User configured hash keys */
+	u8 *rss_lut_user;  /* User configured lookup table entries */
 };
 
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
index a520970..966863c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c
@@ -678,9 +678,7 @@ static int i40evf_set_rxfh(struct net_device *netdev, const u32 *indir,
 {
 	struct i40evf_adapter *adapter = netdev_priv(netdev);
 	struct i40e_vsi *vsi = &adapter->vsi;
-	u8 seed_def[I40EVF_HKEY_ARRAY_SIZE];
-	u8 *seed = NULL, *lut;
-	int ret;
+	u8 *seed = NULL;
 	u16 i;
 
 	/* We do not allow change in unsupported parameters */
@@ -691,21 +689,28 @@ static int i40evf_set_rxfh(struct net_device *netdev, const u32 *indir,
 		return 0;
 
 	if (key) {
-		memcpy(seed_def, key, I40EVF_HKEY_ARRAY_SIZE);
-		seed = seed_def;
+		if (!vsi->rss_hkey_user) {
+			vsi->rss_hkey_user = kzalloc(I40EVF_HKEY_ARRAY_SIZE,
+						     GFP_KERNEL);
+			if (!vsi->rss_hkey_user)
+				return -ENOMEM;
+		}
+		memcpy(vsi->rss_hkey_user, key, I40EVF_HKEY_ARRAY_SIZE);
+		seed = vsi->rss_hkey_user;
+	}
+	if (!vsi->rss_lut_user) {
+		vsi->rss_lut_user = kzalloc(I40EVF_HLUT_ARRAY_SIZE,
+					    GFP_KERNEL);
+		if (!vsi->rss_lut_user)
+			return -ENOMEM;
 	}
-	lut = kzalloc(I40EVF_HLUT_ARRAY_SIZE, GFP_KERNEL);
-	if (!lut)
-		return -ENOMEM;
 
 	/* Each 32 bits pointed by 'indir' is stored with a lut entry */
 	for (i = 0; i < I40EVF_HLUT_ARRAY_SIZE; i++)
-		lut[i] = (u8)(indir[i]);
+		vsi->rss_lut_user[i] = (u8)(indir[i]);
 
-	ret = i40evf_config_rss(vsi, seed, lut, I40EVF_HLUT_ARRAY_SIZE);
-	kfree(lut);
-
-	return ret;
+	return i40evf_config_rss(vsi, seed, vsi->rss_lut_user,
+				 I40EVF_HLUT_ARRAY_SIZE);
 }
 
 static const struct ethtool_ops i40evf_ethtool_ops = {
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 68251fa..1cd5d5d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1453,9 +1453,21 @@ static int i40evf_init_rss(struct i40evf_adapter *adapter)
 	lut = kzalloc(I40EVF_HLUT_ARRAY_SIZE, GFP_KERNEL);
 	if (!lut)
 		return -ENOMEM;
-	i40evf_fill_rss_lut(lut, I40EVF_HLUT_ARRAY_SIZE,
-			    adapter->num_active_queues);
-	netdev_rss_key_fill((void *)seed, I40EVF_HKEY_ARRAY_SIZE);
+
+	/* Use user configured lut if there is one, otherwise use default */
+	if (vsi->rss_lut_user)
+		memcpy(lut, vsi->rss_lut_user, I40EVF_HLUT_ARRAY_SIZE);
+	else
+		i40evf_fill_rss_lut(lut, I40EVF_HLUT_ARRAY_SIZE,
+				    adapter->num_active_queues);
+
+	/* Use user configured hash key if there is one, otherwise
+	 * user default.
+	 */
+	if (vsi->rss_hkey_user)
+		memcpy(seed, vsi->rss_hkey_user, I40EVF_HKEY_ARRAY_SIZE);
+	else
+		netdev_rss_key_fill((void *)seed, I40EVF_HKEY_ARRAY_SIZE);
 	ret = i40evf_config_rss(vsi, seed, lut, I40EVF_HLUT_ARRAY_SIZE);
 	kfree(lut);
 
@@ -1583,6 +1595,22 @@ err_set_interrupt:
 }
 
 /**
+ * i40evf_clear_rss_config_user - Clear user configurations of RSS
+ * @vsi: Pointer to VSI structure
+ **/
+static void i40evf_clear_rss_config_user(struct i40e_vsi *vsi)
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
  * i40evf_watchdog_timer - Periodic call-back timer
  * @data: pointer to adapter disguised as unsigned long
  **/
@@ -2770,6 +2798,9 @@ static void i40evf_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
+	/* Clear user configurations for RSS */
+	i40evf_clear_rss_config_user(&adapter->vsi);
+
 	if (hw->aq.asq.count)
 		i40evf_shutdown_adminq(hw);
 
-- 
2.5.0
