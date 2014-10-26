From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 13/15] net: dsa/mv88e6123_61_65: Add support for reading switch registers
Date: Sun, 26 Oct 2014 09:52:43 -0700
Message-ID: <1414342365-27191-14-git-send-email-linux@roeck-us.net>
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

The infrastructure can now report switch registers to ethtool.
Add support for it to the mv88e6123_61_65 driver.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
v2:
- No change

 drivers/net/dsa/mv88e6123_61_65.c |  2 ++
 drivers/net/dsa/mv88e6xxx.c       | 24 ++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h       |  3 +++
 3 files changed, 29 insertions(+)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 9f43c9b..e2d2e37 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -470,6 +470,8 @@ struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 #ifdef CONFIG_NET_DSA_HWMON
 	.get_temp		= mv88e6123_61_65_get_temp,
 #endif
+	.get_regs_len		= mv88e6xxx_get_regs_len,
+	.get_regs		= mv88e6xxx_get_regs,
 };
 
 MODULE_ALIAS("platform:mv88e6123");
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 8e1090b..c071fde 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -499,6 +499,30 @@ void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 	mutex_unlock(&ps->stats_mutex);
 }
 
+int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port)
+{
+	return 32 * sizeof(u16);
+}
+
+void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
+			struct ethtool_regs *regs, void *_p)
+{
+	u16 *p = _p;
+	int i;
+
+	regs->version = 0;
+
+	memset(p, 0xff, 32 * sizeof(u16));
+
+	for (i = 0; i < 32; i++) {
+		int ret;
+
+		ret = mv88e6xxx_reg_read(ds, REG_PORT(port), i);
+		if (ret >= 0)
+			p[i] = ret;
+	}
+}
+
 static int __init mv88e6xxx_init(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 29feed0..a0780b0 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -78,6 +78,9 @@ void mv88e6xxx_get_strings(struct dsa_switch *ds,
 void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 				 int nr_stats, struct mv88e6xxx_hw_stat *stats,
 				 int port, uint64_t *data);
+int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port);
+void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
+			struct ethtool_regs *regs, void *_p);
 
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
-- 
1.9.1
