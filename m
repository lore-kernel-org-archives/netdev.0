From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 7/8] net: dsa: Support phy interrupt property for switch ports.
Date: Mon, 14 Mar 2016 01:33:50 +0100
Message-ID: <1457915631-16696-8-git-send-email-andrew@lunn.ch>
References: <1457915631-16696-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55932 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932298AbcCNAe3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Mar 2016 20:34:29 -0400
In-Reply-To: <1457915631-16696-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch ports can be connected to phys. These phys can support
interrupts when the link goes up/down. Allow the phy interrupt to be
expressed in device tree, and pass it to the phylib when the phy is
bound to the switch port.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 Documentation/devicetree/bindings/net/dsa/dsa.txt |  3 +++
 net/dsa/dsa_priv.h                                |  1 +
 net/dsa/slave.c                                   | 11 ++++++++++-
 3 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
index 90a4fe115e50..780c96f37508 100644
--- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
+++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
@@ -55,6 +55,9 @@ Optionnal property:
 			  Documentation/devicetree/bindings/net/ethernet.txt
 			  for details.
 
+- interrupt-parent	: property with a value describing the phy
+- interrupts		  interrupt number. See Documentation/devicetree/bindings/net/phy.txt
+
 - phy-mode		: String representing the connection to the designated
 			  PHY node specified by the 'phy-handle' property. See
 			  Documentation/devicetree/bindings/net/ethernet.txt
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 1d1a54687e4a..5ce368ea0464 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -46,6 +46,7 @@ struct dsa_slave_priv {
 	int			old_link;
 	int			old_pause;
 	int			old_duplex;
+	int			phy_irq;
 
 	struct net_device	*bridge_dev;
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 27bf03d11670..155bddc43624 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -13,6 +13,7 @@
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <linux/phy_fixed.h>
+#include <linux/of_irq.h>
 #include <linux/of_net.h>
 #include <linux/of_mdio.h>
 #include <linux/mdio.h>
@@ -921,6 +922,10 @@ static int dsa_slave_phy_connect(struct dsa_slave_priv *p,
 	/* Use already configured phy mode */
 	if (p->phy_interface == PHY_INTERFACE_MODE_NA)
 		p->phy_interface = p->phy->interface;
+
+	if (p->phy_irq)
+		p->phy->irq = p->phy_irq;
+
 	phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
 			   p->phy_interface);
 
@@ -935,7 +940,7 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 	struct device_node *phy_dn, *port_dn;
 	bool phy_is_fixed = false;
 	u32 phy_flags = 0;
-	int mode, ret;
+	int mode, ret, irq;
 
 	port_dn = cd->port_dn[p->port];
 	mode = of_get_phy_mode(port_dn);
@@ -943,6 +948,10 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		mode = PHY_INTERFACE_MODE_NA;
 	p->phy_interface = mode;
 
+	irq = irq_of_parse_and_map(port_dn, 0);
+	if (irq > 0)
+		p->phy_irq = irq;
+
 	phy_dn = of_parse_phandle(port_dn, "phy-handle", 0);
 	if (of_phy_is_fixed_link(port_dn)) {
 		/* In the case of a fixed PHY, the DT node associated
-- 
2.7.0
