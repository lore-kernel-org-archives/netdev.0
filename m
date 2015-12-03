From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 16/28] team: implement lower state change propagation
Date: Thu,  3 Dec 2015 12:12:18 +0100
Message-ID: <1449141150-8172-17-git-send-email-jiri@resnulli.us>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36440 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759858AbbLCLM5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 06:12:57 -0500
Received: by wmww144 with SMTP id w144so16364229wmw.1
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 03:12:56 -0800 (PST)
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Let netdev notifier listeners know about link-up and port-enable state
changes.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/team/team.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 9814133..059c0f6 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -91,10 +91,24 @@ void team_modeop_port_change_dev_addr(struct team *team,
 }
 EXPORT_SYMBOL(team_modeop_port_change_dev_addr);
 
+static void team_lower_state_changed(struct team_port *port)
+{
+	struct netdev_lag_lower_state_info info;
+
+	info.link_up = port->linkup;
+	info.tx_enabled = team_port_enabled(port);
+	netdev_lower_state_changed(port->dev, &info);
+}
+
 static void team_refresh_port_linkup(struct team_port *port)
 {
-	port->linkup = port->user.linkup_enabled ? port->user.linkup :
-						   port->state.linkup;
+	bool new_linkup = port->user.linkup_enabled ? port->user.linkup :
+						      port->state.linkup;
+
+	if (port->linkup != new_linkup) {
+		port->linkup = new_linkup;
+		team_lower_state_changed(port);
+	}
 }
 
 
@@ -932,6 +946,7 @@ static void team_port_enable(struct team *team,
 		team->ops.port_enabled(team, port);
 	team_notify_peers(team);
 	team_mcast_rejoin(team);
+	team_lower_state_changed(port);
 }
 
 static void __reconstruct_port_hlist(struct team *team, int rm_index)
@@ -963,6 +978,7 @@ static void team_port_disable(struct team *team,
 	team_adjust_ops(team);
 	team_notify_peers(team);
 	team_mcast_rejoin(team);
+	team_lower_state_changed(port);
 }
 
 #define TEAM_VLAN_FEATURES (NETIF_F_ALL_CSUM | NETIF_F_SG | \
-- 
1.9.3
