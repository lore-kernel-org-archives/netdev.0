From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 6/8] dsa: mv88e6xxx: Replace ds with ps where possible
Date: Thu, 14 Apr 2016 01:59:56 +0200
Message-ID: <1460591998-20598-7-git-send-email-andrew@lunn.ch>
References: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55188 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754185AbcDNABa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2016 20:01:30 -0400
In-Reply-To: <1460591998-20598-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dsa_switch structure ds is actually needed in very few places,
mostly during setup of the switch. The private structure ps is however
needed nearly everywhere. Pass ps, not ds internally.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6123.c |  11 +-
 drivers/net/dsa/mv88e6131.c |  19 +-
 drivers/net/dsa/mv88e6171.c |  11 +-
 drivers/net/dsa/mv88e6352.c |  22 +-
 drivers/net/dsa/mv88e6xxx.c | 938 ++++++++++++++++++++++----------------------
 drivers/net/dsa/mv88e6xxx.h |  14 +-
 6 files changed, 510 insertions(+), 505 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 450dad5af568..b4dd7ef039da 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -42,6 +42,7 @@ static char *mv88e6123_drv_probe(struct device *dsa_dev,
 
 static int mv88e6123_setup_global(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	u32 upstream_port = dsa_upstream_port(ds);
 	int ret;
 	u32 reg;
@@ -54,7 +55,7 @@ static int mv88e6123_setup_global(struct dsa_switch *ds)
 	 * external PHYs to poll), don't discard packets with
 	 * excessive collisions, and mask all interrupt sources.
 	 */
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CONTROL, 0x0000);
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL, 0x0000);
 	if (ret)
 		return ret;
 
@@ -65,14 +66,14 @@ static int mv88e6123_setup_global(struct dsa_switch *ds)
 	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
 		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
 		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
 	if (ret)
 		return ret;
 
 	/* Disable remote management for now, and set the switch's
 	 * DSA device number.
 	 */
-	return mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CONTROL_2,
+	return mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
 				   ds->index & 0x1f);
 }
 
@@ -83,7 +84,7 @@ static int mv88e6123_setup(struct dsa_switch *ds)
 
 	ps->ds = ds;
 
-	ret = mv88e6xxx_setup_common(ds);
+	ret = mv88e6xxx_setup_common(ps);
 	if (ret < 0)
 		return ret;
 
@@ -99,7 +100,7 @@ static int mv88e6123_setup(struct dsa_switch *ds)
 		return -ENODEV;
 	}
 
-	ret = mv88e6xxx_switch_reset(ds, false);
+	ret = mv88e6xxx_switch_reset(ps, false);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index e1e2410a660c..1659d4dc93c0 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -38,6 +38,7 @@ static char *mv88e6131_drv_probe(struct device *dsa_dev,
 
 static int mv88e6131_setup_global(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	u32 upstream_port = dsa_upstream_port(ds);
 	int ret;
 	u32 reg;
@@ -51,14 +52,14 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	 * to arbitrate between packet queues, set the maximum frame
 	 * size to 1632, and mask all interrupt sources.
 	 */
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CONTROL,
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL,
 				  GLOBAL_CONTROL_PPU_ENABLE |
 				  GLOBAL_CONTROL_MAX_FRAME_1632);
 	if (ret)
 		return ret;
 
 	/* Set the VLAN ethertype to 0x8100. */
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CORE_TAG_TYPE, 0x8100);
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CORE_TAG_TYPE, 0x8100);
 	if (ret)
 		return ret;
 
@@ -69,7 +70,7 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
 		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
 		GLOBAL_MONITOR_CONTROL_ARP_DISABLED;
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
 	if (ret)
 		return ret;
 
@@ -78,11 +79,11 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	 * DSA device number.
 	 */
 	if (ds->dst->pd->nr_chips > 1)
-		ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CONTROL_2,
+		ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
 					  GLOBAL_CONTROL_2_MULTIPLE_CASCADE |
 					  (ds->index & 0x1f));
 	else
-		ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CONTROL_2,
+		ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
 					  GLOBAL_CONTROL_2_NO_CASCADE |
 					  (ds->index & 0x1f));
 	if (ret)
@@ -91,7 +92,7 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	/* Force the priority of IGMP/MLD snoop frames and ARP frames
 	 * to the highest setting.
 	 */
-	return mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_PRIO_OVERRIDE,
+	return mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_PRIO_OVERRIDE,
 				   GLOBAL2_PRIO_OVERRIDE_FORCE_SNOOP |
 				   7 << GLOBAL2_PRIO_OVERRIDE_SNOOP_SHIFT |
 				   GLOBAL2_PRIO_OVERRIDE_FORCE_ARP |
@@ -105,11 +106,11 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 
 	ps->ds = ds;
 
-	ret = mv88e6xxx_setup_common(ds);
+	ret = mv88e6xxx_setup_common(ps);
 	if (ret < 0)
 		return ret;
 
-	mv88e6xxx_ppu_state_init(ds);
+	mv88e6xxx_ppu_state_init(ps);
 
 	switch (ps->id) {
 	case PORT_SWITCH_ID_6085:
@@ -127,7 +128,7 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 		return -ENODEV;
 	}
 
-	ret = mv88e6xxx_switch_reset(ds, false);
+	ret = mv88e6xxx_switch_reset(ps, false);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index e3998be13515..0b934b3008ca 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -37,6 +37,7 @@ static char *mv88e6171_drv_probe(struct device *dsa_dev,
 
 static int mv88e6171_setup_global(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	u32 upstream_port = dsa_upstream_port(ds);
 	int ret;
 	u32 reg;
@@ -48,7 +49,7 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 	/* Discard packets with excessive collisions, mask all
 	 * interrupt sources, enable PPU.
 	 */
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CONTROL,
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL,
 				  GLOBAL_CONTROL_PPU_ENABLE |
 				  GLOBAL_CONTROL_DISCARD_EXCESS);
 	if (ret)
@@ -62,14 +63,14 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
 		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT |
 		upstream_port << GLOBAL_MONITOR_CONTROL_MIRROR_SHIFT;
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
 	if (ret)
 		return ret;
 
 	/* Disable remote management for now, and set the switch's
 	 * DSA device number.
 	 */
-	return mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CONTROL_2,
+	return mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
 				   ds->index & 0x1f);
 }
 
@@ -80,13 +81,13 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 
 	ps->ds = ds;
 
-	ret = mv88e6xxx_setup_common(ds);
+	ret = mv88e6xxx_setup_common(ps);
 	if (ret < 0)
 		return ret;
 
 	ps->num_ports = 7;
 
-	ret = mv88e6xxx_switch_reset(ds, true);
+	ret = mv88e6xxx_switch_reset(ps, true);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index baeb594b63cc..b745a1f36a1f 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -49,6 +49,7 @@ static char *mv88e6352_drv_probe(struct device *dsa_dev,
 
 static int mv88e6352_setup_global(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	u32 upstream_port = dsa_upstream_port(ds);
 	int ret;
 	u32 reg;
@@ -60,7 +61,7 @@ static int mv88e6352_setup_global(struct dsa_switch *ds)
 	/* Discard packets with excessive collisions,
 	 * mask all interrupt sources, enable PPU (bit 14, undocumented).
 	 */
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CONTROL,
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL,
 				  GLOBAL_CONTROL_PPU_ENABLE |
 				  GLOBAL_CONTROL_DISCARD_EXCESS);
 	if (ret)
@@ -73,14 +74,14 @@ static int mv88e6352_setup_global(struct dsa_switch *ds)
 	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
 		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
 		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
 	if (ret)
 		return ret;
 
 	/* Disable remote management for now, and set the switch's
 	 * DSA device number.
 	 */
-	return mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x1c, ds->index & 0x1f);
+	return mv88e6xxx_reg_write(ps, REG_GLOBAL, 0x1c, ds->index & 0x1f);
 }
 
 static int mv88e6352_setup(struct dsa_switch *ds)
@@ -90,7 +91,7 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 
 	ps->ds = ds;
 
-	ret = mv88e6xxx_setup_common(ds);
+	ret = mv88e6xxx_setup_common(ps);
 	if (ret < 0)
 		return ret;
 
@@ -98,7 +99,7 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 
 	mutex_init(&ps->eeprom_mutex);
 
-	ret = mv88e6xxx_switch_reset(ds, true);
+	ret = mv88e6xxx_switch_reset(ps, true);
 	if (ret < 0)
 		return ret;
 
@@ -116,7 +117,7 @@ static int mv88e6352_read_eeprom_word(struct dsa_switch *ds, int addr)
 
 	mutex_lock(&ps->eeprom_mutex);
 
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
 				  GLOBAL2_EEPROM_OP_READ |
 				  (addr & GLOBAL2_EEPROM_OP_ADDR_MASK));
 	if (ret < 0)
@@ -126,7 +127,7 @@ static int mv88e6352_read_eeprom_word(struct dsa_switch *ds, int addr)
 	if (ret < 0)
 		goto error;
 
-	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL2, GLOBAL2_EEPROM_DATA);
+	ret = mv88e6xxx_reg_read(ps, REG_GLOBAL2, GLOBAL2_EEPROM_DATA);
 error:
 	mutex_unlock(&ps->eeprom_mutex);
 	return ret;
@@ -197,9 +198,10 @@ static int mv88e6352_get_eeprom(struct dsa_switch *ds,
 
 static int mv88e6352_eeprom_is_readonly(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP);
+	ret = mv88e6xxx_reg_read(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP);
 	if (ret < 0)
 		return ret;
 
@@ -217,11 +219,11 @@ static int mv88e6352_write_eeprom_word(struct dsa_switch *ds, int addr,
 
 	mutex_lock(&ps->eeprom_mutex);
 
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_EEPROM_DATA, data);
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_EEPROM_DATA, data);
 	if (ret < 0)
 		goto error;
 
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
 				  GLOBAL2_EEPROM_OP_WRITE |
 				  (addr & GLOBAL2_EEPROM_OP_ADDR_MASK));
 	if (ret < 0)
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 93110460e0c3..b8db7ed12005 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -25,12 +25,10 @@
 #include <net/switchdev.h>
 #include "mv88e6xxx.h"
 
-static void assert_smi_lock(struct dsa_switch *ds)
+static void assert_smi_lock(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	if (unlikely(!mutex_is_locked(&ps->smi_mutex))) {
-		dev_err(ds->master_dev, "SMI lock not held!\n");
+		dev_err(ps->dev, "SMI lock not held!\n");
 		dump_stack();
 	}
 }
@@ -92,30 +90,29 @@ static int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr,
 	return ret & 0xffff;
 }
 
-static int _mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
+static int _mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps,
+			       int addr, int reg)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	assert_smi_lock(ds);
+	assert_smi_lock(ps);
 
 	ret = __mv88e6xxx_reg_read(ps->bus, ps->sw_addr, addr, reg);
 	if (ret < 0)
 		return ret;
 
-	dev_dbg(ds->master_dev, "<- addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
+	dev_dbg(ps->dev, "<- addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
 		addr, reg, ret);
 
 	return ret;
 }
 
-int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
+int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr, int reg)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_reg_read(ds, addr, reg);
+	ret = _mv88e6xxx_reg_read(ps, addr, reg);
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
@@ -154,26 +151,24 @@ static int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 	return 0;
 }
 
-static int _mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg,
-				u16 val)
+static int _mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
+				int reg, u16 val)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	assert_smi_lock(ps);
 
-	assert_smi_lock(ds);
-
-	dev_dbg(ds->master_dev, "-> addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
+	dev_dbg(ps->dev, "-> addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
 		addr, reg, val);
 
 	return __mv88e6xxx_reg_write(ps->bus, ps->sw_addr, addr, reg, val);
 }
 
-int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
+int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
+			int reg, u16 val)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_reg_write(ds, addr, reg, val);
+	ret = _mv88e6xxx_reg_write(ps, addr, reg, val);
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
@@ -182,25 +177,27 @@ EXPORT_SYMBOL_GPL(mv88e6xxx_reg_write);
 
 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int err;
 
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_MAC_01,
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MAC_01,
 				  (addr[0] << 8) | addr[1]);
 	if (err)
 		return err;
 
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_MAC_23,
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MAC_23,
 				  (addr[2] << 8) | addr[3]);
 	if (err)
 		return err;
 
-	return mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_MAC_45,
+	return mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_MAC_45,
 				   (addr[4] << 8) | addr[5]);
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_set_addr_direct);
 
 int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret, err;
 	int i;
 
@@ -208,7 +205,7 @@ int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 		int j;
 
 		/* Write the MAC address byte. */
-		err = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_SWITCH_MAC,
+		err = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_SWITCH_MAC,
 					  GLOBAL2_SWITCH_MAC_BUSY |
 					  (i << 8) | addr[i]);
 		if (err)
@@ -216,13 +213,11 @@ int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 
 		/* Wait for the write to complete. */
 		for (j = 0; j < 16; j++) {
-			ret = mv88e6xxx_reg_read(ds, REG_GLOBAL2,
+			ret = mv88e6xxx_reg_read(ps, REG_GLOBAL2,
 						 GLOBAL2_SWITCH_MAC);
 			if (ret < 0)
 				return ret;
 
-			if (ret < 0)
-				return ret;
 			if ((ret & GLOBAL2_SWITCH_MAC_BUSY) == 0)
 				break;
 		}
@@ -234,39 +229,40 @@ int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_set_addr_indirect);
 
-static int _mv88e6xxx_phy_read(struct dsa_switch *ds, int addr, int regnum)
+static int _mv88e6xxx_phy_read(struct mv88e6xxx_priv_state *ps, int addr,
+			       int regnum)
 {
 	if (addr >= 0)
-		return _mv88e6xxx_reg_read(ds, addr, regnum);
+		return _mv88e6xxx_reg_read(ps, addr, regnum);
 	return 0xffff;
 }
 
-static int _mv88e6xxx_phy_write(struct dsa_switch *ds, int addr, int regnum,
-				u16 val)
+static int _mv88e6xxx_phy_write(struct mv88e6xxx_priv_state *ps, int addr,
+				int regnum, u16 val)
 {
 	if (addr >= 0)
-		return _mv88e6xxx_reg_write(ds, addr, regnum, val);
+		return _mv88e6xxx_reg_write(ps, addr, regnum, val);
 	return 0;
 }
 
 #ifdef CONFIG_NET_DSA_MV88E6XXX_NEED_PPU
