From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 2/4] stmmac: add init/exit callback in plat_stmmacenet_data
 struct
Date: Wed, 24 Nov 2010 13:38:05 +0100
Message-ID: <1290561646-9429-2-git-send-email-peppe.cavallaro@st.com>
References: <1290561646-9429-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Peppe CAVALLARO <peppe.cavallaro@st.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:54757 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754154Ab0KXMi2 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 07:38:28 -0500
Received: from zeta.dmz-us.st.com (ns4.st.com [167.4.80.115])
	by beta.dmz-us.st.com (STMicroelectronics) with ESMTP id 557EB159
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 12:38:24 +0000 (GMT)
Received: from Webmail-eu.st.com (safex1hubcas1.st.com [10.75.90.14])
	by zeta.dmz-us.st.com (STMicroelectronics) with ESMTP id B93F014B
	for <netdev@vger.kernel.org>; Wed, 24 Nov 2010 12:38:23 +0000 (GMT)
In-Reply-To: <1290561646-9429-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds in the plat_stmmacenet_data
the init and exit callbacks that can be used
for invoking specific platform functions.
For example, on ST targets, these call the
PAD manager functions to set PIO lines and
syscfg registers.
The patch removes the stmmac_claim_resource
only used on STM Kernels as well.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h      |   22 ----------------------
 drivers/net/stmmac/stmmac_main.c |   18 +++++++++++++-----
 include/linux/stmmac.h           |    6 +++---
 3 files changed, 16 insertions(+), 30 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 3157567..8ae7650 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -87,28 +87,6 @@ struct stmmac_priv {
 	struct plat_stmmacenet_data *plat;
 };
 
-#ifdef CONFIG_STM_DRIVERS
-#include <linux/stm/pad.h>
-static inline int stmmac_claim_resource(struct platform_device *pdev)
-{
-	int ret = 0;
-	struct plat_stmmacenet_data *plat_dat = pdev->dev.platform_data;
-
-	/* Pad routing setup */
-	if (IS_ERR(devm_stm_pad_claim(&pdev->dev, plat_dat->pad_config,
-			dev_name(&pdev->dev)))) {
-		printk(KERN_ERR "%s: Failed to request pads!\n", __func__);
-		ret = -ENODEV;
-	}
-	return ret;
-}
-#else
-static inline int stmmac_claim_resource(struct platform_device *pdev)
-{
-	return 0;
-}
-#endif
-
 extern int stmmac_mdio_unregister(struct net_device *ndev);
 extern int stmmac_mdio_register(struct net_device *ndev);
 extern void stmmac_set_ethtool_ops(struct net_device *netdev);
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 29ba286..b806cd3 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1643,7 +1643,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	struct resource *res;
 	void __iomem *addr = NULL;
 	struct net_device *ndev = NULL;
-	struct stmmac_priv *priv;
+	struct stmmac_priv *priv = NULL;
 	struct plat_stmmacenet_data *plat_dat;
 
 	pr_info("STMMAC driver:\n\tplatform registration... ");
@@ -1708,10 +1708,12 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	/* Set the I/O base addr */
 	ndev->base_addr = (unsigned long)addr;
 
-	/* Verify embedded resource for the platform */
-	ret = stmmac_claim_resource(pdev);
-	if (ret < 0)
-		goto out;
+	/* Custom initialisation */
+	if (priv->plat->init) {
+		ret = priv->plat->init(pdev);
+		if (unlikely(ret))
+			goto out;
+	}
 
 	/* MAC HW revice detection */
 	ret = stmmac_mac_device_setup(ndev);
@@ -1745,6 +1747,9 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 
 out:
 	if (ret < 0) {
+		if (priv->plat->exit)
+			priv->plat->exit(pdev);
+
 		platform_set_drvdata(pdev, NULL);
 		release_mem_region(res->start, resource_size(res));
 		if (addr != NULL)
@@ -1778,6 +1783,9 @@ static int stmmac_dvr_remove(struct platform_device *pdev)
 
 	stmmac_mdio_unregister(ndev);
 
+	if (priv->plat->exit)
+		priv->plat->exit(pdev);
+
 	platform_set_drvdata(pdev, NULL);
 	unregister_netdev(ndev);
 
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index d66c617..e103529 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -40,9 +40,9 @@ struct plat_stmmacenet_data {
 	int pmt;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
-#ifdef CONFIG_STM_DRIVERS
-	struct stm_pad_config *pad_config;
-#endif
+	int (*init)(struct platform_device *pdev);
+	void (*exit)(struct platform_device *pdev);
+	void *custom_cfg;
 	void *bsp_priv;
 };
 
-- 
1.5.5.6
