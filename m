From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 02/20] ixgbe: remove redundant DMA alignment code
Date: Thu, 19 Aug 2010 16:33:41 -0700
Message-ID: <20100819233339.10335.17698.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:33304
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750914Ab0HSXeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:34:02 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch removes the redundant DMA alignment code from the Rx buffer
allocation path.  This code is no longer necessary since all x86 buffers
are now DMA aligned due to recent changes to NET_IP_ALIGN and NET_SKB_PAD.

It also moves the setting of the Rx queue value into the allocation path
since it is more likely that the queue mapping will still be in the cache
at the time of allocation.
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e32af43..5dceaf3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -955,7 +955,6 @@ static void ixgbe_receive_skb(struct ixgbe_q_vector *q_vector,
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
-	skb_record_rx_queue(skb, ring->queue_index);
 	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
 		if (adapter->vlgrp && is_vlan && (tag & VLAN_VID_MASK))
 			vlan_gro_receive(napi, adapter->vlgrp, tag, skb);
@@ -1037,10 +1036,12 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
                                    struct ixgbe_ring *rx_ring,
                                    int cleaned_count)
 {
+	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 	union ixgbe_adv_rx_desc *rx_desc;
 	struct ixgbe_rx_buffer *bi;
 	unsigned int i;
+	unsigned int bufsz = rx_ring->rx_buf_len;
 
 	i = rx_ring->next_to_use;
 	bi = &rx_ring->rx_buffer_info[i];
@@ -1051,7 +1052,7 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 		if (!bi->page_dma &&
 		    (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED)) {
 			if (!bi->page) {
-				bi->page = alloc_page(GFP_ATOMIC);
+				bi->page = netdev_alloc_page(netdev);
 				if (!bi->page) {
 					adapter->alloc_rx_page_failed++;
 					goto no_buffers;
@@ -1069,22 +1070,21 @@ static void ixgbe_alloc_rx_buffers(struct ixgbe_adapter *adapter,
 		}
 
 		if (!bi->skb) {
-			struct sk_buff *skb;
-			/* netdev_alloc_skb reserves 32 bytes up front!! */
-			uint bufsz = rx_ring->rx_buf_len + SMP_CACHE_BYTES;
-			skb = netdev_alloc_skb(adapter->netdev, bufsz);
+			struct sk_buff *skb = netdev_alloc_skb_ip_align(netdev,
+									bufsz);
+			bi->skb = skb;
 
 			if (!skb) {
 				adapter->alloc_rx_buff_failed++;
 				goto no_buffers;
 			}
+			/* initialize queue mapping */
+			skb_record_rx_queue(skb, rx_ring->queue_index);
+		}
 
-			/* advance the data pointer to the next cache line */
-			skb_reserve(skb, (PTR_ALIGN(skb->data, SMP_CACHE_BYTES)
-			                  - skb->data));
-
-			bi->skb = skb;
-			bi->dma = dma_map_single(&pdev->dev, skb->data,
+		if (!bi->dma) {
+			bi->dma = dma_map_single(&pdev->dev,
+						 bi->skb->data,
 			                         rx_ring->rx_buf_len,
 						 DMA_FROM_DEVICE);
 		}

