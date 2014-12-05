From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: [PATCH net-next 3/3] net: rename *_switch_parent_id_get to *_parent_id_get
Date: Fri,  5 Dec 2014 13:02:17 -0500
Message-ID: <1417802537-20020-3-git-send-email-gospo@cumulusnetworks.com>
References: <1417802537-20020-1-git-send-email-gospo@cumulusnetworks.com>
Cc: sfeldma@gmail.com, jpirko@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:48602 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872AbaLESCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 13:02:47 -0500
In-Reply-To: <1417802537-20020-1-git-send-email-gospo@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean up ops to get parent_id for netdev by dropping 'switch' from the
names.

Signed-off-by: Andy Gospodarek <gospo@cumulusnetworks.com>
---
 Documentation/networking/switchdev.txt | 19 +++++++++----------
 drivers/net/ethernet/rocker/rocker.c   |  4 ++--
 include/linux/netdevice.h              |  2 +-
 include/net/switchdev.h                |  4 ++--
 net/core/net-sysfs.c                   |  2 +-
 net/core/rtnetlink.c                   |  2 +-
 net/switchdev/switchdev.c              | 12 ++++++------
 7 files changed, 22 insertions(+), 23 deletions(-)

diff --git a/Documentation/networking/switchdev.txt b/Documentation/networking/switchdev.txt
index f981a92..5afc1a3 100644
--- a/Documentation/networking/switchdev.txt
+++ b/Documentation/networking/switchdev.txt
@@ -46,14 +46,13 @@ of the switch chip. eth0 and eth1 are instances of some other existing driver.
 The only difference of the switch-port netdevice from the ordinary netdevice
 is that is implements couple more NDOs:
 
-  ndo_switch_parent_id_get - This returns the same ID for two port netdevices
-			     of the same physical switch chip. This is
-			     mandatory to be implemented by all switch drivers
-			     and serves the caller for recognition of a port
-			     netdevice.
-  ndo_switch_parent_* - Functions that serve for a manipulation of the switch
-			chip itself (it can be though of as a "parent" of the
-			port, therefore the name). They are not port-specific.
-			Caller might use arbitrary port netdevice of the same
-			switch and it will make no difference.
+  ndo_parent_id_get - This returns the same ID for two port netdevices of the
+		      same physical switch chip. This is mandatory to be
+		      implemented by all switch drivers and serves the caller for
+		      recognition of a port netdevice.
+  ndo_parent_* - Functions that serve for a manipulation of the switch chip
+		 itself (it can be though of as a "parent" of the port,
+		 therefore the name). They are not port-specific.  Caller might
+		 use arbitrary port netdevice of the same switch and it will
+		 make no difference.
   ndo_switch_port_* - Functions that serve for a port-specific manipulation.
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index fded127..baa2ac8 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3762,7 +3762,7 @@ static int rocker_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				       rocker_port->brport_flags, mask);
 }
 
-static int rocker_port_switch_parent_id_get(struct net_device *dev,
+static int rocker_port_parent_id_get(struct net_device *dev,
 					    struct netdev_phys_item_id *psid)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
@@ -3792,7 +3792,7 @@ static const struct net_device_ops rocker_port_netdev_ops = {
 	.ndo_fdb_dump			= rocker_port_fdb_dump,
 	.ndo_bridge_setlink		= rocker_port_bridge_setlink,
 	.ndo_bridge_getlink		= rocker_port_bridge_getlink,
-	.ndo_switch_parent_id_get	= rocker_port_switch_parent_id_get,
+	.ndo_parent_id_get		= rocker_port_parent_id_get,
 	.ndo_switch_port_stp_update	= rocker_port_switch_port_stp_update,
 };
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 29c92ee..5c384b3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1181,7 +1181,7 @@ struct net_device_ops {
 	bool			(*ndo_gso_check) (struct sk_buff *skb,
 						  struct net_device *dev);
 #ifdef CONFIG_NET_SWITCHDEV
-	int			(*ndo_switch_parent_id_get)(struct net_device *dev,
+	int			(*ndo_parent_id_get)(struct net_device *dev,
 							    struct netdev_phys_item_id *psid);
 	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
 							      u8 state);
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 8a6d164..a16502c 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -14,13 +14,13 @@
 
 #ifdef CONFIG_NET_SWITCHDEV
 
-int netdev_switch_parent_id_get(struct net_device *dev,
+int netdev_parent_id_get(struct net_device *dev,
 				struct netdev_phys_item_id *psid);
 int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
 
 #else
 
-static inline int netdev_switch_parent_id_get(struct net_device *dev,
+static inline int netdev_parent_id_get(struct net_device *dev,
 					      struct netdev_phys_item_id *psid)
 {
 	return -EOPNOTSUPP;
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 9993412..a9e27ef 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -429,7 +429,7 @@ static ssize_t phys_switch_id_show(struct device *dev,
 	if (dev_isalive(netdev)) {
 		struct netdev_phys_item_id ppid;
 
-		ret = netdev_switch_parent_id_get(netdev, &ppid);
+		ret = netdev_parent_id_get(netdev, &ppid);
 		if (!ret)
 			ret = sprintf(buf, "%*phN\n", ppid.id_len, ppid.id);
 	}
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1fe0a16..37bd62f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -975,7 +975,7 @@ static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
 	int err;
 	struct netdev_phys_item_id psid;
 
-	err = netdev_switch_parent_id_get(dev, &psid);
+	err = netdev_parent_id_get(dev, &psid);
 	if (err) {
 		if (err == -EOPNOTSUPP)
 			return 0;
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index d162b21..c3e8fb28 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -15,22 +15,22 @@
 #include <net/switchdev.h>
 
 /**
- *	netdev_switch_parent_id_get - Get ID of a switch
+ *	netdev_switch_id_get - Get ID of a switch
  *	@dev: port device
  *	@psid: switch ID
  *
  *	Get ID of a switch this port is part of.
  */
-int netdev_switch_parent_id_get(struct net_device *dev,
+int netdev_parent_id_get(struct net_device *dev,
 				struct netdev_phys_item_id *psid)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
 
-	if (!ops->ndo_switch_parent_id_get)
+	if (!ops->ndo_parent_id_get)
 		return -EOPNOTSUPP;
-	return ops->ndo_switch_parent_id_get(dev, psid);
+	return ops->ndo_parent_id_get(dev, psid);
 }
-EXPORT_SYMBOL(netdev_switch_parent_id_get);
+EXPORT_SYMBOL(netdev_parent_id_get);
 
 /**
  *	netdev_switch_port_stp_update - Notify switch device port of STP
@@ -46,7 +46,7 @@ int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
 
 	if (!ops->ndo_switch_port_stp_update)
 		return -EOPNOTSUPP;
-	WARN_ON(!ops->ndo_switch_parent_id_get);
+	WARN_ON(!ops->ndo_parent_id_get);
 	return ops->ndo_switch_port_stp_update(dev, state);
 }
 EXPORT_SYMBOL(netdev_switch_port_stp_update);
-- 
1.9.3