-static int mv88e6xxx_ppu_disable(struct dsa_switch *ds)
+static int mv88e6xxx_ppu_disable(struct mv88e6xxx_priv_state *ps)
 {
 	int ret;
 	unsigned long timeout;
 
-	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_CONTROL);
+	ret = mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_CONTROL);
 	if (ret < 0)
 		return ret;
 
-	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CONTROL,
+	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL,
 				  ret & ~GLOBAL_CONTROL_PPU_ENABLE);
 	if (ret)
 		return ret;
 
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-		ret = mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATUS);
+		ret = mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATUS);
 		if (ret < 0)
 			return ret;
 
@@ -279,23 +275,23 @@ static int mv88e6xxx_ppu_disable(struct dsa_switch *ds)
 	return -ETIMEDOUT;
 }
 
-static int mv88e6xxx_ppu_enable(struct dsa_switch *ds)
+static int mv88e6xxx_ppu_enable(struct mv88e6xxx_priv_state *ps)
 {
 	int ret, err;
 	unsigned long timeout;
 
-	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_CONTROL);
+	ret = mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_CONTROL);
 	if (ret < 0)
 		return ret;
 
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_CONTROL,
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL,
 				  ret | GLOBAL_CONTROL_PPU_ENABLE);
 	if (err)
 		return err;
 
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-		ret = mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATUS);
+		ret = mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATUS);
 		if (ret < 0)
 			return ret;
 
@@ -314,9 +310,7 @@ static void mv88e6xxx_ppu_reenable_work(struct work_struct *ugly)
 
 	ps = container_of(ugly, struct mv88e6xxx_priv_state, ppu_work);
 	if (mutex_trylock(&ps->ppu_mutex)) {
-		struct dsa_switch *ds = ps->ds;
-
-		if (mv88e6xxx_ppu_enable(ds) == 0)
+		if (mv88e6xxx_ppu_enable(ps) == 0)
 			ps->ppu_disabled = 0;
 		mutex_unlock(&ps->ppu_mutex);
 	}
@@ -329,9 +323,8 @@ static void mv88e6xxx_ppu_reenable_timer(unsigned long _ps)
 	schedule_work(&ps->ppu_work);
 }
 
-static int mv88e6xxx_ppu_access_get(struct dsa_switch *ds)
+static int mv88e6xxx_ppu_access_get(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->ppu_mutex);
@@ -342,7 +335,7 @@ static int mv88e6xxx_ppu_access_get(struct dsa_switch *ds)
 	 * it.
 	 */
 	if (!ps->ppu_disabled) {
-		ret = mv88e6xxx_ppu_disable(ds);
+		ret = mv88e6xxx_ppu_disable(ps);
 		if (ret < 0) {
 			mutex_unlock(&ps->ppu_mutex);
 			return ret;
@@ -356,19 +349,15 @@ static int mv88e6xxx_ppu_access_get(struct dsa_switch *ds)
 	return ret;
 }
 
-static void mv88e6xxx_ppu_access_put(struct dsa_switch *ds)
+static void mv88e6xxx_ppu_access_put(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	/* Schedule a timer to re-enable the PHY polling unit. */
 	mod_timer(&ps->ppu_timer, jiffies + msecs_to_jiffies(10));
 	mutex_unlock(&ps->ppu_mutex);
 }
 
-void mv88e6xxx_ppu_state_init(struct dsa_switch *ds)
+void mv88e6xxx_ppu_state_init(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	mutex_init(&ps->ppu_mutex);
 	INIT_WORK(&ps->ppu_work, mv88e6xxx_ppu_reenable_work);
 	init_timer(&ps->ppu_timer);
@@ -379,12 +368,13 @@ EXPORT_SYMBOL_GPL(mv88e6xxx_ppu_state_init);
 
 int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ret = mv88e6xxx_ppu_access_get(ds);
+	ret = mv88e6xxx_ppu_access_get(ps);
 	if (ret >= 0) {
-		ret = mv88e6xxx_reg_read(ds, addr, regnum);
-		mv88e6xxx_ppu_access_put(ds);
+		ret = mv88e6xxx_reg_read(ps, addr, regnum);
+		mv88e6xxx_ppu_access_put(ps);
 	}
 
 	return ret;
@@ -394,12 +384,13 @@ EXPORT_SYMBOL_GPL(mv88e6xxx_phy_read_ppu);
 int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 			    int regnum, u16 val)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	ret = mv88e6xxx_ppu_access_get(ds);
+	ret = mv88e6xxx_ppu_access_get(ps);
 	if (ret >= 0) {
-		ret = mv88e6xxx_reg_write(ds, addr, regnum, val);
-		mv88e6xxx_ppu_access_put(ds);
+		ret = mv88e6xxx_reg_write(ps, addr, regnum, val);
+		mv88e6xxx_ppu_access_put(ps);
 	}
 
 	return ret;
@@ -407,10 +398,8 @@ int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 EXPORT_SYMBOL_GPL(mv88e6xxx_phy_write_ppu);
 #endif
 
-static bool mv88e6xxx_6065_family(struct dsa_switch *ds)
+static bool mv88e6xxx_6065_family(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	switch (ps->id) {
 	case PORT_SWITCH_ID_6031:
 	case PORT_SWITCH_ID_6061:
@@ -421,10 +410,8 @@ static bool mv88e6xxx_6065_family(struct dsa_switch *ds)
 	return false;
 }
 
-static bool mv88e6xxx_6095_family(struct dsa_switch *ds)
+static bool mv88e6xxx_6095_family(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	switch (ps->id) {
 	case PORT_SWITCH_ID_6092:
 	case PORT_SWITCH_ID_6095:
@@ -433,10 +420,8 @@ static bool mv88e6xxx_6095_family(struct dsa_switch *ds)
 	return false;
 }
 
-static bool mv88e6xxx_6097_family(struct dsa_switch *ds)
+static bool mv88e6xxx_6097_family(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	switch (ps->id) {
 	case PORT_SWITCH_ID_6046:
 	case PORT_SWITCH_ID_6085:
@@ -447,10 +432,8 @@ static bool mv88e6xxx_6097_family(struct dsa_switch *ds)
 	return false;
 }
 
-static bool mv88e6xxx_6165_family(struct dsa_switch *ds)
+static bool mv88e6xxx_6165_family(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	switch (ps->id) {
 	case PORT_SWITCH_ID_6123:
 	case PORT_SWITCH_ID_6161:
@@ -460,10 +443,8 @@ static bool mv88e6xxx_6165_family(struct dsa_switch *ds)
 	return false;
 }
 
-static bool mv88e6xxx_6185_family(struct dsa_switch *ds)
+static bool mv88e6xxx_6185_family(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	switch (ps->id) {
 	case PORT_SWITCH_ID_6121:
 	case PORT_SWITCH_ID_6122:
@@ -478,10 +459,8 @@ static bool mv88e6xxx_6185_family(struct dsa_switch *ds)
 	return false;
 }
 
-static bool mv88e6xxx_6320_family(struct dsa_switch *ds)
+static bool mv88e6xxx_6320_family(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	switch (ps->id) {
 	case PORT_SWITCH_ID_6320:
 	case PORT_SWITCH_ID_6321:
@@ -490,10 +469,8 @@ static bool mv88e6xxx_6320_family(struct dsa_switch *ds)
 	return false;
 }
 
-static bool mv88e6xxx_6351_family(struct dsa_switch *ds)
+static bool mv88e6xxx_6351_family(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	switch (ps->id) {
 	case PORT_SWITCH_ID_6171:
 	case PORT_SWITCH_ID_6175:
@@ -504,10 +481,8 @@ static bool mv88e6xxx_6351_family(struct dsa_switch *ds)
 	return false;
 }
 
-static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
+static bool mv88e6xxx_6352_family(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	switch (ps->id) {
 	case PORT_SWITCH_ID_6172:
 	case PORT_SWITCH_ID_6176:
@@ -518,10 +493,8 @@ static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
 	return false;
 }
 
-static unsigned int mv88e6xxx_num_databases(struct dsa_switch *ds)
+static unsigned int mv88e6xxx_num_databases(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	/* The following devices have 4-bit identifiers for 16 databases */
 	if (ps->id == PORT_SWITCH_ID_6061)
 		return 16;
@@ -531,32 +504,32 @@ static unsigned int mv88e6xxx_num_databases(struct dsa_switch *ds)
 		return 64;
 
 	/* The following devices have 8-bit identifiers for 256 databases */
-	if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds))
+	if (mv88e6xxx_6095_family(ps) || mv88e6xxx_6185_family(ps))
 		return 256;
 
 	/* The following devices have 12-bit identifiers for 4096 databases */
-	if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
-	    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds))
+	if (mv88e6xxx_6097_family(ps) || mv88e6xxx_6165_family(ps) ||
+	    mv88e6xxx_6351_family(ps) || mv88e6xxx_6352_family(ps))
 		return 4096;
 
 	return 0;
 }
 
-static bool mv88e6xxx_has_fid_reg(struct dsa_switch *ds)
+static bool mv88e6xxx_has_fid_reg(struct mv88e6xxx_priv_state *ps)
 {
 	/* Does the device have dedicated FID registers for ATU and VTU ops? */
-	if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
-	    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds))
+	if (mv88e6xxx_6097_family(ps) || mv88e6xxx_6165_family(ps) ||
+	    mv88e6xxx_6351_family(ps) || mv88e6xxx_6352_family(ps))
 		return true;
 
 	return false;
 }
 
-static bool mv88e6xxx_has_stu(struct dsa_switch *ds)
+static bool mv88e6xxx_has_stu(struct mv88e6xxx_priv_state *ps)
 {
 	/* Does the device have STU and dedicated SID registers for VTU ops? */
-	if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
-	    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds))
+	if (mv88e6xxx_6097_family(ps) || mv88e6xxx_6165_family(ps) ||
+	    mv88e6xxx_6351_family(ps) || mv88e6xxx_6352_family(ps))
 		return true;
 
 	return false;
@@ -578,7 +551,7 @@ void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 
-	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_PCS_CTRL);
+	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_PCS_CTRL);
 	if (ret < 0)
 		goto out;
 
@@ -592,7 +565,7 @@ void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 	if (phydev->link)
 			reg |= PORT_PCS_CTRL_LINK_UP;
 
-	if (mv88e6xxx_6065_family(ds) && phydev->speed > SPEED_100)
+	if (mv88e6xxx_6065_family(ps) && phydev->speed > SPEED_100)
 		goto out;
 
 	switch (phydev->speed) {
@@ -614,7 +587,7 @@ void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 	if (phydev->duplex == DUPLEX_FULL)
 		reg |= PORT_PCS_CTRL_DUPLEX_FULL;
 
-	if ((mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds)) &&
+	if ((mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps)) &&
 	    (port >= ps->num_ports - 2)) {
 		if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID)
 			reg |= PORT_PCS_CTRL_RGMII_DELAY_RXCLK;
@@ -624,20 +597,20 @@ void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 			reg |= (PORT_PCS_CTRL_RGMII_DELAY_RXCLK |
 				PORT_PCS_CTRL_RGMII_DELAY_TXCLK);
 	}
-	_mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_PCS_CTRL, reg);
+	_mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_PCS_CTRL, reg);
 
 out:
 	mutex_unlock(&ps->smi_mutex);
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_adjust_link);
 
-static int _mv88e6xxx_stats_wait(struct dsa_switch *ds)
+static int _mv88e6xxx_stats_wait(struct mv88e6xxx_priv_state *ps)
 {
 	int ret;
 	int i;
 
 	for (i = 0; i < 10; i++) {
-		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_OP);
+		ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATS_OP);
 		if ((ret & GLOBAL_STATS_OP_BUSY) == 0)
 			return 0;
 	}
@@ -645,52 +618,54 @@ static int _mv88e6xxx_stats_wait(struct dsa_switch *ds)
 	return -ETIMEDOUT;
 }
 
-static int _mv88e6xxx_stats_snapshot(struct dsa_switch *ds, int port)
+static int _mv88e6xxx_stats_snapshot(struct mv88e6xxx_priv_state *ps,
+				     int port)
 {
 	int ret;
 
-	if (mv88e6xxx_6320_family(ds) || mv88e6xxx_6352_family(ds))
+	if (mv88e6xxx_6320_family(ps) || mv88e6xxx_6352_family(ps))
 		port = (port + 1) << 5;
 
 	/* Snapshot the hardware statistics counters for this port. */
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_STATS_OP,
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_STATS_OP,
 				   GLOBAL_STATS_OP_CAPTURE_PORT |
 				   GLOBAL_STATS_OP_HIST_RX_TX | port);
 	if (ret < 0)
 		return ret;
 
 	/* Wait for the snapshotting to complete. */
-	ret = _mv88e6xxx_stats_wait(ds);
+	ret = _mv88e6xxx_stats_wait(ps);
 	if (ret < 0)
 		return ret;
 
 	return 0;
 }
 
-static void _mv88e6xxx_stats_read(struct dsa_switch *ds, int stat, u32 *val)
+static void _mv88e6xxx_stats_read(struct mv88e6xxx_priv_state *ps,
+				  int stat, u32 *val)
 {
 	u32 _val;
 	int ret;
 
 	*val = 0;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_STATS_OP,
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_STATS_OP,
 				   GLOBAL_STATS_OP_READ_CAPTURED |
 				   GLOBAL_STATS_OP_HIST_RX_TX | stat);
 	if (ret < 0)
 		return;
 
-	ret = _mv88e6xxx_stats_wait(ds);
+	ret = _mv88e6xxx_stats_wait(ps);
 	if (ret < 0)
 		return;
 
-	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_COUNTER_32);
+	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATS_COUNTER_32);
 	if (ret < 0)
 		return;
 
 	_val = ret << 16;
 
-	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_COUNTER_01);
+	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_STATS_COUNTER_01);
 	if (ret < 0)
 		return;
 
