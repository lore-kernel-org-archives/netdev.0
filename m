From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv3 net-next 1/2] net: dsa: mv88e6xxx: Add helper for accessing port registers
Date: Wed, 21 Sep 2016 01:40:31 +0200
Message-ID: <1474414832-1638-2-git-send-email-andrew@lunn.ch>
References: <1474414832-1638-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57151 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754023AbcITXlK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 19:41:10 -0400
In-Reply-To: <1474414832-1638-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a device coming soon which places its port registers
somewhere different to all other Marvell switches supported so far.
Add helper functions for reading/writing port registers, making it
easier to handle this new device.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
v2:
 Call mv88e6xxx_{read|write} in wrappers
 Change some (err < 0) to plain (err)
v3:
 reg = reg & foo -> reg &= foo
 Fix over zealous s/ret/err
---
 drivers/net/dsa/mv88e6xxx/chip.c      | 370 +++++++++++++++++-----------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |   1 -
 2 files changed, 182 insertions(+), 189 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 70a812d159c9..f7014866e8ef 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -216,6 +216,22 @@ int mv88e6xxx_write(struct mv88e6xxx_chip *chip, int addr, int reg, u16 val)
 	return 0;
 }
 
+int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port, int reg,
+			u16 *val)
+{
+	int addr = chip->info->port_base_addr + port;
+
+	return mv88e6xxx_read(chip, addr, reg, val);
+}
+
+int mv88e6xxx_port_write(struct mv88e6xxx_chip *chip, int port, int reg,
+			 u16 val)
+{
+	int addr = chip->info->port_base_addr + port;
+
+	return mv88e6xxx_write(chip, addr, reg, val);
+}
+
 static int mv88e6xxx_phy_read(struct mv88e6xxx_chip *chip, int phy,
 			      int reg, u16 *val)
 {
@@ -585,23 +601,23 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 				  struct phy_device *phydev)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
-	u32 reg;
-	int ret;
+	u16 reg;
+	int err;
 
 	if (!phy_is_pseudo_fixed_link(phydev))
 		return;
 
 	mutex_lock(&chip->reg_lock);
 
-	ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_PCS_CTRL);
-	if (ret < 0)
+	err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
+	if (err)
 		goto out;
 
-	reg = ret & ~(PORT_PCS_CTRL_LINK_UP |
-		      PORT_PCS_CTRL_FORCE_LINK |
-		      PORT_PCS_CTRL_DUPLEX_FULL |
-		      PORT_PCS_CTRL_FORCE_DUPLEX |
-		      PORT_PCS_CTRL_UNFORCED);
+	reg &= ~(PORT_PCS_CTRL_LINK_UP |
+		 PORT_PCS_CTRL_FORCE_LINK |
+		 PORT_PCS_CTRL_DUPLEX_FULL |
+		 PORT_PCS_CTRL_FORCE_DUPLEX |
+		 PORT_PCS_CTRL_UNFORCED);
 
 	reg |= PORT_PCS_CTRL_FORCE_LINK;
 	if (phydev->link)
@@ -639,7 +655,7 @@ static void mv88e6xxx_adjust_link(struct dsa_switch *ds, int port,
 			reg |= (PORT_PCS_CTRL_RGMII_DELAY_RXCLK |
 				PORT_PCS_CTRL_RGMII_DELAY_TXCLK);
 	}
-	_mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_PCS_CTRL, reg);
+	mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
 
 out:
 	mutex_unlock(&chip->reg_lock);
