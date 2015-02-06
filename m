From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 2/5] cxgb4: Added support in debugfs to display TP logic analyzer output
Date: Fri,  6 Feb 2015 19:32:52 +0530
Message-ID: <1423231375-28004-3-git-send-email-hariprasad@chelsio.com>
References: <1423231375-28004-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15587 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752535AbbBFN5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:57:23 -0500
In-Reply-To: <1423231375-28004-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump Transport Processor event trace.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    2 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  248 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   47 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   22 ++
 5 files changed, 320 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 63231bf..574e51f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -221,6 +221,7 @@ struct sge_params {
 struct tp_params {
 	unsigned int ntxchan;        /* # of Tx channels */
 	unsigned int tre;            /* log2 of core clocks per TP tick */
+	unsigned int la_mask;        /* what events are recorded by TP LA */
 	unsigned short tx_modq_map;  /* TX modulation scheduler queue to */
 				     /* channel map */
 
@@ -1175,6 +1176,7 @@ void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p);
 void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log);
 void t4_tp_wr_bits_indirect(struct adapter *adap, unsigned int addr,
 			    unsigned int mask, unsigned int val);
+void t4_tp_read_la(struct adapter *adap, u64 *la_buf, unsigned int *wrptr);
 void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
 			 struct tp_tcp_stats *v6);
 void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 35ec230..1304fe0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -315,6 +315,253 @@ static const struct file_operations cim_obq_fops = {
 	.release = seq_release_private
 };
 
