From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next v2 02/14] qed: Add VF->PF channel infrastructure
Date: Wed, 11 May 2016 16:36:13 +0300
Message-ID: <1462973785-32532-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:15961 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932634AbcEKNgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 May 2016 09:36:45 -0400
In-Reply-To: <1462973785-32532-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Communication between VF and PF is based on a dedicated HW channel;
VF will prepare a messge, and by signaling the HW the PF would get a
notification of that message existance. The PF would then copy the
message, process it and DMA an answer back to the VF as a response.

The messages themselves are TLV-based - allowing easier backward/forward
compatibility.

This patch adds the infrastructure of the channel on the PF side -
starting with the arrival of the notification and ending with DMAing
the response back to the VF.

It also adds a dummy-response as reference, as it only lays the
groundwork of the communication; it doesn't really add support of any
actual messages.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h         |   6 +
 drivers/net/ethernet/qlogic/qed/qed_dev_api.h |  27 +-
 drivers/net/ethernet/qlogic/qed/qed_hsi.h     |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_hw.c      |  44 ++-
 drivers/net/ethernet/qlogic/qed/qed_main.c    |  10 +-
 drivers/net/ethernet/qlogic/qed/qed_spq.c     |  16 +-
 drivers/net/ethernet/qlogic/qed/qed_sriov.c   | 385 ++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_sriov.h   |  53 ++++
 drivers/net/ethernet/qlogic/qed/qed_vf.h      |  52 ++++
 include/linux/qed/common_hsi.h                |   5 +
 10 files changed, 585 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index 2e067c7..01f9b6c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -378,6 +378,12 @@ struct qed_hwfn {
 
 	struct qed_simd_fp_handler	simd_proto_handler[64];
 
+#ifdef CONFIG_QED_SRIOV
+	struct workqueue_struct *iov_wq;
+	struct delayed_work iov_task;
+	unsigned long iov_task_flags;
+#endif
+
 	struct z_stream_s		*stream;
 };
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
index 6aac3f8..f567371 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev_api.h
@@ -182,11 +182,15 @@ enum qed_dmae_address_type_t {
  * used mostly to write a zeroed buffer to destination address
  * using DMA
  */
-#define QED_DMAE_FLAG_RW_REPL_SRC       0x00000001
-#define QED_DMAE_FLAG_COMPLETION_DST    0x00000008
+#define QED_DMAE_FLAG_RW_REPL_SRC	0x00000001
+#define QED_DMAE_FLAG_VF_SRC		0x00000002
+#define QED_DMAE_FLAG_VF_DST		0x00000004
+#define QED_DMAE_FLAG_COMPLETION_DST	0x00000008
 
 struct qed_dmae_params {
-	u32	flags; /* consists of QED_DMAE_FLAG_* values */
+	u32 flags; /* consists of QED_DMAE_FLAG_* values */
+	u8 src_vfid;
+	u8 dst_vfid;
 };
 
 /**
@@ -209,6 +213,23 @@ qed_dmae_host2grc(struct qed_hwfn *p_hwfn,
 		  u32 flags);
 
 /**
+ * @brief qed_dmae_host2host - copy data from to source address
+ * to a destination adress (for SRIOV) using the given ptt
+ *
+ * @param p_hwfn
+ * @param p_ptt
+ * @param source_addr
+ * @param dest_addr
+ * @param size_in_dwords
+ * @param params
+ */
+int qed_dmae_host2host(struct qed_hwfn *p_hwfn,
+		       struct qed_ptt *p_ptt,
+		       dma_addr_t source_addr,
+		       dma_addr_t dest_addr,
+		       u32 size_in_dwords, struct qed_dmae_params *p_params);
+
+/**
  * @brief qed_chain_alloc - Allocate and initialize a chain
  *
  * @param p_hwfn
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hsi.h b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
index c4fae71..6ba197c 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hsi.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_hsi.h
@@ -31,7 +31,7 @@ enum common_event_opcode {
 	COMMON_EVENT_PF_STOP,
 	COMMON_EVENT_RESERVED,
 	COMMON_EVENT_RESERVED2,
-	COMMON_EVENT_RESERVED3,
+	COMMON_EVENT_VF_PF_CHANNEL,
 	COMMON_EVENT_RESERVED4,
 	COMMON_EVENT_RESERVED5,
 	COMMON_EVENT_RESERVED6,
diff --git a/drivers/net/ethernet/qlogic/qed/qed_hw.c b/drivers/net/ethernet/qlogic/qed/qed_hw.c
index a8cf96c..a9be5a4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_hw.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_hw.c
@@ -355,8 +355,8 @@ static void qed_dmae_opcode(struct qed_hwfn *p_hwfn,
 			    const u8 is_dst_type_grc,
 			    struct qed_dmae_params *p_params)
 {
+	u16 opcode_b = 0;
 	u32 opcode = 0;
-	u16 opcodeB = 0;
 
 	/* Whether the source is the PCIe or the GRC.
 	 * 0- The source is the PCIe
@@ -398,14 +398,24 @@ static void qed_dmae_opcode(struct qed_hwfn *p_hwfn,
 	opcode |= (DMAE_CMD_DST_ADDR_RESET_MASK <<
 		   DMAE_CMD_DST_ADDR_RESET_SHIFT);
 
-	opcodeB |= (DMAE_CMD_SRC_VF_ID_MASK <<
-		    DMAE_CMD_SRC_VF_ID_SHIFT);
+	/* SRC/DST VFID: all 1's - pf, otherwise VF id */
+	if (p_params->flags & QED_DMAE_FLAG_VF_SRC) {
+		opcode |= 1 << DMAE_CMD_SRC_VF_ID_VALID_SHIFT;
+		opcode_b |= p_params->src_vfid << DMAE_CMD_SRC_VF_ID_SHIFT;
+	} else {
+		opcode_b |= DMAE_CMD_SRC_VF_ID_MASK <<
+			    DMAE_CMD_SRC_VF_ID_SHIFT;
+	}
 
-	opcodeB |= (DMAE_CMD_DST_VF_ID_MASK <<
-		    DMAE_CMD_DST_VF_ID_SHIFT);
+	if (p_params->flags & QED_DMAE_FLAG_VF_DST) {
+		opcode |= 1 << DMAE_CMD_DST_VF_ID_VALID_SHIFT;
+		opcode_b |= p_params->dst_vfid << DMAE_CMD_DST_VF_ID_SHIFT;
+	} else {
+		opcode_b |= DMAE_CMD_DST_VF_ID_MASK << DMAE_CMD_DST_VF_ID_SHIFT;
+	}
 
 	p_hwfn->dmae_info.p_dmae_cmd->opcode = cpu_to_le32(opcode);
-	p_hwfn->dmae_info.p_dmae_cmd->opcode_b = cpu_to_le16(opcodeB);
+	p_hwfn->dmae_info.p_dmae_cmd->opcode_b = cpu_to_le16(opcode_b);
 }
 
 u32 qed_dmae_idx_to_go_cmd(u8 idx)
