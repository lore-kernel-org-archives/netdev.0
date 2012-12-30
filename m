From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH net-next] team: update master carrier state
Date: Sun, 30 Dec 2012 16:27:29 -0200
Message-ID: <1356892049-14667-1-git-send-email-fbl@redhat.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15018 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754715Ab2L3S3L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Dec 2012 13:29:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update master's carrier state when there is any
change with its ports.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/team/team.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 918a901..78c7d87 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1400,13 +1400,11 @@ static void team_destructor(struct net_device *dev)
 
 static int team_open(struct net_device *dev)
 {
-	netif_carrier_on(dev);
 	return 0;
 }
 
 static int team_close(struct net_device *dev)
 {
-	netif_carrier_off(dev);
 	return 0;
 }
 
@@ -2560,21 +2558,43 @@ send_event:
 
 }
 
+static void __team_carrier_check(struct team *team)
+{
+	struct team_port *port;
+	bool team_linkup;
+
+	team_linkup = false;
+	list_for_each_entry(port, &team->port_list, list) {
+		if (port->linkup) {
+			team_linkup = true;
+			break;
+		}
+	}
+
+	if (team_linkup)
+		netif_carrier_on(team->dev);
+	else
+		netif_carrier_off(team->dev);
+}
+
 static void __team_port_change_check(struct team_port *port, bool linkup)
 {
 	if (port->state.linkup != linkup)
 		__team_port_change_send(port, linkup);
+	__team_carrier_check(port->team);
 }
 
 static void __team_port_change_port_added(struct team_port *port, bool linkup)
 {
 	__team_port_change_send(port, linkup);
+	__team_carrier_check(port->team);
 }
 
 static void __team_port_change_port_removed(struct team_port *port)
 {
 	port->removed = true;
 	__team_port_change_send(port, false);
+	__team_carrier_check(port->team);
 }
 
 static void team_port_change_check(struct team_port *port, bool linkup)
-- 
1.8.0.1
