From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 03/12] net: dsa: mv88e6131: Determine and use number of switch ports
Date: Thu,  2 Apr 2015 03:21:50 +0200
Message-ID: <1427937719-11630-4-git-send-email-andrew@lunn.ch>
References: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35729 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752092AbbDBB0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 21:26:05 -0400
In-Reply-To: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>

Determine and use number of switch ports from chip ID instead of always
using the maximum, and return error when an attempt is made to access a
non-existing port.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6131.c | 42 +++++++++++++++++++++++++++++++++++-------
 drivers/net/dsa/mv88e6xxx.h |  1 +
 2 files changed, 36 insertions(+), 7 deletions(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index f0dea2d1581e..6b818fde2216 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -44,12 +44,13 @@ static char *mv88e6131_probe(struct device *host_dev, int sw_addr)
 
 static int mv88e6131_switch_reset(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int i;
 	int ret;
 	unsigned long timeout;
 
 	/* Set all ports to the disabled state. */
-	for (i = 0; i < 11; i++) {
+	for (i = 0; i < ps->num_ports; i++) {
 		ret = REG_READ(REG_PORT(i), 0x04);
 		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
 	}
@@ -255,6 +256,7 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 
 static int mv88e6131_setup(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int i;
 	int ret;
 
@@ -264,6 +266,21 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 
 	mv88e6xxx_ppu_state_init(ds);
 
+	switch (ps->id) {
+	case ID_6085:
+		ps->num_ports = 10;
+		break;
+	case ID_6095:
+		ps->num_ports = 11;
+		break;
+	case ID_6131:
+	case ID_6131_B2:
+		ps->num_ports = 8;
+		break;
+	default:
+		return -ENODEV;
+	}
+
 	ret = mv88e6131_switch_reset(ds);
 	if (ret < 0)
 		return ret;
@@ -274,7 +291,7 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < 11; i++) {
+	for (i = 0; i < ps->num_ports; i++) {
 		ret = mv88e6131_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
@@ -283,17 +300,24 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6131_port_to_phy_addr(int port)
+static int mv88e6131_port_to_phy_addr(struct dsa_switch *ds, int port)
 {
-	if (port >= 0 && port <= 11)
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (port >= 0 && port < ps->num_ports)
 		return port;
-	return -1;
+
+	return -EINVAL;
 }
 
 static int
 mv88e6131_phy_read(struct dsa_switch *ds, int port, int regnum)
 {
-	int addr = mv88e6131_port_to_phy_addr(port);
+	int addr = mv88e6131_port_to_phy_addr(ds, port);
+
+	if (addr < 0)
+		return addr;
+
 	return mv88e6xxx_phy_read_ppu(ds, addr, regnum);
 }
 
@@ -301,7 +325,11 @@ static int
 mv88e6131_phy_write(struct dsa_switch *ds,
 			      int port, int regnum, u16 val)
 {
-	int addr = mv88e6131_port_to_phy_addr(port);
+	int addr = mv88e6131_port_to_phy_addr(ds, port);
+
+	if (addr < 0)
+		return addr;
+
 	return mv88e6xxx_phy_write_ppu(ds, addr, regnum, val);
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index aca48792db4b..ef058444bdb7 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -109,6 +109,7 @@ struct mv88e6xxx_priv_state {
 	struct mutex eeprom_mutex;
 
 	int		id; /* switch product id */
+	int		num_ports;	/* number of switch ports */
 
 	/* hw bridging */
 
-- 
2.1.4
