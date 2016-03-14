From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 1/8] net: dsa: Add parsing of an interrupt property
Date: Mon, 14 Mar 2016 01:33:44 +0100
Message-ID: <1457915631-16696-2-git-send-email-andrew@lunn.ch>
References: <1457915631-16696-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55956 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932298AbcCNAfB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Mar 2016 20:35:01 -0400
In-Reply-To: <1457915631-16696-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some switch chips have an interrupt line, which can be connected to
a GPIO line and used to indicate interrupts. Add parsing of such
an interrupt to the DSA framework.

Also, update the binding, which already listed an interrupt.  However,
interrupts are a property of the chip, not the cluster, so move it
into the chip level of the hierarchy.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt | 7 +++----
 include/net/dsa.h                                 | 6 ++++++
 net/dsa/dsa.c                                     | 8 ++++++++
 3 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index 5fdbbcdf8c4b..90a4fe115e50 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -10,10 +10,6 @@ Required properties:
 - dsa,ethernet		: Should be a phandle to a valid Ethernet device node
 - dsa,mii-bus		: Should be a phandle to a valid MDIO bus device node
 
-Optional properties:
-- interrupts		: property with a value describing the switch
-			  interrupt number (not supported by the driver)
-
 A DSA node can contain multiple switch chips which are therefore child nodes of
 the parent DSA node. The maximum number of allowed child nodes is 4
 (DSA_MAX_SWITCHES).
@@ -34,6 +30,9 @@ A switch child node has the following optional property:
 - reset-gpios		: phandle and specifier to a gpio line connected to
 			  reset pin of the switch chip.
 
+- interrupts		: property with a value describing the switch
+			  interrupt number
+
 A switch may have multiple "port" children nodes
 
 Each port children node must have the following mandatory properties:
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 26c0a3fa009a..ff737781cf8f 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -59,6 +59,12 @@ struct dsa_chip_data {
 	struct device_node *port_dn[DSA_MAX_PORTS];
 
 	/*
+	 * The switch may have an interrupt line, which can be used
+	 * to indicate events have occurred in the switch.
+	 */
+	int irq;
+
+	/*
 	 * An array (with nr_chips elements) of which element [a]
 	 * indicates which port on this switch should be used to
 	 * send packets to that are destined for switch a.  Can be
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index d8fb47fcad05..980aa10fc3a1 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -20,6 +20,7 @@
 #include <linux/of.h>
 #include <linux/of_mdio.h>
 #include <linux/of_platform.h>
+#include <linux/of_irq.h>
 #include <linux/of_net.h>
 #include <linux/of_gpio.h>
 #include <linux/sysfs.h>
@@ -667,6 +668,7 @@ static int dsa_of_probe(struct device *dev)
 	unsigned long flags;
 	u32 eeprom_len;
 	int ret;
+	int irq;
 
 	mdio = of_parse_phandle(np, "dsa,mii-bus", 0);
 	if (!mdio)
@@ -728,6 +730,12 @@ static int dsa_of_probe(struct device *dev)
 		if (!of_property_read_u32(child, "eeprom-length", &eeprom_len))
 			cd->eeprom_len = eeprom_len;
 
+		irq = of_irq_get(child, 0);
+		if (irq == -EPROBE_DEFER)
+			goto out_free_chip;
+		if (irq > 0)
+			cd->irq = irq;
+
 		mdio = of_parse_phandle(child, "mii-bus", 0);
 		if (mdio) {
 			mdio_bus_switch = of_mdio_find_bus(mdio);
-- 
2.7.0