@@ -759,26 +734,26 @@ static struct mv88e6xxx_hw_stat mv88e6xxx_hw_stats[] = {
 	{ "out_management",	4, 0x1f | GLOBAL_STATS_OP_BANK_1, BANK1, },
 };
 
-static bool mv88e6xxx_has_stat(struct dsa_switch *ds,
+static bool mv88e6xxx_has_stat(struct mv88e6xxx_priv_state *ps,
 			       struct mv88e6xxx_hw_stat *stat)
 {
 	switch (stat->type) {
 	case BANK0:
 		return true;
 	case BANK1:
-		return mv88e6xxx_6320_family(ds);
+		return mv88e6xxx_6320_family(ps);
 	case PORT:
-		return mv88e6xxx_6095_family(ds) ||
-			mv88e6xxx_6185_family(ds) ||
-			mv88e6xxx_6097_family(ds) ||
-			mv88e6xxx_6165_family(ds) ||
-			mv88e6xxx_6351_family(ds) ||
-			mv88e6xxx_6352_family(ds);
+		return mv88e6xxx_6095_family(ps) ||
+			mv88e6xxx_6185_family(ps) ||
+			mv88e6xxx_6097_family(ps) ||
+			mv88e6xxx_6165_family(ps) ||
+			mv88e6xxx_6351_family(ps) ||
+			mv88e6xxx_6352_family(ps);
 	}
 	return false;
 }
 
-static uint64_t _mv88e6xxx_get_ethtool_stat(struct dsa_switch *ds,
+static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_priv_state *ps,
 					    struct mv88e6xxx_hw_stat *s,
 					    int port)
 {
@@ -789,13 +764,13 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct dsa_switch *ds,
 
 	switch (s->type) {
 	case PORT:
-		ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), s->reg);
+		ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), s->reg);
 		if (ret < 0)
 			return UINT64_MAX;
 
 		low = ret;
 		if (s->sizeof_stat == 4) {
-			ret = _mv88e6xxx_reg_read(ds, REG_PORT(port),
+			ret = _mv88e6xxx_reg_read(ps, REG_PORT(port),
 						  s->reg + 1);
 			if (ret < 0)
 				return UINT64_MAX;
@@ -804,9 +779,9 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct dsa_switch *ds,
 		break;
 	case BANK0:
 	case BANK1:
-		_mv88e6xxx_stats_read(ds, s->reg, &low);
+		_mv88e6xxx_stats_read(ps, s->reg, &low);
 		if (s->sizeof_stat == 8)
-			_mv88e6xxx_stats_read(ds, s->reg + 1, &high);
+			_mv88e6xxx_stats_read(ps, s->reg + 1, &high);
 	}
 	value = (((u64)high) << 16) | low;
 	return value;
@@ -814,12 +789,13 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct dsa_switch *ds,
 
 void mv88e6xxx_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct mv88e6xxx_hw_stat *stat;
 	int i, j;
 
 	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
 		stat = &mv88e6xxx_hw_stats[i];
-		if (mv88e6xxx_has_stat(ds, stat)) {
+		if (mv88e6xxx_has_stat(ps, stat)) {
 			memcpy(data + j * ETH_GSTRING_LEN, stat->string,
 			       ETH_GSTRING_LEN);
 			j++;
@@ -830,12 +806,13 @@ EXPORT_SYMBOL_GPL(mv88e6xxx_get_strings);
 
 int mv88e6xxx_get_sset_count(struct dsa_switch *ds)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct mv88e6xxx_hw_stat *stat;
 	int i, j;
 
 	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
 		stat = &mv88e6xxx_hw_stats[i];
-		if (mv88e6xxx_has_stat(ds, stat))
+		if (mv88e6xxx_has_stat(ps, stat))
 			j++;
 	}
 	return j;
@@ -853,15 +830,15 @@ mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 
 	mutex_lock(&ps->smi_mutex);
 
-	ret = _mv88e6xxx_stats_snapshot(ds, port);
+	ret = _mv88e6xxx_stats_snapshot(ps, port);
 	if (ret < 0) {
 		mutex_unlock(&ps->smi_mutex);
 		return;
 	}
 	for (i = 0, j = 0; i < ARRAY_SIZE(mv88e6xxx_hw_stats); i++) {
 		stat = &mv88e6xxx_hw_stats[i];
-		if (mv88e6xxx_has_stat(ds, stat)) {
-			data[j] = _mv88e6xxx_get_ethtool_stat(ds, stat, port);
+		if (mv88e6xxx_has_stat(ps, stat)) {
+			data[j] = _mv88e6xxx_get_ethtool_stat(ps, stat, port);
 			j++;
 		}
 	}
@@ -879,6 +856,7 @@ EXPORT_SYMBOL_GPL(mv88e6xxx_get_regs_len);
 void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			struct ethtool_regs *regs, void *_p)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	u16 *p = _p;
 	int i;
 
@@ -889,14 +867,14 @@ void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 	for (i = 0; i < 32; i++) {
 		int ret;
 
-		ret = mv88e6xxx_reg_read(ds, REG_PORT(port), i);
+		ret = mv88e6xxx_reg_read(ps, REG_PORT(port), i);
 		if (ret >= 0)
 			p[i] = ret;
 	}
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_get_regs);
 
-static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
+static int _mv88e6xxx_wait(struct mv88e6xxx_priv_state *ps, int reg, int offset,
 			   u16 mask)
 {
 	unsigned long timeout = jiffies + HZ / 10;
@@ -904,7 +882,7 @@ static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
 	while (time_before(jiffies, timeout)) {
 		int ret;
 
-		ret = _mv88e6xxx_reg_read(ds, reg, offset);
+		ret = _mv88e6xxx_reg_read(ps, reg, offset);
 		if (ret < 0)
 			return ret;
 		if (!(ret & mask))
@@ -915,76 +893,82 @@ static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
 	return -ETIMEDOUT;
 }
 
-static int mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
+static int mv88e6xxx_wait(struct mv88e6xxx_priv_state *ps, int reg,
+			  int offset, u16 mask)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_wait(ds, reg, offset, mask);
+	ret = _mv88e6xxx_wait(ps, reg, offset, mask);
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
 }
 
-static int _mv88e6xxx_phy_wait(struct dsa_switch *ds)
+static int _mv88e6xxx_phy_wait(struct mv88e6xxx_priv_state *ps)
 {
-	return _mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_SMI_OP,
+	return _mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_SMI_OP,
 			       GLOBAL2_SMI_OP_BUSY);
 }
 
 int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds)
 {
-	return mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	return mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
 			      GLOBAL2_EEPROM_OP_LOAD);
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_eeprom_load_wait);
 
 int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds)
 {
-	return mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	return mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
 			      GLOBAL2_EEPROM_OP_BUSY);
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_eeprom_busy_wait);
 
-static int _mv88e6xxx_atu_wait(struct dsa_switch *ds)
+static int _mv88e6xxx_atu_wait(struct mv88e6xxx_priv_state *ps)
 {
-	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_ATU_OP,
+	return _mv88e6xxx_wait(ps, REG_GLOBAL, GLOBAL_ATU_OP,
 			       GLOBAL_ATU_OP_BUSY);
 }
 
-static int _mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr,
-					int regnum)
+static int _mv88e6xxx_phy_read_indirect(struct mv88e6xxx_priv_state *ps,
+					int addr, int regnum)
 {
 	int ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_SMI_OP,
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_SMI_OP,
 				   GLOBAL2_SMI_OP_22_READ | (addr << 5) |
 				   regnum);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_phy_wait(ds);
+	ret = _mv88e6xxx_phy_wait(ps);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_reg_read(ds, REG_GLOBAL2, GLOBAL2_SMI_DATA);
+	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL2, GLOBAL2_SMI_DATA);
+
+	return ret;
 }
 
-static int _mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr,
-					 int regnum, u16 val)
+static int _mv88e6xxx_phy_write_indirect(struct mv88e6xxx_priv_state *ps,
+					 int addr, int regnum, u16 val)
 {
 	int ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_SMI_DATA, val);
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_SMI_DATA, val);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_SMI_OP,
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_SMI_OP,
 				   GLOBAL2_SMI_OP_22_WRITE | (addr << 5) |
 				   regnum);
 
-	return _mv88e6xxx_phy_wait(ds);
+	return _mv88e6xxx_phy_wait(ps);
 }
 
 int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
@@ -994,14 +978,14 @@ int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
 
 	mutex_lock(&ps->smi_mutex);
 
-	reg = _mv88e6xxx_phy_read_indirect(ds, port, 16);
+	reg = _mv88e6xxx_phy_read_indirect(ps, port, 16);
 	if (reg < 0)
 		goto out;
 
 	e->eee_enabled = !!(reg & 0x0200);
 	e->tx_lpi_enabled = !!(reg & 0x0100);
 
-	reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_STATUS);
+	reg = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_STATUS);
 	if (reg < 0)
 		goto out;
 
@@ -1023,7 +1007,7 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 
-	ret = _mv88e6xxx_phy_read_indirect(ds, port, 16);
+	ret = _mv88e6xxx_phy_read_indirect(ps, port, 16);
 	if (ret < 0)
 		goto out;
 
@@ -1033,7 +1017,7 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	if (e->tx_lpi_enabled)
 		reg |= 0x0100;
 
-	ret = _mv88e6xxx_phy_write_indirect(ds, port, 16, reg);
+	ret = _mv88e6xxx_phy_write_indirect(ps, port, 16, reg);
 out:
 	mutex_unlock(&ps->smi_mutex);
 
@@ -1041,21 +1025,21 @@ out:
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_set_eee);
 
-static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, u16 fid, u16 cmd)
+static int _mv88e6xxx_atu_cmd(struct mv88e6xxx_priv_state *ps, u16 fid, u16 cmd)
 {
 	int ret;
 
-	if (mv88e6xxx_has_fid_reg(ds)) {
-		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_FID, fid);
+	if (mv88e6xxx_has_fid_reg(ps)) {
+		ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_ATU_FID, fid);
 		if (ret < 0)
 			return ret;
-	} else if (mv88e6xxx_num_databases(ds) == 256) {
+	} else if (mv88e6xxx_num_databases(ps) == 256) {
 		/* ATU DBNum[7:4] are located in ATU Control 15:12 */
-		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_ATU_CONTROL);
+		ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_ATU_CONTROL);
 		if (ret < 0)
 			return ret;
 
-		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_CONTROL,
+		ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_ATU_CONTROL,
 					   (ret & 0xfff) |
 					   ((fid << 8) & 0xf000));
 		if (ret < 0)
@@ -1065,14 +1049,14 @@ static int _mv88e6xxx_atu_cmd(struct dsa_switch *ds, u16 fid, u16 cmd)
 		cmd |= fid & 0xf;
 	}
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_OP, cmd);
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_ATU_OP, cmd);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_atu_wait(ds);
+	return _mv88e6xxx_atu_wait(ps);
 }
 
-static int _mv88e6xxx_atu_data_write(struct dsa_switch *ds,
+static int _mv88e6xxx_atu_data_write(struct mv88e6xxx_priv_state *ps,
 				     struct mv88e6xxx_atu_entry *entry)
 {
 	u16 data = entry->state & GLOBAL_ATU_DATA_STATE_MASK;
@@ -1092,21 +1076,21 @@ static int _mv88e6xxx_atu_data_write(struct dsa_switch *ds,
 		data |= (entry->portv_trunkid << shift) & mask;
 	}
 
-	return _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_DATA, data);
+	return _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_ATU_DATA, data);
 }
 
-static int _mv88e6xxx_atu_flush_move(struct dsa_switch *ds,
+static int _mv88e6xxx_atu_flush_move(struct mv88e6xxx_priv_state *ps,
 				     struct mv88e6xxx_atu_entry *entry,
 				     bool static_too)
 {
 	int op;
 	int err;
 
-	err = _mv88e6xxx_atu_wait(ds);
+	err = _mv88e6xxx_atu_wait(ps);
 	if (err)
 		return err;
 
-	err = _mv88e6xxx_atu_data_write(ds, entry);
+	err = _mv88e6xxx_atu_data_write(ps, entry);
 	if (err)
 		return err;
 
@@ -1118,21 +1102,22 @@ static int _mv88e6xxx_atu_flush_move(struct dsa_switch *ds,
 			GLOBAL_ATU_OP_FLUSH_MOVE_NON_STATIC;
 	}
 
-	return _mv88e6xxx_atu_cmd(ds, entry->fid, op);
+	return _mv88e6xxx_atu_cmd(ps, entry->fid, op);
 }
 
-static int _mv88e6xxx_atu_flush(struct dsa_switch *ds, u16 fid, bool static_too)
+static int _mv88e6xxx_atu_flush(struct mv88e6xxx_priv_state *ps,
+				u16 fid, bool static_too)
 {
 	struct mv88e6xxx_atu_entry entry = {
 		.fid = fid,
 		.state = 0, /* EntryState bits must be 0 */
 	};
 
-	return _mv88e6xxx_atu_flush_move(ds, &entry, static_too);
+	return _mv88e6xxx_atu_flush_move(ps, &entry, static_too);
 }
 
-static int _mv88e6xxx_atu_move(struct dsa_switch *ds, u16 fid, int from_port,
-			       int to_port, bool static_too)
+static int _mv88e6xxx_atu_move(struct mv88e6xxx_priv_state *ps, u16 fid,
+			       int from_port, int to_port, bool static_too)
 {
 	struct mv88e6xxx_atu_entry entry = {
 		.trunk = false,
@@ -1146,14 +1131,14 @@ static int _mv88e6xxx_atu_move(struct dsa_switch *ds, u16 fid, int from_port,
 	entry.portv_trunkid = (to_port & 0x0f) << 4;
 	entry.portv_trunkid |= from_port & 0x0f;
 
-	return _mv88e6xxx_atu_flush_move(ds, &entry, static_too);
+	return _mv88e6xxx_atu_flush_move(ps, &entry, static_too);
 }
 
-static int _mv88e6xxx_atu_remove(struct dsa_switch *ds, u16 fid, int port,
-				 bool static_too)
+static int _mv88e6xxx_atu_remove(struct mv88e6xxx_priv_state *ps, u16 fid,
+				 int port, bool static_too)
 {
 	/* Destination port 0xF means remove the entries */
-	return _mv88e6xxx_atu_move(ds, fid, port, 0x0f, static_too);
+	return _mv88e6xxx_atu_move(ps, fid, port, 0x0f, static_too);
 }
 
 static const char * const mv88e6xxx_port_state_names[] = {
@@ -1163,12 +1148,14 @@ static const char * const mv88e6xxx_port_state_names[] = {
 	[PORT_CONTROL_STATE_FORWARDING] = "Forwarding",
 };
 
-static int _mv88e6xxx_port_state(struct dsa_switch *ds, int port, u8 state)
+static int _mv88e6xxx_port_state(struct mv88e6xxx_priv_state *ps, int port,
+				 u8 state)
 {
+	struct dsa_switch *ds = ps->ds;
 	int reg, ret = 0;
 	u8 oldstate;
 
-	reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_CONTROL);
+	reg = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_CONTROL);
 	if (reg < 0)
 		return reg;
 
@@ -1183,13 +1170,13 @@ static int _mv88e6xxx_port_state(struct dsa_switch *ds, int port, u8 state)
 		     oldstate == PORT_CONTROL_STATE_FORWARDING)
 		    && (state == PORT_CONTROL_STATE_DISABLED ||
 			state == PORT_CONTROL_STATE_BLOCKING)) {
-			ret = _mv88e6xxx_atu_remove(ds, 0, port, false);
+			ret = _mv88e6xxx_atu_remove(ps, 0, port, false);
 			if (ret)
 				return ret;
 		}
 
 		reg = (reg & ~PORT_CONTROL_STATE_MASK) | state;
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL,
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_CONTROL,
 					   reg);
 		if (ret)
 			return ret;
