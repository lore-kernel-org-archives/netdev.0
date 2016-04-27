From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/14] i40e: Add support for configuring VF RSS
Date: Wed, 27 Apr 2016 13:15:42 -0700
Message-ID: <1461788153-12869-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461788153-12869-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63244 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753126AbcD0UQ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2016 16:16:29 -0400
In-Reply-To: <1461788153-12869-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Add support for configuring RSS on behalf of the VFs. This removes the
burden of dealing with different hardware interfaces from the VF
drivers, allowing for better future compatibility.

Change-ID: Icea75d3f37241ee8e447be5779e5abb53ddf04c0
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h             |   1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c        |  35 +++-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 193 ++++++++++++++++++++-
 3 files changed, 217 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index d25b3be..e312adf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -202,6 +202,7 @@ struct i40e_lump_tracking {
 
 #define I40E_HKEY_ARRAY_SIZE ((I40E_PFQF_HKEY_MAX_INDEX + 1) * 4)
 #define I40E_HLUT_ARRAY_SIZE ((I40E_PFQF_HLUT_MAX_INDEX + 1) * 4)
+#define I40E_VF_HLUT_ARRAY_SIZE ((I40E_VFQF_HLUT1_MAX_INDEX + 1) * 4)
 
 enum i40e_fd_stat_idx {
 	I40E_FD_STAT_ATR,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ec94ad6c..39b3b56 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8082,24 +8082,45 @@ static int i40e_config_rss_reg(struct i40e_vsi *vsi, const u8 *seed,
 {
 	struct i40e_pf *pf = vsi->back;
 	struct i40e_hw *hw = &pf->hw;
+	u16 vf_id = vsi->vf_id;
 	u8 i;
 
 	/* Fill out hash function seed */
 	if (seed) {
 		u32 *seed_dw = (u32 *)seed;
 
-		for (i = 0; i <= I40E_PFQF_HKEY_MAX_INDEX; i++)
-			i40e_write_rx_ctl(hw, I40E_PFQF_HKEY(i), seed_dw[i]);
+		if (vsi->type == I40E_VSI_MAIN) {
+			for (i = 0; i <= I40E_PFQF_HKEY_MAX_INDEX; i++)
+				i40e_write_rx_ctl(hw, I40E_PFQF_HKEY(i),
+						  seed_dw[i]);
+		} else if (vsi->type == I40E_VSI_SRIOV) {
+			for (i = 0; i <= I40E_VFQF_HKEY1_MAX_INDEX; i++)
+				i40e_write_rx_ctl(hw,
+						  I40E_VFQF_HKEY1(i, vf_id),
+						  seed_dw[i]);
+		} else {
+			dev_err(&pf->pdev->dev, "Cannot set RSS seed - invalid VSI type\n");
+		}
 	}
 
 	if (lut) {
 		u32 *lut_dw = (u32 *)lut;
 
-		if (lut_size != I40E_HLUT_ARRAY_SIZE)
-			return -EINVAL;
-
-		for (i = 0; i <= I40E_PFQF_HLUT_MAX_INDEX; i++)
-			wr32(hw, I40E_PFQF_HLUT(i), lut_dw[i]);
+		if (vsi->type == I40E_VSI_MAIN) {
+			if (lut_size != I40E_HLUT_ARRAY_SIZE)
+				return -EINVAL;
+			for (i = 0; i <= I40E_PFQF_HLUT_MAX_INDEX; i++)
+				wr32(hw, I40E_PFQF_HLUT(i), lut_dw[i]);
+		} else if (vsi->type == I40E_VSI_SRIOV) {
+			if (lut_size != I40E_VF_HLUT_ARRAY_SIZE)
+				return -EINVAL;
+			for (i = 0; i <= I40E_VFQF_HLUT_MAX_INDEX; i++)
+				i40e_write_rx_ctl(hw,
+						  I40E_VFQF_HLUT1(i, vf_id),
+						  lut_dw[i]);
+		} else {
+			dev_err(&pf->pdev->dev, "Cannot set RSS LUT - invalid VSI type\n");
+		}
 	}
 	i40e_flush(hw);
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 30f8cbe..c364588 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1348,12 +1348,16 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 		set_bit(I40E_VF_STAT_IWARPENA, &vf->vf_states);
 	}
 
-	if (pf->flags & I40E_FLAG_RSS_AQ_CAPABLE) {
-		if (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ)
-			vfres->vf_offload_flags |=
-				I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ;
+	if (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF) {
+		vfres->vf_offload_flags |= I40E_VIRTCHNL_VF_OFFLOAD_RSS_PF;
 	} else {
-		vfres->vf_offload_flags |= I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG;
+		if ((pf->flags & I40E_FLAG_RSS_AQ_CAPABLE) &&
+		    (vf->driver_caps & I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ))
+			vfres->vf_offload_flags |=
+					I40E_VIRTCHNL_VF_OFFLOAD_RSS_AQ;
+		else
+			vfres->vf_offload_flags |=
+					I40E_VIRTCHNL_VF_OFFLOAD_RSS_REG;
 	}
 
 	if (pf->flags & I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE) {
@@ -1382,6 +1386,9 @@ static int i40e_vc_get_vf_resources_msg(struct i40e_vf *vf, u8 *msg)
 	vfres->num_vsis = num_vsis;
 	vfres->num_queue_pairs = vf->num_queue_pairs;
 	vfres->max_vectors = pf->hw.func_caps.num_msix_vectors_vf;
+	vfres->rss_key_size = I40E_HKEY_ARRAY_SIZE;
+	vfres->rss_lut_size = I40E_VF_HLUT_ARRAY_SIZE;
+
 	if (vf->lan_vsi_idx) {
 		vfres->vsi_res[0].vsi_id = vf->lan_vsi_id;
 		vfres->vsi_res[0].vsi_type = I40E_VSI_SRIOV;
@@ -2042,6 +2049,139 @@ error_param:
 }
 
 /**
+ * i40e_vc_config_rss_key
+ * @vf: pointer to the VF info
+ * @msg: pointer to the msg buffer
+ * @msglen: msg length
+ *
+ * Configure the VF's RSS key
+ **/
+static int i40e_vc_config_rss_key(struct i40e_vf *vf, u8 *msg, u16 msglen)
+{
+	struct i40e_virtchnl_rss_key *vrk =
+		(struct i40e_virtchnl_rss_key *)msg;
+	struct i40e_pf *pf = vf->pf;
+	struct i40e_vsi *vsi = NULL;
+	u16 vsi_id = vrk->vsi_id;
+	i40e_status aq_ret = 0;
+
+	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
+	    !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps) ||
+	    !i40e_vc_isvalid_vsi_id(vf, vsi_id) ||
+	    (vrk->key_len != I40E_HKEY_ARRAY_SIZE)) {
+		aq_ret = I40E_ERR_PARAM;
+		goto err;
+	}
+
+	vsi = pf->vsi[vf->lan_vsi_idx];
+	aq_ret = i40e_config_rss(vsi, vrk->key, NULL, 0);
+err:
+	/* send the response to the VF */
+	return i40e_vc_send_resp_to_vf(vf, I40E_VIRTCHNL_OP_CONFIG_RSS_KEY,
+				       aq_ret);
+}
+
+/**
+ * i40e_vc_config_rss_lut
+ * @vf: pointer to the VF info
+ * @msg: pointer to the msg buffer
+ * @msglen: msg length
+ *
+ * Configure the VF's RSS LUT
+ **/
+static int i40e_vc_config_rss_lut(struct i40e_vf *vf, u8 *msg, u16 msglen)
+{
+	struct i40e_virtchnl_rss_lut *vrl =
+		(struct i40e_virtchnl_rss_lut *)msg;
+	struct i40e_pf *pf = vf->pf;
+	struct i40e_vsi *vsi = NULL;
+	u16 vsi_id = vrl->vsi_id;
+	i40e_status aq_ret = 0;
+
+	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
+	    !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps) ||
+	    !i40e_vc_isvalid_vsi_id(vf, vsi_id) ||
+	    (vrl->lut_entries != I40E_VF_HLUT_ARRAY_SIZE)) {
+		aq_ret = I40E_ERR_PARAM;
+		goto err;
+	}
+
+	vsi = pf->vsi[vf->lan_vsi_idx];
+	aq_ret = i40e_config_rss(vsi, NULL, vrl->lut, I40E_VF_HLUT_ARRAY_SIZE);
+	/* send the response to the VF */
+err:
+	return i40e_vc_send_resp_to_vf(vf, I40E_VIRTCHNL_OP_CONFIG_RSS_LUT,
+				       aq_ret);
+}
+
+/**
+ * i40e_vc_get_rss_hena
+ * @vf: pointer to the VF info
+ * @msg: pointer to the msg buffer
+ * @msglen: msg length
+ *
+ * Return the RSS HENA bits allowed by the hardware
+ **/
+static int i40e_vc_get_rss_hena(struct i40e_vf *vf, u8 *msg, u16 msglen)
+{
+	struct i40e_virtchnl_rss_hena *vrh = NULL;
+	struct i40e_pf *pf = vf->pf;
+	i40e_status aq_ret = 0;
+	int len = 0;
+
+	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
+	    !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
+		aq_ret = I40E_ERR_PARAM;
+		goto err;
+	}
+	len = sizeof(struct i40e_virtchnl_rss_hena);
+
+	vrh = kzalloc(len, GFP_KERNEL);
+	if (!vrh) {
+		aq_ret = I40E_ERR_NO_MEMORY;
+		len = 0;
+		goto err;
+	}
+	vrh->hena = i40e_pf_get_default_rss_hena(pf);
+err:
+	/* send the response back to the VF */
+	aq_ret = i40e_vc_send_msg_to_vf(vf, I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS,
+					aq_ret, (u8 *)vrh, len);
+	return aq_ret;
+}
+
+/**
+ * i40e_vc_set_rss_hena
+ * @vf: pointer to the VF info
+ * @msg: pointer to the msg buffer
+ * @msglen: msg length
+ *
+ * Set the RSS HENA bits for the VF
+ **/
+static int i40e_vc_set_rss_hena(struct i40e_vf *vf, u8 *msg, u16 msglen)
+{
+	struct i40e_virtchnl_rss_hena *vrh =
+		(struct i40e_virtchnl_rss_hena *)msg;
+	struct i40e_pf *pf = vf->pf;
+	struct i40e_hw *hw = &pf->hw;
+	i40e_status aq_ret = 0;
+
+	if (!test_bit(I40E_VF_STAT_ACTIVE, &vf->vf_states) ||
+	    !test_bit(I40E_VIRTCHNL_VF_CAP_PRIVILEGE, &vf->vf_caps)) {
+		aq_ret = I40E_ERR_PARAM;
+		goto err;
+	}
+	i40e_write_rx_ctl(hw, I40E_VFQF_HENA1(0, vf->vf_id), (u32)vrh->hena);
+	i40e_write_rx_ctl(hw, I40E_VFQF_HENA1(1, vf->vf_id),
+			  (u32)(vrh->hena >> 32));
+
+	/* send the response to the VF */
+err:
+	return i40e_vc_send_resp_to_vf(vf, I40E_VIRTCHNL_OP_SET_RSS_HENA,
+				       aq_ret);
+}
+
+/**
  * i40e_vc_validate_vf_msg
  * @vf: pointer to the VF info
  * @msg: pointer to the msg buffer
@@ -2162,6 +2302,36 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 				sizeof(struct i40e_virtchnl_iwarp_qv_info));
 		}
 		break;
+	case I40E_VIRTCHNL_OP_CONFIG_RSS_KEY:
+		valid_len = sizeof(struct i40e_virtchnl_rss_key);
+		if (msglen >= valid_len) {
+			struct i40e_virtchnl_rss_key *vrk =
+				(struct i40e_virtchnl_rss_key *)msg;
+			if (vrk->key_len != I40E_HKEY_ARRAY_SIZE) {
+				err_msg_format = true;
+				break;
+			}
+			valid_len += vrk->key_len - 1;
+		}
+		break;
+	case I40E_VIRTCHNL_OP_CONFIG_RSS_LUT:
+		valid_len = sizeof(struct i40e_virtchnl_rss_lut);
+		if (msglen >= valid_len) {
+			struct i40e_virtchnl_rss_lut *vrl =
+				(struct i40e_virtchnl_rss_lut *)msg;
+			if (vrl->lut_entries != I40E_VF_HLUT_ARRAY_SIZE) {
+				err_msg_format = true;
+				break;
+			}
+			valid_len += vrl->lut_entries - 1;
+		}
+		break;
+	case I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS:
+		valid_len = 0;
+		break;
+	case I40E_VIRTCHNL_OP_SET_RSS_HENA:
+		valid_len = sizeof(struct i40e_virtchnl_rss_hena);
+		break;
 	/* These are always errors coming from the VF. */
 	case I40E_VIRTCHNL_OP_EVENT:
 	case I40E_VIRTCHNL_OP_UNKNOWN:
@@ -2260,6 +2430,19 @@ int i40e_vc_process_vf_msg(struct i40e_pf *pf, u16 vf_id, u32 v_opcode,
 	case I40E_VIRTCHNL_OP_RELEASE_IWARP_IRQ_MAP:
 		ret = i40e_vc_iwarp_qvmap_msg(vf, msg, msglen, false);
 		break;
+	case I40E_VIRTCHNL_OP_CONFIG_RSS_KEY:
+		ret = i40e_vc_config_rss_key(vf, msg, msglen);
+		break;
+	case I40E_VIRTCHNL_OP_CONFIG_RSS_LUT:
+		ret = i40e_vc_config_rss_lut(vf, msg, msglen);
+		break;
+	case I40E_VIRTCHNL_OP_GET_RSS_HENA_CAPS:
+		ret = i40e_vc_get_rss_hena(vf, msg, msglen);
+		break;
+	case I40E_VIRTCHNL_OP_SET_RSS_HENA:
+		ret = i40e_vc_set_rss_hena(vf, msg, msglen);
+		break;
+
 	case I40E_VIRTCHNL_OP_UNKNOWN:
 	default:
 		dev_err(&pf->pdev->dev, "Unsupported opcode %d from VF %d\n",
-- 
2.5.5
