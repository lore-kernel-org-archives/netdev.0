From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/3] cxgb4: Add debugfs entry to dump channel rate
Date: Tue,  9 Jun 2015 18:27:52 +0530
Message-ID: <1433854672-6649-4-git-send-email-hariprasad@chelsio.com>
References: <1433854672-6649-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:30106 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751640AbbFIHog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 03:44:36 -0400
In-Reply-To: <1433854672-6649-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 34 ++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 46 ++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       | 36 +++++++++++++++++
 4 files changed, 117 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index d84c945..2e70228 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1366,6 +1366,7 @@ void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
 
 void t4_ulprx_read_la(struct adapter *adap, u32 *la_buf);
 
+void t4_get_chan_txrate(struct adapter *adap, u64 *nic_rate, u64 *ofld_rate);
 void t4_mk_filtdelwr(unsigned int ftid, struct fw_filter_wr *wr, int qid);
 
 void t4_wol_magic_enable(struct adapter *adap, unsigned int port,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index eb39564..484eb8c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -752,6 +752,39 @@ static const struct file_operations pm_stats_debugfs_fops = {
 	.write   = pm_stats_clear
 };
 
+static int tx_rate_show(struct seq_file *seq, void *v)
+{
+	u64 nrate[NCHAN], orate[NCHAN];
+	struct adapter *adap = seq->private;
+
+	t4_get_chan_txrate(adap, nrate, orate);
+	if (adap->params.arch.nchan == NCHAN) {
+		seq_puts(seq, "              channel 0   channel 1   "
+			 "channel 2   channel 3\n");
+		seq_printf(seq, "NIC B/s:     %10llu  %10llu  %10llu  %10llu\n",
+			   (unsigned long long)nrate[0],
+			   (unsigned long long)nrate[1],
+			   (unsigned long long)nrate[2],
+			   (unsigned long long)nrate[3]);
+		seq_printf(seq, "Offload B/s: %10llu  %10llu  %10llu  %10llu\n",
+			   (unsigned long long)orate[0],
+			   (unsigned long long)orate[1],
+			   (unsigned long long)orate[2],
+			   (unsigned long long)orate[3]);
+	} else {
+		seq_puts(seq, "              channel 0   channel 1\n");
+		seq_printf(seq, "NIC B/s:     %10llu  %10llu\n",
+			   (unsigned long long)nrate[0],
+			   (unsigned long long)nrate[1]);
+		seq_printf(seq, "Offload B/s: %10llu  %10llu\n",
+			   (unsigned long long)orate[0],
+			   (unsigned long long)orate[1]);
+	}
+	return 0;
+}
+
+DEFINE_SIMPLE_DEBUGFS_FILE(tx_rate);
+
 static int cctrl_tbl_show(struct seq_file *seq, void *v)
 {
 	static const char * const dec_fac[] = {
@@ -2254,6 +2287,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "ulprx_la", &ulprx_la_fops, S_IRUSR, 0 },
 		{ "sensors", &sensors_debugfs_fops, S_IRUSR, 0 },
 		{ "pm_stats", &pm_stats_debugfs_fops, S_IRUSR, 0 },
+		{ "tx_rate", &tx_rate_debugfs_fops, S_IRUSR, 0 },
 		{ "cctrl", &cctrl_tbl_debugfs_fops, S_IRUSR, 0 },
 #if IS_ENABLED(CONFIG_IPV6)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index c967b24..9d93f4c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4191,6 +4191,52 @@ void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
 	}
 }
 
