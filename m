From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 04/12] rocker: Add Open vSwitch (-like) flow support
Date: Wed, 28 Sep 2016 14:42:54 +0200
Message-ID: <1475066582-1971-5-git-send-email-simon.horman@netronome.com>
References: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:33216 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932223AbcI1MnP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:43:15 -0400
Received: by mail-wm0-f48.google.com with SMTP id d66so37197788wmf.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:43:14 -0700 (PDT)
In-Reply-To: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prototype programming of Open vSwitch (-like) flows into hardware
by implementing SWITCHDEV_OBJ_OVS_FLOW type objects in the
rocker_port_obj_{add,del} SDO, a new object type that
was added by an earlier patch in that forms part of this prototype.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker.h      |  5 +++++
 drivers/net/ethernet/rocker/rocker_main.c | 30 ++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 1ab995f7146b..ebcc863fd25e 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -117,6 +117,11 @@ struct rocker_world_ops {
 	int (*port_obj_vlan_dump)(const struct rocker_port *rocker_port,
 				  struct switchdev_obj_port_vlan *vlan,
 				  switchdev_obj_dump_cb_t *cb);
+	int (*port_obj_sw_flow_add)(struct rocker_port *rocker_port,
+				    const struct switchdev_obj_sw_flow *sw_flow,
+				    struct switchdev_trans *trans);
+	int (*port_obj_sw_flow_del)(struct rocker_port *rocker_port,
+				    const struct switchdev_obj_sw_flow *sw_flow);
 	int (*port_obj_fib4_add)(struct rocker_port *rocker_port,
 				 const struct switchdev_obj_ipv4_fib *fib4,
 				 struct switchdev_trans *trans);
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 1f0c08602eba..e019772689a6 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1682,6 +1682,27 @@ rocker_world_port_obj_fdb_dump(const struct rocker_port *rocker_port,
 	return wops->port_obj_fdb_dump(rocker_port, fdb, cb);
 }
 
+static int rocker_world_port_obj_sw_flow_add(struct rocker_port *rocker_port,
+				const struct switchdev_obj_sw_flow *sw_flow,
+				struct switchdev_trans *trans)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_sw_flow_add)
+		return -EOPNOTSUPP;
+	return wops->port_obj_sw_flow_add(rocker_port, sw_flow, trans);
+}
+
+static int rocker_world_port_obj_sw_flow_del(struct rocker_port *rocker_port,
+				const struct switchdev_obj_sw_flow *sw_flow)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_sw_flow_del)
+		return -EOPNOTSUPP;
+	return wops->port_obj_sw_flow_del(rocker_port, sw_flow);
+}
+
 static int rocker_world_port_master_linked(struct rocker_port *rocker_port,
 					   struct net_device *master)
 {
@@ -2106,6 +2127,11 @@ static int rocker_port_obj_add(struct net_device *dev,
 						    SWITCHDEV_OBJ_PORT_FDB(obj),
 						    trans);
 		break;
+	case SWITCHDEV_OBJ_SW_FLOW:
+		err = rocker_world_port_obj_sw_flow_add(rocker_port,
+							 SWITCHDEV_OBJ_SW_FLOW(obj),
+							 trans);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
@@ -2133,6 +2159,10 @@ static int rocker_port_obj_del(struct net_device *dev,
 		err = rocker_world_port_obj_fdb_del(rocker_port,
 						    SWITCHDEV_OBJ_PORT_FDB(obj));
 		break;
+	case SWITCHDEV_OBJ_SW_FLOW:
+		err = rocker_world_port_obj_sw_flow_del(rocker_port,
+							 SWITCHDEV_OBJ_SW_FLOW(obj));
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
2.7.0.rc3.207.g0ac5344
