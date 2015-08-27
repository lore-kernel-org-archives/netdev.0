From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 6/6] rocker: use change upper info
Date: Thu, 27 Aug 2015 09:31:23 +0200
Message-ID: <1440660683-20086-7-git-send-email-jiri@resnulli.us>
References: <1440660683-20086-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, simon.horman@netronome.com,
	f.fainelli@gmail.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34199 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751656AbbH0Hbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 03:31:34 -0400
Received: by widdq5 with SMTP id dq5so68709065wid.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 00:31:32 -0700 (PDT)
In-Reply-To: <1440660683-20086-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since now information about changed upper is passed along, benefit from
that and use this info directly.

This also fixes possible issues that could happen when non-master device
is added (current code does not distinguish between master and non-master
upper device).

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Scott Feldman <sfeldma@gmail.com
---
v1->v2:
- no change
---
 drivers/net/ethernet/rocker/rocker.c | 61 ++++++++++++++++++++++--------------
 1 file changed, 38 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 62f383c..34ac41a 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -5326,46 +5326,61 @@ static int rocker_port_ovs_changed(struct rocker_port *rocker_port,
 	return err;
 }
 
-static int rocker_port_master_changed(struct net_device *dev)
+static int rocker_port_master_linked(struct rocker_port *rocker_port,
+				     struct net_device *master)
+{
+	int err = 0;
+
+	if (netif_is_bridge_master(master))
+		err = rocker_port_bridge_join(rocker_port, master);
+	else if (netif_is_ovs_master(master))
+		err = rocker_port_ovs_changed(rocker_port, master);
+	return err;
+}
+
+static int rocker_port_master_unlinked(struct rocker_port *rocker_port)
 {
-	struct rocker_port *rocker_port = netdev_priv(dev);
-	struct net_device *master = netdev_master_upper_dev_get(dev);
 	int err = 0;
 
-	/* N.B: Do nothing if the type of master is not supported */
-	if (master) {
-		if (netif_is_bridge_master(master))
-			err = rocker_port_bridge_join(rocker_port, master);
-		else if (netif_is_ovs_master(master))
-			err = rocker_port_ovs_changed(rocker_port, master);
-	} else if (rocker_port_is_bridged(rocker_port)) {
+	if (rocker_port_is_bridged(rocker_port))
 		err = rocker_port_bridge_leave(rocker_port);
-	} else if (rocker_port_is_ovsed(rocker_port)) {
+	else if (rocker_port_is_ovsed(rocker_port))
 		err = rocker_port_ovs_changed(rocker_port, NULL);
-	}
-
 	return err;
 }
 
 static int rocker_netdevice_event(struct notifier_block *unused,
 				  unsigned long event, void *ptr)
 {
-	struct net_device *dev;
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct netdev_notifier_changeupper_info *info;
+	struct rocker_port *rocker_port;
 	int err;
 
+	if (!rocker_port_dev_check(dev))
+		return NOTIFY_DONE;
+
 	switch (event) {
 	case NETDEV_CHANGEUPPER:
-		dev = netdev_notifier_info_to_dev(ptr);
-		if (!rocker_port_dev_check(dev))
-			return NOTIFY_DONE;
-		err = rocker_port_master_changed(dev);
-		if (err)
-			netdev_warn(dev,
-				    "failed to reflect master change (err %d)\n",
-				    err);
+		info = ptr;
+		if (!info->master)
+			goto out;
+		rocker_port = netdev_priv(dev);
+		if (info->linking) {
+			err = rocker_port_master_linked(rocker_port,
+							info->upper_dev);
+			if (err)
+				netdev_warn(dev, "failed to reflect master linked (err %d)\n",
+					    err);
+		} else {
+			err = rocker_port_master_unlinked(rocker_port);
+			if (err)
+				netdev_warn(dev, "failed to reflect master unlinked (err %d)\n",
+					    err);
+		}
 		break;
 	}
-
+out:
 	return NOTIFY_DONE;
 }
 
-- 
1.9.3
