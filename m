From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/9] cxgb4: Update pm_stats for T6 adapter family
Date: Wed, 23 Dec 2015 22:47:12 +0530
Message-ID: <1450891039-17196-3-git-send-email-hariprasad@chelsio.com>
References: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:22288 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933011AbbLWRQA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 12:16:00 -0500
In-Reply-To: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Updated pm_stats code to display input FIFO wait (index 5) and read
latency (index 7) counters for T6 adapters

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 30 ++++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  7 +++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |  1 +
 4 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 3b59bc4..eab57cf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -301,6 +301,7 @@ struct devlog_params {
 /* Stores chip specific parameters */
 struct arch_specific_params {
 	u8 nchan;
+	u8 pm_stats_cnt;
 	u16 mps_rplc_size;
 	u16 vfcount;
 	u32 sge_fl_db;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index a008afdb..98965a4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -758,8 +758,8 @@ static int pm_stats_show(struct seq_file *seq, void *v)
 	};
 
 	int i;
-	u32 tx_cnt[PM_NSTATS], rx_cnt[PM_NSTATS];
-	u64 tx_cyc[PM_NSTATS], rx_cyc[PM_NSTATS];
+	u32 tx_cnt[T6_PM_NSTATS], rx_cnt[T6_PM_NSTATS];
+	u64 tx_cyc[T6_PM_NSTATS], rx_cyc[T6_PM_NSTATS];
 	struct adapter *adap = seq->private;
 
 	t4_pmtx_get_stats(adap, tx_cnt, tx_cyc);
@@ -774,6 +774,32 @@ static int pm_stats_show(struct seq_file *seq, void *v)
 	for (i = 0; i < PM_NSTATS - 1; i++)
 		seq_printf(seq, "%-13s %10u  %20llu\n",
 			   rx_pm_stats[i], rx_cnt[i], rx_cyc[i]);
+
+	if (CHELSIO_CHIP_VERSION(adap->params.chip) > CHELSIO_T5) {
+		/* In T5 the granularity of the total wait is too fine.
+		 * It is not useful as it reaches the max value too fast.
+		 * Hence display this Input FIFO wait for T6 onwards.
+		 */
+		seq_printf(seq, "%13s %10s  %20s\n",
+			   " ", "Total wait", "Total Occupancy");
+		seq_printf(seq, "Tx FIFO wait  %10u  %20llu\n",
+			   tx_cnt[i], tx_cyc[i]);
+		seq_printf(seq, "Rx FIFO wait  %10u  %20llu\n",
+			   rx_cnt[i], rx_cyc[i]);
+
+		/* Skip index 6 as there is nothing useful ihere */
+		i += 2;
+
+		/* At index 7, a new stat for read latency (count, total wait)
+		 * is added.
+		 */
+		seq_printf(seq, "%13s %10s  %20s\n",
+			   " ", "Reads", "Total wait");
+		seq_printf(seq, "Tx latency    %10u  %20llu\n",
+			   tx_cnt[i], tx_cyc[i]);
+		seq_printf(seq, "Rx latency    %10u  %20llu\n",
+			   rx_cnt[i], rx_cyc[i]);
+	}
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index cf61a58..5266011 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -5254,7 +5254,7 @@ void t4_pmtx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[])
 	int i;
 	u32 data[2];
 
-	for (i = 0; i < PM_NSTATS; i++) {
+	for (i = 0; i < adap->params.arch.pm_stats_cnt; i++) {
 		t4_write_reg(adap, PM_TX_STAT_CONFIG_A, i + 1);
 		cnt[i] = t4_read_reg(adap, PM_TX_STAT_COUNT_A);
 		if (is_t4(adap->params.chip)) {
@@ -5281,7 +5281,7 @@ void t4_pmrx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[])
 	int i;
 	u32 data[2];
 
-	for (i = 0; i < PM_NSTATS; i++) {
+	for (i = 0; i < adap->params.arch.pm_stats_cnt; i++) {
 		t4_write_reg(adap, PM_RX_STAT_CONFIG_A, i + 1);
 		cnt[i] = t4_read_reg(adap, PM_RX_STAT_COUNT_A);
 		if (is_t4(adap->params.chip)) {
@@ -7060,6 +7060,7 @@ int t4_prep_adapter(struct adapter *adapter)
 				 NUM_MPS_CLS_SRAM_L_INSTANCES;
 		adapter->params.arch.mps_rplc_size = 128;
 		adapter->params.arch.nchan = NCHAN;
+		adapter->params.arch.pm_stats_cnt = PM_NSTATS;
 		adapter->params.arch.vfcount = 128;
 		break;
 	case CHELSIO_T5:
@@ -7069,6 +7070,7 @@ int t4_prep_adapter(struct adapter *adapter)
 				 NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
 		adapter->params.arch.mps_rplc_size = 128;
 		adapter->params.arch.nchan = NCHAN;
+		adapter->params.arch.pm_stats_cnt = PM_NSTATS;
 		adapter->params.arch.vfcount = 128;
 		break;
 	case CHELSIO_T6:
@@ -7078,6 +7080,7 @@ int t4_prep_adapter(struct adapter *adapter)
 				 NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
 		adapter->params.arch.mps_rplc_size = 256;
 		adapter->params.arch.nchan = 2;
+		adapter->params.arch.pm_stats_cnt = T6_PM_NSTATS;
 		adapter->params.arch.vfcount = 256;
 		break;
 	default:
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index 13708fd..2fc60e8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -48,6 +48,7 @@ enum {
 	NMTUS          = 16,    /* size of MTU table */
 	NCCTRL_WIN     = 32,    /* # of congestion control windows */
 	PM_NSTATS      = 5,     /* # of PM stats */
+	T6_PM_NSTATS   = 7,     /* # of PM stats in T6 */
 	MBOX_LEN       = 64,    /* mailbox size in bytes */
 	TRACE_LEN      = 112,   /* length of trace data and mask */
 	FILTER_OPT_LEN = 36,    /* filter tuple width for optional components */
-- 
2.3.4
