From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] ixgbevf: Minor cleanups
Date: Wed,  2 Dec 2015 04:30:58 -0800
Message-ID: <1449059468-87025-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449059468-87025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1811 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756907AbbLBMbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 07:31:13 -0500
In-Reply-To: <1449059468-87025-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Make some minor cleanups, such as simplifying return paths, deleting
unneeded initializations, return values more directly and so forth.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Darin Miller <darin.j.miller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 36 ++++++++---------------
 1 file changed, 12 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 18f1c22..42b971c 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1334,7 +1334,6 @@ static int ixgbevf_map_rings_to_vectors(struct ixgbevf_adapter *adapter)
 	int txr_remaining = adapter->num_tx_queues;
 	int i, j;
 	int rqpv, tqpv;
-	int err = 0;
 
 	q_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
 
@@ -1347,7 +1346,7 @@ static int ixgbevf_map_rings_to_vectors(struct ixgbevf_adapter *adapter)
 
 		for (; txr_idx < txr_remaining; v_start++, txr_idx++)
 			map_vector_to_txq(adapter, v_start, txr_idx);
-		goto out;
+		return 0;
 	}
 
 	/* If we don't have enough vectors for a 1-to-1
@@ -1372,8 +1371,7 @@ static int ixgbevf_map_rings_to_vectors(struct ixgbevf_adapter *adapter)
 		}
 	}
 
-out:
-	return err;
+	return 0;
 }
 
 /**
@@ -1471,9 +1469,7 @@ static inline void ixgbevf_reset_q_vectors(struct ixgbevf_adapter *adapter)
  **/
 static int ixgbevf_request_irq(struct ixgbevf_adapter *adapter)
 {
-	int err = 0;
-
-	err = ixgbevf_request_msix_irqs(adapter);
+	int err = ixgbevf_request_msix_irqs(adapter);
 
 	if (err)
 		hw_dbg(&adapter->hw, "request_irq failed, Error %d\n", err);
@@ -1832,7 +1828,7 @@ static int ixgbevf_vlan_rx_kill_vid(struct net_device *netdev,
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
-	int err = -EOPNOTSUPP;
+	int err;
 
 	spin_lock_bh(&adapter->mbx_lock);
 
@@ -2048,7 +2044,7 @@ static void ixgbevf_negotiate_api(struct ixgbevf_adapter *adapter)
 		      ixgbe_mbox_api_11,
 		      ixgbe_mbox_api_10,
 		      ixgbe_mbox_api_unknown };
-	int err = 0, idx = 0;
+	int err, idx = 0;
 
 	spin_lock_bh(&adapter->mbx_lock);
 
@@ -2421,7 +2417,7 @@ err_allocation:
 static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int err = 0;
+	int err;
 	int vector, v_budget;
 
 	/* It's easy to be greedy for MSI-X vectors, but it really
@@ -2439,26 +2435,21 @@ static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
 	 */
 	adapter->msix_entries = kcalloc(v_budget,
 					sizeof(struct msix_entry), GFP_KERNEL);
-	if (!adapter->msix_entries) {
-		err = -ENOMEM;
-		goto out;
-	}
+	if (!adapter->msix_entries)
+		return -ENOMEM;
 
 	for (vector = 0; vector < v_budget; vector++)
 		adapter->msix_entries[vector].entry = vector;
 
 	err = ixgbevf_acquire_msix_vectors(adapter, v_budget);
 	if (err)
-		goto out;
+		return err;
 
 	err = netif_set_real_num_tx_queues(netdev, adapter->num_tx_queues);
 	if (err)
-		goto out;
-
-	err = netif_set_real_num_rx_queues(netdev, adapter->num_rx_queues);
+		return err;
 
-out:
-	return err;
+	return netif_set_real_num_rx_queues(netdev, adapter->num_rx_queues);
 }
 
 /**
@@ -4246,8 +4237,6 @@ static struct pci_driver ixgbevf_driver = {
  **/
 static int __init ixgbevf_init_module(void)
 {
-	int ret;
-
 	pr_info("%s - version %s\n", ixgbevf_driver_string,
 		ixgbevf_driver_version);
 
@@ -4258,8 +4247,7 @@ static int __init ixgbevf_init_module(void)
 		return -ENOMEM;
 	}
 
-	ret = pci_register_driver(&ixgbevf_driver);
-	return ret;
+	return pci_register_driver(&ixgbevf_driver);
 }
 
 module_init(ixgbevf_init_module);
-- 
2.5.0
