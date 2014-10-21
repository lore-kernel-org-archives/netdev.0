From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH 2/5] stmmac: pci: use managed resources
Date: Tue, 21 Oct 2014 19:35:30 +0300
Message-ID: <1413909333-16380-3-git-send-email-andriy.shevchenko@linux.intel.com>
References: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org,
	Kweh Hock Leong <hock.leong.kweh@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41282 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933215AbaJUUhO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2014 16:37:14 -0400
In-Reply-To: <1413909333-16380-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Migrate pci driver to managed resources to reduce boilerplate error handling
code.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c | 46 +++++-------------------
 1 file changed, 8 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
index 5459a4e..f8d4ce2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c
@@ -65,45 +65,29 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
 			    const struct pci_device_id *id)
 {
 	int ret = 0;
-	void __iomem *addr = NULL;
 	struct stmmac_priv *priv = NULL;
-	int i;
+	int pci_bar = 0;
 
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
+	ret = pcim_iomap_regions(pdev, BIT(pci_bar), pci_name(pdev));
+	if (ret)
+		return ret;
 
-	/* Get the base address of device */
-	for (i = 0; i <= 5; i++) {
-		if (pci_resource_len(pdev, i) == 0)
-			continue;
-		addr = pci_iomap(pdev, i, 0);
-		if (addr == NULL) {
-			pr_err("%s: ERROR: cannot map register memory aborting",
-			       __func__);
-			ret = -EIO;
-			goto err_out_map_failed;
-		}
-		break;
-	}
 	pci_set_master(pdev);
 
 	stmmac_default_data();
 
-	priv = stmmac_dvr_probe(&(pdev->dev), &plat_dat, addr);
+	priv = stmmac_dvr_probe(&pdev->dev, &plat_dat,
+				pcim_iomap_table(pdev)[pci_bar]);
 	if (IS_ERR(priv)) {
 		pr_err("%s: main driver probe failed", __func__);
-		ret = PTR_ERR(priv);
-		goto err_out;
+		return PTR_ERR(priv);
 	}
 	priv->dev->irq = pdev->irq;
 	priv->wol_irq = pdev->irq;
@@ -113,15 +97,6 @@ static int stmmac_pci_probe(struct pci_dev *pdev,
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
@@ -134,13 +109,8 @@ err_out_req_reg_failed:
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
