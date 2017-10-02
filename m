From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 07/12] qed: Add ll2 connection for processing unaligned MPA packets
Date: Mon, 2 Oct 2017 11:23:53 +0300
Message-ID: <1506932638-26268-8-git-send-email-Michal.Kalderon@cavium.com>
References: <1506932638-26268-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Ariel Elior" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1506932638-26268-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds only the establishment and termination of the
ll2 connection that handles unaligned MPA packets.

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c | 65 +++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_iwarp.h |  1 +
 2 files changed, 66 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
index 8fc9c811..f413621 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
@@ -1713,6 +1713,19 @@ int qed_iwarp_reject(void *rdma_cxt, struct qed_iwarp_reject_in *iparams)
 	return 0;
 }
 
+/* fpdu can be fragmented over maximum 3 bds: header, partial mpa, unaligned */
+#define QED_IWARP_MAX_BDS_PER_FPDU 3
+static void
+qed_iwarp_ll2_comp_mpa_pkt(void *cxt, struct qed_ll2_comp_rx_data *data)
+{
+	struct qed_iwarp_info *iwarp_info;
+	struct qed_hwfn *p_hwfn = cxt;
+
+	iwarp_info = &p_hwfn->p_rdma_info->iwarp;
+	qed_iwarp_ll2_post_rx(p_hwfn, data->cookie,
+			      iwarp_info->ll2_mpa_handle);
+}
+
 static void
 qed_iwarp_ll2_comp_syn_pkt(void *cxt, struct qed_ll2_comp_rx_data *data)
 {
@@ -1877,6 +1890,13 @@ static void qed_iwarp_ll2_rel_tx_pkt(void *cxt, u8 connection_handle,
 	kfree(buffer);
 }
 
+void
+qed_iwarp_ll2_slowpath(void *cxt,
+		       u8 connection_handle,
+		       u32 opaque_data_0, u32 opaque_data_1)
+{
+}
+
 static int qed_iwarp_ll2_stop(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 {
 	struct qed_iwarp_info *iwarp_info = &p_hwfn->p_rdma_info->iwarp;
@@ -1902,6 +1922,16 @@ static int qed_iwarp_ll2_stop(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 		iwarp_info->ll2_ooo_handle = QED_IWARP_HANDLE_INVAL;
 	}
 
+	if (iwarp_info->ll2_mpa_handle != QED_IWARP_HANDLE_INVAL) {
+		rc = qed_ll2_terminate_connection(p_hwfn,
+						  iwarp_info->ll2_mpa_handle);
+		if (rc)
+			DP_INFO(p_hwfn, "Failed to terminate mpa connection\n");
+
+		qed_ll2_release_connection(p_hwfn, iwarp_info->ll2_mpa_handle);
+		iwarp_info->ll2_mpa_handle = QED_IWARP_HANDLE_INVAL;
+	}
+
 	qed_llh_remove_mac_filter(p_hwfn,
 				  p_ptt, p_hwfn->p_rdma_info->iwarp.mac_addr);
 	return rc;
@@ -1953,12 +1983,14 @@ static int qed_iwarp_ll2_stop(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	struct qed_iwarp_info *iwarp_info;
 	struct qed_ll2_acquire_data data;
 	struct qed_ll2_cbs cbs;
+	u32 mpa_buff_size;
 	u16 n_ooo_bufs;
 	int rc = 0;
 
 	iwarp_info = &p_hwfn->p_rdma_info->iwarp;
 	iwarp_info->ll2_syn_handle = QED_IWARP_HANDLE_INVAL;
 	iwarp_info->ll2_ooo_handle = QED_IWARP_HANDLE_INVAL;
+	iwarp_info->ll2_mpa_handle = QED_IWARP_HANDLE_INVAL;
 
 	iwarp_info->max_mtu = params->max_mtu;
 
@@ -2029,6 +2061,39 @@ static int qed_iwarp_ll2_stop(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	if (rc)
 		goto err;
 
+	/* Start Unaligned MPA connection */
+	cbs.rx_comp_cb = qed_iwarp_ll2_comp_mpa_pkt;
+	cbs.slowpath_cb = qed_iwarp_ll2_slowpath;
+
+	memset(&data, 0, sizeof(data));
+	data.input.conn_type = QED_LL2_TYPE_IWARP;
+	data.input.mtu = params->max_mtu;
+	/* FW requires that once a packet arrives OOO, it must have at
+	 * least 2 rx buffers available on the unaligned connection
+	 * for handling the case that it is a partial fpdu.
+	 */
+	data.input.rx_num_desc = n_ooo_bufs * 2;
+	data.input.tx_num_desc = data.input.rx_num_desc;
+	data.input.tx_max_bds_per_packet = QED_IWARP_MAX_BDS_PER_FPDU;
+	data.p_connection_handle = &iwarp_info->ll2_mpa_handle;
+	data.input.secondary_queue = true;
+	data.cbs = &cbs;
+
+	rc = qed_ll2_acquire_connection(p_hwfn, &data);
+	if (rc)
+		goto err;
+
+	rc = qed_ll2_establish_connection(p_hwfn, iwarp_info->ll2_mpa_handle);
+	if (rc)
+		goto err;
+
+	mpa_buff_size = QED_IWARP_MAX_BUF_SIZE(params->max_mtu);
+	rc = qed_iwarp_ll2_alloc_buffers(p_hwfn,
+					 data.input.rx_num_desc,
+					 mpa_buff_size,
+					 iwarp_info->ll2_mpa_handle);
+	if (rc)
+		goto err;
 	return rc;
 err:
 	qed_iwarp_ll2_stop(p_hwfn, p_ptt);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.h b/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
index 9e2bfde..9d33a1f 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
@@ -73,6 +73,7 @@ struct qed_iwarp_info {
 	u8 tcp_flags;
 	u8 ll2_syn_handle;
 	u8 ll2_ooo_handle;
+	u8 ll2_mpa_handle;
 	u8 peer2peer;
 	enum mpa_negotiation_mode mpa_rev;
 	enum mpa_rtr_type rtr_type;
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
