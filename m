From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ixgbe: refactor ixgbe_alloc_queues()
Date: Fri, 29 Oct 2010 05:45:33 +0200
Message-ID: <1288323933.2711.43.camel@edumazet-laptop>
References: <1286799439.2737.21.camel@edumazet-laptop>
	 <EA929A9653AAE14F841771FB1DE5A136602807B460@rrsmsx501.amr.corp.intel.com>
	 <1288239858.2658.72.camel@edumazet-laptop>
	 <1288267354.2649.369.camel@edumazet-laptop>
	 <1288268493.27890.5.camel@jtkirshe-MOBL1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Brattain, Ross B" <ross.b.brattain@intel.com>,
	netdev <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62250 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755079Ab0J2Dpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 23:45:39 -0400
Received: by wyf28 with SMTP id 28so2680308wyf.19
        for <netdev@vger.kernel.org>; Thu, 28 Oct 2010 20:45:38 -0700 (PDT)
In-Reply-To: <1288268493.27890.5.camel@jtkirshe-MOBL1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note : compiled only patch, not tested.

Thanks !

[PATCH] ixgbe: refactor ixgbe_alloc_queues()

I noticed ring variable was initialized before allocations, and that
memory node management was a bit ugly. We also leak memory in case of
ring allocations error.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   69 ++++++++++++-------------------
 1 file changed, 28 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 2bd3eb4..e89da9a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4470,65 +4470,52 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
  **/
 static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 {
-	int i;
-	int orig_node = adapter->node;
+	int rx = 0, tx = 0, nid = adapter->node;
 
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		struct ixgbe_ring *ring = adapter->tx_ring[i];
-		if (orig_node == -1) {
-			int cur_node = next_online_node(adapter->node);
-			if (cur_node == MAX_NUMNODES)
-				cur_node = first_online_node;
-			adapter->node = cur_node;
-		}
-		ring = kzalloc_node(sizeof(struct ixgbe_ring), GFP_KERNEL,
-				    adapter->node);
+	if (nid < 0 || !node_online(nid))
+		nid = first_online_node;
+
+	for (; tx < adapter->num_tx_queues; tx++) {
+		struct ixgbe_ring *ring;
+
+		ring = kzalloc_node(sizeof(*ring), GFP_KERNEL, nid);
 		if (!ring)
-			ring = kzalloc(sizeof(struct ixgbe_ring), GFP_KERNEL);
+			ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 		if (!ring)
-			goto err_tx_ring_allocation;
+			goto err_allocation;
 		ring->count = adapter->tx_ring_count;
-		ring->queue_index = i;
-		ring->numa_node = adapter->node;
+		ring->queue_index = tx;
+		ring->numa_node = nid;
 
-		adapter->tx_ring[i] = ring;
+		adapter->tx_ring[tx] = ring;
 	}
 
-	/* Restore the adapter's original node */
-	adapter->node = orig_node;
+	for (; rx < adapter->num_rx_queues; rx++) {
+		struct ixgbe_ring *ring;
 
-	for (i = 0; i < adapter->num_rx_queues; i++) {
-		struct ixgbe_ring *ring = adapter->rx_ring[i];
-		if (orig_node == -1) {
-			int cur_node = next_online_node(adapter->node);
-			if (cur_node == MAX_NUMNODES)
-				cur_node = first_online_node;
-			adapter->node = cur_node;
-		}
-		ring = kzalloc_node(sizeof(struct ixgbe_ring), GFP_KERNEL,
-				    adapter->node);
+		ring = kzalloc_node(sizeof(*ring), GFP_KERNEL, nid);
 		if (!ring)
-			ring = kzalloc(sizeof(struct ixgbe_ring), GFP_KERNEL);
+			ring = kzalloc(sizeof(*ring), GFP_KERNEL);
 		if (!ring)
-			goto err_rx_ring_allocation;
+			goto err_allocation;
 		ring->count = adapter->rx_ring_count;
-		ring->queue_index = i;
-		ring->numa_node = adapter->node;
+		ring->queue_index = rx;
+		ring->numa_node = nid;
 
-		adapter->rx_ring[i] = ring;
+		adapter->rx_ring[rx] = ring;
 	}
 
-	/* Restore the adapter's original node */
-	adapter->node = orig_node;
-
 	ixgbe_cache_ring_register(adapter);
 
 	return 0;
 
-err_rx_ring_allocation:
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		kfree(adapter->tx_ring[i]);
-err_tx_ring_allocation:
+err_allocation:
+	while (tx)
+		kfree(adapter->tx_ring[--tx]);
+
+	while (rx)
+		kfree(adapter->tx_ring[--rx]);
+
 	return -ENOMEM;
 }
 


