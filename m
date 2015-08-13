From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Add MPS tracing support
Date: Thu, 13 Aug 2015 09:44:22 +0530
Message-ID: <1439439262-27980-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6555 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751962AbbHMEOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 00:14:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Handle TRACE_PKT, stack can sniff them on the first port
Add debubfs enrty to configure tracing for offload traffic like iWARP
& iSCSI for debugging purpose.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   8 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 298 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 113 ++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  56 ++++
 4 files changed, 475 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 58de444..3c99454 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -768,6 +768,10 @@ struct adapter {
 
 	struct dentry *debugfs_root;
 	u32 use_bd;     /* Use SGE Back Door intfc for reading SGE Contexts */
+	u32 trace_rss;	/* 1 implies that different RSS flit per filter is
+			 * used per filter else if 0 default RSS flit is
+			 * used for all 4 filters.
+			 */
 
 	spinlock_t stats_lock;
 	spinlock_t win0_lock ____cacheline_aligned_in_smp;
@@ -1441,6 +1445,10 @@ int t4_sge_ctxt_flush(struct adapter *adap, unsigned int mbox);
 int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl);
 void t4_db_full(struct adapter *adapter);
 void t4_db_dropped(struct adapter *adapter);
+int t4_set_trace_filter(struct adapter *adapter, const struct trace_params *tp,
+			int filter_index, int enable);
+void t4_get_trace_filter(struct adapter *adapter, struct trace_params *tp,
+			 int filter_index, int *enabled);
 int t4_fwaddrspace_write(struct adapter *adap, unsigned int mbox,
 			 u32 addr, u32 val);
 void t4_sge_decode_idma_state(struct adapter *adapter, int state);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index ce075d1..c6b9de1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1201,6 +1201,298 @@ static const struct file_operations mbox_debugfs_fops = {
 	.write   = mbox_write
 };
 
