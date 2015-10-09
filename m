From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/16] i40e/i40evf: pass QOS handle to VF
Date: Thu,  8 Oct 2015 18:32:53 -0700
Message-ID: <1444354374-24351-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:54300 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755547AbbJIBdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 21:33:00 -0400
In-Reply-To: <1444354374-24351-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The VF really doesn't care about the QOS handle but it will in the
future. Since the VF only uses TC0, send it that handle. On the VF
side, save the handle and use it to populate the QOS params when we call
into the client interface.

Change-ID: I76f41b070baeaa09b19383e9168bc677837e0761
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 6 ++++--
 drivers/net/ethernet/intel/i40evf/i40evf.h         | 1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 1 +
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 678623f..ee747dc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1210,8 +1210,10 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 	if (vf->lan_vsi_idx) {
 		vfres->vsi_res[i].vsi_id = vf->lan_vsi_id;
 		vfres->vsi_res[i].vsi_type = I40E_VSI_SRIOV;
-		vfres->vsi_res[i].num_queue_pairs =
-		    pf->vsi[vf->lan_vsi_idx]->alloc_queue_pairs;
+		vfres->vsi_res[i].num_queue_pairs = vsi->alloc_queue_pairs;
+		/* VFs only use TC 0 */
+		vfres->vsi_res[i].qset_handle
+					  = le16_to_cpu(vsi->info.qs_handle[0]);
 		ether_addr_copy(vfres->vsi_res[i].default_mac_addr,
 				vf->default_lan_addr.addr);
 		i++;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 27dc3fe..e7a223e 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -66,6 +66,7 @@ struct i40e_vsi {
 	 */
 	u16 rx_itr_setting;
 	u16 tx_itr_setting;
+	u16 qs_handle;
 };
 
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 1f99930..c00e495 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2115,6 +2115,7 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 	adapter->vsi.tx_itr_setting = (I40E_ITR_DYNAMIC |
 				       ITR_REG_TO_USEC(I40E_ITR_TX_DEF));
 	adapter->vsi.netdev = adapter->netdev;
+	adapter->vsi.qs_handle = adapter->vsi_res->qset_handle;
 	return 0;
 }
 
-- 
2.4.3
