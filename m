From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 1/4] cxgb4: Add debugfs support to dump meminfo
Date: Tue,  4 Aug 2015 14:36:17 +0530
Message-ID: <1438679180-25930-2-git-send-email-hariprasad@chelsio.com>
References: <1438679180-25930-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14325 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755139AbbHDDvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 23:51:54 -0400
In-Reply-To: <1438679180-25930-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add debug support to dump memory address ranges of various hardware
modules of the adapter.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 285 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       | 122 +++++++++
 2 files changed, 407 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index f701a6f..b657734 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -2275,6 +2275,290 @@ static const struct file_operations blocked_fl_fops = {
 	.llseek  = generic_file_llseek,
 };
 
+struct mem_desc {
+	unsigned int base;
+	unsigned int limit;
+	unsigned int idx;
+};
+
+static int mem_desc_cmp(const void *a, const void *b)
+{
+	return ((const struct mem_desc *)a)->base -
+	       ((const struct mem_desc *)b)->base;
+}
+
+static void mem_region_show(struct seq_file *seq, const char *name,
+			    unsigned int from, unsigned int to)
+{
+	char buf[40];
+
+	string_get_size((u64)to - from + 1, 1, STRING_UNITS_2, buf,
+			sizeof(buf));
+	seq_printf(seq, "%-15s %#x-%#x [%s]\n", name, from, to, buf);
+}
+
+static int meminfo_show(struct seq_file *seq, void *v)
+{
+	static const char * const memory[] = { "EDC0:", "EDC1:", "MC:",
+					"MC0:", "MC1:"};
+	static const char * const region[] = {
+		"DBQ contexts:", "IMSG contexts:", "FLM cache:", "TCBs:",
+		"Pstructs:", "Timers:", "Rx FL:", "Tx FL:", "Pstruct FL:",
+		"Tx payload:", "Rx payload:", "LE hash:", "iSCSI region:",
+		"TDDP region:", "TPT region:", "STAG region:", "RQ region:",
+		"RQUDP region:", "PBL region:", "TXPBL region:",
+		"DBVFIFO region:", "ULPRX state:", "ULPTX state:",
+		"On-chip queues:"
+	};
+
+	int i, n;
+	u32 lo, hi, used, alloc;
+	struct mem_desc avail[4];
+	struct mem_desc mem[ARRAY_SIZE(region) + 3];      /* up to 3 holes */
+	struct mem_desc *md = mem;
+	struct adapter *adap = seq->private;
+
+	for (i = 0; i < ARRAY_SIZE(mem); i++) {
+		mem[i].limit = 0;
+		mem[i].idx = i;
+	}
+
+	/* Find and sort the populated memory ranges */
+	i = 0;
+	lo = t4_read_reg(adap, MA_TARGET_MEM_ENABLE_A);
+	if (lo & EDRAM0_ENABLE_F) {
+		hi = t4_read_reg(adap, MA_EDRAM0_BAR_A);
+		avail[i].base = EDRAM0_BASE_G(hi) << 20;
+		avail[i].limit = avail[i].base + (EDRAM0_SIZE_G(hi) << 20);
+		avail[i].idx = 0;
+		i++;
+	}
+	if (lo & EDRAM1_ENABLE_F) {
+		hi = t4_read_reg(adap, MA_EDRAM1_BAR_A);
+		avail[i].base = EDRAM1_BASE_G(hi) << 20;
+		avail[i].limit = avail[i].base + (EDRAM1_SIZE_G(hi) << 20);
+		avail[i].idx = 1;
+		i++;
+	}
+
+	if (is_t5(adap->params.chip)) {
+		if (lo & EXT_MEM0_ENABLE_F) {
+			hi = t4_read_reg(adap, MA_EXT_MEMORY0_BAR_A);
+			avail[i].base = EXT_MEM0_BASE_G(hi) << 20;
+			avail[i].limit =
+				avail[i].base + (EXT_MEM0_SIZE_G(hi) << 20);
+			avail[i].idx = 3;
+			i++;
+		}
+		if (lo & EXT_MEM1_ENABLE_F) {
+			hi = t4_read_reg(adap, MA_EXT_MEMORY1_BAR_A);
+			avail[i].base = EXT_MEM1_BASE_G(hi) << 20;
+			avail[i].limit =
+				avail[i].base + (EXT_MEM1_SIZE_G(hi) << 20);
+			avail[i].idx = 4;
+			i++;
+		}
+	} else {
+		if (lo & EXT_MEM_ENABLE_F) {
+			hi = t4_read_reg(adap, MA_EXT_MEMORY_BAR_A);
+			avail[i].base = EXT_MEM_BASE_G(hi) << 20;
+			avail[i].limit =
+				avail[i].base + (EXT_MEM_SIZE_G(hi) << 20);
+			avail[i].idx = 2;
+			i++;
+		}
+	}
+	if (!i)                                    /* no memory available */
+		return 0;
+	sort(avail, i, sizeof(struct mem_desc), mem_desc_cmp, NULL);
+
+	(md++)->base = t4_read_reg(adap, SGE_DBQ_CTXT_BADDR_A);
+	(md++)->base = t4_read_reg(adap, SGE_IMSG_CTXT_BADDR_A);
+	(md++)->base = t4_read_reg(adap, SGE_FLM_CACHE_BADDR_A);
+	(md++)->base = t4_read_reg(adap, TP_CMM_TCB_BASE_A);
+	(md++)->base = t4_read_reg(adap, TP_CMM_MM_BASE_A);
+	(md++)->base = t4_read_reg(adap, TP_CMM_TIMER_BASE_A);
+	(md++)->base = t4_read_reg(adap, TP_CMM_MM_RX_FLST_BASE_A);
+	(md++)->base = t4_read_reg(adap, TP_CMM_MM_TX_FLST_BASE_A);
+	(md++)->base = t4_read_reg(adap, TP_CMM_MM_PS_FLST_BASE_A);
+
+	/* the next few have explicit upper bounds */
+	md->base = t4_read_reg(adap, TP_PMM_TX_BASE_A);
+	md->limit = md->base - 1 +
+		    t4_read_reg(adap, TP_PMM_TX_PAGE_SIZE_A) *
+		    PMTXMAXPAGE_G(t4_read_reg(adap, TP_PMM_TX_MAX_PAGE_A));
+	md++;
+
+	md->base = t4_read_reg(adap, TP_PMM_RX_BASE_A);
+	md->limit = md->base - 1 +
+		    t4_read_reg(adap, TP_PMM_RX_PAGE_SIZE_A) *
+		    PMRXMAXPAGE_G(t4_read_reg(adap, TP_PMM_RX_MAX_PAGE_A));
+	md++;
+
+	if (t4_read_reg(adap, LE_DB_CONFIG_A) & HASHEN_F) {
+		if (CHELSIO_CHIP_VERSION(adap->params.chip) <= CHELSIO_T5) {
+			hi = t4_read_reg(adap, LE_DB_TID_HASHBASE_A) / 4;
+			md->base = t4_read_reg(adap, LE_DB_HASH_TID_BASE_A);
+		 } else {
+			hi = t4_read_reg(adap, LE_DB_HASH_TID_BASE_A);
+			md->base = t4_read_reg(adap,
+					       LE_DB_HASH_TBL_BASE_ADDR_A);
+		}
+		md->limit = 0;
+	} else {
+		md->base = 0;
+		md->idx = ARRAY_SIZE(region);  /* hide it */
+	}
+	md++;
+
+#define ulp_region(reg) do { \
+	md->base = t4_read_reg(adap, ULP_ ## reg ## _LLIMIT_A);\
+	(md++)->limit = t4_read_reg(adap, ULP_ ## reg ## _ULIMIT_A); \
+} while (0)
+
+	ulp_region(RX_ISCSI);
+	ulp_region(RX_TDDP);
+	ulp_region(TX_TPT);
+	ulp_region(RX_STAG);
+	ulp_region(RX_RQ);
+	ulp_region(RX_RQUDP);
+	ulp_region(RX_PBL);
+	ulp_region(TX_PBL);
+#undef ulp_region
+	md->base = 0;
+	md->idx = ARRAY_SIZE(region);
+	if (!is_t4(adap->params.chip)) {
+		u32 size = 0;
+		u32 sge_ctrl = t4_read_reg(adap, SGE_CONTROL2_A);
+		u32 fifo_size = t4_read_reg(adap, SGE_DBVFIFO_SIZE_A);
+
+		if (is_t5(adap->params.chip)) {
+			if (sge_ctrl & VFIFO_ENABLE_F)
+				size = DBVFIFO_SIZE_G(fifo_size);
+		} else {
+			size = T6_DBVFIFO_SIZE_G(fifo_size);
+		}
+
+		if (size) {
+			md->base = BASEADDR_G(t4_read_reg(adap,
+					SGE_DBVFIFO_BADDR_A));
+			md->limit = md->base + (size << 2) - 1;
+		}
+	}
+
+	md++;
+
+	md->base = t4_read_reg(adap, ULP_RX_CTX_BASE_A);
+	md->limit = 0;
+	md++;
+	md->base = t4_read_reg(adap, ULP_TX_ERR_TABLE_BASE_A);
+	md->limit = 0;
+	md++;
+
+	md->base = adap->vres.ocq.start;
+	if (adap->vres.ocq.size)
+		md->limit = md->base + adap->vres.ocq.size - 1;
+	else
+		md->idx = ARRAY_SIZE(region);  /* hide it */
+	md++;
+
+	/* add any address-space holes, there can be up to 3 */
+	for (n = 0; n < i - 1; n++)
+		if (avail[n].limit < avail[n + 1].base)
+			(md++)->base = avail[n].limit;
+	if (avail[n].limit)
+		(md++)->base = avail[n].limit;
+
+	n = md - mem;
+	sort(mem, n, sizeof(struct mem_desc), mem_desc_cmp, NULL);
+
+	for (lo = 0; lo < i; lo++)
+		mem_region_show(seq, memory[avail[lo].idx], avail[lo].base,
+				avail[lo].limit - 1);
+
+	seq_putc(seq, '\n');
+	for (i = 0; i < n; i++) {
+		if (mem[i].idx >= ARRAY_SIZE(region))
+			continue;                        /* skip holes */
+		if (!mem[i].limit)
+			mem[i].limit = i < n - 1 ? mem[i + 1].base - 1 : ~0;
+		mem_region_show(seq, region[mem[i].idx], mem[i].base,
+				mem[i].limit);
+	}
+
+	seq_putc(seq, '\n');
+	lo = t4_read_reg(adap, CIM_SDRAM_BASE_ADDR_A);
+	hi = t4_read_reg(adap, CIM_SDRAM_ADDR_SIZE_A) + lo - 1;
+	mem_region_show(seq, "uP RAM:", lo, hi);
+
+	lo = t4_read_reg(adap, CIM_EXTMEM2_BASE_ADDR_A);
+	hi = t4_read_reg(adap, CIM_EXTMEM2_ADDR_SIZE_A) + lo - 1;
+	mem_region_show(seq, "uP Extmem2:", lo, hi);
+
+	lo = t4_read_reg(adap, TP_PMM_RX_MAX_PAGE_A);
+	seq_printf(seq, "\n%u Rx pages of size %uKiB for %u channels\n",
+		   PMRXMAXPAGE_G(lo),
+		   t4_read_reg(adap, TP_PMM_RX_PAGE_SIZE_A) >> 10,
+		   (lo & PMRXNUMCHN_F) ? 2 : 1);
+
+	lo = t4_read_reg(adap, TP_PMM_TX_MAX_PAGE_A);
+	hi = t4_read_reg(adap, TP_PMM_TX_PAGE_SIZE_A);
+	seq_printf(seq, "%u Tx pages of size %u%ciB for %u channels\n",
+		   PMTXMAXPAGE_G(lo),
+		   hi >= (1 << 20) ? (hi >> 20) : (hi >> 10),
+		   hi >= (1 << 20) ? 'M' : 'K', 1 << PMTXNUMCHN_G(lo));
+	seq_printf(seq, "%u p-structs\n\n",
+		   t4_read_reg(adap, TP_CMM_MM_MAX_PSTRUCT_A));
+
+	for (i = 0; i < 4; i++) {
+		if (CHELSIO_CHIP_VERSION(adap->params.chip) > CHELSIO_T5)
+			lo = t4_read_reg(adap, MPS_RX_MAC_BG_PG_CNT0_A + i * 4);
+		else
+			lo = t4_read_reg(adap, MPS_RX_PG_RSV0_A + i * 4);
+		if (is_t5(adap->params.chip)) {
+			used = T5_USED_G(lo);
+			alloc = T5_ALLOC_G(lo);
+		} else {
+			used = USED_G(lo);
+			alloc = ALLOC_G(lo);
+		}
+		/* For T6 these are MAC buffer groups */
+		seq_printf(seq, "Port %d using %u pages out of %u allocated\n",
+			   i, used, alloc);
+	}
+	for (i = 0; i < adap->params.arch.nchan; i++) {
+		if (CHELSIO_CHIP_VERSION(adap->params.chip) > CHELSIO_T5)
+			lo = t4_read_reg(adap,
+					 MPS_RX_LPBK_BG_PG_CNT0_A + i * 4);
+		else
+			lo = t4_read_reg(adap, MPS_RX_PG_RSV4_A + i * 4);
+		if (is_t5(adap->params.chip)) {
+			used = T5_USED_G(lo);
+			alloc = T5_ALLOC_G(lo);
+		} else {
+			used = USED_G(lo);
+			alloc = ALLOC_G(lo);
+		}
+		/* For T6 these are MAC buffer groups */
+		seq_printf(seq,
+			   "Loopback %d using %u pages out of %u allocated\n",
+			   i, used, alloc);
+	}
+	return 0;
+}
+
+static int meminfo_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, meminfo_show, inode->i_private);
+}
+
+static const struct file_operations meminfo_fops = {
+	.owner   = THIS_MODULE,
+	.open    = meminfo_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = single_release,
+};
 /* Add an array of Debug FS files.
  */
 void add_debugfs_files(struct adapter *adap,
@@ -2342,6 +2626,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
 #endif
 		{ "blocked_fl", &blocked_fl_fops, S_IRUSR | S_IWUSR, 0 },
+		{ "meminfo", &meminfo_fops, S_IRUSR, 0 },
 	};
 
 	/* Debug FS nodes common to all T5 and later adapters.
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index ed8a8f3..0626868 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -136,6 +136,20 @@
 #define  INGPACKBOUNDARY_G(x)	(((x) >> INGPACKBOUNDARY_S) \
 				 & INGPACKBOUNDARY_M)
 
+#define VFIFO_ENABLE_S    10
+#define VFIFO_ENABLE_V(x) ((x) << VFIFO_ENABLE_S)
+#define VFIFO_ENABLE_F    VFIFO_ENABLE_V(1U)
+
+#define SGE_DBVFIFO_BADDR_A 0x1138
+
+#define DBVFIFO_SIZE_S    6
+#define DBVFIFO_SIZE_M    0xfffU
+#define DBVFIFO_SIZE_G(x) (((x) >> DBVFIFO_SIZE_S) & DBVFIFO_SIZE_M)
+
+#define T6_DBVFIFO_SIZE_S    0
+#define T6_DBVFIFO_SIZE_M    0x1fffU
+#define T6_DBVFIFO_SIZE_G(x) (((x) >> T6_DBVFIFO_SIZE_S) & T6_DBVFIFO_SIZE_M)
+
 #define GLOBALENABLE_S    0
 #define GLOBALENABLE_V(x) ((x) << GLOBALENABLE_S)
 #define GLOBALENABLE_F    GLOBALENABLE_V(1U)
@@ -303,6 +317,8 @@
 #define SGE_FL_BUFFER_SIZE7_A 0x1060
 #define SGE_FL_BUFFER_SIZE8_A 0x1064
 
+#define SGE_IMSG_CTXT_BADDR_A 0x1088
+#define SGE_FLM_CACHE_BADDR_A 0x108c
 #define SGE_INGRESS_RX_THRESHOLD_A 0x10a0
 
 #define THRESHOLD_0_S    24
@@ -357,6 +373,7 @@
 #define TSVAL_G(x) (((x) >> TSVAL_S) & TSVAL_M)
 
 #define SGE_DBFIFO_STATUS_A 0x10a4
+#define SGE_DBVFIFO_SIZE_A 0x113c
 
 #define HP_INT_THRESH_S    28
 #define HP_INT_THRESH_M    0xfU
@@ -869,6 +886,10 @@
 /* registers for module MA */
 #define MA_EDRAM0_BAR_A 0x77c0
 
