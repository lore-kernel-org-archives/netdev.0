From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/4] cxgb4: Add support for mps_tcam debugfs
Date: Wed,  7 Jan 2015 08:48:03 +0530
Message-ID: <1420600683-23289-5-git-send-email-hariprasad@chelsio.com>
References: <1420600683-23289-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	anish@chelsio.com, Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9066 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754105AbbAGDO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 22:14:59 -0500
In-Reply-To: <1420600683-23289-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Debug log to get the MPS TCAM table

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  131 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |   60 +++++++++
 2 files changed, 191 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index a8b0223..e9f3489 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -433,6 +433,136 @@ static const struct file_operations devlog_fops = {
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
+			 "  VF              Replication             "
+			 "P0 P1 P2 P3  ML\n");
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
+		if (cls_lo & REPLICATE_F) {
+			struct fw_ldst_cmd ldst_cmd;
+			int ret;
+
+			memset(&ldst_cmd, 0, sizeof(ldst_cmd));
+			ldst_cmd.op_to_addrspace =
+				htonl(FW_CMD_OP_V(FW_LDST_CMD) |
+				      FW_CMD_REQUEST_F |
+				      FW_CMD_READ_F |
+				      FW_LDST_CMD_ADDRSPACE_V(
+					      FW_LDST_ADDRSPC_MPS));
+			ldst_cmd.cycles_to_len16 = htonl(FW_LEN16(ldst_cmd));
+			ldst_cmd.u.mps.fid_ctl =
+				htons(FW_LDST_CMD_FID_V(FW_LDST_MPS_RPLC) |
+				      FW_LDST_CMD_CTL_V(idx));
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
+			   (cls_lo & SRAM_VLD_F) ? 'Y' : 'N', PORTMAP_G(cls_hi),
+			   PF_G(cls_lo),
+			   (cls_lo & VF_VALID_F) ? VF_G(cls_lo) : -1);
+		if (cls_lo & REPLICATE_F)
+			seq_printf(seq, " %08x %08x %08x %08x",
+				   rplc[3], rplc[2], rplc[1], rplc[0]);
+		else
+			seq_printf(seq, "%36c", ' ');
+		seq_printf(seq, "%4u%3u%3u%3u %#x\n",
+			   SRAM_PRIO0_G(cls_lo), SRAM_PRIO1_G(cls_lo),
+			   SRAM_PRIO2_G(cls_lo), SRAM_PRIO3_G(cls_lo),
+			   (cls_lo >> MULTILISTEN0_S) & 0xf);
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
@@ -515,6 +645,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "cim_qcfg", &cim_qcfg_fops, S_IRUSR, 0 },
 		{ "devlog", &devlog_fops, S_IRUSR, 0 },
 		{ "l2t", &t4_l2t_fops, S_IRUSR, 0},
+		{ "mps_tcam", &mps_tcam_debugfs_fops, S_IRUSR, 0 },
 	};
 
 	add_debugfs_files(adap,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index a2cae0e..7ce55f9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1708,6 +1708,66 @@
 
 #define MPS_RX_PERR_INT_CAUSE_A 0x11074
 
+#define MPS_CLS_TCAM_Y_L_A 0xf000
+#define MPS_CLS_TCAM_X_L_A 0xf008
+
+#define MPS_CLS_TCAM_Y_L(idx) (MPS_CLS_TCAM_Y_L_A + (idx) * 16)
+#define NUM_MPS_CLS_TCAM_Y_L_INSTANCES 512
+
+#define MPS_CLS_TCAM_X_L(idx) (MPS_CLS_TCAM_X_L_A + (idx) * 16)
+#define NUM_MPS_CLS_TCAM_X_L_INSTANCES 512
+
+#define MPS_CLS_SRAM_L_A 0xe000
+#define MPS_CLS_SRAM_H_A 0xe004
+
+#define MPS_CLS_SRAM_L(idx) (MPS_CLS_SRAM_L_A + (idx) * 8)
+#define NUM_MPS_CLS_SRAM_L_INSTANCES 336
+
+#define MPS_CLS_SRAM_H(idx) (MPS_CLS_SRAM_H_A + (idx) * 8)
+#define NUM_MPS_CLS_SRAM_H_INSTANCES 336
+
+#define MULTILISTEN0_S    25
+
+#define REPLICATE_S    11
+#define REPLICATE_V(x) ((x) << REPLICATE_S)
+#define REPLICATE_F    REPLICATE_V(1U)
+
+#define PF_S    8
+#define PF_M    0x7U
+#define PF_G(x) (((x) >> PF_S) & PF_M)
+
+#define VF_VALID_S    7
+#define VF_VALID_V(x) ((x) << VF_VALID_S)
+#define VF_VALID_F    VF_VALID_V(1U)
+
+#define VF_S    0
+#define VF_M    0x7fU
+#define VF_G(x) (((x) >> VF_S) & VF_M)
+
+#define SRAM_PRIO3_S    22
+#define SRAM_PRIO3_M    0x7U
+#define SRAM_PRIO3_G(x) (((x) >> SRAM_PRIO3_S) & SRAM_PRIO3_M)
+
+#define SRAM_PRIO2_S    19
+#define SRAM_PRIO2_M    0x7U
+#define SRAM_PRIO2_G(x) (((x) >> SRAM_PRIO2_S) & SRAM_PRIO2_M)
+
+#define SRAM_PRIO1_S    16
+#define SRAM_PRIO1_M    0x7U
+#define SRAM_PRIO1_G(x) (((x) >> SRAM_PRIO1_S) & SRAM_PRIO1_M)
+
+#define SRAM_PRIO0_S    13
+#define SRAM_PRIO0_M    0x7U
+#define SRAM_PRIO0_G(x) (((x) >> SRAM_PRIO0_S) & SRAM_PRIO0_M)
+
+#define SRAM_VLD_S    12
+#define SRAM_VLD_V(x) ((x) << SRAM_VLD_S)
+#define SRAM_VLD_F    SRAM_VLD_V(1U)
+
+#define PORTMAP_S    0
+#define PORTMAP_M    0xfU
+#define PORTMAP_G(x) (((x) >> PORTMAP_S) & PORTMAP_M)
+
 #define CPL_INTR_CAUSE_A 0x19054
 
 #define CIM_OP_MAP_PERR_S    5
-- 
1.7.1