@@ -1202,11 +1189,12 @@ static int _mv88e6xxx_port_state(struct dsa_switch *ds, int port, u8 state)
 	return ret;
 }
 
-static int _mv88e6xxx_port_based_vlan_map(struct dsa_switch *ds, int port)
+static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_priv_state *ps,
+					  int port)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct net_device *bridge = ps->ports[port].bridge_dev;
 	const u16 mask = (1 << ps->num_ports) - 1;
+	struct dsa_switch *ds = ps->ds;
 	u16 output_ports = 0;
 	int reg;
 	int i;
@@ -1229,14 +1217,14 @@ static int _mv88e6xxx_port_based_vlan_map(struct dsa_switch *ds, int port)
 	/* prevent frames from going back out of the port they came in on */
 	output_ports &= ~BIT(port);
 
-	reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_BASE_VLAN);
+	reg = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_BASE_VLAN);
 	if (reg < 0)
 		return reg;
 
 	reg &= ~mask;
 	reg |= output_ports & mask;
 
-	return _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_BASE_VLAN, reg);
+	return _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_BASE_VLAN, reg);
 }
 
 void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port, u8 state)
@@ -1270,13 +1258,14 @@ void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port, u8 state)
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_port_stp_state_set);
 
-static int _mv88e6xxx_port_pvid(struct dsa_switch *ds, int port, u16 *new,
-				u16 *old)
+static int _mv88e6xxx_port_pvid(struct mv88e6xxx_priv_state *ps, int port,
+				u16 *new, u16 *old)
 {
+	struct dsa_switch *ds = ps->ds;
 	u16 pvid;
 	int ret;
 
-	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_DEFAULT_VLAN);
+	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_DEFAULT_VLAN);
 	if (ret < 0)
 		return ret;
 
@@ -1286,7 +1275,7 @@ static int _mv88e6xxx_port_pvid(struct dsa_switch *ds, int port, u16 *new,
 		ret &= ~PORT_DEFAULT_VLAN_MASK;
 		ret |= *new & PORT_DEFAULT_VLAN_MASK;
 
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_DEFAULT_VLAN, ret);
 		if (ret < 0)
 			return ret;
@@ -1301,55 +1290,56 @@ static int _mv88e6xxx_port_pvid(struct dsa_switch *ds, int port, u16 *new,
 	return 0;
 }
 
-static int _mv88e6xxx_port_pvid_get(struct dsa_switch *ds, int port, u16 *pvid)
+static int _mv88e6xxx_port_pvid_get(struct mv88e6xxx_priv_state *ps,
+				    int port, u16 *pvid)
 {
-	return _mv88e6xxx_port_pvid(ds, port, NULL, pvid);
+	return _mv88e6xxx_port_pvid(ps, port, NULL, pvid);
 }
 
-static int _mv88e6xxx_port_pvid_set(struct dsa_switch *ds, int port, u16 pvid)
+static int _mv88e6xxx_port_pvid_set(struct mv88e6xxx_priv_state *ps,
+				    int port, u16 pvid)
 {
-	return _mv88e6xxx_port_pvid(ds, port, &pvid, NULL);
+	return _mv88e6xxx_port_pvid(ps, port, &pvid, NULL);
 }
 
-static int _mv88e6xxx_vtu_wait(struct dsa_switch *ds)
+static int _mv88e6xxx_vtu_wait(struct mv88e6xxx_priv_state *ps)
 {
-	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_VTU_OP,
+	return _mv88e6xxx_wait(ps, REG_GLOBAL, GLOBAL_VTU_OP,
 			       GLOBAL_VTU_OP_BUSY);
 }
 
-static int _mv88e6xxx_vtu_cmd(struct dsa_switch *ds, u16 op)
+static int _mv88e6xxx_vtu_cmd(struct mv88e6xxx_priv_state *ps, u16 op)
 {
 	int ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_OP, op);
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_OP, op);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_vtu_wait(ds);
+	return _mv88e6xxx_vtu_wait(ps);
 }
 
-static int _mv88e6xxx_vtu_stu_flush(struct dsa_switch *ds)
+static int _mv88e6xxx_vtu_stu_flush(struct mv88e6xxx_priv_state *ps)
 {
 	int ret;
 
-	ret = _mv88e6xxx_vtu_wait(ds);
+	ret = _mv88e6xxx_vtu_wait(ps);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_FLUSH_ALL);
+	return _mv88e6xxx_vtu_cmd(ps, GLOBAL_VTU_OP_FLUSH_ALL);
 }
 
-static int _mv88e6xxx_vtu_stu_data_read(struct dsa_switch *ds,
+static int _mv88e6xxx_vtu_stu_data_read(struct mv88e6xxx_priv_state *ps,
 					struct mv88e6xxx_vtu_stu_entry *entry,
 					unsigned int nibble_offset)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	u16 regs[3];
 	int i;
 	int ret;
 
 	for (i = 0; i < 3; ++i) {
-		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
+		ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL,
 					  GLOBAL_VTU_DATA_0_3 + i);
 		if (ret < 0)
 			return ret;
@@ -1367,11 +1357,10 @@ static int _mv88e6xxx_vtu_stu_data_read(struct dsa_switch *ds,
 	return 0;
 }
 
-static int _mv88e6xxx_vtu_stu_data_write(struct dsa_switch *ds,
+static int _mv88e6xxx_vtu_stu_data_write(struct mv88e6xxx_priv_state *ps,
 					 struct mv88e6xxx_vtu_stu_entry *entry,
 					 unsigned int nibble_offset)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	u16 regs[3] = { 0 };
 	int i;
 	int ret;
@@ -1384,7 +1373,7 @@ static int _mv88e6xxx_vtu_stu_data_write(struct dsa_switch *ds,
 	}
 
 	for (i = 0; i < 3; ++i) {
-		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL,
+		ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL,
 					   GLOBAL_VTU_DATA_0_3 + i, regs[i]);
 		if (ret < 0)
 			return ret;
@@ -1393,27 +1382,27 @@ static int _mv88e6xxx_vtu_stu_data_write(struct dsa_switch *ds,
 	return 0;
 }
 
-static int _mv88e6xxx_vtu_vid_write(struct dsa_switch *ds, u16 vid)
+static int _mv88e6xxx_vtu_vid_write(struct mv88e6xxx_priv_state *ps, u16 vid)
 {
-	return _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID,
+	return _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_VID,
 				    vid & GLOBAL_VTU_VID_MASK);
 }
 
-static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds,
+static int _mv88e6xxx_vtu_getnext(struct mv88e6xxx_priv_state *ps,
 				  struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	struct mv88e6xxx_vtu_stu_entry next = { 0 };
 	int ret;
 
-	ret = _mv88e6xxx_vtu_wait(ds);
+	ret = _mv88e6xxx_vtu_wait(ps);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_VTU_GET_NEXT);
+	ret = _mv88e6xxx_vtu_cmd(ps, GLOBAL_VTU_OP_VTU_GET_NEXT);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_VID);
+	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_VTU_VID);
 	if (ret < 0)
 		return ret;
 
@@ -1421,22 +1410,22 @@ static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds,
 	next.valid = !!(ret & GLOBAL_VTU_VID_VALID);
 
 	if (next.valid) {
-		ret = _mv88e6xxx_vtu_stu_data_read(ds, &next, 0);
+		ret = _mv88e6xxx_vtu_stu_data_read(ps, &next, 0);
 		if (ret < 0)
 			return ret;
 
-		if (mv88e6xxx_has_fid_reg(ds)) {
-			ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
+		if (mv88e6xxx_has_fid_reg(ps)) {
+			ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL,
 						  GLOBAL_VTU_FID);
 			if (ret < 0)
 				return ret;
 
 			next.fid = ret & GLOBAL_VTU_FID_MASK;
-		} else if (mv88e6xxx_num_databases(ds) == 256) {
+		} else if (mv88e6xxx_num_databases(ps) == 256) {
 			/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
 			 * VTU DBNum[3:0] are located in VTU Operation 3:0
 			 */
-			ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
+			ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL,
 						  GLOBAL_VTU_OP);
 			if (ret < 0)
 				return ret;
@@ -1445,8 +1434,8 @@ static int _mv88e6xxx_vtu_getnext(struct dsa_switch *ds,
 			next.fid |= ret & 0xf;
 		}
 
-		if (mv88e6xxx_has_stu(ds)) {
-			ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
+		if (mv88e6xxx_has_stu(ps)) {
+			ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL,
 						  GLOBAL_VTU_SID);
 			if (ret < 0)
 				return ret;
@@ -1470,16 +1459,16 @@ int mv88e6xxx_port_vlan_dump(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 
-	err = _mv88e6xxx_port_pvid_get(ds, port, &pvid);
+	err = _mv88e6xxx_port_pvid_get(ps, port, &pvid);
 	if (err)
 		goto unlock;
 
-	err = _mv88e6xxx_vtu_vid_write(ds, GLOBAL_VTU_VID_MASK);
+	err = _mv88e6xxx_vtu_vid_write(ps, GLOBAL_VTU_VID_MASK);
 	if (err)
 		goto unlock;
 
 	do {
-		err = _mv88e6xxx_vtu_getnext(ds, &next);
+		err = _mv88e6xxx_vtu_getnext(ps, &next);
 		if (err)
 			break;
 
@@ -1511,14 +1500,14 @@ unlock:
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_dump);
 
-static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
+static int _mv88e6xxx_vtu_loadpurge(struct mv88e6xxx_priv_state *ps,
 				    struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	u16 op = GLOBAL_VTU_OP_VTU_LOAD_PURGE;
 	u16 reg = 0;
 	int ret;
 
-	ret = _mv88e6xxx_vtu_wait(ds);
+	ret = _mv88e6xxx_vtu_wait(ps);
 	if (ret < 0)
 		return ret;
 
@@ -1526,23 +1515,23 @@ static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
 		goto loadpurge;
 
 	/* Write port member tags */
-	ret = _mv88e6xxx_vtu_stu_data_write(ds, entry, 0);
+	ret = _mv88e6xxx_vtu_stu_data_write(ps, entry, 0);
 	if (ret < 0)
 		return ret;
 
-	if (mv88e6xxx_has_stu(ds)) {
+	if (mv88e6xxx_has_stu(ps)) {
 		reg = entry->sid & GLOBAL_VTU_SID_MASK;
-		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_SID, reg);
+		ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_SID, reg);
 		if (ret < 0)
 			return ret;
 	}
 
-	if (mv88e6xxx_has_fid_reg(ds)) {
+	if (mv88e6xxx_has_fid_reg(ps)) {
 		reg = entry->fid & GLOBAL_VTU_FID_MASK;
-		ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_FID, reg);
+		ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_FID, reg);
 		if (ret < 0)
 			return ret;
-	} else if (mv88e6xxx_num_databases(ds) == 256) {
+	} else if (mv88e6xxx_num_databases(ps) == 256) {
 		/* VTU DBNum[7:4] are located in VTU Operation 11:8, and
 		 * VTU DBNum[3:0] are located in VTU Operation 3:0
 		 */
@@ -1553,46 +1542,46 @@ static int _mv88e6xxx_vtu_loadpurge(struct dsa_switch *ds,
 	reg = GLOBAL_VTU_VID_VALID;
 loadpurge:
 	reg |= entry->vid & GLOBAL_VTU_VID_MASK;
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID, reg);
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_VID, reg);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_vtu_cmd(ds, op);
+	return _mv88e6xxx_vtu_cmd(ps, op);
 }
 
-static int _mv88e6xxx_stu_getnext(struct dsa_switch *ds, u8 sid,
+static int _mv88e6xxx_stu_getnext(struct mv88e6xxx_priv_state *ps, u8 sid,
 				  struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	struct mv88e6xxx_vtu_stu_entry next = { 0 };
 	int ret;
 
-	ret = _mv88e6xxx_vtu_wait(ds);
+	ret = _mv88e6xxx_vtu_wait(ps);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_SID,
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_SID,
 				   sid & GLOBAL_VTU_SID_MASK);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_STU_GET_NEXT);
+	ret = _mv88e6xxx_vtu_cmd(ps, GLOBAL_VTU_OP_STU_GET_NEXT);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_SID);
+	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_VTU_SID);
 	if (ret < 0)
 		return ret;
 
 	next.sid = ret & GLOBAL_VTU_SID_MASK;
 
-	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_VTU_VID);
+	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_VTU_VID);
 	if (ret < 0)
 		return ret;
 
 	next.valid = !!(ret & GLOBAL_VTU_VID_VALID);
 
 	if (next.valid) {
-		ret = _mv88e6xxx_vtu_stu_data_read(ds, &next, 2);
+		ret = _mv88e6xxx_vtu_stu_data_read(ps, &next, 2);
 		if (ret < 0)
 			return ret;
 	}
