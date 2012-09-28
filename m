From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/7 net-next v2] tg3: Allow number of rx and tx rings to
 be set independently.
Date: Fri, 28 Sep 2012 10:12:38 -0700
Message-ID: <1348852363-8582-2-git-send-email-mchan@broadcom.com>
References: <1348852363-8582-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3448 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758260Ab2I2Blp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 21:41:45 -0400
In-Reply-To: <1348852363-8582-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

irq_cnt is no longer necessarily equal to the number rx or tx rings.

Reviewed-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   74 +++++++++++++++++++++++------------
 drivers/net/ethernet/broadcom/tg3.h |    5 ++-
 2 files changed, 53 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 93b8120..330356b 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6278,7 +6278,7 @@ static int tg3_poll_work(struct tg3_napi *tnapi, int work_done, int budget)
 		u32 jmb_prod_idx = dpr->rx_jmb_prod_idx;
 
 		tp->rx_refill = false;
-		for (i = 1; i < tp->irq_cnt; i++)
+		for (i = 1; i <= tp->rxq_cnt; i++)
 			err |= tg3_rx_prodring_xfer(tp, dpr,
 						    &tp->napi[i].prodring);
 
@@ -8654,13 +8654,12 @@ static void __tg3_set_rx_mode(struct net_device *dev)
 	}
 }
 
-static void tg3_rss_init_dflt_indir_tbl(struct tg3 *tp)
+static void tg3_rss_init_dflt_indir_tbl(struct tg3 *tp, u32 qcnt)
 {
 	int i;
 
 	for (i = 0; i < TG3_RSS_INDIR_TBL_SIZE; i++)
-		tp->rss_ind_tbl[i] =
-			ethtool_rxfh_indir_default(i, tp->irq_cnt - 1);
+		tp->rss_ind_tbl[i] = ethtool_rxfh_indir_default(i, qcnt);
 }
 
 static void tg3_rss_check_indir_tbl(struct tg3 *tp)
@@ -8682,7 +8681,7 @@ static void tg3_rss_check_indir_tbl(struct tg3 *tp)
 	}
 
 	if (i != TG3_RSS_INDIR_TBL_SIZE)
-		tg3_rss_init_dflt_indir_tbl(tp);
+		tg3_rss_init_dflt_indir_tbl(tp, tp->rxq_cnt);
 }
 
 static void tg3_rss_write_indir_tbl(struct tg3 *tp)
@@ -10203,22 +10202,36 @@ static int tg3_request_firmware(struct tg3 *tp)
 	return 0;
 }
 
-static bool tg3_enable_msix(struct tg3 *tp)
+static u32 tg3_irq_count(struct tg3 *tp)
 {
-	int i, rc;
-	struct msix_entry msix_ent[tp->irq_max];
+	u32 irq_cnt = max(tp->rxq_cnt, tp->txq_cnt);
 
-	tp->irq_cnt = netif_get_num_default_rss_queues();
-	if (tp->irq_cnt > 1) {
+	if (irq_cnt > 1) {
 		/* We want as many rx rings enabled as there are cpus.
 		 * In multiqueue MSI-X mode, the first MSI-X vector
 		 * only deals with link interrupts, etc, so we add
 		 * one to the number of vectors we are requesting.
 		 */
-		tp->irq_cnt = min_t(unsigned, tp->irq_cnt + 1, tp->irq_max);
-		tp->rxq_cnt = tp->irq_cnt - 1;
+		irq_cnt = min_t(unsigned, irq_cnt + 1, tp->irq_max);
 	}
 
+	return irq_cnt;
+}
+
+static bool tg3_enable_msix(struct tg3 *tp)
+{
+	int i, rc;
+	struct msix_entry msix_ent[tp->irq_max];
+
+	tp->rxq_cnt = netif_get_num_default_rss_queues();
+	if (tp->rxq_cnt > tp->rxq_max)
+		tp->rxq_cnt = tp->rxq_max;
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
+		tp->txq_cnt = min(tp->rxq_cnt, tp->txq_max);
+
+	tp->irq_cnt = tg3_irq_count(tp);
+
 	for (i = 0; i < tp->irq_max; i++) {
 		msix_ent[i].entry  = i;
 		msix_ent[i].vector = 0;
@@ -10234,6 +10247,8 @@ static bool tg3_enable_msix(struct tg3 *tp)
 			      tp->irq_cnt, rc);
 		tp->irq_cnt = rc;
 		tp->rxq_cnt = max(rc - 1, 1);
+		if (tp->txq_cnt)
+			tp->txq_cnt = min(tp->rxq_cnt, tp->txq_max);
 	}
 
 	for (i = 0; i < tp->irq_max; i++)
@@ -10244,16 +10259,15 @@ static bool tg3_enable_msix(struct tg3 *tp)
 		return false;
 	}
 
