From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: add private flag to control source pruning
Date: Fri,  6 Oct 2017 10:57:14 -0700
Message-ID: <20171006175727.868-3-jeffrey.t.kirsher@intel.com>
References: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:17217 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752397AbdJFR5u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Oct 2017 13:57:50 -0400
In-Reply-To: <20171006175727.868-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

By default, our devices do source pruning, that is, they drop receive
packets that have the source MAC matching one of the receive filters.
Unfortunately, this breaks ARP monitoring in channel bonding, as the
bonding driver expects devices to receive ARPs containing their own
source address.

Add an ethtool private flag to control this feature.

Also, remove the netif_running() check when we process our private
flags. It's OK to reset when the device is closed and in most cases we
need the reset the apply these changes.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  7 +++++--
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 25 +++++++++++++++++++++++++
 3 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 2bc4dd0dbbf1..c78448daa7a1 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -452,6 +452,7 @@ struct i40e_pf {
 #define I40E_FLAG_TEMP_LINK_POLLING		BIT_ULL(55)
 #define I40E_FLAG_CLIENT_L2_CHANGE		BIT_ULL(56)
 #define I40E_FLAG_LEGACY_RX			BIT_ULL(58)
+#define I40E_FLAG_SOURCE_PRUNING_DISABLED	BIT_ULL(59)
 
 	struct i40e_client_instance *cinst;
 	bool stat_offsets_loaded;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 1136d02e2e95..6203d362438c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -227,6 +227,8 @@ static const struct i40e_priv_flags i40e_gstrings_priv_flags[] = {
 	I40E_PRIV_FLAG("veb-stats", I40E_FLAG_VEB_STATS_ENABLED, 0),
 	I40E_PRIV_FLAG("hw-atr-eviction", I40E_FLAG_HW_ATR_EVICT_ENABLED, 0),
 	I40E_PRIV_FLAG("legacy-rx", I40E_FLAG_LEGACY_RX, 0),
+	I40E_PRIV_FLAG("disable-source-pruning",
+		       I40E_FLAG_SOURCE_PRUNING_DISABLED, 0),
 };
 
 #define I40E_PRIV_FLAGS_STR_LEN ARRAY_SIZE(i40e_gstrings_priv_flags)
@@ -4189,8 +4191,9 @@ static int i40e_set_priv_flags(struct net_device *dev, u32 flags)
 	/* Issue reset to cause things to take effect, as additional bits
 	 * are added we will need to create a mask of bits requiring reset
 	 */
-	if ((changed_flags & I40E_FLAG_VEB_STATS_ENABLED) ||
-	    ((changed_flags & I40E_FLAG_LEGACY_RX) && netif_running(dev)))
+	if (changed_flags & (I40E_FLAG_VEB_STATS_ENABLED |
+			     I40E_FLAG_LEGACY_RX |
+			     I40E_FLAG_SOURCE_PRUNING_DISABLED))
 		i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED), true);
 
 	return 0;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 3f9e89b054ec..b539469f576f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9903,6 +9903,31 @@ static int i40e_add_vsi(struct i40e_vsi *vsi)
 
 		enabled_tc = i40e_pf_get_tc_map(pf);
 
+		/* Source pruning is enabled by default, so the flag is
+		 * negative logic - if it's set, we need to fiddle with
+		 * the VSI to disable source pruning.
+		 */
+		if (pf->flags & I40E_FLAG_SOURCE_PRUNING_DISABLED) {
+			memset(&ctxt, 0, sizeof(ctxt));
+			ctxt.seid = pf->main_vsi_seid;
+			ctxt.pf_num = pf->hw.pf_id;
+			ctxt.vf_num = 0;
+			ctxt.info.valid_sections |=
+				     cpu_to_le16(I40E_AQ_VSI_PROP_SWITCH_VALID);
+			ctxt.info.switch_id =
+				   cpu_to_le16(I40E_AQ_VSI_SW_ID_FLAG_LOCAL_LB);
+			ret = i40e_aq_update_vsi_params(hw, &ctxt, NULL);
+			if (ret) {
+				dev_info(&pf->pdev->dev,
+					 "update vsi failed, err %s aq_err %s\n",
+					 i40e_stat_str(&pf->hw, ret),
+					 i40e_aq_str(&pf->hw,
+						     pf->hw.aq.asq_last_status));
+				ret = -ENOENT;
+				goto err;
+			}
+		}
+
 		/* MFP mode setup queue map and update VSI */
 		if ((pf->flags & I40E_FLAG_MFP_ENABLED) &&
 		    !(pf->hw.func_caps.iscsi)) { /* NIC type PF */
-- 
2.14.2
