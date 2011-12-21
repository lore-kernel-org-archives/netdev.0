From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] igb: Add support for byte queue limits.
Date: Wed, 21 Dec 2011 16:18:15 +0100
Message-ID: <1324480695.2301.4.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:45574 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753226Ab1LUPST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 10:18:19 -0500
Received: by werm1 with SMTP id m1so2736815wer.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 07:18:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for byte queue limits (BQL)

Since this driver collects bytes count in 'bytecount' field, use it also
in igb_tx_map()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |    5 +++++
 drivers/net/ethernet/intel/igb/igb_main.c |    5 +++++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index c69feeb..3d12e67 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -447,4 +447,9 @@ static inline s32 igb_get_phy_info(struct e1000_hw *hw)
 	return 0;
 }
 
+static inline struct netdev_queue *txring_txq(const struct igb_ring *tx_ring)
+{
+	return netdev_get_tx_queue(tx_ring->netdev, tx_ring->queue_index);
+}
+
 #endif /* _IGB_H_ */
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 89d576c..dcc68cc 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3201,6 +3201,7 @@ static void igb_clean_tx_ring(struct igb_ring *tx_ring)
 		buffer_info = &tx_ring->tx_buffer_info[i];
 		igb_unmap_and_free_tx_resource(tx_ring, buffer_info);
 	}
+	netdev_tx_reset_queue(txring_txq(tx_ring));
 
 	size = sizeof(struct igb_tx_buffer) * tx_ring->count;
 	memset(tx_ring->tx_buffer_info, 0, size);
@@ -4238,6 +4239,8 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 		frag++;
 	}
 
+	netdev_tx_sent_queue(txring_txq(tx_ring), first->bytecount);
+
 	/* write last descriptor with RS and EOP bits */
 	cmd_type |= cpu_to_le32(size) | cpu_to_le32(IGB_TXD_DCMD);
 	tx_desc->read.cmd_type_len = cmd_type;
@@ -5777,6 +5780,8 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 		}
 	}
 
+	netdev_tx_completed_queue(txring_txq(tx_ring),
+				  total_packets, total_bytes);
 	i += tx_ring->count;
 	tx_ring->next_to_clean = i;
 	u64_stats_update_begin(&tx_ring->tx_syncp);