@@ -1601,13 +1590,13 @@ static int _mv88e6xxx_stu_getnext(struct dsa_switch *ds, u8 sid,
 	return 0;
 }
 
-static int _mv88e6xxx_stu_loadpurge(struct dsa_switch *ds,
+static int _mv88e6xxx_stu_loadpurge(struct mv88e6xxx_priv_state *ps,
 				    struct mv88e6xxx_vtu_stu_entry *entry)
 {
 	u16 reg = 0;
 	int ret;
 
-	ret = _mv88e6xxx_vtu_wait(ds);
+	ret = _mv88e6xxx_vtu_wait(ps);
 	if (ret < 0)
 		return ret;
 
@@ -1615,40 +1604,41 @@ static int _mv88e6xxx_stu_loadpurge(struct dsa_switch *ds,
 		goto loadpurge;
 
 	/* Write port states */
-	ret = _mv88e6xxx_vtu_stu_data_write(ds, entry, 2);
+	ret = _mv88e6xxx_vtu_stu_data_write(ps, entry, 2);
 	if (ret < 0)
 		return ret;
 
 	reg = GLOBAL_VTU_VID_VALID;
 loadpurge:
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_VID, reg);
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_VID, reg);
 	if (ret < 0)
 		return ret;
 
 	reg = entry->sid & GLOBAL_VTU_SID_MASK;
-	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_VTU_SID, reg);
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_VTU_SID, reg);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_vtu_cmd(ds, GLOBAL_VTU_OP_STU_LOAD_PURGE);
+	return _mv88e6xxx_vtu_cmd(ps, GLOBAL_VTU_OP_STU_LOAD_PURGE);
 }
 
-static int _mv88e6xxx_port_fid(struct dsa_switch *ds, int port, u16 *new,
-			       u16 *old)
+static int _mv88e6xxx_port_fid(struct mv88e6xxx_priv_state *ps, int port,
+			       u16 *new, u16 *old)
 {
+	struct dsa_switch *ds = ps->ds;
 	u16 upper_mask;
 	u16 fid;
 	int ret;
 
-	if (mv88e6xxx_num_databases(ds) == 4096)
+	if (mv88e6xxx_num_databases(ps) == 4096)
 		upper_mask = 0xff;
-	else if (mv88e6xxx_num_databases(ds) == 256)
+	else if (mv88e6xxx_num_databases(ps) == 256)
 		upper_mask = 0xf;
 	else
 		return -EOPNOTSUPP;
 
 	/* Port's default FID bits 3:0 are located in reg 0x06, offset 12 */
-	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_BASE_VLAN);
+	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_BASE_VLAN);
 	if (ret < 0)
 		return ret;
 
@@ -1658,14 +1648,14 @@ static int _mv88e6xxx_port_fid(struct dsa_switch *ds, int port, u16 *new,
 		ret &= ~PORT_BASE_VLAN_FID_3_0_MASK;
 		ret |= (*new << 12) & PORT_BASE_VLAN_FID_3_0_MASK;
 
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_BASE_VLAN,
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_BASE_VLAN,
 					   ret);
 		if (ret < 0)
 			return ret;
 	}
 
 	/* Port's default FID bits 11:4 are located in reg 0x05, offset 0 */
-	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_CONTROL_1);
+	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_CONTROL_1);
 	if (ret < 0)
 		return ret;
 
@@ -1675,7 +1665,7 @@ static int _mv88e6xxx_port_fid(struct dsa_switch *ds, int port, u16 *new,
 		ret &= ~upper_mask;
 		ret |= (*new >> 4) & upper_mask;
 
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_1,
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_CONTROL_1,
 					   ret);
 		if (ret < 0)
 			return ret;
@@ -1689,19 +1679,20 @@ static int _mv88e6xxx_port_fid(struct dsa_switch *ds, int port, u16 *new,
 	return 0;
 }
 
-static int _mv88e6xxx_port_fid_get(struct dsa_switch *ds, int port, u16 *fid)
+static int _mv88e6xxx_port_fid_get(struct mv88e6xxx_priv_state *ps,
+				   int port, u16 *fid)
 {
-	return _mv88e6xxx_port_fid(ds, port, NULL, fid);
+	return _mv88e6xxx_port_fid(ps, port, NULL, fid);
 }
 
-static int _mv88e6xxx_port_fid_set(struct dsa_switch *ds, int port, u16 fid)
+static int _mv88e6xxx_port_fid_set(struct mv88e6xxx_priv_state *ps,
+				   int port, u16 fid)
 {
-	return _mv88e6xxx_port_fid(ds, port, &fid, NULL);
+	return _mv88e6xxx_port_fid(ps, port, &fid, NULL);
 }
 
-static int _mv88e6xxx_fid_new(struct dsa_switch *ds, u16 *fid)
+static int _mv88e6xxx_fid_new(struct mv88e6xxx_priv_state *ps, u16 *fid)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	DECLARE_BITMAP(fid_bitmap, MV88E6XXX_N_FID);
 	struct mv88e6xxx_vtu_stu_entry vlan;
 	int i, err;
@@ -1710,7 +1701,7 @@ static int _mv88e6xxx_fid_new(struct dsa_switch *ds, u16 *fid)
 
 	/* Set every FID bit used by the (un)bridged ports */
 	for (i = 0; i < ps->num_ports; ++i) {
-		err = _mv88e6xxx_port_fid_get(ds, i, fid);
+		err = _mv88e6xxx_port_fid_get(ps, i, fid);
 		if (err)
 			return err;
 
@@ -1718,12 +1709,12 @@ static int _mv88e6xxx_fid_new(struct dsa_switch *ds, u16 *fid)
 	}
 
 	/* Set every FID bit used by the VLAN entries */
-	err = _mv88e6xxx_vtu_vid_write(ds, GLOBAL_VTU_VID_MASK);
+	err = _mv88e6xxx_vtu_vid_write(ps, GLOBAL_VTU_VID_MASK);
 	if (err)
 		return err;
 
 	do {
-		err = _mv88e6xxx_vtu_getnext(ds, &vlan);
+		err = _mv88e6xxx_vtu_getnext(ps, &vlan);
 		if (err)
 			return err;
 
@@ -1737,24 +1728,24 @@ static int _mv88e6xxx_fid_new(struct dsa_switch *ds, u16 *fid)
 	 * databases are not needed. Return the next positive available.
 	 */
 	*fid = find_next_zero_bit(fid_bitmap, MV88E6XXX_N_FID, 1);
-	if (unlikely(*fid >= mv88e6xxx_num_databases(ds)))
+	if (unlikely(*fid >= mv88e6xxx_num_databases(ps)))
 		return -ENOSPC;
 
 	/* Clear the database */
-	return _mv88e6xxx_atu_flush(ds, *fid, true);
+	return _mv88e6xxx_atu_flush(ps, *fid, true);
 }
 
-static int _mv88e6xxx_vtu_new(struct dsa_switch *ds, u16 vid,
+static int _mv88e6xxx_vtu_new(struct mv88e6xxx_priv_state *ps, u16 vid,
 			      struct mv88e6xxx_vtu_stu_entry *entry)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct dsa_switch *ds = ps->ds;
 	struct mv88e6xxx_vtu_stu_entry vlan = {
 		.valid = true,
 		.vid = vid,
 	};
 	int i, err;
 
-	err = _mv88e6xxx_fid_new(ds, &vlan.fid);
+	err = _mv88e6xxx_fid_new(ps, &vlan.fid);
 	if (err)
 		return err;
 
@@ -1764,8 +1755,8 @@ static int _mv88e6xxx_vtu_new(struct dsa_switch *ds, u16 vid,
 			? GLOBAL_VTU_DATA_MEMBER_TAG_UNMODIFIED
 			: GLOBAL_VTU_DATA_MEMBER_TAG_NON_MEMBER;
 
-	if (mv88e6xxx_6097_family(ds) || mv88e6xxx_6165_family(ds) ||
-	    mv88e6xxx_6351_family(ds) || mv88e6xxx_6352_family(ds)) {
+	if (mv88e6xxx_6097_family(ps) || mv88e6xxx_6165_family(ps) ||
+	    mv88e6xxx_6351_family(ps) || mv88e6xxx_6352_family(ps)) {
 		struct mv88e6xxx_vtu_stu_entry vstp;
 
 		/* Adding a VTU entry requires a valid STU entry. As VSTP is not
@@ -1773,7 +1764,7 @@ static int _mv88e6xxx_vtu_new(struct dsa_switch *ds, u16 vid,
 		 * entries. Thus, validate the SID 0.
 		 */
 		vlan.sid = 0;
-		err = _mv88e6xxx_stu_getnext(ds, GLOBAL_VTU_SID_MASK, &vstp);
+		err = _mv88e6xxx_stu_getnext(ps, GLOBAL_VTU_SID_MASK, &vstp);
 		if (err)
 			return err;
 
@@ -1782,7 +1773,7 @@ static int _mv88e6xxx_vtu_new(struct dsa_switch *ds, u16 vid,
 			vstp.valid = true;
 			vstp.sid = vlan.sid;
 
-			err = _mv88e6xxx_stu_loadpurge(ds, &vstp);
+			err = _mv88e6xxx_stu_loadpurge(ps, &vstp);
 			if (err)
 				return err;
 		}
@@ -1792,7 +1783,7 @@ static int _mv88e6xxx_vtu_new(struct dsa_switch *ds, u16 vid,
 	return 0;
 }
 
-static int _mv88e6xxx_vtu_get(struct dsa_switch *ds, u16 vid,
+static int _mv88e6xxx_vtu_get(struct mv88e6xxx_priv_state *ps, u16 vid,
 			      struct mv88e6xxx_vtu_stu_entry *entry, bool creat)
 {
 	int err;
@@ -1800,11 +1791,11 @@ static int _mv88e6xxx_vtu_get(struct dsa_switch *ds, u16 vid,
 	if (!vid)
 		return -EINVAL;
 
-	err = _mv88e6xxx_vtu_vid_write(ds, vid - 1);
+	err = _mv88e6xxx_vtu_vid_write(ps, vid - 1);
 	if (err)
 		return err;
 
-	err = _mv88e6xxx_vtu_getnext(ds, entry);
+	err = _mv88e6xxx_vtu_getnext(ps, entry);
 	if (err)
 		return err;
 
@@ -1815,7 +1806,7 @@ static int _mv88e6xxx_vtu_get(struct dsa_switch *ds, u16 vid,
 		 * -EOPNOTSUPP to inform bridge about an eventual software VLAN.
 		 */
 
-		err = _mv88e6xxx_vtu_new(ds, vid, entry);
+		err = _mv88e6xxx_vtu_new(ps, vid, entry);
 	}
 
 	return err;
@@ -1833,12 +1824,12 @@ static int mv88e6xxx_port_check_hw_vlan(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 
-	err = _mv88e6xxx_vtu_vid_write(ds, vid_begin - 1);
+	err = _mv88e6xxx_vtu_vid_write(ps, vid_begin - 1);
 	if (err)
 		goto unlock;
 
 	do {
-		err = _mv88e6xxx_vtu_getnext(ds, &vlan);
+		err = _mv88e6xxx_vtu_getnext(ps, &vlan);
 		if (err)
 			goto unlock;
 
@@ -1892,7 +1883,7 @@ int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 
-	ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_CONTROL_2);
+	ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_CONTROL_2);
 	if (ret < 0)
 		goto unlock;
 
@@ -1902,7 +1893,7 @@ int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 		ret &= ~PORT_CONTROL_2_8021Q_MASK;
 		ret |= new & PORT_CONTROL_2_8021Q_MASK;
 
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_2,
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_CONTROL_2,
 					   ret);
 		if (ret < 0)
 			goto unlock;
@@ -1941,13 +1932,13 @@ int mv88e6xxx_port_vlan_prepare(struct dsa_switch *ds, int port,
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_prepare);
 
-static int _mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
-				    bool untagged)
+static int _mv88e6xxx_port_vlan_add(struct mv88e6xxx_priv_state *ps, int port,
+				    u16 vid, bool untagged)
 {
 	struct mv88e6xxx_vtu_stu_entry vlan;
 	int err;
 
-	err = _mv88e6xxx_vtu_get(ds, vid, &vlan, true);
+	err = _mv88e6xxx_vtu_get(ps, vid, &vlan, true);
 	if (err)
 		return err;
 
@@ -1955,7 +1946,7 @@ static int _mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port, u16 vid,
 		GLOBAL_VTU_DATA_MEMBER_TAG_UNTAGGED :
 		GLOBAL_VTU_DATA_MEMBER_TAG_TAGGED;
 
-	return _mv88e6xxx_vtu_loadpurge(ds, &vlan);
+	return _mv88e6xxx_vtu_loadpurge(ps, &vlan);
 }
 
 void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
@@ -1970,11 +1961,11 @@ void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 	mutex_lock(&ps->smi_mutex);
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid)
-		if (_mv88e6xxx_port_vlan_add(ds, port, vid, untagged))
+		if (_mv88e6xxx_port_vlan_add(ps, port, vid, untagged))
 			netdev_err(ds->ports[port], "failed to add VLAN %d%c\n",
 				   vid, untagged ? 'u' : 't');
 
-	if (pvid && _mv88e6xxx_port_pvid_set(ds, port, vlan->vid_end))
+	if (pvid && _mv88e6xxx_port_pvid_set(ps, port, vlan->vid_end))
 		netdev_err(ds->ports[port], "failed to set PVID %d\n",
 			   vlan->vid_end);
 
@@ -1982,13 +1973,14 @@ void mv88e6xxx_port_vlan_add(struct dsa_switch *ds, int port,
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_add);
 
-static int _mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
+static int _mv88e6xxx_port_vlan_del(struct mv88e6xxx_priv_state *ps,
+				    int port, u16 vid)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	struct dsa_switch *ds = ps->ds;
 	struct mv88e6xxx_vtu_stu_entry vlan;
 	int i, err;
 
-	err = _mv88e6xxx_vtu_get(ds, vid, &vlan, false);
+	err = _mv88e6xxx_vtu_get(ps, vid, &vlan, false);
 	if (err)
 		return err;
 
@@ -2010,11 +2002,11 @@ static int _mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port, u16 vid)
 		}
 	}
 
-	err = _mv88e6xxx_vtu_loadpurge(ds, &vlan);
+	err = _mv88e6xxx_vtu_loadpurge(ps, &vlan);
 	if (err)
 		return err;
 
-	return _mv88e6xxx_atu_remove(ds, vlan.fid, port, false);
+	return _mv88e6xxx_atu_remove(ps, vlan.fid, port, false);
 }
 
 int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
