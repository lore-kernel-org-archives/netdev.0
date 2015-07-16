From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next] rocker: forward packets to CPU when port is joined to openvswitch
Date: Thu, 16 Jul 2015 10:39:14 +0900
Message-ID: <1437010754-29038-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:33157 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755154AbbGPBjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 21:39:37 -0400
Received: by pdbqm3 with SMTP id qm3so34684921pdb.0
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 18:39:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Teach rocker to forward packets to CPU when a port is joined to Open vSwitch.
There is scope to later refine what is passed up as per Open vSwitch flows
on a port.

This does not change the behaviour of rocker ports that are
not joined to Open vSwitch.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker.c | 62 +++++++++++++++++++++++++++++-------
 1 file changed, 50 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index c0051673c9fa..0c8e7ceb4205 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -202,6 +202,7 @@ enum {
 	ROCKER_CTRL_IPV4_MCAST,
 	ROCKER_CTRL_IPV6_MCAST,
 	ROCKER_CTRL_DFLT_BRIDGING,
+	ROCKER_CTRL_DFLT_OVS,
 	ROCKER_CTRL_MAX,
 };
 
@@ -321,9 +322,21 @@ static u16 rocker_port_vlan_to_vid(const struct rocker_port *rocker_port,
 	return ntohs(vlan_id);
 }
 
+static bool rocker_port_is_slave(const struct rocker_port *rocker_port,
+				   const char *kind)
+{
+	return rocker_port->bridge_dev &&
+		!strcmp(rocker_port->bridge_dev->rtnl_link_ops->kind, kind);
+}
+
 static bool rocker_port_is_bridged(const struct rocker_port *rocker_port)
 {
-	return !!rocker_port->bridge_dev;
+	return rocker_port_is_slave(rocker_port, "bridge");
+}
+
+static bool rocker_port_is_ovsed(const struct rocker_port *rocker_port)
+{
+	return rocker_port_is_slave(rocker_port, "openvswitch");
 }
 
 #define ROCKER_OP_FLAG_REMOVE		BIT(0)
@@ -3275,6 +3288,12 @@ static struct rocker_ctrl {
 		.bridge = true,
 		.copy_to_cpu = true,
 	},
+	[ROCKER_CTRL_DFLT_OVS] = {
+		/* pass all pkts up to CPU */
+		.eth_dst = zero_mac,
+		.eth_dst_mask = zero_mac,
+		.acl = true,
+	},
 };
 
 static int rocker_port_ctrl_vlan_acl(struct rocker_port *rocker_port,
@@ -3787,11 +3806,14 @@ static int rocker_port_stp_update(struct rocker_port *rocker_port,
 		break;
 	case BR_STATE_LEARNING:
 	case BR_STATE_FORWARDING:
-		want[ROCKER_CTRL_LINK_LOCAL_MCAST] = true;
+		if (!rocker_port_is_ovsed(rocker_port))
+			want[ROCKER_CTRL_LINK_LOCAL_MCAST] = true;
 		want[ROCKER_CTRL_IPV4_MCAST] = true;
 		want[ROCKER_CTRL_IPV6_MCAST] = true;
 		if (rocker_port_is_bridged(rocker_port))
 			want[ROCKER_CTRL_DFLT_BRIDGING] = true;
+		else if (rocker_port_is_ovsed(rocker_port))
+			want[ROCKER_CTRL_DFLT_OVS] = true;
 		else
 			want[ROCKER_CTRL_LOCAL_ARP] = true;
 		break;
@@ -5251,23 +5273,39 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 	return err;
 }
 
+
+static int rocker_port_ovs_changed(struct rocker_port *rocker_port,
+				   struct net_device *master)
+{
+	int err;
+
+	rocker_port->bridge_dev = master;
+
+	err = rocker_port_fwd_disable(rocker_port, SWITCHDEV_TRANS_NONE, 0);
+	if (err)
+		return err;
+	err = rocker_port_fwd_enable(rocker_port, SWITCHDEV_TRANS_NONE, 0);
+
+	return err;
+}
+
 static int rocker_port_master_changed(struct net_device *dev)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct net_device *master = netdev_master_upper_dev_get(dev);
 	int err = 0;
 
-	/* There are currently three cases handled here:
-	 * 1. Joining a bridge
-	 * 2. Leaving a previously joined bridge
-	 * 3. Other, e.g. being added to or removed from a bond or openvswitch,
-	 *    in which case nothing is done
-	 */
-	if (master && master->rtnl_link_ops &&
-	    !strcmp(master->rtnl_link_ops->kind, "bridge"))
-		err = rocker_port_bridge_join(rocker_port, master);
-	else if (rocker_port_is_bridged(rocker_port))
+	/* N.B: Do nothing if the type of master is not supported */
+	if (master && master->rtnl_link_ops) {
+		if (!strcmp(master->rtnl_link_ops->kind, "bridge"))
+			err = rocker_port_bridge_join(rocker_port, master);
+		else if (!strcmp(master->rtnl_link_ops->kind, "openvswitch"))
+			err = rocker_port_ovs_changed(rocker_port, master);
+	} else if (rocker_port_is_bridged(rocker_port)) {
 		err = rocker_port_bridge_leave(rocker_port);
+	} else if (rocker_port_is_ovsed(rocker_port)) {
+		err = rocker_port_ovs_changed(rocker_port, NULL);
+	}
 
 	return err;
 }
-- 
2.1.4
