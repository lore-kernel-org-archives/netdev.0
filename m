From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/5] cxgb4: Added support in debugfs to dump cim ingress bound queue contents
Date: Tue, 27 Jan 2015 13:47:46 +0530
Message-ID: <1422346669-26913-3-git-send-email-hariprasad@chelsio.com>
References: <1422346669-26913-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24389 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757624AbbA0IMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:12:15 -0500
In-Reply-To: <1422346669-26913-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    2 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   42 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   42 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   17 ++++++++
 5 files changed, 104 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 533a691..368b5ad 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1054,6 +1054,8 @@ int t4_mc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
 	       u64 *parity);
 int t4_edc_read(struct adapter *adap, int idx, u32 addr, __be32 *data,
 		u64 *parity);
+int t4_read_cim_ibq(struct adapter *adap, unsigned int qid, u32 *data,
+		    size_t n);
 int t4_cim_read(struct adapter *adap, unsigned int addr, unsigned int n,
 		unsigned int *valp);
 int t4_cim_write(struct adapter *adap, unsigned int addr, unsigned int n,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index eb420e1..3f4b07e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -239,6 +239,42 @@ static const struct file_operations cim_qcfg_fops = {
 	.release = single_release,
 };
 
+static int cimq_show(struct seq_file *seq, void *v, int idx)
+{
+	const u32 *p = v;
+
+	seq_printf(seq, "%#06x: %08x %08x %08x %08x\n", idx * 16, p[0], p[1],
+		   p[2], p[3]);
+	return 0;
+}
+
+static int cim_ibq_open(struct inode *inode, struct file *file)
+{
+	int ret;
+	struct seq_tab *p;
+	unsigned int qid = (uintptr_t)inode->i_private & 7;
+	struct adapter *adap = inode->i_private - qid;
+
+	p = seq_open_tab(file, CIM_IBQ_SIZE, 4 * sizeof(u32), 0, cimq_show);
+	if (!p)
+		return -ENOMEM;
+
+	ret = t4_read_cim_ibq(adap, qid, (u32 *)p->data, CIM_IBQ_SIZE * 4);
+	if (ret < 0)
+		seq_release_private(inode, file);
+	else
+		ret = 0;
+	return ret;
+}
+
+static const struct file_operations cim_ibq_fops = {
+	.owner   = THIS_MODULE,
+	.open    = cim_ibq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private
+};
+
 /* Firmware Device Log dump. */
 static const char * const devlog_level_strings[] = {
 	[FW_DEVLOG_LEVEL_EMERG]		= "EMERG",
@@ -1346,6 +1382,12 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "rss_pf_config", &rss_pf_config_debugfs_fops, S_IRUSR, 0 },
 		{ "rss_vf_config", &rss_vf_config_debugfs_fops, S_IRUSR, 0 },
 		{ "sge_qinfo", &sge_qinfo_debugfs_fops, S_IRUSR, 0 },
+		{ "ibq_tp0",  &cim_ibq_fops, S_IRUSR, 0 },
+		{ "ibq_tp1",  &cim_ibq_fops, S_IRUSR, 1 },
+		{ "ibq_ulp",  &cim_ibq_fops, S_IRUSR, 2 },
+		{ "ibq_sge0", &cim_ibq_fops, S_IRUSR, 3 },
+		{ "ibq_sge1", &cim_ibq_fops, S_IRUSR, 4 },
+		{ "ibq_ncsi", &cim_ibq_fops, S_IRUSR, 5 },
 #if IS_ENABLED(CONFIG_IPV6)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
 #endif
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 8f99878..4ea4a4a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4526,6 +4526,48 @@ void t4_read_cimq_cfg(struct adapter *adap, u16 *base, u16 *size, u16 *thres)
 }
 
 /**
+ *	t4_read_cim_ibq - read the contents of a CIM inbound queue
+ *	@adap: the adapter
+ *	@qid: the queue index
+ *	@data: where to store the queue contents
+ *	@n: capacity of @data in 32-bit words
+ *
+ *	Reads the contents of the selected CIM queue starting at address 0 up
+ *	to the capacity of @data.  @n must be a multiple of 4.  Returns < 0 on
+ *	error and the number of 32-bit words actually read on success.
+ */
+int t4_read_cim_ibq(struct adapter *adap, unsigned int qid, u32 *data, size_t n)
+{
+	int i, err, attempts;
+	unsigned int addr;
+	const unsigned int nwords = CIM_IBQ_SIZE * 4;
+
+	if (qid > 5 || (n & 3))
+		return -EINVAL;
+
+	addr = qid * nwords;
+	if (n > nwords)
+		n = nwords;
+
+	/* It might take 3-10ms before the IBQ debug read access is allowed.
+	 * Wait for 1 Sec with a delay of 1 usec.
+	 */
+	attempts = 1000000;
+
+	for (i = 0; i < n; i++, addr++) {
+		t4_write_reg(adap, CIM_IBQ_DBG_CFG_A, IBQDBGADDR_V(addr) |
+			     IBQDBGEN_F);
+		err = t4_wait_op_done(adap, CIM_IBQ_DBG_CFG_A, IBQDBGBUSY_F, 0,
+				      attempts, 1);
+		if (err)
+			return err;
+		*data++ = t4_read_reg(adap, CIM_IBQ_DBG_DATA_A);
+	}
+	t4_write_reg(adap, CIM_IBQ_DBG_CFG_A, 0);
+	return i;
+}
+
+/**
  *	t4_cim_read - read a block from CIM internal address space
  *	@adap: the adapter
  *	@addr: the start address within the CIM address space
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index f6b82da..6581cd5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -60,6 +60,7 @@ enum {
 	CIM_NUM_OBQ    = 6,     /* # of CIM OBQs */
 	CIM_NUM_OBQ_T5 = 8,     /* # of CIM OBQs for T5 adapter */
 	CIMLA_SIZE     = 2048,  /* # of 32-bit words in CIM LA */
+	CIM_IBQ_SIZE   = 128,   /* # of 128-bit words in a CIM IBQ */
 };
 
 enum {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index e036b56..39e4b75 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2538,6 +2538,23 @@
 #define HOSTWRITE_V(x)	((x) << HOSTWRITE_S)
 #define HOSTWRITE_F	HOSTWRITE_V(1U)
 
+#define CIM_IBQ_DBG_CFG_A 0x7b60
+
+#define IBQDBGADDR_S    16
+#define IBQDBGADDR_M    0xfffU
+#define IBQDBGADDR_V(x) ((x) << IBQDBGADDR_S)
+#define IBQDBGADDR_G(x) (((x) >> IBQDBGADDR_S) & IBQDBGADDR_M)
+
+#define IBQDBGBUSY_S    1
+#define IBQDBGBUSY_V(x) ((x) << IBQDBGBUSY_S)
+#define IBQDBGBUSY_F    IBQDBGBUSY_V(1U)
+
+#define IBQDBGEN_S    0
+#define IBQDBGEN_V(x) ((x) << IBQDBGEN_S)
+#define IBQDBGEN_F    IBQDBGEN_V(1U)
+
+#define CIM_IBQ_DBG_DATA_A 0x7b68
+
 #define UPDBGLARDEN_S		1
 #define UPDBGLARDEN_V(x)	((x) << UPDBGLARDEN_S)
 #define UPDBGLARDEN_F		UPDBGLARDEN_V(1U)
-- 
1.7.1
