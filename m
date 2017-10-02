From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH net-next 08/12] qed: Add mpa buffer descriptors for storing and processing mpa fpdus
Date: Mon, 2 Oct 2017 11:23:54 +0300
Message-ID: <1506932638-26268-9-git-send-email-Michal.Kalderon@cavium.com>
References: <1506932638-26268-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        "Ariel Elior" <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0041.outbound.protection.outlook.com ([104.47.32.41]:23456
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750962AbdJBIZW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 04:25:22 -0400
In-Reply-To: <1506932638-26268-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mpa buff is a descriptor for iwarp ll2 buffers that contains
additional information required for aligining fpdu's.
In some cases, an additional packet will arrive which will complete
the alignment of a fpdu, but we won't be able to post the fpdu due to
insufficient place on the tx ring. In this case we can't loose the data
and require storing it for later. Processing is therefore done
in two places, during rx completion, where we initialize a mpa buffer
descriptor and add it to the pending list, and during tx-completion, since
we free up an entry in the tx chain we can process any pending mpa packets.
The mpa buff descriptors are pre-allocated since we have to ensure that
we won't reach a state where we can't store an incoming unaligned packet.
All packets received on the ll2 MUST be processed by the driver at some
stage. Since they are preallocated, we hold a free list.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c | 116 ++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_iwarp.h |  11 +++
 2 files changed, 127 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
index f413621..efd4861 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
@@ -1415,7 +1415,10 @@ int qed_iwarp_alloc(struct qed_hwfn *p_hwfn)
 
 void qed_iwarp_resc_free(struct qed_hwfn *p_hwfn)
 {
+	struct qed_iwarp_info *iwarp_info = &p_hwfn->p_rdma_info->iwarp;
+
 	qed_rdma_bmap_free(p_hwfn, &p_hwfn->p_rdma_info->tcp_cid_map, 1);
+	kfree(iwarp_info->mpa_bufs);
 }
 
 int qed_iwarp_accept(void *rdma_cxt, struct qed_iwarp_accept_in *iparams)
@@ -1716,12 +1719,103 @@ int qed_iwarp_reject(void *rdma_cxt, struct qed_iwarp_reject_in *iparams)
 /* fpdu can be fragmented over maximum 3 bds: header, partial mpa, unaligned */
 #define QED_IWARP_MAX_BDS_PER_FPDU 3
 static void
+qed_iwarp_mpa_get_data(struct qed_hwfn *p_hwfn,
+		       struct unaligned_opaque_data *curr_pkt,
+		       u32 opaque_data0, u32 opaque_data1)
+{
+	u64 opaque_data;
+
+	opaque_data = HILO_64(opaque_data1, opaque_data0);
+	*curr_pkt = *((struct unaligned_opaque_data *)&opaque_data);
+
+	curr_pkt->first_mpa_offset = curr_pkt->tcp_payload_offset +
+				     le16_to_cpu(curr_pkt->first_mpa_offset);
+	curr_pkt->cid = le32_to_cpu(curr_pkt->cid);
+}
+
+/* This function is called when an unaligned or incomplete MPA packet arrives
+ * driver needs to align the packet, perhaps using previous data and send
+ * it down to FW once it is aligned.
+ */
+static int
+qed_iwarp_process_mpa_pkt(struct qed_hwfn *p_hwfn,
+			  struct qed_iwarp_ll2_mpa_buf *mpa_buf)
+{
+	struct qed_iwarp_ll2_buff *buf = mpa_buf->ll2_buf;
+	int rc = -EINVAL;
+
+	qed_iwarp_ll2_post_rx(p_hwfn,
+			      buf,
+			      p_hwfn->p_rdma_info->iwarp.ll2_mpa_handle);
+	return rc;
+}
+
+static void qed_iwarp_process_pending_pkts(struct qed_hwfn *p_hwfn)
+{
+	struct qed_iwarp_info *iwarp_info = &p_hwfn->p_rdma_info->iwarp;
+	struct qed_iwarp_ll2_mpa_buf *mpa_buf = NULL;
+	int rc;
+
+	while (!list_empty(&iwarp_info->mpa_buf_pending_list)) {
+		mpa_buf = list_first_entry(&iwarp_info->mpa_buf_pending_list,
+					   struct qed_iwarp_ll2_mpa_buf,
+					   list_entry);
+
+		rc = qed_iwarp_process_mpa_pkt(p_hwfn, mpa_buf);
+
+		/* busy means break and continue processing later, don't
+		 * remove the buf from the pending list.
+		 */
+		if (rc == -EBUSY)
+			break;
+
+		list_del(&mpa_buf->list_entry);
+		list_add_tail(&mpa_buf->list_entry, &iwarp_info->mpa_buf_list);
+
+		if (rc) {	/* different error, don't continue */
+			DP_NOTICE(p_hwfn, "process pkts failed rc=%d\n", rc);
+			break;
+		}
+	}
+}
+
+static void
 qed_iwarp_ll2_comp_mpa_pkt(void *cxt, struct qed_ll2_comp_rx_data *data)
 {
+	struct qed_iwarp_ll2_mpa_buf *mpa_buf;
 	struct qed_iwarp_info *iwarp_info;
 	struct qed_hwfn *p_hwfn = cxt;
 
 	iwarp_info = &p_hwfn->p_rdma_info->iwarp;
+	mpa_buf = list_first_entry(&iwarp_info->mpa_buf_list,
+				   struct qed_iwarp_ll2_mpa_buf, list_entry);
+	if (!mpa_buf) {
+		DP_ERR(p_hwfn, "No free mpa buf\n");
+		goto err;
+	}
+
+	list_del(&mpa_buf->list_entry);
+	qed_iwarp_mpa_get_data(p_hwfn, &mpa_buf->data,
+			       data->opaque_data_0, data->opaque_data_1);
+
+	DP_VERBOSE(p_hwfn,
+		   QED_MSG_RDMA,
+		   "LL2 MPA CompRx payload_len:0x%x\tfirst_mpa_offset:0x%x\ttcp_payload_offset:0x%x\tflags:0x%x\tcid:0x%x\n",
+		   data->length.packet_length, mpa_buf->data.first_mpa_offset,
+		   mpa_buf->data.tcp_payload_offset, mpa_buf->data.flags,
+		   mpa_buf->data.cid);
+
+	mpa_buf->ll2_buf = data->cookie;
+	mpa_buf->tcp_payload_len = data->length.packet_length -
+				   mpa_buf->data.first_mpa_offset;
+	mpa_buf->data.first_mpa_offset += data->u.placement_offset;
+	mpa_buf->placement_offset = data->u.placement_offset;
+
+	list_add_tail(&mpa_buf->list_entry, &iwarp_info->mpa_buf_pending_list);
+
+	qed_iwarp_process_pending_pkts(p_hwfn);
+	return;
+err:
 	qed_iwarp_ll2_post_rx(p_hwfn, data->cookie,
 			      iwarp_info->ll2_mpa_handle);
 }
@@ -1872,6 +1966,11 @@ static void qed_iwarp_ll2_comp_tx_pkt(void *cxt, u8 connection_handle,
 
 	/* this was originally an rx packet, post it back */
 	qed_iwarp_ll2_post_rx(p_hwfn, buffer, connection_handle);
+
+	if (connection_handle == p_hwfn->p_rdma_info->iwarp.ll2_mpa_handle)
+		qed_iwarp_process_pending_pkts(p_hwfn);
+
+	return;
 }
 
 static void qed_iwarp_ll2_rel_tx_pkt(void *cxt, u8 connection_handle,
@@ -1986,6 +2085,7 @@ static int qed_iwarp_ll2_stop(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	u32 mpa_buff_size;
 	u16 n_ooo_bufs;
 	int rc = 0;
+	int i;
 
 	iwarp_info = &p_hwfn->p_rdma_info->iwarp;
 	iwarp_info->ll2_syn_handle = QED_IWARP_HANDLE_INVAL;
@@ -2094,6 +2194,22 @@ static int qed_iwarp_ll2_stop(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 					 iwarp_info->ll2_mpa_handle);
 	if (rc)
 		goto err;
+	/* The mpa_bufs array serves for pending RX packets received on the
+	 * mpa ll2 that don't have place on the tx ring and require later
+	 * processing. We can't fail on allocation of such a struct therefore
+	 * we allocate enough to take care of all rx packets
+	 */
+	iwarp_info->mpa_bufs = kcalloc(data.input.rx_num_desc,
+				       sizeof(*iwarp_info->mpa_bufs),
+				       GFP_KERNEL);
+	if (!iwarp_info->mpa_bufs)
+		goto err;
+
+	INIT_LIST_HEAD(&iwarp_info->mpa_buf_pending_list);
+	INIT_LIST_HEAD(&iwarp_info->mpa_buf_list);
+	for (i = 0; i < data.input.rx_num_desc; i++)
+		list_add_tail(&iwarp_info->mpa_bufs[i].list_entry,
+			      &iwarp_info->mpa_buf_list);
 	return rc;
 err:
 	qed_iwarp_ll2_stop(p_hwfn, p_ptt);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.h b/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
index 9d33a1f..2c53fe4 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
@@ -60,10 +60,20 @@ struct qed_iwarp_ll2_buff {
 	u32 buff_size;
 };
 
+struct qed_iwarp_ll2_mpa_buf {
+	struct list_head list_entry;
+	struct qed_iwarp_ll2_buff *ll2_buf;
+	struct unaligned_opaque_data data;
+	u16 tcp_payload_len;
+	u8 placement_offset;
+};
+
 struct qed_iwarp_info {
 	struct list_head listen_list;	/* qed_iwarp_listener */
 	struct list_head ep_list;	/* qed_iwarp_ep */
 	struct list_head ep_free_list;	/* pre-allocated ep's */
+	struct list_head mpa_buf_list;	/* list of mpa_bufs */
+	struct list_head mpa_buf_pending_list;
 	spinlock_t iw_lock;	/* for iwarp resources */
 	spinlock_t qp_lock;	/* for teardown races */
 	u32 rcv_wnd_scale;
@@ -77,6 +87,7 @@ struct qed_iwarp_info {
 	u8 peer2peer;
 	enum mpa_negotiation_mode mpa_rev;
 	enum mpa_rtr_type rtr_type;
+	struct qed_iwarp_ll2_mpa_buf *mpa_bufs;
 };
 
 enum qed_iwarp_ep_state {
-- 
1.8.3.1
