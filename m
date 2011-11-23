From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next] netxen: write IP address to firmware when using bonding
Date: Wed, 23 Nov 2011 13:43:11 -0500
Message-ID: <1322073791-15223-1-git-send-email-andy@greyhouse.net>
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59813 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321Ab1KWSk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 13:40:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch was added to enable NX3031 devices to properly
aggregate frames for LRO:

	commit 6598b169b856793f8f9b80a3f3c5a48f5eaf40e3
	Author: Dhananjay Phadke <dhananjay@netxen.com>
	Date:   Sun Jul 26 20:07:37 2009 +0000

	    netxen: enable ip addr hashing

This patch is a followup to that fix as it allows LRO aggregation on
bonded devices that contain an NX3031 device.  This was tested on an
older distro and modified slightly to the latest upstream.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |  119 +++++++++++++++-----
 1 files changed, 92 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 7dd9a4b..64eb618 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -3038,18 +3038,45 @@ recheck:
 		goto recheck;
 	}
 
-	if (!is_netxen_netdev(dev))
-		goto done;
+	/* If this is a bonding device, look for netxen-based slaves*/
+	if (dev->priv_flags & IFF_BONDING) {
+		struct net_device *slave;
 
-	adapter = netdev_priv(dev);
+		rcu_read_lock();
+		for_each_netdev_rcu(&init_net, slave) {
+			/* check to see if the device is in the bond */
+			if (slave->master == dev) {
 
-	if (!adapter)
-		goto done;
+				if (!is_netxen_netdev(slave))
+					continue;
 
-	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
-		goto done;
+				adapter = netdev_priv(slave);
+
+				if (!adapter)
+					continue;
+
+				if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+					continue;
+
+				netxen_config_indev_addr(adapter, orig_dev, event);
+			}
+		}
+		rcu_read_unlock();
+
+	} else {
+		if (!is_netxen_netdev(dev))
+			goto done;
+
+		adapter = netdev_priv(dev);
 
-	netxen_config_indev_addr(adapter, orig_dev, event);
+		if (!adapter)
+			goto done;
+
+		if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+			goto done;
+
+		netxen_config_indev_addr(adapter, orig_dev, event);
+	}
 done:
 	return NOTIFY_DONE;
 }
@@ -3074,30 +3101,68 @@ recheck:
 		goto recheck;
 	}
 
-	if (!is_netxen_netdev(dev))
-		goto done;
+	/* If this is a bonding device, look for netxen-based slaves*/
+	if (dev->priv_flags & IFF_BONDING) {
+		struct net_device *slave;
 
-	adapter = netdev_priv(dev);
+		rcu_read_lock();
+		for_each_netdev_rcu(&init_net, slave) {
+			/* check to see if the device is in the bond */
+			if (slave->master == dev) {
 
-	if (!adapter || !netxen_destip_supported(adapter))
-		goto done;
+				if (!is_netxen_netdev(slave))
+					continue;
 
-	if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
-		goto done;
+				adapter = netdev_priv(slave);
 
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
+				if (!adapter || !netxen_destip_supported(adapter))
+					continue;
+
+				if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
+					continue;
+
+				switch (event) {
+				case NETDEV_UP:
+					netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_UP);
+					netxen_list_config_vlan_ip(adapter, ifa, NX_IP_UP);
+					break;
+				case NETDEV_DOWN:
+					netxen_config_ipaddr(adapter, ifa->ifa_address, NX_IP_DOWN);
+					netxen_list_config_vlan_ip(adapter, ifa, NX_IP_DOWN);
+					break;
+				default:
+					break;
+				}
+			}
+		}
+		rcu_read_unlock();
+
+	} else {
+
+		if (!is_netxen_netdev(dev))
+			goto done;
+
+		adapter = netdev_priv(dev);
+
+		if (!adapter || !netxen_destip_supported(adapter))
+			goto done;
 
+		if (adapter->is_up != NETXEN_ADAPTER_UP_MAGIC)
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
-- 
1.7.4.4
