From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v3 07/15] net: dsa/mv88e6352: Report chip temperature
Date: Wed, 29 Oct 2014 10:44:59 -0700
Message-ID: <1414604707-22407-8-git-send-email-linux@roeck-us.net>
References: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

MV88E6352 supports reading the chip temperature from two PHY registers,
6:26 and 6:27. Report it using the more accurate register 6:27.
Also report temperature limit and alarm.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v3:
- No change
v2:
- Make new functionality optional, depending on CONFIG_NET_DSA_HWMON

 drivers/net/dsa/mv88e6352.c | 101 ++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 101 insertions(+)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index f17364f..744e6fa 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -325,6 +325,101 @@ static int mv88e6352_setup_port(struct dsa_switch *ds, int p)
 	return 0;
 }
 
+#ifdef CONFIG_NET_DSA_HWMON
+
+static int mv88e6352_phy_page_read(struct dsa_switch *ds,
+				   int port, int page, int reg)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	mutex_lock(&ps->phy_mutex);
+	ret = __mv88e6352_phy_write(ds, port, 0x16, page);
+	if (ret < 0)
+		goto error;
+	ret = __mv88e6352_phy_read(ds, port, reg);
+error:
+	__mv88e6352_phy_write(ds, port, 0x16, 0x0);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
+}
+
+static int mv88e6352_phy_page_write(struct dsa_switch *ds,
+				    int port, int page, int reg, int val)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	mutex_lock(&ps->phy_mutex);
+	ret = __mv88e6352_phy_write(ds, port, 0x16, page);
+	if (ret < 0)
+		goto error;
+
+	ret = __mv88e6352_phy_write(ds, port, reg, val);
+error:
+	__mv88e6352_phy_write(ds, port, 0x16, 0x0);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
+}
+
+static int mv88e6352_get_temp(struct dsa_switch *ds, int *temp)
+{
+	int ret;
+
+	*temp = 0;
+
+	ret = mv88e6352_phy_page_read(ds, 0, 6, 27);
+	if (ret < 0)
+		return ret;
+
+	*temp = (ret & 0xff) - 25;
+
+	return 0;
+}
+
+static int mv88e6352_get_temp_limit(struct dsa_switch *ds, int *temp)
+{
+	int ret;
+
+	*temp = 0;
+
+	ret = mv88e6352_phy_page_read(ds, 0, 6, 26);
+	if (ret < 0)
+		return ret;
+
+	*temp = (((ret >> 8) & 0x1f) * 5) - 25;
+
+	return 0;
+}
+
+static int mv88e6352_set_temp_limit(struct dsa_switch *ds, int temp)
+{
+	int ret;
+
+	ret = mv88e6352_phy_page_read(ds, 0, 6, 26);
+	if (ret < 0)
+		return ret;
+	temp = clamp_val(DIV_ROUND_CLOSEST(temp, 5) + 5, 0, 0x1f);
+	return mv88e6352_phy_page_write(ds, 0, 6, 26,
+					(ret & 0xe0ff) | (temp << 8));
+}
+
+static int mv88e6352_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
+{
+	int ret;
+
+	*alarm = false;
+
+	ret = mv88e6352_phy_page_read(ds, 0, 6, 26);
+	if (ret < 0)
+		return ret;
+
+	*alarm = !!(ret & 0x40);
+
+	return 0;
+}
+#endif /* CONFIG_NET_DSA_HWMON */
+
 static int mv88e6352_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -461,6 +556,12 @@ struct dsa_switch_driver mv88e6352_switch_driver = {
 	.get_strings		= mv88e6352_get_strings,
 	.get_ethtool_stats	= mv88e6352_get_ethtool_stats,
 	.get_sset_count		= mv88e6352_get_sset_count,
+#ifdef CONFIG_NET_DSA_HWMON
+	.get_temp		= mv88e6352_get_temp,
+	.get_temp_limit		= mv88e6352_get_temp_limit,
+	.set_temp_limit		= mv88e6352_set_temp_limit,
+	.get_temp_alarm		= mv88e6352_get_temp_alarm,
+#endif
 };
 
 MODULE_ALIAS("platform:mv88e6352");
-- 
1.9.1
