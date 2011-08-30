From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 5/9] stmmac: export DMA TX/RX rings via debugfs (v2)
Date: Tue, 30 Aug 2011 16:21:00 +0200
Message-ID: <1314714064-29101-6-git-send-email-peppe.cavallaro@st.com>
References: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog115.obsmtp.com ([207.126.144.139]:38398 "EHLO
	eu1sys200aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754394Ab1H3OVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 10:21:40 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id C103AD0
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:38 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 86BB02261
	for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 14:21:38 +0000 (GMT)
In-Reply-To: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
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

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/Kconfig       |    7 +++
 drivers/net/stmmac/stmmac_main.c |  105 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 112 insertions(+), 0 deletions(-)

diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
index 7df7df4..c253012 100644
--- a/drivers/net/stmmac/Kconfig
+++ b/drivers/net/stmmac/Kconfig
@@ -11,6 +11,13 @@ config STMMAC_ETH
 
 if STMMAC_ETH
 
+config STMMAC_DEBUG_FS
+	bool "Enable monitoring via sysFS "
+	default n
+	depends on STMMAC_ETH && DEBUG_FS
+	-- help
+	  The stmmac entry in /sys reports DMA TX/RX rings.
+
 config STMMAC_DA
 	bool "STMMAC DMA arbitration scheme"
 	default n
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 88b2973..1319b4c 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -47,6 +47,10 @@
 #include <linux/slab.h>
 #include <linux/prefetch.h>
 #include "stmmac.h"
+#ifdef CONFIG_STMMAC_DEBUG_FS
+#include <linux/debugfs.h>
+#include <linux/seq_file.h>
+#endif
 
 #define STMMAC_RESOURCE_NAME	"stmmaceth"
 
@@ -1424,6 +1428,96 @@ static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	return ret;
 }
 
+#ifdef CONFIG_STMMAC_DEBUG_FS
+static struct dentry *stmmac_fs_dir;
+static struct dentry *stmmac_rings_status;
+
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
+static int stmmac_init_fs(struct net_device *dev)
+{
+	/* Create debugfs entries */
+	stmmac_fs_dir = debugfs_create_dir(STMMAC_RESOURCE_NAME, NULL);
+
+	if (!stmmac_fs_dir || IS_ERR(stmmac_fs_dir)) {
+		pr_err("ERROR %s, debugfs create directory failed\n",
+		       STMMAC_RESOURCE_NAME);
+
+		return -ENOMEM;
+	}
+
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
+	return 0;
+}
+
+static void stmmac_exit_fs(void)
+{
+	debugfs_remove(stmmac_rings_status);
+	debugfs_remove(stmmac_fs_dir);
+}
+#endif /* CONFIG_STMMAC_DEBUG_FS */
+
 static const struct net_device_ops stmmac_netdev_ops = {
 	.ndo_open = stmmac_open,
 	.ndo_start_xmit = stmmac_xmit,
@@ -1648,6 +1742,13 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	if (ret < 0)
 		goto out_unregister;
 	pr_debug("registered!\n");
+
+#ifdef CONFIG_STMMAC_DEBUG_FS
+	ret = stmmac_init_fs(ndev);
+	if (ret < 0)
+		pr_warning("\tFailed debugFS registration");
+#endif
+
 	return 0;
 
 out_unregister:
@@ -1700,6 +1801,10 @@ static int stmmac_dvr_remove(struct platform_device *pdev)
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	release_mem_region(res->start, resource_size(res));
 
+#ifdef CONFIG_STMMAC_DEBUG_FS
+	stmmac_exit_fs();
+#endif
+
 	free_netdev(ndev);
 
 	return 0;
-- 
1.7.4.4
