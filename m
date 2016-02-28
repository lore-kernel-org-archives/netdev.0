From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 03/32] dsa: Make setup and finish more symmetrical
Date: Sun, 28 Feb 2016 17:41:11 +0100
Message-ID: <1456677700-23027-4-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44892 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758821AbcB1Ql5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:41:57 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename and reposition dsa_switch_destroy() to dsa_switch_finish_one()
to make it clear it is the opposite of dsa_switch_setup_one().

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 90 +++++++++++++++++++++++++++++------------------------------
 1 file changed, 45 insertions(+), 45 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index be68c00b8cfd..6e9176545dda 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -374,6 +374,50 @@ out:
 	return ret;
 }
 
+static void dsa_switch_finish_one(struct dsa_switch *ds)
+{
+	struct device_node *port_dn;
+	struct phy_device *phydev;
+	struct dsa_chip_data *cd = ds->pd;
+	int port;
+
+#ifdef CONFIG_NET_DSA_HWMON
+	if (ds->hwmon_dev)
+		hwmon_device_unregister(ds->hwmon_dev);
+#endif
+
+	/* Disable configuration of the CPU and DSA ports */
+	for (port = 0; port < DSA_MAX_PORTS; port++) {
+		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
+			continue;
+
+		port_dn = cd->port_dn[port];
+		if (of_phy_is_fixed_link(port_dn)) {
+			phydev = of_phy_find_device(port_dn);
+			if (phydev) {
+				int addr = phydev->mdio.addr;
+
+				phy_device_free(phydev);
+				of_node_put(port_dn);
+				fixed_phy_del(addr);
+			}
+		}
+	}
+
+	/* Destroy network devices for physical switch ports. */
+	for (port = 0; port < DSA_MAX_PORTS; port++) {
+		if (!(ds->phys_port_mask & (1 << port)))
+			continue;
+
+		if (!ds->ports[port])
+			continue;
+
+		dsa_slave_destroy(ds->ports[port]);
+	}
+
+	mdiobus_unregister(ds->slave_mii_bus);
+}
+
 static struct dsa_switch *
 dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 		 struct device *parent, struct device *host_dev)
@@ -418,50 +462,6 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	return ds;
 }
 
-static void dsa_switch_destroy(struct dsa_switch *ds)
-{
-	struct device_node *port_dn;
-	struct phy_device *phydev;
-	struct dsa_chip_data *cd = ds->pd;
-	int port;
-
-#ifdef CONFIG_NET_DSA_HWMON
-	if (ds->hwmon_dev)
-		hwmon_device_unregister(ds->hwmon_dev);
-#endif
-
-	/* Disable configuration of the CPU and DSA ports */
-	for (port = 0; port < DSA_MAX_PORTS; port++) {
-		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
-			continue;
-
-		port_dn = cd->port_dn[port];
-		if (of_phy_is_fixed_link(port_dn)) {
-			phydev = of_phy_find_device(port_dn);
-			if (phydev) {
-				int addr = phydev->mdio.addr;
-
-				phy_device_free(phydev);
-				of_node_put(port_dn);
-				fixed_phy_del(addr);
-			}
-		}
-	}
-
-	/* Destroy network devices for physical switch ports. */
-	for (port = 0; port < DSA_MAX_PORTS; port++) {
-		if (!(ds->phys_port_mask & (1 << port)))
-			continue;
-
-		if (!ds->ports[port])
-			continue;
-
-		dsa_slave_destroy(ds->ports[port]);
-	}
-
-	mdiobus_unregister(ds->slave_mii_bus);
-}
-
 #ifdef CONFIG_PM_SLEEP
 static int dsa_switch_suspend(struct dsa_switch *ds)
 {
@@ -928,7 +928,7 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 		struct dsa_switch *ds = dst->ds[i];
 
 		if (ds)
-			dsa_switch_destroy(ds);
+			dsa_switch_finish_one(ds);
 	}
 
 	dev_put(dst->master_netdev);
-- 
2.7.0
