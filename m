From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next] netxen: write IP address to firmware when using bonding
Date: Tue, 25 Sep 2012 10:48:03 +0200
Message-ID: <1348562883-14780-1-git-send-email-nikolay@redhat.com>
Cc: netdev@vger.kernel.org, agospoda@redhat.com,
	rajesh.borundia@qlogic.com, davem@davemloft.net
To: sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42811 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753626Ab2IYItQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Sep 2012 04:49:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <naleksan@redhat.com>

This patch allows LRO aggregation on bonded devices that contain an NX3031
device. It also adds a for_each_netdev_in_bond_rcu(bond, slave) macro
which executes for each slave that has bond as master.

Signed-off-by: Andy Gospodarek <agospoda@redhat.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   | 113 +++++++++++++++------
 include/linux/netdevice.h                          |   3 +
 2 files changed, 87 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index e2a4858..aaf6cf7 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -3244,6 +3244,25 @@ netxen_restore_indev_addr(struct net_device *netdev, unsigned long event)
 	}
 }
 
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
+	if(!adapter)
+		return -ENODEV;
+
+	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+		return -ENODEV;
+
+	return 0;
+}
+
 static int netxen_netdev_event(struct notifier_block *this,
 				 unsigned long event, void *ptr)
 {
@@ -3260,18 +3279,27 @@ recheck:
 		goto recheck;
 	}
 
-	if (!is_netxen_netdev(dev))
-		goto done;
-
-	adapter = netdev_priv(dev);
-
-	if (!adapter)
-		goto done;
+	/* If this is a bonding device, look for netxen-based slaves*/
+	if (dev->priv_flags & IFF_BONDING) {
+		struct net_device *slave;
 
-	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
-		goto done;
+		rcu_read_lock();
+		for_each_netdev_in_bond_rcu(dev, slave) {
+			if (netxen_config_checkdev(slave) < 0)
+				continue;
+			
+			adapter = netdev_priv(slave);
+			netxen_config_indev_addr(adapter, orig_dev, event);
+		}
+		rcu_read_unlock();
 
-	netxen_config_indev_addr(adapter, orig_dev, event);
+	} else {
+		if (netxen_config_checkdev(dev) < 0)
+			goto done;
+		
+		adapter = netdev_priv(dev);
+		netxen_config_indev_addr(adapter, orig_dev, event);
+	}
 done:
 	return NOTIFY_DONE;
 }
@@ -3296,30 +3324,57 @@ recheck:
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
+			switch (event) {
+			case NETDEV_UP:
+				netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_UP);
+				netxen_list_config_vlan_ip(adapter, ifa, NX_IP_UP);
+				break;
+			case NETDEV_DOWN:
+				netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_DOWN);
+				netxen_list_config_vlan_ip(adapter, ifa, NX_IP_DOWN);
+				break;
+			default:
+				break;
+			}
+		}
+		rcu_read_unlock();
 
+	} else {
+		if (netxen_config_checkdev(dev) < 0)
+			goto done;
+
+		adapter = netdev_priv(dev);
+
+		if (!netxen_destip_supported(adapter))
+			goto done;
+
+		switch (event) {
+		case NETDEV_UP:
+			netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_UP);
+			netxen_list_config_vlan_ip(adapter, ifa, NX_IP_UP);
+			break;
+		case NETDEV_DOWN:
+			netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_DOWN);
+			netxen_list_config_vlan_ip(adapter, ifa, NX_IP_DOWN);
+			break;
+		default:
+			break;
+		}
+	}
 done:
 	return NOTIFY_DONE;
 }
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
