From: Manish Rangankar <manish.rangankar@cavium.com>
Subject: [PATCH v2 5/6] qedi: Add support for iSCSI session management.
Date: Mon, 7 Nov 2016 22:57:02 -0800
Message-ID: <1478588223-16183-6-git-send-email-manish.rangankar@cavium.com>
References: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <netdev@vger.kernel.org>,
        <QLogic-Storage-Upstream@cavium.com>, <Yuval.Mintz@cavium.com>
To: <martin.petersen@oracle.com>, <lduncan@suse.com>,
        <cleech@redhat.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1478588223-16183-1-git-send-email-manish.rangankar@cavium.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds support for iscsi_transport LLD Login,
Logout, NOP-IN/NOP-OUT, Async, Reject PDU processing
and Firmware async event handling support.

Signed-off-by: Nilesh Javali <nilesh.javali@cavium.com>
Signed-off-by: Adheer Chandravanshi <adheer.chandravanshi@qlogic.com>
Signed-off-by: Chad Dupuis <chad.dupuis@cavium.com>
Signed-off-by: Saurav Kashyap <saurav.kashyap@cavium.com>
Signed-off-by: Arun Easi <arun.easi@cavium.com>
Signed-off-by: Manish Rangankar <manish.rangankar@cavium.com>
---
 drivers/scsi/qedi/qedi_fw.c    | 1106 +++++++++++++++++++++++++++
 drivers/scsi/qedi/qedi_gbl.h   |   67 ++
 drivers/scsi/qedi/qedi_iscsi.c | 1611 ++++++++++++++++++++++++++++++++++++++++
 drivers/scsi/qedi/qedi_iscsi.h |  232 ++++++
 drivers/scsi/qedi/qedi_main.c  |  166 +++++
 5 files changed, 3182 insertions(+)
 create mode 100644 drivers/scsi/qedi/qedi_fw.c
 create mode 100644 drivers/scsi/qedi/qedi_gbl.h
 create mode 100644 drivers/scsi/qedi/qedi_iscsi.c
 create mode 100644 drivers/scsi/qedi/qedi_iscsi.h

