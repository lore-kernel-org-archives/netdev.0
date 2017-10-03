From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 net-next 02/12] qed: Add ll2 ability of opening a secondary queue
Date: Tue, 3 Oct 2017 11:54:52 +0300
Message-ID: <1507020902-4952-3-git-send-email-Michal.Kalderon@cavium.com>
References: <1507020902-4952-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        "Ariel Elior" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507020902-4952-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When more than one ll2 queue is opened ( that is not an OOO queue )
ll2 code does not have enough information to determine whether
the queue is the main one or not, so a new field is added to the
acquire input data to expose the control of determining whether
the queue is the main queue or a secondary queue.

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 7 ++++++-
 drivers/net/ethernet/qlogic/qed/qed_ll2.h | 1 +
 include/linux/qed/qed_ll2_if.h            | 1 +
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 75af40a..3c695da 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -894,7 +894,7 @@ static int qed_sp_ll2_rx_queue_start(struct qed_hwfn *p_hwfn,
 	p_ramrod->drop_ttl0_flg = p_ll2_conn->input.rx_drop_ttl0_flg;
 	p_ramrod->inner_vlan_removal_en = p_ll2_conn->input.rx_vlan_removal_en;
 	p_ramrod->queue_id = p_ll2_conn->queue_id;
-	p_ramrod->main_func_queue = (conn_type == QED_LL2_TYPE_OOO) ? 0 : 1;
+	p_ramrod->main_func_queue = p_ll2_conn->main_func_queue ? 1 : 0;
 
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
index 9bdd08f..f658170 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.h
@@ -121,6 +121,7 @@ struct qed_ll2_info {
 	bool b_active;
 	enum core_tx_dest tx_dest;
 	u8 tx_stats_en;
+	bool main_func_queue;
 	struct qed_ll2_rx_queue rx_queue;
 	struct qed_ll2_tx_queue tx_queue;
 	struct qed_ll2_cbs cbs;
diff --git a/include/linux/qed/qed_ll2_if.h b/include/linux/qed/qed_ll2_if.h
index 89fa0bb..d7cca59 100644
--- a/include/linux/qed/qed_ll2_if.h
+++ b/include/linux/qed/qed_ll2_if.h
@@ -171,6 +171,7 @@ struct qed_ll2_acquire_data_inputs {
 	enum qed_ll2_tx_dest tx_dest;
 	enum qed_ll2_error_handle ai_err_packet_too_big;
 	enum qed_ll2_error_handle ai_err_no_buf;
+	bool secondary_queue;
 	u8 gsi_enable;
 };
 
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
