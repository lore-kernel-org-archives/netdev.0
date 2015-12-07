From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 net-next 4/4] net: dsa: move dsa slave destroy code to slave.c
Date: Mon,  7 Dec 2015 13:57:35 +0100
Message-ID: <1449493055-29047-5-git-send-email-narmstrong@baylibre.com>
References: <56321D9A.8010109@baylibre.com>
 <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong@baylibre.com>,
	Frode Isaksen <fisaksen@baylibre.com>
To: davem@davemloft.net, andrew@lunn.ch, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	fabf@skynet.be, pavel.nakonechny@skitlab.ru, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:32933 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755000AbbLGM7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 07:59:11 -0500
Received: by wmec201 with SMTP id c201so164194125wme.0
        for <netdev@vger.kernel.org>; Mon, 07 Dec 2015 04:59:10 -0800 (PST)
In-Reply-To: <1449493055-29047-1-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move dsa slave dedicated code from dsa_switch_destroy to a new
dsa_slave_destroy function in slave.c.
Add the netif_carrier_off and phy_disconnect calls in order to
correctly cleanup the netdev state and PHY state machine.

Signed-off-by: Frode Isaksen <fisaksen@baylibre.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c      |  3 +--
 net/dsa/dsa_priv.h |  1 +
 net/dsa/slave.c    | 11 +++++++++++
 3 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index d22d303e..208d1b2 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -456,8 +456,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 		if (!ds->ports[port])
 			continue;
 
-		unregister_netdev(ds->ports[port]);
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
index 7bc787b..1e9e942 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1212,6 +1212,17 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	return 0;
 }
 
+void dsa_slave_destroy(struct net_device *slave_dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(slave_dev);
+
+	netif_carrier_off(slave_dev);
+	if (p->phy)
+		phy_disconnect(p->phy);
+	unregister_netdev(slave_dev);
+	free_netdev(slave_dev);
+}
+
 static bool dsa_slave_dev_check(struct net_device *dev)
 {
 	return dev->netdev_ops == &dsa_slave_netdev_ops;
-- 
1.9.1
