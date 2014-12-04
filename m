From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Use correct fastpath version for VFs.
Date: Thu, 4 Dec 2014 12:52:06 +0200
Message-ID: <1417690326-11422-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:21963 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752712AbaLDKyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 05:54:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our FW can support several fastpath HSI [for backward compatibility] but up
until now VFs were always configured to use latest fastpath HSI [although VF
driver might be older and use an older fastpath HSI].

For linux drivers, the differences are insignificant since driver never
utilized features that were overridden by the HSI change. But for VMs running
other operating systems this might be a problem.
In addition, eventually FW might change fastpath HSI in such a manner that
backward compatibility WILL break unless configured with proper version.

This patch fixes the issue for other operating system VMs, as well as lays
the ground work for forward compatibility in regard to the fastpath HSI.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
Hi Dave,

Please consider applying this patch to `net-next'.

[Notice there's a single too-long line in it, but there was no 'good'
way of preventing it]

Thanks,
Yuval Mintz

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c    |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h    |  2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |  1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |  2 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  | 75 ++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h  |  9 ++-
 7 files changed, 88 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 336ef3c..07c6368 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -3163,6 +3163,8 @@ static void bnx2x_pf_q_prep_general(struct bnx2x *bp,
 		gen_init->mtu = bp->dev->mtu;
 
 	gen_init->cos = cos;
+
+	gen_init->fp_hsi = ETH_FP_HSI_VERSION;
 }
 
 static void bnx2x_pf_rx_q_prep(struct bnx2x *bp,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 7bc2924..07cdf9b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -4336,7 +4336,7 @@ static void bnx2x_q_fill_init_general_data(struct bnx2x *bp,
 		test_bit(BNX2X_Q_FLG_FCOE, flags) ?
 		LLFC_TRAFFIC_TYPE_FCOE : LLFC_TRAFFIC_TYPE_NW;
 
-	gen_data->fp_hsi_ver = ETH_FP_HSI_VERSION;
+	gen_data->fp_hsi_ver = params->fp_hsi;
 
 	DP(BNX2X_MSG_SP, "flags: active %d, cos %d, stats en %d\n",
 	   gen_data->activate_flg, gen_data->cos, gen_data->statistics_en_flg);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index e97275f..86baecb 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -937,6 +937,8 @@ struct bnx2x_general_setup_params {
 	u8		spcl_id;
 	u16		mtu;
 	u8		cos;
+
+	u8		fp_hsi;
 };
 
 struct bnx2x_rxq_setup_params {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index c88b20a..e5aca2d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -193,6 +193,7 @@ void bnx2x_vfop_qctor_prep(struct bnx2x *bp,
 	/* Setup-op general parameters */
 	setup_p->gen_params.spcl_id = vf->sp_cl_id;
 	setup_p->gen_params.stat_id = vfq_stat_id(vf, q);
+	setup_p->gen_params.fp_hsi = vf->fp_hsi;
 
 	/* Setup-op pause params:
 	 * Nothing to do, the pause thresholds are set by default to 0 which
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 01bafa4..66ee62a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -205,6 +205,8 @@ struct bnx2x_virtf {
 	/* slow-path operations */
 	struct mutex			op_mutex; /* one vfop at a time mutex */
 	enum channel_tlvs		op_current;
+
+	u8 fp_hsi;
 };
 
 #define BNX2X_NR_VIRTFN(bp)	((bp)->vfdb->sriov.nr_virtfn)
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index b1d9c44..be40eab 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -224,6 +224,7 @@ int bnx2x_vfpf_acquire(struct bnx2x *bp, u8 tx_count, u8 rx_count)
 	struct vfpf_acquire_tlv *req = &bp->vf2pf_mbox->req.acquire;
 	struct pfvf_acquire_resp_tlv *resp = &bp->vf2pf_mbox->resp.acquire_resp;
 	struct vfpf_port_phys_id_resp_tlv *phys_port_resp;
+	struct vfpf_fp_hsi_resp_tlv *fp_hsi_resp;
 	u32 vf_id;
 	bool resources_acquired = false;
 
@@ -237,6 +238,7 @@ int bnx2x_vfpf_acquire(struct bnx2x *bp, u8 tx_count, u8 rx_count)
 
 	req->vfdev_info.vf_id = vf_id;
 	req->vfdev_info.vf_os = 0;
+	req->vfdev_info.fp_hsi_ver = ETH_FP_HSI_VERSION;
 
 	req->resc_request.num_rxqs = rx_count;
 	req->resc_request.num_txqs = tx_count;
@@ -316,9 +318,14 @@ int bnx2x_vfpf_acquire(struct bnx2x *bp, u8 tx_count, u8 rx_count)
 			memset(&bp->vf2pf_mbox->resp, 0,
 			       sizeof(union pfvf_tlvs));
 		} else {
-			/* PF reports error */
-			BNX2X_ERR("Failed to get the requested amount of resources: %d. Breaking...\n",
-				  bp->acquire_resp.hdr.status);
+			/* Determine reason of PF failure of acquire process */
+			fp_hsi_resp = bnx2x_search_tlv_list(bp, resp,
+							    CHANNEL_TLV_FP_HSI_SUPPORT);
+			if (fp_hsi_resp && !fp_hsi_resp->is_supported)
+				BNX2X_ERR("Old hypervisor - doesn't support current fastpath HSI version; Need to downgrade VF driver [or upgrade hypervisor]\n");
+			else
+				BNX2X_ERR("Failed to get the requested amount of resources: %d. Breaking...\n",
+					  bp->acquire_resp.hdr.status);
 			rc = -EAGAIN;
 			goto out;
 		}
@@ -333,6 +340,25 @@ int bnx2x_vfpf_acquire(struct bnx2x *bp, u8 tx_count, u8 rx_count)
 		bp->flags |= HAS_PHYS_PORT_ID;
 	}
 
+	/* Old Hypevisors might not even support the FP_HSI_SUPPORT TLV.
+	 * If that's the case, we need to make certain required FW was
+	 * supported by such a hypervisor [i.e., v0-v2].
+	 */
+	fp_hsi_resp = bnx2x_search_tlv_list(bp, resp,
+					    CHANNEL_TLV_FP_HSI_SUPPORT);
+	if (!fp_hsi_resp && (ETH_FP_HSI_VERSION > ETH_FP_HSI_VER_2)) {
+		BNX2X_ERR("Old hypervisor - need to downgrade VF's driver\n");
+
+		/* Since acquire succeeded on the PF side, we need to send a
+		 * release message in order to allow future probes.
+		 */
+		bnx2x_vfpf_finalize(bp, &req->first_tlv);
+		bnx2x_vfpf_release(bp);
+
+		rc = -EINVAL;
+		goto out;
+	}
+
 	/* get HW info */
 	bp->common.chip_id |= (bp->acquire_resp.pfdev_info.chip_num & 0xffff);
 	bp->link_params.chip_id = bp->common.chip_id;
@@ -1125,6 +1151,26 @@ static void bnx2x_vf_mbx_resp_phys_port(struct bnx2x *bp,
 	*offset += sizeof(struct vfpf_port_phys_id_resp_tlv);
 }
 
+static void bnx2x_vf_mbx_resp_fp_hsi_ver(struct bnx2x *bp,
+					 struct bnx2x_virtf *vf,
+					 void *buffer,
+					 u16 *offset)
+{
+	struct vfpf_fp_hsi_resp_tlv *fp_hsi;
+
+	bnx2x_add_tlv(bp, buffer, *offset, CHANNEL_TLV_FP_HSI_SUPPORT,
+		      sizeof(struct vfpf_fp_hsi_resp_tlv));
+
+	fp_hsi = (struct vfpf_fp_hsi_resp_tlv *)
+		 (((u8 *)buffer) + *offset);
+	fp_hsi->is_supported = (vf->fp_hsi > ETH_FP_HSI_VERSION) ? 0 : 1;
+
+	/* Offset should continue representing the offset to the tail
+	 * of TLV data (outside this function scope)
+	 */
+	*offset += sizeof(struct vfpf_fp_hsi_resp_tlv);
+}
+
 static void bnx2x_vf_mbx_acquire_resp(struct bnx2x *bp, struct bnx2x_virtf *vf,
 				      struct bnx2x_vf_mbx *mbx, int vfop_status)
 {
@@ -1219,6 +1265,12 @@ static void bnx2x_vf_mbx_acquire_resp(struct bnx2x *bp, struct bnx2x_virtf *vf,
 				  CHANNEL_TLV_PHYS_PORT_ID))
 		bnx2x_vf_mbx_resp_phys_port(bp, vf, &mbx->msg->resp, &length);
 
+	/* `New' vfs will want to know if fastpath HSI is supported, since
+	 * if that's not the case they could print into system log the fact
+	 * the driver version must be updated.
+	 */
+	bnx2x_vf_mbx_resp_fp_hsi_ver(bp, vf, &mbx->msg->resp, &length);
+
 	bnx2x_add_tlv(bp, &mbx->msg->resp, length, CHANNEL_TLV_LIST_END,
 		      sizeof(struct channel_list_end_tlv));
 
