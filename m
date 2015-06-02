From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 2/3] cxgb4: Adds support for T6 adapter
Date: Tue,  2 Jun 2015 13:59:39 +0530
Message-ID: <1433233780-17734-3-git-send-email-hariprasad@chelsio.com>
References: <1433233780-17734-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26551 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754677AbbFBDQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 23:16:34 -0400
In-Reply-To: <1433233780-17734-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds NIC driver related changes for T6 adapter. Register related
changes, MC related changes, VF related changes, doorbell related
changes, debugfs changes, etc

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  11 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c | 180 ++++++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  47 ++++-
 drivers/net/ethernet/chelsio/cxgb4/sge.c           |  47 +++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 218 +++++++++++++++------
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |   3 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       | 105 ++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |   1 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  56 ++++--
 drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h  |   5 +
 10 files changed, 524 insertions(+), 149 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 83773f3..4d3a8c2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -224,7 +224,6 @@ struct sge_params {
 };
 
 struct tp_params {
-	unsigned int ntxchan;        /* # of Tx channels */
 	unsigned int tre;            /* log2 of core clocks per TP tick */
 	unsigned int la_mask;        /* what events are recorded by TP LA */
 	unsigned short tx_modq_map;  /* TX modulation scheduler queue to */
@@ -297,6 +296,15 @@ struct devlog_params {
 	u32 size;                       /* size of log */
 };
 
+/* Stores chip specific parameters */
+struct arch_specific_params {
+	u8 nchan;
+	u16 mps_rplc_size;
+	u16 vfcount;
+	u32 sge_fl_db;
+	u16 mps_tcam_size;
+};
+
 struct adapter_params {
 	struct sge_params sge;
 	struct tp_params  tp;
@@ -322,6 +330,7 @@ struct adapter_params {
 	unsigned char nports;             /* # of ethernet ports */
 	unsigned char portvec;
 	enum chip_type chip;               /* chip code */
+	struct arch_specific_params arch;  /* chip specific params */
 	unsigned char offload;
 
 	unsigned char bypass;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 7cb4237..3719807 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1084,41 +1084,89 @@ static inline void tcamxy2valmask(u64 x, u64 y, u8 *addr, u64 *mask)
 
 static int mps_tcam_show(struct seq_file *seq, void *v)
 {
-	if (v == SEQ_START_TOKEN)
-		seq_puts(seq, "Idx  Ethernet address     Mask     Vld Ports PF"
-			 "  VF              Replication             "
-			 "P0 P1 P2 P3  ML\n");
-	else {
+	struct adapter *adap = seq->private;
+	unsigned int chip_ver = CHELSIO_CHIP_VERSION(adap->params.chip);
+
+	if (v == SEQ_START_TOKEN) {
+		if (adap->params.arch.mps_rplc_size > 128)
+			seq_puts(seq, "Idx  Ethernet address     Mask     "
+				 "Vld Ports PF  VF                           "
+				 "Replication                                "
+				 "    P0 P1 P2 P3  ML\n");
+		else
+			seq_puts(seq, "Idx  Ethernet address     Mask     "
+				 "Vld Ports PF  VF              Replication"
+				 "	         P0 P1 P2 P3  ML\n");
+	} else {
 		u64 mask;
 		u8 addr[ETH_ALEN];
-		struct adapter *adap = seq->private;
+		bool replicate;
 		unsigned int idx = (uintptr_t)v - 2;
-		u64 tcamy = t4_read_reg64(adap, MPS_CLS_TCAM_Y_L(idx));
-		u64 tcamx = t4_read_reg64(adap, MPS_CLS_TCAM_X_L(idx));
-		u32 cls_lo = t4_read_reg(adap, MPS_CLS_SRAM_L(idx));
-		u32 cls_hi = t4_read_reg(adap, MPS_CLS_SRAM_H(idx));
-		u32 rplc[4] = {0, 0, 0, 0};
+		u64 tcamy, tcamx, val;
+		u32 cls_lo, cls_hi, ctl;
+		u32 rplc[8] = {0};
+
+		if (chip_ver > CHELSIO_T5) {
+			/* CtlCmdType - 0: Read, 1: Write
+			 * CtlTcamSel - 0: TCAM0, 1: TCAM1
+			 * CtlXYBitSel- 0: Y bit, 1: X bit
+			 */
+
+			/* Read tcamy */
+			ctl = CTLCMDTYPE_V(0) | CTLXYBITSEL_V(0);
+			if (idx < 256)
+				ctl |= CTLTCAMINDEX_V(idx) | CTLTCAMSEL_V(0);
+			else
+				ctl |= CTLTCAMINDEX_V(idx - 256) |
+				       CTLTCAMSEL_V(1);
+			t4_write_reg(adap, MPS_CLS_TCAM_DATA2_CTL_A, ctl);
+			val = t4_read_reg(adap, MPS_CLS_TCAM_DATA1_A);
+			tcamy = DMACH_G(val) << 32;
+			tcamy |= t4_read_reg(adap, MPS_CLS_TCAM_DATA0_A);
+
+			/* Read tcamx. Change the control param */
+			ctl |= CTLXYBITSEL_V(1);
+			t4_write_reg(adap, MPS_CLS_TCAM_DATA2_CTL_A, ctl);
+			val = t4_read_reg(adap, MPS_CLS_TCAM_DATA1_A);
+			tcamx = DMACH_G(val) << 32;
+			tcamx |= t4_read_reg(adap, MPS_CLS_TCAM_DATA0_A);
+		} else {
+			tcamy = t4_read_reg64(adap, MPS_CLS_TCAM_Y_L(idx));
+			tcamx = t4_read_reg64(adap, MPS_CLS_TCAM_X_L(idx));
+		}
+
+		cls_lo = t4_read_reg(adap, MPS_CLS_SRAM_L(idx));
+		cls_hi = t4_read_reg(adap, MPS_CLS_SRAM_H(idx));
 
 		if (tcamx & tcamy) {
 			seq_printf(seq, "%3u         -\n", idx);
 			goto out;
 		}
 
-		if (cls_lo & REPLICATE_F) {
+		rplc[0] = rplc[1] = rplc[2] = rplc[3] = 0;
+		if (chip_ver > CHELSIO_T5)
+			replicate = (cls_lo & T6_REPLICATE_F);
+		else
+			replicate = (cls_lo & REPLICATE_F);
+
+		if (replicate) {
 			struct fw_ldst_cmd ldst_cmd;
 			int ret;
+			struct fw_ldst_mps_rplc mps_rplc;
+			u32 ldst_addrspc;
 
 			memset(&ldst_cmd, 0, sizeof(ldst_cmd));
+			ldst_addrspc =
+				FW_LDST_CMD_ADDRSPACE_V(FW_LDST_ADDRSPC_MPS);
 			ldst_cmd.op_to_addrspace =
 				htonl(FW_CMD_OP_V(FW_LDST_CMD) |
 				      FW_CMD_REQUEST_F |
 				      FW_CMD_READ_F |
-				      FW_LDST_CMD_ADDRSPACE_V(
-					      FW_LDST_ADDRSPC_MPS));
+				      ldst_addrspc);
 			ldst_cmd.cycles_to_len16 = htonl(FW_LEN16(ldst_cmd));
-			ldst_cmd.u.mps.fid_ctl =
+			ldst_cmd.u.mps.rplc.fid_idx =
 				htons(FW_LDST_CMD_FID_V(FW_LDST_MPS_RPLC) |
-				      FW_LDST_CMD_CTL_V(idx));
+				      FW_LDST_CMD_IDX_V(idx));
 			ret = t4_wr_mbox(adap, adap->mbox, &ldst_cmd,
 					 sizeof(ldst_cmd), &ldst_cmd);
 			if (ret)
@@ -1126,30 +1174,69 @@ static int mps_tcam_show(struct seq_file *seq, void *v)
 					 "replication map for idx %d: %d\n",
 					 idx, -ret);
 			else {
-				rplc[0] = ntohl(ldst_cmd.u.mps.rplc31_0);
-				rplc[1] = ntohl(ldst_cmd.u.mps.rplc63_32);
-				rplc[2] = ntohl(ldst_cmd.u.mps.rplc95_64);
-				rplc[3] = ntohl(ldst_cmd.u.mps.rplc127_96);
+				mps_rplc = ldst_cmd.u.mps.rplc;
+				rplc[0] = ntohl(mps_rplc.rplc31_0);
+				rplc[1] = ntohl(mps_rplc.rplc63_32);
+				rplc[2] = ntohl(mps_rplc.rplc95_64);
+				rplc[3] = ntohl(mps_rplc.rplc127_96);
+				if (adap->params.arch.mps_rplc_size > 128) {
+					rplc[4] = ntohl(mps_rplc.rplc159_128);
+					rplc[5] = ntohl(mps_rplc.rplc191_160);
+					rplc[6] = ntohl(mps_rplc.rplc223_192);
+					rplc[7] = ntohl(mps_rplc.rplc255_224);
+				}
 			}
 		}
 
 		tcamxy2valmask(tcamx, tcamy, addr, &mask);
-		seq_printf(seq, "%3u %02x:%02x:%02x:%02x:%02x:%02x %012llx"
-			   "%3c   %#x%4u%4d",
-			   idx, addr[0], addr[1], addr[2], addr[3], addr[4],
-			   addr[5], (unsigned long long)mask,
-			   (cls_lo & SRAM_VLD_F) ? 'Y' : 'N', PORTMAP_G(cls_hi),
-			   PF_G(cls_lo),
-			   (cls_lo & VF_VALID_F) ? VF_G(cls_lo) : -1);
-		if (cls_lo & REPLICATE_F)
-			seq_printf(seq, " %08x %08x %08x %08x",
-				   rplc[3], rplc[2], rplc[1], rplc[0]);
+		if (chip_ver > CHELSIO_T5)
+			seq_printf(seq, "%3u %02x:%02x:%02x:%02x:%02x:%02x "
+				   "%012llx%3c   %#x%4u%4d",
+				   idx, addr[0], addr[1], addr[2], addr[3],
+				   addr[4], addr[5], (unsigned long long)mask,
+				   (cls_lo & T6_SRAM_VLD_F) ? 'Y' : 'N',
+				   PORTMAP_G(cls_hi),
+				   T6_PF_G(cls_lo),
+				   (cls_lo & T6_VF_VALID_F) ?
+				   T6_VF_G(cls_lo) : -1);
 		else
-			seq_printf(seq, "%36c", ' ');
-		seq_printf(seq, "%4u%3u%3u%3u %#x\n",
-			   SRAM_PRIO0_G(cls_lo), SRAM_PRIO1_G(cls_lo),
-			   SRAM_PRIO2_G(cls_lo), SRAM_PRIO3_G(cls_lo),
-			   (cls_lo >> MULTILISTEN0_S) & 0xf);
+			seq_printf(seq, "%3u %02x:%02x:%02x:%02x:%02x:%02x "
+				   "%012llx%3c   %#x%4u%4d",
+				   idx, addr[0], addr[1], addr[2], addr[3],
+				   addr[4], addr[5], (unsigned long long)mask,
+				   (cls_lo & SRAM_VLD_F) ? 'Y' : 'N',
+				   PORTMAP_G(cls_hi),
+				   PF_G(cls_lo),
+				   (cls_lo & VF_VALID_F) ? VF_G(cls_lo) : -1);
+
+		if (replicate) {
+			if (adap->params.arch.mps_rplc_size > 128)
+				seq_printf(seq, " %08x %08x %08x %08x "
+					   "%08x %08x %08x %08x",
+					   rplc[7], rplc[6], rplc[5], rplc[4],
+					   rplc[3], rplc[2], rplc[1], rplc[0]);
+			else
+				seq_printf(seq, " %08x %08x %08x %08x",
+					   rplc[3], rplc[2], rplc[1], rplc[0]);
+		} else {
+			if (adap->params.arch.mps_rplc_size > 128)
+				seq_printf(seq, "%72c", ' ');
+			else
+				seq_printf(seq, "%36c", ' ');
+		}
+
+		if (chip_ver > CHELSIO_T5)
+			seq_printf(seq, "%4u%3u%3u%3u %#x\n",
+				   T6_SRAM_PRIO0_G(cls_lo),
+				   T6_SRAM_PRIO1_G(cls_lo),
+				   T6_SRAM_PRIO2_G(cls_lo),
+				   T6_SRAM_PRIO3_G(cls_lo),
+				   (cls_lo >> T6_MULTILISTEN0_S) & 0xf);
+		else
+			seq_printf(seq, "%4u%3u%3u%3u %#x\n",
+				   SRAM_PRIO0_G(cls_lo), SRAM_PRIO1_G(cls_lo),
+				   SRAM_PRIO2_G(cls_lo), SRAM_PRIO3_G(cls_lo),
+				   (cls_lo >> MULTILISTEN0_S) & 0xf);
 	}
 out:	return 0;
 }
@@ -1416,6 +1503,9 @@ static int rss_config_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "  HashDelay:     %3d\n", HASHDELAY_G(rssconf));
 	if (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5)
 		seq_printf(seq, "  VfWrAddr:      %3d\n", VFWRADDR_G(rssconf));
+	else
+		seq_printf(seq, "  VfWrAddr:      %3d\n",
+			   T6_VFWRADDR_G(rssconf));
 	seq_printf(seq, "  KeyMode:       %s\n", keymode[KEYMODE_G(rssconf)]);
 	seq_printf(seq, "  VfWrEn:        %3s\n", yesno(rssconf & VFWREN_F));
 	seq_printf(seq, "  KeyWrEn:       %3s\n", yesno(rssconf & KEYWREN_F));
@@ -1634,14 +1724,14 @@ static int rss_vf_config_open(struct inode *inode, struct file *file)
 	struct adapter *adapter = inode->i_private;
 	struct seq_tab *p;
 	struct rss_vf_conf *vfconf;
-	int vf;
+	int vf, vfcount = adapter->params.arch.vfcount;
 
-	p = seq_open_tab(file, 128, sizeof(*vfconf), 1, rss_vf_config_show);
+	p = seq_open_tab(file, vfcount, sizeof(*vfconf), 1, rss_vf_config_show);
 	if (!p)
 		return -ENOMEM;
 
 	vfconf = (struct rss_vf_conf *)p->data;
-	for (vf = 0; vf < 128; vf++) {
+	for (vf = 0; vf < vfcount; vf++) {
 		t4_read_rss_vf_config(adapter, vf, &vfconf[vf].rss_vf_vfl,
 				      &vfconf[vf].rss_vf_vfh);
 	}
@@ -2033,7 +2123,7 @@ void add_debugfs_files(struct adapter *adap,
 int t4_setup_debugfs(struct adapter *adap)
 {
 	int i;
-	u32 size;
+	u32 size = 0;
 	struct dentry *de;
 
 	static struct t4_debugfs_entry t4_debugfs_files[] = {
@@ -2104,12 +2194,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		size = t4_read_reg(adap, MA_EDRAM1_BAR_A);
 		add_debugfs_mem(adap, "edc1", MEM_EDC1, EDRAM1_SIZE_G(size));
 	}
-	if (is_t4(adap->params.chip)) {
-		size = t4_read_reg(adap, MA_EXT_MEMORY_BAR_A);
-		if (i & EXT_MEM_ENABLE_F)
-			add_debugfs_mem(adap, "mc", MEM_MC,
-					EXT_MEM_SIZE_G(size));
-	} else {
+	if (is_t5(adap->params.chip)) {
 		if (i & EXT_MEM0_ENABLE_F) {
 			size = t4_read_reg(adap, MA_EXT_MEMORY0_BAR_A);
 			add_debugfs_mem(adap, "mc0", MEM_MC0,
@@ -2120,6 +2205,11 @@ int t4_setup_debugfs(struct adapter *adap)
 			add_debugfs_mem(adap, "mc1", MEM_MC1,
 					EXT_MEM1_SIZE_G(size));
 		}
+	} else {
+		if (i & EXT_MEM_ENABLE_F)
+			size = t4_read_reg(adap, MA_EXT_MEMORY_BAR_A);
+			add_debugfs_mem(adap, "mc", MEM_MC,
+					EXT_MEM_SIZE_G(size));
 	}
 
 	de = debugfs_create_file_size("flash", S_IRUSR, adap->debugfs_root, adap,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 974b27c..a589591 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -135,8 +135,10 @@ struct filter_entry {
 
 #define FW4_FNAME "cxgb4/t4fw.bin"
 #define FW5_FNAME "cxgb4/t5fw.bin"
+#define FW6_FNAME "cxgb4/t6fw.bin"
 #define FW4_CFNAME "cxgb4/t4-config.txt"
 #define FW5_CFNAME "cxgb4/t5-config.txt"
+#define FW6_CFNAME "cxgb4/t6-config.txt"
 #define PHY_AQ1202_FIRMWARE "cxgb4/aq1202_fw.cld"
 #define PHY_BCM84834_FIRMWARE "cxgb4/bcm8483.bin"
 #define PHY_AQ1202_DEVICEID 0x4409
@@ -1721,7 +1723,7 @@ static int tid_init(struct tid_info *t)
 	bitmap_zero(t->stid_bmap, t->nstids + t->nsftids);
 	/* Reserve stid 0 for T4/T5 adapters */
 	if (!t->stid_base &&
-	    (is_t4(adap->params.chip) || is_t5(adap->params.chip)))
+	    (CHELSIO_CHIP_VERSION(adap->params.chip) <= CHELSIO_T5))
 		__set_bit(0, t->stid_bmap);
 
 	return 0;
@@ -2108,10 +2110,7 @@ int cxgb4_read_tpte(struct net_device *dev, u32 stag, __be32 *tpte)
 		if (offset < mc0_end) {
 			memtype = MEM_MC0;
 			memaddr = offset - edc1_end;
-		} else if (is_t4(adap->params.chip)) {
-			/* T4 only has a single memory channel */
-			goto err;
-		} else {
+		} else if (is_t5(adap->params.chip)) {
 			size = t4_read_reg(adap, MA_EXT_MEMORY1_BAR_A);
 			mc1_size = EXT_MEM1_SIZE_G(size) << 20;
 			mc1_end = mc0_end + mc1_size;
@@ -2122,6 +2121,9 @@ int cxgb4_read_tpte(struct net_device *dev, u32 stag, __be32 *tpte)
 				/* offset beyond the end of any memory */
 				goto err;
 			}
+		} else {
+			/* T4/T6 only has a single memory channel */
+			goto err;
 		}
 	}
 
@@ -2286,9 +2288,13 @@ static void process_db_full(struct work_struct *work)
 	drain_db_fifo(adap, dbfifo_drain_delay);
 	enable_dbs(adap);
 	notify_rdma_uld(adap, CXGB4_CONTROL_DB_EMPTY);
-	t4_set_reg_field(adap, SGE_INT_ENABLE3_A,
-			 DBFIFO_HP_INT_F | DBFIFO_LP_INT_F,
-			 DBFIFO_HP_INT_F | DBFIFO_LP_INT_F);
+	if (CHELSIO_CHIP_VERSION(adap->params.chip) <= CHELSIO_T5)
+		t4_set_reg_field(adap, SGE_INT_ENABLE3_A,
+				 DBFIFO_HP_INT_F | DBFIFO_LP_INT_F,
+				 DBFIFO_HP_INT_F | DBFIFO_LP_INT_F);
+	else
+		t4_set_reg_field(adap, SGE_INT_ENABLE3_A,
+				 DBFIFO_LP_INT_F, DBFIFO_LP_INT_F);
 }
 
 static void sync_txq_pidx(struct adapter *adap, struct sge_txq *q)
@@ -2350,7 +2356,7 @@ static void process_db_drop(struct work_struct *work)
 		drain_db_fifo(adap, dbfifo_drain_delay);
 		enable_dbs(adap);
 		notify_rdma_uld(adap, CXGB4_CONTROL_DB_EMPTY);
-	} else {
+	} else if (is_t5(adap->params.chip)) {
 		u32 dropped_db = t4_read_reg(adap, 0x010ac);
 		u16 qid = (dropped_db >> 15) & 0x1ffff;
 		u16 pidx_inc = dropped_db & 0x1fff;
@@ -2371,7 +2377,8 @@ static void process_db_drop(struct work_struct *work)
 		t4_set_reg_field(adap, 0x10b0, 1<<15, 1<<15);
 	}
 
-	t4_set_reg_field(adap, SGE_DOORBELL_CONTROL_A, DROPPED_DB_F, 0);
+	if (CHELSIO_CHIP_VERSION(adap->params.chip) <= CHELSIO_T5)
+		t4_set_reg_field(adap, SGE_DOORBELL_CONTROL_A, DROPPED_DB_F, 0);
 }
 
 void t4_db_full(struct adapter *adap)
@@ -3390,6 +3397,9 @@ static int adap_init0_config(struct adapter *adapter, int reset)
 	case CHELSIO_T5:
 		fw_config_file = FW5_CFNAME;
 		break;
+	case CHELSIO_T6:
+		fw_config_file = FW6_CFNAME;
+		break;
 	default:
 		dev_err(adapter->pdev_dev, "Device %d is not supported\n",
 		       adapter->pdev->device);
@@ -3586,7 +3596,24 @@ static struct fw_info fw_info_array[] = {
 			.intfver_iscsi = FW_INTFVER(T5, ISCSI),
 			.intfver_fcoe = FW_INTFVER(T5, FCOE),
 		},
+	}, {
+		.chip = CHELSIO_T6,
+		.fs_name = FW6_CFNAME,
+		.fw_mod_name = FW6_FNAME,
+		.fw_hdr = {
+			.chip = FW_HDR_CHIP_T6,
+			.fw_ver = __cpu_to_be32(FW_VERSION(T6)),
+			.intfver_nic = FW_INTFVER(T6, NIC),
+			.intfver_vnic = FW_INTFVER(T6, VNIC),
+			.intfver_ofld = FW_INTFVER(T6, OFLD),
+			.intfver_ri = FW_INTFVER(T6, RI),
+			.intfver_iscsipdu = FW_INTFVER(T6, ISCSIPDU),
+			.intfver_iscsi = FW_INTFVER(T6, ISCSI),
+			.intfver_fcoepdu = FW_INTFVER(T6, FCOEPDU),
+			.intfver_fcoe = FW_INTFVER(T6, FCOE),
+		},
 	}
+
 };
 
 static struct fw_info *find_fw_info(int chip)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index f9c889e..6b7c37fd0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -522,14 +522,13 @@ static void unmap_rx_buf(struct adapter *adap, struct sge_fl *q)
 
 static inline void ring_fl_db(struct adapter *adap, struct sge_fl *q)
 {
-	u32 val;
 	if (q->pend_cred >= 8) {
+		u32 val = adap->params.arch.sge_fl_db;
+
 		if (is_t4(adap->params.chip))
-			val = PIDX_V(q->pend_cred / 8);
+			val |= PIDX_V(q->pend_cred / 8);
 		else
-			val = PIDX_T5_V(q->pend_cred / 8) |
-				DBTYPE_F;
-		val |= DBPRIO_F;
+			val |= PIDX_T5_V(q->pend_cred / 8);
 
 		/* Make sure all memory writes to the Free List queue are
 		 * committed before we tell the hardware about them.
@@ -1034,7 +1033,7 @@ static void inline_tx_skb(const struct sk_buff *skb, const struct sge_txq *q,
  * Figure out what HW csum a packet wants and return the appropriate control
  * bits.
  */
-static u64 hwcsum(const struct sk_buff *skb)
+static u64 hwcsum(enum chip_type chip, const struct sk_buff *skb)
 {
 	int csum_type;
 	const struct iphdr *iph = ip_hdr(skb);
@@ -1065,11 +1064,16 @@ nocsum:			/*
 			goto nocsum;
 	}
 
-	if (likely(csum_type >= TX_CSUM_TCPIP))
-		return TXPKT_CSUM_TYPE_V(csum_type) |
-			TXPKT_IPHDR_LEN_V(skb_network_header_len(skb)) |
-			TXPKT_ETHHDR_LEN_V(skb_network_offset(skb) - ETH_HLEN);
-	else {
+	if (likely(csum_type >= TX_CSUM_TCPIP)) {
+		u64 hdr_len = TXPKT_IPHDR_LEN_V(skb_network_header_len(skb));
+		int eth_hdr_len = skb_network_offset(skb) - ETH_HLEN;
+
+		if (CHELSIO_CHIP_VERSION(chip) <= CHELSIO_T5)
+			hdr_len |= TXPKT_ETHHDR_LEN_V(eth_hdr_len);
+		else
+			hdr_len |= T6_TXPKT_ETHHDR_LEN_V(eth_hdr_len);
+		return TXPKT_CSUM_TYPE_V(csum_type) | hdr_len;
+	} else {
 		int start = skb_transport_offset(skb);
 
 		return TXPKT_CSUM_TYPE_V(csum_type) |
@@ -1237,9 +1241,15 @@ out_free:	dev_kfree_skb_any(skb);
 		else
 			lso->c.len = htonl(LSO_T5_XFER_SIZE_V(skb->len));
 		cpl = (void *)(lso + 1);
-		cntrl = TXPKT_CSUM_TYPE_V(v6 ? TX_CSUM_TCPIP6 : TX_CSUM_TCPIP) |
-			TXPKT_IPHDR_LEN_V(l3hdr_len) |
-			TXPKT_ETHHDR_LEN_V(eth_xtra_len);
+
+		if (CHELSIO_CHIP_VERSION(adap->params.chip) <= CHELSIO_T5)
+			cntrl =	TXPKT_ETHHDR_LEN_V(eth_xtra_len);
+		else
+			cntrl = T6_TXPKT_ETHHDR_LEN_V(eth_xtra_len);
+
+		cntrl |= TXPKT_CSUM_TYPE_V(v6 ?
+					   TX_CSUM_TCPIP6 : TX_CSUM_TCPIP) |
+			 TXPKT_IPHDR_LEN_V(l3hdr_len);
 		q->tso++;
 		q->tx_cso += ssi->gso_segs;
 	} else {
@@ -1248,7 +1258,8 @@ out_free:	dev_kfree_skb_any(skb);
 				       FW_WR_IMMDLEN_V(len));
 		cpl = (void *)(wr + 1);
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			cntrl = hwcsum(skb) | TXPKT_IPCSUM_DIS_F;
+			cntrl = hwcsum(adap->params.chip, skb) |
+				TXPKT_IPCSUM_DIS_F;
 			q->tx_cso++;
 		}
 	}
@@ -2440,6 +2451,8 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 		c.iqns_to_fl0congen = htonl(FW_IQ_CMD_IQFLINTCONGEN_F);
 
 	if (fl) {
+		enum chip_type chip = CHELSIO_CHIP_VERSION(adap->params.chip);
+
 		/* Allocate the ring for the hardware free list (with space
 		 * for its status page) along with the associated software
 		 * descriptor ring.  The free list size needs to be a multiple
@@ -2468,7 +2481,9 @@ int t4_sge_alloc_rxq(struct adapter *adap, struct sge_rspq *iq, bool fwevtq,
 				      FW_IQ_CMD_FL0CONGEN_F);
 		c.fl0dcaen_to_fl0cidxfthresh =
 			htons(FW_IQ_CMD_FL0FBMIN_V(FETCHBURSTMIN_64B_X) |
-			      FW_IQ_CMD_FL0FBMAX_V(FETCHBURSTMAX_512B_X));
+			      FW_IQ_CMD_FL0FBMAX_V((chip <= CHELSIO_T5) ?
+						   FETCHBURSTMAX_512B_X :
+						   FETCHBURSTMAX_256B_X));
 		c.fl0size = htons(flsz);
 		c.fl0addr = cpu_to_be64(fl->addr);
 	}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index e9ccfeb..35a44db 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -150,7 +150,12 @@ void t4_write_indirect(struct adapter *adap, unsigned int addr_reg,
  */
 void t4_hw_pci_read_cfg4(struct adapter *adap, int reg, u32 *val)
 {
-	u32 req = ENABLE_F | FUNCTION_V(adap->pf) | REGISTER_V(reg);
+	u32 req = FUNCTION_V(adap->pf) | REGISTER_V(reg);
+
+	if (CHELSIO_CHIP_VERSION(adap->params.chip) <= CHELSIO_T5)
+		req |= ENABLE_F;
+	else
+		req |= T6_ENABLE_F;
 
 	if (is_t4(adap->params.chip))
 		req |= LOCALCFG_F;
@@ -381,9 +386,8 @@ int t4_memory_rw(struct adapter *adap, int win, int mtype, u32 addr,
 	/* Offset into the region of memory which is being accessed
 	 * MEM_EDC0 = 0
 	 * MEM_EDC1 = 1
-	 * MEM_MC   = 2 -- T4
-	 * MEM_MC0  = 2 -- For T5
-	 * MEM_MC1  = 3 -- For T5
+	 * MEM_MC   = 2 -- MEM_MC for chips with only 1 memory controller
+	 * MEM_MC1  = 3 -- for chips with 2 memory controllers (e.g. T5)
 	 */
 	edc_size  = EDRAM0_SIZE_G(t4_read_reg(adap, MA_EDRAM0_BAR_A));
 	if (mtype != MEM_MC1)
@@ -2292,7 +2296,8 @@ static bool t4_fw_matches_chip(const struct adapter *adap,
 	 * which will keep us "honest" in the future ...
 	 */
 	if ((is_t4(adap->params.chip) && hdr->chip == FW_HDR_CHIP_T4) ||
-	    (is_t5(adap->params.chip) && hdr->chip == FW_HDR_CHIP_T5))
+	    (is_t5(adap->params.chip) && hdr->chip == FW_HDR_CHIP_T5) ||
+	    (is_t6(adap->params.chip) && hdr->chip == FW_HDR_CHIP_T6))
 		return true;
 
 	dev_err(adap->pdev_dev,
@@ -2832,6 +2837,7 @@ static void tp_intr_handler(struct adapter *adapter)
 static void sge_intr_handler(struct adapter *adapter)
 {
 	u64 v;
+	u32 err;
 
 	static const struct intr_info sge_intr_info[] = {
 		{ ERR_CPL_EXCEED_IQE_SIZE_F,
@@ -2840,8 +2846,6 @@ static void sge_intr_handler(struct adapter *adapter)
 		  "SGE GTS CIDX increment too large", -1, 0 },
 		{ ERR_CPL_OPCODE_0_F, "SGE received 0-length CPL", -1, 0 },
 		{ DBFIFO_LP_INT_F, NULL, -1, 0, t4_db_full },
-		{ DBFIFO_HP_INT_F, NULL, -1, 0, t4_db_full },
-		{ ERR_DROPPED_DB_F, NULL, -1, 0, t4_db_dropped },
 		{ ERR_DATA_CPL_ON_HIGH_QID1_F | ERR_DATA_CPL_ON_HIGH_QID0_F,
 		  "SGE IQID > 1023 received CPL for FL", -1, 0 },
 		{ ERR_BAD_DB_PIDX3_F, "SGE DBP 3 pidx increment too large", -1,
@@ -2854,13 +2858,19 @@ static void sge_intr_handler(struct adapter *adapter)
 		  0 },
 		{ ERR_ING_CTXT_PRIO_F,
 		  "SGE too many priority ingress contexts", -1, 0 },
-		{ ERR_EGR_CTXT_PRIO_F,
-		  "SGE too many priority egress contexts", -1, 0 },
 		{ INGRESS_SIZE_ERR_F, "SGE illegal ingress QID", -1, 0 },
 		{ EGRESS_SIZE_ERR_F, "SGE illegal egress QID", -1, 0 },
 		{ 0 }
 	};
 
+	static struct intr_info t4t5_sge_intr_info[] = {
+		{ ERR_DROPPED_DB_F, NULL, -1, 0, t4_db_dropped },
+		{ DBFIFO_HP_INT_F, NULL, -1, 0, t4_db_full },
+		{ ERR_EGR_CTXT_PRIO_F,
+		  "SGE too many priority egress contexts", -1, 0 },
+		{ 0 }
+	};
+
 	v = (u64)t4_read_reg(adapter, SGE_INT_CAUSE1_A) |
 		((u64)t4_read_reg(adapter, SGE_INT_CAUSE2_A) << 32);
 	if (v) {
@@ -2870,8 +2880,23 @@ static void sge_intr_handler(struct adapter *adapter)
 		t4_write_reg(adapter, SGE_INT_CAUSE2_A, v >> 32);
 	}
 
-	if (t4_handle_intr_status(adapter, SGE_INT_CAUSE3_A, sge_intr_info) ||
-	    v != 0)
+	v |= t4_handle_intr_status(adapter, SGE_INT_CAUSE3_A, sge_intr_info);
+	if (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5)
+		v |= t4_handle_intr_status(adapter, SGE_INT_CAUSE3_A,
+					   t4t5_sge_intr_info);
+
+	err = t4_read_reg(adapter, SGE_ERROR_STATS_A);
+	if (err & ERROR_QID_VALID_F) {
+		dev_err(adapter->pdev_dev, "SGE error for queue %u\n",
+			ERROR_QID_G(err));
+		if (err & UNCAPTURED_ERROR_F)
+			dev_err(adapter->pdev_dev,
+				"SGE UNCAPTURED_ERROR set (clearing)\n");
+		t4_write_reg(adapter, SGE_ERROR_STATS_A, ERROR_QID_VALID_F |
+			     UNCAPTURED_ERROR_F);
+	}
+
+	if (v != 0)
 		t4_fatal_err(adapter);
 }
 
@@ -3044,6 +3069,7 @@ static void cplsw_intr_handler(struct adapter *adapter)
  */
 static void le_intr_handler(struct adapter *adap)
 {
+	enum chip_type chip = CHELSIO_CHIP_VERSION(adap->params.chip);
 	static const struct intr_info le_intr_info[] = {
 		{ LIPMISS_F, "LE LIP miss", -1, 0 },
 		{ LIP0_F, "LE 0 LIP error", -1, 0 },
@@ -3053,7 +3079,18 @@ static void le_intr_handler(struct adapter *adap)
 		{ 0 }
 	};
 
-	if (t4_handle_intr_status(adap, LE_DB_INT_CAUSE_A, le_intr_info))
+	static struct intr_info t6_le_intr_info[] = {
+		{ T6_LIPMISS_F, "LE LIP miss", -1, 0 },
+		{ T6_LIP0_F, "LE 0 LIP error", -1, 0 },
+		{ TCAMINTPERR_F, "LE parity error", -1, 1 },
+		{ T6_UNKNOWNCMD_F, "LE unknown command", -1, 1 },
+		{ SSRAMINTPERR_F, "LE request queue parity error", -1, 1 },
+		{ 0 }
+	};
+
+	if (t4_handle_intr_status(adap, LE_DB_INT_CAUSE_A,
+				  (chip <= CHELSIO_T5) ?
+				  le_intr_info : t6_le_intr_info))
 		t4_fatal_err(adap);
 }
 
@@ -3322,7 +3359,7 @@ int t4_slow_intr_handler(struct adapter *adapter)
 		pcie_intr_handler(adapter);
 	if (cause & MC_F)
 		mem_intr_handler(adapter, MEM_MC);
-	if (!is_t4(adapter->params.chip) && (cause & MC1_S))
+	if (is_t5(adapter->params.chip) && (cause & MC1_F))
 		mem_intr_handler(adapter, MEM_MC1);
 	if (cause & EDC0_F)
 		mem_intr_handler(adapter, MEM_EDC0);
@@ -3368,17 +3405,18 @@ int t4_slow_intr_handler(struct adapter *adapter)
  */
 void t4_intr_enable(struct adapter *adapter)
 {
+	u32 val = 0;
 	u32 pf = SOURCEPF_G(t4_read_reg(adapter, PL_WHOAMI_A));
 
+	if (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5)
+		val = ERR_DROPPED_DB_F | ERR_EGR_CTXT_PRIO_F | DBFIFO_HP_INT_F;
 	t4_write_reg(adapter, SGE_INT_ENABLE3_A, ERR_CPL_EXCEED_IQE_SIZE_F |
 		     ERR_INVALID_CIDX_INC_F | ERR_CPL_OPCODE_0_F |
-		     ERR_DROPPED_DB_F | ERR_DATA_CPL_ON_HIGH_QID1_F |
+		     ERR_DATA_CPL_ON_HIGH_QID1_F | INGRESS_SIZE_ERR_F |
 		     ERR_DATA_CPL_ON_HIGH_QID0_F | ERR_BAD_DB_PIDX3_F |
 		     ERR_BAD_DB_PIDX2_F | ERR_BAD_DB_PIDX1_F |
 		     ERR_BAD_DB_PIDX0_F | ERR_ING_CTXT_PRIO_F |
-		     ERR_EGR_CTXT_PRIO_F | INGRESS_SIZE_ERR_F |
-		     DBFIFO_HP_INT_F | DBFIFO_LP_INT_F |
-		     EGRESS_SIZE_ERR_F);
+		     DBFIFO_LP_INT_F | EGRESS_SIZE_ERR_F | val);
 	t4_write_reg(adapter, MYPF_REG(PL_PF_INT_ENABLE_A), PF_INTR_MASK);
 	t4_set_reg_field(adapter, PL_INT_MAP0_A, 0, 1 << pf);
 }
@@ -3592,11 +3630,29 @@ void t4_read_rss_key(struct adapter *adap, u32 *key)
  */
 void t4_write_rss_key(struct adapter *adap, const u32 *key, int idx)
 {
+	u8 rss_key_addr_cnt = 16;
+	u32 vrt = t4_read_reg(adap, TP_RSS_CONFIG_VRT_A);
+
+	/* T6 and later: for KeyMode 3 (per-vf and per-vf scramble),
+	 * allows access to key addresses 16-63 by using KeyWrAddrX
+	 * as index[5:4](upper 2) into key table
+	 */
+	if ((CHELSIO_CHIP_VERSION(adap->params.chip) > CHELSIO_T5) &&
+	    (vrt & KEYEXTEND_F) && (KEYMODE_G(vrt) == 3))
+		rss_key_addr_cnt = 32;
+
 	t4_write_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A, key, 10,
 			  TP_RSS_SECRET_KEY0_A);
-	if (idx >= 0 && idx < 16)
-		t4_write_reg(adap, TP_RSS_CONFIG_VRT_A,
-			     KEYWRADDR_V(idx) | KEYWREN_F);
+
+	if (idx >= 0 && idx < rss_key_addr_cnt) {
+		if (rss_key_addr_cnt > 16)
+			t4_write_reg(adap, TP_RSS_CONFIG_VRT_A,
+				     KEYWRADDRX_V(idx >> 4) |
+				     T6_VFWRADDR_V(idx) | KEYWREN_F);
+		else
+			t4_write_reg(adap, TP_RSS_CONFIG_VRT_A,
+				     KEYWRADDR_V(idx) | KEYWREN_F);
+	}
 }
 
 /**
@@ -3630,8 +3686,13 @@ void t4_read_rss_vf_config(struct adapter *adapter, unsigned int index,
 {
 	u32 vrt, mask, data;
 
-	mask = VFWRADDR_V(VFWRADDR_M);
-	data = VFWRADDR_V(index);
+	if (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5) {
+		mask = VFWRADDR_V(VFWRADDR_M);
+		data = VFWRADDR_V(index);
+	} else {
+		 mask =  T6_VFWRADDR_V(T6_VFWRADDR_M);
+		 data = T6_VFWRADDR_V(index);
+	}
 
 	/* Request that the index'th VF Table values be read into VFL/VFH.
 	 */
@@ -5142,45 +5203,71 @@ int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
 		      unsigned int viid, bool free, unsigned int naddr,
 		      const u8 **addr, u16 *idx, u64 *hash, bool sleep_ok)
 {
-	int i, ret;
+	int offset, ret = 0;
 	struct fw_vi_mac_cmd c;
-	struct fw_vi_mac_exact *p;
-	unsigned int max_naddr = is_t4(adap->params.chip) ?
-				       NUM_MPS_CLS_SRAM_L_INSTANCES :
-				       NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
+	unsigned int nfilters = 0;
+	unsigned int max_naddr = adap->params.arch.mps_tcam_size;
+	unsigned int rem = naddr;
 
-	if (naddr > 7)
+	if (naddr > max_naddr)
 		return -EINVAL;
 
-	memset(&c, 0, sizeof(c));
-	c.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_MAC_CMD) |
-				   FW_CMD_REQUEST_F | FW_CMD_WRITE_F |
-				   (free ? FW_CMD_EXEC_F : 0) |
-				   FW_VI_MAC_CMD_VIID_V(viid));
-	c.freemacs_to_len16 = cpu_to_be32(FW_VI_MAC_CMD_FREEMACS_V(free) |
-					  FW_CMD_LEN16_V((naddr + 2) / 2));
-
-	for (i = 0, p = c.u.exact; i < naddr; i++, p++) {
-		p->valid_to_idx =
-			cpu_to_be16(FW_VI_MAC_CMD_VALID_F |
-				    FW_VI_MAC_CMD_IDX_V(FW_VI_MAC_ADD_MAC));
-		memcpy(p->macaddr, addr[i], sizeof(p->macaddr));
-	}
+	for (offset = 0; offset < naddr ; /**/) {
+		unsigned int fw_naddr = (rem < ARRAY_SIZE(c.u.exact) ?
+					 rem : ARRAY_SIZE(c.u.exact));
+		size_t len16 = DIV_ROUND_UP(offsetof(struct fw_vi_mac_cmd,
+						     u.exact[fw_naddr]), 16);
+		struct fw_vi_mac_exact *p;
+		int i;
 
-	ret = t4_wr_mbox_meat(adap, mbox, &c, sizeof(c), &c, sleep_ok);
-	if (ret)
-		return ret;
+		memset(&c, 0, sizeof(c));
+		c.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_MAC_CMD) |
+					   FW_CMD_REQUEST_F |
+					   FW_CMD_WRITE_F |
+					   FW_CMD_EXEC_V(free) |
+					   FW_VI_MAC_CMD_VIID_V(viid));
+		c.freemacs_to_len16 =
+			cpu_to_be32(FW_VI_MAC_CMD_FREEMACS_V(free) |
+				    FW_CMD_LEN16_V(len16));
+
+		for (i = 0, p = c.u.exact; i < fw_naddr; i++, p++) {
+			p->valid_to_idx =
+				cpu_to_be16(FW_VI_MAC_CMD_VALID_F |
+					    FW_VI_MAC_CMD_IDX_V(
+						    FW_VI_MAC_ADD_MAC));
+			memcpy(p->macaddr, addr[offset + i],
+			       sizeof(p->macaddr));
+		}
 
-	for (i = 0, p = c.u.exact; i < naddr; i++, p++) {
-		u16 index = FW_VI_MAC_CMD_IDX_G(be16_to_cpu(p->valid_to_idx));
+		/* It's okay if we run out of space in our MAC address arena.
+		 * Some of the addresses we submit may get stored so we need
+		 * to run through the reply to see what the results were ...
+		 */
+		ret = t4_wr_mbox_meat(adap, mbox, &c, sizeof(c), &c, sleep_ok);
+		if (ret && ret != -FW_ENOMEM)
+			break;
 
-		if (idx)
-			idx[i] = index >= max_naddr ? 0xffff : index;
-		if (index < max_naddr)
-			ret++;
-		else if (hash)
-			*hash |= (1ULL << hash_mac_addr(addr[i]));
+		for (i = 0, p = c.u.exact; i < fw_naddr; i++, p++) {
+			u16 index = FW_VI_MAC_CMD_IDX_G(
+					be16_to_cpu(p->valid_to_idx));
+
+			if (idx)
+				idx[offset + i] = (index >= max_naddr ?
+						   0xffff : index);
+			if (index < max_naddr)
+				nfilters++;
+			else if (hash)
+				*hash |= (1ULL <<
+					  hash_mac_addr(addr[offset + i]));
+		}
+
+		free = false;
+		offset += fw_naddr;
+		rem -= fw_naddr;
 	}
+
+	if (ret == 0 || ret == -FW_ENOMEM)
+		ret = nfilters;
 	return ret;
 }
 
