From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] ixgbe: restore normal RSS after last macvlan offload is removed
Date: Mon,  9 Oct 2017 11:39:53 -0700
Message-ID: <20171009184000.80053-4-jeffrey.t.kirsher@intel.com>
References: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@oracle.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54649 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755214AbdJISkX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 14:40:23 -0400
In-Reply-To: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@oracle.com>

Just like when the last VF is removed, we need to restore normal
operations after the last macvlan offload is removed, else we
get stuck in single queue operations.

To test:
ethtool -l eth1   # note the number of queues in use, ~= cpus

ethtool -K eth1 l2-fwd-offload on
ip link add mv1 link eth1 type macvlan mode bridge
ip link set dev mv1 up
ip link del mv1

ethtool -l eth1   # are we back to the same # of queues, or stuck on 1?

Signed-off-by: Shannon Nelson <shannon.nelson@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3942c6208745..d83cc9d34de3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9758,6 +9758,17 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
 	limit = find_last_bit(&adapter->fwd_bitmask, 32);
 	adapter->ring_feature[RING_F_VMDQ].limit = limit + 1;
 	ixgbe_fwd_ring_down(fwd_adapter->netdev, fwd_adapter);
+
+	/* go back to full RSS if we're done with our VMQs */
+	if (adapter->ring_feature[RING_F_VMDQ].limit == 1) {
+		int rss = min_t(int, ixgbe_max_rss_indices(adapter),
+				num_online_cpus());
+
+		adapter->flags &= ~IXGBE_FLAG_VMDQ_ENABLED;
+		adapter->flags &= ~IXGBE_FLAG_SRIOV_ENABLED;
+		adapter->ring_feature[RING_F_RSS].limit = rss;
+	}
+
 	ixgbe_setup_tc(pdev, netdev_get_num_tc(pdev));
 	netdev_dbg(pdev, "pool %i:%i queues %i:%i VSI bitmask %lx\n",
 		   fwd_adapter->pool, adapter->num_rx_pools,
-- 
2.14.2
