From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/5] cxgb4: Added support in debugfs to dump PM module stats
Date: Tue, 27 Jan 2015 13:47:48 +0530
Message-ID: <1422346669-26913-5-git-send-email-hariprasad@chelsio.com>
References: <1422346669-26913-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11119 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757850AbbA0IMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:12:23 -0500
In-Reply-To: <1422346669-26913-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    2 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   66 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   54 ++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   12 ++++
 5 files changed, 135 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index da94b9a..d98a446 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1054,6 +1054,8 @@ int t4_mc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
 	       u64 *parity);
 int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
 		u64 *parity);
+void t4_pmtx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[]);
+void t4_pmrx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[]);
 int t4_read_cim_ibq(struct adapter *adap, unsigned int qid, u32 *data,
 		    size_t n);
 int t4_read_cim_obq(struct adapter *adap, unsigned int qid, u32 *data,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 4619bb3..df90c78 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -315,6 +315,71 @@ static const struct file_operations cim_obq_fops = {
 	.release = seq_release_private
 };
 
+/* Show the PM memory stats.  These stats include:
+ *
+ * TX:
+ *   Read: memory read operation
+ *   Write Bypass: cut-through
+ *   Bypass + mem: cut-through and save copy
+ *
+ * RX:
+ *   Read: memory read
+ *   Write Bypass: cut-through
+ *   Flush: payload trim or drop
+ */
+static int pm_stats_show(struct seq_file *seq, void *v)
+{
+	static const char * const tx_pm_stats[] = {
+		"Read:", "Write bypass:", "Write mem:", "Bypass + mem:"
+	};
+	static const char * const rx_pm_stats[] = {
+		"Read:", "Write bypass:", "Write mem:", "Flush:"
+	};
+
+	int i;
+	u32 tx_cnt[PM_NSTATS], rx_cnt[PM_NSTATS];
+	u64 tx_cyc[PM_NSTATS], rx_cyc[PM_NSTATS];
+	struct adapter *adap = seq->private;
+
+	t4_pmtx_get_stats(adap, tx_cnt, tx_cyc);
+	t4_pmrx_get_stats(adap, rx_cnt, rx_cyc);
+
+	seq_printf(seq, "%13s %10s  %20s\n", " ", "Tx pcmds", "Tx bytes");
+	for (i = 0; i < PM_NSTATS - 1; i++)
+		seq_printf(seq, "%-13s %10u  %20llu\n",
+			   tx_pm_stats[i], tx_cnt[i], tx_cyc[i]);
+
+	seq_printf(seq, "%13s %10s  %20s\n", " ", "Rx pcmds", "Rx bytes");
+	for (i = 0; i < PM_NSTATS - 1; i++)
+		seq_printf(seq, "%-13s %10u  %20llu\n",
+			   rx_pm_stats[i], rx_cnt[i], rx_cyc[i]);
+	return 0;
+}
+
+static int pm_stats_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, pm_stats_show, inode->i_private);
+}
+
+static ssize_t pm_stats_clear(struct file *file, const char __user *buf,
+			      size_t count, loff_t *pos)
+{
+	struct adapter *adap = FILE_DATA(file)->i_private;
+
+	t4_write_reg(adap, PM_RX_STAT_CONFIG_A, 0);
+	t4_write_reg(adap, PM_TX_STAT_CONFIG_A, 0);
+	return count;
+}
+
+static const struct file_operations pm_stats_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = pm_stats_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = single_release,
+	.write   = pm_stats_clear
+};
+
 /* Firmware Device Log dump. */
 static const char * const devlog_level_strings[] = {
 	[FW_DEVLOG_LEVEL_EMERG]		= "EMERG",
@@ -1434,6 +1499,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "obq_ulp3", &cim_obq_fops, S_IRUSR, 3 },
 		{ "obq_sge",  &cim_obq_fops, S_IRUSR, 4 },
 		{ "obq_ncsi", &cim_obq_fops, S_IRUSR, 5 },
