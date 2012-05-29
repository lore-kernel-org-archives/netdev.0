From: Devendra Naga <devendra.aaru@gmail.com>
Subject: [PATCH V2 2/2] r6040: Do a Proper deinit at errorpath and also when driver unloads (calling r6040_remove_one)
Date: Wed, 30 May 2012 05:13:34 +0530
Message-ID: <1338335014-14877-1-git-send-email-devendra.aaru@gmail.com>
Cc: Devendra Naga <devendra.aaru@gmail.com>
To: David Miller <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

so if mdiobus_alloc fails, the errorpath doesnt do a netif_napi_del and also
doesn't set the priv data of the driver to NULL.

at the driver unload stage the driver doesn't remove the NAPI context, and
doesnt' set the priv data to NULL, and also doesn't call the pci_iounmap.

Signed-off-by: Devendra Naga <devendra.aaru@gmail.com>
---
 drivers/net/ethernet/rdc/r6040.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index f5e6f1f..d1827e8 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -1233,6 +1233,8 @@ err_out_mdio_irq:
 err_out_mdio:
 	mdiobus_free(lp->mii_bus);
 err_out_unmap:
+	netif_napi_del(&lp->napi);
+	pci_set_drvdata(pdev, NULL);
 	pci_iounmap(pdev, ioaddr);
 err_out_free_res:
 	pci_release_regions(pdev);
@@ -1253,6 +1255,9 @@ static void __devexit r6040_remove_one(struct pci_dev *pdev)
 	mdiobus_unregister(lp->mii_bus);
 	kfree(lp->mii_bus->irq);
 	mdiobus_free(lp->mii_bus);
+	netif_napi_del(&lp->napi);
+	pci_set_drvdata(pdev, NULL);
+	pci_iounmap(pdev, lp->base);
 	pci_release_regions(pdev);
 	free_netdev(dev);
 	pci_disable_device(pdev);
-- 
1.7.9.5
