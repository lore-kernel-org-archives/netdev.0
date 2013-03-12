From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next v3] netxen: write IP address to firmware when using bonding
Date: Tue, 12 Mar 2013 13:49:01 +0100
Message-ID: <1363092541-12391-1-git-send-email-nikolay@redhat.com>
Cc: rajesh.borundia@qlogic.com, davem@davemloft.net,
	agospoda@redhat.com, sony.chacko@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17845 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754683Ab3CLMvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Mar 2013 08:51:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows LRO aggregation on bonded devices that contain an
NX3031 device. It also adds a for_each_netdev_in_bond_rcu(bond, slave)
macro which executes for each slave that has bond as master.

V3: After testing and discussing this with Rajesh, I decided to keep the
    vlan ip cache and just rename it to ip_cache since it will store bond
    ip addresses too. A new master flag has been added to the ip cache to
    denote that the address has been added because of a master device.
    I've taken care of the enslave/release cases by checking for various 
    combinations of events and flags (e.g. netxen has a master, it's a 
    bond master and it's not marked as a slave means it is being enslaved
    and is dev_open()ed in bond_enslave).
    I've changed netxen_free_ip_list() to have a "master" parameter which
    causes all IP addresses marked as master to be deleted (used when a
    netxen is being released). I've made the patch use the new upper
    device API as well. The following cases were tested:
    - bond -> netxen
    - vlan -> netxen
    - vlan -> bond -> netxen

V2: Remove local ip caching, retrieve addresses dynamically and
    restore them if necessary.

Note: Tested with NX3031 adapter.

Tested-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Andy Gospodarek <agospoda@redhat.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |   5 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   | 220 ++++++++++++++-------
 include/linux/netdevice.h                          |   8 +
 3 files changed, 155 insertions(+), 78 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index eb3dfdb..322a36b 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -955,9 +955,10 @@ typedef struct nx_mac_list_s {
 	uint8_t mac_addr[ETH_ALEN+2];
 } nx_mac_list_t;
 
