From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/15] igb: Added rcu_lock to avoid race
Date: Thu, 22 Aug 2013 02:49:39 -0700
Message-ID: <1377164991-27988-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377164991-27988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:52886 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752457Ab3HVJt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 05:49:57 -0400
In-Reply-To: <1377164991-27988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

This patch adds rcu_lock to avoid possible race condition with igb_update_stats
function accessing the rings in free_ q_vector.

CC: Eric Dumazet <edumazet@google.com>
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 090ee56..8e7c1b8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1013,7 +1013,7 @@ static void igb_free_q_vector(struct igb_adapter *adapter, int v_idx)
 	adapter->q_vector[v_idx] = NULL;
 	netif_napi_del(&q_vector->napi);
 
-	/* ixgbe_get_stats64() might access the rings on this vector,
+	/* igb_get_stats64() might access the rings on this vector,
 	 * we must wait a grace period before freeing it.
 	 */
 	kfree_rcu(q_vector, rcu);
@@ -4859,6 +4859,8 @@ void igb_update_stats(struct igb_adapter *adapter,
 
 	bytes = 0;
 	packets = 0;
+
+	rcu_read_lock();
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		u32 rqdpc = rd32(E1000_RQDPC(i));
 		struct igb_ring *ring = adapter->rx_ring[i];
@@ -4894,6 +4896,7 @@ void igb_update_stats(struct igb_adapter *adapter,
 	}
 	net_stats->tx_bytes = bytes;
 	net_stats->tx_packets = packets;
+	rcu_read_unlock();
 
 	/* read stats registers */
 	adapter->stats.crcerrs += rd32(E1000_CRCERRS);
-- 
1.8.3.1
