From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/3] cxgb4: Add a debugfs entry to dump CIM MA logic analyzer logs
Date: Tue,  9 Jun 2015 18:27:50 +0530
Message-ID: <1433854672-6649-2-git-send-email-hariprasad@chelsio.com>
References: <1433854672-6649-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:32086 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752586AbbFIHod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 03:44:33 -0400
In-Reply-To: <1433854672-6649-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 47 ++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 21 ++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |  1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       | 14 +++++++
 5 files changed, 84 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 4d627a8..2465026 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1337,6 +1337,7 @@ int t4_cim_read(struct adapter *adap, unsigned int addr, unsigned int n,
 int t4_cim_write(struct adapter *adap, unsigned int addr, unsigned int n,
 		 const unsigned int *valp);
 int t4_cim_read_la(struct adapter *adap, u32 *la_buf, unsigned int *wrptr);
+void t4_cim_read_ma_la(struct adapter *adap, u32 *ma_req, u32 *ma_rsp);
 void t4_read_cimq_cfg(struct adapter *adap, u16 *base, u16 *size, u16 *thres);
 const char *t4_get_port_type_description(enum fw_port_type port_type);
 void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 3719807..7c9ad63 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -182,6 +182,52 @@ static const struct file_operations cim_la_fops = {
 	.release = seq_release_private
 };
 
+static int cim_ma_la_show(struct seq_file *seq, void *v, int idx)
+{
+	const u32 *p = v;
+
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "\n");
+	} else if (idx < CIM_MALA_SIZE) {
+		seq_printf(seq, "%02x%08x%08x%08x%08x\n",
+			   p[4], p[3], p[2], p[1], p[0]);
+	} else {
+		if (idx == CIM_MALA_SIZE)
+			seq_puts(seq,
+				 "\nCnt ID Tag UE       Data       RDY VLD\n");
+		seq_printf(seq, "%3u %2u  %x   %u %08x%08x  %u   %u\n",
+			   (p[2] >> 10) & 0xff, (p[2] >> 7) & 7,
+			   (p[2] >> 3) & 0xf, (p[2] >> 2) & 1,
+			   (p[1] >> 2) | ((p[2] & 3) << 30),
+			   (p[0] >> 2) | ((p[1] & 3) << 30), (p[0] >> 1) & 1,
+			   p[0] & 1);
+	}
+	return 0;
+}
+
+static int cim_ma_la_open(struct inode *inode, struct file *file)
+{
+	struct seq_tab *p;
+	struct adapter *adap = inode->i_private;
+
+	p = seq_open_tab(file, 2 * CIM_MALA_SIZE, 5 * sizeof(u32), 1,
+			 cim_ma_la_show);
+	if (!p)
+		return -ENOMEM;
+
+	t4_cim_read_ma_la(adap, (u32 *)p->data,
+			  (u32 *)p->data + 5 * CIM_MALA_SIZE);
+	return 0;
+}
+
+static const struct file_operations cim_ma_la_fops = {
+	.owner   = THIS_MODULE,
+	.open    = cim_ma_la_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private
+};
+
 static int cim_qcfg_show(struct seq_file *seq, void *v)
 {
 	static const char * const qname[] = {
@@ -2128,6 +2174,7 @@ int t4_setup_debugfs(struct adapter *adap)
 
 	static struct t4_debugfs_entry t4_debugfs_files[] = {
 		{ "cim_la", &cim_la_fops, S_IRUSR, 0 },
+		{ "cim_ma_la", &cim_ma_la_fops, S_IRUSR, 0 },
 		{ "cim_qcfg", &cim_qcfg_fops, S_IRUSR, 0 },
 		{ "clk", &clk_debugfs_fops, S_IRUSR, 0 },
 		{ "devlog", &devlog_fops, S_IRUSR, 0 },
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index fdda0f8..5643cad 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2586,6 +2586,27 @@ int t4_fwcache(struct adapter *adap, enum fw_params_param_dev_fwcache op)
 	return t4_wr_mbox(adap, adap->mbox, &c, sizeof(c), NULL);
 }
 
+void t4_cim_read_ma_la(struct adapter *adap, u32 *ma_req, u32 *ma_rsp)
+{
+	u32 cfg;
+	int i, j, idx;
+
+	cfg = t4_read_reg(adap, CIM_DEBUGCFG_A);
+	if (cfg & LADBGEN_F)
+		t4_write_reg(adap, CIM_DEBUGCFG_A, cfg ^ LADBGEN_F);
+
+	for (i = 0; i < CIM_MALA_SIZE; i++) {
+		for (j = 0; j < 5; j++) {
+			idx = 8 * i + j;
+			t4_write_reg(adap, CIM_DEBUGCFG_A, POLADBGRDPTR_V(idx) |
+				     PILADBGRDPTR_V(idx));
+			*ma_req++ = t4_read_reg(adap, CIM_PO_LA_MADEBUGDATA_A);
+			*ma_rsp++ = t4_read_reg(adap, CIM_PI_LA_MADEBUGDATA_A);
+		}
+	}
+	t4_write_reg(adap, CIM_DEBUGCFG_A, cfg);
+}
+
 void t4_ulprx_read_la(struct adapter *adap, u32 *la_buf)
 {
 	unsigned int i, j;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index f9a2cb1..24c5462 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -59,6 +59,7 @@ enum {
 	CIM_NUM_OBQ    = 6,     /* # of CIM OBQs */
 	CIM_NUM_OBQ_T5 = 8,     /* # of CIM OBQs for T5 adapter */
 	CIMLA_SIZE     = 2048,  /* # of 32-bit words in CIM LA */
+	CIM_MALA_SIZE  = 64,    /* # of 160-bit words in CIM MA LA */
 	CIM_IBQ_SIZE   = 128,   /* # of 128-bit words in a CIM IBQ */
 	CIM_OBQ_SIZE   = 128,   /* # of 128-bit words in a CIM OBQ */
 	TPLA_SIZE      = 128,   /* # of 64-bit words in TP LA */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index af3462d..07072af 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2759,6 +2759,20 @@
 
 #define CIM_IBQ_DBG_DATA_A 0x7b68
 #define CIM_OBQ_DBG_DATA_A 0x7b6c
+#define CIM_DEBUGCFG_A 0x7b70
+
+#define POLADBGRDPTR_S		23
+#define POLADBGRDPTR_V(x)	((x) << POLADBGRDPTR_S)
+
+#define PILADBGRDPTR_S		14
+#define PILADBGRDPTR_V(x)	((x) << PILADBGRDPTR_S)
+
+#define LADBGEN_S	12
+#define LADBGEN_V(x)	((x) << LADBGEN_S)
+#define LADBGEN_F	LADBGEN_V(1U)
+
+#define CIM_PO_LA_MADEBUGDATA_A	0x7b80
+#define CIM_PI_LA_MADEBUGDATA_A	0x7b84
 
 #define UPDBGLARDEN_S		1
 #define UPDBGLARDEN_V(x)	((x) << UPDBGLARDEN_S)
-- 
2.3.4