+#define EDRAM0_BASE_S    16
+#define EDRAM0_BASE_M    0xfffU
+#define EDRAM0_BASE_G(x) (((x) >> EDRAM0_BASE_S) & EDRAM0_BASE_M)
+
 #define EDRAM0_SIZE_S    0
 #define EDRAM0_SIZE_M    0xfffU
 #define EDRAM0_SIZE_V(x) ((x) << EDRAM0_SIZE_S)
@@ -876,6 +897,10 @@
 
 #define MA_EDRAM1_BAR_A 0x77c4
 
+#define EDRAM1_BASE_S    16
+#define EDRAM1_BASE_M    0xfffU
+#define EDRAM1_BASE_G(x) (((x) >> EDRAM1_BASE_S) & EDRAM1_BASE_M)
+
 #define EDRAM1_SIZE_S    0
 #define EDRAM1_SIZE_M    0xfffU
 #define EDRAM1_SIZE_V(x) ((x) << EDRAM1_SIZE_S)
@@ -883,6 +908,11 @@
 
 #define MA_EXT_MEMORY_BAR_A 0x77c8
 
+#define EXT_MEM_BASE_S    16
+#define EXT_MEM_BASE_M    0xfffU
+#define EXT_MEM_BASE_V(x) ((x) << EXT_MEM_BASE_S)
+#define EXT_MEM_BASE_G(x) (((x) >> EXT_MEM_BASE_S) & EXT_MEM_BASE_M)
+
 #define EXT_MEM_SIZE_S    0
 #define EXT_MEM_SIZE_M    0xfffU
 #define EXT_MEM_SIZE_V(x) ((x) << EXT_MEM_SIZE_S)
