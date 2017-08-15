From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH net-next] ixgbe: restore normal RSS after last macvlan offload is removed
Date: Tue, 15 Aug 2017 08:59:54 -0700
Message-ID: <1502812794-452204-1-git-send-email-shannon.nelson@oracle.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41064 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753149AbdHOP6r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:58:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 0f867dc..cedaf1c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9728,6 +9728,17 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
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
1.7.1
