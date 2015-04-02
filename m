From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 08/12] net: dsa: Consolidate phy read and write functions
Date: Thu,  2 Apr 2015 04:06:36 +0200
Message-ID: <1427940400-12434-9-git-send-email-andrew@lunn.ch>
References: <1427940400-12434-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35806 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752984AbbDBCKy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 22:10:54 -0400
In-Reply-To: <1427940400-12434-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the common code for reading and writing phy registers into the
shared mv88e6xxx.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Guenter Roeck <linux@roeck-us.net>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6123_61_65.c |  46 +--------------
 drivers/net/dsa/mv88e6171.c       |  40 +------------
 drivers/net/dsa/mv88e6352.c       |  45 +--------------
 drivers/net/dsa/mv88e6xxx.c       | 118 ++++++++++++++++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx.h       |   7 ++-
 5 files changed, 110 insertions(+), 146 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 10228ad48151..5f536722f7c7 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -277,48 +277,6 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6123_61_65_port_to_phy_addr(struct dsa_switch *ds, int port)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
-	if (port >= 0 && port < ps->num_ports)
-		return port;
-	return -EINVAL;
-}
-
-static int
-mv88e6123_61_65_phy_read(struct dsa_switch *ds, int port, int regnum)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6123_61_65_port_to_phy_addr(ds, port);
-	int ret;
-
-	if (addr < 0)
-		return addr;
-
-	mutex_lock(&ps->phy_mutex);
-	ret = mv88e6xxx_phy_read(ds, addr, regnum);
-	mutex_unlock(&ps->phy_mutex);
-	return ret;
-}
-
-static int
-mv88e6123_61_65_phy_write(struct dsa_switch *ds,
-			      int port, int regnum, u16 val)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6123_61_65_port_to_phy_addr(ds, port);
-	int ret;
-
-	if (addr < 0)
-		return addr;
-
-	mutex_lock(&ps->phy_mutex);
-	ret = mv88e6xxx_phy_write(ds, addr, regnum, val);
-	mutex_unlock(&ps->phy_mutex);
-	return ret;
-}
-
 static struct mv88e6xxx_hw_stat mv88e6123_61_65_hw_stats[] = {
 	{ "in_good_octets", 8, 0x00, },
 	{ "in_bad_octets", 4, 0x02, },
@@ -381,8 +339,8 @@ struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.probe			= mv88e6123_61_65_probe,
 	.setup			= mv88e6123_61_65_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
-	.phy_read		= mv88e6123_61_65_phy_read,
-	.phy_write		= mv88e6123_61_65_phy_write,
+	.phy_read		= mv88e6xxx_phy_read,
+	.phy_write		= mv88e6xxx_phy_write,
 	.poll_link		= mv88e6xxx_poll_link,
 	.get_strings		= mv88e6123_61_65_get_strings,
 	.get_ethtool_stats	= mv88e6123_61_65_get_ethtool_stats,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 69b35d124de5..4d6038991a59 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -258,42 +258,6 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6171_port_to_phy_addr(struct dsa_switch *ds, int port)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
-	if (port >= 0 && port < ps->num_ports)
-		return port;
-	return -1;
-}
-
-static int
-mv88e6171_phy_read(struct dsa_switch *ds, int port, int regnum)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6171_port_to_phy_addr(ds, port);
-	int ret;
-
-	mutex_lock(&ps->phy_mutex);
-	ret = mv88e6xxx_phy_read_indirect(ds, addr, regnum);
-	mutex_unlock(&ps->phy_mutex);
-	return ret;
-}
-
-static int
-mv88e6171_phy_write(struct dsa_switch *ds,
-		    int port, int regnum, u16 val)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6171_port_to_phy_addr(ds, port);
-	int ret;
-
-	mutex_lock(&ps->phy_mutex);
-	ret = mv88e6xxx_phy_write_indirect(ds, addr, regnum, val);
-	mutex_unlock(&ps->phy_mutex);
-	return ret;
-}
-
 static struct mv88e6xxx_hw_stat mv88e6171_hw_stats[] = {
 	{ "in_good_octets", 8, 0x00, },
 	{ "in_bad_octets", 4, 0x02, },
@@ -375,8 +339,8 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 	.probe			= mv88e6171_probe,
 	.setup			= mv88e6171_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
-	.phy_read		= mv88e6171_phy_read,
-	.phy_write		= mv88e6171_phy_write,
+	.phy_read		= mv88e6xxx_phy_read_indirect,
+	.phy_write		= mv88e6xxx_phy_write_indirect,
 	.poll_link		= mv88e6xxx_poll_link,
 	.get_strings		= mv88e6171_get_strings,
 	.get_ethtool_stats	= mv88e6171_get_ethtool_stats,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index fb16671c5f92..3806ff1aaa9c 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -321,47 +321,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6352_port_to_phy_addr(int port)
-{
-	if (port >= 0 && port <= 4)
-		return port;
-	return -EINVAL;
-}
-
-static int
-mv88e6352_phy_read(struct dsa_switch *ds, int port, int regnum)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6352_port_to_phy_addr(port);
-	int ret;
-
-	if (addr < 0)
-		return addr;
-
-	mutex_lock(&ps->phy_mutex);
-	ret = mv88e6xxx_phy_read_indirect(ds, addr, regnum);
-	mutex_unlock(&ps->phy_mutex);
-
-	return ret;
-}
-
-static int
-mv88e6352_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6352_port_to_phy_addr(port);
-	int ret;
-
-	if (addr < 0)
-		return addr;
-
-	mutex_lock(&ps->phy_mutex);
-	ret = mv88e6xxx_phy_write_indirect(ds, addr, regnum, val);
-	mutex_unlock(&ps->phy_mutex);
-
-	return ret;
-}
-
 static struct mv88e6xxx_hw_stat mv88e6352_hw_stats[] = {
 	{ "in_good_octets", 8, 0x00, },
 	{ "in_bad_octets", 4, 0x02, },
@@ -621,8 +580,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.probe			= mv88e6352_probe,
 	.setup			= mv88e6352_setup,
 	.set_addr		= mv88e6xxx_set_addr_indirect,
-	.phy_read		= mv88e6352_phy_read,
-	.phy_write		= mv88e6352_phy_write,
+	.phy_read		= mv88e6xxx_phy_read_indirect,
+	.phy_write		= mv88e6xxx_phy_write_indirect,
 	.poll_link		= mv88e6xxx_poll_link,
 	.get_strings		= mv88e6352_get_strings,
 	.get_ethtool_stats	= mv88e6352_get_ethtool_stats,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index df727e1db18d..7c4c04bb0cb0 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -214,14 +214,17 @@ int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 	return 0;
 }
 