@@ -799,22 +815,22 @@ static uint64_t _mv88e6xxx_get_ethtool_stat(struct mv88e6xxx_chip *chip,
 {
 	u32 low;
 	u32 high = 0;
-	int ret;
+	int err;
+	u16 reg;
 	u64 value;
 
 	switch (s->type) {
 	case PORT:
-		ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), s->reg);
-		if (ret < 0)
+		err = mv88e6xxx_port_read(chip, port, s->reg, &reg);
+		if (err)
 			return UINT64_MAX;
 
-		low = ret;
+		low = reg;
 		if (s->sizeof_stat == 4) {
-			ret = _mv88e6xxx_reg_read(chip, REG_PORT(port),
-						  s->reg + 1);
-			if (ret < 0)
+			err = mv88e6xxx_port_read(chip, port, s->reg + 1, &reg);
+			if (err)
 				return UINT64_MAX;
-			high = ret;
+			high = reg;
 		}
 		break;
 	case BANK0:
@@ -893,6 +909,8 @@ static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			       struct ethtool_regs *regs, void *_p)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
+	int err;
+	u16 reg;
 	u16 *p = _p;
 	int i;
 
@@ -903,11 +921,10 @@ static void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 	mutex_lock(&chip->reg_lock);
 
 	for (i = 0; i < 32; i++) {
-		int ret;
 
-		ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), i);
-		if (ret >= 0)
-			p[i] = ret;
+		err = mv88e6xxx_port_read(chip, port, i, &reg);
+		if (!err)
+			p[i] = reg;
 	}
 
 	mutex_unlock(&chip->reg_lock);
@@ -938,7 +955,7 @@ static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 	e->eee_enabled = !!(reg & 0x0200);
 	e->tx_lpi_enabled = !!(reg & 0x0100);
 
-	err = mv88e6xxx_read(chip, REG_PORT(port), PORT_STATUS, &reg);
+	err = mv88e6xxx_port_read(chip, port, PORT_STATUS, &reg);
 	if (err)
 		goto out;
 
@@ -1106,12 +1123,13 @@ static int _mv88e6xxx_port_state(struct mv88e6xxx_chip *chip, int port,
 				 u8 state)
 {
 	struct dsa_switch *ds = chip->ds;
-	int reg, ret = 0;
+	u16 reg;
+	int err;
 	u8 oldstate;
 
-	reg = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_CONTROL);
-	if (reg < 0)
-		return reg;
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL, &reg);
+	if (err)
+		return err;
 
 	oldstate = reg & PORT_CONTROL_STATE_MASK;
 
@@ -1124,23 +1142,22 @@ static int _mv88e6xxx_port_state(struct mv88e6xxx_chip *chip, int port,
 		     oldstate == PORT_CONTROL_STATE_FORWARDING) &&
 		    (state == PORT_CONTROL_STATE_DISABLED ||
 		     state == PORT_CONTROL_STATE_BLOCKING)) {
-			ret = _mv88e6xxx_atu_remove(chip, 0, port, false);
-			if (ret)
-				return ret;
+			err = _mv88e6xxx_atu_remove(chip, 0, port, false);
+			if (err)
+				return err;
 		}
 
 		reg = (reg & ~PORT_CONTROL_STATE_MASK) | state;
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_CONTROL,
-					   reg);
-		if (ret)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+		if (err)
+			return err;
 
 		netdev_dbg(ds->ports[port].netdev, "PortState %s (was %s)\n",
 			   mv88e6xxx_port_state_names[state],
 			   mv88e6xxx_port_state_names[oldstate]);
 	}
 
-	return ret;
+	return err;
 }
 
 static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
@@ -1149,7 +1166,8 @@ static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 	const u16 mask = (1 << chip->info->num_ports) - 1;
 	struct dsa_switch *ds = chip->ds;
 	u16 output_ports = 0;
-	int reg;
+	u16 reg;
+	int err;
 	int i;
 
 	/* allow CPU port or DSA link(s) to send frames to every port */
@@ -1170,14 +1188,14 @@ static int _mv88e6xxx_port_based_vlan_map(struct mv88e6xxx_chip *chip, int port)
 	/* prevent frames from going back out of the port they came in on */
 	output_ports &= ~BIT(port);
 
-	reg = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_BASE_VLAN);
-	if (reg < 0)
-		return reg;
+	err = mv88e6xxx_port_read(chip, port, PORT_BASE_VLAN, &reg);
+	if (err)
+		return err;
 
 	reg &= ~mask;
 	reg |= output_ports & mask;
 
