From: sfeldma@gmail.com
Subject: [PATCH net-next v6 09/23] rocker: use switchdev add/del obj for bridge port vlans
Date: Sat,  9 May 2015 10:40:11 -0700
Message-ID: <1431193225-807-10-git-send-email-sfeldma@gmail.com>
References: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, andrew@lunn.ch, simon.horman@netronome.com,
	joe@perches.com, sridhar.samudrala@intel.com, ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:36463 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbbEIRn0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 13:43:26 -0400
Received: by pabsx10 with SMTP id sx10so75735098pab.3
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 10:43:25 -0700 (PDT)
In-Reply-To: <1431193225-807-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Acked-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c |  130 ++++++++++++++++++++++++++++++++--
 1 file changed, 123 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index d260837..048d4b7 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -3386,20 +3386,22 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 
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
 
@@ -3408,7 +3410,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 	if (err) {
 		netdev_err(rocker_port->dev,
 			   "Error (%d) port VLAN l2 groups\n", err);
-		return err;
+		goto err_out;
 	}
 
 	err = rocker_port_vlan_flood_group(rocker_port, flags,
@@ -3416,7 +3418,7 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 	if (err) {
 		netdev_err(rocker_port->dev,
 			   "Error (%d) port VLAN l2 flood group\n", err);
-		return err;
+		goto err_out;
 	}
 
 	err = rocker_flow_tbl_vlan(rocker_port, flags,
@@ -3426,6 +3428,10 @@ static int rocker_port_vlan(struct rocker_port *rocker_port, int flags,
 		netdev_err(rocker_port->dev,
 			   "Error (%d) port VLAN table\n", err);
 
+err_out:
+	if (rocker_port->trans == SWITCHDEV_TRANS_PREPARE)
+		change_bit(ntohs(internal_vlan_id), rocker_port->vlan_bitmap);
+
 	return err;
 }
 
@@ -4390,6 +4396,114 @@ static int rocker_port_attr_set(struct net_device *dev,
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
+				 struct switchdev_obj_vlan *vlan)
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
+static int rocker_port_obj_add(struct net_device *dev,
+			       struct switchdev_obj *obj)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err = 0;
+
+	rocker_port->trans = obj->trans;
+
+	switch (rocker_port->trans) {
+	case SWITCHDEV_TRANS_PREPARE:
+		BUG_ON(!list_empty(&rocker_port->trans_mem));
+		break;
+	case SWITCHDEV_TRANS_ABORT:
+		rocker_port_trans_abort(rocker_port);
+		return 0;
+	default:
+		break;
+	}
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_PORT_VLAN:
+		err = rocker_port_vlans_add(rocker_port, &obj->vlan);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	rocker_port->trans = SWITCHDEV_TRANS_NONE;
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
+				 struct switchdev_obj_vlan *vlan)
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
+static int rocker_port_obj_del(struct net_device *dev,
+			       struct switchdev_obj *obj)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err = 0;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_PORT_VLAN:
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
 static int rocker_port_switchdev_fib_ipv4_add(struct net_device *dev,
 					      __be32 dst, int dst_len,
 					      struct fib_info *fi,
@@ -4418,6 +4532,8 @@ static int rocker_port_switchdev_fib_ipv4_del(struct net_device *dev,
 static const struct switchdev_ops rocker_port_switchdev_ops = {
 	.switchdev_port_attr_get	= rocker_port_attr_get,
 	.switchdev_port_attr_set	= rocker_port_attr_set,
+	.switchdev_port_obj_add		= rocker_port_obj_add,
+	.switchdev_port_obj_del		= rocker_port_obj_del,
 	.switchdev_fib_ipv4_add		= rocker_port_switchdev_fib_ipv4_add,
 	.switchdev_fib_ipv4_del		= rocker_port_switchdev_fib_ipv4_del,
 };
-- 
1.7.10.4
