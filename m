From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: [PATCH] net: stmmac: create one debugfs dir per net-device
Date: Fri, 22 May 2015 19:03:29 -0700
Message-ID: <1432346609-2961-1-git-send-email-mathieu@codeaurora.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mathieu Olivari <mathieu@codeaurora.org>
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

stmmac DebugFS entries are currently global to the driver. As a result,
having more than one stmmac device in the system creates the following
error:
* ERROR stmmaceth, debugfs create directory failed
* stmmac_hw_setup: failed debugFS registration

This also results in being able to access the debugfs information for
the first registered device only.

This patch changes the debugfs structure to have one sub-directory per
net-device. Files under "/sys/kernel/debug/stmmaceth" will now show-up
under /sys/kernel/debug/stmmaceth/ethN/.

Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |  6 ++
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 76 ++++++++++++++++-------
 2 files changed, 59 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index 9cbcae2..1f3b33a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -125,6 +125,12 @@ struct stmmac_priv {
 	int use_riwt;
 	int irq_wake;
 	spinlock_t ptp_lock;
+
+#ifdef CONFIG_DEBUG_FS
+	struct dentry *dbgfs_dir;
+	struct dentry *dbgfs_rings_status;
+	struct dentry *dbgfs_dma_cap;
+#endif
 };
 
 int stmmac_mdio_unregister(struct net_device *ndev);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index c46178c..a515673 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -119,7 +119,7 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id);
 
 #ifdef CONFIG_DEBUG_FS
 static int stmmac_init_fs(struct net_device *dev);
-static void stmmac_exit_fs(void);
+static void stmmac_exit_fs(struct net_device *dev);
 #endif
 
 #define STMMAC_COAL_TIMER(x) (jiffies + usecs_to_jiffies(x))
@@ -1922,7 +1922,7 @@ static int stmmac_release(struct net_device *dev)
 	netif_carrier_off(dev);
 
 #ifdef CONFIG_DEBUG_FS
-	stmmac_exit_fs();
+	stmmac_exit_fs(dev);
 #endif
 
 	stmmac_release_ptp(priv);
@@ -2514,8 +2514,6 @@ static int stmmac_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 #ifdef CONFIG_DEBUG_FS
 static struct dentry *stmmac_fs_dir;
-static struct dentry *stmmac_rings_status;
-static struct dentry *stmmac_dma_cap;
 
 static void sysfs_display_ring(void *head, int size, int extend_desc,
 			       struct seq_file *seq)
@@ -2654,36 +2652,39 @@ static const struct file_operations stmmac_dma_cap_fops = {
 
 static int stmmac_init_fs(struct net_device *dev)
 {
-	/* Create debugfs entries */
-	stmmac_fs_dir = debugfs_create_dir(STMMAC_RESOURCE_NAME, NULL);
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	/* Create per netdev entries */
+	priv->dbgfs_dir = debugfs_create_dir(dev->name, stmmac_fs_dir);
 
-	if (!stmmac_fs_dir || IS_ERR(stmmac_fs_dir)) {
-		pr_err("ERROR %s, debugfs create directory failed\n",
-		       STMMAC_RESOURCE_NAME);
+	if (!priv->dbgfs_dir || IS_ERR(priv->dbgfs_dir)) {
+		pr_err("ERROR %s/%s, debugfs create directory failed\n",
+		       STMMAC_RESOURCE_NAME, dev->name);
 
 		return -ENOMEM;
 	}
 
 	/* Entry to report DMA RX/TX rings */
-	stmmac_rings_status = debugfs_create_file("descriptors_status",
-						  S_IRUGO, stmmac_fs_dir, dev,
-						  &stmmac_rings_status_fops);
+	priv->dbgfs_rings_status =
+		debugfs_create_file("descriptors_status", S_IRUGO,
+				    priv->dbgfs_dir, dev,
+				    &stmmac_rings_status_fops);
 
-	if (!stmmac_rings_status || IS_ERR(stmmac_rings_status)) {
+	if (!priv->dbgfs_rings_status || IS_ERR(priv->dbgfs_rings_status)) {
 		pr_info("ERROR creating stmmac ring debugfs file\n");
-		debugfs_remove(stmmac_fs_dir);
+		debugfs_remove_recursive(priv->dbgfs_dir);
 
 		return -ENOMEM;
 	}
 
 	/* Entry to report the DMA HW features */
-	stmmac_dma_cap = debugfs_create_file("dma_cap", S_IRUGO, stmmac_fs_dir,
-					     dev, &stmmac_dma_cap_fops);
+	priv->dbgfs_dma_cap = debugfs_create_file("dma_cap", S_IRUGO,
+					    priv->dbgfs_dir,
+					    dev, &stmmac_dma_cap_fops);
 
-	if (!stmmac_dma_cap || IS_ERR(stmmac_dma_cap)) {
+	if (!priv->dbgfs_dma_cap || IS_ERR(priv->dbgfs_dma_cap)) {
 		pr_info("ERROR creating stmmac MMC debugfs file\n");
-		debugfs_remove(stmmac_rings_status);
-		debugfs_remove(stmmac_fs_dir);
+		debugfs_remove_recursive(priv->dbgfs_dir);
 
 		return -ENOMEM;
 	}
@@ -2691,11 +2692,11 @@ static int stmmac_init_fs(struct net_device *dev)
 	return 0;
 }
 
-static void stmmac_exit_fs(void)
+static void stmmac_exit_fs(struct net_device *dev)
 {
-	debugfs_remove(stmmac_rings_status);
-	debugfs_remove(stmmac_dma_cap);
-	debugfs_remove(stmmac_fs_dir);
+	struct stmmac_priv *priv = netdev_priv(dev);
+
+	debugfs_remove_recursive(priv->dbgfs_dir);
 }
 #endif /* CONFIG_DEBUG_FS */
 
@@ -3163,6 +3164,35 @@ err:
 __setup("stmmaceth=", stmmac_cmdline_opt);
 #endif /* MODULE */
 
+static int __init stmmac_init(void)
+{
+#ifdef CONFIG_DEBUG_FS
+	/* Create debugfs main directory if it doesn't exist yet */
+	if (!stmmac_fs_dir) {
+		stmmac_fs_dir = debugfs_create_dir(STMMAC_RESOURCE_NAME, NULL);
+
+		if (!stmmac_fs_dir || IS_ERR(stmmac_fs_dir)) {
+			pr_err("ERROR %s, debugfs create directory failed\n",
+			       STMMAC_RESOURCE_NAME);
+
+			return -ENOMEM;
+		}
+	}
+#endif
+
+	return 0;
+}
+
+static void __exit stmmac_exit(void)
+{
+#ifdef CONFIG_DEBUG_FS
+	debugfs_remove_recursive(stmmac_fs_dir);
+#endif
+}
+
+module_init(stmmac_init)
+module_exit(stmmac_exit)
+
 MODULE_DESCRIPTION("STMMAC 10/100/1000 Ethernet device driver");
 MODULE_AUTHOR("Giuseppe Cavallaro <peppe.cavallaro@st.com>");
 MODULE_LICENSE("GPL");
-- 
2.1.4
