From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH net-next 04/11] fjes: Add debugfs entry for statistics
Date: Mon, 11 Apr 2016 17:10:16 +0900
Message-ID: <1460362216-15165-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwym03.jp.fujitsu.com ([211.128.242.42]:38535 "EHLO
	mgwym03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbcDKISm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 04:18:42 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by yt-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id 8232FAC0133
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 17:18:33 +0900 (JST)
In-Reply-To: <1460362136-14968-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces debugfs entry named "statistics"
for statistics information.
You can get net_stats information by reading
/sys/kernel/debug/fjes/fjes.N/statistics file.
This is useful for debugging.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_debugfs.c | 72 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 72 insertions(+)

diff --git a/drivers/net/fjes/fjes_debugfs.c b/drivers/net/fjes/fjes_debugfs.c
index d2fd892..b0807c2 100644
--- a/drivers/net/fjes/fjes_debugfs.c
+++ b/drivers/net/fjes/fjes_debugfs.c
@@ -31,6 +31,72 @@
 
 static struct dentry *fjes_debug_root;
 
+static int fjes_dbg_stats_show(struct seq_file *m, void *v)
+{
+	struct fjes_adapter *adapter = m->private;
+	struct fjes_hw *hw = &adapter->hw;
+	int max_epid = hw->max_epid;
+	int my_epid = hw->my_epid;
+	int epidx;
+
+	seq_printf(m, "%41s", " ");
+	for (epidx = 0; epidx < max_epid; epidx++)
+		seq_printf(m, "%10s%d",
+			   my_epid == epidx ? "(self)EP#" : "EP#", epidx);
+	seq_printf(m, "\n");
+
+#define FJES_DEBUGFS_NET_STATS_ENTRY(X) do {				\
+	seq_printf(m, "%-41s", #X);					\
+	for (epidx = 0; epidx < max_epid; epidx++) {			\
+		if (epidx == my_epid)					\
+			seq_printf(m, "          -");			\
+		else							\
+			seq_printf(m, " %10llu",			\
+				   hw->ep_shm_info[epidx].net_stats.X); \
+	}								\
+	seq_printf(m, "\n");						\
+} while (0)
+
+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_packets);
+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_packets);
+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_bytes);
+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_bytes);
+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_dropped);
+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_dropped);
+	FJES_DEBUGFS_NET_STATS_ENTRY(multicast);
+	FJES_DEBUGFS_NET_STATS_ENTRY(collisions);
+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_length_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_over_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_crc_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_frame_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_fifo_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_missed_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_aborted_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_carrier_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_fifo_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_heartbeat_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_window_errors);
+	FJES_DEBUGFS_NET_STATS_ENTRY(rx_compressed);
+	FJES_DEBUGFS_NET_STATS_ENTRY(tx_compressed);
+
+	return 0;
+}
+
+static int fjes_dbg_stats_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, fjes_dbg_stats_show, inode->i_private);
+}
+
+static const struct file_operations fjes_dbg_stats_fops = {
+	.owner		= THIS_MODULE,
+	.open		= fjes_dbg_stats_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 static int fjes_dbg_status_show(struct seq_file *m, void *v)
 {
 	struct fjes_adapter *adapter = m->private;
@@ -89,6 +155,12 @@ void fjes_dbg_adapter_init(struct fjes_adapter *adapter)
 	if (!pfile)
 		dev_err(&adapter->plat_dev->dev,
 			"debugfs status for %s failed\n", name);
+
+	pfile = debugfs_create_file("statistics", 0444, adapter->dbg_adapter,
+				    adapter, &fjes_dbg_stats_fops);
+	if (!pfile)
+		dev_err(&adapter->plat_dev->dev,
+			"debugfs status for %s failed\n", name);
 }
 
 void fjes_dbg_adapter_exit(struct fjes_adapter *adapter)
-- 
2.4.3