@@ -753,6 +763,28 @@ int qed_dmae_host2grc(struct qed_hwfn *p_hwfn,
 	return rc;
 }
 
+int
+qed_dmae_host2host(struct qed_hwfn *p_hwfn,
+		   struct qed_ptt *p_ptt,
+		   dma_addr_t source_addr,
+		   dma_addr_t dest_addr,
+		   u32 size_in_dwords, struct qed_dmae_params *p_params)
+{
+	int rc;
+
+	mutex_lock(&(p_hwfn->dmae_info.mutex));
+
+	rc = qed_dmae_execute_command(p_hwfn, p_ptt, source_addr,
+				      dest_addr,
+				      QED_DMAE_ADDRESS_HOST_PHYS,
+				      QED_DMAE_ADDRESS_HOST_PHYS,
+				      size_in_dwords, p_params);
+
+	mutex_unlock(&(p_hwfn->dmae_info.mutex));
+
+	return rc;
+}
+
 u16 qed_get_qm_pq(struct qed_hwfn *p_hwfn,
 		  enum protocol_type proto,
 		  union qed_qm_pq_params *p_params)
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 1b758bd..c209ed4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -24,6 +24,7 @@
 #include <linux/qed/qed_if.h>
 
 #include "qed.h"
+#include "qed_sriov.h"
 #include "qed_sp.h"
 #include "qed_dev_api.h"
 #include "qed_mcp.h"
