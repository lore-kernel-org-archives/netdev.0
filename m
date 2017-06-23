From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH] i40e: handle setting administratively set MAC address back to zero
Date: Fri, 23 Jun 2017 09:46:24 +0200
Message-ID: <20170623074624.32405-1-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36732 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751240AbdFWHqp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 03:46:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an administratively set MAC was previously set and should now be
switched back to 00:00:00:00:00:00 the pf_set_mac flag did not get
toggled back to false.
As a result VFs were still treated as if an administratively set MAC was
present.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index ecbe40e..af0ff61 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2764,7 +2764,6 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 
 	spin_unlock_bh(&vsi->mac_filter_hash_lock);
 
-	dev_info(&pf->pdev->dev, "Setting MAC %pM on VF %d\n", mac, vf_id);
 	/* program mac filter */
 	if (i40e_sync_vsi_filters(vsi)) {
 		dev_err(&pf->pdev->dev, "Unable to program ucast filters\n");
@@ -2772,7 +2771,16 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 		goto error_param;
 	}
 	ether_addr_copy(vf->default_lan_addr.addr, mac);
-	vf->pf_set_mac = true;
+
+	if (is_zero_ether_addr(mac)) {
+		vf->pf_set_mac = false;
+		dev_info(&pf->pdev->dev, "Removing MAC on VF %d\n", vf_id);
+	} else {
+		vf->pf_set_mac = true;
+		dev_info(&pf->pdev->dev, "Setting MAC %pM on VF %d\n",
+			 mac, vf_id);
+	}
+
 	/* Force the VF driver stop so it has to reload with new MAC address */
 	i40e_vc_disable_vf(pf, vf);
 	dev_info(&pf->pdev->dev, "Reload the VF driver to make this change effective.\n");
-- 
2.9.4
