From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/4] cxgb4: Add support for mps_tcam debugfs
Date: Thu, 16 Oct 2014 06:52:04 +0530
Message-ID: <1413422524-14054-5-git-send-email-hariprasad@chelsio.com>
References: <1413422524-14054-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, kumaras@chelsio.com,
	nirranjan@chelsio.com, santosh@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:46069
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751450AbaJPBQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2014 21:16:38 -0400
In-Reply-To: <1413422524-14054-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Debug log to get the MPS TCAM table

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  130 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   16 +++
 2 files changed, 146 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index e8b84dc..7d114ed 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -435,6 +435,135 @@ static const struct file_operations devlog_fops = {
 	.release = seq_release_private
 };
 
+static inline void tcamxy2valmask(u64 x, u64 y, u8 *addr, u64 *mask)
+{
+	*mask = x | y;
+	y = (__force u64)cpu_to_be64(y);
+	memcpy(addr, (char *)&y + 2, ETH_ALEN);
+}
+
+static int mps_tcam_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN)
+		seq_puts(seq, "Idx  Ethernet address     Mask     Vld Ports PF"
+			 "  VF              Replication             P0 P1 P2 P3  ML\n");
+	else {
+		u64 mask;
+		u8 addr[ETH_ALEN];
+		struct adapter *adap = seq->private;
+		unsigned int idx = (uintptr_t)v - 2;
+		u64 tcamy = t4_read_reg64(adap, MPS_CLS_TCAM_Y_L(idx));
+		u64 tcamx = t4_read_reg64(adap, MPS_CLS_TCAM_X_L(idx));
+		u32 cls_lo = t4_read_reg(adap, MPS_CLS_SRAM_L(idx));
+		u32 cls_hi = t4_read_reg(adap, MPS_CLS_SRAM_H(idx));
+		u32 rplc[4] = {0, 0, 0, 0};
+
+		if (tcamx & tcamy) {
+			seq_printf(seq, "%3u         -\n", idx);
+			goto out;
+		}
+
+		if (cls_lo & REPLICATE) {
+			struct fw_ldst_cmd ldst_cmd;
+			int ret;
+
+			memset(&ldst_cmd, 0, sizeof(ldst_cmd));
+			ldst_cmd.op_to_addrspace =
+				htonl(FW_CMD_OP(FW_LDST_CMD) |
+				      FW_CMD_REQUEST |
+				      FW_CMD_READ |
+				      FW_LDST_CMD_ADDRSPACE(
+					      FW_LDST_ADDRSPC_MPS));
+			ldst_cmd.cycles_to_len16 = htonl(FW_LEN16(ldst_cmd));
+			ldst_cmd.u.mps.fid_ctl =
+				htons(FW_LDST_CMD_FID(FW_LDST_MPS_RPLC) |
+				      FW_LDST_CMD_CTL(idx));
+			ret = t4_wr_mbox(adap, adap->mbox, &ldst_cmd,
+					 sizeof(ldst_cmd), &ldst_cmd);
+			if (ret)
+				dev_warn(adap->pdev_dev, "Can't read MPS "
+					 "replication map for idx %d: %d\n",
+					 idx, -ret);
+			else {
+				rplc[0] = ntohl(ldst_cmd.u.mps.rplc31_0);
+				rplc[1] = ntohl(ldst_cmd.u.mps.rplc63_32);
+				rplc[2] = ntohl(ldst_cmd.u.mps.rplc95_64);
+				rplc[3] = ntohl(ldst_cmd.u.mps.rplc127_96);
+			}
+		}
+
+		tcamxy2valmask(tcamx, tcamy, addr, &mask);
+		seq_printf(seq, "%3u %02x:%02x:%02x:%02x:%02x:%02x %012llx"
+			   "%3c   %#x%4u%4d",
+			   idx, addr[0], addr[1], addr[2], addr[3], addr[4],
+			   addr[5], (unsigned long long)mask,
+			   (cls_lo & SRAM_VLD) ? 'Y' : 'N', PORTMAP_GET(cls_hi),
+			   PF_GET(cls_lo),
+			   (cls_lo & VF_VALID) ? VF_GET(cls_lo) : -1);
+		if (cls_lo & REPLICATE)
+			seq_printf(seq, " %08x %08x %08x %08x",
+				   rplc[3], rplc[2], rplc[1], rplc[0]);
+		else
+			seq_printf(seq, "%36c", ' ');
+		seq_printf(seq, "%4u%3u%3u%3u %#x\n",
+			   SRAM_PRIO0_GET(cls_lo), SRAM_PRIO1_GET(cls_lo),
+			   SRAM_PRIO2_GET(cls_lo), SRAM_PRIO3_GET(cls_lo),
+			   (cls_lo >> MULTILISTEN0_SHIFT) & 0xf);
+	}
+out:	return 0;
+}
+
+static inline void *mps_tcam_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct adapter *adap = seq->private;
+	int max_mac_addr = is_t4(adap->params.chip) ?
+				NUM_MPS_CLS_SRAM_L_INSTANCES :
+				NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
+	return ((pos <= max_mac_addr) ? (void *)(uintptr_t)(pos + 1) : NULL);
+}
+
+static void *mps_tcam_start(struct seq_file *seq, loff_t *pos)
+{
+	return *pos ? mps_tcam_get_idx(seq, *pos) : SEQ_START_TOKEN;
+}
+
+static void *mps_tcam_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return mps_tcam_get_idx(seq, *pos);
+}
+
+static void mps_tcam_stop(struct seq_file *seq, void *v)
+{
+}
+
+static const struct seq_operations mps_tcam_seq_ops = {
+	.start = mps_tcam_start,
+	.next  = mps_tcam_next,
+	.stop  = mps_tcam_stop,
+	.show  = mps_tcam_show
+};
+
+static int mps_tcam_open(struct inode *inode, struct file *file)
+{
+	int res = seq_open(file, &mps_tcam_seq_ops);
+
+	if (!res) {
+		struct seq_file *seq = file->private_data;
+
+		seq->private = inode->i_private;
+	}
+	return res;
+}
+
+static const struct file_operations mps_tcam_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = mps_tcam_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
 static ssize_t mem_read(struct file *file, char __user *buf, size_t count,
 			loff_t *ppos)
 {
@@ -517,6 +646,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "cim_qcfg", &cim_qcfg_fops, S_IRUSR, 0 },
 		{ "devlog", &devlog_fops, S_IRUSR, 0 },
 		{ "l2t", &t4_l2t_fops, S_IRUSR, 0},
