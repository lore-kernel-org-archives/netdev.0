From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next 2/3] bonding: unify all places where actor-oper key needs to be updated.
Date: Sat, 31 Oct 2015 12:45:06 -0700
Message-ID: <1446320706-38949-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	David Decotigny <decot@google.com>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34134 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbbJaTpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Oct 2015 15:45:11 -0400
Received: by padhk11 with SMTP id hk11so106170828pad.1
        for <netdev@vger.kernel.org>; Sat, 31 Oct 2015 12:45:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

actor_admin, and actor_oper key is changed at multiple locations in
the code. This patch brings all those updates into one location in
an attempt to avoid possible inconsistent updates causing LACP state
machine to go in weird state.

The unified place is ad_update_actor_key() with simple state-machine
logic -
  (a) If port is "duplex" then only it can participate in LACP
  (b) Speed change reinitializes the LACP state-machine.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c | 87 +++++++++++++++++++++++++-----------------
 1 file changed, 52 insertions(+), 35 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 3a17fd207ec6..b9816b7f319f 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -127,6 +127,7 @@ static void ad_marker_info_received(struct bond_marker *marker_info,
 				    struct port *port);
 static void ad_marker_response_received(struct bond_marker *marker,
 					struct port *port);
+static void ad_update_actor_keys(struct port *port, bool reset);
 
 
 /* ================= api to bonding and kernel code ================== */
@@ -1951,14 +1952,7 @@ void bond_3ad_bind_slave(struct slave *slave)
 		 * user key
 		 */
 		port->actor_admin_port_key = bond->params.ad_user_port_key << 6;
-		port->actor_admin_port_key |= __get_duplex(port);
-		port->actor_admin_port_key |= (__get_link_speed(port) << 1);
-		port->actor_oper_port_key = port->actor_admin_port_key;
-		/* if the port is not full duplex, then the port should be not
-		 * lacp Enabled
-		 */
-		if (!(port->actor_oper_port_key & AD_DUPLEX_KEY_MASKS))
-			port->sm_vars &= ~AD_PORT_LACP_ENABLED;
+		ad_update_actor_keys(port, false);
 		/* actor system is the bond's system */
 		port->actor_system = BOND_AD_INFO(bond).system.sys_mac_addr;
 		port->actor_system_priority =
@@ -2308,6 +2302,52 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
 }
 
 /**
+ * ad_update_actor_keys - Update the oper / admin keys for a port based on
+ * its current speed and duplex settings.
+ *
+ * @port: the port we'are looking at
+ * @reset: Boolean to just reset the speed and the duplex part of the key
+ *
+ * The logic to change the oper / admin keys is:
+ * (a) A full duplex port can participate in LACP with partner.
+ * (b) When the speed is changed, LACP need to be reinitiated.
+ */
+static void ad_update_actor_keys(struct port *port, bool reset)
+{
+	u8 duplex = 0;
+	u16 ospeed = 0, speed = 0;
+	u16 old_oper_key = port->actor_oper_port_key;
+
+	port->actor_admin_port_key &= ~(AD_SPEED_KEY_MASKS|AD_DUPLEX_KEY_MASKS);
+	if (!reset) {
+		speed = __get_link_speed(port);
+		ospeed = (old_oper_key & AD_SPEED_KEY_MASKS) >> 1;
+		duplex = __get_duplex(port);
+		port->actor_admin_port_key |= (speed << 1) | duplex;
+	}
+	port->actor_oper_port_key = port->actor_admin_port_key;
+
+	if (old_oper_key != port->actor_oper_port_key) {
+		/* Only 'duplex' port participates in LACP */
+		if (duplex)
+			port->sm_vars |= AD_PORT_LACP_ENABLED;
+		else
+			port->sm_vars &= ~AD_PORT_LACP_ENABLED;
+
+		if (!reset) {
+			if (!speed) {
+				netdev_err(port->slave->dev,
+					   "speed changed to 0 for port %s",
+					   port->slave->dev->name);
+			} else if (duplex && ospeed != speed) {
+				/* Speed change restarts LACP state-machine */
+				port->sm_vars |= AD_PORT_BEGIN;
+			}
+		}
+	}
+}
+
+/**
  * bond_3ad_adapter_speed_changed - handle a slave's speed change indication
  * @slave: slave struct to work on
  *
@@ -2328,14 +2368,8 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 
 	spin_lock_bh(&slave->bond->mode_lock);
 
-	port->actor_admin_port_key &= ~AD_SPEED_KEY_MASKS;
-	port->actor_admin_port_key |= __get_link_speed(port) << 1;
-	port->actor_oper_port_key = port->actor_admin_port_key;
+	ad_update_actor_keys(port, false);
 	netdev_dbg(slave->bond->dev, "Port %d changed speed\n", port->actor_port_number);
-	/* there is no need to reselect a new aggregator, just signal the
-	 * state machines to reinitialize
-	 */
-	port->sm_vars |= AD_PORT_BEGIN;
 
 	spin_unlock_bh(&slave->bond->mode_lock);
 }
@@ -2361,17 +2395,9 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 
 	spin_lock_bh(&slave->bond->mode_lock);
 
-	port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
-	port->actor_admin_port_key |= __get_duplex(port);
-	port->actor_oper_port_key = port->actor_admin_port_key;
+	ad_update_actor_keys(port, false);
 	netdev_dbg(slave->bond->dev, "Port %d slave %s changed duplex\n",
 		   port->actor_port_number, slave->dev->name);
-	if (port->actor_oper_port_key & AD_DUPLEX_KEY_MASKS)
-		port->sm_vars |= AD_PORT_LACP_ENABLED;
-	/* there is no need to reselect a new aggregator, just signal the
-	 * state machines to reinitialize
-	 */
-	port->sm_vars |= AD_PORT_BEGIN;
 
 	spin_unlock_bh(&slave->bond->mode_lock);
 }
@@ -2404,26 +2430,17 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 	 * on link up we are forcing recheck on the duplex and speed since
 	 * some of he adaptors(ce1000.lan) report.
 	 */
-	port->actor_admin_port_key &= ~(AD_DUPLEX_KEY_MASKS|AD_SPEED_KEY_MASKS);
 	if (link == BOND_LINK_UP) {
 		port->is_enabled = true;
-		port->actor_admin_port_key |=
-			(__get_link_speed(port) << 1) | __get_duplex(port);
-		if (port->actor_admin_port_key & AD_DUPLEX_KEY_MASKS)
-			port->sm_vars |= AD_PORT_LACP_ENABLED;
+		ad_update_actor_keys(port, false);
 	} else {
 		/* link has failed */
 		port->is_enabled = false;
-		port->sm_vars &= ~AD_PORT_LACP_ENABLED;
+		ad_update_actor_keys(port, true);
 	}
-	port->actor_oper_port_key = port->actor_admin_port_key;
 	netdev_dbg(slave->bond->dev, "Port %d changed link status to %s\n",
 		   port->actor_port_number,
 		   link == BOND_LINK_UP ? "UP" : "DOWN");
-	/* there is no need to reselect a new aggregator, just signal the
-	 * state machines to reinitialize
-	 */
-	port->sm_vars |= AD_PORT_BEGIN;
 
 	spin_unlock_bh(&slave->bond->mode_lock);
 
-- 
2.6.0.rc2.230.g3dd15c0
