From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: [PATCH net-next 06/11] ixgbe: Flip to the new dev walk API
Date: Fri, 14 Oct 2016 18:28:46 -0700
Message-ID: <1476494931-31813-7-git-send-email-dsa@cumulusnetworks.com>
References: <1476494931-31813-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
To: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476494931-31813-1-git-send-email-dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Convert ixgbe users to new dev walk API. This is just a code conversion;
no functional change is intended.

Signed-off-by: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 132 ++++++++++++++++----------
 1 file changed, 82 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 784b0b98ab2f..f380fda11eb6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5012,24 +5012,23 @@ static int ixgbe_fwd_ring_up(struct net_device *vdev,
 	return err;
 }
 
-static void ixgbe_configure_dfwd(struct ixgbe_adapter *adapter)
+static int ixgbe_upper_dev_walk(struct net_device *upper, void *data)
 {
-	struct net_device *upper;
-	struct list_head *iter;
-	int err;
-
-	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
-		if (netif_is_macvlan(upper)) {
-			struct macvlan_dev *dfwd = netdev_priv(upper);
-			struct ixgbe_fwd_adapter *vadapter = dfwd->fwd_priv;
+	if (netif_is_macvlan(upper)) {
+		struct macvlan_dev *dfwd = netdev_priv(upper);
+		struct ixgbe_fwd_adapter *vadapter = dfwd->fwd_priv;
 
-			if (dfwd->fwd_priv) {
-				err = ixgbe_fwd_ring_up(upper, vadapter);
-				if (err)
-					continue;
-			}
-		}
+		if (dfwd->fwd_priv)
+			ixgbe_fwd_ring_up(upper, vadapter);
 	}
+
+	return 0;
+}
+
+static void ixgbe_configure_dfwd(struct ixgbe_adapter *adapter)
+{
+	netdev_walk_all_upper_dev_rcu(adapter->netdev,
+				      ixgbe_upper_dev_walk, NULL);
 }
 
 static void ixgbe_configure(struct ixgbe_adapter *adapter)
@@ -5448,12 +5447,25 @@ static void ixgbe_fdir_filter_exit(struct ixgbe_adapter *adapter)
 	spin_unlock(&adapter->fdir_perfect_lock);
 }
 
+static int ixgbe_disable_macvlan(struct net_device *upper, void *data)
+{
+	if (netif_is_macvlan(upper)) {
+		struct macvlan_dev *vlan = netdev_priv(upper);
+
+		if (vlan->fwd_priv) {
+			netif_tx_stop_all_queues(upper);
+			netif_carrier_off(upper);
+			netif_tx_disable(upper);
+		}
+	}
+
+	return 0;
+}
+
 void ixgbe_down(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct net_device *upper;
-	struct list_head *iter;
 	int i;
 
 	/* signal that we are down to the interrupt handler */
@@ -5477,17 +5489,8 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	netif_tx_disable(netdev);
 
 	/* disable any upper devices */
-	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
-		if (netif_is_macvlan(upper)) {
-			struct macvlan_dev *vlan = netdev_priv(upper);
-
-			if (vlan->fwd_priv) {
-				netif_tx_stop_all_queues(upper);
-				netif_carrier_off(upper);
-				netif_tx_disable(upper);
-			}
-		}
-	}
+	netdev_walk_all_upper_dev_rcu(adapter->netdev,
+				      ixgbe_disable_macvlan, NULL);
 
 	ixgbe_irq_disable(adapter);
 
@@ -6728,6 +6731,18 @@ static void ixgbe_update_default_up(struct ixgbe_adapter *adapter)
 #endif
 }
 
+static int ixgbe_enable_macvlan(struct net_device *upper, void *data)
+{
+	if (netif_is_macvlan(upper)) {
+		struct macvlan_dev *vlan = netdev_priv(upper);
+
+		if (vlan->fwd_priv)
+			netif_tx_wake_all_queues(upper);
+	}
+
+	return 0;
+}
+
 /**
  * ixgbe_watchdog_link_is_up - update netif_carrier status and
  *                             print link up message
@@ -6737,8 +6752,6 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct net_device *upper;
-	struct list_head *iter;
 	u32 link_speed = adapter->link_speed;
 	const char *speed_str;
 	bool flow_rx, flow_tx;
@@ -6809,14 +6822,8 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 
 	/* enable any upper devices */
 	rtnl_lock();
-	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
-		if (netif_is_macvlan(upper)) {
-			struct macvlan_dev *vlan = netdev_priv(upper);
-
-			if (vlan->fwd_priv)
-				netif_tx_wake_all_queues(upper);
-		}
-	}
+	netdev_walk_all_upper_dev_rcu(adapter->netdev,
+				      ixgbe_enable_macvlan, NULL);
 	rtnl_unlock();
 
 	/* update the default user priority for VFs */
@@ -8350,12 +8357,38 @@ static int ixgbe_configure_clsu32_del_hnode(struct ixgbe_adapter *adapter,
 }
 
 #ifdef CONFIG_NET_CLS_ACT
+struct upper_walk_data {
+	struct ixgbe_adapter *adapter;
+	u64 action;
+	int ifindex;
+	u8 queue;
+};
+
+static int get_macvlan_queue(struct net_device *upper, void *_data)
+{
+	if (netif_is_macvlan(upper)) {
+		struct macvlan_dev *dfwd = netdev_priv(upper);
+		struct ixgbe_fwd_adapter *vadapter = dfwd->fwd_priv;
+		struct upper_walk_data *data = _data;
+		struct ixgbe_adapter *adapter = data->adapter;
+		int ifindex = data->ifindex;
+
+		if (vadapter && vadapter->netdev->ifindex == ifindex) {
+			data->queue = adapter->rx_ring[vadapter->rx_base_queue]->reg_idx;
+			data->action = data->queue;
+			return 1;
+		}
+	}
+
+	return 0;
+}
+
 static int handle_redirect_action(struct ixgbe_adapter *adapter, int ifindex,
 				  u8 *queue, u64 *action)
 {
 	unsigned int num_vfs = adapter->num_vfs, vf;
+	struct upper_walk_data data;
 	struct net_device *upper;
-	struct list_head *iter;
 
 	/* redirect to a SRIOV VF */
 	for (vf = 0; vf < num_vfs; ++vf) {
@@ -8373,17 +8406,16 @@ static int handle_redirect_action(struct ixgbe_adapter *adapter, int ifindex,
 	}
 
 	/* redirect to a offloaded macvlan netdev */
-	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
-		if (netif_is_macvlan(upper)) {
-			struct macvlan_dev *dfwd = netdev_priv(upper);
-			struct ixgbe_fwd_adapter *vadapter = dfwd->fwd_priv;
-
-			if (vadapter && vadapter->netdev->ifindex == ifindex) {
-				*queue = adapter->rx_ring[vadapter->rx_base_queue]->reg_idx;
-				*action = *queue;
-				return 0;
-			}
-		}
+	data.adapter = adapter;
+	data.ifindex = ifindex;
+	data.action = 0;
+	data.queue = 0;
+	if (netdev_walk_all_upper_dev_rcu(adapter->netdev,
+					  get_macvlan_queue, &data)) {
+		*action = data.action;
+		*queue = data.queue;
+
+		return 0;
 	}
 
 	return -EINVAL;
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
