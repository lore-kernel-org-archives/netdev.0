From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 07/10] net: dsa: mv88e6xxx: Replace PHY mutex by SMI mutex
Date: Wed,  6 May 2015 01:09:53 +0200
Message-ID: <1430867396-2268-8-git-send-email-andrew@lunn.ch>
References: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44496 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751116AbbEEXOv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 19:14:51 -0400
In-Reply-To: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SMI bus is the bottleneck in all switch operations, not the
granularity of locks. Replace the PHY mutex by the SMI mutex to make
the locking concept simpler.

The REG_READ/REG_WRITE macros cannot be used while holding the SMI
mutex, since they try to acquire it. Replace with calls to the
appropriate function which does not try to get the mutex.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 121 +++++++++++++++++++++++---------------------
 drivers/net/dsa/mv88e6xxx.h |   1 -
 2 files changed, 63 insertions(+), 59 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index f38d8dfa934a..e974d26c1a03 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -199,20 +199,20 @@ int mv88e6xxx_set_addr_indirect(struct dsa_switch *ds, u8 *addr)
 	return 0;
 }
 
-/* Must be called with phy mutex held */
+/* Must be called with SMI mutex held */
 static int _mv88e6xxx_phy_read(struct dsa_switch *ds, int addr, int regnum)
 {
 	if (addr >= 0)
-		return mv88e6xxx_reg_read(ds, addr, regnum);
+		return _mv88e6xxx_reg_read(ds, addr, regnum);
 	return 0xffff;
 }
 
-/* Must be called with phy mutex held */
+/* Must be called with SMI mutex held */
 static int _mv88e6xxx_phy_write(struct dsa_switch *ds, int addr, int regnum,
 				u16 val)
 {
 	if (addr >= 0)
-		return mv88e6xxx_reg_write(ds, addr, regnum, val);
+		return _mv88e6xxx_reg_write(ds, addr, regnum, val);
 	return 0;
 }
 
@@ -762,7 +762,7 @@ int  mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 
 	*temp = 0;
 
-	mutex_lock(&ps->phy_mutex);
+	mutex_lock(&ps->smi_mutex);
 
 	ret = _mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x6);
 	if (ret < 0)
@@ -795,19 +795,23 @@ int  mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
 
 error:
 	_mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x0);
-	mutex_unlock(&ps->phy_mutex);
+	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
 #endif /* CONFIG_NET_DSA_HWMON */
 
-static int mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
+/* Must be called with SMI lock held */
+static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
+			   u16 mask)
 {
 	unsigned long timeout = jiffies + HZ / 10;
 
 	while (time_before(jiffies, timeout)) {
 		int ret;
 
-		ret = REG_READ(reg, offset);
+		ret = _mv88e6xxx_reg_read(ds, reg, offset);
+		if (ret < 0)
+			return ret;
 		if (!(ret & mask))
 			return 0;
 
@@ -816,10 +820,22 @@ static int mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
 	return -ETIMEDOUT;
 }
 
-int mv88e6xxx_phy_wait(struct dsa_switch *ds)
+static int mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_wait(ds, reg, offset, mask);
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
+static int _mv88e6xxx_phy_wait(struct dsa_switch *ds)
 {
-	return mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_SMI_OP,
-			      GLOBAL2_SMI_OP_BUSY);
+	return _mv88e6xxx_wait(ds, REG_GLOBAL2, GLOBAL2_SMI_OP,
+			       GLOBAL2_SMI_OP_BUSY);
 }
 
 int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds)
@@ -835,56 +851,46 @@ int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds)
 }
 
 /* Must be called with SMI lock held */
-static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
-{
-	unsigned long timeout = jiffies + HZ / 10;
-
-	while (time_before(jiffies, timeout)) {
-		int ret;
-
-		ret = _mv88e6xxx_reg_read(ds, reg, offset);
-		if (ret < 0)
-			return ret;
-		if (!(ret & mask))
-			return 0;
-
-		usleep_range(1000, 2000);
-	}
-	return -ETIMEDOUT;
-}
-
-/* Must be called with SMI lock held */
 static int _mv88e6xxx_atu_wait(struct dsa_switch *ds)
 {
 	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_ATU_OP,
 			       GLOBAL_ATU_OP_BUSY);
 }
 
-/* Must be called with phy mutex held */
+/* Must be called with SMI mutex held */
 static int _mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr,
 					int regnum)
 {
 	int ret;
 
-	REG_WRITE(REG_GLOBAL2, GLOBAL2_SMI_OP,
-		  GLOBAL2_SMI_OP_22_READ | (addr << 5) | regnum);
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_SMI_OP,
+				   GLOBAL2_SMI_OP_22_READ | (addr << 5) |
+				   regnum);
+	if (ret < 0)
+		return ret;
 
-	ret = mv88e6xxx_phy_wait(ds);
+	ret = _mv88e6xxx_phy_wait(ds);
 	if (ret < 0)
 		return ret;
 
-	return REG_READ(REG_GLOBAL2, GLOBAL2_SMI_DATA);
+	return _mv88e6xxx_reg_read(ds, REG_GLOBAL2, GLOBAL2_SMI_DATA);
 }
 
