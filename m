From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH net-next 3/4] stmmac: change the stmmac_dvr_probe return type to int
Date: Wed, 20 May 2015 20:03:08 +0200
Message-ID: <1432144989-28283-4-git-send-email-manabian@gmail.com>
References: <1432144989-28283-1-git-send-email-manabian@gmail.com>
Cc: Joachim Eastwood <manabian@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, arnd@arndb.de,
	linux-arm-kernel@lists.infradead.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33390 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754774AbbETSDd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 14:03:33 -0400
Received: by lbbzk7 with SMTP id zk7so537704lbb.0
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 11:03:30 -0700 (PDT)
In-Reply-To: <1432144989-28283-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since stmmac_dvr_probe takes care of setting driver data and
assign resources to the priv structure there is no need to
access the priv structure from the other probe functions.
This mean that this function can be changed into just return
an int and thus simplifying the callers.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac.h          |  6 +++---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c     | 15 +++++++--------
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c      | 11 +----------
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 11 +----------
 4 files changed, 12 insertions(+), 31 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index b1687adb8e02..9cbcae203597 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -137,9 +137,9 @@ void stmmac_ptp_unregister(struct stmmac_priv *priv);
 int stmmac_resume(struct net_device *ndev);
 int stmmac_suspend(struct net_device *ndev);
 int stmmac_dvr_remove(struct net_device *ndev);
-struct stmmac_priv *stmmac_dvr_probe(struct device *device,
-				     struct plat_stmmacenet_data *plat_dat,
-				     struct stmmac_resources *res);
+int stmmac_dvr_probe(struct device *device,
+		     struct plat_stmmacenet_data *plat_dat,
+		     struct stmmac_resources *res);
 void stmmac_disable_eee_mode(struct stmmac_priv *priv);
 bool stmmac_eee_init(struct stmmac_priv *priv);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index e8b630a1f1ef..538de1ae4e2d 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2803,12 +2803,11 @@ static int stmmac_hw_init(struct stmmac_priv *priv)
  * Description: this is the main probe function used to
  * call the alloc_etherdev, allocate the priv structure.
  * Return:
- * on success the new private structure is returned, otherwise the error
- * pointer.
+ * returns 0 on success, otherwise errno.
  */
-struct stmmac_priv *stmmac_dvr_probe(struct device *device,
-				     struct plat_stmmacenet_data *plat_dat,
-				     struct stmmac_resources *res)
+int stmmac_dvr_probe(struct device *device,
+		     struct plat_stmmacenet_data *plat_dat,
+		     struct stmmac_resources *res)
 {
 	int ret = 0;
 	struct net_device *ndev = NULL;
@@ -2816,7 +2815,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 
 	ndev = alloc_etherdev(sizeof(struct stmmac_priv));
 	if (!ndev)
-		return ERR_PTR(-ENOMEM);
+		return -ENOMEM;
 
 	SET_NETDEV_DEV(ndev, device);
 
@@ -2952,7 +2951,7 @@ struct stmmac_priv *stmmac_dvr_probe(struct device *device,
 		}
 	}
 
-	return priv;
+	return 0;
 
 error_mdio_register:
 	unregister_netdev(ndev);
@@ -2965,7 +2964,7 @@ error_pclk_get:
 error_clk_get:
 	free_netdev(ndev);
 
-	return ERR_PTR(ret);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(stmmac_dvr_probe);
 
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 2c663ec2dfb3..d71a721ea61c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -164,7 +164,6 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	struct stmmac_pci_info *info = (struct stmmac_pci_info *)id->driver_data;
 	struct plat_stmmacenet_data *plat;
 	struct stmmac_resources res;
-	struct stmmac_priv *priv;
 	int i;
 	int ret;
 
@@ -220,15 +219,7 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	res.wol_irq = pdev->irq;
 	res.irq = pdev->irq;
 
-	priv = stmmac_dvr_probe(&pdev->dev, plat, &res);
-	if (IS_ERR(priv)) {
-		dev_err(&pdev->dev, "%s: main driver probe failed\n", __func__);
-		return PTR_ERR(priv);
-	}
-
-	dev_dbg(&pdev->dev, "STMMAC PCI driver registration completed\n");
-
-	return 0;
+	return stmmac_dvr_probe(&pdev->dev, plat, &res);
 }
 
 /**
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index 6b7481afbdf7..10de9351a1ec 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -255,7 +255,6 @@ int stmmac_pltfr_probe(struct platform_device *pdev)
 	int ret = 0;
 	struct resource *res;
 	struct device *dev = &pdev->dev;
-	struct stmmac_priv *priv = NULL;
 	struct plat_stmmacenet_data *plat_dat = NULL;
 
 	memset(&stmmac_res, 0, sizeof(stmmac_res));
@@ -334,15 +333,7 @@ int stmmac_pltfr_probe(struct platform_device *pdev)
 			return ret;
 	}
 
-	priv = stmmac_dvr_probe(&(pdev->dev), plat_dat, &stmmac_res);
-	if (IS_ERR(priv)) {
-		pr_err("%s: main driver probe failed", __func__);
-		return PTR_ERR(priv);
-	}
-
-	pr_debug("STMMAC platform driver registration completed");
-
-	return 0;
+	return stmmac_dvr_probe(&pdev->dev, plat_dat, &stmmac_res);
 }
 EXPORT_SYMBOL_GPL(stmmac_pltfr_probe);
 
-- 
1.8.0
