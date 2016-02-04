From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/20] i40evf: add new write-back mode
Date: Thu,  4 Feb 2016 03:49:04 -0800
Message-ID: <1454586551-35919-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34313 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965776AbcBDLtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Feb 2016 06:49:21 -0500
In-Reply-To: <1454586551-35919-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Add write-back on interrupt throttle rate timer expiration support
for the i40evf driver, when running on X722 devices.

Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  6 ++++++
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c      | 16 ++++++++++++++++
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    |  5 +++++
 3 files changed, 27 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 86aacb9..659d782 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1222,6 +1222,12 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 	if (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING)
 		vfres->vf_offload_flags |= I40E_VIRTCHNL_VF_OFFLOAD_RX_POLLING;
 
+	if (pf->flags & I40E_FLAG_WB_ON_ITR_CAPABLE) {
+		if (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR)
+			vfres->vf_offload_flags |=
+					I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR;
+	}
+
 	vfres->num_vsis = num_vsis;
 	vfres->num_queue_pairs = vf->num_queue_pairs;
 	vfres->max_vectors = pf->hw.func_caps.num_msix_vectors_vf;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index 7a00657..7d663fb 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -252,6 +252,22 @@ static bool i40e_clean_tx_irq(struct i40e_ring *tx_ring, int budget)
 	tx_ring->q_vector->tx.total_bytes += total_bytes;
 	tx_ring->q_vector->tx.total_packets += total_packets;
 
+	if (tx_ring->flags & I40E_TXR_FLAGS_WB_ON_ITR) {
+		unsigned int j = 0;
+		/* check to see if there are < 4 descriptors
+		 * waiting to be written back, then kick the hardware to force
+		 * them to be written back in case we stay in NAPI.
+		 * In this mode on X722 we do not enable Interrupt.
+		 */
+		j = i40evf_get_tx_pending(tx_ring);
+
+		if (budget &&
+		    ((j / (WB_STRIDE + 1)) == 0) && (j > 0) &&
+		    !test_bit(__I40E_DOWN, &tx_ring->vsi->state) &&
+		    (I40E_DESC_UNUSED(tx_ring) != tx_ring->count))
+			tx_ring->arm_wb = true;
+	}
+
 	netdev_tx_completed_queue(netdev_get_tx_queue(tx_ring->netdev,
 						      tx_ring->queue_index),
 				  total_packets, total_bytes);
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 798f0de..615ad0f 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2511,6 +2511,11 @@ static void i40evf_init_task(struct work_struct *work)
 	if (adapter->vf_res->vf_offload_flags &
 		    I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR)
 		adapter->flags |= I40EVF_FLAG_WB_ON_ITR_CAPABLE;
+
+	if (adapter->vf_res->vf_offload_flags &
+	    I40E_VIRTCHNL_VF_OFFLOAD_WB_ON_ITR)
+		adapter->flags |= I40EVF_FLAG_WB_ON_ITR_CAPABLE;
+
 	err = i40evf_request_misc_irq(adapter);
 	if (err)
 		goto err_sw_init;
-- 
2.5.0
