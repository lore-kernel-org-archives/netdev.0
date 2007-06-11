From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 8/15] spidernet: beautify error messages
Date: Mon, 11 Jun 2007 13:41:38 -0500
Message-ID: <20070611184138.GH13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:57571 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751322AbXFKSlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 14:41:40 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BIfeB0006830
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:41:40 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BIfe3X514654
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:41:40 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BIfdBD023779
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:41:39 -0400
Content-Disposition: inline
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Use dev_err() to print device error messages.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   64 ++++++++++++++++++++++++-----------------------
 1 file changed, 34 insertions(+), 30 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-11 13:09:46.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-11 13:11:29.000000000 -0500
@@ -434,7 +434,8 @@ spider_net_prepare_rx_descr(struct spide
 				      bufsize + SPIDER_NET_RXBUF_ALIGN - 1);
 	if (!descr->skb) {
 		if (netif_msg_rx_err(card) && net_ratelimit())
-			pr_err("Not enough memory to allocate rx buffer\n");
+			dev_err(&card->netdev->dev,
+			        "Not enough memory to allocate rx buffer\n");
 		card->spider_stats.alloc_rx_skb_error++;
 		return -ENOMEM;
 	}
@@ -455,7 +456,7 @@ spider_net_prepare_rx_descr(struct spide
 		dev_kfree_skb_any(descr->skb);
 		descr->skb = NULL;
 		if (netif_msg_rx_err(card) && net_ratelimit())
-			pr_err("Could not iommu-map rx buffer\n");
+			dev_err(&card->netdev->dev, "Could not iommu-map rx buffer\n");
 		card->spider_stats.rx_iommu_map_error++;
 		hwdescr->dmac_cmd_status = SPIDER_NET_DESCR_NOT_IN_USE;
 	} else {
@@ -692,7 +693,7 @@ spider_net_prepare_tx_descr(struct spide
 	buf = pci_map_single(card->pdev, skb->data, skb->len, PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(buf)) {
 		if (netif_msg_tx_err(card) && net_ratelimit())
-			pr_err("could not iommu-map packet (%p, %i). "
+			dev_err(&card->netdev->dev, "could not iommu-map packet (%p, %i). "
 				  "Dropping packet\n", skb->data, skb->len);
 		card->spider_stats.tx_iommu_map_error++;
 		return -ENOMEM;
@@ -832,9 +833,8 @@ spider_net_release_tx_chain(struct spide
 		case SPIDER_NET_DESCR_PROTECTION_ERROR:
 		case SPIDER_NET_DESCR_FORCE_END:
 			if (netif_msg_tx_err(card))
-				pr_err("%s: forcing end of tx descriptor "
-				       "with status x%02x\n",
-				       card->netdev->name, status);
+				dev_err(&card->netdev->dev, "forcing end of tx descriptor "
+				       "with status x%02x\n", status);
 			card->netdev_stats.tx_errors++;
 			break;
 
@@ -1147,8 +1147,8 @@ spider_net_decode_one_descr(struct spide
 	     (status == SPIDER_NET_DESCR_PROTECTION_ERROR) ||
 	     (status == SPIDER_NET_DESCR_FORCE_END) ) {
 		if (netif_msg_rx_err(card))
-			pr_err("%s: dropping RX descriptor with state %d\n",
-			       card->netdev->name, status);
+			dev_err(&card->netdev->dev,
+			       "dropping RX descriptor with state %d\n", status);
 		card->netdev_stats.rx_dropped++;
 		goto bad_desc;
 	}
@@ -1156,8 +1156,8 @@ spider_net_decode_one_descr(struct spide
 	if ( (status != SPIDER_NET_DESCR_COMPLETE) &&
 	     (status != SPIDER_NET_DESCR_FRAME_END) ) {
 		if (netif_msg_rx_err(card))
-			pr_err("%s: RX descriptor with unknown state %d\n",
-			       card->netdev->name, status);
+			dev_err(&card->netdev->dev,
+			       "RX descriptor with unknown state %d\n", status);
 		card->spider_stats.rx_desc_unk_state++;
 		goto bad_desc;
 	}
@@ -1165,16 +1165,15 @@ spider_net_decode_one_descr(struct spide
 	/* The cases we'll throw away the packet immediately */
 	if (hwdescr->data_error & SPIDER_NET_DESTROY_RX_FLAGS) {
 		if (netif_msg_rx_err(card))
-			pr_err("%s: error in received descriptor found, "
+			dev_err(&card->netdev->dev,
+			       "error in received descriptor found, "
 			       "data_status=x%08x, data_error=x%08x\n",
-			       card->netdev->name,
 			       hwdescr->data_status, hwdescr->data_error);
 		goto bad_desc;
 	}
 
 	if (hwdescr->dmac_cmd_status & 0xfcf4) {
-		pr_err("%s: bad status, cmd_status=x%08x\n",
-			       card->netdev->name,
+		dev_err(&card->netdev->dev, "bad status, cmd_status=x%08x\n",
 			       hwdescr->dmac_cmd_status);
 		pr_err("buf_addr=x%08x\n", hwdescr->buf_addr);
 		pr_err("buf_size=x%08x\n", hwdescr->buf_size);
@@ -1452,7 +1451,7 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GPWFFINT:
 		/* PHY command queue full */
 		if (netif_msg_intr(card))
-			pr_err("PHY write queue full\n");
+			dev_err(&card->netdev->dev, "PHY write queue full\n");
 		show_error = 0;
 		break;
 
@@ -1619,9 +1618,8 @@ spider_net_handle_error_irq(struct spide
 	}
 
 	if ((show_error) && (netif_msg_intr(card)) && net_ratelimit())
-		pr_err("Got error interrupt on %s, GHIINT0STS = 0x%08x, "
+		dev_err(&card->netdev->dev, "Error interrupt, GHIINT0STS = 0x%08x, "
 		       "GHIINT1STS = 0x%08x, GHIINT2STS = 0x%08x\n",
-		       card->netdev->name,
 		       status_reg, error_reg1, error_reg2);
 
 	/* clear interrupt sources */
@@ -1886,7 +1884,8 @@ spider_net_init_firmware(struct spider_n
 			     SPIDER_NET_FIRMWARE_NAME, &card->pdev->dev) == 0) {
 		if ( (firmware->size != SPIDER_NET_FIRMWARE_LEN) &&
 		     netif_msg_probe(card) ) {
-			pr_err("Incorrect size of spidernet firmware in " \
+			dev_err(&card->netdev->dev,
+			       "Incorrect size of spidernet firmware in " \
 			       "filesystem. Looking in host firmware...\n");
 			goto try_host_fw;
 		}
@@ -1910,8 +1909,8 @@ try_host_fw:
 
 	if ( (fw_size != SPIDER_NET_FIRMWARE_LEN) &&
 	     netif_msg_probe(card) ) {
-		pr_err("Incorrect size of spidernet firmware in " \
-		       "host firmware\n");
+		dev_err(&card->netdev->dev,
+		       "Incorrect size of spidernet firmware in host firmware\n");
 		goto done;
 	}
 
@@ -1921,7 +1920,8 @@ done:
 	return err;
 out_err:
 	if (netif_msg_probe(card))
-		pr_err("Couldn't find spidernet firmware in filesystem " \
+		dev_err(&card->netdev->dev,
+		       "Couldn't find spidernet firmware in filesystem " \
 		       "or host firmware\n");
 	return err;
 }
@@ -2319,13 +2319,14 @@ spider_net_setup_netdev(struct spider_ne
 
 	result = spider_net_set_mac(netdev, &addr);
 	if ((result) && (netif_msg_probe(card)))
-		pr_err("Failed to set MAC address: %i\n", result);
+		dev_err(&card->netdev->dev,
+		        "Failed to set MAC address: %i\n", result);
 
 	result = register_netdev(netdev);
 	if (result) {
 		if (netif_msg_probe(card))
-			pr_err("Couldn't register net_device: %i\n",
-				  result);
+			dev_err(&card->netdev->dev,
+			        "Couldn't register net_device: %i\n", result);
 		return result;
 	}
 
@@ -2403,17 +2404,19 @@ spider_net_setup_pci_dev(struct pci_dev 
 	unsigned long mmio_start, mmio_len;
 
 	if (pci_enable_device(pdev)) {
-		pr_err("Couldn't enable PCI device\n");
+		dev_err(&pdev->dev, "Couldn't enable PCI device\n");
 		return NULL;
 	}
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
-		pr_err("Couldn't find proper PCI device base address.\n");
+		dev_err(&pdev->dev,
+		        "Couldn't find proper PCI device base address.\n");
 		goto out_disable_dev;
 	}
 
 	if (pci_request_regions(pdev, spider_net_driver_name)) {
-		pr_err("Couldn't obtain PCI resources, aborting.\n");
+		dev_err(&pdev->dev,
+		        "Couldn't obtain PCI resources, aborting.\n");
 		goto out_disable_dev;
 	}
 
@@ -2421,8 +2424,8 @@ spider_net_setup_pci_dev(struct pci_dev 
 
 	card = spider_net_alloc_card();
 	if (!card) {
-		pr_err("Couldn't allocate net_device structure, "
-			  "aborting.\n");
+		dev_err(&pdev->dev,
+		        "Couldn't allocate net_device structure, aborting.\n");
 		goto out_release_regions;
 	}
 	card->pdev = pdev;
@@ -2436,7 +2439,8 @@ spider_net_setup_pci_dev(struct pci_dev 
 	card->regs = ioremap(mmio_start, mmio_len);
 
 	if (!card->regs) {
-		pr_err("Couldn't obtain PCI resources, aborting.\n");
+		dev_err(&pdev->dev,
+		        "Couldn't obtain PCI resources, aborting.\n");
 		goto out_release_regions;
 	}
 
