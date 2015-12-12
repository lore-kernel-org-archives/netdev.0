From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/11] i40e: don't add zero MAC filter
Date: Sat, 12 Dec 2015 00:33:25 -0800
Message-ID: <1449909213-33795-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:2094 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453AbbLLIdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Dec 2015 03:33:41 -0500
In-Reply-To: <1449909213-33795-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When VFs are created, the MAC address defaults to all zeros, indicating
to the VF driver that it should use a random MAC address. However, the
PF driver was incorrectly adding this zero MAC to the filter table,
along with the VF's randomly generated MAC address.

Check for a good address before adding the default filter. While we're
at it, make the error message a bit more useful.

Change-ID: Ia100947d68140e0f73a19ba755cbffc3e79a8fcf
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index cbbb2ef..aa58a49 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -549,12 +549,15 @@ static int i40e_alloc_vsi_res(struct i40e_vf *vf, enum i40e_vsi_type type)
 			i40e_vsi_add_pvid(vsi, vf->port_vlan_id);
 
 		spin_lock_bh(&vsi->mac_filter_list_lock);
-		f = i40e_add_filter(vsi, vf->default_lan_addr.addr,
-				    vf->port_vlan_id ? vf->port_vlan_id : -1,
-				    true, false);
-		if (!f)
-			dev_info(&pf->pdev->dev,
-				 "Could not allocate VF MAC addr\n");
+		if (is_valid_ether_addr(vf->default_lan_addr.addr)) {
+			f = i40e_add_filter(vsi, vf->default_lan_addr.addr,
+				       vf->port_vlan_id ? vf->port_vlan_id : -1,
+				       true, false);
+			if (!f)
+				dev_info(&pf->pdev->dev,
+					 "Could not add MAC filter %pM for VF %d\n",
+					vf->default_lan_addr.addr, vf->vf_id);
+		}
 		f = i40e_add_filter(vsi, brdcast,
 				    vf->port_vlan_id ? vf->port_vlan_id : -1,
 				    true, false);
-- 
2.5.0
