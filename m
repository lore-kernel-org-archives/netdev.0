From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/3] e1000: cleanup clean_tx_irq routine so that it
	completely cleans ring
Date: Thu, 26 Mar 2009 00:59:04 -0700
Message-ID: <20090326075904.30121.89432.stgit@lost.foo-projects.org>
References: <20090326075844.30121.48999.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:59483
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752102AbZCZH7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 03:59:23 -0400
In-Reply-To: <20090326075844.30121.48999.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The tx cleanup routine was stopping after 64 packets and this was causing
issues resulting in the ring not being completely cleaned.

This change updates the driver to clean the entire ring and if it doesn't
it then will retry on the next pass.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   21 +++++++++------------
 1 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index e60faab..5c61b92 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3769,7 +3769,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	adapter->clean_rx(adapter, &adapter->rx_ring[0],
 	                  &work_done, budget);
 
-	if (tx_cleaned)
+	if (!tx_cleaned)
 		work_done = budget;
 
 	/* If budget not fully consumed, exit the polling mode */
@@ -3796,15 +3796,16 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	struct e1000_buffer *buffer_info;
 	unsigned int i, eop;
 	unsigned int count = 0;
-	bool cleaned = false;
+	bool cleaned;
 	unsigned int total_tx_bytes=0, total_tx_packets=0;
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
 	eop_desc = E1000_TX_DESC(*tx_ring, eop);
 
-	while (eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) {
-		for (cleaned = false; !cleaned; ) {
+	while ((eop_desc->upper.data & cpu_to_le32(E1000_TXD_STAT_DD)) &&
+	       (count < tx_ring->count)) {
+		for (cleaned = false; !cleaned; count++) {
 			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 			cleaned = (i == eop);
@@ -3827,10 +3828,6 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 
 		eop = tx_ring->buffer_info[i].next_to_watch;
 		eop_desc = E1000_TX_DESC(*tx_ring, eop);
-#define E1000_TX_WEIGHT 64
-		/* weight of a sort for tx, to avoid endless transmit cleanup */
-		if (count++ == E1000_TX_WEIGHT)
-			break;
 	}
 
 	tx_ring->next_to_clean = i;
@@ -3852,8 +3849,8 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 		/* Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i */
 		adapter->detect_tx_hung = false;
-		if (tx_ring->buffer_info[eop].time_stamp &&
-		    time_after(jiffies, tx_ring->buffer_info[eop].time_stamp +
+		if (tx_ring->buffer_info[i].time_stamp &&
+		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp +
 		               (adapter->tx_timeout_factor * HZ))
 		    && !(er32(STATUS) & E1000_STATUS_TXOFF)) {
 
@@ -3875,7 +3872,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 				readl(hw->hw_addr + tx_ring->tdt),
 				tx_ring->next_to_use,
 				tx_ring->next_to_clean,
-				tx_ring->buffer_info[eop].time_stamp,
+				tx_ring->buffer_info[i].time_stamp,
 				eop,
 				jiffies,
 				eop_desc->upper.fields.status);
@@ -3886,7 +3883,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	adapter->total_tx_packets += total_tx_packets;
 	adapter->net_stats.tx_bytes += total_tx_bytes;
 	adapter->net_stats.tx_packets += total_tx_packets;
-	return cleaned;
+	return (count < tx_ring->count);
 }
 
 /**

