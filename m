From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH net-next 02/12] qed: Add ll2 ability of opening a secondary queue
Date: Mon, 2 Oct 2017 11:23:48 +0300
Message-ID: <1506932638-26268-3-git-send-email-Michal.Kalderon@cavium.com>
References: <1506932638-26268-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
        <dledford@redhat.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        "Ariel Elior" <Ariel.Elior@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0059.outbound.protection.outlook.com ([104.47.32.59]:22558
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751061AbdJBIYk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 04:24:40 -0400
In-Reply-To: <1506932638-26268-1-git-send-email-Michal.Kalderon@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When more than one ll2 queue is opened ( that is not an OOO queue )
ll2 code does not have enough information to determine whether
the queue is the main one or not, so a new field is added to the
acquire input data to expose the control of determining whether
the queue is the main queue or a secondary queue.

Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Ariel Elior <Ariel.Elior@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 7 ++++++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.h | 1 +
 include/linux/qed/qed_ll2_if.h            | 1 +
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 10e3a43..1dd0cca 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -894,7 +894,7 @@ static int qed_sp_ll2_rx_queue_start(struct qed_hwfn *p_hwfn,
 	p_ramrod->drop_ttl0_flg = p_ll2_conn->input.rx_drop_ttl0_flg;
 	p_ramrod->inner_vlan_removal_en = p_ll2_conn->input.rx_vlan_removal_en;
 	p_ramrod->queue_id = p_ll2_conn->queue_id;
-	p_ramrod->main_func_queue = (conn_type == QED_LL2_TYPE_OOO) ? 0 : 1;
+	p_ramrod->main_func_queue = p_ll2_conn->main_func_queue;
 
 	if ((IS_MF_DEFAULT(p_hwfn) || IS_MF_SI(p_hwfn)) &&
 	    p_ramrod->main_func_queue && (conn_type != QED_LL2_TYPE_ROCE) &&
@@ -1265,6 +1265,11 @@ int qed_ll2_acquire_connection(void *cxt, struct qed_ll2_acquire_data *data)
 
 	p_ll2_info->tx_dest = (data->input.tx_dest == QED_LL2_TX_DEST_NW) ?
 			      CORE_TX_DEST_NW : CORE_TX_DEST_LB;
+	if (data->input.conn_type == QED_LL2_TYPE_OOO ||
+	    data->input.secondary_queue)
+		p_ll2_info->main_func_queue = false;
+	else
+		p_ll2_info->main_func_queue = true;
 
 	/* Correct maximum number of Tx BDs */
 	p_tx_max = &p_ll2_info->input.tx_max_bds_per_packet;
diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.h b/drivers/net/ethernet/qlogic/qed/qed_ll2.h
index 8019336..346f3d3 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.h
@@ -121,6 +121,7 @@ struct qed_ll2_info {
 	bool b_active;
 	enum core_tx_dest tx_dest;
 	u8 tx_stats_en;
+	u8 main_func_queue;
 	struct qed_ll2_rx_queue rx_queue;
 	struct qed_ll2_tx_queue tx_queue;
 	struct qed_ll2_cbs cbs;
diff --git a/include/linux/qed/qed_ll2_if.h b/include/linux/qed/qed_ll2_if.h
index 89fa0bb..25153ff 100644
--- a/include/linux/qed/qed_ll2_if.h
+++ b/include/linux/qed/qed_ll2_if.h
@@ -171,6 +171,7 @@ struct qed_ll2_acquire_data_inputs {
 	enum qed_ll2_tx_dest tx_dest;
 	enum qed_ll2_error_handle ai_err_packet_too_big;
 	enum qed_ll2_error_handle ai_err_no_buf;
+	u8 secondary_queue;
 	u8 gsi_enable;
 };
 
-- 
1.8.3.1
