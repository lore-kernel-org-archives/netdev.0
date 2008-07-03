From: Patrick McHardy <kaber@trash.net>
Subject: vlan 04/06: Change vlan_dev_set_vlan_flag() to handle multiple flags at once
Date: Thu,  3 Jul 2008 19:04:47 +0200 (MEST)
Message-ID: <20080703170447.6650.20979.sendpatchset@localhost.localdomain>
References: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>
Cc: shemminger@vyatta.com, Patrick McHardy <kaber@trash.net>,
	davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42849 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978AbYGCREs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 13:04:48 -0400
In-Reply-To: <20080703170441.6650.64717.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: Change vlan_dev_set_vlan_flag() to handle multiple flags at once

Change vlan_dev_set_vlan_flag() to handle multiple flags at once and
rename to vlan_dev_change_flags(). This allows to to use it from the
netlink interface, which in turn allows to handle necessary adjustments
when changing flags centrally.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 12ad21b911562368e08dc7166109370130c156c7
tree 1002d0cb3c6b1158a25fdd3494e81904c1931d17
parent 4c8767ab0402e70217e9ec118d940e56255a8221
author Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 18:11:18 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 18:11:18 +0200

 net/8021q/vlan.c         |    6 +++---
 net/8021q/vlan.h         |    3 +--
 net/8021q/vlan_dev.c     |   20 +++++++++-----------
 net/8021q/vlan_netlink.c |    4 +---
 4 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index ab2225d..b591bfc 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -591,9 +591,9 @@ static int vlan_ioctl_handler(struct net *net, void __user *arg)
 		err = -EPERM;
 		if (!capable(CAP_NET_ADMIN))
 			break;
-		err = vlan_dev_set_vlan_flag(dev,
-					     args.u.flag,
-					     args.vlan_qos);
+		err = vlan_dev_change_flags(dev,
+					    args.vlan_qos ? args.u.flag : 0,
+					    args.u.flag);
 		break;
 
 	case SET_VLAN_NAME_TYPE_CMD:
diff --git a/net/8021q/vlan.h b/net/8021q/vlan.h
index 5229a72..639e254 100644
--- a/net/8021q/vlan.h
+++ b/net/8021q/vlan.h
@@ -28,8 +28,7 @@ void vlan_dev_set_ingress_priority(const struct net_device *dev,
 				   u32 skb_prio, short vlan_prio);
 int vlan_dev_set_egress_priority(const struct net_device *dev,
 				 u32 skb_prio, short vlan_prio);
-int vlan_dev_set_vlan_flag(const struct net_device *dev,
-			   u32 flag, short flag_val);
+int vlan_dev_change_flags(const struct net_device *dev, u32 flag, u32 mask);
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result);
 void vlan_dev_get_vid(const struct net_device *dev, unsigned short *result);
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 5d055c2..76c665c 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -507,18 +507,16 @@ int vlan_dev_set_egress_priority(const struct net_device *dev,
 }
 
 /* Flags are defined in the vlan_flags enum in include/linux/if_vlan.h file. */
-int vlan_dev_set_vlan_flag(const struct net_device *dev,
-			   u32 flag, short flag_val)
+int vlan_dev_change_flags(const struct net_device *dev, u32 flags, u32 mask)
 {
-	/* verify flag is supported */
-	if (flag == VLAN_FLAG_REORDER_HDR) {
-		if (flag_val)
-			vlan_dev_info(dev)->flags |= VLAN_FLAG_REORDER_HDR;
-		else
-			vlan_dev_info(dev)->flags &= ~VLAN_FLAG_REORDER_HDR;
-		return 0;
-	}
-	return -EINVAL;
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	u32 old_flags = vlan->flags;
+
+	if (mask & ~VLAN_FLAG_REORDER_HDR)
+		return -EINVAL;
+
+	vlan->flags = (old_flags & ~mask) | (flags & mask);
+	return 0;
 }
 
 void vlan_dev_get_realdev_name(const struct net_device *dev, char *result)
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index c93e69e..fd7cb19 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -75,7 +75,6 @@ static int vlan_validate(struct nlattr *tb[], struct nlattr *data[])
 static int vlan_changelink(struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
-	struct vlan_dev_info *vlan = vlan_dev_info(dev);
 	struct ifla_vlan_flags *flags;
 	struct ifla_vlan_qos_mapping *m;
 	struct nlattr *attr;
@@ -83,8 +82,7 @@ static int vlan_changelink(struct net_device *dev,
 
 	if (data[IFLA_VLAN_FLAGS]) {
 		flags = nla_data(data[IFLA_VLAN_FLAGS]);
-		vlan->flags = (vlan->flags & ~flags->mask) |
-			      (flags->flags & flags->mask);
+		vlan_dev_change_flags(dev, flags->flags, flags->mask);
 	}
 	if (data[IFLA_VLAN_INGRESS_QOS]) {
 		nla_for_each_nested(attr, data[IFLA_VLAN_INGRESS_QOS], rem) {
