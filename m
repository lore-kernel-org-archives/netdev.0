From: sfeldma@gmail.com
Subject: [PATCH net-next v3 08/26] rocker: use swdev add/del obj for bridge port vlans
Date: Thu,  2 Apr 2015 01:09:54 -0700
Message-ID: <1427962212-18411-9-git-send-email-sfeldma@gmail.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36639 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbbDBIJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 04:09:30 -0400
Received: by padcy3 with SMTP id cy3so77261189pad.3
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 01:09:30 -0700 (PDT)
In-Reply-To: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   96 ++++++++++++++++++++++++++++++++++
 1 file changed, 96 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index c9b5299..8c7ef8a 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4267,6 +4267,100 @@ static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
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
+	if (obj->flags & SWDEV_F_TRANS_PREPARE)
+		return 0;
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
@@ -4295,6 +4389,8 @@ static int rocker_port_swdev_fib_ipv4_del(struct net_device *dev,
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