-struct nx_vlan_ip_list {
+struct nx_ip_list {
 	struct list_head list;
 	__be32 ip_addr;
+	bool master;
 };
 
 /*
@@ -1605,7 +1606,7 @@ struct netxen_adapter {
 	struct net_device *netdev;
 	struct pci_dev *pdev;
 	struct list_head mac_list;
-	struct list_head vlan_ip_list;
+	struct list_head ip_list;
 
 	spinlock_t tx_clean_lock;
 
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 501f492..7867aeb 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -90,7 +90,7 @@ static irqreturn_t netxen_intr(int irq, void *data);
 static irqreturn_t netxen_msi_intr(int irq, void *data);
 static irqreturn_t netxen_msix_intr(int irq, void *data);
 
-static void netxen_free_vlan_ip_list(struct netxen_adapter *);
+static void netxen_free_ip_list(struct netxen_adapter *, bool);
 static void netxen_restore_indev_addr(struct net_device *dev, unsigned long);
 static struct rtnl_link_stats64 *netxen_nic_get_stats(struct net_device *dev,
 						      struct rtnl_link_stats64 *stats);
@@ -1450,7 +1450,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	spin_lock_init(&adapter->tx_clean_lock);
 	INIT_LIST_HEAD(&adapter->mac_list);
-	INIT_LIST_HEAD(&adapter->vlan_ip_list);
+	INIT_LIST_HEAD(&adapter->ip_list);
 
 	err = netxen_setup_pci_map(adapter);
 	if (err)
@@ -1585,7 +1585,7 @@ static void netxen_nic_remove(struct pci_dev *pdev)
 
 	cancel_work_sync(&adapter->tx_timeout_task);
 
-	netxen_free_vlan_ip_list(adapter);
+	netxen_free_ip_list(adapter, false);
 	netxen_nic_detach(adapter);
 
 	nx_decr_dev_ref_cnt(adapter);
@@ -3137,62 +3137,77 @@ netxen_destip_supported(struct netxen_adapter *adapter)
 }
 
 static void
-netxen_free_vlan_ip_list(struct netxen_adapter *adapter)
+netxen_free_ip_list(struct netxen_adapter *adapter, bool master)
 {
-	struct nx_vlan_ip_list  *cur;
-	struct list_head *head = &adapter->vlan_ip_list;
+	struct nx_ip_list  *cur, *tmp_cur;
 
-	while (!list_empty(head)) {
-		cur = list_entry(head->next, struct nx_vlan_ip_list, list);
-		netxen_config_ipaddr(adapter, cur->ip_addr, NX_IP_DOWN);
-		list_del(&cur->list);
-		kfree(cur);
+	list_for_each_entry_safe(cur, tmp_cur, &adapter->ip_list, list) {
+		if (master) {
+			if (cur->master) {
+				netxen_config_ipaddr(adapter, cur->ip_addr,
+						     NX_IP_DOWN);
+				list_del(&cur->list);
+				kfree(cur);
+			}
+		} else {
+			netxen_config_ipaddr(adapter, cur->ip_addr, NX_IP_DOWN);
+			list_del(&cur->list);
+			kfree(cur);
+		}
 	}
-
 }
-static void
-netxen_list_config_vlan_ip(struct netxen_adapter *adapter,
+
+static bool
+netxen_list_config_ip(struct netxen_adapter *adapter,
 		struct in_ifaddr *ifa, unsigned long event)
 {
 	struct net_device *dev;
-	struct nx_vlan_ip_list *cur, *tmp_cur;
+	struct nx_ip_list *cur, *tmp_cur;
 	struct list_head *head;
+	bool ret = false;
 
 	dev = ifa->ifa_dev ? ifa->ifa_dev->dev : NULL;
 
 	if (dev == NULL)
-		return;
-
-	if (!is_vlan_dev(dev))
-		return;
+		goto out;
 
 	switch (event) {
 	case NX_IP_UP:
-		list_for_each(head, &adapter->vlan_ip_list) {
-			cur = list_entry(head, struct nx_vlan_ip_list, list);
+		list_for_each(head, &adapter->ip_list) {
+			cur = list_entry(head, struct nx_ip_list, list);
 
 			if (cur->ip_addr == ifa->ifa_address)
-				return;
+				goto out;
 		}
 
-		cur = kzalloc(sizeof(struct nx_vlan_ip_list), GFP_ATOMIC);
+		cur = kzalloc(sizeof(struct nx_ip_list), GFP_ATOMIC);
 		if (cur == NULL)
-			return;
-
+			goto out;
+		if (dev->priv_flags & IFF_802_1Q_VLAN)
+			dev = vlan_dev_real_dev(dev);
+		cur->master = !!netif_is_bond_master(dev);
 		cur->ip_addr = ifa->ifa_address;
-		list_add_tail(&cur->list, &adapter->vlan_ip_list);
+		list_add_tail(&cur->list, &adapter->ip_list);
+		netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_UP);
+		ret = true;
 		break;
 	case NX_IP_DOWN:
 		list_for_each_entry_safe(cur, tmp_cur,
-					&adapter->vlan_ip_list, list) {
+					&adapter->ip_list, list) {
 			if (cur->ip_addr == ifa->ifa_address) {
 				list_del(&cur->list);
 				kfree(cur);
+				netxen_config_ipaddr(adapter, ifa->ifa_address,
+						     NX_IP_DOWN);
+				ret = true;
 				break;
 			}
 		}
 	}
+out:
+	return ret;
 }
+
 static void
 netxen_config_indev_addr(struct netxen_adapter *adapter,
 		struct net_device *dev, unsigned long event)
@@ -3209,14 +3224,10 @@ netxen_config_indev_addr(struct netxen_adapter *adapter,
 	for_ifa(indev) {
 		switch (event) {
 		case NETDEV_UP:
-			netxen_config_ipaddr(adapter,
-					ifa->ifa_address, NX_IP_UP);
-			netxen_list_config_vlan_ip(adapter, ifa, NX_IP_UP);
+			netxen_list_config_ip(adapter, ifa, NX_IP_UP);
 			break;
 		case NETDEV_DOWN:
-			netxen_config_ipaddr(adapter,
-					ifa->ifa_address, NX_IP_DOWN);
-			netxen_list_config_vlan_ip(adapter, ifa, NX_IP_DOWN);
+			netxen_list_config_ip(adapter, ifa, NX_IP_DOWN);
 			break;
 		default:
 			break;
@@ -3231,23 +3242,78 @@ netxen_restore_indev_addr(struct net_device *netdev, unsigned long event)
 
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
-	struct nx_vlan_ip_list *pos, *tmp_pos;
+	struct nx_ip_list *pos, *tmp_pos;
 	unsigned long ip_event;
 
 	ip_event = (event == NETDEV_UP) ? NX_IP_UP : NX_IP_DOWN;
 	netxen_config_indev_addr(adapter, netdev, event);
 
-	list_for_each_entry_safe(pos, tmp_pos, &adapter->vlan_ip_list, list) {
+	list_for_each_entry_safe(pos, tmp_pos, &adapter->ip_list, list) {
 		netxen_config_ipaddr(adapter, pos->ip_addr, ip_event);
 	}
 }
 
+static inline bool
+netxen_config_checkdev(struct net_device *dev)
+{
+	struct netxen_adapter *adapter;
+
+	if (!is_netxen_netdev(dev))
+		return false;
+	adapter = netdev_priv(dev);
+	if (!adapter)
+		return false;
+	if (!netxen_destip_supported(adapter))
+		return false;
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		return false;
+
+	return true;
+}
+
+/**
+ * netxen_config_master - configure addresses based on master
+ * @dev: netxen device
+ * @event: netdev event
+ */
+static void netxen_config_master(struct net_device *dev, unsigned long event)
+{
+	struct net_device *master, *slave;
+	struct netxen_adapter *adapter = netdev_priv(dev);
+
+	rcu_read_lock();
+	master = netdev_master_upper_dev_get_rcu(dev);
+	/*
+	 * This is the case where the netxen nic is being
+	 * enslaved and is dev_open()ed in bond_enslave()
+	 * Now we should program the bond's (and its vlans')
+	 * addresses in the netxen NIC.
+	 */
+	if (master && netif_is_bond_master(master) &&
+	    !netif_is_bond_slave(dev)) {
+		netxen_config_indev_addr(adapter, master, event);
+		for_each_netdev_rcu(&init_net, slave)
+			if (slave->priv_flags & IFF_802_1Q_VLAN &&
+			    vlan_dev_real_dev(slave) == master)
+				netxen_config_indev_addr(adapter, slave, event);
+	}
+	rcu_read_unlock();
+	/*
+	 * This is the case where the netxen nic is being
+	 * released and is dev_close()ed in bond_release()
+	 * just before IFF_BONDING is stripped.
+	 */
+	if (!master && dev->priv_flags & IFF_BONDING)
+		netxen_free_ip_list(adapter, true);
+}
+
 static int netxen_netdev_event(struct notifier_block *this,
 				 unsigned long event, void *ptr)
 {
 	struct netxen_adapter *adapter;
 	struct net_device *dev = (struct net_device *)ptr;
 	struct net_device *orig_dev = dev;
+	struct net_device *slave;
 
 recheck:
 	if (dev == NULL)
@@ -3257,19 +3323,28 @@ recheck:
 		dev = vlan_dev_real_dev(dev);
 		goto recheck;
 	}
-
-	if (!is_netxen_netdev(dev))
-		goto done;
-
-	adapter = netdev_priv(dev);
-
-	if (!adapter)
-		goto done;
-
-	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
-		goto done;
-
-	netxen_config_indev_addr(adapter, orig_dev, event);
+	if (event == NETDEV_UP || event == NETDEV_DOWN) {
+		/* If this is a bonding device, look for netxen-based slaves*/
+		if (netif_is_bond_master(dev)) {
+			rcu_read_lock();
+			for_each_netdev_in_bond_rcu(dev, slave) {
+				if (!netxen_config_checkdev(slave))
+					continue;
+				adapter = netdev_priv(slave);
+				netxen_config_indev_addr(adapter,
+							 orig_dev, event);
+			}
+			rcu_read_unlock();
+		} else {
+			if (!netxen_config_checkdev(dev))
+				goto done;
+			adapter = netdev_priv(dev);
+			/* Act only if the actual netxen is the target */
+			if (orig_dev == dev)
+				netxen_config_master(dev, event);
+			netxen_config_indev_addr(adapter, orig_dev, event);
+		}
+	}
 done:
 	return NOTIFY_DONE;
 }
