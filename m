From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] igb: Fixes needed for surprise removal support
Date: Fri, 21 Nov 2014 23:52:54 -0800
Message-ID: <1416642774-17077-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416642774-17077-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Yanir Lubetkin <yanirx.lubetkin@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:22930 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750880AbaKVHxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 02:53:13 -0500
In-Reply-To: <1416642774-17077-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch adds some checks in order to prevent panic's on surprise
removal of devices during S0, S3, S4.  Without this patch, Thunderbolt
type device removal will panic the system.

Signed-off-by: Yanir Lubetkin <yanirx.lubetkin@intel.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 23 ++++++++++++++++-------
 1 file changed, 16 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index a2d72a8..487cd9c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1012,7 +1012,8 @@ static void igb_free_q_vector(struct igb_adapter *adapter, int v_idx)
 	/* igb_get_stats64() might access the rings on this vector,
 	 * we must wait a grace period before freeing it.
 	 */
-	kfree_rcu(q_vector, rcu);
+	if (q_vector)
+		kfree_rcu(q_vector, rcu);
 }
 
 /**
@@ -1792,8 +1793,10 @@ void igb_down(struct igb_adapter *adapter)
 	adapter->flags &= ~IGB_FLAG_NEED_LINK_UPDATE;
 
 	for (i = 0; i < adapter->num_q_vectors; i++) {
-		napi_synchronize(&(adapter->q_vector[i]->napi));
-		napi_disable(&(adapter->q_vector[i]->napi));
+		if (adapter->q_vector[i]) {
+			napi_synchronize(&adapter->q_vector[i]->napi);
+			napi_disable(&adapter->q_vector[i]->napi);
+		}
 	}
 
 
@@ -3717,7 +3720,8 @@ static void igb_free_all_tx_resources(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		igb_free_tx_resources(adapter->tx_ring[i]);
+		if (adapter->tx_ring[i])
+			igb_free_tx_resources(adapter->tx_ring[i]);
 }
 
 void igb_unmap_and_free_tx_resource(struct igb_ring *ring,
@@ -3782,7 +3786,8 @@ static void igb_clean_all_tx_rings(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
-		igb_clean_tx_ring(adapter->tx_ring[i]);
+		if (adapter->tx_ring[i])
+			igb_clean_tx_ring(adapter->tx_ring[i]);
 }
 
 /**
@@ -3819,7 +3824,8 @@ static void igb_free_all_rx_resources(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_free_rx_resources(adapter->rx_ring[i]);
+		if (adapter->rx_ring[i])
+			igb_free_rx_resources(adapter->rx_ring[i]);
 }
 
 /**
@@ -3874,7 +3880,8 @@ static void igb_clean_all_rx_rings(struct igb_adapter *adapter)
 	int i;
 
 	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_clean_rx_ring(adapter->rx_ring[i]);
+		if (adapter->rx_ring[i])
+			igb_clean_rx_ring(adapter->rx_ring[i]);
 }
 
 /**
@@ -7404,6 +7411,8 @@ static int igb_resume(struct device *dev)
 	pci_restore_state(pdev);
 	pci_save_state(pdev);
 
+	if (!pci_device_is_present(pdev))
+		return -ENODEV;
 	err = pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
-- 
1.9.3
