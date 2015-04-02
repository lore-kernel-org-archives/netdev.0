From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 04/12] net: dsa: mv88e6123_61_65: Determine and use number of switch ports
Date: Thu,  2 Apr 2015 04:06:32 +0200
Message-ID: <1427940400-12434-5-git-send-email-andrew@lunn.ch>
References: <1427940400-12434-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35797 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752083AbbDBCKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 22:10:38 -0400
In-Reply-To: <1427940400-12434-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>

Determine and use number of switch ports from chip ID instead of always
using the maximum, and return error when an attempt is made to access a
non-existing port.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6123_61_65.c | 54 +++++++++++++++++++++++++++------------
 1 file changed, 38 insertions(+), 16 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 2d7e1ffe9fdc..6480f77829ef 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -27,25 +27,25 @@ static char *mv88e6123_61_65_probe(struct device *host_dev, int sw_addr)
 
 	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
 	if (ret >= 0) {
-		if (ret == 0x1212)
+		if (ret == ID_6123_A1)
 			return "Marvell 88E6123 (A1)";
-		if (ret == 0x1213)
+		if (ret == ID_6123_A2)
 			return "Marvell 88E6123 (A2)";
-		if ((ret & 0xfff0) == 0x1210)
+		if ((ret & 0xfff0) == ID_6123)
 			return "Marvell 88E6123";
 
-		if (ret == 0x1612)
+		if (ret == ID_6161_A1)
 			return "Marvell 88E6161 (A1)";
-		if (ret == 0x1613)
+		if (ret == ID_6161_A2)
 			return "Marvell 88E6161 (A2)";
-		if ((ret & 0xfff0) == 0x1610)
+		if ((ret & 0xfff0) == ID_6161)
 			return "Marvell 88E6161";
 
-		if (ret == 0x1652)
+		if (ret == ID_6165_A1)
 			return "Marvell 88E6165 (A1)";
-		if (ret == 0x1653)
+		if (ret == ID_6165_A2)
 			return "Marvell 88e6165 (A2)";
-		if ((ret & 0xfff0) == 0x1650)
+		if ((ret & 0xfff0) == ID_6165)
 			return "Marvell 88E6165";
 	}
 
@@ -54,12 +54,13 @@ static char *mv88e6123_61_65_probe(struct device *host_dev, int sw_addr)
 
 static int mv88e6123_61_65_switch_reset(struct dsa_switch *ds)
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
@@ -271,6 +272,7 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 
 static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int i;
 	int ret;
 
@@ -278,6 +280,18 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
+	switch (ps->id) {
+	case ID_6123:
+		ps->num_ports = 3;
+		break;
+	case ID_6161:
+	case ID_6165:
+		ps->num_ports = 6;
+		break;
+	default:
+		return -ENODEV;
+	}
+
 	ret = mv88e6123_61_65_switch_reset(ds);
 	if (ret < 0)
 		return ret;
@@ -288,7 +302,7 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < 6; i++) {
+	for (i = 0; i < ps->num_ports; i++) {
 		ret = mv88e6123_61_65_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
@@ -297,20 +311,25 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6123_61_65_port_to_phy_addr(int port)
+static int mv88e6123_61_65_port_to_phy_addr(struct dsa_switch *ds, int port)
 {
-	if (port >= 0 && port <= 4)
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (port >= 0 && port < ps->num_ports)
 		return port;
-	return -1;
+	return -EINVAL;
 }
 
 static int
 mv88e6123_61_65_phy_read(struct dsa_switch *ds, int port, int regnum)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6123_61_65_port_to_phy_addr(port);
+	int addr = mv88e6123_61_65_port_to_phy_addr(ds, port);
 	int ret;
 
+	if (addr < 0)
+		return addr;
+
 	mutex_lock(&ps->phy_mutex);
 	ret = mv88e6xxx_phy_read(ds, addr, regnum);
 	mutex_unlock(&ps->phy_mutex);
@@ -322,9 +341,12 @@ mv88e6123_61_65_phy_write(struct dsa_switch *ds,
 			      int port, int regnum, u16 val)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6123_61_65_port_to_phy_addr(port);
+	int addr = mv88e6123_61_65_port_to_phy_addr(ds, port);
 	int ret;
 
+	if (addr < 0)
+		return addr;
+
 	mutex_lock(&ps->phy_mutex);
 	ret = mv88e6xxx_phy_write(ds, addr, regnum, val);
 	mutex_unlock(&ps->phy_mutex);
-- 
2.1.4
