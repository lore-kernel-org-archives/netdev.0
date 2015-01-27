From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/5] cxgb4: Addded support in debugfs to dump CIM outbound queue content
Date: Tue, 27 Jan 2015 13:47:47 +0530
Message-ID: <1422346669-26913-4-git-send-email-hariprasad@chelsio.com>
References: <1422346669-26913-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14589 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757716AbbA0IMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:12:19 -0500
In-Reply-To: <1422346669-26913-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    2 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   57 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   43 +++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   16 ++++++
 5 files changed, 119 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 368b5ad..da94b9a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1056,6 +1056,8 @@ int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
 		u64 *parity);
 int t4_read_cim_ibq(struct adapter *adap, unsigned int qid, u32 *data,
 		    size_t n);
+int t4_read_cim_obq(struct adapter *adap, unsigned int qid, u32 *data,
+		    size_t n);
 int t4_cim_read(struct adapter *adap, unsigned int addr, unsigned int n,
 		unsigned int *valp);
 int t4_cim_write(struct adapter *adap, unsigned int addr, unsigned int n,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 3f4b07e..4619bb3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -104,6 +104,17 @@ struct seq_tab *seq_open_tab(struct file *f, unsigned int rows,
 	return p;
 }
 
+/* Trim the size of a seq_tab to the supplied number of rows.  The operation is
+ * irreversible.
+ */
+static int seq_tab_trim(struct seq_tab *p, unsigned int new_rows)
+{
+	if (new_rows > p->rows)
+		return -EINVAL;
+	p->rows = new_rows;
+	return 0;
+}
+
 static int cim_la_show(struct seq_file *seq, void *v, int idx)
 {
 	if (v == SEQ_START_TOKEN)
@@ -275,6 +286,35 @@ static const struct file_operations cim_ibq_fops = {
 	.release = seq_release_private
 };
 
+static int cim_obq_open(struct inode *inode, struct file *file)
+{
+	int ret;
+	struct seq_tab *p;
+	unsigned int qid = (uintptr_t)inode->i_private & 7;
+	struct adapter *adap = inode->i_private - qid;
+
+	p = seq_open_tab(file, 6 * CIM_OBQ_SIZE, 4 * sizeof(u32), 0, cimq_show);
+	if (!p)
+		return -ENOMEM;
+
+	ret = t4_read_cim_obq(adap, qid, (u32 *)p->data, 6 * CIM_OBQ_SIZE * 4);
+	if (ret < 0) {
+		seq_release_private(inode, file);
+	} else {
+		seq_tab_trim(p, ret / 4);
+		ret = 0;
+	}
+	return ret;
+}
+
+static const struct file_operations cim_obq_fops = {
+	.owner   = THIS_MODULE,
+	.open    = cim_obq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private
+};
+
 /* Firmware Device Log dump. */
 static const char * const devlog_level_strings[] = {
 	[FW_DEVLOG_LEVEL_EMERG]		= "EMERG",
@@ -1388,14 +1428,31 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "ibq_sge0", &cim_ibq_fops, S_IRUSR, 3 },
 		{ "ibq_sge1", &cim_ibq_fops, S_IRUSR, 4 },
 		{ "ibq_ncsi", &cim_ibq_fops, S_IRUSR, 5 },
+		{ "obq_ulp0", &cim_obq_fops, S_IRUSR, 0 },
+		{ "obq_ulp1", &cim_obq_fops, S_IRUSR, 1 },
+		{ "obq_ulp2", &cim_obq_fops, S_IRUSR, 2 },
+		{ "obq_ulp3", &cim_obq_fops, S_IRUSR, 3 },
+		{ "obq_sge",  &cim_obq_fops, S_IRUSR, 4 },
+		{ "obq_ncsi", &cim_obq_fops, S_IRUSR, 5 },
 #if IS_ENABLED(CONFIG_IPV6)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
 #endif
 	};
 
+	/* Debug FS nodes common to all T5 and later adapters.
+	 */
+	static struct t4_debugfs_entry t5_debugfs_files[] = {
+		{ "obq_sge_rx_q0", &cim_obq_fops, S_IRUSR, 6 },
+		{ "obq_sge_rx_q1", &cim_obq_fops, S_IRUSR, 7 },
+	};
+
 	add_debugfs_files(adap,
 			  t4_debugfs_files,
 			  ARRAY_SIZE(t4_debugfs_files));
+	if (!is_t4(adap->params.chip))
+		add_debugfs_files(adap,
+				  t5_debugfs_files,
+				  ARRAY_SIZE(t5_debugfs_files));
 
 	i = t4_read_reg(adap, MA_TARGET_MEM_ENABLE_A);
 	if (i & EDRAM0_ENABLE_F) {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 4ea4a4a..a3d2f31 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4568,6 +4568,49 @@ int t4_read_cim_ibq(struct adapter *adap, unsigned int qid, u32 *data, size_t n)
 }
 
 /**
+ *	t4_read_cim_obq - read the contents of a CIM outbound queue
+ *	@adap: the adapter
+ *	@qid: the queue index
+ *	@data: where to store the queue contents
+ *	@n: capacity of @data in 32-bit words
+ *
+ *	Reads the contents of the selected CIM queue starting at address 0 up
+ *	to the capacity of @data.  @n must be a multiple of 4.  Returns < 0 on
+ *	error and the number of 32-bit words actually read on success.
+ */
+int t4_read_cim_obq(struct adapter *adap, unsigned int qid, u32 *data, size_t n)
+{
+	int i, err;
+	unsigned int addr, v, nwords;
+	int cim_num_obq = is_t4(adap->params.chip) ?
+				CIM_NUM_OBQ : CIM_NUM_OBQ_T5;
+
+	if ((qid > (cim_num_obq - 1)) || (n & 3))
+		return -EINVAL;
+
+	t4_write_reg(adap, CIM_QUEUE_CONFIG_REF_A, OBQSELECT_F |
+		     QUENUMSELECT_V(qid));
+	v = t4_read_reg(adap, CIM_QUEUE_CONFIG_CTRL_A);
+
+	addr = CIMQBASE_G(v) * 64;    /* muliple of 256 -> muliple of 4 */
+	nwords = CIMQSIZE_G(v) * 64;  /* same */
+	if (n > nwords)
+		n = nwords;
+
+	for (i = 0; i < n; i++, addr++) {
+		t4_write_reg(adap, CIM_OBQ_DBG_CFG_A, OBQDBGADDR_V(addr) |
+			     OBQDBGEN_F);
+		err = t4_wait_op_done(adap, CIM_OBQ_DBG_CFG_A, OBQDBGBUSY_F, 0,
+				      2, 1);
+		if (err)
+			return err;
+		*data++ = t4_read_reg(adap, CIM_OBQ_DBG_DATA_A);
+	}
+	t4_write_reg(adap, CIM_OBQ_DBG_CFG_A, 0);
+	return i;
+}
+
+/**
  *	t4_cim_read - read a block from CIM internal address space
  *	@adap: the adapter
  *	@addr: the start address within the CIM address space
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index 6581cd5..f9fb81e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -61,6 +61,7 @@ enum {
 	CIM_NUM_OBQ_T5 = 8,     /* # of CIM OBQs for T5 adapter */
 	CIMLA_SIZE     = 2048,  /* # of 32-bit words in CIM LA */
 	CIM_IBQ_SIZE   = 128,   /* # of 128-bit words in a CIM IBQ */
+	CIM_OBQ_SIZE   = 128,   /* # of 128-bit words in a CIM OBQ */
 };
 
 enum {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 39e4b75..1b1560a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2553,7 +2553,23 @@
 #define IBQDBGEN_V(x) ((x) << IBQDBGEN_S)
 #define IBQDBGEN_F    IBQDBGEN_V(1U)
 
+#define CIM_OBQ_DBG_CFG_A 0x7b64
+
+#define OBQDBGADDR_S    16
+#define OBQDBGADDR_M    0xfffU
+#define OBQDBGADDR_V(x) ((x) << OBQDBGADDR_S)
+#define OBQDBGADDR_G(x) (((x) >> OBQDBGADDR_S) & OBQDBGADDR_M)
+
+#define OBQDBGBUSY_S    1
+#define OBQDBGBUSY_V(x) ((x) << OBQDBGBUSY_S)
+#define OBQDBGBUSY_F    OBQDBGBUSY_V(1U)
+
+#define OBQDBGEN_S    0
+#define OBQDBGEN_V(x) ((x) << OBQDBGEN_S)
+#define OBQDBGEN_F    OBQDBGEN_V(1U)
+
 #define CIM_IBQ_DBG_DATA_A 0x7b68
+#define CIM_OBQ_DBG_DATA_A 0x7b6c
 
 #define UPDBGLARDEN_S		1
 #define UPDBGLARDEN_V(x)	((x) << UPDBGLARDEN_S)
-- 
1.7.1
