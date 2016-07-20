From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/3] net: dsa: mv88e6xxx: kill last locked reg_read
Date: Wed, 20 Jul 2016 12:05:47 -0400
Message-ID: <20160720160547.30133-4-vivien.didelot@savoirfairelinux.com>
References: <20160720160547.30133-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:38143 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777AbcGTQG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2016 12:06:28 -0400
In-Reply-To: <20160720160547.30133-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of the last usage of the locked mv88e6xxx_reg_read function with
a new mv88e6xxx_port_read helper, useful later for chips with different
port registers base address.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 35 +++++++++++++++++++----------------
 1 file changed, 19 insertions(+), 16 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index f95f1d4..4c6fc6d 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -254,17 +254,6 @@ static int _mv88e6xxx_reg_read(struct mv88e6xxx_chip *chip, int addr, int reg)
 	return val;
 }
 
-static int mv88e6xxx_reg_read(struct mv88e6xxx_chip *chip, int addr, int reg)
-{
-	int ret;
-
-	mutex_lock(&chip->reg_lock);
-	ret = _mv88e6xxx_reg_read(chip, addr, reg);
-	mutex_unlock(&chip->reg_lock);
-
-	return ret;
-}
-
 static int _mv88e6xxx_reg_write(struct mv88e6xxx_chip *chip, int addr,
 				int reg, u16 val)
 {
@@ -2426,6 +2415,17 @@ static int mv88e6xxx_power_on_serdes(struct mv88e6xxx_chip *chip)
 	return ret;
 }
 
+static int mv88e6xxx_port_read(struct mv88e6xxx_chip *chip, int port,
+			       int reg, u16 *data)
+{
+	int addr = chip->info->port_base_addr + port;
+
+	if (port >= chip->info->num_ports)
+		return -EINVAL;
+
+	return mv88e6xxx_read(chip, addr, reg, data);
+}
+
 static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 {
 	struct dsa_switch *ds = chip->ds;
@@ -3830,12 +3830,15 @@ static const struct mv88e6xxx_info *mv88e6xxx_lookup_info(unsigned int prod_num)
 static int mv88e6xxx_detect(struct mv88e6xxx_chip *chip)
 {
 	const struct mv88e6xxx_info *info;
-	int id, prod_num, rev;
+	unsigned int prod_num, rev;
+	u16 id;
+	int err;
 
-	id = mv88e6xxx_reg_read(chip, chip->info->port_base_addr,
-				PORT_SWITCH_ID);
-	if (id < 0)
-		return id;
+	mutex_lock(&chip->reg_lock);
+	err = mv88e6xxx_port_read(chip, 0, PORT_SWITCH_ID, &id);
+	mutex_unlock(&chip->reg_lock);
+	if (err)
+		return err;
 
 	prod_num = (id & 0xfff0) >> 4;
 	rev = id & 0x000f;
-- 
2.9.0