@@ -3279,12 +3354,12 @@ netxen_inetaddr_event(struct notifier_block *this,
 		unsigned long event, void *ptr)
 {
 	struct netxen_adapter *adapter;
-	struct net_device *dev;
-
+	struct net_device *dev, *slave;
 	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
+	unsigned long ip_event;
 
 	dev = ifa->ifa_dev ? ifa->ifa_dev->dev : NULL;
-
+	ip_event = (event == NETDEV_UP) ? NX_IP_UP : NX_IP_DOWN;
 recheck:
 	if (dev == NULL)
 		goto done;
@@ -3293,31 +3368,24 @@ recheck:
 		dev = vlan_dev_real_dev(dev);
 		goto recheck;
 	}
-
-	if (!is_netxen_netdev(dev))
-		goto done;
-
-	adapter = netdev_priv(dev);
-
-	if (!adapter || !netxen_destip_supported(adapter))
-		goto done;
-
-	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
-		goto done;
-
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
+	if (event == NETDEV_UP || event == NETDEV_DOWN) {
+		/* If this is a bonding device, look for netxen-based slaves*/
+		if (netif_is_bond_master(dev)) {
+			rcu_read_lock();
+			for_each_netdev_in_bond_rcu(dev, slave) {
+				if (!netxen_config_checkdev(slave))
+					continue;
+				adapter = netdev_priv(slave);
+				netxen_list_config_ip(adapter, ifa, ip_event);
+			}
+			rcu_read_unlock();
+		} else {
+			if (!netxen_config_checkdev(dev))
+				goto done;
+			adapter = netdev_priv(dev);
+			netxen_list_config_ip(adapter, ifa, ip_event);
+		}
 	}
