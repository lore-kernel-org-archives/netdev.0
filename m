From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] teamd: send port changed when added
Date: Fri, 21 Sep 2012 13:50:37 +0200
Message-ID: <1348228237-11378-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:61063 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804Ab2IULum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 07:50:42 -0400
Received: by bkuw11 with SMTP id w11so759130bku.19
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 04:50:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some hw, link is not up during adding iface to team. That causes event
not being sent to userspace and that may cause confusion.
Fix this bug by sending port changed event once it's added to team.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 33 +++++++++++++++++++++++++--------
 1 file changed, 25 insertions(+), 8 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 266af7b..9ce0c51 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -966,7 +966,8 @@ static struct netpoll_info *team_netpoll_info(struct team *team)
 }
 #endif
 
-static void __team_port_change_check(struct team_port *port, bool linkup);
+static void __team_port_change_port_added(struct team_port *port, bool linkup);
+
 static int team_dev_type_check_change(struct net_device *dev,
 				      struct net_device *port_dev);
 
@@ -1079,7 +1080,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 	team_port_enable(team, port);
 	list_add_tail_rcu(&port->list, &team->port_list);
 	__team_compute_features(team);
-	__team_port_change_check(port, !!netif_carrier_ok(port_dev));
+	__team_port_change_port_added(port, !!netif_carrier_ok(port_dev));
 	__team_options_change_check(team);
 
 	netdev_info(dev, "Port device %s added\n", portname);
@@ -1114,6 +1115,8 @@ err_set_mtu:
 	return err;
 }
 
+static void __team_port_change_port_removed(struct team_port *port);
+
 static int team_port_del(struct team *team, struct net_device *port_dev)
 {
 	struct net_device *dev = team->dev;
@@ -1130,8 +1133,7 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 	__team_option_inst_mark_removed_port(team, port);
 	__team_options_change_check(team);
 	__team_option_inst_del_port(team, port);
-	port->removed = true;
-	__team_port_change_check(port, false);
+	__team_port_change_port_removed(port);
 	team_port_disable(team, port);
 	list_del_rcu(&port->list);
 	netdev_rx_handler_unregister(port_dev);
@@ -2499,13 +2501,11 @@ static void __team_options_change_check(struct team *team)
 }
 
 /* rtnl lock is held */
-static void __team_port_change_check(struct team_port *port, bool linkup)
+
+static void __team_port_change_send(struct team_port *port, bool linkup)
 {
 	int err;
 
-	if (!port->removed && port->state.linkup == linkup)
-		return;
-
 	port->changed = true;
 	port->state.linkup = linkup;
 	team_refresh_port_linkup(port);
@@ -2530,6 +2530,23 @@ send_event:
 
 }
 
+static void __team_port_change_check(struct team_port *port, bool linkup)
+{
+	if (port->state.linkup != linkup)
+		__team_port_change_send(port, linkup);
+}
+
+static void __team_port_change_port_added(struct team_port *port, bool linkup)
+{
+	__team_port_change_send(port, linkup);
+}
+
+static void __team_port_change_port_removed(struct team_port *port)
+{
+	port->removed = true;
+	__team_port_change_send(port, false);
+}
+
 static void team_port_change_check(struct team_port *port, bool linkup)
 {
 	struct team *team = port->team;
-- 
1.7.12
