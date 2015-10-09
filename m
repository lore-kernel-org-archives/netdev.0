From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] bridge: try switchdev op first in __vlan_vid_add/del
Date: Fri,  9 Oct 2015 13:54:11 +0200
Message-ID: <1444391651-13775-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
	john.fastabend@gmail.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:37961 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbbJILyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 07:54:15 -0400
Received: by wiclk2 with SMTP id lk2so63741788wic.1
        for <netdev@vger.kernel.org>; Fri, 09 Oct 2015 04:54:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Some drivers need to implement both switchdev vlan ops and
vid_add/kill ndos. For that to work in bridge code, we need to try
switchdev op first when adding/deleting vlan id.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 net/bridge/br_vlan.c | 58 ++++++++++++++++++++--------------------------------
 1 file changed, 22 insertions(+), 36 deletions(-)

diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index eae07ee..975deb9 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -72,28 +72,20 @@ static void __vlan_add_flags(struct net_bridge_vlan *v, u16 flags)
 static int __vlan_vid_add(struct net_device *dev, struct net_bridge *br,
 			  u16 vid, u16 flags)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
+	struct switchdev_obj_port_vlan v = {
+		.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
+		.flags = flags,
+		.vid_begin = vid,
+		.vid_end = vid,
+	};
 	int err;
 
-	/* If driver uses VLAN ndo ops, use 8021q to install vid
-	 * on device, otherwise try switchdev ops to install vid.
+	/* Try switchdev op first. In case it is not supported, fallback to
+	 * 8021q add.
 	 */
-
-	if (ops->ndo_vlan_rx_add_vid) {
-		err = vlan_vid_add(dev, br->vlan_proto, vid);
-	} else {
-		struct switchdev_obj_port_vlan v = {
-			.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
-			.flags = flags,
-			.vid_begin = vid,
-			.vid_end = vid,
-		};
-
-		err = switchdev_port_obj_add(dev, &v.obj);
-		if (err == -EOPNOTSUPP)
-			err = 0;
-	}
-
+	err = switchdev_port_obj_add(dev, &v.obj);
+	if (err == -EOPNOTSUPP)
+		return vlan_vid_add(dev, br->vlan_proto, vid);
 	return err;
 }
 
@@ -122,27 +114,21 @@ static void __vlan_del_list(struct net_bridge_vlan *v)
 static int __vlan_vid_del(struct net_device *dev, struct net_bridge *br,
 			  u16 vid)
 {
-	const struct net_device_ops *ops = dev->netdev_ops;
-	int err = 0;
+	struct switchdev_obj_port_vlan v = {
+		.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
+		.vid_begin = vid,
+		.vid_end = vid,
+	};
+	int err;
 
-	/* If driver uses VLAN ndo ops, use 8021q to delete vid
-	 * on device, otherwise try switchdev ops to delete vid.
+	/* Try switchdev op first. In case it is not supported, fallback to
+	 * 8021q del.
 	 */
-
-	if (ops->ndo_vlan_rx_kill_vid) {
+	err = switchdev_port_obj_del(dev, &v.obj);
+	if (err == -EOPNOTSUPP) {
 		vlan_vid_del(dev, br->vlan_proto, vid);
-	} else {
-		struct switchdev_obj_port_vlan v = {
-			.obj.id = SWITCHDEV_OBJ_ID_PORT_VLAN,
-			.vid_begin = vid,
-			.vid_end = vid,
-		};
-
-		err = switchdev_port_obj_del(dev, &v.obj);
-		if (err == -EOPNOTSUPP)
-			err = 0;
+		return 0;
 	}
-
 	return err;
 }
 
-- 
1.9.3
