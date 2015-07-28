From: Murali Karicheri <m-karicheri2@ti.com>
Subject: [PATCH 3/3] net: netcp: ethss: cleanup gbe_probe() and gbe_remove() functions
Date: Tue, 28 Jul 2015 18:20:14 -0400
Message-ID: <1438122014-24744-4-git-send-email-m-karicheri2@ti.com>
References: <1438122014-24744-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<w-kwok2@ti.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1438122014-24744-1-git-send-email-m-karicheri2@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch clean up error handle code to use goto label properly. In some
cases, the code unnecessarily use goto instead of just returning the error
code.  Code also make explicit calls to devm_* APIs on error which is
not necessary. In the gbe_remove() also it makes similar calls which is
also unnecessary.

Also fix few checkpatch warnings

Signed-off-by: Murali Karicheri <m-karicheri2@ti.com>
---
 drivers/net/ethernet/ti/netcp_core.c  |  1 -
 drivers/net/ethernet/ti/netcp_ethss.c | 44 ++++++++++++++---------------------
 2 files changed, 17 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/ti/netcp_core.c b/drivers/net/ethernet/ti/netcp_core.c
index a1c6961..9749dfd 100644
--- a/drivers/net/ethernet/ti/netcp_core.c
+++ b/drivers/net/ethernet/ti/netcp_core.c
@@ -2135,7 +2135,6 @@ static int netcp_remove(struct platform_device *pdev)
 	WARN(!list_empty(&netcp_device->interface_head),
 	     "%s interface list not empty!\n", pdev->name);
 
-	devm_kfree(&pdev->dev, netcp_device);
 	pm_runtime_put_sync(&pdev->dev);
 	pm_runtime_disable(&pdev->dev);
 	platform_set_drvdata(pdev, NULL);
diff --git a/drivers/net/ethernet/ti/netcp_ethss.c b/drivers/net/ethernet/ti/netcp_ethss.c
index 77bcfca..f846c0f 100644
--- a/drivers/net/ethernet/ti/netcp_ethss.c
+++ b/drivers/net/ethernet/ti/netcp_ethss.c
@@ -2838,14 +2838,13 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 				      &gbe_dev->dma_chan_name);
 	if (ret < 0) {
 		dev_err(dev, "missing \"tx-channel\" parameter\n");
-		ret = -ENODEV;
-		goto quit;
+		return -EINVAL;
 	}
 
 	if (!strcmp(node->name, "gbe")) {
 		ret = get_gbe_resource_version(gbe_dev, node);
 		if (ret)
-			goto quit;
+			return ret;
 
 		dev_dbg(dev, "ss_version: 0x%08x\n", gbe_dev->ss_version);
 
@@ -2856,22 +2855,20 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 		else
 			ret = -ENODEV;
 
-		if (ret)
-			goto quit;
 	} else if (!strcmp(node->name, "xgbe")) {
 		ret = set_xgbe_ethss10_priv(gbe_dev, node);
 		if (ret)
-			goto quit;
+			return ret;
 		ret = netcp_xgbe_serdes_init(gbe_dev->xgbe_serdes_regs,
 					     gbe_dev->ss_regs);
-		if (ret)
-			goto quit;
 	} else {
 		dev_err(dev, "unknown GBE node(%s)\n", node->name);
 		ret = -ENODEV;
-		goto quit;
 	}
 
+	if (ret)
+		return ret;
+
 	interfaces = of_get_child_by_name(node, "interfaces");
 	if (!interfaces)
 		dev_err(dev, "could not find interfaces\n");
@@ -2879,11 +2876,11 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 	ret = netcp_txpipe_init(&gbe_dev->tx_pipe, netcp_device,
 				gbe_dev->dma_chan_name, gbe_dev->tx_queue_id);
 	if (ret)
-		goto quit;
+		return ret;
 
 	ret = netcp_txpipe_open(&gbe_dev->tx_pipe);
 	if (ret)
-		goto quit;
+		return ret;
 
 	/* Create network interfaces */
 	INIT_LIST_HEAD(&gbe_dev->gbe_intf_head);
@@ -2898,6 +2895,7 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 		if (gbe_dev->num_slaves >= gbe_dev->max_num_slaves)
 			break;
 	}
+	of_node_put(interfaces);
 
 	if (!gbe_dev->num_slaves)
 		dev_warn(dev, "No network interface configured\n");
@@ -2910,9 +2908,10 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 	of_node_put(secondary_ports);
 
 	if (!gbe_dev->num_slaves) {
-		dev_err(dev, "No network interface or secondary ports configured\n");
+		dev_err(dev,
+			"No network interface or secondary ports configured\n");
 		ret = -ENODEV;
-		goto quit;
+		goto free_sec_ports;
 	}
 
 	memset(&ale_params, 0, sizeof(ale_params));
@@ -2926,7 +2925,7 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 	if (!gbe_dev->ale) {
 		dev_err(gbe_dev->dev, "error initializing ale engine\n");
 		ret = -ENODEV;
-		goto quit;
+		goto free_sec_ports;
 	} else {
 		dev_dbg(gbe_dev->dev, "Created a gbe ale engine\n");
 	}
@@ -2942,14 +2941,8 @@ static int gbe_probe(struct netcp_device *netcp_device, struct device *dev,
 	*inst_priv = gbe_dev;
 	return 0;
 
-quit:
-	if (gbe_dev->hw_stats)
-		devm_kfree(dev, gbe_dev->hw_stats);
-	cpsw_ale_destroy(gbe_dev->ale);
-	if (gbe_dev->ss_regs)
-		devm_iounmap(dev, gbe_dev->ss_regs);
-	of_node_put(interfaces);
-	devm_kfree(dev, gbe_dev);
+free_sec_ports:
+	free_secondary_ports(gbe_dev);
 	return ret;
 }
 
@@ -3022,12 +3015,9 @@ static int gbe_remove(struct netcp_device *netcp_device, void *inst_priv)
 	free_secondary_ports(gbe_dev);
 
 	if (!list_empty(&gbe_dev->gbe_intf_head))
-		dev_alert(gbe_dev->dev, "unreleased ethss interfaces present\n");
+		dev_alert(gbe_dev->dev,
+			  "unreleased ethss interfaces present\n");
 
-	devm_kfree(gbe_dev->dev, gbe_dev->hw_stats);
-	devm_iounmap(gbe_dev->dev, gbe_dev->ss_regs);
-	memset(gbe_dev, 0x00, sizeof(*gbe_dev));
-	devm_kfree(gbe_dev->dev, gbe_dev);
 	return 0;
 }
 
-- 
1.9.1
