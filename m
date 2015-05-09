From: sfeldma@gmail.com
Subject: [PATCH net-next v6 17/23] switchdev: remove unused switchdev_port_bridge_dellink
Date: Sat,  9 May 2015 10:40:19 -0700
Message-ID: <1431193225-807-18-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:33617 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbbEIRnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:35 -0400
Received: by pacwv17 with SMTP id wv17so75784588pac.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:35 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Now we can remove old wrappers for dellink.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/net/switchdev.h   |   15 ---------------
 net/bridge/br_netlink.c   |   11 +----------
 net/switchdev/switchdev.c |   30 ------------------------------
 3 files changed, 1 insertion(+), 55 deletions(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 8ffadca..397b1e6 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -130,8 +130,6 @@ int switchdev_port_bridge_setlink(struct net_device *dev,
 				  struct nlmsghdr *nlh, u16 flags);
 int switchdev_port_bridge_dellink(struct net_device *dev,
 				  struct nlmsghdr *nlh, u16 flags);
-int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
-					   struct nlmsghdr *nlh, u16 flags);
 int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 nlflags, u32 tb_id);
 int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
@@ -164,12 +162,6 @@ static inline int switchdev_port_obj_del(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static inline int switchdev_port_bridge_dellink(struct net_device *dev,
-					    struct nlmsghdr *nlh, u16 flags)
-{
-	return -EOPNOTSUPP;
-}
-
 static inline int register_switchdev_notifier(struct notifier_block *nb)
 {
 	return 0;
@@ -201,13 +193,6 @@ static inline int switchdev_port_bridge_dellink(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
-static inline int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
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
index e9b9435..6b67ed3 100644
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
@@ -658,15 +658,6 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 		 */
 		br_ifinfo_notify(RTM_NEWLINK, p);
 
-	if (p && !(flags & BRIDGE_FLAGS_SELF)) {
-		/* del bridge attributes in hardware
-		 */
-		ret_offload = switchdev_port_bridge_dellink(dev, nlh, flags);
-		if (ret_offload && ret_offload != -EOPNOTSUPP)
-			br_warn(p->br, "error deleting attrs on port %u (%s)\n",
-				(unsigned int)p->port_no, p->dev->name);
-	}
-
 	return err;
 }
 static int br_validate(struct nlattr *tb[], struct nlattr *data[])
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 8ce678e..0e15b6f 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -536,36 +536,6 @@ int switchdev_port_bridge_dellink(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(switchdev_port_bridge_dellink);
 
-/**
- *	ndo_dflt_switchdev_port_bridge_dellink - default ndo bridge dellink
- *						 op for master devices
- *
- *	@dev: port device
- *	@nlh: netlink msg with bridge port attributes
- *	@flags: bridge dellink flags
- *
- *	Notify master device slaves of bridge port attribute deletes
- */
-int ndo_dflt_switchdev_port_bridge_dellink(struct net_device *dev,
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
-		err = switchdev_port_bridge_dellink(lower_dev, nlh, flags);
-		if (err && err != -EOPNOTSUPP)
-			ret = err;
-	}
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(ndo_dflt_switchdev_port_bridge_dellink);
-
 static struct net_device *switchdev_get_lowest_dev(struct net_device *dev)
 {
 	const struct switchdev_ops *ops = dev->switchdev_ops;
-- 
1.7.10.4
