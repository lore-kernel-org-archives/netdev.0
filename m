From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/14] ixgbevf: add DCB configuration into queue setup
Date: Tue, 17 Dec 2013 22:44:38 -0800
Message-ID: <1387349082-18506-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24896 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752836Ab3LRGpB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 01:45:01 -0500
In-Reply-To: <1387349082-18506-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch takes the DCB config checks and adds them to the normal setting
up of the queues. This way we won't have to allocation queues in a separate
place for enabling DCB.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-By: Jack Morgan<jack.morgan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |   1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 228 +++++++++-------------
 2 files changed, 91 insertions(+), 138 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index eaaa3ec..bb76e96 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -354,6 +354,7 @@ struct ixgbevf_adapter {
 	u32 flags;
 #define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1)
 #define IXGBE_FLAG_IN_NETPOLL                   (u32)(1 << 1)
+#define IXGBEVF_FLAG_QUEUE_RESET_REQUESTED	(u32)(1 << 2)
 
 	/* OS defined structs */
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 84b55fe..a5d3167 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -95,6 +95,7 @@ module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
 /* forward decls */
+static void ixgbevf_queue_reset_subtask(struct ixgbevf_adapter *adapter);
 static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector);
 static void ixgbevf_free_all_rx_resources(struct ixgbevf_adapter *adapter);
 
@@ -1368,11 +1369,51 @@ static void ixgbevf_napi_disable_all(struct ixgbevf_adapter *adapter)
 	}
 }
 
+static int ixgbevf_configure_dcb(struct ixgbevf_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	unsigned int def_q = 0;
+	unsigned int num_tcs = 0;
+	unsigned int num_rx_queues = 1;
+	int err;
+
+	spin_lock_bh(&adapter->mbx_lock);
+
+	/* fetch queue configuration from the PF */
+	err = ixgbevf_get_queues(hw, &num_tcs, &def_q);
+
+	spin_unlock_bh(&adapter->mbx_lock);
+
+	if (err)
+		return err;
+
+	if (num_tcs > 1) {
+		/* update default Tx ring register index */
+		adapter->tx_ring[0].reg_idx = def_q;
+
+		/* we need as many queues as traffic classes */
+		num_rx_queues = num_tcs;
+	}
+
+	/* if we have a bad config abort request queue reset */
+	if (adapter->num_rx_queues != num_rx_queues) {
+		/* force mailbox timeout to prevent further messages */
+		hw->mbx.timeout = 0;
+
+		/* wait for watchdog to come around and bail us out */
+		adapter->flags |= IXGBEVF_FLAG_QUEUE_RESET_REQUESTED;
+	}
+
+	return 0;
+}
+
 static void ixgbevf_configure(struct ixgbevf_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	int i;
 
+	ixgbevf_configure_dcb(adapter);
+
 	ixgbevf_set_rx_mode(netdev);
 
 	ixgbevf_restore_vlan(adapter);
@@ -1551,85 +1592,10 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
 	mod_timer(&adapter->watchdog_timer, jiffies);
 }
 