@@ -5209,9 +5296,7 @@ int t4_change_mac(struct adapter *adap, unsigned int mbox, unsigned int viid,
 	int ret, mode;
 	struct fw_vi_mac_cmd c;
 	struct fw_vi_mac_exact *p = c.u.exact;
-	unsigned int max_mac_addr = is_t4(adap->params.chip) ?
-				    NUM_MPS_CLS_SRAM_L_INSTANCES :
-				    NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
+	unsigned int max_mac_addr = adap->params.arch.mps_tcam_size;
 
 	if (idx < 0)                             /* new allocation */
 		idx = persist ? FW_VI_MAC_ADD_PERSIST_MAC : FW_VI_MAC_ADD_MAC;
@@ -5620,9 +5705,30 @@ int t4_prep_adapter(struct adapter *adapter)
 	switch (ver) {
 	case CHELSIO_T4:
 		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T4, pl_rev);
+		adapter->params.arch.sge_fl_db = DBPRIO_F;
+		adapter->params.arch.mps_tcam_size =
+				 NUM_MPS_CLS_SRAM_L_INSTANCES;
+		adapter->params.arch.mps_rplc_size = 128;
+		adapter->params.arch.nchan = NCHAN;
+		adapter->params.arch.vfcount = 128;
 		break;
 	case CHELSIO_T5:
 		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T5, pl_rev);
