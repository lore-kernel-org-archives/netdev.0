From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 7/8] qed: Call rx_release_cb() when flushing LL2
Date: Thu, 8 Jun 2017 19:13:22 +0300
Message-ID: <20170608161323.7597-8-Yuval.Mintz@cavium.com>
References: <20170608161323.7597-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170608161323.7597-1-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Driver to inform the connection owner that the its buffers are being
released as part of a flush.

Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 2a68fb9..c6172a77e 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -525,10 +525,6 @@ static void qed_ll2_rxq_flush(struct qed_hwfn *p_hwfn, u8 connection_handle)
 	p_rx = &p_ll2_conn->rx_queue;
 
 	while (!list_empty(&p_rx->active_descq)) {
-		dma_addr_t rx_buf_addr;
-		void *cookie;
-		bool b_last;
-
 		p_pkt = list_first_entry(&p_rx->active_descq,
 					 struct qed_ll2_rx_packet, list_entry);
 		if (!p_pkt)
@@ -543,10 +539,15 @@ static void qed_ll2_rxq_flush(struct qed_hwfn *p_hwfn, u8 connection_handle)
 			qed_ooo_put_free_buffer(p_hwfn, p_hwfn->p_ooo_info,
 						p_buffer);
 		} else {
-			rx_buf_addr = p_pkt->rx_buf_addr;
-			cookie = p_pkt->cookie;
+			dma_addr_t rx_buf_addr = p_pkt->rx_buf_addr;
+			void *cookie = p_pkt->cookie;
+			bool b_last;
 
 			b_last = list_empty(&p_rx->active_descq);
+			p_ll2_conn->cbs.rx_release_cb(p_ll2_conn->cbs.cookie,
+						      p_ll2_conn->my_id,
+						      cookie,
+						      rx_buf_addr, b_last);
 		}
 	}
 }
-- 
2.9.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
