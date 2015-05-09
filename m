From: sfeldma@gmail.com
Subject: [PATCH net-next v6 20/23] switchdev: convert fib_ipv4_add/del over to switchdev_port_obj_add/del
Date: Sat,  9 May 2015 10:40:22 -0700
Message-ID: <1431193225-807-21-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33648 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776AbbEIRni (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:38 -0400
Received: by pacwv17 with SMTP id wv17so75785259pac.0
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:38 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

The IPv4 FIB ops convert nicely to the switchdev objs and we're left with
only four switchdev ops: port get/set and port add/del.  Other objs will
follow, such as FDB.  So go ahead and convert IPv4 FIB over to switchdev
obj for consistency, anticipating more objs to come.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c |   42 +++++++++++------------------
 include/net/switchdev.h              |   21 +++++++--------
 net/switchdev/switchdev.c            |   49 +++++++++++++++++++++-------------
 3 files changed, 56 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index a363300..95814d7 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4402,6 +4402,7 @@ static int rocker_port_obj_add(struct net_device *dev,
 			       struct switchdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
 	rocker_port->trans = obj->trans;
@@ -4421,6 +4422,12 @@ static int rocker_port_obj_add(struct net_device *dev,
 	case SWITCHDEV_OBJ_PORT_VLAN:
 		err = rocker_port_vlans_add(rocker_port, &obj->vlan);
 		break;
+	case SWITCHDEV_OBJ_IPV4_FIB:
+		fib4 = &obj->ipv4_fib;
+		err = rocker_port_fib_ipv4(rocker_port, fib4->dst,
+					   fib4->dst_len, fib4->fi,
+					   fib4->tb_id, 0);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -4463,12 +4470,20 @@ static int rocker_port_obj_del(struct net_device *dev,
 			       struct switchdev_obj *obj)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
 		err = rocker_port_vlans_del(rocker_port, &obj->vlan);
 		break;
+	case SWITCHDEV_OBJ_IPV4_FIB:
+		fib4 = &obj->ipv4_fib;
+		err = rocker_port_fib_ipv4(rocker_port, fib4->dst,
+					   fib4->dst_len, fib4->fi,
+					   fib4->tb_id,
+					   ROCKER_OP_FLAG_REMOVE);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -4477,38 +4492,11 @@ static int rocker_port_obj_del(struct net_device *dev,
 	return err;
 }
 
-static int rocker_port_switchdev_fib_ipv4_add(struct net_device *dev,
-					      __be32 dst, int dst_len,
-					      struct fib_info *fi,
-					      u8 tos, u8 type,
-					      u32 nlflags, u32 tb_id)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	int flags = 0;
-
-	return rocker_port_fib_ipv4(rocker_port, dst, dst_len,
-				    fi, tb_id, flags);
-}
-
-static int rocker_port_switchdev_fib_ipv4_del(struct net_device *dev,
-					      __be32 dst, int dst_len,
-					      struct fib_info *fi,
-					      u8 tos, u8 type, u32 tb_id)
-{
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	int flags = ROCKER_OP_FLAG_REMOVE;
-
-	return rocker_port_fib_ipv4(rocker_port, dst, dst_len,
-				    fi, tb_id, flags);
-}
-
 static const struct switchdev_ops rocker_port_switchdev_ops = {
 	.switchdev_port_attr_get	= rocker_port_attr_get,
 	.switchdev_port_attr_set	= rocker_port_attr_set,
 	.switchdev_port_obj_add		= rocker_port_obj_add,
 	.switchdev_port_obj_del		= rocker_port_obj_del,
-	.switchdev_fib_ipv4_add		= rocker_port_switchdev_fib_ipv4_add,
-	.switchdev_fib_ipv4_del		= rocker_port_switchdev_fib_ipv4_del,
 };
 
 /********************
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index e081d67..3b217b4 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -46,6 +46,7 @@ struct fib_info;
 enum switchdev_obj_id {
 	SWITCHDEV_OBJ_UNDEFINED,
 	SWITCHDEV_OBJ_PORT_VLAN,
+	SWITCHDEV_OBJ_IPV4_FIB,
 };
 
 struct switchdev_obj {
@@ -57,6 +58,15 @@ struct switchdev_obj {
 			u16 vid_start;
 			u16 vid_end;
 		} vlan;
+		struct switchdev_obj_ipv4_fib {		/* IPV4_FIB */
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
 
@@ -70,10 +80,6 @@ struct switchdev_obj {
  * @switchdev_port_obj_add: Add an object to port (see switchdev_obj).
  *
  * @switchdev_port_obj_del: Delete an object from port (see switchdev_obj).
- *
- * @switchdev_fib_ipv4_add: Called to add/modify IPv4 route to switch device.
- *
- * @switchdev_fib_ipv4_del: Called to delete IPv4 route from switch device.
  */
 struct switchdev_ops {
 	int	(*switchdev_port_attr_get)(struct net_device *dev,
@@ -84,13 +90,6 @@ struct switchdev_ops {
 					  struct switchdev_obj *obj);
 	int	(*switchdev_port_obj_del)(struct net_device *dev,
 					  struct switchdev_obj *obj);
-	int	(*switchdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
-					  int dst_len, struct fib_info *fi,
-					  u8 tos, u8 type, u32 nlflags,
-					  u32 tb_id);
-	int	(*switchdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
-					  int dst_len, struct fib_info *fi,
-					  u8 tos, u8 type, u32 tb_id);
 };
 
 enum switchdev_notifier_type {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 9210355..65d49d4 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -641,8 +641,19 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 nlflags, u32 tb_id)
 {
+	struct switchdev_obj fib_obj = {
+		.id = SWITCHDEV_OBJ_IPV4_FIB,
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
-	const struct switchdev_ops *ops;
 	int err = 0;
 
 	/* Don't offload route if using custom ip rules or if
@@ -660,15 +671,10 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	dev = switchdev_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
-	ops = dev->switchdev_ops;
-
-	if (ops->switchdev_fib_ipv4_add) {
-		err = ops->switchdev_fib_ipv4_add(dev, htonl(dst), dst_len,
-						  fi, tos, type, nlflags,
-						  tb_id);
-		if (!err)
-			fi->fib_flags |= RTNH_F_EXTERNAL;
-	}
+
+	err = switchdev_port_obj_add(dev, &fib_obj);
+	if (!err)
+		fi->fib_flags |= RTNH_F_EXTERNAL;
 
 	return err;
 }
@@ -689,8 +695,19 @@ EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_add);
 int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 tb_id)
 {
+	struct switchdev_obj fib_obj = {
+		.id = SWITCHDEV_OBJ_IPV4_FIB,
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
-	const struct switchdev_ops *ops;
 	int err = 0;
 
 	if (!(fi->fib_flags & RTNH_F_EXTERNAL))
@@ -699,14 +716,10 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	dev = switchdev_get_dev_by_nhs(fi);
 	if (!dev)
 		return 0;
-	ops = dev->switchdev_ops;
 
-	if (ops->switchdev_fib_ipv4_del) {
-		err = ops->switchdev_fib_ipv4_del(dev, htonl(dst), dst_len,
-						  fi, tos, type, tb_id);
-		if (!err)
-			fi->fib_flags &= ~RTNH_F_EXTERNAL;
-	}
+	err = switchdev_port_obj_del(dev, &fib_obj);
+	if (!err)
+		fi->fib_flags &= ~RTNH_F_EXTERNAL;
 
 	return err;
 }
-- 
1.7.10.4
