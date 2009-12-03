From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 07/10] bnx2: remove skb_dma_map/unmap calls from
	driver
Date: Wed, 02 Dec 2009 18:47:57 -0800
Message-ID: <20091203024756.2232.37924.stgit@localhost.localdomain>
References: <20091203024519.2232.6084.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Michael Chan <mchan@broadcom.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:37597
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753307AbZLCCsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 21:48:09 -0500
In-Reply-To: <20091203024519.2232.6084.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Due to the fact that skb_dma_map/unmap do not work correctly when a HW
IOMMU is enabled it has been recommended to go about removing the calls
from the network device drivers.

[ Fix bnx2_free_tx_skbs() ring indexing and use NETDEV_TX_OK return
  code in bnx2_start_xmit() after cleaning up DMA mapping errors. -Mchan ]

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/bnx2.c |   72 +++++++++++++++++++++++++++++++++++++++++++---------
 drivers/net/bnx2.h |    1 +
 2 files changed, 61 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 539d23b..f47bf50 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2815,13 +2815,21 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 			}
 		}
 
-		skb_dma_unmap(&bp->pdev->dev, skb, DMA_TO_DEVICE);
+		pci_unmap_single(bp->pdev, pci_unmap_addr(tx_buf, mapping),
+			skb_headlen(skb), PCI_DMA_TODEVICE);
 
 		tx_buf->skb = NULL;
 		last = tx_buf->nr_frags;
 
 		for (i = 0; i < last; i++) {
 			sw_cons = NEXT_TX_BD(sw_cons);
+
+			pci_unmap_page(bp->pdev,
+				pci_unmap_addr(
+					&txr->tx_buf_ring[TX_RING_IDX(sw_cons)],
+					mapping),
+				skb_shinfo(skb)->frags[i].size,
+				PCI_DMA_TODEVICE);
 		}
 
 		sw_cons = NEXT_TX_BD(sw_cons);
@@ -5295,17 +5303,29 @@ bnx2_free_tx_skbs(struct bnx2 *bp)
 		for (j = 0; j < TX_DESC_CNT; ) {
 			struct sw_tx_bd *tx_buf = &txr->tx_buf_ring[j];
 			struct sk_buff *skb = tx_buf->skb;
+			int k, last;
 
 			if (skb == NULL) {
 				j++;
 				continue;
 			}
 
-			skb_dma_unmap(&bp->pdev->dev, skb, DMA_TO_DEVICE);
+			pci_unmap_single(bp->pdev,
+					 pci_unmap_addr(tx_buf, mapping),
+					 skb_headlen(skb),
+					 PCI_DMA_TODEVICE);
 
 			tx_buf->skb = NULL;
 
-			j += skb_shinfo(skb)->nr_frags + 1;
+			last = tx_buf->nr_frags;
+			j++;
+			for (k = 0; k < last; k++, j++) {
+				tx_buf = &txr->tx_buf_ring[TX_RING_IDX(j)];
+				pci_unmap_page(bp->pdev,
+					pci_unmap_addr(tx_buf, mapping),
+					skb_shinfo(skb)->frags[k].size,
+					PCI_DMA_TODEVICE);
+			}
 			dev_kfree_skb(skb);
 		}
 	}
@@ -5684,11 +5704,12 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 	for (i = 14; i < pkt_size; i++)
 		packet[i] = (unsigned char) (i & 0xff);
 
-	if (skb_dma_map(&bp->pdev->dev, skb, DMA_TO_DEVICE)) {
+	map = pci_map_single(bp->pdev, skb->data, pkt_size,
+		PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(bp->pdev, map)) {
 		dev_kfree_skb(skb);
 		return -EIO;
 	}
-	map = skb_shinfo(skb)->dma_head;
 
 	REG_WR(bp, BNX2_HC_COMMAND,
 	       bp->hc_cmd | BNX2_HC_COMMAND_COAL_NOW_WO_INT);
@@ -5723,7 +5744,7 @@ bnx2_run_loopback(struct bnx2 *bp, int loopback_mode)
 
 	udelay(5);
 
-	skb_dma_unmap(&bp->pdev->dev, skb, DMA_TO_DEVICE);
+	pci_unmap_single(bp->pdev, map, pkt_size, PCI_DMA_TODEVICE);
 	dev_kfree_skb(skb);
 
 	if (bnx2_get_hw_tx_cons(tx_napi) != txr->tx_prod)
@@ -6302,7 +6323,6 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct bnx2_napi *bnapi;
 	struct bnx2_tx_ring_info *txr;
 	struct netdev_queue *txq;
-	struct skb_shared_info *sp;
 
 	/*  Determine which tx ring we will be placed on */
 	i = skb_get_queue_mapping(skb);
@@ -6367,16 +6387,15 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	} else
 		mss = 0;
 
-	if (skb_dma_map(&bp->pdev->dev, skb, DMA_TO_DEVICE)) {
+	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
+	if (pci_dma_mapping_error(bp->pdev, mapping)) {
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 
-	sp = skb_shinfo(skb);
-	mapping = sp->dma_head;
-
 	tx_buf = &txr->tx_buf_ring[ring_prod];
 	tx_buf->skb = skb;
+	pci_unmap_addr_set(tx_buf, mapping, mapping);
 
 	txbd = &txr->tx_desc_ring[ring_prod];
 
@@ -6397,7 +6416,12 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		txbd = &txr->tx_desc_ring[ring_prod];
 
 		len = frag->size;
-		mapping = sp->dma_maps[i];
+		mapping = pci_map_page(bp->pdev, frag->page, frag->page_offset,
+			len, PCI_DMA_TODEVICE);
+		if (pci_dma_mapping_error(bp->pdev, mapping))
+			goto dma_error;
+		pci_unmap_addr_set(&txr->tx_buf_ring[ring_prod], mapping,
+				   mapping);
 
 		txbd->tx_bd_haddr_hi = (u64) mapping >> 32;
 		txbd->tx_bd_haddr_lo = (u64) mapping & 0xffffffff;
@@ -6424,6 +6448,30 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	return NETDEV_TX_OK;
+dma_error:
+	/* save value of frag that failed */
+	last_frag = i;
+
+	/* start back at beginning and unmap skb */
+	prod = txr->tx_prod;
+	ring_prod = TX_RING_IDX(prod);
+	tx_buf = &txr->tx_buf_ring[ring_prod];
+	tx_buf->skb = NULL;
+	pci_unmap_single(bp->pdev, pci_unmap_addr(tx_buf, mapping),
+			 skb_headlen(skb), PCI_DMA_TODEVICE);
+
+	/* unmap remaining mapped pages */
+	for (i = 0; i < last_frag; i++) {
+		prod = NEXT_TX_BD(prod);
+		ring_prod = TX_RING_IDX(prod);
+		tx_buf = &txr->tx_buf_ring[ring_prod];
+		pci_unmap_page(bp->pdev, pci_unmap_addr(tx_buf, mapping),
+			       skb_shinfo(skb)->frags[i].size,
+			       PCI_DMA_TODEVICE);
+	}
+
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
 }
 
 /* Called with rtnl_lock */
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index a4d8340..4908b9f 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6559,6 +6559,7 @@ struct sw_pg {
 
 struct sw_tx_bd {
 	struct sk_buff		*skb;
+	DECLARE_PCI_UNMAP_ADDR(mapping)
 	unsigned short		is_gso;
 	unsigned short		nr_frags;
 };

