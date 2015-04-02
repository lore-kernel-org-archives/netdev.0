From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 06/12] net: dsa: Centralize Marvell switch reset
Date: Thu,  2 Apr 2015 04:06:34 +0200
Message-ID: <1427940400-12434-7-git-send-email-andrew@lunn.ch>
References: <1427940400-12434-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35821 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753050AbbDBCLS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 22:11:18 -0400
In-Reply-To: <1427940400-12434-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marvell switches are all reset in nearly the same way. The only
difference is if the PPU should be enabled or not. Move this
code into the shared mv88x6xxx.c.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Guenter Roeck <linux@roeck-us.net>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6123_61_65.c | 36 +----------------------------
 drivers/net/dsa/mv88e6131.c       | 36 +----------------------------
 drivers/net/dsa/mv88e6171.c       | 48 +--------------------------------------
 drivers/net/dsa/mv88e6352.c       | 38 +------------------------------
 drivers/net/dsa/mv88e6xxx.c       | 40 ++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h       |  1 +
 6 files changed, 45 insertions(+), 154 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 6480f77829ef..10228ad48151 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -52,40 +52,6 @@ static char *mv88e6123_61_65_probe(struct device *host_dev, int sw_addr)
 	return NULL;
 }
 
-static int mv88e6123_61_65_switch_reset(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int i;
-	int ret;
-	unsigned long timeout;
-
-	/* Set all ports to the disabled state. */
-	for (i = 0; i < ps->num_ports; i++) {
-		ret = REG_READ(REG_PORT(i), 0x04);
-		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
-	}
-
-	/* Wait for transmit queues to drain. */
-	usleep_range(2000, 4000);
-
-	/* Reset the switch. */
-	REG_WRITE(REG_GLOBAL, 0x04, 0xc400);
-
-	/* Wait up to one second for reset to complete. */
-	timeout = jiffies + 1 * HZ;
-	while (time_before(jiffies, timeout)) {
-		ret = REG_READ(REG_GLOBAL, 0x00);
-		if ((ret & 0xc800) == 0xc800)
-			break;
-
-		usleep_range(1000, 2000);
-	}
-	if (time_after(jiffies, timeout))
-		return -ETIMEDOUT;
-
-	return 0;
-}
-
 static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 {
 	int ret;
@@ -292,7 +258,7 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 		return -ENODEV;
 	}
 
-	ret = mv88e6123_61_65_switch_reset(ds);
+	ret = mv88e6xxx_switch_reset(ds, false);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 6b818fde2216..534a8f0b1c28 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -42,40 +42,6 @@ static char *mv88e6131_probe(struct device *host_dev, int sw_addr)
 	return NULL;
 }
 
-static int mv88e6131_switch_reset(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int i;
-	int ret;
-	unsigned long timeout;
-
-	/* Set all ports to the disabled state. */
-	for (i = 0; i < ps->num_ports; i++) {
-		ret = REG_READ(REG_PORT(i), 0x04);
-		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
-	}
-
-	/* Wait for transmit queues to drain. */
-	usleep_range(2000, 4000);
-
-	/* Reset the switch. */
-	REG_WRITE(REG_GLOBAL, 0x04, 0xc400);
-
-	/* Wait up to one second for reset to complete. */
-	timeout = jiffies + 1 * HZ;
-	while (time_before(jiffies, timeout)) {
-		ret = REG_READ(REG_GLOBAL, 0x00);
-		if ((ret & 0xc800) == 0xc800)
-			break;
-
-		usleep_range(1000, 2000);
-	}
-	if (time_after(jiffies, timeout))
-		return -ETIMEDOUT;
-
-	return 0;
-}
-
 static int mv88e6131_setup_global(struct dsa_switch *ds)
 {
 	int ret;
@@ -281,7 +247,7 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 		return -ENODEV;
 	}
 
-	ret = mv88e6131_switch_reset(ds);
+	ret = mv88e6xxx_switch_reset(ds, false);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 5a295533ff20..69b35d124de5 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -36,52 +36,6 @@ static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
 	return NULL;
 }
 
