From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [net-next 1/4] stmmac: modify and improve the bus_setup platform callback
Date: Wed, 23 May 2012 07:40:16 +0200
Message-ID: <1337751619-21941-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:46708 "EHLO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751132Ab2EWFka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2012 01:40:30 -0400
Received: from zeta.dmz-eu.st.com (zeta.dmz-eu.st.com [164.129.230.9])
	by beta.dmz-eu.st.com (STMicroelectronics) with ESMTP id B5D30A3
	for <netdev@vger.kernel.org>; Wed, 23 May 2012 05:40:25 +0000 (GMT)
Received: from mail7.sgp.st.com (mail7.sgp.st.com [164.129.223.81])
	by zeta.dmz-eu.st.com (STMicroelectronics) with ESMTP id 256F11B4E
	for <netdev@vger.kernel.org>; Wed, 23 May 2012 05:40:25 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch modifies and improves the bus_setup callback now
by passing extra parameters that can help on more complex
platforms that require more custom settings.
The patch also updates the documentation.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 Documentation/networking/stmmac.txt               |    3 ++-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |   19 +++++++++++++++----
 include/linux/stmmac.h                            |    3 ++-
 3 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index ab1e8d7..20c01bf 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -121,7 +121,7 @@ and detailed below as well:
 	int pmt;
 	int force_sf_dma_mode;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
-	void (*bus_setup)(void __iomem *ioaddr);
+	void *(*bus_setup)(void __iomem *ioaddr, struct device *dev, void *d);
 	int (*init)(struct platform_device *pdev);
 	void (*exit)(struct platform_device *pdev);
 	void *bsp_priv;
@@ -156,6 +156,7 @@ Where:
  o bus_setup: perform HW setup of the bus. For example, on some ST platforms
 	     this field is used to configure the AMBA  bridge to generate more
 	     efficient STBus traffic.
+ o bus_data: saved custom data for custom bus setting.
  o init/exit: callbacks used for calling a custom initialisation;
 	     this is sometime necessary on some platforms (e.g. ST boxes)
 	     where the HW needs to have set some PIO lines or system cfg
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 7096633..2fc5462 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -999,10 +999,6 @@ static int stmmac_open(struct net_device *dev)
 	/* Copy the MAC addr into the HW  */
 	priv->hw->mac->set_umac_addr(priv->ioaddr, dev->dev_addr, 0);
 
-	/* If required, perform hw setup of the bus. */
-	if (priv->plat->bus_setup)
-		priv->plat->bus_setup(priv->ioaddr);
-
 	/* Initialize the MAC Core */
 	priv->hw->mac->core_init(priv->ioaddr);
 
@@ -1949,6 +1945,15 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 		goto error;
 	}
 
+	/* On some platforms, is is possible to perform some hw setup of the bus
+	 * and this is done by calling the bus_setup (when implemented).
+	 * Data from bus_setup can be saved in the patform structure to be
+	 * restored when resume for example form standby.
+	 */
+	if (priv->plat->bus_setup)
+		priv->plat->bus_data =
+			priv->plat->bus_setup(priv->ioaddr, priv->device,
+					      priv->plat->bus_data);
 	return priv;
 
 error:
@@ -2057,6 +2062,8 @@ int stmmac_resume(struct net_device *ndev)
 	priv->hw->dma->start_tx(priv->ioaddr);
 	priv->hw->dma->start_rx(priv->ioaddr);
 
+	priv->plat->bus_data = priv->plat->bus_setup(priv->ioaddr, priv->device,
+						     priv->plat->bus_data);
 #ifdef CONFIG_STMMAC_TIMER
 	if (likely(priv->tm->enable))
 		priv->tm->timer_start(tmrate);
@@ -2083,9 +2090,13 @@ int stmmac_freeze(struct net_device *ndev)
 
 int stmmac_restore(struct net_device *ndev)
 {
+	struct stmmac_priv *priv = netdev_priv(ndev);
+
 	if (!ndev || !netif_running(ndev))
 		return 0;
 
+	priv->plat->bus_data = priv->plat->bus_setup(priv->ioaddr, priv->device,
+						     priv->plat->bus_data);
 	return stmmac_open(ndev);
 }
 #endif /* CONFIG_PM */
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index b69bdb1..cf03968 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -106,7 +106,8 @@ struct plat_stmmacenet_data {
 	int pmt;
 	int force_sf_dma_mode;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
-	void (*bus_setup)(void __iomem *ioaddr);
+	void *(*bus_setup)(void __iomem *ioaddr, struct device *dev, void *d);
+	void *bus_data;
 	int (*init)(struct platform_device *pdev);
 	void (*exit)(struct platform_device *pdev);
 	void *custom_cfg;
-- 
1.7.4.4
