From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [RFC PATCH] ixgbe: acquire RCU read lock when calling netdev_for_each_all_upper_dev_rcu()
Date: Thu, 19 Dec 2013 14:00:56 +0800
Message-ID: <1387432860-14021-1-git-send-email-jiang.liu@linux.intel.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

According to documentation for netdev_for_each_all_upper_dev_rcu(),
caller should take RCU read lock, otherwise it will trigger following
warnings. The simplest fix is to protect with rcu_read_lock()/
rcu_read_unlock(). And this solutions passes basic tests.

Otherwise we may need to introduce  netdev_for_each_all_upper_dev()
as netdev_lower_get_next_private(), which assumes the caller has
gained the lock to protect the list.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index cc06854..da72a5f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -4336,6 +4336,7 @@ static void ixgbe_configure_dfwd(struct ixgbe_adapter *adapter)
 	struct list_head *iter;
 	int err;
 
+	rcu_read_lock();
 	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
 		if (netif_is_macvlan(upper)) {
 			struct macvlan_dev *dfwd = netdev_priv(upper);
@@ -4348,6 +4349,7 @@ static void ixgbe_configure_dfwd(struct ixgbe_adapter *adapter)
 			}
 		}
 	}
+	rcu_read_unlock();
 }
 
 static void ixgbe_configure(struct ixgbe_adapter *adapter)
@@ -4601,6 +4603,7 @@ static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	netif_tx_start_all_queues(adapter->netdev);
 
 	/* enable any upper devices */
+	rcu_read_lock();
 	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
 		if (netif_is_macvlan(upper)) {
 			struct macvlan_dev *vlan = netdev_priv(upper);
@@ -4609,6 +4612,7 @@ static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
 				netif_tx_start_all_queues(upper);
 		}
 	}
+	rcu_read_unlock();
 
 	/* bring the link up in the watchdog, this could race with our first
 	 * link up interrupt but shouldn't be a problem */
@@ -4803,6 +4807,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	netif_tx_disable(netdev);
 
 	/* disable any upper devices */
+	rcu_read_lock();
 	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
 		if (netif_is_macvlan(upper)) {
 			struct macvlan_dev *vlan = netdev_priv(upper);
@@ -4814,6 +4819,7 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 			}
 		}
 	}
+	rcu_read_unlock();
 
 	ixgbe_irq_disable(adapter);
 
-- 
1.7.10.4
