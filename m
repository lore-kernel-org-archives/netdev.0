From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 1/3] e1000e: retire last_tx_tso workaround
Date: Wed, 22 Aug 2007 08:08:39 -0700
Message-ID: <20070822150839.19918.86665.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com,
	akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:53577 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761199AbXHVPIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:08:44 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This TSO-related workaround is no longer needed since it's only
applicable for 8254x silicon.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/e1000.h  |   15 +++------------
 drivers/net/e1000e/netdev.c |   20 ++------------------
 2 files changed, 5 insertions(+), 30 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index e3cd877..bbe5faf 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -142,18 +142,9 @@ struct e1000_ring {
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
 
-	union {
-		/* for TX */
-		struct {
-			bool last_tx_tso; /* used to mark tso desc.  */
-		};
-		/* for RX */
-		struct {
-			/* arrays of page information for packet split */
-			struct e1000_ps_page *ps_pages;
-			struct sk_buff *rx_skb_top;
-		};
-	};
+	/* arrays of page information for packet split */
+	struct e1000_ps_page *ps_pages;
+	struct sk_buff *rx_skb_top;
 
 	struct e1000_queue_stats stats;
 };
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 8ebe238..4916f7c 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1483,7 +1483,6 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter)
 
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
-	tx_ring->last_tx_tso = 0;
 
 	writel(0, adapter->hw.hw_addr + tx_ring->head);
 	writel(0, adapter->hw.hw_addr + tx_ring->tail);
@@ -3216,15 +3215,6 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 	while (len) {
 		buffer_info = &tx_ring->buffer_info[i];
 		size = min(len, max_per_txd);
-		/* Workaround for Controller erratum --
-		 * descriptor for non-tso packet in a linear SKB that follows a
-		 * tso gets written back prematurely before the data is fully
-		 * DMA'd to the controller */
-		if (tx_ring->last_tx_tso && !skb_is_gso(skb)) {
-			tx_ring->last_tx_tso = 0;
-			if (!skb->data_len)
-				size -= 4;
-		}
 
 		/* Workaround for premature desc write-backs
 		 * in TSO mode.  Append 4-byte sentinel desc */
@@ -3497,10 +3487,6 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		count++;
 	count++;
 
-	/* Controller Erratum workaround */
-	if (!skb->data_len && tx_ring->last_tx_tso && !skb_is_gso(skb))
-		count++;
-
 	count += TXD_USE_COUNT(len, max_txd_pwr);
 
 	nr_frags = skb_shinfo(skb)->nr_frags;
@@ -3536,12 +3522,10 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_OK;
 	}
 
-	if (tso) {
-		tx_ring->last_tx_tso = 1;
+	if (tso)
 		tx_flags |= E1000_TX_FLAGS_TSO;
-	} else if (e1000_tx_csum(adapter, skb)) {
+	else if (e1000_tx_csum(adapter, skb))
 		tx_flags |= E1000_TX_FLAGS_CSUM;
-	}
 
 	/* Old method was to assume IPv4 packet by default if TSO was enabled.
 	 * 82571 hardware supports TSO capabilities for IPv6 as well...