@@ -890,6 +920,10 @@
 
 #define MA_EXT_MEMORY1_BAR_A 0x7808
 
+#define EXT_MEM1_BASE_S    16
+#define EXT_MEM1_BASE_M    0xfffU
+#define EXT_MEM1_BASE_G(x) (((x) >> EXT_MEM1_BASE_S) & EXT_MEM1_BASE_M)
+
 #define EXT_MEM1_SIZE_S    0
 #define EXT_MEM1_SIZE_M    0xfffU
 #define EXT_MEM1_SIZE_V(x) ((x) << EXT_MEM1_SIZE_S)
@@ -897,6 +931,10 @@
 
 #define MA_EXT_MEMORY0_BAR_A 0x77c8
 
+#define EXT_MEM0_BASE_S    16
+#define EXT_MEM0_BASE_M    0xfffU
+#define EXT_MEM0_BASE_G(x) (((x) >> EXT_MEM0_BASE_S) & EXT_MEM0_BASE_M)
+
 #define EXT_MEM0_SIZE_S    0
 #define EXT_MEM0_SIZE_M    0xfffU
 #define EXT_MEM0_SIZE_V(x) ((x) << EXT_MEM0_SIZE_S)
@@ -978,6 +1016,10 @@
 
 /* registers for module CIM */
 #define CIM_BOOT_CFG_A 0x7b00
