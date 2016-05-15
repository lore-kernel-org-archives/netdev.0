From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] i40e: lie to the VF
Date: Sat, 14 May 2016 21:57:27 -0700
Message-ID: <1463288255-1654-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51923 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752365AbcEOE5k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:40 -0400
In-Reply-To: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If an untrusted VF attempts to configure promiscuous mode, log a message
pointing out its naughty behavior. But then, instead of returning an
error to the offender, just lie to it and say everything's OK. It will
continue on its way, thinking it's in promiscuous mode, but receiving no
packets except its own.

Change-ID: I63369215b1720f3c531eedfc06af86ff8c0e3dc8
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 6430933..9473429 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1474,12 +1474,16 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 
 	vsi = i40e_find_vsi_from_id(pf, info->vsi_id);
 	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
-	    !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps) ||
 	    !i40e_vc_isvalid_vsi_id(vf, info->vsi_id)) {
+		aq_ret = I40E_ERR_PARAM;
+		goto error_param;
+	}
+	if (!test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
 		dev_err(&pf->pdev->dev,
-			"VF %d doesn't meet requirements to enter promiscuous mode\n",
+			"Unprivileged VF %d is attempting to configure promiscuous mode\n",
 			vf->vf_id);
-		aq_ret = I40E_ERR_PARAM;
+		/* Lie to the VF on purpose. */
+		aq_ret = 0;
 		goto error_param;
 	}
 	/* Multicast promiscuous handling*/
-- 
2.5.5
