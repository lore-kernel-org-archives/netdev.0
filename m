From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 5/8] cxgb4: Add support to dump HW port loopback stats in debugfs
Date: Mon,  2 Feb 2015 20:23:06 +0530
Message-ID: <1422888789-12016-6-git-send-email-hariprasad@chelsio.com>
References: <1422888789-12016-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23695 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751902AbbBBOrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 09:47:48 -0500
In-Reply-To: <1422888789-12016-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   38 +++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   48 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |    1 +
 4 files changed, 88 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 72a948c..e4e0199 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1059,6 +1059,7 @@ int t4_cim_read_la(struct adapter *adap, u32 *la_buf, unsigned int *wrptr);
 void t4_read_cimq_cfg(struct adapter *adap, u16 *base, u16 *size, u16 *thres);
 const char *t4_get_port_type_description(enum fw_port_type port_type);
 void t4_get_port_stats(struct adapter *adap, int idx, struct port_stats *p);
+void t4_get_lb_stats(struct adapter *adap, int idx, struct lb_port_stats *p);
 void t4_read_mtu_tbl(struct adapter *adap, u16 *mtus, u8 *mtu_log);
 void t4_tp_wr_bits_indirect(struct adapter *adap, unsigned int addr,
 			    unsigned int mask, unsigned int val);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 83e2932..5341a00 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1207,6 +1207,43 @@ static int sensors_show(struct seq_file *seq, void *v)
 
 DEFINE_SIMPLE_DEBUGFS_FILE(sensors);
 
+static int lb_stats_show(struct seq_file *seq, void *v)
+{
+	static const char * const stat_name[] = {
+		"OctetsOK:", "FramesOK:", "BcastFrames:", "McastFrames:",
+		"UcastFrames:", "ErrorFrames:", "Frames64:", "Frames65To127:",
+		"Frames128To255:", "Frames256To511:", "Frames512To1023:",
+		"Frames1024To1518:", "Frames1519ToMax:", "FramesDropped:",
+		"BG0FramesDropped:", "BG1FramesDropped:", "BG2FramesDropped:",
+		"BG3FramesDropped:", "BG0FramesTrunc:", "BG1FramesTrunc:",
+		"BG2FramesTrunc:", "BG3FramesTrunc:"
+	};
+
+	int i, j;
+	u64 *p0, *p1;
+	struct lb_port_stats s[2];
+
+	memset(s, 0, sizeof(s));
+
+	for (i = 0; i < 4; i += 2) {
+		t4_get_lb_stats(seq->private, i, &s[0]);
+		t4_get_lb_stats(seq->private, i + 1, &s[1]);
+
+		p0 = &s[0].octets;
+		p1 = &s[1].octets;
+		seq_printf(seq, "%s                       Loopback %u          "
+			   " Loopback %u\n", i == 0 ? "" : "\n", i, i + 1);
+
+		for (j = 0; j < ARRAY_SIZE(stat_name); j++)
+			seq_printf(seq, "%-17s %20llu %20llu\n", stat_name[j],
+				   (unsigned long long)*p0++,
+				   (unsigned long long)*p1++);
+	}
+	return 0;
+}
+
+DEFINE_SIMPLE_DEBUGFS_FILE(lb_stats);
+
 #if IS_ENABLED(CONFIG_IPV6)
 static int clip_tbl_open(struct inode *inode, struct file *file)
 {
@@ -1989,6 +2026,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "tp_la", &tp_la_fops, S_IRUSR, 0 },
 		{ "ulprx_la", &ulprx_la_fops, S_IRUSR, 0 },
 		{ "sensors", &sensors_debugfs_fops, S_IRUSR, 0 },
+		{ "lb_stats", &lb_stats_debugfs_fops, S_IRUSR, 0 },
 		{ "pm_stats", &pm_stats_debugfs_fops, S_IRUSR, 0 },
 #if IS_ENABLED(CONFIG_IPV6)
 		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 9938f2a..2603b64 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2813,6 +2813,54 @@ int t4_wol_pat_enable(struct adapter *adap, unsigned int port, unsigned int map,
 	return 0;
 }
 
