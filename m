From: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH V5 for-next 16/21] RDMA/bnxt_re: Support poll_cq verb
Date: Fri, 10 Feb 2017 03:19:48 -0800
Message-ID: <1486725593-9872-17-git-send-email-selvin.xavier@broadcom.com>
References: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1486725593-9872-1-git-send-email-selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Enables the fastpath ib_poll_cq verb.

v2: Fixed sparse warnings
v3: Fixes endianness related warnings reported by sparse. Also, fixes
    smatch and checkpatch warnings
v5: Uses ETH_P_IBOE macro for RoCE ethertype

Signed-off-by: Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Signed-off-by: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/bnxt_re/ib_verbs.c | 522 ++++++++++++++++++++++++++++
 drivers/infiniband/hw/bnxt_re/ib_verbs.h |   1 +
 drivers/infiniband/hw/bnxt_re/main.c     |  22 +-
 drivers/infiniband/hw/bnxt_re/qplib_fp.c | 560 ++++++++++++++++++++++++++++++-
 drivers/infiniband/hw/bnxt_re/qplib_fp.h |   7 +-
 5 files changed, 1107 insertions(+), 5 deletions(-)

diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.c b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
index 54d85bc..33af2e3 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.c
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.c
@@ -2230,6 +2230,528 @@ struct ib_cq *bnxt_re_create_cq(struct ib_device *ibdev,
 	return ERR_PTR(rc);
 }
 
