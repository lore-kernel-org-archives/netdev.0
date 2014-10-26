From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 08/15] net: dsa/mv88e6123_61_65: Report chip temperature
Date: Sun, 26 Oct 2014 09:52:38 -0700
Message-ID: <1414342365-27191-9-git-send-email-linux@roeck-us.net>
References: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414342365-27191-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MV88E6123 and compatible chips support reading the chip temperature
from PHY register 6:26.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2:
- Make new functionality optional, depending on CONFIG_NET_DSA_HWMON

 drivers/net/dsa/mv88e6123_61_65.c | 68 +++++++++++++++++++++++++++++++++++++--
 1 file changed, 66 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index a332c53..9f43c9b 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -291,6 +291,54 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 	return 0;
 }
 
+#ifdef CONFIG_NET_DSA_HWMON
+
+static int  mv88e6123_61_65_get_temp(struct dsa_switch *ds, int *temp)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+	int val;
+
+	*temp = 0;
+
+	mutex_lock(&ps->phy_mutex);
+
+	ret = mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x6);
+	if (ret < 0)
+		goto error;
+
+	/* Enable temperature sensor */
+	ret = mv88e6xxx_phy_read(ds, 0x0, 0x1a);
+	if (ret < 0)
+		goto error;
+
+	ret = mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret | (1 << 5));
+	if (ret < 0)
+		goto error;
+
+	/* Wait for temperature to stabilize */
+	usleep_range(10000, 12000);
+
+	val = mv88e6xxx_phy_read(ds, 0x0, 0x1a);
+	if (val < 0) {
+		ret = val;
+		goto error;
+	}
+
+	/* Disable temperature sensor */
+	ret = mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret & ~(1 << 5));
+	if (ret < 0)
+		goto error;
+
+	*temp = ((val & 0x1f) - 5) * 5;
+
+error:
+	mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x0);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
+}
+#endif /* CONFIG_NET_DSA_HWMON */
+
 static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -299,6 +347,7 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 
 	mutex_init(&ps->smi_mutex);
 	mutex_init(&ps->stats_mutex);
+	mutex_init(&ps->phy_mutex);
 
 	ret = mv88e6123_61_65_switch_reset(ds);
 	if (ret < 0)
@@ -329,16 +378,28 @@ static int mv88e6123_61_65_port_to_phy_addr(int port)
 static int
 mv88e6123_61_65_phy_read(struct dsa_switch *ds, int port, int regnum)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int addr = mv88e6123_61_65_port_to_phy_addr(port);
-	return mv88e6xxx_phy_read(ds, addr, regnum);
+	int ret;
+
+	mutex_lock(&ps->phy_mutex);
+	ret = mv88e6xxx_phy_read(ds, addr, regnum);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
 }
 
 static int
 mv88e6123_61_65_phy_write(struct dsa_switch *ds,
 			      int port, int regnum, u16 val)
 {
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int addr = mv88e6123_61_65_port_to_phy_addr(port);
-	return mv88e6xxx_phy_write(ds, addr, regnum, val);
+	int ret;
+
+	mutex_lock(&ps->phy_mutex);
+	ret = mv88e6xxx_phy_write(ds, addr, regnum, val);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
 }
 
 static struct mv88e6xxx_hw_stat mv88e6123_61_65_hw_stats[] = {
@@ -406,6 +467,9 @@ struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.get_strings		= mv88e6123_61_65_get_strings,
 	.get_ethtool_stats	= mv88e6123_61_65_get_ethtool_stats,
 	.get_sset_count		= mv88e6123_61_65_get_sset_count,
+#ifdef CONFIG_NET_DSA_HWMON
+	.get_temp		= mv88e6123_61_65_get_temp,
+#endif
 };
 
 MODULE_ALIAS("platform:mv88e6123");
-- 
1.9.1
