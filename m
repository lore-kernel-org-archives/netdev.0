From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH 14/14] net: dsa: Provide additional RMON statistics
Date: Wed, 22 Oct 2014 21:03:22 -0700
Message-ID: <1414037002-25528-15-git-send-email-linux@roeck-us.net>
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

Display sw_in_discards, sw_in_filtered, and sw_out_filtered for chips
supported by mv88e6123_61_65 and mv88e6352 drivers.

The variables are provided in port registers, not the normal status registers.
Mark by adding 0x100 to the register offset and add special handling code
to mv88e6xxx_get_ethtool_stats.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6123_61_65.c |  3 +++
 drivers/net/dsa/mv88e6352.c       |  3 +++
 drivers/net/dsa/mv88e6xxx.c       | 26 +++++++++++++++++++++-----
 3 files changed, 27 insertions(+), 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index a3aeba4..18c026f 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -430,6 +430,9 @@ static struct mv88e6xxx_hw_stat mv88e6123_61_65_hw_stats[] = {
 	{ "hist_256_511bytes", 4, 0x0b, },
 	{ "hist_512_1023bytes", 4, 0x0c, },
 	{ "hist_1024_max_bytes", 4, 0x0d, },
+	{ "sw_in_discards", 4, 0x110, },
+	{ "sw_in_filtered", 2, 0x112, },
+	{ "sw_out_filtered", 2, 0x113, },
 };
 
 static void
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 2f31e28..85dabd9 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -536,6 +536,9 @@ static struct mv88e6xxx_hw_stat mv88e6352_hw_stats[] = {
 	{ "hist_256_511bytes", 4, 0x0b, },
 	{ "hist_512_1023bytes", 4, 0x0c, },
 	{ "hist_1024_max_bytes", 4, 0x0d, },
+	{ "sw_in_discards", 4, 0x110, },
+	{ "sw_in_filtered", 2, 0x112, },
+	{ "sw_out_filtered", 2, 0x113, },
 };
 
 static int mv88e6352_get_eeprom_len(struct dsa_switch *ds)
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index c071fde..da558d8 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -485,17 +485,33 @@ void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 	for (i = 0; i < nr_stats; i++) {
 		struct mv88e6xxx_hw_stat *s = stats + i;
 		u32 low;
-		u32 high;
-
+		u32 high = 0;
+
+		if (s->reg >= 0x100) {
+			int ret;
+
+			ret = mv88e6xxx_reg_read(ds, REG_PORT(port),
+						 s->reg - 0x100);
+			if (ret < 0)
+				goto error;
+			low = ret;
+			if (s->sizeof_stat == 4) {
+				ret = mv88e6xxx_reg_read(ds, REG_PORT(port),
+							 s->reg - 0x100 + 1);
+				if (ret < 0)
+					goto error;
+				high = ret;
+			}
+			data[i] = (((u64)high) << 16) | low;
+			continue;
+		}
 		mv88e6xxx_stats_read(ds, s->reg, &low);
 		if (s->sizeof_stat == 8)
 			mv88e6xxx_stats_read(ds, s->reg + 1, &high);
-		else
-			high = 0;
 
 		data[i] = (((u64)high) << 32) | low;
 	}
-
+error:
 	mutex_unlock(&ps->stats_mutex);
 }
 
-- 
1.9.1