+static u8 __req_to_ib_wc_status(u8 qstatus)
+{
+	switch (qstatus) {
+	case CQ_REQ_STATUS_OK:
+		return IB_WC_SUCCESS;
+	case CQ_REQ_STATUS_BAD_RESPONSE_ERR:
+		return IB_WC_BAD_RESP_ERR;
+	case CQ_REQ_STATUS_LOCAL_LENGTH_ERR:
+		return IB_WC_LOC_LEN_ERR;
+	case CQ_REQ_STATUS_LOCAL_QP_OPERATION_ERR:
+		return IB_WC_LOC_QP_OP_ERR;
+	case CQ_REQ_STATUS_LOCAL_PROTECTION_ERR:
+		return IB_WC_LOC_PROT_ERR;
+	case CQ_REQ_STATUS_MEMORY_MGT_OPERATION_ERR:
+		return IB_WC_GENERAL_ERR;
+	case CQ_REQ_STATUS_REMOTE_INVALID_REQUEST_ERR:
+		return IB_WC_REM_INV_REQ_ERR;
+	case CQ_REQ_STATUS_REMOTE_ACCESS_ERR:
+		return IB_WC_REM_ACCESS_ERR;
+	case CQ_REQ_STATUS_REMOTE_OPERATION_ERR:
+		return IB_WC_REM_OP_ERR;
+	case CQ_REQ_STATUS_RNR_NAK_RETRY_CNT_ERR:
+		return IB_WC_RNR_RETRY_EXC_ERR;
+	case CQ_REQ_STATUS_TRANSPORT_RETRY_CNT_ERR:
+		return IB_WC_RETRY_EXC_ERR;
+	case CQ_REQ_STATUS_WORK_REQUEST_FLUSHED_ERR:
+		return IB_WC_WR_FLUSH_ERR;
+	default:
+		return IB_WC_GENERAL_ERR;
+	}
+	return 0;
+}
+
+static u8 __rawqp1_to_ib_wc_status(u8 qstatus)
+{
+	switch (qstatus) {
+	case CQ_RES_RAWETH_QP1_STATUS_OK:
+		return IB_WC_SUCCESS;
+	case CQ_RES_RAWETH_QP1_STATUS_LOCAL_ACCESS_ERROR:
+		return IB_WC_LOC_ACCESS_ERR;
+	case CQ_RES_RAWETH_QP1_STATUS_HW_LOCAL_LENGTH_ERR:
+		return IB_WC_LOC_LEN_ERR;
+	case CQ_RES_RAWETH_QP1_STATUS_LOCAL_PROTECTION_ERR:
+		return IB_WC_LOC_PROT_ERR;
+	case CQ_RES_RAWETH_QP1_STATUS_LOCAL_QP_OPERATION_ERR:
+		return IB_WC_LOC_QP_OP_ERR;
+	case CQ_RES_RAWETH_QP1_STATUS_MEMORY_MGT_OPERATION_ERR:
+		return IB_WC_GENERAL_ERR;
+	case CQ_RES_RAWETH_QP1_STATUS_WORK_REQUEST_FLUSHED_ERR:
+		return IB_WC_WR_FLUSH_ERR;
+	case CQ_RES_RAWETH_QP1_STATUS_HW_FLUSH_ERR:
+		return IB_WC_WR_FLUSH_ERR;
+	default:
+		return IB_WC_GENERAL_ERR;
+	}
+}
+
+static u8 __rc_to_ib_wc_status(u8 qstatus)
+{
+	switch (qstatus) {
+	case CQ_RES_RC_STATUS_OK:
+		return IB_WC_SUCCESS;
+	case CQ_RES_RC_STATUS_LOCAL_ACCESS_ERROR:
+		return IB_WC_LOC_ACCESS_ERR;
+	case CQ_RES_RC_STATUS_LOCAL_LENGTH_ERR:
+		return IB_WC_LOC_LEN_ERR;
+	case CQ_RES_RC_STATUS_LOCAL_PROTECTION_ERR:
+		return IB_WC_LOC_PROT_ERR;
+	case CQ_RES_RC_STATUS_LOCAL_QP_OPERATION_ERR:
+		return IB_WC_LOC_QP_OP_ERR;
+	case CQ_RES_RC_STATUS_MEMORY_MGT_OPERATION_ERR:
+		return IB_WC_GENERAL_ERR;
+	case CQ_RES_RC_STATUS_REMOTE_INVALID_REQUEST_ERR:
+		return IB_WC_REM_INV_REQ_ERR;
+	case CQ_RES_RC_STATUS_WORK_REQUEST_FLUSHED_ERR:
+		return IB_WC_WR_FLUSH_ERR;
+	case CQ_RES_RC_STATUS_HW_FLUSH_ERR:
+		return IB_WC_WR_FLUSH_ERR;
+	default:
+		return IB_WC_GENERAL_ERR;
+	}
+}
+
+static void bnxt_re_process_req_wc(struct ib_wc *wc, struct bnxt_qplib_cqe *cqe)
+{
+	switch (cqe->type) {
+	case BNXT_QPLIB_SWQE_TYPE_SEND:
+		wc->opcode = IB_WC_SEND;
+		break;
+	case BNXT_QPLIB_SWQE_TYPE_SEND_WITH_IMM:
+		wc->opcode = IB_WC_SEND;
+		wc->wc_flags |= IB_WC_WITH_IMM;
+		break;
+	case BNXT_QPLIB_SWQE_TYPE_SEND_WITH_INV:
+		wc->opcode = IB_WC_SEND;
+		wc->wc_flags |= IB_WC_WITH_INVALIDATE;
+		break;
+	case BNXT_QPLIB_SWQE_TYPE_RDMA_WRITE:
+		wc->opcode = IB_WC_RDMA_WRITE;
+		break;
+	case BNXT_QPLIB_SWQE_TYPE_RDMA_WRITE_WITH_IMM:
+		wc->opcode = IB_WC_RDMA_WRITE;
+		wc->wc_flags |= IB_WC_WITH_IMM;
+		break;
+	case BNXT_QPLIB_SWQE_TYPE_RDMA_READ:
+		wc->opcode = IB_WC_RDMA_READ;
+		break;
+	case BNXT_QPLIB_SWQE_TYPE_ATOMIC_CMP_AND_SWP:
+		wc->opcode = IB_WC_COMP_SWAP;
+		break;
+	case BNXT_QPLIB_SWQE_TYPE_ATOMIC_FETCH_AND_ADD:
+		wc->opcode = IB_WC_FETCH_ADD;
+		break;
+	case BNXT_QPLIB_SWQE_TYPE_LOCAL_INV:
+		wc->opcode = IB_WC_LOCAL_INV;
+		break;
+	case BNXT_QPLIB_SWQE_TYPE_REG_MR:
+		wc->opcode = IB_WC_REG_MR;
+		break;
+	default:
+		wc->opcode = IB_WC_SEND;
+		break;
+	}
+
+	wc->status = __req_to_ib_wc_status(cqe->status);
+}
+
+static int bnxt_re_check_packet_type(u16 raweth_qp1_flags,
+				     u16 raweth_qp1_flags2)
+{
+	bool is_udp = false, is_ipv6 = false, is_ipv4 = false;
+
+	/* raweth_qp1_flags Bit 9-6 indicates itype */
+	if ((raweth_qp1_flags & CQ_RES_RAWETH_QP1_RAWETH_QP1_FLAGS_ITYPE_ROCE)
+	    != CQ_RES_RAWETH_QP1_RAWETH_QP1_FLAGS_ITYPE_ROCE)
+		return -1;
+
+	if (raweth_qp1_flags2 &
+	    CQ_RES_RAWETH_QP1_RAWETH_QP1_FLAGS2_IP_CS_CALC &&
+	    raweth_qp1_flags2 &
+	    CQ_RES_RAWETH_QP1_RAWETH_QP1_FLAGS2_L4_CS_CALC) {
+		is_udp = true;
+		/* raweth_qp1_flags2 Bit 8 indicates ip_type. 0-v4 1 - v6 */
+		(raweth_qp1_flags2 &
+		 CQ_RES_RAWETH_QP1_RAWETH_QP1_FLAGS2_IP_TYPE) ?
+			(is_ipv6 = true) : (is_ipv4 = true);
+		return ((is_ipv6) ?
+			 BNXT_RE_ROCEV2_IPV6_PACKET :
+			 BNXT_RE_ROCEV2_IPV4_PACKET);
+	} else {
+		return BNXT_RE_ROCE_V1_PACKET;
+	}
+}
+
+static int bnxt_re_to_ib_nw_type(int nw_type)
+{
+	u8 nw_hdr_type = 0xFF;
+
+	switch (nw_type) {
+	case BNXT_RE_ROCE_V1_PACKET:
+		nw_hdr_type = RDMA_NETWORK_ROCE_V1;
+		break;
+	case BNXT_RE_ROCEV2_IPV4_PACKET:
+		nw_hdr_type = RDMA_NETWORK_IPV4;
+		break;
+	case BNXT_RE_ROCEV2_IPV6_PACKET:
+		nw_hdr_type = RDMA_NETWORK_IPV6;
+		break;
+	}
+	return nw_hdr_type;
+}
+
+static bool bnxt_re_is_loopback_packet(struct bnxt_re_dev *rdev,
+				       void *rq_hdr_buf)
+{
+	u8 *tmp_buf = NULL;
+	struct ethhdr *eth_hdr;
+	u16 eth_type;
+	bool rc = false;
+
+	tmp_buf = (u8 *)rq_hdr_buf;
+	/*
+	 * If dest mac is not same as I/F mac, this could be a
+	 * loopback address or multicast address, check whether
+	 * it is a loopback packet
+	 */
+	if (!ether_addr_equal(tmp_buf, rdev->netdev->dev_addr)) {
+		tmp_buf += 4;
+		/* Check the  ether type */
+		eth_hdr = (struct ethhdr *)tmp_buf;
+		eth_type = ntohs(eth_hdr->h_proto);
+		switch (eth_type) {
+		case ETH_P_IBOE:
+			rc = true;
+			break;
+		case ETH_P_IP:
+		case ETH_P_IPV6: {
+			u32 len;
+			struct udphdr *udp_hdr;
+
+			len = (eth_type == ETH_P_IP ? sizeof(struct iphdr) :
+						      sizeof(struct ipv6hdr));
+			tmp_buf += sizeof(struct ethhdr) + len;
+			udp_hdr = (struct udphdr *)tmp_buf;
+			if (ntohs(udp_hdr->dest) ==
+				    ROCE_V2_UDP_DPORT)
+				rc = true;
+			break;
+			}
+		default:
+			break;
+		}
+	}
+
+	return rc;
+}
+
+static int bnxt_re_process_raw_qp_pkt_rx(struct bnxt_re_qp *qp1_qp,
+					 struct bnxt_qplib_cqe *cqe)
+{
+	struct bnxt_re_dev *rdev = qp1_qp->rdev;
+	struct bnxt_re_sqp_entries *sqp_entry = NULL;
+	struct bnxt_re_qp *qp = rdev->qp1_sqp;
+	struct ib_send_wr *swr;
+	struct ib_ud_wr udwr;
+	struct ib_recv_wr rwr;
+	int pkt_type = 0;
+	u32 tbl_idx;
+	void *rq_hdr_buf;
+	dma_addr_t rq_hdr_buf_map;
+	dma_addr_t shrq_hdr_buf_map;
+	u32 offset = 0;
+	u32 skip_bytes = 0;
+	struct ib_sge s_sge[2];
+	struct ib_sge r_sge[2];
+	int rc;
+
+	memset(&udwr, 0, sizeof(udwr));
+	memset(&rwr, 0, sizeof(rwr));
+	memset(&s_sge, 0, sizeof(s_sge));
+	memset(&r_sge, 0, sizeof(r_sge));
+
+	swr = &udwr.wr;
+	tbl_idx = cqe->wr_id;
+
+	rq_hdr_buf = qp1_qp->qplib_qp.rq_hdr_buf +
+			(tbl_idx * qp1_qp->qplib_qp.rq_hdr_buf_size);
+	rq_hdr_buf_map = bnxt_qplib_get_qp_buf_from_index(&qp1_qp->qplib_qp,
+							  tbl_idx);
+
+	/* Shadow QP header buffer */
+	shrq_hdr_buf_map = bnxt_qplib_get_qp_buf_from_index(&qp->qplib_qp,
+							    tbl_idx);
+	sqp_entry = &rdev->sqp_tbl[tbl_idx];
+
+	/* Store this cqe */
+	memcpy(&sqp_entry->cqe, cqe, sizeof(struct bnxt_qplib_cqe));
+	sqp_entry->qp1_qp = qp1_qp;
+
+	/* Find packet type from the cqe */
+
+	pkt_type = bnxt_re_check_packet_type(cqe->raweth_qp1_flags,
+					     cqe->raweth_qp1_flags2);
+	if (pkt_type < 0) {
+		dev_err(rdev_to_dev(rdev), "Invalid packet\n");
+		return -EINVAL;
+	}
+
+	/* Adjust the offset for the user buffer and post in the rq */
+
+	if (pkt_type == BNXT_RE_ROCEV2_IPV4_PACKET)
+		offset = 20;
+
+	/*
+	 * QP1 loopback packet has 4 bytes of internal header before
+	 * ether header. Skip these four bytes.
+	 */
+	if (bnxt_re_is_loopback_packet(rdev, rq_hdr_buf))
+		skip_bytes = 4;
+
+	/* First send SGE . Skip the ether header*/
+	s_sge[0].addr = rq_hdr_buf_map + BNXT_QPLIB_MAX_QP1_RQ_ETH_HDR_SIZE
+			+ skip_bytes;
+	s_sge[0].lkey = 0xFFFFFFFF;
+	s_sge[0].length = offset ? BNXT_QPLIB_MAX_GRH_HDR_SIZE_IPV4 :
+				BNXT_QPLIB_MAX_GRH_HDR_SIZE_IPV6;
+
+	/* Second Send SGE */
+	s_sge[1].addr = s_sge[0].addr + s_sge[0].length +
+			BNXT_QPLIB_MAX_QP1_RQ_BDETH_HDR_SIZE;
+	if (pkt_type != BNXT_RE_ROCE_V1_PACKET)
+		s_sge[1].addr += 8;
+	s_sge[1].lkey = 0xFFFFFFFF;
+	s_sge[1].length = 256;
+
+	/* First recv SGE */
+
+	r_sge[0].addr = shrq_hdr_buf_map;
+	r_sge[0].lkey = 0xFFFFFFFF;
+	r_sge[0].length = 40;
+
+	r_sge[1].addr = sqp_entry->sge.addr + offset;
+	r_sge[1].lkey = sqp_entry->sge.lkey;
+	r_sge[1].length = BNXT_QPLIB_MAX_GRH_HDR_SIZE_IPV6 + 256 - offset;
+
+	/* Create receive work request */
+	rwr.num_sge = 2;
+	rwr.sg_list = r_sge;
+	rwr.wr_id = tbl_idx;
+	rwr.next = NULL;
+
+	rc = bnxt_re_post_recv_shadow_qp(rdev, qp, &rwr);
+	if (rc) {
+		dev_err(rdev_to_dev(rdev),
+			"Failed to post Rx buffers to shadow QP");
+		return -ENOMEM;
+	}
+
+	swr->num_sge = 2;
+	swr->sg_list = s_sge;
+	swr->wr_id = tbl_idx;
+	swr->opcode = IB_WR_SEND;
+	swr->next = NULL;
+
+	udwr.ah = &rdev->sqp_ah->ib_ah;
+	udwr.remote_qpn = rdev->qp1_sqp->qplib_qp.id;
+	udwr.remote_qkey = rdev->qp1_sqp->qplib_qp.qkey;
+
+	/* post data received  in the send queue */
+	rc = bnxt_re_post_send_shadow_qp(rdev, qp, swr);
+
+	return 0;
+}
+
+static void bnxt_re_process_res_rawqp1_wc(struct ib_wc *wc,
+					  struct bnxt_qplib_cqe *cqe)
+{
+	wc->opcode = IB_WC_RECV;
+	wc->status = __rawqp1_to_ib_wc_status(cqe->status);
+	wc->wc_flags |= IB_WC_GRH;
+}
+
+static void bnxt_re_process_res_rc_wc(struct ib_wc *wc,
+				      struct bnxt_qplib_cqe *cqe)
+{
+	wc->opcode = IB_WC_RECV;
+	wc->status = __rc_to_ib_wc_status(cqe->status);
+
+	if (cqe->flags & CQ_RES_RC_FLAGS_IMM)
+		wc->wc_flags |= IB_WC_WITH_IMM;
+	if (cqe->flags & CQ_RES_RC_FLAGS_INV)
+		wc->wc_flags |= IB_WC_WITH_INVALIDATE;
+	if ((cqe->flags & (CQ_RES_RC_FLAGS_RDMA | CQ_RES_RC_FLAGS_IMM)) ==
+	    (CQ_RES_RC_FLAGS_RDMA | CQ_RES_RC_FLAGS_IMM))
+		wc->opcode = IB_WC_RECV_RDMA_WITH_IMM;
+}
+
+static void bnxt_re_process_res_shadow_qp_wc(struct bnxt_re_qp *qp,
+					     struct ib_wc *wc,
+					     struct bnxt_qplib_cqe *cqe)
+{
+	u32 tbl_idx;
+	struct bnxt_re_dev *rdev = qp->rdev;
+	struct bnxt_re_qp *qp1_qp = NULL;
+	struct bnxt_qplib_cqe *orig_cqe = NULL;
+	struct bnxt_re_sqp_entries *sqp_entry = NULL;
+	int nw_type;
+
+	tbl_idx = cqe->wr_id;
+
+	sqp_entry = &rdev->sqp_tbl[tbl_idx];
+	qp1_qp = sqp_entry->qp1_qp;
+	orig_cqe = &sqp_entry->cqe;
+
+	wc->wr_id = sqp_entry->wrid;
+	wc->byte_len = orig_cqe->length;
+	wc->qp = &qp1_qp->ib_qp;
+
+	wc->ex.imm_data = orig_cqe->immdata;
+	wc->src_qp = orig_cqe->src_qp;
+	memcpy(wc->smac, orig_cqe->smac, ETH_ALEN);
+	wc->port_num = 1;
+	wc->vendor_err = orig_cqe->status;
+
+	wc->opcode = IB_WC_RECV;
+	wc->status = __rawqp1_to_ib_wc_status(orig_cqe->status);
+	wc->wc_flags |= IB_WC_GRH;
+
+	nw_type = bnxt_re_check_packet_type(orig_cqe->raweth_qp1_flags,
+					    orig_cqe->raweth_qp1_flags2);
+	if (nw_type >= 0) {
+		wc->network_hdr_type = bnxt_re_to_ib_nw_type(nw_type);
+		wc->wc_flags |= IB_WC_WITH_NETWORK_HDR_TYPE;
+	}
+}
+
+static void bnxt_re_process_res_ud_wc(struct ib_wc *wc,
+				      struct bnxt_qplib_cqe *cqe)
+{
+	wc->opcode = IB_WC_RECV;
+	wc->status = __rc_to_ib_wc_status(cqe->status);
+
+	if (cqe->flags & CQ_RES_RC_FLAGS_IMM)
+		wc->wc_flags |= IB_WC_WITH_IMM;
+	if (cqe->flags & CQ_RES_RC_FLAGS_INV)
+		wc->wc_flags |= IB_WC_WITH_INVALIDATE;
+	if ((cqe->flags & (CQ_RES_RC_FLAGS_RDMA | CQ_RES_RC_FLAGS_IMM)) ==
+	    (CQ_RES_RC_FLAGS_RDMA | CQ_RES_RC_FLAGS_IMM))
+		wc->opcode = IB_WC_RECV_RDMA_WITH_IMM;
+}
+
+int bnxt_re_poll_cq(struct ib_cq *ib_cq, int num_entries, struct ib_wc *wc)
+{
+	struct bnxt_re_cq *cq = container_of(ib_cq, struct bnxt_re_cq, ib_cq);
+	struct bnxt_re_qp *qp;
+	struct bnxt_qplib_cqe *cqe;
+	int i, ncqe, budget;
+	u32 tbl_idx;
+	struct bnxt_re_sqp_entries *sqp_entry = NULL;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cq->cq_lock, flags);
+	budget = min_t(u32, num_entries, cq->max_cql);
+	if (!cq->cql) {
+		dev_err(rdev_to_dev(cq->rdev), "POLL CQ : no CQL to use");
+		goto exit;
+	}
+	cqe = &cq->cql[0];
+	while (budget) {
+		ncqe = bnxt_qplib_poll_cq(&cq->qplib_cq, cqe, budget);
+		if (!ncqe)
+			break;
+
+		for (i = 0; i < ncqe; i++, cqe++) {
+			/* Transcribe each qplib_wqe back to ib_wc */
+			memset(wc, 0, sizeof(*wc));
+
+			wc->wr_id = cqe->wr_id;
+			wc->byte_len = cqe->length;
+			qp = container_of
+				((struct bnxt_qplib_qp *)
+				 (unsigned long)(cqe->qp_handle),
+				 struct bnxt_re_qp, qplib_qp);
+			if (!qp) {
+				dev_err(rdev_to_dev(cq->rdev),
+					"POLL CQ : bad QP handle");
+				continue;
+			}
+			wc->qp = &qp->ib_qp;
+			wc->ex.imm_data = cqe->immdata;
+			wc->src_qp = cqe->src_qp;
+			memcpy(wc->smac, cqe->smac, ETH_ALEN);
+			wc->port_num = 1;
+			wc->vendor_err = cqe->status;
+
+			switch (cqe->opcode) {
+			case CQ_BASE_CQE_TYPE_REQ:
+				if (qp->qplib_qp.id ==
+				    qp->rdev->qp1_sqp->qplib_qp.id) {
+					/* Handle this completion with
+					 * the stored completion
+					 */
+					memset(wc, 0, sizeof(*wc));
+					continue;
+				}
+				bnxt_re_process_req_wc(wc, cqe);
+				break;
+			case CQ_BASE_CQE_TYPE_RES_RAWETH_QP1:
+				if (!cqe->status) {
+					int rc = 0;
+
+					rc = bnxt_re_process_raw_qp_pkt_rx
+								(qp, cqe);
+					if (!rc) {
+						memset(wc, 0, sizeof(*wc));
+						continue;
+					}
+					cqe->status = -1;
+				}
+				/* Errors need not be looped back.
+				 * But change the wr_id to the one
+				 * stored in the table
+				 */
+				tbl_idx = cqe->wr_id;
+				sqp_entry = &cq->rdev->sqp_tbl[tbl_idx];
+				wc->wr_id = sqp_entry->wrid;
+				bnxt_re_process_res_rawqp1_wc(wc, cqe);
+				break;
+			case CQ_BASE_CQE_TYPE_RES_RC:
+				bnxt_re_process_res_rc_wc(wc, cqe);
+				break;
+			case CQ_BASE_CQE_TYPE_RES_UD:
+				if (qp->qplib_qp.id ==
+				    qp->rdev->qp1_sqp->qplib_qp.id) {
+					/* Handle this completion with
+					 * the stored completion
+					 */
+					if (cqe->status) {
+						continue;
+					} else {
+						bnxt_re_process_res_shadow_qp_wc
+								(qp, wc, cqe);
+						break;
+					}
+				}
+				bnxt_re_process_res_ud_wc(wc, cqe);
+				break;
+			default:
+				dev_err(rdev_to_dev(cq->rdev),
+					"POLL CQ : type 0x%x not handled",
+					cqe->opcode);
+				continue;
+			}
+			wc++;
+			budget--;
+		}
+	}
+exit:
+	spin_unlock_irqrestore(&cq->cq_lock, flags);
+	return num_entries - budget;
+}
+
 int bnxt_re_req_notify_cq(struct ib_cq *ib_cq,
 			  enum ib_cq_notify_flags ib_cqn_flags)
 {
diff --git a/drivers/infiniband/hw/bnxt_re/ib_verbs.h b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
index 839c25c..b4084c2 100644
--- a/drivers/infiniband/hw/bnxt_re/ib_verbs.h
+++ b/drivers/infiniband/hw/bnxt_re/ib_verbs.h
@@ -172,6 +172,7 @@ struct ib_cq *bnxt_re_create_cq(struct ib_device *ibdev,
 				struct ib_ucontext *context,
 				struct ib_udata *udata);
 int bnxt_re_destroy_cq(struct ib_cq *cq);
+int bnxt_re_poll_cq(struct ib_cq *cq, int num_entries, struct ib_wc *wc);
 int bnxt_re_req_notify_cq(struct ib_cq *cq, enum ib_cq_notify_flags flags);
 struct ib_mr *bnxt_re_get_dma_mr(struct ib_pd *pd, int mr_access_flags);
 
diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index 310addd..95dbbbe 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -463,6 +463,7 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 
 	ibdev->create_cq		= bnxt_re_create_cq;
 	ibdev->destroy_cq		= bnxt_re_destroy_cq;
+	ibdev->poll_cq			= bnxt_re_poll_cq;
 	ibdev->req_notify_cq		= bnxt_re_req_notify_cq;
 
 	ibdev->get_dma_mr		= bnxt_re_get_dma_mr;
@@ -597,6 +598,25 @@ static int bnxt_re_aeq_handler(struct bnxt_qplib_rcfw *rcfw,
 	return 0;
 }
 
+static int bnxt_re_cqn_handler(struct bnxt_qplib_nq *nq,
+			       struct bnxt_qplib_cq *handle)
+{
+	struct bnxt_re_cq *cq = container_of(handle, struct bnxt_re_cq,
+					     qplib_cq);
+
+	if (!cq) {
+		dev_err(NULL, "%s: CQ is NULL, CQN not handled",
+			ROCE_DRV_MODULE_NAME);
+		return -EINVAL;
+	}
+	if (cq->ib_cq.comp_handler) {
+		/* Lock comp_handler? */
+		(*cq->ib_cq.comp_handler)(&cq->ib_cq, cq->ib_cq.cq_context);
+	}
+
+	return 0;
+}
+
 static void bnxt_re_cleanup_res(struct bnxt_re_dev *rdev)
 {
 	if (rdev->nq.hwq.max_elements)
@@ -618,7 +638,7 @@ static int bnxt_re_init_res(struct bnxt_re_dev *rdev)
 	rc = bnxt_qplib_enable_nq(rdev->en_dev->pdev, &rdev->nq,
 				  rdev->msix_entries[BNXT_RE_NQ_IDX].vector,
 				  rdev->msix_entries[BNXT_RE_NQ_IDX].db_offset,
-				  NULL,
+				  &bnxt_re_cqn_handler,
 				  NULL);
 
 	if (rc)
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_fp.c b/drivers/infiniband/hw/bnxt_re/qplib_fp.c
index 3f5854c..43d08b5 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_fp.c
+++ b/drivers/infiniband/hw/bnxt_re/qplib_fp.c
@@ -211,7 +211,7 @@ void bnxt_qplib_disable_nq(struct bnxt_qplib_nq *nq)
 int bnxt_qplib_enable_nq(struct pci_dev *pdev, struct bnxt_qplib_nq *nq,
 			 int msix_vector, int bar_reg_offset,
 			 int (*cqn_handler)(struct bnxt_qplib_nq *nq,
-					    void *),
+					    struct bnxt_qplib_cq *),
 			 int (*srqn_handler)(struct bnxt_qplib_nq *nq,
 					     void *, u8 event))
 {
@@ -1597,6 +1597,564 @@ int bnxt_qplib_destroy_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq)
 	return 0;
 }
 
