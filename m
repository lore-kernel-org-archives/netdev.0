From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/8] e1000: add byte queue limits
Date: Sun, 16 Sep 2012 21:15:35 -0700
Message-ID: <1347855342-6610-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Otto Estuardo Solares Cabrera <solca@galileo.edu>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44766 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750743Ab2IQEPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2012 00:15:48 -0400
In-Reply-To: <1347855342-6610-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Otto Estuardo Solares Cabrera <solca@galileo.edu>

Signed-off-by: Otto Estuardo Solares Cabrera <solca@galileo.edu>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 0ae2fcf..3a8368e 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -2014,6 +2014,7 @@ static void e1000_clean_tx_ring(struct e1000_adapter *adapter,
 		e1000_unmap_and_free_tx_resource(adapter, buffer_info);
 	}
 
+	netdev_reset_queue(adapter->netdev);
 	size = sizeof(struct e1000_buffer) * tx_ring->count;
 	memset(tx_ring->buffer_info, 0, size);
 
@@ -3262,6 +3263,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	                     nr_frags, mss);
 
 	if (count) {
+		netdev_sent_queue(netdev, skb->len);
 		skb_tx_timestamp(skb);
 
 		e1000_tx_queue(adapter, tx_ring, tx_flags, count);
@@ -3849,6 +3851,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	unsigned int i, eop;
 	unsigned int count = 0;
 	unsigned int total_tx_bytes=0, total_tx_packets=0;
+	unsigned int bytes_compl = 0, pkts_compl = 0;
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
@@ -3866,6 +3869,11 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
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
@@ -3879,6 +3887,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 
 	tx_ring->next_to_clean = i;
 
+	netdev_completed_queue(netdev, pkts_compl, bytes_compl);
+
 #define TX_WAKE_THRESHOLD 32
 	if (unlikely(count && netif_carrier_ok(netdev) &&
 		     E1000_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)) {
-- 
1.7.11.4
