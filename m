From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] ixgbe: enable tx queues after link up
Date: Thu, 20 Mar 2014 01:33:05 -0700
Message-ID: <1395304385-6874-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Arun Sharma <asharma@fb.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8080 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756028AbaCTId6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Mar 2014 04:33:58 -0400
In-Reply-To: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

This patch moves the call to enable Tx queues after the link is established.
Previously there was a chance for aggressive start_ndo_xmit() callers to
sneak packets between enabling the Tx queues and the link coming up.

In addition it replaces netif_tx_start_all_queues() with
netif_tx_wake_all_queues() to allow for flushing of the qdisc.

CC: Arun Sharma <asharma@fb.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 32 ++++++++++++++-------------
 1 file changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 354771f..9e5a366 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4655,8 +4655,6 @@ static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
 static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct net_device *upper;
-	struct list_head *iter;
 	int err;
 	u32 ctrl_ext;
 
@@ -4698,19 +4696,6 @@ static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
 			e_crit(drv, "Fan has stopped, replace the adapter\n");
 	}
 
-	/* enable transmits */
-	netif_tx_start_all_queues(adapter->netdev);
-
-	/* enable any upper devices */
-	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
-		if (netif_is_macvlan(upper)) {
-			struct macvlan_dev *vlan = netdev_priv(upper);
-
-			if (vlan->fwd_priv)
-				netif_tx_start_all_queues(upper);
-		}
-	}
-
 	/* bring the link up in the watchdog, this could race with our first
 	 * link up interrupt but shouldn't be a problem */
 	adapter->flags |= IXGBE_FLAG_NEED_LINK_UPDATE;
@@ -6082,6 +6067,8 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct net_device *upper;
+	struct list_head *iter;
 	u32 link_speed = adapter->link_speed;
 	bool flow_rx, flow_tx;
 
@@ -6133,6 +6120,21 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 	netif_carrier_on(netdev);
 	ixgbe_check_vf_rate_limit(adapter);
 
+	/* enable transmits */
+	netif_tx_wake_all_queues(adapter->netdev);
+
+	/* enable any upper devices */
+	rtnl_lock();
+	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
+		if (netif_is_macvlan(upper)) {
+			struct macvlan_dev *vlan = netdev_priv(upper);
+
+			if (vlan->fwd_priv)
+				netif_tx_wake_all_queues(upper);
+		}
+	}
+	rtnl_unlock();
+
 	/* update the default user priority for VFs */
 	ixgbe_update_default_up(adapter);
 
-- 
1.8.3.1
