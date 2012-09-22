From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] team: send port changed when added
Date: Sat, 22 Sep 2012 19:07:53 +0200
Message-ID: <1348333673-29860-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:33777 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab2IVRH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 13:07:56 -0400
Received: by wibhr14 with SMTP id hr14so3239530wib.1
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 10:07:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On some hw, link is not up during adding iface to team. That causes event
not being sent to userspace and that may cause confusion.
Fix this bug by sending port changed event once it's added to team.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/team/team.c | 32 ++++++++++++++++++++++++--------
 1 file changed, 24 insertions(+), 8 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 341b65d..3ffe8a6 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -848,7 +848,7 @@ static struct netpoll_info *team_netpoll_info(struct team *team)
 }
 #endif
 
-static void __team_port_change_check(struct team_port *port, bool linkup);
+static void __team_port_change_port_added(struct team_port *port, bool linkup);
 
 static int team_port_add(struct team *team, struct net_device *port_dev)
 {
@@ -948,7 +948,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 	team_port_enable(team, port);
 	list_add_tail_rcu(&port->list, &team->port_list);
 	__team_compute_features(team);
-	__team_port_change_check(port, !!netif_carrier_ok(port_dev));
+	__team_port_change_port_added(port, !!netif_carrier_ok(port_dev));
 	__team_options_change_check(team);
 
 	netdev_info(dev, "Port device %s added\n", portname);
@@ -983,6 +983,8 @@ err_set_mtu:
 	return err;
 }
 
+static void __team_port_change_port_removed(struct team_port *port);
+
 static int team_port_del(struct team *team, struct net_device *port_dev)
 {
 	struct net_device *dev = team->dev;
@@ -999,8 +1001,7 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 	__team_option_inst_mark_removed_port(team, port);
 	__team_options_change_check(team);
 	__team_option_inst_del_port(team, port);
-	port->removed = true;
-	__team_port_change_check(port, false);
+	__team_port_change_port_removed(port);
 	team_port_disable(team, port);
 	list_del_rcu(&port->list);
 	netdev_rx_handler_unregister(port_dev);
@@ -2251,13 +2252,11 @@ static void __team_options_change_check(struct team *team)
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
@@ -2282,6 +2281,23 @@ send_event:
 
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
1.7.11.4
