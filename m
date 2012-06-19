From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next 17/19] team: ensure correct order of netlink messages delivery
Date: Tue, 19 Jun 2012 17:54:19 +0200
Message-ID: <1340121261-2966-18-git-send-email-jpirko@redhat.com>
References: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com, jbrouer@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754637Ab2FSPyw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:54:52 -0400
In-Reply-To: <1340121261-2966-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

currently, when port is created and per-port options are present, there
options are sent to userspace with ifindex of port which userspace does
not know about. Port add message goes right after.

This patch corrects message ordering so userspace would not be confused.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/team/team.c |   25 +++++--------------------
 1 file changed, 5 insertions(+), 20 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 9e9d3e5..a7b391d 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -347,24 +347,6 @@ void team_options_unregister(struct team *team,
 }
 EXPORT_SYMBOL(team_options_unregister);
 
-static int team_option_port_add(struct team *team, struct team_port *port)
-{
-	int err;
-
-	err = __team_option_inst_add_port(team, port);
-	if (err)
-		return err;
-	__team_options_change_check(team);
-	return 0;
-}
-
-static void team_option_port_del(struct team *team, struct team_port *port)
-{
-	__team_option_inst_mark_removed_port(team, port);
-	__team_options_change_check(team);
-	__team_option_inst_del_port(team, port);
-}
-
 static int team_option_get(struct team *team,
 			   struct team_option_inst *opt_inst,
 			   struct team_gsetter_ctx *ctx)
@@ -891,7 +873,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_handler_register;
 	}
 
-	err = team_option_port_add(team, port);
+	err = __team_option_inst_add_port(team, port);
 	if (err) {
 		netdev_err(dev, "Device %s failed to add per-port options\n",
 			   portname);
@@ -904,6 +886,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 	team_adjust_ops(team);
 	__team_compute_features(team);
 	__team_port_change_check(port, !!netif_carrier_ok(port_dev));
+	__team_options_change_check(team);
 
 	netdev_info(dev, "Port device %s added\n", portname);
 
@@ -947,12 +930,14 @@ static int team_port_del(struct team *team, struct net_device *port_dev)
 		return -ENOENT;
 	}
 
+	__team_option_inst_mark_removed_port(team, port);
+	__team_options_change_check(team);
+	__team_option_inst_del_port(team, port);
 	port->removed = true;
 	__team_port_change_check(port, false);
 	team_port_disable(team, port);
 	list_del_rcu(&port->list);
 	team_adjust_ops(team);
-	team_option_port_del(team, port);
 	netdev_rx_handler_unregister(port_dev);
 	netdev_set_master(port_dev, NULL);
 	vlan_vids_del_by_dev(port_dev, dev);
-- 
1.7.10.2
