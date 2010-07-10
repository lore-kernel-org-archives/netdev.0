From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net/mlx4: Use %pV, pr_<level>, printk_once
Date: Sat, 10 Jul 2010 10:22:46 -0700
Message-ID: <baf5f3949ffd5a48a6f5667b6d6394e6d48c91ca.1278696312.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Roland Dreier <rolandd@cisco.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove near duplication of format string constants by using the newly
introduced vsprintf extention %pV to reduce text by 20k or so.

$ size drivers/net/mlx4/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 161367	   1866	  48784	 212017	  33c31	drivers/net/mlx4/built-in.o
 142621	   1866	  46248	 190735	  2e90f	drivers/net/mlx4/built-in.o.new

Use printk_once as appropriate.
Convert printks to pr_<level>, some bare printks now use pr_cont.
Remove now unused #define PFX.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/mlx4/catas.c   |    4 +-
 drivers/net/mlx4/en_main.c |   29 +++++++++++++++++---
 drivers/net/mlx4/eq.c      |    6 ++--
 drivers/net/mlx4/main.c    |   16 +++--------
 drivers/net/mlx4/mlx4.h    |   15 +++++-----
 drivers/net/mlx4/mlx4_en.h |   62 +++++++++++++++++++++----------------------
 6 files changed, 71 insertions(+), 61 deletions(-)

diff --git a/drivers/net/mlx4/catas.c b/drivers/net/mlx4/catas.c
index f599294..68aaa42 100644
--- a/drivers/net/mlx4/catas.c
+++ b/drivers/net/mlx4/catas.c
@@ -101,8 +101,8 @@ static void catas_reset(struct work_struct *work)
 		ret = mlx4_restart_one(priv->dev.pdev);
 		/* 'priv' now is not valid */
 		if (ret)
