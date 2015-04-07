From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next v2] bonding: Code re-factoring for admin, oper-key operations
Date: Tue,  7 Apr 2015 16:16:11 -0700
Message-ID: <1428448571-1996-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f201.google.com ([209.85.192.201]:33216 "EHLO
	mail-pd0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932100AbbDGXQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 19:16:16 -0400
Received: by pdjg10 with SMTP id g10so5886432pdj.0
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 16:16:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch breaks the rich assignments into it's own statements
and removes some duplicate code where admin-key, & oper-key are
updated.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c | 29 +++++++++++++----------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index b31673a476d9..e2ba211c5c9b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1423,8 +1423,10 @@ static void ad_port_selection_logic(struct port *port, bool *update_slave_arr)
 			else
 				port->aggregator->is_individual = true;
 
-			port->aggregator->actor_admin_aggregator_key = port->actor_admin_port_key;
-			port->aggregator->actor_oper_aggregator_key = port->actor_oper_port_key;
+			port->aggregator->actor_admin_aggregator_key =
+				port->actor_admin_port_key;
+			port->aggregator->actor_oper_aggregator_key =
+				port->actor_oper_port_key;
 			port->aggregator->partner_system =
 				port->partner_oper.system;
 			port->aggregator->partner_system_priority =
@@ -2348,8 +2350,8 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 	spin_lock_bh(&slave->bond->mode_lock);
 
 	port->actor_admin_port_key &= ~AD_SPEED_KEY_MASKS;
-	port->actor_oper_port_key = port->actor_admin_port_key |=
-		(__get_link_speed(port) << 1);
+	port->actor_admin_port_key |= __get_link_speed(port) << 1;
+	port->actor_oper_port_key = port->actor_admin_port_key;
 	netdev_dbg(slave->bond->dev, "Port %d changed speed\n", port->actor_port_number);
 	/* there is no need to reselect a new aggregator, just signal the
 	 * state machines to reinitialize
@@ -2381,8 +2383,8 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 	spin_lock_bh(&slave->bond->mode_lock);
 
 	port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
-	port->actor_oper_port_key = port->actor_admin_port_key |=
-		__get_duplex(port);
+	port->actor_admin_port_key |= __get_duplex(port);
+	port->actor_oper_port_key = port->actor_admin_port_key;
 	netdev_dbg(slave->bond->dev, "Port %d slave %s changed duplex\n",
 		   port->actor_port_number, slave->dev->name);
 	if (port->actor_oper_port_key & AD_DUPLEX_KEY_MASKS)
@@ -2423,24 +2425,19 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 	 * on link up we are forcing recheck on the duplex and speed since
 	 * some of he adaptors(ce1000.lan) report.
 	 */
+	port->actor_admin_port_key &= ~(AD_DUPLEX_KEY_MASKS|AD_SPEED_KEY_MASKS);
 	if (link == BOND_LINK_UP) {
 		port->is_enabled = true;
-		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
-		port->actor_oper_port_key = port->actor_admin_port_key |=
-			__get_duplex(port);
-		port->actor_admin_port_key &= ~AD_SPEED_KEY_MASKS;
-		port->actor_oper_port_key = port->actor_admin_port_key |=
-			(__get_link_speed(port) << 1);
-		if (port->actor_oper_port_key & AD_DUPLEX_KEY_MASKS)
+		port->actor_admin_port_key |=
+			(__get_link_speed(port) << 1) | __get_duplex(port);
+		if (port->actor_admin_port_key & AD_DUPLEX_KEY_MASKS)
 			port->sm_vars |= AD_PORT_LACP_ENABLED;
 	} else {
 		/* link has failed */
 		port->is_enabled = false;
-		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
-		port->actor_oper_port_key = (port->actor_admin_port_key &=
-					     ~AD_SPEED_KEY_MASKS);
 		port->sm_vars &= ~AD_PORT_LACP_ENABLED;
 	}
+	port->actor_oper_port_key = port->actor_admin_port_key;
 	netdev_dbg(slave->bond->dev, "Port %d changed link status to %s\n",
 		   port->actor_port_number,
 		   link == BOND_LINK_UP ? "UP" : "DOWN");
-- 
2.2.0.rc0.207.ga3a616c
