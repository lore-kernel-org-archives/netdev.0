From: Tom Herbert <therbert@google.com>
Subject: [RFC PATCH v2 5/9] e1000e: Support for byte queue limits
Date: Sun, 7 Aug 2011 21:49:35 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1108072146530.14333@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:13042 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab1HHEtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 00:49:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes to e1000e to use byte queue limits.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/e1000e/netdev.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4353ad5..4ce114c 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -998,6 +998,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 	unsigned int i, eop;
 	unsigned int count = 0;
 	unsigned int total_tx_bytes = 0, total_tx_packets = 0;
+	unsigned int bytes_compl = 0, pkts_compl = 0;
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
@@ -1015,6 +1016,11 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 			if (cleaned) {
 				total_tx_packets += buffer_info->segs;
 				total_tx_bytes += buffer_info->bytecount;
+				if (buffer_info->skb) {
+					bytes_compl += buffer_info->skb->len;
+					pkts_compl++;
+				}
+
 			}
 
 			e1000_put_txbuf(adapter, buffer_info);
@@ -1033,6 +1039,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter)
 
 	tx_ring->next_to_clean = i;
 
+	netdev_completed_queue(netdev, pkts_compl, bytes_compl);
+
 #define TX_WAKE_THRESHOLD 32
 	if (count && netif_carrier_ok(netdev) &&
 	    e1000_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD) {
@@ -2164,6 +2172,7 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter)
 		e1000_put_txbuf(adapter, buffer_info);
 	}
 
+	netdev_reset_queue(adapter->netdev);
 	size = sizeof(struct e1000_buffer) * tx_ring->count;
 	memset(tx_ring->buffer_info, 0, size);
 
@@ -4882,6 +4891,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	/* if count is 0 then mapping error has occurred */
 	count = e1000_tx_map(adapter, skb, first, max_per_txd, nr_frags, mss);
 	if (count) {
+		netdev_sent_queue(netdev, 1, skb->len);
 		e1000_tx_queue(adapter, tx_flags, count);
 		/* Make sure there is space in the ring for the next send. */
 		e1000_maybe_stop_tx(netdev, MAX_SKB_FRAGS + 2);
-- 
1.7.3.1