+/**
+ *	t4_get_lb_stats - collect loopback port statistics
+ *	@adap: the adapter
+ *	@idx: the loopback port index
+ *	@p: the stats structure to fill
+ *
+ *	Return HW statistics for the given loopback port.
+ */
+void t4_get_lb_stats(struct adapter *adap, int idx, struct lb_port_stats *p)
+{
+	u32 bgmap = get_mps_bg_map(adap, idx);
+
+#define GET_STAT(name) \
+	t4_read_reg64(adap, \
+	(is_t4(adap->params.chip) ? \
+	PORT_REG(idx, MPS_PORT_STAT_LB_PORT_##name##_L) : \
+	T5_PORT_REG(idx, MPS_PORT_STAT_LB_PORT_##name##_L)))
+#define GET_STAT_COM(name) t4_read_reg64(adap, MPS_STAT_##name##_L)
+
+	p->octets           = GET_STAT(BYTES);
+	p->frames           = GET_STAT(FRAMES);
+	p->bcast_frames     = GET_STAT(BCAST);
+	p->mcast_frames     = GET_STAT(MCAST);
+	p->ucast_frames     = GET_STAT(UCAST);
+	p->error_frames     = GET_STAT(ERROR);
+
+	p->frames_64        = GET_STAT(64B);
+	p->frames_65_127    = GET_STAT(65B_127B);
+	p->frames_128_255   = GET_STAT(128B_255B);
+	p->frames_256_511   = GET_STAT(256B_511B);
+	p->frames_512_1023  = GET_STAT(512B_1023B);
+	p->frames_1024_1518 = GET_STAT(1024B_1518B);
+	p->frames_1519_max  = GET_STAT(1519B_MAX);
+	p->drop             = GET_STAT(DROP_FRAMES);
+
+	p->ovflow0 = (bgmap & 1) ? GET_STAT_COM(RX_BG_0_LB_DROP_FRAME) : 0;
+	p->ovflow1 = (bgmap & 2) ? GET_STAT_COM(RX_BG_1_LB_DROP_FRAME) : 0;
+	p->ovflow2 = (bgmap & 4) ? GET_STAT_COM(RX_BG_2_LB_DROP_FRAME) : 0;
+	p->ovflow3 = (bgmap & 8) ? GET_STAT_COM(RX_BG_3_LB_DROP_FRAME) : 0;
+	p->trunc0 = (bgmap & 1) ? GET_STAT_COM(RX_BG_0_LB_TRUNC_FRAME) : 0;
+	p->trunc1 = (bgmap & 2) ? GET_STAT_COM(RX_BG_1_LB_TRUNC_FRAME) : 0;
+	p->trunc2 = (bgmap & 4) ? GET_STAT_COM(RX_BG_2_LB_TRUNC_FRAME) : 0;
+	p->trunc3 = (bgmap & 8) ? GET_STAT_COM(RX_BG_3_LB_TRUNC_FRAME) : 0;
+
+#undef GET_STAT
+#undef GET_STAT_COM
+}
+
 /*     t4_mk_filtdelwr - create a delete filter WR
  *     @ftid: the filter ID
  *     @wr: the filter work request to populate
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 3f18d5c..c91b64b 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1566,6 +1566,7 @@
 #define MPS_PORT_STAT_LB_PORT_1519B_MAX_L 0x520
 #define MPS_PORT_STAT_LB_PORT_1519B_MAX_H 0x524
 #define MPS_PORT_STAT_LB_PORT_DROP_FRAMES 0x528
+#define MPS_PORT_STAT_LB_PORT_DROP_FRAMES_L 0x528
 #define MPS_PORT_STAT_RX_PORT_BYTES_L 0x540
 #define MPS_PORT_STAT_RX_PORT_BYTES_H 0x544
 #define MPS_PORT_STAT_RX_PORT_FRAMES_L 0x548
-- 
1.7.1
