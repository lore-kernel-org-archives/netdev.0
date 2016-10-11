From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 5/6] fjes: Add debugfs entry for EP status information in fjes driver
Date: Tue, 11 Oct 2016 17:55:28 +0900
Message-ID: <1476176128-18902-1-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1476176047-18670-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:52329 "EHLO
        mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752646AbcJKJRo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 05:17:44 -0400
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
        by kw-mxoi2.gw.nic.fujitsu.com (Postfix) with ESMTP id AABEFAC00EE
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 18:06:22 +0900 (JST)
In-Reply-To: <1476176047-18670-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds debugfs entry to show EP status information.
You can get each EP's status information like the following:

  # cat /sys/kernel/debug/fjes/fjes.0/status

EPID    STATUS           SAME_ZONE        CONNECTED
ep0     shared           Y                Y
ep1     -                -                -
ep2     unshared         N                N
ep3     unshared         N                N
ep4     unshared         N                N
ep5     unshared         N                N
ep6     unshared         N                N
ep7     unshared         N                N

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/fjes_debugfs.c | 51 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/drivers/net/fjes/fjes_debugfs.c b/drivers/net/fjes/fjes_debugfs.c
index d868fe7..19528a5 100644
--- a/drivers/net/fjes/fjes_debugfs.c
+++ b/drivers/net/fjes/fjes_debugfs.c
@@ -97,6 +97,51 @@ static const struct file_operations fjes_dbg_dbg_mode_fops = {
 	.write		= fjes_dbg_dbg_mode_write,
 };
 
+static const char * const ep_status_string[] = {
+	"unshared",
+	"shared",
+	"waiting",
+	"complete",
+};
+
+static int fjes_dbg_status_show(struct seq_file *m, void *v)
+{
+	struct fjes_adapter *adapter = m->private;
+	struct fjes_hw *hw = &adapter->hw;
+	int max_epid = hw->max_epid;
+	int my_epid = hw->my_epid;
+	int epidx;
+
+	seq_puts(m, "EPID\tSTATUS           SAME_ZONE        CONNECTED\n");
+	for (epidx = 0; epidx < max_epid; epidx++) {
+		if (epidx == my_epid) {
+			seq_printf(m, "ep%d\t%-16c %-16c %-16c\n",
+				   epidx, '-', '-', '-');
+		} else {
+			seq_printf(m, "ep%d\t%-16s %-16c %-16c\n",
+				   epidx,
+				   ep_status_string[fjes_hw_get_partner_ep_status(hw, epidx)],
+				   fjes_hw_epid_is_same_zone(hw, epidx) ? 'Y' : 'N',
+				   fjes_hw_epid_is_shared(hw->hw_info.share, epidx) ? 'Y' : 'N');
+		}
+	}
+
+	return 0;
+}
+
+static int fjes_dbg_status_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, fjes_dbg_status_show, inode->i_private);
+}
+
+static const struct file_operations fjes_dbg_status_fops = {
+	.owner		= THIS_MODULE,
+	.open		= fjes_dbg_status_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 void fjes_dbg_adapter_init(struct fjes_adapter *adapter)
 {
 	const char *name = dev_name(&adapter->plat_dev->dev);
@@ -132,6 +177,12 @@ void fjes_dbg_adapter_init(struct fjes_adapter *adapter)
 		hw->hw_info.trace = NULL;
 		hw->hw_info.trace_size = 0;
 	}
+
+	pfile = debugfs_create_file("status", 0444, adapter->dbg_adapter,
+				    adapter, &fjes_dbg_status_fops);
+	if (!pfile)
+		dev_err(&adapter->plat_dev->dev,
+			"debugfs status for %s failed\n", name);
 }
 
 void fjes_dbg_adapter_exit(struct fjes_adapter *adapter)
-- 
2.6.6
