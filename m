From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] i40e: limit WoL and link settings to partition 1
Date: Tue, 13 Jan 2015 03:33:29 -0800
Message-ID: <1421148811-9763-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:65096 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752359AbbAMLdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 06:33:39 -0500
In-Reply-To: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

When in multi-function mode, e.g. Dell's NPAR, only partition 1
of each MAC is allowed to set WoL, speed, and flow control.

Change-ID: I87a9debc7479361c55a71f0120294ea319f23588
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 43 +++++++++++++++++++++++++-
 1 file changed, 42 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 951e876..b8230dc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -219,6 +219,16 @@ static const char i40e_gstrings_test[][ETH_GSTRING_LEN] = {
 #define I40E_TEST_LEN (sizeof(i40e_gstrings_test) / ETH_GSTRING_LEN)
 
 /**
+ * i40e_partition_setting_complaint - generic complaint for MFP restriction
+ * @pf: the PF struct
+ **/
+static void i40e_partition_setting_complaint(struct i40e_pf *pf)
+{
+	dev_info(&pf->pdev->dev,
+		 "The link settings are allowed to be changed only from the first partition of a given port. Please switch to the first partition in order to change the setting.\n");
+}
+
+/**
  * i40e_get_settings - Get Link Speed and Duplex settings
  * @netdev: network interface device structure
  * @ecmd: ethtool command
@@ -485,6 +495,14 @@ static int i40e_set_settings(struct net_device *netdev,
 	u8 autoneg;
 	u32 advertise;
 
+	/* Changing port settings is not supported if this isn't the
+	 * port's controlling PF
+	 */
+	if (hw->partition_id != 1) {
+		i40e_partition_setting_complaint(pf);
+		return -EOPNOTSUPP;
+	}
+
 	if (vsi != pf->vsi[pf->lan_vsi])
 		return -EOPNOTSUPP;
 
@@ -687,6 +705,14 @@ static int i40e_set_pauseparam(struct net_device *netdev,
 	u8 aq_failures;
 	int err = 0;
 
+	/* Changing the port's flow control is not supported if this isn't the
+	 * port's controlling PF
+	 */
+	if (hw->partition_id != 1) {
+		i40e_partition_setting_complaint(pf);
+		return -EOPNOTSUPP;
+	}
+
 	if (vsi != pf->vsi[pf->lan_vsi])
 		return -EOPNOTSUPP;
 
@@ -1503,7 +1529,7 @@ static void i40e_get_wol(struct net_device *netdev,
 
 	/* NVM bit on means WoL disabled for the port */
 	i40e_read_nvm_word(hw, I40E_SR_NVM_WAKE_ON_LAN, &wol_nvm_bits);
-	if ((1 << hw->port) & wol_nvm_bits) {
+	if ((1 << hw->port) & wol_nvm_bits || hw->partition_id != 1) {
 		wol->supported = 0;
 		wol->wolopts = 0;
 	} else {
@@ -1512,13 +1538,28 @@ static void i40e_get_wol(struct net_device *netdev,
 	}
 }
 
+/**
+ * i40e_set_wol - set the WakeOnLAN configuration
+ * @netdev: the netdev in question
+ * @wol: the ethtool WoL setting data
+ **/
 static int i40e_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_pf *pf = np->vsi->back;
+	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_hw *hw = &pf->hw;
 	u16 wol_nvm_bits;
 
+	/* WoL not supported if this isn't the controlling PF on the port */
+	if (hw->partition_id != 1) {
+		i40e_partition_setting_complaint(pf);
+		return -EOPNOTSUPP;
+	}
+
+	if (vsi != pf->vsi[pf->lan_vsi])
+		return -EOPNOTSUPP;
+
 	/* NVM bit on means WoL disabled for the port */
 	i40e_read_nvm_word(hw, I40E_SR_NVM_WAKE_ON_LAN, &wol_nvm_bits);
 	if (((1 << hw->port) & wol_nvm_bits))
-- 
1.9.3
