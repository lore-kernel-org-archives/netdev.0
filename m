From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH v2 net-next 19/22] bnx2x: Support of PF driver of a VF
 release request
Date: Thu, 15 Nov 2012 18:47:44 +0200
Message-ID: <1352998067-9707-20-git-send-email-ariele@broadcom.com>
References: <1352998067-9707-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3492 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1768479Ab2KOQqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 11:46:16 -0500
In-Reply-To: <1352998067-9707-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'release' request is the opposite of the 'acquire' request.
At release, all the resources allocated to the VF are reclaimed.
The release flow applies the close flow if applicable.
Note that there are actually two types of release:
1. The VF has been removed, and so issued a 'release' request
over the VF <-> PF Channel.
2. The PF is going down and so has to release all of it's VFs.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |  123 +++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |   23 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  |   25 ++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h  |    1 +
 5 files changed, 172 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 1f82d8b..4fa3e74 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -8611,6 +8611,7 @@ void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode, bool keep_link)
 
 	netif_addr_unlock_bh(bp->dev);
 
+	bnx2x_iov_chip_cleanup(bp);
 
 
 	/*
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
index 888e3ec..3baa26d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
@@ -1423,6 +1423,14 @@ bnx2x_iov_static_resc(struct bnx2x *bp, struct vf_pf_resc_request *resc)
 	/* num_sbs already set */
 }
 
+/* FLR routines: */
+static void bnx2x_vf_free_resc(struct bnx2x *bp, struct bnx2x_virtf *vf)
+{
+	/* reset the state variables */
+	bnx2x_iov_static_resc(bp, &vf->alloc_resc);
+	vf->state = VF_FREE;
+}
+
 /* called by bnx2x_init_hw_func, returns the next ilt line */
 
 /* IOV global initialization routines  */
@@ -1946,6 +1954,22 @@ int bnx2x_iov_nic_init(struct bnx2x *bp)
 	return 0;
 }
 
+/* called by bnx2x_chip_cleanup */
+int bnx2x_iov_chip_cleanup(struct bnx2x *bp)
+{
+	int i;
+
+	if (!IS_SRIOV(bp))
+		return 0;
+
+	/* release all the VFs */
+	for_each_vf(bp, i)
+		bnx2x_vf_release(bp, BP_VF(bp, i), true); /* blocking */
+
+	return 0;
+}
+
+/* called by bnx2x_init_hw_func, returns the next ilt line */
 int bnx2x_iov_init_ilt(struct bnx2x *bp, u16 line)
 {
 	int i;
@@ -2565,6 +2589,105 @@ int bnx2x_vfop_close_cmd(struct bnx2x *bp,
 	}
 	return -ENOMEM;
 }
