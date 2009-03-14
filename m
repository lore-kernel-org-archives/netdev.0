From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 06/11] ixgbe: Fix the Tx clean logic to return proper
	status
Date: Sat, 14 Mar 2009 01:14:10 -0700
Message-ID: <20090314081409.4687.50170.stgit@lost.foo-projects.org>
References: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:33436
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755134AbZCNIOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 04:14:32 -0400
In-Reply-To: <20090314081229.4687.40245.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The Tx accounting when cleaning during NAPI was not completely properly.
We should use the work_limit to determine when to finish cleaning, and
use the same to return the cleaned status.  The impact of running like this
causes the NAPI clean for this Tx to get stuck in a scheduling loop, and
can result in Tx not getting cleaned, ending with a Tx hang and device
reset.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   19 ++++++++++---------
 1 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 4a2a769..c4e5fd3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -251,6 +251,8 @@ static void ixgbe_tx_timeout(struct net_device *netdev);
  * ixgbe_clean_tx_irq - Reclaim resources after transmit completes
  * @adapter: board private structure
  * @tx_ring: tx ring to clean
+ *
+ * returns true if transmit work is done
  **/
 static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
                                struct ixgbe_ring *tx_ring)
@@ -266,7 +268,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 	eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
 
 	while ((eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) &&
-	       (count < tx_ring->count)) {
+	       (count < tx_ring->work_limit)) {
 		bool cleaned = false;
 		for ( ; !cleaned; count++) {
 			struct sk_buff *skb;
@@ -328,8 +330,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 	}
 
 	/* re-arm the interrupt */
-	if ((total_packets >= tx_ring->work_limit) ||
-	    (count == tx_ring->count))
+	if (count >= tx_ring->work_limit)
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, tx_ring->v_idx);
 
 	tx_ring->total_bytes += total_bytes;
@@ -338,7 +339,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 	tx_ring->stats.bytes += total_bytes;
 	adapter->net_stats.tx_bytes += total_bytes;
 	adapter->net_stats.tx_packets += total_packets;
-	return (total_packets ? true : false);
+	return (count < tx_ring->work_limit);
 }
 
 #ifdef CONFIG_IXGBE_DCA
@@ -2590,10 +2591,10 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
  **/
 static int ixgbe_poll(struct napi_struct *napi, int budget)
 {
-	struct ixgbe_q_vector *q_vector = container_of(napi,
-	                                          struct ixgbe_q_vector, napi);
+	struct ixgbe_q_vector *q_vector =
+	                        container_of(napi, struct ixgbe_q_vector, napi);
 	struct ixgbe_adapter *adapter = q_vector->adapter;
-	int tx_cleaned, work_done = 0;
+	int tx_clean_complete, work_done = 0;
 
 #ifdef CONFIG_IXGBE_DCA
 	if (adapter->flags & IXGBE_FLAG_DCA_ENABLED) {
@@ -2602,10 +2603,10 @@ static int ixgbe_poll(struct napi_struct *napi, int budget)
 	}
 #endif
 
-	tx_cleaned = ixgbe_clean_tx_irq(adapter, adapter->tx_ring);
+	tx_clean_complete = ixgbe_clean_tx_irq(adapter, adapter->tx_ring);
 	ixgbe_clean_rx_irq(q_vector, adapter->rx_ring, &work_done, budget);
 
-	if (tx_cleaned)
+	if (!tx_clean_complete)
 		work_done = budget;
 
 	/* If budget not fully consumed, exit the polling mode */

