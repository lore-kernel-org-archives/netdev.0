From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 25/75] intel: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:57 +0100
Message-ID: <1313760467-8598-25-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>
Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Cc: Alex Duyck <alexander.h.duyck@intel.com>
Cc: John Ronciak <john.ronciak@intel.com>
Cc: e1000-devel@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/e1000/e1000_main.c     |   16 +++++++++-------
 drivers/net/e1000e/netdev.c        |    7 +++----
 drivers/net/igb/igb_main.c         |    5 +----
 drivers/net/igbvf/netdev.c         |    5 +----
 drivers/net/ixgb/ixgb_main.c       |    6 +++---
 drivers/net/ixgbe/ixgbe_main.c     |    9 ++++-----
 drivers/net/ixgbevf/ixgbevf_main.c |   10 ++++------
 7 files changed, 25 insertions(+), 33 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index f97afda..c96770c 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2909,9 +2909,10 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		offset = frag->page_offset;
+		offset = 0;
 
 		while (len) {
+			unsigned long bufend;
 			i++;
 			if (unlikely(i == tx_ring->count))
 				i = 0;
@@ -2925,18 +2926,19 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			/* Workaround for potential 82544 hang in PCI-X.
 			 * Avoid terminating buffers within evenly-aligned
 			 * dwords. */
+			bufend = (unsigned long)
+				page_to_phys(skb_frag_page(frag));
+			bufend += offset + size - 1;
 			if (unlikely(adapter->pcix_82544 &&
-			    !((unsigned long)(page_to_phys(frag->page) + offset
-			                      + size - 1) & 4) &&
-			    size > 4))
+				     !(bufend & 4) &&
+				     size > 4))
 				size -= 4;
 
 			buffer_info->length = size;
 			buffer_info->time_stamp = jiffies;
 			buffer_info->mapped_as_page = true;
-			buffer_info->dma = dma_map_page(&pdev->dev, frag->page,
-							offset,	size,
-							DMA_TO_DEVICE);
+			buffer_info->dma = skb_frag_dma_map(&pdev->dev, frag,
+						offset, size, DMA_TO_DEVICE);
 			if (dma_mapping_error(&pdev->dev, buffer_info->dma))
 				goto dma_error;
 			buffer_info->next_to_watch = i;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 362f703..446a571 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4581,7 +4581,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		offset = frag->page_offset;
+		offset = 0;
 
 		while (len) {
 			i++;
@@ -4594,9 +4594,8 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 			buffer_info->length = size;
 			buffer_info->time_stamp = jiffies;
 			buffer_info->next_to_watch = i;
-			buffer_info->dma = dma_map_page(&pdev->dev, frag->page,
-							offset, size,
-							DMA_TO_DEVICE);
+			buffer_info->dma = skb_frag_dma_map(&pdev->dev, frag,
+						offset, size, DMA_TO_DEVICE);
 			buffer_info->mapped_as_page = true;
 			if (dma_mapping_error(&pdev->dev, buffer_info->dma))
 				goto dma_error;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 40d4c40..8e84e63 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4172,10 +4172,7 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
 		buffer_info->time_stamp = jiffies;
 		buffer_info->next_to_watch = i;
 		buffer_info->mapped_as_page = true;
-		buffer_info->dma = dma_map_page(dev,
-						frag->page,
-						frag->page_offset,
-						len,
+		buffer_info->dma = skb_frag_dma_map(dev, frag, 0, len,
 						DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, buffer_info->dma))
 			goto dma_error;
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 40ed066..27f68d3 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -2061,10 +2061,7 @@ static inline int igbvf_tx_map_adv(struct igbvf_adapter *adapter,
 		buffer_info->time_stamp = jiffies;
 		buffer_info->next_to_watch = i;
 		buffer_info->mapped_as_page = true;
-		buffer_info->dma = dma_map_page(&pdev->dev,
-						frag->page,
-						frag->page_offset,
-						len,
+		buffer_info->dma = skb_frag_dma_map(&pdev->dev, frag, 0, len,
 						DMA_TO_DEVICE);
 		if (dma_mapping_error(&pdev->dev, buffer_info->dma))
 			goto dma_error;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 6a130eb..45c4e90 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1341,7 +1341,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		offset = frag->page_offset;
+		offset = 0;
 
 		while (len) {
 			i++;
@@ -1361,8 +1361,8 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
 			buffer_info->time_stamp = jiffies;
 			buffer_info->mapped_as_page = true;
 			buffer_info->dma =
-				dma_map_page(&pdev->dev, frag->page,
-					     offset, size, DMA_TO_DEVICE);
+				skb_frag_dma_map(&pdev->dev, frag, offset, size,
+						 DMA_TO_DEVICE);
 			if (dma_mapping_error(&pdev->dev, buffer_info->dma))
 				goto dma_error;
 			buffer_info->next_to_watch = 0;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e86297b..23ae14f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6459,7 +6459,7 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = min((unsigned int)frag->size, total);
-		offset = frag->page_offset;
+		offset = 0;
 
 		while (len) {
 			i++;
@@ -6470,10 +6470,9 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 			size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
 
 			tx_buffer_info->length = size;
-			tx_buffer_info->dma = dma_map_page(dev,
-							   frag->page,
-							   offset, size,
-							   DMA_TO_DEVICE);
+			tx_buffer_info->dma =
+				skb_frag_dma_map(dev, frag, offset, size,
+					     DMA_TO_DEVICE);
 			tx_buffer_info->mapped_as_page = true;
 			if (dma_mapping_error(dev, tx_buffer_info->dma))
 				goto dma_error;
diff --git a/drivers/net/ixgbevf/ixgbevf_main.c b/drivers/net/ixgbevf/ixgbevf_main.c
index 3b880a2..0b8b7a6 100644
--- a/drivers/net/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ixgbevf/ixgbevf_main.c
@@ -2918,18 +2918,16 @@ static int ixgbevf_tx_map(struct ixgbevf_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = min((unsigned int)frag->size, total);
-		offset = frag->page_offset;
+		offset = 0;
 
 		while (len) {
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
 			size = min(len, (unsigned int)IXGBE_MAX_DATA_PER_TXD);
 
 			tx_buffer_info->length = size;
-			tx_buffer_info->dma = dma_map_page(&adapter->pdev->dev,
-							   frag->page,
-							   offset,
-							   size,
-							   DMA_TO_DEVICE);
+			tx_buffer_info->dma =
+				skb_frag_dma_map(&adapter->pdev->dev, frag,
+						 offset, size, DMA_TO_DEVICE);
 			tx_buffer_info->mapped_as_page = true;
 			if (dma_mapping_error(&pdev->dev, tx_buffer_info->dma))
 				goto dma_error;
-- 
1.7.2.5