+		{ "mps_tcam", &mps_tcam_debugfs_fops, S_IRUSR, 0 },
 	};
 
 	add_debugfs_files(adap,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 562cd70..6c4369e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1054,6 +1054,22 @@
 
 #define MPS_RX_PERR_INT_CAUSE 0x11074
 
+#define MPS_CLS_TCAM_Y_L(idx) (0xf000 + (idx) * 16)
+#define MPS_CLS_TCAM_X_L(idx) (0xf008 + (idx) * 16)
+#define MPS_CLS_SRAM_L(idx) (0xe000 + (idx) * 8)
+#define MPS_CLS_SRAM_H(idx) (0xe004 + (idx) * 8)
+#define REPLICATE    (1U << 11)
+#define SRAM_VLD    (1U << 12)
+#define SRAM_PRIO0_GET(x) (((x) >> 13) & 0x7U)
+#define SRAM_PRIO1_GET(x) (((x) >> 16) & 0x7U)
+#define SRAM_PRIO2_GET(x) (((x) >> 19) & 0x7U)
+#define SRAM_PRIO3_GET(x) (((x) >> 22) & 0x7U)
+#define PORTMAP_GET(x) (((x) >> 0) & 0xfU)
+#define PF_GET(x) (((x) >> 8) & 0x7U)
+#define VF_GET(x) (((x) >> 0) & 0x7fU)
+#define VF_VALID    (1U << 7)
+#define MULTILISTEN0_SHIFT    25
+
 #define CPL_INTR_CAUSE 0x19054
 #define  CIM_OP_MAP_PERR   0x00000020U
 #define  CIM_OVFL_ERROR    0x00000010U
-- 
1.7.1
