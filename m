From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/6] qed: Relax VF firmware requirements
Date: Sun, 5 Jun 2016 13:11:11 +0300
Message-ID: <1465121476-32494-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:45880 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750785AbcFEKLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 06:11:32 -0400
In-Reply-To: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current driver require an exact match between VF and PF storm firmware;
Any difference would fail the VF acquire message, causing the VF probe
to be aborted.

While there's still dependencies between the two, the recent FW submission
has relaxed the match requirement - instead of an exact match, there's now
a 'fastpath' HSI major/minor scheme, where VFs and PFs that match in their
major number can co-exist even if their minor is different.

In order to accomadate this change some changes in the vf-start init flow
had to be made, as the VF start ramrod now has to be sent only after PF
learns which fastpath HSI its VF is requiring.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed_sriov.c | 131 ++++++++++++++++++----------
 drivers/net/ethernet/qlogic/qed/qed_sriov.h |   3 +
 drivers/net/ethernet/qlogic/qed/qed_vf.c    |  19 ++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h    |  13 ++-
 4 files changed, 116 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index eb75b82..9857624 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -21,18 +21,18 @@
 #include "qed_vf.h"
 
 /* IOV ramrods */
-static int qed_sp_vf_start(struct qed_hwfn *p_hwfn,
-			   u32 concrete_vfid, u16 opaque_vfid)
+static int qed_sp_vf_start(struct qed_hwfn *p_hwfn, struct qed_vf_info *p_vf)
 {
 	struct vf_start_ramrod_data *p_ramrod = NULL;
 	struct qed_spq_entry *p_ent = NULL;
 	struct qed_sp_init_data init_data;
 	int rc = -EINVAL;
+	u8 fp_minor;
 
 	/* Get SPQ entry */
 	memset(&init_data, 0, sizeof(init_data));
 	init_data.cid = qed_spq_get_cid(p_hwfn);
-	init_data.opaque_fid = opaque_vfid;
+	init_data.opaque_fid = p_vf->opaque_fid;
 	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
 
 	rc = qed_sp_init_request(p_hwfn, &p_ent,
@@ -43,12 +43,39 @@ static int qed_sp_vf_start(struct qed_hwfn *p_hwfn,
 
 	p_ramrod = &p_ent->ramrod.vf_start;
 
-	p_ramrod->vf_id = GET_FIELD(concrete_vfid, PXP_CONCRETE_FID_VFID);
-	p_ramrod->opaque_fid = cpu_to_le16(opaque_vfid);
+	p_ramrod->vf_id = GET_FIELD(p_vf->concrete_fid, PXP_CONCRETE_FID_VFID);
+	p_ramrod->opaque_fid = cpu_to_le16(p_vf->opaque_fid);
+
+	switch (p_hwfn->hw_info.personality) {
+	case QED_PCI_ETH:
+		p_ramrod->personality = PERSONALITY_ETH;
+		break;
+	case QED_PCI_ETH_ROCE:
+		p_ramrod->personality = PERSONALITY_RDMA_AND_ETH;
+		break;
+	default:
+		DP_NOTICE(p_hwfn, "Unknown VF personality %d\n",
+			  p_hwfn->hw_info.personality);
+		return -EINVAL;
+	}
+
+	fp_minor = p_vf->acquire.vfdev_info.eth_fp_hsi_minor;
+	if (fp_minor > ETH_HSI_VER_MINOR) {
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_IOV,
+			   "VF [%d] - Requested fp hsi %02x.%02x which is slightly newer than PF's %02x.%02x; Configuring PFs version\n",
+			   p_vf->abs_vf_id,
+			   ETH_HSI_VER_MAJOR,
+			   fp_minor, ETH_HSI_VER_MAJOR, ETH_HSI_VER_MINOR);
+		fp_minor = ETH_HSI_VER_MINOR;
+	}
 
-	p_ramrod->personality = PERSONALITY_ETH;
 	p_ramrod->hsi_fp_ver.major_ver_arr[ETH_VER_KEY] = ETH_HSI_VER_MAJOR;
-	p_ramrod->hsi_fp_ver.minor_ver_arr[ETH_VER_KEY] = ETH_HSI_VER_MINOR;
+	p_ramrod->hsi_fp_ver.minor_ver_arr[ETH_VER_KEY] = fp_minor;
+
+	DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+		   "VF[%d] - Starting using HSI %02x.%02x\n",
+		   p_vf->abs_vf_id, ETH_HSI_VER_MAJOR, fp_minor);
 
 	return qed_spq_post(p_hwfn, p_ent, NULL);
 }
