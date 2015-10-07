From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/18] i40e: fix bug in return from get_link_status and avoid spurious link messages
Date: Wed,  7 Oct 2015 15:47:07 -0700
Message-ID: <1444258032-41476-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:8249 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753735AbbJGWrZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2015 18:47:25 -0400
In-Reply-To: <1444258032-41476-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Previously, the driver could call this function and have only true/false
returned, but false could mean multiple things like failure to read
or link was down. This change allows the caller to get all return values
in the call chain bubbled back to the source, which keeps information about
failures from being lost.

Also, in some unlikely scenarios, the firmware can become slow to respond
to admin queue (AQ) queries for link state.  Should the AQ time out,
the driver can detect the state and avoid a link change when there
may have been none.

Change-ID: Ib2ac38407b7880750fb891b392fa77457fe6c21c
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c    | 15 ++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c   | 11 ++++++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c      | 12 ++++++++++--
 drivers/net/ethernet/intel/i40e/i40e_prototype.h |  2 +-
 4 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 7a70abc..2839ea5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2235,27 +2235,28 @@ i40e_status i40e_aq_send_driver_version(struct i40e_hw *hw,
 /**
  * i40e_get_link_status - get status of the HW network link
  * @hw: pointer to the hw struct
+ * @link_up: pointer to bool (true/false = linkup/linkdown)
  *
- * Returns true if link is up, false if link is down.
+ * Variable link_up true if link is up, false if link is down.
+ * The variable link_up is invalid if returned value of status != 0
  *
  * Side effect: LinkStatusEvent reporting becomes enabled
  **/
-bool i40e_get_link_status(struct i40e_hw *hw)
+i40e_status i40e_get_link_status(struct i40e_hw *hw, bool *link_up)
 {
 	i40e_status status = 0;
-	bool link_status = false;
 
 	if (hw->phy.get_link_info) {
 		status = i40e_aq_get_link_info(hw, true, NULL, NULL);
 
 		if (status)
-			goto i40e_get_link_status_exit;
+			i40e_debug(hw, I40E_DEBUG_LINK, "get link failed: status %d\n",
+				   status);
 	}
 
-	link_status = hw->phy.link_info.link_info & I40E_AQ_LINK_UP;
+	*link_up = hw->phy.link_info.link_info & I40E_AQ_LINK_UP;
 
-i40e_get_link_status_exit:
-	return link_status;
+	return status;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 930369c..1fa38f6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1516,9 +1516,18 @@ static int i40e_link_test(struct net_device *netdev, u64 *data)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_pf *pf = np->vsi->back;
+	i40e_status status;
+	bool link_up = false;
 
 	netif_info(pf, hw, netdev, "link test\n");
-	if (i40e_get_link_status(&pf->hw))
+	status = i40e_get_link_status(&pf->hw, &link_up);
+	if (status) {
+		netif_err(pf, drv, netdev, "link query timed out, please retry test\n");
+		*data = 1;
+		return *data;
+	}
+
+	if (link_up)
 		*data = 0;
 	else
 		*data = 1;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1fa1eba..f205e18 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5836,15 +5836,23 @@ static void i40e_veb_link_event(struct i40e_veb *veb, bool link_up)
  **/
 static void i40e_link_event(struct i40e_pf *pf)
 {
-	bool new_link, old_link;
 	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
 	u8 new_link_speed, old_link_speed;
+	i40e_status status;
+	bool new_link, old_link;
 
 	/* set this to force the get_link_status call to refresh state */
 	pf->hw.phy.get_link_info = true;
 
 	old_link = (pf->hw.phy.link_info_old.link_info & I40E_AQ_LINK_UP);
-	new_link = i40e_get_link_status(&pf->hw);
+
+	status = i40e_get_link_status(&pf->hw, &new_link);
+	if (status) {
+		dev_dbg(&pf->pdev->dev, "couldn't get link state, status: %d\n",
+			status);
+		return;
+	}
+
 	old_link_speed = pf->hw.phy.link_info_old.link_speed;
 	new_link_speed = pf->hw.phy.link_info.link_speed;
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_prototype.h b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
index dcb72a8..e51e156 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_prototype.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_prototype.h
@@ -258,7 +258,7 @@ i40e_status i40e_init_shared_code(struct i40e_hw *hw);
 i40e_status i40e_pf_reset(struct i40e_hw *hw);
 void i40e_clear_hw(struct i40e_hw *hw);
 void i40e_clear_pxe_mode(struct i40e_hw *hw);
-bool i40e_get_link_status(struct i40e_hw *hw);
+i40e_status i40e_get_link_status(struct i40e_hw *hw, bool *link_up);
 i40e_status i40e_get_mac_addr(struct i40e_hw *hw, u8 *mac_addr);
 i40e_status i40e_read_bw_from_alt_ram(struct i40e_hw *hw,
 				      u32 *max_bw, u32 *min_bw, bool *min_valid,
-- 
2.4.3
