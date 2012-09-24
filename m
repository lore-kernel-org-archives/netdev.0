From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 1/3] netlink: add attributes to fdb interface
Date: Mon, 24 Sep 2012 11:43:05 -0700
Message-ID: <20120924185050.024609164@vyatta.com>
References: <20120924184304.727711327@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fiji.vyatta.com ([76.74.103.50]:44014 "EHLO fiji.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757600Ab2IXSwu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 14:52:50 -0400
Content-Disposition: inline; filename=fdb-attr.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Later changes need to be able to refer to neighbour attributes
when doing fdb_add.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 +-
 drivers/net/macvlan.c                         |    2 +-
 include/linux/netdevice.h                     |    4 +++-
 net/bridge/br_fdb.c                           |    3 ++-
 net/bridge/br_private.h                       |    2 +-
 net/core/rtnetlink.c                          |    6 ++++--
 6 files changed, 12 insertions(+), 7 deletions(-)

--- a/drivers/net/macvlan.c	2012-09-17 11:24:34.000000000 -0700
+++ b/drivers/net/macvlan.c	2012-09-17 11:28:13.999165490 -0700
@@ -546,7 +546,7 @@ static int macvlan_vlan_rx_kill_vid(stru
 	return 0;
 }
 
-static int macvlan_fdb_add(struct ndmsg *ndm,
+static int macvlan_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			   struct net_device *dev,
 			   const unsigned char *addr,
 			   u16 flags)
--- a/include/linux/netdevice.h	2012-09-17 11:24:34.000000000 -0700
+++ b/include/linux/netdevice.h	2012-09-17 11:28:13.999165490 -0700
@@ -906,7 +906,8 @@ struct netdev_fcoe_hbainfo {
  *	feature set might be less than what was returned by ndo_fix_features()).
  *	Must return >0 or -errno if it changed dev->features itself.
  *
- * int (*ndo_fdb_add)(struct ndmsg *ndm, struct net_device *dev,
+ * int (*ndo_fdb_add)(struct ndmsg *ndm, struct nlattr *tb[],
+ *		      struct net_device *dev,
  *		      const unsigned char *addr, u16 flags)
  *	Adds an FDB entry to dev for addr.
  * int (*ndo_fdb_del)(struct ndmsg *ndm, struct net_device *dev,
@@ -1016,6 +1017,7 @@ struct net_device_ops {
 	void			(*ndo_neigh_destroy)(struct neighbour *n);
 
 	int			(*ndo_fdb_add)(struct ndmsg *ndm,
+					       struct nlattr *tb[],
 					       struct net_device *dev,
 					       const unsigned char *addr,
 					       u16 flags);
--- a/net/bridge/br_fdb.c	2012-09-17 11:24:34.000000000 -0700
+++ b/net/bridge/br_fdb.c	2012-09-17 11:28:13.999165490 -0700
@@ -608,7 +608,8 @@ static int fdb_add_entry(struct net_brid
 }
 
 /* Add new permanent fdb entry with RTM_NEWNEIGH */
-int br_fdb_add(struct ndmsg *ndm, struct net_device *dev,
+int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
+	       struct net_device *dev,
 	       const unsigned char *addr, u16 nlh_flags)
 {
 	struct net_bridge_port *p;
--- a/net/bridge/br_private.h	2012-09-17 11:24:34.000000000 -0700
+++ b/net/bridge/br_private.h	2012-09-17 11:28:13.999165490 -0700
@@ -364,7 +364,7 @@ extern void br_fdb_update(struct net_bri
 extern int br_fdb_delete(struct ndmsg *ndm,
 			 struct net_device *dev,
 			 const unsigned char *addr);
-extern int br_fdb_add(struct ndmsg *nlh,
+extern int br_fdb_add(struct ndmsg *nlh, struct nlattr *tb[],
 		      struct net_device *dev,
 		      const unsigned char *addr,
 		      u16 nlh_flags);
--- a/net/core/rtnetlink.c	2012-09-17 11:24:34.000000000 -0700
+++ b/net/core/rtnetlink.c	2012-09-17 11:28:14.003165450 -0700
@@ -2090,7 +2090,8 @@ static int rtnl_fdb_add(struct sk_buff *
 	if ((!ndm->ndm_flags || ndm->ndm_flags & NTF_MASTER) &&
 	    (dev->priv_flags & IFF_BRIDGE_PORT)) {
 		master = dev->master;
-		err = master->netdev_ops->ndo_fdb_add(ndm, dev, addr,
+		err = master->netdev_ops->ndo_fdb_add(ndm, tb,
+						      dev, addr,
 						      nlh->nlmsg_flags);
 		if (err)
 			goto out;
@@ -2100,7 +2101,8 @@ static int rtnl_fdb_add(struct sk_buff *
 
 	/* Embedded bridge, macvlan, and any other device support */
 	if ((ndm->ndm_flags & NTF_SELF) && dev->netdev_ops->ndo_fdb_add) {
-		err = dev->netdev_ops->ndo_fdb_add(ndm, dev, addr,
+		err = dev->netdev_ops->ndo_fdb_add(ndm, tb,
+						   dev, addr,
 						   nlh->nlmsg_flags);
 
 		if (!err) {
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-09-17 11:25:15.000000000 -0700
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-09-17 11:31:03.325464947 -0700
@@ -6888,7 +6888,7 @@ static int ixgbe_set_features(struct net
 	return 0;
 }
 
-static int ixgbe_ndo_fdb_add(struct ndmsg *ndm,
+static int ixgbe_ndo_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 			     struct net_device *dev,
 			     const unsigned char *addr,
 			     u16 flags)
