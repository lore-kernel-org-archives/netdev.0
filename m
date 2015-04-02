From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 09/12] net: dsa: mv88e6xxx: Add missing mutex's in EEE operations.
Date: Thu,  2 Apr 2015 03:21:56 +0200
Message-ID: <1427937719-11630-10-git-send-email-andrew@lunn.ch>
References: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35744 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751533AbbDBB0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 21:26:21 -0400
In-Reply-To: <1427937719-11630-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy_mutex should be held while reading and writing to the phy.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Guenter Roeck <linux@roeck-us.net>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6xxx.c | 59 +++++++++++++++++++++++----------------------
 1 file changed, 30 insertions(+), 29 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 7c4c04bb0cb0..d9a78c71a4bb 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -701,53 +701,54 @@ static int _mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr,
 
 int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int reg;
 
-	reg = mv88e6xxx_phy_read_indirect(ds, port, 16);
+	mutex_lock(&ps->phy_mutex);
+
+	reg = _mv88e6xxx_phy_read_indirect(ds, port, 16);
 	if (reg < 0)
-		return -EOPNOTSUPP;
+		goto out;
 
 	e->eee_enabled = !!(reg & 0x0200);
 	e->tx_lpi_enabled = !!(reg & 0x0100);
 
-	reg = REG_READ(REG_PORT(port), 0);
-	e->eee_active = !!(reg & 0x0040);
-
-	return 0;
-}
-
-static int mv88e6xxx_eee_enable_set(struct dsa_switch *ds, int port,
-				    bool eee_enabled, bool tx_lpi_enabled)
-{
-	int reg, nreg;
-
-	reg = _mv88e6xxx_phy_read_indirect(ds, port, 16);
+	reg = mv88e6xxx_reg_read(ds, REG_PORT(port), 0);
 	if (reg < 0)
-		return reg;
-
-	nreg = reg & ~0x0300;
-	if (eee_enabled)
-		nreg |= 0x0200;
-	if (tx_lpi_enabled)
-		nreg |= 0x0100;
+		goto out;
 
-	if (nreg != reg)
-		return _mv88e6xxx_phy_write_indirect(ds, port, 16, nreg);
+	e->eee_active = !!(reg & 0x0040);
+	reg = 0;
 
-	return 0;
+out:
+	mutex_unlock(&ps->phy_mutex);
+	return reg;
 }
 
 int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 		      struct phy_device *phydev, struct ethtool_eee *e)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int reg;
 	int ret;
 
-	ret = mv88e6xxx_eee_enable_set(ds, port, e->eee_enabled,
-				       e->tx_lpi_enabled);
-	if (ret)
-		return -EOPNOTSUPP;
+	mutex_lock(&ps->phy_mutex);
 
-	return 0;
+	ret = _mv88e6xxx_phy_read_indirect(ds, port, 16);
+	if (ret < 0)
+		goto out;
+
+	reg = ret & ~0x0300;
+	if (e->eee_enabled)
+		reg |= 0x0200;
+	if (e->tx_lpi_enabled)
+		reg |= 0x0100;
+
+	ret = _mv88e6xxx_phy_write_indirect(ds, port, 16, reg);
+out:
+	mutex_unlock(&ps->phy_mutex);
+
+	return ret;
 }
 
 static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, int fid, u16 cmd)
-- 
2.1.4
