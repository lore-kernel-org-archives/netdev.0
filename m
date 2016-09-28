From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 05/12] rocker: Support Open vSwitch (-like) flow stats
Date: Wed, 28 Sep 2016 14:42:55 +0200
Message-ID: <1475066582-1971-6-git-send-email-simon.horman@netronome.com>
References: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36210 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932268AbcI1MnQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:43:16 -0400
Received: by mail-wm0-f41.google.com with SMTP id w84so233852497wmg.1
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:43:15 -0700 (PDT)
In-Reply-To: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prototype an implementation of the new switchdev_port_obj_get SDO for the
SWITCHDEV_OBJ_OVS_FLOW object type. This allows retrieval of
statistics for Open vSwitch (-like) flows which have been programmed into
hardware.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker.h      |  2 ++
 drivers/net/ethernet/rocker/rocker_main.c | 30 ++++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index ebcc863fd25e..332adce701fa 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -122,6 +122,8 @@ struct rocker_world_ops {
 				    struct switchdev_trans *trans);
 	int (*port_obj_sw_flow_del)(struct rocker_port *rocker_port,
 				    const struct switchdev_obj_sw_flow *sw_flow);
+	int (*port_obj_sw_flow_get_stats)(struct rocker_port *rocker_port,
+					  const struct switchdev_obj_sw_flow *sw_flow);
 	int (*port_obj_fib4_add)(struct rocker_port *rocker_port,
 				 const struct switchdev_obj_ipv4_fib *fib4,
 				 struct switchdev_trans *trans);
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index e019772689a6..6c6a486cced6 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1703,6 +1703,16 @@ static int rocker_world_port_obj_sw_flow_del(struct rocker_port *rocker_port,
 	return wops->port_obj_sw_flow_del(rocker_port, sw_flow);
 }
 
+static int rocker_world_port_obj_sw_flow_get_stats(struct rocker_port *rocker_port,
+				const struct switchdev_obj_sw_flow *sw_flow)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_sw_flow_get_stats)
+		return -EOPNOTSUPP;
+	return wops->port_obj_sw_flow_get_stats(rocker_port, sw_flow);
+}
+
 static int rocker_world_port_master_linked(struct rocker_port *rocker_port,
 					   struct net_device *master)
 {
@@ -2197,12 +2207,32 @@ static int rocker_port_obj_dump(struct net_device *dev,
 	return err;
 }
 
+static int rocker_port_obj_get(struct net_device *dev,
+			       struct switchdev_obj *obj)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err = 0;
+
+	switch (obj->id) {
+	case SWITCHDEV_OBJ_SW_FLOW:
+		err = rocker_world_port_obj_sw_flow_get_stats(rocker_port,
+						 SWITCHDEV_OBJ_SW_FLOW(obj));
+		break;
+	default:
+		err = -EOPNOTSUPP;
+		break;
+	}
+
+	return err;
+}
+
 static const struct switchdev_ops rocker_port_switchdev_ops = {
 	.switchdev_port_attr_get	= rocker_port_attr_get,
 	.switchdev_port_attr_set	= rocker_port_attr_set,
 	.switchdev_port_obj_add		= rocker_port_obj_add,
 	.switchdev_port_obj_del		= rocker_port_obj_del,
 	.switchdev_port_obj_dump	= rocker_port_obj_dump,
+	.switchdev_port_obj_get		= rocker_port_obj_get,
 };
 
 /********************
-- 
2.7.0.rc3.207.g0ac5344
