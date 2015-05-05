From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 04/10] net: dsa: Move mv88e6172 support into mv88e6352 family driver
Date: Wed,  6 May 2015 01:09:50 +0200
Message-ID: <1430867396-2268-5-git-send-email-andrew@lunn.ch>
References: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44510 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128AbbEEXPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 19:15:06 -0400
In-Reply-To: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6172 is part of the mv88e6352 family of devices. Move support
for it out of the mv88e6171 driver into the mv88e6352, which results
in some simplifications to the code.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/Kconfig     | 10 ++++-----
 drivers/net/dsa/mv88e6171.c | 53 ++++++---------------------------------------
 drivers/net/dsa/mv88e6352.c |  3 +++
 3 files changed, 15 insertions(+), 51 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 18550c7ebe6f..d96f2e24e6a9 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -37,22 +37,22 @@ config NET_DSA_MV88E6123_61_65
 	  ethernet switch chips.
 
 config NET_DSA_MV88E6171
-	tristate "Marvell 88E6171/6172 ethernet switch chip support"
+	tristate "Marvell 88E6171 ethernet switch chip support"
 	depends on NET_DSA
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_TAG_EDSA
 	---help---
-	  This enables support for the Marvell 88E6171/6172 ethernet switch
+	  This enables support for the Marvell 88E6171 ethernet switch
 	  chips.
 
 config NET_DSA_MV88E6352
-	tristate "Marvell 88E6176/88E6352 ethernet switch chip support"
+	tristate "Marvell 88E6172/88E6176/88E6352 ethernet switch chip support"
 	depends on NET_DSA
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_TAG_EDSA
 	---help---
-	  This enables support for the Marvell 88E6176 and 88E6352 ethernet
-	  switch chips.
+	  This enables support for the Marvell 88E6172, 88E6176 and 88E6352
+	  ethernet switch chips.
 
 config NET_DSA_BCM_SF2
 	tristate "Broadcom Starfighter 2 Ethernet switch support"
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 56fad84aded6..132783cc8aea 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -1,4 +1,4 @@
-/* net/dsa/mv88e6171.c - Marvell 88e6171/8826172 switch chip support
+/* net/dsa/mv88e6171.c - Marvell 88e6171 switch chip support
  * Copyright (c) 2008-2009 Marvell Semiconductor
  * Copyright (c) 2014 Claudio Leite <leitec@staticky.com>
  *
@@ -29,8 +29,6 @@ static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
 	if (ret >= 0) {
 		if ((ret & 0xfff0) == PORT_SWITCH_ID_6171)
 			return "Marvell 88E6171";
-		if ((ret & 0xfff0) == PORT_SWITCH_ID_6172)
-			return "Marvell 88E6172";
 	}
 
 	return NULL;
@@ -40,6 +38,7 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 {
 	u32 upstream_port = dsa_upstream_port(ds);
 	int ret;
+	u32 reg;
 
 	ret = mv88e6xxx_setup_global(ds);
 	if (ret)
@@ -55,24 +54,11 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 	 * port as the port to which ingress and egress monitor frames
 	 * are to be sent.
 	 */
-	if (REG_READ(REG_PORT(0), PORT_SWITCH_ID) == PORT_SWITCH_ID_6171)
-		REG_WRITE(REG_GLOBAL, GLOBAL_MONITOR_CONTROL,
-			  upstream_port <<
-			  GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
-			  upstream_port <<
-			  GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
-			  upstream_port <<
-			  GLOBAL_MONITOR_CONTROL_ARP_SHIFT |
-			  upstream_port <<
-			  GLOBAL_MONITOR_CONTROL_MIRROR_SHIFT);
-	else
-		REG_WRITE(REG_GLOBAL, GLOBAL_MONITOR_CONTROL,
-			  upstream_port <<
-			  GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
-			  upstream_port <<
-			  GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
-			  upstream_port <<
-			  GLOBAL_MONITOR_CONTROL_ARP_SHIFT);
+	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_MIRROR_SHIFT;
+	REG_WRITE(REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
 
 	/* Disable remote management for now, and set the switch's
 	 * DSA device number.
@@ -104,28 +90,6 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	return mv88e6xxx_setup_ports(ds);
 }
 
-static int mv88e6171_get_eee(struct dsa_switch *ds, int port,
-			     struct ethtool_eee *e)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
-	if (ps->id == PORT_SWITCH_ID_6172)
-		return mv88e6xxx_get_eee(ds, port, e);
-
-	return -EOPNOTSUPP;
-}
-
-static int mv88e6171_set_eee(struct dsa_switch *ds, int port,
-			     struct phy_device *phydev, struct ethtool_eee *e)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
-	if (ps->id == PORT_SWITCH_ID_6172)
-		return mv88e6xxx_set_eee(ds, port, phydev, e);
-
-	return -EOPNOTSUPP;
-}
-
 struct dsa_switch_driver mv88e6171_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.priv_size		= sizeof(struct mv88e6xxx_priv_state),
@@ -138,8 +102,6 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
-	.set_eee		= mv88e6171_set_eee,
-	.get_eee		= mv88e6171_get_eee,
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp               = mv88e6xxx_get_temp,
 #endif
@@ -154,4 +116,3 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 };
 
 MODULE_ALIAS("platform:mv88e6171");
-MODULE_ALIAS("platform:mv88e6172");
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index e9aca7f7945e..632815c10a40 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -32,6 +32,8 @@ static char *mv88e6352_probe(struct device *host_dev, int sw_addr)
 
 	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), PORT_SWITCH_ID);
 	if (ret >= 0) {
+		if ((ret & 0xfff0) == PORT_SWITCH_ID_6172)
+			return "Marvell 88E6172";
 		if ((ret & 0xfff0) == PORT_SWITCH_ID_6176)
 			return "Marvell 88E6176";
 		if (ret == PORT_SWITCH_ID_6352_A0)
@@ -393,3 +395,4 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 };
 
 MODULE_ALIAS("platform:mv88e6352");
+MODULE_ALIAS("platform:mv88e6172");
-- 
2.1.4
