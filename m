From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 4/9] net: dsa: Allow configuration of CPU & DSA port speeds/duplex
Date: Sun, 23 Aug 2015 11:46:55 +0200
Message-ID: <1440323220-20438-5-git-send-email-andrew@lunn.ch>
References: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38074 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971AbbHWJyx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2015 05:54:53 -0400
In-Reply-To: <1440323220-20438-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By default, DSA and CPU ports are configured to the maximum speed the
switch supports. However there can be use cases where the peer devices
port is slower. Allow a fixed-link property to be used with the DSA
and CPU port in the device tree, and use this information to configure
the port.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 053eb2b8e682..afff17341b73 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -176,6 +176,35 @@ __ATTRIBUTE_GROUPS(dsa_hwmon);
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
@@ -297,6 +326,14 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
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
2.5.0