-			printk(KERN_ERR "mlx4 %s: Reset failed (%d)\n",
-				pci_name(pdev), ret);
+			pr_err("mlx4 %s: Reset failed (%d)\n",
+			       pci_name(pdev), ret);
 		else {
 			dev  = pci_get_drvdata(pdev);
 			mlx4_dbg(dev, "Reset succeeded\n");
diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/mlx4/en_main.c
index cbabf14..97934f1 100644
--- a/drivers/net/mlx4/en_main.c
+++ b/drivers/net/mlx4/en_main.c
@@ -79,6 +79,29 @@ MLX4_EN_PARM_INT(pfctx, 0, "Priority based Flow Control policy on TX[7:0]."
 MLX4_EN_PARM_INT(pfcrx, 0, "Priority based Flow Control policy on RX[7:0]."
 			   " Per priority bit mask");
 
+int en_print(const char *level, const struct mlx4_en_priv *priv,
+	     const char *format, ...)
+{
+	va_list args;
+	struct va_format vaf;
+	int i;
+
+	va_start(args, format);
+
+	vaf.fmt = format;
+	vaf.va = &args;
+	if (priv->registered)
+		i = printk("%s%s: %s: %pV",
+			   level, DRV_NAME, priv->dev->name, &vaf);
+	else
+		i = printk("%s%s: %s: Port %d: %pV",
+			   level, DRV_NAME, dev_name(&priv->mdev->pdev->dev),
+			   priv->port, &vaf);
+	va_end(args);
+
+	return i;
+}
+
 static int mlx4_en_get_profile(struct mlx4_en_dev *mdev)
 {
 	struct mlx4_en_profile *params = &mdev->profile;
@@ -152,15 +175,11 @@ static void mlx4_en_remove(struct mlx4_dev *dev, void *endev_ptr)
 
 static void *mlx4_en_add(struct mlx4_dev *dev)
 {
-	static int mlx4_en_version_printed;
 	struct mlx4_en_dev *mdev;
 	int i;
 	int err;
 
-	if (!mlx4_en_version_printed) {
-		printk(KERN_INFO "%s", mlx4_en_version);
-		mlx4_en_version_printed++;
-	}
+	printk_once(KERN_INFO "%s", mlx4_en_version);
 
 	mdev = kzalloc(sizeof *mdev, GFP_KERNEL);
 	if (!mdev) {
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index 22d0b3b..6d7b2bf 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -475,10 +475,10 @@ static void mlx4_free_eq(struct mlx4_dev *dev,
 		mlx4_dbg(dev, "Dumping EQ context %02x:\n", eq->eqn);
 		for (i = 0; i < sizeof (struct mlx4_eq_context) / 4; ++i) {
 			if (i % 4 == 0)
-				printk("[%02x] ", i * 4);
-			printk(" %08x", be32_to_cpup(mailbox->buf + i * 4));
+				pr_cont("[%02x] ", i * 4);
+			pr_cont(" %08x", be32_to_cpup(mailbox->buf + i * 4));
 			if ((i + 1) % 4 == 0)
-				printk("\n");
+				pr_cont("\n");
 		}
 	}
 
diff --git a/drivers/net/mlx4/main.c b/drivers/net/mlx4/main.c
index e3e0d54..5102ab1 100644
--- a/drivers/net/mlx4/main.c
+++ b/drivers/net/mlx4/main.c
@@ -1050,8 +1050,7 @@ static int __mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
 	int err;
 	int port;
 
-	printk(KERN_INFO PFX "Initializing %s\n",
-	       pci_name(pdev));
+	pr_info(DRV_NAME ": Initializing %s\n", pci_name(pdev));
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -1216,12 +1215,7 @@ err_disable_pdev:
 static int __devinit mlx4_init_one(struct pci_dev *pdev,
 				   const struct pci_device_id *id)
 {
-	static int mlx4_version_printed;
-
-	if (!mlx4_version_printed) {
-		printk(KERN_INFO "%s", mlx4_version);
-		++mlx4_version_printed;
-	}
+	printk_once(KERN_INFO "%s", mlx4_version);
 
 	return __mlx4_init_one(pdev, id);
 }
@@ -1301,17 +1295,17 @@ static struct pci_driver mlx4_driver = {
 static int __init mlx4_verify_params(void)
 {
 	if ((log_num_mac < 0) || (log_num_mac > 7)) {
-		printk(KERN_WARNING "mlx4_core: bad num_mac: %d\n", log_num_mac);
+		pr_warning("mlx4_core: bad num_mac: %d\n", log_num_mac);
 		return -1;
 	}
 
 	if ((log_num_vlan < 0) || (log_num_vlan > 7)) {
-		printk(KERN_WARNING "mlx4_core: bad num_vlan: %d\n", log_num_vlan);
+		pr_warning("mlx4_core: bad num_vlan: %d\n", log_num_vlan);
 		return -1;
 	}
 
 	if ((log_mtts_per_seg < 1) || (log_mtts_per_seg > 5)) {
-		printk(KERN_WARNING "mlx4_core: bad log_mtts_per_seg: %d\n", log_mtts_per_seg);
+		pr_warning("mlx4_core: bad log_mtts_per_seg: %d\n", log_mtts_per_seg);
 		return -1;
 	}
 
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/mlx4/mlx4.h
index 13343e8..0da5bb7 100644
--- a/drivers/net/mlx4/mlx4.h
+++ b/drivers/net/mlx4/mlx4.h
@@ -48,7 +48,6 @@
 #include <linux/mlx4/doorbell.h>
 
 #define DRV_NAME	"mlx4_core"
-#define PFX		DRV_NAME ": "
 #define DRV_VERSION	"0.01"
 #define DRV_RELDATE	"May 1, 2007"
 
@@ -88,17 +87,17 @@ extern int mlx4_debug_level;
 #endif /* CONFIG_MLX4_DEBUG */
 
 #define mlx4_dbg(mdev, format, arg...)					\
-	do {								\
-		if (mlx4_debug_level)					\
-			dev_printk(KERN_DEBUG, &mdev->pdev->dev, format, ## arg); \
-	} while (0)
+do {									\
+	if (mlx4_debug_level)						\
+		dev_printk(KERN_DEBUG, &mdev->pdev->dev, format, ##arg); \
+} while (0)
 
 #define mlx4_err(mdev, format, arg...) \
-	dev_err(&mdev->pdev->dev, format, ## arg)
+	dev_err(&mdev->pdev->dev, format, ##arg)
 #define mlx4_info(mdev, format, arg...) \
-	dev_info(&mdev->pdev->dev, format, ## arg)
+	dev_info(&mdev->pdev->dev, format, ##arg)
 #define mlx4_warn(mdev, format, arg...) \
-	dev_warn(&mdev->pdev->dev, format, ## arg)
+	dev_warn(&mdev->pdev->dev, format, ##arg)
 
 struct mlx4_bitmap {
 	u32			last;
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index b55e46c..4492109 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -52,40 +52,8 @@
 #define DRV_VERSION	"1.4.1.1"
 #define DRV_RELDATE	"June 2009"
 
-
 #define MLX4_EN_MSG_LEVEL	(NETIF_MSG_LINK | NETIF_MSG_IFDOWN)
 
-#define en_print(level, priv, format, arg...)			\
-	{							\
-	if ((priv)->registered)					\
-		printk(level "%s: %s: " format, DRV_NAME,	\
-			(priv->dev)->name, ## arg);		\
-	else							\
-		printk(level "%s: %s: Port %d: " format,	\
-			DRV_NAME, dev_name(&priv->mdev->pdev->dev), \
-			(priv)->port, ## arg);			\
-	}
-
-#define en_dbg(mlevel, priv, format, arg...)			\
-	{							\
-	if (NETIF_MSG_##mlevel & priv->msg_enable)		\
-		en_print(KERN_DEBUG, priv, format, ## arg)	\
-	}
-#define en_warn(priv, format, arg...)				\
-	en_print(KERN_WARNING, priv, format, ## arg)
-#define en_err(priv, format, arg...)				\
-	en_print(KERN_ERR, priv, format, ## arg)
-
-#define mlx4_err(mdev, format, arg...) \
-	printk(KERN_ERR "%s %s: " format , DRV_NAME ,\
-		dev_name(&mdev->pdev->dev) , ## arg)
-#define mlx4_info(mdev, format, arg...) \
-	printk(KERN_INFO "%s %s: " format , DRV_NAME ,\
-		dev_name(&mdev->pdev->dev) , ## arg)
-#define mlx4_warn(mdev, format, arg...) \
-	printk(KERN_WARNING "%s %s: " format , DRV_NAME ,\
-		dev_name(&mdev->pdev->dev) , ## arg)
-
 /*
  * Device constants
  */
@@ -568,4 +536,34 @@ int mlx4_en_DUMP_ETH_STATS(struct mlx4_en_dev *mdev, u8 port, u8 reset);
  * Globals
  */
 extern const struct ethtool_ops mlx4_en_ethtool_ops;
+
+
+
+/*
+ * printk / logging functions
+ */
+
+int en_print(const char *level, const struct mlx4_en_priv *priv,
+	     const char *format, ...) __attribute__ ((format (printf, 3, 4)));
+
+#define en_dbg(mlevel, priv, format, arg...)			\
+do {								\
+	if (NETIF_MSG_##mlevel & priv->msg_enable)		\
+		en_print(KERN_DEBUG, priv, format, ##arg);	\
+} while (0)
+#define en_warn(priv, format, arg...)			\
+	en_print(KERN_WARNING, priv, format, ##arg)
+#define en_err(priv, format, arg...)			\
+	en_print(KERN_ERR, priv, format, ##arg)
+
+#define mlx4_err(mdev, format, arg...)			\
+	pr_err("%s %s: " format, DRV_NAME,		\
+	       dev_name(&mdev->pdev->dev), ##arg)
+#define mlx4_info(mdev, format, arg...)			\
+	pr_info("%s %s: " format, DRV_NAME,		\
+		dev_name(&mdev->pdev->dev), ##arg)
+#define mlx4_warn(mdev, format, arg...)			\
+	pr_warning("%s %s: " format, DRV_NAME,		\
+		   dev_name(&mdev->pdev->dev), ##arg)
+
 #endif
-- 
1.7.1.337.g6068.dirty
