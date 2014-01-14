From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 1/2] i40e: Warn admin to reload VF driver on port VLAN configuration
Date: Mon, 13 Jan 2014 16:13:03 -0800
Message-ID: <1389658384-15825-2-git-send-email-aaron.f.brown@intel.com>
References: <1389658384-15825-1-git-send-email-aaron.f.brown@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26269 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751289AbaANANK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 19:13:10 -0500
In-Reply-To: <1389658384-15825-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The i40e Physical Function (PF) driver will allow the
 Virtual Function (VF) driver to configure its own VLAN filters if no port
 VLAN filter has been configured.  This leads to the possibility of the
 administrator setting a port VLAN filter for the VF after the VF has already
 configured its own VLAN filters.  This leads to a conflict that can only be
 resolved by reloading the VF driver.  When the conflicting administrative
 command is detected in setting the port VLAN then log a message indicating to
 the system administrator that he must now reload the VF driver for the new
 port VLAN settings to take effect.

Change-Id: I8de73b885d944a043aff32226297e4249862bcad
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index d04a776..ecb873c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2076,6 +2076,11 @@ int i40e_ndo_set_vf_port_vlan(struct net_device *netdev,
 		goto error_pvid;
 	}
 
+	if (vsi->info.pvid == 0 && i40e_is_vsi_in_vlan(vsi))
+		dev_err(&pf->pdev->dev,
+			"VF %d has already configured VLAN filters and the administrator is requesting a port VLAN override.\nPlease unload and reload the VF driver for this change to take effect.\n",
+			vf_id);
+
 	if (vsi->info.pvid) {
 		/* kill old VLAN */
 		ret = i40e_vsi_kill_vlan(vsi, (le16_to_cpu(vsi->info.pvid) &
-- 
1.8.5.GIT
