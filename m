From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 05/10] bna: Fix for TX queue
Date: Tue, 21 Dec 2010 23:23:11 -0800
Message-ID: <1293002596-3239-6-git-send-email-rmody@brocade.com>
References: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rasesh Mody <rmody@brocade.com>, Debashis Dutt <ddutt@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54135 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752026Ab0LVHn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 02:43:26 -0500
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id oBM7MMDT021251
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 23:23:23 -0800
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.141.11])
	by mx0b-000f0801.pphosted.com with ESMTP id tb71ag48f-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 23:23:23 -0800
In-Reply-To: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chnage details:
	- Call netif_wake_queue() if we have freed up sufficient elements at the end of completion processing
	- Add netif_queue_stopped counter back to bnad_drv_stats {}
	- Get netif_queue_stopped value from stack
	- Remove BUG_ON() on value returned by pci_unmap_addr()

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bnad.c         |   20 ++++++++++++++++----
 drivers/net/bna/bnad.h         |    7 +++++--
 drivers/net/bna/bnad_ethtool.c |    4 ++++
 3 files changed, 25 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index 348ebf9..79d84f2 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -109,7 +109,7 @@ static void
 bnad_free_all_txbufs(struct bnad *bnad,
 		 struct bna_tcb *tcb)
 {
-	u16 		unmap_cons;
+	u32 		unmap_cons;
 	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
 	struct bnad_skb_unmap *unmap_array;
 	struct sk_buff 		*skb = NULL;
@@ -244,7 +244,7 @@ bnad_tx_free_tasklet(unsigned long bnad_ptr)
 {
 	struct bnad *bnad = (struct bnad *)bnad_ptr;
 	struct bna_tcb *tcb;
-	u32 		acked;
+	u32 		acked = 0;
 	int			i, j;
 
 	for (i = 0; i < bnad->num_tx; i++) {
@@ -263,6 +263,20 @@ bnad_tx_free_tasklet(unsigned long bnad_ptr)
 				smp_mb__before_clear_bit();
 				clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
 			}
+			if (unlikely(!test_bit(BNAD_TXQ_TX_STARTED,
+						&tcb->flags)))
+				continue;
+			if (netif_queue_stopped(bnad->netdev)) {
+				if (acked && netif_carrier_ok(bnad->netdev) &&
+					BNA_QE_FREE_CNT(tcb, tcb->q_depth) >=
+						BNAD_NETIF_WAKE_THRESHOLD) {
+					netif_wake_queue(bnad->netdev);
+					/* TODO */
+					/* Counters for individual TxQs? */
+					BNAD_UPDATE_CTR(bnad,
+						netif_queue_wakeup);
+				}
+			}
 		}
 	}
 }
@@ -334,8 +348,6 @@ bnad_free_all_rxbufs(struct bnad *bnad, struct bna_rcb *rcb)
 		skb = unmap_q->unmap_array[unmap_cons].skb;
 		if (!skb)
 			continue;
-		BUG_ON(!(pci_unmap_addr(
-			&unmap_q->unmap_array[unmap_cons], dma_addr)));
 		unmap_q->unmap_array[unmap_cons].skb = NULL;
 		pci_unmap_single(bnad->pcidev, pci_unmap_addr(&unmap_q->
 					unmap_array[unmap_cons],
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 92768e2..06d9ea2 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -126,6 +126,7 @@ struct bnad_completion {
 struct bnad_drv_stats {
 	u64 		netif_queue_stop;
 	u64		netif_queue_wakeup;
+	u64		netif_queue_stopped;
 	u64		tso4;
 	u64		tso6;
 	u64		tso_err;
@@ -308,8 +309,10 @@ extern void bnad_cleanup_rx(struct bnad *bnad, uint rx_id);
 extern void bnad_dim_timer_start(struct bnad *bnad);
 
 /* Statistics */
-extern void bnad_netdev_qstats_fill(struct bnad *bnad, struct rtnl_link_stats64 *stats);
-extern void bnad_netdev_hwstats_fill(struct bnad *bnad, struct rtnl_link_stats64 *stats);
+extern void bnad_netdev_qstats_fill(struct bnad *bnad,
+		struct rtnl_link_stats64 *stats);
+extern void bnad_netdev_hwstats_fill(struct bnad *bnad,
+		struct rtnl_link_stats64 *stats);
 
 /**
  * MACROS
diff --git a/drivers/net/bna/bnad_ethtool.c b/drivers/net/bna/bnad_ethtool.c
index 3011110..99be5ae 100644
--- a/drivers/net/bna/bnad_ethtool.c
+++ b/drivers/net/bna/bnad_ethtool.c
@@ -68,6 +68,7 @@ static char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
 
 	"netif_queue_stop",
 	"netif_queue_wakeup",
+	"netif_queue_stopped",
 	"tso4",
 	"tso6",
 	"tso_err",
@@ -1180,6 +1181,9 @@ bnad_get_ethtool_stats(struct net_device *netdev, struct ethtool_stats *stats,
 
 	bi = sizeof(*net_stats64) / sizeof(u64);
 
+	/* Get netif_queue_stopped from stack */
+	bnad->stats.drv_stats.netif_queue_stopped = netif_queue_stopped(netdev);
+
 	/* Fill driver stats into ethtool buffers */
 	stats64 = (u64 *)&bnad->stats.drv_stats;
 	for (i = 0; i < sizeof(struct bnad_drv_stats) / sizeof(u64); i++)
-- 
1.7.1

