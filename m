From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v3 3/5] bridge: offload bridge port attributes to switch asic if feature flag set
Date: Thu, 22 Jan 2015 20:33:24 -0800
Message-ID: <1421987606-10884-4-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:63039 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751815AbbAWEdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 23:33:35 -0500
Received: by mail-pd0-f175.google.com with SMTP id fl12so6158662pdb.6
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 20:33:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds support to set/del bridge port attributes in hardware from
the bridge driver.

When the user sends a bridge setlink message, it will come in with 'master',
   - go to the bridge driver ndo_bridge_setlink handler,
   - set settings in the kernel
   - if offload mode is set on the port, also call the swicthdev api to
     propagate the attrs to the switchdev hardware

   If you want to act on the hw alone, you can still use the self flag to
   go to the switch hw or switch port driver directly.

With this, it also makes sure a notification goes out only after the
attributes are set both in the kernel and hw.

The patch calls switchdev api only if BRIDGE_FLAGS_SELF is not set.
This is because the offload cases with BRIDGE_FLAGS_SELF are handled in
the caller (in rtnetlink.c). This needed flags (IFLA_BRIDGE_FLAGS) to be
passed to bridge setlink and dellink functions, to avoid
another call to parse of IFLA_AF_SPEC in br_setlink/br_getlink respectively.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 drivers/net/ethernet/rocker/rocker.c          |    2 +-
 include/linux/netdevice.h                     |    6 +++--
 net/bridge/br_netlink.c                       |   30 ++++++++++++++++++++-----
 net/bridge/br_private.h                       |    4 ++--
 net/core/rtnetlink.c                          |   10 +++++----
 6 files changed, 39 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2ed2c7d..13425e5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -7786,7 +7786,7 @@ static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 }
 
 static int ixgbe_ndo_bridge_setlink(struct net_device *dev,
-				    struct nlmsghdr *nlh)
+				    struct nlmsghdr *nlh, u16 flags)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 	struct nlattr *attr, *br_spec;
diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 2f398fa..109aa1b 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3713,7 +3713,7 @@ skip:
 }
 
 static int rocker_port_bridge_setlink(struct net_device *dev,
-				      struct nlmsghdr *nlh)
+				      struct nlmsghdr *nlh, u16 flags)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct nlattr *protinfo;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c31f74d..1c8641f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1151,13 +1151,15 @@ struct net_device_ops {
 						int idx);
 
 	int			(*ndo_bridge_setlink)(struct net_device *dev,
-						      struct nlmsghdr *nlh);
+						      struct nlmsghdr *nlh,
+						      u16 flags);
 	int			(*ndo_bridge_getlink)(struct sk_buff *skb,
 						      u32 pid, u32 seq,
 						      struct net_device *dev,
 						      u32 filter_mask);
 	int			(*ndo_bridge_dellink)(struct net_device *dev,
-						      struct nlmsghdr *nlh);
+						      struct nlmsghdr *nlh,
+						      u16 flags);
 	int			(*ndo_change_carrier)(struct net_device *dev,
 						      bool new_carrier);
 	int			(*ndo_get_phys_port_id)(struct net_device *dev,
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 9f5eb55..f73b094 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -16,6 +16,7 @@
 #include <net/rtnetlink.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
+#include <net/switchdev.h>
 #include <uapi/linux/if_bridge.h>
 
 #include "br_private.h"
@@ -359,13 +360,13 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 }
 
 /* Change state and parameters on port. */
-int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
+int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 {
 	struct nlattr *protinfo;
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
 	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
-	int err = 0;
+	int err = 0, ret_offload = 0;
 
 	protinfo = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_PROTINFO);
 	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
@@ -407,19 +408,28 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 				afspec, RTM_SETLINK);
 	}
 
+	if (!(flags & BRIDGE_FLAGS_SELF)) {
+		/* set bridge attributes in hardware if supported
+		 */
+		ret_offload = netdev_switch_port_bridge_setlink(dev, nlh,
+								flags);
+		if (ret_offload && ret_offload != -EOPNOTSUPP)
+			br_warn(p->br, "error setting attrs on port %u(%s)\n",
+				(unsigned int)p->port_no, p->dev->name);
+	}
+
 	if (err == 0)
 		br_ifinfo_notify(RTM_NEWLINK, p);
-
 out:
 	return err;
 }
 
 /* Delete port information */
-int br_dellink(struct net_device *dev, struct nlmsghdr *nlh)
+int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 {
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
-	int err;
+	int err = 0, ret_offload = 0;
 
 	afspec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
 	if (!afspec)
@@ -433,6 +443,16 @@ int br_dellink(struct net_device *dev, struct nlmsghdr *nlh)
 	err = br_afspec((struct net_bridge *)netdev_priv(dev), p,
 			afspec, RTM_DELLINK);
 
+	if (!(flags & BRIDGE_FLAGS_SELF)) {
+		/* del bridge attributes in hardware
+		 */
+		ret_offload = netdev_switch_port_bridge_dellink(dev, nlh,
+								flags);
+		if (ret_offload && ret_offload != -EOPNOTSUPP)
+			br_warn(p->br, "error deleting attrs on port %u (%s)\n",
+				(unsigned int)p->port_no, p->dev->name);
+	}
+
 	return err;
 }
 static int br_validate(struct nlattr *tb[], struct nlattr *data[])
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index aea3d13..0ebad7c 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -815,8 +815,8 @@ extern struct rtnl_link_ops br_link_ops;
 int br_netlink_init(void);
 void br_netlink_fini(void);
 void br_ifinfo_notify(int event, struct net_bridge_port *port);
-int br_setlink(struct net_device *dev, struct nlmsghdr *nlmsg);
-int br_dellink(struct net_device *dev, struct nlmsghdr *nlmsg);
+int br_setlink(struct net_device *dev, struct nlmsghdr *nlmsg, u16 flags);
+int br_dellink(struct net_device *dev, struct nlmsghdr *nlmsg, u16 flags);
 int br_getlink(struct sk_buff *skb, u32 pid, u32 seq, struct net_device *dev,
 	       u32 filter_mask);
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d06107d..70e5c93 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2946,7 +2946,7 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 			goto out;
 		}
 
-		err = br_dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
+		err = br_dev->netdev_ops->ndo_bridge_setlink(dev, nlh, flags);
 		if (err)
 			goto out;
 
@@ -2957,7 +2957,8 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (!dev->netdev_ops->ndo_bridge_setlink)
 			err = -EOPNOTSUPP;
 		else
-			err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
+			err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh,
+								  flags);
 
 		if (!err)
 			flags &= ~BRIDGE_FLAGS_SELF;
@@ -3019,7 +3020,7 @@ static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 			goto out;
 		}
 
-		err = br_dev->netdev_ops->ndo_bridge_dellink(dev, nlh);
+		err = br_dev->netdev_ops->ndo_bridge_dellink(dev, nlh, flags);
 		if (err)
 			goto out;
 
@@ -3030,7 +3031,8 @@ static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (!dev->netdev_ops->ndo_bridge_dellink)
 			err = -EOPNOTSUPP;
 		else
-			err = dev->netdev_ops->ndo_bridge_dellink(dev, nlh);
+			err = dev->netdev_ops->ndo_bridge_dellink(dev, nlh,
+								  flags);
 
 		if (!err)
 			flags &= ~BRIDGE_FLAGS_SELF;
-- 
1.7.10.4
