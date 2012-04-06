From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 23/39] uli526x: fix regions leak in driver probe error path.
Date: Fri,  6 Apr 2012 12:06:37 +0200
Message-ID: <5a61e7c690fce53cd37eddc9808134bc0e6b9837.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43488 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756048Ab2DFKKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:43 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Grant Grundler <grundler@parisc-linux.org>
---
 drivers/net/ethernet/dec/tulip/uli526x.c |   48 ++++++++++++-----------------
 1 files changed, 20 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index fc4001f..c9b3396 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -313,9 +313,9 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 		goto err_out_disable;
 	}
 
-	if (pci_request_regions(pdev, DRV_NAME)) {
+	err = pci_request_regions(pdev, DRV_NAME);
+	if (err < 0) {
 		pr_err("Failed to request PCI regions\n");
-		err = -ENODEV;
 		goto err_out_disable;
 	}
 
@@ -323,18 +323,15 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	db = netdev_priv(dev);
 
 	/* Allocate Tx/Rx descriptor memory */
+	err = -ENOMEM;
+
 	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
-	if(db->desc_pool_ptr == NULL)
-	{
-		err = -ENOMEM;
-		goto err_out_nomem;
-	}
+	if (!db->desc_pool_ptr)
+		goto err_out_release;
+
 	db->buf_pool_ptr = pci_alloc_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
-	if(db->buf_pool_ptr == NULL)
-	{
-		err = -ENOMEM;
-		goto err_out_nomem;
-	}
+	if (!db->buf_pool_ptr)
+		goto err_out_free_tx_desc;
 
 	db->first_tx_desc = (struct tx_desc *) db->desc_pool_ptr;
 	db->first_tx_desc_dma = db->desc_pool_dma_ptr;
@@ -387,7 +384,7 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 	}
 	err = register_netdev (dev);
 	if (err)
-		goto err_out_res;
+		goto err_out_free_tx_buf;
 
 	netdev_info(dev, "ULi M%04lx at pci%s, %pM, irq %d\n",
 		    ent->driver_data >> 16, pci_name(pdev),
@@ -397,16 +394,14 @@ static int __devinit uli526x_init_one (struct pci_dev *pdev,
 
 	return 0;
 
-err_out_res:
+err_out_free_tx_buf:
+	pci_free_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
+			    db->buf_pool_ptr, db->buf_pool_dma_ptr);
+err_out_free_tx_desc:
+	pci_free_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20,
+			    db->desc_pool_ptr, db->desc_pool_dma_ptr);
+err_out_release:
 	pci_release_regions(pdev);
-err_out_nomem:
-	if(db->desc_pool_ptr)
-		pci_free_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20,
-			db->desc_pool_ptr, db->desc_pool_dma_ptr);
-
-	if(db->buf_pool_ptr != NULL)
-		pci_free_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
-			db->buf_pool_ptr, db->buf_pool_dma_ptr);
 err_out_disable:
 	pci_disable_device(pdev);
 err_out_free:
@@ -422,19 +417,16 @@ static void __devexit uli526x_remove_one (struct pci_dev *pdev)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct uli526x_board_info *db = netdev_priv(dev);
 
-	ULI526X_DBUG(0, "uli526x_remove_one()", 0);
-
+	unregister_netdev(dev);
 	pci_free_consistent(db->pdev, sizeof(struct tx_desc) *
 				DESC_ALL_CNT + 0x20, db->desc_pool_ptr,
  				db->desc_pool_dma_ptr);
 	pci_free_consistent(db->pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
 				db->buf_pool_ptr, db->buf_pool_dma_ptr);
-	unregister_netdev(dev);
 	pci_release_regions(pdev);
-	free_netdev(dev);	/* free board information */
-	pci_set_drvdata(pdev, NULL);
 	pci_disable_device(pdev);
-	ULI526X_DBUG(0, "uli526x_remove_one() exit", 0);
+	pci_set_drvdata(pdev, NULL);
+	free_netdev(dev);
 }
 
 
-- 
1.7.7.6