diff --git a/drivers/scsi/qedi/qedi_fw.c b/drivers/scsi/qedi/qedi_fw.c
new file mode 100644
index 0000000..5ee62a2
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_fw.c
@@ -0,0 +1,1106 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/blkdev.h>
+#include <scsi/scsi_tcq.h>
+#include <linux/delay.h>
+
+#include "qedi.h"
+#include "qedi_iscsi.h"
+#include "qedi_gbl.h"
+
+static int qedi_send_iscsi_tmf(struct qedi_conn *qedi_conn,
+			       struct iscsi_task *mtask);
+
+void qedi_iscsi_unmap_sg_list(struct qedi_cmd *cmd)
+{
+	struct scsi_cmnd *sc = cmd->scsi_cmd;
+
+	if (cmd->io_tbl.sge_valid && sc) {
+		cmd->io_tbl.sge_valid = 0;
+		scsi_dma_unmap(sc);
+	}
+}
+
+static void qedi_process_logout_resp(struct qedi_ctx *qedi,
+				     union iscsi_cqe *cqe,
+				     struct iscsi_task *task,
+				     struct qedi_conn *qedi_conn)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_logout_rsp *resp_hdr;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_logout_response_hdr *cqe_logout_response;
+	struct qedi_cmd *cmd;
+
+	cmd = (struct qedi_cmd *)task->dd_data;
+	cqe_logout_response = &cqe->cqe_common.iscsi_hdr.logout_response;
+	spin_lock(&session->back_lock);
+	resp_hdr = (struct iscsi_logout_rsp *)&qedi_conn->gen_pdu.resp_hdr;
+	memset(resp_hdr, 0, sizeof(struct iscsi_hdr));
+	resp_hdr->opcode = cqe_logout_response->opcode;
+	resp_hdr->flags = cqe_logout_response->flags;
+	resp_hdr->hlength = 0;
+
+	resp_hdr->itt = build_itt(cqe->cqe_solicited.itid, conn->session->age);
+	resp_hdr->statsn = cpu_to_be32(cqe_logout_response->stat_sn);
+	resp_hdr->exp_cmdsn = cpu_to_be32(cqe_logout_response->exp_cmd_sn);
+	resp_hdr->max_cmdsn = cpu_to_be32(cqe_logout_response->max_cmd_sn);
+
+	resp_hdr->t2wait = cpu_to_be32(cqe_logout_response->time2wait);
+	resp_hdr->t2retain = cpu_to_be32(cqe_logout_response->time2retain);
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_TID,
+		  "Freeing tid=0x%x for cid=0x%x\n",
+		  cmd->task_id, qedi_conn->iscsi_conn_id);
+
+	if (likely(cmd->io_cmd_in_list)) {
+		cmd->io_cmd_in_list = false;
+		list_del_init(&cmd->io_cmd);
+		qedi_conn->active_cmd_count--;
+	} else {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+			  "Active cmd list node already deleted, tid=0x%x, cid=0x%x, io_cmd_node=%p\n",
+			  cmd->task_id, qedi_conn->iscsi_conn_id,
+			  &cmd->io_cmd);
+	}
+
+	cmd->state = RESPONSE_RECEIVED;
+	qedi_clear_task_idx(qedi, cmd->task_id);
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)resp_hdr, NULL, 0);
+
+	spin_unlock(&session->back_lock);
+}
+
+static void qedi_process_text_resp(struct qedi_ctx *qedi,
+				   union iscsi_cqe *cqe,
+				   struct iscsi_task *task,
+				   struct qedi_conn *qedi_conn)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_task_context *task_ctx;
+	struct iscsi_text_rsp *resp_hdr_ptr;
+	struct iscsi_text_response_hdr *cqe_text_response;
+	struct qedi_cmd *cmd;
+	int pld_len;
+	u32 *tmp;
+
+	cmd = (struct qedi_cmd *)task->dd_data;
+	task_ctx = qedi_get_task_mem(&qedi->tasks, cmd->task_id);
+
+	cqe_text_response = &cqe->cqe_common.iscsi_hdr.text_response;
+	spin_lock(&session->back_lock);
+	resp_hdr_ptr =  (struct iscsi_text_rsp *)&qedi_conn->gen_pdu.resp_hdr;
+	memset(resp_hdr_ptr, 0, sizeof(struct iscsi_hdr));
+	resp_hdr_ptr->opcode = cqe_text_response->opcode;
+	resp_hdr_ptr->flags = cqe_text_response->flags;
+	resp_hdr_ptr->hlength = 0;
+
+	hton24(resp_hdr_ptr->dlength,
+	       (cqe_text_response->hdr_second_dword &
+		ISCSI_TEXT_RESPONSE_HDR_DATA_SEG_LEN_MASK));
+	tmp = (u32 *)resp_hdr_ptr->dlength;
+
+	resp_hdr_ptr->itt = build_itt(cqe->cqe_solicited.itid,
+				      conn->session->age);
+	resp_hdr_ptr->ttt = cqe_text_response->ttt;
+	resp_hdr_ptr->statsn = cpu_to_be32(cqe_text_response->stat_sn);
+	resp_hdr_ptr->exp_cmdsn = cpu_to_be32(cqe_text_response->exp_cmd_sn);
+	resp_hdr_ptr->max_cmdsn = cpu_to_be32(cqe_text_response->max_cmd_sn);
+
+	pld_len = cqe_text_response->hdr_second_dword &
+		  ISCSI_TEXT_RESPONSE_HDR_DATA_SEG_LEN_MASK;
+	qedi_conn->gen_pdu.resp_wr_ptr = qedi_conn->gen_pdu.resp_buf + pld_len;
+
+	memset(task_ctx, '\0', sizeof(*task_ctx));
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_TID,
+		  "Freeing tid=0x%x for cid=0x%x\n",
+		  cmd->task_id, qedi_conn->iscsi_conn_id);
+
+	if (likely(cmd->io_cmd_in_list)) {
+		cmd->io_cmd_in_list = false;
+		list_del_init(&cmd->io_cmd);
+		qedi_conn->active_cmd_count--;
+	} else {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+			  "Active cmd list node already deleted, tid=0x%x, cid=0x%x, io_cmd_node=%p\n",
+			  cmd->task_id, qedi_conn->iscsi_conn_id,
+			  &cmd->io_cmd);
+	}
+
+	cmd->state = RESPONSE_RECEIVED;
+	qedi_clear_task_idx(qedi, cmd->task_id);
+
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)resp_hdr_ptr,
+			     qedi_conn->gen_pdu.resp_buf,
+			     (qedi_conn->gen_pdu.resp_wr_ptr -
+			      qedi_conn->gen_pdu.resp_buf));
+	spin_unlock(&session->back_lock);
+}
+
+static void qedi_process_login_resp(struct qedi_ctx *qedi,
+				    union iscsi_cqe *cqe,
+				    struct iscsi_task *task,
+				    struct qedi_conn *qedi_conn)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_task_context *task_ctx;
+	struct iscsi_login_rsp *resp_hdr_ptr;
+	struct iscsi_login_response_hdr *cqe_login_response;
+	struct qedi_cmd *cmd;
+	int pld_len;
+	u32 *tmp;
+
+	cmd = (struct qedi_cmd *)task->dd_data;
+
+	cqe_login_response = &cqe->cqe_common.iscsi_hdr.login_response;
+	task_ctx = qedi_get_task_mem(&qedi->tasks, cmd->task_id);
+
+	spin_lock(&session->back_lock);
+	resp_hdr_ptr =  (struct iscsi_login_rsp *)&qedi_conn->gen_pdu.resp_hdr;
+	memset(resp_hdr_ptr, 0, sizeof(struct iscsi_login_rsp));
+	resp_hdr_ptr->opcode = cqe_login_response->opcode;
+	resp_hdr_ptr->flags = cqe_login_response->flags_attr;
+	resp_hdr_ptr->hlength = 0;
+
+	hton24(resp_hdr_ptr->dlength,
+	       (cqe_login_response->hdr_second_dword &
+		ISCSI_LOGIN_RESPONSE_HDR_DATA_SEG_LEN_MASK));
+	tmp = (u32 *)resp_hdr_ptr->dlength;
+	resp_hdr_ptr->itt = build_itt(cqe->cqe_solicited.itid,
+				      conn->session->age);
+	resp_hdr_ptr->tsih = cqe_login_response->tsih;
+	resp_hdr_ptr->statsn = cpu_to_be32(cqe_login_response->stat_sn);
+	resp_hdr_ptr->exp_cmdsn = cpu_to_be32(cqe_login_response->exp_cmd_sn);
+	resp_hdr_ptr->max_cmdsn = cpu_to_be32(cqe_login_response->max_cmd_sn);
+	resp_hdr_ptr->status_class = cqe_login_response->status_class;
+	resp_hdr_ptr->status_detail = cqe_login_response->status_detail;
+	pld_len = cqe_login_response->hdr_second_dword &
+		  ISCSI_LOGIN_RESPONSE_HDR_DATA_SEG_LEN_MASK;
+	qedi_conn->gen_pdu.resp_wr_ptr = qedi_conn->gen_pdu.resp_buf + pld_len;
+
+	if (likely(cmd->io_cmd_in_list)) {
+		cmd->io_cmd_in_list = false;
+		list_del_init(&cmd->io_cmd);
+		qedi_conn->active_cmd_count--;
+	}
+
+	memset(task_ctx, '\0', sizeof(*task_ctx));
+
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)resp_hdr_ptr,
+			     qedi_conn->gen_pdu.resp_buf,
+			     (qedi_conn->gen_pdu.resp_wr_ptr -
+			     qedi_conn->gen_pdu.resp_buf));
+
+	spin_unlock(&session->back_lock);
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_TID,
+		  "Freeing tid=0x%x for cid=0x%x\n",
+		  cmd->task_id, qedi_conn->iscsi_conn_id);
+	cmd->state = RESPONSE_RECEIVED;
+	qedi_clear_task_idx(qedi, cmd->task_id);
+}
+
+static void qedi_get_rq_bdq_buf(struct qedi_ctx *qedi,
+				struct iscsi_cqe_unsolicited *cqe,
+				char *ptr, int len)
+{
+	u16 idx = 0;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "pld_len [%d], bdq_prod_idx [%d], idx [%d]\n",
+		  len, qedi->bdq_prod_idx,
+		  (qedi->bdq_prod_idx % qedi->rq_num_entries));
+
+	/* Obtain buffer address from rqe_opaque */
+	idx = cqe->rqe_opaque.lo;
+	if ((idx < 0) || (idx > (QEDI_BDQ_NUM - 1))) {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "wrong idx %d returned by FW, dropping the unsolicited pkt\n",
+			  idx);
+		return;
+	}
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "rqe_opaque.lo [0x%p], rqe_opaque.hi [0x%p], idx [%d]\n",
+		  cqe->rqe_opaque.lo, cqe->rqe_opaque.hi, idx);
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "unsol_cqe_type = %d\n", cqe->unsol_cqe_type);
+	switch (cqe->unsol_cqe_type) {
+	case ISCSI_CQE_UNSOLICITED_SINGLE:
+	case ISCSI_CQE_UNSOLICITED_FIRST:
+		if (len)
+			memcpy(ptr, (void *)qedi->bdq[idx].buf_addr, len);
+		break;
+	case ISCSI_CQE_UNSOLICITED_MIDDLE:
+	case ISCSI_CQE_UNSOLICITED_LAST:
+		break;
+	default:
+		break;
+	}
+}
+
+static void qedi_put_rq_bdq_buf(struct qedi_ctx *qedi,
+				struct iscsi_cqe_unsolicited *cqe,
+				int count)
+{
+	u16 tmp;
+	u16 idx = 0;
+	struct scsi_bd *pbl;
+
+	/* Obtain buffer address from rqe_opaque */
+	idx = cqe->rqe_opaque.lo;
+	if ((idx < 0) || (idx > (QEDI_BDQ_NUM - 1))) {
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "wrong idx %d returned by FW, dropping the unsolicited pkt\n",
+			  idx);
+		return;
+	}
+
+	pbl = (struct scsi_bd *)qedi->bdq_pbl;
+	pbl += (qedi->bdq_prod_idx % qedi->rq_num_entries);
+	pbl->address.hi = cpu_to_le32(QEDI_U64_HI(qedi->bdq[idx].buf_dma));
+	pbl->address.lo = cpu_to_le32(QEDI_U64_LO(qedi->bdq[idx].buf_dma));
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "pbl [0x%p] pbl->address hi [0x%llx] lo [0x%llx] idx [%d]\n",
+		  pbl, pbl->address.hi, pbl->address.lo, idx);
+	pbl->opaque.hi = 0;
+	pbl->opaque.lo = cpu_to_le32(QEDI_U64_LO(idx));
+
+	/* Increment producer to let f/w know we've handled the frame */
+	qedi->bdq_prod_idx += count;
+
+	writew(qedi->bdq_prod_idx, qedi->bdq_primary_prod);
+	tmp = readw(qedi->bdq_primary_prod);
+
+	writew(qedi->bdq_prod_idx, qedi->bdq_secondary_prod);
+	tmp = readw(qedi->bdq_secondary_prod);
+}
+
+static void qedi_unsol_pdu_adjust_bdq(struct qedi_ctx *qedi,
+				      struct iscsi_cqe_unsolicited *cqe,
+				      u32 pdu_len, u32 num_bdqs,
+				      char *bdq_data)
+{
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "num_bdqs [%d]\n", num_bdqs);
+
+	qedi_get_rq_bdq_buf(qedi, cqe, bdq_data, pdu_len);
+	qedi_put_rq_bdq_buf(qedi, cqe, (num_bdqs + 1));
+}
+
+static int qedi_process_nopin_mesg(struct qedi_ctx *qedi,
+				   union iscsi_cqe *cqe,
+				   struct iscsi_task *task,
+				   struct qedi_conn *qedi_conn, u16 que_idx)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_nop_in_hdr *cqe_nop_in;
+	struct iscsi_nopin *hdr;
+	struct qedi_cmd *cmd;
+	int tgt_async_nop = 0;
+	u32 lun[2];
+	u32 pdu_len, num_bdqs;
+	char bdq_data[QEDI_BDQ_BUF_SIZE];
+	unsigned long flags;
+
+	spin_lock_bh(&session->back_lock);
+	cqe_nop_in = &cqe->cqe_common.iscsi_hdr.nop_in;
+
+	pdu_len = cqe_nop_in->hdr_second_dword &
+		  ISCSI_NOP_IN_HDR_DATA_SEG_LEN_MASK;
+	num_bdqs = pdu_len / QEDI_BDQ_BUF_SIZE;
+
+	hdr = (struct iscsi_nopin *)&qedi_conn->gen_pdu.resp_hdr;
+	memset(hdr, 0, sizeof(struct iscsi_hdr));
+	hdr->opcode = cqe_nop_in->opcode;
+	hdr->max_cmdsn = cpu_to_be32(cqe_nop_in->max_cmd_sn);
+	hdr->exp_cmdsn = cpu_to_be32(cqe_nop_in->exp_cmd_sn);
+	hdr->statsn = cpu_to_be32(cqe_nop_in->stat_sn);
+	hdr->ttt = cpu_to_be32(cqe_nop_in->ttt);
+
+	if (cqe->cqe_common.cqe_type == ISCSI_CQE_TYPE_UNSOLICITED) {
+		spin_lock_irqsave(&qedi->hba_lock, flags);
+		qedi_unsol_pdu_adjust_bdq(qedi, &cqe->cqe_unsolicited,
+					  pdu_len, num_bdqs, bdq_data);
+		hdr->itt = RESERVED_ITT;
+		tgt_async_nop = 1;
+		spin_unlock_irqrestore(&qedi->hba_lock, flags);
+		goto done;
+	}
+
+	/* Response to one of our nop-outs */
+	if (task) {
+		cmd = task->dd_data;
+		hdr->flags = ISCSI_FLAG_CMD_FINAL;
+		hdr->itt = build_itt(cqe->cqe_solicited.itid,
+				     conn->session->age);
+		lun[0] = 0xffffffff;
+		lun[1] = 0xffffffff;
+		memcpy(&hdr->lun, lun, sizeof(struct scsi_lun));
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_TID,
+			  "Freeing tid=0x%x for cid=0x%x\n",
+			  cmd->task_id, qedi_conn->iscsi_conn_id);
+		cmd->state = RESPONSE_RECEIVED;
+		spin_lock(&qedi_conn->list_lock);
+		if (likely(cmd->io_cmd_in_list)) {
+			cmd->io_cmd_in_list = false;
+			list_del_init(&cmd->io_cmd);
+			qedi_conn->active_cmd_count--;
+		}
+
+		spin_unlock(&qedi_conn->list_lock);
+		qedi_clear_task_idx(qedi, cmd->task_id);
+	}
+
+done:
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)hdr, bdq_data, pdu_len);
+
+	spin_unlock_bh(&session->back_lock);
+	return tgt_async_nop;
+}
+
+static void qedi_process_async_mesg(struct qedi_ctx *qedi,
+				    union iscsi_cqe *cqe,
+				    struct iscsi_task *task,
+				    struct qedi_conn *qedi_conn,
+				    u16 que_idx)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_async_msg_hdr *cqe_async_msg;
+	struct iscsi_async *resp_hdr;
+	u32 lun[2];
+	u32 pdu_len, num_bdqs;
+	char bdq_data[QEDI_BDQ_BUF_SIZE];
+	unsigned long flags;
+
+	spin_lock_bh(&session->back_lock);
+
+	cqe_async_msg = &cqe->cqe_common.iscsi_hdr.async_msg;
+	pdu_len = cqe_async_msg->hdr_second_dword &
+		ISCSI_ASYNC_MSG_HDR_DATA_SEG_LEN_MASK;
+	num_bdqs = pdu_len / QEDI_BDQ_BUF_SIZE;
+
+	if (cqe->cqe_common.cqe_type == ISCSI_CQE_TYPE_UNSOLICITED) {
+		spin_lock_irqsave(&qedi->hba_lock, flags);
+		qedi_unsol_pdu_adjust_bdq(qedi, &cqe->cqe_unsolicited,
+					  pdu_len, num_bdqs, bdq_data);
+		spin_unlock_irqrestore(&qedi->hba_lock, flags);
+	}
+
+	resp_hdr = (struct iscsi_async *)&qedi_conn->gen_pdu.resp_hdr;
+	memset(resp_hdr, 0, sizeof(struct iscsi_hdr));
+	resp_hdr->opcode = cqe_async_msg->opcode;
+	resp_hdr->flags = 0x80;
+
+	lun[0] = cpu_to_be32(cqe_async_msg->lun.lo);
+	lun[1] = cpu_to_be32(cqe_async_msg->lun.hi);
+	memcpy(&resp_hdr->lun, lun, sizeof(struct scsi_lun));
+	resp_hdr->exp_cmdsn = cpu_to_be32(cqe_async_msg->exp_cmd_sn);
+	resp_hdr->max_cmdsn = cpu_to_be32(cqe_async_msg->max_cmd_sn);
+	resp_hdr->statsn = cpu_to_be32(cqe_async_msg->stat_sn);
+
+	resp_hdr->async_event = cqe_async_msg->async_event;
+	resp_hdr->async_vcode = cqe_async_msg->async_vcode;
+
+	resp_hdr->param1 = cpu_to_be16(cqe_async_msg->param1_rsrv);
+	resp_hdr->param2 = cpu_to_be16(cqe_async_msg->param2_rsrv);
+	resp_hdr->param3 = cpu_to_be16(cqe_async_msg->param3_rsrv);
+
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)resp_hdr, bdq_data,
+			     pdu_len);
+
+	spin_unlock_bh(&session->back_lock);
+}
+
+static void qedi_process_reject_mesg(struct qedi_ctx *qedi,
+				     union iscsi_cqe *cqe,
+				     struct iscsi_task *task,
+				     struct qedi_conn *qedi_conn,
+				     uint16_t que_idx)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct iscsi_reject_hdr *cqe_reject;
+	struct iscsi_reject *hdr;
+	u32 pld_len, num_bdqs;
+	unsigned long flags;
+
+	spin_lock_bh(&session->back_lock);
+	cqe_reject = &cqe->cqe_common.iscsi_hdr.reject;
+	pld_len = cqe_reject->hdr_second_dword &
+		  ISCSI_REJECT_HDR_DATA_SEG_LEN_MASK;
+	num_bdqs = pld_len / QEDI_BDQ_BUF_SIZE;
+
+	if (cqe->cqe_common.cqe_type == ISCSI_CQE_TYPE_UNSOLICITED) {
+		spin_lock_irqsave(&qedi->hba_lock, flags);
+		qedi_unsol_pdu_adjust_bdq(qedi, &cqe->cqe_unsolicited,
+					  pld_len, num_bdqs, conn->data);
+		spin_unlock_irqrestore(&qedi->hba_lock, flags);
+	}
+	hdr = (struct iscsi_reject *)&qedi_conn->gen_pdu.resp_hdr;
+	memset(hdr, 0, sizeof(struct iscsi_hdr));
+	hdr->opcode = cqe_reject->opcode;
+	hdr->reason = cqe_reject->hdr_reason;
+	hdr->flags = cqe_reject->hdr_flags;
+	hton24(hdr->dlength, (cqe_reject->hdr_second_dword &
+			      ISCSI_REJECT_HDR_DATA_SEG_LEN_MASK));
+	hdr->max_cmdsn = cpu_to_be32(cqe_reject->max_cmd_sn);
+	hdr->exp_cmdsn = cpu_to_be32(cqe_reject->exp_cmd_sn);
+	hdr->statsn = cpu_to_be32(cqe_reject->stat_sn);
+	hdr->ffffffff = cpu_to_be32(0xffffffff);
+
+	__iscsi_complete_pdu(conn, (struct iscsi_hdr *)hdr,
+			     conn->data, pld_len);
+	spin_unlock_bh(&session->back_lock);
+}
+
+static void qedi_mtask_completion(struct qedi_ctx *qedi,
+				  union iscsi_cqe *cqe,
+				  struct iscsi_task *task,
+				  struct qedi_conn *conn, uint16_t que_idx)
+{
+	struct iscsi_conn *iscsi_conn;
+	u32 hdr_opcode;
+
+	hdr_opcode = cqe->cqe_common.iscsi_hdr.common.hdr_first_byte;
+	iscsi_conn = conn->cls_conn->dd_data;
+
+	switch (hdr_opcode) {
+	case ISCSI_OPCODE_LOGIN_RESPONSE:
+		qedi_process_login_resp(qedi, cqe, task, conn);
+		break;
+	case ISCSI_OPCODE_TEXT_RESPONSE:
+		qedi_process_text_resp(qedi, cqe, task, conn);
+		break;
+	case ISCSI_OPCODE_LOGOUT_RESPONSE:
+		qedi_process_logout_resp(qedi, cqe, task, conn);
+		break;
+	case ISCSI_OPCODE_NOP_IN:
+		qedi_process_nopin_mesg(qedi, cqe, task, conn, que_idx);
+		break;
+	default:
+		QEDI_ERR(&qedi->dbg_ctx, "unknown opcode\n");
+	}
+}
+
+static void qedi_process_nopin_local_cmpl(struct qedi_ctx *qedi,
+					  struct iscsi_cqe_solicited *cqe,
+					  struct iscsi_task *task,
+					  struct qedi_conn *qedi_conn)
+{
+	struct iscsi_conn *conn = qedi_conn->cls_conn->dd_data;
+	struct iscsi_session *session = conn->session;
+	struct qedi_cmd *cmd = task->dd_data;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_UNSOL,
+		  "itid=0x%x, cmd task id=0x%x\n",
+		  cqe->itid, cmd->task_id);
+
+	cmd->state = RESPONSE_RECEIVED;
+	qedi_clear_task_idx(qedi, cmd->task_id);
+
+	spin_lock_bh(&session->back_lock);
+	__iscsi_put_task(task);
+	spin_unlock_bh(&session->back_lock);
+}
+
+void qedi_fp_process_cqes(struct qedi_work *work)
+{
+	struct qedi_ctx *qedi = work->qedi;
+	union iscsi_cqe *cqe = &work->cqe;
+	struct iscsi_task *task = NULL;
+	struct iscsi_nopout *nopout_hdr;
+	struct qedi_conn *q_conn;
+	struct iscsi_conn *conn;
+	struct qedi_cmd *qedi_cmd;
+	u32 comp_type;
+	u32 iscsi_cid;
+	u32 hdr_opcode;
+	u16 que_idx = work->que_idx;
+	u8 cqe_err_bits = 0;
+
+	comp_type = cqe->cqe_common.cqe_type;
+	hdr_opcode = cqe->cqe_common.iscsi_hdr.common.hdr_first_byte;
+	cqe_err_bits =
+		cqe->cqe_common.error_bitmap.error_bits.cqe_error_status_bits;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "fw_cid=0x%x, cqe type=0x%x, opcode=0x%x\n",
+		  cqe->cqe_common.conn_id, comp_type, hdr_opcode);
+
+	if (comp_type >= MAX_ISCSI_CQES_TYPE) {
+		QEDI_WARN(&qedi->dbg_ctx, "Invalid CqE type\n");
+		return;
+	}
+
+	iscsi_cid  = cqe->cqe_common.conn_id;
+	q_conn = qedi->cid_que.conn_cid_tbl[iscsi_cid];
+	if (!q_conn) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "Session no longer exists for cid=0x%x!!\n",
+			  iscsi_cid);
+		return;
+	}
+
+	conn = q_conn->cls_conn->dd_data;
+
+	if (unlikely(cqe_err_bits &&
+		     GET_FIELD(cqe_err_bits,
+			       CQE_ERROR_BITMAP_DATA_DIGEST_ERR))) {
+		iscsi_conn_failure(conn, ISCSI_ERR_DATA_DGST);
+		return;
+	}
+
+	switch (comp_type) {
+	case ISCSI_CQE_TYPE_SOLICITED:
+	case ISCSI_CQE_TYPE_SOLICITED_WITH_SENSE:
+		qedi_cmd = container_of(work, struct qedi_cmd, cqe_work);
+		task = qedi_cmd->task;
+		if (!task) {
+			QEDI_WARN(&qedi->dbg_ctx, "task is NULL\n");
+			return;
+		}
+
+		/* Process NOPIN local completion */
+		nopout_hdr = (struct iscsi_nopout *)task->hdr;
+		if ((nopout_hdr->itt == RESERVED_ITT) &&
+		    (cqe->cqe_solicited.itid != (u16)RESERVED_ITT)) {
+			qedi_process_nopin_local_cmpl(qedi, &cqe->cqe_solicited,
+						      task, q_conn);
+		} else {
+			cqe->cqe_solicited.itid =
+					       qedi_get_itt(cqe->cqe_solicited);
+			/* Process other solicited responses */
+			qedi_mtask_completion(qedi, cqe, task, q_conn, que_idx);
+		}
+		break;
+	case ISCSI_CQE_TYPE_UNSOLICITED:
+		switch (hdr_opcode) {
+		case ISCSI_OPCODE_NOP_IN:
+			qedi_process_nopin_mesg(qedi, cqe, task, q_conn,
+						que_idx);
+			break;
+		case ISCSI_OPCODE_ASYNC_MSG:
+			qedi_process_async_mesg(qedi, cqe, task, q_conn,
+						que_idx);
+			break;
+		case ISCSI_OPCODE_REJECT:
+			qedi_process_reject_mesg(qedi, cqe, task, q_conn,
+						 que_idx);
+			break;
+		}
+		goto exit_fp_process;
+	default:
+		QEDI_ERR(&qedi->dbg_ctx, "Error cqe.\n");
+		break;
+	}
+
+exit_fp_process:
+	return;
+}
+
+static void qedi_add_to_sq(struct qedi_conn *qedi_conn, struct iscsi_task *task,
+			   u16 tid, uint16_t ptu_invalidate, int is_cleanup)
+{
+	struct iscsi_wqe *wqe;
+	struct iscsi_wqe_field *cont_field;
+	struct qedi_endpoint *ep;
+	struct scsi_cmnd *sc = task->sc;
+	struct iscsi_login_req *login_hdr;
+	struct qedi_cmd *cmd = task->dd_data;
+
+	login_hdr = (struct iscsi_login_req *)task->hdr;
+	ep = qedi_conn->ep;
+	wqe = &ep->sq[ep->sq_prod_idx];
+
+	memset(wqe, 0, sizeof(*wqe));
+
+	ep->sq_prod_idx++;
+	ep->fw_sq_prod_idx++;
+	if (ep->sq_prod_idx == QEDI_SQ_SIZE)
+		ep->sq_prod_idx = 0;
+
+	if (is_cleanup) {
+		SET_FIELD(wqe->flags, ISCSI_WQE_WQE_TYPE,
+			  ISCSI_WQE_TYPE_TASK_CLEANUP);
+		wqe->task_id = tid;
+		return;
+	}
+
+	if (ptu_invalidate) {
+		SET_FIELD(wqe->flags, ISCSI_WQE_PTU_INVALIDATE,
+			  ISCSI_WQE_SET_PTU_INVALIDATE);
+	}
+
+	cont_field = &wqe->cont_prevtid_union.cont_field;
+
+	switch (task->hdr->opcode & ISCSI_OPCODE_MASK) {
+	case ISCSI_OP_LOGIN:
+	case ISCSI_OP_TEXT:
+		SET_FIELD(wqe->flags, ISCSI_WQE_WQE_TYPE,
+			  ISCSI_WQE_TYPE_MIDDLE_PATH);
+		SET_FIELD(wqe->flags, ISCSI_WQE_NUM_FAST_SGES,
+			  1);
+		cont_field->contlen_cdbsize_field = ntoh24(login_hdr->dlength);
+		break;
+	case ISCSI_OP_LOGOUT:
+	case ISCSI_OP_NOOP_OUT:
+	case ISCSI_OP_SCSI_TMFUNC:
+		 SET_FIELD(wqe->flags, ISCSI_WQE_WQE_TYPE,
+			   ISCSI_WQE_TYPE_NORMAL);
+		break;
+	default:
+		if (!sc)
+			break;
+
+		SET_FIELD(wqe->flags, ISCSI_WQE_WQE_TYPE,
+			  ISCSI_WQE_TYPE_NORMAL);
+		cont_field->contlen_cdbsize_field =
+				(sc->sc_data_direction == DMA_TO_DEVICE) ?
+				scsi_bufflen(sc) : 0;
+		if (cmd->use_slowpath)
+			SET_FIELD(wqe->flags, ISCSI_WQE_NUM_FAST_SGES, 0);
+		else
+			SET_FIELD(wqe->flags, ISCSI_WQE_NUM_FAST_SGES,
+				  (sc->sc_data_direction ==
+				   DMA_TO_DEVICE) ?
+				  min((u16)QEDI_FAST_SGE_COUNT,
+				      (u16)cmd->io_tbl.sge_valid) : 0);
+		break;
+	}
+
+	wqe->task_id = tid;
+	/* Make sure SQ data is coherent */
+	wmb();
+}
+
+static void qedi_ring_doorbell(struct qedi_conn *qedi_conn)
+{
+	struct iscsi_db_data dbell = { 0 };
+
+	dbell.agg_flags = 0;
+
+	dbell.params |= DB_DEST_XCM << ISCSI_DB_DATA_DEST_SHIFT;
+	dbell.params |= DB_AGG_CMD_SET << ISCSI_DB_DATA_AGG_CMD_SHIFT;
+	dbell.params |=
+		   DQ_XCM_ISCSI_SQ_PROD_CMD << ISCSI_DB_DATA_AGG_VAL_SEL_SHIFT;
+
+	dbell.sq_prod = qedi_conn->ep->fw_sq_prod_idx;
+	writel(*(u32 *)&dbell, qedi_conn->ep->p_doorbell);
+
+	/* Make sure fw write idx is coherent, and include both memory barriers
+	 * as a failsafe as for some architectures the call is the same but on
+	 * others they are two different assembly operations.
+	 */
+	wmb();
+	mmiowb();
+	QEDI_INFO(&qedi_conn->qedi->dbg_ctx, QEDI_LOG_MP_REQ,
+		  "prod_idx=0x%x, fw_prod_idx=0x%x, cid=0x%x\n",
+		  qedi_conn->ep->sq_prod_idx, qedi_conn->ep->fw_sq_prod_idx,
+		  qedi_conn->iscsi_conn_id);
+}
+
+int qedi_send_iscsi_login(struct qedi_conn *qedi_conn,
+			  struct iscsi_task *task)
+{
+	struct qedi_ctx *qedi = qedi_conn->qedi;
+	struct iscsi_task_context *fw_task_ctx;
+	struct iscsi_login_req *login_hdr;
+	struct iscsi_login_req_hdr *fw_login_req = NULL;
+	struct iscsi_cached_sge_ctx *cached_sge = NULL;
+	struct iscsi_sge *single_sge = NULL;
+	struct iscsi_sge *req_sge = NULL;
+	struct iscsi_sge *resp_sge = NULL;
+	struct qedi_cmd *qedi_cmd;
+	s16 ptu_invalidate = 0;
+	s16 tid = 0;
+
+	req_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.req_bd_tbl;
+	resp_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.resp_bd_tbl;
+	qedi_cmd = (struct qedi_cmd *)task->dd_data;
+	login_hdr = (struct iscsi_login_req *)task->hdr;
+
+	tid = qedi_get_task_idx(qedi);
+	if (tid == -1)
+		return -ENOMEM;
+
+	fw_task_ctx = qedi_get_task_mem(&qedi->tasks, tid);
+	memset(fw_task_ctx, 0, sizeof(struct iscsi_task_context));
+
+	qedi_cmd->task_id = tid;
+
+	/* Ystorm context */
+	fw_login_req = &fw_task_ctx->ystorm_st_context.pdu_hdr.login_req;
+	fw_login_req->opcode = login_hdr->opcode;
+	fw_login_req->version_min = login_hdr->min_version;
+	fw_login_req->version_max = login_hdr->max_version;
+	fw_login_req->flags_attr = login_hdr->flags;
+	fw_login_req->isid_tabc = *((u16 *)login_hdr->isid + 2);
+	fw_login_req->isid_d = *((u32 *)login_hdr->isid);
+	fw_login_req->tsih = login_hdr->tsih;
+	qedi_update_itt_map(qedi, tid, task->itt, qedi_cmd);
+	fw_login_req->itt = qedi_set_itt(tid, get_itt(task->itt));
+	fw_login_req->cid = qedi_conn->iscsi_conn_id;
+	fw_login_req->cmd_sn = be32_to_cpu(login_hdr->cmdsn);
+	fw_login_req->exp_stat_sn = be32_to_cpu(login_hdr->exp_statsn);
+	fw_login_req->exp_stat_sn = 0;
+
+	if (qedi->tid_reuse_count[tid] == QEDI_MAX_TASK_NUM) {
+		ptu_invalidate = 1;
+		qedi->tid_reuse_count[tid] = 0;
+	}
+
+	fw_task_ctx->ystorm_st_context.state.reuse_count =
+						qedi->tid_reuse_count[tid];
+	fw_task_ctx->mstorm_st_context.reuse_count =
+						qedi->tid_reuse_count[tid]++;
+	cached_sge =
+	       &fw_task_ctx->ystorm_st_context.state.sgl_ctx_union.cached_sge;
+	cached_sge->sge.sge_len = req_sge->sge_len;
+	cached_sge->sge.sge_addr.lo = (u32)(qedi_conn->gen_pdu.req_dma_addr);
+	cached_sge->sge.sge_addr.hi =
+			     (u32)((u64)qedi_conn->gen_pdu.req_dma_addr >> 32);
+
+	/* Mstorm context */
+	single_sge = &fw_task_ctx->mstorm_st_context.sgl_union.single_sge;
+	fw_task_ctx->mstorm_st_context.task_type = 0x2;
+	fw_task_ctx->mstorm_ag_context.task_cid = (u16)qedi_conn->iscsi_conn_id;
+	single_sge->sge_addr.lo = resp_sge->sge_addr.lo;
+	single_sge->sge_addr.hi = resp_sge->sge_addr.hi;
+	single_sge->sge_len = resp_sge->sge_len;
+
+	SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+		  ISCSI_MFLAGS_SINGLE_SGE, 1);
+	SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+		  ISCSI_MFLAGS_SLOW_IO, 0);
+	fw_task_ctx->mstorm_st_context.sgl_size = 1;
+	fw_task_ctx->mstorm_st_context.rem_task_size = resp_sge->sge_len;
+
+	/* Ustorm context */
+	fw_task_ctx->ustorm_st_context.rem_rcv_len = resp_sge->sge_len;
+	fw_task_ctx->ustorm_st_context.exp_data_transfer_len =
+						ntoh24(login_hdr->dlength);
+	fw_task_ctx->ustorm_st_context.exp_data_sn = 0;
+	fw_task_ctx->ustorm_st_context.cq_rss_number = 0;
+	fw_task_ctx->ustorm_st_context.task_type = 0x2;
+	fw_task_ctx->ustorm_ag_context.icid = (u16)qedi_conn->iscsi_conn_id;
+	fw_task_ctx->ustorm_ag_context.exp_data_acked =
+						 ntoh24(login_hdr->dlength);
+	SET_FIELD(fw_task_ctx->ustorm_ag_context.flags1,
+		  USTORM_ISCSI_TASK_AG_CTX_R2T2RECV, 1);
+	SET_FIELD(fw_task_ctx->ustorm_st_context.flags,
+		  USTORM_ISCSI_TASK_ST_CTX_LOCAL_COMP, 0);
+
+	spin_lock(&qedi_conn->list_lock);
+	list_add_tail(&qedi_cmd->io_cmd, &qedi_conn->active_cmd_list);
+	qedi_cmd->io_cmd_in_list = true;
+	qedi_conn->active_cmd_count++;
+	spin_unlock(&qedi_conn->list_lock);
+
+	qedi_add_to_sq(qedi_conn, task, tid, ptu_invalidate, false);
+	qedi_ring_doorbell(qedi_conn);
+	return 0;
+}
+
+int qedi_send_iscsi_logout(struct qedi_conn *qedi_conn,
+			   struct iscsi_task *task)
+{
+	struct qedi_ctx *qedi = qedi_conn->qedi;
+	struct iscsi_logout_req_hdr *fw_logout_req = NULL;
+	struct iscsi_task_context *fw_task_ctx = NULL;
+	struct iscsi_logout *logout_hdr = NULL;
+	struct qedi_cmd *qedi_cmd = NULL;
+	s16  tid = 0;
+	s16 ptu_invalidate = 0;
+
+	qedi_cmd = (struct qedi_cmd *)task->dd_data;
+	logout_hdr = (struct iscsi_logout *)task->hdr;
+
+	tid = qedi_get_task_idx(qedi);
+	if (tid == -1)
+		return -ENOMEM;
+
+	fw_task_ctx = qedi_get_task_mem(&qedi->tasks, tid);
+
+	memset(fw_task_ctx, 0, sizeof(struct iscsi_task_context));
+	qedi_cmd->task_id = tid;
+
+	/* Ystorm context */
+	fw_logout_req = &fw_task_ctx->ystorm_st_context.pdu_hdr.logout_req;
+	fw_logout_req->opcode = ISCSI_OPCODE_LOGOUT_REQUEST;
+	fw_logout_req->reason_code = 0x80 | logout_hdr->flags;
+	qedi_update_itt_map(qedi, tid, task->itt, qedi_cmd);
+	fw_logout_req->itt = qedi_set_itt(tid, get_itt(task->itt));
+	fw_logout_req->exp_stat_sn = be32_to_cpu(logout_hdr->exp_statsn);
+	fw_logout_req->cmd_sn = be32_to_cpu(logout_hdr->cmdsn);
+
+	if (qedi->tid_reuse_count[tid] == QEDI_MAX_TASK_NUM) {
+		ptu_invalidate = 1;
+		qedi->tid_reuse_count[tid] = 0;
+	}
+	fw_task_ctx->ystorm_st_context.state.reuse_count =
+						  qedi->tid_reuse_count[tid];
+	fw_task_ctx->mstorm_st_context.reuse_count =
+						qedi->tid_reuse_count[tid]++;
+	fw_logout_req->cid = qedi_conn->iscsi_conn_id;
+	fw_task_ctx->ystorm_st_context.state.buffer_offset[0] = 0;
+
+	/* Mstorm context */
+	fw_task_ctx->mstorm_st_context.task_type = ISCSI_TASK_TYPE_MIDPATH;
+	fw_task_ctx->mstorm_ag_context.task_cid = (u16)qedi_conn->iscsi_conn_id;
+
+	/* Ustorm context */
+	fw_task_ctx->ustorm_st_context.rem_rcv_len = 0;
+	fw_task_ctx->ustorm_st_context.exp_data_transfer_len = 0;
+	fw_task_ctx->ustorm_st_context.exp_data_sn = 0;
+	fw_task_ctx->ustorm_st_context.task_type =  ISCSI_TASK_TYPE_MIDPATH;
+	fw_task_ctx->ustorm_st_context.cq_rss_number = 0;
+
+	SET_FIELD(fw_task_ctx->ustorm_st_context.flags,
+		  USTORM_ISCSI_TASK_ST_CTX_LOCAL_COMP, 0);
+	SET_FIELD(fw_task_ctx->ustorm_st_context.reg1.reg1_map,
+		  ISCSI_REG1_NUM_FAST_SGES, 0);
+
+	fw_task_ctx->ustorm_ag_context.icid = (u16)qedi_conn->iscsi_conn_id;
+	SET_FIELD(fw_task_ctx->ustorm_ag_context.flags1,
+		  USTORM_ISCSI_TASK_AG_CTX_R2T2RECV, 1);
+
+	spin_lock(&qedi_conn->list_lock);
+	list_add_tail(&qedi_cmd->io_cmd, &qedi_conn->active_cmd_list);
+	qedi_cmd->io_cmd_in_list = true;
+	qedi_conn->active_cmd_count++;
+	spin_unlock(&qedi_conn->list_lock);
+
+	qedi_add_to_sq(qedi_conn, task, tid, ptu_invalidate, false);
+	qedi_ring_doorbell(qedi_conn);
+
+	return 0;
+}
+
+int qedi_send_iscsi_text(struct qedi_conn *qedi_conn,
+			 struct iscsi_task *task)
+{
+	struct qedi_ctx *qedi = qedi_conn->qedi;
+	struct iscsi_task_context *fw_task_ctx;
+	struct iscsi_text_request_hdr *fw_text_request;
+	struct iscsi_cached_sge_ctx *cached_sge;
+	struct iscsi_sge *single_sge;
+	struct qedi_cmd *qedi_cmd;
+	/* For 6.5 hdr iscsi_hdr */
+	struct iscsi_text *text_hdr;
+	struct iscsi_sge *req_sge;
+	struct iscsi_sge *resp_sge;
+	s16 ptu_invalidate = 0;
+	s16 tid = 0;
+
+	req_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.req_bd_tbl;
+	resp_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.resp_bd_tbl;
+	qedi_cmd = (struct qedi_cmd *)task->dd_data;
+	text_hdr = (struct iscsi_text *)task->hdr;
+
+	tid = qedi_get_task_idx(qedi);
+	if (tid == -1)
+		return -ENOMEM;
+
+	fw_task_ctx = qedi_get_task_mem(&qedi->tasks, tid);
+	memset(fw_task_ctx, 0, sizeof(struct iscsi_task_context));
+
+	qedi_cmd->task_id = tid;
+
+	/* Ystorm context */
+	fw_text_request =
+			&fw_task_ctx->ystorm_st_context.pdu_hdr.text_request;
+	fw_text_request->opcode = text_hdr->opcode;
+	fw_text_request->flags_attr = text_hdr->flags;
+
+	qedi_update_itt_map(qedi, tid, task->itt, qedi_cmd);
+	fw_text_request->itt = qedi_set_itt(tid, get_itt(task->itt));
+	fw_text_request->ttt = text_hdr->ttt;
+	fw_text_request->cmd_sn = be32_to_cpu(text_hdr->cmdsn);
+	fw_text_request->exp_stat_sn = be32_to_cpu(text_hdr->exp_statsn);
+	fw_text_request->hdr_second_dword = ntoh24(text_hdr->dlength);
+
+	if (qedi->tid_reuse_count[tid] == QEDI_MAX_TASK_NUM) {
+		ptu_invalidate = 1;
+		qedi->tid_reuse_count[tid] = 0;
+	}
+	fw_task_ctx->ystorm_st_context.state.reuse_count =
+						     qedi->tid_reuse_count[tid];
+	fw_task_ctx->mstorm_st_context.reuse_count =
+						   qedi->tid_reuse_count[tid]++;
+
+	cached_sge =
+	       &fw_task_ctx->ystorm_st_context.state.sgl_ctx_union.cached_sge;
+	cached_sge->sge.sge_len = req_sge->sge_len;
+	cached_sge->sge.sge_addr.lo = (u32)(qedi_conn->gen_pdu.req_dma_addr);
+	cached_sge->sge.sge_addr.hi =
+			      (u32)((u64)qedi_conn->gen_pdu.req_dma_addr >> 32);
+
+	/* Mstorm context */
+	single_sge = &fw_task_ctx->mstorm_st_context.sgl_union.single_sge;
+	fw_task_ctx->mstorm_st_context.task_type = 0x2;
+	fw_task_ctx->mstorm_ag_context.task_cid = (u16)qedi_conn->iscsi_conn_id;
+	single_sge->sge_addr.lo = resp_sge->sge_addr.lo;
+	single_sge->sge_addr.hi = resp_sge->sge_addr.hi;
+	single_sge->sge_len = resp_sge->sge_len;
+
+	SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+		  ISCSI_MFLAGS_SINGLE_SGE, 1);
+	SET_FIELD(fw_task_ctx->mstorm_st_context.flags.mflags,
+		  ISCSI_MFLAGS_SLOW_IO, 0);
+	fw_task_ctx->mstorm_st_context.sgl_size = 1;
+	fw_task_ctx->mstorm_st_context.rem_task_size = resp_sge->sge_len;
+
+	/* Ustorm context */
+	fw_task_ctx->ustorm_ag_context.exp_data_acked =
+						      ntoh24(text_hdr->dlength);
+	fw_task_ctx->ustorm_st_context.rem_rcv_len = resp_sge->sge_len;
+	fw_task_ctx->ustorm_st_context.exp_data_transfer_len =
+						      ntoh24(text_hdr->dlength);
+	fw_task_ctx->ustorm_st_context.exp_data_sn =
+					      be32_to_cpu(text_hdr->exp_statsn);
+	fw_task_ctx->ustorm_st_context.cq_rss_number = 0;
+	fw_task_ctx->ustorm_st_context.task_type = 0x2;
+	fw_task_ctx->ustorm_ag_context.icid = (u16)qedi_conn->iscsi_conn_id;
+	SET_FIELD(fw_task_ctx->ustorm_ag_context.flags1,
+		  USTORM_ISCSI_TASK_AG_CTX_R2T2RECV, 1);
+
+	/*  Add command in active command list */
+	spin_lock(&qedi_conn->list_lock);
+	list_add_tail(&qedi_cmd->io_cmd, &qedi_conn->active_cmd_list);
+	qedi_cmd->io_cmd_in_list = true;
+	qedi_conn->active_cmd_count++;
+	spin_unlock(&qedi_conn->list_lock);
+
+	qedi_add_to_sq(qedi_conn, task, tid, ptu_invalidate, false);
+	qedi_ring_doorbell(qedi_conn);
+
+	return 0;
+}
+
+int qedi_send_iscsi_nopout(struct qedi_conn *qedi_conn,
+			   struct iscsi_task *task,
+			   char *datap, int data_len, int unsol)
+{
+	struct qedi_ctx *qedi = qedi_conn->qedi;
+	struct iscsi_task_context *fw_task_ctx;
+	struct iscsi_nop_out_hdr *fw_nop_out;
+	struct qedi_cmd *qedi_cmd;
+	/* For 6.5 hdr iscsi_hdr */
+	struct iscsi_nopout *nopout_hdr;
+	struct iscsi_cached_sge_ctx *cached_sge;
+	struct iscsi_sge *single_sge;
+	struct iscsi_sge *req_sge;
+	struct iscsi_sge *resp_sge;
+	u32 lun[2];
+	s16 ptu_invalidate = 0;
+	s16 tid = 0;
+
+	req_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.req_bd_tbl;
+	resp_sge = (struct iscsi_sge *)qedi_conn->gen_pdu.resp_bd_tbl;
+	qedi_cmd = (struct qedi_cmd *)task->dd_data;
+	nopout_hdr = (struct iscsi_nopout *)task->hdr;
+
+	tid = qedi_get_task_idx(qedi);
+	if (tid == -1) {
+		QEDI_WARN(&qedi->dbg_ctx, "Invalid tid\n");
+		return -ENOMEM;
+	}
+
+	fw_task_ctx = qedi_get_task_mem(&qedi->tasks, tid);
+
+	memset(fw_task_ctx, 0, sizeof(struct iscsi_task_context));
+	qedi_cmd->task_id = tid;
+
+	/* Ystorm context */
+	fw_nop_out = &fw_task_ctx->ystorm_st_context.pdu_hdr.nop_out;
+	SET_FIELD(fw_nop_out->flags_attr, ISCSI_NOP_OUT_HDR_CONST1, 1);
+	SET_FIELD(fw_nop_out->flags_attr, ISCSI_NOP_OUT_HDR_RSRV, 0);
+
+	memcpy(lun, &nopout_hdr->lun, sizeof(struct scsi_lun));
+	fw_nop_out->lun.lo = be32_to_cpu(lun[0]);
+	fw_nop_out->lun.hi = be32_to_cpu(lun[1]);
+
+	qedi_update_itt_map(qedi, tid, task->itt, qedi_cmd);
+
+	if (nopout_hdr->ttt != ISCSI_TTT_ALL_ONES) {
+		fw_nop_out->itt = be32_to_cpu(nopout_hdr->itt);
+		fw_nop_out->ttt = be32_to_cpu(nopout_hdr->ttt);
+		fw_task_ctx->ystorm_st_context.state.buffer_offset[0] = 0;
+		fw_task_ctx->ystorm_st_context.state.local_comp = 1;
+		SET_FIELD(fw_task_ctx->ustorm_st_context.flags,
+			  USTORM_ISCSI_TASK_ST_CTX_LOCAL_COMP, 1);
+	} else {
+		fw_nop_out->itt = qedi_set_itt(tid, get_itt(task->itt));
+		fw_nop_out->ttt = ISCSI_TTT_ALL_ONES;
+		fw_task_ctx->ystorm_st_context.state.buffer_offset[0] = 0;
+
+		spin_lock(&qedi_conn->list_lock);
+		list_add_tail(&qedi_cmd->io_cmd, &qedi_conn->active_cmd_list);
+		qedi_cmd->io_cmd_in_list = true;
+		qedi_conn->active_cmd_count++;
+		spin_unlock(&qedi_conn->list_lock);
+	}
+
+	fw_nop_out->opcode = ISCSI_OPCODE_NOP_OUT;
+	fw_nop_out->cmd_sn = be32_to_cpu(nopout_hdr->cmdsn);
+	fw_nop_out->exp_stat_sn = be32_to_cpu(nopout_hdr->exp_statsn);
+
+	cached_sge =
+	       &fw_task_ctx->ystorm_st_context.state.sgl_ctx_union.cached_sge;
+	cached_sge->sge.sge_len = req_sge->sge_len;
+	cached_sge->sge.sge_addr.lo = (u32)(qedi_conn->gen_pdu.req_dma_addr);
+	cached_sge->sge.sge_addr.hi =
+			(u32)((u64)qedi_conn->gen_pdu.req_dma_addr >> 32);
+
+	/* Mstorm context */
+	fw_task_ctx->mstorm_st_context.task_type = ISCSI_TASK_TYPE_MIDPATH;
+	fw_task_ctx->mstorm_ag_context.task_cid = (u16)qedi_conn->iscsi_conn_id;
+
+	single_sge = &fw_task_ctx->mstorm_st_context.sgl_union.single_sge;
+	single_sge->sge_addr.lo = resp_sge->sge_addr.lo;
+	single_sge->sge_addr.hi = resp_sge->sge_addr.hi;
+	single_sge->sge_len = resp_sge->sge_len;
+	fw_task_ctx->mstorm_st_context.rem_task_size = resp_sge->sge_len;
+
+	if (qedi->tid_reuse_count[tid] == QEDI_MAX_TASK_NUM) {
+		ptu_invalidate = 1;
+		qedi->tid_reuse_count[tid] = 0;
+	}
+	fw_task_ctx->ystorm_st_context.state.reuse_count =
+						qedi->tid_reuse_count[tid];
+	fw_task_ctx->mstorm_st_context.reuse_count =
+						qedi->tid_reuse_count[tid]++;
+	/* Ustorm context */
+	fw_task_ctx->ustorm_st_context.rem_rcv_len = resp_sge->sge_len;
+	fw_task_ctx->ustorm_st_context.exp_data_transfer_len = data_len;
+	fw_task_ctx->ustorm_st_context.exp_data_sn = 0;
+	fw_task_ctx->ustorm_st_context.task_type =  ISCSI_TASK_TYPE_MIDPATH;
+	fw_task_ctx->ustorm_st_context.cq_rss_number = 0;
+
+	SET_FIELD(fw_task_ctx->ustorm_st_context.reg1.reg1_map,
+		  ISCSI_REG1_NUM_FAST_SGES, 0);
+
+	fw_task_ctx->ustorm_ag_context.icid = (u16)qedi_conn->iscsi_conn_id;
+	SET_FIELD(fw_task_ctx->ustorm_ag_context.flags1,
+		  USTORM_ISCSI_TASK_AG_CTX_R2T2RECV, 1);
+
+	fw_task_ctx->ustorm_st_context.lun.lo = be32_to_cpu(lun[0]);
+	fw_task_ctx->ustorm_st_context.lun.hi = be32_to_cpu(lun[1]);
+
+	qedi_add_to_sq(qedi_conn, task, tid, ptu_invalidate, false);
+	qedi_ring_doorbell(qedi_conn);
+	return 0;
+}
diff --git a/drivers/scsi/qedi/qedi_gbl.h b/drivers/scsi/qedi/qedi_gbl.h
new file mode 100644
index 0000000..3af8bd7
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_gbl.h
@@ -0,0 +1,67 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QEDI_GBL_H_
+#define _QEDI_GBL_H_
+
+#include "qedi_iscsi.h"
+
+extern uint io_tracing;
+extern int do_not_recover;
+extern struct scsi_host_template qedi_host_template;
+extern struct iscsi_transport qedi_iscsi_transport;
+extern const struct qed_iscsi_ops *qedi_ops;
+extern struct qedi_debugfs_ops qedi_debugfs_ops;
+extern const struct file_operations qedi_dbg_fops;
+extern struct device_attribute *qedi_shost_attrs[];
+
+int qedi_alloc_sq(struct qedi_ctx *qedi, struct qedi_endpoint *ep);
+void qedi_free_sq(struct qedi_ctx *qedi, struct qedi_endpoint *ep);
+
+int qedi_send_iscsi_login(struct qedi_conn *qedi_conn,
+			  struct iscsi_task *task);
+int qedi_send_iscsi_logout(struct qedi_conn *qedi_conn,
+			   struct iscsi_task *task);
+int qedi_send_iscsi_text(struct qedi_conn *qedi_conn,
+			 struct iscsi_task *task);
+int qedi_send_iscsi_nopout(struct qedi_conn *qedi_conn,
+			   struct iscsi_task *task,
+			   char *datap, int data_len, int unsol);
+int qedi_get_task_idx(struct qedi_ctx *qedi);
+void qedi_clear_task_idx(struct qedi_ctx *qedi, int idx);
+int qedi_iscsi_cleanup_task(struct iscsi_task *task,
+			    bool mark_cmd_node_deleted);
+void qedi_iscsi_unmap_sg_list(struct qedi_cmd *cmd);
+void qedi_update_itt_map(struct qedi_ctx *qedi, u32 tid, u32 proto_itt,
+			 struct qedi_cmd *qedi_cmd);
+void qedi_get_proto_itt(struct qedi_ctx *qedi, u32 tid, u32 *proto_itt);
+void qedi_get_task_tid(struct qedi_ctx *qedi, u32 itt, int16_t *tid);
+void qedi_process_iscsi_error(struct qedi_endpoint *ep,
+			      struct async_data *data);
+void qedi_start_conn_recovery(struct qedi_ctx *qedi,
+			      struct qedi_conn *qedi_conn);
+struct qedi_conn *qedi_get_conn_from_id(struct qedi_ctx *qedi, u32 iscsi_cid);
+void qedi_process_tcp_error(struct qedi_endpoint *ep, struct async_data *data);
+void qedi_mark_device_missing(struct iscsi_cls_session *cls_session);
+void qedi_mark_device_available(struct iscsi_cls_session *cls_session);
+void qedi_reset_host_mtu(struct qedi_ctx *qedi, u16 mtu);
+int qedi_recover_all_conns(struct qedi_ctx *qedi);
+void qedi_fp_process_cqes(struct qedi_work *work);
+void qedi_trace_io(struct qedi_ctx *qedi, struct iscsi_task *task,
+		   u16 tid, int8_t direction);
+int qedi_alloc_id(struct qedi_portid_tbl *id_tbl, u16 id);
+u16 qedi_alloc_new_id(struct qedi_portid_tbl *id_tbl);
+void qedi_free_id(struct qedi_portid_tbl *id_tbl, u16 id);
+int qedi_create_sysfs_ctx_attr(struct qedi_ctx *qedi);
+void qedi_remove_sysfs_ctx_attr(struct qedi_ctx *qedi);
+void qedi_clearsq(struct qedi_ctx *qedi,
+		  struct qedi_conn *qedi_conn,
+		  struct iscsi_task *task);
+
+#endif
diff --git a/drivers/scsi/qedi/qedi_iscsi.c b/drivers/scsi/qedi/qedi_iscsi.c
new file mode 100644
index 0000000..4a41367
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_iscsi.c
@@ -0,0 +1,1611 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#include <linux/blkdev.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <scsi/scsi_tcq.h>
+
+#include "qedi.h"
+#include "qedi_iscsi.h"
+#include "qedi_gbl.h"
+
+int qedi_recover_all_conns(struct qedi_ctx *qedi)
+{
+	struct qedi_conn *qedi_conn;
+	int i;
+
+	for (i = 0; i < qedi->max_active_conns; i++) {
+		qedi_conn = qedi_get_conn_from_id(qedi, i);
+		if (!qedi_conn)
+			continue;
+
+		qedi_start_conn_recovery(qedi, qedi_conn);
+	}
+
+	return SUCCESS;
+}
+
+static int qedi_eh_host_reset(struct scsi_cmnd *cmd)
+{
+	struct Scsi_Host *shost = cmd->device->host;
+	struct qedi_ctx *qedi;
+
+	qedi = iscsi_host_priv(shost);
+
+	return qedi_recover_all_conns(qedi);
+}
+
+struct scsi_host_template qedi_host_template = {
+	.module = THIS_MODULE,
+	.name = "QLogic QEDI 25/40/100Gb iSCSI Initiator Driver",
+	.proc_name = QEDI_MODULE_NAME,
+	.can_queue = QEDI_MAX_ISCSI_TASK,
+	.this_id = -1,
+	.sg_tablesize = QEDI_ISCSI_MAX_BDS_PER_CMD,
+	.max_sectors = 0xffff,
+	.cmd_per_lun = 128,
+	.use_clustering = ENABLE_CLUSTERING,
+	.shost_attrs = qedi_shost_attrs,
+};
+
+static void qedi_conn_free_login_resources(struct qedi_ctx *qedi,
+					   struct qedi_conn *qedi_conn)
+{
+	if (qedi_conn->gen_pdu.resp_bd_tbl) {
+		dma_free_coherent(&qedi->pdev->dev, QEDI_PAGE_SIZE,
+				  qedi_conn->gen_pdu.resp_bd_tbl,
+				  qedi_conn->gen_pdu.resp_bd_dma);
+		qedi_conn->gen_pdu.resp_bd_tbl = NULL;
+	}
+
+	if (qedi_conn->gen_pdu.req_bd_tbl) {
+		dma_free_coherent(&qedi->pdev->dev, QEDI_PAGE_SIZE,
+				  qedi_conn->gen_pdu.req_bd_tbl,
+				  qedi_conn->gen_pdu.req_bd_dma);
+		qedi_conn->gen_pdu.req_bd_tbl = NULL;
+	}
+
+	if (qedi_conn->gen_pdu.resp_buf) {
+		dma_free_coherent(&qedi->pdev->dev,
+				  ISCSI_DEF_MAX_RECV_SEG_LEN,
+				  qedi_conn->gen_pdu.resp_buf,
+				  qedi_conn->gen_pdu.resp_dma_addr);
+		qedi_conn->gen_pdu.resp_buf = NULL;
+	}
+
+	if (qedi_conn->gen_pdu.req_buf) {
+		dma_free_coherent(&qedi->pdev->dev,
+				  ISCSI_DEF_MAX_RECV_SEG_LEN,
+				  qedi_conn->gen_pdu.req_buf,
+				  qedi_conn->gen_pdu.req_dma_addr);
+		qedi_conn->gen_pdu.req_buf = NULL;
+	}
+}
+
+static int qedi_conn_alloc_login_resources(struct qedi_ctx *qedi,
+					   struct qedi_conn *qedi_conn)
+{
+	qedi_conn->gen_pdu.req_buf =
+		dma_alloc_coherent(&qedi->pdev->dev,
+				   ISCSI_DEF_MAX_RECV_SEG_LEN,
+				   &qedi_conn->gen_pdu.req_dma_addr,
+				   GFP_KERNEL);
+	if (!qedi_conn->gen_pdu.req_buf)
+		goto login_req_buf_failure;
+
+	qedi_conn->gen_pdu.req_buf_size = 0;
+	qedi_conn->gen_pdu.req_wr_ptr = qedi_conn->gen_pdu.req_buf;
+
+	qedi_conn->gen_pdu.resp_buf =
+		dma_alloc_coherent(&qedi->pdev->dev,
+				   ISCSI_DEF_MAX_RECV_SEG_LEN,
+				   &qedi_conn->gen_pdu.resp_dma_addr,
+				   GFP_KERNEL);
+	if (!qedi_conn->gen_pdu.resp_buf)
+		goto login_resp_buf_failure;
+
+	qedi_conn->gen_pdu.resp_buf_size = ISCSI_DEF_MAX_RECV_SEG_LEN;
+	qedi_conn->gen_pdu.resp_wr_ptr = qedi_conn->gen_pdu.resp_buf;
+
+	qedi_conn->gen_pdu.req_bd_tbl =
+		dma_alloc_coherent(&qedi->pdev->dev, QEDI_PAGE_SIZE,
+				   &qedi_conn->gen_pdu.req_bd_dma, GFP_KERNEL);
+	if (!qedi_conn->gen_pdu.req_bd_tbl)
+		goto login_req_bd_tbl_failure;
+
+	qedi_conn->gen_pdu.resp_bd_tbl =
+		dma_alloc_coherent(&qedi->pdev->dev, QEDI_PAGE_SIZE,
+				   &qedi_conn->gen_pdu.resp_bd_dma,
+				   GFP_KERNEL);
+	if (!qedi_conn->gen_pdu.resp_bd_tbl)
+		goto login_resp_bd_tbl_failure;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_SESS,
+		  "Allocation successful, cid=0x%x\n",
+		  qedi_conn->iscsi_conn_id);
+	return 0;
+
+login_resp_bd_tbl_failure:
+	dma_free_coherent(&qedi->pdev->dev, QEDI_PAGE_SIZE,
+			  qedi_conn->gen_pdu.req_bd_tbl,
+			  qedi_conn->gen_pdu.req_bd_dma);
+	qedi_conn->gen_pdu.req_bd_tbl = NULL;
+
+login_req_bd_tbl_failure:
+	dma_free_coherent(&qedi->pdev->dev, ISCSI_DEF_MAX_RECV_SEG_LEN,
+			  qedi_conn->gen_pdu.resp_buf,
+			  qedi_conn->gen_pdu.resp_dma_addr);
+	qedi_conn->gen_pdu.resp_buf = NULL;
+login_resp_buf_failure:
+	dma_free_coherent(&qedi->pdev->dev, ISCSI_DEF_MAX_RECV_SEG_LEN,
+			  qedi_conn->gen_pdu.req_buf,
+			  qedi_conn->gen_pdu.req_dma_addr);
+	qedi_conn->gen_pdu.req_buf = NULL;
+login_req_buf_failure:
+	iscsi_conn_printk(KERN_ERR, qedi_conn->cls_conn->dd_data,
+			  "login resource alloc failed!!\n");
+	return -ENOMEM;
+}
+
+static void qedi_destroy_cmd_pool(struct qedi_ctx *qedi,
+				  struct iscsi_session *session)
+{
+	int i;
+
+	for (i = 0; i < session->cmds_max; i++) {
+		struct iscsi_task *task = session->cmds[i];
+		struct qedi_cmd *cmd = task->dd_data;
+
+		if (cmd->io_tbl.sge_tbl)
+			dma_free_coherent(&qedi->pdev->dev,
+					  QEDI_ISCSI_MAX_BDS_PER_CMD *
+					  sizeof(struct iscsi_sge),
+					  cmd->io_tbl.sge_tbl,
+					  cmd->io_tbl.sge_tbl_dma);
+
+		if (cmd->sense_buffer)
+			dma_free_coherent(&qedi->pdev->dev,
+					  SCSI_SENSE_BUFFERSIZE,
+					  cmd->sense_buffer,
+					  cmd->sense_buffer_dma);
+	}
+}
+
+static int qedi_alloc_sget(struct qedi_ctx *qedi, struct iscsi_session *session,
+			   struct qedi_cmd *cmd)
+{
+	struct qedi_io_bdt *io = &cmd->io_tbl;
+	struct iscsi_sge *sge;
+
+	io->sge_tbl = dma_alloc_coherent(&qedi->pdev->dev,
+					 QEDI_ISCSI_MAX_BDS_PER_CMD *
+					 sizeof(*sge),
+					 &io->sge_tbl_dma, GFP_KERNEL);
+	if (!io->sge_tbl) {
+		iscsi_session_printk(KERN_ERR, session,
+				     "Could not allocate BD table.\n");
+		return -ENOMEM;
+	}
+
+	io->sge_valid = 0;
+	return 0;
+}
+
+static int qedi_setup_cmd_pool(struct qedi_ctx *qedi,
+			       struct iscsi_session *session)
+{
+	int i;
+
+	for (i = 0; i < session->cmds_max; i++) {
+		struct iscsi_task *task = session->cmds[i];
+		struct qedi_cmd *cmd = task->dd_data;
+
+		task->hdr = &cmd->hdr;
+		task->hdr_max = sizeof(struct iscsi_hdr);
+
+		if (qedi_alloc_sget(qedi, session, cmd))
+			goto free_sgets;
+
+		cmd->sense_buffer = dma_alloc_coherent(&qedi->pdev->dev,
+						       SCSI_SENSE_BUFFERSIZE,
+						       &cmd->sense_buffer_dma,
+						       GFP_KERNEL);
+		if (!cmd->sense_buffer)
+			goto free_sgets;
+	}
+
+	return 0;
+
+free_sgets:
+	qedi_destroy_cmd_pool(qedi, session);
+	return -ENOMEM;
+}
+
+static struct iscsi_cls_session *
+qedi_session_create(struct iscsi_endpoint *ep, u16 cmds_max,
+		    u16 qdepth, uint32_t initial_cmdsn)
+{
+	struct Scsi_Host *shost;
+	struct iscsi_cls_session *cls_session;
+	struct qedi_ctx *qedi;
+	struct qedi_endpoint *qedi_ep;
+
+	if (!ep)
+		return NULL;
+
+	qedi_ep = ep->dd_data;
+	shost = qedi_ep->qedi->shost;
+	qedi = iscsi_host_priv(shost);
+
+	if (cmds_max > qedi->max_sqes)
+		cmds_max = qedi->max_sqes;
+	else if (cmds_max < QEDI_SQ_WQES_MIN)
+		cmds_max = QEDI_SQ_WQES_MIN;
+
+	cls_session = iscsi_session_setup(&qedi_iscsi_transport, shost,
+					  cmds_max, 0, sizeof(struct qedi_cmd),
+					  initial_cmdsn, ISCSI_MAX_TARGET);
+	if (!cls_session) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Failed to setup session for ep=%p\n", qedi_ep);
+		return NULL;
+	}
+
+	if (qedi_setup_cmd_pool(qedi, cls_session->dd_data)) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Failed to setup cmd pool for ep=%p\n", qedi_ep);
+		goto session_teardown;
+	}
+
+	return cls_session;
+
+session_teardown:
+	iscsi_session_teardown(cls_session);
+	return NULL;
+}
+
+static void qedi_session_destroy(struct iscsi_cls_session *cls_session)
+{
+	struct iscsi_session *session = cls_session->dd_data;
+	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
+	struct qedi_ctx *qedi = iscsi_host_priv(shost);
+
+	qedi_destroy_cmd_pool(qedi, session);
+	iscsi_session_teardown(cls_session);
+}
+
+static struct iscsi_cls_conn *
+qedi_conn_create(struct iscsi_cls_session *cls_session, uint32_t cid)
+{
+	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
+	struct qedi_ctx *qedi = iscsi_host_priv(shost);
+	struct iscsi_cls_conn *cls_conn;
+	struct qedi_conn *qedi_conn;
+	struct iscsi_conn *conn;
+
+	cls_conn = iscsi_conn_setup(cls_session, sizeof(*qedi_conn),
+				    cid);
+	if (!cls_conn) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "conn_new: iscsi conn setup failed, cid=0x%x, cls_sess=%p!\n",
+			 cid, cls_session);
+		return NULL;
+	}
+
+	conn = cls_conn->dd_data;
+	qedi_conn = conn->dd_data;
+	qedi_conn->cls_conn = cls_conn;
+	qedi_conn->qedi = qedi;
+	qedi_conn->ep = NULL;
+	qedi_conn->active_cmd_count = 0;
+	INIT_LIST_HEAD(&qedi_conn->active_cmd_list);
+	spin_lock_init(&qedi_conn->list_lock);
+
+	if (qedi_conn_alloc_login_resources(qedi, qedi_conn)) {
+		iscsi_conn_printk(KERN_ALERT, conn,
+				  "conn_new: login resc alloc failed, cid=0x%x, cls_sess=%p!!\n",
+				   cid, cls_session);
+		goto free_conn;
+	}
+
+	return cls_conn;
+
+free_conn:
+	iscsi_conn_teardown(cls_conn);
+	return NULL;
+}
+
+void qedi_mark_device_missing(struct iscsi_cls_session *cls_session)
+{
+	iscsi_block_session(cls_session);
+}
+
+void qedi_mark_device_available(struct iscsi_cls_session *cls_session)
+{
+	iscsi_unblock_session(cls_session);
+}
+
+static int qedi_bind_conn_to_iscsi_cid(struct qedi_ctx *qedi,
+				       struct qedi_conn *qedi_conn)
+{
+	u32 iscsi_cid = qedi_conn->iscsi_conn_id;
+
+	if (qedi->cid_que.conn_cid_tbl[iscsi_cid]) {
+		iscsi_conn_printk(KERN_ALERT, qedi_conn->cls_conn->dd_data,
+				  "conn bind - entry #%d not free\n",
+				  iscsi_cid);
+		return -EBUSY;
+	}
+
+	qedi->cid_que.conn_cid_tbl[iscsi_cid] = qedi_conn;
+	return 0;
+}
+
+struct qedi_conn *qedi_get_conn_from_id(struct qedi_ctx *qedi, u32 iscsi_cid)
+{
+	if (!qedi->cid_que.conn_cid_tbl) {
+		QEDI_ERR(&qedi->dbg_ctx, "missing conn<->cid table\n");
+		return NULL;
+
+	} else if (iscsi_cid >= qedi->max_active_conns) {
+		QEDI_ERR(&qedi->dbg_ctx, "wrong cid #%d\n", iscsi_cid);
+		return NULL;
+	}
+	return qedi->cid_que.conn_cid_tbl[iscsi_cid];
+}
+
+static int qedi_conn_bind(struct iscsi_cls_session *cls_session,
+			  struct iscsi_cls_conn *cls_conn,
+			  u64 transport_fd, int is_leading)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct Scsi_Host *shost = iscsi_session_to_shost(cls_session);
+	struct qedi_ctx *qedi = iscsi_host_priv(shost);
+	struct qedi_endpoint *qedi_ep;
+	struct iscsi_endpoint *ep;
+
+	ep = iscsi_lookup_endpoint(transport_fd);
+	if (!ep)
+		return -EINVAL;
+
+	qedi_ep = ep->dd_data;
+	if ((qedi_ep->state == EP_STATE_TCP_FIN_RCVD) ||
+	    (qedi_ep->state == EP_STATE_TCP_RST_RCVD))
+		return -EINVAL;
+
+	if (iscsi_conn_bind(cls_session, cls_conn, is_leading))
+		return -EINVAL;
+
+	qedi_ep->conn = qedi_conn;
+	qedi_conn->ep = qedi_ep;
+	qedi_conn->iscsi_conn_id = qedi_ep->iscsi_cid;
+	qedi_conn->fw_cid = qedi_ep->fw_cid;
+	qedi_conn->cmd_cleanup_req = 0;
+	qedi_conn->cmd_cleanup_cmpl = 0;
+
+	if (qedi_bind_conn_to_iscsi_cid(qedi, qedi_conn))
+		return -EINVAL;
+
+	spin_lock_init(&qedi_conn->tmf_work_lock);
+	INIT_LIST_HEAD(&qedi_conn->tmf_work_list);
+	init_waitqueue_head(&qedi_conn->wait_queue);
+	return 0;
+}
+
+static int qedi_iscsi_update_conn(struct qedi_ctx *qedi,
+				  struct qedi_conn *qedi_conn)
+{
+	struct qed_iscsi_params_update *conn_info;
+	struct iscsi_cls_conn *cls_conn = qedi_conn->cls_conn;
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct qedi_endpoint *qedi_ep;
+	int rval;
+
+	qedi_ep = qedi_conn->ep;
+
+	conn_info = kzalloc(sizeof(*conn_info), GFP_KERNEL);
+	if (!conn_info) {
+		QEDI_ERR(&qedi->dbg_ctx, "memory alloc failed\n");
+		return -ENOMEM;
+	}
+
+	conn_info->update_flag = 0;
+
+	if (conn->hdrdgst_en)
+		SET_FIELD(conn_info->update_flag,
+			  ISCSI_CONN_UPDATE_RAMROD_PARAMS_HD_EN, true);
+	if (conn->datadgst_en)
+		SET_FIELD(conn_info->update_flag,
+			  ISCSI_CONN_UPDATE_RAMROD_PARAMS_DD_EN, true);
+	if (conn->session->initial_r2t_en)
+		SET_FIELD(conn_info->update_flag,
+			  ISCSI_CONN_UPDATE_RAMROD_PARAMS_INITIAL_R2T,
+			  true);
+	if (conn->session->imm_data_en)
+		SET_FIELD(conn_info->update_flag,
+			  ISCSI_CONN_UPDATE_RAMROD_PARAMS_IMMEDIATE_DATA,
+			  true);
+
+	conn_info->max_seq_size = conn->session->max_burst;
+	conn_info->max_recv_pdu_length = conn->max_recv_dlength;
+	conn_info->max_send_pdu_length = conn->max_xmit_dlength;
+	conn_info->first_seq_length = conn->session->first_burst;
+	conn_info->exp_stat_sn = conn->exp_statsn;
+
+	rval = qedi_ops->update_conn(qedi->cdev, qedi_ep->handle,
+				     conn_info);
+	if (rval) {
+		rval = -ENXIO;
+		QEDI_ERR(&qedi->dbg_ctx, "Could not update connection\n");
+		goto update_conn_err;
+	}
+
+	kfree(conn_info);
+	rval = 0;
+
+update_conn_err:
+	return rval;
+}
+
+static u16 qedi_calc_mss(u16 pmtu, u8 is_ipv6, u8 tcp_ts_en, u8 vlan_en)
+{
+	u16 mss = 0;
+	u16 hdrs = TCP_HDR_LEN;
+
+	if (is_ipv6)
+		hdrs += IPV6_HDR_LEN;
+	else
+		hdrs += IPV4_HDR_LEN;
+
+	if (vlan_en)
+		hdrs += VLAN_LEN;
+
+	mss = pmtu - hdrs;
+
+	if (tcp_ts_en)
+		mss -= TCP_OPTION_LEN;
+
+	if (!mss)
+		mss = DEF_MSS;
+
+	return mss;
+}
+
+static int qedi_iscsi_offload_conn(struct qedi_endpoint *qedi_ep)
+{
+	struct qedi_ctx *qedi = qedi_ep->qedi;
+	struct qed_iscsi_params_offload *conn_info;
+	int rval;
+	int i;
+
+	conn_info = kzalloc(sizeof(*conn_info), GFP_KERNEL);
+	if (!conn_info) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Failed to allocate memory ep=%p\n", qedi_ep);
+		return -ENOMEM;
+	}
+
+	ether_addr_copy(conn_info->src.mac, qedi_ep->src_mac);
+	ether_addr_copy(conn_info->dst.mac, qedi_ep->dst_mac);
+
+	conn_info->src.ip[0] = ntohl(qedi_ep->src_addr[0]);
+	conn_info->dst.ip[0] = ntohl(qedi_ep->dst_addr[0]);
+
+	if (qedi_ep->ip_type == TCP_IPV4) {
+		conn_info->ip_version = 0;
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "After ntohl: src_addr=%pI4, dst_addr=%pI4\n",
+			  qedi_ep->src_addr, qedi_ep->dst_addr);
+	} else {
+		for (i = 1; i < 4; i++) {
+			conn_info->src.ip[i] = ntohl(qedi_ep->src_addr[i]);
+			conn_info->dst.ip[i] = ntohl(qedi_ep->dst_addr[i]);
+		}
+
+		conn_info->ip_version = 1;
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "After ntohl: src_addr=%pI6, dst_addr=%pI6\n",
+			  qedi_ep->src_addr, qedi_ep->dst_addr);
+	}
+
+	conn_info->src.port = qedi_ep->src_port;
+	conn_info->dst.port = qedi_ep->dst_port;
+
+	conn_info->layer_code = ISCSI_SLOW_PATH_LAYER_CODE;
+	conn_info->sq_pbl_addr = qedi_ep->sq_pbl_dma;
+	conn_info->vlan_id = qedi_ep->vlan_id;
+
+	SET_FIELD(conn_info->tcp_flags, TCP_OFFLOAD_PARAMS_TS_EN, 1);
+	SET_FIELD(conn_info->tcp_flags, TCP_OFFLOAD_PARAMS_DA_EN, 1);
+	SET_FIELD(conn_info->tcp_flags, TCP_OFFLOAD_PARAMS_DA_CNT_EN, 1);
+	SET_FIELD(conn_info->tcp_flags, TCP_OFFLOAD_PARAMS_KA_EN, 1);
+
+	conn_info->default_cq = (qedi_ep->fw_cid % 8);
+
+	conn_info->ka_max_probe_cnt = DEF_KA_MAX_PROBE_COUNT;
+	conn_info->dup_ack_theshold = 3;
+	conn_info->rcv_wnd = 65535;
+	conn_info->cwnd = DEF_MAX_CWND;
+
+	conn_info->ss_thresh = 65535;
+	conn_info->srtt = 300;
+	conn_info->rtt_var = 150;
+	conn_info->flow_label = 0;
+	conn_info->ka_timeout = DEF_KA_TIMEOUT;
+	conn_info->ka_interval = DEF_KA_INTERVAL;
+	conn_info->max_rt_time = DEF_MAX_RT_TIME;
+	conn_info->ttl = DEF_TTL;
+	conn_info->tos_or_tc = DEF_TOS;
+	conn_info->remote_port = qedi_ep->dst_port;
+	conn_info->local_port = qedi_ep->src_port;
+
+	conn_info->mss = qedi_calc_mss(qedi_ep->pmtu,
+				       (qedi_ep->ip_type == TCP_IPV6),
+				       1, (qedi_ep->vlan_id != 0));
+
+	conn_info->rcv_wnd_scale = 4;
+	conn_info->ts_ticks_per_second = 1000;
+	conn_info->da_timeout_value = 200;
+	conn_info->ack_frequency = 2;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+		  "Default cq index [%d], mss [%d]\n",
+		  conn_info->default_cq, conn_info->mss);
+
+	rval = qedi_ops->offload_conn(qedi->cdev, qedi_ep->handle, conn_info);
+	if (rval)
+		QEDI_ERR(&qedi->dbg_ctx, "offload_conn returned %d, ep=%p\n",
+			 rval, qedi_ep);
+
+	kfree(conn_info);
+	return rval;
+}
+
+static int qedi_conn_start(struct iscsi_cls_conn *cls_conn)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct qedi_ctx *qedi;
+	int rval;
+
+	qedi = qedi_conn->qedi;
+
+	rval = qedi_iscsi_update_conn(qedi, qedi_conn);
+	if (rval) {
+		iscsi_conn_printk(KERN_ALERT, conn,
+				  "conn_start: FW oflload conn failed.\n");
+		rval = -EINVAL;
+		goto start_err;
+	}
+
+	clear_bit(QEDI_CONN_FW_CLEANUP, &qedi_conn->flags);
+	qedi_conn->abrt_conn = 0;
+
+	rval = iscsi_conn_start(cls_conn);
+	if (rval) {
+		iscsi_conn_printk(KERN_ALERT, conn,
+				  "iscsi_conn_start: FW oflload conn failed!!\n");
+	}
+
+start_err:
+	return rval;
+}
+
+static void qedi_conn_destroy(struct iscsi_cls_conn *cls_conn)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct Scsi_Host *shost;
+	struct qedi_ctx *qedi;
+
+	shost = iscsi_session_to_shost(iscsi_conn_to_session(cls_conn));
+	qedi = iscsi_host_priv(shost);
+
+	qedi_conn_free_login_resources(qedi, qedi_conn);
+	iscsi_conn_teardown(cls_conn);
+}
+
+static int qedi_ep_get_param(struct iscsi_endpoint *ep,
+			     enum iscsi_param param, char *buf)
+{
+	struct qedi_endpoint *qedi_ep = ep->dd_data;
+	int len;
+
+	if (!qedi_ep)
+		return -ENOTCONN;
+
+	switch (param) {
+	case ISCSI_PARAM_CONN_PORT:
+		len = sprintf(buf, "%hu\n", qedi_ep->dst_port);
+		break;
+	case ISCSI_PARAM_CONN_ADDRESS:
+		if (qedi_ep->ip_type == TCP_IPV4)
+			len = sprintf(buf, "%pI4\n", qedi_ep->dst_addr);
+		else
+			len = sprintf(buf, "%pI6\n", qedi_ep->dst_addr);
+		break;
+	default:
+		return -ENOTCONN;
+	}
+
+	return len;
+}
+
+static int qedi_host_get_param(struct Scsi_Host *shost,
+			       enum iscsi_host_param param, char *buf)
+{
+	struct qedi_ctx *qedi;
+	int len;
+
+	qedi = iscsi_host_priv(shost);
+
+	switch (param) {
+	case ISCSI_HOST_PARAM_HWADDRESS:
+		len = sysfs_format_mac(buf, qedi->mac, 6);
+		break;
+	case ISCSI_HOST_PARAM_NETDEV_NAME:
+		len = sprintf(buf, "host%d\n", shost->host_no);
+		break;
+	case ISCSI_HOST_PARAM_IPADDRESS:
+		if (qedi->ip_type == TCP_IPV4)
+			len = sprintf(buf, "%pI4\n", qedi->src_ip);
+		else
+			len = sprintf(buf, "%pI6\n", qedi->src_ip);
+		break;
+	default:
+		return iscsi_host_get_param(shost, param, buf);
+	}
+
+	return len;
+}
+
+static void qedi_conn_get_stats(struct iscsi_cls_conn *cls_conn,
+				struct iscsi_stats *stats)
+{
+	struct iscsi_conn *conn = cls_conn->dd_data;
+	struct qed_iscsi_stats iscsi_stats;
+	struct Scsi_Host *shost;
+	struct qedi_ctx *qedi;
+
+	shost = iscsi_session_to_shost(iscsi_conn_to_session(cls_conn));
+	qedi = iscsi_host_priv(shost);
+	qedi_ops->get_stats(qedi->cdev, &iscsi_stats);
+
+	conn->txdata_octets = iscsi_stats.iscsi_tx_bytes_cnt;
+	conn->rxdata_octets = iscsi_stats.iscsi_rx_bytes_cnt;
+	conn->dataout_pdus_cnt = (uint32_t)iscsi_stats.iscsi_tx_data_pdu_cnt;
+	conn->datain_pdus_cnt = (uint32_t)iscsi_stats.iscsi_rx_data_pdu_cnt;
+	conn->r2t_pdus_cnt = (uint32_t)iscsi_stats.iscsi_rx_r2t_pdu_cnt;
+
+	stats->txdata_octets = conn->txdata_octets;
+	stats->rxdata_octets = conn->rxdata_octets;
+	stats->scsicmd_pdus = conn->scsicmd_pdus_cnt;
+	stats->dataout_pdus = conn->dataout_pdus_cnt;
+	stats->scsirsp_pdus = conn->scsirsp_pdus_cnt;
+	stats->datain_pdus = conn->datain_pdus_cnt;
+	stats->r2t_pdus = conn->r2t_pdus_cnt;
+	stats->tmfcmd_pdus = conn->tmfcmd_pdus_cnt;
+	stats->tmfrsp_pdus = conn->tmfrsp_pdus_cnt;
+	stats->digest_err = 0;
+	stats->timeout_err = 0;
+	strcpy(stats->custom[0].desc, "eh_abort_cnt");
+	stats->custom[0].value = conn->eh_abort_cnt;
+	stats->custom_length = 1;
+}
+
+static void qedi_iscsi_prep_generic_pdu_bd(struct qedi_conn *qedi_conn)
+{
+	struct iscsi_sge *bd_tbl;
+
+	bd_tbl = (struct iscsi_sge *)qedi_conn->gen_pdu.req_bd_tbl;
+
+	bd_tbl->sge_addr.hi =
+		(u32)((u64)qedi_conn->gen_pdu.req_dma_addr >> 32);
+	bd_tbl->sge_addr.lo = (u32)qedi_conn->gen_pdu.req_dma_addr;
+	bd_tbl->sge_len = qedi_conn->gen_pdu.req_wr_ptr -
+				qedi_conn->gen_pdu.req_buf;
+	bd_tbl->reserved0 = 0;
+	bd_tbl = (struct iscsi_sge  *)qedi_conn->gen_pdu.resp_bd_tbl;
+	bd_tbl->sge_addr.hi =
+			(u32)((u64)qedi_conn->gen_pdu.resp_dma_addr >> 32);
+	bd_tbl->sge_addr.lo = (u32)qedi_conn->gen_pdu.resp_dma_addr;
+	bd_tbl->sge_len = ISCSI_DEF_MAX_RECV_SEG_LEN;
+	bd_tbl->reserved0 = 0;
+}
+
+static int qedi_iscsi_send_generic_request(struct iscsi_task *task)
+{
+	struct qedi_cmd *cmd = task->dd_data;
+	struct qedi_conn *qedi_conn = cmd->conn;
+	char *buf;
+	int data_len;
+	int rc = 0;
+
+	qedi_iscsi_prep_generic_pdu_bd(qedi_conn);
+	switch (task->hdr->opcode & ISCSI_OPCODE_MASK) {
+	case ISCSI_OP_LOGIN:
+		qedi_send_iscsi_login(qedi_conn, task);
+		break;
+	case ISCSI_OP_NOOP_OUT:
+		data_len = qedi_conn->gen_pdu.req_buf_size;
+		buf = qedi_conn->gen_pdu.req_buf;
+		if (data_len)
+			rc = qedi_send_iscsi_nopout(qedi_conn, task,
+						    buf, data_len, 1);
+		else
+			rc = qedi_send_iscsi_nopout(qedi_conn, task,
+						    NULL, 0, 1);
+		break;
+	case ISCSI_OP_LOGOUT:
+		rc = qedi_send_iscsi_logout(qedi_conn, task);
+		break;
+	case ISCSI_OP_TEXT:
+		rc = qedi_send_iscsi_text(qedi_conn, task);
+		break;
+	default:
+		iscsi_conn_printk(KERN_ALERT, qedi_conn->cls_conn->dd_data,
+				  "unsupported op 0x%x\n", task->hdr->opcode);
+	}
+
+	return rc;
+}
+
+static int qedi_mtask_xmit(struct iscsi_conn *conn, struct iscsi_task *task)
+{
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct qedi_cmd *cmd = task->dd_data;
+
+	memset(qedi_conn->gen_pdu.req_buf, 0, ISCSI_DEF_MAX_RECV_SEG_LEN);
+
+	qedi_conn->gen_pdu.req_buf_size = task->data_count;
+
+	if (task->data_count) {
+		memcpy(qedi_conn->gen_pdu.req_buf, task->data,
+		       task->data_count);
+		qedi_conn->gen_pdu.req_wr_ptr =
+			qedi_conn->gen_pdu.req_buf + task->data_count;
+	}
+
+	cmd->conn = conn->dd_data;
+	cmd->scsi_cmd = NULL;
+	return qedi_iscsi_send_generic_request(task);
+}
+
+static int qedi_task_xmit(struct iscsi_task *task)
+{
+	struct iscsi_conn *conn = task->conn;
+	struct qedi_conn *qedi_conn = conn->dd_data;
+	struct qedi_cmd *cmd = task->dd_data;
+	struct scsi_cmnd *sc = task->sc;
+
+	cmd->state = 0;
+	cmd->task = NULL;
+	cmd->use_slowpath = false;
+	cmd->conn = qedi_conn;
+	cmd->task = task;
+	cmd->io_cmd_in_list = false;
+	INIT_LIST_HEAD(&cmd->io_cmd);
+
+	if (!sc)
+		return qedi_mtask_xmit(conn, task);
+}
+
+static struct iscsi_endpoint *
+qedi_ep_connect(struct Scsi_Host *shost, struct sockaddr *dst_addr,
+		int non_blocking)
+{
+	struct qedi_ctx *qedi;
+	struct iscsi_endpoint *ep;
+	struct qedi_endpoint *qedi_ep;
+	struct sockaddr_in *addr;
+	struct sockaddr_in6 *addr6;
+	struct qed_dev *cdev  =  NULL;
+	struct qedi_uio_dev *udev = NULL;
+	struct iscsi_path path_req;
+	u32 msg_type = ISCSI_KEVENT_IF_DOWN;
+	u32 iscsi_cid = QEDI_CID_RESERVED;
+	u16 len = 0;
+	char *buf = NULL;
+	int ret;
+
+	if (!shost) {
+		ret = -ENXIO;
+		QEDI_ERR(NULL, "shost is NULL\n");
+		return ERR_PTR(ret);
+	}
+
+	if (do_not_recover) {
+		ret = -ENOMEM;
+		return ERR_PTR(ret);
+	}
+
+	qedi = iscsi_host_priv(shost);
+	cdev = qedi->cdev;
+	udev = qedi->udev;
+
+	if (test_bit(QEDI_IN_OFFLINE, &qedi->flags) ||
+	    test_bit(QEDI_IN_RECOVERY, &qedi->flags)) {
+		ret = -ENOMEM;
+		return ERR_PTR(ret);
+	}
+
+	ep = iscsi_create_endpoint(sizeof(struct qedi_endpoint));
+	if (!ep) {
+		QEDI_ERR(&qedi->dbg_ctx, "endpoint create fail\n");
+		ret = -ENOMEM;
+		return ERR_PTR(ret);
+	}
+	qedi_ep = ep->dd_data;
+	memset(qedi_ep, 0, sizeof(struct qedi_endpoint));
+	qedi_ep->state = EP_STATE_IDLE;
+	qedi_ep->iscsi_cid = (u32)-1;
+	qedi_ep->qedi = qedi;
+
+	if (dst_addr->sa_family == AF_INET) {
+		addr = (struct sockaddr_in *)dst_addr;
+		memcpy(qedi_ep->dst_addr, &addr->sin_addr.s_addr,
+		       sizeof(struct in_addr));
+		qedi_ep->dst_port = ntohs(addr->sin_port);
+		qedi_ep->ip_type = TCP_IPV4;
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "dst_addr=%pI4, dst_port=%u\n",
+			  qedi_ep->dst_addr, qedi_ep->dst_port);
+	} else if (dst_addr->sa_family == AF_INET6) {
+		addr6 = (struct sockaddr_in6 *)dst_addr;
+		memcpy(qedi_ep->dst_addr, &addr6->sin6_addr,
+		       sizeof(struct in6_addr));
+		qedi_ep->dst_port = ntohs(addr6->sin6_port);
+		qedi_ep->ip_type = TCP_IPV6;
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "dst_addr=%pI6, dst_port=%u\n",
+			  qedi_ep->dst_addr, qedi_ep->dst_port);
+	} else {
+		QEDI_ERR(&qedi->dbg_ctx, "Invalid endpoint\n");
+	}
+
+	if (atomic_read(&qedi->link_state) != QEDI_LINK_UP) {
+		QEDI_WARN(&qedi->dbg_ctx, "qedi link down\n");
+		ret = -ENXIO;
+		goto ep_conn_exit;
+	}
+
+	ret = qedi_alloc_sq(qedi, qedi_ep);
+	if (ret)
+		goto ep_conn_exit;
+
+	ret = qedi_ops->acquire_conn(qedi->cdev, &qedi_ep->handle,
+				     &qedi_ep->fw_cid, &qedi_ep->p_doorbell);
+
+	if (ret) {
+		QEDI_ERR(&qedi->dbg_ctx, "Could not acquire connection\n");
+		ret = -ENXIO;
+		goto ep_free_sq;
+	}
+
+	iscsi_cid = qedi_ep->handle;
+	qedi_ep->iscsi_cid = iscsi_cid;
+
+	init_waitqueue_head(&qedi_ep->ofld_wait);
+	init_waitqueue_head(&qedi_ep->tcp_ofld_wait);
+	qedi_ep->state = EP_STATE_OFLDCONN_START;
+	qedi->ep_tbl[iscsi_cid] = qedi_ep;
+
+	buf = (char *)&path_req;
+	len = sizeof(path_req);
+	memset(&path_req, 0, len);
+
+	msg_type = ISCSI_KEVENT_PATH_REQ;
+	path_req.handle = (u64)qedi_ep->iscsi_cid;
+	path_req.pmtu = qedi->ll2_mtu;
+	qedi_ep->pmtu = qedi->ll2_mtu;
+	if (qedi_ep->ip_type == TCP_IPV4) {
+		memcpy(&path_req.dst.v4_addr, &qedi_ep->dst_addr,
+		       sizeof(struct in_addr));
+		path_req.ip_addr_len = 4;
+	} else {
+		memcpy(&path_req.dst.v6_addr, &qedi_ep->dst_addr,
+		       sizeof(struct in6_addr));
+		path_req.ip_addr_len = 16;
+	}
+
+	ret = iscsi_offload_mesg(shost, &qedi_iscsi_transport, msg_type, buf,
+				 len);
+	if (ret) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "iscsi_offload_mesg() failed for cid=0x%x ret=%d\n",
+			 iscsi_cid, ret);
+		goto ep_rel_conn;
+	}
+
+	atomic_inc(&qedi->num_offloads);
+	return ep;
+
+ep_rel_conn:
+	qedi->ep_tbl[iscsi_cid] = NULL;
+	ret = qedi_ops->release_conn(qedi->cdev, qedi_ep->handle);
+	if (ret)
+		QEDI_WARN(&qedi->dbg_ctx, "release_conn returned %d\n",
+			  ret);
+ep_free_sq:
+	qedi_free_sq(qedi, qedi_ep);
+ep_conn_exit:
+	iscsi_destroy_endpoint(ep);
+	return ERR_PTR(ret);
+}
+
+static int qedi_ep_poll(struct iscsi_endpoint *ep, int timeout_ms)
+{
+	struct qedi_endpoint *qedi_ep;
+	int ret = 0;
+
+	if (do_not_recover)
+		return 1;
+
+	qedi_ep = ep->dd_data;
+	if (qedi_ep->state == EP_STATE_IDLE ||
+	    qedi_ep->state == EP_STATE_OFLDCONN_FAILED)
+		return -1;
+
+	if (qedi_ep->state == EP_STATE_OFLDCONN_COMPL)
+		ret = 1;
+
+	ret = wait_event_interruptible_timeout(qedi_ep->ofld_wait,
+					       QEDI_OFLD_WAIT_STATE(qedi_ep),
+					       msecs_to_jiffies(timeout_ms));
+
+	if (qedi_ep->state == EP_STATE_OFLDCONN_FAILED)
+		ret = -1;
+
+	if (ret > 0)
+		return 1;
+	else if (!ret)
+		return 0;
+	else
+		return ret;
+}
+
+static void qedi_cleanup_active_cmd_list(struct qedi_conn *qedi_conn)
+{
+	struct qedi_cmd *cmd, *cmd_tmp;
+
+	list_for_each_entry_safe(cmd, cmd_tmp, &qedi_conn->active_cmd_list,
+				 io_cmd) {
+		list_del_init(&cmd->io_cmd);
+		qedi_conn->active_cmd_count--;
+	}
+}
+
+static void qedi_ep_disconnect(struct iscsi_endpoint *ep)
+{
+	struct qedi_endpoint *qedi_ep;
+	struct qedi_conn *qedi_conn = NULL;
+	struct iscsi_conn *conn = NULL;
+	struct qedi_ctx *qedi;
+	int ret = 0;
+	int wait_delay = 20 * HZ;
+	int abrt_conn = 0;
+	int count = 10;
+
+	qedi_ep = ep->dd_data;
+	qedi = qedi_ep->qedi;
+
+	flush_work(&qedi_ep->offload_work);
+
+	if (qedi_ep->conn) {
+		qedi_conn = qedi_ep->conn;
+		conn = qedi_conn->cls_conn->dd_data;
+		iscsi_suspend_queue(conn);
+		abrt_conn = qedi_conn->abrt_conn;
+
+		while (count--)	{
+			if (!test_bit(QEDI_CONN_FW_CLEANUP,
+				      &qedi_conn->flags)) {
+				break;
+			}
+			msleep(1000);
+		}
+
+		if (test_bit(QEDI_IN_RECOVERY, &qedi->flags)) {
+			if (do_not_recover) {
+				QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+					  "Do not recover cid=0x%x\n",
+					  qedi_ep->iscsi_cid);
+				goto ep_exit_recover;
+			}
+			QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+				  "Reset recovery cid=0x%x, qedi_ep=%p, state=0x%x\n",
+				  qedi_ep->iscsi_cid, qedi_ep, qedi_ep->state);
+			qedi_cleanup_active_cmd_list(qedi_conn);
+			goto ep_release_conn;
+		}
+	}
+
+	if (do_not_recover)
+		goto ep_exit_recover;
+
+	switch (qedi_ep->state) {
+	case EP_STATE_OFLDCONN_START:
+		goto ep_release_conn;
+	case EP_STATE_OFLDCONN_FAILED:
+			break;
+	case EP_STATE_OFLDCONN_COMPL:
+		if (unlikely(!qedi_conn))
+			break;
+
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+			  "Active cmd count=%d, abrt_conn=%d, ep state=0x%x, cid=0x%x, qedi_conn=%p\n",
+			  qedi_conn->active_cmd_count, abrt_conn,
+			  qedi_ep->state,
+			  qedi_ep->iscsi_cid,
+			  qedi_ep->conn
+			  );
+
+		if (!qedi_conn->active_cmd_count)
+			abrt_conn = 0;
+		else
+			abrt_conn = 1;
+
+		if (abrt_conn)
+			qedi_clearsq(qedi, qedi_conn, NULL);
+		break;
+	default:
+		break;
+	}
+
+	qedi_ep->state = EP_STATE_DISCONN_START;
+	ret = qedi_ops->destroy_conn(qedi->cdev, qedi_ep->handle, abrt_conn);
+	if (ret) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "destroy_conn failed returned %d\n", ret);
+	} else {
+		ret = wait_event_interruptible_timeout(
+					qedi_ep->tcp_ofld_wait,
+					(qedi_ep->state !=
+					 EP_STATE_DISCONN_START),
+					wait_delay);
+		if ((ret <= 0) || (qedi_ep->state == EP_STATE_DISCONN_START)) {
+			QEDI_WARN(&qedi->dbg_ctx,
+				  "Destroy conn timedout or interrupted, ret=%d, delay=%d, cid=0x%x\n",
+				  ret, wait_delay, qedi_ep->iscsi_cid);
+		}
+	}
+
+ep_release_conn:
+	ret = qedi_ops->release_conn(qedi->cdev, qedi_ep->handle);
+	if (ret)
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "release_conn returned %d, cid=0x%x\n",
+			  ret, qedi_ep->iscsi_cid);
+ep_exit_recover:
+	qedi_ep->state = EP_STATE_IDLE;
+	qedi->ep_tbl[qedi_ep->iscsi_cid] = NULL;
+	qedi->cid_que.conn_cid_tbl[qedi_ep->iscsi_cid] = NULL;
+	qedi_free_id(&qedi->lcl_port_tbl, qedi_ep->src_port);
+	qedi_free_sq(qedi, qedi_ep);
+
+	if (qedi_conn)
+		qedi_conn->ep = NULL;
+
+	qedi_ep->conn = NULL;
+	qedi_ep->qedi = NULL;
+	atomic_dec(&qedi->num_offloads);
+
+	iscsi_destroy_endpoint(ep);
+}
+
+static int qedi_data_avail(struct qedi_ctx *qedi, u16 vlanid)
+{
+	struct qed_dev *cdev = qedi->cdev;
+	struct qedi_uio_dev *udev;
+	struct qedi_uio_ctrl *uctrl;
+	struct sk_buff *skb;
+	u32 len;
+	int rc = 0;
+
+	udev = qedi->udev;
+	if (!udev) {
+		QEDI_ERR(&qedi->dbg_ctx, "udev is NULL.\n");
+		return -EINVAL;
+	}
+
+	uctrl = (struct qedi_uio_ctrl *)udev->uctrl;
+	if (!uctrl) {
+		QEDI_ERR(&qedi->dbg_ctx, "uctlr is NULL.\n");
+		return -EINVAL;
+	}
+
+	len = uctrl->host_tx_pkt_len;
+	if (!len) {
+		QEDI_ERR(&qedi->dbg_ctx, "Invalid len %u\n", len);
+		return -EINVAL;
+	}
+
+	skb = alloc_skb(len, GFP_ATOMIC);
+	if (!skb) {
+		QEDI_ERR(&qedi->dbg_ctx, "alloc_skb failed\n");
+		return -EINVAL;
+	}
+
+	skb_put(skb, len);
+	memcpy(skb->data, udev->tx_pkt, len);
+	skb->ip_summed = CHECKSUM_NONE;
+
+	if (vlanid)
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlanid);
+
+	rc = qedi_ops->ll2->start_xmit(cdev, skb);
+	if (rc) {
+		QEDI_ERR(&qedi->dbg_ctx, "ll2 start_xmit returned %d\n",
+			 rc);
+		kfree_skb(skb);
+	}
+
+	uctrl->host_tx_pkt_len = 0;
+	uctrl->hw_tx_cons++;
+
+	return rc;
+}
+
+static void qedi_offload_work(struct work_struct *work)
+{
+	struct qedi_endpoint *qedi_ep =
+		container_of(work, struct qedi_endpoint, offload_work);
+	struct qedi_ctx *qedi;
+	int wait_delay = 20 * HZ;
+	int ret;
+
+	qedi = qedi_ep->qedi;
+
+	ret = qedi_iscsi_offload_conn(qedi_ep);
+	if (ret) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "offload error: iscsi_cid=%u, qedi_ep=%p, ret=%d\n",
+			 qedi_ep->iscsi_cid, qedi_ep, ret);
+		qedi_ep->state = EP_STATE_OFLDCONN_FAILED;
+		return;
+	}
+
+	ret = wait_event_interruptible_timeout(qedi_ep->tcp_ofld_wait,
+					       (qedi_ep->state ==
+					       EP_STATE_OFLDCONN_COMPL),
+					       wait_delay);
+	if ((ret <= 0) || (qedi_ep->state != EP_STATE_OFLDCONN_COMPL)) {
+		qedi_ep->state = EP_STATE_OFLDCONN_FAILED;
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Offload conn TIMEOUT iscsi_cid=%u, qedi_ep=%p\n",
+			 qedi_ep->iscsi_cid, qedi_ep);
+	}
+}
+
+static int qedi_set_path(struct Scsi_Host *shost, struct iscsi_path *path_data)
+{
+	struct qedi_ctx *qedi;
+	struct qedi_endpoint *qedi_ep;
+	int ret = 0;
+	u32 iscsi_cid;
+	u16 port_id = 0;
+
+	if (!shost) {
+		ret = -ENXIO;
+		QEDI_ERR(NULL, "shost is NULL\n");
+		return ret;
+	}
+
+	if (strcmp(shost->hostt->proc_name, "qedi")) {
+		ret = -ENXIO;
+		QEDI_ERR(NULL, "shost %s is invalid\n",
+			 shost->hostt->proc_name);
+		return ret;
+	}
+
+	qedi = iscsi_host_priv(shost);
+	if (path_data->handle == QEDI_PATH_HANDLE) {
+		ret = qedi_data_avail(qedi, path_data->vlan_id);
+		goto set_path_exit;
+	}
+
+	iscsi_cid = (u32)path_data->handle;
+	qedi_ep = qedi->ep_tbl[iscsi_cid];
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "iscsi_cid=0x%x, qedi_ep=%p\n", iscsi_cid, qedi_ep);
+
+	if (!is_valid_ether_addr(&path_data->mac_addr[0])) {
+		QEDI_NOTICE(&qedi->dbg_ctx, "dst mac NOT VALID\n");
+		ret = -EIO;
+		goto set_path_exit;
+	}
+
+	ether_addr_copy(&qedi_ep->src_mac[0], &qedi->mac[0]);
+	ether_addr_copy(&qedi_ep->dst_mac[0], &path_data->mac_addr[0]);
+
+	qedi_ep->vlan_id = path_data->vlan_id;
+	if (path_data->pmtu < DEF_PATH_MTU) {
+		qedi_ep->pmtu = qedi->ll2_mtu;
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO,
+			  "MTU cannot be %u, using default MTU %u\n",
+			   path_data->pmtu, qedi_ep->pmtu);
+	}
+
+	if (path_data->pmtu != qedi->ll2_mtu) {
+		if (path_data->pmtu > JUMBO_MTU) {
+			ret = -EINVAL;
+			QEDI_ERR(NULL, "Invalid MTU %u\n", path_data->pmtu);
+			goto set_path_exit;
+		}
+
+		qedi_reset_host_mtu(qedi, path_data->pmtu);
+		qedi_ep->pmtu = qedi->ll2_mtu;
+	}
+
+	port_id = qedi_ep->src_port;
+	if (port_id >= QEDI_LOCAL_PORT_MIN &&
+	    port_id < QEDI_LOCAL_PORT_MAX) {
+		if (qedi_alloc_id(&qedi->lcl_port_tbl, port_id))
+			port_id = 0;
+	} else {
+		port_id = 0;
+	}
+
+	if (!port_id) {
+		port_id = qedi_alloc_new_id(&qedi->lcl_port_tbl);
+		if (port_id == QEDI_LOCAL_PORT_INVALID) {
+			QEDI_ERR(&qedi->dbg_ctx,
+				 "Failed to allocate port id for iscsi_cid=0x%x\n",
+				 iscsi_cid);
+			ret = -ENOMEM;
+			goto set_path_exit;
+		}
+	}
+
+	qedi_ep->src_port = port_id;
+
+	if (qedi_ep->ip_type == TCP_IPV4) {
+		memcpy(&qedi_ep->src_addr[0], &path_data->src.v4_addr,
+		       sizeof(struct in_addr));
+		memcpy(&qedi->src_ip[0], &path_data->src.v4_addr,
+		       sizeof(struct in_addr));
+		qedi->ip_type = TCP_IPV4;
+
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "src addr:port=%pI4:%u, dst addr:port=%pI4:%u\n",
+			  qedi_ep->src_addr, qedi_ep->src_port,
+			  qedi_ep->dst_addr, qedi_ep->dst_port);
+	} else {
+		memcpy(&qedi_ep->src_addr[0], &path_data->src.v6_addr,
+		       sizeof(struct in6_addr));
+		memcpy(&qedi->src_ip[0], &path_data->src.v6_addr,
+		       sizeof(struct in6_addr));
+		qedi->ip_type = TCP_IPV6;
+
+		QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+			  "src addr:port=%pI6:%u, dst addr:port=%pI6:%u\n",
+			  qedi_ep->src_addr, qedi_ep->src_port,
+			  qedi_ep->dst_addr, qedi_ep->dst_port);
+	}
+
+	INIT_WORK(&qedi_ep->offload_work, qedi_offload_work);
+	queue_work(qedi->offload_thread, &qedi_ep->offload_work);
+
+	ret = 0;
+
+set_path_exit:
+	return ret;
+}
+
+static umode_t qedi_attr_is_visible(int param_type, int param)
+{
+	switch (param_type) {
+	case ISCSI_HOST_PARAM:
+		switch (param) {
+		case ISCSI_HOST_PARAM_NETDEV_NAME:
+		case ISCSI_HOST_PARAM_HWADDRESS:
+		case ISCSI_HOST_PARAM_IPADDRESS:
+			return S_IRUGO;
+		default:
+			return 0;
+		}
+	case ISCSI_PARAM:
+		switch (param) {
+		case ISCSI_PARAM_MAX_RECV_DLENGTH:
+		case ISCSI_PARAM_MAX_XMIT_DLENGTH:
+		case ISCSI_PARAM_HDRDGST_EN:
+		case ISCSI_PARAM_DATADGST_EN:
+		case ISCSI_PARAM_CONN_ADDRESS:
+		case ISCSI_PARAM_CONN_PORT:
+		case ISCSI_PARAM_EXP_STATSN:
+		case ISCSI_PARAM_PERSISTENT_ADDRESS:
+		case ISCSI_PARAM_PERSISTENT_PORT:
+		case ISCSI_PARAM_PING_TMO:
+		case ISCSI_PARAM_RECV_TMO:
+		case ISCSI_PARAM_INITIAL_R2T_EN:
+		case ISCSI_PARAM_MAX_R2T:
+		case ISCSI_PARAM_IMM_DATA_EN:
+		case ISCSI_PARAM_FIRST_BURST:
+		case ISCSI_PARAM_MAX_BURST:
+		case ISCSI_PARAM_PDU_INORDER_EN:
+		case ISCSI_PARAM_DATASEQ_INORDER_EN:
+		case ISCSI_PARAM_ERL:
+		case ISCSI_PARAM_TARGET_NAME:
+		case ISCSI_PARAM_TPGT:
+		case ISCSI_PARAM_USERNAME:
+		case ISCSI_PARAM_PASSWORD:
+		case ISCSI_PARAM_USERNAME_IN:
+		case ISCSI_PARAM_PASSWORD_IN:
+		case ISCSI_PARAM_FAST_ABORT:
+		case ISCSI_PARAM_ABORT_TMO:
+		case ISCSI_PARAM_LU_RESET_TMO:
+		case ISCSI_PARAM_TGT_RESET_TMO:
+		case ISCSI_PARAM_IFACE_NAME:
+		case ISCSI_PARAM_INITIATOR_NAME:
+		case ISCSI_PARAM_BOOT_ROOT:
+		case ISCSI_PARAM_BOOT_NIC:
+		case ISCSI_PARAM_BOOT_TARGET:
+			return S_IRUGO;
+		default:
+			return 0;
+		}
+	}
+
+	return 0;
+}
+
+static void qedi_cleanup_task(struct iscsi_task *task)
+{
+	if (!task->sc || task->state == ISCSI_TASK_PENDING) {
+		QEDI_INFO(NULL, QEDI_LOG_IO, "Returning ref_cnt=%d\n",
+			  atomic_read(&task->refcount));
+		return;
+	}
+
+	qedi_iscsi_unmap_sg_list(task->dd_data);
+}
+
+struct iscsi_transport qedi_iscsi_transport = {
+	.owner = THIS_MODULE,
+	.name = QEDI_MODULE_NAME,
+	.caps = CAP_RECOVERY_L0 | CAP_HDRDGST | CAP_MULTI_R2T | CAP_DATADGST |
+		CAP_DATA_PATH_OFFLOAD | CAP_TEXT_NEGO,
+	.create_session = qedi_session_create,
+	.destroy_session = qedi_session_destroy,
+	.create_conn = qedi_conn_create,
+	.bind_conn = qedi_conn_bind,
+	.start_conn = qedi_conn_start,
+	.stop_conn = iscsi_conn_stop,
+	.destroy_conn = qedi_conn_destroy,
+	.set_param = iscsi_set_param,
+	.get_ep_param = qedi_ep_get_param,
+	.get_conn_param = iscsi_conn_get_param,
+	.get_session_param = iscsi_session_get_param,
+	.get_host_param = qedi_host_get_param,
+	.send_pdu = iscsi_conn_send_pdu,
+	.get_stats = qedi_conn_get_stats,
+	.xmit_task = qedi_task_xmit,
+	.cleanup_task = qedi_cleanup_task,
+	.session_recovery_timedout = iscsi_session_recovery_timedout,
+	.ep_connect = qedi_ep_connect,
+	.ep_poll = qedi_ep_poll,
+	.ep_disconnect = qedi_ep_disconnect,
+	.set_path = qedi_set_path,
+	.attr_is_visible = qedi_attr_is_visible,
+};
+
+void qedi_start_conn_recovery(struct qedi_ctx *qedi,
+			      struct qedi_conn *qedi_conn)
+{
+	struct iscsi_cls_session *cls_sess;
+	struct iscsi_cls_conn *cls_conn;
+	struct iscsi_conn *conn;
+
+	cls_conn = qedi_conn->cls_conn;
+	conn = cls_conn->dd_data;
+	cls_sess = iscsi_conn_to_session(cls_conn);
+
+	if (iscsi_is_session_online(cls_sess)) {
+		qedi_conn->abrt_conn = 1;
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "Failing connection, state=0x%x, cid=0x%x\n",
+			 conn->session->state, qedi_conn->iscsi_conn_id);
+		iscsi_conn_failure(qedi_conn->cls_conn->dd_data,
+				   ISCSI_ERR_CONN_FAILED);
+	}
+}
+
+static const struct {
+	enum iscsi_error_types error_code;
+	char *err_string;
+} qedi_iscsi_error[] = {
+	{ ISCSI_STATUS_NONE,
+	  "tcp_error none"
+	},
+	{ ISCSI_CONN_ERROR_TASK_CID_MISMATCH,
+	  "task cid mismatch"
+	},
+	{ ISCSI_CONN_ERROR_TASK_NOT_VALID,
+	  "invalid task"
+	},
+	{ ISCSI_CONN_ERROR_RQ_RING_IS_FULL,
+	  "rq ring full"
+	},
+	{ ISCSI_CONN_ERROR_CMDQ_RING_IS_FULL,
+	  "cmdq ring full"
+	},
+	{ ISCSI_CONN_ERROR_HQE_CACHING_FAILED,
+	  "sge caching failed"
+	},
+	{ ISCSI_CONN_ERROR_HEADER_DIGEST_ERROR,
+	  "hdr digest error"
+	},
+	{ ISCSI_CONN_ERROR_LOCAL_COMPLETION_ERROR,
+	  "local cmpl error"
+	},
+	{ ISCSI_CONN_ERROR_DATA_OVERRUN,
+	  "invalid task"
+	},
+	{ ISCSI_CONN_ERROR_OUT_OF_SGES_ERROR,
+	  "out of sge error"
+	},
+	{ ISCSI_CONN_ERROR_TCP_SEG_PROC_IP_OPTIONS_ERROR,
+	  "tcp seg ip options error"
+	},
+	{ ISCSI_CONN_ERROR_TCP_IP_FRAGMENT_ERROR,
+	  "tcp ip fragment error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_AHS_LEN,
+	  "AHS len protocol error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_ITT_OUT_OF_RANGE,
+	  "itt out of range error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DATA_SEG_LEN_EXCEEDS_PDU_SIZE,
+	  "data seg more than pdu size"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_INVALID_OPCODE,
+	  "invalid opcode"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_INVALID_OPCODE_BEFORE_UPDATE,
+	  "invalid opcode before update"
+	},
+	{ ISCSI_CONN_ERROR_UNVALID_NOPIN_DSL,
+	  "unexpected opcode"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_R2T_CARRIES_NO_DATA,
+	  "r2t carries no data"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DATA_SN,
+	  "data sn error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DATA_IN_TTT,
+	  "data TTT error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_R2T_TTT,
+	  "r2t TTT error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_R2T_BUFFER_OFFSET,
+	  "buffer offset error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_BUFFER_OFFSET_OOO,
+	  "buffer offset ooo"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_R2T_SN,
+	  "data seg len 0"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DESIRED_DATA_TRNS_LEN_0,
+	  "data xer len error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DESIRED_DATA_TRNS_LEN_1,
+	  "data xer len1 error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DESIRED_DATA_TRNS_LEN_2,
+	  "data xer len2 error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_LUN,
+	  "protocol lun error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_F_BIT_ZERO,
+	  "f bit zero error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_EXP_STAT_SN,
+	  "exp stat sn error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DSL_NOT_ZERO,
+	  "dsl not zero error"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_INVALID_DSL,
+	  "invalid dsl"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_DATA_SEG_LEN_TOO_BIG,
+	  "data seg len too big"
+	},
+	{ ISCSI_CONN_ERROR_PROTOCOL_ERR_OUTSTANDING_R2T_COUNT,
+	  "outstanding r2t count error"
+	},
+	{ ISCSI_CONN_ERROR_SENSE_DATA_LENGTH,
+	  "sense datalen error"
+	},
+};
+
+char *qedi_get_iscsi_error(enum iscsi_error_types err_code)
+{
+	int i;
+	char *msg = NULL;
+
+	for (i = 0; i < ARRAY_SIZE(qedi_iscsi_error); i++) {
+		if (qedi_iscsi_error[i].error_code == err_code) {
+			msg = qedi_iscsi_error[i].err_string;
+			break;
+		}
+	}
+	return msg;
+}
+
+void qedi_process_iscsi_error(struct qedi_endpoint *ep, struct async_data *data)
+{
+	struct qedi_conn *qedi_conn;
+	struct qedi_ctx *qedi;
+	char warn_notice[] = "iscsi_warning";
+	char error_notice[] = "iscsi_error";
+	char unknown_msg[] = "Unknown error";
+	char *message;
+	int need_recovery = 0;
+	u32 err_mask = 0;
+	char *msg;
+
+	if (!ep)
+		return;
+
+	qedi_conn = ep->conn;
+	if (!qedi_conn)
+		return;
+
+	qedi = ep->qedi;
+
+	QEDI_ERR(&qedi->dbg_ctx, "async event iscsi error:0x%x\n",
+		 data->error_code);
+
+	if (err_mask) {
+		need_recovery = 0;
+		message = warn_notice;
+	} else {
+		need_recovery = 1;
+		message = error_notice;
+	}
+
+	msg = qedi_get_iscsi_error(data->error_code);
+	if (!msg) {
+		need_recovery = 0;
+		msg = unknown_msg;
+	}
+
+	iscsi_conn_printk(KERN_ALERT,
+			  qedi_conn->cls_conn->dd_data,
+			  "qedi: %s - %s\n", message, msg);
+
+	if (need_recovery)
+		qedi_start_conn_recovery(qedi_conn->qedi, qedi_conn);
+}
+
+void qedi_process_tcp_error(struct qedi_endpoint *ep, struct async_data *data)
+{
+	struct qedi_conn *qedi_conn;
+
+	if (!ep)
+		return;
+
+	qedi_conn = ep->conn;
+	if (!qedi_conn)
+		return;
+
+	QEDI_ERR(&ep->qedi->dbg_ctx, "async event TCP error:0x%x\n",
+		 data->error_code);
+
+	qedi_start_conn_recovery(qedi_conn->qedi, qedi_conn);
+}
diff --git a/drivers/scsi/qedi/qedi_iscsi.h b/drivers/scsi/qedi/qedi_iscsi.h
new file mode 100644
index 0000000..de7ab1f
--- /dev/null
+++ b/drivers/scsi/qedi/qedi_iscsi.h
@@ -0,0 +1,232 @@
+/*
+ * QLogic iSCSI Offload Driver
+ * Copyright (c) 2016 Cavium Inc.
+ *
+ * This software is available under the terms of the GNU General Public License
+ * (GPL) Version 2, available from the file COPYING in the main directory of
+ * this source tree.
+ */
+
+#ifndef _QEDI_ISCSI_H_
+#define _QEDI_ISCSI_H_
+
+#include <linux/socket.h>
+#include <linux/completion.h>
+#include "qedi.h"
+
+#define ISCSI_MAX_SESS_PER_HBA	4096
+
+#define DEF_KA_TIMEOUT		7200000
+#define DEF_KA_INTERVAL		10000
+#define DEF_KA_MAX_PROBE_COUNT	10
+#define DEF_TOS			0
+#define DEF_TTL			0xfe
+#define DEF_SND_SEQ_SCALE	0
+#define DEF_RCV_BUF		0xffff
+#define DEF_SND_BUF		0xffff
+#define DEF_SEED		0
+#define DEF_MAX_RT_TIME		8000
+#define DEF_MAX_DA_COUNT        2
+#define DEF_SWS_TIMER		1000
+#define DEF_MAX_CWND		2
+#define DEF_PATH_MTU		1500
+#define DEF_MSS			1460
+#define DEF_LL2_MTU		1560
+#define JUMBO_MTU		9000
+
+#define MIN_MTU         576 /* rfc 793 */
+#define IPV4_HDR_LEN    20
+#define IPV6_HDR_LEN    40
+#define TCP_HDR_LEN     20
+#define TCP_OPTION_LEN  12
+#define VLAN_LEN         4
+
+enum {
+	EP_STATE_IDLE                   = 0x0,
+	EP_STATE_ACQRCONN_START         = 0x1,
+	EP_STATE_ACQRCONN_COMPL         = 0x2,
+	EP_STATE_OFLDCONN_START         = 0x4,
+	EP_STATE_OFLDCONN_COMPL         = 0x8,
+	EP_STATE_DISCONN_START          = 0x10,
+	EP_STATE_DISCONN_COMPL          = 0x20,
+	EP_STATE_CLEANUP_START          = 0x40,
+	EP_STATE_CLEANUP_CMPL           = 0x80,
+	EP_STATE_TCP_FIN_RCVD           = 0x100,
+	EP_STATE_TCP_RST_RCVD           = 0x200,
+	EP_STATE_LOGOUT_SENT            = 0x400,
+	EP_STATE_LOGOUT_RESP_RCVD       = 0x800,
+	EP_STATE_CLEANUP_FAILED         = 0x1000,
+	EP_STATE_OFLDCONN_FAILED        = 0x2000,
+	EP_STATE_CONNECT_FAILED         = 0x4000,
+	EP_STATE_DISCONN_TIMEDOUT       = 0x8000,
+};
+
+struct qedi_conn;
+
+struct qedi_endpoint {
+	struct qedi_ctx *qedi;
+	u32 dst_addr[4];
+	u32 src_addr[4];
+	u16 src_port;
+	u16 dst_port;
+	u16 vlan_id;
+	u16 pmtu;
+	u8 src_mac[ETH_ALEN];
+	u8 dst_mac[ETH_ALEN];
+	u8 ip_type;
+	int state;
+	wait_queue_head_t ofld_wait;
+	wait_queue_head_t tcp_ofld_wait;
+	u32 iscsi_cid;
+	/* identifier of the connection from qed */
+	u32 handle;
+	u32 fw_cid;
+	void __iomem *p_doorbell;
+
+	/* Send queue management */
+	struct iscsi_wqe *sq;
+	dma_addr_t sq_dma;
+
+	u16 sq_prod_idx;
+	u16 fw_sq_prod_idx;
+	u16 sq_con_idx;
+	u32 sq_mem_size;
+
+	void *sq_pbl;
+	dma_addr_t sq_pbl_dma;
+	u32 sq_pbl_size;
+	struct qedi_conn *conn;
+	struct work_struct offload_work;
+};
+
+#define QEDI_SQ_WQES_MIN	16
+
+struct qedi_io_bdt {
+	struct iscsi_sge *sge_tbl;
+	dma_addr_t sge_tbl_dma;
+	u16 sge_valid;
+};
+
+/**
+ * struct generic_pdu_resc - login pdu resource structure
+ *
+ * @req_buf:            driver buffer used to stage payload associated with
+ *                      the login request
+ * @req_dma_addr:       dma address for iscsi login request payload buffer
+ * @req_buf_size:       actual login request payload length
+ * @req_wr_ptr:         pointer into login request buffer when next data is
+ *                      to be written
+ * @resp_hdr:           iscsi header where iscsi login response header is to
+ *                      be recreated
+ * @resp_buf:           buffer to stage login response payload
+ * @resp_dma_addr:      login response payload buffer dma address
+ * @resp_buf_size:      login response paylod length
+ * @resp_wr_ptr:        pointer into login response buffer when next data is
+ *                      to be written
+ * @req_bd_tbl:         iscsi login request payload BD table
+ * @req_bd_dma:         login request BD table dma address
+ * @resp_bd_tbl:        iscsi login response payload BD table
+ * @resp_bd_dma:        login request BD table dma address
+ *
+ * following structure defines buffer info for generic pdus such as iSCSI Login,
+ *      Logout and NOP
+ */
+struct generic_pdu_resc {
+	char *req_buf;
+	dma_addr_t req_dma_addr;
+	u32 req_buf_size;
+	char *req_wr_ptr;
+	struct iscsi_hdr resp_hdr;
+	char *resp_buf;
+	dma_addr_t resp_dma_addr;
+	u32 resp_buf_size;
+	char *resp_wr_ptr;
+	char *req_bd_tbl;
+	dma_addr_t req_bd_dma;
+	char *resp_bd_tbl;
+	dma_addr_t resp_bd_dma;
+};
+
+struct qedi_conn {
+	struct iscsi_cls_conn *cls_conn;
+	struct qedi_ctx *qedi;
+	struct qedi_endpoint *ep;
+	struct list_head active_cmd_list;
+	spinlock_t list_lock;		/* internal conn lock */
+	u32 active_cmd_count;
+	u32 cmd_cleanup_req;
+	u32 cmd_cleanup_cmpl;
+
+	u32 iscsi_conn_id;
+	int itt;
+	int abrt_conn;
+#define QEDI_CID_RESERVED	0x5AFF
+	u32 fw_cid;
+	/*
+	 * Buffer for login negotiation process
+	 */
+	struct generic_pdu_resc gen_pdu;
+
+	struct list_head tmf_work_list;
+	wait_queue_head_t wait_queue;
+	spinlock_t tmf_work_lock;	/* tmf work lock */
+	unsigned long flags;
+#define QEDI_CONN_FW_CLEANUP	1
+};
+
+struct qedi_cmd {
+	struct list_head io_cmd;
+	bool io_cmd_in_list;
+	struct iscsi_hdr hdr;
+	struct qedi_conn *conn;
+	struct scsi_cmnd *scsi_cmd;
+	struct scatterlist *sg;
+	struct qedi_io_bdt io_tbl;
+	struct iscsi_task_context request;
+	unsigned char *sense_buffer;
+	dma_addr_t sense_buffer_dma;
+	u16 task_id;
+
+	/* field populated for tmf work queue */
+	struct iscsi_task *task;
+	struct work_struct tmf_work;
+	int state;
+#define CLEANUP_WAIT	1
+#define CLEANUP_RECV	2
+#define CLEANUP_WAIT_FAILED	3
+#define CLEANUP_NOT_REQUIRED	4
+#define LUN_RESET_RESPONSE_RECEIVED	5
+#define RESPONSE_RECEIVED	6
+
+	int type;
+#define TYPEIO		1
+#define TYPERESET	2
+
+	struct qedi_work_map *list_tmf_work;
+	/* slowpath management */
+	bool use_slowpath;
+
+	struct iscsi_tm_rsp *tmf_resp_buf;
+	struct qedi_work cqe_work;
+};
+
+struct qedi_work_map {
+	struct list_head list;
+	struct qedi_cmd *qedi_cmd;
+	int rtid;
+
+	int state;
+#define QEDI_WORK_QUEUED	1
+#define QEDI_WORK_SCHEDULED	2
+#define QEDI_WORK_EXIT		3
+
+	struct work_struct *ptr_tmf_work;
+};
+
+#define qedi_set_itt(task_id, itt) ((u32)((task_id & 0xffff) | (itt << 16)))
+#define qedi_get_itt(cqe) (cqe.iscsi_hdr.cmd.itt >> 16)
+
+#define QEDI_OFLD_WAIT_STATE(q) ((q)->state == EP_STATE_OFLDCONN_FAILED || \
+				(q)->state == EP_STATE_OFLDCONN_COMPL)
+
+#endif /* _QEDI_ISCSI_H_ */
diff --git a/drivers/scsi/qedi/qedi_main.c b/drivers/scsi/qedi/qedi_main.c
index ef309c6..d3f47dd 100644
--- a/drivers/scsi/qedi/qedi_main.c
+++ b/drivers/scsi/qedi/qedi_main.c
@@ -27,6 +27,8 @@
 #include <scsi/scsi.h>
 
 #include "qedi.h"
