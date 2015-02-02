From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 7/8] cxgb4: Added support in debugfs to display tp_err_stats
Date: Mon,  2 Feb 2015 20:23:08 +0530
Message-ID: <1422888789-12016-8-git-send-email-hariprasad@chelsio.com>
References: <1422888789-12016-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3454 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751955AbbBBOry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 09:47:54 -0500
In-Reply-To: <1422888789-12016-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   21 +++++-----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   43 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |   23 ++++++++++
 3 files changed, 77 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index e4e0199..87fe265 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -200,16 +200,16 @@ struct tp_tcp_stats {
 };
 
 struct tp_err_stats {
-	u32 macInErrs[4];
-	u32 hdrInErrs[4];
-	u32 tcpInErrs[4];
-	u32 tnlCongDrops[4];
-	u32 ofldChanDrops[4];
-	u32 tnlTxDrops[4];
-	u32 ofldVlanDrops[4];
-	u32 tcp6InErrs[4];
-	u32 ofldNoNeigh;
-	u32 ofldCongDefer;
+	u32 mac_in_errs[4];
+	u32 hdr_in_errs[4];
+	u32 tcp_in_errs[4];
+	u32 tnl_cong_drops[4];
+	u32 ofld_chan_drops[4];
+	u32 tnl_tx_drops[4];
+	u32 ofld_vlan_drops[4];
+	u32 tcp6_in_errs[4];
+	u32 ofld_no_neigh;
+	u32 ofld_cong_defer;
 };
 
 struct sge_params {
@@ -1066,6 +1066,7 @@ void t4_tp_wr_bits_indirect(struct adapter *adap, unsigned int addr,
 void t4_tp_read_la(struct adapter *adap, u64 *la_buf, unsigned int *wrptr);
 void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
 			 struct tp_tcp_stats *v6);
+void t4_tp_get_err_stats(struct adapter *adap, struct tp_err_stats *st);
 void t4_load_mtus(struct adapter *adap, const unsigned short *mtus,
 		  const unsigned short *alpha, const unsigned short *beta);
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 904f36d..da939f2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -1271,6 +1271,48 @@ static int tp_tcp_stats_show(struct seq_file *seq, void *v)
 
 DEFINE_SIMPLE_DEBUGFS_FILE(tp_tcp_stats);
 
+static int tp_err_stats_show(struct seq_file *seq, void *v)
+{
+	struct tp_err_stats stats;
+	struct adapter *adap = seq->private;
+
+	spin_lock(&adap->stats_lock);
+	t4_tp_get_err_stats(adap, &stats);
+	spin_unlock(&adap->stats_lock);
+
+	seq_puts(seq, "                 channel 0  channel 1  "
+		 "channel 2  channel 3\n");
+	seq_printf(seq, "mac_in_errs:      %10u %10u %10u %10u\n",
+		   stats.mac_in_errs[0], stats.mac_in_errs[1],
+		   stats.mac_in_errs[2], stats.mac_in_errs[3]);
+	seq_printf(seq, "hdr_in_errs:      %10u %10u %10u %10u\n",
+		   stats.hdr_in_errs[0], stats.hdr_in_errs[1],
+		   stats.hdr_in_errs[2], stats.hdr_in_errs[3]);
+	seq_printf(seq, "tcp_in_errs:      %10u %10u %10u %10u\n",
+		   stats.tcp_in_errs[0], stats.tcp_in_errs[1],
+		   stats.tcp_in_errs[2], stats.tcp_in_errs[3]);
+	seq_printf(seq, "tcp6_in_errs:     %10u %10u %10u %10u\n",
+		   stats.tcp6_in_errs[0], stats.tcp6_in_errs[1],
+		   stats.tcp6_in_errs[2], stats.tcp6_in_errs[3]);
+	seq_printf(seq, "tnl_cong_drops:   %10u %10u %10u %10u\n",
+		   stats.tnl_cong_drops[0], stats.tnl_cong_drops[1],
+		   stats.tnl_cong_drops[2], stats.tnl_cong_drops[3]);
+	seq_printf(seq, "tnl_tx_drops:     %10u %10u %10u %10u\n",
+		   stats.tnl_tx_drops[0], stats.tnl_tx_drops[1],
+		   stats.tnl_tx_drops[2], stats.tnl_tx_drops[3]);
+	seq_printf(seq, "ofld_vlan_drops:  %10u %10u %10u %10u\n",
+		   stats.ofld_vlan_drops[0], stats.ofld_vlan_drops[1],
+		   stats.ofld_vlan_drops[2], stats.ofld_vlan_drops[3]);
+	seq_printf(seq, "ofld_chan_drops:  %10u %10u %10u %10u\n\n",
+		   stats.ofld_chan_drops[0], stats.ofld_chan_drops[1],
+		   stats.ofld_chan_drops[2], stats.ofld_chan_drops[3]);
+	seq_printf(seq, "ofld_no_neigh:    %u\nofld_cong_defer:  %u\n",
+		   stats.ofld_no_neigh, stats.ofld_cong_defer);
+	return 0;
+}
+
+DEFINE_SIMPLE_DEBUGFS_FILE(tp_err_stats);
+
 #if IS_ENABLED(CONFIG_IPV6)
 static int clip_tbl_open(struct inode *inode, struct file *file)
 {
@@ -2052,6 +2094,7 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "obq_ncsi", &cim_obq_fops, S_IRUSR, 5 },
 		{ "tp_la", &tp_la_fops, S_IRUSR, 0 },
 		{ "tp_tcp_stats", &tp_tcp_stats_debugfs_fops, S_IRUSR, 0 },
+		{ "tp_err_stats", &tp_err_stats_debugfs_fops, S_IRUSR, 0 },
 		{ "ulprx_la", &ulprx_la_fops, S_IRUSR, 0 },
 		{ "sensors", &sensors_debugfs_fops, S_IRUSR, 0 },
 		{ "lb_stats", &lb_stats_debugfs_fops, S_IRUSR, 0 },
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 2603b64..7e0db7a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -2396,6 +2396,29 @@ void t4_tp_get_tcp_stats(struct adapter *adap, struct tp_tcp_stats *v4,
 }
 
 /**
+ *	t4_tp_get_err_stats - read TP's error MIB counters
+ *	@adap: the adapter
+ *	@st: holds the counter values
+ *
+ *	Returns the values of TP's error counters.
+ */
+void t4_tp_get_err_stats(struct adapter *adap, struct tp_err_stats *st)
+{
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->mac_in_errs, 12, TP_MIB_MAC_IN_ERR_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->tnl_cong_drops, 8, TP_MIB_TNL_CNG_DROP_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->tnl_tx_drops, 4, TP_MIB_TNL_DROP_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->ofld_vlan_drops, 4, TP_MIB_OFD_VLN_DROP_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 st->tcp6_in_errs, 4, TP_MIB_TCP_V6IN_ERR_0_A);
+	t4_read_indirect(adap, TP_MIB_INDEX_A, TP_MIB_DATA_A,
+			 &st->ofld_no_neigh, 2, TP_MIB_OFD_ARP_DROP_A);
+}
+
+/**
  *	t4_read_mtu_tbl - returns the values in the HW path MTU table
  *	@adap: the adapter
  *	@mtus: where to store the MTU values
-- 
1.7.1
