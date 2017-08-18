From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 06/14] amd-xgbe: Add support to handle device
 renaming
Date: Thu, 17 Aug 2017 19:02:58 -0500
Message-ID: <20170818000258.10005.86785.stgit@tlendack-t1.amdoffice.net>
References: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0064.outbound.protection.outlook.com ([104.47.37.64]:35392
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753342AbdHRADF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 20:03:05 -0400
In-Reply-To: <20170818000201.10005.36182.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many of the names used by the driver are based upon the name of the device
found during device probe.  Move the formatting of the names into the
device open function so that any renaming that occurs before the device is
brought up will be accounted for.  This also means moving the creation of
some named workqueues into the device open path.

Add support to register for net events so that if a device is renamed
the corresponding debugfs directory can be renamed.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |   25 +++++++++
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |   44 +++++++++++++++-
 drivers/net/ethernet/amd/xgbe/xgbe-main.c    |   72 +++++++++++---------------
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    5 +-
 4 files changed, 100 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
index 7409705..e79a0bd 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
@@ -678,3 +678,28 @@ void xgbe_debugfs_exit(struct xgbe_prv_data *pdata)
 	debugfs_remove_recursive(pdata->xgbe_debugfs);
 	pdata->xgbe_debugfs = NULL;
 }
+
+void xgbe_debugfs_rename(struct xgbe_prv_data *pdata)
+{
+	struct dentry *pfile;
+	char *buf;
+
+	if (!pdata->xgbe_debugfs)
+		return;
+
+	buf = kasprintf(GFP_KERNEL, "amd-xgbe-%s", pdata->netdev->name);
+	if (!buf)
+		return;
+
+	if (!strcmp(pdata->xgbe_debugfs->d_name.name, buf))
+		goto out;
+
+	pfile = debugfs_rename(pdata->xgbe_debugfs->d_parent,
+			       pdata->xgbe_debugfs,
+			       pdata->xgbe_debugfs->d_parent, buf);
+	if (!pfile)
+		netdev_err(pdata->netdev, "debugfs_rename failed\n");
+
+out:
+	kfree(buf);
+}
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 2fd9b80..d6d29d8 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -887,7 +887,7 @@ static int xgbe_request_irqs(struct xgbe_prv_data *pdata)
 		     (unsigned long)pdata);
 
 	ret = devm_request_irq(pdata->dev, pdata->dev_irq, xgbe_isr, 0,
-			       netdev->name, pdata);
+			       netdev_name(netdev), pdata);
 	if (ret) {
 		netdev_alert(netdev, "error requesting irq %d\n",
 			     pdata->dev_irq);
@@ -1589,16 +1589,42 @@ static int xgbe_open(struct net_device *netdev)
 
 	DBGPR("-->xgbe_open\n");
 
+	/* Create the various names based on netdev name */
+	snprintf(pdata->an_name, sizeof(pdata->an_name) - 1, "%s-pcs",
+		 netdev_name(netdev));
+
+	snprintf(pdata->ecc_name, sizeof(pdata->ecc_name) - 1, "%s-ecc",
+		 netdev_name(netdev));
+
+	snprintf(pdata->i2c_name, sizeof(pdata->i2c_name) - 1, "%s-i2c",
+		 netdev_name(netdev));
+
+	/* Create workqueues */
+	pdata->dev_workqueue =
+		create_singlethread_workqueue(netdev_name(netdev));
+	if (!pdata->dev_workqueue) {
+		netdev_err(netdev, "device workqueue creation failed\n");
+		return -ENOMEM;
+	}
+
+	pdata->an_workqueue =
+		create_singlethread_workqueue(pdata->an_name);
+	if (!pdata->an_workqueue) {
+		netdev_err(netdev, "phy workqueue creation failed\n");
+		ret = -ENOMEM;
+		goto err_dev_wq;
+	}
+
 	/* Reset the phy settings */
 	ret = xgbe_phy_reset(pdata);
 	if (ret)
-		return ret;
+		goto err_an_wq;
 
 	/* Enable the clocks */
 	ret = clk_prepare_enable(pdata->sysclk);
 	if (ret) {
 		netdev_alert(netdev, "dma clk_prepare_enable failed\n");
-		return ret;
+		goto err_an_wq;
 	}
 
 	ret = clk_prepare_enable(pdata->ptpclk);
@@ -1651,6 +1677,12 @@ static int xgbe_open(struct net_device *netdev)
 err_sysclk:
 	clk_disable_unprepare(pdata->sysclk);
 
+err_an_wq:
+	destroy_workqueue(pdata->an_workqueue);
+
+err_dev_wq:
+	destroy_workqueue(pdata->dev_workqueue);
+
 	return ret;
 }
 
@@ -1674,6 +1706,12 @@ static int xgbe_close(struct net_device *netdev)
 	clk_disable_unprepare(pdata->ptpclk);
 	clk_disable_unprepare(pdata->sysclk);
 
+	flush_workqueue(pdata->an_workqueue);
+	destroy_workqueue(pdata->an_workqueue);
+
+	flush_workqueue(pdata->dev_workqueue);
+	destroy_workqueue(pdata->dev_workqueue);
+
 	set_bit(XGBE_DOWN, &pdata->dev_state);
 
 	DBGPR("<--xgbe_close\n");
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 53a425c..c5ff385 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -120,6 +120,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/io.h>
+#include <linux/notifier.h>
 
 #include "xgbe.h"
 #include "xgbe-common.h"
