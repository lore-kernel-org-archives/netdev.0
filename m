From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 2/2] e1000: Fix DMA mapping error handling on RX
Date: Thu, 21 Jan 2010 22:44:20 +1100
Message-ID: <20100121114420.GA11892@kryten>
References: <20100121114244.GC32259@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Joh
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:45347 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751502Ab0AULqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2010 06:46:05 -0500
Content-Disposition: inline
In-Reply-To: <20100121114244.GC32259@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Check for error return from pci_map_single/pci_map_page and clean up.

With this and the previous patch the driver was able to handle a significant
percentage of errors (I set the fault injection rate to 10% and could still
download large files at a reasonable speed).

Signed-off-by: Anton Blanchard <anton@samba.org>
---

I wasn't able to stress the jumbo frame path, so that part could do with some
more eyes.

Index: linux.trees.git/drivers/net/e1000/e1000_main.c
===================================================================
--- linux.trees.git.orig/drivers/net/e1000/e1000_main.c	2010-01-21 11:13:10.000000000 +1100
+++ linux.trees.git/drivers/net/e1000/e1000_main.c	2010-01-21 11:15:54.000000000 +1100
@@ -4014,11 +4014,21 @@ check_page:
 			}
 		}
 
-		if (!buffer_info->dma)
+		if (!buffer_info->dma) {
 			buffer_info->dma = pci_map_page(pdev,
 			                                buffer_info->page, 0,
 			                                buffer_info->length,
 			                                PCI_DMA_FROMDEVICE);
+			if (pci_dma_mapping_error(pdev, buffer_info->dma)) {
+				put_page(buffer_info->page);
+				dev_kfree_skb(skb);
+				buffer_info->page = NULL;
+				buffer_info->skb = NULL;
+				buffer_info->dma = 0;
+				adapter->alloc_rx_buff_failed++;
+				break; /* while !buffer_info->skb */
+			}
+		}
 
 		rx_desc = E1000_RX_DESC(*rx_ring, i);
 		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
@@ -4109,6 +4119,13 @@ map_skb:
 						  skb->data,
 						  buffer_info->length,
 						  PCI_DMA_FROMDEVICE);
+		if (pci_dma_mapping_error(pdev, buffer_info->dma)) {
+			dev_kfree_skb(skb);
+			buffer_info->skb = NULL;
+			buffer_info->dma = 0;
+			adapter->alloc_rx_buff_failed++;
+			break; /* while !buffer_info->skb */
+		}
 
 		/*
 		 * XXX if it was allocated cleanly it will never map to a
