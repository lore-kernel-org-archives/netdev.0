From: sfeldma@gmail.com
Subject: [PATCH net-next 11/18] switchdev: remove old netdev_switch_port_bridge_setlink
Date: Mon, 30 Mar 2015 01:40:29 -0700
Message-ID: <1427704836-8776-12-git-send-email-sfeldma@gmail.com>
References: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35952 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386AbbC3Ij5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 04:39:57 -0400
Received: by padcy3 with SMTP id cy3so160670051pad.3
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 01:39:56 -0700 (PDT)
In-Reply-To: <1427704836-8776-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

New attr-based bridge_setlink can recurse lower devs and recover on err, so
remove old wrapper.  Also, restore br_setlink back to original and don't call
into SELF port driver.  rtnetlink.c:bridge_setlink already does a call into
port driver for SELF.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   18 ---------------
 net/bridge/br_netlink.c   |   12 +---------
 net/switchdev/switchdev.c |   55 ---------------------------------------------
 3 files changed, 1 insertion(+), 84 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index bf66bcd..bad2ec7 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -92,14 +92,10 @@ int register_netdev_switch_notifier(struct notifier_block *nb);
 int unregister_netdev_switch_notifier(struct notifier_block *nb);
 int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
 				 struct netdev_switch_notifier_info *info);
-int netdev_switch_port_bridge_setlink(struct net_device *dev,
-				struct nlmsghdr *nlh, u16 flags);
 int netdev_switch_port_bridge_dellink(struct net_device *dev,
 				struct nlmsghdr *nlh, u16 flags);
 int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
 					       struct nlmsghdr *nlh, u16 flags);
-int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
-					       struct nlmsghdr *nlh, u16 flags);
 int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			       u8 tos, u8 type, u32 nlflags, u32 tb_id);
 int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
@@ -142,13 +138,6 @@ static inline int call_netdev_switch_notifiers(unsigned long val, struct net_dev
 	return NOTIFY_DONE;
 }
 
-static inline int netdev_switch_port_bridge_setlink(struct net_device *dev,
-						    struct nlmsghdr *nlh,
-						    u16 flags)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline int netdev_switch_port_bridge_dellink(struct net_device *dev,
 						    struct nlmsghdr *nlh,
 						    u16 flags)
@@ -163,13 +152,6 @@ static inline int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *
 	return 0;
 }
 
-static inline int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
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
index e1115a2..5deb063 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -586,7 +586,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
 	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
-	int err = 0, ret_offload = 0;
+	int err = 0;
 
 	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_PROTINFO);
 	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
@@ -628,16 +628,6 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 				afspec, RTM_SETLINK);
 	}
 
-	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
-		/* set bridge attributes in hardware if supported
-		 */
-		ret_offload = netdev_switch_port_bridge_setlink(dev, nlh,
-								flags);
-		if (ret_offload && ret_offload != -EOPNOTSUPP)
-			br_warn(p->br, "error setting attrs on port %u(%s)\n",
-				(unsigned int)p->port_no, p->dev->name);
-	}
-
 	if (err == 0)
 		br_ifinfo_notify(RTM_NEWLINK, p);
 out:
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index f3f457e..0307a45 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -173,31 +173,6 @@ int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(call_netdev_switch_notifiers);
 
-/**
- *	netdev_switch_port_bridge_setlink - Notify switch device port of bridge
- *	port attributes
- *
- *	@dev: port device
- *	@nlh: netlink msg with bridge port attributes
- *	@flags: bridge setlink flags
- *
- *	Notify switch device port of bridge port attributes
- */
-int netdev_switch_port_bridge_setlink(struct net_device *dev,
-				      struct nlmsghdr *nlh, u16 flags)
-{
-	const struct net_device_ops *ops = dev->netdev_ops;
-
-	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
-		return 0;
-
-	if (!ops->ndo_bridge_setlink)
-		return -EOPNOTSUPP;
-
-	return ops->ndo_bridge_setlink(dev, nlh, flags);
-}
-EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_setlink);
-
 static int swdev_port_bridge_setflag(struct net_device *dev,
 				     struct nlattr *ifla,
 				     unsigned long brport_flag)
@@ -309,36 +284,6 @@ int netdev_switch_port_bridge_dellink(struct net_device *dev,
 EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_dellink);
 
 /**
- *	ndo_dflt_netdev_switch_port_bridge_setlink - default ndo bridge setlink
- *						     op for master devices
- *
- *	@dev: port device
- *	@nlh: netlink msg with bridge port attributes
- *	@flags: bridge setlink flags
- *
- *	Notify master device slaves of bridge port attributes
- */
-int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
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
-		err = netdev_switch_port_bridge_setlink(lower_dev, nlh, flags);
-		if (err && err != -EOPNOTSUPP)
-			ret = err;
-	}
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(ndo_dflt_netdev_switch_port_bridge_setlink);
-
-/**
  *	ndo_dflt_netdev_switch_port_bridge_dellink - default ndo bridge dellink
  *						     op for master devices
  *
-- 
1.7.10.4
