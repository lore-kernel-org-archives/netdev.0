From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/14] i40e/virtchnl: refactor code for validate checks
Date: Thu,  1 Jun 2017 14:38:33 -0700
Message-ID: <20170601213840.36286-8-jeffrey.t.kirsher@intel.com>
References: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:40283 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751157AbdFAVjB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 17:39:01 -0400
In-Reply-To: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This change updates the arguments passed to the validate function
and fixes the caller, as well as uses the new return values added to
virtchnl.h

One other minor tweak, remove a duplicate set to zero of valid_len.

This is in preparation for moving the function to virtchnl.h.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 36 ++++++++++++----------
 include/linux/avf/virtchnl.h                       | 17 ++++++++++
 2 files changed, 37 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 923026a255c0..61f948c587ad 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -2536,15 +2536,16 @@ static int i40e_vc_set_rss_hena(struct i40e_vf *vf, u8 *msg, u16 msglen)
 
 /**
  * i40e_vc_validate_vf_msg
- * @vf: pointer to the VF info
+ * @ver: Virtchnl version info
+ * @v_opcode: Opcode for the message
  * @msg: pointer to the msg buffer
  * @msglen: msg length
- * @msghndl: msg handle
  *
- * validate msg
+ * validate msg format against struct for each opcode
  **/
-static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
-				   u32 v_retval, u8 *msg, u16 msglen)
+static int
+i40e_vc_validate_vf_msg(struct virtchnl_version_info *ver, u32 v_opcode,
+			u8 *msg, u16 msglen)
 {
 	bool err_msg_format = false;
 	int valid_len = 0;
@@ -2557,7 +2558,7 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 	case VIRTCHNL_OP_RESET_VF:
 		break;
 	case VIRTCHNL_OP_GET_VF_RESOURCES:
-		if (VF_IS_V11(&vf->vf_ver))
+		if (VF_IS_V11(ver))
 			valid_len = sizeof(u32);
 		break;
 	case VIRTCHNL_OP_CONFIG_TX_QUEUE:
@@ -2633,7 +2634,6 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 			err_msg_format = true;
 		break;
 	case VIRTCHNL_OP_RELEASE_IWARP_IRQ_MAP:
-		valid_len = 0;
 		break;
 	case VIRTCHNL_OP_CONFIG_IWARP_IRQ_MAP:
 		valid_len = sizeof(struct virtchnl_iwarp_qvlist_info);
@@ -2673,15 +2673,13 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 	case VIRTCHNL_OP_EVENT:
 	case VIRTCHNL_OP_UNKNOWN:
 	default:
-		return -EPERM;
+		return VIRTCHNL_ERR_PARAM;
 	}
 	/* few more checks */
-	if ((valid_len != msglen) || (err_msg_format)) {
-		i40e_vc_send_resp_to_vf(vf, v_opcode, I40E_ERR_PARAM);
-		return -EINVAL;
-	} else {
-		return 0;
-	}
+	if ((valid_len != msglen) || (err_msg_format))
+		return VIRTCHNL_STATUS_ERR_OPCODE_MISMATCH;
+
+	return 0;
 }
 
 /**
@@ -2713,7 +2711,7 @@ int i40e_vc_process_vf_msg(struct i40e_pf *pf, s16 vf_id, u32 v_opcode,
 		return I40E_ERR_PARAM;
 
 	/* perform basic checks on the msg */
-	ret = i40e_vc_validate_vf_msg(vf, v_opcode, v_retval, msg, msglen);
+	ret = i40e_vc_validate_vf_msg(&vf->vf_ver, v_opcode, msg, msglen);
 
 	/* perform additional checks specific to this driver */
 	if (v_opcode == VIRTCHNL_OP_CONFIG_RSS_KEY) {
@@ -2729,9 +2727,15 @@ int i40e_vc_process_vf_msg(struct i40e_pf *pf, s16 vf_id, u32 v_opcode,
 	}
 
 	if (ret) {
+		i40e_vc_send_resp_to_vf(vf, v_opcode, I40E_ERR_PARAM);
 		dev_err(&pf->pdev->dev, "Invalid message from VF %d, opcode %d, len %d\n",
 			local_vf_id, v_opcode, msglen);
-		return ret;
+		switch (ret) {
+		case VIRTCHNL_ERR_PARAM:
+			return -EPERM;
+		default:
+			return -EINVAL;
+		}
 	}
 
 	switch (v_opcode) {
diff --git a/include/linux/avf/virtchnl.h b/include/linux/avf/virtchnl.h
index 8ffa670c2ffd..f1cc1f02036e 100644
--- a/include/linux/avf/virtchnl.h
+++ b/include/linux/avf/virtchnl.h
@@ -53,6 +53,23 @@
  * its queues, optionally add MAC and VLAN filters, and process traffic.
  */
 
+/* START GENERIC DEFINES
+ * Need to ensure the following enums and defines hold the same meaning and
+ * value in current and future projects
+ */
+
+/* Error Codes */
+enum virtchnl_status_code {
+	VIRTCHNL_STATUS_SUCCESS				= 0,
+	VIRTCHNL_ERR_PARAM				= -5,
+	VIRTCHNL_STATUS_ERR_OPCODE_MISMATCH		= -38,
+	VIRTCHNL_STATUS_ERR_CQP_COMPL_ERROR		= -39,
+	VIRTCHNL_STATUS_ERR_INVALID_VF_ID		= -40,
+	VIRTCHNL_STATUS_NOT_SUPPORTED			= -64,
+};
+
+/* END GENERIC DEFINES */
+
 /* Opcodes for VF-PF communication. These are placed in the v_opcode field
  * of the virtchnl_msg structure.
  */
-- 
2.12.2
