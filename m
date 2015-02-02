From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/8] cxgb4: Add support to dump mbox in debugfs
Date: Mon,  2 Feb 2015 20:23:05 +0530
Message-ID: <1422888789-12016-5-git-send-email-hariprasad@chelsio.com>
References: <1422888789-12016-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	nirranjan@chelsio.com, praveenm@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25071 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751955AbbBBOrp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 09:47:45 -0500
In-Reply-To: <1422888789-12016-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |   85 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h     |    5 +
 3 files changed, 91 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index 5a46273..83e2932 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -40,6 +40,7 @@
 
 #include "cxgb4.h"
 #include "t4_regs.h"
+#include "t4_values.h"
 #include "t4fw_api.h"
 #include "cxgb4_debugfs.h"
 #include "clip_tbl.h"
@@ -920,6 +921,82 @@ static const struct file_operations devlog_fops = {
 	.release = seq_release_private
 };
 
+static int mbox_show(struct seq_file *seq, void *v)
+{
+	static const char * const owner[] = { "none", "FW", "driver",
+					      "unknown" };
+
+	int i;
+	unsigned int mbox = (uintptr_t)seq->private & 7;
+	struct adapter *adap = seq->private - mbox;
+	void __iomem *addr = adap->regs + PF_REG(mbox, CIM_PF_MAILBOX_DATA_A);
+	unsigned int ctrl_reg = (is_t4(adap->params.chip)
+				 ? CIM_PF_MAILBOX_CTRL_A
+				 : CIM_PF_MAILBOX_CTRL_SHADOW_COPY_A);
+	void __iomem *ctrl = adap->regs + PF_REG(mbox, ctrl_reg);
+
+	i = MBOWNER_G(readl(ctrl));
+	seq_printf(seq, "mailbox owned by %s\n\n", owner[i]);
+
+	for (i = 0; i < MBOX_LEN; i += 8)
+		seq_printf(seq, "%016llx\n",
+			   (unsigned long long)readq(addr + i));
+	return 0;
+}
+
+static int mbox_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, mbox_show, inode->i_private);
+}
+
+static ssize_t mbox_write(struct file *file, const char __user *buf,
+			  size_t count, loff_t *pos)
+{
+	int i;
+	char c = '\n', s[256];
+	unsigned long long data[8];
+	const struct inode *ino;
+	unsigned int mbox;
+	struct adapter *adap;
+	void __iomem *addr;
+	void __iomem *ctrl;
+
+	if (count > sizeof(s) - 1 || !count)
+		return -EINVAL;
+	if (copy_from_user(s, buf, count))
+		return -EFAULT;
+	s[count] = '\0';
+
+	if (sscanf(s, "%llx %llx %llx %llx %llx %llx %llx %llx%c", &data[0],
+		   &data[1], &data[2], &data[3], &data[4], &data[5], &data[6],
+		   &data[7], &c) < 8 || c != '\n')
+		return -EINVAL;
+
+	ino = FILE_DATA(file);
+	mbox = (uintptr_t)ino->i_private & 7;
+	adap = ino->i_private - mbox;
+	addr = adap->regs + PF_REG(mbox, CIM_PF_MAILBOX_DATA_A);
+	ctrl = addr + MBOX_LEN;
+
+	if (MBOWNER_G(readl(ctrl)) != X_MBOWNER_PL)
+		return -EBUSY;
+
+	for (i = 0; i < 8; i++)
+		writeq(data[i], addr + 8 * i);
+
+	writel(MBMSGVALID_F | MBOWNER_V(X_MBOWNER_FW), ctrl);
+	return count;
+}
+
+static const struct file_operations mbox_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = mbox_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = single_release,
+	.write   = mbox_write
+};
+
 static ssize_t flash_read(struct file *file, char __user *buf, size_t count,
 			  loff_t *ppos)
 {
@@ -1881,6 +1958,14 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "cim_qcfg", &cim_qcfg_fops, S_IRUSR, 0 },
 		{ "clk", &clk_debugfs_fops, S_IRUSR, 0 },
 		{ "devlog", &devlog_fops, S_IRUSR, 0 },
+		{ "mbox0", &mbox_debugfs_fops, S_IRUSR | S_IWUSR, 0 },
+		{ "mbox1", &mbox_debugfs_fops, S_IRUSR | S_IWUSR, 1 },
+		{ "mbox2", &mbox_debugfs_fops, S_IRUSR | S_IWUSR, 2 },
+		{ "mbox3", &mbox_debugfs_fops, S_IRUSR | S_IWUSR, 3 },
+		{ "mbox4", &mbox_debugfs_fops, S_IRUSR | S_IWUSR, 4 },
+		{ "mbox5", &mbox_debugfs_fops, S_IRUSR | S_IWUSR, 5 },
+		{ "mbox6", &mbox_debugfs_fops, S_IRUSR | S_IWUSR, 6 },
+		{ "mbox7", &mbox_debugfs_fops, S_IRUSR | S_IWUSR, 7 },
 		{ "l2t", &t4_l2t_fops, S_IRUSR, 0},
 		{ "mps_tcam", &mps_tcam_debugfs_fops, S_IRUSR, 0 },
 		{ "rss", &rss_debugfs_fops, S_IRUSR, 0 },
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 91e0ea1..3f18d5c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -947,6 +947,7 @@
 
 /* registers for module CIM */
 #define CIM_BOOT_CFG_A 0x7b00
+#define CIM_PF_MAILBOX_CTRL_SHADOW_COPY_A 0x290
 
 #define  BOOTADDR_M	0xffffff00U
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
index a404844..01a31a5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
@@ -78,6 +78,11 @@
 #define SGE_UDB_GTS		20
 #define SGE_UDB_WCDOORBELL	64
 
+/* CIM register field values.
+ */
+#define X_MBOWNER_FW			1
+#define X_MBOWNER_PL			2
+
 /* PCI-E definitions */
 #define WINDOW_SHIFT_X		10
 #define PCIEOFST_SHIFT_X	10
-- 
1.7.1
