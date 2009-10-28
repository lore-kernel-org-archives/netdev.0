From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 06/20] igb: move SRRCTL register configuration
	into ring specific config
Date: Tue, 27 Oct 2009 18:51:07 -0700
Message-ID: <20091028015107.12470.34779.stgit@localhost.localdomain>
References: <20091028014858.12470.99520.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:36359
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757182AbZJ1Byu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 21:54:50 -0400
In-Reply-To: <20091028014858.12470.99520.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The SRRCTL register exists per ring.  Instead of configuring all of them in
the RCTL configuration which is meant to be global it makes more sense to move
this out into the ring specific configuration.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   60 +++++++++++++++++---------------------------
 1 files changed, 23 insertions(+), 37 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 24e502d..dfca821 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2230,8 +2230,6 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl;
-	u32 srrctl = 0;
-	int i;
 
 	rctl = rd32(E1000_RCTL);
 
@@ -2256,31 +2254,8 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	/* enable LPE to prevent packets larger than max_frame_size */
 	rctl |= E1000_RCTL_LPE;
 
-	/* 82575 and greater support packet-split where the protocol
-	 * header is placed in skb->data and the packet data is
-	 * placed in pages hanging off of skb_shinfo(skb)->nr_frags.
-	 * In the case of a non-split, skb->data is linearly filled,
-	 * followed by the page buffers.  Therefore, skb->data is
-	 * sized to hold the largest protocol header.
-	 */
-	/* allocations using alloc_page take too long for regular MTU
-	 * so only enable packet split for jumbo frames */
-	if (adapter->rx_buffer_len < IGB_RXBUFFER_1024) {
-		srrctl = ALIGN(adapter->rx_buffer_len, 64) <<
-		         E1000_SRRCTL_BSIZEHDRSIZE_SHIFT;
-#if (PAGE_SIZE / 2) > IGB_RXBUFFER_16384
-		srrctl |= IGB_RXBUFFER_16384 >>
-		          E1000_SRRCTL_BSIZEPKT_SHIFT;
-#else
-		srrctl |= (PAGE_SIZE / 2) >>
-		          E1000_SRRCTL_BSIZEPKT_SHIFT;
-#endif
-		srrctl |= E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
-	} else {
-		srrctl = ALIGN(adapter->rx_buffer_len, 1024) >>
-		         E1000_SRRCTL_BSIZEPKT_SHIFT;
-		srrctl |= E1000_SRRCTL_DESCTYPE_ADV_ONEBUF;
-	}
+	/* disable queue 0 to prevent tail write w/o re-config */
+	wr32(E1000_RXDCTL(0), 0);
 
 	/* Attention!!!  For SR-IOV PF driver operations you must enable
 	 * queue drop for all VF and PF queues to prevent head of line blocking
@@ -2291,10 +2266,6 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 
 		/* set all queue drop enable bits */
 		wr32(E1000_QDE, ALL_QUEUES);
-		srrctl |= E1000_SRRCTL_DROP_EN;
-
-		/* disable queue 0 to prevent tail write w/o re-config */
-		wr32(E1000_RXDCTL(0), 0);
 
 		vmolr = rd32(E1000_VMOLR(adapter->vfs_allocated_count));
 		if (rctl & E1000_RCTL_LPE)
@@ -2304,11 +2275,6 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 		wr32(E1000_VMOLR(adapter->vfs_allocated_count), vmolr);
 	}
 
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		int j = adapter->rx_ring[i].reg_idx;
-		wr32(E1000_SRRCTL(j), srrctl);
-	}
-
 	wr32(E1000_RCTL, rctl);
 }
 
@@ -2373,7 +2339,7 @@ static void igb_configure_rx_ring(struct igb_adapter *adapter,
 	struct e1000_hw *hw = &adapter->hw;
 	u64 rdba = ring->dma;
 	int reg_idx = ring->reg_idx;
-	u32 rxdctl;
+	u32 srrctl, rxdctl;
 
 	/* disable the queue */
 	rxdctl = rd32(E1000_RXDCTL(reg_idx));
@@ -2393,6 +2359,26 @@ static void igb_configure_rx_ring(struct igb_adapter *adapter,
 	writel(0, hw->hw_addr + ring->head);
 	writel(0, hw->hw_addr + ring->tail);
 
+	/* set descriptor configuration */
+	if (adapter->rx_buffer_len < IGB_RXBUFFER_1024) {
+		srrctl = ALIGN(adapter->rx_buffer_len, 64) <<
+		         E1000_SRRCTL_BSIZEHDRSIZE_SHIFT;
+#if (PAGE_SIZE / 2) > IGB_RXBUFFER_16384
+		srrctl |= IGB_RXBUFFER_16384 >>
+		          E1000_SRRCTL_BSIZEPKT_SHIFT;
+#else
+		srrctl |= (PAGE_SIZE / 2) >>
+		          E1000_SRRCTL_BSIZEPKT_SHIFT;
+#endif
+		srrctl |= E1000_SRRCTL_DESCTYPE_HDR_SPLIT_ALWAYS;
+	} else {
+		srrctl = ALIGN(adapter->rx_buffer_len, 1024) >>
+		         E1000_SRRCTL_BSIZEPKT_SHIFT;
+		srrctl |= E1000_SRRCTL_DESCTYPE_ADV_ONEBUF;
+	}
+
+	wr32(E1000_SRRCTL(reg_idx), srrctl);
+
 	/* enable receive descriptor fetching */
 	rxdctl = rd32(E1000_RXDCTL(reg_idx));
 	rxdctl |= E1000_RXDCTL_QUEUE_ENABLE;

