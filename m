From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] i40e: use a local variable instead of calculating multiple times
Date: Mon,  9 Oct 2017 15:38:39 -0700
Message-ID: <20171009223841.2557-13-jeffrey.t.kirsher@intel.com>
References: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Cc: Lihong Yang <lihong.yang@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36097 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755565AbdJIWjI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 18:39:08 -0400
In-Reply-To: <20171009223841.2557-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lihong Yang <lihong.yang@intel.com>

The computed result of I40E_MAX_VSI_QP * I40E_VIRTCHNL_SUPPORTED_QTYPES
is used more than three times in function i40e_config_irq_link_list.
Simply declare a local variable to store it to improve readability.

Signed-off-by: Lihong Yang <lihong.yang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 20 +++++++-------------
 1 file changed, 7 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 125dcd1d2233..0c4fa225c7be 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -273,7 +273,7 @@ static void i40e_config_irq_link_list(struct i40e_vf *vf, u16 vsi_id,
 	struct i40e_hw *hw = &pf->hw;
 	u16 vsi_queue_id, pf_queue_id;
 	enum i40e_queue_type qtype;
-	u16 next_q, vector_id;
+	u16 next_q, vector_id, size;
 	u32 reg, reg_idx;
 	u16 itr_idx = 0;
 
@@ -303,11 +303,9 @@ static void i40e_config_irq_link_list(struct i40e_vf *vf, u16 vsi_id,
 				     vsi_queue_id + 1));
 	}
 
-	next_q = find_first_bit(&linklistmap,
-				(I40E_MAX_VSI_QP *
-				 I40E_VIRTCHNL_SUPPORTED_QTYPES));
-	if (unlikely(next_q == (I40E_MAX_VSI_QP *
-				I40E_VIRTCHNL_SUPPORTED_QTYPES)))
+	size = I40E_MAX_VSI_QP * I40E_VIRTCHNL_SUPPORTED_QTYPES;
+	next_q = find_first_bit(&linklistmap, size);
+	if (unlikely(next_q == size))
 		goto irq_list_done;
 
 	vsi_queue_id = next_q / I40E_VIRTCHNL_SUPPORTED_QTYPES;
@@ -317,7 +315,7 @@ static void i40e_config_irq_link_list(struct i40e_vf *vf, u16 vsi_id,
 
 	wr32(hw, reg_idx, reg);
 
-	while (next_q < (I40E_MAX_VSI_QP * I40E_VIRTCHNL_SUPPORTED_QTYPES)) {
+	while (next_q < size) {
 		switch (qtype) {
 		case I40E_QUEUE_TYPE_RX:
 			reg_idx = I40E_QINT_RQCTL(pf_queue_id);
@@ -331,12 +329,8 @@ static void i40e_config_irq_link_list(struct i40e_vf *vf, u16 vsi_id,
 			break;
 		}
 
-		next_q = find_next_bit(&linklistmap,
-				       (I40E_MAX_VSI_QP *
-					I40E_VIRTCHNL_SUPPORTED_QTYPES),
-				       next_q + 1);
-		if (next_q <
-		    (I40E_MAX_VSI_QP * I40E_VIRTCHNL_SUPPORTED_QTYPES)) {
+		next_q = find_next_bit(&linklistmap, size, next_q + 1);
+		if (next_q < size) {
 			vsi_queue_id = next_q / I40E_VIRTCHNL_SUPPORTED_QTYPES;
 			qtype = next_q % I40E_VIRTCHNL_SUPPORTED_QTYPES;
 			pf_queue_id = i40e_vc_get_pf_queue_id(vf, vsi_id,
-- 
2.14.2
