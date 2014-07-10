From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH v2] farsync: fix invalid memory accesses in fst_add_one() and fst_init_card()
Date: Thu, 10 Jul 2014 18:43:01 -0400
Message-ID: <1405032181-5342-1-git-send-email-khoroshilov@ispras.ru>
References: <20140708.162027.1804045121900039101.davem@davemloft.net>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Kevin Curtis <kevin.curtis@farsite.co.uk>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ispras.ru ([83.149.199.45]:33119 "EHLO mail.ispras.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750927AbaGJWnT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2014 18:43:19 -0400
In-Reply-To: <20140708.162027.1804045121900039101.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several issues in fst_add_one() and fst_init_card():
- invalid pointer dereference at card->ports[card->nports - 1] if
  register_hdlc_device() fails for the first port in fst_init_card();
- fst_card_array overflow at fst_card_array[no_of_cards_added]
  because there is no checks for array overflow;
- use after free because pointer to deallocated card is left in fst_card_array
  if something fails after fst_card_array[no_of_cards_added] = card;
- several leaks on failure paths in fst_add_one().

The patch fixes all the issues and makes code more readable.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wan/farsync.c | 112 ++++++++++++++++++++++++----------------------
 1 file changed, 58 insertions(+), 54 deletions(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 93ace042d0aa..1f041271f7fe 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2363,7 +2363,7 @@ static char *type_strings[] = {
 	"FarSync TE1"
 };
 
-static void
+static int
 fst_init_card(struct fst_card_info *card)
 {
 	int i;
@@ -2374,24 +2374,21 @@ fst_init_card(struct fst_card_info *card)
 	 * we'll have to revise it in some way then.
 	 */
 	for (i = 0; i < card->nports; i++) {
-                err = register_hdlc_device(card->ports[i].dev);
-                if (err < 0) {
-			int j;
+		err = register_hdlc_device(card->ports[i].dev);
+		if (err < 0) {
 			pr_err("Cannot register HDLC device for port %d (errno %d)\n",
-			       i, -err);
-			for (j = i; j < card->nports; j++) {
-				free_netdev(card->ports[j].dev);
-				card->ports[j].dev = NULL;
-			}
-                        card->nports = i;
-                        break;
-                }
+				i, -err);
+			while (i--)
+				unregister_hdlc_device(card->ports[i].dev);
+			return err;
+		}
 	}
 
 	pr_info("%s-%s: %s IRQ%d, %d ports\n",
 		port_to_dev(&card->ports[0])->name,
 		port_to_dev(&card->ports[card->nports - 1])->name,
 		type_strings[card->type], card->irq, card->nports);
+	return 0;
 }
 
 static const struct net_device_ops fst_ops = {
@@ -2447,15 +2444,12 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* Try to enable the device */
 	if ((err = pci_enable_device(pdev)) != 0) {
 		pr_err("Failed to enable card. Err %d\n", -err);
-		kfree(card);
-		return err;
+		goto enable_fail;
 	}
 
 	if ((err = pci_request_regions(pdev, "FarSync")) !=0) {
 		pr_err("Failed to allocate regions. Err %d\n", -err);
-		pci_disable_device(pdev);
-		kfree(card);
-	        return err;
+		goto regions_fail;
 	}
 
 	/* Get virtual addresses of memory regions */
@@ -2464,30 +2458,21 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	card->phys_ctlmem = pci_resource_start(pdev, 3);
 	if ((card->mem = ioremap(card->phys_mem, FST_MEMSIZE)) == NULL) {
 		pr_err("Physical memory remap failed\n");
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		kfree(card);
-		return -ENODEV;
+		err = -ENODEV;
+		goto ioremap_physmem_fail;
 	}
 	if ((card->ctlmem = ioremap(card->phys_ctlmem, 0x10)) == NULL) {
 		pr_err("Control memory remap failed\n");
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		iounmap(card->mem);
-		kfree(card);
-		return -ENODEV;
+		err = -ENODEV;
+		goto ioremap_ctlmem_fail;
 	}
 	dbg(DBG_PCI, "kernel mem %p, ctlmem %p\n", card->mem, card->ctlmem);
 
 	/* Register the interrupt handler */
 	if (request_irq(pdev->irq, fst_intr, IRQF_SHARED, FST_DEV_NAME, card)) {
 		pr_err("Unable to register interrupt %d\n", card->irq);
-		pci_release_regions(pdev);
-		pci_disable_device(pdev);
-		iounmap(card->ctlmem);
-		iounmap(card->mem);
-		kfree(card);
-		return -ENODEV;
+		err = -ENODEV;
+		goto irq_fail;
 	}
 
 	/* Record info we need */
@@ -2513,13 +2498,8 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			while (i--)
 				free_netdev(card->ports[i].dev);
 			pr_err("FarSync: out of memory\n");
-                        free_irq(card->irq, card);
-                        pci_release_regions(pdev);
-                        pci_disable_device(pdev);
-                        iounmap(card->ctlmem);
-                        iounmap(card->mem);
-                        kfree(card);
-                        return -ENODEV;
+			err = -ENOMEM;
+			goto hdlcdev_fail;
 		}
 		card->ports[i].dev    = dev;
                 card->ports[i].card   = card;
@@ -2565,9 +2545,16 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_drvdata(pdev, card);
 
 	/* Remainder of card setup */
+	if (no_of_cards_added >= FST_MAX_CARDS) {
+		pr_err("FarSync: too many cards\n");
+		err = -ENOMEM;
+		goto card_array_fail;
+	}
 	fst_card_array[no_of_cards_added] = card;
 	card->card_no = no_of_cards_added++;	/* Record instance and bump it */
-	fst_init_card(card);
+	err = fst_init_card(card);
+	if (err)
+		goto init_card_fail;
 	if (card->family == FST_FAMILY_TXU) {
 		/*
 		 * Allocate a dma buffer for transmit and receives
@@ -2577,29 +2564,46 @@ fst_add_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 					 &card->rx_dma_handle_card);
 		if (card->rx_dma_handle_host == NULL) {
 			pr_err("Could not allocate rx dma buffer\n");
-			fst_disable_intr(card);
-			pci_release_regions(pdev);
-			pci_disable_device(pdev);
-			iounmap(card->ctlmem);
-			iounmap(card->mem);
-			kfree(card);
-			return -ENOMEM;
+			err = -ENOMEM;
+			goto rx_dma_fail;
 		}
 		card->tx_dma_handle_host =
 		    pci_alloc_consistent(card->device, FST_MAX_MTU,
 					 &card->tx_dma_handle_card);
 		if (card->tx_dma_handle_host == NULL) {
 			pr_err("Could not allocate tx dma buffer\n");
-			fst_disable_intr(card);
-			pci_release_regions(pdev);
-			pci_disable_device(pdev);
-			iounmap(card->ctlmem);
-			iounmap(card->mem);
-			kfree(card);
-			return -ENOMEM;
+			err = -ENOMEM;
+			goto tx_dma_fail;
 		}
 	}
 	return 0;		/* Success */
+
+tx_dma_fail:
+	pci_free_consistent(card->device, FST_MAX_MTU,
+			    card->rx_dma_handle_host,
+			    card->rx_dma_handle_card);
+rx_dma_fail:
+	fst_disable_intr(card);
+	for (i = 0 ; i < card->nports ; i++)
+		unregister_hdlc_device(card->ports[i].dev);
+init_card_fail:
+	fst_card_array[card->card_no] = NULL;
+card_array_fail:
+	for (i = 0 ; i < card->nports ; i++)
+		free_netdev(card->ports[i].dev);
+hdlcdev_fail:
+	free_irq(card->irq, card);
+irq_fail:
+	iounmap(card->ctlmem);
+ioremap_ctlmem_fail:
+	iounmap(card->mem);
+ioremap_physmem_fail:
+	pci_release_regions(pdev);
+regions_fail:
+	pci_disable_device(pdev);
+enable_fail:
+	kfree(card);
+	return err;
 }
 
 /*
-- 
1.9.1