+static int mps_trc_show(struct seq_file *seq, void *v)
+{
+	int enabled, i;
+	struct trace_params tp;
+	unsigned int trcidx = (uintptr_t)seq->private & 3;
+	struct adapter *adap = seq->private - trcidx;
+
+	t4_get_trace_filter(adap, &tp, trcidx, &enabled);
+	if (!enabled) {
+		seq_puts(seq, "tracer is disabled\n");
+		return 0;
+	}
+
+	if (tp.skip_ofst * 8 >= TRACE_LEN) {
+		dev_err(adap->pdev_dev, "illegal trace pattern skip offset\n");
+		return -EINVAL;
+	}
+	if (tp.port < 8) {
+		i = adap->chan_map[tp.port & 3];
+		if (i >= MAX_NPORTS) {
+			dev_err(adap->pdev_dev, "tracer %u is assigned "
+				"to non-existing port\n", trcidx);
+			return -EINVAL;
+		}
+		seq_printf(seq, "tracer is capturing %s %s, ",
+			   adap->port[i]->name, tp.port < 4 ? "Rx" : "Tx");
+	} else
+		seq_printf(seq, "tracer is capturing loopback %d, ",
+			   tp.port - 8);
+	seq_printf(seq, "snap length: %u, min length: %u\n", tp.snap_len,
+		   tp.min_len);
+	seq_printf(seq, "packets captured %smatch filter\n",
+		   tp.invert ? "do not " : "");
+
+	if (tp.skip_ofst) {
+		seq_puts(seq, "filter pattern: ");
+		for (i = 0; i < tp.skip_ofst * 2; i += 2)
+			seq_printf(seq, "%08x%08x", tp.data[i], tp.data[i + 1]);
+		seq_putc(seq, '/');
+		for (i = 0; i < tp.skip_ofst * 2; i += 2)
+			seq_printf(seq, "%08x%08x", tp.mask[i], tp.mask[i + 1]);
+		seq_puts(seq, "@0\n");
+	}
+
+	seq_puts(seq, "filter pattern: ");
+	for (i = tp.skip_ofst * 2; i < TRACE_LEN / 4; i += 2)
+		seq_printf(seq, "%08x%08x", tp.data[i], tp.data[i + 1]);
+	seq_putc(seq, '/');
+	for (i = tp.skip_ofst * 2; i < TRACE_LEN / 4; i += 2)
+		seq_printf(seq, "%08x%08x", tp.mask[i], tp.mask[i + 1]);
+	seq_printf(seq, "@%u\n", (tp.skip_ofst + tp.skip_len) * 8);
+	return 0;
+}
+
+static int mps_trc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mps_trc_show, inode->i_private);
+}
+
+static unsigned int xdigit2int(unsigned char c)
+{
+	return isdigit(c) ? c - '0' : tolower(c) - 'a' + 10;
+}
+
+#define TRC_PORT_NONE 0xff
+#define TRC_RSS_ENABLE 0x33
+#define TRC_RSS_DISABLE 0x13
+
+/* Set an MPS trace filter.  Syntax is:
+ *
+ * disable
+ *
+ * to disable tracing, or
+ *
+ * interface qid=<qid no> [snaplen=<val>] [minlen=<val>] [not] [<pattern>]...
+ *
+ * where interface is one of rxN, txN, or loopbackN, N = 0..3, qid can be one
+ * of the NIC's response qid obtained from sge_qinfo and pattern has the form
+ *
+ * <pattern data>[/<pattern mask>][@<anchor>]
+ *
+ * Up to 2 filter patterns can be specified.  If 2 are supplied the first one
+ * must be anchored at 0.  An omited mask is taken as a mask of 1s, an omitted
+ * anchor is taken as 0.
+ */
+static ssize_t mps_trc_write(struct file *file, const char __user *buf,
+			     size_t count, loff_t *pos)
+{
+	int i, j, enable, ret;
+	u32 *data, *mask;
+	struct trace_params tp;
+	const struct inode *ino;
+	unsigned int trcidx;
+	char *s, *p, *word, *end;
+	struct adapter *adap;
+
+	ino = file_inode(file);
+	trcidx = (uintptr_t)ino->i_private & 3;
+	adap = ino->i_private - trcidx;
+
+	/* Don't accept input more than 1K, can't be anything valid except lots
+	 * of whitespace.  Well, use less.
+	 */
+	if (count > 1024)
+		return -EFBIG;
+	p = s = kzalloc(count + 1, GFP_USER);
+	if (!s)
+		return -ENOMEM;
+	if (copy_from_user(s, buf, count)) {
+		count = -EFAULT;
+		goto out;
+	}
+
+	if (s[count - 1] == '\n')
+		s[count - 1] = '\0';
+
+	enable = strcmp("disable", s) != 0;
+	if (!enable)
+		goto apply;
+
+	/* enable or disable trace multi rss filter */
+	if (adap->trace_rss)
+		t4_write_reg(adap, MPS_TRC_CFG_A, TRC_RSS_ENABLE);
+	else
+		t4_write_reg(adap, MPS_TRC_CFG_A, TRC_RSS_DISABLE);
+
+	memset(&tp, 0, sizeof(tp));
+	tp.port = TRC_PORT_NONE;
+	i = 0;	/* counts pattern nibbles */
+
+	while (p) {
+		while (isspace(*p))
+			p++;
+		word = strsep(&p, " ");
+		if (!*word)
+			break;
+
+		if (!strncmp(word, "qid=", 4)) {
+			end = (char *)word + 4;
+			ret = kstrtoul(end, 10, (unsigned long *)&j);
+			if (ret)
+				goto out;
+			if (!adap->trace_rss) {
+				t4_write_reg(adap, MPS_T5_TRC_RSS_CONTROL_A, j);
+				continue;
+			}
+
+			switch (trcidx) {
+			case 0:
+				t4_write_reg(adap, MPS_TRC_RSS_CONTROL_A, j);
+				break;
+			case 1:
+				t4_write_reg(adap,
+					     MPS_TRC_FILTER1_RSS_CONTROL_A, j);
+				break;
+			case 2:
+				t4_write_reg(adap,
+					     MPS_TRC_FILTER2_RSS_CONTROL_A, j);
+				break;
+			case 3:
+				t4_write_reg(adap,
+					     MPS_TRC_FILTER3_RSS_CONTROL_A, j);
+				break;
+			}
+			continue;
+		}
+		if (!strncmp(word, "snaplen=", 8)) {
+			end = (char *)word + 8;
+			ret = kstrtoul(end, 10, (unsigned long *)&j);
+			if (ret || j > 9600) {
+inval:				count = -EINVAL;
+				goto out;
+			}
+			tp.snap_len = j;
+			continue;
+		}
+		if (!strncmp(word, "minlen=", 7)) {
+			end = (char *)word + 7;
+			ret = kstrtoul(end, 10, (unsigned long *)&j);
+			if (ret || j > TFMINPKTSIZE_M)
+				goto inval;
+			tp.min_len = j;
+			continue;
+		}
+		if (!strcmp(word, "not")) {
+			tp.invert = !tp.invert;
+			continue;
+		}
+		if (!strncmp(word, "loopback", 8) && tp.port == TRC_PORT_NONE) {
+			if (word[8] < '0' || word[8] > '3' || word[9])
+				goto inval;
+			tp.port = word[8] - '0' + 8;
+			continue;
+		}
+		if (!strncmp(word, "tx", 2) && tp.port == TRC_PORT_NONE) {
+			if (word[2] < '0' || word[2] > '3' || word[3])
+				goto inval;
+			tp.port = word[2] - '0' + 4;
+			if (adap->chan_map[tp.port & 3] >= MAX_NPORTS)
+				goto inval;
+			continue;
+		}
+		if (!strncmp(word, "rx", 2) && tp.port == TRC_PORT_NONE) {
+			if (word[2] < '0' || word[2] > '3' || word[3])
+				goto inval;
+			tp.port = word[2] - '0';
+			if (adap->chan_map[tp.port] >= MAX_NPORTS)
+				goto inval;
+			continue;
+		}
+		if (!isxdigit(*word))
+			goto inval;
+
+		/* we have found a trace pattern */
+		if (i) {                            /* split pattern */
+			if (tp.skip_len)            /* too many splits */
+				goto inval;
+			tp.skip_ofst = i / 16;
+		}
+
+		data = &tp.data[i / 8];
+		mask = &tp.mask[i / 8];
+		j = i;
+
+		while (isxdigit(*word)) {
+			if (i >= TRACE_LEN * 2) {
+				count = -EFBIG;
+				goto out;
+			}
+			*data = (*data << 4) + xdigit2int(*word++);
+			if (++i % 8 == 0)
+				data++;
+		}
+		if (*word == '/') {
+			word++;
+			while (isxdigit(*word)) {
+				if (j >= i)         /* mask longer than data */
+					goto inval;
+				*mask = (*mask << 4) + xdigit2int(*word++);
+				if (++j % 8 == 0)
+					mask++;
+			}
+			if (i != j)                 /* mask shorter than data */
+				goto inval;
+		} else {                            /* no mask, use all 1s */
+			for ( ; i - j >= 8; j += 8)
+				*mask++ = 0xffffffff;
+			if (i % 8)
+				*mask = (1 << (i % 8) * 4) - 1;
+		}
+		if (*word == '@') {
+			end = (char *)word + 1;
+			ret = kstrtoul(end, 10, (unsigned long *)&j);
+			if (*end && *end != '\n')
+				goto inval;
+			if (j & 7)          /* doesn't start at multiple of 8 */
+				goto inval;
+			j /= 8;
+			if (j < tp.skip_ofst)     /* overlaps earlier pattern */
+				goto inval;
+			if (j - tp.skip_ofst > 31)            /* skip too big */
+				goto inval;
+			tp.skip_len = j - tp.skip_ofst;
+		}
+		if (i % 8) {
+			*data <<= (8 - i % 8) * 4;
+			*mask <<= (8 - i % 8) * 4;
+			i = (i + 15) & ~15;         /* 8-byte align */
+		}
+	}
+
+	if (tp.port == TRC_PORT_NONE)
+		goto inval;
+
+apply:
+	i = t4_set_trace_filter(adap, &tp, trcidx, enable);
+	if (i)
+		count = i;
+out:
+	kfree(s);
+	return count;
+}
+
+static const struct file_operations mps_trc_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = mps_trc_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = single_release,
+	.write   = mps_trc_write
+};
+
 static ssize_t flash_read(struct file *file, char __user *buf, size_t count,
 			  loff_t *ppos)
 {
@@ -2708,6 +3000,10 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "mbox5", &mbox_debugfs_fops, S_IRUSR | S_IWUSR, 5 },
 		{ "mbox6", &mbox_debugfs_fops, S_IRUSR | S_IWUSR, 6 },
 		{ "mbox7", &mbox_debugfs_fops, S_IRUSR | S_IWUSR, 7 },
