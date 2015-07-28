From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 16/17] stmmac: remove setup/free glue callbacks
Date: Wed, 29 Jul 2015 00:09:03 +0200
Message-ID: <1438121344-5304-17-git-send-email-manabian@gmail.com>
References: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org
To: peppe.cavallaro@st.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:36545 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752167AbbG1WJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 18:09:38 -0400
Received: by lagw2 with SMTP id w2so77108687lag.3
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 15:09:37 -0700 (PDT)
In-Reply-To: <1438121344-5304-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As all dwmac-* drivers have been converted to have a proper probe
function the setup callback can now be removed. Also remove the
free callback that wasn't used by any driver.

New dwmac-* drivers should implement standard probe and remove
functions to preform any needed setup and teardown.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 Documentation/networking/stmmac.txt                   | 8 ++------
 drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c   | 7 -------
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 3 ---
 include/linux/stmmac.h                                | 2 --
 4 files changed, 2 insertions(+), 18 deletions(-)

diff --git a/Documentation/networking/stmmac.txt b/Documentation/networking/stmmac.txt
index de5c42342ec3..2903b1cf4d70 100644
--- a/Documentation/networking/stmmac.txt
+++ b/Documentation/networking/stmmac.txt
@@ -135,8 +135,6 @@ struct plat_stmmacenet_data {
 	int maxmtu;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
-	void *(*setup)(struct platform_device *pdev);
-	void (*free)(struct platform_device *pdev, void *priv);
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
 	void *bsp_priv;
@@ -177,12 +175,10 @@ Where:
  o bus_setup: perform HW setup of the bus. For example, on some ST platforms
 	     this field is used to configure the AMBA  bridge to generate more
 	     efficient STBus traffic.
- o setup/init/exit: callbacks used for calling a custom initialization;
+ o init/exit: callbacks used for calling a custom initialization;
 	     this is sometime necessary on some platforms (e.g. ST boxes)
 	     where the HW needs to have set some PIO lines or system cfg
-	     registers. setup should return a pointer to private data,
-	     which will be stored in bsp_priv, and then passed to init and
-	     exit callbacks. init/exit callbacks should not use or modify
+	     registers.  init/exit callbacks should not use or modify
 	     platform data.
  o bsp_priv: another private pointer.
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
index f4fe9f1a33b4..b1e5f24708c9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-generic.c
@@ -46,13 +46,6 @@ static int dwmac_generic_probe(struct platform_device *pdev)
 		plat_dat->unicast_filter_entries = 1;
 	}
 
-	/* Custom setup (if needed) */
-	if (plat_dat->setup) {
-		plat_dat->bsp_priv = plat_dat->setup(pdev);
-		if (IS_ERR(plat_dat->bsp_priv))
-			return PTR_ERR(plat_dat->bsp_priv);
-	}
-
 	/* Custom initialisation (if needed) */
 	if (plat_dat->init) {
 		ret = plat_dat->init(pdev, plat_dat->bsp_priv);
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 55e569b330b2..1cb660405f35 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -300,9 +300,6 @@ int stmmac_pltfr_remove(struct platform_device *pdev)
 	if (priv->plat->exit)
 		priv->plat->exit(pdev, priv->plat->bsp_priv);
 
-	if (priv->plat->free)
-		priv->plat->free(pdev, priv->plat->bsp_priv);
-
 	return ret;
 }
 EXPORT_SYMBOL_GPL(stmmac_pltfr_remove);
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index b43cd56b78e9..eead8ab93c0a 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -119,8 +119,6 @@ struct plat_stmmacenet_data {
 	int rx_fifo_size;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
-	void *(*setup)(struct platform_device *pdev);
-	void (*free)(struct platform_device *pdev, void *priv);
 	int (*init)(struct platform_device *pdev, void *priv);
 	void (*exit)(struct platform_device *pdev, void *priv);
 	void *bsp_priv;
-- 
1.8.0
