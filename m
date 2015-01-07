From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/4] cxgb4: Add support for cim_qcfg entry in debugfs
Date: Wed,  7 Jan 2015 08:48:02 +0530
Message-ID: <1420600683-23289-4-git-send-email-hariprasad@chelsio.com>
References: <1420600683-23289-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	anish@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:14404 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754105AbbAGDO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 22:14:56 -0500
In-Reply-To: <1420600683-23289-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds debug log to get cim queue config

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   70 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   35 ++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    3 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   55 +++++++++++++++
 5 files changed, 164 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 46cd506..7c785b5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1041,6 +1041,7 @@ int t4_cim_read(struct adapter *adap, unsigned int addr, unsigned int n,
 int t4_cim_write(struct adapter *adap, unsigned int addr, unsigned int n,
 		 const unsigned int *valp);
 int t4_cim_read_la(struct adapter *adap, u32 *la_buf, unsigned int *wrptr);
+void t4_read_cimq_cfg(struct adapter *adap, u16 *base, u16 *size, u16 *thres);
 const char *t4_get_port_type_description(enum fw_port_type port_type);
 void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p);
 void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 0f7b23f..a8b0223 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -168,6 +168,75 @@ static const struct file_operations cim_la_fops = {
 	.release = seq_release_private
 };
 
+static int cim_qcfg_show(struct seq_file *seq, void *v)
+{
+	static const char * const qname[] = {
+		"TP0", "TP1", "ULP", "SGE0", "SGE1", "NC-SI",
+		"ULP0", "ULP1", "ULP2", "ULP3", "SGE", "NC-SI",
+		"SGE0-RX", "SGE1-RX"
+	};
+
+	int i;
+	struct adapter *adap = seq->private;
+	u16 base[CIM_NUM_IBQ + CIM_NUM_OBQ_T5];
+	u16 size[CIM_NUM_IBQ + CIM_NUM_OBQ_T5];
+	u32 stat[(4 * (CIM_NUM_IBQ + CIM_NUM_OBQ_T5))];
+	u16 thres[CIM_NUM_IBQ];
+	u32 obq_wr_t4[2 * CIM_NUM_OBQ], *wr;
+	u32 obq_wr_t5[2 * CIM_NUM_OBQ_T5];
+	u32 *p = stat;
+	int cim_num_obq = is_t4(adap->params.chip) ?
+				CIM_NUM_OBQ : CIM_NUM_OBQ_T5;
+
+	i = t4_cim_read(adap, is_t4(adap->params.chip) ? UP_IBQ_0_RDADDR_A :
+			UP_IBQ_0_SHADOW_RDADDR_A,
+			ARRAY_SIZE(stat), stat);
+	if (!i) {
+		if (is_t4(adap->params.chip)) {
+			i = t4_cim_read(adap, UP_OBQ_0_REALADDR_A,
+					ARRAY_SIZE(obq_wr_t4), obq_wr_t4);
+				wr = obq_wr_t4;
+		} else {
+			i = t4_cim_read(adap, UP_OBQ_0_SHADOW_REALADDR_A,
+					ARRAY_SIZE(obq_wr_t5), obq_wr_t5);
+				wr = obq_wr_t5;
+		}
+	}
+	if (i)
+		return i;
+
+	t4_read_cimq_cfg(adap, base, size, thres);
+
+	seq_printf(seq,
+		   "  Queue  Base  Size Thres  RdPtr WrPtr  SOP  EOP Avail\n");
+	for (i = 0; i < CIM_NUM_IBQ; i++, p += 4)
+		seq_printf(seq, "%7s %5x %5u %5u %6x  %4x %4u %4u %5u\n",
+			   qname[i], base[i], size[i], thres[i],
+			   IBQRDADDR_G(p[0]), IBQWRADDR_G(p[1]),
+			   QUESOPCNT_G(p[3]), QUEEOPCNT_G(p[3]),
+			   QUEREMFLITS_G(p[2]) * 16);
+	for ( ; i < CIM_NUM_IBQ + cim_num_obq; i++, p += 4, wr += 2)
+		seq_printf(seq, "%7s %5x %5u %12x  %4x %4u %4u %5u\n",
+			   qname[i], base[i], size[i],
+			   QUERDADDR_G(p[0]) & 0x3fff, wr[0] - base[i],
+			   QUESOPCNT_G(p[3]), QUEEOPCNT_G(p[3]),
+			   QUEREMFLITS_G(p[2]) * 16);
+	return 0;
+}
+
+static int cim_qcfg_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, cim_qcfg_show, inode->i_private);
+}
+
+static const struct file_operations cim_qcfg_fops = {
+	.owner   = THIS_MODULE,
+	.open    = cim_qcfg_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = single_release,
+};
+
 /* Firmware Device Log dump. */
 static const char * const devlog_level_strings[] = {
 	[FW_DEVLOG_LEVEL_EMERG]		= "EMERG",
@@ -443,6 +512,7 @@ int t4_setup_debugfs(struct adapter *adap)
 
 	static struct t4_debugfs_entry t4_debugfs_files[] = {
 		{ "cim_la", &cim_la_fops, S_IRUSR, 0 },
+		{ "cim_qcfg", &cim_qcfg_fops, S_IRUSR, 0 },
 		{ "devlog", &devlog_fops, S_IRUSR, 0 },
 		{ "l2t", &t4_l2t_fops, S_IRUSR, 0},
 	};
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 1e30554..734d33e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4326,6 +4326,41 @@ int t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 }
 
 /**
+ *	t4_read_cimq_cfg - read CIM queue configuration
+ *	@adap: the adapter
+ *	@base: holds the queue base addresses in bytes
+ *	@size: holds the queue sizes in bytes
+ *	@thres: holds the queue full thresholds in bytes
+ *
+ *	Returns the current configuration of the CIM queues, starting with
+ *	the IBQs, then the OBQs.
+ */
+void t4_read_cimq_cfg(struct adapter *adap, u16 *base, u16 *size, u16 *thres)
+{
+	unsigned int i, v;
+	int cim_num_obq = is_t4(adap->params.chip) ?
+				CIM_NUM_OBQ : CIM_NUM_OBQ_T5;
+
+	for (i = 0; i < CIM_NUM_IBQ; i++) {
+		t4_write_reg(adap, CIM_QUEUE_CONFIG_REF_A, IBQSELECT_F |
+			     QUENUMSELECT_V(i));
+		v = t4_read_reg(adap, CIM_QUEUE_CONFIG_CTRL_A);
+		/* value is in 256-byte units */
+		*base++ = CIMQBASE_G(v) * 256;
+		*size++ = CIMQSIZE_G(v) * 256;
+		*thres++ = QUEFULLTHRSH_G(v) * 8; /* 8-byte unit */
+	}
+	for (i = 0; i < cim_num_obq; i++) {
+		t4_write_reg(adap, CIM_QUEUE_CONFIG_REF_A, OBQSELECT_F |
+			     QUENUMSELECT_V(i));
+		v = t4_read_reg(adap, CIM_QUEUE_CONFIG_CTRL_A);
+		/* value is in 256-byte units */
+		*base++ = CIMQBASE_G(v) * 256;
+		*size++ = CIMQSIZE_G(v) * 256;
+	}
+}
+
+/**
  *	t4_cim_read - read a block from CIM internal address space
  *	@adap: the adapter
  *	@addr: the start address within the CIM address space
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index bcc925b..f6b82da 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -56,6 +56,9 @@ enum {
 };
 
 enum {
+	CIM_NUM_IBQ    = 6,     /* # of CIM IBQs */
+	CIM_NUM_OBQ    = 6,     /* # of CIM OBQs */
+	CIM_NUM_OBQ_T5 = 8,     /* # of CIM OBQs for T5 adapter */
 	CIMLA_SIZE     = 2048,  /* # of 32-bit words in CIM LA */
 };
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 3fe6eeb..a2cae0e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2096,4 +2096,59 @@
 #define UPDBGLACAPTPCONLY_V(x)	((x) << UPDBGLACAPTPCONLY_S)
 #define UPDBGLACAPTPCONLY_F	UPDBGLACAPTPCONLY_V(1U)
 