-	return _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_BASE_VLAN, reg);
+	return mv88e6xxx_port_write(chip, port, PORT_BASE_VLAN, reg);
 }
 
 static void mv88e6xxx_port_stp_state_set(struct dsa_switch *ds, int port,
@@ -1218,23 +1236,22 @@ static int _mv88e6xxx_port_pvid(struct mv88e6xxx_chip *chip, int port,
 				u16 *new, u16 *old)
 {
 	struct dsa_switch *ds = chip->ds;
-	u16 pvid;
-	int ret;
+	u16 pvid, reg;
+	int err;
 
-	ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_DEFAULT_VLAN);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_port_read(chip, port, PORT_DEFAULT_VLAN, &reg);
+	if (err)
+		return err;
 
-	pvid = ret & PORT_DEFAULT_VLAN_MASK;
+	pvid = reg & PORT_DEFAULT_VLAN_MASK;
 
 	if (new) {
-		ret &= ~PORT_DEFAULT_VLAN_MASK;
-		ret |= *new & PORT_DEFAULT_VLAN_MASK;
+		reg &= ~PORT_DEFAULT_VLAN_MASK;
+		reg |= *new & PORT_DEFAULT_VLAN_MASK;
 
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-					   PORT_DEFAULT_VLAN, ret);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, reg);
+		if (err)
+			return err;
 
 		netdev_dbg(ds->ports[port].netdev,
 			   "DefaultVID %d (was %d)\n", *new, pvid);
@@ -1613,7 +1630,8 @@ static int _mv88e6xxx_port_fid(struct mv88e6xxx_chip *chip, int port,
 	struct dsa_switch *ds = chip->ds;
 	u16 upper_mask;
 	u16 fid;
-	int ret;
+	u16 reg;
+	int err;
 
 	if (mv88e6xxx_num_databases(chip) == 4096)
 		upper_mask = 0xff;
@@ -1623,37 +1641,35 @@ static int _mv88e6xxx_port_fid(struct mv88e6xxx_chip *chip, int port,
 		return -EOPNOTSUPP;
 
 	/* Port's default FID bits 3:0 are located in reg 0x06, offset 12 */
-	ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_BASE_VLAN);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_port_read(chip, port, PORT_BASE_VLAN, &reg);
+	if (err)
+		return err;
 
-	fid = (ret & PORT_BASE_VLAN_FID_3_0_MASK) >> 12;
+	fid = (reg & PORT_BASE_VLAN_FID_3_0_MASK) >> 12;
 
 	if (new) {
-		ret &= ~PORT_BASE_VLAN_FID_3_0_MASK;
-		ret |= (*new << 12) & PORT_BASE_VLAN_FID_3_0_MASK;
+		reg &= ~PORT_BASE_VLAN_FID_3_0_MASK;
+		reg |= (*new << 12) & PORT_BASE_VLAN_FID_3_0_MASK;
 
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_BASE_VLAN,
-					   ret);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_BASE_VLAN, reg);
+		if (err)
+			return err;
 	}
 
 	/* Port's default FID bits 11:4 are located in reg 0x05, offset 0 */
-	ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_CONTROL_1);
-	if (ret < 0)
-		return ret;
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_1, &reg);
+	if (err)
+		return err;
 
-	fid |= (ret & upper_mask) << 4;
+	fid |= (reg & upper_mask) << 4;
 
 	if (new) {
-		ret &= ~upper_mask;
-		ret |= (*new >> 4) & upper_mask;
+		reg &= ~upper_mask;
+		reg |= (*new >> 4) & upper_mask;
 
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_CONTROL_1,
-					   ret);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_1, reg);
+		if (err)
+			return err;
 
 		netdev_dbg(ds->ports[port].netdev,
 			   "FID %d (was %d)\n", *new, fid);
@@ -1865,26 +1881,26 @@ static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_chip *chip = ds->priv;
 	u16 old, new = vlan_filtering ? PORT_CONTROL_2_8021Q_SECURE :
 		PORT_CONTROL_2_8021Q_DISABLED;
