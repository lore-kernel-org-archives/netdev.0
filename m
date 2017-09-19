From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH net-next 2/4] qed: Add iWARP out of order support
Date: Tue, 19 Sep 2017 20:26:17 +0300
Message-ID: <1505841979-26365-3-git-send-email-Michal.Kalderon@cavium.com>
References: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma@vger.kernel.org>, <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0080.outbound.protection.outlook.com ([104.47.36.80]:55516
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751378AbdISR12 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 19 Sep 2017 13:27:28 -0400
In-Reply-To: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iWARP requires OOO support which is already provided by the ll2
interface (until now was used only for iSCSI offload).
The changes mostly include opening a ll2 dedicated connection for
OOO and notifiying the FW about the handle id.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c | 44 +++++++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_iwarp.h | 11 +++++++-
 drivers/net/ethernet/qlogic/qed/qed_rdma.c  |  7 +++--
 3 files changed, 59 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
index 9d989c9..568e985 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
@@ -41,6 +41,7 @@
 #include "qed_rdma.h"
 #include "qed_reg_addr.h"
 #include "qed_sp.h"
+#include "qed_ooo.h"
 
 #define QED_IWARP_ORD_DEFAULT		32
 #define QED_IWARP_IRD_DEFAULT		32
@@ -119,6 +120,13 @@ static void qed_iwarp_cid_cleaned(struct qed_hwfn *p_hwfn, u32 cid)
 	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
 }
 
