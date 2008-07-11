From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 6/9] e1000: Move assignments in tests before test
Date: Fri, 11 Jul 2008 15:17:28 -0700
Message-ID: <20080711221728.3255.45296.stgit@localhost.localdomain>
References: <20080711221442.3255.16180.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63952 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756227AbYGKWRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 18:17:50 -0400
In-Reply-To: <20080711221442.3255.16180.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |   49 ++++++++++++++++++++++---------------
 drivers/net/e1000/e1000_main.c    |   41 ++++++++++++++++++++-----------
 2 files changed, 56 insertions(+), 34 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index f9ac9a8..6a3893a 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -483,10 +483,12 @@ static int e1000_get_eeprom(struct net_device *netdev,
 					    last_word - first_word + 1,
 					    eeprom_buff);
 	else {
-		for (i = 0; i < last_word - first_word + 1; i++)
-			if ((ret_val = e1000_read_eeprom(hw, first_word + i, 1,
-							&eeprom_buff[i])))
+		for (i = 0; i < last_word - first_word + 1; i++) {
+			ret_val = e1000_read_eeprom(hw, first_word + i, 1,
+						    &eeprom_buff[i]);
+			if (ret_val)
 				break;
+		}
 	}
 
 	/* Device's eeprom is always little-endian, word addressable */
