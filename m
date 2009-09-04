From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 23/29] dw_dmac: implement a private tx_list
Date: Thu, 03 Sep 2009 19:32:27 -0700
Message-ID: <20090904023227.32667.50915.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Haavard Skinnemoen <haavard.skinnemoen@atmel.com>,
	maciej.sosnowski@intel.com
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:52747 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932778AbZIDCcY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 22:32:24 -0400
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop dw_dmac's use of tx_list from struct dma_async_tx_descriptor in
preparation for removal of this field.

Cc: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/dw_dmac.c      |   19 ++++++++++---------
 drivers/dma/dw_dmac_regs.h |    1 +
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/dma/dw_dmac.c b/drivers/dma/dw_dmac.c
index 98c9a84..514ef7d 100644
--- a/drivers/dma/dw_dmac.c
+++ b/drivers/dma/dw_dmac.c
@@ -116,7 +116,7 @@ static void dwc_sync_desc_for_cpu(struct dw_dma_chan *dwc, struct dw_desc *desc)
 {
 	struct dw_desc	*child;
 
-	list_for_each_entry(child, &desc->txd.tx_list, desc_node)
+	list_for_each_entry(child, &desc->tx_list, desc_node)
 		dma_sync_single_for_cpu(chan2parent(&dwc->chan),
 				child->txd.phys, sizeof(child->lli),
 				DMA_TO_DEVICE);
@@ -137,11 +137,11 @@ static void dwc_desc_put(struct dw_dma_chan *dwc, struct dw_desc *desc)
 		dwc_sync_desc_for_cpu(dwc, desc);
 
 		spin_lock_bh(&dwc->lock);
-		list_for_each_entry(child, &desc->txd.tx_list, desc_node)
+		list_for_each_entry(child, &desc->tx_list, desc_node)
 			dev_vdbg(chan2dev(&dwc->chan),
 					"moving child desc %p to freelist\n",
 					child);
-		list_splice_init(&desc->txd.tx_list, &dwc->free_list);
+		list_splice_init(&desc->tx_list, &dwc->free_list);
 		dev_vdbg(chan2dev(&dwc->chan), "moving desc %p to freelist\n", desc);
 		list_add(&desc->desc_node, &dwc->free_list);
 		spin_unlock_bh(&dwc->lock);
@@ -209,7 +209,7 @@ dwc_descriptor_complete(struct dw_dma_chan *dwc, struct dw_desc *desc)
 	param = txd->callback_param;
 
 	dwc_sync_desc_for_cpu(dwc, desc);
-	list_splice_init(&txd->tx_list, &dwc->free_list);
+	list_splice_init(&desc->tx_list, &dwc->free_list);
 	list_move(&desc->desc_node, &dwc->free_list);
 
 	/*
@@ -289,7 +289,7 @@ static void dwc_scan_descriptors(struct dw_dma *dw, struct dw_dma_chan *dwc)
 			/* This one is currently in progress */
 			return;
 
-		list_for_each_entry(child, &desc->txd.tx_list, desc_node)
+		list_for_each_entry(child, &desc->tx_list, desc_node)
 			if (child->lli.llp == llp)
 				/* Currently in progress */
 				return;
@@ -356,7 +356,7 @@ static void dwc_handle_error(struct dw_dma *dw, struct dw_dma_chan *dwc)
 	dev_printk(KERN_CRIT, chan2dev(&dwc->chan),
 			"  cookie: %d\n", bad_desc->txd.cookie);
 	dwc_dump_lli(dwc, &bad_desc->lli);
-	list_for_each_entry(child, &bad_desc->txd.tx_list, desc_node)
+	list_for_each_entry(child, &bad_desc->tx_list, desc_node)
 		dwc_dump_lli(dwc, &child->lli);
 
 	/* Pretend the descriptor completed successfully */
@@ -608,7 +608,7 @@ dwc_prep_dma_memcpy(struct dma_chan *chan, dma_addr_t dest, dma_addr_t src,
 					prev->txd.phys, sizeof(prev->lli),
 					DMA_TO_DEVICE);
 			list_add_tail(&desc->desc_node,
-					&first->txd.tx_list);
+					&first->tx_list);
 		}
 		prev = desc;
 	}
@@ -700,7 +700,7 @@ dwc_prep_slave_sg(struct dma_chan *chan, struct scatterlist *sgl,
 						sizeof(prev->lli),
 						DMA_TO_DEVICE);
 				list_add_tail(&desc->desc_node,
-						&first->txd.tx_list);
+						&first->tx_list);
 			}
 			prev = desc;
 			total_len += len;
@@ -746,7 +746,7 @@ dwc_prep_slave_sg(struct dma_chan *chan, struct scatterlist *sgl,
 						sizeof(prev->lli),
 						DMA_TO_DEVICE);
 				list_add_tail(&desc->desc_node,
-						&first->txd.tx_list);
+						&first->tx_list);
 			}
 			prev = desc;
 			total_len += len;
@@ -902,6 +902,7 @@ static int dwc_alloc_chan_resources(struct dma_chan *chan)
 			break;
 		}
 
+		INIT_LIST_HEAD(&desc->tx_list);
 		dma_async_tx_descriptor_init(&desc->txd, chan);
 		desc->txd.tx_submit = dwc_tx_submit;
 		desc->txd.flags = DMA_CTRL_ACK;
diff --git a/drivers/dma/dw_dmac_regs.h b/drivers/dma/dw_dmac_regs.h
index 13a5807..d9a939f 100644
--- a/drivers/dma/dw_dmac_regs.h
+++ b/drivers/dma/dw_dmac_regs.h
@@ -217,6 +217,7 @@ struct dw_desc {
 
 	/* THEN values for driver housekeeping */
 	struct list_head		desc_node;
+	struct list_head		tx_list;
 	struct dma_async_tx_descriptor	txd;
 	size_t				len;
 };

