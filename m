From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
	<niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCH 2/2] ravb: add sleep PM suspend/resume support
Date: Wed,  3 Aug 2016 15:56:47 +0200
Message-ID: <20160803135647.23242-3-niklas.soderlund+renesas@ragnatech.se>
References: <20160803135647.23242-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, wsa@the-dreams.de,
	=?UTF-8?q?Niklas=20S=C3=B6derlund?=
	<niklas.soderlund+renesas@ragnatech.se>
To: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-4.sys.kth.se ([130.237.48.193]:59974 "EHLO
	smtp-4.sys.kth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754482AbcHCOKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2016 10:10:13 -0400
In-Reply-To: <20160803135647.23242-1-niklas.soderlund+renesas@ragnatech.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interface would not function after the system had been woken up
after have been suspended (echo mem > /sys/power/state) cycle. The
reason for this is that all device registers have been reset to its
default values. This patch adds sleep suspend and resume functions that
detached the interface at suspend and restore the registers and reattach
the interface at resume.

Only the registers that are only configured at probe time needs to be
explicitly restored by the resume handler. All other registers are
reconfigured by either reopening the device in the resume handler (if
the device was running when the system was suspended) or when the
interface is opened by a user at a later time.

Signed-off-by: Niklas Söderlund <niklas.soderlund+renesas@ragnatech.se>
---
 drivers/net/ethernet/renesas/ravb_main.c | 72 ++++++++++++++++++++++++++++----
 1 file changed, 64 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index da8da86..1de55c9 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -1876,6 +1876,20 @@ static int ravb_set_gti(struct net_device *ndev)
 	return 0;
 }
 
+static void ravb_set_config_mode(struct net_device *ndev)
+{
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	if (priv->chip_id == RCAR_GEN2) {
+		ravb_modify(ndev, CCC, CCC_OPC, CCC_OPC_CONFIG);
+		/* Set CSEL value */
+		ravb_modify(ndev, CCC, CCC_CSEL, CCC_CSEL_HPB);
+	} else {
+		ravb_modify(ndev, CCC, CCC_OPC, CCC_OPC_CONFIG |
+			    CCC_GAC | CCC_CSEL_HPB);
+	}
+}
+
 static int ravb_probe(struct platform_device *pdev)
 {
 	struct device_node *np = pdev->dev.of_node;
@@ -1979,14 +1993,7 @@ static int ravb_probe(struct platform_device *pdev)
 	ndev->ethtool_ops = &ravb_ethtool_ops;
 
 	/* Set AVB config mode */
-	if (chip_id == RCAR_GEN2) {
-		ravb_modify(ndev, CCC, CCC_OPC, CCC_OPC_CONFIG);
-		/* Set CSEL value */
-		ravb_modify(ndev, CCC, CCC_CSEL, CCC_CSEL_HPB);
-	} else {
-		ravb_modify(ndev, CCC, CCC_OPC, CCC_OPC_CONFIG |
-			    CCC_GAC | CCC_CSEL_HPB);
-	}
+	ravb_set_config_mode(ndev);
 
 	/* Set GTI value */
 	error = ravb_set_gti(ndev);
@@ -2098,6 +2105,54 @@ static int ravb_remove(struct platform_device *pdev)
 }
 
 #ifdef CONFIG_PM
+static int ravb_runtime_suspend(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+	int ret = 0;
+
+	if (netif_running(ndev)) {
+		netif_device_detach(ndev);
+		ret = ravb_close(ndev);
+	}
+
+	return ret;
+}
+
+static int ravb_runtime_resume(struct device *dev)
+{
+	struct net_device *ndev = dev_get_drvdata(dev);
+	struct ravb_private *priv = netdev_priv(ndev);
+	int ret = 0;
+
+	/* All register have been reset to default values.
+	 * Restore all registers which where setup at probe time and
+	 * reopen device if it was running before system suspended.
+	 */
+
+	/* Set AVB config mode */
+	ravb_set_config_mode(ndev);
+
+	/* Set GTI value */
+	ret = ravb_set_gti(ndev);
+	if (ret)
+		return ret;
+
+	/* Request GTI loading */
+	ravb_modify(ndev, GCCR, GCCR_LTI, GCCR_LTI);
+
+	/* Restore descriptor base address table */
+	ravb_write(ndev, priv->desc_bat_dma, DBAT);
+
+	if (netif_running(ndev)) {
+		ret = ravb_open(ndev);
+		if (ret < 0)
+			return ret;
+		netif_device_attach(ndev);
+	}
+
+	return ret;
+}
+
 static int ravb_runtime_nop(struct device *dev)
 {
 	/* Runtime PM callback shared between ->runtime_suspend()
@@ -2111,6 +2166,7 @@ static int ravb_runtime_nop(struct device *dev)
 }
 
 static const struct dev_pm_ops ravb_dev_pm_ops = {
+	SET_SYSTEM_SLEEP_PM_OPS(ravb_runtime_suspend, ravb_runtime_resume)
 	SET_RUNTIME_PM_OPS(ravb_runtime_nop, ravb_runtime_nop, NULL)
 };
 
-- 
2.9.0
