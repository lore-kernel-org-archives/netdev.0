From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH 1/2] net: dsa: mv88e6xxx: sleep in _mv88e6xxx_stats_wait
Date: Fri, 10 Jul 2015 12:57:28 -0400
Message-ID: <1436547449-26927-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current _mv88e6xxx_stats_wait function does not sleep while testing
the stats busy bit. Fix this by using the generic _mv88e6xxx_wait
function.

Note that it requires to move _mv88e6xxx_wait on top of
_mv88e6xxx_stats_wait to avoid undefined reference compilation error.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6xxx.c | 52 +++++++++++++++++++--------------------------
 1 file changed, 22 insertions(+), 30 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index f6c7409..7753db1 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -557,19 +557,31 @@ static bool mv88e6xxx_6352_family(struct dsa_switch *ds)
 	return false;
 }
 
+/* Must be called with SMI lock held */
+static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
+			   u16 mask)
+{
+	unsigned long timeout = jiffies + HZ / 10;
+
+	while (time_before(jiffies, timeout)) {
+		int ret;
+
+		ret = _mv88e6xxx_reg_read(ds, reg, offset);
+		if (ret < 0)
+			return ret;
+		if (!(ret & mask))
+			return 0;
+
+		usleep_range(1000, 2000);
+	}
+	return -ETIMEDOUT;
+}
+
 /* Must be called with SMI mutex held */
 static int _mv88e6xxx_stats_wait(struct dsa_switch *ds)
 {
-	int ret;
-	int i;
-
-	for (i = 0; i < 10; i++) {
-		ret = _mv88e6xxx_reg_read(ds, REG_GLOBAL, GLOBAL_STATS_OP);
-		if ((ret & GLOBAL_STATS_OP_BUSY) == 0)
-			return 0;
-	}
-
-	return -ETIMEDOUT;
+	return _mv88e6xxx_wait(ds, REG_GLOBAL, GLOBAL_STATS_OP,
+			       GLOBAL_STATS_OP_BUSY);
 }
 
 /* Must be called with SMI mutex held */
@@ -856,26 +868,6 @@ error:
 }
 #endif /* CONFIG_NET_DSA_HWMON */
 
-/* Must be called with SMI lock held */
-static int _mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset,
-			   u16 mask)
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
 static int mv88e6xxx_wait(struct dsa_switch *ds, int reg, int offset, u16 mask)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-- 
2.4.5