-int mv88e6xxx_phy_read(struct dsa_switch *ds, int addr, int regnum)
+/* Must be called with phy mutex held */
+static int _mv88e6xxx_phy_read(struct dsa_switch *ds, int addr, int regnum)
 {
 	if (addr >= 0)
 		return mv88e6xxx_reg_read(ds, addr, regnum);
 	return 0xffff;
 }
 
-int mv88e6xxx_phy_write(struct dsa_switch *ds, int addr, int regnum, u16 val)
+/* Must be called with phy mutex held */
+static int _mv88e6xxx_phy_write(struct dsa_switch *ds, int addr, int regnum,
+				u16 val)
 {
 	if (addr >= 0)
 		return mv88e6xxx_reg_write(ds, addr, regnum, val);
@@ -579,37 +582,37 @@ int  mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 
 	mutex_lock(&ps->phy_mutex);
 
-	ret = mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x6);
+	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x6);
 	if (ret < 0)
 		goto error;
 
 	/* Enable temperature sensor */
-	ret = mv88e6xxx_phy_read(ds, 0x0, 0x1a);
+	ret = _mv88e6xxx_phy_read(ds, 0x0, 0x1a);
 	if (ret < 0)
 		goto error;
 
-	ret = mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret | (1 << 5));
+	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret | (1 << 5));
 	if (ret < 0)
 		goto error;
 
 	/* Wait for temperature to stabilize */
 	usleep_range(10000, 12000);
 
-	val = mv88e6xxx_phy_read(ds, 0x0, 0x1a);
+	val = _mv88e6xxx_phy_read(ds, 0x0, 0x1a);
 	if (val < 0) {
 		ret = val;
 		goto error;
 	}
 
 	/* Disable temperature sensor */
-	ret = mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret & ~(1 << 5));
+	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret & ~(1 << 5));
 	if (ret < 0)
 		goto error;
 
 	*temp = ((val & 0x1f) - 5) * 5;
 
 error:
-	mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x0);
+	_mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x0);
 	mutex_unlock(&ps->phy_mutex);
 	return ret;
 }
@@ -671,7 +674,9 @@ static int _mv88e6xxx_atu_wait(struct dsa_switch *ds)
 	return _mv88e6xxx_wait(ds, REG_GLOBAL, 0x0b, ATU_BUSY);
 }
 
