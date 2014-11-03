From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2 3/5] stmmac: pci: use managed resources
Date: Mon,  3 Nov 2014 15:02:15 +0200
Message-ID: <1415019737-32736-4-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1415019737-32736-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>,
	Rayagond K <rayagond@vayavyalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55907 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752384AbaKCNDA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2014 08:03:00 -0500
In-Reply-To: <1415019737-32736-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Migrate pci driver to managed resources to reduce boilerplate error handling
code.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 43 ++++++------------------
 1 file changed, 10 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index f19ac8e..5357a3f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -71,46 +71,37 @@ static void stmmac_default_data(void)
 static int stmmac_pci_probe(struct pci_dev *pdev,
 			    const struct pci_device_id *id)
 {
-	int ret = 0;
-	void __iomem *addr = NULL;
-	struct stmmac_priv *priv = NULL;
+	struct stmmac_priv *priv;
 	int i;
+	int ret;
 
 	/* Enable pci device */
-	ret = pci_enable_device(pdev);
+	ret = pcim_enable_device(pdev);
 	if (ret) {
 		pr_err("%s : ERROR: failed to enable %s device\n", __func__,
 		       pci_name(pdev));
 		return ret;
 	}
-	if (pci_request_regions(pdev, STMMAC_RESOURCE_NAME)) {
-		pr_err("%s: ERROR: failed to get PCI region\n", __func__);
-		ret = -ENODEV;
-		goto err_out_req_reg_failed;
-	}
 
 	/* Get the base address of device */
 	for (i = 0; i <= PCI_STD_RESOURCE_END; i++) {
 		if (pci_resource_len(pdev, i) == 0)
 			continue;
-		addr = pci_iomap(pdev, i, 0);
-		if (addr == NULL) {
-			pr_err("%s: ERROR: cannot map register memory aborting",
-			       __func__);
-			ret = -EIO;
-			goto err_out_map_failed;
-		}
+		ret = pcim_iomap_regions(pdev, BIT(i), pci_name(pdev));
+		if (ret)
+			return ret;
 		break;
 	}
+
 	pci_set_master(pdev);
 
 	stmmac_default_data();
 
-	priv = stmmac_dvr_probe(&(pdev->dev), &plat_dat, addr);
+	priv = stmmac_dvr_probe(&pdev->dev, &plat_dat,
+				pcim_iomap_table(pdev)[i]);
 	if (IS_ERR(priv)) {
 		pr_err("%s: main driver probe failed", __func__);
-		ret = PTR_ERR(priv);
-		goto err_out;
+		return PTR_ERR(priv);
 	}
 	priv->dev->irq = pdev->irq;
 	priv->wol_irq = pdev->irq;
@@ -120,15 +111,6 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 	pr_debug("STMMAC platform driver registration completed");
 
 	return 0;
-
-err_out:
-	pci_clear_master(pdev);
-err_out_map_failed:
-	pci_release_regions(pdev);
-err_out_req_reg_failed:
-	pci_disable_device(pdev);
-
-	return ret;
 }
 
 /**
@@ -141,13 +123,8 @@ err_out_req_reg_failed:
 static void stmmac_pci_remove(struct pci_dev *pdev)
 {
 	struct net_device *ndev = pci_get_drvdata(pdev);
-	struct stmmac_priv *priv = netdev_priv(ndev);
 
 	stmmac_dvr_remove(ndev);
-
-	pci_iounmap(pdev, priv->ioaddr);
-	pci_release_regions(pdev);
-	pci_disable_device(pdev);
 }
 
 #ifdef CONFIG_PM_SLEEP
-- 
2.1.1
