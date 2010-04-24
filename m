From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/4] e1000e: reduce writes of RX producer ptr
Date: Fri, 23 Apr 2010 17:26:15 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1004231718260.16544@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:1971 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756257Ab0DXA0V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 20:26:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce number of writes to RX producer pointer.   When alloc'ing RX
buffers, only write the RX producer pointer once every
E1000_RX_BUFFER_WRITE (16) buffers created.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 5f70c43..4f5034a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -193,26 +193,23 @@ map_skb:
 		rx_desc = E1000_RX_DESC(*rx_ring, i);
 		rx_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
 
+		if (unlikely(!(i & (E1000_RX_BUFFER_WRITE - 1)))) {
+			/*
+			 * Force memory writes to complete before letting h/w
+			 * know there are new descriptors to fetch.  (Only
+			 * applicable for weak-ordered memory model archs,
+			 * such as IA-64).
+			 */
+			wmb();
+			writel(i, adapter->hw.hw_addr + rx_ring->tail);
+		}
 		i++;
 		if (i == rx_ring->count)
 			i = 0;
 		buffer_info = &rx_ring->buffer_info[i];
 	}
 
-	if (rx_ring->next_to_use != i) {
-		rx_ring->next_to_use = i;
-		if (i-- == 0)
-			i = (rx_ring->count - 1);
-
-		/*
-		 * Force memory writes to complete before letting h/w
-		 * know there are new descriptors to fetch.  (Only
-		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64).
-		 */
-		wmb();
-		writel(i, adapter->hw.hw_addr + rx_ring->tail);
-	}
+	rx_ring->next_to_use = i;
 }
 
 /**
@@ -293,6 +290,17 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 
 		rx_desc->read.buffer_addr[0] = cpu_to_le64(buffer_info->dma);
 
+		if (unlikely(!(i & (E1000_RX_BUFFER_WRITE - 1)))) {
+			/*
+			 * Force memory writes to complete before letting h/w
+			 * know there are new descriptors to fetch.  (Only
+			 * applicable for weak-ordered memory model archs,
+			 * such as IA-64).
+			 */
+			wmb();
+			writel(i<<1, adapter->hw.hw_addr + rx_ring->tail);
+		}
+
 		i++;
 		if (i == rx_ring->count)
 			i = 0;
@@ -300,26 +308,7 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 	}
 
 no_buffers:
-	if (rx_ring->next_to_use != i) {
-		rx_ring->next_to_use = i;
-
-		if (!(i--))
-			i = (rx_ring->count - 1);
-
-		/*
-		 * Force memory writes to complete before letting h/w
-		 * know there are new descriptors to fetch.  (Only
-		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64).
-		 */
-		wmb();
-		/*
-		 * Hardware increments by 16 bytes, but packet split
-		 * descriptors are 32 bytes...so we increment tail
-		 * twice as much.
-		 */
-		writel(i<<1, adapter->hw.hw_addr + rx_ring->tail);
-	}
+	rx_ring->next_to_use = i;
 }
 
 /**