+/* Calculates a rate in bytes/s given the number of 256-byte units per 4K core
+ * clocks.  The formula is
+ *
+ * bytes/s = bytes256 * 256 * ClkFreq / 4096
+ *
+ * which is equivalent to
+ *
+ * bytes/s = 62.5 * bytes256 * ClkFreq_ms
+ */
+static u64 chan_rate(struct adapter *adap, unsigned int bytes256)
+{
+	u64 v = bytes256 * adap->params.vpd.cclk;
+
+	return v * 62 + v / 2;
+}
+
+/**
+ *	t4_get_chan_txrate - get the current per channel Tx rates
+ *	@adap: the adapter
+ *	@nic_rate: rates for NIC traffic
+ *	@ofld_rate: rates for offloaded traffic
+ *
+ *	Return the current Tx rates in bytes/s for NIC and offloaded traffic
+ *	for each channel.
+ */
+void t4_get_chan_txrate(struct adapter *adap, u64 *nic_rate, u64 *ofld_rate)
+{
+	u32 v;
+
+	v = t4_read_reg(adap, TP_TX_TRATE_A);
+	nic_rate[0] = chan_rate(adap, TNLRATE0_G(v));
+	nic_rate[1] = chan_rate(adap, TNLRATE1_G(v));
+	if (adap->params.arch.nchan == NCHAN) {
+		nic_rate[2] = chan_rate(adap, TNLRATE2_G(v));
+		nic_rate[3] = chan_rate(adap, TNLRATE3_G(v));
+	}
+
+	v = t4_read_reg(adap, TP_TX_ORATE_A);
+	ofld_rate[0] = chan_rate(adap, OFDRATE0_G(v));
+	ofld_rate[1] = chan_rate(adap, OFDRATE1_G(v));
+	if (adap->params.arch.nchan == NCHAN) {
+		ofld_rate[2] = chan_rate(adap, OFDRATE2_G(v));
+		ofld_rate[3] = chan_rate(adap, OFDRATE3_G(v));
+	}
+}
+
 /**
  *	t4_pmtx_get_stats - returns the HW stats from PMTX
  *	@adap: the adapter
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 525d06e..375a825 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1361,6 +1361,42 @@
 #define FLMTXFLSTEMPTY_V(x) ((x) << FLMTXFLSTEMPTY_S)
 #define FLMTXFLSTEMPTY_F    FLMTXFLSTEMPTY_V(1U)
 
+#define TP_TX_ORATE_A 0x7ebc
+
+#define OFDRATE3_S    24
+#define OFDRATE3_M    0xffU
+#define OFDRATE3_G(x) (((x) >> OFDRATE3_S) & OFDRATE3_M)
+
+#define OFDRATE2_S    16
+#define OFDRATE2_M    0xffU
+#define OFDRATE2_G(x) (((x) >> OFDRATE2_S) & OFDRATE2_M)
+
+#define OFDRATE1_S    8
+#define OFDRATE1_M    0xffU
+#define OFDRATE1_G(x) (((x) >> OFDRATE1_S) & OFDRATE1_M)
+
+#define OFDRATE0_S    0
+#define OFDRATE0_M    0xffU
+#define OFDRATE0_G(x) (((x) >> OFDRATE0_S) & OFDRATE0_M)
+
+#define TP_TX_TRATE_A 0x7ed0
+
+#define TNLRATE3_S    24
+#define TNLRATE3_M    0xffU
+#define TNLRATE3_G(x) (((x) >> TNLRATE3_S) & TNLRATE3_M)
+
+#define TNLRATE2_S    16
+#define TNLRATE2_M    0xffU
+#define TNLRATE2_G(x) (((x) >> TNLRATE2_S) & TNLRATE2_M)
+
+#define TNLRATE1_S    8
+#define TNLRATE1_M    0xffU
+#define TNLRATE1_G(x) (((x) >> TNLRATE1_S) & TNLRATE1_M)
+
+#define TNLRATE0_S    0
+#define TNLRATE0_M    0xffU
+#define TNLRATE0_G(x) (((x) >> TNLRATE0_S) & TNLRATE0_M)
+
 #define TP_VLAN_PRI_MAP_A 0x140
 
 #define FRAGMENTATION_S    9
-- 
2.3.4