+		adapter->params.arch.sge_fl_db = DBPRIO_F | DBTYPE_F;
+		adapter->params.arch.mps_tcam_size =
+				 NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
+		adapter->params.arch.mps_rplc_size = 128;
+		adapter->params.arch.nchan = NCHAN;
+		adapter->params.arch.vfcount = 128;
+		break;
+	case CHELSIO_T6:
+		adapter->params.chip |= CHELSIO_CHIP_CODE(CHELSIO_T6, pl_rev);
+		adapter->params.arch.sge_fl_db = 0;
+		adapter->params.arch.mps_tcam_size =
+				 NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
+		adapter->params.arch.mps_rplc_size = 256;
+		adapter->params.arch.nchan = 2;
+		adapter->params.arch.vfcount = 256;
 		break;
 	default:
 		dev_err(adapter->pdev_dev, "Device %d is not supported\n",
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
index d90f8a0..132cb8f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
@@ -686,6 +686,9 @@ struct cpl_tx_pkt {
 #define TXPKT_ETHHDR_LEN_S    34
 #define TXPKT_ETHHDR_LEN_V(x) ((__u64)(x) << TXPKT_ETHHDR_LEN_S)
 
+#define T6_TXPKT_ETHHDR_LEN_S    32
+#define T6_TXPKT_ETHHDR_LEN_V(x) ((__u64)(x) << T6_TXPKT_ETHHDR_LEN_S)
+
 #define TXPKT_CSUM_TYPE_S    40
 #define TXPKT_CSUM_TYPE_V(x) ((__u64)(x) << TXPKT_CSUM_TYPE_S)
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 326674b..c7fc3d3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -418,6 +418,20 @@
 #define SGE_INGRESS_QUEUES_PER_PAGE_PF_A 0x10f4
 #define SGE_INGRESS_QUEUES_PER_PAGE_VF_A 0x10f8
 
+#define SGE_ERROR_STATS_A 0x1100
+
+#define UNCAPTURED_ERROR_S    18
+#define UNCAPTURED_ERROR_V(x) ((x) << UNCAPTURED_ERROR_S)
+#define UNCAPTURED_ERROR_F    UNCAPTURED_ERROR_V(1U)
+
+#define ERROR_QID_VALID_S    17
+#define ERROR_QID_VALID_V(x) ((x) << ERROR_QID_VALID_S)
+#define ERROR_QID_VALID_F    ERROR_QID_VALID_V(1U)
+
+#define ERROR_QID_S    0
+#define ERROR_QID_M    0x1ffffU
+#define ERROR_QID_G(x) (((x) >> ERROR_QID_S) & ERROR_QID_M)
+
 #define HP_INT_THRESH_S    28
 #define HP_INT_THRESH_M    0xfU
 #define HP_INT_THRESH_V(x) ((x) << HP_INT_THRESH_S)
@@ -705,6 +719,10 @@
 #define REGISTER_S    0
 #define REGISTER_V(x) ((x) << REGISTER_S)
 
+#define T6_ENABLE_S    31
+#define T6_ENABLE_V(x) ((x) << T6_ENABLE_S)
+#define T6_ENABLE_F    T6_ENABLE_V(1U)
+
 #define PFNUM_S    0
 #define PFNUM_V(x) ((x) << PFNUM_S)
 
@@ -2054,6 +2072,11 @@
 #define VFLKPIDX_M    0xffU
 #define VFLKPIDX_G(x) (((x) >> VFLKPIDX_S) & VFLKPIDX_M)
 
+#define T6_VFWRADDR_S    8
+#define T6_VFWRADDR_M    0xffU
+#define T6_VFWRADDR_V(x) ((x) << T6_VFWRADDR_S)
+#define T6_VFWRADDR_G(x) (((x) >> T6_VFWRADDR_S) & T6_VFWRADDR_M)
+
 #define TP_RSS_CONFIG_CNG_A 0x7e04
 #define TP_RSS_SECRET_KEY0_A 0x40
 #define TP_RSS_PF0_CONFIG_A 0x30
@@ -2175,7 +2198,28 @@
 #define MPS_RX_PERR_INT_CAUSE_A 0x11074
 
 #define MPS_CLS_TCAM_Y_L_A 0xf000
+#define MPS_CLS_TCAM_DATA0_A 0xf000
+#define MPS_CLS_TCAM_DATA1_A 0xf004
+
+#define DMACH_S    0
+#define DMACH_M    0xffffU
+#define DMACH_G(x) (((x) >> DMACH_S) & DMACH_M)
+
 #define MPS_CLS_TCAM_X_L_A 0xf008
+#define MPS_CLS_TCAM_DATA2_CTL_A 0xf008
+
+#define CTLCMDTYPE_S    31
+#define CTLCMDTYPE_V(x) ((x) << CTLCMDTYPE_S)
+#define CTLCMDTYPE_F    CTLCMDTYPE_V(1U)
+
+#define CTLTCAMSEL_S    25
+#define CTLTCAMSEL_V(x) ((x) << CTLTCAMSEL_S)
+
+#define CTLTCAMINDEX_S    17
+#define CTLTCAMINDEX_V(x) ((x) << CTLTCAMINDEX_S)
+
+#define CTLXYBITSEL_S    16
+#define CTLXYBITSEL_V(x) ((x) << CTLXYBITSEL_S)
 
 #define MPS_CLS_TCAM_Y_L(idx) (MPS_CLS_TCAM_Y_L_A + (idx) * 16)
 #define NUM_MPS_CLS_TCAM_Y_L_INSTANCES 512
@@ -2184,6 +2228,45 @@
 #define NUM_MPS_CLS_TCAM_X_L_INSTANCES 512
 
 #define MPS_CLS_SRAM_L_A 0xe000
+
+#define T6_MULTILISTEN0_S    26
+
+#define T6_SRAM_PRIO3_S    23
+#define T6_SRAM_PRIO3_M    0x7U
+#define T6_SRAM_PRIO3_G(x) (((x) >> T6_SRAM_PRIO3_S) & T6_SRAM_PRIO3_M)
+
+#define T6_SRAM_PRIO2_S    20
+#define T6_SRAM_PRIO2_M    0x7U
+#define T6_SRAM_PRIO2_G(x) (((x) >> T6_SRAM_PRIO2_S) & T6_SRAM_PRIO2_M)
+
+#define T6_SRAM_PRIO1_S    17
+#define T6_SRAM_PRIO1_M    0x7U
+#define T6_SRAM_PRIO1_G(x) (((x) >> T6_SRAM_PRIO1_S) & T6_SRAM_PRIO1_M)
+
+#define T6_SRAM_PRIO0_S    14
+#define T6_SRAM_PRIO0_M    0x7U
+#define T6_SRAM_PRIO0_G(x) (((x) >> T6_SRAM_PRIO0_S) & T6_SRAM_PRIO0_M)
+
+#define T6_SRAM_VLD_S    13
+#define T6_SRAM_VLD_V(x) ((x) << T6_SRAM_VLD_S)
+#define T6_SRAM_VLD_F    T6_SRAM_VLD_V(1U)
+
+#define T6_REPLICATE_S    12
+#define T6_REPLICATE_V(x) ((x) << T6_REPLICATE_S)
+#define T6_REPLICATE_F    T6_REPLICATE_V(1U)
+
+#define T6_PF_S    9
+#define T6_PF_M    0x7U
+#define T6_PF_G(x) (((x) >> T6_PF_S) & T6_PF_M)
+
+#define T6_VF_VALID_S    8
+#define T6_VF_VALID_V(x) ((x) << T6_VF_VALID_S)
+#define T6_VF_VALID_F    T6_VF_VALID_V(1U)
+
+#define T6_VF_S    0
+#define T6_VF_M    0xffU
+#define T6_VF_G(x) (((x) >> T6_VF_S) & T6_VF_M)
+
 #define MPS_CLS_SRAM_H_A 0xe004
 
 #define MPS_CLS_SRAM_L(idx) (MPS_CLS_SRAM_L_A + (idx) * 8)
@@ -2433,6 +2516,8 @@
 #define CIM_F    CIM_V(1U)
 
 #define MC1_S    31
+#define MC1_V(x) ((x) << MC1_S)
+#define MC1_F    MC1_V(1U)
 
 #define PL_INT_ENABLE_A 0x19410
 #define PL_INT_MAP0_A 0x19414
@@ -2463,6 +2548,18 @@
 #define REV_V(x) ((x) << REV_S)
 #define REV_G(x) (((x) >> REV_S) & REV_M)
 
+#define T6_UNKNOWNCMD_S    3
+#define T6_UNKNOWNCMD_V(x) ((x) << T6_UNKNOWNCMD_S)
+#define T6_UNKNOWNCMD_F    T6_UNKNOWNCMD_V(1U)
+
+#define T6_LIP0_S    2
+#define T6_LIP0_V(x) ((x) << T6_LIP0_S)
+#define T6_LIP0_F    T6_LIP0_V(1U)
+
+#define T6_LIPMISS_S    1
+#define T6_LIPMISS_V(x) ((x) << T6_LIPMISS_S)
+#define T6_LIPMISS_F    T6_LIPMISS_V(1U)
+
 #define LE_DB_INT_CAUSE_A 0x19c3c
 
 #define REQQPARERR_S    16
@@ -2485,6 +2582,14 @@
 #define LIP0_V(x) ((x) << LIP0_S)
 #define LIP0_F    LIP0_V(1U)
 
+#define TCAMINTPERR_S    13
+#define TCAMINTPERR_V(x) ((x) << TCAMINTPERR_S)
+#define TCAMINTPERR_F    TCAMINTPERR_V(1U)
+
+#define SSRAMINTPERR_S    10
+#define SSRAMINTPERR_V(x) ((x) << SSRAMINTPERR_S)
+#define SSRAMINTPERR_F    SSRAMINTPERR_V(1U)
+
 #define NCSI_INT_CAUSE_A 0x1a0d8
 
 #define CIM_DM_PRTY_ERR_S    8
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
index 72ec1f9..7bdee3b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
@@ -63,6 +63,7 @@
 
 #define FETCHBURSTMIN_64B_X		2
 
+#define FETCHBURSTMAX_256B_X		2
 #define FETCHBURSTMAX_512B_X		3
 
 #define HOSTFCMODE_STATUS_PAGE_X	2
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
index 0848317..aceb1e8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
@@ -788,15 +788,27 @@ struct fw_ldst_cmd {
 			__be16 vctl;
 			__be16 rval;
 		} mdio;
-		struct fw_ldst_mps {
-			__be16 fid_ctl;
-			__be16 rplcpf_pkd;
-			__be32 rplc127_96;
-			__be32 rplc95_64;
-			__be32 rplc63_32;
-			__be32 rplc31_0;
-			__be32 atrb;
-			__be16 vlan[16];
+		union fw_ldst_mps {
+			struct fw_ldst_mps_rplc {
+				__be16 fid_idx;
+				__be16 rplcpf_pkd;
+				__be32 rplc255_224;
+				__be32 rplc223_192;
+				__be32 rplc191_160;
+				__be32 rplc159_128;
+				__be32 rplc127_96;
+				__be32 rplc95_64;
+				__be32 rplc63_32;
+				__be32 rplc31_0;
+			} rplc;
+			struct fw_ldst_mps_atrb {
+				__be16 fid_mpsid;
+				__be16 r2[3];
+				__be32 r3[2];
+				__be32 r4;
+				__be32 atrb;
+				__be16 vlan[16];
+			} atrb;
 		} mps;
 		struct fw_ldst_func {
 			u8 access_ctl;
@@ -831,8 +843,8 @@ struct fw_ldst_cmd {
 #define FW_LDST_CMD_FID_S       15
 #define FW_LDST_CMD_FID_V(x)	((x) << FW_LDST_CMD_FID_S)
 
-#define FW_LDST_CMD_CTL_S       0
-#define FW_LDST_CMD_CTL_V(x)	((x) << FW_LDST_CMD_CTL_S)
+#define FW_LDST_CMD_IDX_S	0
+#define FW_LDST_CMD_IDX_V(x)	((x) << FW_LDST_CMD_IDX_S)
 
 #define FW_LDST_CMD_RPLCPF_S    0
 #define FW_LDST_CMD_RPLCPF_V(x)	((x) << FW_LDST_CMD_RPLCPF_S)
@@ -2536,13 +2548,8 @@ enum fw_port_mod_sub_type {
 	FW_PORT_MOD_SUB_TYPE_TWINAX_7 = 0xC,
 };
 
-/* port stats */
-#define FW_NUM_PORT_STATS 50
-#define FW_NUM_PORT_TX_STATS 23
-#define FW_NUM_PORT_RX_STATS 27
-
 enum fw_port_stats_tx_index {
-	FW_STAT_TX_PORT_BYTES_IX,
+	FW_STAT_TX_PORT_BYTES_IX = 0,
 	FW_STAT_TX_PORT_FRAMES_IX,
 	FW_STAT_TX_PORT_BCAST_IX,
 	FW_STAT_TX_PORT_MCAST_IX,
@@ -2564,11 +2571,12 @@ enum fw_port_stats_tx_index {
 	FW_STAT_TX_PORT_PPP4_IX,
 	FW_STAT_TX_PORT_PPP5_IX,
 	FW_STAT_TX_PORT_PPP6_IX,
-	FW_STAT_TX_PORT_PPP7_IX
+	FW_STAT_TX_PORT_PPP7_IX,
+	FW_NUM_PORT_TX_STATS
 };
 
 enum fw_port_stat_rx_index {
-	FW_STAT_RX_PORT_BYTES_IX,
+	FW_STAT_RX_PORT_BYTES_IX = 0,
 	FW_STAT_RX_PORT_FRAMES_IX,
 	FW_STAT_RX_PORT_BCAST_IX,
 	FW_STAT_RX_PORT_MCAST_IX,
@@ -2594,9 +2602,14 @@ enum fw_port_stat_rx_index {
 	FW_STAT_RX_PORT_PPP5_IX,
 	FW_STAT_RX_PORT_PPP6_IX,
 	FW_STAT_RX_PORT_PPP7_IX,
-	FW_STAT_RX_PORT_LESS_64B_IX
+	FW_STAT_RX_PORT_LESS_64B_IX,
+	FW_STAT_RX_PORT_MAC_ERROR_IX,
+	FW_NUM_PORT_RX_STATS
 };
 
+/* port stats */
+#define FW_NUM_PORT_STATS (FW_NUM_PORT_TX_STATS + FW_NUM_PORT_RX_STATS)
+
 struct fw_port_stats_cmd {
 	__be32 op_to_portid;
 	__be32 retval_len16;
@@ -3025,7 +3038,8 @@ struct fw_hdr {
 
 enum fw_hdr_chip {
 	FW_HDR_CHIP_T4,
-	FW_HDR_CHIP_T5
+	FW_HDR_CHIP_T5,
+	FW_HDR_CHIP_T6
 };
 
 #define FW_HDR_FW_VER_MAJOR_S	24
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
index b9d1cba..32b2135 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4fw_version.h
@@ -45,4 +45,9 @@
 #define T5FW_VERSION_MICRO 0x20
 #define T5FW_VERSION_BUILD 0x00
 
+#define T6FW_VERSION_MAJOR 0x01
+#define T6FW_VERSION_MINOR 0x0D
+#define T6FW_VERSION_MICRO 0x2D
+#define T6FW_VERSION_BUILD 0x00
+
 #endif
-- 
2.3.4
