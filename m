From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [PATCH] team: add support to get speed via ethtool
Date: Thu,  5 Mar 2015 13:48:35 -0800
Message-ID: <1425592115-1750-1-git-send-email-sridhar.samudrala@intel.com>
To: davem@davemloft.net, jiri@resnulli.us, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:65259 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751278AbbCEVrn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Mar 2015 16:47:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With this patch ethtool <team> OR cat /sys/class/net/<team>/speed
returns the speed of team based on member ports speed and state.

Based on get speed support in bonding driver.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 drivers/net/team/team.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 9d3366f..e822803 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1954,6 +1954,30 @@ static int team_change_carrier(struct net_device *dev, bool new_carrier)
 	return 0;
 }
 
+static int team_ethtool_get_settings(struct net_device *dev,
+				     struct ethtool_cmd *ecmd)
+{
+	struct team *team = netdev_priv(dev);
+	struct team_port *port;
+	unsigned long speed = 0;
+
+	ecmd->duplex = DUPLEX_UNKNOWN;
+	ecmd->port = PORT_OTHER;
+
+	mutex_lock(&team->lock);
+	list_for_each_entry(port, &team->port_list, list) {
+		if (port->linkup)
+			speed += port->state.speed;
+		if (ecmd->duplex == DUPLEX_UNKNOWN &&
+		    port->state.duplex != 0)
+			ecmd->duplex = port->state.duplex;
+	}
+	ethtool_cmd_speed_set(ecmd, speed);
+	mutex_unlock(&team->lock);
+
+	return 0;
+}
+
 static const struct net_device_ops team_netdev_ops = {
 	.ndo_init		= team_init,
 	.ndo_uninit		= team_uninit,
@@ -1995,6 +2019,7 @@ static void team_ethtool_get_drvinfo(struct net_device *dev,
 static const struct ethtool_ops team_ethtool_ops = {
 	.get_drvinfo		= team_ethtool_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
+	.get_settings		= team_ethtool_get_settings,
 };
 
 /***********************
-- 
1.8.4.2
