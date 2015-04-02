From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 05/12] net: dsa: Consistently set and use ps->num_ports
Date: Thu,  2 Apr 2015 03:21:52 +0200
Message-ID: <1427937719-11630-6-git-send-email-andrew@lunn.ch>
References: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35755 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533AbbDBB0i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 21:26:38 -0400
In-Reply-To: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a step towards consolidating code, consistently set the
number of ports in the private state structure, and make use of it in
loops.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6171.c | 23 +++++++++++++++--------
 drivers/net/dsa/mv88e6352.c | 10 +++++++---
 2 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 639bd83b76c7..5a295533ff20 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -38,12 +38,13 @@ static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
 
 static int mv88e6171_switch_reset(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int i;
 	int ret;
 	unsigned long timeout;
 
 	/* Set all ports to the disabled state. */
-	for (i = 0; i < 8; i++) {
+	for (i = 0; i < ps->num_ports; i++) {
 		ret = REG_READ(REG_PORT(i), 0x04);
 		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
 	}
@@ -70,7 +71,7 @@ static int mv88e6171_switch_reset(struct dsa_switch *ds)
 		return -ETIMEDOUT;
 
 	/* Enable ports not under DSA, e.g. WAN port */
-	for (i = 0; i < 8; i++) {
+	for (i = 0; i < ps->num_ports; i++) {
 		if (dsa_is_cpu_port(ds, i) || ds->phys_port_mask & (1 << i))
 			continue;
 
@@ -83,6 +84,7 @@ static int mv88e6171_switch_reset(struct dsa_switch *ds)
 
 static int mv88e6171_setup_global(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 	int i;
 
@@ -147,7 +149,7 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 	}
 
 	/* Clear all trunk masks. */
-	for (i = 0; i < 8; i++)
+	for (i = 0; i < ps->num_ports; i++)
 		REG_WRITE(REG_GLOBAL2, 0x07, 0x8000 | (i << 12) | 0xff);
 
 	/* Clear all trunk mappings. */
@@ -270,6 +272,7 @@ static int mv88e6171_setup_port(struct dsa_switch *ds, int p)
 
 static int mv88e6171_setup(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int i;
 	int ret;
 
@@ -277,6 +280,8 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
+	ps->num_ports = 7;
+
 	ret = mv88e6171_switch_reset(ds);
 	if (ret < 0)
 		return ret;
@@ -287,7 +292,7 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < 8; i++) {
+	for (i = 0; i < ps->num_ports; i++) {
 		if (!(dsa_is_cpu_port(ds, i) || ds->phys_port_mask & (1 << i)))
 			continue;
 
@@ -299,9 +304,11 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6171_port_to_phy_addr(int port)
+static int mv88e6171_port_to_phy_addr(struct dsa_switch *ds, int port)
 {
-	if (port >= 0 && port <= 4)
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (port >= 0 && port < ps->num_ports)
 		return port;
 	return -1;
 }
@@ -310,7 +317,7 @@ static int
 mv88e6171_phy_read(struct dsa_switch *ds, int port, int regnum)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6171_port_to_phy_addr(port);
+	int addr = mv88e6171_port_to_phy_addr(ds, port);
 	int ret;
 
 	mutex_lock(&ps->phy_mutex);
@@ -324,7 +331,7 @@ mv88e6171_phy_write(struct dsa_switch *ds,
 		    int port, int regnum, u16 val)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6171_port_to_phy_addr(port);
+	int addr = mv88e6171_port_to_phy_addr(ds, port);
 	int ret;
 
 	mutex_lock(&ps->phy_mutex);
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 41fe3a6a72d1..040027fcd013 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -47,12 +47,13 @@ static char *mv88e6352_probe(struct device *host_dev, int sw_addr)
 
 static int mv88e6352_switch_reset(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	unsigned long timeout;
 	int ret;
 	int i;
 
 	/* Set all ports to the disabled state. */
-	for (i = 0; i < 7; i++) {
+	for (i = 0; i < ps->num_ports; i++) {
 		ret = REG_READ(REG_PORT(i), 0x04);
 		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
 	}
@@ -82,6 +83,7 @@ static int mv88e6352_switch_reset(struct dsa_switch *ds)
 
 static int mv88e6352_setup_global(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 	int i;
 
@@ -152,7 +154,7 @@ static int mv88e6352_setup_global(struct dsa_switch *ds)
 	/* Disable ingress rate limiting by resetting all ingress
 	 * rate limit registers to their initial state.
 	 */
-	for (i = 0; i < 7; i++)
+	for (i = 0; i < ps->num_ports; i++)
 		REG_WRITE(REG_GLOBAL2, 0x09, 0x9000 | (i << 8));
 
 	/* Initialise cross-chip port VLAN table to reset defaults. */
@@ -367,6 +369,8 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
+	ps->num_ports = 7;
+
 	mutex_init(&ps->eeprom_mutex);
 
 	ret = mv88e6352_switch_reset(ds);
@@ -379,7 +383,7 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < 7; i++) {
+	for (i = 0; i < ps->num_ports; i++) {
 		ret = mv88e6352_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
-- 
2.1.4
