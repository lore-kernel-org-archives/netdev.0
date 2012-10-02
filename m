From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v2] netxen: write IP address to firmware when using bonding
Date: Tue,  2 Oct 2012 11:16:26 +0200
Message-ID: <1349169386-18391-1-git-send-email-nikolay@redhat.com>
References: <1348562883-14780-1-git-send-email-nikolay@redhat.com>
Cc: <agospoda@redhat.com>, <rajesh.borundia@qlogic.com>,
	<davem@davemloft.net>, <netdev@vger.kernel.org>
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62475 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751461Ab2JBJSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 05:18:05 -0400
In-Reply-To: <1348562883-14780-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows LRO aggregation on bonded devices that contain an NX3031
device. It also adds a for_each_netdev_in_bond_rcu(bond, slave) macro
which executes for each slave that has bond as master.

V2: Remove local ip caching, retrieve addresses dynamically and
    restore them if necessary.

Note: Tested with NX3031 adapter.

Signed-off-by: Andy Gospodarek <agospoda@redhat.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |   6 -
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   | 192 +++++++++++----------
 include/linux/netdevice.h                          |   3 +
 3 files changed, 100 insertions(+), 101 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index eb3dfdb..cb4f2ce 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -955,11 +955,6 @@ typedef struct nx_mac_list_s {
 	uint8_t mac_addr[ETH_ALEN+2];
 } nx_mac_list_t;
 
