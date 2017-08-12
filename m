From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: remove workaround for Open Firmware MAC address
Date: Sat, 12 Aug 2017 04:08:39 -0700
Message-ID: <20170812110848.18264-8-jeffrey.t.kirsher@intel.com>
References: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12721 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750948AbdHLLIy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Aug 2017 07:08:54 -0400
In-Reply-To: <20170812110848.18264-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Since commit b499ffb0a22c ("i40e: Look up MAC address in Open Firmware
or IDPROM"), we've had support for obtaining the MAC address
form Open Firmware or IDPROM.

This code relied on sending the Open Firmware address directly to the
device firmware instead of relying on our MAC/VLAN filter list. Thus,
a work around was introduced in commit b1b15df59232 ("i40e: Explicitly
write platform-specific mac address after PF reset")

We refactored the Open Firmware address enablement code in the ill-named
commit 41c4c2b50d52 ("i40e: allow look-up of MAC address from Open
Firmware or IDPROM")

Since this refactor, we no longer even set I40E_FLAG_PF_MAC. Further, we
don't need this work around, because we actually store the MAC address
as part of the MAC/VLAN filter hash. Thus, we will restore the address
correctly upon reset.

The refactor above failed to revert the workaround, so do that now.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 -
 drivers/net/ethernet/intel/i40e/i40e_main.c | 60 -----------------------------
 2 files changed, 61 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f07217b15ffd..d0c1bf5441d8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -445,7 +445,6 @@ struct i40e_pf {
 #define I40E_FLAG_VEB_STATS_ENABLED		BIT_ULL(37)
 #define I40E_FLAG_LINK_POLLING_ENABLED		BIT_ULL(39)
 #define I40E_FLAG_VEB_MODE_ENABLED		BIT_ULL(40)
-#define I40E_FLAG_PF_MAC			BIT_ULL(50)
 #define I40E_FLAG_TRUE_PROMISC_SUPPORT		BIT_ULL(51)
 #define I40E_FLAG_CLIENT_RESET			BIT_ULL(54)
 #define I40E_FLAG_TEMP_LINK_POLLING		BIT_ULL(55)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index d7248e5c5f01..4d1eb0c19028 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2713,44 +2713,6 @@ static int i40e_vlan_rx_kill_vid(struct net_device *netdev,
 	return 0;
 }
 
-/**
- * i40e_macaddr_init - explicitly write the mac address filters
- *
- * @vsi: pointer to the vsi
- * @macaddr: the MAC address
- *
- * This is needed when the macaddr has been obtained by other
- * means than the default, e.g., from Open Firmware or IDPROM.
- * Returns 0 on success, negative on failure
- **/
-static int i40e_macaddr_init(struct i40e_vsi *vsi, u8 *macaddr)
-{
-	int ret;
-	struct i40e_aqc_add_macvlan_element_data element;
-
-	ret = i40e_aq_mac_address_write(&vsi->back->hw,
-					I40E_AQC_WRITE_TYPE_LAA_WOL,
-					macaddr, NULL);
-	if (ret) {
-		dev_info(&vsi->back->pdev->dev,
-			 "Addr change for VSI failed: %d\n", ret);
-		return -EADDRNOTAVAIL;
-	}
-
-	memset(&element, 0, sizeof(element));
-	ether_addr_copy(element.mac_addr, macaddr);
-	element.flags = cpu_to_le16(I40E_AQC_MACVLAN_ADD_PERFECT_MATCH);
-	ret = i40e_aq_add_macvlan(&vsi->back->hw, vsi->seid, &element, 1, NULL);
-	if (ret) {
-		dev_info(&vsi->back->pdev->dev,
-			 "add filter failed err %s aq_err %s\n",
-			 i40e_stat_str(&vsi->back->hw, ret),
-			 i40e_aq_str(&vsi->back->hw,
-				     vsi->back->hw.aq.asq_last_status));
-	}
-	return ret;
-}
-
 /**
  * i40e_restore_vlan - Reinstate vlans when vsi/netdev comes back up
  * @vsi: the vsi being brought back up
@@ -3203,19 +3165,8 @@ static void i40e_vsi_config_dcb_rings(struct i40e_vsi *vsi)
  **/
 static void i40e_set_vsi_rx_mode(struct i40e_vsi *vsi)
 {
-	struct i40e_pf *pf = vsi->back;
-	int err;
-
 	if (vsi->netdev)
 		i40e_set_rx_mode(vsi->netdev);
-
-	if (!!(pf->flags & I40E_FLAG_PF_MAC)) {
-		err = i40e_macaddr_init(vsi, pf->hw.mac.addr);
-		if (err) {
-			dev_warn(&pf->pdev->dev,
-				 "could not set up macaddr; err %d\n", err);
-		}
-	}
 }
 
 /**
@@ -10400,17 +10351,6 @@ struct i40e_vsi *i40e_vsi_setup(struct i40e_pf *pf, u8 type,
 	switch (vsi->type) {
 	/* setup the netdev if needed */
 	case I40E_VSI_MAIN:
-		/* Apply relevant filters if a platform-specific mac
-		 * address was selected.
-		 */
-		if (!!(pf->flags & I40E_FLAG_PF_MAC)) {
-			ret = i40e_macaddr_init(vsi, pf->hw.mac.addr);
-			if (ret) {
-				dev_warn(&pf->pdev->dev,
-					 "could not set up macaddr; err %d\n",
-					 ret);
-			}
-		}
 	case I40E_VSI_VMDQ2:
 		ret = i40e_config_netdev(vsi);
 		if (ret)
-- 
2.14.0
