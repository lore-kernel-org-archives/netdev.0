From: Jim Lewis <jim@jklewis.com>
Subject: [PATCH] Spidernet - remove ETH_ZLEN check in earlier patch
Date: Fri, 10 Nov 2006 11:50:46 -0600
Message-ID: <1163181046.4422.11.camel@localhost.localdomain>
Reply-To: jim@jklewis.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Work <jklewis@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from centrmmtao01.cox.net ([70.168.83.83]:28669 "EHLO
	centrmmtao01.cox.net") by vger.kernel.org with ESMTP
	id S1161905AbWKJRut (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 12:50:49 -0500
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: Spidernet - remove ETH_ZLEN check in earlier patch
From: James K Lewis <jklewis@us.ibm.com>

In an earlier patch, code was added to pad packets that were less that
ETH_ZLEN (60) bytes using the skb_pad function. This has caused hangs
when accessing certain NFS mounted file systems. This patch removes the
check and solves the NFS problem. The driver, with this patch, has been
tested extensively. Please apply.


Signed-off-by: James K Lewis <jklewis@us.ibm.com>


---
 drivers/net/spider_net.c |   17 ++++-------------
 drivers/net/spider_net.h |    2 +-
 2 files changed, 5 insertions(+), 14 deletions(-)

Index: linux-2.6.18/drivers/net/spider_net.c
===================================================================
--- linux-2.6.18.orig/drivers/net/spider_net.c	2006-11-04
13:04:32.000000000 -0600
+++ linux-2.6.18/drivers/net/spider_net.c	2006-11-04 13:10:00.000000000
-0600
@@ -610,20 +610,12 @@ spider_net_prepare_tx_descr(struct spide
 	struct spider_net_descr *descr;
 	dma_addr_t buf;
 	unsigned long flags;
-	int length;
 
-	length = skb->len;
-	if (length < ETH_ZLEN) {
-		if (skb_pad(skb, ETH_ZLEN-length))
-			return 0;
-		length = ETH_ZLEN;
-	}
-
-	buf = pci_map_single(card->pdev, skb->data, length, PCI_DMA_TODEVICE);
+	buf = pci_map_single(card->pdev, skb->data, skb->len,
PCI_DMA_TODEVICE);
 	if (pci_dma_mapping_error(buf)) {
 		if (netif_msg_tx_err(card) && net_ratelimit())
 			pr_err("could not iommu-map packet (%p, %i). "
-				  "Dropping packet\n", skb->data, length);
+				  "Dropping packet\n", skb->data, skb->len);
 		card->spider_stats.tx_iommu_map_error++;
 		return -ENOMEM;
 	}
@@ -633,7 +625,7 @@ spider_net_prepare_tx_descr(struct spide
 	card->tx_chain.head = descr->next;
 
 	descr->buf_addr = buf;
-	descr->buf_size = length;
+	descr->buf_size = skb->len;
 	descr->next_descr_addr = 0;
 	descr->skb = skb;
 	descr->data_status = 0;
@@ -768,8 +760,7 @@ spider_net_release_tx_chain(struct spide
 
 		/* unmap the skb */
 		if (skb) {
-			int len = skb->len < ETH_ZLEN ? ETH_ZLEN : skb->len;
-			pci_unmap_single(card->pdev, buf_addr, len, PCI_DMA_TODEVICE);
+			pci_unmap_single(card->pdev, buf_addr, skb->len, PCI_DMA_TODEVICE);
 			dev_kfree_skb(skb);
 		}
 	}
Index: linux-2.6.18/drivers/net/spider_net.h
===================================================================
--- linux-2.6.18.orig/drivers/net/spider_net.h	2006-11-04
13:03:58.000000000 -0600
+++ linux-2.6.18/drivers/net/spider_net.h	2006-11-04 13:06:11.000000000
-0600
@@ -24,7 +24,7 @@
 #ifndef _SPIDER_NET_H
 #define _SPIDER_NET_H
 
-#define VERSION "1.1 A"
+#define VERSION "1.5 A"
 
 #include "sungem_phy.h"
 


