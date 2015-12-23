From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC 28/28] dsa: Destroy fixed link phys after the phy has been disconnected
Date: Wed, 23 Dec 2015 13:56:42 +0100
Message-ID: <1450875402-20740-29-git-send-email-andrew@lunn.ch>
References: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>, narmstrong@baylibre.com,
	vivien.didelot@savoirfairelinux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48814 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757202AbbLWM7J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 07:59:09 -0500
In-Reply-To: <1450875402-20740-1-git-send-email-andrew@lunn.ch>
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
index c5f55b672675..e344c833e707 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -426,7 +426,18 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
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
@@ -444,17 +455,6 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
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
2.6.3
