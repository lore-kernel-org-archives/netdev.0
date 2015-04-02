From: sfeldma@gmail.com
Subject: [PATCH net-next v3 25/26] switchdev: convert swdev_fib_ipv4_add/del over to swdev_port_obj_add/del
Date: Thu,  2 Apr 2015 01:10:11 -0700
Message-ID: <1427962212-18411-26-git-send-email-sfeldma@gmail.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:32937 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848AbbDBIJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 04:09:50 -0400
Received: by pdbnk13 with SMTP id nk13so1998398pdb.0
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 01:09:50 -0700 (PDT)
In-Reply-To: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

The IPv4 FIB ops convert nicely to the swdev objs and we're left with only
four swdev ops: port get/set and port add/del.  Other objs will follow, such
as FDB.  So go ahead and convert IPv4 FIB over to swdev obj for consistency,
anticipating more objs to come.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   42 +++++++++++------------------
 include/net/switchdev.h              |   21 +++++++--------
 net/switchdev/switchdev.c            |   49 +++++++++++++++++++++-------------
 3 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 1ab4916..589303e 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4247,6 +4247,7 @@ static int rocker_port_vlans_add(struct rocker_port *rocker_port,
 static int rocker_port_obj_add(struct net_device *dev, struct swdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct swdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
 	if (obj->flags & SWDEV_F_TRANS_PREPARE)
@@ -4256,6 +4257,12 @@ static int rocker_port_obj_add(struct net_device *dev, struct swdev_obj *obj)
 	case SWDEV_OBJ_PORT_VLAN:
 		err = rocker_port_vlans_add(rocker_port, &obj->vlan);
 		break;
+	case SWDEV_OBJ_IPV4_FIB:
+		fib4 = &obj->ipv4_fib;
+		err = rocker_port_fib_ipv4(rocker_port, fib4->dst,
+					   fib4->dst_len, fib4->fi,
+					   fib4->tb_id, 0);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -4295,12 +4302,20 @@ static int rocker_port_vlans_del(struct rocker_port *rocker_port,
 static int rocker_port_obj_del(struct net_device *dev, struct swdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct swdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
 	switch (obj->id) {
 	case SWDEV_OBJ_PORT_VLAN:
 		err = rocker_port_vlans_del(rocker_port, &obj->vlan);
 		break;
+	case SWDEV_OBJ_IPV4_FIB:
+		fib4 = &obj->ipv4_fib;
+		err = rocker_port_fib_ipv4(rocker_port, fib4->dst,
+					   fib4->dst_len, fib4->fi,
+					   fib4->tb_id,
+					   ROCKER_OP_FLAG_REMOVE);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -4309,38 +4324,11 @@ static int rocker_port_obj_del(struct net_device *dev, struct swdev_obj *obj)
 	return err;
 }
 
-static int rocker_port_swdev_fib_ipv4_add(struct net_device *dev,
-					  __be32 dst, int dst_len,
-					  struct fib_info *fi,
-					  u8 tos, u8 type,
-					  u32 nlflags, u32 tb_id)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	int flags = 0;
-
-	return rocker_port_fib_ipv4(rocker_port, dst, dst_len,
-				    fi, tb_id, flags);
-}
-
-static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
-					  __be32 dst, int dst_len,
-					  struct fib_info *fi,
-					  u8 tos, u8 type, u32 tb_id)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	int flags = ROCKER_OP_FLAG_REMOVE;
-
-	return rocker_port_fib_ipv4(rocker_port, dst, dst_len,
-				    fi, tb_id, flags);
-}
-
 static const struct swdev_ops rocker_port_swdev_ops = {
 	.swdev_port_attr_get		= rocker_port_attr_get,
 	.swdev_port_attr_set		= rocker_port_attr_set,
 	.swdev_port_obj_add		= rocker_port_obj_add,
 	.swdev_port_obj_del		= rocker_port_obj_del,
-	.swdev_fib_ipv4_add		= rocker_port_swdev_fib_ipv4_add,
-	.swdev_fib_ipv4_del		= rocker_port_swdev_fib_ipv4_del,
 };
 
 /********************
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 1677606..c3b1dfd 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -41,6 +41,7 @@ struct fib_info;
 enum swdev_obj_id {
 	SWDEV_OBJ_UNDEFINED,
 	SWDEV_OBJ_PORT_VLAN,
+	SWDEV_OBJ_IPV4_FIB,
 };
 
 struct swdev_obj {
@@ -52,6 +53,15 @@ struct swdev_obj {
 			u16 vid_start;
 			u16 vid_end;
 		} vlan;
+		struct swdev_obj_ipv4_fib {		/* IPV4_FIB */
+			u32 dst;
+			int dst_len;
+			struct fib_info *fi;
+			u8 tos;
+			u8 type;
+			u32 nlflags;
+			u32 tb_id;
+		} ipv4_fib;
 	};
 };
 
