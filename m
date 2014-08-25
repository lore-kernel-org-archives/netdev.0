From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] team: set IFF_TEAM_PORT priv_flag after rx_handler is registered
Date: Mon, 25 Aug 2014 21:38:27 +0200
Message-ID: <1408995507-10338-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fbl@redhat.com, erik.hugne@ericsson.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:43211 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933108AbaHYTic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 15:38:32 -0400
Received: by mail-wi0-f181.google.com with SMTP id bs8so3068080wib.8
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 12:38:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When one tries to add eth as a port into team and that eth is already in
use by other rx_handler device (macvlan, bond, bridge, ...) a bug in
team_port_add() causes that IFF_TEAM_PORT flag is set before rx_handler
is registered. In between, netdev nofifier is called and
team_device_event() sees IFF_TEAM_PORT and thinks that rx_handler_data
pointer is set to team_port. But it isn't.

Fix this by reordering rx_handler register and IFF_TEAM_PORT priv flag
set so it is very similar to how bonding does this.

Reported-by: Erik Hugne <erik.hugne@ericsson.com>
Introduced-by: 3d249d4ca7 "net: introduce ethernet teaming device"
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 44 ++++++++++++++++++++++++++++++--------------
 1 file changed, 30 insertions(+), 14 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index ef10302..2277c36 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1003,7 +1003,6 @@ static int team_port_enter(struct team *team, struct team_port *port)
 	int err = 0;
 
 	dev_hold(team->dev);
-	port->dev->priv_flags |= IFF_TEAM_PORT;
 	if (team->ops.port_enter) {
 		err = team->ops.port_enter(team, port);
 		if (err) {
@@ -1016,7 +1015,6 @@ static int team_port_enter(struct team *team, struct team_port *port)
 	return 0;
 
 err_port_enter:
-	port->dev->priv_flags &= ~IFF_TEAM_PORT;
 	dev_put(team->dev);
 
 	return err;
@@ -1026,7 +1024,6 @@ static void team_port_leave(struct team *team, struct team_port *port)
 {
 	if (team->ops.port_leave)
 		team->ops.port_leave(team, port);
-	port->dev->priv_flags &= ~IFF_TEAM_PORT;
 	dev_put(team->dev);
 }
 
@@ -1075,6 +1072,25 @@ static void team_port_disable_netpoll(struct team_port *port)
 }
 #endif
 
+static int team_upper_dev_link(struct net_device *dev,
+			       struct net_device *port_dev)
+{
+	int err;
+
+	err = netdev_master_upper_dev_link(port_dev, dev);
+	if (err)
+		return err;
+	port_dev->priv_flags |= IFF_TEAM_PORT;
+	return 0;
+}
+
+static void team_upper_dev_unlink(struct net_device *dev,
+				  struct net_device *port_dev)
+{
+	netdev_upper_dev_unlink(port_dev, dev);
+	port_dev->priv_flags &= ~IFF_TEAM_PORT;
+}
+
 static void __team_port_change_port_added(struct team_port *port, bool linkup);
 static int team_dev_type_check_change(struct net_device *dev,
 				      struct net_device *port_dev);
@@ -1161,13 +1177,6 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_enable_netpoll;
 	}
 
-	err = netdev_master_upper_dev_link(port_dev, dev);
-	if (err) {
-		netdev_err(dev, "Device %s failed to set upper link\n",
-			   portname);
-		goto err_set_upper_link;
-	}
-
 	err = netdev_rx_handler_register(port_dev, team_handle_frame,
 					 port);
 	if (err) {
@@ -1176,6 +1185,13 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_handler_register;
 	}
 
+	err = team_upper_dev_link(dev, port_dev);
+	if (err) {
+		netdev_err(dev, "Device %s failed to set upper link\n",
+			   portname);
+		goto err_set_upper_link;
+	}
+
 	err = __team_option_inst_add_port(team, port);
 	if (err) {
 		netdev_err(dev, "Device %s failed to add per-port options\n",
@@ -1195,12 +1211,12 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 	return 0;
 
 err_option_port_add:
+	team_upper_dev_unlink(dev, port_dev);
+
+err_set_upper_link:
 	netdev_rx_handler_unregister(port_dev);
 
 err_handler_register:
-	netdev_upper_dev_unlink(port_dev, dev);
-
-err_set_upper_link:
 	team_port_disable_netpoll(port);
 
 err_enable_netpoll:
@@ -1239,8 +1255,8 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 
 	team_port_disable(team, port);
 	list_del_rcu(&port->list);
+	team_upper_dev_unlink(dev, port_dev);
 	netdev_rx_handler_unregister(port_dev);
-	netdev_upper_dev_unlink(port_dev, dev);
 	team_port_disable_netpoll(port);
 	vlan_vids_del_by_dev(port_dev, dev);
 	dev_uc_unsync(port_dev, dev);
-- 
1.9.3