+		{ "pm_stats", &pm_stats_debugfs_fops, S_IRUSR, 0 },
 #if IS_ENABLED(CONFIG_IPV6)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
 #endif
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index a3d2f31..ea16c62 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2512,6 +2512,60 @@ void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
 }
 
 /**
+ *	t4_pmtx_get_stats - returns the HW stats from PMTX
+ *	@adap: the adapter
+ *	@cnt: where to store the count statistics
+ *	@cycles: where to store the cycle statistics
+ *
+ *	Returns performance statistics from PMTX.
+ */
+void t4_pmtx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[])
+{
+	int i;
+	u32 data[2];
+
+	for (i = 0; i < PM_NSTATS; i++) {
+		t4_write_reg(adap, PM_TX_STAT_CONFIG_A, i + 1);
+		cnt[i] = t4_read_reg(adap, PM_TX_STAT_COUNT_A);
+		if (is_t4(adap->params.chip)) {
+			cycles[i] = t4_read_reg64(adap, PM_TX_STAT_LSB_A);
+		} else {
+			t4_read_indirect(adap, PM_TX_DBG_CTRL_A,
+					 PM_TX_DBG_DATA_A, data, 2,
+					 PM_TX_DBG_STAT_MSB_A);
+			cycles[i] = (((u64)data[0] << 32) | data[1]);
+		}
+	}
+}
+
+/**
+ *	t4_pmrx_get_stats - returns the HW stats from PMRX
+ *	@adap: the adapter
+ *	@cnt: where to store the count statistics
+ *	@cycles: where to store the cycle statistics
+ *
+ *	Returns performance statistics from PMRX.
+ */
+void t4_pmrx_get_stats(struct adapter *adap, u32 cnt[], u64 cycles[])
+{
+	int i;
+	u32 data[2];
+
+	for (i = 0; i < PM_NSTATS; i++) {
+		t4_write_reg(adap, PM_RX_STAT_CONFIG_A, i + 1);
+		cnt[i] = t4_read_reg(adap, PM_RX_STAT_COUNT_A);
+		if (is_t4(adap->params.chip)) {
+			cycles[i] = t4_read_reg64(adap, PM_RX_STAT_LSB_A);
+		} else {
+			t4_read_indirect(adap, PM_RX_DBG_CTRL_A,
+					 PM_RX_DBG_DATA_A, data, 2,
+					 PM_RX_DBG_STAT_MSB_A);
+			cycles[i] = (((u64)data[0] << 32) | data[1]);
+		}
+	}
+}
+
+/**
  *	get_mps_bg_map - return the buffer groups associated with a port
  *	@adap: the adapter
  *	@idx: the port index
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index f9fb81e..664375f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -48,6 +48,7 @@ enum {
 	NMTUS          = 16,    /* size of MTU table */
 	NCCTRL_WIN     = 32,    /* # of congestion control windows */
 	L2T_SIZE       = 4096,  /* # of L2T entries */
+	PM_NSTATS      = 5,     /* # of PM stats */
 	MBOX_LEN       = 64,    /* mailbox size in bytes */
 	TRACE_LEN      = 112,   /* length of trace data and mask */
 	FILTER_OPT_LEN = 36,    /* filter tuple width for optional components */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 1b1560a..7aa0db1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1380,6 +1380,12 @@
 #define PBL_BOUND_ERR_CH0_F    PBL_BOUND_ERR_CH0_V(1U)
 
 #define PM_RX_INT_CAUSE_A	0x8fdc
+#define PM_RX_STAT_CONFIG_A 0x8fc8
+#define PM_RX_STAT_COUNT_A 0x8fcc
+#define PM_RX_STAT_LSB_A 0x8fd0
+#define PM_RX_DBG_CTRL_A 0x8fd0
+#define PM_RX_DBG_DATA_A 0x8fd4
+#define PM_RX_DBG_STAT_MSB_A 0x10013
 
 #define PMRX_FRAMING_ERROR_F	0x003ffff0U
 
@@ -1404,6 +1410,12 @@
 #define PMRX_E_PCMD_PAR_ERROR_F    PMRX_E_PCMD_PAR_ERROR_V(1U)
 
 #define PM_TX_INT_CAUSE_A	0x8ffc
+#define PM_TX_STAT_CONFIG_A 0x8fe8
+#define PM_TX_STAT_COUNT_A 0x8fec
+#define PM_TX_STAT_LSB_A 0x8ff0
+#define PM_TX_DBG_CTRL_A 0x8ff0
+#define PM_TX_DBG_DATA_A 0x8ff4
+#define PM_TX_DBG_STAT_MSB_A 0x1001a
 
 #define PCMD_LEN_OVFL0_S    31
 #define PCMD_LEN_OVFL0_V(x) ((x) << PCMD_LEN_OVFL0_S)
-- 
1.7.1
