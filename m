From: sunil.kovvuri@gmail.com
Subject: [PATCH 3/3] net: thunderx: Fix receive packet stats
Date: Tue, 16 Feb 2016 16:29:51 +0530
Message-ID: <1455620391-31619-4-git-send-email-sunil.kovvuri@gmail.com>
References: <1455620391-31619-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	sgoutham@cavium.com, robert.richter@caviumnetworks.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455620391-31619-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Counting rx packets for every CQE_RX in CQ irq handler is incorrect.
Synchronization is missing when multiple queues are receiving packets
simultaneously. Like transmit packet stats use HW stats here.

Also removed unused 'cqe_type' parameter in nicvf_rcv_pkt_handler().

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   |   11 ++++++-----
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |    8 ++------
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |    3 +--
 3 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 84c5a33..a009bc3 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -574,8 +574,7 @@ static inline void nicvf_set_rxhash(struct net_device *netdev,
 
 static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 				  struct napi_struct *napi,
-				  struct cmp_queue *cq,
-				  struct cqe_rx_t *cqe_rx, int cqe_type)
+				  struct cqe_rx_t *cqe_rx)
 {
 	struct sk_buff *skb;
 	struct nicvf *nic = netdev_priv(netdev);
@@ -591,7 +590,7 @@ static void nicvf_rcv_pkt_handler(struct net_device *netdev,
 	}
 
 	/* Check for errors */
-	err = nicvf_check_cqe_rx_errs(nic, cq, cqe_rx);
+	err = nicvf_check_cqe_rx_errs(nic, cqe_rx);
 	if (err && !cqe_rx->rb_cnt)
 		return;
 
@@ -682,8 +681,7 @@ loop:
 			   cq_idx, cq_desc->cqe_type);
 		switch (cq_desc->cqe_type) {
 		case CQE_TYPE_RX:
-			nicvf_rcv_pkt_handler(netdev, napi, cq,
-					      cq_desc, CQE_TYPE_RX);
+			nicvf_rcv_pkt_handler(netdev, napi, cq_desc);
 			work_done++;
 		break;
 		case CQE_TYPE_SEND:
@@ -1353,6 +1351,9 @@ void nicvf_update_stats(struct nicvf *nic)
 	drv_stats->tx_frames_ok = stats->tx_ucast_frames_ok +
 				  stats->tx_bcast_frames_ok +
 				  stats->tx_mcast_frames_ok;
+	drv_stats->rx_frames_ok = stats->rx_ucast_frames +
+				  stats->rx_bcast_frames +
+				  stats->rx_mcast_frames;
 	drv_stats->rx_drops = stats->rx_drop_red +
 			      stats->rx_drop_overrun;
 	drv_stats->tx_drops = stats->tx_drops;
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index d0d1b54..767347b 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -1329,16 +1329,12 @@ void nicvf_update_sq_stats(struct nicvf *nic, int sq_idx)
 }
 
 /* Check for errors in the receive cmp.queue entry */
-int nicvf_check_cqe_rx_errs(struct nicvf *nic,
-			    struct cmp_queue *cq, struct cqe_rx_t *cqe_rx)
+int nicvf_check_cqe_rx_errs(struct nicvf *nic, struct cqe_rx_t *cqe_rx)
 {
 	struct nicvf_hw_stats *stats = &nic->hw_stats;
-	struct nicvf_drv_stats *drv_stats = &nic->drv_stats;
 
-	if (!cqe_rx->err_level && !cqe_rx->err_opcode) {
-		drv_stats->rx_frames_ok++;
+	if (!cqe_rx->err_level && !cqe_rx->err_opcode)
 		return 0;
-	}
 
 	if (netif_msg_rx_err(nic))
 		netdev_err(nic->netdev,
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
index c5030a7..6673e11 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.h
@@ -338,8 +338,7 @@ u64  nicvf_queue_reg_read(struct nicvf *nic,
 /* Stats */
 void nicvf_update_rq_stats(struct nicvf *nic, int rq_idx);
 void nicvf_update_sq_stats(struct nicvf *nic, int sq_idx);
-int nicvf_check_cqe_rx_errs(struct nicvf *nic,
-			    struct cmp_queue *cq, struct cqe_rx_t *cqe_rx);
+int nicvf_check_cqe_rx_errs(struct nicvf *nic, struct cqe_rx_t *cqe_rx);
 int nicvf_check_cqe_tx_errs(struct nicvf *nic,
 			    struct cmp_queue *cq, struct cqe_send_t *cqe_tx);
 #endif /* NICVF_QUEUES_H */
-- 
1.7.1
