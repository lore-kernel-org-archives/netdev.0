From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v4 2/7] bridge: add flags argument to ndo_bridge_setlink and ndo_bridge_dellink
Date: Thu, 29 Jan 2015 22:40:12 -0800
Message-ID: <1422600017-42393-3-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:64081 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbbA3GkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 01:40:25 -0500
Received: by mail-pa0-f44.google.com with SMTP id rd3so48630974pab.3
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 22:40:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

bridge flags are needed inside ndo_bridge_setlink/dellink handlers to
avoid another call to parse IFLA_AF_SPEC inside these handlers

This is used later in this series

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c   |    3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 drivers/net/ethernet/rocker/rocker.c          |    2 +-
 include/linux/netdevice.h                     |    6 ++++--
 net/bridge/br_netlink.c                       |    4 ++--
 net/bridge/br_private.h                       |    4 ++--
 net/core/rtnetlink.c                          |   10 ++++++----
 7 files changed, 18 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 598c507..efed92c 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4327,7 +4327,8 @@ fw_exit:
 	return status;
 }
 
-static int be_ndo_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh)
+static int be_ndo_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
+				 u16 flags)
 {
 	struct be_adapter *adapter = netdev_priv(dev);
 	struct nlattr *attr, *br_spec;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7bb421b..e4086fe 100644
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
index 11f4ffc..f0d607c 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3722,7 +3722,7 @@ skip:
 }
 
 static int rocker_port_bridge_setlink(struct net_device *dev,
-				      struct nlmsghdr *nlh)
+				      struct nlmsghdr *nlh, u16 flags)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct nlattr *protinfo;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 642d426..6013b38 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1154,13 +1154,15 @@ struct net_device_ops {
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
index 3875ea5..5b38221 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -494,7 +494,7 @@ static int br_setport(struct net_bridge_port *p, struct nlattr *tb[])
 }
 
 /* Change state and parameters on port. */
-int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
+int br_setlink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 {
 	struct nlattr *protinfo;
 	struct nlattr *afspec;
@@ -550,7 +550,7 @@ out:
 }
 
 /* Delete port information */
-int br_dellink(struct net_device *dev, struct nlmsghdr *nlh)
+int br_dellink(struct net_device *dev, struct nlmsghdr *nlh, u16 flags)
 {
 	struct nlattr *afspec;
 	struct net_bridge_port *p;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index e8e3f36..de09199 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -819,8 +819,8 @@ extern struct rtnl_link_ops br_link_ops;
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
index 07447d1..c693c8a 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2991,7 +2991,7 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 			goto out;
 		}
 
-		err = br_dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
+		err = br_dev->netdev_ops->ndo_bridge_setlink(dev, nlh, flags);
 		if (err)
 			goto out;
 
@@ -3002,7 +3002,8 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (!dev->netdev_ops->ndo_bridge_setlink)
 			err = -EOPNOTSUPP;
 		else
-			err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
+			err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh,
+								  flags);
 		if (!err) {
 			flags &= ~BRIDGE_FLAGS_SELF;
 
@@ -3064,7 +3065,7 @@ static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 			goto out;
 		}
 
-		err = br_dev->netdev_ops->ndo_bridge_dellink(dev, nlh);
+		err = br_dev->netdev_ops->ndo_bridge_dellink(dev, nlh, flags);
 		if (err)
 			goto out;
 
@@ -3075,7 +3076,8 @@ static int rtnl_bridge_dellink(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (!dev->netdev_ops->ndo_bridge_dellink)
 			err = -EOPNOTSUPP;
 		else
-			err = dev->netdev_ops->ndo_bridge_dellink(dev, nlh);
+			err = dev->netdev_ops->ndo_bridge_dellink(dev, nlh,
+								  flags);
 
 		if (!err) {
 			flags &= ~BRIDGE_FLAGS_SELF;
-- 
1.7.10.4