+static int __flush_sq(struct bnxt_qplib_q *sq, struct bnxt_qplib_qp *qp,
+		      struct bnxt_qplib_cqe **pcqe, int *budget)
+{
+	u32 sw_prod, sw_cons;
+	struct bnxt_qplib_cqe *cqe;
+	int rc = 0;
+
+	/* Now complete all outstanding SQEs with FLUSHED_ERR */
+	sw_prod = HWQ_CMP(sq->hwq.prod, &sq->hwq);
+	cqe = *pcqe;
+	while (*budget) {
+		sw_cons = HWQ_CMP(sq->hwq.cons, &sq->hwq);
+		if (sw_cons == sw_prod) {
+			sq->flush_in_progress = false;
+			break;
+		}
+		memset(cqe, 0, sizeof(*cqe));
+		cqe->status = CQ_REQ_STATUS_WORK_REQUEST_FLUSHED_ERR;
+		cqe->opcode = CQ_BASE_CQE_TYPE_REQ;
+		cqe->qp_handle = (u64)(unsigned long)qp;
+		cqe->wr_id = sq->swq[sw_cons].wr_id;
+		cqe->src_qp = qp->id;
+		cqe->type = sq->swq[sw_cons].type;
+		cqe++;
+		(*budget)--;
+		sq->hwq.cons++;
+	}
+	*pcqe = cqe;
+	if (!(*budget) && HWQ_CMP(sq->hwq.cons, &sq->hwq) != sw_prod)
+		/* Out of budget */
+		rc = -EAGAIN;
+
+	return rc;
+}
+
+static int __flush_rq(struct bnxt_qplib_q *rq, struct bnxt_qplib_qp *qp,
+		      int opcode, struct bnxt_qplib_cqe **pcqe, int *budget)
+{
+	struct bnxt_qplib_cqe *cqe;
+	u32 sw_prod, sw_cons;
+	int rc = 0;
+
+	/* Flush the rest of the RQ */
+	sw_prod = HWQ_CMP(rq->hwq.prod, &rq->hwq);
+	cqe = *pcqe;
+	while (*budget) {
+		sw_cons = HWQ_CMP(rq->hwq.cons, &rq->hwq);
+		if (sw_cons == sw_prod)
+			break;
+		memset(cqe, 0, sizeof(*cqe));
+		cqe->status =
+		    CQ_RES_RC_STATUS_WORK_REQUEST_FLUSHED_ERR;
+		cqe->opcode = opcode;
+		cqe->qp_handle = (unsigned long)qp;
+		cqe->wr_id = rq->swq[sw_cons].wr_id;
+		cqe++;
+		(*budget)--;
+		rq->hwq.cons++;
+	}
+	*pcqe = cqe;
+	if (!*budget && HWQ_CMP(rq->hwq.cons, &rq->hwq) != sw_prod)
+		/* Out of budget */
+		rc = -EAGAIN;
+
+	return rc;
+}
+
+static int bnxt_qplib_cq_process_req(struct bnxt_qplib_cq *cq,
+				     struct cq_req *hwcqe,
+				     struct bnxt_qplib_cqe **pcqe, int *budget)
+{
+	struct bnxt_qplib_qp *qp;
+	struct bnxt_qplib_q *sq;
+	struct bnxt_qplib_cqe *cqe;
+	u32 sw_cons, cqe_cons;
+	int rc = 0;
+
+	qp = (struct bnxt_qplib_qp *)((unsigned long)
+				      le64_to_cpu(hwcqe->qp_handle));
+	if (!qp) {
+		dev_err(&cq->hwq.pdev->dev,
+			"QPLIB: FP: Process Req qp is NULL");
+		return -EINVAL;
+	}
+	sq = &qp->sq;
+
+	cqe_cons = HWQ_CMP(le16_to_cpu(hwcqe->sq_cons_idx), &sq->hwq);
+	if (cqe_cons > sq->hwq.max_elements) {
+		dev_err(&cq->hwq.pdev->dev,
+			"QPLIB: FP: CQ Process req reported ");
+		dev_err(&cq->hwq.pdev->dev,
+			"QPLIB: sq_cons_idx 0x%x which exceeded max 0x%x",
+			cqe_cons, sq->hwq.max_elements);
+		return -EINVAL;
+	}
+	/* If we were in the middle of flushing the SQ, continue */
+	if (sq->flush_in_progress)
+		goto flush;
+
+	/* Require to walk the sq's swq to fabricate CQEs for all previously
+	 * signaled SWQEs due to CQE aggregation from the current sq cons
+	 * to the cqe_cons
+	 */
+	cqe = *pcqe;
+	while (*budget) {
+		sw_cons = HWQ_CMP(sq->hwq.cons, &sq->hwq);
+		if (sw_cons == cqe_cons)
+			break;
+		memset(cqe, 0, sizeof(*cqe));
+		cqe->opcode = CQ_BASE_CQE_TYPE_REQ;
+		cqe->qp_handle = (u64)(unsigned long)qp;
+		cqe->src_qp = qp->id;
+		cqe->wr_id = sq->swq[sw_cons].wr_id;
+		cqe->type = sq->swq[sw_cons].type;
+
+		/* For the last CQE, check for status.  For errors, regardless
+		 * of the request being signaled or not, it must complete with
+		 * the hwcqe error status
+		 */
+		if (HWQ_CMP((sw_cons + 1), &sq->hwq) == cqe_cons &&
+		    hwcqe->status != CQ_REQ_STATUS_OK) {
+			cqe->status = hwcqe->status;
+			dev_err(&cq->hwq.pdev->dev,
+				"QPLIB: FP: CQ Processed Req ");
+			dev_err(&cq->hwq.pdev->dev,
+				"QPLIB: wr_id[%d] = 0x%llx with status 0x%x",
+				sw_cons, cqe->wr_id, cqe->status);
+			cqe++;
+			(*budget)--;
+			sq->flush_in_progress = true;
+			/* Must block new posting of SQ and RQ */
+			qp->state = CMDQ_MODIFY_QP_NEW_STATE_ERR;
+		} else {
+			if (sq->swq[sw_cons].flags &
+			    SQ_SEND_FLAGS_SIGNAL_COMP) {
+				cqe->status = CQ_REQ_STATUS_OK;
+				cqe++;
+				(*budget)--;
+			}
+		}
+		sq->hwq.cons++;
+	}
+	*pcqe = cqe;
+	if (!*budget && HWQ_CMP(sq->hwq.cons, &sq->hwq) != cqe_cons) {
+		/* Out of budget */
+		rc = -EAGAIN;
+		goto done;
+	}
+	if (!sq->flush_in_progress)
+		goto done;
+flush:
+	/* Require to walk the sq's swq to fabricate CQEs for all
+	 * previously posted SWQEs due to the error CQE received
+	 */
+	rc = __flush_sq(sq, qp, pcqe, budget);
+	if (!rc)
+		sq->flush_in_progress = false;
+done:
+	return rc;
+}
+
+static int bnxt_qplib_cq_process_res_rc(struct bnxt_qplib_cq *cq,
+					struct cq_res_rc *hwcqe,
+					struct bnxt_qplib_cqe **pcqe,
+					int *budget)
+{
+	struct bnxt_qplib_qp *qp;
+	struct bnxt_qplib_q *rq;
+	struct bnxt_qplib_cqe *cqe;
+	u32 wr_id_idx;
+	int rc = 0;
+
+	qp = (struct bnxt_qplib_qp *)((unsigned long)
+				      le64_to_cpu(hwcqe->qp_handle));
+	if (!qp) {
+		dev_err(&cq->hwq.pdev->dev, "QPLIB: process_cq RC qp is NULL");
+		return -EINVAL;
+	}
+	cqe = *pcqe;
+	cqe->opcode = hwcqe->cqe_type_toggle & CQ_BASE_CQE_TYPE_MASK;
+	cqe->length = le32_to_cpu(hwcqe->length);
+	cqe->invrkey = le32_to_cpu(hwcqe->imm_data_or_inv_r_key);
+	cqe->mr_handle = le64_to_cpu(hwcqe->mr_handle);
+	cqe->flags = le16_to_cpu(hwcqe->flags);
+	cqe->status = hwcqe->status;
+	cqe->qp_handle = (u64)(unsigned long)qp;
+
+	wr_id_idx = le32_to_cpu(hwcqe->srq_or_rq_wr_id) &
+				CQ_RES_RC_SRQ_OR_RQ_WR_ID_MASK;
+	rq = &qp->rq;
+	if (wr_id_idx > rq->hwq.max_elements) {
+		dev_err(&cq->hwq.pdev->dev, "QPLIB: FP: CQ Process RC ");
+		dev_err(&cq->hwq.pdev->dev,
+			"QPLIB: wr_id idx 0x%x exceeded RQ max 0x%x",
+			wr_id_idx, rq->hwq.max_elements);
+		return -EINVAL;
+	}
+	if (rq->flush_in_progress)
+		goto flush_rq;
+
+	cqe->wr_id = rq->swq[wr_id_idx].wr_id;
+	cqe++;
+	(*budget)--;
+	rq->hwq.cons++;
+	*pcqe = cqe;
+
+	if (hwcqe->status != CQ_RES_RC_STATUS_OK) {
+		rq->flush_in_progress = true;
+flush_rq:
+		rc = __flush_rq(rq, qp, CQ_BASE_CQE_TYPE_RES_RC, pcqe, budget);
+		if (!rc)
+			rq->flush_in_progress = false;
+	}
+	return rc;
+}
+
+static int bnxt_qplib_cq_process_res_ud(struct bnxt_qplib_cq *cq,
+					struct cq_res_ud *hwcqe,
+					struct bnxt_qplib_cqe **pcqe,
+					int *budget)
+{
+	struct bnxt_qplib_qp *qp;
+	struct bnxt_qplib_q *rq;
+	struct bnxt_qplib_cqe *cqe;
+	u32 wr_id_idx;
+	int rc = 0;
+
+	qp = (struct bnxt_qplib_qp *)((unsigned long)
+				      le64_to_cpu(hwcqe->qp_handle));
+	if (!qp) {
+		dev_err(&cq->hwq.pdev->dev, "QPLIB: process_cq UD qp is NULL");
+		return -EINVAL;
+	}
+	cqe = *pcqe;
+	cqe->opcode = hwcqe->cqe_type_toggle & CQ_BASE_CQE_TYPE_MASK;
+	cqe->length = le32_to_cpu(hwcqe->length);
+	cqe->invrkey = le32_to_cpu(hwcqe->imm_data);
+	cqe->flags = le16_to_cpu(hwcqe->flags);
+	cqe->status = hwcqe->status;
+	cqe->qp_handle = (u64)(unsigned long)qp;
+	memcpy(cqe->smac, hwcqe->src_mac, 6);
+	wr_id_idx = le32_to_cpu(hwcqe->src_qp_high_srq_or_rq_wr_id)
+				& CQ_RES_UD_SRQ_OR_RQ_WR_ID_MASK;
+	cqe->src_qp = le16_to_cpu(hwcqe->src_qp_low) |
+				  ((le32_to_cpu(
+				  hwcqe->src_qp_high_srq_or_rq_wr_id) &
+				 CQ_RES_UD_SRC_QP_HIGH_MASK) >> 8);
+
+	rq = &qp->rq;
+	if (wr_id_idx > rq->hwq.max_elements) {
+		dev_err(&cq->hwq.pdev->dev, "QPLIB: FP: CQ Process UD ");
+		dev_err(&cq->hwq.pdev->dev,
+			"QPLIB: wr_id idx %#x exceeded RQ max %#x",
+			wr_id_idx, rq->hwq.max_elements);
+		return -EINVAL;
+	}
+	if (rq->flush_in_progress)
+		goto flush_rq;
+
+	cqe->wr_id = rq->swq[wr_id_idx].wr_id;
+	cqe++;
+	(*budget)--;
+	rq->hwq.cons++;
+	*pcqe = cqe;
+
+	if (hwcqe->status != CQ_RES_RC_STATUS_OK) {
+		rq->flush_in_progress = true;
+flush_rq:
+		rc = __flush_rq(rq, qp, CQ_BASE_CQE_TYPE_RES_UD, pcqe, budget);
+		if (!rc)
+			rq->flush_in_progress = false;
+	}
+	return rc;
+}
+
+static int bnxt_qplib_cq_process_res_raweth_qp1(struct bnxt_qplib_cq *cq,
+						struct cq_res_raweth_qp1 *hwcqe,
+						struct bnxt_qplib_cqe **pcqe,
+						int *budget)
+{
+	struct bnxt_qplib_qp *qp;
+	struct bnxt_qplib_q *rq;
+	struct bnxt_qplib_cqe *cqe;
+	u32 wr_id_idx;
+	int rc = 0;
+
+	qp = (struct bnxt_qplib_qp *)((unsigned long)
+				      le64_to_cpu(hwcqe->qp_handle));
+	if (!qp) {
+		dev_err(&cq->hwq.pdev->dev,
+			"QPLIB: process_cq Raw/QP1 qp is NULL");
+		return -EINVAL;
+	}
+	cqe = *pcqe;
+	cqe->opcode = hwcqe->cqe_type_toggle & CQ_BASE_CQE_TYPE_MASK;
+	cqe->flags = le16_to_cpu(hwcqe->flags);
+	cqe->qp_handle = (u64)(unsigned long)qp;
+
+	wr_id_idx =
+		le32_to_cpu(hwcqe->raweth_qp1_payload_offset_srq_or_rq_wr_id)
+				& CQ_RES_RAWETH_QP1_SRQ_OR_RQ_WR_ID_MASK;
+	cqe->src_qp = qp->id;
+	if (qp->id == 1 && !cqe->length) {
+		/* Add workaround for the length misdetection */
+		cqe->length = 296;
+	} else {
+		cqe->length = le16_to_cpu(hwcqe->length);
+	}
+	cqe->pkey_index = qp->pkey_index;
+	memcpy(cqe->smac, qp->smac, 6);
+
+	cqe->raweth_qp1_flags = le16_to_cpu(hwcqe->raweth_qp1_flags);
+	cqe->raweth_qp1_flags2 = le32_to_cpu(hwcqe->raweth_qp1_flags2);
+
+	rq = &qp->rq;
+	if (wr_id_idx > rq->hwq.max_elements) {
+		dev_err(&cq->hwq.pdev->dev, "QPLIB: FP: CQ Process Raw/QP1 RQ wr_id ");
+		dev_err(&cq->hwq.pdev->dev, "QPLIB: ix 0x%x exceeded RQ max 0x%x",
+			wr_id_idx, rq->hwq.max_elements);
+		return -EINVAL;
+	}
+	if (rq->flush_in_progress)
+		goto flush_rq;
+
+	cqe->wr_id = rq->swq[wr_id_idx].wr_id;
+	cqe++;
+	(*budget)--;
+	rq->hwq.cons++;
+	*pcqe = cqe;
+
+	if (hwcqe->status != CQ_RES_RC_STATUS_OK) {
+		rq->flush_in_progress = true;
+flush_rq:
+		rc = __flush_rq(rq, qp, CQ_BASE_CQE_TYPE_RES_RAWETH_QP1, pcqe,
+				budget);
+		if (!rc)
+			rq->flush_in_progress = false;
+	}
+	return rc;
+}
+
+static int bnxt_qplib_cq_process_terminal(struct bnxt_qplib_cq *cq,
+					  struct cq_terminal *hwcqe,
+					  struct bnxt_qplib_cqe **pcqe,
+					  int *budget)
+{
+	struct bnxt_qplib_qp *qp;
+	struct bnxt_qplib_q *sq, *rq;
+	struct bnxt_qplib_cqe *cqe;
+	u32 sw_cons = 0, cqe_cons;
+	int rc = 0;
+	u8 opcode = 0;
+
+	/* Check the Status */
+	if (hwcqe->status != CQ_TERMINAL_STATUS_OK)
+		dev_warn(&cq->hwq.pdev->dev,
+			 "QPLIB: FP: CQ Process Terminal Error status = 0x%x",
+			 hwcqe->status);
+
+	qp = (struct bnxt_qplib_qp *)((unsigned long)
+				      le64_to_cpu(hwcqe->qp_handle));
+	if (!qp) {
+		dev_err(&cq->hwq.pdev->dev,
+			"QPLIB: FP: CQ Process terminal qp is NULL");
+		return -EINVAL;
+	}
+	/* Must block new posting of SQ and RQ */
+	qp->state = CMDQ_MODIFY_QP_NEW_STATE_ERR;
+
+	sq = &qp->sq;
+	rq = &qp->rq;
+
+	cqe_cons = le16_to_cpu(hwcqe->sq_cons_idx);
+	if (cqe_cons == 0xFFFF)
+		goto do_rq;
+
+	if (cqe_cons > sq->hwq.max_elements) {
+		dev_err(&cq->hwq.pdev->dev,
+			"QPLIB: FP: CQ Process terminal reported ");
+		dev_err(&cq->hwq.pdev->dev,
+			"QPLIB: sq_cons_idx 0x%x which exceeded max 0x%x",
+			cqe_cons, sq->hwq.max_elements);
+		goto do_rq;
+	}
+	/* If we were in the middle of flushing, continue */
+	if (sq->flush_in_progress)
+		goto flush_sq;
+
+	/* Terminal CQE can also include aggregated successful CQEs prior.
+	 * So we must complete all CQEs from the current sq's cons to the
+	 * cq_cons with status OK
+	 */
+	cqe = *pcqe;
+	while (*budget) {
+		sw_cons = HWQ_CMP(sq->hwq.cons, &sq->hwq);
+		if (sw_cons == cqe_cons)
+			break;
+		if (sq->swq[sw_cons].flags & SQ_SEND_FLAGS_SIGNAL_COMP) {
+			memset(cqe, 0, sizeof(*cqe));
+			cqe->status = CQ_REQ_STATUS_OK;
+			cqe->opcode = CQ_BASE_CQE_TYPE_REQ;
+			cqe->qp_handle = (u64)(unsigned long)qp;
+			cqe->src_qp = qp->id;
+			cqe->wr_id = sq->swq[sw_cons].wr_id;
+			cqe->type = sq->swq[sw_cons].type;
+			cqe++;
+			(*budget)--;
+		}
+		sq->hwq.cons++;
+	}
+	*pcqe = cqe;
+	if (!(*budget) && sw_cons != cqe_cons) {
+		/* Out of budget */
+		rc = -EAGAIN;
+		goto sq_done;
+	}
+	sq->flush_in_progress = true;
+flush_sq:
+	rc = __flush_sq(sq, qp, pcqe, budget);
+	if (!rc)
+		sq->flush_in_progress = false;
+sq_done:
+	if (rc)
+		return rc;
+do_rq:
+	cqe_cons = le16_to_cpu(hwcqe->rq_cons_idx);
+	if (cqe_cons == 0xFFFF) {
+		goto done;
+	} else if (cqe_cons > rq->hwq.max_elements) {
+		dev_err(&cq->hwq.pdev->dev,
+			"QPLIB: FP: CQ Processed terminal ");
+		dev_err(&cq->hwq.pdev->dev,
+			"QPLIB: reported rq_cons_idx 0x%x exceeds max 0x%x",
+			cqe_cons, rq->hwq.max_elements);
+		goto done;
+	}
+	/* Terminal CQE requires all posted RQEs to complete with FLUSHED_ERR
+	 * from the current rq->cons to the rq->prod regardless what the
+	 * rq->cons the terminal CQE indicates
+	 */
+	rq->flush_in_progress = true;
+	switch (qp->type) {
+	case CMDQ_CREATE_QP1_TYPE_GSI:
+		opcode = CQ_BASE_CQE_TYPE_RES_RAWETH_QP1;
+		break;
+	case CMDQ_CREATE_QP_TYPE_RC:
+		opcode = CQ_BASE_CQE_TYPE_RES_RC;
+		break;
+	case CMDQ_CREATE_QP_TYPE_UD:
+		opcode = CQ_BASE_CQE_TYPE_RES_UD;
+		break;
+	}
+
+	rc = __flush_rq(rq, qp, opcode, pcqe, budget);
+	if (!rc)
+		rq->flush_in_progress = false;
+done:
+	return rc;
+}
+
+static int bnxt_qplib_cq_process_cutoff(struct bnxt_qplib_cq *cq,
+					struct cq_cutoff *hwcqe)
+{
+	/* Check the Status */
+	if (hwcqe->status != CQ_CUTOFF_STATUS_OK) {
+		dev_err(&cq->hwq.pdev->dev,
+			"QPLIB: FP: CQ Process Cutoff Error status = 0x%x",
+			hwcqe->status);
+		return -EINVAL;
+	}
+	clear_bit(CQ_FLAGS_RESIZE_IN_PROG, &cq->flags);
+	wake_up_interruptible(&cq->waitq);
+
+	return 0;
+}
+
+int bnxt_qplib_poll_cq(struct bnxt_qplib_cq *cq, struct bnxt_qplib_cqe *cqe,
+		       int num_cqes)
+{
+	struct cq_base *hw_cqe, **hw_cqe_ptr;
+	unsigned long flags;
+	u32 sw_cons, raw_cons;
+	int budget, rc = 0;
+
+	spin_lock_irqsave(&cq->hwq.lock, flags);
+	raw_cons = cq->hwq.cons;
+	budget = num_cqes;
+
+	while (budget) {
+		sw_cons = HWQ_CMP(raw_cons, &cq->hwq);
+		hw_cqe_ptr = (struct cq_base **)cq->hwq.pbl_ptr;
+		hw_cqe = &hw_cqe_ptr[CQE_PG(sw_cons)][CQE_IDX(sw_cons)];
+
+		/* Check for Valid bit */
+		if (!CQE_CMP_VALID(hw_cqe, raw_cons, cq->hwq.max_elements))
+			break;
+
+		/* From the device's respective CQE format to qplib_wc*/
+		switch (hw_cqe->cqe_type_toggle & CQ_BASE_CQE_TYPE_MASK) {
+		case CQ_BASE_CQE_TYPE_REQ:
+			rc = bnxt_qplib_cq_process_req(cq,
+						       (struct cq_req *)hw_cqe,
+						       &cqe, &budget);
+			break;
+		case CQ_BASE_CQE_TYPE_RES_RC:
+			rc = bnxt_qplib_cq_process_res_rc(cq,
+							  (struct cq_res_rc *)
+							  hw_cqe, &cqe,
+							  &budget);
+			break;
+		case CQ_BASE_CQE_TYPE_RES_UD:
+			rc = bnxt_qplib_cq_process_res_ud
+					(cq, (struct cq_res_ud *)hw_cqe, &cqe,
+					 &budget);
+			break;
+		case CQ_BASE_CQE_TYPE_RES_RAWETH_QP1:
+			rc = bnxt_qplib_cq_process_res_raweth_qp1
+					(cq, (struct cq_res_raweth_qp1 *)
+					 hw_cqe, &cqe, &budget);
+			break;
+		case CQ_BASE_CQE_TYPE_TERMINAL:
+			rc = bnxt_qplib_cq_process_terminal
+					(cq, (struct cq_terminal *)hw_cqe,
+					 &cqe, &budget);
+			break;
+		case CQ_BASE_CQE_TYPE_CUT_OFF:
+			bnxt_qplib_cq_process_cutoff
+					(cq, (struct cq_cutoff *)hw_cqe);
+			/* Done processing this CQ */
+			goto exit;
+		default:
+			dev_err(&cq->hwq.pdev->dev,
+				"QPLIB: process_cq unknown type 0x%lx",
+				hw_cqe->cqe_type_toggle &
+				CQ_BASE_CQE_TYPE_MASK);
+			rc = -EINVAL;
+			break;
+		}
+		if (rc < 0) {
+			if (rc == -EAGAIN)
+				break;
+			/* Error while processing the CQE, just skip to the
+			 * next one
+			 */
+			dev_err(&cq->hwq.pdev->dev,
+				"QPLIB: process_cqe error rc = 0x%x", rc);
+		}
+		raw_cons++;
+	}
+	if (cq->hwq.cons != raw_cons) {
+		cq->hwq.cons = raw_cons;
+		bnxt_qplib_arm_cq(cq, DBR_DBR_TYPE_CQ);
+	}
+exit:
+	spin_unlock_irqrestore(&cq->hwq.lock, flags);
+	return num_cqes - budget;
+}
+
 void bnxt_qplib_req_notify_cq(struct bnxt_qplib_cq *cq, u32 arm_type)
 {
 	unsigned long flags;
diff --git a/drivers/infiniband/hw/bnxt_re/qplib_fp.h b/drivers/infiniband/hw/bnxt_re/qplib_fp.h
index 5dcdd9d..f0150f8 100644
--- a/drivers/infiniband/hw/bnxt_re/qplib_fp.h
+++ b/drivers/infiniband/hw/bnxt_re/qplib_fp.h
@@ -396,7 +396,7 @@ struct bnxt_qplib_nq {
 
 	int				(*cqn_handler)
 						(struct bnxt_qplib_nq *nq,
-						 void *cq);
+						 struct bnxt_qplib_cq *cq);
 	int				(*srqn_handler)
 						(struct bnxt_qplib_nq *nq,
 						 void *srq,
@@ -407,7 +407,7 @@ void bnxt_qplib_disable_nq(struct bnxt_qplib_nq *nq);
 int bnxt_qplib_enable_nq(struct pci_dev *pdev, struct bnxt_qplib_nq *nq,
 			 int msix_vector, int bar_reg_offset,
 			 int (*cqn_handler)(struct bnxt_qplib_nq *nq,
-					    void *cq),
+					    struct bnxt_qplib_cq *cq),
 			 int (*srqn_handler)(struct bnxt_qplib_nq *nq,
 					     void *srq,
 					     u8 event));
@@ -431,7 +431,8 @@ int bnxt_qplib_post_recv(struct bnxt_qplib_qp *qp,
 			 struct bnxt_qplib_swqe *wqe);
 int bnxt_qplib_create_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq);
 int bnxt_qplib_destroy_cq(struct bnxt_qplib_res *res, struct bnxt_qplib_cq *cq);
-
+int bnxt_qplib_poll_cq(struct bnxt_qplib_cq *cq, struct bnxt_qplib_cqe *cqe,
+		       int num);
 void bnxt_qplib_req_notify_cq(struct bnxt_qplib_cq *cq, u32 arm_type);
 void bnxt_qplib_free_nq(struct bnxt_qplib_nq *nq);
 int bnxt_qplib_alloc_nq(struct pci_dev *pdev, struct bnxt_qplib_nq *nq);
-- 
2.5.5

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
