From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 13/23] igb: change queue ordering for 82576 based
	adapters
Date: Wed, 28 Oct 2009 02:49:40 -0700
Message-ID: <20091028094939.13156.75956.stgit@localhost.localdomain>
References: <20091028094540.13156.2637.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:47389
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751499AbZJ1JxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 05:53:25 -0400
In-Reply-To: <20091028094540.13156.2637.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch changes the queue ordering for 82576 adapters so that if VFs are
enabled the queues will first be allocated out of the PF pool.  Any
remaining queues will be allocated out of other VMDq pools.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   25 +++++++++++++------------
 1 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index e67ff0e..52c4302 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -285,7 +285,7 @@ module_exit(igb_exit_module);
  **/
 static void igb_cache_ring_register(struct igb_adapter *adapter)
 {
-	int i;
+	int i = 0, j = 0;
 	u32 rbase_offset = adapter->vfs_allocated_count;
 
 	switch (adapter->hw.mac.type) {
@@ -295,19 +295,20 @@ static void igb_cache_ring_register(struct igb_adapter *adapter)
 		 * In order to avoid collision we start at the first free queue
 		 * and continue consuming queues in the same sequence
 		 */
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			adapter->rx_ring[i].reg_idx = rbase_offset +
-			                              Q_IDX_82576(i);
-		for (i = 0; i < adapter->num_tx_queues; i++)
-			adapter->tx_ring[i].reg_idx = rbase_offset +
-			                              Q_IDX_82576(i);
-		break;
+		if (adapter->vfs_allocated_count) {
+			for (; i < adapter->num_rx_queues; i++)
+				adapter->rx_ring[i].reg_idx = rbase_offset +
+				                              Q_IDX_82576(i);
+			for (; j < adapter->num_tx_queues; j++)
+				adapter->tx_ring[j].reg_idx = rbase_offset +
+				                              Q_IDX_82576(j);
+		}
 	case e1000_82575:
 	default:
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			adapter->rx_ring[i].reg_idx = i;
-		for (i = 0; i < adapter->num_tx_queues; i++)
-			adapter->tx_ring[i].reg_idx = i;
+		for (; i < adapter->num_rx_queues; i++)
+			adapter->rx_ring[i].reg_idx = rbase_offset + i;
+		for (; j < adapter->num_tx_queues; j++)
+			adapter->tx_ring[j].reg_idx = rbase_offset + j;
 		break;
 	}
 }

