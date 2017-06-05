From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 15/19] rocker: Add support for querying supported bridge flags
Date: Mon,  5 Jun 2017 11:20:39 +0200
Message-ID: <20170605092043.3523-16-jiri@resnulli.us>
References: <20170605092043.3523-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35290 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751802AbdFEJVQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 05:21:16 -0400
Received: by mail-wm0-f67.google.com with SMTP id g15so28760880wmc.2
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 02:21:15 -0700 (PDT)
In-Reply-To: <20170605092043.3523-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for querying supported bridge flags.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.h       |  4 ++++
 drivers/net/ethernet/rocker/rocker_main.c  | 18 ++++++++++++++++++
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 11 +++++++++++
 3 files changed, 33 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index ee9675d..c25e331 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -112,6 +112,10 @@ struct rocker_world_ops {
 					  struct switchdev_trans *trans);
 	int (*port_attr_bridge_flags_get)(const struct rocker_port *rocker_port,
 					  unsigned long *p_brport_flags);
+	int (*port_attr_bridge_flags_support_get)(const struct rocker_port *
+						  rocker_port,
+						  unsigned long *
+						  p_brport_flags);
 	int (*port_attr_bridge_ageing_time_set)(struct rocker_port *rocker_port,
 						u32 ageing_time,
 						struct switchdev_trans *trans);
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index bab1361..a741e51 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1585,6 +1585,20 @@ rocker_world_port_attr_bridge_flags_get(const struct rocker_port *rocker_port,
 }
 
 static int
+rocker_world_port_attr_bridge_flags_support_get(const struct rocker_port *
+						rocker_port,
+						unsigned long *
+						p_brport_flags_support)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_attr_bridge_flags_support_get)
+		return -EOPNOTSUPP;
+	return wops->port_attr_bridge_flags_support_get(rocker_port,
+							p_brport_flags_support);
+}
+
+static int
 rocker_world_port_attr_bridge_ageing_time_set(struct rocker_port *rocker_port,
 					      u32 ageing_time,
 					      struct switchdev_trans *trans)
@@ -2053,6 +2067,10 @@ static int rocker_port_attr_get(struct net_device *dev,
 		err = rocker_world_port_attr_bridge_flags_get(rocker_port,
 							      &attr->u.brport_flags);
 		break;
+	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT:
+		err = rocker_world_port_attr_bridge_flags_support_get(rocker_port,
+								      &attr->u.brport_flags_support);
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index 0b5a58f..7528ee7 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -2643,6 +2643,16 @@ ofdpa_port_attr_bridge_flags_get(const struct rocker_port *rocker_port,
 }
 
 static int
+ofdpa_port_attr_bridge_flags_support_get(const struct rocker_port *
+					 rocker_port,
+					 unsigned long *
+					 p_brport_flags_support)
+{
+	*p_brport_flags_support = BR_LEARNING;
+	return 0;
+}
+
+static int
 ofdpa_port_attr_bridge_ageing_time_set(struct rocker_port *rocker_port,
 				       u32 ageing_time,
 				       struct switchdev_trans *trans)
@@ -2989,6 +2999,7 @@ struct rocker_world_ops rocker_ofdpa_ops = {
 	.port_attr_stp_state_set = ofdpa_port_attr_stp_state_set,
 	.port_attr_bridge_flags_set = ofdpa_port_attr_bridge_flags_set,
 	.port_attr_bridge_flags_get = ofdpa_port_attr_bridge_flags_get,
+	.port_attr_bridge_flags_support_get = ofdpa_port_attr_bridge_flags_support_get,
 	.port_attr_bridge_ageing_time_set = ofdpa_port_attr_bridge_ageing_time_set,
 	.port_obj_vlan_add = ofdpa_port_obj_vlan_add,
 	.port_obj_vlan_del = ofdpa_port_obj_vlan_del,
-- 
2.9.3
