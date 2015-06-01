From: sfeldma@gmail.com
Subject: [PATCH net-next 4/5] rocker: install/remove router MAC for untagged VLAN when joining/leaving bridge
Date: Mon,  1 Jun 2015 11:39:05 -0700
Message-ID: <1433183947-13095-5-git-send-email-sfeldma@gmail.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36846 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864AbbFASha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 14:37:30 -0400
Received: by pacux9 with SMTP id ux9so74788561pac.3
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 11:37:29 -0700 (PDT)
In-Reply-To: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

When the port joins a bridge, the port's internal VLAN ID needs to change
to the bridge's internal VLAN ID.  Likewise, when leaving the bridge, the
internal VLAN ID reverts back the port's original internal VLAN ID.  (The
internal VLAN ID is used by device to internally mark untagged pkts with
some VLAN, which will eventually be removed on egress...think PVID).  When
the internal VLAN ID changes, we need to update the VLAN table entries and
the router MAC entries for IP/IPv6 to reflect the new internal VLAN ID.

This patch makes use of the common rocker_port_vlan_add/del functions to
make sure the tables are updated for the current internal VLAN ID.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   42 ++++++++++++++++++++--------------
 1 file changed, 25 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index bd56273..3eb3eba 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -5178,41 +5178,49 @@ static bool rocker_port_dev_check(const struct net_device *dev)
 static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 				   struct net_device *bridge)
 {
+	u16 untagged_vid = 0;
 	int err;
 
-	rocker_port_internal_vlan_id_put(rocker_port,
-					 rocker_port->dev->ifindex);
-
-	rocker_port->bridge_dev = bridge;
+	/* Port is joining bridge, so the internal VLAN for the
+	 * port is going to change to the bridge internal VLAN.
+	 * Let's remove untagged VLAN (vid=0) from port and
+	 * re-add once internal VLAN has changed.
+	 */
 
-	/* Use bridge internal VLAN ID for untagged pkts */
-	err = rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE,
-			       ROCKER_OP_FLAG_REMOVE, 0);
+	err = rocker_port_vlan_del(rocker_port, untagged_vid, 0);
 	if (err)
 		return err;
+
+	rocker_port_internal_vlan_id_put(rocker_port,
+					 rocker_port->dev->ifindex);
 	rocker_port->internal_vlan_id =
 		rocker_port_internal_vlan_id_get(rocker_port, bridge->ifindex);
-	return rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE, 0, 0);
+
+	rocker_port->bridge_dev = bridge;
+
+	return rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
+				    untagged_vid, 0);
 }
 
 static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 {
+	u16 untagged_vid = 0;
 	int err;
 
-	rocker_port_internal_vlan_id_put(rocker_port,
-					 rocker_port->bridge_dev->ifindex);
-
-	rocker_port->bridge_dev = NULL;
-
-	/* Use port internal VLAN ID for untagged pkts */
-	err = rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE,
-			       ROCKER_OP_FLAG_REMOVE, 0);
+	err = rocker_port_vlan_del(rocker_port, untagged_vid, 0);
 	if (err)
 		return err;
+
+	rocker_port_internal_vlan_id_put(rocker_port,
+					 rocker_port->bridge_dev->ifindex);
 	rocker_port->internal_vlan_id =
 		rocker_port_internal_vlan_id_get(rocker_port,
 						 rocker_port->dev->ifindex);
-	err = rocker_port_vlan(rocker_port, SWITCHDEV_TRANS_NONE, 0, 0);
+
+	rocker_port->bridge_dev = NULL;
+
+	err = rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
+				   untagged_vid, 0);
 	if (err)
 		return err;
 
-- 
1.7.10.4
