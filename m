From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/14] igb: fix ethtool offline test
Date: Mon, 12 Mar 2012 21:03:39 -0700
Message-ID: <1331611432-30109-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43936 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750912Ab2CMEDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2012 00:03:55 -0400
In-Reply-To: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bug was introduced with the following patch:

  Commmit bdbc063129e811264cd6c311d8c2d9b95de01231
  Author: Eric Dumazet <eric.dumazet@gmail.com>
  igb: Add support for byte queue limits.

The ethtool offline tests will cause a perpetual link flap, this
is because the tests also need to account for byte queue limits (BQL).

CC: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Tested-by:  Jeff Pieper  <jeffrey.e.pieper@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index aa399a8..e10821a 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1577,7 +1577,9 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 	union e1000_adv_rx_desc *rx_desc;
 	struct igb_rx_buffer *rx_buffer_info;
 	struct igb_tx_buffer *tx_buffer_info;
+	struct netdev_queue *txq;
 	u16 rx_ntc, tx_ntc, count = 0;
+	unsigned int total_bytes = 0, total_packets = 0;
 
 	/* initialize next to clean and descriptor values */
 	rx_ntc = rx_ring->next_to_clean;
@@ -1601,6 +1603,8 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 
 		/* unmap buffer on tx side */
 		tx_buffer_info = &tx_ring->tx_buffer_info[tx_ntc];
+		total_bytes += tx_buffer_info->bytecount;
+		total_packets += tx_buffer_info->gso_segs;
 		igb_unmap_and_free_tx_resource(tx_ring, tx_buffer_info);
 
 		/* increment rx/tx next to clean counters */
@@ -1615,6 +1619,9 @@ static int igb_clean_test_rings(struct igb_ring *rx_ring,
 		rx_desc = IGB_RX_DESC(rx_ring, rx_ntc);
 	}
 
+	txq = netdev_get_tx_queue(tx_ring->netdev, tx_ring->queue_index);
+	netdev_tx_completed_queue(txq, total_packets, total_bytes);
+
 	/* re-map buffers to ring, store next to clean values */
 	igb_alloc_rx_buffers(rx_ring, count);
 	rx_ring->next_to_clean = rx_ntc;
-- 
1.7.7.6
