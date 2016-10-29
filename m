From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/17] i40e: Removal of workaround for simple MAC address filter deletion
Date: Sat, 29 Oct 2016 00:30:55 -0700
Message-ID: <1477726258-111563-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Filip Sadowski <filip.sadowski@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50625 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752249AbcJ2HbI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 03:31:08 -0400
In-Reply-To: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Filip Sadowski <filip.sadowski@intel.com>

This is code refactoring. This patch removes the workaround which deleted
a default MAC filter added by the firmware when the interface was brought
up. This filter caused frames to pass disregarding the VLAN tagging.
It used to be automatically applied after reset in pre-SRA FW versions.
This workaround is not needed in production NICs and hence can be removed.

Change-ID: I129fe1aae1f17b5a224c9b29a996d916aa1be1ec
Signed-off-by: Filip Sadowski <filip.sadowski@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 41 -----------------------------
 1 file changed, 41 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a4bae0a..2e787ff 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1287,39 +1287,6 @@ int i40e_del_mac_all_vlan(struct i40e_vsi *vsi, u8 *macaddr,
 }
 
 /**
- * i40e_rm_default_mac_filter - Remove the default MAC filter set by NVM
- * @vsi: the PF Main VSI - inappropriate for any other VSI
- * @macaddr: the MAC address
- *
- * Remove whatever filter the firmware set up so the driver can manage
- * its own filtering intelligently.
- **/
-static void i40e_rm_default_mac_filter(struct i40e_vsi *vsi, u8 *macaddr)
-{
-	struct i40e_aqc_remove_macvlan_element_data element;
-	struct i40e_pf *pf = vsi->back;
-
-	/* Only appropriate for the PF main VSI */
-	if (vsi->type != I40E_VSI_MAIN)
-		return;
-
-	memset(&element, 0, sizeof(element));
-	ether_addr_copy(element.mac_addr, macaddr);
-	element.vlan_tag = 0;
-	/* Ignore error returns, some firmware does it this way... */
-	element.flags = I40E_AQC_MACVLAN_DEL_PERFECT_MATCH;
-	i40e_aq_remove_macvlan(&pf->hw, vsi->seid, &element, 1, NULL);
-
-	memset(&element, 0, sizeof(element));
-	ether_addr_copy(element.mac_addr, macaddr);
-	element.vlan_tag = 0;
-	/* ...and some firmware does it this way. */
-	element.flags = I40E_AQC_MACVLAN_DEL_PERFECT_MATCH |
-			I40E_AQC_MACVLAN_DEL_IGNORE_VLAN;
-	i40e_aq_remove_macvlan(&pf->hw, vsi->seid, &element, 1, NULL);
-}
-
-/**
  * i40e_add_filter - Add a mac/vlan filter to the VSI
  * @vsi: the VSI to be searched
  * @macaddr: the MAC address
@@ -9218,12 +9185,6 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	if (vsi->type == I40E_VSI_MAIN) {
 		SET_NETDEV_DEV(netdev, &pf->pdev->dev);
 		ether_addr_copy(mac_addr, hw->mac.perm_addr);
-		/* The following steps are necessary to prevent reception
-		 * of tagged packets - some older NVM configurations load a
-		 * default a MAC-VLAN filter that accepts any tagged packet
-		 * which must be replaced by a normal filter.
-		 */
-		i40e_rm_default_mac_filter(vsi, mac_addr);
 		spin_lock_bh(&vsi->mac_filter_list_lock);
 		i40e_add_filter(vsi, mac_addr, I40E_VLAN_ANY, false, true);
 		spin_unlock_bh(&vsi->mac_filter_list_lock);
@@ -9741,8 +9702,6 @@ static struct i40e_vsi *i40e_vsi_reinit_setup(struct i40e_vsi *vsi)
 	pf->vsi[pf->lan_vsi]->tc_config.enabled_tc = 0;
 	pf->vsi[pf->lan_vsi]->seid = pf->main_vsi_seid;
 	i40e_vsi_config_tc(pf->vsi[pf->lan_vsi], enabled_tc);
-	if (vsi->type == I40E_VSI_MAIN)
-		i40e_rm_default_mac_filter(vsi, pf->hw.mac.perm_addr);
 
 	/* assign it some queues */
 	ret = i40e_alloc_rings(vsi);
-- 
2.7.4
