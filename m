From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 04/16] net: dsa: mv88e6xxx: Split mv88e6xxx_reg_read and mv88e6xxx_reg_write
Date: Thu, 26 Mar 2015 18:36:31 -0700
Message-ID: <1427420203-27685-5-git-send-email-linux@roeck-us.net>
References: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39325 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321AbbC0Bg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 21:36:59 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YbJCk-0020Yt-3I
	for netdev@vger.kernel.org; Fri, 27 Mar 2015 01:36:58 +0000
In-Reply-To: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split mv88e6xxx_reg_read and mv88e6xxx_reg_write into two functions each,
one to acquire smi_mutex and one to get struct mii_bus *bus from
struct dsa_switch *ds and to call the actual read/write function.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6xxx.c | 35 ++++++++++++++++++++++++++---------
 1 file changed, 26 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 5da50b00fdf6..d8f13327a438 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -72,19 +72,16 @@ int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg)
 	return ret & 0xffff;
 }
 
-int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
+/* Must be called with SMI mutex held */
+static int _mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
 	int ret;
 
 	if (bus == NULL)
 		return -EINVAL;
 
-	mutex_lock(&ps->smi_mutex);
 	ret = __mv88e6xxx_reg_read(bus, ds->pd->sw_addr, addr, reg);
-	mutex_unlock(&ps->smi_mutex);
-
 	if (ret < 0)
 		return ret;
 
@@ -94,6 +91,18 @@ int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
 	return ret;
 }
 
+int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	mutex_lock(&ps->smi_mutex);
+	ret = _mv88e6xxx_reg_read(ds, addr, reg);
+	mutex_unlock(&ps->smi_mutex);
+
+	return ret;
+}
+
 int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 			  int reg, u16 val)
 {
@@ -125,11 +134,11 @@ int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
 	return 0;
 }
 
-int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
+/* Must be called with SMI mutex held */
+static int _mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg,
+				u16 val)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	struct mii_bus *bus = dsa_host_dev_to_mii_bus(ds->master_dev);
-	int ret;
 
 	if (bus == NULL)
 		return -EINVAL;
@@ -137,8 +146,16 @@ int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
 	dev_dbg(ds->master_dev, "-> addr: 0x%.2x reg: 0x%.2x val: 0x%.4x\n",
 		addr, reg, val);
 
+	return __mv88e6xxx_reg_write(bus, ds->pd->sw_addr, addr, reg, val);
+}
+
+int mv88e6xxx_reg_write(struct dsa_switch *ds, int addr, int reg, u16 val)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
 	mutex_lock(&ps->smi_mutex);
-	ret = __mv88e6xxx_reg_write(bus, ds->pd->sw_addr, addr, reg, val);
+	ret = _mv88e6xxx_reg_write(ds, addr, reg, val);
 	mutex_unlock(&ps->smi_mutex);
 
 	return ret;
-- 
2.1.0
