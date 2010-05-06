From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/4] e1000e: reduce writes of RX producer ptr
Date: Wed, 05 May 2010 17:02:49 -0700
Message-ID: <20100506000247.8042.97827.stgit@localhost.localdomain>
References: <20100506000221.8042.64794.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Tom Herbert <therbert@google.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:52733 "EHLO
	qmta03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752412Ab0EFADI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 20:03:08 -0400
In-Reply-To: <20100506000221.8042.64794.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>

Reduce number of writes to RX producer pointer.   When alloc'ing RX
buffers, only write the RX producer pointer once every
E1000_RX_BUFFER_WRITE (16) buffers created.

Signed-off-by: Tom Herbert <therbert@google.com>
Acked-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   57 +++++++++++++++++--------------------------
 1 files changed, 23 insertions(+), 34 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 1eb9b59..b767dbb 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -548,26 +548,23 @@ map_skb:
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
@@ -649,6 +646,17 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 
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
@@ -656,26 +664,7 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
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

