From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/10] i40e: Fix to check for NULL
Date: Thu, 22 Sep 2016 22:45:36 -0700
Message-ID: <1474609542-121940-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474609542-121940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:40400 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758001AbcIWFpr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 01:45:47 -0400
In-Reply-To: <1474609542-121940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes an issue in the virt channel code, where a return
from i40e_find_vsi_from_id was not checked for NULL when applicable.
Without this patch, there is a risk for panic and static analysis
tools complain. This patch fixes the problem by adding the check
and adding an additional input check for similar reasons.

Change-ID: I7e9be88eb7a3addb50eadc451c8336d9e06f5394
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 611fc87..2ab5355 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -502,8 +502,16 @@ static int i40e_config_vsi_tx_queue(struct i40e_vf *vf, u16 vsi_id,
 	u32 qtx_ctl;
 	int ret = 0;
 
+	if (!i40e_vc_isvalid_vsi_id(vf, info->vsi_id)) {
+		ret = -ENOENT;
+		goto error_context;
+	}
 	pf_queue_id = i40e_vc_get_pf_queue_id(vf, vsi_id, vsi_queue_id);
 	vsi = i40e_find_vsi_from_id(pf, vsi_id);
+	if (!vsi) {
+		ret = -ENOENT;
+		goto error_context;
+	}
 
 	/* clear the context structure first */
 	memset(&tx_ctx, 0, sizeof(struct i40e_hmc_obj_txq));
@@ -1476,7 +1484,8 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 
 	vsi = i40e_find_vsi_from_id(pf, info->vsi_id);
 	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
-	    !i40e_vc_isvalid_vsi_id(vf, info->vsi_id)) {
+	    !i40e_vc_isvalid_vsi_id(vf, info->vsi_id) ||
+	    !vsi) {
 		aq_ret = I40E_ERR_PARAM;
 		goto error_param;
 	}
-- 
2.7.4
