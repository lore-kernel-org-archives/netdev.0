From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/15] i40e: remove redundant code
Date: Wed, 18 Dec 2013 22:34:45 -0800
Message-ID: <1387434891-19719-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:65348 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752515Ab3LSGfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 01:35:01 -0500
In-Reply-To: <1387434891-19719-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Don't keep separate functions to enable and disable queues for the VFs.
Just call the existing function that everybody else uses. Remove the
unused functions.

Change-Id: I15db9aad64a59e502bfe1e0fdab9b347ab85c12c
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 249 +--------------------
 1 file changed, 4 insertions(+), 245 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index fae955b..ac8f459 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -102,130 +102,6 @@ static u16 i40e_vc_get_pf_queue_id(struct i40e_vf *vf, u8 vsi_idx,
 }
 
 /**
- * i40e_ctrl_vsi_tx_queue
- * @vf: pointer to the vf info
- * @vsi_idx: index of VSI in PF struct
- * @vsi_queue_id: vsi relative queue index
- * @ctrl: control flags
- *
- * enable/disable/enable check/disable check
- **/
-static int i40e_ctrl_vsi_tx_queue(struct i40e_vf *vf, u16 vsi_idx,
-				  u16 vsi_queue_id,
-				  enum i40e_queue_ctrl ctrl)
-{
-	struct i40e_pf *pf = vf->pf;
-	struct i40e_hw *hw = &pf->hw;
-	bool writeback = false;
-	u16 pf_queue_id;
-	int ret = 0;
-	u32 reg;
-
-	pf_queue_id = i40e_vc_get_pf_queue_id(vf, vsi_idx, vsi_queue_id);
-	reg = rd32(hw, I40E_QTX_ENA(pf_queue_id));
-
-	switch (ctrl) {
-	case I40E_QUEUE_CTRL_ENABLE:
-		reg |= I40E_QTX_ENA_QENA_REQ_MASK;
-		writeback = true;
-		break;
-	case I40E_QUEUE_CTRL_ENABLECHECK:
-		ret = (reg & I40E_QTX_ENA_QENA_STAT_MASK) ? 0 : -EPERM;
-		break;
-	case I40E_QUEUE_CTRL_DISABLE:
-		reg &= ~I40E_QTX_ENA_QENA_REQ_MASK;
-		writeback = true;
-		break;
-	case I40E_QUEUE_CTRL_DISABLECHECK:
-		ret = (reg & I40E_QTX_ENA_QENA_STAT_MASK) ? -EPERM : 0;
-		break;
-	case I40E_QUEUE_CTRL_FASTDISABLE:
-		reg |= I40E_QTX_ENA_FAST_QDIS_MASK;
-		writeback = true;
-		break;
-	case I40E_QUEUE_CTRL_FASTDISABLECHECK:
-		ret = (reg & I40E_QTX_ENA_QENA_STAT_MASK) ? -EPERM : 0;
-		if (!ret) {
-			reg &= ~I40E_QTX_ENA_FAST_QDIS_MASK;
-			writeback = true;
-		}
-		break;
-	default:
-		ret = -EINVAL;
-		break;
-	}
-
-	if (writeback) {
-		wr32(hw, I40E_QTX_ENA(pf_queue_id), reg);
-		i40e_flush(hw);
-	}
-
-	return ret;
-}
-
-/**
- * i40e_ctrl_vsi_rx_queue
- * @vf: pointer to the vf info
- * @vsi_idx: index of VSI in PF struct
- * @vsi_queue_id: vsi relative queue index
- * @ctrl: control flags
- *
- * enable/disable/enable check/disable check
- **/
-static int i40e_ctrl_vsi_rx_queue(struct i40e_vf *vf, u16 vsi_idx,
-				  u16 vsi_queue_id,
-				  enum i40e_queue_ctrl ctrl)
-{
-	struct i40e_pf *pf = vf->pf;
-	struct i40e_hw *hw = &pf->hw;
-	bool writeback = false;
-	u16 pf_queue_id;
-	int ret = 0;
-	u32 reg;
-
-	pf_queue_id = i40e_vc_get_pf_queue_id(vf, vsi_idx, vsi_queue_id);
-	reg = rd32(hw, I40E_QRX_ENA(pf_queue_id));
-
-	switch (ctrl) {
-	case I40E_QUEUE_CTRL_ENABLE:
-		reg |= I40E_QRX_ENA_QENA_REQ_MASK;
-		writeback = true;
-		break;
-	case I40E_QUEUE_CTRL_ENABLECHECK:
-		ret = (reg & I40E_QRX_ENA_QENA_STAT_MASK) ? 0 : -EPERM;
-		break;
-	case I40E_QUEUE_CTRL_DISABLE:
-		reg &= ~I40E_QRX_ENA_QENA_REQ_MASK;
-		writeback = true;
-		break;
-	case I40E_QUEUE_CTRL_DISABLECHECK:
-		ret = (reg & I40E_QRX_ENA_QENA_STAT_MASK) ? -EPERM : 0;
-		break;
-	case I40E_QUEUE_CTRL_FASTDISABLE:
-		reg |= I40E_QRX_ENA_FAST_QDIS_MASK;
-		writeback = true;
-		break;
-	case I40E_QUEUE_CTRL_FASTDISABLECHECK:
-		ret = (reg & I40E_QRX_ENA_QENA_STAT_MASK) ? -EPERM : 0;
-		if (!ret) {
-			reg &= ~I40E_QRX_ENA_FAST_QDIS_MASK;
-			writeback = true;
-		}
-		break;
-	default:
-		ret = -EINVAL;
-		break;
-	}
-
-	if (writeback) {
-		wr32(hw, I40E_QRX_ENA(pf_queue_id), reg);
-		i40e_flush(hw);
-	}
-
-	return ret;
-}
-
-/**
  * i40e_config_irq_link_list
  * @vf: pointer to the vf info
  * @vsi_idx: index of VSI in PF struct
@@ -1340,8 +1216,6 @@ static int i40e_vc_enable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	struct i40e_pf *pf = vf->pf;
 	u16 vsi_id = vqs->vsi_id;
 	i40e_status aq_ret = 0;
-	unsigned long tempmap;
-	u16 queue_id;
 
 	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
@@ -1358,65 +1232,8 @@ static int i40e_vc_enable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 		goto error_param;
 	}
 
-	tempmap = vqs->rx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
-		if (!i40e_vc_isvalid_queue_id(vf, vsi_id, queue_id)) {
-			aq_ret = I40E_ERR_PARAM;
-			goto error_param;
-		}
-		i40e_ctrl_vsi_rx_queue(vf, vsi_id, queue_id,
-				       I40E_QUEUE_CTRL_ENABLE);
-
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
-	}
-
-	tempmap = vqs->tx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
-		if (!i40e_vc_isvalid_queue_id(vf, vsi_id, queue_id)) {
-			aq_ret = I40E_ERR_PARAM;
-			goto error_param;
-		}
-		i40e_ctrl_vsi_tx_queue(vf, vsi_id, queue_id,
-				       I40E_QUEUE_CTRL_ENABLE);
-
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
-	}
-
-	/* Poll the status register to make sure that the
-	 * requested op was completed successfully
-	 */
-	udelay(10);
-
-	tempmap = vqs->rx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
-		if (i40e_ctrl_vsi_rx_queue(vf, vsi_id, queue_id,
-					   I40E_QUEUE_CTRL_ENABLECHECK)) {
-			dev_err(&pf->pdev->dev,
-				"Queue control check failed on RX queue %d of VSI %d VF %d\n",
-				queue_id, vsi_id, vf->vf_id);
-		}
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
-	}
-
-	tempmap = vqs->tx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
-		if (i40e_ctrl_vsi_tx_queue(vf, vsi_id, queue_id,
-					   I40E_QUEUE_CTRL_ENABLECHECK)) {
-			dev_err(&pf->pdev->dev,
-				"Queue control check failed on TX queue %d of VSI %d VF %d\n",
-				queue_id, vsi_id, vf->vf_id);
-		}
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
-	}
-
+	if (i40e_vsi_control_rings(pf->vsi[vsi_id], true))
+		aq_ret = I40E_ERR_TIMEOUT;
 error_param:
 	/* send the response to the vf */
 	return i40e_vc_send_resp_to_vf(vf, I40E_VIRTCHNL_OP_ENABLE_QUEUES,
@@ -1439,8 +1256,6 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 	struct i40e_pf *pf = vf->pf;
 	u16 vsi_id = vqs->vsi_id;
 	i40e_status aq_ret = 0;
-	unsigned long tempmap;
-	u16 queue_id;
 
 	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states)) {
 		aq_ret = I40E_ERR_PARAM;
@@ -1457,64 +1272,8 @@ static int i40e_vc_disable_queues_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 		goto error_param;
 	}
 
