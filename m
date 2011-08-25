From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 4/9] stmmac: export DMA TX/RX rings via debugfs.
Date: Thu, 25 Aug 2011 10:00:24 +0200
Message-ID: <1314259229-13767-5-git-send-email-peppe.cavallaro@st.com>
References: <1314259229-13767-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:32838 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751749Ab1HYIBJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 04:01:09 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 5CB1FE6
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:01:07 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 22F9716B2
	for <netdev@vger.kernel.org>; Thu, 25 Aug 2011 08:01:07 +0000 (GMT)
In-Reply-To: <1314259229-13767-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the following debugFs entry to dump the
RX/TX DMA rings:

 /sys/kernel/debug/stmmaceth/descriptors_status

This is an example:
=======================
 RX descriptor ring
=======================
[0] DES0=0x85ee0320 DES1=0x1fff1fff BUF1=0x5fae2022 BUF2=0x0
[1] DES0=0x85ee0320 DES1=0x1fff1fff BUF1=0x5fae0022 BUF2=0x0
[2] DES0=0x81460320 DES1=0x1fff1fff BUF1=0x5f9dd022 BUF2=0x0
...

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Kconfig       |    3 +-
 drivers/net/stmmac/stmmac_main.c |   68 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 70 insertions(+), 1 deletions(-)

diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
index 0a1bd82..57ae3716 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/stmmac/Kconfig
@@ -18,7 +18,8 @@ config STMMAC_MONITOR
 	-- help
 	  To Enable monitoring via debufs.
 	  The stmmac entry in /sys reports the state of the HW monitoring
-	  counters (if supported).
+	  counters (if supported) and other useful debug information
+	  (e.g. DMA TX/RX rings).
 
 config STMMAC_DA
 	bool "STMMAC DMA arbitration scheme"
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 4655fab..50fe89f 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1430,8 +1430,61 @@ static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 #ifdef CONFIG_STMMAC_MONITOR
 static struct dentry *stmmac_fs_dir;
+static struct dentry *stmmac_rings_status;
 static struct dentry *stmmac_mmc;
 
+static int stmmac_sysfs_ring_read(struct seq_file *seq, void *v)
+{
+	struct tmp_s {
+		u64 a;
+		unsigned int b;
+		unsigned int c;
+	};
+	int i;
+	struct net_device *dev = seq->private;
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	seq_printf(seq, "=======================\n");
+	seq_printf(seq, " RX descriptor ring\n");
+	seq_printf(seq, "=======================\n");
+
+	for (i = 0; i < priv->dma_rx_size; i++) {
+		struct tmp_s *x = (struct tmp_s *)(priv->dma_rx + i);
+		seq_printf(seq, "[%d] DES0=0x%x DES1=0x%x BUF1=0x%x BUF2=0x%x",
+			   i, (unsigned int)(x->a),
+			   (unsigned int)((x->a) >> 32), x->b, x->c);
+		seq_printf(seq, "\n");
+	}
+
+	seq_printf(seq, "\n");
+	seq_printf(seq, "=======================\n");
+	seq_printf(seq, "  TX descriptor ring\n");
+	seq_printf(seq, "=======================\n");
+
+	for (i = 0; i < priv->dma_tx_size; i++) {
+		struct tmp_s *x = (struct tmp_s *)(priv->dma_tx + i);
+		seq_printf(seq, "[%d] DES0=0x%x DES1=0x%x BUF1=0x%x BUF2=0x%x",
+			   i, (unsigned int)(x->a),
+			   (unsigned int)((x->a) >> 32), x->b, x->c);
+		seq_printf(seq, "\n");
+	}
+
+	return 0;
+}
+
+static int stmmac_sysfs_ring_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, stmmac_sysfs_ring_read, inode->i_private);
+}
+
+static const struct file_operations stmmac_rings_status_fops = {
+	.owner = THIS_MODULE,
+	.open = stmmac_sysfs_ring_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+
 /* To only dump counters > 0 */
 static inline void seq_printf_mmc(struct seq_file *seq,
 				  const char *description,
@@ -1656,11 +1709,25 @@ static int stmmac_init_fs(struct net_device *dev)
 		return -ENOMEM;
 	}
 
+	/* Entry to report DMA RX/TX rings */
+	stmmac_rings_status = debugfs_create_file("descriptors_status",
+					   S_IRUGO, stmmac_fs_dir, dev,
+					   &stmmac_rings_status_fops);
+
+	if (!stmmac_rings_status || IS_ERR(stmmac_rings_status)) {
+		pr_info("ERROR creating stmmac ring debugfs file\n");
+		debugfs_remove(stmmac_fs_dir);
+
+		return -ENOMEM;
+	}
+
+	/* Entry to report MAC Management counters */
 	stmmac_mmc = debugfs_create_file("mmc", S_IRUGO, stmmac_fs_dir, dev,
 					   &stmmac_mmc_fops);
 
 	if (!stmmac_mmc || IS_ERR(stmmac_mmc)) {
 		pr_info("ERROR creating stmmac MMC debugfs file\n");
+		debugfs_remove(stmmac_rings_status);
 		debugfs_remove(stmmac_fs_dir);
 
 		return -ENOMEM;
@@ -1671,6 +1738,7 @@ static int stmmac_init_fs(struct net_device *dev)
 
 static void stmmac_exit_fs(void)
 {
+	debugfs_remove(stmmac_rings_status);
 	debugfs_remove(stmmac_mmc);
 	debugfs_remove(stmmac_fs_dir);
 }
-- 
1.7.4.4