+#define CIM_QUEUE_CONFIG_REF_A 0x7b48
+#define CIM_QUEUE_CONFIG_CTRL_A 0x7b4c
+
+#define CIMQSIZE_S    24
+#define CIMQSIZE_M    0x3fU
+#define CIMQSIZE_G(x) (((x) >> CIMQSIZE_S) & CIMQSIZE_M)
+
+#define CIMQBASE_S    16
+#define CIMQBASE_M    0x3fU
+#define CIMQBASE_G(x) (((x) >> CIMQBASE_S) & CIMQBASE_M)
+
+#define QUEFULLTHRSH_S    0
+#define QUEFULLTHRSH_M    0x1ffU
+#define QUEFULLTHRSH_G(x) (((x) >> QUEFULLTHRSH_S) & QUEFULLTHRSH_M)
+
+#define UP_IBQ_0_RDADDR_A 0x10
+#define UP_IBQ_0_SHADOW_RDADDR_A 0x280
+#define UP_OBQ_0_REALADDR_A 0x104
+#define UP_OBQ_0_SHADOW_REALADDR_A 0x394
+
+#define IBQRDADDR_S    0
+#define IBQRDADDR_M    0x1fffU
+#define IBQRDADDR_G(x) (((x) >> IBQRDADDR_S) & IBQRDADDR_M)
+
+#define IBQWRADDR_S    0
+#define IBQWRADDR_M    0x1fffU
+#define IBQWRADDR_G(x) (((x) >> IBQWRADDR_S) & IBQWRADDR_M)
+
+#define QUERDADDR_S    0
+#define QUERDADDR_M    0x7fffU
+#define QUERDADDR_G(x) (((x) >> QUERDADDR_S) & QUERDADDR_M)
+
+#define QUEREMFLITS_S    0
+#define QUEREMFLITS_M    0x7ffU
+#define QUEREMFLITS_G(x) (((x) >> QUEREMFLITS_S) & QUEREMFLITS_M)
+
+#define QUEEOPCNT_S    16
+#define QUEEOPCNT_M    0xfffU
+#define QUEEOPCNT_G(x) (((x) >> QUEEOPCNT_S) & QUEEOPCNT_M)
+
+#define QUESOPCNT_S    0
+#define QUESOPCNT_M    0xfffU
+#define QUESOPCNT_G(x) (((x) >> QUESOPCNT_S) & QUESOPCNT_M)
+
+#define OBQSELECT_S    4
+#define OBQSELECT_V(x) ((x) << OBQSELECT_S)
+#define OBQSELECT_F    OBQSELECT_V(1U)
+
+#define IBQSELECT_S    3
+#define IBQSELECT_V(x) ((x) << IBQSELECT_S)
+#define IBQSELECT_F    IBQSELECT_V(1U)
+
+#define QUENUMSELECT_S    0
+#define QUENUMSELECT_V(x) ((x) << QUENUMSELECT_S)
+
 #endif /* __T4_REGS_H */
-- 
1.7.1