-int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr, int regnum)
+/* Must be called with phy mutex held */
+static int _mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr,
+					int regnum)
 {
 	int ret;
 
@@ -684,8 +689,9 @@ int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr, int regnum)
 	return REG_READ(REG_GLOBAL2, 0x19);
 }
 
-int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr, int regnum,
-				 u16 val)
+/* Must be called with phy mutex held */
+static int _mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr,
+					 int regnum, u16 val)
 {
 	REG_WRITE(REG_GLOBAL2, 0x19, val);
 	REG_WRITE(REG_GLOBAL2, 0x18, 0x9400 | (addr << 5) | regnum);
@@ -715,7 +721,7 @@ static int mv88e6xxx_eee_enable_set(struct dsa_switch *ds, int port,
 {
 	int reg, nreg;
 
-	reg = mv88e6xxx_phy_read_indirect(ds, port, 16);
+	reg = _mv88e6xxx_phy_read_indirect(ds, port, 16);
 	if (reg < 0)
 		return reg;
 
@@ -726,7 +732,7 @@ static int mv88e6xxx_eee_enable_set(struct dsa_switch *ds, int port,
 		nreg |= 0x0100;
 
 	if (nreg != reg)
-		return mv88e6xxx_phy_write_indirect(ds, port, 16, nreg);
+		return _mv88e6xxx_phy_write_indirect(ds, port, 16, nreg);
 
 	return 0;
 }
@@ -1207,12 +1213,12 @@ int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
 	int ret;
 
 	mutex_lock(&ps->phy_mutex);
-	ret = mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
+	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
 	if (ret < 0)
 		goto error;
-	ret = mv88e6xxx_phy_read_indirect(ds, port, reg);
+	ret = _mv88e6xxx_phy_read_indirect(ds, port, reg);
 error:
-	mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
+	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
 	mutex_unlock(&ps->phy_mutex);
 	return ret;
 }
@@ -1224,13 +1230,87 @@ int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 	int ret;
 
 	mutex_lock(&ps->phy_mutex);
-	ret = mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
+	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
 	if (ret < 0)
 		goto error;
 
-	ret = mv88e6xxx_phy_write_indirect(ds, port, reg, val);
+	ret = _mv88e6xxx_phy_write_indirect(ds, port, reg, val);
 error:
-	mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
+	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
+}
+
+static int mv88e6xxx_port_to_phy_addr(struct dsa_switch *ds, int port)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (port >= 0 && port < ps->num_ports)
+		return port;
+	return -EINVAL;
+}
+
+int
+mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int addr = mv88e6xxx_port_to_phy_addr(ds, port);
+	int ret;
+
+	if (addr < 0)
+		return addr;
+
+	mutex_lock(&ps->phy_mutex);
+	ret = _mv88e6xxx_phy_read(ds, addr, regnum);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
+}
+
+int
+mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int addr = mv88e6xxx_port_to_phy_addr(ds, port);
+	int ret;
+
+	if (addr < 0)
+		return addr;
+
+	mutex_lock(&ps->phy_mutex);
+	ret = _mv88e6xxx_phy_write(ds, addr, regnum, val);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
+}
+
+int
+mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int addr = mv88e6xxx_port_to_phy_addr(ds, port);
+	int ret;
+
+	if (addr < 0)
+		return addr;
+
+	mutex_lock(&ps->phy_mutex);
+	ret = _mv88e6xxx_phy_read_indirect(ds, addr, regnum);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
+}
+
+int
+mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
+			     u16 val)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int addr = mv88e6xxx_port_to_phy_addr(ds, port);
+	int ret;
+
+	if (addr < 0)
+		return addr;
+
+	mutex_lock(&ps->phy_mutex);
+	ret = _mv88e6xxx_phy_write_indirect(ds, addr, regnum, val);
 	mutex_unlock(&ps->phy_mutex);
 	return ret;
 }
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 49614765760f..44b0ec79cc6b 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -140,8 +140,11 @@ int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val);
 int mv88e6xxx_config_prio(struct dsa_switch *ds);
 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr);
 int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr);
-int mv88e6xxx_phy_read(struct dsa_switch *ds, int addr, int regnum);
-int mv88e6xxx_phy_write(struct dsa_switch *ds, int addr, int regnum, u16 val);
+int mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum);
+int mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val);
+int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum);
+int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
+				 u16 val);
 void mv88e6xxx_ppu_state_init(struct dsa_switch *ds);
 int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum);
 int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
-- 
2.1.4
