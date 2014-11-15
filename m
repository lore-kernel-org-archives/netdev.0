From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 1/3] net: dsa: Centralise code for reading the temperature sensor
Date: Sat, 15 Nov 2014 22:24:51 +0100
Message-ID: <1416086694-15790-2-git-send-email-andrew@lunn.ch>
References: <1416086694-15790-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, linux@roeck-us.net,
	Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32999 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754916AbaKOVZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 16:25:28 -0500
In-Reply-To: <1416086694-15790-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The method to read the temperature used in the mve6123_61_65 driver
can also be used for other chips. Move the code into the shared code
base of mv88e6xxx.c.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6123_61_65.c | 50 +--------------------------------------
 drivers/net/dsa/mv88e6xxx.c       | 48 +++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h       |  1 +
 3 files changed, 50 insertions(+), 49 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index 9a3f9e0b0532..e9c736e1cef3 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -291,54 +291,6 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 	return 0;
 }
 
-#ifdef CONFIG_NET_DSA_HWMON
-
-static int  mv88e6123_61_65_get_temp(struct dsa_switch *ds, int *temp)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-	int val;
-
-	*temp = 0;
-
-	mutex_lock(&ps->phy_mutex);
-
-	ret = mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x6);
-	if (ret < 0)
-		goto error;
-
-	/* Enable temperature sensor */
-	ret = mv88e6xxx_phy_read(ds, 0x0, 0x1a);
-	if (ret < 0)
-		goto error;
-
-	ret = mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret | (1 << 5));
-	if (ret < 0)
-		goto error;
-
-	/* Wait for temperature to stabilize */
-	usleep_range(10000, 12000);
-
-	val = mv88e6xxx_phy_read(ds, 0x0, 0x1a);
-	if (val < 0) {
-		ret = val;
-		goto error;
-	}
-
-	/* Disable temperature sensor */
-	ret = mv88e6xxx_phy_write(ds, 0x0, 0x1a, ret & ~(1 << 5));
-	if (ret < 0)
-		goto error;
-
-	*temp = ((val & 0x1f) - 5) * 5;
-
-error:
-	mv88e6xxx_phy_write(ds, 0x0, 0x16, 0x0);
-	mutex_unlock(&ps->phy_mutex);
-	return ret;
-}
-#endif /* CONFIG_NET_DSA_HWMON */
-
 static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -471,7 +423,7 @@ struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
 	.get_ethtool_stats	= mv88e6123_61_65_get_ethtool_stats,
 	.get_sset_count		= mv88e6123_61_65_get_sset_count,
 #ifdef CONFIG_NET_DSA_HWMON
-	.get_temp		= mv88e6123_61_65_get_temp,
+	.get_temp		= mv88e6xxx_get_temp,
 #endif
 	.get_regs_len		= mv88e6xxx_get_regs_len,
 	.get_regs		= mv88e6xxx_get_regs,
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index da558d887dad..cd6807c6b4ed 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -539,6 +539,54 @@ void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 	}
 }
 
+#ifdef CONFIG_NET_DSA_HWMON
+
+int  mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
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
 static int __init mv88e6xxx_init(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index a0780b08bb4c..03e397efde36 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -81,6 +81,7 @@ void mv88e6xxx_get_ethtool_stats(struct dsa_switch *ds,
 int mv88e6xxx_get_regs_len(struct dsa_switch *ds, int port);
 void mv88e6xxx_get_regs(struct dsa_switch *ds, int port,
 			struct ethtool_regs *regs, void *_p);
+int  mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp);
 
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
-- 
2.1.3
