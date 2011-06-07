From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 24/40] ixgbe: alloc DDP PCI pool and ixgbe queues as per NUMA nodes
Date: Tue,  7 Jun 2011 05:32:59 -0700
Message-ID: <1307449995-9458-25-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasu Dev <vasu.dev@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4748 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753313Ab1FGMd2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jun 2011 08:33:28 -0400
In-Reply-To: <1307449995-9458-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

Have DDP PCI pools allocated from closest NUMA node to the CPU
and have ixgbe queues allocs per NUMA node.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_fcoe.c |    8 ++++++--
 drivers/net/ixgbe/ixgbe_main.c |   12 +++++++++---
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index aadff4f..71e8458 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -615,7 +615,7 @@ static void ixgbe_fcoe_ddp_pools_free(struct ixgbe_fcoe *fcoe)
 static void ixgbe_fcoe_ddp_pools_alloc(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_fcoe *fcoe = &adapter->fcoe;
-	unsigned int cpu;
+	unsigned int cpu, nid;
 	struct pci_pool **pool;
 	char pool_name[32];
 
@@ -623,19 +623,23 @@ static void ixgbe_fcoe_ddp_pools_alloc(struct ixgbe_adapter *adapter)
 	if (!fcoe->pool)
 		return;
 
+	nid = dev_to_node(&adapter->pdev->dev);
 	/* allocate pci pool for each cpu */
 	for_each_possible_cpu(cpu) {
 		snprintf(pool_name, 32, "ixgbe_fcoe_ddp_%d", cpu);
 		pool = per_cpu_ptr(fcoe->pool, cpu);
+		set_dev_node(&adapter->pdev->dev, cpu_to_node(cpu));
 		*pool = pci_pool_create(pool_name,
 					adapter->pdev, IXGBE_FCPTR_MAX,
 					IXGBE_FCPTR_ALIGN, PAGE_SIZE);
 		if (!*pool) {
 			e_err(drv, "failed to alloc DDP pool on cpu:%d\n", cpu);
 			ixgbe_fcoe_ddp_pools_free(fcoe);
-			return;
+			break;
 		}
 	}
+	/* restore original node value */
+	set_dev_node(&adapter->pdev->dev, nid);
 }
 
 static void ixgbe_fcoe_locks_free(struct ixgbe_fcoe *fcoe)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 053c561..1c2e721 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4782,10 +4782,9 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
  **/
 static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 {
-	int rx = 0, tx = 0, nid = adapter->node;
+	int rx = 0, tx = 0, nid;
 
-	if (nid < 0 || !node_online(nid))
-		nid = first_online_node;
+	nid = first_online_node;
 
 	for (; tx < adapter->num_tx_queues; tx++) {
 		struct ixgbe_ring *ring;
@@ -4802,8 +4801,12 @@ static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 		ring->netdev = adapter->netdev;
 
 		adapter->tx_ring[tx] = ring;
+		nid = next_online_node(nid);
+		if (nid == MAX_NUMNODES)
+			nid = first_online_node;
 	}
 
+	nid = first_online_node;
 	for (; rx < adapter->num_rx_queues; rx++) {
 		struct ixgbe_ring *ring;
 
@@ -4819,6 +4822,9 @@ static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 		ring->netdev = adapter->netdev;
 
 		adapter->rx_ring[rx] = ring;
+		nid = next_online_node(nid);
+		if (nid == MAX_NUMNODES)
+			nid = first_online_node;
 	}
 
 	ixgbe_cache_ring_register(adapter);
-- 
1.7.5.2

