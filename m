From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net-next 3/5] cxgb4: Add support for ULP RX logic analyzer output in debugfs
Date: Fri,  6 Feb 2015 19:32:53 +0530
Message-ID: <1423231375-28004-4-git-send-email-hariprasad@chelsio.com>
References: <1423231375-28004-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:16347 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752535AbbBFN5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:57:25 -0500
In-Reply-To: <1423231375-28004-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dump Upper Layer Protocol RX module command trace

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |    2 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   36 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   15 ++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |    4 ++
 5 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 574e51f..b8fee60 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1182,6 +1182,8 @@ void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
 void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
 		  const unsigned short *alpha, const unsigned short *beta);
 
+void t4_ulprx_read_la(struct adapter *adap, u32 *la_buf);
+
 void t4_mk_filtdelwr(unsigned int ftid, struct fw_filter_wr *wr, int qid);
 
 void t4_wol_magic_enable(struct adapter *adap, unsigned int port,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 1304fe0..5a46273 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -562,6 +562,41 @@ static const struct file_operations tp_la_fops = {
 	.write   = tp_la_write
 };
 
+static int ulprx_la_show(struct seq_file *seq, void *v, int idx)
+{
+	const u32 *p = v;
+
+	if (v == SEQ_START_TOKEN)
+		seq_puts(seq, "      Pcmd        Type   Message"
+			 "                Data\n");
+	else
+		seq_printf(seq, "%08x%08x  %4x  %08x  %08x%08x%08x%08x\n",
+			   p[1], p[0], p[2], p[3], p[7], p[6], p[5], p[4]);
+	return 0;
+}
+
+static int ulprx_la_open(struct inode *inode, struct file *file)
+{
+	struct seq_tab *p;
+	struct adapter *adap = inode->i_private;
+
+	p = seq_open_tab(file, ULPRX_LA_SIZE, 8 * sizeof(u32), 1,
+			 ulprx_la_show);
+	if (!p)
+		return -ENOMEM;
+
+	t4_ulprx_read_la(adap, (u32 *)p->data);
+	return 0;
+}
+
+static const struct file_operations ulprx_la_fops = {
+	.owner   = THIS_MODULE,
+	.open    = ulprx_la_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_private
+};
+
 /* Show the PM memory stats.  These stats include:
  *
  * TX:
@@ -1867,6 +1902,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "obq_sge",  &cim_obq_fops, S_IRUSR, 4 },
 		{ "obq_ncsi", &cim_obq_fops, S_IRUSR, 5 },
 		{ "tp_la", &tp_la_fops, S_IRUSR, 0 },
+		{ "ulprx_la", &ulprx_la_fops, S_IRUSR, 0 },
 		{ "sensors", &sensors_debugfs_fops, S_IRUSR, 0 },
 		{ "pm_stats", &pm_stats_debugfs_fops, S_IRUSR, 0 },
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 96cfa0a..5871c00 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1300,6 +1300,21 @@ int t4_fwcache(struct adapter *adap, enum fw_params_param_dev_fwcache op)
 	return t4_wr_mbox(adap, adap->mbox, &c, sizeof(c), NULL);
 }
 
+void t4_ulprx_read_la(struct adapter *adap, u32 *la_buf)
+{
+	unsigned int i, j;
+
+	for (i = 0; i < 8; i++) {
+		u32 *p = la_buf + i;
+
+		t4_write_reg(adap, ULP_RX_LA_CTL_A, i);
+		j = t4_read_reg(adap, ULP_RX_LA_WRPTR_A);
+		t4_write_reg(adap, ULP_RX_LA_RDPTR_A, j);
+		for (j = 0; j < ULPRX_LA_SIZE; j++, p += 8)
+			*p = t4_read_reg(adap, ULP_RX_LA_RDDATA_A);
+	}
+}
+
 #define ADVERT_MASK (FW_PORT_CAP_SPEED_100M | FW_PORT_CAP_SPEED_1G |\
 		     FW_PORT_CAP_SPEED_10G | FW_PORT_CAP_SPEED_40G | \
 		     FW_PORT_CAP_ANEG)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index f0b98d7..380b15c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -64,6 +64,7 @@ enum {
 	CIM_IBQ_SIZE   = 128,   /* # of 128-bit words in a CIM IBQ */
 	CIM_OBQ_SIZE   = 128,   /* # of 128-bit words in a CIM OBQ */
 	TPLA_SIZE      = 128,   /* # of 64-bit words in TP LA */
+	ULPRX_LA_SIZE  = 512,   /* # of 256-bit words in ULP_RX LA */
 };
 
 enum {
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 15d0ecc..91e0ea1 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -2270,6 +2270,10 @@
 #define ULP_RX_INT_CAUSE_A 0x19158
 #define ULP_RX_ISCSI_TAGMASK_A 0x19164
 #define ULP_RX_ISCSI_PSZ_A 0x19168
+#define ULP_RX_LA_CTL_A 0x1923c
+#define ULP_RX_LA_RDPTR_A 0x19240
+#define ULP_RX_LA_RDDATA_A 0x19244
+#define ULP_RX_LA_WRPTR_A 0x19248
 
 #define HPZ3_S    24
 #define HPZ3_V(x) ((x) << HPZ3_S)
-- 
1.7.1