+struct field_desc {
+	const char *name;
+	unsigned int start;
+	unsigned int width;
+};
+
+static void field_desc_show(struct seq_file *seq, u64 v,
+			    const struct field_desc *p)
+{
+	char buf[32];
+	int line_size = 0;
+
+	while (p->name) {
+		u64 mask = (1ULL << p->width) - 1;
+		int len = scnprintf(buf, sizeof(buf), "%s: %llu", p->name,
+				    ((unsigned long long)v >> p->start) & mask);
+
+		if (line_size + len >= 79) {
+			line_size = 8;
+			seq_puts(seq, "\n        ");
+		}
+		seq_printf(seq, "%s ", buf);
+		line_size += len + 1;
+		p++;
+	}
+	seq_putc(seq, '\n');
+}
+
+static struct field_desc tp_la0[] = {
+	{ "RcfOpCodeOut", 60, 4 },
+	{ "State", 56, 4 },
+	{ "WcfState", 52, 4 },
+	{ "RcfOpcSrcOut", 50, 2 },
+	{ "CRxError", 49, 1 },
+	{ "ERxError", 48, 1 },
+	{ "SanityFailed", 47, 1 },
+	{ "SpuriousMsg", 46, 1 },
+	{ "FlushInputMsg", 45, 1 },
+	{ "FlushInputCpl", 44, 1 },
+	{ "RssUpBit", 43, 1 },
+	{ "RssFilterHit", 42, 1 },
+	{ "Tid", 32, 10 },
+	{ "InitTcb", 31, 1 },
+	{ "LineNumber", 24, 7 },
+	{ "Emsg", 23, 1 },
+	{ "EdataOut", 22, 1 },
+	{ "Cmsg", 21, 1 },
+	{ "CdataOut", 20, 1 },
+	{ "EreadPdu", 19, 1 },
+	{ "CreadPdu", 18, 1 },
+	{ "TunnelPkt", 17, 1 },
+	{ "RcfPeerFin", 16, 1 },
+	{ "RcfReasonOut", 12, 4 },
+	{ "TxCchannel", 10, 2 },
+	{ "RcfTxChannel", 8, 2 },
+	{ "RxEchannel", 6, 2 },
+	{ "RcfRxChannel", 5, 1 },
+	{ "RcfDataOutSrdy", 4, 1 },
+	{ "RxDvld", 3, 1 },
+	{ "RxOoDvld", 2, 1 },
+	{ "RxCongestion", 1, 1 },
+	{ "TxCongestion", 0, 1 },
+	{ NULL }
+};
+
+static int tp_la_show(struct seq_file *seq, void *v, int idx)
+{
+	const u64 *p = v;
+
+	field_desc_show(seq, *p, tp_la0);
+	return 0;
+}
+
+static int tp_la_show2(struct seq_file *seq, void *v, int idx)
+{
+	const u64 *p = v;
+
+	if (idx)
+		seq_putc(seq, '\n');
+	field_desc_show(seq, p[0], tp_la0);
+	if (idx < (TPLA_SIZE / 2 - 1) || p[1] != ~0ULL)
+		field_desc_show(seq, p[1], tp_la0);
+	return 0;
+}
+
+static int tp_la_show3(struct seq_file *seq, void *v, int idx)
+{
+	static struct field_desc tp_la1[] = {
+		{ "CplCmdIn", 56, 8 },
+		{ "CplCmdOut", 48, 8 },
+		{ "ESynOut", 47, 1 },
+		{ "EAckOut", 46, 1 },
+		{ "EFinOut", 45, 1 },
+		{ "ERstOut", 44, 1 },
+		{ "SynIn", 43, 1 },
+		{ "AckIn", 42, 1 },
+		{ "FinIn", 41, 1 },
+		{ "RstIn", 40, 1 },
+		{ "DataIn", 39, 1 },
+		{ "DataInVld", 38, 1 },
+		{ "PadIn", 37, 1 },
+		{ "RxBufEmpty", 36, 1 },
+		{ "RxDdp", 35, 1 },
+		{ "RxFbCongestion", 34, 1 },
+		{ "TxFbCongestion", 33, 1 },
+		{ "TxPktSumSrdy", 32, 1 },
+		{ "RcfUlpType", 28, 4 },
+		{ "Eread", 27, 1 },
+		{ "Ebypass", 26, 1 },
+		{ "Esave", 25, 1 },
+		{ "Static0", 24, 1 },
+		{ "Cread", 23, 1 },
+		{ "Cbypass", 22, 1 },
+		{ "Csave", 21, 1 },
+		{ "CPktOut", 20, 1 },
+		{ "RxPagePoolFull", 18, 2 },
+		{ "RxLpbkPkt", 17, 1 },
+		{ "TxLpbkPkt", 16, 1 },
+		{ "RxVfValid", 15, 1 },
+		{ "SynLearned", 14, 1 },
+		{ "SetDelEntry", 13, 1 },
+		{ "SetInvEntry", 12, 1 },
+		{ "CpcmdDvld", 11, 1 },
+		{ "CpcmdSave", 10, 1 },
+		{ "RxPstructsFull", 8, 2 },
+		{ "EpcmdDvld", 7, 1 },
+		{ "EpcmdFlush", 6, 1 },
+		{ "EpcmdTrimPrefix", 5, 1 },
+		{ "EpcmdTrimPostfix", 4, 1 },
+		{ "ERssIp4Pkt", 3, 1 },
+		{ "ERssIp6Pkt", 2, 1 },
+		{ "ERssTcpUdpPkt", 1, 1 },
+		{ "ERssFceFipPkt", 0, 1 },
+		{ NULL }
+	};
+	static struct field_desc tp_la2[] = {
+		{ "CplCmdIn", 56, 8 },
+		{ "MpsVfVld", 55, 1 },
+		{ "MpsPf", 52, 3 },
+		{ "MpsVf", 44, 8 },
+		{ "SynIn", 43, 1 },
+		{ "AckIn", 42, 1 },
+		{ "FinIn", 41, 1 },
+		{ "RstIn", 40, 1 },
+		{ "DataIn", 39, 1 },
+		{ "DataInVld", 38, 1 },
+		{ "PadIn", 37, 1 },
+		{ "RxBufEmpty", 36, 1 },
+		{ "RxDdp", 35, 1 },
+		{ "RxFbCongestion", 34, 1 },
+		{ "TxFbCongestion", 33, 1 },
+		{ "TxPktSumSrdy", 32, 1 },
+		{ "RcfUlpType", 28, 4 },
+		{ "Eread", 27, 1 },
+		{ "Ebypass", 26, 1 },
+		{ "Esave", 25, 1 },
+		{ "Static0", 24, 1 },
+		{ "Cread", 23, 1 },
+		{ "Cbypass", 22, 1 },
+		{ "Csave", 21, 1 },
+		{ "CPktOut", 20, 1 },
+		{ "RxPagePoolFull", 18, 2 },
+		{ "RxLpbkPkt", 17, 1 },
+		{ "TxLpbkPkt", 16, 1 },
+		{ "RxVfValid", 15, 1 },
+		{ "SynLearned", 14, 1 },
+		{ "SetDelEntry", 13, 1 },
+		{ "SetInvEntry", 12, 1 },
+		{ "CpcmdDvld", 11, 1 },
+		{ "CpcmdSave", 10, 1 },
+		{ "RxPstructsFull", 8, 2 },
+		{ "EpcmdDvld", 7, 1 },
+		{ "EpcmdFlush", 6, 1 },
+		{ "EpcmdTrimPrefix", 5, 1 },
+		{ "EpcmdTrimPostfix", 4, 1 },
+		{ "ERssIp4Pkt", 3, 1 },
+		{ "ERssIp6Pkt", 2, 1 },
+		{ "ERssTcpUdpPkt", 1, 1 },
+		{ "ERssFceFipPkt", 0, 1 },
+		{ NULL }
+	};
+	const u64 *p = v;
+
+	if (idx)
+		seq_putc(seq, '\n');
+	field_desc_show(seq, p[0], tp_la0);
+	if (idx < (TPLA_SIZE / 2 - 1) || p[1] != ~0ULL)
+		field_desc_show(seq, p[1], (p[0] & BIT(17)) ? tp_la2 : tp_la1);
+	return 0;
+}
+
+static int tp_la_open(struct inode *inode, struct file *file)
+{
+	struct seq_tab *p;
+	struct adapter *adap = inode->i_private;
+
+	switch (DBGLAMODE_G(t4_read_reg(adap, TP_DBG_LA_CONFIG_A))) {
+	case 2:
+		p = seq_open_tab(file, TPLA_SIZE / 2, 2 * sizeof(u64), 0,
+				 tp_la_show2);
+		break;
+	case 3:
+		p = seq_open_tab(file, TPLA_SIZE / 2, 2 * sizeof(u64), 0,
+				 tp_la_show3);
+		break;
+	default:
+		p = seq_open_tab(file, TPLA_SIZE, sizeof(u64), 0, tp_la_show);
+	}
+	if (!p)
+		return -ENOMEM;
+
+	t4_tp_read_la(adap, (u64 *)p->data, NULL);
+	return 0;
+}
+
+static ssize_t tp_la_write(struct file *file, const char __user *buf,
+			   size_t count, loff_t *pos)
+{
+	int err;
+	char s[32];
+	unsigned long val;
+	size_t size = min(sizeof(s) - 1, count);
+	struct adapter *adap = FILE_DATA(file)->i_private;
+
+	if (copy_from_user(s, buf, size))
+		return -EFAULT;
+	s[size] = '\0';
+	err = kstrtoul(s, 0, &val);
+	if (err)
+		return err;
+	if (val > 0xffff)
+		return -EINVAL;
+	adap->params.tp.la_mask = val << 16;
+	t4_set_reg_field(adap, TP_DBG_LA_CONFIG_A, 0xffff0000U,
+			 adap->params.tp.la_mask);
+	return count;
+}
+
+static const struct file_operations tp_la_fops = {
+	.owner   = THIS_MODULE,
+	.open    = tp_la_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private,
+	.write   = tp_la_write
+};
+
 /* Show the PM memory stats.  These stats include:
  *
  * TX:
@@ -1619,6 +1866,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "obq_ulp3", &cim_obq_fops, S_IRUSR, 3 },
 		{ "obq_sge",  &cim_obq_fops, S_IRUSR, 4 },
 		{ "obq_ncsi", &cim_obq_fops, S_IRUSR, 5 },
+		{ "tp_la", &tp_la_fops, S_IRUSR, 0 },
 		{ "sensors", &sensors_debugfs_fops, S_IRUSR, 0 },
 		{ "pm_stats", &pm_stats_debugfs_fops, S_IRUSR, 0 },
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index ae69796..96cfa0a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4819,3 +4819,50 @@ restart:
 	}
 	return ret;
 }
+
+/**
+ *	t4_tp_read_la - read TP LA capture buffer
+ *	@adap: the adapter
+ *	@la_buf: where to store the LA data
+ *	@wrptr: the HW write pointer within the capture buffer
+ *
+ *	Reads the contents of the TP LA buffer with the most recent entry at
+ *	the end	of the returned data and with the entry at @wrptr first.
+ *	We leave the LA in the running state we find it in.
+ */
+void t4_tp_read_la(struct adapter *adap, u64 *la_buf, unsigned int *wrptr)
+{
+	bool last_incomplete;
+	unsigned int i, cfg, val, idx;
+
+	cfg = t4_read_reg(adap, TP_DBG_LA_CONFIG_A) & 0xffff;
+	if (cfg & DBGLAENABLE_F)			/* freeze LA */
+		t4_write_reg(adap, TP_DBG_LA_CONFIG_A,
+			     adap->params.tp.la_mask | (cfg ^ DBGLAENABLE_F));
+
+	val = t4_read_reg(adap, TP_DBG_LA_CONFIG_A);
+	idx = DBGLAWPTR_G(val);
+	last_incomplete = DBGLAMODE_G(val) >= 2 && (val & DBGLAWHLF_F) == 0;
+	if (last_incomplete)
+		idx = (idx + 1) & DBGLARPTR_M;
+	if (wrptr)
+		*wrptr = idx;
+
+	val &= 0xffff;
+	val &= ~DBGLARPTR_V(DBGLARPTR_M);
+	val |= adap->params.tp.la_mask;
+
+	for (i = 0; i < TPLA_SIZE; i++) {
+		t4_write_reg(adap, TP_DBG_LA_CONFIG_A, DBGLARPTR_V(idx) | val);
+		la_buf[i] = t4_read_reg64(adap, TP_DBG_LA_DATAL_A);
+		idx = (idx + 1) & DBGLARPTR_M;
+	}
+
+	/* Wipe out last entry if it isn't valid */
+	if (last_incomplete)
+		la_buf[TPLA_SIZE - 1] = ~0ULL;
+
+	if (cfg & DBGLAENABLE_F)                    /* restore running state */
+		t4_write_reg(adap, TP_DBG_LA_CONFIG_A,
+			     cfg | adap->params.tp.la_mask);
+}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index 664375f..f0b98d7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -63,6 +63,7 @@ enum {
 	CIMLA_SIZE     = 2048,  /* # of 32-bit words in CIM LA */
 	CIM_IBQ_SIZE   = 128,   /* # of 128-bit words in a CIM IBQ */
 	CIM_OBQ_SIZE   = 128,   /* # of 128-bit words in a CIM OBQ */
+	TPLA_SIZE      = 128,   /* # of 64-bit words in TP LA */
 };
 
 enum {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 940b56c..15d0ecc 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1183,9 +1183,31 @@
 #define RSVDSPACEINT_F    RSVDSPACEINT_V(1U)
 
 /* registers for module TP */
+#define DBGLAWHLF_S    23
+#define DBGLAWHLF_V(x) ((x) << DBGLAWHLF_S)
+#define DBGLAWHLF_F    DBGLAWHLF_V(1U)
+
+#define DBGLAWPTR_S    16
+#define DBGLAWPTR_M    0x7fU
+#define DBGLAWPTR_G(x) (((x) >> DBGLAWPTR_S) & DBGLAWPTR_M)
+
+#define DBGLAENABLE_S    12
+#define DBGLAENABLE_V(x) ((x) << DBGLAENABLE_S)
+#define DBGLAENABLE_F    DBGLAENABLE_V(1U)
+
+#define DBGLARPTR_S    0
+#define DBGLARPTR_M    0x7fU
+#define DBGLARPTR_V(x) ((x) << DBGLARPTR_S)
+
+#define TP_DBG_LA_DATAL_A	0x7ed8
+#define TP_DBG_LA_CONFIG_A	0x7ed4
 #define TP_OUT_CONFIG_A		0x7d04
 #define TP_GLOBAL_CONFIG_A	0x7d08
 
+#define DBGLAMODE_S	14
+#define DBGLAMODE_M	0x3U
+#define DBGLAMODE_G(x)	(((x) >> DBGLAMODE_S) & DBGLAMODE_M)
+
 #define FIVETUPLELOOKUP_S    17
 #define FIVETUPLELOOKUP_M    0x3U
 #define FIVETUPLELOOKUP_V(x) ((x) << FIVETUPLELOOKUP_S)
-- 
1.7.1