@@ -2026,17 +2018,17 @@ int mv88e6xxx_port_vlan_del(struct dsa_switch *ds, int port,
 
 	mutex_lock(&ps->smi_mutex);
 
-	err = _mv88e6xxx_port_pvid_get(ds, port, &pvid);
+	err = _mv88e6xxx_port_pvid_get(ps, port, &pvid);
 	if (err)
 		goto unlock;
 
 	for (vid = vlan->vid_begin; vid <= vlan->vid_end; ++vid) {
-		err = _mv88e6xxx_port_vlan_del(ds, port, vid);
+		err = _mv88e6xxx_port_vlan_del(ps, port, vid);
 		if (err)
 			goto unlock;
 
 		if (vid == pvid) {
-			err = _mv88e6xxx_port_pvid_set(ds, port, 0);
+			err = _mv88e6xxx_port_pvid_set(ps, port, 0);
 			if (err)
 				goto unlock;
 		}
@@ -2049,14 +2041,14 @@ unlock:
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_port_vlan_del);
 
-static int _mv88e6xxx_atu_mac_write(struct dsa_switch *ds,
+static int _mv88e6xxx_atu_mac_write(struct mv88e6xxx_priv_state *ps,
 				    const unsigned char *addr)
 {
 	int i, ret;
 
 	for (i = 0; i < 3; i++) {
 		ret = _mv88e6xxx_reg_write(
-			ds, REG_GLOBAL, GLOBAL_ATU_MAC_01 + i,
+			ps, REG_GLOBAL, GLOBAL_ATU_MAC_01 + i,
 			(addr[i * 2] << 8) | addr[i * 2 + 1]);
 		if (ret < 0)
 			return ret;
@@ -2065,12 +2057,13 @@ static int _mv88e6xxx_atu_mac_write(struct dsa_switch *ds,
 	return 0;
 }
 
-static int _mv88e6xxx_atu_mac_read(struct dsa_switch *ds, unsigned char *addr)
+static int _mv88e6xxx_atu_mac_read(struct mv88e6xxx_priv_state *ps,
+				   unsigned char *addr)
 {
 	int i, ret;
 
 	for (i = 0; i < 3; i++) {
-		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL,
+		ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL,
 					  GLOBAL_ATU_MAC_01 + i);
 		if (ret < 0)
 			return ret;
@@ -2081,27 +2074,27 @@ static int _mv88e6xxx_atu_mac_read(struct dsa_switch *ds, unsigned char *addr)
 	return 0;
 }
 
-static int _mv88e6xxx_atu_load(struct dsa_switch *ds,
+static int _mv88e6xxx_atu_load(struct mv88e6xxx_priv_state *ps,
 			       struct mv88e6xxx_atu_entry *entry)
 {
 	int ret;
 
-	ret = _mv88e6xxx_atu_wait(ds);
+	ret = _mv88e6xxx_atu_wait(ps);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_atu_mac_write(ds, entry->mac);
+	ret = _mv88e6xxx_atu_mac_write(ps, entry->mac);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_atu_data_write(ds, entry);
+	ret = _mv88e6xxx_atu_data_write(ps, entry);
 	if (ret < 0)
 		return ret;
 
-	return _mv88e6xxx_atu_cmd(ds, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
+	return _mv88e6xxx_atu_cmd(ps, entry->fid, GLOBAL_ATU_OP_LOAD_DB);
 }
 
-static int _mv88e6xxx_port_fdb_load(struct dsa_switch *ds, int port,
+static int _mv88e6xxx_port_fdb_load(struct mv88e6xxx_priv_state *ps, int port,
 				    const unsigned char *addr, u16 vid,
 				    u8 state)
 {
@@ -2111,9 +2104,9 @@ static int _mv88e6xxx_port_fdb_load(struct dsa_switch *ds, int port,
 
 	/* Null VLAN ID corresponds to the port private database */
 	if (vid == 0)
-		err = _mv88e6xxx_port_fid_get(ds, port, &vlan.fid);
+		err = _mv88e6xxx_port_fid_get(ps, port, &vlan.fid);
 	else
-		err = _mv88e6xxx_vtu_get(ds, vid, &vlan, false);
+		err = _mv88e6xxx_vtu_get(ps, vid, &vlan, false);
 	if (err)
 		return err;
 
@@ -2125,7 +2118,7 @@ static int _mv88e6xxx_port_fdb_load(struct dsa_switch *ds, int port,
 		entry.portv_trunkid = BIT(port);
 	}
 
-	return _mv88e6xxx_atu_load(ds, &entry);
+	return _mv88e6xxx_atu_load(ps, &entry);
 }
 
 int mv88e6xxx_port_fdb_prepare(struct dsa_switch *ds, int port,
@@ -2149,7 +2142,7 @@ void mv88e6xxx_port_fdb_add(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 
 	mutex_lock(&ps->smi_mutex);
-	if (_mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid, state))
+	if (_mv88e6xxx_port_fdb_load(ps, port, fdb->addr, fdb->vid, state))
 		netdev_err(ds->ports[port], "failed to load MAC address\n");
 	mutex_unlock(&ps->smi_mutex);
 }
@@ -2162,7 +2155,7 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_port_fdb_load(ds, port, fdb->addr, fdb->vid,
+	ret = _mv88e6xxx_port_fdb_load(ps, port, fdb->addr, fdb->vid,
 				       GLOBAL_ATU_DATA_STATE_UNUSED);
 	mutex_unlock(&ps->smi_mutex);
 
@@ -2170,7 +2163,7 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_port_fdb_del);
 
-static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
+static int _mv88e6xxx_atu_getnext(struct mv88e6xxx_priv_state *ps, u16 fid,
 				  struct mv88e6xxx_atu_entry *entry)
 {
 	struct mv88e6xxx_atu_entry next = { 0 };
@@ -2178,19 +2171,19 @@ static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
 
 	next.fid = fid;
 
-	ret = _mv88e6xxx_atu_wait(ds);
+	ret = _mv88e6xxx_atu_wait(ps);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_atu_cmd(ds, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
+	ret = _mv88e6xxx_atu_cmd(ps, fid, GLOBAL_ATU_OP_GET_NEXT_DB);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_atu_mac_read(ds, next.mac);
+	ret = _mv88e6xxx_atu_mac_read(ps, next.mac);
 	if (ret < 0)
 		return ret;
 
-	ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_ATU_DATA);
+	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL, GLOBAL_ATU_DATA);
 	if (ret < 0)
 		return ret;
 
@@ -2215,8 +2208,8 @@ static int _mv88e6xxx_atu_getnext(struct dsa_switch *ds, u16 fid,
 	return 0;
 }
 
-static int _mv88e6xxx_port_fdb_dump_one(struct dsa_switch *ds, u16 fid, u16 vid,
-					int port,
+static int _mv88e6xxx_port_fdb_dump_one(struct mv88e6xxx_priv_state *ps,
+					u16 fid, u16 vid, int port,
 					struct switchdev_obj_port_fdb *fdb,
 					int (*cb)(struct switchdev_obj *obj))
 {
@@ -2225,12 +2218,12 @@ static int _mv88e6xxx_port_fdb_dump_one(struct dsa_switch *ds, u16 fid, u16 vid,
 	};
 	int err;
 
-	err = _mv88e6xxx_atu_mac_write(ds, addr.mac);
+	err = _mv88e6xxx_atu_mac_write(ps, addr.mac);
 	if (err)
 		return err;
 
 	do {
-		err = _mv88e6xxx_atu_getnext(ds, fid, &addr);
+		err = _mv88e6xxx_atu_getnext(ps, fid, &addr);
 		if (err)
 			break;
 
@@ -2270,28 +2263,28 @@ int mv88e6xxx_port_fdb_dump(struct dsa_switch *ds, int port,
 	mutex_lock(&ps->smi_mutex);
 
 	/* Dump port's default Filtering Information Database (VLAN ID 0) */
-	err = _mv88e6xxx_port_fid_get(ds, port, &fid);
+	err = _mv88e6xxx_port_fid_get(ps, port, &fid);
 	if (err)
 		goto unlock;
 
-	err = _mv88e6xxx_port_fdb_dump_one(ds, fid, 0, port, fdb, cb);
+	err = _mv88e6xxx_port_fdb_dump_one(ps, fid, 0, port, fdb, cb);
 	if (err)
 		goto unlock;
 
 	/* Dump VLANs' Filtering Information Databases */
-	err = _mv88e6xxx_vtu_vid_write(ds, vlan.vid);
+	err = _mv88e6xxx_vtu_vid_write(ps, vlan.vid);
 	if (err)
 		goto unlock;
 
 	do {
-		err = _mv88e6xxx_vtu_getnext(ds, &vlan);
+		err = _mv88e6xxx_vtu_getnext(ps, &vlan);
 		if (err)
 			break;
 
 		if (!vlan.valid)
 			break;
 
-		err = _mv88e6xxx_port_fdb_dump_one(ds, vlan.fid, vlan.vid, port,
+		err = _mv88e6xxx_port_fdb_dump_one(ps, vlan.fid, vlan.vid, port,
 						   fdb, cb);
 		if (err)
 			break;
@@ -2319,13 +2312,13 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 			break;
 
 	if (i < ps->num_ports)
-		err = _mv88e6xxx_port_fid_get(ds, i, &fid);
+		err = _mv88e6xxx_port_fid_get(ps, i, &fid);
 	else
-		err = _mv88e6xxx_fid_new(ds, &fid);
+		err = _mv88e6xxx_fid_new(ps, &fid);
 	if (err)
 		goto unlock;
 
-	err = _mv88e6xxx_port_fid_set(ds, port, fid);
+	err = _mv88e6xxx_port_fid_set(ps, port, fid);
 	if (err)
 		goto unlock;
 
@@ -2334,7 +2327,7 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 
 	for (i = 0; i < ps->num_ports; ++i) {
 		if (ps->ports[i].bridge_dev == bridge) {
-			err = _mv88e6xxx_port_based_vlan_map(ds, i);
+			err = _mv88e6xxx_port_based_vlan_map(ps, i);
 			if (err)
 				break;
 		}
@@ -2357,8 +2350,8 @@ void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 	mutex_lock(&ps->smi_mutex);
 
 	/* Give the port a fresh Filtering Information Database */
-	if (_mv88e6xxx_fid_new(ds, &fid) ||
-	    _mv88e6xxx_port_fid_set(ds, port, fid))
+	if (_mv88e6xxx_fid_new(ps, &fid) ||
+	    _mv88e6xxx_port_fid_set(ps, port, fid))
 		netdev_warn(ds->ports[port], "failed to assign a new FID\n");
 
 	/* Unassign the bridge and remap each port's VLANTable */
@@ -2366,7 +2359,7 @@ void mv88e6xxx_port_bridge_leave(struct dsa_switch *ds, int port)
 
 	for (i = 0; i < ps->num_ports; ++i)
 		if (i == port || ps->ports[i].bridge_dev == bridge)
-			if (_mv88e6xxx_port_based_vlan_map(ds, i))
+			if (_mv88e6xxx_port_based_vlan_map(ps, i))
 				netdev_warn(ds->ports[i], "failed to remap\n");
 
 	mutex_unlock(&ps->smi_mutex);
@@ -2386,57 +2379,58 @@ static void mv88e6xxx_bridge_work(struct work_struct *work)
 
 	for (port = 0; port < ps->num_ports; ++port)
 		if (test_and_clear_bit(port, ps->port_state_update_mask) &&
-		    _mv88e6xxx_port_state(ds, port, ps->ports[port].state))
-			netdev_warn(ds->ports[port], "failed to update state to %s\n",
+		    _mv88e6xxx_port_state(ps, port, ps->ports[port].state))
+			netdev_warn(ds->ports[port],
+				    "failed to update state to %s\n",
 				    mv88e6xxx_port_state_names[ps->ports[port].state]);
 
 	mutex_unlock(&ps->smi_mutex);
 }
 
-static int _mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
-				     int reg, int val)
+static int _mv88e6xxx_phy_page_write(struct mv88e6xxx_priv_state *ps,
+				     int port, int page, int reg, int val)
 {
 	int ret;
 
-	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
+	ret = _mv88e6xxx_phy_write_indirect(ps, port, 0x16, page);
 	if (ret < 0)
 		goto restore_page_0;
 
-	ret = _mv88e6xxx_phy_write_indirect(ds, port, reg, val);
+	ret = _mv88e6xxx_phy_write_indirect(ps, port, reg, val);
 restore_page_0:
-	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
+	_mv88e6xxx_phy_write_indirect(ps, port, 0x16, 0x0);
 
 	return ret;
 }
 
-static int _mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page,
-				    int reg)
+static int _mv88e6xxx_phy_page_read(struct mv88e6xxx_priv_state *ps,
+				    int port, int page, int reg)
 {
 	int ret;
 
-	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
+	ret = _mv88e6xxx_phy_write_indirect(ps, port, 0x16, page);
 	if (ret < 0)
 		goto restore_page_0;
 
-	ret = _mv88e6xxx_phy_read_indirect(ds, port, reg);
+	ret = _mv88e6xxx_phy_read_indirect(ps, port, reg);
 restore_page_0:
-	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
+	_mv88e6xxx_phy_write_indirect(ps, port, 0x16, 0x0);
 
 	return ret;
 }
 
-static int mv88e6xxx_power_on_serdes(struct dsa_switch *ds)
+static int mv88e6xxx_power_on_serdes(struct mv88e6xxx_priv_state *ps)
 {
 	int ret;
 
-	ret = _mv88e6xxx_phy_page_read(ds, REG_FIBER_SERDES, PAGE_FIBER_SERDES,
+	ret = _mv88e6xxx_phy_page_read(ps, REG_FIBER_SERDES, PAGE_FIBER_SERDES,
 				       MII_BMCR);
 	if (ret < 0)
 		return ret;
 
 	if (ret & BMCR_PDOWN) {
 		ret &= ~BMCR_PDOWN;
-		ret = _mv88e6xxx_phy_page_write(ds, REG_FIBER_SERDES,
+		ret = _mv88e6xxx_phy_page_write(ps, REG_FIBER_SERDES,
 						PAGE_FIBER_SERDES, MII_BMCR,
 						ret);
 	}
@@ -2452,24 +2446,24 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 
 	mutex_lock(&ps->smi_mutex);
 
-	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6095_family(ds) ||
-	    mv88e6xxx_6065_family(ds) || mv88e6xxx_6320_family(ds)) {
+	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
+	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
+	    mv88e6xxx_6185_family(ps) || mv88e6xxx_6095_family(ps) ||
+	    mv88e6xxx_6065_family(ps) || mv88e6xxx_6320_family(ps)) {
 		/* MAC Forcing register: don't force link, speed,
 		 * duplex or flow control state to any particular
 		 * values on physical ports, but force the CPU port
 		 * and all DSA ports to their maximum bandwidth and
 		 * full duplex.
 		 */
-		reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_PCS_CTRL);
+		reg = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_PCS_CTRL);
 		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
 			reg &= ~PORT_PCS_CTRL_UNFORCED;
 			reg |= PORT_PCS_CTRL_FORCE_LINK |
 				PORT_PCS_CTRL_LINK_UP |
 				PORT_PCS_CTRL_DUPLEX_FULL |
 				PORT_PCS_CTRL_FORCE_DUPLEX;
-			if (mv88e6xxx_6065_family(ds))
+			if (mv88e6xxx_6065_family(ps))
 				reg |= PORT_PCS_CTRL_100;
 			else
 				reg |= PORT_PCS_CTRL_1000;
@@ -2477,7 +2471,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 			reg |= PORT_PCS_CTRL_UNFORCED;
 		}
 
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_PCS_CTRL, reg);
 		if (ret)
 			goto abort;
@@ -2498,19 +2492,19 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 * forwarding of unknown unicasts and multicasts.
 	 */
 	reg = 0;
-	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds) ||
-	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6320_family(ds))
+	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
+	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
+	    mv88e6xxx_6095_family(ps) || mv88e6xxx_6065_family(ps) ||
+	    mv88e6xxx_6185_family(ps) || mv88e6xxx_6320_family(ps))
 		reg = PORT_CONTROL_IGMP_MLD_SNOOP |
 		PORT_CONTROL_USE_TAG | PORT_CONTROL_USE_IP |
 		PORT_CONTROL_STATE_FORWARDING;
 	if (dsa_is_cpu_port(ds, port)) {
-		if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds))
+		if (mv88e6xxx_6095_family(ps) || mv88e6xxx_6185_family(ps))
 			reg |= PORT_CONTROL_DSA_TAG;
-		if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-		    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-		    mv88e6xxx_6320_family(ds)) {
+		if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
+		    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
+		    mv88e6xxx_6320_family(ps)) {
 			if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
 				reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA;
 			else
@@ -2519,20 +2513,20 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
 		}
 
-		if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-		    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-		    mv88e6xxx_6095_family(ds) || mv88e6xxx_6065_family(ds) ||
-		    mv88e6xxx_6185_family(ds) || mv88e6xxx_6320_family(ds)) {
+		if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
+		    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
+		    mv88e6xxx_6095_family(ps) || mv88e6xxx_6065_family(ps) ||
+		    mv88e6xxx_6185_family(ps) || mv88e6xxx_6320_family(ps)) {
 			if (ds->dst->tag_protocol == DSA_TAG_PROTO_EDSA)
 				reg |= PORT_CONTROL_EGRESS_ADD_TAG;
 		}
 	}
 	if (dsa_is_dsa_port(ds, port)) {
-		if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds))
+		if (mv88e6xxx_6095_family(ps) || mv88e6xxx_6185_family(ps))
 			reg |= PORT_CONTROL_DSA_TAG;
-		if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-		    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-		    mv88e6xxx_6320_family(ds)) {
+		if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
+		    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
+		    mv88e6xxx_6320_family(ps)) {
 			reg |= PORT_CONTROL_FRAME_MODE_DSA;
 		}
 
@@ -2541,7 +2535,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
 	}
 	if (reg) {
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_CONTROL, reg);
 		if (ret)
 			goto abort;
@@ -2550,15 +2544,15 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	/* If this port is connected to a SerDes, make sure the SerDes is not
 	 * powered down.
 	 */
-	if (mv88e6xxx_6352_family(ds)) {
-		ret = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_STATUS);
+	if (mv88e6xxx_6352_family(ps)) {
+		ret = _mv88e6xxx_reg_read(ps, REG_PORT(port), PORT_STATUS);
 		if (ret < 0)
 			goto abort;
 		ret &= PORT_STATUS_CMODE_MASK;
 		if ((ret == PORT_STATUS_CMODE_100BASE_X) ||
 		    (ret == PORT_STATUS_CMODE_1000BASE_X) ||
 		    (ret == PORT_STATUS_CMODE_SGMII)) {
-			ret = mv88e6xxx_power_on_serdes(ds);
+			ret = mv88e6xxx_power_on_serdes(ps);
 			if (ret < 0)
 				goto abort;
 		}
@@ -2571,17 +2565,17 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 * copy of all transmitted/received frames on this port to the CPU.
 	 */
 	reg = 0;
-	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-	    mv88e6xxx_6095_family(ds) || mv88e6xxx_6320_family(ds) ||
-	    mv88e6xxx_6185_family(ds))
+	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
+	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
+	    mv88e6xxx_6095_family(ps) || mv88e6xxx_6320_family(ps) ||
+	    mv88e6xxx_6185_family(ps))
 		reg = PORT_CONTROL_2_MAP_DA;
 