-	int ret;
+	u16 reg;
+	int err;
 
 	if (!mv88e6xxx_has(chip, MV88E6XXX_FLAG_VTU))
 		return -EOPNOTSUPP;
 
 	mutex_lock(&chip->reg_lock);
 
-	ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_CONTROL_2);
-	if (ret < 0)
+	err = mv88e6xxx_port_read(chip, port, PORT_CONTROL_2, &reg);
+	if (err)
 		goto unlock;
 
-	old = ret & PORT_CONTROL_2_8021Q_MASK;
+	old = reg & PORT_CONTROL_2_8021Q_MASK;
 
 	if (new != old) {
-		ret &= ~PORT_CONTROL_2_8021Q_MASK;
-		ret |= new & PORT_CONTROL_2_8021Q_MASK;
+		reg &= ~PORT_CONTROL_2_8021Q_MASK;
+		reg |= new & PORT_CONTROL_2_8021Q_MASK;
 
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_CONTROL_2,
-					   ret);
-		if (ret < 0)
+		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+		if (err)
 			goto unlock;
 
 		netdev_dbg(ds->ports[port].netdev, "802.1Q Mode %s (was %s)\n",
@@ -1892,11 +1908,11 @@ static int mv88e6xxx_port_vlan_filtering(struct dsa_switch *ds, int port,
 			   mv88e6xxx_port_8021q_mode_names[old]);
 	}
 
-	ret = 0;
+	err = 0;
 unlock:
 	mutex_unlock(&chip->reg_lock);
 
-	return ret;
+	return err;
 }
 
 static int
@@ -2364,19 +2380,20 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
 	struct gpio_desc *gpiod = chip->reset;
 	unsigned long timeout;
-	int ret;
+	int err, ret;
+	u16 reg;
 	int i;
 
 	/* Set all ports to the disabled state. */
 	for (i = 0; i < chip->info->num_ports; i++) {
-		ret = _mv88e6xxx_reg_read(chip, REG_PORT(i), PORT_CONTROL);
-		if (ret < 0)
-			return ret;
+		err = mv88e6xxx_port_read(chip, i, PORT_CONTROL, &reg);
+		if (err)
+			return err;
 
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(i), PORT_CONTROL,
-					   ret & 0xfffc);
-		if (ret)
-			return ret;
+		err = mv88e6xxx_port_write(chip, i, PORT_CONTROL,
+					   reg & 0xfffc);
+		if (err)
+			return err;
 	}
 
 	/* Wait for transmit queues to drain. */
@@ -2395,11 +2412,11 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 	 * through global registers 0x18 and 0x19.
 	 */
 	if (ppu_active)
-		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, 0x04, 0xc000);
+		err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, 0x04, 0xc000);
 	else
-		ret = _mv88e6xxx_reg_write(chip, REG_GLOBAL, 0x04, 0xc400);
-	if (ret)
-		return ret;
+		err = _mv88e6xxx_reg_write(chip, REG_GLOBAL, 0x04, 0xc400);
+	if (err)
+		return err;
 
 	/* Wait up to one second for reset to complete. */
 	timeout = jiffies + 1 * HZ;
@@ -2413,11 +2430,11 @@ static int mv88e6xxx_switch_reset(struct mv88e6xxx_chip *chip)
 		usleep_range(1000, 2000);
 	}
 	if (time_after(jiffies, timeout))
-		ret = -ETIMEDOUT;
+		err = -ETIMEDOUT;
 	else
-		ret = 0;
+		err = 0;
 
-	return ret;
+	return err;
 }
 
 static int mv88e6xxx_serdes_power_on(struct mv88e6xxx_chip *chip)
@@ -2438,21 +2455,10 @@ static int mv88e6xxx_serdes_power_on(struct mv88e6xxx_chip *chip)
 	return err;
 }
 