@@ -749,7 +750,10 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 	struct qed_mcp_drv_version drv_version;
 	const u8 *data = NULL;
 	struct qed_hwfn *hwfn;
-	int rc;
+	int rc = -EINVAL;
+
+	if (qed_iov_wq_start(cdev))
+		goto err;
 
 	rc = request_firmware(&cdev->firmware, QED_FW_FILE_NAME,
 			      &cdev->pdev->dev);
@@ -826,6 +830,8 @@ err1:
 err:
 	release_firmware(cdev->firmware);
 
+	qed_iov_wq_stop(cdev, false);
+
 	return rc;
 }
 
@@ -842,6 +848,8 @@ static int qed_slowpath_stop(struct qed_dev *cdev)
 	qed_disable_msix(cdev);
 	qed_nic_reset(cdev);
 
+	qed_iov_wq_stop(cdev, true);
+
 	release_firmware(cdev->firmware);
 
 	return 0;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_spq.c b/drivers/net/ethernet/qlogic/qed/qed_spq.c
index 89469d5..0e439e4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_spq.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_spq.c
@@ -27,6 +27,7 @@
 #include "qed_mcp.h"
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
+#include "qed_sriov.h"
 
 /***************************************************************************
 * Structures & Definitions
@@ -242,10 +243,17 @@ static int
 qed_async_event_completion(struct qed_hwfn *p_hwfn,
 			   struct event_ring_entry *p_eqe)
 {
-	DP_NOTICE(p_hwfn,
-		  "Unknown Async completion for protocol: %d\n",
-		   p_eqe->protocol_id);
-	return -EINVAL;
+	switch (p_eqe->protocol_id) {
+	case PROTOCOLID_COMMON:
+		return qed_sriov_eqe_event(p_hwfn,
+					   p_eqe->opcode,
+					   p_eqe->echo, &p_eqe->data);
+	default:
+		DP_NOTICE(p_hwfn,
+			  "Unknown Async completion for protocol: %d\n",
+			  p_eqe->protocol_id);
+		return -EINVAL;
+	}
 }
 
 /***************************************************************************
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.c b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
index 685e3fa..4a6af42 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.c
@@ -31,6 +31,26 @@ bool qed_iov_is_valid_vfid(struct qed_hwfn *p_hwfn,
 	return true;
 }
 
+static struct qed_vf_info *qed_iov_get_vf_info(struct qed_hwfn *p_hwfn,
+					       u16 relative_vf_id,
+					       bool b_enabled_only)
+{
+	struct qed_vf_info *vf = NULL;
+
+	if (!p_hwfn->pf_iov_info) {
+		DP_NOTICE(p_hwfn->cdev, "No iov info\n");
+		return NULL;
+	}
+
+	if (qed_iov_is_valid_vfid(p_hwfn, relative_vf_id, b_enabled_only))
+		vf = &p_hwfn->pf_iov_info->vfs_array[relative_vf_id];
+	else
+		DP_ERR(p_hwfn, "qed_iov_get_vf_info: VF[%d] is not enabled\n",
+		       relative_vf_id);
+
+	return vf;
+}
+
 static int qed_iov_pci_cfg_info(struct qed_dev *cdev)
 {
 	struct qed_hw_sriov_info *iov = cdev->p_iov_info;
@@ -349,6 +369,232 @@ int qed_iov_hw_info(struct qed_hwfn *p_hwfn)
 	return 0;
 }
 
+static bool qed_iov_pf_sanity_check(struct qed_hwfn *p_hwfn, int vfid)
+{
+	/* Check PF supports sriov */
+	if (!IS_QED_SRIOV(p_hwfn->cdev) || !IS_PF_SRIOV_ALLOC(p_hwfn))
+		return false;
+
+	/* Check VF validity */
+	if (!qed_iov_is_valid_vfid(p_hwfn, vfid, true))
+		return false;
+
+	return true;
+}
+
+static bool qed_iov_tlv_supported(u16 tlvtype)
+{
+	return CHANNEL_TLV_NONE < tlvtype && tlvtype < CHANNEL_TLV_MAX;
+}
+
+/* place a given tlv on the tlv buffer, continuing current tlv list */
+void *qed_add_tlv(struct qed_hwfn *p_hwfn, u8 **offset, u16 type, u16 length)
+{
+	struct channel_tlv *tl = (struct channel_tlv *)*offset;
+
+	tl->type = type;
+	tl->length = length;
+
+	/* Offset should keep pointing to next TLV (the end of the last) */
+	*offset += length;
+
+	/* Return a pointer to the start of the added tlv */
+	return *offset - length;
+}
+
+/* list the types and lengths of the tlvs on the buffer */
+void qed_dp_tlv_list(struct qed_hwfn *p_hwfn, void *tlvs_list)
+{
+	u16 i = 1, total_length = 0;
+	struct channel_tlv *tlv;
+
+	do {
+		tlv = (struct channel_tlv *)((u8 *)tlvs_list + total_length);
+
+		/* output tlv */
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "TLV number %d: type %d, length %d\n",
+			   i, tlv->type, tlv->length);
+
+		if (tlv->type == CHANNEL_TLV_LIST_END)
+			return;
+
+		/* Validate entry - protect against malicious VFs */
+		if (!tlv->length) {
+			DP_NOTICE(p_hwfn, "TLV of length 0 found\n");
+			return;
+		}
+
+		total_length += tlv->length;
+
+		if (total_length >= sizeof(struct tlv_buffer_size)) {
+			DP_NOTICE(p_hwfn, "TLV ==> Buffer overflow\n");
+			return;
+		}
+
+		i++;
+	} while (1);
+}
+
+static void qed_iov_send_response(struct qed_hwfn *p_hwfn,
+				  struct qed_ptt *p_ptt,
+				  struct qed_vf_info *p_vf,
+				  u16 length, u8 status)
+{
+	struct qed_iov_vf_mbx *mbx = &p_vf->vf_mbx;
+	struct qed_dmae_params params;
+	u8 eng_vf_id;
+
+	mbx->reply_virt->default_resp.hdr.status = status;
+
+	qed_dp_tlv_list(p_hwfn, mbx->reply_virt);
+
+	eng_vf_id = p_vf->abs_vf_id;
+
+	memset(&params, 0, sizeof(struct qed_dmae_params));
+	params.flags = QED_DMAE_FLAG_VF_DST;
+	params.dst_vfid = eng_vf_id;
+
+	qed_dmae_host2host(p_hwfn, p_ptt, mbx->reply_phys + sizeof(u64),
+			   mbx->req_virt->first_tlv.reply_address +
+			   sizeof(u64),
+			   (sizeof(union pfvf_tlvs) - sizeof(u64)) / 4,
+			   &params);
+
+	qed_dmae_host2host(p_hwfn, p_ptt, mbx->reply_phys,
+			   mbx->req_virt->first_tlv.reply_address,
+			   sizeof(u64) / 4, &params);
+
+	REG_WR(p_hwfn,
+	       GTT_BAR0_MAP_REG_USDM_RAM +
+	       USTORM_VF_PF_CHANNEL_READY_OFFSET(eng_vf_id), 1);
+}
+
+static void qed_iov_prepare_resp(struct qed_hwfn *p_hwfn,
+				 struct qed_ptt *p_ptt,
+				 struct qed_vf_info *vf_info,
+				 u16 type, u16 length, u8 status)
+{
+	struct qed_iov_vf_mbx *mbx = &vf_info->vf_mbx;
+
+	mbx->offset = (u8 *)mbx->reply_virt;
+
+	qed_add_tlv(p_hwfn, &mbx->offset, type, length);
+	qed_add_tlv(p_hwfn, &mbx->offset, CHANNEL_TLV_LIST_END,
+		    sizeof(struct channel_list_end_tlv));
+
+	qed_iov_send_response(p_hwfn, p_ptt, vf_info, length, status);
+}
+
+static void qed_iov_process_mbx_dummy_resp(struct qed_hwfn *p_hwfn,
+					   struct qed_ptt *p_ptt,
+					   struct qed_vf_info *p_vf)
+{
+	qed_iov_prepare_resp(p_hwfn, p_ptt, p_vf, CHANNEL_TLV_NONE,
+			     sizeof(struct pfvf_def_resp_tlv),
+			     PFVF_STATUS_SUCCESS);
+}
+
+static void qed_iov_process_mbx_req(struct qed_hwfn *p_hwfn,
+				    struct qed_ptt *p_ptt, int vfid)
+{
+	struct qed_iov_vf_mbx *mbx;
+	struct qed_vf_info *p_vf;
+	int i;
+
+	p_vf = qed_iov_get_vf_info(p_hwfn, (u16) vfid, true);
+	if (!p_vf)
+		return;
+
+	mbx = &p_vf->vf_mbx;
+
+	/* qed_iov_process_mbx_request */
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_IOV,
+		   "qed_iov_process_mbx_req vfid %d\n", p_vf->abs_vf_id);
+
+	mbx->first_tlv = mbx->req_virt->first_tlv;
+
+	/* check if tlv type is known */
+	if (qed_iov_tlv_supported(mbx->first_tlv.tl.type)) {
+		qed_iov_process_mbx_dummy_resp(p_hwfn, p_ptt, p_vf);
+	} else {
+		/* unknown TLV - this may belong to a VF driver from the future
+		 * - a version written after this PF driver was written, which
+		 * supports features unknown as of yet. Too bad since we don't
+		 * support them. Or this may be because someone wrote a crappy
+		 * VF driver and is sending garbage over the channel.
+		 */
+		DP_ERR(p_hwfn,
+		       "unknown TLV. type %d length %d. first 20 bytes of mailbox buffer:\n",
+		       mbx->first_tlv.tl.type, mbx->first_tlv.tl.length);
+
+		for (i = 0; i < 20; i++) {
+			DP_VERBOSE(p_hwfn,
+				   QED_MSG_IOV,
+				   "%x ",
+				   mbx->req_virt->tlv_buf_size.tlv_buffer[i]);
+		}
+	}
+}
+
+void qed_iov_pf_add_pending_events(struct qed_hwfn *p_hwfn, u8 vfid)
+{
+	u64 add_bit = 1ULL << (vfid % 64);
+
+	p_hwfn->pf_iov_info->pending_events[vfid / 64] |= add_bit;
+}
+
+static void qed_iov_pf_get_and_clear_pending_events(struct qed_hwfn *p_hwfn,
+						    u64 *events)
+{
+	u64 *p_pending_events = p_hwfn->pf_iov_info->pending_events;
+
+	memcpy(events, p_pending_events, sizeof(u64) * QED_VF_ARRAY_LENGTH);
+	memset(p_pending_events, 0, sizeof(u64) * QED_VF_ARRAY_LENGTH);
+}
+
+static int qed_sriov_vfpf_msg(struct qed_hwfn *p_hwfn,
+			      u16 abs_vfid, struct regpair *vf_msg)
+{
+	u8 min = (u8)p_hwfn->cdev->p_iov_info->first_vf_in_pf;
+	struct qed_vf_info *p_vf;
+
+	if (!qed_iov_pf_sanity_check(p_hwfn, (int)abs_vfid - min)) {
+		DP_VERBOSE(p_hwfn,
+			   QED_MSG_IOV,
+			   "Got a message from VF [abs 0x%08x] that cannot be handled by PF\n",
+			   abs_vfid);
+		return 0;
+	}
+	p_vf = &p_hwfn->pf_iov_info->vfs_array[(u8)abs_vfid - min];
+
+	/* List the physical address of the request so that handler
+	 * could later on copy the message from it.
+	 */
+	p_vf->vf_mbx.pending_req = (((u64)vf_msg->hi) << 32) | vf_msg->lo;
+
+	/* Mark the event and schedule the workqueue */
+	qed_iov_pf_add_pending_events(p_hwfn, p_vf->relative_vf_id);
+	qed_schedule_iov(p_hwfn, QED_IOV_WQ_MSG_FLAG);
+
+	return 0;
+}
+
+int qed_sriov_eqe_event(struct qed_hwfn *p_hwfn,
+			u8 opcode, __le16 echo, union event_ring_data *data)
+{
+	switch (opcode) {
+	case COMMON_EVENT_VF_PF_CHANNEL:
+		return qed_sriov_vfpf_msg(p_hwfn, le16_to_cpu(echo),
+					  &data->vf_pf_channel.msg_addr);
+	default:
+		DP_INFO(p_hwfn->cdev, "Unknown sriov eqe event 0x%02x\n",
+			opcode);
+		return -EINVAL;
+	}
+}
+
 u16 qed_iov_get_next_active_vf(struct qed_hwfn *p_hwfn, u16 rel_vf_id)
 {
 	struct qed_hw_sriov_info *p_iov = p_hwfn->cdev->p_iov_info;
@@ -364,3 +610,142 @@ u16 qed_iov_get_next_active_vf(struct qed_hwfn *p_hwfn, u16 rel_vf_id)
 out:
 	return MAX_NUM_VFS;
 }
