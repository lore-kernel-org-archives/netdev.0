From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/17] i40e: allow VF to remove any MAC filter
Date: Fri, 10 Jan 2014 12:30:31 -0800
Message-ID: <1389385839-11996-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389385839-11996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11524 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758214AbaAJUap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 15:30:45 -0500
In-Reply-To: <1389385839-11996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If you use ip to change the MAC address of a VF while the VF
driver is loaded, closing the VF interface or unloading the VF
driver will cause the VF driver to remove the MAC filter for its
original (now invalid) MAC address. This would cause the PF
driver to kick an error message to the log, and back to the VF
driver.

Since the VF driver has not really done anything naughty, let's
not punish it. Don't check for MAC address overrides on the
delete operation, just make sure it's a valid address. This keeps
us from spamming the log with confusing errors.

Change-ID: I1f051bd4014e50855457d928c9ee8b0766981b2f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 51a4f61..d04a776 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1525,9 +1525,13 @@ static int i40e_vc_del_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	}
 
 	for (i = 0; i < al->num_elements; i++) {
-		ret = i40e_check_vf_permission(vf, al->list[i].addr);
-		if (ret)
+		if (is_broadcast_ether_addr(al->list[i].addr) ||
+		    is_zero_ether_addr(al->list[i].addr)) {
+			dev_err(&pf->pdev->dev, "invalid VF MAC addr %pM\n",
+				al->list[i].addr);
+			ret = I40E_ERR_INVALID_MAC_ADDR;
 			goto error_param;
+		}
 	}
 	vsi = pf->vsi[vsi_id];
 
-- 
1.8.3.1