+		{ "trace0", &mps_trc_debugfs_fops, S_IRUSR | S_IWUSR, 0 },
+		{ "trace1", &mps_trc_debugfs_fops, S_IRUSR | S_IWUSR, 1 },
+		{ "trace2", &mps_trc_debugfs_fops, S_IRUSR | S_IWUSR, 2 },
+		{ "trace3", &mps_trc_debugfs_fops, S_IRUSR | S_IWUSR, 3 },
 		{ "l2t", &t4_l2t_fops, S_IRUSR, 0},
 		{ "mps_tcam", &mps_tcam_debugfs_fops, S_IRUSR, 0 },
 		{ "rss", &rss_debugfs_fops, S_IRUSR, 0 },
@@ -2788,6 +3084,8 @@ int t4_setup_debugfs(struct adapter *adap)
 				      &flash_debugfs_fops, adap->params.sf_size);
 	debugfs_create_bool("use_backdoor", S_IWUSR | S_IRUSR,
 			    adap->debugfs_root, &adap->use_bd);
+	debugfs_create_bool("trace_rss", S_IWUSR | S_IRUSR,
+			    adap->debugfs_root, &adap->trace_rss);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 91750ad..ac368ef 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4265,6 +4265,119 @@ void t4_get_chan_txrate(struct adapter *adap, u64 *nic_rate, u64 *ofld_rate)
 }
 
 /**
+ *	t4_set_trace_filter - configure one of the tracing filters
+ *	@adap: the adapter
+ *	@tp: the desired trace filter parameters
+ *	@idx: which filter to configure
+ *	@enable: whether to enable or disable the filter
+ *
+ *	Configures one of the tracing filters available in HW.  If @enable is
+ *	%0 @tp is not examined and may be %NULL. The user is responsible to
+ *	set the single/multiple trace mode by writing to MPS_TRC_CFG_A register
+ */
+int t4_set_trace_filter(struct adapter *adap, const struct trace_params *tp,
+			int idx, int enable)
+{
+	int i, ofst = idx * 4;
+	u32 data_reg, mask_reg, cfg;
+	u32 multitrc = TRCMULTIFILTER_F;
+
+	if (!enable) {
+		t4_write_reg(adap, MPS_TRC_FILTER_MATCH_CTL_A_A + ofst, 0);
+		return 0;
+	}
+
+	cfg = t4_read_reg(adap, MPS_TRC_CFG_A);
+	if (cfg & TRCMULTIFILTER_F) {
+		/* If multiple tracers are enabled, then maximum
+		 * capture size is 2.5KB (FIFO size of a single channel)
+		 * minus 2 flits for CPL_TRACE_PKT header.
+		 */
+		if (tp->snap_len > ((10 * 1024 / 4) - (2 * 8)))
+			return -EINVAL;
+	} else {
+		/* If multiple tracers are disabled, to avoid deadlocks
+		 * maximum packet capture size of 9600 bytes is recommended.
+		 * Also in this mode, only trace0 can be enabled and running.
+		 */
+		multitrc = 0;
+		if (tp->snap_len > 9600 || idx)
+			return -EINVAL;
+	}
+
+	if (tp->port > (is_t4(adap->params.chip) ? 11 : 19) || tp->invert > 1 ||
+	    tp->skip_len > TFLENGTH_M || tp->skip_ofst > TFOFFSET_M ||
+	    tp->min_len > TFMINPKTSIZE_M)
+		return -EINVAL;
+
+	/* stop the tracer we'll be changing */
+	t4_write_reg(adap, MPS_TRC_FILTER_MATCH_CTL_A_A + ofst, 0);
+
+	idx *= (MPS_TRC_FILTER1_MATCH_A - MPS_TRC_FILTER0_MATCH_A);
+	data_reg = MPS_TRC_FILTER0_MATCH_A + idx;
+	mask_reg = MPS_TRC_FILTER0_DONT_CARE_A + idx;
+
+	for (i = 0; i < TRACE_LEN / 4; i++, data_reg += 4, mask_reg += 4) {
+		t4_write_reg(adap, data_reg, tp->data[i]);
+		t4_write_reg(adap, mask_reg, ~tp->mask[i]);
+	}
+	t4_write_reg(adap, MPS_TRC_FILTER_MATCH_CTL_B_A + ofst,
+		     TFCAPTUREMAX_V(tp->snap_len) |
+		     TFMINPKTSIZE_V(tp->min_len));
+	t4_write_reg(adap, MPS_TRC_FILTER_MATCH_CTL_A_A + ofst,
+		     TFOFFSET_V(tp->skip_ofst) | TFLENGTH_V(tp->skip_len) |
+		     (is_t4(adap->params.chip) ?
+		     TFPORT_V(tp->port) | TFEN_F | TFINVERTMATCH_V(tp->invert) :
+		     T5_TFPORT_V(tp->port) | T5_TFEN_F |
+		     T5_TFINVERTMATCH_V(tp->invert)));
+
+	return 0;
+}
+
+/**
+ *	t4_get_trace_filter - query one of the tracing filters
+ *	@adap: the adapter
+ *	@tp: the current trace filter parameters
+ *	@idx: which trace filter to query
+ *	@enabled: non-zero if the filter is enabled
+ *
+ *	Returns the current settings of one of the HW tracing filters.
+ */
+void t4_get_trace_filter(struct adapter *adap, struct trace_params *tp, int idx,
+			 int *enabled)
+{
+	u32 ctla, ctlb;
+	int i, ofst = idx * 4;
+	u32 data_reg, mask_reg;
+
+	ctla = t4_read_reg(adap, MPS_TRC_FILTER_MATCH_CTL_A_A + ofst);
+	ctlb = t4_read_reg(adap, MPS_TRC_FILTER_MATCH_CTL_B_A + ofst);
+
+	if (is_t4(adap->params.chip)) {
+		*enabled = !!(ctla & TFEN_F);
+		tp->port =  TFPORT_G(ctla);
+		tp->invert = !!(ctla & TFINVERTMATCH_F);
+	} else {
+		*enabled = !!(ctla & T5_TFEN_F);
+		tp->port = T5_TFPORT_G(ctla);
+		tp->invert = !!(ctla & T5_TFINVERTMATCH_F);
+	}
+	tp->snap_len = TFCAPTUREMAX_G(ctlb);
+	tp->min_len = TFMINPKTSIZE_G(ctlb);
+	tp->skip_ofst = TFOFFSET_G(ctla);
+	tp->skip_len = TFLENGTH_G(ctla);
+
+	ofst = (MPS_TRC_FILTER1_MATCH_A - MPS_TRC_FILTER0_MATCH_A) * idx;
+	data_reg = MPS_TRC_FILTER0_MATCH_A + ofst;
+	mask_reg = MPS_TRC_FILTER0_DONT_CARE_A + ofst;
+
+	for (i = 0; i < TRACE_LEN / 4; i++, data_reg += 4, mask_reg += 4) {
+		tp->mask[i] = ~t4_read_reg(adap, mask_reg);
+		tp->data[i] = t4_read_reg(adap, data_reg) & tp->mask[i];
+	}
+}
+
+/**
  *	t4_pmtx_get_stats - returns the HW stats from PMTX
  *	@adap: the adapter
  *	@cnt: where to store the count statistics
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 4d2c929..fc3044c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1886,6 +1886,9 @@
 #define TRCMULTIFILTER_F    TRCMULTIFILTER_V(1U)
 
 #define MPS_TRC_RSS_CONTROL_A		0x9808
+#define MPS_TRC_FILTER1_RSS_CONTROL_A	0x9ff4
+#define MPS_TRC_FILTER2_RSS_CONTROL_A	0x9ffc
+#define MPS_TRC_FILTER3_RSS_CONTROL_A	0xa004
 #define MPS_T5_TRC_RSS_CONTROL_A	0xa00c
 
 #define RSSCONTROL_S    16
@@ -1894,6 +1897,59 @@
 #define QUEUENUMBER_S    0
 #define QUEUENUMBER_V(x) ((x) << QUEUENUMBER_S)
 
+#define TFINVERTMATCH_S    24
+#define TFINVERTMATCH_V(x) ((x) << TFINVERTMATCH_S)
+#define TFINVERTMATCH_F    TFINVERTMATCH_V(1U)
+
+#define TFEN_S    22
+#define TFEN_V(x) ((x) << TFEN_S)
+#define TFEN_F    TFEN_V(1U)
+
+#define TFPORT_S    18
+#define TFPORT_M    0xfU
+#define TFPORT_V(x) ((x) << TFPORT_S)
+#define TFPORT_G(x) (((x) >> TFPORT_S) & TFPORT_M)
+
+#define TFLENGTH_S    8
+#define TFLENGTH_M    0x1fU
+#define TFLENGTH_V(x) ((x) << TFLENGTH_S)
+#define TFLENGTH_G(x) (((x) >> TFLENGTH_S) & TFLENGTH_M)
+
+#define TFOFFSET_S    0
+#define TFOFFSET_M    0x1fU
+#define TFOFFSET_V(x) ((x) << TFOFFSET_S)
+#define TFOFFSET_G(x) (((x) >> TFOFFSET_S) & TFOFFSET_M)
+
+#define T5_TFINVERTMATCH_S    25
+#define T5_TFINVERTMATCH_V(x) ((x) << T5_TFINVERTMATCH_S)
+#define T5_TFINVERTMATCH_F    T5_TFINVERTMATCH_V(1U)
+
+#define T5_TFEN_S    23
+#define T5_TFEN_V(x) ((x) << T5_TFEN_S)
+#define T5_TFEN_F    T5_TFEN_V(1U)
+
+#define T5_TFPORT_S    18
+#define T5_TFPORT_M    0x1fU
+#define T5_TFPORT_V(x) ((x) << T5_TFPORT_S)
+#define T5_TFPORT_G(x) (((x) >> T5_TFPORT_S) & T5_TFPORT_M)
+
+#define MPS_TRC_FILTER_MATCH_CTL_A_A 0x9810
+#define MPS_TRC_FILTER_MATCH_CTL_B_A 0x9820
+
+#define TFMINPKTSIZE_S    16
+#define TFMINPKTSIZE_M    0x1ffU
+#define TFMINPKTSIZE_V(x) ((x) << TFMINPKTSIZE_S)
+#define TFMINPKTSIZE_G(x) (((x) >> TFMINPKTSIZE_S) & TFMINPKTSIZE_M)
+
+#define TFCAPTUREMAX_S    0
+#define TFCAPTUREMAX_M    0x3fffU
+#define TFCAPTUREMAX_V(x) ((x) << TFCAPTUREMAX_S)
+#define TFCAPTUREMAX_G(x) (((x) >> TFCAPTUREMAX_S) & TFCAPTUREMAX_M)
+
+#define MPS_TRC_FILTER0_MATCH_A 0x9c00
+#define MPS_TRC_FILTER0_DONT_CARE_A 0x9c80
+#define MPS_TRC_FILTER1_MATCH_A 0x9d00
+
 #define TP_RSS_CONFIG_A 0x7df0
 
 #define TNL4TUPENIPV6_S    31
-- 
2.3.4
