From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 3/18] spidernet: beautify error messages
Date: Thu, 7 Jun 2007 14:24:28 -0500
Message-ID: <20070607192428.GC16077@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cbe-oss-dev@ozlabs.org, netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:43069 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764263AbXFGTYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 15:24:30 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l57JPYEM018562
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:25:34 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l57JOT0w517036
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:24:29 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l57JOT9B007911
	for <netdev@vger.kernel.org>; Thu, 7 Jun 2007 15:24:29 -0400
Content-Disposition: inline
In-Reply-To: <20070607191707.GA7904@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Use dev_err() to print device error messages.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   67 ++++++++++++++++++++++++-----------------------
 drivers/net/spider_net.h |    2 -
 2 files changed, 36 insertions(+), 33 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-07 11:51:45.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-07 11:51:47.000000000 -0500
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
 
@@ -1087,8 +1087,8 @@ spider_net_decode_one_descr(struct spide
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
@@ -1096,8 +1096,8 @@ spider_net_decode_one_descr(struct spide
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
@@ -1105,16 +1105,14 @@ spider_net_decode_one_descr(struct spide
 	/* The cases we'll throw away the packet immediately */
 	if (hwdescr->data_error & SPIDER_NET_DESTROY_RX_FLAGS) {
 		if (netif_msg_rx_err(card))
-			pr_err("%s: error in received descriptor found, "
+			dev_err(&card->netdev->dev, "error in received descriptor found, "
 			       "data_status=x%08x, data_error=x%08x\n",
-			       card->netdev->name,
 			       hwdescr->data_status, hwdescr->data_error);
 		goto bad_desc;
 	}
 
 	if (hwdescr->dmac_cmd_status & 0xfefe) {
-		pr_err("%s: bad status, cmd_status=x%08x\n",
-			       card->netdev->name,
+		dev_err(&card->netdev->dev, "bad status, cmd_status=x%08x\n",
 			       hwdescr->dmac_cmd_status);
 		pr_err("buf_addr=x%08x\n", hwdescr->buf_addr);
 		pr_err("buf_size=x%08x\n", hwdescr->buf_size);
@@ -1384,7 +1382,7 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GPWFFINT:
 		/* PHY command queue full */
 		if (netif_msg_intr(card))
-			pr_err("PHY write queue full\n");
+			dev_err(&card->netdev->dev, "PHY write queue full\n");
 		show_error = 0;
 		break;
 
@@ -1455,7 +1453,7 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GRFAFLLINT: /* fallthrough */
 	case SPIDER_NET_GRMFLLINT:
 		if (netif_msg_intr(card) && net_ratelimit())
-			pr_err("Spider RX RAM full, incoming packets "
+			dev_err(&card->netdev->dev, "Spider RX RAM full, incoming packets "
 			       "might be discarded!\n");
 		spider_net_rx_irq_off(card);
 		netif_rx_schedule(card->netdev);
@@ -1474,7 +1472,7 @@ spider_net_handle_error_irq(struct spide
 	case SPIDER_NET_GDBDCEINT: /* fallthrough */
 	case SPIDER_NET_GDADCEINT:
 		if (netif_msg_intr(card) && net_ratelimit())
-			pr_err("got descriptor chain end interrupt, "
+			dev_err(&card->netdev->dev, "got descriptor chain end interrupt, "
 			       "restarting DMAC %c.\n",
 			       'D'-(i-SPIDER_NET_GDDDCEINT)/3);
 		spider_net_refill_rx_chain(card);
@@ -1545,9 +1543,8 @@ spider_net_handle_error_irq(struct spide
 	}
 
 	if ((show_error) && (netif_msg_intr(card)) && net_ratelimit())
-		pr_err("Got error interrupt on %s, GHIINT0STS = 0x%08x, "
+		dev_err(&card->netdev->dev, "Error interrupt, GHIINT0STS = 0x%08x, "
 		       "GHIINT1STS = 0x%08x, GHIINT2STS = 0x%08x\n",
-		       card->netdev->name,
 		       status_reg, error_reg1, error_reg2);
 
 	/* clear interrupt sources */
@@ -1811,7 +1808,8 @@ spider_net_init_firmware(struct spider_n
 			     SPIDER_NET_FIRMWARE_NAME, &card->pdev->dev) == 0) {
 		if ( (firmware->size != SPIDER_NET_FIRMWARE_LEN) &&
 		     netif_msg_probe(card) ) {
-			pr_err("Incorrect size of spidernet firmware in " \
+			dev_err(&card->netdev->dev,
+			       "Incorrect size of spidernet firmware in " \
 			       "filesystem. Looking in host firmware...\n");
 			goto try_host_fw;
 		}
@@ -1835,8 +1833,8 @@ try_host_fw:
 
 	if ( (fw_size != SPIDER_NET_FIRMWARE_LEN) &&
 	     netif_msg_probe(card) ) {
-		pr_err("Incorrect size of spidernet firmware in " \
-		       "host firmware\n");
+		dev_err(&card->netdev->dev,
+		       "Incorrect size of spidernet firmware in host firmware\n");
 		goto done;
 	}
 
@@ -1846,7 +1844,8 @@ done:
 	return err;
 out_err:
 	if (netif_msg_probe(card))
-		pr_err("Couldn't find spidernet firmware in filesystem " \
+		dev_err(&card->netdev->dev,
+		       "Couldn't find spidernet firmware in filesystem " \
 		       "or host firmware\n");
 	return err;
 }
@@ -2242,13 +2241,14 @@ spider_net_setup_netdev(struct spider_ne
 
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
 
@@ -2326,17 +2326,19 @@ spider_net_setup_pci_dev(struct pci_dev 
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
 
@@ -2344,8 +2346,8 @@ spider_net_setup_pci_dev(struct pci_dev 
 
 	card = spider_net_alloc_card();
 	if (!card) {
-		pr_err("Couldn't allocate net_device structure, "
-			  "aborting.\n");
+		dev_err(&pdev->dev,
+		        "Couldn't allocate net_device structure, aborting.\n");
 		goto out_release_regions;
 	}
 	card->pdev = pdev;
@@ -2359,7 +2361,8 @@ spider_net_setup_pci_dev(struct pci_dev 
 	card->regs = ioremap(mmio_start, mmio_len);
 
 	if (!card->regs) {
-		pr_err("Couldn't obtain PCI resources, aborting.\n");
+		dev_err(&pdev->dev,
+		        "Couldn't obtain PCI resources, aborting.\n");
 		goto out_release_regions;
 	}
 
Index: linux-2.6.22-rc1/drivers/net/spider_net.h
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.h	2007-06-07 11:42:17.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.h	2007-06-07 11:51:47.000000000 -0500
@@ -25,7 +25,7 @@
 #ifndef _SPIDER_NET_H
 #define _SPIDER_NET_H
 
-#define VERSION "2.0 A"
+#define VERSION "2.0 B"
 
 #include "sungem_phy.h"
 
