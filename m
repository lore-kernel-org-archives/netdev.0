From: sfeldma@gmail.com
Subject: [PATCH net-next v5 12/21] switchdev: remove old switchdev_port_bridge_setlink
Date: Tue,  5 May 2015 10:34:48 -0700
Message-ID: <1430847297-15728-13-git-send-email-sfeldma@gmail.com>
References: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34724 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965328AbbEEReO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 13:34:14 -0400
Received: by pacyx8 with SMTP id yx8so199835645pac.1
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 10:34:13 -0700 (PDT)
In-Reply-To: <1430847297-15728-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

New attr-based bridge_setlink can recurse lower devs and recover on err, so
remove old wrapper.  Also, restore br_setlink back to original and don't
call into SELF port driver.  rtnetlink.c:bridge_setlink already does a call
into port driver for SELF.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   17 -----------------
 net/bridge/br_netlink.c   |   11 +----------
 net/switchdev/switchdev.c |   30 ------------------------------
 3 files changed, 1 insertion(+), 57 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index aa6c370..ce5ceb2 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -122,8 +122,6 @@ int switchdev_port_attr_set(struct net_device *dev,
 			    struct switchdev_attr *attr);
 int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj);
 int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj);
-int switchdev_port_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
-			      u16 flags);
 int register_switchdev_notifier(struct notifier_block *nb);
 int unregister_switchdev_notifier(struct notifier_block *nb);
 int call_switchdev_notifiers(unsigned long val, struct net_device *dev,
@@ -134,8 +132,6 @@ int switchdev_port_bridge_dellink(struct net_device *dev,
 				  struct nlmsghdr *nlh, u16 flags);
 int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
 					   struct nlmsghdr *nlh, u16 flags);
-int ndo_dflt_switchdev_port_bridge_setlink(struct net_device *dev,
-					   struct nlmsghdr *nlh, u16 flags);
 int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 nlflags, u32 tb_id);
 int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
@@ -168,12 +164,6 @@ static inline int switchdev_port_obj_del(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static inline int switchdev_port_bridge_setlink(struct net_device *dev,
-					    struct nlmsghdr *nlh, u16 flags)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline int register_switchdev_notifier(struct notifier_block *nb)
 {
 	return 0;
@@ -212,13 +202,6 @@ static inline int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
 	return 0;
 }
 
-static inline int ndo_dflt_switchdev_port_bridge_setlink(struct net_device *dev,
-							 struct nlmsghdr *nlh,
-							 u16 flags)
-{
-	return 0;
-}
-
 static inline int switchdev_fib_ipv4_add(u32 dst, int dst_len,
 					 struct fib_info *fi,
 					 u8 tos, u8 type,
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index dc23453..e9b9435 100644
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
@@ -628,15 +628,6 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 				afspec, RTM_SETLINK);
 	}
 
-	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
-		/* set bridge attributes in hardware if supported
-		 */
-		ret_offload = switchdev_port_bridge_setlink(dev, nlh, flags);
-		if (ret_offload && ret_offload != -EOPNOTSUPP)
-			br_warn(p->br, "error setting attrs on port %u(%s)\n",
-				(unsigned int)p->port_no, p->dev->name);
-	}
-
 	if (err == 0)
 		br_ifinfo_notify(RTM_NEWLINK, p);
 out:
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index b01791a..dcdec9d 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -537,36 +537,6 @@ int switchdev_port_bridge_dellink(struct net_device *dev,
 EXPORT_SYMBOL_GPL(switchdev_port_bridge_dellink);
 
 /**
- *	ndo_dflt_switchdev_port_bridge_setlink - default ndo bridge setlink
- *						 op for master devices
- *
- *	@dev: port device
- *	@nlh: netlink msg with bridge port attributes
- *	@flags: bridge setlink flags
- *
- *	Notify master device slaves of bridge port attributes
- */
-int ndo_dflt_switchdev_port_bridge_setlink(struct net_device *dev,
-					   struct nlmsghdr *nlh, u16 flags)
-{
-	struct net_device *lower_dev;
-	struct list_head *iter;
-	int ret = 0, err = 0;
-
-	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
-		return ret;
-
-	netdev_for_each_lower_dev(dev, lower_dev, iter) {
-		err = switchdev_port_bridge_setlink(lower_dev, nlh, flags);
-		if (err && err != -EOPNOTSUPP)
-			ret = err;
-	}
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(ndo_dflt_switchdev_port_bridge_setlink);
-
-/**
  *	ndo_dflt_switchdev_port_bridge_dellink - default ndo bridge dellink
  *						 op for master devices
  *
-- 
1.7.10.4
