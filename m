From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v1] bonding: cosmetic/readability changes for admin, oper-key ops
Date: Fri,  3 Apr 2015 13:54:00 -0700
Message-ID: <1428094440-9241-1-git-send-email-maheshb@google.com>
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
Received: from mail-pd0-f202.google.com ([209.85.192.202]:33290 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021AbbDCUyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 16:54:04 -0400
Received: by pdjg10 with SMTP id g10so10835350pdj.0
        for <netdev@vger.kernel.org>; Fri, 03 Apr 2015 13:54:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c | 31 +++++++++++++------------------
 1 file changed, 13 insertions(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index b31673a476d9..4eeb02210fed 100644
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
@@ -1756,8 +1758,6 @@ static void ad_initialize_port(struct port *port, int lacp_fast)
 		port->actor_system_priority = 0xffff;
 		port->actor_port_aggregator_identifier = 0;
 		port->ntt = false;
-		port->actor_admin_port_key = 1;
-		port->actor_oper_port_key  = 1;
 		port->actor_admin_port_state = AD_STATE_AGGREGATION |
 					       AD_STATE_LACP_ACTIVITY;
 		port->actor_oper_port_state  = AD_STATE_AGGREGATION |
@@ -2348,8 +2348,8 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 	spin_lock_bh(&slave->bond->mode_lock);
 
 	port->actor_admin_port_key &= ~AD_SPEED_KEY_MASKS;
-	port->actor_oper_port_key = port->actor_admin_port_key |=
-		(__get_link_speed(port) << 1);
+	port->actor_admin_port_key |= __get_link_speed(port) << 1;
+	port->actor_oper_port_key = port->actor_admin_port_key;
 	netdev_dbg(slave->bond->dev, "Port %d changed speed\n", port->actor_port_number);
 	/* there is no need to reselect a new aggregator, just signal the
 	 * state machines to reinitialize
@@ -2381,8 +2381,8 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 	spin_lock_bh(&slave->bond->mode_lock);
 
 	port->actor_admin_port_key &= ~AD_DUPLEX_KEY_MASKS;
-	port->actor_oper_port_key = port->actor_admin_port_key |=
-		__get_duplex(port);
+	port->actor_admin_port_key |= __get_duplex(port);
+	port->actor_oper_port_key = port->actor_admin_port_key;
 	netdev_dbg(slave->bond->dev, "Port %d slave %s changed duplex\n",
 		   port->actor_port_number, slave->dev->name);
 	if (port->actor_oper_port_key & AD_DUPLEX_KEY_MASKS)
@@ -2423,24 +2423,19 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
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
