From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/5] i40e: allow zero MAC address for VFs
Date: Fri,  8 Jan 2016 02:14:40 -0800
Message-ID: <1452248083-78628-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1452248083-78628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38757 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753490AbcAHKO4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2016 05:14:56 -0500
In-Reply-To: <1452248083-78628-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Allow the user to specify a zero MAC address for VFs. This removes the
existing MAC address and allows the VF to use a random address. Libvirt
does this normally when removing a VF from a VM.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index b8deb50..63e62f9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2084,9 +2084,9 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 		goto error_param;
 	}
 
-	if (!is_valid_ether_addr(mac)) {
+	if (is_multicast_ether_addr(mac)) {
 		dev_err(&pf->pdev->dev,
-			"Invalid VF ethernet address\n");
+			"Invalid Ethernet address %pM for VF %d\n", mac, vf_id);
 		ret = -EINVAL;
 		goto error_param;
 	}
@@ -2097,9 +2097,10 @@ int i40e_ndo_set_vf_mac(struct net_device *netdev, int vf_id, u8 *mac)
 	spin_lock_bh(&vsi->mac_filter_list_lock);
 
 	/* delete the temporary mac address */
-	i40e_del_filter(vsi, vf->default_lan_addr.addr,
-			vf->port_vlan_id ? vf->port_vlan_id : -1,
-			true, false);
+	if (!is_zero_ether_addr(vf->default_lan_addr.addr))
+		i40e_del_filter(vsi, vf->default_lan_addr.addr,
+				vf->port_vlan_id ? vf->port_vlan_id : -1,
+				true, false);
 
 	/* Delete all the filters for this VSI - we're going to kill it
 	 * anyway.
-- 
2.5.0
