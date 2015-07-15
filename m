From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/16] i40e: ignore duplicate port VLAN requests
Date: Tue, 14 Jul 2015 18:30:30 -0700
Message-ID: <1436923840-24455-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22319 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752586AbbGOBaq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jul 2015 21:30:46 -0400
In-Reply-To: <1436923840-24455-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If user attempts to set a port VLAN on a VF that already has the same
port VLAN configured, the driver will go through a completely
unnecessary flurry of filter removals and filter adds. Just check for
this condition and return success instead of doing a bunch of busywork.

Change-ID: Ia1a9e83e6ed48b3f4658bc20dfc6af0cf525d54a
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 23f95cd..433e803 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2088,6 +2088,10 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		goto error_pvid;
 	}
 
+	if (vsi->info.pvid == (vlan_id | (qos << I40E_VLAN_PRIORITY_SHIFT)))
+		/* duplicate request, so just return success */
+		goto error_pvid;
+
 	if (vsi->info.pvid == 0 && i40e_is_vsi_in_vlan(vsi)) {
 		dev_err(&pf->pdev->dev,
 			"VF %d has already configured VLAN filters and the administrator is requesting a port VLAN override.\nPlease unload and reload the VF driver for this change to take effect.\n",
-- 
2.4.3
