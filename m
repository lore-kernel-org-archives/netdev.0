From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 03/20] net: dsa: mv88e6xxx: factorize EEPROM access
Date: Thu,  5 May 2016 18:40:47 -0400
Message-ID: <1462488064-1841-4-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a MV88E6XXX_FLAG_EEPROM flag to describe switch models featuring an
EEPROM and distribute the EEPROM access routines to all models.

In the meantime, change the static functions to use a
mv88e6xxx_priv_state instead of a dsa_switch.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c |   2 +
 drivers/net/dsa/mv88e6131.c |   2 +
 drivers/net/dsa/mv88e6171.c |   2 +
 drivers/net/dsa/mv88e6352.c | 225 +++-------------------------------------
 drivers/net/dsa/mv88e6xxx.c | 248 +++++++++++++++++++++++++++++++++++++++++---
 drivers/net/dsa/mv88e6xxx.h |  12 ++-
 6 files changed, 264 insertions(+), 227 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 5535a42..1fc8f0d 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -121,6 +121,8 @@ struct dsa_switch_driver mv88e6123_switch_driver = {
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp		= mv88e6xxx_get_temp,
 #endif
+	.get_eeprom		= mv88e6xxx_get_eeprom,
+	.set_eeprom		= mv88e6xxx_set_eeprom,
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
 };
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 437faf8..3796f6d 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -153,6 +153,8 @@ struct dsa_switch_driver mv88e6131_switch_driver = {
 	.get_strings		= mv88e6xxx_get_strings,
 	.get_ethtool_stats	= mv88e6xxx_get_ethtool_stats,
 	.get_sset_count		= mv88e6xxx_get_sset_count,
+	.get_eeprom		= mv88e6xxx_get_eeprom,
+	.set_eeprom		= mv88e6xxx_set_eeprom,
 	.adjust_link		= mv88e6xxx_adjust_link,
 	.port_bridge_join	= mv88e6xxx_port_bridge_join,
 	.port_bridge_leave	= mv88e6xxx_port_bridge_leave,
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 304e25e..b8b6902 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -133,6 +133,8 @@ struct dsa_switch_driver mv88e6171_switch_driver = {
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp               = mv88e6xxx_get_temp,
 #endif
+	.get_eeprom		= mv88e6xxx_get_eeprom,
+	.set_eeprom		= mv88e6xxx_set_eeprom,
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
 	.port_bridge_join	= mv88e6xxx_port_bridge_join,
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index df9f944..e6437de 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -29,42 +29,48 @@ static const struct mv88e6xxx_info mv88e6352_table[] = {
 		.name = "Marvell 88E6320",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY,
+		.flags = MV88E6XXX_FLAG_EEPROM |
+			MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6321,
 		.family = MV88E6XXX_FAMILY_6320,
 		.name = "Marvell 88E6321",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY,
+		.flags = MV88E6XXX_FLAG_EEPROM |
+			MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6172,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6172",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY,
+		.flags = MV88E6XXX_FLAG_EEPROM |
+			MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6176,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6176",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY,
+		.flags = MV88E6XXX_FLAG_EEPROM |
+			MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6240,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6240",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY,
+		.flags = MV88E6XXX_FLAG_EEPROM |
+			MV88E6XXX_FLAG_SMI_PHY,
 	}, {
 		.prod_num = PORT_SWITCH_ID_PROD_NUM_6352,
 		.family = MV88E6XXX_FAMILY_6352,
 		.name = "Marvell 88E6352",
 		.num_databases = 4096,
 		.num_ports = 7,
-		.flags = MV88E6XXX_FLAG_SMI_PHY,
+		.flags = MV88E6XXX_FLAG_EEPROM |
+			MV88E6XXX_FLAG_SMI_PHY,
 	}
 };
 
@@ -125,8 +131,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	mutex_init(&ps->eeprom_mutex);
-
 	ret = mv88e6xxx_switch_reset(ps, true);
 	if (ret < 0)
 		return ret;
@@ -138,207 +142,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	return mv88e6xxx_setup_ports(ds);
 }
 