+#define CIM_SDRAM_BASE_ADDR_A 0x7b14
+#define CIM_SDRAM_ADDR_SIZE_A 0x7b18
+#define CIM_EXTMEM2_BASE_ADDR_A 0x7b1c
+#define CIM_EXTMEM2_ADDR_SIZE_A 0x7b20
 #define CIM_PF_MAILBOX_CTRL_SHADOW_COPY_A 0x290
 
 #define  BOOTADDR_M	0xffffff00U
@@ -1236,6 +1278,33 @@
 #define TP_OUT_CONFIG_A		0x7d04
 #define TP_GLOBAL_CONFIG_A	0x7d08
 
+#define TP_CMM_TCB_BASE_A 0x7d10
+#define TP_CMM_MM_BASE_A 0x7d14
+#define TP_CMM_TIMER_BASE_A 0x7d18
+#define TP_PMM_TX_BASE_A 0x7d20
+#define TP_PMM_RX_BASE_A 0x7d28
+#define TP_PMM_RX_PAGE_SIZE_A 0x7d2c
+#define TP_PMM_RX_MAX_PAGE_A 0x7d30
+#define TP_PMM_TX_PAGE_SIZE_A 0x7d34
+#define TP_PMM_TX_MAX_PAGE_A 0x7d38
+#define TP_CMM_MM_MAX_PSTRUCT_A 0x7e6c
+
+#define PMRXNUMCHN_S    31
+#define PMRXNUMCHN_V(x) ((x) << PMRXNUMCHN_S)
+#define PMRXNUMCHN_F    PMRXNUMCHN_V(1U)
+
+#define PMTXNUMCHN_S    30
+#define PMTXNUMCHN_M    0x3U
+#define PMTXNUMCHN_G(x) (((x) >> PMTXNUMCHN_S) & PMTXNUMCHN_M)
+
+#define PMTXMAXPAGE_S    0
+#define PMTXMAXPAGE_M    0x1fffffU
+#define PMTXMAXPAGE_G(x) (((x) >> PMTXMAXPAGE_S) & PMTXMAXPAGE_M)
+
+#define PMRXMAXPAGE_S    0
+#define PMRXMAXPAGE_M    0x1fffffU
+#define PMRXMAXPAGE_G(x) (((x) >> PMRXMAXPAGE_S) & PMRXMAXPAGE_M)
+
 #define DBGLAMODE_S	14
 #define DBGLAMODE_M	0x3U
 #define DBGLAMODE_G(x)	(((x) >> DBGLAMODE_S) & DBGLAMODE_M)