-	if (tp->irq_cnt > 1) {
-		tg3_flag_set(tp, ENABLE_RSS);
+	if (tp->irq_cnt == 1)
+		return true;
 
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720) {
-			tg3_flag_set(tp, ENABLE_TSS);
-			tp->txq_cnt = tp->rxq_cnt;
-			netif_set_real_num_tx_queues(tp->dev, tp->txq_cnt);
-		}
-	}
+	tg3_flag_set(tp, ENABLE_RSS);
+
+	if (tp->txq_cnt > 1)
+		tg3_flag_set(tp, ENABLE_TSS);
+
+	netif_set_real_num_tx_queues(tp->dev, tp->txq_cnt);
 
 	return true;
 }
@@ -11275,11 +11289,11 @@ static int tg3_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
 	switch (info->cmd) {
 	case ETHTOOL_GRXRINGS:
 		if (netif_running(tp->dev))
-			info->data = tp->irq_cnt;
+			info->data = tp->rxq_cnt;
 		else {
 			info->data = num_online_cpus();
-			if (info->data > TG3_IRQ_MAX_VECS_RSS)
-				info->data = TG3_IRQ_MAX_VECS_RSS;
+			if (info->data > TG3_RSS_MAX_NUM_QS)
+				info->data = TG3_RSS_MAX_NUM_QS;
 		}
 
 		/* The first interrupt vector only
@@ -14600,10 +14614,20 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		if (tg3_flag(tp, 57765_PLUS)) {
 			tg3_flag_set(tp, SUPPORT_MSIX);
 			tp->irq_max = TG3_IRQ_MAX_VECS;
-			tg3_rss_init_dflt_indir_tbl(tp);
 		}
 	}
 
+	tp->txq_max = 1;
+	tp->rxq_max = 1;
+	if (tp->irq_max > 1) {
+		tp->rxq_max = TG3_RSS_MAX_NUM_QS;
+		tg3_rss_init_dflt_indir_tbl(tp, TG3_RSS_MAX_NUM_QS);
+
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
+			tp->txq_max = tp->irq_max - 1;
+	}
+
 	if (tg3_flag(tp, 5755_PLUS) ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		tg3_flag_set(tp, SHORT_DMA_BUG);
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 5838dea..2abe94c 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2860,7 +2860,8 @@ struct tg3_rx_prodring_set {
 	dma_addr_t			rx_jmb_mapping;
 };
 
-#define TG3_IRQ_MAX_VECS_RSS		5
+#define TG3_RSS_MAX_NUM_QS		4
+#define TG3_IRQ_MAX_VECS_RSS		(TG3_RSS_MAX_NUM_QS + 1)
 #define TG3_IRQ_MAX_VECS		TG3_IRQ_MAX_VECS_RSS
 
 struct tg3_napi {
@@ -3038,6 +3039,7 @@ struct tg3 {
 							    u32);
 	u32				dma_limit;
 	u32				txq_cnt;
+	u32				txq_max;
 
 	/* begin "rx thread" cacheline section */
 	struct tg3_napi			napi[TG3_IRQ_MAX_VECS];
@@ -3053,6 +3055,7 @@ struct tg3 {
 	u32				rx_offset;
 	u32				rx_pkt_map_sz;
 	u32				rxq_cnt;
+	u32				rxq_max;
 	bool				rx_refill;
 
 
-- 
1.7.1
