From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 30/32] dsa: Destroy fixed link phys after the phy has been disconnected
Date: Sun, 28 Feb 2016 17:41:38 +0100
Message-ID: <1456677700-23027-31-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45023 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758567AbcB1Qn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:43:56 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy is disconnected from the slave in dsa_slave_destroy(). Don't
destroy fixed link phys until after this, since there can be fixed
linked phys connected to ports.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index c61b7ab092f5..73f962d81d40 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -387,7 +387,18 @@ static void dsa_switch_finish_one(struct dsa_switch *ds)
 		hwmon_device_unregister(ds->hwmon_dev);
 #endif
 
-	/* Disable configuration of the CPU and DSA ports */
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
+	/* Remove any fixed link PHYs */
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
@@ -405,17 +416,6 @@ static void dsa_switch_finish_one(struct dsa_switch *ds)
 		}
 	}
 
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
 	mdiobus_unregister(ds->slave_mii_bus);
 }
 
-- 
2.7.0