@@ -1343,6 +1412,9 @@
 #define MTUVALUE_G(x) (((x) >> MTUVALUE_S) & MTUVALUE_M)
 
 #define TP_RSS_LKP_TABLE_A	0x7dec
+#define TP_CMM_MM_RX_FLST_BASE_A 0x7e60
+#define TP_CMM_MM_TX_FLST_BASE_A 0x7e64
+#define TP_CMM_MM_PS_FLST_BASE_A 0x7e68
 
 #define LKPTBLROWVLD_S    31
 #define LKPTBLROWVLD_V(x) ((x) << LKPTBLROWVLD_S)
@@ -1488,6 +1560,11 @@
 #define TP_MIB_RQE_DFR_PKT_A	0x64
 
 #define ULP_TX_INT_CAUSE_A	0x8dcc
+#define ULP_TX_TPT_LLIMIT_A	0x8dd4
+#define ULP_TX_TPT_ULIMIT_A	0x8dd8
+#define ULP_TX_PBL_LLIMIT_A	0x8ddc
+#define ULP_TX_PBL_ULIMIT_A	0x8de0
+#define ULP_TX_ERR_TABLE_BASE_A 0x8e04
 
 #define PBL_BOUND_ERR_CH3_S    31
 #define PBL_BOUND_ERR_CH3_V(x) ((x) << PBL_BOUND_ERR_CH3_S)