-static int mv88e6352_read_eeprom_word(struct dsa_switch *ds, int addr)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-
-	mutex_lock(&ps->eeprom_mutex);
-
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
-				  GLOBAL2_EEPROM_OP_READ |
-				  (addr & GLOBAL2_EEPROM_OP_ADDR_MASK));
-	if (ret < 0)
-		goto error;
-
-	ret = mv88e6xxx_eeprom_busy_wait(ds);
-	if (ret < 0)
-		goto error;
-
-	ret = mv88e6xxx_reg_read(ps, REG_GLOBAL2, GLOBAL2_EEPROM_DATA);
-error:
-	mutex_unlock(&ps->eeprom_mutex);
-	return ret;
-}
-
-static int mv88e6352_get_eeprom(struct dsa_switch *ds,
-				struct ethtool_eeprom *eeprom, u8 *data)
-{
-	int offset;
-	int len;
-	int ret;
-
-	offset = eeprom->offset;
-	len = eeprom->len;
-	eeprom->len = 0;
-
-	eeprom->magic = 0xc3ec4951;
-
-	ret = mv88e6xxx_eeprom_load_wait(ds);
-	if (ret < 0)
-		return ret;
-
-	if (offset & 1) {
-		int word;
-
-		word = mv88e6352_read_eeprom_word(ds, offset >> 1);
-		if (word < 0)
-			return word;
-
-		*data++ = (word >> 8) & 0xff;
-
-		offset++;
-		len--;
-		eeprom->len++;
-	}
-
-	while (len >= 2) {
-		int word;
-
-		word = mv88e6352_read_eeprom_word(ds, offset >> 1);
-		if (word < 0)
-			return word;
-
-		*data++ = word & 0xff;
-		*data++ = (word >> 8) & 0xff;
-
-		offset += 2;
-		len -= 2;
-		eeprom->len += 2;
-	}
-
-	if (len) {
-		int word;
-
-		word = mv88e6352_read_eeprom_word(ds, offset >> 1);
-		if (word < 0)
-			return word;
-
-		*data++ = word & 0xff;
-
-		offset++;
-		len--;
-		eeprom->len++;
-	}
-
-	return 0;
-}
-
-static int mv88e6352_eeprom_is_readonly(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-
-	ret = mv88e6xxx_reg_read(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP);
-	if (ret < 0)
-		return ret;
-
-	if (!(ret & GLOBAL2_EEPROM_OP_WRITE_EN))
-		return -EROFS;
-
-	return 0;
-}
-
-static int mv88e6352_write_eeprom_word(struct dsa_switch *ds, int addr,
-				       u16 data)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-
-	mutex_lock(&ps->eeprom_mutex);
-
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_EEPROM_DATA, data);
-	if (ret < 0)
-		goto error;
-
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
-				  GLOBAL2_EEPROM_OP_WRITE |
-				  (addr & GLOBAL2_EEPROM_OP_ADDR_MASK));
-	if (ret < 0)
-		goto error;
-
-	ret = mv88e6xxx_eeprom_busy_wait(ds);
-error:
-	mutex_unlock(&ps->eeprom_mutex);
-	return ret;
-}
-
-static int mv88e6352_set_eeprom(struct dsa_switch *ds,
-				struct ethtool_eeprom *eeprom, u8 *data)
-{
-	int offset;
-	int ret;
-	int len;
-
-	if (eeprom->magic != 0xc3ec4951)
-		return -EINVAL;
-
-	ret = mv88e6352_eeprom_is_readonly(ds);
-	if (ret)
-		return ret;
-
-	offset = eeprom->offset;
-	len = eeprom->len;
-	eeprom->len = 0;
-
-	ret = mv88e6xxx_eeprom_load_wait(ds);
-	if (ret < 0)
-		return ret;
-
-	if (offset & 1) {
-		int word;
-
-		word = mv88e6352_read_eeprom_word(ds, offset >> 1);
-		if (word < 0)
-			return word;
-
-		word = (*data++ << 8) | (word & 0xff);
-
-		ret = mv88e6352_write_eeprom_word(ds, offset >> 1, word);
-		if (ret < 0)
-			return ret;
-
-		offset++;
-		len--;
-		eeprom->len++;
-	}
-
-	while (len >= 2) {
-		int word;
-
-		word = *data++;
-		word |= *data++ << 8;
-
-		ret = mv88e6352_write_eeprom_word(ds, offset >> 1, word);
-		if (ret < 0)
-			return ret;
-
-		offset += 2;
-		len -= 2;
-		eeprom->len += 2;
-	}
-
-	if (len) {
-		int word;
-
-		word = mv88e6352_read_eeprom_word(ds, offset >> 1);
-		if (word < 0)
-			return word;
-
-		word = (word & 0xff00) | *data++;
-
-		ret = mv88e6352_write_eeprom_word(ds, offset >> 1, word);
-		if (ret < 0)
-			return ret;
-
-		offset++;
-		len--;
-		eeprom->len++;
-	}
-
-	return 0;
-}
-
 struct dsa_switch_driver mv88e6352_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.probe			= mv88e6352_drv_probe,
