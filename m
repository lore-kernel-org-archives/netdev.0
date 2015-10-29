From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 6/6] net: dsa: move dsa slave destroy code to slave.c
Date: Thu, 29 Oct 2015 14:23:31 +0100
Message-ID: <56321DD3.3030708@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Frode Isaksen <fisaksen@baylibre.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move dsa slave dedicated code from dsa_switch_destroy to a new
dsa_slave_destroy function in slave.c

Signed-off-by: Frode Isaksen <fisaksen@baylibre.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c      |  5 +----
 net/dsa/dsa_priv.h |  1 +
 net/dsa/slave.c    | 10 ++++++++++
 3 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 11452e4..cf6b092 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -454,10 +454,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 		if (!ds->ports[port])
 			continue;

-		netif_carrier_off(ds->ports[port]);
-		unregister_netdev(ds->ports[port]);
-		phy_disconnect(p->phy);
-		free_netdev(ds->ports[port]);
+		dsa_slave_destroy(ds->ports[port]);
 	}

 	mdiobus_unregister(ds->slave_mii_bus);
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 311796c8..1d1a546 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -61,6 +61,7 @@ extern const struct dsa_device_ops notag_netdev_ops;
 void dsa_slave_mii_bus_init(struct dsa_switch *ds);
 int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		     int port, char *name);
+void dsa_slave_destroy(struct net_device *slave_dev);
 int dsa_slave_suspend(struct net_device *slave_dev);
 int dsa_slave_resume(struct net_device *slave_dev);
 int dsa_slave_netdevice_event(struct notifier_block *unused,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 481754e..f77e5bd 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1223,6 +1223,16 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	return 0;
 }

+void dsa_slave_destroy(struct net_device *slave_dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(slave_dev);
+
+	netif_carrier_off(slave_dev);
+	unregister_netdev(slave_dev);
+	phy_disconnect(p->phy);
+	free_netdev(slave_dev);
+}
+
 static bool dsa_slave_dev_check(struct net_device *dev)
 {
 	return dev->netdev_ops == &dsa_slave_netdev_ops;
-- 
1.9.1
