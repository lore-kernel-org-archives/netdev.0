From: sfeldma@gmail.com
Subject: [PATCH net-next v2 08/26] rocker: use swdev add/del obj for bridge port vlans
Date: Wed,  1 Apr 2015 03:07:44 -0700
Message-ID: <1427882882-2533-9-git-send-email-sfeldma@gmail.com>
References: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35210 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597AbbDAKGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 06:06:37 -0400
Received: by patj18 with SMTP id j18so47873805pat.2
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 03:06:37 -0700 (PDT)
In-Reply-To: <1427882882-2533-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   93 ++++++++++++++++++++++++++++++++++
 1 file changed, 93 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 7602973..900d4fb 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4264,6 +4264,97 @@ static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
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
+	switch (obj->id) {
+	case SWDEV_OBJ_PORT_VLAN:
+		err = rocker_port_vlans_add(rocker_port, &obj->vlan);
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
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
@@ -4292,6 +4383,8 @@ static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
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