@@ -2252,12 +2329,32 @@
 #define MATCHSRAM_V(x) ((x) << MATCHSRAM_S)
 #define MATCHSRAM_F    MATCHSRAM_V(1U)
 
+#define MPS_RX_PG_RSV0_A 0x11010
+#define MPS_RX_PG_RSV4_A 0x11020
 #define MPS_RX_PERR_INT_CAUSE_A 0x11074
+#define MPS_RX_MAC_BG_PG_CNT0_A 0x11208
+#define MPS_RX_LPBK_BG_PG_CNT0_A 0x11218
 
 #define MPS_CLS_TCAM_Y_L_A 0xf000
 #define MPS_CLS_TCAM_DATA0_A 0xf000
 #define MPS_CLS_TCAM_DATA1_A 0xf004
 
+#define USED_S    16
+#define USED_M    0x7ffU
+#define USED_G(x) (((x) >> USED_S) & USED_M)
+
+#define ALLOC_S    0
+#define ALLOC_M    0x7ffU
+#define ALLOC_G(x) (((x) >> ALLOC_S) & ALLOC_M)
+
+#define T5_USED_S    16
+#define T5_USED_M    0xfffU
+#define T5_USED_G(x) (((x) >> T5_USED_S) & T5_USED_M)
+
+#define T5_ALLOC_S    0
+#define T5_ALLOC_M    0xfffU
+#define T5_ALLOC_G(x) (((x) >> T5_ALLOC_S) & T5_ALLOC_M)
+
 #define DMACH_S    0
 #define DMACH_M    0xffffU
 #define DMACH_G(x) (((x) >> DMACH_S) & DMACH_M)
