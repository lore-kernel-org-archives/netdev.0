From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 08/13] i40e: Issue a PF reset if Tx queue disable timeout
Date: Thu, 26 Feb 2015 07:03:44 -0800
Message-ID: <1424963029-4612-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Parikh, Neerav" <neerav.parikh@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:48322 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753933AbbBZPD5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:03:57 -0500
In-Reply-To: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Parikh, Neerav" <neerav.parikh@intel.com>

As part of DCB reconfiguration flow if the Tx queue disable times out
then issue a PF reset to do some level of recovery.

Change-ID: I7550021c55bff355351c0365e61e1f05fcaff46d
Signed-off-by: Neerav Parikh <neerav.parikh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index bd4494d..9751465 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5266,8 +5266,14 @@ static int i40e_handle_lldp_event(struct i40e_pf *pf,
 
 	/* Wait for the PF's Tx queues to be disabled */
 	ret = i40e_pf_wait_txq_disabled(pf);
-	if (!ret)
+	if (ret) {
+		/* Schedule PF reset to recover */
+		set_bit(__I40E_PF_RESET_REQUESTED, &pf->state);
+		i40e_service_event_schedule(pf);
+	} else {
 		i40e_pf_unquiesce_all_vsi(pf);
+	}
+
 exit:
 	return ret;
 }
-- 
1.9.3
