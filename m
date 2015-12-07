From: Phil Reid <preid@electromag.com.au>
Subject: [PATCH v2 4/5] stmmac: Add ptp debugfs entry.
Date: Mon,  7 Dec 2015 09:38:43 +0800
Message-ID: <1449452324-53858-6-git-send-email-preid@electromag.com.au>
References: <1449452324-53858-1-git-send-email-preid@electromag.com.au>
Cc: Phil Reid <preid@electromag.com.au>
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	peppe.cavallaro@st.com, davem@davemloft.net,
	devicetree@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 203-59-230-133.perm.iinet.net.au ([203.59.230.133]:49196 "EHLO
	preid-centos7.electromag.com.au" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755086AbbLGBjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 20:39:17 -0500
In-Reply-To: <1449452324-53858-1-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a debugfs entry to view the current status of the ptp
registers.

Signed-off-by: Phil Reid <preid@electromag.com.au>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 61 +++++++++++++++++++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h  |  5 ++
 3 files changed, 67 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 1f3b33a..d0ac1b1 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -130,6 +130,7 @@ struct stmmac_priv {
 	struct dentry *dbgfs_dir;
 	struct dentry *dbgfs_rings_status;
 	struct dentry *dbgfs_dma_cap;
+	struct dentry *dbgfs_ptp;
 #endif
 };
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index ab8d916..f75b2f9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2657,6 +2657,57 @@ static const struct file_operations stmmac_dma_cap_fops = {
 	.release = single_release,
 };
 
+static int stmmac_sysfs_ptp_read(struct seq_file *seq, void *v)
+{
+	struct net_device *dev = seq->private;
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	if (!(priv->dma_cap.time_stamp || priv->adv_ts)) {
+		seq_printf(seq, "PTP HW features not supported\n");
+		return 0;
+	}
+
+	seq_printf(seq, "==============================\n");
+	seq_printf(seq, "\tPTP Status\n");
+	seq_printf(seq, "==============================\n");
+	
+	#define DUMP_REG(x) seq_printf(seq, "%-20s       %04x  %08x\n", #x, x, readl(priv->ioaddr + x));
+	DUMP_REG(GMAC_INT_STATUS);
+	DUMP_REG(GMAC_INT_MASK);
+
+	DUMP_REG(PTP_TCR);
+	DUMP_REG(PTP_SSIR);
+	DUMP_REG(PTP_STSR);
+	DUMP_REG(PTP_STNSR);
+	DUMP_REG(PTP_STSUR);
+	DUMP_REG(PTP_STNSUR);
+	DUMP_REG(PTP_TAR);
+	DUMP_REG(PTP_TTSR);
+	DUMP_REG(PTP_TTNSR);
+	DUMP_REG(PTP_STHWSR);
+	DUMP_REG(PTP_TSR);
+	DUMP_REG(PTP_PPSCTLR);
+	DUMP_REG(PTP_AUXTSTNSR);
+	DUMP_REG(PTP_AUXTSTSR);
+	DUMP_REG(PTP_PPS0INTRR);
+	DUMP_REG(PTP_PPS0WDTHR);
+
+	return 0;
+}
+
+static int stmmac_sysfs_ptp_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, stmmac_sysfs_ptp_read, inode->i_private);
+}
+
+static const struct file_operations stmmac_ptp_fops = {
+	.owner = THIS_MODULE,
+	.open = stmmac_sysfs_ptp_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = single_release,
+};
+
 static int stmmac_init_fs(struct net_device *dev)
 {
 	struct stmmac_priv *priv = netdev_priv(dev);
@@ -2692,6 +2743,16 @@ static int stmmac_init_fs(struct net_device *dev)
 	if (!priv->dbgfs_dma_cap || IS_ERR(priv->dbgfs_dma_cap)) {
 		pr_info("ERROR creating stmmac MMC debugfs file\n");
 		debugfs_remove_recursive(priv->dbgfs_dir);
+	}
+
+	/* Entry to report the PTP status */
+	priv->dbgfs_ptp = debugfs_create_file("ptp", S_IRUGO,
+					    priv->dbgfs_dir,
+					    dev, &stmmac_ptp_fops);
+
+	if (!priv->dbgfs_ptp || IS_ERR(priv->dbgfs_ptp)) {
+		pr_info("ERROR creating stmmac PTP debugfs file\n");
+		debugfs_remove_recursive(priv->dbgfs_dir);
 
 		return -ENOMEM;
 	}
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
index 4535df3..b00b005 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ptp.h
@@ -37,6 +37,11 @@
 #define PTP_TTNSR	0x0720	/* Target Time Nanoseconds Reg */
 #define	PTP_STHWSR	0x0724	/* System Time - Higher Word Seconds Reg */
 #define PTP_TSR		0x0728	/* Timestamp Status */
+#define PTP_PPSCTLR	0x072C	/* PPS Control Reg */
+#define PTP_AUXTSTNSR	0x0730	/* Aux Timestamp - Nanoseconds Reg */
+#define PTP_AUXTSTSR	0x0734	/* Aux Timestamp - Seconds Reg */
+#define PTP_PPS0INTRR	0x0760	/* PPS0 Interval Reg */
+#define PTP_PPS0WDTHR	0x0764	/* PPS0 Width Reg */
 
 #define PTP_STNSUR_ADDSUB_SHIFT 31
 
-- 
1.8.3.1