@@ -2415,8 +2512,21 @@
 #define SLVFIFOPARINT_F    SLVFIFOPARINT_V(1U)
 
 #define ULP_RX_INT_CAUSE_A 0x19158
+#define ULP_RX_ISCSI_LLIMIT_A 0x1915c
+#define ULP_RX_ISCSI_ULIMIT_A 0x19160
 #define ULP_RX_ISCSI_TAGMASK_A 0x19164
 #define ULP_RX_ISCSI_PSZ_A 0x19168
+#define ULP_RX_TDDP_LLIMIT_A 0x1916c
+#define ULP_RX_TDDP_ULIMIT_A 0x19170
+#define ULP_RX_STAG_LLIMIT_A 0x1917c
+#define ULP_RX_STAG_ULIMIT_A 0x19180
+#define ULP_RX_RQ_LLIMIT_A 0x19184
+#define ULP_RX_RQ_ULIMIT_A 0x19188
+#define ULP_RX_PBL_LLIMIT_A 0x1918c
+#define ULP_RX_PBL_ULIMIT_A 0x19190
+#define ULP_RX_CTX_BASE_A 0x19194
+#define ULP_RX_RQUDP_LLIMIT_A 0x191a4
+#define ULP_RX_RQUDP_ULIMIT_A 0x191a8
 #define ULP_RX_LA_CTL_A 0x1923c
 #define ULP_RX_LA_RDPTR_A 0x19240
 #define ULP_RX_LA_RDDATA_A 0x19244
@@ -2617,7 +2727,15 @@
 #define T6_LIPMISS_V(x) ((x) << T6_LIPMISS_S)
 #define T6_LIPMISS_F    T6_LIPMISS_V(1U)
 
+#define LE_DB_CONFIG_A 0x19c04
+#define LE_DB_HASH_TID_BASE_A 0x19c30
+#define LE_DB_HASH_TBL_BASE_ADDR_A 0x19c30
 #define LE_DB_INT_CAUSE_A 0x19c3c
+#define LE_DB_TID_HASHBASE_A 0x19df8
+
+#define HASHEN_S    20
+#define HASHEN_V(x) ((x) << HASHEN_S)
+#define HASHEN_F    HASHEN_V(1U)
 
 #define REQQPARERR_S    16
 #define REQQPARERR_V(x) ((x) << REQQPARERR_S)
@@ -2639,6 +2757,10 @@
 #define LIP0_V(x) ((x) << LIP0_S)
 #define LIP0_F    LIP0_V(1U)
 
+#define BASEADDR_S    3
+#define BASEADDR_M    0x1fffffffU
+#define BASEADDR_G(x) (((x) >> BASEADDR_S) & BASEADDR_M)
+
 #define TCAMINTPERR_S    13
 #define TCAMINTPERR_V(x) ((x) << TCAMINTPERR_S)
 #define TCAMINTPERR_F    TCAMINTPERR_V(1U)
-- 
2.3.4