@@ -358,8 +161,8 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.set_temp_limit		= mv88e6xxx_set_temp_limit,
 	.get_temp_alarm		= mv88e6xxx_get_temp_alarm,
 #endif
-	.get_eeprom		= mv88e6352_get_eeprom,
-	.set_eeprom		= mv88e6352_set_eeprom,
+	.get_eeprom		= mv88e6xxx_get_eeprom,
+	.set_eeprom		= mv88e6xxx_set_eeprom,
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
 	.port_bridge_join	= mv88e6xxx_port_bridge_join,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index e48271c..233c265 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -786,38 +786,255 @@ static int _mv88e6xxx_wait(struct mv88e6xxx_priv_state *ps, int reg, int offset,
 	return -ETIMEDOUT;
 }
 
-static int mv88e6xxx_wait(struct mv88e6xxx_priv_state *ps, int reg,
-			  int offset, u16 mask)
+static int _mv88e6xxx_phy_wait(struct mv88e6xxx_priv_state *ps)
+{
+	return _mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_SMI_OP,
+			       GLOBAL2_SMI_OP_BUSY);
+}
+
+static int _mv88e6xxx_eeprom_load_wait(struct mv88e6xxx_priv_state *ps)
+{
+	return _mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+			       GLOBAL2_EEPROM_OP_LOAD);
+}
+
+static int _mv88e6xxx_eeprom_busy_wait(struct mv88e6xxx_priv_state *ps)
+{
+	return _mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+			       GLOBAL2_EEPROM_OP_BUSY);
+}
+
+static int _mv88e6xxx_read_eeprom_word(struct mv88e6xxx_priv_state *ps,
+				       int addr)
 {
 	int ret;
 
-	mutex_lock(&ps->smi_mutex);
-	ret = _mv88e6xxx_wait(ps, reg, offset, mask);
-	mutex_unlock(&ps->smi_mutex);
+	mutex_lock(&ps->eeprom_mutex);
+
+	ret = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+				  GLOBAL2_EEPROM_OP_READ |
+				  (addr & GLOBAL2_EEPROM_OP_ADDR_MASK));
+	if (ret)
+		goto unlock;
+
+	ret = _mv88e6xxx_eeprom_busy_wait(ps);
+	if (ret)
+		goto unlock;
+
+	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL2, GLOBAL2_EEPROM_DATA);
+unlock:
+	mutex_unlock(&ps->eeprom_mutex);
 
 	return ret;
 }
 