-	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6320_family(ds))
+	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
+	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6320_family(ps))
 		reg |= PORT_CONTROL_2_JUMBO_10240;
 
-	if (mv88e6xxx_6095_family(ds) || mv88e6xxx_6185_family(ds)) {
+	if (mv88e6xxx_6095_family(ps) || mv88e6xxx_6185_family(ps)) {
 		/* Set the upstream port this port should use */
 		reg |= dsa_upstream_port(ds);
 		/* enable forwarding of unknown multicast addresses to
@@ -2594,7 +2588,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	reg |= PORT_CONTROL_2_8021Q_DISABLED;
 
 	if (reg) {
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_CONTROL_2, reg);
 		if (ret)
 			goto abort;
@@ -2610,24 +2604,24 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port))
 		reg = PORT_ASSOC_VECTOR_LOCKED_PORT;
 
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_ASSOC_VECTOR, reg);
+	ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_ASSOC_VECTOR, reg);
 	if (ret)
 		goto abort;
 
 	/* Egress rate control 2: disable egress rate control. */
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_RATE_CONTROL_2,
+	ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_RATE_CONTROL_2,
 				   0x0000);
 	if (ret)
 		goto abort;
 
-	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-	    mv88e6xxx_6320_family(ds)) {
+	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
+	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
+	    mv88e6xxx_6320_family(ps)) {
 		/* Do not limit the period of time that this port can
 		 * be paused for by the remote end or the period of
 		 * time that this port can pause the remote end.
 		 */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_PAUSE_CTRL, 0x0000);
 		if (ret)
 			goto abort;
@@ -2636,12 +2630,12 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		 * address database entries that this port is allowed
 		 * to use.
 		 */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_ATU_CONTROL, 0x0000);
 		/* Priority Override: disable DA, SA and VTU priority
 		 * override.
 		 */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_PRI_OVERRIDE, 0x0000);
 		if (ret)
 			goto abort;
@@ -2649,14 +2643,14 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		/* Port Ethertype: use the Ethertype DSA Ethertype
 		 * value.
 		 */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_ETH_TYPE, ETH_P_EDSA);
 		if (ret)
 			goto abort;
 		/* Tag Remap: use an identity 802.1p prio -> switch
 		 * prio mapping.
 		 */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_TAG_REGMAP_0123, 0x3210);
 		if (ret)
 			goto abort;
@@ -2664,18 +2658,18 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 		/* Tag Remap 2: use an identity 802.1p prio -> switch
 		 * prio mapping.
 		 */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_TAG_REGMAP_4567, 0x7654);
 		if (ret)
 			goto abort;
 	}
 
-	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6095_family(ds) ||
-	    mv88e6xxx_6320_family(ds)) {
+	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
+	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
+	    mv88e6xxx_6185_family(ps) || mv88e6xxx_6095_family(ps) ||
+	    mv88e6xxx_6320_family(ps)) {
 		/* Rate Control: disable ingress rate limiting. */
-		ret = _mv88e6xxx_reg_write(ds, REG_PORT(port),
+		ret = _mv88e6xxx_reg_write(ps, REG_PORT(port),
 					   PORT_RATE_CONTROL, 0x0001);
 		if (ret)
 			goto abort;
@@ -2684,7 +2678,7 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	/* Port Control 1: disable trunking, disable sending
 	 * learning messages to this port.
 	 */
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_CONTROL_1, 0x0000);
+	ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_CONTROL_1, 0x0000);
 	if (ret)
 		goto abort;
 
@@ -2692,18 +2686,18 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 	 * database, and allow bidirectional communication between the
 	 * CPU and DSA port(s), and the other ports.
 	 */
-	ret = _mv88e6xxx_port_fid_set(ds, port, port + 1);
+	ret = _mv88e6xxx_port_fid_set(ps, port, port + 1);
 	if (ret)
 		goto abort;
 
-	ret = _mv88e6xxx_port_based_vlan_map(ds, port);
+	ret = _mv88e6xxx_port_based_vlan_map(ps, port);
 	if (ret)
 		goto abort;
 
 	/* Default VLAN ID and priority: don't set a default VLAN
 	 * ID, and set the default packet priority to zero.
 	 */
-	ret = _mv88e6xxx_reg_write(ds, REG_PORT(port), PORT_DEFAULT_VLAN,
+	ret = _mv88e6xxx_reg_write(ps, REG_PORT(port), PORT_DEFAULT_VLAN,
 				   0x0000);
 abort:
 	mutex_unlock(&ps->smi_mutex);
@@ -2725,11 +2719,8 @@ int mv88e6xxx_setup_ports(struct dsa_switch *ds)
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_setup_ports);
 
-int mv88e6xxx_setup_common(struct dsa_switch *ds)
+int mv88e6xxx_setup_common(struct mv88e6xxx_priv_state *ps)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
-	ps->ds = ds;
 	mutex_init(&ps->smi_mutex);
 
 	ps->id = __mv88e6xxx_reg_read(ps->bus, ps->sw_addr, REG_PORT(0),
@@ -2751,46 +2742,46 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 	 * enable address learn messages to be sent to all message
 	 * ports.
 	 */
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_ATU_CONTROL,
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_ATU_CONTROL,
 				  0x0140 | GLOBAL_ATU_CONTROL_LEARN2ALL);
 	if (err)
 		return err;
 
 	/* Configure the IP ToS mapping registers. */
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_0, 0x0000);
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_0, 0x0000);
 	if (err)
 		return err;
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_1, 0x0000);
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_1, 0x0000);
 	if (err)
 		return err;
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_2, 0x5555);
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_2, 0x5555);
 	if (err)
 		return err;
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_3, 0x5555);
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_3, 0x5555);
 	if (err)
 		return err;
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_4, 0xaaaa);
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_4, 0xaaaa);
 	if (err)
 		return err;
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_5, 0xaaaa);
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_5, 0xaaaa);
 	if (err)
 		return err;
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_6, 0xffff);
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_6, 0xffff);
 	if (err)
 		return err;
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IP_PRI_7, 0xffff);
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IP_PRI_7, 0xffff);
 	if (err)
 		return err;
 
 	/* Configure the IEEE 802.1p priority mapping register. */
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_IEEE_PRI, 0xfa41);
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_IEEE_PRI, 0xfa41);
 	if (err)
 		return err;
 
 	/* Send all frames with destination addresses matching
 	 * 01:80:c2:00:00:0x to the CPU port.
 	 */
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_MGMT_EN_0X, 0xffff);
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_MGMT_EN_0X, 0xffff);
 	if (err)
 		return err;
 
@@ -2799,7 +2790,7 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 	 * highest, and send all special multicast frames to the CPU
 	 * port at the highest priority.
 	 */
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_SWITCH_MGMT,
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_SWITCH_MGMT,
 				  0x7 | GLOBAL2_SWITCH_MGMT_RSVD2CPU | 0x70 |
 				  GLOBAL2_SWITCH_MGMT_FORCE_FLOW_CTRL_PRI);
 	if (err)
@@ -2814,17 +2805,17 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 			nexthop = ds->pd->rtable[i] & 0x1f;
 
 		err = mv88e6xxx_reg_write(
-			ds, REG_GLOBAL2,
+			ps, REG_GLOBAL2,
 			GLOBAL2_DEVICE_MAPPING,
 			GLOBAL2_DEVICE_MAPPING_UPDATE |
 			(i << GLOBAL2_DEVICE_MAPPING_TARGET_SHIFT) | nexthop);
-	if (err)
-		return err;
+		if (err)
+			return err;
 	}
 
 	/* Clear all trunk masks. */
 	for (i = 0; i < 8; i++) {
-		err = mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_TRUNK_MASK,
+		err = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_TRUNK_MASK,
 					  0x8000 |
 					  (i << GLOBAL2_TRUNK_MASK_NUM_SHIFT) |
 					  ((1 << ps->num_ports) - 1));
@@ -2835,7 +2826,7 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 	/* Clear all trunk mappings. */
 	for (i = 0; i < 16; i++) {
 		err = mv88e6xxx_reg_write(
-			ds, REG_GLOBAL2,
+			ps, REG_GLOBAL2,
 			GLOBAL2_TRUNK_MAPPING,
 			GLOBAL2_TRUNK_MAPPING_UPDATE |
 			(i << GLOBAL2_TRUNK_MAPPING_ID_SHIFT));
@@ -2843,13 +2834,13 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 			return err;
 	}
 