-static int mv88e6171_switch_reset(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int i;
-	int ret;
-	unsigned long timeout;
-
-	/* Set all ports to the disabled state. */
-	for (i = 0; i < ps->num_ports; i++) {
-		ret = REG_READ(REG_PORT(i), 0x04);
-		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
-	}
-
-	/* Wait for transmit queues to drain. */
-	usleep_range(2000, 4000);
-
-	/* Reset the switch. Keep PPU active.  The PPU needs to be
-	 * active to support indirect phy register accesses through
-	 * global registers 0x18 and 0x19.
-	 */
-	REG_WRITE(REG_GLOBAL, 0x04, 0xc000);
-
-	/* Wait up to one second for reset to complete. */
-	timeout = jiffies + 1 * HZ;
-	while (time_before(jiffies, timeout)) {
-		ret = REG_READ(REG_GLOBAL, 0x00);
-		if ((ret & 0xc800) == 0xc800)
-			break;
-
-		usleep_range(1000, 2000);
-	}
-	if (time_after(jiffies, timeout))
-		return -ETIMEDOUT;
-
-	/* Enable ports not under DSA, e.g. WAN port */
-	for (i = 0; i < ps->num_ports; i++) {
-		if (dsa_is_cpu_port(ds, i) || ds->phys_port_mask & (1 << i))
-			continue;
-
-		ret = REG_READ(REG_PORT(i), 0x04);
-		REG_WRITE(REG_PORT(i), 0x04, ret | 0x03);
-	}
-
-	return 0;
-}
-
 static int mv88e6171_setup_global(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -282,7 +236,7 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 
 	ps->num_ports = 7;
 
-	ret = mv88e6171_switch_reset(ds);
+	ret = mv88e6xxx_switch_reset(ds, true);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 040027fcd013..214bdbc8a5b1 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -45,42 +45,6 @@ static char *mv88e6352_probe(struct device *host_dev, int sw_addr)
 	return NULL;
 }
 
-static int mv88e6352_switch_reset(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	unsigned long timeout;
-	int ret;
-	int i;
-
-	/* Set all ports to the disabled state. */
-	for (i = 0; i < ps->num_ports; i++) {
-		ret = REG_READ(REG_PORT(i), 0x04);
-		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
-	}
-
-	/* Wait for transmit queues to drain. */
-	usleep_range(2000, 4000);
-
-	/* Reset the switch. Keep PPU active (bit 14, undocumented).
-	 * The PPU needs to be active to support indirect phy register
-	 * accesses through global registers 0x18 and 0x19.
-	 */
-	REG_WRITE(REG_GLOBAL, 0x04, 0xc000);
-
-	/* Wait up to one second for reset to complete. */
-	timeout = jiffies + 1 * HZ;
-	while (time_before(jiffies, timeout)) {
-		ret = REG_READ(REG_GLOBAL, 0x00);
-		if ((ret & 0x8800) == 0x8800)
-			break;
-		usleep_range(1000, 2000);
-	}
-	if (time_after(jiffies, timeout))
-		return -ETIMEDOUT;
-
-	return 0;
-}
-
 static int mv88e6352_setup_global(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -373,7 +337,7 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 
 	mutex_init(&ps->eeprom_mutex);
 
-	ret = mv88e6352_switch_reset(ds);
+	ret = mv88e6xxx_switch_reset(ds, true);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 13572cc24c6d..9db5b40d78ea 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1161,6 +1161,46 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	return 0;
 }
 
+int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
+	unsigned long timeout;
+	int ret;
+	int i;
+
+	/* Set all ports to the disabled state. */
+	for (i = 0; i < ps->num_ports; i++) {
+		ret = REG_READ(REG_PORT(i), 0x04);
+		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
+	}
+
+	/* Wait for transmit queues to drain. */
+	usleep_range(2000, 4000);
+
+	/* Reset the switch. Keep the PPU active if requested. The PPU
+	 * needs to be active to support indirect phy register access
+	 * through global registers 0x18 and 0x19.
+	 */
+	if (ppu_active)
+		REG_WRITE(REG_GLOBAL, 0x04, 0xc000);
+	else
+		REG_WRITE(REG_GLOBAL, 0x04, 0xc400);
+
+	/* Wait up to one second for reset to complete. */
+	timeout = jiffies + 1 * HZ;
+	while (time_before(jiffies, timeout)) {
+		ret = REG_READ(REG_GLOBAL, 0x00);
+		if ((ret & is_reset) == is_reset)
+			break;
+		usleep_range(1000, 2000);
+	}
+	if (time_after(jiffies, timeout))
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
 static int __init mv88e6xxx_init(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index ef058444bdb7..f84d3d5178b9 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -129,6 +129,7 @@ struct mv88e6xxx_hw_stat {
 	int reg;
 };
 
+int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
 int mv88e6xxx_setup_port_common(struct dsa_switch *ds, int port);
 int mv88e6xxx_setup_common(struct dsa_switch *ds);
 int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg);
-- 
2.1.4
