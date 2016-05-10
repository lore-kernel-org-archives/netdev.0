From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 5/7] dsa: Remove master_dev from switch structure
Date: Tue, 10 May 2016 23:27:23 +0200
Message-ID: <1462915645-24674-6-git-send-email-andrew@lunn.ch>
References: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35017 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751410AbcEJVao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 17:30:44 -0400
In-Reply-To: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The switch drivers only use the master_dev member for dev_info()
messages.  Now that the device is passed to the old style probe, and
new style drivers are probed as true linux drivers, this is no longer
needed.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 1 +
 include/net/dsa.h           | 7 ++-----
 net/dsa/dsa.c               | 2 +-
 net/dsa/slave.c             | 2 +-
 4 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index f4bb3bed812f..428d213ed4fc 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3628,6 +3628,7 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev)
 
 	ps = (struct mv88e6xxx_priv_state *)(ds + 1);
 	ds->priv = ps;
+	ds->dev = dev;
 	ps->dev = dev;
 	ps->ds = ds;
 	ps->bus = mdiodev->bus;
diff --git a/include/net/dsa.h b/include/net/dsa.h
index ecb52e265cc3..f4c0bff8d9d6 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -120,6 +120,8 @@ struct dsa_switch_tree {
 };
 
 struct dsa_switch {
+	struct device *dev;
+
 	/*
 	 * Parent switch tree, and switch index.
 	 */
@@ -142,11 +144,6 @@ struct dsa_switch {
 	 */
 	struct dsa_switch_driver	*drv;
 
-	/*
-	 * Reference to host device to use.
-	 */
-	struct device		*master_dev;
-
 #ifdef CONFIG_NET_DSA_HWMON
 	/*
 	 * Hardware monitoring information
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index df169811f26d..5db779c69a68 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -411,7 +411,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	ds->pd = pd;
 	ds->drv = drv;
 	ds->priv = priv;
-	ds->master_dev = host_dev;
+	ds->dev = parent;
 
 	ret = dsa_switch_setup_one(ds, parent);
 	if (ret)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 5ea8a40c8d33..f25dcd9e814a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -51,7 +51,7 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 	ds->slave_mii_bus->write = dsa_slave_phy_write;
 	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "dsa-%d:%.2x",
 			ds->index, ds->pd->sw_addr);
-	ds->slave_mii_bus->parent = ds->master_dev;
+	ds->slave_mii_bus->parent = ds->dev;
 	ds->slave_mii_bus->phy_mask = ~ds->phys_mii_mask;
 }
 
-- 
2.8.1