-static int _mv88e6xxx_phy_wait(struct mv88e6xxx_priv_state *ps)
+static int _mv88e6xxx_get_eeprom(struct mv88e6xxx_priv_state *ps,
+				 struct ethtool_eeprom *eeprom, u8 *data)
 {
-	return _mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_SMI_OP,
-			       GLOBAL2_SMI_OP_BUSY);
+	int offset;
+	int len;
+	int ret;
+
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
+		return -EOPNOTSUPP;
+
+	offset = eeprom->offset;
+	len = eeprom->len;
+	eeprom->len = 0;
+
+	eeprom->magic = 0xc3ec4951;
+
+	ret = _mv88e6xxx_eeprom_load_wait(ps);
+	if (ret < 0)
+		return ret;
+
+	if (offset & 1) {
+		int word;
+
+		word = _mv88e6xxx_read_eeprom_word(ps, offset >> 1);
+		if (word < 0)
+			return word;
+
+		*data++ = (word >> 8) & 0xff;
+
+		offset++;
+		len--;
+		eeprom->len++;
+	}
+
+	while (len >= 2) {
+		int word;
+
+		word = _mv88e6xxx_read_eeprom_word(ps, offset >> 1);
+		if (word < 0)
+			return word;
+
+		*data++ = word & 0xff;
+		*data++ = (word >> 8) & 0xff;
+
+		offset += 2;
+		len -= 2;
+		eeprom->len += 2;
+	}
+
+	if (len) {
+		int word;
+
+		word = _mv88e6xxx_read_eeprom_word(ps, offset >> 1);
+		if (word < 0)
+			return word;
+
+		*data++ = word & 0xff;
+
+		offset++;
+		len--;
+		eeprom->len++;
+	}
+
+	return 0;
 }
 
-int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds)
+int mv88e6xxx_get_eeprom(struct dsa_switch *ds, struct ethtool_eeprom *eeprom,
+			 u8 *data)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int err;
+
+	mutex_lock(&ps->smi_mutex);
+	err = _mv88e6xxx_get_eeprom(ps, eeprom, data);
+	mutex_unlock(&ps->smi_mutex);
+
+	return err;
+}
+
+static int _mv88e6xxx_eeprom_is_readonly(struct mv88e6xxx_priv_state *ps)
+{
+	int ret;
+
+	ret = _mv88e6xxx_reg_read(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP);
+	if (ret < 0)
+		return ret;
 
-	return mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
-			      GLOBAL2_EEPROM_OP_LOAD);
+	if (!(ret & GLOBAL2_EEPROM_OP_WRITE_EN))
+		return -EROFS;
+
+	return 0;
+}
+
+static int _mv88e6xxx_write_eeprom_word(struct mv88e6xxx_priv_state *ps,
+					int addr, u16 data)
+{
+	int err;
+
+	mutex_lock(&ps->eeprom_mutex);
+
+	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_EEPROM_DATA, data);
+	if (err)
+		goto unlock;
+
+	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
+				   GLOBAL2_EEPROM_OP_WRITE |
+				   (addr & GLOBAL2_EEPROM_OP_ADDR_MASK));
+	if (err)
+		goto unlock;
+
+	err = _mv88e6xxx_eeprom_busy_wait(ps);
+unlock:
+	mutex_unlock(&ps->eeprom_mutex);
+
+	return err;
 }
 