@@ -1288,6 +1340,23 @@ static void bnx2x_vf_mbx_acquire(struct bnx2x *bp, struct bnx2x_virtf *vf,
 		goto out;
 	}
 
+	/* Verify the VF fastpath HSI can be supported by the loaded FW.
+	 * Linux vfs should be oblivious to changes between v0 and v2.
+	 */
+	if (bnx2x_vf_mbx_is_windows_vm(bp, &mbx->msg->req.acquire))
+		vf->fp_hsi = acquire->vfdev_info.fp_hsi_ver;
+	else
+		vf->fp_hsi = max_t(u8, acquire->vfdev_info.fp_hsi_ver,
+				   ETH_FP_HSI_VER_2);
+	if (vf->fp_hsi > ETH_FP_HSI_VERSION) {
+		DP(BNX2X_MSG_IOV,
+		   "VF [%d] - Can't support acquire request since VF requests a FW version which is too new [%02x > %02x]\n",
+		   vf->abs_vfid, acquire->vfdev_info.fp_hsi_ver,
+		   ETH_FP_HSI_VERSION);
+		rc = -EINVAL;
+		goto out;
+	}
+
 	/* acquire the resources */
 	rc = bnx2x_vf_acquire(bp, vf, &acquire->resc_request);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
index 15670c4..b86479f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
@@ -124,7 +124,7 @@ struct vfpf_acquire_tlv {
 #define VF_OS_UNDEFINED		(0 << VF_OS_SHIFT)
 #define VF_OS_WINDOWS		(1 << VF_OS_SHIFT)
 
-		u8 padding;
+		u8 fp_hsi_ver;
 		u8 caps;
 #define VF_CAP_SUPPORT_EXT_BULLETIN	(1 << 0)
 	} vfdev_info;
@@ -204,6 +204,12 @@ struct vfpf_port_phys_id_resp_tlv {
 	u8 padding[2];
 };
 
+struct vfpf_fp_hsi_resp_tlv {
+	struct channel_tlv tl;
+	u8 is_supported;
+	u8 padding[3];
+};
+
 #define VFPF_INIT_FLG_STATS_COALESCE	(1 << 0) /* when set the VFs queues
 						  * stats will be coalesced on
 						  * the leading RSS queue
@@ -448,6 +454,7 @@ enum channel_tlvs {
 	CHANNEL_TLV_UPDATE_RSS,
 	CHANNEL_TLV_PHYS_PORT_ID,
 	CHANNEL_TLV_UPDATE_TPA,
+	CHANNEL_TLV_FP_HSI_SUPPORT,
 	CHANNEL_TLV_MAX
 };
 
-- 
1.9.3