-static int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port,
-			       int reg, u16 *val)
-{
-	int addr = chip->info->port_base_addr + port;
-
-	if (port >= chip->info->num_ports)
-		return -EINVAL;
-
-	return mv88e6xxx_read(chip, addr, reg, val);
-}
-
 static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 {
 	struct dsa_switch *ds = chip->ds;
-	int ret;
+	int err;
 	u16 reg;
 
 	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
@@ -2465,7 +2471,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 		 * and all DSA ports to their maximum bandwidth and
 		 * full duplex.
 		 */
-		reg = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_PCS_CTRL);
+		err = mv88e6xxx_port_read(chip, port, PORT_PCS_CTRL, &reg);
 		if (dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)) {
 			reg &= ~PORT_PCS_CTRL_UNFORCED;
 			reg |= PORT_PCS_CTRL_FORCE_LINK |
@@ -2480,10 +2486,9 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 			reg |= PORT_PCS_CTRL_UNFORCED;
 		}
 
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-					   PORT_PCS_CTRL, reg);
-		if (ret)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_PCS_CTRL, reg);
+		if (err)
+			return err;
 	}
 
 	/* Port Control: disable Drop-on-Unlock, disable Drop-on-Lock,
@@ -2534,26 +2539,25 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
 	}
 	if (reg) {
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-					   PORT_CONTROL, reg);
-		if (ret)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL, reg);
+		if (err)
+			return err;
 	}
 
 	/* If this port is connected to a SerDes, make sure the SerDes is not
 	 * powered down.
 	 */
 	if (mv88e6xxx_has(chip, MV88E6XXX_FLAGS_SERDES)) {
-		ret = _mv88e6xxx_reg_read(chip, REG_PORT(port), PORT_STATUS);
-		if (ret < 0)
-			return ret;
-		ret &= PORT_STATUS_CMODE_MASK;
-		if ((ret == PORT_STATUS_CMODE_100BASE_X) ||
-		    (ret == PORT_STATUS_CMODE_1000BASE_X) ||
-		    (ret == PORT_STATUS_CMODE_SGMII)) {
-			ret = mv88e6xxx_serdes_power_on(chip);
-			if (ret < 0)
-				return ret;
+		err = mv88e6xxx_port_read(chip, port, PORT_STATUS, &reg);
+		if (err)
+			return err;
+		reg &= PORT_STATUS_CMODE_MASK;
+		if ((reg == PORT_STATUS_CMODE_100BASE_X) ||
+		    (reg == PORT_STATUS_CMODE_1000BASE_X) ||
+		    (reg == PORT_STATUS_CMODE_SGMII)) {
+			err = mv88e6xxx_serdes_power_on(chip);
+			if (err < 0)
+				return err;
 		}
 	}
 
@@ -2587,10 +2591,9 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	reg |= PORT_CONTROL_2_8021Q_DISABLED;
 
 	if (reg) {
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-					   PORT_CONTROL_2, reg);
-		if (ret)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_2, reg);
+		if (err)
+			return err;
 	}
 
 	/* Port Association Vector: when learning source addresses
@@ -2603,16 +2606,14 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (dsa_is_cpu_port(ds, port))
 		reg = 0;
 
-	ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_ASSOC_VECTOR,
-				   reg);
-	if (ret)
-		return ret;
+	err = mv88e6xxx_port_write(chip, port, PORT_ASSOC_VECTOR, reg);
+	if (err)
+		return err;
 
 	/* Egress rate control 2: disable egress rate control. */
-	ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_RATE_CONTROL_2,
-				   0x0000);
-	if (ret)
-		return ret;
+	err = mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL_2, 0x0000);
+	if (err)
+		return err;
 
 	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
 	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
