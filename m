From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] team: team_port_add should check link_up before enable port
Date: Sat,  3 Dec 2016 21:42:11 +0800
Message-ID: <14defaf74cf554158b8e289dd394815da1d8760c.1480772531.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, Jiri Pirko <jiri@resnulli.us>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36856 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752016AbcLCOBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 09:01:21 -0500
Received: by mail-pg0-f65.google.com with SMTP id x23so10910269pgx.3
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 06:00:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now when users add a nic to team dev, the option 'enable' of the port
is true by default, as team_port_enable enables it after dev_open in
team_port_add.

But even if the port_dev has no carrier, like it's cable was unpluged,
the port is still enabled. It leads to that team dev couldn't work well
if this port was chosen to connect, and has no chance to change to use
other ports if link_watch is ethtool.

This patch is to enable the port only when the port_dev has carrier in
team_port_add.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 drivers/net/team/team.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index a380649..42004ac 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1140,6 +1140,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 	struct net_device *dev = team->dev;
 	struct team_port *port;
 	char *portname = port_dev->name;
+	bool linkup;
 	int err;
 
 	if (port_dev->flags & IFF_LOOPBACK) {
@@ -1249,9 +1250,12 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 
 	port->index = -1;
 	list_add_tail_rcu(&port->list, &team->port_list);
-	team_port_enable(team, port);
+	linkup = !!netif_carrier_ok(port_dev);
+	if (linkup)
+		team_port_enable(team, port);
+
 	__team_compute_features(team);
-	__team_port_change_port_added(port, !!netif_carrier_ok(port_dev));
+	__team_port_change_port_added(port, linkup);
 	__team_options_change_check(team);
 
 	netdev_info(dev, "Port device %s added\n", portname);
-- 
2.1.0