-	tempmap = vqs->rx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
-		if (!i40e_vc_isvalid_queue_id(vf, vsi_id, queue_id)) {
-			aq_ret = I40E_ERR_PARAM;
-			goto error_param;
-		}
-		i40e_ctrl_vsi_rx_queue(vf, vsi_id, queue_id,
-				       I40E_QUEUE_CTRL_DISABLE);
-
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
-	}
-
-	tempmap = vqs->tx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
-		if (!i40e_vc_isvalid_queue_id(vf, vsi_id, queue_id)) {
-			aq_ret = I40E_ERR_PARAM;
-			goto error_param;
-		}
-		i40e_ctrl_vsi_tx_queue(vf, vsi_id, queue_id,
-				       I40E_QUEUE_CTRL_DISABLE);
-
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
-	}
-
-	/* Poll the status register to make sure that the
-	 * requested op was completed successfully
-	 */
-	udelay(10);
-
-	tempmap = vqs->rx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
-		if (i40e_ctrl_vsi_rx_queue(vf, vsi_id, queue_id,
-					   I40E_QUEUE_CTRL_DISABLECHECK)) {
-			dev_err(&pf->pdev->dev,
-				"Queue control check failed on RX queue %d of VSI %d VF %d\n",
-				queue_id, vsi_id, vf->vf_id);
-		}
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
-	}
-
-	tempmap = vqs->tx_queues;
-	queue_id = find_first_bit(&tempmap, I40E_MAX_VSI_QP);
-	while (queue_id < I40E_MAX_VSI_QP) {
-		if (i40e_ctrl_vsi_tx_queue(vf, vsi_id, queue_id,
-					   I40E_QUEUE_CTRL_DISABLECHECK)) {
-			dev_err(&pf->pdev->dev,
-				"Queue control check failed on TX queue %d of VSI %d VF %d\n",
-				queue_id, vsi_id, vf->vf_id);
-		}
-		queue_id = find_next_bit(&tempmap, I40E_MAX_VSI_QP,
-					 queue_id + 1);
-	}
+	if (i40e_vsi_control_rings(pf->vsi[vsi_id], false))
+		aq_ret = I40E_ERR_TIMEOUT;
 
 error_param:
 	/* send the response to the vf */
-- 
1.8.3.1
