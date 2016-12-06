From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net] team: team_port_add should check link_up before enable port
Date: Tue,  6 Dec 2016 15:29:08 +0800
Message-ID: <62f7aa9c00b68beed68a907c51dde22e7847d6c9.1481009348.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33540 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751689AbcLFHnD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 02:43:03 -0500
Received: by mail-pf0-f195.google.com with SMTP id 144so18289667pfv.0
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 23:42:50 -0800 (PST)
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

v1 -> v2:
  use netif_carrier_ok() instead of !!netif_carrier_ok(), as it returns
  bool now.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 drivers/net/team/team.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index a380649..4bc0103 100644
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
+	linkup = netif_carrier_ok(port_dev);
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
