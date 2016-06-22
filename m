From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 08/13] liquidio: tx rx interrupt moderation
Date: Tue, 21 Jun 2016 22:53:10 -0700
Message-ID: <1466574795-4306-9-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0093.outbound.protection.outlook.com ([65.55.169.93]:30902
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751587AbcFVFzY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 01:55:24 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch has new tx/rx interrupt moderation defaults of
count/timer for better throughput and utilisation.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 270 ++++++++++++---------
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  22 +-
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  49 ++--
 3 files changed, 200 insertions(+), 141 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 56f465b..9c6b58a 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -616,50 +616,50 @@ static int lio_get_intr_coalesce(struct net_device *netdev,
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
-	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
 	struct octeon_instr_queue *iq;
 	struct oct_intrmod_cfg *intrmod_cfg;
 
 	intrmod_cfg = &oct->intrmod;
 
 	switch (oct->chip_id) {
-	/* case OCTEON_CN73XX: Todo */
-	/*      break; */
 	case OCTEON_CN68XX:
-	case OCTEON_CN66XX:
-		if (!intrmod_cfg->intrmod_enable) {
+	case OCTEON_CN66XX: {
+		struct octeon_cn6xxx *cn6xxx =
+			(struct octeon_cn6xxx *)oct->chip;
+
+		if (!intrmod_cfg->rx_enable) {
 			intr_coal->rx_coalesce_usecs =
 				CFG_GET_OQ_INTR_TIME(cn6xxx->conf);
 			intr_coal->rx_max_coalesced_frames =
 				CFG_GET_OQ_INTR_PKT(cn6xxx->conf);
-		} else {
-			intr_coal->use_adaptive_rx_coalesce =
-				intrmod_cfg->intrmod_enable;
-			intr_coal->rate_sample_interval =
-				intrmod_cfg->intrmod_check_intrvl;
-			intr_coal->pkt_rate_high =
-				intrmod_cfg->intrmod_maxpkt_ratethr;
-			intr_coal->pkt_rate_low =
-				intrmod_cfg->intrmod_minpkt_ratethr;
-			intr_coal->rx_max_coalesced_frames_high =
-				intrmod_cfg->intrmod_maxcnt_trigger;
-			intr_coal->rx_coalesce_usecs_high =
-				intrmod_cfg->intrmod_maxtmr_trigger;
-			intr_coal->rx_coalesce_usecs_low =
-				intrmod_cfg->intrmod_mintmr_trigger;
-			intr_coal->rx_max_coalesced_frames_low =
-				intrmod_cfg->intrmod_mincnt_trigger;
 		}
 
 		iq = oct->instr_queue[lio->linfo.txpciq[0].s.q_no];
 		intr_coal->tx_max_coalesced_frames = iq->fill_threshold;
 		break;
-
+	}
 	default:
 		netif_info(lio, drv, lio->netdev, "Unknown Chip !!\n");
 		return -EINVAL;
 	}
-
+	if (intrmod_cfg->rx_enable) {
+		intr_coal->use_adaptive_rx_coalesce =
+			intrmod_cfg->rx_enable;
+		intr_coal->rate_sample_interval =
+			intrmod_cfg->check_intrvl;
+		intr_coal->pkt_rate_high =
+			intrmod_cfg->maxpkt_ratethr;
+		intr_coal->pkt_rate_low =
+			intrmod_cfg->minpkt_ratethr;
+		intr_coal->rx_max_coalesced_frames_high =
+			intrmod_cfg->rx_maxcnt_trigger;
+		intr_coal->rx_coalesce_usecs_high =
+			intrmod_cfg->rx_maxtmr_trigger;
+		intr_coal->rx_coalesce_usecs_low =
+			intrmod_cfg->rx_mintmr_trigger;
+		intr_coal->rx_max_coalesced_frames_low =
+			intrmod_cfg->rx_mincnt_trigger;
+	}
 	return 0;
 }
 
@@ -679,19 +679,20 @@ static void octnet_intrmod_callback(struct octeon_device *oct_dev,
 	else
 		dev_info(&oct_dev->pci_dev->dev,
 			 "Rx-Adaptive Interrupt moderation enabled:%llx\n",
-			 oct_dev->intrmod.intrmod_enable);
+			 oct_dev->intrmod.rx_enable);
 
 	octeon_free_soft_command(oct_dev, sc);
 }
 
 /*  Configure interrupt moderation parameters */
-static int octnet_set_intrmod_cfg(void *oct, struct oct_intrmod_cfg *intr_cfg)
+static int octnet_set_intrmod_cfg(struct lio *lio,
+				  struct oct_intrmod_cfg *intr_cfg)
 {
 	struct octeon_soft_command *sc;
 	struct oct_intrmod_cmd *cmd;
 	struct oct_intrmod_cfg *cfg;
 	int retval;
-	struct octeon_device *oct_dev = (struct octeon_device *)oct;
+	struct octeon_device *oct_dev = lio->oct_dev;
 
 	/* Alloc soft command */
 	sc = (struct octeon_soft_command *)
@@ -712,6 +713,8 @@ static int octnet_set_intrmod_cfg(void *oct, struct oct_intrmod_cfg *intr_cfg)
 	cmd->cfg = cfg;
 	cmd->oct_dev = oct_dev;
 
+	sc->iq_no = lio->linfo.txpciq[0].s.q_no;
+
 	octeon_prepare_soft_command(oct_dev, sc, OPCODE_NIC,
 				    OPCODE_NIC_INTRMOD_CFG, 0, 0, 0);
 
@@ -730,7 +733,7 @@ static int octnet_set_intrmod_cfg(void *oct, struct oct_intrmod_cfg *intr_cfg)
 
 /* Enable/Disable auto interrupt Moderation */
 static int oct_cfg_adaptive_intr(struct lio *lio, struct ethtool_coalesce
-				 *intr_coal, int adaptive)
+				 *intr_coal)
 {
 	int ret = 0;
 	struct octeon_device *oct = lio->oct_dev;
@@ -738,59 +741,73 @@ static int oct_cfg_adaptive_intr(struct lio *lio, struct ethtool_coalesce
 
 	intrmod_cfg = &oct->intrmod;
 
-	if (adaptive) {
+	if (oct->intrmod.rx_enable || oct->intrmod.tx_enable) {
 		if (intr_coal->rate_sample_interval)
-			intrmod_cfg->intrmod_check_intrvl =
+			intrmod_cfg->check_intrvl =
 				intr_coal->rate_sample_interval;
 		else
-			intrmod_cfg->intrmod_check_intrvl =
+			intrmod_cfg->check_intrvl =
 				LIO_INTRMOD_CHECK_INTERVAL;
 
 		if (intr_coal->pkt_rate_high)
-			intrmod_cfg->intrmod_maxpkt_ratethr =
+			intrmod_cfg->maxpkt_ratethr =
 				intr_coal->pkt_rate_high;
 		else
-			intrmod_cfg->intrmod_maxpkt_ratethr =
+			intrmod_cfg->maxpkt_ratethr =
 				LIO_INTRMOD_MAXPKT_RATETHR;
 
 		if (intr_coal->pkt_rate_low)
-			intrmod_cfg->intrmod_minpkt_ratethr =
+			intrmod_cfg->minpkt_ratethr =
 				intr_coal->pkt_rate_low;
 		else
-			intrmod_cfg->intrmod_minpkt_ratethr =
+			intrmod_cfg->minpkt_ratethr =
 				LIO_INTRMOD_MINPKT_RATETHR;
-
+	}
+	if (oct->intrmod.rx_enable) {
 		if (intr_coal->rx_max_coalesced_frames_high)
-			intrmod_cfg->intrmod_maxcnt_trigger =
+			intrmod_cfg->rx_maxcnt_trigger =
 				intr_coal->rx_max_coalesced_frames_high;
 		else
-			intrmod_cfg->intrmod_maxcnt_trigger =
-				LIO_INTRMOD_MAXCNT_TRIGGER;
+			intrmod_cfg->rx_maxcnt_trigger =
+				LIO_INTRMOD_RXMAXCNT_TRIGGER;
 
 		if (intr_coal->rx_coalesce_usecs_high)
-			intrmod_cfg->intrmod_maxtmr_trigger =
+			intrmod_cfg->rx_maxtmr_trigger =
 				intr_coal->rx_coalesce_usecs_high;
 		else
-			intrmod_cfg->intrmod_maxtmr_trigger =
-				LIO_INTRMOD_MAXTMR_TRIGGER;
+			intrmod_cfg->rx_maxtmr_trigger =
+				LIO_INTRMOD_RXMAXTMR_TRIGGER;
 
 		if (intr_coal->rx_coalesce_usecs_low)
-			intrmod_cfg->intrmod_mintmr_trigger =
+			intrmod_cfg->rx_mintmr_trigger =
 				intr_coal->rx_coalesce_usecs_low;
 		else
-			intrmod_cfg->intrmod_mintmr_trigger =
-				LIO_INTRMOD_MINTMR_TRIGGER;
+			intrmod_cfg->rx_mintmr_trigger =
+				LIO_INTRMOD_RXMINTMR_TRIGGER;
 
 		if (intr_coal->rx_max_coalesced_frames_low)
-			intrmod_cfg->intrmod_mincnt_trigger =
+			intrmod_cfg->rx_mincnt_trigger =
 				intr_coal->rx_max_coalesced_frames_low;
 		else
-			intrmod_cfg->intrmod_mincnt_trigger =
-				LIO_INTRMOD_MINCNT_TRIGGER;
+			intrmod_cfg->rx_mincnt_trigger =
+				LIO_INTRMOD_RXMINCNT_TRIGGER;
+	}
+	if (oct->intrmod.tx_enable) {
+		if (intr_coal->tx_max_coalesced_frames_high)
+			intrmod_cfg->tx_maxcnt_trigger =
+				intr_coal->tx_max_coalesced_frames_high;
+		else
+			intrmod_cfg->tx_maxcnt_trigger =
+				LIO_INTRMOD_TXMAXCNT_TRIGGER;
+		if (intr_coal->tx_max_coalesced_frames_low)
+			intrmod_cfg->tx_mincnt_trigger =
+				intr_coal->tx_max_coalesced_frames_low;
+		else
+			intrmod_cfg->tx_mincnt_trigger =
+				LIO_INTRMOD_TXMINCNT_TRIGGER;
 	}
 
-	intrmod_cfg->intrmod_enable = adaptive;
-	ret = octnet_set_intrmod_cfg(oct, intrmod_cfg);
+	ret = octnet_set_intrmod_cfg(lio, intrmod_cfg);
 
 	return ret;
 }
@@ -798,54 +815,82 @@ static int oct_cfg_adaptive_intr(struct lio *lio, struct ethtool_coalesce
 static int
 oct_cfg_rx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal)
 {
-	int ret;
 	struct octeon_device *oct = lio->oct_dev;
-	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
 	u32 rx_max_coalesced_frames;
 
-	if (!intr_coal->rx_max_coalesced_frames)
-		rx_max_coalesced_frames = CN6XXX_OQ_INTR_PKT;
-	else
-		rx_max_coalesced_frames = intr_coal->rx_max_coalesced_frames;
-
-	/* Disable adaptive interrupt modulation */
-	ret = oct_cfg_adaptive_intr(lio, intr_coal, 0);
-	if (ret)
-		return ret;
-
 	/* Config Cnt based interrupt values */
-	octeon_write_csr(oct, CN6XXX_SLI_OQ_INT_LEVEL_PKTS,
-			 rx_max_coalesced_frames);
-	CFG_SET_OQ_INTR_PKT(cn6xxx->conf, rx_max_coalesced_frames);
+	switch (oct->chip_id) {
+	case OCTEON_CN68XX:
+	case OCTEON_CN66XX: {
+		struct octeon_cn6xxx *cn6xxx =
+			(struct octeon_cn6xxx *)oct->chip;
+
+		if (!intr_coal->rx_max_coalesced_frames)
+			rx_max_coalesced_frames = CN6XXX_OQ_INTR_PKT;
+		else
+			rx_max_coalesced_frames =
+				intr_coal->rx_max_coalesced_frames;
+		octeon_write_csr(oct, CN6XXX_SLI_OQ_INT_LEVEL_PKTS,
+				 rx_max_coalesced_frames);
+		CFG_SET_OQ_INTR_PKT(cn6xxx->conf, rx_max_coalesced_frames);
+		break;
+	}
+	default:
+		return -EINVAL;
+	}
 	return 0;
 }
 
 static int oct_cfg_rx_intrtime(struct lio *lio, struct ethtool_coalesce
 			       *intr_coal)
 {
-	int ret;
 	struct octeon_device *oct = lio->oct_dev;
-	struct octeon_cn6xxx *cn6xxx = (struct octeon_cn6xxx *)oct->chip;
 	u32 time_threshold, rx_coalesce_usecs;
 
-	if (!intr_coal->rx_coalesce_usecs)
-		rx_coalesce_usecs = CN6XXX_OQ_INTR_TIME;
-	else
-		rx_coalesce_usecs = intr_coal->rx_coalesce_usecs;
+	/* Config Time based interrupt values */
+	switch (oct->chip_id) {
+	case OCTEON_CN68XX:
+	case OCTEON_CN66XX: {
+		struct octeon_cn6xxx *cn6xxx =
+			(struct octeon_cn6xxx *)oct->chip;
+		if (!intr_coal->rx_coalesce_usecs)
+			rx_coalesce_usecs = CN6XXX_OQ_INTR_TIME;
+		else
+			rx_coalesce_usecs = intr_coal->rx_coalesce_usecs;
 
-	/* Disable adaptive interrupt modulation */
-	ret = oct_cfg_adaptive_intr(lio, intr_coal, 0);
-	if (ret)
-		return ret;
+		time_threshold = lio_cn6xxx_get_oq_ticks(oct,
+							 rx_coalesce_usecs);
+		octeon_write_csr(oct,
+				 CN6XXX_SLI_OQ_INT_LEVEL_TIME,
+				 time_threshold);
 
-	/* Config Time based interrupt values */
-	time_threshold = lio_cn6xxx_get_oq_ticks(oct, rx_coalesce_usecs);
-	octeon_write_csr(oct, CN6XXX_SLI_OQ_INT_LEVEL_TIME, time_threshold);
-	CFG_SET_OQ_INTR_TIME(cn6xxx->conf, rx_coalesce_usecs);
+		CFG_SET_OQ_INTR_TIME(cn6xxx->conf, rx_coalesce_usecs);
+		break;
+	}
+	default:
+		return -EINVAL;
+	}
 
 	return 0;
 }
 
+static int
+oct_cfg_tx_intrcnt(struct lio *lio, struct ethtool_coalesce *intr_coal
+		   __attribute__((unused)))
+{
+	struct octeon_device *oct = lio->oct_dev;
+
+	/* Config Cnt based interrupt values */
+	switch (oct->chip_id) {
+	case OCTEON_CN68XX:
+	case OCTEON_CN66XX:
+		break;
+	default:
+		return -EINVAL;
+	}
+	return 0;
+}
+
 static int lio_set_intr_coalesce(struct net_device *netdev,
 				 struct ethtool_coalesce *intr_coal)
 {
@@ -853,59 +898,48 @@ static int lio_set_intr_coalesce(struct net_device *netdev,
 	int ret;
 	struct octeon_device *oct = lio->oct_dev;
 	u32 j, q_no;
+	int db_max, db_min;
 
-	if ((intr_coal->tx_max_coalesced_frames >= CN6XXX_DB_MIN) &&
-	    (intr_coal->tx_max_coalesced_frames <= CN6XXX_DB_MAX)) {
-		for (j = 0; j < lio->linfo.num_txpciq; j++) {
-			q_no = lio->linfo.txpciq[j].s.q_no;
-			oct->instr_queue[q_no]->fill_threshold =
-				intr_coal->tx_max_coalesced_frames;
+	switch (oct->chip_id) {
+	case OCTEON_CN68XX:
+	case OCTEON_CN66XX:
+		db_min = CN6XXX_DB_MIN;
+		db_max = CN6XXX_DB_MAX;
+		if ((intr_coal->tx_max_coalesced_frames >= db_min) &&
+		    (intr_coal->tx_max_coalesced_frames <= db_max)) {
+			for (j = 0; j < lio->linfo.num_txpciq; j++) {
+				q_no = lio->linfo.txpciq[j].s.q_no;
+				oct->instr_queue[q_no]->fill_threshold =
+					intr_coal->tx_max_coalesced_frames;
+			}
+		} else {
+			dev_err(&oct->pci_dev->dev,
+				"LIQUIDIO: Invalid tx-frames:%d. Range is min:%d max:%d\n",
+				intr_coal->tx_max_coalesced_frames, db_min,
+				db_max);
+			return -EINVAL;
 		}
-	} else {
-		dev_err(&oct->pci_dev->dev,
-			"LIQUIDIO: Invalid tx-frames:%d. Range is min:%d max:%d\n",
-			intr_coal->tx_max_coalesced_frames, CN6XXX_DB_MIN,
-			CN6XXX_DB_MAX);
+		break;
+	default:
 		return -EINVAL;
 	}
 
-	/* User requested adaptive-rx on */
-	if (intr_coal->use_adaptive_rx_coalesce) {
-		ret = oct_cfg_adaptive_intr(lio, intr_coal, 1);
-		if (ret)
-			goto ret_intrmod;
-	}
+	oct->intrmod.rx_enable = intr_coal->use_adaptive_rx_coalesce ? 1 : 0;
+	oct->intrmod.tx_enable = intr_coal->use_adaptive_tx_coalesce ? 1 : 0;
+
+	ret = oct_cfg_adaptive_intr(lio, intr_coal);
 
-	/* User requested adaptive-rx off and rx coalesce */
-	if ((intr_coal->rx_coalesce_usecs) &&
-	    (!intr_coal->use_adaptive_rx_coalesce)) {
+	if (!intr_coal->use_adaptive_rx_coalesce) {
 		ret = oct_cfg_rx_intrtime(lio, intr_coal);
 		if (ret)
 			goto ret_intrmod;
-	}
 
-	/* User requested adaptive-rx off and rx coalesce */
-	if ((intr_coal->rx_max_coalesced_frames) &&
-	    (!intr_coal->use_adaptive_rx_coalesce)) {
 		ret = oct_cfg_rx_intrcnt(lio, intr_coal);
 		if (ret)
 			goto ret_intrmod;
 	}
-
-	/* User requested adaptive-rx off, so use default coalesce params */
-	if ((!intr_coal->rx_max_coalesced_frames) &&
-	    (!intr_coal->use_adaptive_rx_coalesce) &&
-	    (!intr_coal->rx_coalesce_usecs)) {
-		dev_info(&oct->pci_dev->dev,
-			 "Turning off adaptive-rx interrupt moderation\n");
-		dev_info(&oct->pci_dev->dev,
-			 "Using RX Coalesce Default values rx_coalesce_usecs:%d rx_max_coalesced_frames:%d\n",
-			 CN6XXX_OQ_INTR_TIME, CN6XXX_OQ_INTR_PKT);
-		ret = oct_cfg_rx_intrtime(lio, intr_coal);
-		if (ret)
-			goto ret_intrmod;
-
-		ret = oct_cfg_rx_intrcnt(lio, intr_coal);
+	if (!intr_coal->use_adaptive_tx_coalesce) {
+		ret = oct_cfg_tx_intrcnt(lio, intr_coal);
 		if (ret)
 			goto ret_intrmod;
 	}
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 56b1d67..a1e31ac 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3579,15 +3579,19 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 
 	/* Initialize interrupt moderation params */
 	intrmod_cfg = &((struct octeon_device *)oct)->intrmod;
-	intrmod_cfg->intrmod_enable = 1;
-	intrmod_cfg->intrmod_check_intrvl = LIO_INTRMOD_CHECK_INTERVAL;
-	intrmod_cfg->intrmod_maxpkt_ratethr = LIO_INTRMOD_MAXPKT_RATETHR;
-	intrmod_cfg->intrmod_minpkt_ratethr = LIO_INTRMOD_MINPKT_RATETHR;
-	intrmod_cfg->intrmod_maxcnt_trigger = LIO_INTRMOD_MAXCNT_TRIGGER;
-	intrmod_cfg->intrmod_maxtmr_trigger = LIO_INTRMOD_MAXTMR_TRIGGER;
-	intrmod_cfg->intrmod_mintmr_trigger = LIO_INTRMOD_MINTMR_TRIGGER;
-	intrmod_cfg->intrmod_mincnt_trigger = LIO_INTRMOD_MINCNT_TRIGGER;
-
+	intrmod_cfg->rx_enable = 1;
+	intrmod_cfg->check_intrvl =   LIO_INTRMOD_CHECK_INTERVAL;
+	intrmod_cfg->maxpkt_ratethr = LIO_INTRMOD_MAXPKT_RATETHR;
+	intrmod_cfg->minpkt_ratethr = LIO_INTRMOD_MINPKT_RATETHR;
+	intrmod_cfg->rx_maxcnt_trigger = LIO_INTRMOD_RXMAXCNT_TRIGGER;
+	intrmod_cfg->rx_maxtmr_trigger = LIO_INTRMOD_RXMAXTMR_TRIGGER;
+	intrmod_cfg->rx_mintmr_trigger = LIO_INTRMOD_RXMINTMR_TRIGGER;
+	intrmod_cfg->rx_mincnt_trigger = LIO_INTRMOD_RXMINCNT_TRIGGER;
+	intrmod_cfg->tx_enable = 1;
+	intrmod_cfg->tx_maxcnt_trigger = LIO_INTRMOD_TXMAXCNT_TRIGGER;
+	intrmod_cfg->tx_mincnt_trigger = LIO_INTRMOD_TXMINCNT_TRIGGER;
+	intrmod_cfg->rx_frames = CFG_GET_OQ_INTR_PKT(octeon_get_conf(oct));
+	intrmod_cfg->rx_usecs = CFG_GET_OQ_INTR_TIME(octeon_get_conf(oct));
 	dev_dbg(&oct->pci_dev->dev, "Network interfaces ready\n");
 
 	return retval;
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 1ef9001..b5ab704 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -796,23 +796,44 @@ struct oct_mdio_cmd {
 
 #define OCT_LINK_STATS_SIZE   (sizeof(struct oct_link_stats))
 
+/* intrmod: max. packet rate threshold */
+#define LIO_INTRMOD_MAXPKT_RATETHR	196608
+/* intrmod: min. packet rate threshold */
+#define LIO_INTRMOD_MINPKT_RATETHR	9216
+/* intrmod: max. packets to trigger interrupt */
+#define LIO_INTRMOD_RXMAXCNT_TRIGGER	384
+/* intrmod: min. packets to trigger interrupt */
+#define LIO_INTRMOD_RXMINCNT_TRIGGER	1
+/* intrmod: max. time to trigger interrupt */
+#define LIO_INTRMOD_RXMAXTMR_TRIGGER	128
+/* 66xx:intrmod: min. time to trigger interrupt
+ * (value of 1 is optimum for TCP_RR)
+ */
+#define LIO_INTRMOD_RXMINTMR_TRIGGER	1
+
+/* intrmod: max. packets to trigger interrupt */
+#define LIO_INTRMOD_TXMAXCNT_TRIGGER	64
+/* intrmod: min. packets to trigger interrupt */
+#define LIO_INTRMOD_TXMINCNT_TRIGGER	0
+
+/* intrmod: poll interval in seconds */
 #define LIO_INTRMOD_CHECK_INTERVAL  1
-#define LIO_INTRMOD_MAXPKT_RATETHR  196608 /* max pkt rate threshold */
-#define LIO_INTRMOD_MINPKT_RATETHR  9216   /* min pkt rate threshold */
-#define LIO_INTRMOD_MAXCNT_TRIGGER  384    /* max pkts to trigger interrupt */
-#define LIO_INTRMOD_MINCNT_TRIGGER  1      /* min pkts to trigger interrupt */
-#define LIO_INTRMOD_MAXTMR_TRIGGER  128    /* max time to trigger interrupt */
-#define LIO_INTRMOD_MINTMR_TRIGGER  32     /* min time to trigger interrupt */
 
 struct oct_intrmod_cfg {
-	u64 intrmod_enable;
-	u64 intrmod_check_intrvl;
-	u64 intrmod_maxpkt_ratethr;
-	u64 intrmod_minpkt_ratethr;
-	u64 intrmod_maxcnt_trigger;
-	u64 intrmod_maxtmr_trigger;
-	u64 intrmod_mincnt_trigger;
-	u64 intrmod_mintmr_trigger;
+	u64 rx_enable;
+	u64 tx_enable;
+	u64 check_intrvl;
+	u64 maxpkt_ratethr;
+	u64 minpkt_ratethr;
+	u64 rx_maxcnt_trigger;
+	u64 rx_mincnt_trigger;
+	u64 rx_maxtmr_trigger;
+	u64 rx_mintmr_trigger;
+	u64 tx_mincnt_trigger;
+	u64 tx_maxcnt_trigger;
+	u64 rx_frames;
+	u64 tx_frames;
+	u64 rx_usecs;
 };
 
 #define BASE_QUEUE_NOT_REQUESTED 65535
-- 
1.8.3.1