@@ -2621,96 +2622,89 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 		 * be paused for by the remote end or the period of
 		 * time that this port can pause the remote end.
 		 */
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-					   PORT_PAUSE_CTRL, 0x0000);
-		if (ret)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_PAUSE_CTRL, 0x0000);
+		if (err)
+			return err;
 
 		/* Port ATU control: disable limiting the number of
 		 * address database entries that this port is allowed
 		 * to use.
 		 */
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-					   PORT_ATU_CONTROL, 0x0000);
+		err = mv88e6xxx_port_write(chip, port, PORT_ATU_CONTROL,
+					   0x0000);
 		/* Priority Override: disable DA, SA and VTU priority
 		 * override.
 		 */
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-					   PORT_PRI_OVERRIDE, 0x0000);
-		if (ret)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_PRI_OVERRIDE,
+					   0x0000);
+		if (err)
+			return err;
 
 		/* Port Ethertype: use the Ethertype DSA Ethertype
 		 * value.
 		 */
 		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EDSA)) {
-			ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-						   PORT_ETH_TYPE, ETH_P_EDSA);
-			if (ret)
-				return ret;
+			err = mv88e6xxx_port_write(chip, port, PORT_ETH_TYPE,
+						   ETH_P_EDSA);
+			if (err)
+				return err;
 		}
 
 		/* Tag Remap: use an identity 802.1p prio -> switch
 		 * prio mapping.
 		 */
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-					   PORT_TAG_REGMAP_0123, 0x3210);
-		if (ret)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_0123,
+					   0x3210);
+		if (err)
+			return err;
 
 		/* Tag Remap 2: use an identity 802.1p prio -> switch
 		 * prio mapping.
 		 */
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-					   PORT_TAG_REGMAP_4567, 0x7654);
-		if (ret)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_TAG_REGMAP_4567,
+					   0x7654);
+		if (err)
+			return err;
 	}
 
 	/* Rate Control: disable ingress rate limiting. */
 	if (mv88e6xxx_6352_family(chip) || mv88e6xxx_6351_family(chip) ||
 	    mv88e6xxx_6165_family(chip) || mv88e6xxx_6097_family(chip) ||
 	    mv88e6xxx_6320_family(chip)) {
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-					   PORT_RATE_CONTROL, 0x0001);
-		if (ret)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL,
+					   0x0001);
+		if (err)
+			return err;
 	} else if (mv88e6xxx_6185_family(chip) || mv88e6xxx_6095_family(chip)) {
-		ret = _mv88e6xxx_reg_write(chip, REG_PORT(port),
-					   PORT_RATE_CONTROL, 0x0000);
-		if (ret)
-			return ret;
+		err = mv88e6xxx_port_write(chip, port, PORT_RATE_CONTROL,
+					   0x0000);
+		if (err)
+			return err;
 	}
 
 	/* Port Control 1: disable trunking, disable sending
 	 * learning messages to this port.
 	 */
-	ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_CONTROL_1,
-				   0x0000);
-	if (ret)
-		return ret;
+	err = mv88e6xxx_port_write(chip, port, PORT_CONTROL_1, 0x0000);
+	if (err)
+		return err;
 
 	/* Port based VLAN map: give each port the same default address
 	 * database, and allow bidirectional communication between the
 	 * CPU and DSA port(s), and the other ports.
 	 */
-	ret = _mv88e6xxx_port_fid_set(chip, port, 0);
-	if (ret)
-		return ret;
+	err = _mv88e6xxx_port_fid_set(chip, port, 0);
+	if (err)
+		return err;
 
-	ret = _mv88e6xxx_port_based_vlan_map(chip, port);
-	if (ret)
-		return ret;
+	err = _mv88e6xxx_port_based_vlan_map(chip, port);
+	if (err)
+		return err;
 
 	/* Default VLAN ID and priority: don't set a default VLAN
 	 * ID, and set the default packet priority to zero.
 	 */
-	ret = _mv88e6xxx_reg_write(chip, REG_PORT(port), PORT_DEFAULT_VLAN,
-				   0x0000);
-	if (ret)
-		return ret;
-
-	return 0;
+	return mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, 0x0000);
 }
 
 static int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
diff --git a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
index 52f3f5231f51..e349d0d64645 100644
--- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
@@ -37,7 +37,6 @@
 #define ADDR_SERDES		0x0f
 #define SERDES_PAGE_FIBER	0x01
 
-#define REG_PORT(p)		(0x10 + (p))
 #define PORT_STATUS		0x00
 #define PORT_STATUS_PAUSE_EN	BIT(15)
 #define PORT_STATUS_MY_PAUSE	BIT(14)
-- 
2.9.3