-struct nx_vlan_ip_list {
-	struct list_head list;
-	__be32 ip_addr;
-};
-
 /*
  * Interrupt coalescing defaults. The defaults are for 1500 MTU. It is
  * adjusted based on configured MTU.
@@ -1605,7 +1600,6 @@ struct netxen_adapter {
 	struct net_device *netdev;
 	struct pci_dev *pdev;
 	struct list_head mac_list;
-	struct list_head vlan_ip_list;
 
 	spinlock_t tx_clean_lock;
 
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index e2a4858..8e3eb61 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -90,7 +90,6 @@ static irqreturn_t netxen_intr(int irq, void *data);
 static irqreturn_t netxen_msi_intr(int irq, void *data);
 static irqreturn_t netxen_msix_intr(int irq, void *data);
 
-static void netxen_free_vlan_ip_list(struct netxen_adapter *);
 static void netxen_restore_indev_addr(struct net_device *dev, unsigned long);
 static struct rtnl_link_stats64 *netxen_nic_get_stats(struct net_device *dev,
 						      struct rtnl_link_stats64 *stats);
@@ -1451,7 +1450,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	spin_lock_init(&adapter->tx_clean_lock);
 	INIT_LIST_HEAD(&adapter->mac_list);
-	INIT_LIST_HEAD(&adapter->vlan_ip_list);
 
 	err = netxen_setup_pci_map(adapter);
 	if (err)
@@ -1586,7 +1584,7 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	cancel_work_sync(&adapter->tx_timeout_task);
 
-	netxen_free_vlan_ip_list(adapter);
+	netxen_restore_indev_addr(netdev, NETDEV_DOWN);
 	netxen_nic_detach(adapter);
 
 	nx_decr_dev_ref_cnt(adapter);
@@ -3135,66 +3133,22 @@ netxen_destip_supported(struct netxen_adapter *adapter)
 	return 1;
 }
 
-static void
-netxen_free_vlan_ip_list(struct netxen_adapter *adapter)
+static inline __be32
+netxen_get_addr(struct net_device *dev)
 {
-	struct nx_vlan_ip_list  *cur;
-	struct list_head *head = &adapter->vlan_ip_list;
-
-	while (!list_empty(head)) {
-		cur = list_entry(head->next, struct nx_vlan_ip_list, list);
-		netxen_config_ipaddr(adapter, cur->ip_addr, NX_IP_DOWN);
-		list_del(&cur->list);
-		kfree(cur);
-	}
-
-}
-static void
-netxen_list_config_vlan_ip(struct netxen_adapter *adapter,
-		struct in_ifaddr *ifa, unsigned long event)
-{
-	struct net_device *dev;
-	struct nx_vlan_ip_list *cur, *tmp_cur;
-	struct list_head *head;
-
-	dev = ifa->ifa_dev ? ifa->ifa_dev->dev : NULL;
-
-	if (dev == NULL)
-		return;
-
-	if (!is_vlan_dev(dev))
-		return;
+	struct in_device *in_dev;
+	__be32 addr = 0;
 
-	switch (event) {
-	case NX_IP_UP:
-		list_for_each(head, &adapter->vlan_ip_list) {
-			cur = list_entry(head, struct nx_vlan_ip_list, list);
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(dev);
 
-			if (cur->ip_addr == ifa->ifa_address)
-				return;
-		}
+	if (in_dev)
+		addr = inet_confirm_addr(in_dev, 0, 0, RT_SCOPE_HOST);
 
-		cur = kzalloc(sizeof(struct nx_vlan_ip_list), GFP_ATOMIC);
-		if (cur == NULL) {
-			printk(KERN_ERR "%s: failed to add vlan ip to list\n",
-					adapter->netdev->name);
-			return;
-		}
-
-		cur->ip_addr = ifa->ifa_address;
-		list_add_tail(&cur->list, &adapter->vlan_ip_list);
-		break;
-	case NX_IP_DOWN:
-		list_for_each_entry_safe(cur, tmp_cur,
-					&adapter->vlan_ip_list, list) {
-			if (cur->ip_addr == ifa->ifa_address) {
-				list_del(&cur->list);
-				kfree(cur);
-				break;
-			}
-		}
-	}
+	rcu_read_unlock();
+	return addr;
 }
+
 static void
 netxen_config_indev_addr(struct netxen_adapter *adapter,
 		struct net_device *dev, unsigned long event)
@@ -3213,12 +3167,10 @@ netxen_config_indev_addr(struct netxen_adapter *adapter,
 		case NETDEV_UP:
 			netxen_config_ipaddr(adapter,
 					ifa->ifa_address, NX_IP_UP);
-			netxen_list_config_vlan_ip(adapter, ifa, NX_IP_UP);
 			break;
 		case NETDEV_DOWN:
 			netxen_config_ipaddr(adapter,
 					ifa->ifa_address, NX_IP_DOWN);
-			netxen_list_config_vlan_ip(adapter, ifa, NX_IP_DOWN);
 			break;
 		default:
 			break;
@@ -3233,15 +3185,54 @@ netxen_restore_indev_addr(struct net_device *netdev, unsigned long event)
 
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
-	struct nx_vlan_ip_list *pos, *tmp_pos;
+	struct net_device *vlan_dev, *real_dev;
 	unsigned long ip_event;
+	__be32 addr = 0;
 
 	ip_event = (event == NETDEV_UP) ? NX_IP_UP : NX_IP_DOWN;
 	netxen_config_indev_addr(adapter, netdev, event);
 
-	list_for_each_entry_safe(pos, tmp_pos, &adapter->vlan_ip_list, list) {
-		netxen_config_ipaddr(adapter, pos->ip_addr, ip_event);
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, vlan_dev) {
+		if (vlan_dev->priv_flags & IFF_802_1Q_VLAN) {
+			real_dev = vlan_dev_real_dev(vlan_dev);
+
+			if (real_dev == netdev) {
+				addr = netxen_get_addr(vlan_dev);
+
+				if (addr) {
+					netxen_config_ipaddr(adapter, addr,
+							     ip_event);
+				}
+			}
+		}
 	}
+
+	if (netdev->master) {
+		addr = netxen_get_addr(netdev->master);
+		if (addr)
+			netxen_config_ipaddr(adapter, addr, ip_event);
+	}
+	rcu_read_unlock();
+}
+
+static inline int
+netxen_config_checkdev(struct net_device *dev)
+{
+	struct netxen_adapter *adapter;
+
+	if (!is_netxen_netdev(dev))
+		return -ENODEV;
+
+	adapter = netdev_priv(dev);
+
+	if (!adapter)
+		return -ENODEV;
+
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		return -ENODEV;
+
+	return 0;
 }
 
 static int netxen_netdev_event(struct notifier_block *this,
@@ -3260,18 +3251,26 @@ recheck:
 		goto recheck;
 	}
 
-	if (!is_netxen_netdev(dev))
-		goto done;
+	/* If this is a bonding device, look for netxen-based slaves*/
+	if (dev->priv_flags & IFF_BONDING) {
+		struct net_device *slave;
 
-	adapter = netdev_priv(dev);
+		rcu_read_lock();
+		for_each_netdev_in_bond_rcu(dev, slave) {
+			if (netxen_config_checkdev(slave) < 0)
+				continue;
 
-	if (!adapter)
-		goto done;
-
-	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
-		goto done;
+			adapter = netdev_priv(slave);
+			netxen_config_indev_addr(adapter, orig_dev, event);
+		}
+		rcu_read_unlock();
+	} else {
+		if (netxen_config_checkdev(dev) < 0)
+			goto done;
 
-	netxen_config_indev_addr(adapter, orig_dev, event);
+		adapter = netdev_priv(dev);
+		netxen_config_indev_addr(adapter, orig_dev, event);
+	}
 done:
 	return NOTIFY_DONE;
 }
