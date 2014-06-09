From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] i40e: Delete stale MAC filters after change
Date: Mon,  9 Jun 2014 01:49:16 -0700
Message-ID: <1402303758-1429-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:27489 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754681AbaFIIta (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 04:49:30 -0400
In-Reply-To: <1402303758-1429-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Delete all the old and stale MAC filters for the VF VSI when the host
administrator changes the VF MAC address from under its feet.  Also don't
bother to add a filter for the VSI when its going to go away anyway.
Just record the new address and punch the VF reset.

Change-ID: Ic0d12055926f41989d1965ccf500053729c063ad
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 3f6cad4..385a46f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2063,14 +2063,11 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	i40e_del_filter(vsi, vf->default_lan_addr.addr, vf->port_vlan_id,
 			true, false);
 
-	/* add the new mac address */
-	f = i40e_add_filter(vsi, mac, vf->port_vlan_id, true, false);
-	if (!f) {
-		dev_err(&pf->pdev->dev,
-			"Unable to add VF ucast filter\n");
-		ret = -ENOMEM;
-		goto error_param;
-	}
+	/* Delete all the filters for this VSI - we're going to kill it
+	 * anyway.
+	 */
+	list_for_each_entry(f, &vsi->mac_filter_list, list)
+		i40e_del_filter(vsi, f->macaddr, f->vlan, true, false);
 
 	dev_info(&pf->pdev->dev, "Setting MAC %pM on VF %d\n", mac, vf_id);
 	/* program mac filter */
-- 
1.9.3
