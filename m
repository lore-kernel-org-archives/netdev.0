From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 04/13] stmmac: rewiew platform data
Date: Thu,  7 Jan 2010 10:07:14 +0100
Message-ID: <1262855243-6762-4-git-send-email-peppe.cavallaro@st.com>
References: <1262855243-6762-1-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-2-git-send-email-peppe.cavallaro@st.com>
 <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:43341 "EHLO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756048Ab0AGJH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:07:28 -0500
Received: from zeta.dmz-eu.st.com (ns2.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 05FB216C
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:24 +0000 (GMT)
Received: from mail3.ctn.st.com (mail3.ctn.st.com [164.130.116.150])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id BE63CBE9
	for <netdev@vger.kernel.org>; Thu,  7 Jan 2010 09:07:23 +0000 (GMT)
In-Reply-To: <1262855243-6762-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch rewiews and reorganises all the data
come from the platform removing any dependency
from the stm code.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/stmmac/stmmac.h      |   24 ++++++++++++++++++++++++
 drivers/net/stmmac/stmmac_main.c |   16 +++++++++-------
 2 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/drivers/net/stmmac/stmmac.h b/drivers/net/stmmac/stmmac.h
index 6d2eae3..0d5529f 100644
--- a/drivers/net/stmmac/stmmac.h
+++ b/drivers/net/stmmac/stmmac.h
@@ -21,6 +21,7 @@
 *******************************************************************************/
 
 #define DRV_MODULE_VERSION	"Oct_09"
+#include <linux/stmmac.h>
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #define STMMAC_VLAN_TAG_USED
@@ -69,6 +70,7 @@ struct stmmac_priv {
 	int phy_mask;
 	int (*phy_reset) (void *priv);
 	void (*fix_mac_speed) (void *priv, unsigned int speed);
+	void (*bus_setup)(unsigned long ioaddr);
 	void *bsp_priv;
 
 	int phy_irq;
@@ -93,6 +95,28 @@ struct stmmac_priv {
 #endif
 };
 
+#ifdef CONFIG_STM_DRIVERS
+#include <linux/stm/pad.h>
+static inline int stmmac_claim_resource(struct platform_device *pdev)
+{
+	int ret = 0;
+	struct plat_stmmacenet_data *plat_dat = pdev->dev.platform_data;
+
+	/* Pad routing setup */
+	if (IS_ERR(devm_stm_pad_claim(&pdev->dev, plat_dat->pad_config,
+			dev_name(&pdev->dev)))) {
+		printk(KERN_ERR "%s: Failed to request pads!\n", __func__);
+		ret = -ENODEV;
+	}
+	return ret;
+}
+#else
+static inline int stmmac_claim_resource(struct platform_device *pdev)
+{
+	return 0;
+}
+#endif
+
 extern int stmmac_mdio_unregister(struct net_device *ndev);
 extern int stmmac_mdio_register(struct net_device *ndev);
 extern void stmmac_set_ethtool_ops(struct net_device *netdev);
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index 79a9381..d50fe6f 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -45,7 +45,6 @@
 #include <linux/phy.h>
 #include <linux/if_vlan.h>
 #include <linux/dma-mapping.h>
-#include <linux/stm/soc.h>
 #include "stmmac.h"
 
 #define STMMAC_RESOURCE_NAME	"stmmaceth"
@@ -1798,8 +1797,7 @@ static int stmmac_mac_device_setup(struct net_device *dev)
 
 static int stmmacphy_dvr_probe(struct platform_device *pdev)
 {
-	struct plat_stmmacphy_data *plat_dat;
-	plat_dat = (struct plat_stmmacphy_data *)((pdev->dev).platform_data);
+	struct plat_stmmacphy_data *plat_dat = pdev->dev.platform_data;
 
 	pr_debug("stmmacphy_dvr_probe: added phy for bus %d\n",
 	       plat_dat->bus_id);
@@ -1831,9 +1829,7 @@ static struct platform_driver stmmacphy_driver = {
 static int stmmac_associate_phy(struct device *dev, void *data)
 {
 	struct stmmac_priv *priv = (struct stmmac_priv *)data;
-	struct plat_stmmacphy_data *plat_dat;
-
-	plat_dat = (struct plat_stmmacphy_data *)(dev->platform_data);
+	struct plat_stmmacphy_data *plat_dat = dev->platform_data;
 
 	DBG(probe, DEBUG, "%s: checking phy for bus %d\n", __func__,
 		plat_dat->bus_id);
@@ -1923,7 +1919,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	priv = netdev_priv(ndev);
 	priv->device = &(pdev->dev);
 	priv->dev = ndev;
-	plat_dat = (struct plat_stmmacenet_data *)((pdev->dev).platform_data);
+	plat_dat = pdev->dev.platform_data;
 	priv->bus_id = plat_dat->bus_id;
 	priv->pbl = plat_dat->pbl;	/* TLI */
 	priv->is_gmac = plat_dat->has_gmac;	/* GMAC is on board */
@@ -1933,6 +1929,11 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	/* Set the I/O base addr */
 	ndev->base_addr = (unsigned long)addr;
 
+	/* Verify embedded resource for the platform */
+	ret = stmmac_claim_resource(pdev);
+	if (ret < 0)
+		goto out;
+
 	/* MAC HW revice detection */
 	ret = stmmac_mac_device_setup(ndev);
 	if (ret < 0)
@@ -1953,6 +1954,7 @@ static int stmmac_dvr_probe(struct platform_device *pdev)
 	}
 
 	priv->fix_mac_speed = plat_dat->fix_mac_speed;
+	priv->bus_setup = plat_dat->bus_setup;
 	priv->bsp_priv = plat_dat->bsp_priv;
 
 	pr_info("\t%s - (dev. name: %s - id: %d, IRQ #%d\n"
-- 
1.6.0.4