@@ -3282,10 +3281,11 @@ netxen_inetaddr_event(struct notifier_block *this,
 {
 	struct netxen_adapter *adapter;
 	struct net_device *dev;
-
+	unsigned long ip_event;
 	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
 
 	dev = ifa->ifa_dev ? ifa->ifa_dev->dev : NULL;
+	ip_event = (event == NETDEV_UP) ? NX_IP_UP : NX_IP_DOWN;
 
 recheck:
 	if (dev == NULL)
@@ -3296,30 +3296,35 @@ recheck:
 		goto recheck;
 	}
 
-	if (!is_netxen_netdev(dev))
-		goto done;
+	/* If this is a bonding device, look for netxen-based slaves*/
+	if (dev->priv_flags & IFF_BONDING) {
+		struct net_device *slave;
 
-	adapter = netdev_priv(dev);
+		rcu_read_lock();
+		for_each_netdev_in_bond_rcu(dev, slave) {
+			if (netxen_config_checkdev(slave) < 0)
+				continue;
 
-	if (!adapter || !netxen_destip_supported(adapter))
-		goto done;
+			adapter = netdev_priv(slave);
 
-	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
-		goto done;
+			if (!netxen_destip_supported(adapter))
+				continue;
 
-	switch (event) {
-	case NETDEV_UP:
-		netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_UP);
-		netxen_list_config_vlan_ip(adapter, ifa, NX_IP_UP);
-		break;
-	case NETDEV_DOWN:
-		netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_DOWN);
-		netxen_list_config_vlan_ip(adapter, ifa, NX_IP_DOWN);
-		break;
-	default:
-		break;
-	}
+			netxen_config_ipaddr(adapter, ifa->ifa_address,
+					     ip_event);
+		}
+		rcu_read_unlock();
+	} else {
+		if (netxen_config_checkdev(dev) < 0)
+			goto done;
+
+		adapter = netdev_priv(dev);
 
+		if (!netxen_destip_supported(adapter))
+			goto done;
+
+		netxen_config_ipaddr(adapter, ifa->ifa_address, ip_event);
+	}
 done:
 	return NOTIFY_DONE;
 }
@@ -3335,9 +3340,6 @@ static struct notifier_block netxen_inetaddr_cb = {
 static void
 netxen_restore_indev_addr(struct net_device *dev, unsigned long event)
 { }
-static void
-netxen_free_vlan_ip_list(struct netxen_adapter *adapter)
-{ }
 #endif
 
 static struct pci_error_handlers netxen_err_handler = {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 59dc05f3..463bb40 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1578,6 +1578,9 @@ extern rwlock_t				dev_base_lock;		/* Device list lock */
 		list_for_each_entry_continue(d, &(net)->dev_base_head, dev_list)
 #define for_each_netdev_continue_rcu(net, d)		\
 	list_for_each_entry_continue_rcu(d, &(net)->dev_base_head, dev_list)
+#define for_each_netdev_in_bond_rcu(bond, slave)	\
+	for_each_netdev_rcu(&init_net, slave)		\
+		if (slave->master == bond)
 #define net_device_entry(lh)	list_entry(lh, struct net_device, dev_list)
 
 static inline struct net_device *next_net_device(struct net_device *dev)
-- 
1.7.11.4
