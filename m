From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 2/3] net: switchdev: extract switchdev_obj_ipv4_fib
Date: Tue,  8 Sep 2015 16:47:54 -0400
Message-ID: <1441745275-13200-3-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, kernel@savoirfairelinux.com,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ip-208-88-110-44.savoirfairelinux.net ([208.88.110.44]:41211
	"EHLO mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751552AbbIHUtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 16:49:07 -0400
In-Reply-To: <1441745275-13200-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the switchdev_obj_ipv4_fib structure out of the switchdev_obj
union.

This lightens the switchdev_obj structure and allows drivers to access
the object transaction and callback directly from a
switchdev_obj_ipv4_fib. This is more consistent and convenient for add
and dump operations.

The patch updates the Rocker driver accordingly.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/ethernet/rocker/rocker.c |  4 ++--
 include/net/switchdev.h              | 21 +++++++++--------
 net/switchdev/switchdev.c            | 44 ++++++++++++++++--------------------
 3 files changed, 34 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index e72d49a..41aabbc 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4447,7 +4447,7 @@ static int rocker_port_obj_add(struct net_device *dev,
 		err = rocker_port_vlans_add(rocker_port, vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
-		fib4 = &obj->u.ipv4_fib;
+		fib4 = (struct switchdev_obj_ipv4_fib *) obj;
 		err = rocker_port_fib_ipv4(rocker_port, obj->trans,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id, 0);
@@ -4519,7 +4519,7 @@ static int rocker_port_obj_del(struct net_device *dev,
 		err = rocker_port_vlans_del(rocker_port, vlan);
 		break;
 	case SWITCHDEV_OBJ_IPV4_FIB:
-		fib4 = &obj->u.ipv4_fib;
+		fib4 = (struct switchdev_obj_ipv4_fib *) obj;
 		err = rocker_port_fib_ipv4(rocker_port, SWITCHDEV_TRANS_NONE,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id,
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 55fa106..0b76aa8 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -55,15 +55,6 @@ struct switchdev_obj {
 	enum switchdev_trans trans;
 	int (*cb)(struct net_device *dev, struct switchdev_obj *obj);
 	union {
-		struct switchdev_obj_ipv4_fib {		/* IPV4_FIB */
-			u32 dst;
-			int dst_len;
-			struct fib_info *fi;
-			u8 tos;
-			u8 type;
-			u32 nlflags;
-			u32 tb_id;
-		} ipv4_fib;
 		struct switchdev_obj_fdb {		/* PORT_FDB */
 			const unsigned char *addr;
 			u16 vid;
@@ -80,6 +71,18 @@ struct switchdev_obj_vlan {
 	u16 vid_end;
 };
 
+/* SWITCHDEV_OBJ_IPV4_FIB */
+struct switchdev_obj_ipv4_fib {
+	struct switchdev_obj obj;	/* must be first */
+	u32 dst;
+	int dst_len;
+	struct fib_info *fi;
+	u8 tos;
+	u8 type;
+	u32 nlflags;
+	u32 tb_id;
+};
+
 /**
  * struct switchdev_ops - switchdev operations
  *
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 9923a97..10fde6f 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -936,17 +936,15 @@ static struct net_device *switchdev_get_dev_by_nhs(struct fib_info *fi)
 int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 nlflags, u32 tb_id)
 {
-	struct switchdev_obj fib_obj = {
-		.id = SWITCHDEV_OBJ_IPV4_FIB,
-		.u.ipv4_fib = {
-			.dst = dst,
-			.dst_len = dst_len,
-			.fi = fi,
-			.tos = tos,
-			.type = type,
-			.nlflags = nlflags,
-			.tb_id = tb_id,
-		},
+	struct switchdev_obj_ipv4_fib fib_obj = {
+		.obj.id = SWITCHDEV_OBJ_IPV4_FIB,
+		.dst = dst,
+		.dst_len = dst_len,
+		.fi = fi,
+		.tos = tos,
+		.type = type,
+		.nlflags = nlflags,
+		.tb_id = tb_id,
 	};
 	struct net_device *dev;
 	int err = 0;
@@ -967,7 +965,7 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	if (!dev)
 		return 0;
 
-	err = switchdev_port_obj_add(dev, &fib_obj);
+	err = switchdev_port_obj_add(dev, &fib_obj.obj);
 	if (!err)
 		fi->fib_flags |= RTNH_F_OFFLOAD;
 
@@ -990,17 +988,15 @@ EXPORT_SYMBOL_GPL(switchdev_fib_ipv4_add);
 int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 			   u8 tos, u8 type, u32 tb_id)
 {
-	struct switchdev_obj fib_obj = {
-		.id = SWITCHDEV_OBJ_IPV4_FIB,
-		.u.ipv4_fib = {
-			.dst = dst,
-			.dst_len = dst_len,
-			.fi = fi,
-			.tos = tos,
-			.type = type,
-			.nlflags = 0,
-			.tb_id = tb_id,
-		},
+	struct switchdev_obj_ipv4_fib fib_obj = {
+		.obj.id = SWITCHDEV_OBJ_IPV4_FIB,
+		.dst = dst,
+		.dst_len = dst_len,
+		.fi = fi,
+		.tos = tos,
+		.type = type,
+		.nlflags = 0,
+		.tb_id = tb_id,
 	};
 	struct net_device *dev;
 	int err = 0;
@@ -1012,7 +1008,7 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	if (!dev)
 		return 0;
 
-	err = switchdev_port_obj_del(dev, &fib_obj);
+	err = switchdev_port_obj_del(dev, &fib_obj.obj);
 	if (!err)
 		fi->fib_flags &= ~RTNH_F_OFFLOAD;
 
-- 
2.5.1
