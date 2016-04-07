From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/14] i40e: Restrict VF poll mode to only single function mode devices
Date: Wed,  6 Apr 2016 20:29:33 -0700
Message-ID: <1459999779-22254-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47670 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754555AbcDGD3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Apr 2016 23:29:45 -0400
In-Reply-To: <1459999779-22254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The VFs can request their queues to be set up into polling mode, rather
than interrupt mode, which works well for supporting things like DPDK,
but this should not be available when working in an multi-function
support device.

Change-ID: Id36792e4e7422db8f2033336507211f68f14ff6f
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index b353966..30f8cbe 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1362,8 +1362,16 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 				I40E_VIRTCHNL_VF_OFFLOAD_RSS_PCTYPE_V2;
 	}
 
-	if (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING)
+	if (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING) {
+		if (pf->flags & I40E_FLAG_MFP_ENABLED) {
+			dev_err(&pf->pdev->dev,
+				"VF %d requested polling mode: this feature is supported only when the device is running in single function per port (SFP) mode\n",
+				 vf->vf_id);
+			ret = I40E_ERR_PARAM;
+			goto err;
+		}
 		vfres->vf_offload_flags |= I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING;
+	}
 
 	if (pf->flags & I40E_FLAG_WB_ON_ITR_CAPABLE) {
 		if (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR)
-- 
2.5.5