-int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds)
+static int _mv88e6xxx_set_eeprom(struct mv88e6xxx_priv_state *ps,
+				 struct ethtool_eeprom *eeprom, u8 *data)
+{
+	int offset;
+	int ret;
+	int len;
+
+	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
+		return -EOPNOTSUPP;
+
+	if (eeprom->magic != 0xc3ec4951)
+		return -EINVAL;
+
+	ret = _mv88e6xxx_eeprom_is_readonly(ps);
+	if (ret)
+		return ret;
+
+	offset = eeprom->offset;
+	len = eeprom->len;
+	eeprom->len = 0;
+
+	ret = _mv88e6xxx_eeprom_load_wait(ps);
+	if (ret < 0)
+		return ret;
+
+	if (offset & 1) {
+		int word;
+
+		word = _mv88e6xxx_read_eeprom_word(ps, offset >> 1);
+		if (word < 0)
+			return word;
+
+		word = (*data++ << 8) | (word & 0xff);
+
+		ret = _mv88e6xxx_write_eeprom_word(ps, offset >> 1, word);
+		if (ret < 0)
+			return ret;
+
+		offset++;
+		len--;
+		eeprom->len++;
+	}
+
+	while (len >= 2) {
+		int word;
+
+		word = *data++;
+		word |= *data++ << 8;
+
+		ret = _mv88e6xxx_write_eeprom_word(ps, offset >> 1, word);
+		if (ret < 0)
+			return ret;
+
+		offset += 2;
+		len -= 2;
+		eeprom->len += 2;
+	}
+
+	if (len) {
+		int word;
+
+		word = _mv88e6xxx_read_eeprom_word(ps, offset >> 1);
+		if (word < 0)
+			return word;
+
+		word = (word & 0xff00) | *data++;
+
+		ret = _mv88e6xxx_write_eeprom_word(ps, offset >> 1, word);
+		if (ret < 0)
+			return ret;
+
+		offset++;
+		len--;
+		eeprom->len++;
+	}
+
+	return 0;
+}
+
+int mv88e6xxx_set_eeprom(struct dsa_switch *ds, struct ethtool_eeprom *eeprom,
+			 u8 *data)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int err;
 
-	return mv88e6xxx_wait(ps, REG_GLOBAL2, GLOBAL2_EEPROM_OP,
-			      GLOBAL2_EEPROM_OP_BUSY);
+	mutex_lock(&ps->smi_mutex);
+	err = _mv88e6xxx_set_eeprom(ps, eeprom, data);
+	mutex_unlock(&ps->smi_mutex);
+
+	return err;
 }
 
 static int _mv88e6xxx_atu_wait(struct mv88e6xxx_priv_state *ps)
@@ -2577,6 +2794,9 @@ int mv88e6xxx_setup_common(struct mv88e6xxx_priv_state *ps)
 
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
 
+	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
+		mutex_init(&ps->eeprom_mutex);
+
 	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_PPU))
 		mv88e6xxx_ppu_state_init(ps);
 
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 95cbb8b..08cb5c4 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -351,6 +351,11 @@ enum mv88e6xxx_family {
 };
 
 enum mv88e6xxx_cap {
+	/* EEPROM Command and Data registers.
+	 * See GLOBAL2_EEPROM_OP and GLOBAL2_EEPROM_DATA.
+	 */
+	MV88E6XXX_CAP_EEPROM,
+
 	/* PHY Polling Unit.
 	 * See GLOBAL_CONTROL_PPU_ENABLE and GLOBAL_STATUS_PPU_POLLING.
 	 */
@@ -364,6 +369,7 @@ enum mv88e6xxx_cap {
 };
 
 /* Bitmask of capabilities */
+#define MV88E6XXX_FLAG_EEPROM		BIT(MV88E6XXX_CAP_EEPROM)
 #define MV88E6XXX_FLAG_PPU		BIT(MV88E6XXX_CAP_PPU)
 #define MV88E6XXX_FLAG_SMI_PHY		BIT(MV88E6XXX_CAP_SMI_PHY)
 
@@ -501,8 +507,10 @@ int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp);
 int mv88e6xxx_get_temp_limit(struct dsa_switch *ds, int *temp);
 int mv88e6xxx_set_temp_limit(struct dsa_switch *ds, int temp);
 int mv88e6xxx_get_temp_alarm(struct dsa_switch *ds, bool *alarm);
-int mv88e6xxx_eeprom_load_wait(struct dsa_switch *ds);
-int mv88e6xxx_eeprom_busy_wait(struct dsa_switch *ds);
+int mv88e6xxx_get_eeprom(struct dsa_switch *ds, struct ethtool_eeprom *eeprom,
+			 u8 *data);
+int mv88e6xxx_set_eeprom(struct dsa_switch *ds, struct ethtool_eeprom *eeprom,
+			 u8 *data);
 int mv88e6xxx_phy_read_indirect(struct dsa_switch *ds, int addr, int regnum);
 int mv88e6xxx_phy_write_indirect(struct dsa_switch *ds, int addr, int regnum,
 				 u16 val);
-- 
2.8.2
