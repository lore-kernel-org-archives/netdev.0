From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2 net-next 10/12] qed: Add support for freeing two ll2 buffers for corner cases
Date: Tue, 3 Oct 2017 11:55:00 +0300
Message-ID: <1507020902-4952-11-git-send-email-Michal.Kalderon@cavium.com>
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

When posting a packet on the ll2 tx, we can provide a cookie that
will be returned upon tx completion. This cookie is the ll2 iwarp buffer
which is then reposted to the rx ring. Part of the unaligned mpa flow
is determining when a buffer can be reposted. Each buffer needs to be
sent only once as a cookie for on the tx ring. In packed fpdu case, only
the last packet will be sent with the buffer, meaning we need to handle the
case that a cookie can be NULL on tx complete. In addition, when a fpdu
splits over two buffers, but there are no more fpdus on the second buffer,
two buffers need to be provided as a cookie. To avoid changing the ll2
interface to provide two cookies, we introduce a piggy buf pointer,
relevant for iWARP only, that holds a pointer to a second buffer that
needs to be released during tx completion.

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c | 25 +++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_iwarp.h |  1 +
 2 files changed, 26 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
index 83b147f..8b17369 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
@@ -1846,6 +1846,12 @@ enum qed_iwarp_mpa_pkt_type {
 	/* vlan overload with enum iwarp_ll2_tx_queues */
 	tx_pkt.vlan = IWARP_LL2_ALIGNED_TX_QUEUE;
 
+	/* special case of unaligned packet and not packed, need to send
+	 * both buffers as cookie to release.
+	 */
+	if (tcp_payload_size == fpdu->incomplete_bytes)
+		fpdu->mpa_buf->piggy_buf = buf;
+
 	ll2_handle = p_hwfn->p_rdma_info->iwarp.ll2_mpa_handle;
 
 	/* Set first fragment to header */
@@ -2195,9 +2201,19 @@ static void qed_iwarp_ll2_comp_tx_pkt(void *cxt, u8 connection_handle,
 				      bool b_last_fragment, bool b_last_packet)
 {
 	struct qed_iwarp_ll2_buff *buffer = cookie;
+	struct qed_iwarp_ll2_buff *piggy;
 	struct qed_hwfn *p_hwfn = cxt;
 
+	if (!buffer)		/* can happen in packed mpa unaligned... */
+		return;
+
 	/* this was originally an rx packet, post it back */
+	piggy = buffer->piggy_buf;
+	if (piggy) {
+		buffer->piggy_buf = NULL;
+		qed_iwarp_ll2_post_rx(p_hwfn, piggy, connection_handle);
+	}
+
 	qed_iwarp_ll2_post_rx(p_hwfn, buffer, connection_handle);
 
 	if (connection_handle == p_hwfn->p_rdma_info->iwarp.ll2_mpa_handle)
@@ -2216,6 +2232,15 @@ static void qed_iwarp_ll2_rel_tx_pkt(void *cxt, u8 connection_handle,
 	if (!buffer)
 		return;
 
+	if (buffer->piggy_buf) {
+		dma_free_coherent(&p_hwfn->cdev->pdev->dev,
+				  buffer->piggy_buf->buff_size,
+				  buffer->piggy_buf->data,
+				  buffer->piggy_buf->data_phys_addr);
+
+		kfree(buffer->piggy_buf);
+	}
+
 	dma_free_coherent(&p_hwfn->cdev->pdev->dev, buffer->buff_size,
 			  buffer->data, buffer->data_phys_addr);
 
diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.h b/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
index 858755c..58db51a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.h
@@ -55,6 +55,7 @@ enum qed_iwarp_qp_state {
 #define QED_IWARP_HANDLE_INVAL		(0xff)
 
 struct qed_iwarp_ll2_buff {
+	struct qed_iwarp_ll2_buff *piggy_buf;
 	void *data;
 	dma_addr_t data_phys_addr;
 	u32 buff_size;
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
