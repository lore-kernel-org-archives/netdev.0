From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 2/2] ixgbe: Add functionality for delaying the MMIO write
	for Tx
Date: Wed, 11 Jul 2012 17:26:08 -0700
Message-ID: <20120712002608.27846.31038.stgit@gitlad.jf.intel.com>
References: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	edumazet@google.com, bhutchings@solarflare.com,
	therbert@google.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50284 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758484Ab2GLAZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jul 2012 20:25:47 -0400
In-Reply-To: <20120712002103.27846.73812.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that ixgbe can use the new framework for delaying
the MMIO writes in the transmit path.  With this change in place we see a
significant reduction in CPU utilization and increase in overall packets
per second throughput for bulk traffic tests.  In addition I have not seen
any increase in latency as a result of this patch.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   22 ++++++++++++++++++++--
 1 files changed, 20 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9ec65ee..e9b71b8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -884,6 +884,8 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		return true;
 	}
 
+	netif_tx_dispatch_queue(txring_txq(tx_ring));
+
 	netdev_tx_completed_queue(txring_txq(tx_ring),
 				  total_packets, total_bytes);
 
@@ -5825,6 +5827,22 @@ static void ixgbe_service_task(struct work_struct *work)
 	ixgbe_service_event_complete(adapter);
 }
 
+static void ixgbe_complete_xmit_frame(struct net_device *dev,
+				      unsigned int index)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	struct ixgbe_ring *tx_ring = adapter->tx_ring[index];
+
+	/* notify HW of packet */
+	writel(tx_ring->next_to_use, tx_ring->tail);
+
+	/*
+	 * we need this if more than one processor can write to our tail
+	 * at a time, it synchronizes IO on IA64/Altix systems
+	 */
+	mmiowb();
+}
+
 static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 		     struct ixgbe_tx_buffer *first,
 		     u8 *hdr_len)
@@ -6150,8 +6168,7 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 
 	tx_ring->next_to_use = i;
 
-	/* notify HW of packet */
-	writel(i, tx_ring->tail);
+	netdev_complete_xmit(txring_txq(tx_ring));
 
 	return;
 dma_error:
@@ -6961,6 +6978,7 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
 	.ndo_start_xmit		= ixgbe_xmit_frame,
+	.ndo_complete_xmit	= ixgbe_complete_xmit_frame,
 #ifdef IXGBE_FCOE
 	.ndo_select_queue	= ixgbe_select_queue,
 #endif
