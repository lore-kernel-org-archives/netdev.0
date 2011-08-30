From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 10/14] intel: convert to SKB paged frag API.
Date: Tue, 30 Aug 2011 10:18:26 +0100
Message-ID: <1314695910-22344-10-git-send-email-ian.campbell@citrix.com>
References: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: netdev@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1314695847.10283.102.camel@zakaz.uk.xensource.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
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
---
 drivers/net/ethernet/intel/e1000/e1000_main.c     |   16 +++++++++-------
 drivers/net/ethernet/intel/e1000e/netdev.c        |    7 +++----
 drivers/net/ethernet/intel/igb/igb_main.c         |    5 +----
 drivers/net/ethernet/intel/igbvf/netdev.c         |    5 +----
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       |    6 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    3 +--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   10 ++++------
 7 files changed, 22 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 4a32c15..27f586a 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2911,9 +2911,10 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		offset = frag->page_offset;
+		offset = 0;
 
 		while (len) {
+			unsigned long bufend;
 			i++;
 			if (unlikely(i == tx_ring->count))
 				i = 0;
@@ -2927,18 +2928,19 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
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
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 9742bc6..b585383 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4677,7 +4677,7 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
-		offset = frag->page_offset;
+		offset = 0;
 
 		while (len) {
 			i++;
@@ -4690,9 +4690,8 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
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
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 8016084..3cb1bc9 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4174,10 +4174,7 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
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
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index a6bdb3c..b3d760b 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
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
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index b8ef2c0..c8b9c90 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
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
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e8aad76..7dba3ab 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6562,8 +6562,7 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 		offset = 0;
 		tx_flags |= IXGBE_TX_FLAGS_MAPPED_AS_PAGE;
 
-		dma = dma_map_page(dev, frag->page, frag->page_offset,
-				   size, DMA_TO_DEVICE);
+		dma = skb_frag_dma_map(dev, frag, 0, size, DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, dma))
 			goto dma_error;
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index b1e1c2d..3bc38e1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2919,18 +2919,16 @@ static int ixgbevf_tx_map(struct ixgbevf_adapter *adapter,
 
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


------------------------------------------------------------------------------
Special Offer -- Download ArcSight Logger for FREE!
Finally, a world-class log management solution at an even better 
price-free! And you'll get a free "Love Thy Logs" t-shirt when you
download Logger. Secure your free ArcSight Logger TODAY!
http://p.sf.net/sfu/arcsisghtdev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