+#include "qedi_gbl.h"
+#include "qedi_iscsi.h"
 
 static uint fw_debug;
 module_param(fw_debug, uint, S_IRUGO | S_IWUSR);
@@ -1416,6 +1418,141 @@ static int qedi_alloc_global_queues(struct qedi_ctx *qedi)
 	return status;
 }
 
+int qedi_alloc_sq(struct qedi_ctx *qedi, struct qedi_endpoint *ep)
+{
+	int rval = 0;
+	u32 *pbl;
+	dma_addr_t page;
+	int num_pages;
+
+	if (!ep)
+		return -EIO;
+
+	/* Calculate appropriate queue and PBL sizes */
+	ep->sq_mem_size = QEDI_SQ_SIZE * sizeof(struct iscsi_wqe);
+	ep->sq_mem_size += QEDI_PAGE_SIZE - 1;
+
+	ep->sq_pbl_size = (ep->sq_mem_size / QEDI_PAGE_SIZE) * sizeof(void *);
+	ep->sq_pbl_size = ep->sq_pbl_size + QEDI_PAGE_SIZE;
+
+	ep->sq = dma_alloc_coherent(&qedi->pdev->dev, ep->sq_mem_size,
+				    &ep->sq_dma, GFP_KERNEL);
+	if (!ep->sq) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "Could not allocate send queue.\n");
+		rval = -ENOMEM;
+		goto out;
+	}
+	memset(ep->sq, 0, ep->sq_mem_size);
+
+	ep->sq_pbl = dma_alloc_coherent(&qedi->pdev->dev, ep->sq_pbl_size,
+					&ep->sq_pbl_dma, GFP_KERNEL);
+	if (!ep->sq_pbl) {
+		QEDI_WARN(&qedi->dbg_ctx,
+			  "Could not allocate send queue PBL.\n");
+		rval = -ENOMEM;
+		goto out_free_sq;
+	}
+	memset(ep->sq_pbl, 0, ep->sq_pbl_size);
+
+	/* Create PBL */
+	num_pages = ep->sq_mem_size / QEDI_PAGE_SIZE;
+	page = ep->sq_dma;
+	pbl = (u32 *)ep->sq_pbl;
+
+	while (num_pages--) {
+		*pbl = (u32)page;
+		pbl++;
+		*pbl = (u32)((u64)page >> 32);
+		pbl++;
+		page += QEDI_PAGE_SIZE;
+	}
+
+	return rval;
+
+out_free_sq:
+	dma_free_coherent(&qedi->pdev->dev, ep->sq_mem_size, ep->sq,
+			  ep->sq_dma);
+out:
+	return rval;
+}
+
+void qedi_free_sq(struct qedi_ctx *qedi, struct qedi_endpoint *ep)
+{
+	if (ep->sq_pbl)
+		dma_free_coherent(&qedi->pdev->dev, ep->sq_pbl_size, ep->sq_pbl,
+				  ep->sq_pbl_dma);
+	if (ep->sq)
+		dma_free_coherent(&qedi->pdev->dev, ep->sq_mem_size, ep->sq,
+				  ep->sq_dma);
+}
+
+int qedi_get_task_idx(struct qedi_ctx *qedi)
+{
+	s16 tmp_idx;
+
+again:
+	tmp_idx = find_first_zero_bit(qedi->task_idx_map,
+				      MAX_ISCSI_TASK_ENTRIES);
+
+	if (tmp_idx >= MAX_ISCSI_TASK_ENTRIES) {
+		QEDI_ERR(&qedi->dbg_ctx, "FW task context pool is full.\n");
+		tmp_idx = -1;
+		goto err_idx;
+	}
+
+	if (test_and_set_bit(tmp_idx, qedi->task_idx_map))
+		goto again;
+
+err_idx:
+	return tmp_idx;
+}
+
+void qedi_clear_task_idx(struct qedi_ctx *qedi, int idx)
+{
+	if (!test_and_clear_bit(idx, qedi->task_idx_map)) {
+		QEDI_ERR(&qedi->dbg_ctx,
+			 "FW task context, already cleared, tid=0x%x\n", idx);
+		WARN_ON(1);
+	}
+}
+
+void qedi_update_itt_map(struct qedi_ctx *qedi, u32 tid, u32 proto_itt,
+			 struct qedi_cmd *cmd)
+{
+	qedi->itt_map[tid].itt = proto_itt;
+	qedi->itt_map[tid].p_cmd = cmd;
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "update itt map tid=0x%x, with proto itt=0x%x\n", tid,
+		  qedi->itt_map[tid].itt);
+}
+
+void qedi_get_task_tid(struct qedi_ctx *qedi, u32 itt, s16 *tid)
+{
+	u16 i;
+
+	for (i = 0; i < MAX_ISCSI_TASK_ENTRIES; i++) {
+		if (qedi->itt_map[i].itt == itt) {
+			*tid = i;
+			QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+				  "Ref itt=0x%x, found at tid=0x%x\n",
+				  itt, *tid);
+			return;
+		}
+	}
+
+	WARN_ON(1);
+}
+
+void qedi_get_proto_itt(struct qedi_ctx *qedi, u32 tid, u32 *proto_itt)
+{
+	*proto_itt = qedi->itt_map[tid].itt;
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_CONN,
+		  "Get itt map tid [0x%x with proto itt[0x%x]",
+		  tid, *proto_itt);
+}
+
 struct qedi_cmd *qedi_get_cmd_from_tid(struct qedi_ctx *qedi, u32 tid)
 {
 	struct qedi_cmd *cmd = NULL;
@@ -1554,6 +1691,26 @@ static int qedi_cpu_callback(struct notifier_block *nfb,
 	.notifier_call = qedi_cpu_callback,
 };
 
+void qedi_reset_host_mtu(struct qedi_ctx *qedi, u16 mtu)
+{
+	struct qed_ll2_params params;
+
+	qedi_recover_all_conns(qedi);
+
+	qedi_ops->ll2->stop(qedi->cdev);
+	qedi_ll2_free_skbs(qedi);
+
+	QEDI_INFO(&qedi->dbg_ctx, QEDI_LOG_INFO, "old MTU %u, new MTU %u\n",
+		  qedi->ll2_mtu, mtu);
+	memset(&params, 0, sizeof(params));
+	qedi->ll2_mtu = mtu;
+	params.mtu = qedi->ll2_mtu + IPV6_HDR_LEN + TCP_HDR_LEN;
+	params.drop_ttl0_packets = 0;
+	params.rx_vlan_stripping = 1;
+	ether_addr_copy(params.ll2_mac_address, qedi->dev_info.common.hw_mac);
+	qedi_ops->ll2->start(qedi->cdev, &params);
+}
+
 static void __qedi_remove(struct pci_dev *pdev, int mode)
 {
 	struct qedi_ctx *qedi = pci_get_drvdata(pdev);
@@ -1918,6 +2075,13 @@ static int __init qedi_init(void)
 	qedi_dbg_init("qedi");
 #endif
 
+	qedi_scsi_transport = iscsi_register_transport(&qedi_iscsi_transport);
+	if (!qedi_scsi_transport) {
+		QEDI_ERR(NULL, "Could not register qedi transport");
+		rc = -ENOMEM;
+		goto exit_qedi_init_1;
+	}
+
 	register_hotcpu_notifier(&qedi_cpu_notifier);
 
 	ret = pci_register_driver(&qedi_pci_driver);
@@ -1940,6 +2104,7 @@ static int __init qedi_init(void)
 	return rc;
 
 exit_qedi_init_2:
+	iscsi_unregister_transport(&qedi_iscsi_transport);
 exit_qedi_init_1:
 #ifdef CONFIG_DEBUG_FS
 	qedi_dbg_exit();
@@ -1958,6 +2123,7 @@ static void __exit qedi_cleanup(void)
 
 	pci_unregister_driver(&qedi_pci_driver);
 	unregister_hotcpu_notifier(&qedi_cpu_notifier);
+	iscsi_unregister_transport(&qedi_iscsi_transport);
 
 #ifdef CONFIG_DEBUG_FS
 	qedi_dbg_exit();
-- 
1.8.3.1