@@ -669,9 +671,11 @@ static int e1000_set_ringparam(struct net_device *netdev,
 
 	if (netif_running(adapter->netdev)) {
 		/* Try to get new resources before deleting old */
-		if ((err = e1000_setup_all_rx_resources(adapter)))
+		err = e1000_setup_all_rx_resources(adapter);
+		if (err)
 			goto err_setup_rx;
-		if ((err = e1000_setup_all_tx_resources(adapter)))
+		err = e1000_setup_all_tx_resources(adapter);
+		if (err)
 			goto err_setup_tx;
 
 		/* save the new, restore the old in order to free it,
@@ -685,7 +689,8 @@ static int e1000_set_ringparam(struct net_device *netdev,
 		kfree(rx_old);
 		adapter->rx_ring = rxdr;
 		adapter->tx_ring = txdr;
-		if ((err = e1000_up(adapter)))
+		err = e1000_up(adapter);
+		if (err)
 			goto err_setup;
 	}
 
@@ -1057,17 +1062,17 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	if (!txdr->count)
 		txdr->count = E1000_DEFAULT_TXD;
 
-	if (!(txdr->buffer_info = kcalloc(txdr->count,
-	                                  sizeof(struct e1000_buffer),
-		                          GFP_KERNEL))) {
+	txdr->buffer_info = kcalloc(txdr->count, sizeof(struct e1000_buffer),
+				    GFP_KERNEL);
+	if (!txdr->buffer_info) {
 		ret_val = 1;
 		goto err_nomem;
 	}
 
 	txdr->size = txdr->count * sizeof(struct e1000_tx_desc);
 	txdr->size = ALIGN(txdr->size, 4096);
-	if (!(txdr->desc = pci_alloc_consistent(pdev, txdr->size,
-	                                        &txdr->dma))) {
+	txdr->desc = pci_alloc_consistent(pdev, txdr->size, &txdr->dma);
+	if (!txdr->desc) {
 		ret_val = 2;
 		goto err_nomem;
 	}
@@ -1088,7 +1093,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		struct sk_buff *skb;
 		unsigned int size = 1024;
 
-		if (!(skb = alloc_skb(size, GFP_KERNEL))) {
+		skb = alloc_skb(size, GFP_KERNEL);
+		if (!skb) {
 			ret_val = 3;
 			goto err_nomem;
 		}
@@ -1111,15 +1117,16 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	if (!rxdr->count)
 		rxdr->count = E1000_DEFAULT_RXD;
 
-	if (!(rxdr->buffer_info = kcalloc(rxdr->count,
-	                                  sizeof(struct e1000_buffer),
-	                                  GFP_KERNEL))) {
+	rxdr->buffer_info = kcalloc(rxdr->count, sizeof(struct e1000_buffer),
+				    GFP_KERNEL);
+	if (!rxdr->buffer_info) {
 		ret_val = 4;
 		goto err_nomem;
 	}
 
 	rxdr->size = rxdr->count * sizeof(struct e1000_rx_desc);
-	if (!(rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma))) {
+	rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma);
+	if (!rxdr->desc) {
 		ret_val = 5;
 		goto err_nomem;
 	}
@@ -1142,8 +1149,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		struct e1000_rx_desc *rx_desc = E1000_RX_DESC(*rxdr, i);
 		struct sk_buff *skb;
 
-		if (!(skb = alloc_skb(E1000_RXBUFFER_2048 + NET_IP_ALIGN,
-				GFP_KERNEL))) {
+		skb = alloc_skb(E1000_RXBUFFER_2048 + NET_IP_ALIGN, GFP_KERNEL);
+		if (!skb) {
 			ret_val = 6;
 			goto err_nomem;
 		}
@@ -1564,9 +1571,11 @@ static int e1000_loopback_test(struct e1000_adapter *adapter, u64 *data)
 		goto out;
 	}
 
-	if ((*data = e1000_setup_desc_rings(adapter)))
+	*data = e1000_setup_desc_rings(adapter);
+	if (*data)
 		goto out;
-	if ((*data = e1000_setup_loopback_test(adapter)))
+	*data = e1000_setup_loopback_test(adapter);
+	if (*data)
 		goto err_loopback;
 	*data = e1000_run_loopback_test(adapter);
 	e1000_loopback_cleanup(adapter);
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 397fe52..d1d4d00 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -898,22 +898,28 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
 	DECLARE_MAC_BUF(mac);
 
-	if ((err = pci_enable_device(pdev)))
+	err = pci_enable_device(pdev);
+	if (err)
 		return err;
 
-	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
-	    !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
+	if (!pci_set_dma_mask(pdev, DMA_64BIT_MASK) &&
+	    !pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK)) {
 		pci_using_dac = 1;
 	} else {
-		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) &&
-		    (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
-			E1000_ERR("No usable DMA configuration, aborting\n");
-			goto err_dma;
+		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
+		if (err) {
+			err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK);
+			if (err) {
+				E1000_ERR("No usable DMA configuration, "
+					  "aborting\n");
+				goto err_dma;
+			}
 		}
 		pci_using_dac = 0;
 	}
 
-	if ((err = pci_request_regions(pdev, e1000_driver_name)))
+	err = pci_request_regions(pdev, e1000_driver_name);
+	if (err)
 		goto err_pci_reg;
 
 	pci_set_master(pdev);
@@ -975,7 +981,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* setup the private structure */
 
-	if ((err = e1000_sw_init(adapter)))
+	err = e1000_sw_init(adapter);
+	if (err)
 		goto err_sw_init;
 
 	err = -EIO;
@@ -1182,7 +1189,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netif_stop_queue(netdev);
 
 	strcpy(netdev->name, "eth%d");
-	if ((err = register_netdev(netdev)))
+	err = register_netdev(netdev);
+	if (err)
 		goto err_register;
 
 	DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");
@@ -4393,7 +4401,8 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 		}
 
 		for (j = 0; j < adapter->rx_ps_pages; j++) {
-			if (!(length= le16_to_cpu(rx_desc->wb.upper.length[j])))
+			length = le16_to_cpu(rx_desc->wb.upper.length[j]);
+			if (!length)
 				break;
 			pci_unmap_page(pdev, ps_page_dma->ps_page_dma[j],
 					PAGE_SIZE, PCI_DMA_FROMDEVICE);
@@ -5151,7 +5160,8 @@ static int e1000_resume(struct pci_dev *pdev)
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	if ((err = pci_enable_device(pdev))) {
+	err = pci_enable_device(pdev);
+	if (err) {
 		printk(KERN_ERR "e1000: Cannot enable PCI device from suspend\n");
 		return err;
 	}
@@ -5160,8 +5170,11 @@ static int e1000_resume(struct pci_dev *pdev)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
-	if (netif_running(netdev) && (err = e1000_request_irq(adapter)))
-		return err;
+	if (netif_running(netdev)) {
+		err = e1000_request_irq(adapter);
+		if (err)
+			return err;
+	}
 
 	e1000_power_up_phy(adapter);
 	e1000_reset(adapter);

