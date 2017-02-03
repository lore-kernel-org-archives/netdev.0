From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/6] net: dsa: simplify netdevice events handling
Date: Fri,  3 Feb 2017 13:20:17 -0500
Message-ID: <20170203182021.14246-3-vivien.didelot@savoirfairelinux.com>
References: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, cphealy@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170203182021.14246-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Simplify the code handling the slave netdevice notifier call by
providing a dsa_slave_changeupper helper for NETDEV_CHANGEUPPER, and so
on (only this event is supported at the moment.)

Return NOTIFY_DONE when we did not care about an event, and NOTIFY_OK
when we were concerned but no error occurred, as the API suggests.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 44 ++++++++++++++++----------------------------
 1 file changed, 16 insertions(+), 28 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 949644c1dac2..332eb234dc21 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1491,37 +1491,22 @@ static bool dsa_slave_dev_check(struct net_device *dev)
 	return dev->netdev_ops == &dsa_slave_netdev_ops;
 }
 
-static int dsa_slave_port_upper_event(struct net_device *dev,
-				      unsigned long event, void *ptr)
+static int dsa_slave_changeupper(struct net_device *dev,
+				 struct netdev_notifier_changeupper_info *info)
 {
-	struct netdev_notifier_changeupper_info *info = ptr;
-	struct net_device *upper = info->upper_dev;
-	int err = 0;
+	int err = NOTIFY_DONE;
 
-	switch (event) {
-	case NETDEV_CHANGEUPPER:
-		if (netif_is_bridge_master(upper)) {
-			if (info->linking)
-				err = dsa_slave_bridge_port_join(dev, upper);
-			else
-				dsa_slave_bridge_port_leave(dev, upper);
+	if (netif_is_bridge_master(info->upper_dev)) {
+		if (info->linking) {
+			err = dsa_slave_bridge_port_join(dev, info->upper_dev);
+			err = notifier_from_errno(err);
+		} else {
+			dsa_slave_bridge_port_leave(dev, info->upper_dev);
+			err = NOTIFY_OK;
 		}
-
-		break;
-	}
-
-	return notifier_from_errno(err);
-}
-
-static int dsa_slave_port_event(struct net_device *dev, unsigned long event,
-				void *ptr)
-{
-	switch (event) {
-	case NETDEV_CHANGEUPPER:
-		return dsa_slave_port_upper_event(dev, event, ptr);
 	}
 
-	return NOTIFY_DONE;
+	return err;
 }
 
 static int dsa_slave_netdevice_event(struct notifier_block *nb,
@@ -1529,8 +1514,11 @@ static int dsa_slave_netdevice_event(struct notifier_block *nb,
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
-	if (dsa_slave_dev_check(dev))
-		return dsa_slave_port_event(dev, event, ptr);
+	if (dev->netdev_ops != &dsa_slave_netdev_ops)
+		return NOTIFY_DONE;
+
+	if (event == NETDEV_CHANGEUPPER)
+		return dsa_slave_changeupper(dev, ptr);
 
 	return NOTIFY_DONE;
 }
-- 
2.11.0
