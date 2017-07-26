From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/14] i40e: handle setting administratively set MAC address back to zero
Date: Wed, 26 Jul 2017 03:31:23 -0700
Message-ID: <20170726103123.76743-15-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:25252 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751798AbdGZKg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:36:58 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

When an administratively set MAC was previously set and should now be
switched back to 00:00:00:00:00:00 the pf_set_mac flag did not get
toggled back to false.
As a result VFs were still treated as if an administratively set MAC was
present.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 2e261bb59d10..979110d59f67 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2762,7 +2762,6 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 
 	spin_unlock_bh(&vsi->mac_filter_hash_lock);
 
-	dev_info(&pf->pdev->dev, "Setting MAC %pM on VF %d\n", mac, vf_id);
 	/* program mac filter */
 	if (i40e_sync_vsi_filters(vsi)) {
 		dev_err(&pf->pdev->dev, "Unable to program ucast filters\n");
@@ -2770,7 +2769,16 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
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
2.13.3
