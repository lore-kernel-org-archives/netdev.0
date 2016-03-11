From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 3/5] dsa: Destroy fixed link phys after the phy has been disconnected
Date: Sat, 12 Mar 2016 00:01:38 +0100
Message-ID: <1457737300-23660-4-git-send-email-andrew@lunn.ch>
References: <1457737300-23660-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55199 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932683AbcCKXCN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 18:02:13 -0500
In-Reply-To: <1457737300-23660-1-git-send-email-andrew@lunn.ch>
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
index d8fb47fcad05..1018e7dcfcc9 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -430,7 +430,18 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
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
@@ -448,17 +459,6 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
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
