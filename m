From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH 2/2] ixgbe: deleting dfwd stations out of order can
 cause null ptr deref
Date: Fri, 08 Nov 2013 00:51:10 -0800
Message-ID: <20131108085109.6935.99661.stgit@nitbit.x32>
References: <20131108084654.6935.36501.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:40326 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168Ab3KHIv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 03:51:29 -0500
Received: by mail-ob0-f176.google.com with SMTP id uy5so1235511obc.7
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 00:51:28 -0800 (PST)
In-Reply-To: <20131108084654.6935.36501.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The number of stations in use is kept in the num_rx_pools counter
in the ixgbe_adapter structure. This is in turn used by the queue
allocation scheme to determine how many queues are needed to support
the number of pools in use with the current feature set.

This works as long as the pools are added and destroyed in order
because (num_rx_pools * queues_per_pool) is equal to the last
queue in use by a pool. But as soon as you delete a pool out of
order this is no longer the case. So the above multiplication
allocates to few queues and a pool may reference a ring that has
not been allocated/initialized.

To resolve use the bit mask of in use pools to determine the final
pool being used and allocate enough queues so that we don't
inadvertently remove its queues.

# ip link add link eth2 \
	numtxqueues 4 numrxqueues 4 txqueuelen 50 type macvlan
# ip link set dev macvlan0 up
# ip link add link eth2 \
	numtxqueues 4 numrxqueues 4 txqueuelen 50 type macvlan
# ip link set dev macvlan1 up
# for i in {0..100}; do
  ip link set dev macvlan0 down; ip link set dev macvlan0 up;
  done;

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2e17c30..ec1bf3e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7536,6 +7536,7 @@ static void *ixgbe_fwd_add(struct net_device *pdev, struct net_device *vdev)
 {
 	struct ixgbe_fwd_adapter *fwd_adapter = NULL;
 	struct ixgbe_adapter *adapter = netdev_priv(pdev);
+	unsigned int limit;
 	int pool, err;
 
 #ifdef CONFIG_RPS
@@ -7566,10 +7567,11 @@ static void *ixgbe_fwd_add(struct net_device *pdev, struct net_device *vdev)
 	pool = find_first_zero_bit(&adapter->fwd_bitmask, 32);
 	adapter->num_rx_pools++;
 	set_bit(pool, &adapter->fwd_bitmask);
+	limit = find_last_bit(&adapter->fwd_bitmask, 32);
 
 	/* Enable VMDq flag so device will be set in VM mode */
 	adapter->flags |= IXGBE_FLAG_VMDQ_ENABLED | IXGBE_FLAG_SRIOV_ENABLED;
-	adapter->ring_feature[RING_F_VMDQ].limit = adapter->num_rx_pools;
+	adapter->ring_feature[RING_F_VMDQ].limit = limit + 1;
 	adapter->ring_feature[RING_F_RSS].limit = vdev->num_tx_queues;
 
 	/* Force reinit of ring allocation with VMDQ enabled */
@@ -7597,11 +7599,13 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
 {
 	struct ixgbe_fwd_adapter *fwd_adapter = priv;
 	struct ixgbe_adapter *adapter = fwd_adapter->real_adapter;
+	unsigned int limit;
 
 	clear_bit(fwd_adapter->pool, &adapter->fwd_bitmask);
 	adapter->num_rx_pools--;
 
-	adapter->ring_feature[RING_F_VMDQ].limit = adapter->num_rx_pools;
+	limit = find_last_bit(&adapter->fwd_bitmask, 32);
+	adapter->ring_feature[RING_F_VMDQ].limit = limit + 1;
 	ixgbe_fwd_ring_down(fwd_adapter->netdev, fwd_adapter);
 	ixgbe_setup_tc(pdev, netdev_get_num_tc(pdev));
 	netdev_dbg(pdev, "pool %i:%i queues %i:%i VSI bitmask %lx\n",
