From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCHv2 4/4] net: dsa: Allow configuration of CPU & DSA port speeds/duplex
Date: Sun, 28 Jun 2015 21:50:01 +0200
Message-ID: <1435521001-25195-5-git-send-email-andrew@lunn.ch>
References: <1435521001-25195-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58894 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752678AbbF1T4X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2015 15:56:23 -0400
In-Reply-To: <1435521001-25195-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, DSA and CPU ports are configured to the maximum speed the
switch supports. However there can be use cases where the peer device
port is slower. Allow a fixed-link property to be used with the DSA
and CPU port in the device tree, and use this information to configure
the port.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2: Remove support for multiple CPU ports.
---
 net/dsa/dsa.c | 38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 392e29a0227d..18eed3fbae93 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -176,6 +176,36 @@ __ATTRIBUTE_GROUPS(dsa_hwmon);
 #endif /* CONFIG_NET_DSA_HWMON */
 
 /* basic switch operations **************************************************/
+static int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct net_device *master)
+{
+	struct dsa_chip_data *cd = ds->pd;
+	struct device_node *port_dn;
+	struct phy_device *phydev;
+	int ret, port;
+
+	for (port = 0; port < DSA_MAX_PORTS; port++) {
+		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
+			continue;
+
+		port_dn = cd->port_dn[port];
+		if (of_phy_is_fixed_link(port_dn)) {
+			ret = of_phy_register_fixed_link(port_dn);
+			if (ret) {
+				netdev_err(master,
+					   "failed to register fixed PHY\n");
+				return ret;
+			}
+			phydev = of_phy_find_device(port_dn);
+			phydev->is_pseudo_fixed_link = true;
+			genphy_config_init(phydev);
+			genphy_read_status(phydev);
+			if (ds->drv->adjust_link)
+				ds->drv->adjust_link(ds, port, phydev);
+		}
+	}
+	return 0;
+}
+
 static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 {
 	struct dsa_switch_driver *drv = ds->drv;
@@ -297,6 +327,14 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		}
 	}
 
+	/* Perform configuration of the CPU and DSA ports */
+	ret = dsa_cpu_dsa_setup(ds, dst->master_netdev);
+	if (ret < 0) {
+		netdev_err(dst->master_netdev, "[%d] : can't configure CPU and DSA ports\n",
+			   index);
+		ret = 0;
+	}
+
 #ifdef CONFIG_NET_DSA_HWMON
 	/* If the switch provides a temperature sensor,
 	 * register with hardware monitoring subsystem.
-- 
2.1.4