-	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-	    mv88e6xxx_6320_family(ds)) {
+	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
+	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
+	    mv88e6xxx_6320_family(ps)) {
 		/* Send all frames with destination addresses matching
 		 * 01:80:c2:00:00:2x to the CPU port.
 		 */
-		err = mv88e6xxx_reg_write(ds, REG_GLOBAL2,
+		err = mv88e6xxx_reg_write(ps, REG_GLOBAL2,
 					  GLOBAL2_MGMT_EN_2X, 0xffff);
 		if (err)
 			return err;
@@ -2857,14 +2848,14 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 		/* Initialise cross-chip port VLAN table to reset
 		 * defaults.
 		 */
-		err = mv88e6xxx_reg_write(ds, REG_GLOBAL2,
+		err = mv88e6xxx_reg_write(ps, REG_GLOBAL2,
 					  GLOBAL2_PVT_ADDR, 0x9000);
 		if (err)
 			return err;
 
 		/* Clear the priority override table. */
 		for (i = 0; i < 16; i++) {
-			err = mv88e6xxx_reg_write(ds, REG_GLOBAL2,
+			err = mv88e6xxx_reg_write(ps, REG_GLOBAL2,
 						  GLOBAL2_PRIO_OVERRIDE,
 						  0x8000 | (i << 8));
 			if (err)
@@ -2872,16 +2863,16 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 		}
 	}
 
-	if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-	    mv88e6xxx_6165_family(ds) || mv88e6xxx_6097_family(ds) ||
-	    mv88e6xxx_6185_family(ds) || mv88e6xxx_6095_family(ds) ||
-	    mv88e6xxx_6320_family(ds)) {
+	if (mv88e6xxx_6352_family(ps) || mv88e6xxx_6351_family(ps) ||
+	    mv88e6xxx_6165_family(ps) || mv88e6xxx_6097_family(ps) ||
+	    mv88e6xxx_6185_family(ps) || mv88e6xxx_6095_family(ps) ||
+	    mv88e6xxx_6320_family(ps)) {
 		/* Disable ingress rate limiting by resetting all
 		 * ingress rate limit registers to their initial
 		 * state.
 		 */
 		for (i = 0; i < ps->num_ports; i++) {
-			err = mv88e6xxx_reg_write(ds, REG_GLOBAL2,
+			err = mv88e6xxx_reg_write(ps, REG_GLOBAL2,
 						  GLOBAL2_INGRESS_OP,
 						  0x9000 | (i << 8));
 			if (err)
@@ -2890,24 +2881,24 @@ int mv88e6xxx_setup_global(struct dsa_switch *ds)
 	}
 
 	/* Clear the statistics counters for all ports */
-	err = mv88e6xxx_reg_write(ds, REG_GLOBAL, GLOBAL_STATS_OP,
+	err = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_STATS_OP,
 				  GLOBAL_STATS_OP_FLUSH_ALL);
 	if (err)
 		return err;
 
 	/* Wait for the flush to complete. */
 	mutex_lock(&ps->smi_mutex);
-	err = _mv88e6xxx_stats_wait(ds);
+	err = _mv88e6xxx_stats_wait(ps);
 	if (err < 0)
 		goto unlock;
 
 	/* Clear all ATU entries */
-	err = _mv88e6xxx_atu_flush(ds, 0, true);
+	err = _mv88e6xxx_atu_flush(ps, 0, true);
 	if (err < 0)
 		goto unlock;
 
 	/* Clear all the VTU and STU entries */
-	err = _mv88e6xxx_vtu_stu_flush(ds);
+	err = _mv88e6xxx_vtu_stu_flush(ps);
 unlock:
 	mutex_unlock(&ps->smi_mutex);
 
@@ -2915,9 +2906,8 @@ unlock:
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_setup_global);
 
-int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
+int mv88e6xxx_switch_reset(struct mv88e6xxx_priv_state *ps, bool ppu_active)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
 	struct gpio_desc *gpiod = ps->reset;
 	unsigned long timeout;
@@ -2926,11 +2916,11 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 
 	/* Set all ports to the disabled state. */
 	for (i = 0; i < ps->num_ports; i++) {
-		ret = mv88e6xxx_reg_read(ds, REG_PORT(i), PORT_CONTROL);
+		ret = mv88e6xxx_reg_read(ps, REG_PORT(i), PORT_CONTROL);
 		if (ret < 0)
 			return ret;
 
-		err = mv88e6xxx_reg_write(ds, REG_PORT(i), PORT_CONTROL,
+		err = mv88e6xxx_reg_write(ps, REG_PORT(i), PORT_CONTROL,
 					  ret & 0xfffc);
 		if (err)
 			return err;
@@ -2952,16 +2942,16 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 	 * through global registers 0x18 and 0x19.
 	 */
 	if (ppu_active)
-		err = mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x04, 0xc000);
+		err = mv88e6xxx_reg_write(ps, REG_GLOBAL, 0x04, 0xc000);
 	else
-		err = mv88e6xxx_reg_write(ds, REG_GLOBAL, 0x04, 0xc400);
+		err = mv88e6xxx_reg_write(ps, REG_GLOBAL, 0x04, 0xc400);
 	if (err)
 		return err;
 
 	/* Wait up to one second for reset to complete. */
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-		ret = mv88e6xxx_reg_read(ds, REG_GLOBAL, 0x00);
+		ret = mv88e6xxx_reg_read(ps, REG_GLOBAL, 0x00);
 		if (ret < 0)
 			return ret;
 
@@ -2982,7 +2972,7 @@ int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_page_read(ds, port, page, reg);
+	ret = _mv88e6xxx_phy_page_read(ps, port, page, reg);
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
@@ -2996,17 +2986,16 @@ int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 	int ret;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_page_write(ds, port, page, reg, val);
+	ret = _mv88e6xxx_phy_page_write(ps, port, page, reg, val);
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
 }
 EXPORT_SYMBOL_GPL(mv88e6xxx_phy_page_write);
 
-static int mv88e6xxx_port_to_phy_addr(struct dsa_switch *ds, int port)
+static int mv88e6xxx_port_to_phy_addr(struct mv88e6xxx_priv_state *ps,
+				      int port)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
 	if (port >= 0 && port < ps->num_ports)
 		return port;
 	return -EINVAL;
@@ -3016,14 +3005,14 @@ int
 mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6xxx_port_to_phy_addr(ds, port);
+	int addr = mv88e6xxx_port_to_phy_addr(ps, port);
 	int ret;
 
 	if (addr < 0)
-		return addr;
+		return 0xffff;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_read(ds, addr, regnum);
+	ret = _mv88e6xxx_phy_read(ps, addr, regnum);
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
@@ -3033,14 +3022,14 @@ int
 mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6xxx_port_to_phy_addr(ds, port);
+	int addr = mv88e6xxx_port_to_phy_addr(ps, port);
 	int ret;
 
 	if (addr < 0)
-		return addr;
+		return 0xffff;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_write(ds, addr, regnum, val);
+	ret = _mv88e6xxx_phy_write(ps, addr, regnum, val);
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
@@ -3050,14 +3039,14 @@ int
 mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6xxx_port_to_phy_addr(ds, port);
+	int addr = mv88e6xxx_port_to_phy_addr(ps, port);
 	int ret;
 
 	if (addr < 0)
-		return addr;
+		return 0xffff;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_read_indirect(ds, addr, regnum);
+	ret = _mv88e6xxx_phy_read_indirect(ps, addr, regnum);
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
@@ -3068,14 +3057,14 @@ mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
 			     u16 val)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int addr = mv88e6xxx_port_to_phy_addr(ds, port);
+	int addr = mv88e6xxx_port_to_phy_addr(ps, port);
 	int ret;
 
 	if (addr < 0)
 		return addr;
 
 	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_phy_write_indirect(ds, addr, regnum, val);
+	ret = _mv88e6xxx_phy_write_indirect(ps, addr, regnum, val);
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
@@ -3093,44 +3082,45 @@ static int mv88e61xx_get_temp(struct dsa_switch *ds, int *temp)
 
 	mutex_lock(&ps->smi_mutex);
 
-	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x6);
+	ret = _mv88e6xxx_phy_write(ps, 0x0, 0x16, 0x6);
 	if (ret < 0)
 		goto error;
 
 	/* Enable temperature sensor */
-	ret = _mv88e6xxx_phy_read(ds, 0x0, 0x1a);
+	ret = _mv88e6xxx_phy_read(ps, 0x0, 0x1a);
 	if (ret < 0)
 		goto error;
 
-	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret | (1 << 5));
+	ret = _mv88e6xxx_phy_write(ps, 0x0, 0x1a, ret | (1 << 5));
 	if (ret < 0)
 		goto error;
 
 	/* Wait for temperature to stabilize */
 	usleep_range(10000, 12000);
 
-	val = _mv88e6xxx_phy_read(ds, 0x0, 0x1a);
+	val = _mv88e6xxx_phy_read(ps, 0x0, 0x1a);
 	if (val < 0) {
 		ret = val;
 		goto error;
 	}
 
 	/* Disable temperature sensor */
-	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret & ~(1 << 5));
+	ret = _mv88e6xxx_phy_write(ps, 0x0, 0x1a, ret & ~(1 << 5));
 	if (ret < 0)
 		goto error;
 
 	*temp = ((val & 0x1f) - 5) * 5;
 
 error:
-	_mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x0);
+	_mv88e6xxx_phy_write(ps, 0x0, 0x16, 0x0);
 	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
 
 static int mv88e63xx_get_temp(struct dsa_switch *ds, int *temp)
 {
-	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
 	int ret;
 
 	*temp = 0;
@@ -3146,7 +3136,9 @@ static int mv88e63xx_get_temp(struct dsa_switch *ds, int *temp)
 
 int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 {
-	if (mv88e6xxx_6320_family(ds) || mv88e6xxx_6352_family(ds))
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	if (mv88e6xxx_6320_family(ps) || mv88e6xxx_6352_family(ps))
 		return mv88e63xx_get_temp(ds, temp);
 
 	return mv88e61xx_get_temp(ds, temp);
@@ -3155,10 +3147,11 @@ EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp);
 
 int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp)
 {
-	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
 	int ret;
 
-	if (!mv88e6xxx_6320_family(ds) && !mv88e6xxx_6352_family(ds))
+	if (!mv88e6xxx_6320_family(ps) && !mv88e6xxx_6352_family(ps))
 		return -EOPNOTSUPP;
 
 	*temp = 0;
@@ -3175,10 +3168,11 @@ EXPORT_SYMBOL_GPL(mv88e6xxx_get_temp_limit);
 
 int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp)
 {
-	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
 	int ret;
 
-	if (!mv88e6xxx_6320_family(ds) && !mv88e6xxx_6352_family(ds))
+	if (!mv88e6xxx_6320_family(ps) && !mv88e6xxx_6352_family(ps))
 		return -EOPNOTSUPP;
 
 	ret = mv88e6xxx_phy_page_read(ds, phy, 6, 26);
@@ -3192,10 +3186,11 @@ EXPORT_SYMBOL_GPL(mv88e6xxx_set_temp_limit);
 
 int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 {
-	int phy = mv88e6xxx_6320_family(ds) ? 3 : 0;
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int phy = mv88e6xxx_6320_family(ps) ? 3 : 0;
 	int ret;
 
-	if (!mv88e6xxx_6320_family(ds) && !mv88e6xxx_6352_family(ds))
+	if (!mv88e6xxx_6320_family(ps) && !mv88e6xxx_6352_family(ps))
 		return -EOPNOTSUPP;
 
 	*alarm = false;
@@ -3286,6 +3281,7 @@ int mv88e6xxx_probe(struct mdio_device *mdiodev, struct dsa_switch_driver *ops,
 
 	ps = (struct mv88e6xxx_priv_state *)(ds + 1);
 	ds->priv = ps;
+	ps->dev = dev;
 	ps->ds = ds;
 	ps->bus = mdiodev->bus;
 	ps->sw_addr = mdiodev->addr;
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 6d1b6207144d..3f7a432c9050 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -401,6 +401,9 @@ struct mv88e6xxx_priv_state {
 	/* The dsa_switch this private structure is related to */
 	struct dsa_switch *ds;
 
+	/* The device this structure is associated to */
+	struct device *dev;
+
 	/* When using multi-chip addressing, this mutex protects
 	 * access to the indirect access registers.  (In single-chip
 	 * mode, this mutex is effectively useless.)
@@ -468,17 +471,18 @@ struct mv88e6xxx_hw_stat {
 	enum stat_type type;
 };
 
-int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active);
+int mv88e6xxx_switch_reset(struct mv88e6xxx_priv_state *ps, bool ppu_active);
 char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
 			  int sw_addr, void **priv,
 			  const struct mv88e6xxx_switch_id *table,
 			  unsigned int num);
 
 int mv88e6xxx_setup_ports(struct dsa_switch *ds);
-int mv88e6xxx_setup_common(struct dsa_switch *ds);
+int mv88e6xxx_setup_common(struct mv88e6xxx_priv_state *ps);
 int mv88e6xxx_setup_global(struct dsa_switch *ds);
-int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg);
-int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val);
+int mv88e6xxx_reg_read(struct mv88e6xxx_priv_state *ps, int addr, int reg);
+int mv88e6xxx_reg_write(struct mv88e6xxx_priv_state *ps, int addr,
+			int reg, u16 val);
 int mv88e6xxx_set_addr_direct(struct dsa_switch *ds, u8 *addr);
 int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr);
 int mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum);
@@ -486,7 +490,7 @@ int mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val);
 int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum);
 int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
 				 u16 val);
-void mv88e6xxx_ppu_state_init(struct dsa_switch *ds);
+void mv88e6xxx_ppu_state_init(struct mv88e6xxx_priv_state *ps);
 int mv88e6xxx_phy_read_ppu(struct dsa_switch *ds, int addr, int regnum);
 int mv88e6xxx_phy_write_ppu(struct dsa_switch *ds, int addr,
 			    int regnum, u16 val);
-- 
2.7.0