@@ -399,35 +400,6 @@ int xgbe_config_netdev(struct xgbe_prv_data *pdata)
 		return ret;
 	}
 
-	/* Create the PHY/ANEG name based on netdev name */
-	snprintf(pdata->an_name, sizeof(pdata->an_name) - 1, "%s-pcs",
-		 netdev_name(netdev));
-
-	/* Create the ECC name based on netdev name */
-	snprintf(pdata->ecc_name, sizeof(pdata->ecc_name) - 1, "%s-ecc",
-		 netdev_name(netdev));
-
-	/* Create the I2C name based on netdev name */
-	snprintf(pdata->i2c_name, sizeof(pdata->i2c_name) - 1, "%s-i2c",
-		 netdev_name(netdev));
-
-	/* Create workqueues */
-	pdata->dev_workqueue =
-		create_singlethread_workqueue(netdev_name(netdev));
-	if (!pdata->dev_workqueue) {
-		netdev_err(netdev, "device workqueue creation failed\n");
-		ret = -ENOMEM;
-		goto err_netdev;
-	}
-
-	pdata->an_workqueue =
-		create_singlethread_workqueue(pdata->an_name);
-	if (!pdata->an_workqueue) {
-		netdev_err(netdev, "phy workqueue creation failed\n");
-		ret = -ENOMEM;
-		goto err_wq;
-	}
-
 	if (IS_REACHABLE(CONFIG_PTP_1588_CLOCK))
 		xgbe_ptp_register(pdata);
 
@@ -439,14 +411,6 @@ int xgbe_config_netdev(struct xgbe_prv_data *pdata)
 		  pdata->rx_ring_count);
 
 	return 0;
-
-err_wq:
-	destroy_workqueue(pdata->dev_workqueue);
-
-err_netdev:
-	unregister_netdev(netdev);
-
-	return ret;
 }
 
 void xgbe_deconfig_netdev(struct xgbe_prv_data *pdata)
@@ -461,18 +425,42 @@ void xgbe_deconfig_netdev(struct xgbe_prv_data *pdata)
 	unregister_netdev(netdev);
 
 	pdata->phy_if.phy_exit(pdata);
+}
 
-	flush_workqueue(pdata->an_workqueue);
-	destroy_workqueue(pdata->an_workqueue);
+static int xgbe_netdev_event(struct notifier_block *nb, unsigned long event,
+			     void *data)
+{
+	struct net_device *netdev = netdev_notifier_info_to_dev(data);
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
 
-	flush_workqueue(pdata->dev_workqueue);
-	destroy_workqueue(pdata->dev_workqueue);
+	if (netdev->netdev_ops != xgbe_get_netdev_ops())
+		goto out;
+
+	switch (event) {
+	case NETDEV_CHANGENAME:
+		xgbe_debugfs_rename(pdata);
+		break;
+
+	default:
+		break;
+	}
+
+out:
+	return NOTIFY_DONE;
 }
 
+static struct notifier_block xgbe_netdev_notifier = {
+	.notifier_call = xgbe_netdev_event,
+};
+
 static int __init xgbe_mod_init(void)
 {
 	int ret;
 
+	ret = register_netdevice_notifier(&xgbe_netdev_notifier);
+	if (ret)
+		return ret;
+
 	ret = xgbe_platform_init();
 	if (ret)
 		return ret;
@@ -489,6 +477,8 @@ static void __exit xgbe_mod_exit(void)
 	xgbe_pci_exit();
 
 	xgbe_platform_exit();
+
+	unregister_netdevice_notifier(&xgbe_netdev_notifier);
 }
 
 module_init(xgbe_mod_init);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 8a3fb9d..4932a44 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -130,6 +130,7 @@
 #include <linux/completion.h>
 #include <linux/cpumask.h>
 #include <linux/interrupt.h>
+#include <linux/dcache.h>
 
 #define XGBE_DRV_NAME		"amd-xgbe"
 #define XGBE_DRV_VERSION	"1.0.3"
@@ -1181,7 +1182,6 @@ struct xgbe_prv_data {
 	struct tasklet_struct tasklet_i2c;
 	struct tasklet_struct tasklet_an;
 
-#ifdef CONFIG_DEBUG_FS
 	struct dentry *xgbe_debugfs;
 
 	unsigned int debugfs_xgmac_reg;
@@ -1195,7 +1195,6 @@ struct xgbe_prv_data {
 
 	unsigned int debugfs_phydev_mmd;
 	unsigned int debugfs_phydev_reg;
-#endif
 };
 
 /* Function prototypes*/
@@ -1244,9 +1243,11 @@ void xgbe_dump_rx_desc(struct xgbe_prv_data *, struct xgbe_ring *,
 #ifdef CONFIG_DEBUG_FS
 void xgbe_debugfs_init(struct xgbe_prv_data *);
 void xgbe_debugfs_exit(struct xgbe_prv_data *);
+void xgbe_debugfs_rename(struct xgbe_prv_data *pdata);
 #else
 static inline void xgbe_debugfs_init(struct xgbe_prv_data *pdata) {}
 static inline void xgbe_debugfs_exit(struct xgbe_prv_data *pdata) {}
+static inline void xgbe_debugfs_rename(struct xgbe_prv_data *pdata) {}
 #endif /* CONFIG_DEBUG_FS */
 
 /* NOTE: Uncomment for function trace log messages in KERNEL LOG */
