From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] e1000: Fix DMA mapping error handling on RX
Date: Fri, 19 Feb 2010 19:54:53 -0800
Message-ID: <20100220035423.31265.13034.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Anton Blanchard <anton@samba.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:40484 "EHLO
	qmta07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754594Ab0BTDzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 22:55:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

Check for error return from pci_map_single/pci_map_page and clean up.

With this and the previous patch the driver was able to handle a significant
percentage of errors (I set the fault injection rate to 10% and could still
download large files at a reasonable speed).

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index d29bb53..7655436 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -4006,11 +4006,21 @@ check_page:
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
@@ -4101,6 +4111,13 @@ map_skb:
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

