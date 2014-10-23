From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 10/14] net: dsa/mv88e6352: Implement EEPROM access functions
Date: Wed, 22 Oct 2014 21:03:18 -0700
Message-ID: <1414037002-25528-11-git-send-email-linux@roeck-us.net>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MV88E6352 supports read and write access to its configuration eeprom.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6352.c | 228 +++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx.h |   5 +
 2 files changed, 230 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index aff6695..9dddcba 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -22,18 +22,18 @@
 #include <net/dsa.h>
 #include "mv88e6xxx.h"
 
-static int mv88e6352_phy_wait(struct dsa_switch *ds)
+static int mv88e6352_wait(struct dsa_switch *ds, int reg, u16 mask)
 {
 	unsigned long timeout = jiffies + HZ / 10;
 
 	while (time_before(jiffies, timeout)) {
 		int ret;
 
-		ret = REG_READ(REG_GLOBAL2, 0x18);
+		ret = REG_READ(REG_GLOBAL2, reg);
 		if (ret < 0)
 			return ret;
 
-		if (!(ret & 0x8000))
+		if (!(ret & mask))
 			return 0;
 
 		usleep_range(1000, 2000);
@@ -41,6 +41,21 @@ static int mv88e6352_phy_wait(struct dsa_switch *ds)
 	return -ETIMEDOUT;
 }
 
+static inline int mv88e6352_phy_wait(struct dsa_switch *ds)
+{
+	return mv88e6352_wait(ds, 0x18, 0x8000);
+}
+
+static inline int mv88e6352_eeprom_load_wait(struct dsa_switch *ds)
+{
+	return mv88e6352_wait(ds, 0x14, 0x0800);
+}
+
+static inline int mv88e6352_eeprom_busy_wait(struct dsa_switch *ds)
+{
+	return mv88e6352_wait(ds, 0x14, 0x8000);
+}
+
 static int __mv88e6352_phy_read(struct dsa_switch *ds, int addr, int regnum)
 {
 	int ret;
@@ -426,6 +441,7 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	mutex_init(&ps->smi_mutex);
 	mutex_init(&ps->stats_mutex);
 	mutex_init(&ps->phy_mutex);
+	mutex_init(&ps->eeprom_mutex);
 
 	ps->id = REG_READ(REG_PORT(0), 0x03) & 0xfff0;
 
@@ -522,6 +538,209 @@ static struct mv88e6xxx_hw_stat mv88e6352_hw_stats[] = {
 	{ "hist_1024_max_bytes", 4, 0x0d, },
 };
 
+static int mv88e6352_get_eeprom_len(struct dsa_switch *ds)
+{
+	return 0x200;
+}
+
+static int mv88e6352_read_eeprom_word(struct dsa_switch *ds, int addr)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	mutex_lock(&ps->eeprom_mutex);
+
+	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, 0x14,
+				  0xc000 | (addr & 0xff));
+	if (ret < 0)
+		goto error;
+
+	ret = mv88e6352_eeprom_busy_wait(ds);
+	if (ret < 0)
+		goto error;
+
+	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL2, 0x15);
+error:
+	mutex_unlock(&ps->eeprom_mutex);
+	return ret;
+}
+
+static int mv88e6352_get_eeprom(struct dsa_switch *ds,
+				struct ethtool_eeprom *eeprom, u8 *data)
+{
+	int offset;
+	int len;
+	int ret;
+
+	offset = eeprom->offset;
+	len = eeprom->len;
+	eeprom->len = 0;
+
+	eeprom->magic = 0xc3ec4951;
+
+	ret = mv88e6352_eeprom_load_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	if (offset & 1) {
+		int word;
+
+		word = mv88e6352_read_eeprom_word(ds, offset >> 1);
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
+		word = mv88e6352_read_eeprom_word(ds, offset >> 1);
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
+		word = mv88e6352_read_eeprom_word(ds, offset >> 1);
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
+}
+
+static int mv88e6352_eeprom_is_readonly(struct dsa_switch *ds)
+{
+	int ret;
+
+	ret = mv88e6xxx_reg_read(ds, REG_GLOBAL2, 0x14);
+	if (ret < 0)
+		return ret;
+
+	if (!(ret & 0x0400))
+		return -EROFS;
+
+	return 0;
+}
+
+static int mv88e6352_write_eeprom_word(struct dsa_switch *ds, int addr,
+				       u16 data)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	mutex_lock(&ps->eeprom_mutex);
+
+	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, 0x15, data);
+	if (ret < 0)
+		goto error;
+
+	ret = mv88e6xxx_reg_write(ds, REG_GLOBAL2, 0x14,
+				  0xb000 | (addr & 0xff));
+	if (ret < 0)
+		goto error;
+
+	ret = mv88e6352_eeprom_busy_wait(ds);
+error:
+	mutex_unlock(&ps->eeprom_mutex);
+	return ret;
+}
+
+static int mv88e6352_set_eeprom(struct dsa_switch *ds,
+				struct ethtool_eeprom *eeprom, u8 *data)
+{
+	int offset;
+	int ret;
+	int len;
+
+	if (eeprom->magic != 0xc3ec4951)
+		return -EINVAL;
+
+	ret = mv88e6352_eeprom_is_readonly(ds);
+	if (ret)
+		return ret;
+
+	offset = eeprom->offset;
+	len = eeprom->len;
+	eeprom->len = 0;
+
+	ret = mv88e6352_eeprom_load_wait(ds);
+	if (ret < 0)
+		return ret;
+
+	if (offset & 1) {
+		int word;
+
+		word = mv88e6352_read_eeprom_word(ds, offset >> 1);
+		if (word < 0)
+			return word;
+
+		word = (*data++ << 8) | (word & 0xff);
+
+		ret = mv88e6352_write_eeprom_word(ds, offset >> 1, word);
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
+		ret = mv88e6352_write_eeprom_word(ds, offset >> 1, word);
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
+		word = mv88e6352_read_eeprom_word(ds, offset >> 1);
+		if (word < 0)
+			return word;
+
+		word = (word & 0xff00) | *data++;
+
+		ret = mv88e6352_write_eeprom_word(ds, offset >> 1, word);
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
 static void
 mv88e6352_get_strings(struct dsa_switch *ds, int port, uint8_t *data)
 {
@@ -557,6 +776,9 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.get_temp_limit		= mv88e6352_get_temp_limit,
 	.set_temp_limit		= mv88e6352_set_temp_limit,
 	.get_temp_alarm		= mv88e6352_get_temp_alarm,
+	.get_eeprom_len		= mv88e6352_get_eeprom_len,
+	.get_eeprom		= mv88e6352_get_eeprom,
+	.set_eeprom		= mv88e6352_set_eeprom,
 };
 
 MODULE_ALIAS("platform:mv88e6352");
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 77beff5..d4d53ae 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -43,6 +43,11 @@ struct mv88e6xxx_priv_state {
 	 */
 	struct mutex phy_mutex;
 
+	/* This mutex serializes eeprom access for chips with
+	 * eeprom support.
+	 */
+	struct mutex eeprom_mutex;
+
 	int		id; /* switch product id */
 };
 
-- 
1.9.1
