From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/6] net: bridge: Notify on bridge device mrouter state changes
Date: Thu,  5 Oct 2017 12:36:38 +0200
Message-ID: <20171005103642.1414-3-jiri@resnulli.us>
References: <20171005103642.1414-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36824 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751721AbdJEKgv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 06:36:51 -0400
Received: by mail-wr0-f193.google.com with SMTP id l10so1121373wre.3
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 03:36:50 -0700 (PDT)
In-Reply-To: <20171005103642.1414-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Add the SWITCHDEV_ATTR_ID_BRIDGE_MROUTER switchdev notification type, used
to indicate whether the bridge is or isn't mrouter. Notify when the bridge
changes its state, similarly to the already existing bridged port mrouter
notifications.

The notification uses the switchdev_attr.u.mrouter boolean flag to indicate
the current bridge mrouter status. Thus, it only indicates whether the
bridge is currently used as an mrouter or not, and does not indicate the
exact mrouter state of the bridge (learning, permanent, etc.).

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h   |  1 +
 net/bridge/br_multicast.c | 21 ++++++++++++++++++++-
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index d767b79..d756fbe 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -51,6 +51,7 @@ enum switchdev_attr_id {
 	SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
 	SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
 	SWITCHDEV_ATTR_ID_BRIDGE_MC_DISABLED,
+	SWITCHDEV_ATTR_ID_BRIDGE_MROUTER,
 };
 
 struct switchdev_attr {
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index b86307b..4d4fcb5 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -859,6 +859,19 @@ static void br_multicast_router_expired(unsigned long data)
 	spin_unlock(&br->multicast_lock);
 }
 
+static void br_mc_router_state_change(struct net_bridge *p,
+				      bool is_mc_router)
+{
+	struct switchdev_attr attr = {
+		.orig_dev = p->dev,
+		.id = SWITCHDEV_ATTR_ID_BRIDGE_MROUTER,
+		.flags = SWITCHDEV_F_DEFER,
+		.u.mrouter = is_mc_router,
+	};
+
+	switchdev_port_attr_set(p->dev, &attr);
+}
+
 static void br_multicast_local_router_expired(unsigned long data)
 {
 	struct net_bridge *br = (struct net_bridge *) data;
@@ -869,6 +882,7 @@ static void br_multicast_local_router_expired(unsigned long data)
 	    timer_pending(&br->multicast_router_timer))
 		goto out;
 
+	br_mc_router_state_change(br, false);
 	br->multicast_router = MDB_RTR_TYPE_TEMP_QUERY;
 out:
 	spin_unlock(&br->multicast_lock);
@@ -1379,6 +1393,8 @@ static void br_multicast_mark_router(struct net_bridge *br,
 		    br->multicast_router == MDB_RTR_TYPE_TEMP) {
 			mod_timer(&br->multicast_router_timer,
 				  now + br->multicast_querier_interval);
+			if (br->multicast_router == MDB_RTR_TYPE_TEMP_QUERY)
+				br_mc_router_state_change(br, true);
 			br->multicast_router = MDB_RTR_TYPE_TEMP;
 		}
 		return;
@@ -2056,13 +2072,16 @@ int br_multicast_set_router(struct net_bridge *br, unsigned long val)
 	switch (val) {
 	case MDB_RTR_TYPE_DISABLED:
 	case MDB_RTR_TYPE_PERM:
+		br_mc_router_state_change(br, val == MDB_RTR_TYPE_PERM);
 		del_timer(&br->multicast_router_timer);
 		br->multicast_router = val;
 		err = 0;
 		break;
 	case MDB_RTR_TYPE_TEMP_QUERY:
-		if (br->multicast_router != MDB_RTR_TYPE_TEMP)
+		if (br->multicast_router != MDB_RTR_TYPE_TEMP) {
+			br_mc_router_state_change(br, false);
 			br->multicast_router = val;
+		}
 		err = 0;
 		break;
 	}
-- 
2.9.5
