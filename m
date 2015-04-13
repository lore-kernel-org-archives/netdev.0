From: sfeldma@gmail.com
Subject: [PATCH net-next v4 08/24] rocker: use swdev add/del obj for bridge port vlans
Date: Sun, 12 Apr 2015 23:17:02 -0700
Message-ID: <1428905838-14920-9-git-send-email-sfeldma@gmail.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36457 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950AbbDMGQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 02:16:41 -0400
Received: by pabsx10 with SMTP id sx10so91882131pab.3
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 23:16:40 -0700 (PDT)
In-Reply-To: <1428905838-14920-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |  128 ++++++++++++++++++++++++++++++++--
 1 file changed, 121 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 9bd4fc6..f81e362 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3384,20 +3384,22 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 
 	internal_vlan_id = rocker_port_vid_to_vlan(rocker_port, vid, &untagged);
 
-	if (adding && test_and_set_bit(ntohs(internal_vlan_id),
-				       rocker_port->vlan_bitmap))
+	if (adding && test_bit(ntohs(internal_vlan_id),
+			       rocker_port->vlan_bitmap))
 			return 0; /* already added */
-	else if (!adding && !test_and_clear_bit(ntohs(internal_vlan_id),
-						rocker_port->vlan_bitmap))
+	else if (!adding && !test_bit(ntohs(internal_vlan_id),
+				      rocker_port->vlan_bitmap))
 			return 0; /* already removed */
 
+	change_bit(ntohs(internal_vlan_id), rocker_port->vlan_bitmap);
+
 	if (adding) {
 		err = rocker_port_ctrl_vlan_add(rocker_port, flags,
 						internal_vlan_id);
 		if (err) {
 			netdev_err(rocker_port->dev,
 				   "Error (%d) port ctrl vlan add\n", err);
-			return err;
+			goto err_out;
 		}
 	}
 
@@ -3406,7 +3408,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 	if (err) {
 		netdev_err(rocker_port->dev,
 			   "Error (%d) port VLAN l2 groups\n", err);
-		return err;
+		goto err_out;
 	}
 
 	err = rocker_port_vlan_flood_group(rocker_port, flags,
@@ -3414,7 +3416,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 	if (err) {
 		netdev_err(rocker_port->dev,
 			   "Error (%d) port VLAN l2 flood group\n", err);
-		return err;
+		goto err_out;
 	}
 
 	err = rocker_flow_tbl_vlan(rocker_port, flags,
@@ -3424,6 +3426,10 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 		netdev_err(rocker_port->dev,
 			   "Error (%d) port VLAN table\n", err);
 
+err_out:
+	if (rocker_port->trans == SWDEV_TRANS_PREPARE)
+		change_bit(ntohs(internal_vlan_id), rocker_port->vlan_bitmap);
+
 	return err;
 }
 
@@ -4407,6 +4413,112 @@ static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
 	return err;
 }
 
+static int rocker_port_vlan_add(struct rocker_port *rocker_port,
+				u16 vid, u16 flags)
+{
+	int err;
+
+	/* XXX deal with flags for PVID and untagged */
+
+	err = rocker_port_vlan(rocker_port, 0, vid);
+	if (err)
+		return err;
+
+	return rocker_port_router_mac(rocker_port, 0, htons(vid));
+}
+
+static int rocker_port_vlans_add(struct rocker_port *rocker_port,
+				 struct swdev_obj_vlan *vlan)
+{
+	u16 vid;
+	int err;
+
+	for (vid = vlan->vid_start; vid <= vlan->vid_end; vid++) {
+		err = rocker_port_vlan_add(rocker_port, vid, vlan->flags);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int rocker_port_obj_add(struct net_device *dev, struct swdev_obj *obj)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err = 0;
+
+	rocker_port->trans = obj->trans;
+
+	switch (rocker_port->trans) {
+	case SWDEV_TRANS_PREPARE:
+		BUG_ON(!list_empty(&rocker_port->trans_mem));
+		break;
+	case SWDEV_TRANS_ABORT:
+		rocker_port_trans_abort(rocker_port);
+		return 0;
+	default:
+		break;
+	}
+
+	switch (obj->id) {
+	case SWDEV_OBJ_PORT_VLAN:
+		err = rocker_port_vlans_add(rocker_port, &obj->vlan);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	rocker_port->trans = SWDEV_TRANS_NONE;
+
+	return err;
+}
+
+static int rocker_port_vlan_del(struct rocker_port *rocker_port,
+				u16 vid, u16 flags)
+{
+	int err;
+
+	err = rocker_port_router_mac(rocker_port, ROCKER_OP_FLAG_REMOVE,
+				     htons(vid));
+	if (err)
+		return err;
+
+	return rocker_port_vlan(rocker_port, ROCKER_OP_FLAG_REMOVE, vid);
+}
+
+static int rocker_port_vlans_del(struct rocker_port *rocker_port,
+				 struct swdev_obj_vlan *vlan)
+{
+	u16 vid;
+	int err;
+
+	for (vid = vlan->vid_start; vid <= vlan->vid_end; vid++) {
+		err = rocker_port_vlan_del(rocker_port, vid, vlan->flags);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+static int rocker_port_obj_del(struct net_device *dev, struct swdev_obj *obj)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err = 0;
+
+	switch (obj->id) {
+	case SWDEV_OBJ_PORT_VLAN:
+		err = rocker_port_vlans_del(rocker_port, &obj->vlan);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
 static int rocker_port_swdev_fib_ipv4_add(struct net_device *dev,
 					  __be32 dst, int dst_len,
 					  struct fib_info *fi,
@@ -4435,6 +4547,8 @@ static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
 static const struct swdev_ops rocker_port_swdev_ops = {
 	.swdev_port_attr_get		= rocker_port_attr_get,
 	.swdev_port_attr_set		= rocker_port_attr_set,
+	.swdev_port_obj_add		= rocker_port_obj_add,
+	.swdev_port_obj_del		= rocker_port_obj_del,
 	.swdev_fib_ipv4_add		= rocker_port_swdev_fib_ipv4_add,
 	.swdev_fib_ipv4_del		= rocker_port_swdev_fib_ipv4_del,
 };
-- 
1.7.10.4