-static int ixgbevf_reset_queues(struct ixgbevf_adapter *adapter)
-{
-	struct ixgbe_hw *hw = &adapter->hw;
-	struct ixgbevf_ring *rx_ring;
-	unsigned int def_q = 0;
-	unsigned int num_tcs = 0;
-	unsigned int num_rx_queues = 1;
-	int err, i;
-
-	spin_lock_bh(&adapter->mbx_lock);
-
-	/* fetch queue configuration from the PF */
-	err = ixgbevf_get_queues(hw, &num_tcs, &def_q);
-
-	spin_unlock_bh(&adapter->mbx_lock);
-
-	if (err)
-		return err;
-
-	if (num_tcs > 1) {
-		/* update default Tx ring register index */
-		adapter->tx_ring[0].reg_idx = def_q;
-
-		/* we need as many queues as traffic classes */
-		num_rx_queues = num_tcs;
-	}
-
-	/* nothing to do if we have the correct number of queues */
-	if (adapter->num_rx_queues == num_rx_queues)
-		return 0;
-
-	/* allocate new rings */
-	rx_ring = kcalloc(num_rx_queues,
-			  sizeof(struct ixgbevf_ring), GFP_KERNEL);
-	if (!rx_ring)
-		return -ENOMEM;
-
-	/* setup ring fields */
-	for (i = 0; i < num_rx_queues; i++) {
-		rx_ring[i].count = adapter->rx_ring_count;
-		rx_ring[i].queue_index = i;
-		rx_ring[i].reg_idx = i;
-		rx_ring[i].dev = &adapter->pdev->dev;
-		rx_ring[i].netdev = adapter->netdev;
-
-		/* allocate resources on the ring */
-		err = ixgbevf_setup_rx_resources(adapter, &rx_ring[i]);
-		if (err) {
-			while (i) {
-				i--;
-				ixgbevf_free_rx_resources(adapter, &rx_ring[i]);
-			}
-			kfree(rx_ring);
-			return err;
-		}
-	}
-
-	/* free the existing rings and queues */
-	ixgbevf_free_all_rx_resources(adapter);
-	adapter->num_rx_queues = 0;
-	kfree(adapter->rx_ring);
-
-	/* move new rings into position on the adapter struct */
-	adapter->rx_ring = rx_ring;
-	adapter->num_rx_queues = num_rx_queues;
-
-	/* reset ring to vector mapping */
-	ixgbevf_reset_q_vectors(adapter);
-	ixgbevf_map_rings_to_vectors(adapter);
-
-	return 0;
-}
-
 void ixgbevf_up(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	ixgbevf_reset_queues(adapter);
-
 	ixgbevf_configure(adapter);
 
 	ixgbevf_up_complete(adapter);
@@ -1875,9 +1841,28 @@ static int ixgbevf_acquire_msix_vectors(struct ixgbevf_adapter *adapter,
  **/
 static void ixgbevf_set_num_queues(struct ixgbevf_adapter *adapter)
 {
+	struct ixgbe_hw *hw = &adapter->hw;
+	unsigned int def_q = 0;
+	unsigned int num_tcs = 0;
+	int err;
+
 	/* Start with base case */
 	adapter->num_rx_queues = 1;
 	adapter->num_tx_queues = 1;
+
+	spin_lock_bh(&adapter->mbx_lock);
+
+	/* fetch queue configuration from the PF */
+	err = ixgbevf_get_queues(hw, &num_tcs, &def_q);
+
+	spin_unlock_bh(&adapter->mbx_lock);
+
+	if (err)
+		return;
+
+	/* we need as many queues as traffic classes */
+	if (num_tcs > 1)
+		adapter->num_rx_queues = num_tcs;
 }
 
 /**
@@ -2326,6 +2311,8 @@ static void ixgbevf_watchdog_task(struct work_struct *work)
 	bool link_up = adapter->link_up;
 	s32 need_reset;
 
+	ixgbevf_queue_reset_subtask(adapter);
+
 	adapter->flags |= IXGBE_FLAG_IN_WATCHDOG_TASK;
 
 	/*
@@ -2595,63 +2582,6 @@ static void ixgbevf_free_all_rx_resources(struct ixgbevf_adapter *adapter)
 						  &adapter->rx_ring[i]);
 }
 
-static int ixgbevf_setup_queues(struct ixgbevf_adapter *adapter)
-{
-	struct ixgbe_hw *hw = &adapter->hw;
-	struct ixgbevf_ring *rx_ring;
-	unsigned int def_q = 0;
-	unsigned int num_tcs = 0;
-	unsigned int num_rx_queues = 1;
-	int err, i;
-
-	spin_lock_bh(&adapter->mbx_lock);
-
-	/* fetch queue configuration from the PF */
-	err = ixgbevf_get_queues(hw, &num_tcs, &def_q);
-
-	spin_unlock_bh(&adapter->mbx_lock);
-
-	if (err)
-		return err;
-
-	if (num_tcs > 1) {
-		/* update default Tx ring register index */
-		adapter->tx_ring[0].reg_idx = def_q;
-
-		/* we need as many queues as traffic classes */
-		num_rx_queues = num_tcs;
-	}
-
-	/* nothing to do if we have the correct number of queues */
-	if (adapter->num_rx_queues == num_rx_queues)
-		return 0;
-
-	/* allocate new rings */
-	rx_ring = kcalloc(num_rx_queues,
-			  sizeof(struct ixgbevf_ring), GFP_KERNEL);
-	if (!rx_ring)
-		return -ENOMEM;
-
-	/* setup ring fields */
-	for (i = 0; i < num_rx_queues; i++) {
-		rx_ring[i].count = adapter->rx_ring_count;
-		rx_ring[i].queue_index = i;
-		rx_ring[i].reg_idx = i;
-		rx_ring[i].dev = &adapter->pdev->dev;
-		rx_ring[i].netdev = adapter->netdev;
-	}
-
-	/* free the existing ring and queues */
-	adapter->num_rx_queues = 0;
-	kfree(adapter->rx_ring);
-
-	/* move new rings into position on the adapter struct */
-	adapter->rx_ring = rx_ring;
-	adapter->num_rx_queues = num_rx_queues;
-
-	return 0;
-}
-
 /**
  * ixgbevf_open - Called when a network interface is made active
  * @netdev: network interface device structure
@@ -2695,11 +2625,6 @@ static int ixgbevf_open(struct net_device *netdev)
 		}
 	}
 
-	/* setup queue reg_idx and Rx queue count */
-	err = ixgbevf_setup_queues(adapter);
-	if (err)
-		goto err_setup_queues;
-
 	/* allocate transmit descriptors */
 	err = ixgbevf_setup_all_tx_resources(adapter);
 	if (err)
@@ -2737,7 +2662,6 @@ err_setup_rx:
 	ixgbevf_free_all_rx_resources(adapter);
 err_setup_tx:
 	ixgbevf_free_all_tx_resources(adapter);
-err_setup_queues:
 	ixgbevf_reset(adapter);
 
 err_setup_reset:
@@ -2769,6 +2693,34 @@ static int ixgbevf_close(struct net_device *netdev)
 	return 0;
 }
 
+static void ixgbevf_queue_reset_subtask(struct ixgbevf_adapter *adapter)
+{
+	struct net_device *dev = adapter->netdev;
+
+	if (!(adapter->flags & IXGBEVF_FLAG_QUEUE_RESET_REQUESTED))
+		return;
+
+	adapter->flags &= ~IXGBEVF_FLAG_QUEUE_RESET_REQUESTED;
+
+	/* if interface is down do nothing */
+	if (test_bit(__IXGBEVF_DOWN, &adapter->state) ||
+	    test_bit(__IXGBEVF_RESETTING, &adapter->state))
+		return;
+
+	/* Hardware has to reinitialize queues and interrupts to
+	 * match packet buffer alignment. Unfortunately, the
+	 * hardware is not flexible enough to do this dynamically.
+	 */
+	if (netif_running(dev))
+		ixgbevf_close(dev);
+
+	ixgbevf_clear_interrupt_scheme(adapter);
+	ixgbevf_init_interrupt_scheme(adapter);
+
+	if (netif_running(dev))
+		ixgbevf_open(dev);
+}
+
 static void ixgbevf_tx_ctxtdesc(struct ixgbevf_ring *tx_ring,
 				u32 vlan_macip_lens, u32 type_tucmd,
 				u32 mss_l4len_idx)
-- 
1.8.3.1
