From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/16] i40e: Don't notify client(s) for DCB changes on all VSIs
Date: Tue, 28 Jun 2016 21:41:02 -0700
Message-ID: <1467175262-54719-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Neerav Parikh <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Usha Ketineni <usha.k.ketineni@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:16687 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751489AbcF2EnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 00:43:19 -0400
In-Reply-To: <1467175262-54719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neerav Parikh <neerav.parikh@intel.com>

When LLDP/DCBX change happens the i40e driver code flow tried to
notify the client(s) for each of the PF VSIs. This resulted into
kernel panic on the first VSI that didn't have any netdev
associated to it.

The DCB change notification to the client(s) should be done only
once for the PF/LAN VSI where the client(s) instances have been
added to. Also, move the notification call after the PF driver has
made changes related to the updated DCB configuration.

Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Usha Ketineni <usha.k.ketineni@intel.com>
Tested-by: Ronald J Bynoe <ronald.j.bynoe@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index a313194..2b11405 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4982,7 +4982,6 @@ static void i40e_dcb_reconfigure(struct i40e_pf *pf)
 			if (pf->vsi[v]->netdev)
 				i40e_dcbnl_set_all(pf->vsi[v]);
 		}
-		i40e_notify_client_of_l2_param_changes(pf->vsi[v]);
 	}
 }
 
@@ -5730,6 +5729,8 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 		i40e_service_event_schedule(pf);
 	} else {
 		i40e_pf_unquiesce_all_vsi(pf);
+		/* Notify the client for the DCB changes */
+		i40e_notify_client_of_l2_param_changes(pf->vsi[pf->lan_vsi]);
 	}
 
 exit:
-- 
2.5.5
