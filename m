From: roopa@cumulusnetworks.com
Subject: [PATCH net-next 1/3] switchdev: fix stp update API to work with layered netdevices
Date: Thu,  5 Mar 2015 20:04:16 -0800
Message-ID: <1425614658-43701-2-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: sfeldma@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:39980 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417AbbCFEE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 23:04:26 -0500
Received: by pdbfp1 with SMTP id fp1so34666898pdb.7
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 20:04:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

make it same as the netdev_switch_port_bridge_setlink/dellink
api (ie traverse lowerdevs to get to the switch port).

removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because bridge ports
can be bonds and teams which might not implement this ndo.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/switchdev.h   |    7 +++++++
 net/switchdev/switchdev.c |   30 +++++++++++++++++++++++++++++-
 2 files changed, 36 insertions(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index cfcdac2..a93279b 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -51,6 +51,7 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
 					       struct nlmsghdr *nlh, u16 flags);
 int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
 					       struct nlmsghdr *nlh, u16 flags);
+int ndo_dflt_netdev_switch_port_stp_update(struct net_device *dev, u8 state);
 #else
 
 static inline int netdev_switch_parent_id_get(struct net_device *dev,
@@ -109,6 +110,12 @@ static inline int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *
 	return 0;
 }
 
+static inline int ndo_dflt_netdev_switch_port_stp_update(struct net_device *dev,
+							 u8 state)
+{
+	return 0;
+}
+
 #endif
 
 #endif /* _LINUX_SWITCHDEV_H_ */
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 8c1e558..4316eb5 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -48,7 +48,7 @@ int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
 
 	if (!ops->ndo_switch_port_stp_update)
 		return -EOPNOTSUPP;
-	WARN_ON(!ops->ndo_switch_parent_id_get);
+
 	return ops->ndo_switch_port_stp_update(dev, state);
 }
 EXPORT_SYMBOL(netdev_switch_port_stp_update);
@@ -225,3 +225,31 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
 	return ret;
 }
 EXPORT_SYMBOL(ndo_dflt_netdev_switch_port_bridge_dellink);
+
+/**
+ *	ndo_dflt_netdev_switch_port_stp_update - default ndo bridge port
+ *						 stp update function
+ *
+ *	@dev: port device
+ *	@state: bridge stp state
+ *
+ *	Notify master device slaves of bridge port stp state updates
+ */
+int ndo_dflt_netdev_switch_port_stp_update(struct net_device *dev, u8 state)
+{
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int ret = 0, err = 0;
+
+	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
+		return ret;
+
+	netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = netdev_switch_port_stp_update(lower_dev, state);
+		if (err && err != -EOPNOTSUPP)
+			ret = err;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(ndo_dflt_netdev_switch_port_stp_update);
-- 
1.7.10.4
