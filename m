From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] switchdev: call bridge setlink/dellink ndos recursively
Date: Mon, 16 Mar 2015 15:22:54 +0100
Message-ID: <1426515774-21038-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38227 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933264AbbCPOW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 10:22:59 -0400
Received: by wifj2 with SMTP id j2so44918144wif.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 07:22:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There has been a discussion about if it's better to let masters to
propagate call down themself or if its better just blindly go down and
try to call ndo on every lower netdev. Turned out that more people (me
not included) like the second option better.

This patch changes bridge setlink/dellink in that direction.
Sorry Roopa for forcing you to do it the way I liked initially.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c |  2 --
 drivers/net/team/team.c         |  2 --
 include/net/switchdev.h         |  4 ---
 net/switchdev/switchdev.c       | 78 ++++++++++-------------------------------
 4 files changed, 19 insertions(+), 67 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c026ce9..c1dce04 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4036,8 +4036,6 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_add_slave		= bond_enslave,
 	.ndo_del_slave		= bond_release,
 	.ndo_fix_features	= bond_fix_features,
-	.ndo_bridge_setlink	= ndo_dflt_netdev_switch_port_bridge_setlink,
-	.ndo_bridge_dellink	= ndo_dflt_netdev_switch_port_bridge_dellink,
 };
 
 static const struct device_type bond_type = {
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index a23319f..dbd39b9 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1977,8 +1977,6 @@ static const struct net_device_ops team_netdev_ops = {
 	.ndo_del_slave		= team_del_slave,
 	.ndo_fix_features	= team_fix_features,
 	.ndo_change_carrier     = team_change_carrier,
-	.ndo_bridge_setlink     = ndo_dflt_netdev_switch_port_bridge_setlink,
-	.ndo_bridge_dellink     = ndo_dflt_netdev_switch_port_bridge_dellink,
 };
 
 /***********************
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index e5de53f..489c5c0 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -86,10 +86,6 @@ int netdev_switch_port_bridge_setlink(struct net_device *dev,
 				struct nlmsghdr *nlh, u16 flags);
 int netdev_switch_port_bridge_dellink(struct net_device *dev,
 				struct nlmsghdr *nlh, u16 flags);
-int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
-					       struct nlmsghdr *nlh, u16 flags);
-int ndo_dflt_netdev_switch_port_bridge_setlink(struct net_device *dev,
-					       struct nlmsghdr *nlh, u16 flags);
 int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			       u8 tos, u8 type, u32 nlflags, u32 tb_id);
 int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index c9bfa00..ce494cd 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -132,14 +132,24 @@ int netdev_switch_port_bridge_setlink(struct net_device *dev,
 				      struct nlmsghdr *nlh, u16 flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	struct net_device *lower_dev;
+	struct list_head *iter;
+	int err;
+	int ret = -EOPNOTSUPP;
 
 	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
 		return 0;
 
-	if (!ops->ndo_bridge_setlink)
-		return -EOPNOTSUPP;
+	if (ops->ndo_bridge_setlink)
+		return ops->ndo_bridge_setlink(dev, nlh, flags);
+
+        netdev_for_each_lower_dev(dev, lower_dev, iter) {
+		err = netdev_switch_port_bridge_setlink(lower_dev, nlh, flags);
+		if (err && err != -EOPNOTSUPP)
+			ret = err;
+	}
+	return ret;
 
-	return ops->ndo_bridge_setlink(dev, nlh, flags);
 }
 EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_setlink);
 
@@ -157,66 +167,16 @@ int netdev_switch_port_bridge_dellink(struct net_device *dev,
 				      struct nlmsghdr *nlh, u16 flags)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
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
 	struct net_device *lower_dev;
 	struct list_head *iter;
-	int ret = 0, err = 0;
+	int err;
+	int ret = -EOPNOTSUPP;
 
 	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
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
+		return 0;
 
-	if (!(dev->features & NETIF_F_HW_SWITCH_OFFLOAD))
-		return ret;
+	if (ops->ndo_bridge_dellink)
+		return ops->ndo_bridge_dellink(dev, nlh, flags);
 
 	netdev_for_each_lower_dev(dev, lower_dev, iter) {
 		err = netdev_switch_port_bridge_dellink(lower_dev, nlh, flags);
@@ -226,7 +186,7 @@ int ndo_dflt_netdev_switch_port_bridge_dellink(struct net_device *dev,
 
 	return ret;
 }
-EXPORT_SYMBOL_GPL(ndo_dflt_netdev_switch_port_bridge_dellink);
+EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_dellink);
 
 static struct net_device *netdev_switch_get_lowest_dev(struct net_device *dev)
 {
-- 
1.9.3
