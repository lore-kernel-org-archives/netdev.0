From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v3 3/5] net: dsa: complete dsa_switch_destroy
Date: Tue, 6 Oct 2015 15:40:32 +0100
Message-ID: <5613DD60.3010900@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When unbinding dsa, complete the dsa_switch_destroy to unregister the
fixed link phy then cleanly unregister and destroy the net devices.

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 14fac4e..6155923 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -22,6 +22,7 @@
 #include <linux/of_platform.h>
 #include <linux/of_net.h>
 #include <linux/sysfs.h>
+#include <linux/phy_fixed.h>
 #include "dsa_priv.h"

 char dsa_driver_version[] = "0.1";
@@ -420,10 +421,46 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,

 static void dsa_switch_destroy(struct dsa_switch *ds)
 {
+	struct device_node *port_dn;
+	struct phy_device *phydev;
+	struct dsa_chip_data *cd = ds->pd;
+	int port;
+
 #ifdef CONFIG_NET_DSA_HWMON
 	if (ds->hwmon_dev)
 		hwmon_device_unregister(ds->hwmon_dev);
 #endif
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
+				int addr = phydev->addr;
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
+		unregister_netdev(ds->ports[port]);
+		free_netdev(ds->ports[port]);
+	}
+
 	mdiobus_unregister(ds->slave_mii_bus);
 	mdiobus_free(ds->slave_mii_bus);
 }
-- 
1.9.1