-
 done:
 	return NOTIFY_DONE;
 }
@@ -3334,7 +3402,7 @@ static void
 netxen_restore_indev_addr(struct net_device *dev, unsigned long event)
 { }
 static void
-netxen_free_vlan_ip_list(struct netxen_adapter *adapter)
+netxen_free_ip_list(struct netxen_adapter *adapter, bool master)
 { }
 #endif
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e1ebeff..9fc1ab0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1617,6 +1617,9 @@ extern seqcount_t	devnet_rename_seq;	/* Device rename seq */
 		list_for_each_entry_continue(d, &(net)->dev_base_head, dev_list)
 #define for_each_netdev_continue_rcu(net, d)		\
 	list_for_each_entry_continue_rcu(d, &(net)->dev_base_head, dev_list)
+#define for_each_netdev_in_bond_rcu(bond, slave)	\
+		for_each_netdev_rcu(&init_net, slave)	\
+			if (netdev_master_upper_dev_get_rcu(slave) == bond)
 #define net_device_entry(lh)	list_entry(lh, struct net_device, dev_list)
 
 static inline struct net_device *next_net_device(struct net_device *dev)
@@ -2774,6 +2777,11 @@ static inline void netif_set_gso_max_size(struct net_device *dev,
 	dev->gso_max_size = size;
 }
 
+static inline bool netif_is_bond_master(struct net_device *dev)
+{
+	return dev->flags & IFF_MASTER && dev->priv_flags & IFF_BONDING;
+}
+
 static inline bool netif_is_bond_slave(struct net_device *dev)
 {
 	return dev->flags & IFF_SLAVE && dev->priv_flags & IFF_BONDING;
-- 
1.7.11.7
