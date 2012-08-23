From: Otto Estuardo Solares Cabrera <solca@galileo.edu>
Subject: [PATCH] e1000: add byte queue limits
Date: Thu, 23 Aug 2012 03:28:18 -0600
Message-ID: <1345714098-2644-1-git-send-email-solca@galileo.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.galileo.edu ([200.9.255.17]:10438 "EHLO mail.galileo.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758294Ab2HWJdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 05:33:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Otto Estuardo Solares Cabrera <solca@galileo.edu>
---
 Copied from e1000e.
 Cc me please.

 drivers/net/ethernet/intel/e1000/e1000_main.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 7483ca0..208bc78 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2016,6 +2016,7 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
 		e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 	}
 
+	netdev_reset_queue(adapter->netdev);
 	size = sizeof(struct e1000_buffer) * tx_ring->count;
 	memset(tx_ring->buffer_info, 0, size);
 
@@ -3265,6 +3266,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	                     nr_frags, mss);
 
 	if (count) {
+		netdev_sent_queue(netdev, skb->len);
 		skb_tx_timestamp(skb);
 
 		e1000_tx_queue(adapter, tx_ring, tx_flags, count);
@@ -3852,6 +3854,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	unsigned int i, eop;
 	unsigned int count = 0;
 	unsigned int total_tx_bytes=0, total_tx_packets=0;
+	unsigned int bytes_compl = 0, pkts_compl = 0;
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
@@ -3869,6 +3872,11 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 			if (cleaned) {
 				total_tx_packets += buffer_info->segs;
 				total_tx_bytes += buffer_info->bytecount;
+				if (buffer_info->skb) {
+					bytes_compl += buffer_info->skb->len;
+					pkts_compl++;
+				}
+
 			}
 			e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 			tx_desc->upper.data = 0;
@@ -3882,6 +3890,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 
 	tx_ring->next_to_clean = i;
 
+	netdev_completed_queue(netdev, pkts_compl, bytes_compl);
+
 #define TX_WAKE_THRESHOLD 32
 	if (unlikely(count && netif_carrier_ok(netdev) &&
 		     E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)) {
-- 
1.7.10.4
