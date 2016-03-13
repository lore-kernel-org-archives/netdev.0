From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 3/3] net: dsa: refine netdev event notifier
Date: Sun, 13 Mar 2016 01:42:26 -0500
Message-ID: <1457851346-26257-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1457851346-26257-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
	Ido Schimmel <idosch@mellanox.com>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:34400 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbcCMGm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 01:42:56 -0500
In-Reply-To: <1457851346-26257-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rework the netdev event handler, similar to what the Mellanox Spectrum
driver does, to eventually welcome NETDEV_PRECHANGEUPPER actions and use
netdev helpers, such as netif_is_bridge_master.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 55 +++++++++++++++++++++++++++++++------------------------
 1 file changed, 31 insertions(+), 24 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 54976c4..27f7886 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -451,7 +451,7 @@ static int dsa_slave_bridge_port_join(struct net_device *dev,
 	if (ds->drv->port_bridge_join)
 		ret = ds->drv->port_bridge_join(ds, p->port, br);
 
-	return ret;
+	return ret == -EOPNOTSUPP ? 0 : ret;
 }
 
 static void dsa_slave_bridge_port_leave(struct net_device *dev)
@@ -1139,40 +1139,47 @@ static bool dsa_slave_dev_check(struct net_device *dev)
 	return dev->netdev_ops == &dsa_slave_netdev_ops;
 }
 
-static int dsa_slave_master_changed(struct net_device *dev)
+static int dsa_slave_port_upper_event(struct net_device *dev,
+				      unsigned long event, void *ptr)
 {
-	struct net_device *master = netdev_master_upper_dev_get(dev);
-	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct netdev_notifier_changeupper_info *info = ptr;
+	struct net_device *upper = info->upper_dev;
 	int err = 0;
 
-	if (master && master->rtnl_link_ops &&
-	    !strcmp(master->rtnl_link_ops->kind, "bridge"))
-		err = dsa_slave_bridge_port_join(dev, master);
-	else if (dsa_port_is_bridged(p))
-		dsa_slave_bridge_port_leave(dev);
+	switch (event) {
+	case NETDEV_CHANGEUPPER:
+		if (netif_is_bridge_master(upper)) {
+			if (info->linking)
+				err = dsa_slave_bridge_port_join(dev, upper);
+			else
+				dsa_slave_bridge_port_leave(dev);
+		}
 
-	return err;
+		break;
+	}
+
+	return notifier_from_errno(err);
 }
 
-int dsa_slave_netdevice_event(struct notifier_block *unused,
-			      unsigned long event, void *ptr)
+static int dsa_slave_port_event(struct net_device *dev, unsigned long event,
+				void *ptr)
 {
-	struct net_device *dev;
-	int err = 0;
-
 	switch (event) {
+	case NETDEV_PRECHANGEUPPER:
 	case NETDEV_CHANGEUPPER:
-		dev = netdev_notifier_info_to_dev(ptr);
-		if (!dsa_slave_dev_check(dev))
-			goto out;
+		return dsa_slave_port_upper_event(dev, event, ptr);
+	}
 
-		err = dsa_slave_master_changed(dev);
-		if (err && err != -EOPNOTSUPP)
-			netdev_warn(dev, "failed to reflect master change\n");
+	return NOTIFY_DONE;
+}
 
-		break;
-	}
+int dsa_slave_netdevice_event(struct notifier_block *unused,
+			      unsigned long event, void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+
+	if (dsa_slave_dev_check(dev))
+		return dsa_slave_port_event(dev, event, ptr);
 
-out:
 	return NOTIFY_DONE;
 }
-- 
2.7.2
