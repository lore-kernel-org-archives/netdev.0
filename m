From: sfeldma@gmail.com
Subject: [PATCH net-next v2 18/26] switchdev: remove unused netdev_switch_port_bridge_dellink
Date: Wed,  1 Apr 2015 03:07:54 -0700
Message-ID: <1427882882-2533-19-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35720 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114AbbDAKGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:48 -0400
Received: by pddn5 with SMTP id n5so50338004pdd.2
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:48 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Now we can remove old wrappers for dellink.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   18 ---------------
 net/bridge/br_netlink.c   |   12 +---------
 net/switchdev/switchdev.c |   55 ---------------------------------------------
 3 files changed, 1 insertion(+), 84 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 60b83b0..9147a35 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -121,10 +121,6 @@ int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
 int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
 				 struct netdev_switch_notifier_info *info);
-int netdev_switch_port_bridge_dellink(struct net_device *dev,
-				struct nlmsghdr *nlh, u16 flags);
-int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
-					       struct nlmsghdr *nlh, u16 flags);
 int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			       u8 tos, u8 type, u32 nlflags, u32 tb_id);
 int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
@@ -185,20 +181,6 @@ static inline int call_netdev_switch_notifiers(unsigned long val, struct net_dev
 	return NOTIFY_DONE;
 }
 
-static inline int netdev_switch_port_bridge_dellink(struct net_device *dev,
-						    struct nlmsghdr *nlh,
-						    u16 flags)
-{
-	return -EOPNOTSUPP;
-}
-
-static inline int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
-							struct nlmsghdr *nlh,
-							u16 flags)
-{
-	return 0;
-}
-
 static inline int netdev_switch_fib_ipv4_add(u32 dst, int dst_len,
 					     struct fib_info *fi,
 					     u8 tos, u8 type,
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 5deb063..cfee027 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -639,7 +639,7 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 {
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
-	int err = 0, ret_offload = 0;
+	int err = 0;
 
 	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
 	if (!afspec)
@@ -658,16 +658,6 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 		 */
 		br_ifinfo_notify(RTM_NEWLINK, p);
 
-	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
-		/* del bridge attributes in hardware
-		 */
-		ret_offload = netdev_switch_port_bridge_dellink(dev, nlh,
-								flags);
-		if (ret_offload && ret_offload != -EOPNOTSUPP)
-			br_warn(p->br, "error deleting attrs on port %u (%s)\n",
-				(unsigned int)p->port_no, p->dev->name);
-	}
-
 	return err;
 }
 static int br_validate(struct nlattr *tb[], struct nlattr *data[])
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index a720a3c..96cdee0 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -431,61 +431,6 @@ int swdev_port_bridge_dellink(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(swdev_port_bridge_dellink);
 
-/**
- *	netdev_switch_port_bridge_dellink - Notify switch device port of bridge
- *	port attribute delete
- *
- *	@dev: port device
- *	@nlh: netlink msg with bridge port attributes
- *	@flags: bridge setlink flags
- *
- *	Notify switch device port of bridge port attribute delete
- */
-int netdev_switch_port_bridge_dellink(struct net_device *dev,
-				      struct nlmsghdr *nlh, u16 flags)
-{
-	const struct net_device_ops *ops = dev->netdev_ops;
-
-	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
-		return 0;
-
-	if (!ops->ndo_bridge_dellink)
-		return -EOPNOTSUPP;
-
-	return ops->ndo_bridge_dellink(dev, nlh, flags);
-}
-EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_dellink);
-
-/**
- *	ndo_dflt_netdev_switch_port_bridge_dellink - default ndo bridge dellink
- *						     op for master devices
- *
- *	@dev: port device
- *	@nlh: netlink msg with bridge port attributes
- *	@flags: bridge dellink flags
- *
- *	Notify master device slaves of bridge port attribute deletes
- */
-int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
-					       struct nlmsghdr *nlh, u16 flags)
-{
-	struct net_device *lower_dev;
-	struct list_head *iter;
-	int ret = 0, err = 0;
-
-	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
-		return ret;
-
-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = netdev_switch_port_bridge_dellink(lower_dev, nlh, flags);
-		if (err && err != -EOPNOTSUPP)
-			ret = err;
-	}
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(ndo_dflt_netdev_switch_port_bridge_dellink);
-
 static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
 {
 	const struct swdev_ops *ops = dev->swdev_ops;
-- 
1.7.10.4
