From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/5] cxgb4: Added support in debugfs to dump different timer and clock values of the adapter
Date: Tue, 27 Jan 2015 13:47:49 +0530
Message-ID: <1422346669-26913-6-git-send-email-hariprasad@chelsio.com>
References: <1422346669-26913-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:8096 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932101AbbA0IMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:12:24 -0500
In-Reply-To: <1422346669-26913-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   63 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   23 +++++++
 2 files changed, 86 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index df90c78..47c0869 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -380,6 +380,68 @@ static const struct file_operations pm_stats_debugfs_fops = {
 	.write   = pm_stats_clear
 };
 
+/* Format a value in a unit that differs from the value's native unit by the
+ * given factor.
+ */
+static char *unit_conv(char *buf, size_t len, unsigned int val,
+		       unsigned int factor)
+{
+	unsigned int rem = val % factor;
+
+	if (rem == 0) {
+		snprintf(buf, len, "%u", val / factor);
+	} else {
+		while (rem % 10 == 0)
+			rem /= 10;
+		snprintf(buf, len, "%u.%u", val / factor, rem);
+	}
+	return buf;
+}
+
+static int clk_show(struct seq_file *seq, void *v)
+{
+	char buf[32];
+	struct adapter *adap = seq->private;
+	unsigned int cclk_ps = 1000000000 / adap->params.vpd.cclk;  /* in ps */
+	u32 res = t4_read_reg(adap, TP_TIMER_RESOLUTION_A);
+	unsigned int tre = TIMERRESOLUTION_G(res);
+	unsigned int dack_re = DELAYEDACKRESOLUTION_G(res);
+	unsigned long long tp_tick_us = (cclk_ps << tre) / 1000000; /* in us */
+
+	seq_printf(seq, "Core clock period: %s ns\n",
+		   unit_conv(buf, sizeof(buf), cclk_ps, 1000));
+	seq_printf(seq, "TP timer tick: %s us\n",
+		   unit_conv(buf, sizeof(buf), (cclk_ps << tre), 1000000));
+	seq_printf(seq, "TCP timestamp tick: %s us\n",
+		   unit_conv(buf, sizeof(buf),
+			     (cclk_ps << TIMESTAMPRESOLUTION_G(res)), 1000000));
+	seq_printf(seq, "DACK tick: %s us\n",
+		   unit_conv(buf, sizeof(buf), (cclk_ps << dack_re), 1000000));
+	seq_printf(seq, "DACK timer: %u us\n",
+		   ((cclk_ps << dack_re) / 1000000) *
+		   t4_read_reg(adap, TP_DACK_TIMER_A));
+	seq_printf(seq, "Retransmit min: %llu us\n",
+		   tp_tick_us * t4_read_reg(adap, TP_RXT_MIN_A));
+	seq_printf(seq, "Retransmit max: %llu us\n",
+		   tp_tick_us * t4_read_reg(adap, TP_RXT_MAX_A));
+	seq_printf(seq, "Persist timer min: %llu us\n",
+		   tp_tick_us * t4_read_reg(adap, TP_PERS_MIN_A));
+	seq_printf(seq, "Persist timer max: %llu us\n",
+		   tp_tick_us * t4_read_reg(adap, TP_PERS_MAX_A));
+	seq_printf(seq, "Keepalive idle timer: %llu us\n",
+		   tp_tick_us * t4_read_reg(adap, TP_KEEP_IDLE_A));
+	seq_printf(seq, "Keepalive interval: %llu us\n",
+		   tp_tick_us * t4_read_reg(adap, TP_KEEP_INTVL_A));
+	seq_printf(seq, "Initial SRTT: %llu us\n",
+		   tp_tick_us * INITSRTT_G(t4_read_reg(adap, TP_INIT_SRTT_A)));
+	seq_printf(seq, "FINWAIT2 timer: %llu us\n",
+		   tp_tick_us * t4_read_reg(adap, TP_FINWAIT2_TIMER_A));
+
+	return 0;
+}
+
+DEFINE_SIMPLE_DEBUGFS_FILE(clk);
+
 /* Firmware Device Log dump. */
 static const char * const devlog_level_strings[] = {
 	[FW_DEVLOG_LEVEL_EMERG]		= "EMERG",
@@ -1478,6 +1540,7 @@ int t4_setup_debugfs(struct adapter *adap)
 	static struct t4_debugfs_entry t4_debugfs_files[] = {
 		{ "cim_la", &cim_la_fops, S_IRUSR, 0 },
 		{ "cim_qcfg", &cim_qcfg_fops, S_IRUSR, 0 },
+		{ "clk", &clk_debugfs_fops, S_IRUSR, 0 },
 		{ "devlog", &devlog_fops, S_IRUSR, 0 },
 		{ "l2t", &t4_l2t_fops, S_IRUSR, 0},
 		{ "mps_tcam", &mps_tcam_debugfs_fops, S_IRUSR, 0 },
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 7aa0db1..940b56c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1203,12 +1203,35 @@
 #define TIMERRESOLUTION_M    0xffU
 #define TIMERRESOLUTION_G(x) (((x) >> TIMERRESOLUTION_S) & TIMERRESOLUTION_M)
 
+#define TIMESTAMPRESOLUTION_S    8
+#define TIMESTAMPRESOLUTION_M    0xffU
+#define TIMESTAMPRESOLUTION_G(x) \
+	(((x) >> TIMESTAMPRESOLUTION_S) & TIMESTAMPRESOLUTION_M)
+
 #define DELAYEDACKRESOLUTION_S    0
 #define DELAYEDACKRESOLUTION_M    0xffU
 #define DELAYEDACKRESOLUTION_G(x) \
 	(((x) >> DELAYEDACKRESOLUTION_S) & DELAYEDACKRESOLUTION_M)
 
 #define TP_SHIFT_CNT_A 0x7dc0
+#define TP_RXT_MIN_A 0x7d98
+#define TP_RXT_MAX_A 0x7d9c
+#define TP_PERS_MIN_A 0x7da0
+#define TP_PERS_MAX_A 0x7da4
+#define TP_KEEP_IDLE_A 0x7da8
+#define TP_KEEP_INTVL_A 0x7dac
+#define TP_INIT_SRTT_A 0x7db0
+#define TP_DACK_TIMER_A 0x7db4
+#define TP_FINWAIT2_TIMER_A 0x7db8
+
+#define INITSRTT_S    0
+#define INITSRTT_M    0xffffU
+#define INITSRTT_G(x) (((x) >> INITSRTT_S) & INITSRTT_M)
+
+#define PERSMAX_S    0
+#define PERSMAX_M    0x3fffffffU
+#define PERSMAX_V(x) ((x) << PERSMAX_S)
+#define PERSMAX_G(x) (((x) >> PERSMAX_S) & PERSMAX_M)
 
 #define SYNSHIFTMAX_S    24
 #define SYNSHIFTMAX_M    0xffU
-- 
1.7.1
