From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/10] igb: Added rcu_lock to avoid race
Date: Wed, 26 Jun 2013 03:55:19 -0700
Message-ID: <1372244122-17664-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9007 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751711Ab3FZKz3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 06:55:29 -0400
In-Reply-To: <1372244122-17664-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch adds rcu_lock to avoid possible race condition with igb_update_stats
function accessing the rings in free_ q_vector.

Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 7112e52..c74ad78 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -705,6 +705,8 @@ static void __exit igb_exit_module(void)
 	dca_unregister_notify(&dca_notifier);
 #endif
 	pci_unregister_driver(&igb_driver);
+
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 module_exit(igb_exit_module);
@@ -1013,7 +1015,7 @@ static void igb_free_q_vector(struct igb_adapter *adapter, int v_idx)
 	adapter->q_vector[v_idx] = NULL;
 	netif_napi_del(&q_vector->napi);
 
-	/* ixgbe_get_stats64() might access the rings on this vector,
+	/* igb_get_stats64() might access the rings on this vector,
 	 * we must wait a grace period before freeing it.
 	 */
 	kfree_rcu(q_vector, rcu);
@@ -4860,6 +4862,8 @@ void igb_update_stats(struct igb_adapter *adapter,
 
 	bytes = 0;
 	packets = 0;
+
+	rcu_read_lock();
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		u32 rqdpc = rd32(E1000_RQDPC(i));
 		struct igb_ring *ring = adapter->rx_ring[i];
@@ -4895,6 +4899,7 @@ void igb_update_stats(struct igb_adapter *adapter,
 	}
 	net_stats->tx_bytes = bytes;
 	net_stats->tx_packets = packets;
+	rcu_read_unlock();
 
 	/* read stats registers */
 	adapter->stats.crcerrs += rd32(E1000_CRCERRS);
-- 
1.7.11.7
