From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 07/12] net: dsa: Move phy page access functions into shared code
Date: Thu,  2 Apr 2015 04:06:35 +0200
Message-ID: <1427940400-12434-8-git-send-email-andrew@lunn.ch>
References: <1427940400-12434-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35836 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753087AbbDBCLm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 22:11:42 -0400
In-Reply-To: <1427940400-12434-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These functions could in future be used by other drivers. Move them
into the shared area.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6352.c | 45 +++++----------------------------------------
 drivers/net/dsa/mv88e6xxx.c | 34 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h |  4 +++-
 3 files changed, 42 insertions(+), 41 deletions(-)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 214bdbc8a5b1..fb16671c5f92 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -230,48 +230,13 @@ static int mv88e6352_setup_port(struct dsa_switch *ds, int p)
 
 #ifdef CONFIG_NET_DSA_HWMON
 
-static int mv88e6352_phy_page_read(struct dsa_switch *ds,
-				   int port, int page, int reg)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-
-	mutex_lock(&ps->phy_mutex);
-	ret = mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
-	if (ret < 0)
-		goto error;
-	ret = mv88e6xxx_phy_read_indirect(ds, port, reg);
-error:
-	mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
-	mutex_unlock(&ps->phy_mutex);
-	return ret;
-}
-
-static int mv88e6352_phy_page_write(struct dsa_switch *ds,
-				    int port, int page, int reg, int val)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-
-	mutex_lock(&ps->phy_mutex);
-	ret = mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
-	if (ret < 0)
-		goto error;
-
-	ret = mv88e6xxx_phy_write_indirect(ds, port, reg, val);
-error:
-	mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
-	mutex_unlock(&ps->phy_mutex);
-	return ret;
-}
-
 static int mv88e6352_get_temp(struct dsa_switch *ds, int *temp)
 {
 	int ret;
 
 	*temp = 0;
 
-	ret = mv88e6352_phy_page_read(ds, 0, 6, 27);
+	ret = mv88e6xxx_phy_page_read(ds, 0, 6, 27);
 	if (ret < 0)
 		return ret;
 
@@ -286,7 +251,7 @@ static int mv88e6352_get_temp_limit(struct dsa_switch *ds, int *temp)
 
 	*temp = 0;
 
-	ret = mv88e6352_phy_page_read(ds, 0, 6, 26);
+	ret = mv88e6xxx_phy_page_read(ds, 0, 6, 26);
 	if (ret < 0)
 		return ret;
 
@@ -299,11 +264,11 @@ static int mv88e6352_set_temp_limit(struct dsa_switch *ds, int temp)
 {
 	int ret;
 
-	ret = mv88e6352_phy_page_read(ds, 0, 6, 26);
+	ret = mv88e6xxx_phy_page_read(ds, 0, 6, 26);
 	if (ret < 0)
 		return ret;
 	temp = clamp_val(DIV_ROUND_CLOSEST(temp, 5) + 5, 0, 0x1f);
-	return mv88e6352_phy_page_write(ds, 0, 6, 26,
+	return mv88e6xxx_phy_page_write(ds, 0, 6, 26,
 					(ret & 0xe0ff) | (temp << 8));
 }
 
@@ -313,7 +278,7 @@ static int mv88e6352_get_temp_alarm(struct dsa_switch *ds, bool *alarm)
 
 	*alarm = false;
 
-	ret = mv88e6352_phy_page_read(ds, 0, 6, 26);
+	ret = mv88e6xxx_phy_page_read(ds, 0, 6, 26);
 	if (ret < 0)
 		return ret;
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 9db5b40d78ea..df727e1db18d 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1201,6 +1201,40 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 	return 0;
 }
 
+int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	mutex_lock(&ps->phy_mutex);
+	ret = mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
+	if (ret < 0)
+		goto error;
+	ret = mv88e6xxx_phy_read_indirect(ds, port, reg);
+error:
+	mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
+}
+
+int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
+			     int reg, int val)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+	int ret;
+
+	mutex_lock(&ps->phy_mutex);
+	ret = mv88e6xxx_phy_write_indirect(ds, port, 0x16, page);
+	if (ret < 0)
+		goto error;
+
+	ret = mv88e6xxx_phy_write_indirect(ds, port, reg, val);
+error:
+	mv88e6xxx_phy_write_indirect(ds, port, 0x16, 0x0);
+	mutex_unlock(&ps->phy_mutex);
+	return ret;
+}
+
 static int __init mv88e6xxx_init(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index f84d3d5178b9..49614765760f 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -175,7 +175,9 @@ int mv88e6xxx_port_fdb_del(struct dsa_switch *ds, int port,
 			   const unsigned char *addr, u16 vid);
 int mv88e6xxx_port_fdb_getnext(struct dsa_switch *ds, int port,
 			       unsigned char *addr, bool *is_static);
-
+int mv88e6xxx_phy_page_read(struct dsa_switch *ds, int port, int page, int reg);
+int mv88e6xxx_phy_page_write(struct dsa_switch *ds, int port, int page,
+			     int reg, int val);
 extern struct dsa_switch_driver mv88e6131_switch_driver;
 extern struct dsa_switch_driver mv88e6123_61_65_switch_driver;
 extern struct dsa_switch_driver mv88e6352_switch_driver;
-- 
2.1.4
