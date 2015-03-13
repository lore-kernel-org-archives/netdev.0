From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v2 1/3] switchdev: fix stp update API to work with layered netdevices
Date: Thu, 12 Mar 2015 17:29:56 -0700
Message-ID: <1426206598-29410-2-git-send-email-roopa@cumulusnetworks.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: sfeldma@gmail.com, jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:38901 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710AbbCMAaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 20:30:10 -0400
Received: by pabrd3 with SMTP id rd3so24751892pab.5
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 17:30:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

make it same as the netdev_switch_port_bridge_setlink/dellink
api (ie traverse lowerdevs to get to the switch port).

removes "WARN_ON(!ops->ndo_switch_parent_id_get)" because bridge ports
can be bonds and teams which might not implement this ndo.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/net/switchdev.h   |    1 +
 net/switchdev/switchdev.c |   30 +++++++++++++++++++++++++++++-
 2 files changed, 30 insertions(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 1a9382f..ccfe2bb 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -57,6 +57,7 @@ int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 			       u8 tos, u8 type, u32 tb_id);
 void netdev_switch_fib_ipv4_abort(struct fib_info *fi);
+int ndo_dflt_netdev_switch_port_stp_update(struct net_device *dev, u8 state);
 
 #else
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index b7a2313..e0e491f 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -50,7 +50,7 @@ int netdev_switch_port_stp_update(struct net_device *dev, u8 state)
 
 	if (!ops->ndo_switch_port_stp_update)
 		return -EOPNOTSUPP;
-	WARN_ON(!ops->ndo_switch_parent_id_get);
+
 	return ops->ndo_switch_port_stp_update(dev, state);
 }
 EXPORT_SYMBOL_GPL(netdev_switch_port_stp_update);
@@ -393,3 +393,31 @@ void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
 	fi->fib_net->ipv4.fib_offload_disabled = true;
 }
 EXPORT_SYMBOL_GPL(netdev_switch_fib_ipv4_abort);
+
+/**
+ *	ndo_dflt_netdev_switch_port_stp_update - default ndo bridge port
+ *						 stp update function
+ *
+ *	@dev: port device
+ *	@state: bridge stp state
+ *
+ *	Propagate stp updates through lowerdevs
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