@@ -65,10 +75,6 @@ struct swdev_obj {
  * @swdev_port_obj_add: Add an object to port (see swdev_obj).
  *
  * @swdev_port_obj_del: Delete an object from port (see swdev_obj).
- *
- * @swdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
- *
- * @swdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
  */
 struct swdev_ops {
 	int	(*swdev_port_attr_get)(struct net_device *dev,
@@ -79,13 +85,6 @@ struct swdev_ops {
 				      struct swdev_obj *obj);
 	int	(*swdev_port_obj_del)(struct net_device *dev,
 				      struct swdev_obj *obj);
-	int	(*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
-				      int dst_len, struct fib_info *fi,
-				      u8 tos, u8 type, u32 nlflags,
-				      u32 tb_id);
-	int	(*swdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
-				      int dst_len, struct fib_info *fi,
-				      u8 tos, u8 type, u32 tb_id);
 };
 
 enum swdev_notifier_type {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 2e5b893..04e8efd 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -594,8 +594,19 @@ static struct net_device *swdev_get_dev_by_nhs(struct fib_info *fi)
 int swdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 		       u8 tos, u8 type, u32 nlflags, u32 tb_id)
 {
+	struct swdev_obj fib_obj = {
+		.id = SWDEV_OBJ_IPV4_FIB,
+		.ipv4_fib = {
+			.dst = htonl(dst),
+			.dst_len = dst_len,
+			.fi = fi,
+			.tos = tos,
+			.type = type,
+			.nlflags = nlflags,
+			.tb_id = tb_id,
+		},
+	};
 	struct net_device *dev;
-	const struct swdev_ops *ops;
 	int err = 0;
 
 	/* Don't offload route if using custom ip rules or if
@@ -613,15 +624,10 @@ int swdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	dev = swdev_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
-	ops = dev->swdev_ops;
-
-	if (ops->swdev_fib_ipv4_add) {
-		err = ops->swdev_fib_ipv4_add(dev, htonl(dst), dst_len,
-					      fi, tos, type, nlflags,
-					      tb_id);
-		if (!err)
-			fi->fib_flags |= RTNH_F_EXTERNAL;
-	}
+
+	err = swdev_port_obj_add(dev, &fib_obj);
+	if (!err)
+		fi->fib_flags |= RTNH_F_EXTERNAL;
 
 	return err;
 }
@@ -642,8 +648,19 @@ EXPORT_SYMBOL_GPL(swdev_fib_ipv4_add);
 int swdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 		       u8 tos, u8 type, u32 tb_id)
 {
+	struct swdev_obj fib_obj = {
+		.id = SWDEV_OBJ_IPV4_FIB,
+		.ipv4_fib = {
+			.dst = htonl(dst),
+			.dst_len = dst_len,
+			.fi = fi,
+			.tos = tos,
+			.type = type,
+			.nlflags = 0,
+			.tb_id = tb_id,
+		},
+	};
 	struct net_device *dev;
-	const struct swdev_ops *ops;
 	int err = 0;
 
 	if (!(fi->fib_flags & RTNH_F_EXTERNAL))
@@ -652,14 +669,10 @@ int swdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	dev = swdev_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
-	ops = dev->swdev_ops;
 
-	if (ops->swdev_fib_ipv4_del) {
-		err = ops->swdev_fib_ipv4_del(dev, htonl(dst), dst_len,
-					      fi, tos, type, tb_id);
-		if (!err)
-			fi->fib_flags &= ~RTNH_F_EXTERNAL;
-	}
+	err = swdev_port_obj_del(dev, &fib_obj);
+	if (!err)
+		fi->fib_flags &= ~RTNH_F_EXTERNAL;
 
 	return err;
 }
-- 
1.7.10.4