+void qed_iwarp_init_fw_ramrod(struct qed_hwfn *p_hwfn,
+			      struct iwarp_init_func_params *p_ramrod)
+{
+	p_ramrod->ll2_ooo_q_index = RESC_START(p_hwfn, QED_LL2_QUEUE) +
+				    p_hwfn->p_rdma_info->iwarp.ll2_ooo_handle;
+}
+
 static int qed_iwarp_alloc_cid(struct qed_hwfn *p_hwfn, u32 *cid)
 {
 	int rc;
@@ -1876,6 +1884,16 @@ static int qed_iwarp_ll2_stop(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 		iwarp_info->ll2_syn_handle = QED_IWARP_HANDLE_INVAL;
 	}
 
+	if (iwarp_info->ll2_ooo_handle != QED_IWARP_HANDLE_INVAL) {
+		rc = qed_ll2_terminate_connection(p_hwfn,
+						  iwarp_info->ll2_ooo_handle);
+		if (rc)
+			DP_INFO(p_hwfn, "Failed to terminate ooo connection\n");
+
+		qed_ll2_release_connection(p_hwfn, iwarp_info->ll2_ooo_handle);
+		iwarp_info->ll2_ooo_handle = QED_IWARP_HANDLE_INVAL;
+	}
+
 	qed_llh_remove_mac_filter(p_hwfn,
 				  p_ptt, p_hwfn->p_rdma_info->iwarp.mac_addr);
 	return rc;
@@ -1927,10 +1945,12 @@ static int qed_iwarp_ll2_stop(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	struct qed_iwarp_info *iwarp_info;
 	struct qed_ll2_acquire_data data;
 	struct qed_ll2_cbs cbs;
+	u16 n_ooo_bufs;
 	int rc = 0;
 
 	iwarp_info = &p_hwfn->p_rdma_info->iwarp;
 	iwarp_info->ll2_syn_handle = QED_IWARP_HANDLE_INVAL;
+	iwarp_info->ll2_ooo_handle = QED_IWARP_HANDLE_INVAL;
 
 	iwarp_info->max_mtu = params->max_mtu;
 
@@ -1978,6 +1998,29 @@ static int qed_iwarp_ll2_stop(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt)
 	if (rc)
 		goto err;
 
+	/* Start OOO connection */
+	data.input.conn_type = QED_LL2_TYPE_OOO;
+	data.input.mtu = params->max_mtu;
+
+	n_ooo_bufs = (QED_IWARP_MAX_OOO * QED_IWARP_RCV_WND_SIZE_DEF) /
+		     iwarp_info->max_mtu;
+	n_ooo_bufs = min_t(u32, n_ooo_bufs, QED_IWARP_LL2_OOO_MAX_RX_SIZE);
+
+	data.input.rx_num_desc = n_ooo_bufs;
+	data.input.rx_num_ooo_buffers = n_ooo_bufs;
+
+	data.input.tx_max_bds_per_packet = 1;	/* will never be fragmented */
+	data.input.tx_num_desc = QED_IWARP_LL2_OOO_DEF_TX_SIZE;
+	data.p_connection_handle = &iwarp_info->ll2_ooo_handle;
+
+	rc = qed_ll2_acquire_connection(p_hwfn, &data);
+	if (rc)
+		goto err;
+
+	rc = qed_ll2_establish_connection(p_hwfn, iwarp_info->ll2_ooo_handle);
+	if (rc)
+		goto err;
+
 	return rc;
 err:
 	qed_iwarp_ll2_stop(p_hwfn, p_ptt);
@@ -2014,6 +2057,7 @@ int qed_iwarp_setup(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 
 	qed_spq_register_async_cb(p_hwfn, PROTOCOLID_IWARP,
 				  qed_iwarp_async_event);
+	qed_ooo_setup(p_hwfn);
 
 	return qed_iwarp_ll2_start(p_hwfn, params, p_ptt);
 }
diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.h b/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
index 148ef3c..9e2bfde 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
@@ -47,7 +47,12 @@ enum qed_iwarp_qp_state {
 #define QED_IWARP_LL2_SYN_TX_SIZE       (128)
 #define QED_IWARP_LL2_SYN_RX_SIZE       (256)
 #define QED_IWARP_MAX_SYN_PKT_SIZE      (128)
-#define QED_IWARP_HANDLE_INVAL			(0xff)
+
+#define QED_IWARP_LL2_OOO_DEF_TX_SIZE   (256)
+#define QED_IWARP_MAX_OOO		(16)
+#define QED_IWARP_LL2_OOO_MAX_RX_SIZE   (16384)
+
+#define QED_IWARP_HANDLE_INVAL		(0xff)
 
 struct qed_iwarp_ll2_buff {
 	void *data;
@@ -67,6 +72,7 @@ struct qed_iwarp_info {
 	u8 crc_needed;
 	u8 tcp_flags;
 	u8 ll2_syn_handle;
+	u8 ll2_ooo_handle;
 	u8 peer2peer;
 	enum mpa_negotiation_mode mpa_rev;
 	enum mpa_rtr_type rtr_type;
@@ -147,6 +153,9 @@ struct qed_iwarp_listener {
 int qed_iwarp_setup(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 		    struct qed_rdma_start_in_params *params);
 
+void qed_iwarp_init_fw_ramrod(struct qed_hwfn *p_hwfn,
+			      struct iwarp_init_func_params *p_ramrod);
+
 int qed_iwarp_stop(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt);
 
 void qed_iwarp_resc_free(struct qed_hwfn *p_hwfn);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_rdma.c b/drivers/net/ethernet/qlogic/qed/qed_rdma.c
index 06715f7..4f46f28 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_rdma.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_rdma.c
@@ -551,10 +551,13 @@ static int qed_rdma_start_fw(struct qed_hwfn *p_hwfn,
 	if (rc)
 		return rc;
 
-	if (QED_IS_IWARP_PERSONALITY(p_hwfn))
+	if (QED_IS_IWARP_PERSONALITY(p_hwfn)) {
+		qed_iwarp_init_fw_ramrod(p_hwfn,
+					 &p_ent->ramrod.iwarp_init_func.iwarp);
 		p_ramrod = &p_ent->ramrod.iwarp_init_func.rdma;
-	else
+	} else {
 		p_ramrod = &p_ent->ramrod.roce_init_func.rdma;
+	}
 
 	p_params_header = &p_ramrod->params_header;
 	p_params_header->cnq_start_offset = (u8)RESC_START(p_hwfn,
-- 
1.8.3.1
