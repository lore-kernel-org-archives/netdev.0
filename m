From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 09/23] igb: only process global stats in
	igb_update_stats
Date: Wed, 28 Oct 2009 02:48:12 -0700
Message-ID: <20091028094811.13156.36154.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:46798
	"EHLO QMTA13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752943AbZJ1Jv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:51:56 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch moves the update of adapter->net_stats.rx/tx values out of the
interrupt routine and into igb_update_stats by just adding together the
tx/rx byte/packet counts for the rings.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   61 +++++++++++++++++++++-----------------------
 1 files changed, 29 insertions(+), 32 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 54e8f02..62b6876 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3769,7 +3769,10 @@ void igb_update_stats(struct igb_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct e1000_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
+	u32 rnbc;
 	u16 phy_tmp;
+	int i;
+	u64 bytes, packets;
 
 #define PHY_IDLE_ERROR_COUNT_MASK 0x00FF
 
@@ -3782,6 +3785,29 @@ void igb_update_stats(struct igb_adapter *adapter)
 	if (pci_channel_offline(pdev))
 		return;
 
+	bytes = 0;
+	packets = 0;
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		u32 rqdpc_tmp = rd32(E1000_RQDPC(i)) & 0x0FFF;
+		adapter->rx_ring[i].rx_stats.drops += rqdpc_tmp;
+		netdev->stats.rx_fifo_errors += rqdpc_tmp;
+		bytes += adapter->rx_ring[i].rx_stats.bytes;
+		packets += adapter->rx_ring[i].rx_stats.packets;
+	}
+
+	netdev->stats.rx_bytes = bytes;
+	netdev->stats.rx_packets = packets;
+
+	bytes = 0;
+	packets = 0;
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		bytes += adapter->tx_ring[i].tx_stats.bytes;
+		packets += adapter->tx_ring[i].tx_stats.packets;
+	}
+	netdev->stats.tx_bytes = bytes;
+	netdev->stats.tx_packets = packets;
+
+	/* read stats registers */
 	adapter->stats.crcerrs += rd32(E1000_CRCERRS);
 	adapter->stats.gprc += rd32(E1000_GPRC);
 	adapter->stats.gorc += rd32(E1000_GORCL);
@@ -3814,7 +3840,9 @@ void igb_update_stats(struct igb_adapter *adapter)
 	adapter->stats.gptc += rd32(E1000_GPTC);
 	adapter->stats.gotc += rd32(E1000_GOTCL);
 	rd32(E1000_GOTCH); /* clear GOTCL */
-	adapter->stats.rnbc += rd32(E1000_RNBC);
+	rnbc = rd32(E1000_RNBC);
+	adapter->stats.rnbc += rnbc;
+	netdev->stats.rx_fifo_errors += rnbc;
 	adapter->stats.ruc += rd32(E1000_RUC);
 	adapter->stats.rfc += rd32(E1000_RFC);
 	adapter->stats.rjc += rd32(E1000_RJC);
@@ -3861,33 +3889,6 @@ void igb_update_stats(struct igb_adapter *adapter)
 
 	/* Rx Errors */
 
-	if (hw->mac.type != e1000_82575) {
-		u32 rqdpc_tmp;
-		u64 rqdpc_total = 0;
-		int i;
-		/* Read out drops stats per RX queue.  Notice RQDPC (Receive
-		 * Queue Drop Packet Count) stats only gets incremented, if
-		 * the DROP_EN but it set (in the SRRCTL register for that
-		 * queue).  If DROP_EN bit is NOT set, then the some what
-		 * equivalent count is stored in RNBC (not per queue basis).
-		 * Also note the drop count is due to lack of available
-		 * descriptors.
-		 */
-		for (i = 0; i < adapter->num_rx_queues; i++) {
-			rqdpc_tmp = rd32(E1000_RQDPC(i)) & 0xFFF;
-			adapter->rx_ring[i].rx_stats.drops += rqdpc_tmp;
-			rqdpc_total += adapter->rx_ring[i].rx_stats.drops;
-		}
-		netdev->stats.rx_fifo_errors = rqdpc_total;
-	}
-
-	/* Note RNBC (Receive No Buffers Count) is an not an exact
-	 * drop count as the hardware FIFO might save the day.  Thats
-	 * one of the reason for saving it in rx_fifo_errors, as its
-	 * potentially not a true drop.
-	 */
-	netdev->stats.rx_fifo_errors += adapter->stats.rnbc;
-
 	/* RLEC on some newer hardware can be incorrect so build
 	 * our own version based on RUC and ROC */
 	netdev->stats.rx_errors = adapter->stats.rxerrc +
@@ -4818,8 +4819,6 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 	tx_ring->total_packets += total_packets;
 	tx_ring->tx_stats.bytes += total_bytes;
 	tx_ring->tx_stats.packets += total_packets;
-	netdev->stats.tx_bytes += total_bytes;
-	netdev->stats.tx_packets += total_packets;
 	return (count < tx_ring->count);
 }
 
@@ -5043,8 +5042,6 @@ next_desc:
 	rx_ring->total_bytes += total_bytes;
 	rx_ring->rx_stats.packets += total_packets;
 	rx_ring->rx_stats.bytes += total_bytes;
-	netdev->stats.rx_bytes += total_bytes;
-	netdev->stats.rx_packets += total_packets;
 	return cleaned;
 }
 

