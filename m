From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next 3/3] bonding: simplify / unify event handling code for 3ad mode.
Date: Sat, 31 Oct 2015 12:45:11 -0700
Message-ID: <1446320711-38991-1-git-send-email-maheshb@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>,
	David Decotigny <decot@google.com>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35215 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbbJaTpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Oct 2015 15:45:15 -0400
Received: by pasz6 with SMTP id z6so106012538pas.2
        for <netdev@vger.kernel.org>; Sat, 31 Oct 2015 12:45:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Old logic of updating state-machine is not required since
ad_update_actor_keys() does it implicitly. The only loss is
the notification differentiation between speed vs. duplex
change. Now only one unified notification is printed.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_3ad.c  | 38 ++++++--------------------------------
 drivers/net/bonding/bond_main.c | 14 ++------------
 include/net/bond_3ad.h          |  3 +--
 3 files changed, 9 insertions(+), 46 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index b9816b7f319f..940e2ebbdea8 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2348,39 +2348,14 @@ static void ad_update_actor_keys(struct port *port, bool reset)
 }
 
 /**
- * bond_3ad_adapter_speed_changed - handle a slave's speed change indication
- * @slave: slave struct to work on
+ * bond_3ad_adapter_speed_duplex_changed - handle a slave's speed / duplex
+ * change indication
  *
- * Handle reselection of aggregator (if needed) for this port.
- */
-void bond_3ad_adapter_speed_changed(struct slave *slave)
-{
-	struct port *port;
-
-	port = &(SLAVE_AD_INFO(slave)->port);
-
-	/* if slave is null, the whole port is not initialized */
-	if (!port->slave) {
-		netdev_warn(slave->bond->dev, "speed changed for uninitialized port on %s\n",
-			    slave->dev->name);
-		return;
-	}
-
-	spin_lock_bh(&slave->bond->mode_lock);
-
-	ad_update_actor_keys(port, false);
-	netdev_dbg(slave->bond->dev, "Port %d changed speed\n", port->actor_port_number);
-
-	spin_unlock_bh(&slave->bond->mode_lock);
-}
-
-/**
- * bond_3ad_adapter_duplex_changed - handle a slave's duplex change indication
  * @slave: slave struct to work on
  *
  * Handle reselection of aggregator (if needed) for this port.
  */
-void bond_3ad_adapter_duplex_changed(struct slave *slave)
+void bond_3ad_adapter_speed_duplex_changed(struct slave *slave)
 {
 	struct port *port;
 
@@ -2388,17 +2363,16 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave)
 
 	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
-		netdev_warn(slave->bond->dev, "duplex changed for uninitialized port on %s\n",
+		netdev_warn(slave->bond->dev,
+			    "speed/duplex changed for uninitialized port %s\n",
 			    slave->dev->name);
 		return;
 	}
 
 	spin_lock_bh(&slave->bond->mode_lock);
-
 	ad_update_actor_keys(port, false);
-	netdev_dbg(slave->bond->dev, "Port %d slave %s changed duplex\n",
+	netdev_dbg(slave->bond->dev, "Port %d slave %s changed speed/duplex\n",
 		   port->actor_port_number, slave->dev->name);
-
 	spin_unlock_bh(&slave->bond->mode_lock);
 }
 
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d0f23cd6e236..b4351caf8e01 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2943,8 +2943,6 @@ static int bond_slave_netdev_event(unsigned long event,
 	struct slave *slave = bond_slave_get_rtnl(slave_dev), *primary;
 	struct bonding *bond;
 	struct net_device *bond_dev;
-	u32 old_speed;
-	u8 old_duplex;
 
 	/* A netdev event can be generated while enslaving a device
 	 * before netdev_rx_handler_register is called in which case
@@ -2965,17 +2963,9 @@ static int bond_slave_netdev_event(unsigned long event,
 		break;
 	case NETDEV_UP:
 	case NETDEV_CHANGE:
-		old_speed = slave->speed;
-		old_duplex = slave->duplex;
-
 		bond_update_speed_duplex(slave);
-
-		if (BOND_MODE(bond) == BOND_MODE_8023AD) {
-			if (old_speed != slave->speed)
-				bond_3ad_adapter_speed_changed(slave);
-			if (old_duplex != slave->duplex)
-				bond_3ad_adapter_duplex_changed(slave);
-		}
+		if (BOND_MODE(bond) == BOND_MODE_8023AD)
+			bond_3ad_adapter_speed_duplex_changed(slave);
 		/* Fallthrough */
 	case NETDEV_DOWN:
 		/* Refresh slave-array if applicable!
diff --git a/include/net/bond_3ad.h b/include/net/bond_3ad.h
index c2a40a172fcd..f1fbc3b11962 100644
--- a/include/net/bond_3ad.h
+++ b/include/net/bond_3ad.h
@@ -297,8 +297,7 @@ void bond_3ad_bind_slave(struct slave *slave);
 void bond_3ad_unbind_slave(struct slave *slave);
 void bond_3ad_state_machine_handler(struct work_struct *);
 void bond_3ad_initiate_agg_selection(struct bonding *bond, int timeout);
-void bond_3ad_adapter_speed_changed(struct slave *slave);
-void bond_3ad_adapter_duplex_changed(struct slave *slave);
+void bond_3ad_adapter_speed_duplex_changed(struct slave *slave);
 void bond_3ad_handle_link_change(struct slave *slave, char link);
 int  bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info);
 int  __bond_3ad_get_active_agg_info(struct bonding *bond,
-- 
2.6.0.rc2.230.g3dd15c0
