From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/3] cxgb4: Add debugfs entry to dump CIM PIF logic analyzer contents
Date: Tue,  9 Jun 2015 18:27:51 +0530
Message-ID: <1433854672-6649-3-git-send-email-hariprasad@chelsio.com>
References: <1433854672-6649-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2177 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753283AbbFIHof (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2015 03:44:35 -0400
In-Reply-To: <1433854672-6649-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  3 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 44 ++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 34 +++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |  1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       | 13 +++++++
 5 files changed, 95 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 2465026..d84c945 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1337,6 +1337,9 @@ int t4_cim_read(struct adapter *adap, unsigned int addr, unsigned int n,
 int t4_cim_write(struct adapter *adap, unsigned int addr, unsigned int n,
 		 const unsigned int *valp);
 int t4_cim_read_la(struct adapter *adap, u32 *la_buf, unsigned int *wrptr);
+void t4_cim_read_pif_la(struct adapter *adap, u32 *pif_req, u32 *pif_rsp,
+			unsigned int *pif_req_wrptr,
+			unsigned int *pif_rsp_wrptr);
 void t4_cim_read_ma_la(struct adapter *adap, u32 *ma_req, u32 *ma_rsp);
 void t4_read_cimq_cfg(struct adapter *adap, u16 *base, u16 *size, u16 *thres);
 const char *t4_get_port_type_description(enum fw_port_type port_type);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 7c9ad63..eb39564 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -182,6 +182,49 @@ static const struct file_operations cim_la_fops = {
 	.release = seq_release_private
 };
 
+static int cim_pif_la_show(struct seq_file *seq, void *v, int idx)
+{
+	const u32 *p = v;
+
+	if (v == SEQ_START_TOKEN) {
+		seq_puts(seq, "Cntl ID DataBE   Addr                 Data\n");
+	} else if (idx < CIM_PIFLA_SIZE) {
+		seq_printf(seq, " %02x  %02x  %04x  %08x %08x%08x%08x%08x\n",
+			   (p[5] >> 22) & 0xff, (p[5] >> 16) & 0x3f,
+			   p[5] & 0xffff, p[4], p[3], p[2], p[1], p[0]);
+	} else {
+		if (idx == CIM_PIFLA_SIZE)
+			seq_puts(seq, "\nCntl ID               Data\n");
+		seq_printf(seq, " %02x  %02x %08x%08x%08x%08x\n",
+			   (p[4] >> 6) & 0xff, p[4] & 0x3f,
+			   p[3], p[2], p[1], p[0]);
+	}
+	return 0;
+}
+
+static int cim_pif_la_open(struct inode *inode, struct file *file)
+{
+	struct seq_tab *p;
+	struct adapter *adap = inode->i_private;
+
+	p = seq_open_tab(file, 2 * CIM_PIFLA_SIZE, 6 * sizeof(u32), 1,
+			 cim_pif_la_show);
+	if (!p)
+		return -ENOMEM;
+
+	t4_cim_read_pif_la(adap, (u32 *)p->data,
+			   (u32 *)p->data + 6 * CIM_PIFLA_SIZE, NULL, NULL);
+	return 0;
+}
+
+static const struct file_operations cim_pif_la_fops = {
+	.owner   = THIS_MODULE,
+	.open    = cim_pif_la_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private
+};
+
 static int cim_ma_la_show(struct seq_file *seq, void *v, int idx)
 {
 	const u32 *p = v;
@@ -2174,6 +2217,7 @@ int t4_setup_debugfs(struct adapter *adap)
 
 	static struct t4_debugfs_entry t4_debugfs_files[] = {
 		{ "cim_la", &cim_la_fops, S_IRUSR, 0 },
+		{ "cim_pif_la", &cim_pif_la_fops, S_IRUSR, 0 },
 		{ "cim_ma_la", &cim_ma_la_fops, S_IRUSR, 0 },
 		{ "cim_qcfg", &cim_qcfg_fops, S_IRUSR, 0 },
 		{ "clk", &clk_debugfs_fops, S_IRUSR, 0 },
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 5643cad..c967b24 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2586,6 +2586,40 @@ int t4_fwcache(struct adapter *adap, enum fw_params_param_dev_fwcache op)
 	return t4_wr_mbox(adap, adap->mbox, &c, sizeof(c), NULL);
 }
 
+void t4_cim_read_pif_la(struct adapter *adap, u32 *pif_req, u32 *pif_rsp,
+			unsigned int *pif_req_wrptr,
+			unsigned int *pif_rsp_wrptr)
+{
+	int i, j;
+	u32 cfg, val, req, rsp;
+
+	cfg = t4_read_reg(adap, CIM_DEBUGCFG_A);
+	if (cfg & LADBGEN_F)
+		t4_write_reg(adap, CIM_DEBUGCFG_A, cfg ^ LADBGEN_F);
+
+	val = t4_read_reg(adap, CIM_DEBUGSTS_A);
+	req = POLADBGWRPTR_G(val);
+	rsp = PILADBGWRPTR_G(val);
+	if (pif_req_wrptr)
+		*pif_req_wrptr = req;
+	if (pif_rsp_wrptr)
+		*pif_rsp_wrptr = rsp;
+
+	for (i = 0; i < CIM_PIFLA_SIZE; i++) {
+		for (j = 0; j < 6; j++) {
+			t4_write_reg(adap, CIM_DEBUGCFG_A, POLADBGRDPTR_V(req) |
+				     PILADBGRDPTR_V(rsp));
+			*pif_req++ = t4_read_reg(adap, CIM_PO_LA_DEBUGDATA_A);
+			*pif_rsp++ = t4_read_reg(adap, CIM_PI_LA_DEBUGDATA_A);
+			req++;
+			rsp++;
+		}
+		req = (req + 2) & POLADBGRDPTR_M;
+		rsp = (rsp + 2) & PILADBGRDPTR_M;
+	}
+	t4_write_reg(adap, CIM_DEBUGCFG_A, cfg);
+}
+
 void t4_cim_read_ma_la(struct adapter *adap, u32 *ma_req, u32 *ma_rsp)
 {
 	u32 cfg;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index 24c5462..c8488f4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -59,6 +59,7 @@ enum {
 	CIM_NUM_OBQ    = 6,     /* # of CIM OBQs */
 	CIM_NUM_OBQ_T5 = 8,     /* # of CIM OBQs for T5 adapter */
 	CIMLA_SIZE     = 2048,  /* # of 32-bit words in CIM LA */
+	CIM_PIFLA_SIZE = 64,    /* # of 192-bit words in CIM PIF LA */
 	CIM_MALA_SIZE  = 64,    /* # of 160-bit words in CIM MA LA */
 	CIM_IBQ_SIZE   = 128,   /* # of 128-bit words in a CIM IBQ */
 	CIM_OBQ_SIZE   = 128,   /* # of 128-bit words in a CIM OBQ */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 07072af..525d06e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2760,17 +2760,30 @@
 #define CIM_IBQ_DBG_DATA_A 0x7b68
 #define CIM_OBQ_DBG_DATA_A 0x7b6c
 #define CIM_DEBUGCFG_A 0x7b70
+#define CIM_DEBUGSTS_A 0x7b74
 
 #define POLADBGRDPTR_S		23
+#define POLADBGRDPTR_M		0x1ffU
 #define POLADBGRDPTR_V(x)	((x) << POLADBGRDPTR_S)
 
+#define POLADBGWRPTR_S		16
+#define POLADBGWRPTR_M		0x1ffU
+#define POLADBGWRPTR_G(x)	(((x) >> POLADBGWRPTR_S) & POLADBGWRPTR_M)
+
 #define PILADBGRDPTR_S		14
+#define PILADBGRDPTR_M		0x1ffU
 #define PILADBGRDPTR_V(x)	((x) << PILADBGRDPTR_S)
 
+#define PILADBGWRPTR_S		0
+#define PILADBGWRPTR_M		0x1ffU
+#define PILADBGWRPTR_G(x)	(((x) >> PILADBGWRPTR_S) & PILADBGWRPTR_M)
+
 #define LADBGEN_S	12
 #define LADBGEN_V(x)	((x) << LADBGEN_S)
 #define LADBGEN_F	LADBGEN_V(1U)
 
+#define CIM_PO_LA_DEBUGDATA_A 0x7b78
+#define CIM_PI_LA_DEBUGDATA_A 0x7b7c
 #define CIM_PO_LA_MADEBUGDATA_A	0x7b80
 #define CIM_PI_LA_MADEBUGDATA_A	0x7b84
 
-- 
2.3.4