+
+static int qed_iov_copy_vf_msg(struct qed_hwfn *p_hwfn, struct qed_ptt *ptt,
+			       int vfid)
+{
+	struct qed_dmae_params params;
+	struct qed_vf_info *vf_info;
+
+	vf_info = qed_iov_get_vf_info(p_hwfn, (u16) vfid, true);
+	if (!vf_info)
+		return -EINVAL;
+
+	memset(&params, 0, sizeof(struct qed_dmae_params));
+	params.flags = QED_DMAE_FLAG_VF_SRC | QED_DMAE_FLAG_COMPLETION_DST;
+	params.src_vfid = vf_info->abs_vf_id;
+
+	if (qed_dmae_host2host(p_hwfn, ptt,
+			       vf_info->vf_mbx.pending_req,
+			       vf_info->vf_mbx.req_phys,
+			       sizeof(union vfpf_tlvs) / 4, &params)) {
+		DP_VERBOSE(p_hwfn, QED_MSG_IOV,
+			   "Failed to copy message from VF 0x%02x\n", vfid);
+
+		return -EIO;
+	}
+
+	return 0;
+}
+
+/**
+ * qed_schedule_iov - schedules IOV task for VF and PF
+ * @hwfn: hardware function pointer
+ * @flag: IOV flag for VF/PF
+ */
+void qed_schedule_iov(struct qed_hwfn *hwfn, enum qed_iov_wq_flag flag)
+{
+	smp_mb__before_atomic();
+	set_bit(flag, &hwfn->iov_task_flags);
+	smp_mb__after_atomic();
+	DP_VERBOSE(hwfn, QED_MSG_IOV, "Scheduling iov task [Flag: %d]\n", flag);
+	queue_delayed_work(hwfn->iov_wq, &hwfn->iov_task, 0);
+}
+
+static void qed_handle_vf_msg(struct qed_hwfn *hwfn)
+{
+	u64 events[QED_VF_ARRAY_LENGTH];
+	struct qed_ptt *ptt;
+	int i;
+
+	ptt = qed_ptt_acquire(hwfn);
+	if (!ptt) {
+		DP_VERBOSE(hwfn, QED_MSG_IOV,
+			   "Can't acquire PTT; re-scheduling\n");
+		qed_schedule_iov(hwfn, QED_IOV_WQ_MSG_FLAG);
+		return;
+	}
+
+	qed_iov_pf_get_and_clear_pending_events(hwfn, events);
+
+	DP_VERBOSE(hwfn, QED_MSG_IOV,
+		   "Event mask of VF events: 0x%llx 0x%llx 0x%llx\n",
+		   events[0], events[1], events[2]);
+
+	qed_for_each_vf(hwfn, i) {
+		/* Skip VFs with no pending messages */
+		if (!(events[i / 64] & (1ULL << (i % 64))))
+			continue;
+
+		DP_VERBOSE(hwfn, QED_MSG_IOV,
+			   "Handling VF message from VF 0x%02x [Abs 0x%02x]\n",
+			   i, hwfn->cdev->p_iov_info->first_vf_in_pf + i);
+
+		/* Copy VF's message to PF's request buffer for that VF */
+		if (qed_iov_copy_vf_msg(hwfn, ptt, i))
+			continue;
+
+		qed_iov_process_mbx_req(hwfn, ptt, i);
+	}
+
+	qed_ptt_release(hwfn, ptt);
+}
+
+void qed_iov_pf_task(struct work_struct *work)
+{
+	struct qed_hwfn *hwfn = container_of(work, struct qed_hwfn,
+					     iov_task.work);
+
+	if (test_and_clear_bit(QED_IOV_WQ_STOP_WQ_FLAG, &hwfn->iov_task_flags))
+		return;
+
+	if (test_and_clear_bit(QED_IOV_WQ_MSG_FLAG, &hwfn->iov_task_flags))
+		qed_handle_vf_msg(hwfn);
+}
+
+void qed_iov_wq_stop(struct qed_dev *cdev, bool schedule_first)
+{
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		if (!cdev->hwfns[i].iov_wq)
+			continue;
+
+		if (schedule_first) {
+			qed_schedule_iov(&cdev->hwfns[i],
+					 QED_IOV_WQ_STOP_WQ_FLAG);
+			cancel_delayed_work_sync(&cdev->hwfns[i].iov_task);
+		}
+
+		flush_workqueue(cdev->hwfns[i].iov_wq);
+		destroy_workqueue(cdev->hwfns[i].iov_wq);
+	}
+}
+
+int qed_iov_wq_start(struct qed_dev *cdev)
+{
+	char name[NAME_SIZE];
+	int i;
+
+	for_each_hwfn(cdev, i) {
+		struct qed_hwfn *p_hwfn = &cdev->hwfns[i];
+
+		/* PFs needs a dedicated workqueue only if they support IOV. */
+		if (!IS_PF_SRIOV(p_hwfn))
+			continue;
+
+		snprintf(name, NAME_SIZE, "iov-%02x:%02x.%02x",
+			 cdev->pdev->bus->number,
+			 PCI_SLOT(cdev->pdev->devfn), p_hwfn->abs_pf_id);
+
+		p_hwfn->iov_wq = create_singlethread_workqueue(name);
+		if (!p_hwfn->iov_wq) {
+			DP_NOTICE(p_hwfn, "Cannot create iov workqueue\n");
+			return -ENOMEM;
+		}
+
+		INIT_DELAYED_WORK(&p_hwfn->iov_task, qed_iov_pf_task);
+	}
+
+	return 0;
+}
diff --git a/drivers/net/ethernet/qlogic/qed/qed_sriov.h b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
index 0ac5619..1122168 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_sriov.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_sriov.h
@@ -50,6 +50,14 @@ struct qed_iov_vf_mbx {
 	dma_addr_t req_phys;
 	union pfvf_tlvs *reply_virt;
 	dma_addr_t reply_phys;
+
+	/* Address in VF where a pending message is located */
+	dma_addr_t pending_req;
+
+	u8 *offset;
+
+	/* saved VF request header */
+	struct vfpf_first_tlv first_tlv;
 };
 
 enum vf_state {
@@ -96,6 +104,14 @@ struct qed_pf_iov {
 	u32 bulletins_size;
 };
 
+enum qed_iov_wq_flag {
+	QED_IOV_WQ_MSG_FLAG,
+	QED_IOV_WQ_SET_UNICAST_FILTER_FLAG,
+	QED_IOV_WQ_BULLETIN_UPDATE_FLAG,
+	QED_IOV_WQ_STOP_WQ_FLAG,
+	QED_IOV_WQ_FLR_FLAG,
+};
+
 #ifdef CONFIG_QED_SRIOV
 /**
  * @brief - Given a VF index, return index of next [including that] active VF.
@@ -147,6 +163,22 @@ void qed_iov_free(struct qed_hwfn *p_hwfn);
  * @param cdev
  */
 void qed_iov_free_hw_info(struct qed_dev *cdev);
+
+/**
+ * @brief qed_sriov_eqe_event - handle async sriov event arrived on eqe.
+ *
+ * @param p_hwfn
+ * @param opcode
+ * @param echo
+ * @param data
+ */
+int qed_sriov_eqe_event(struct qed_hwfn *p_hwfn,
+			u8 opcode, __le16 echo, union event_ring_data *data);
+
+void qed_iov_wq_stop(struct qed_dev *cdev, bool schedule_first);
+int qed_iov_wq_start(struct qed_dev *cdev);
+
+void qed_schedule_iov(struct qed_hwfn *hwfn, enum qed_iov_wq_flag flag);
 #else
 static inline u16 qed_iov_get_next_active_vf(struct qed_hwfn *p_hwfn,
 					     u16 rel_vf_id)
@@ -175,6 +207,27 @@ static inline void qed_iov_free(struct qed_hwfn *p_hwfn)
 static inline void qed_iov_free_hw_info(struct qed_dev *cdev)
 {
 }
+
+static inline int qed_sriov_eqe_event(struct qed_hwfn *p_hwfn,
+				      u8 opcode,
+				      __le16 echo, union event_ring_data *data)
+{
+	return -EINVAL;
+}
+
+static inline void qed_iov_wq_stop(struct qed_dev *cdev, bool schedule_first)
+{
+}
+
+static inline int qed_iov_wq_start(struct qed_dev *cdev)
+{
+	return 0;
+}
+
+static inline void qed_schedule_iov(struct qed_hwfn *hwfn,
+				    enum qed_iov_wq_flag flag)
+{
+}
 #endif
 
 #define qed_for_each_vf(_p_hwfn, _i)			  \
diff --git a/drivers/net/ethernet/qlogic/qed/qed_vf.h b/drivers/net/ethernet/qlogic/qed/qed_vf.h
index 7c78f01..a0a68308 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_vf.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_vf.h
@@ -9,16 +9,62 @@
 #ifndef _QED_VF_H
 #define _QED_VF_H
 
+enum {
+	PFVF_STATUS_WAITING,
+	PFVF_STATUS_SUCCESS,
+	PFVF_STATUS_FAILURE,
+	PFVF_STATUS_NOT_SUPPORTED,
+	PFVF_STATUS_NO_RESOURCE,
+	PFVF_STATUS_FORCED,
+};
+
+/* vf pf channel tlvs */
+/* general tlv header (used for both vf->pf request and pf->vf response) */
+struct channel_tlv {
+	u16 type;
+	u16 length;
+};
+
+/* header of first vf->pf tlv carries the offset used to calculate reponse
+ * buffer address
+ */
+struct vfpf_first_tlv {
+	struct channel_tlv tl;
+	u32 padding;
+	u64 reply_address;
+};
+
+/* header of pf->vf tlvs, carries the status of handling the request */
+struct pfvf_tlv {
+	struct channel_tlv tl;
+	u8 status;
+	u8 padding[3];
+};
+
+/* response tlv used for most tlvs */
+struct pfvf_def_resp_tlv {
+	struct pfvf_tlv hdr;
+};
+
+/* used to terminate and pad a tlv list */
+struct channel_list_end_tlv {
+	struct channel_tlv tl;
+	u8 padding[4];
+};
+
 #define TLV_BUFFER_SIZE                 1024
 struct tlv_buffer_size {
 	u8 tlv_buffer[TLV_BUFFER_SIZE];
 };
 
 union vfpf_tlvs {
+	struct vfpf_first_tlv first_tlv;
+	struct channel_list_end_tlv list_end;
 	struct tlv_buffer_size tlv_buf_size;
 };
 
 union pfvf_tlvs {
+	struct pfvf_def_resp_tlv default_resp;
 	struct tlv_buffer_size tlv_buf_size;
 };
 
@@ -38,4 +84,10 @@ struct qed_bulletin {
 	u32 size;
 };
 
+enum {
+	CHANNEL_TLV_NONE,	/* ends tlv sequence */
+	CHANNEL_TLV_LIST_END,
+	CHANNEL_TLV_MAX
+};
+
 #endif
diff --git a/include/linux/qed/common_hsi.h b/include/linux/qed/common_hsi.h
index 53ecb37..8914d27 100644
--- a/include/linux/qed/common_hsi.h
+++ b/include/linux/qed/common_hsi.h
@@ -327,9 +327,14 @@ struct regpair {
 	__le32	hi;
 };
 
+struct vf_pf_channel_eqe_data {
+	struct regpair msg_addr;
+};
+
 /* Event Data Union */
 union event_ring_data {
 	u8				bytes[8];
+	struct vf_pf_channel_eqe_data	vf_pf_channel;
 	struct async_data		async_info;
 };
 
-- 
1.9.3