@@ -600,17 +627,6 @@ static int qed_iov_enable_vf_access(struct qed_hwfn *p_hwfn,
 	/* unpretend */
 	qed_fid_pretend(p_hwfn, p_ptt, (u16) p_hwfn->hw_info.concrete_fid);
 
-	if (vf->state != VF_STOPPED) {
-		DP_NOTICE(p_hwfn, "VF[%02x] is already started\n",
-			  vf->abs_vf_id);
-		return -EINVAL;
-	}
-
-	/* Start VF */
-	rc = qed_sp_vf_start(p_hwfn, vf->concrete_fid, vf->opaque_fid);
-	if (rc)
-		DP_NOTICE(p_hwfn, "Failed to start VF[%02x]\n", vf->abs_vf_id);
-
 	vf->state = VF_FREE;
 
 	return rc;
@@ -854,7 +870,6 @@ static int qed_iov_release_hw_for_vf(struct qed_hwfn *p_hwfn,
 	struct qed_mcp_link_params params;
 	struct qed_mcp_link_state link;
 	struct qed_vf_info *vf = NULL;
-	int rc = 0;
 
 	vf = qed_iov_get_vf_info(p_hwfn, rel_vf_id, true);
 	if (!vf) {
@@ -876,18 +891,8 @@ static int qed_iov_release_hw_for_vf(struct qed_hwfn *p_hwfn,
 	memcpy(&caps, qed_mcp_get_link_capabilities(p_hwfn), sizeof(caps));
 	qed_iov_set_link(p_hwfn, rel_vf_id, &params, &link, &caps);
 
-	if (vf->state != VF_STOPPED) {
-		/* Stopping the VF */
-		rc = qed_sp_vf_stop(p_hwfn, vf->concrete_fid, vf->opaque_fid);
-
-		if (rc != 0) {
-			DP_ERR(p_hwfn, "qed_sp_vf_stop returned error %d\n",
-			       rc);
-			return rc;
-		}
-
-		vf->state = VF_STOPPED;
-	}
+	/* Forget the VF's acquisition message */
+	memset(&vf->acquire, 0, sizeof(vf->acquire));
 
 	/* disablng interrupts and resetting permission table was done during
 	 * vf-close, however, we could get here without going through vf_close
@@ -1132,6 +1137,7 @@ static void qed_iov_vf_cleanup(struct qed_hwfn *p_hwfn,
 		p_vf->vf_queues[i].rxq_active = 0;
 
 	memset(&p_vf->shadow_config, 0, sizeof(p_vf->shadow_config));
+	memset(&p_vf->acquire, 0, sizeof(p_vf->acquire));
 	qed_iov_clean_vf(p_hwfn, p_vf->relative_vf_id);
 }
 
@@ -1143,25 +1149,27 @@ static void qed_iov_vf_mbx_acquire(struct qed_hwfn *p_hwfn,
 	struct pfvf_acquire_resp_tlv *resp = &mbx->reply_virt->acquire_resp;
 	struct pf_vf_pfdev_info *pfdev_info = &resp->pfdev_info;
 	struct vfpf_acquire_tlv *req = &mbx->req_virt->acquire;
-	u8 i, vfpf_status = PFVF_STATUS_SUCCESS;
+	u8 i, vfpf_status = PFVF_STATUS_NOT_SUPPORTED;
 	struct pf_vf_resc *resc = &resp->resc;
+	int rc;
+
+	memset(resp, 0, sizeof(*resp));
 
 	/* Validate FW compatibility */
-	if (req->vfdev_info.fw_major != FW_MAJOR_VERSION ||
-	    req->vfdev_info.fw_minor != FW_MINOR_VERSION ||
-	    req->vfdev_info.fw_revision != FW_REVISION_VERSION ||
-	    req->vfdev_info.fw_engineering != FW_ENGINEERING_VERSION) {
+	if (req->vfdev_info.eth_fp_hsi_major != ETH_HSI_VER_MAJOR) {
 		DP_INFO(p_hwfn,
-			"VF[%d] is running an incompatible driver [VF needs FW %02x:%02x:%02x:%02x but Hypervisor is using %02x:%02x:%02x:%02x]\n",
+			"VF[%d] needs fastpath HSI %02x.%02x, which is incompatible with loaded FW's faspath HSI %02x.%02x\n",
 			vf->abs_vf_id,
-			req->vfdev_info.fw_major,
-			req->vfdev_info.fw_minor,
-			req->vfdev_info.fw_revision,
-			req->vfdev_info.fw_engineering,
-			FW_MAJOR_VERSION,
-			FW_MINOR_VERSION,
-			FW_REVISION_VERSION, FW_ENGINEERING_VERSION);
-		vfpf_status = PFVF_STATUS_NOT_SUPPORTED;
+			req->vfdev_info.eth_fp_hsi_major,
+			req->vfdev_info.eth_fp_hsi_minor,
+			ETH_HSI_VER_MAJOR, ETH_HSI_VER_MINOR);
+
+		/* Write the PF version so that VF would know which version
+		 * is supported.
+		 */
+		pfdev_info->major_fp_hsi = ETH_HSI_VER_MAJOR;
+		pfdev_info->minor_fp_hsi = ETH_HSI_VER_MINOR;
+
 		goto out;
 	}
 
@@ -1171,11 +1179,11 @@ static void qed_iov_vf_mbx_acquire(struct qed_hwfn *p_hwfn,
 		DP_INFO(p_hwfn,
 			"VF[%d] is running an old driver that doesn't support 100g\n",
 			vf->abs_vf_id);
-		vfpf_status = PFVF_STATUS_NOT_SUPPORTED;
 		goto out;
 	}
 
-	memset(resp, 0, sizeof(*resp));
+	/* Store the acquire message */
+	memcpy(&vf->acquire, req, sizeof(vf->acquire));
 
 	/* Fill in vf info stuff */
 	vf->opaque_fid = req->vfdev_info.opaque_fid;
@@ -1223,6 +1231,9 @@ static void qed_iov_vf_mbx_acquire(struct qed_hwfn *p_hwfn,
 	pfdev_info->fw_minor = FW_MINOR_VERSION;
 	pfdev_info->fw_rev = FW_REVISION_VERSION;
 	pfdev_info->fw_eng = FW_ENGINEERING_VERSION;
+	pfdev_info->minor_fp_hsi = min_t(u8,
+					 ETH_HSI_VER_MINOR,
+					 req->vfdev_info.eth_fp_hsi_minor);
 	pfdev_info->os_type = VFPF_ACQUIRE_OS_LINUX;
 	qed_mcp_get_mfw_ver(p_hwfn, p_ptt, &pfdev_info->mfw_ver, NULL);
 
@@ -1253,6 +1264,14 @@ static void qed_iov_vf_mbx_acquire(struct qed_hwfn *p_hwfn,
 	 */
 	resc->num_mc_filters = req->resc_request.num_mc_filters;
 
+	/* Start the VF in FW */
+	rc = qed_sp_vf_start(p_hwfn, vf);
+	if (rc) {
+		DP_NOTICE(p_hwfn, "Failed to start VF[%02x]\n", vf->abs_vf_id);
+		vfpf_status = PFVF_STATUS_FAILURE;
+		goto out;
+	}
+
 	/* Fill agreed size of bulletin board in response */
 	resp->bulletin_size = vf->bulletin.size;
 	qed_iov_post_vf_bulletin(p_hwfn, vf->relative_vf_id, p_ptt);
@@ -2360,11 +2379,27 @@ static void qed_iov_vf_mbx_release(struct qed_hwfn *p_hwfn,
 				   struct qed_vf_info *p_vf)
 {
 	u16 length = sizeof(struct pfvf_def_resp_tlv);
+	u8 status = PFVF_STATUS_SUCCESS;
+	int rc = 0;
 
 	qed_iov_vf_cleanup(p_hwfn, p_vf);
 
+	if (p_vf->state != VF_STOPPED && p_vf->state != VF_FREE) {
+		/* Stopping the VF */
+		rc = qed_sp_vf_stop(p_hwfn, p_vf->concrete_fid,
+				    p_vf->opaque_fid);
+
+		if (rc) {
+			DP_ERR(p_hwfn, "qed_sp_vf_stop returned error %d\n",
+			       rc);
+			status = PFVF_STATUS_FAILURE;
+		}
+
+		p_vf->state = VF_STOPPED;
+	}
+
 	qed_iov_prepare_resp(p_hwfn, p_ptt, p_vf, CHANNEL_TLV_RELEASE,
-			     length, PFVF_STATUS_SUCCESS);
+			     length, status);
 }
 
 static int
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index c8667c6..2bcaeb3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -131,6 +131,9 @@ struct qed_vf_info {
 	struct qed_bulletin bulletin;
 	dma_addr_t vf_bulletin;
 
+	/* PF saves a copy of the last VF acquire message */
+	struct vfpf_acquire_tlv acquire;
+
 	u32 concrete_fid;
 	u16 opaque_fid;
 	u16 mtu;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.c b/drivers/net/ethernet/qlogic/qed/qed_vf.c
index 72e69c0..ce8aec3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.c
@@ -147,6 +147,8 @@ static int qed_vf_pf_acquire(struct qed_hwfn *p_hwfn)
 	req->vfdev_info.fw_minor = FW_MINOR_VERSION;
 	req->vfdev_info.fw_revision = FW_REVISION_VERSION;
 	req->vfdev_info.fw_engineering = FW_ENGINEERING_VERSION;
+	req->vfdev_info.eth_fp_hsi_major = ETH_HSI_VER_MAJOR;
+	req->vfdev_info.eth_fp_hsi_minor = ETH_HSI_VER_MINOR;
 
 	/* Fill capability field with any non-deprecated config we support */
 	req->vfdev_info.capabilities |= VFPF_ACQUIRE_CAP_100G;
@@ -200,6 +202,16 @@ static int qed_vf_pf_acquire(struct qed_hwfn *p_hwfn)
 
 			/* Clear response buffer */
 			memset(p_iov->pf2vf_reply, 0, sizeof(union pfvf_tlvs));
+		} else if ((resp->hdr.status == PFVF_STATUS_NOT_SUPPORTED) &&
+			   pfdev_info->major_fp_hsi &&
+			   (pfdev_info->major_fp_hsi != ETH_HSI_VER_MAJOR)) {
+			DP_NOTICE(p_hwfn,
+				  "PF uses an incompatible fastpath HSI %02x.%02x [VF requires %02x.%02x]. Please change to a VF driver using %02x.xx.\n",
+				  pfdev_info->major_fp_hsi,
+				  pfdev_info->minor_fp_hsi,
+				  ETH_HSI_VER_MAJOR,
+				  ETH_HSI_VER_MINOR, pfdev_info->major_fp_hsi);
+			return -EINVAL;
 		} else {
 			DP_ERR(p_hwfn,
 			       "PF returned error %d to VF acquisition request\n",
@@ -225,6 +237,13 @@ static int qed_vf_pf_acquire(struct qed_hwfn *p_hwfn)
 		}
 	}
 
+	if (ETH_HSI_VER_MINOR &&
+	    (resp->pfdev_info.minor_fp_hsi < ETH_HSI_VER_MINOR)) {
+		DP_INFO(p_hwfn,
+			"PF is using older fastpath HSI; %02x.%02x is configured\n",
+			ETH_HSI_VER_MAJOR, resp->pfdev_info.minor_fp_hsi);
+	}
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index b82fda9..b23ce58 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -96,7 +96,9 @@ struct vfpf_acquire_tlv {
 		u32 driver_version;
 		u16 opaque_fid;	/* ME register value */
 		u8 os_type;	/* VFPF_ACQUIRE_OS_* value */
-		u8 padding[5];
+		u8 eth_fp_hsi_major;
+		u8 eth_fp_hsi_minor;
+		u8 padding[3];
 	} vfdev_info;
 
 	struct vf_pf_resc_request resc_request;
@@ -171,7 +173,14 @@ struct pfvf_acquire_resp_tlv {
 		struct pfvf_stats_info stats_info;
 
 		u8 port_mac[ETH_ALEN];
-		u8 padding2[2];
+
+		/* It's possible PF had to configure an older fastpath HSI
+		 * [in case VF is newer than PF]. This is communicated back
+		 * to the VF. It can also be used in case of error due to
+		 * non-matching versions to shed light in VF about failure.
+		 */
+		u8 major_fp_hsi;
+		u8 minor_fp_hsi;
 	} pfdev_info;
 
 	struct pf_vf_resc {
-- 
1.9.3