-/* Must be called with phy mutex held */
+/* Must be called with SMI mutex held */
 static int _mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr,
 					 int regnum, u16 val)
 {
-	REG_WRITE(REG_GLOBAL2, GLOBAL2_SMI_DATA, val);
-	REG_WRITE(REG_GLOBAL2, GLOBAL2_SMI_OP,
-		  GLOBAL2_SMI_OP_22_WRITE | (addr << 5) | regnum);
+	int ret;
+
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_SMI_DATA, val);
+	if (ret < 0)
+		return ret;
 
-	return mv88e6xxx_phy_wait(ds);
+	ret = _mv88e6xxx_reg_write(ds, REG_GLOBAL2, GLOBAL2_SMI_OP,
+				   GLOBAL2_SMI_OP_22_WRITE | (addr << 5) |
+				   regnum);
+
+	return _mv88e6xxx_phy_wait(ds);
 }
 
 int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
@@ -892,7 +898,7 @@ int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int reg;
 
-	mutex_lock(&ps->phy_mutex);
+	mutex_lock(&ps->smi_mutex);
 
 	reg = _mv88e6xxx_phy_read_indirect(ds, port, 16);
 	if (reg < 0)
@@ -901,7 +907,7 @@ int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
 	e->eee_enabled = !!(reg & 0x0200);
 	e->tx_lpi_enabled = !!(reg & 0x0100);
 
-	reg = mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_STATUS);
+	reg = _mv88e6xxx_reg_read(ds, REG_PORT(port), PORT_STATUS);
 	if (reg < 0)
 		goto out;
 
@@ -909,7 +915,7 @@ int mv88e6xxx_get_eee(struct dsa_switch *ds, int port, struct ethtool_eee *e)
 	reg = 0;
 
 out:
-	mutex_unlock(&ps->phy_mutex);
+	mutex_unlock(&ps->smi_mutex);
 	return reg;
 }
 
@@ -920,7 +926,7 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	int reg;
 	int ret;
 
-	mutex_lock(&ps->phy_mutex);
+	mutex_lock(&ps->smi_mutex);
 
 	ret = _mv88e6xxx_phy_read_indirect(ds, port, 16);
 	if (ret < 0)
@@ -934,7 +940,7 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 
 	ret = _mv88e6xxx_phy_write_indirect(ds, port, 16, reg);
 out:
-	mutex_unlock(&ps->phy_mutex);
+	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
 }
@@ -1568,7 +1574,6 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 
 	mutex_init(&ps->smi_mutex);
 	mutex_init(&ps->stats_mutex);
-	mutex_init(&ps->phy_mutex);
 
 	ps->id = REG_READ(REG_PORT(0), PORT_SWITCH_ID) & 0xfff0;
 
@@ -1722,14 +1727,14 @@ int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	mutex_lock(&ps->phy_mutex);
+	mutex_lock(&ps->smi_mutex);
 	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
 	if (ret < 0)
 		goto error;
 	ret = _mv88e6xxx_phy_read_indirect(ds, port, reg);
 error:
 	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
-	mutex_unlock(&ps->phy_mutex);
+	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
 
@@ -1739,7 +1744,7 @@ int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int ret;
 
-	mutex_lock(&ps->phy_mutex);
+	mutex_lock(&ps->smi_mutex);
 	ret = _mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
 	if (ret < 0)
 		goto error;
@@ -1747,7 +1752,7 @@ int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
 	ret = _mv88e6xxx_phy_write_indirect(ds, port, reg, val);
 error:
 	_mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
-	mutex_unlock(&ps->phy_mutex);
+	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
 
@@ -1770,9 +1775,9 @@ mv88e6xxx_phy_read(struct dsa_switch *ds, int port, int regnum)
 	if (addr < 0)
 		return addr;
 
-	mutex_lock(&ps->phy_mutex);
+	mutex_lock(&ps->smi_mutex);
 	ret = _mv88e6xxx_phy_read(ds, addr, regnum);
-	mutex_unlock(&ps->phy_mutex);
+	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
 
@@ -1786,9 +1791,9 @@ mv88e6xxx_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 	if (addr < 0)
 		return addr;
 
-	mutex_lock(&ps->phy_mutex);
+	mutex_lock(&ps->smi_mutex);
 	ret = _mv88e6xxx_phy_write(ds, addr, regnum, val);
-	mutex_unlock(&ps->phy_mutex);
+	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
 
@@ -1802,9 +1807,9 @@ mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int port, int regnum)
 	if (addr < 0)
 		return addr;
 
-	mutex_lock(&ps->phy_mutex);
+	mutex_lock(&ps->smi_mutex);
 	ret = _mv88e6xxx_phy_read_indirect(ds, addr, regnum);
-	mutex_unlock(&ps->phy_mutex);
+	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
 
@@ -1819,9 +1824,9 @@ mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int port, int regnum,
 	if (addr < 0)
 		return addr;
 
-	mutex_lock(&ps->phy_mutex);
+	mutex_lock(&ps->smi_mutex);
 	ret = _mv88e6xxx_phy_write_indirect(ds, addr, regnum, val);
-	mutex_unlock(&ps->phy_mutex);
+	mutex_unlock(&ps->smi_mutex);
 	return ret;
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index aafcb1a0a616..e10ccdb4ffbc 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -377,7 +377,6 @@ int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port);
 void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			struct ethtool_regs *regs, void *_p);
 int  mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp);
-int mv88e6xxx_phy_wait(struct dsa_switch *ds);
 int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds);
 int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds);
 int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr, int regnum);
-- 
2.1.4
