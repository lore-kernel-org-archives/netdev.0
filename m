From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 4/7] switchdev: remove pointers from switchdev objects
Date: Mon, 12 Oct 2015 17:45:47 +0200
Message-ID: <1444664750-11260-5-git-send-email-jiri@resnulli.us>
References: <1444664750-11260-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35858 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbbJLPp6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 11:45:58 -0400
Received: by wicgb1 with SMTP id gb1so154343689wic.1
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 08:45:57 -0700 (PDT)
In-Reply-To: <1444664750-11260-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

When object is used in deferred work, we cannot use pointers in
switchdev object structures because the memory they point at may be already
used by someone else. So rather do local copy of the value.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.c |  6 +++---
 include/net/switchdev.h              |  7 +++----
 net/bridge/br_fdb.c                  |  2 +-
 net/dsa/slave.c                      |  2 +-
 net/switchdev/switchdev.c            | 11 +++++++----
 5 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index eafa907..bb956a5 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4469,7 +4469,7 @@ static int rocker_port_obj_add(struct net_device *dev,
 		fib4 = SWITCHDEV_OBJ_IPV4_FIB(obj);
 		err = rocker_port_fib_ipv4(rocker_port, trans,
 					   htonl(fib4->dst), fib4->dst_len,
-					   fib4->fi, fib4->tb_id, 0);
+					   &fib4->fi, fib4->tb_id, 0);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = rocker_port_fdb_add(rocker_port, trans,
@@ -4541,7 +4541,7 @@ static int rocker_port_obj_del(struct net_device *dev,
 		fib4 = SWITCHDEV_OBJ_IPV4_FIB(obj);
 		err = rocker_port_fib_ipv4(rocker_port, NULL,
 					   htonl(fib4->dst), fib4->dst_len,
-					   fib4->fi, fib4->tb_id,
+					   &fib4->fi, fib4->tb_id,
 					   ROCKER_OP_FLAG_REMOVE);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
@@ -4571,7 +4571,7 @@ static int rocker_port_fdb_dump(const struct rocker_port *rocker_port,
 	hash_for_each_safe(rocker->fdb_tbl, bkt, tmp, found, entry) {
 		if (found->key.rocker_port != rocker_port)
 			continue;
-		fdb->addr = found->key.addr;
+		ether_addr_copy(fdb->addr, found->key.addr);
 		fdb->ndm_state = NUD_REACHABLE;
 		fdb->vid = rocker_port_vlan_to_vid(rocker_port,
 						   found->key.vlan_id);
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 6b109e4..767d516 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -14,6 +14,7 @@
 #include <linux/netdevice.h>
 #include <linux/notifier.h>
 #include <linux/list.h>
+#include <net/ip_fib.h>
 
 #define SWITCHDEV_F_NO_RECURSE		BIT(0)
 #define SWITCHDEV_F_SKIP_EOPNOTSUPP	BIT(1)
@@ -59,8 +60,6 @@ struct switchdev_attr {
 	} u;
 };
 
-struct fib_info;
-
 enum switchdev_obj_id {
 	SWITCHDEV_OBJ_ID_UNDEFINED,
 	SWITCHDEV_OBJ_ID_PORT_VLAN,
@@ -88,7 +87,7 @@ struct switchdev_obj_ipv4_fib {
 	struct switchdev_obj obj;
 	u32 dst;
 	int dst_len;
-	struct fib_info *fi;
+	struct fib_info fi;
 	u8 tos;
 	u8 type;
 	u32 nlflags;
@@ -101,7 +100,7 @@ struct switchdev_obj_ipv4_fib {
 /* SWITCHDEV_OBJ_ID_PORT_FDB */
 struct switchdev_obj_port_fdb {
 	struct switchdev_obj obj;
-	const unsigned char *addr;
+	unsigned char addr[ETH_ALEN];
 	u16 vid;
 	u16 ndm_state;
 };
diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index f43ce05..f5e7da0 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -135,10 +135,10 @@ static void fdb_del_external_learn(struct net_bridge_fdb_entry *f)
 {
 	struct switchdev_obj_port_fdb fdb = {
 		.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
-		.addr = f->addr.addr,
 		.vid = f->vlan_id,
 	};
 
+	ether_addr_copy(fdb.addr, f->addr.addr);
 	switchdev_port_obj_del(f->dst->dev, &fdb.obj);
 }
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index bb2bd3b..2ad4e0e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -393,7 +393,7 @@ static int dsa_slave_port_fdb_dump(struct net_device *dev,
 		if (ret < 0)
 			break;
 
-		fdb->addr = addr;
+		ether_addr_copy(fdb->addr, addr);
 		fdb->vid = vid;
 		fdb->ndm_state = is_static ? NUD_NOARP : NUD_REACHABLE;
 
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 5a92d08..77b616b 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -15,6 +15,7 @@
 #include <linux/mutex.h>
 #include <linux/notifier.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/if_bridge.h>
 #include <linux/list.h>
 #include <linux/workqueue.h>
@@ -842,10 +843,10 @@ int switchdev_port_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 {
 	struct switchdev_obj_port_fdb fdb = {
 		.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
-		.addr = addr,
 		.vid = vid,
 	};
 
+	ether_addr_copy(fdb.addr, addr);
 	return switchdev_port_obj_add(dev, &fdb.obj);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_add);
@@ -867,10 +868,10 @@ int switchdev_port_fdb_del(struct ndmsg *ndm, struct nlattr *tb[],
 {
 	struct switchdev_obj_port_fdb fdb = {
 		.obj.id = SWITCHDEV_OBJ_ID_PORT_FDB,
-		.addr = addr,
 		.vid = vid,
 	};
 
+	ether_addr_copy(fdb.addr, addr);
 	return switchdev_port_obj_del(dev, &fdb.obj);
 }
 EXPORT_SYMBOL_GPL(switchdev_port_fdb_del);
@@ -1032,7 +1033,6 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 		.obj.id = SWITCHDEV_OBJ_ID_IPV4_FIB,
 		.dst = dst,
 		.dst_len = dst_len,
-		.fi = fi,
 		.tos = tos,
 		.type = type,
 		.nlflags = nlflags,
@@ -1041,6 +1041,8 @@ int switchdev_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
 	struct net_device *dev;
 	int err = 0;
 
+	memcpy(&ipv4_fib.fi, fi, sizeof(ipv4_fib.fi));
+
 	/* Don't offload route if using custom ip rules or if
 	 * IPv4 FIB offloading has been disabled completely.
 	 */
@@ -1084,7 +1086,6 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 		.obj.id = SWITCHDEV_OBJ_ID_IPV4_FIB,
 		.dst = dst,
 		.dst_len = dst_len,
-		.fi = fi,
 		.tos = tos,
 		.type = type,
 		.nlflags = 0,
@@ -1093,6 +1094,8 @@ int switchdev_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
 	struct net_device *dev;
 	int err = 0;
 
+	memcpy(&ipv4_fib.fi, fi, sizeof(ipv4_fib.fi));
+
 	if (!(fi->fib_flags & RTNH_F_OFFLOAD))
 		return 0;
 
-- 
1.9.3
