From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 5/5] cxgb4: Add support in debugfs to dump the congestion control table
Date: Fri,  6 Feb 2015 19:32:55 +0530
Message-ID: <1423231375-28004-6-git-send-email-hariprasad@chelsio.com>
References: <1423231375-28004-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7353 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755086AbbBFN5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:57:32 -0500
In-Reply-To: <1423231375-28004-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump Transport Processor modules congestion control configuration

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   28 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   21 +++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |    3 ++
 4 files changed, 53 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index b8fee60..d6cda17 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1174,6 +1174,7 @@ void t4_read_cimq_cfg(struct adapter *adap, u16 *base, u16 *size, u16 *thres);
 const char *t4_get_port_type_description(enum fw_port_type port_type);
 void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p);
 void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log);
+void t4_read_cong_tbl(struct adapter *adap, u16 incr[NMTUS][NCCTRL_WIN]);
 void t4_tp_wr_bits_indirect(struct adapter *adap, unsigned int addr,
 			    unsigned int mask, unsigned int val);
 void t4_tp_read_la(struct adapter *adap, u64 *la_buf, unsigned int *wrptr);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 83e2932..a1029ee 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -663,6 +663,33 @@ static const struct file_operations pm_stats_debugfs_fops = {
 	.write   = pm_stats_clear
 };
 
+static int cctrl_tbl_show(struct seq_file *seq, void *v)
+{
+	static const char * const dec_fac[] = {
+		"0.5", "0.5625", "0.625", "0.6875", "0.75", "0.8125", "0.875",
+		"0.9375" };
+
+	int i;
+	u16 incr[NMTUS][NCCTRL_WIN];
+	struct adapter *adap = seq->private;
+
+	t4_read_cong_tbl(adap, incr);
+
+	for (i = 0; i < NCCTRL_WIN; ++i) {
+		seq_printf(seq, "%2d: %4u %4u %4u %4u %4u %4u %4u %4u\n", i,
+			   incr[0][i], incr[1][i], incr[2][i], incr[3][i],
+			   incr[4][i], incr[5][i], incr[6][i], incr[7][i]);
+		seq_printf(seq, "%8u %4u %4u %4u %4u %4u %4u %4u %5u %s\n",
+			   incr[8][i], incr[9][i], incr[10][i], incr[11][i],
+			   incr[12][i], incr[13][i], incr[14][i], incr[15][i],
+			   adap->params.a_wnd[i],
+			   dec_fac[adap->params.b_wnd[i]]);
+	}
+	return 0;
+}
+
+DEFINE_SIMPLE_DEBUGFS_FILE(cctrl_tbl);
+
 /* Format a value in a unit that differs from the value's native unit by the
  * given factor.
  */
@@ -1990,6 +2017,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "ulprx_la", &ulprx_la_fops, S_IRUSR, 0 },
 		{ "sensors", &sensors_debugfs_fops, S_IRUSR, 0 },
 		{ "pm_stats", &pm_stats_debugfs_fops, S_IRUSR, 0 },
+		{ "cctrl", &cctrl_tbl_debugfs_fops, S_IRUSR, 0 },
 #if IS_ENABLED(CONFIG_IPV6)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
 #endif
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 5871c00..4d643b6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2456,6 +2456,27 @@ void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log)
 }
 
 /**
+ *	t4_read_cong_tbl - reads the congestion control table
+ *	@adap: the adapter
+ *	@incr: where to store the alpha values
+ *
+ *	Reads the additive increments programmed into the HW congestion
+ *	control table.
+ */
+void t4_read_cong_tbl(struct adapter *adap, u16 incr[NMTUS][NCCTRL_WIN])
+{
+	unsigned int mtu, w;
+
+	for (mtu = 0; mtu < NMTUS; ++mtu)
+		for (w = 0; w < NCCTRL_WIN; ++w) {
+			t4_write_reg(adap, TP_CCTRL_TABLE_A,
+				     ROWINDEX_V(0xffff) | (mtu << 5) | w);
+			incr[mtu][w] = (u16)t4_read_reg(adap,
+						TP_CCTRL_TABLE_A) & 0x1fff;
+		}
+}
+
+/**
  *	t4_tp_wr_bits_indirect - set/clear bits in an indirect TP register
  *	@adap: the adapter
  *	@addr: the indirect TP register address
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 3f18d5c..231a725 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1292,6 +1292,9 @@
 #define KEEPALIVEMAXR2_V(x) ((x) << KEEPALIVEMAXR2_S)
 #define KEEPALIVEMAXR2_G(x) (((x) >> KEEPALIVEMAXR2_S) & KEEPALIVEMAXR2_M)
 
+#define ROWINDEX_S    16
+#define ROWINDEX_V(x) ((x) << ROWINDEX_S)
+
 #define TP_CCTRL_TABLE_A	0x7ddc
 #define TP_MTU_TABLE_A		0x7de4
 
-- 
1.7.1