+
+/* VF release can be called either: 1. the VF was acquired but
+ * not enabled 2. the vf was enabled or in the process of being
+ * enabled
+ */
+static void bnx2x_vfop_release(struct bnx2x *bp, struct bnx2x_virtf *vf)
+{
+	struct bnx2x_vfop *vfop = bnx2x_vfop_cur(bp, vf);
+	struct bnx2x_vfop_cmd cmd = {
+		.done = bnx2x_vfop_release,
+		.block = false,
+	};
+
+	DP(BNX2X_MSG_IOV, "vfop->rc %d\n", vfop->rc);
+
+	if (vfop->rc < 0)
+		goto op_err;
+
+	DP(BNX2X_MSG_IOV, "VF[%d] STATE: %s\n", vf->abs_vfid,
+	   vf->state == VF_FREE ? "Free" :
+	   vf->state == VF_ACQUIRED ? "Acquired" :
+	   vf->state == VF_ENABLED ? "Enabled" :
+	   vf->state == VF_RESET ? "Reset" :
+	   "Unknown");
+
+	switch (vf->state) {
+	case VF_ENABLED:
+		vfop->rc = bnx2x_vfop_close_cmd(bp, vf, &cmd);
+		if (vfop->rc)
+			goto op_err;
+		return;
+
+	case VF_ACQUIRED:
+		DP(BNX2X_MSG_IOV, "about to free resources\n");
+		bnx2x_vf_free_resc(bp, vf);
+		DP(BNX2X_MSG_IOV, "vfop->rc %d\n", vfop->rc);
+		goto op_done;
+
+	case VF_FREE:
+	case VF_RESET:
+		/* do nothing */
+		goto op_done;
+	default:
+		bnx2x_vfop_default(vf->state);
+	}
+op_err:
+	BNX2X_ERR("VF[%d] RELEASE error: rc %d\n", vf->abs_vfid, vfop->rc);
+op_done:
+	bnx2x_vfop_end(bp, vf, vfop);
+}
+
+int bnx2x_vfop_release_cmd(struct bnx2x *bp,
+			   struct bnx2x_virtf *vf,
+			   struct bnx2x_vfop_cmd *cmd)
+{
+	struct bnx2x_vfop *vfop = bnx2x_vfop_add(bp, vf);
+	if (vfop) {
+		bnx2x_vfop_opset(-1, /* use vf->state */
+				 bnx2x_vfop_release, cmd->done);
+		return bnx2x_vfop_transition(bp, vf, bnx2x_vfop_release,
+					     cmd->block);
+	}
+	return -ENOMEM;
+}
+
+/* VF release ~ VF close + VF release-resources
+ * Release is the ultimate SW shutdown and is called whenever an
+ * irrecoverable error is encountered.
+ */
+void bnx2x_vf_release(struct bnx2x *bp, struct bnx2x_virtf *vf, bool block)
+{
+	struct bnx2x_vfop_cmd cmd = {
+		.done = NULL,
+		.block = block,
+	};
+	int rc;
+	bnx2x_lock_vf_pf_channel(bp, vf, CHANNEL_TLV_PF_RELEASE_VF);
+	rc = bnx2x_vfop_release_cmd(bp, vf, &cmd);
+	if (rc)
+		WARN(rc,
+		     "VF[%d] Failed to allocate resources for release op- rc=%d\n",
+		     vf->abs_vfid, rc);
+}
+
+static inline void bnx2x_vf_get_sbdf(struct bnx2x *bp,
+			      struct bnx2x_virtf *vf, u32 *sbdf)
+{
+	*sbdf = vf->devfn | (vf->bus << 8);
+}
+
+static inline void bnx2x_vf_get_bars(struct bnx2x *bp, struct bnx2x_virtf *vf,
+		       struct bnx2x_vf_bar_info *bar_info)
+{
+	int n;
+	bar_info->nr_bars = bp->vfdb->sriov.nres;
+	for (n = 0; n < bar_info->nr_bars; n++)
+		bar_info->bars[n] = vf->bars[n];
+}
+
 void bnx2x_lock_vf_pf_channel(struct bnx2x *bp, struct bnx2x_virtf *vf,
 			      enum channel_tlvs tlv)
 {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
index 9fadabc..3a750af 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -49,6 +49,12 @@ struct bnx2x_vf_bar {
 	u64 bar;
 	u32 size;
 };
+
+struct bnx2x_vf_bar_info {
+	struct bnx2x_vf_bar bars[PCI_SRIOV_NUM_BARS];
+	u8 nr_bars;
+};
+
 /* vf queue (used both for rx or tx) */
 struct bnx2x_vf_queue {
 	struct eth_context		*cxt;
@@ -430,6 +436,7 @@ void __devexit bnx2x_iov_remove_one(struct bnx2x *bp);
 void bnx2x_iov_free_mem(struct bnx2x *bp);
 int bnx2x_iov_alloc_mem(struct bnx2x *bp);
 int bnx2x_iov_nic_init(struct bnx2x *bp);
+int bnx2x_iov_chip_cleanup(struct bnx2x *bp);
 void bnx2x_iov_init_dq(struct bnx2x *bp);
 void bnx2x_iov_init_dmae(struct bnx2x *bp);
 void bnx2x_iov_set_queue_sp_obj(struct bnx2x *bp, int vf_cid,
@@ -547,6 +554,11 @@ static inline void bnx2x_vfop_end(struct bnx2x *bp, struct bnx2x_virtf *vf,
 	if (vfop->done) {
 		DP(BNX2X_MSG_IOV, "calling done handler\n");
 		vfop->done(bp, vf);
+	} else {
+		/* there is no done handler for the operation to unlock
+		 * the mutex. Must have gotten here from PF initiated VF RELEASE
+		 */
+		bnx2x_unlock_vf_pf_channel(bp, vf, CHANNEL_TLV_PF_RELEASE_VF);
 	}
 
 	DP(BNX2X_MSG_IOV, "done handler complete. vf->op_rc %d, vfop->rc %d\n",
@@ -665,6 +677,17 @@ int bnx2x_vfop_close_cmd(struct bnx2x *bp,
 			 struct bnx2x_virtf *vf,
 			 struct bnx2x_vfop_cmd *cmd);
 
+int bnx2x_vfop_release_cmd(struct bnx2x *bp,
+			   struct bnx2x_virtf *vf,
+			   struct bnx2x_vfop_cmd *cmd);
+
+/**
+ * VF release ~ VF close + VF release-resources
+ *
+ * Release is the ultimate SW shutdown and is called whenever an
+ * irrecoverable error is encountered.
+ */
+void bnx2x_vf_release(struct bnx2x *bp, struct bnx2x_virtf *vf, bool block);
 int bnx2x_vf_idx_by_abs_fid(struct bnx2x *bp, u16 abs_vfid);
 u8 bnx2x_vf_max_queue_cnt(struct bnx2x *bp, struct bnx2x_virtf *vf);
 /* VF FLR helpers */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
index 96a1de3..0955ba4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c
@@ -233,7 +233,7 @@ static void bnx2x_vf_mbx_resp(struct bnx2x *bp, struct bnx2x_virtf *vf)
 		if (rc) {
 			BNX2X_ERR("Failed to copy response body to VF %d\n",
 				  vf->abs_vfid);
-			return;
+			goto mbx_error;
 		}
 		vf_addr -= sizeof(u64);
 		pf_addr -= sizeof(u64);
@@ -260,8 +260,12 @@ static void bnx2x_vf_mbx_resp(struct bnx2x *bp, struct bnx2x_virtf *vf)
 	if (rc) {
 		BNX2X_ERR("Failed to copy response status to VF %d\n",
 			  vf->abs_vfid);
+		goto mbx_error;
 	}
 	return;
+
+mbx_error:
+	bnx2x_vf_release(bp, vf, false); /* non blocking */
 }
 
 static void bnx2x_vf_mbx_acquire_resp(struct bnx2x *bp, struct bnx2x_virtf *vf,
@@ -835,6 +839,21 @@ static void bnx2x_vf_mbx_close_vf(struct bnx2x *bp, struct bnx2x_virtf *vf,
 		bnx2x_vf_mbx_close_done(bp, vf);
 }
 
+static void bnx2x_vf_mbx_release_vf(struct bnx2x *bp, struct bnx2x_virtf *vf,
+				    struct bnx2x_vf_mbx *mbx)
+{
+	struct bnx2x_vfop_cmd cmd = {
+		.done = bnx2x_vf_mbx_resp,
+		.block = false,
+	};
+
+	DP(BNX2X_MSG_IOV, "VF[%d] VF_RELEASE\n", vf->abs_vfid);
+
+	vf->op_rc = bnx2x_vfop_release_cmd(bp, vf, &cmd);
+	if (vf->op_rc)
+		bnx2x_vf_mbx_resp(bp, vf);
+}
+
 /* dispatch request */
 static void bnx2x_vf_mbx_request(struct bnx2x *bp, struct bnx2x_virtf *vf,
 				  struct bnx2x_vf_mbx *mbx)
@@ -869,6 +888,9 @@ static void bnx2x_vf_mbx_request(struct bnx2x *bp, struct bnx2x_virtf *vf,
 		case CHANNEL_TLV_CLOSE:
 			bnx2x_vf_mbx_close_vf(bp, vf, mbx);
 			break;
+		case CHANNEL_TLV_RELEASE:
+			bnx2x_vf_mbx_release_vf(bp, vf, mbx);
+			break;
 		}
 
 	/* unknown TLV - this may belong to a VF driver from the future - a
@@ -965,6 +987,7 @@ void bnx2x_vf_mbx(struct bnx2x *bp, struct vf_pf_event_data *vfpf_event)
 	goto mbx_done;
 
 mbx_error:
+	bnx2x_vf_release(bp, vf, false); /* non blocking */
 mbx_done:
 	return;
 }
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
index 95f5c2b..6e06d00 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.h
@@ -304,6 +304,7 @@ enum channel_tlvs {
 	   CHANNEL_TLV_TEARDOWN_Q,
 	   CHANNEL_TLV_CLOSE,
 	   CHANNEL_TLV_RELEASE,
+	   CHANNEL_TLV_PF_RELEASE_VF,
 	   CHANNEL_TLV_LIST_END,
 	   CHANNEL_TLV_MAX
 };
-- 
1.7.9.GIT
