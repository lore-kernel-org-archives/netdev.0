From: Guenter Roeck <linux@roeck-us.net>
Subject: [RFT/RFC PATCH 1/8] net: dsa: mv88e6xxx: Factor out common initialization code
Date: Mon, 23 Feb 2015 11:35:43 -0800
Message-ID: <1424720150-27564-2-git-send-email-linux@roeck-us.net>
References: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:34249 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbbBWTf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 14:35:58 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YPynN-003fBU-Kz
	for netdev@vger.kernel.org; Mon, 23 Feb 2015 19:35:58 +0000
In-Reply-To: <1424720150-27564-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code used and needed in mv886xxx.c should be initialized there as well,
so factor it out from the individual initialization files.

Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6123_61_65.c |  7 +++----
 drivers/net/dsa/mv88e6171.c       |  5 +++--
 drivers/net/dsa/mv88e6352.c       |  7 ++++---
 drivers/net/dsa/mv88e6xxx.c       | 11 +++++++++++
 drivers/net/dsa/mv88e6xxx.h       |  1 +
 5 files changed, 22 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index e9c736e..6ebe570 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -293,13 +293,12 @@ static int mv88e6123_61_65_setup_port(struct dsa_switch *ds, int p)
 
 static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	int i;
 	int ret;
 
-	mutex_init(&ps->smi_mutex);
-	mutex_init(&ps->stats_mutex);
-	mutex_init(&ps->phy_mutex);
+	ret = mv88e6xxx_setup_common(ds);
+	if (ret < 0)
+		return ret;
 
 	ret = mv88e6123_61_65_switch_reset(ds);
 	if (ret < 0)
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 9808c86..2374205 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -296,8 +296,9 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	int i;
 	int ret;
 
-	mutex_init(&ps->smi_mutex);
-	mutex_init(&ps->stats_mutex);
+	ret = mv88e6xxx_setup_common(ds);
+	if (ret < 0)
+		return ret;
 
 	ret = mv88e6171_switch_reset(ds);
 	if (ret < 0)
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 7bc5998..75cf9e1 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -385,9 +385,10 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	int ret;
 	int i;
 
-	mutex_init(&ps->smi_mutex);
-	mutex_init(&ps->stats_mutex);
-	mutex_init(&ps->phy_mutex);
+	ret = mv88e6xxx_setup_common(ds);
+	if (ret < 0)
+		return ret;
+
 	mutex_init(&ps->eeprom_mutex);
 
 	ps->id = REG_READ(REG_PORT(0), 0x03) & 0xfff0;
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 2d5306a..7b767e3 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -704,6 +704,17 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	return 0;
 }
 
+int mv88e6xxx_setup_common(struct dsa_switch *ds)
+{
+	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
+
+	mutex_init(&ps->smi_mutex);
+	mutex_init(&ps->stats_mutex);
+	mutex_init(&ps->phy_mutex);
+
+	return 0;
+}
+
 static int __init mv88e6xxx_init(void)
 {
 #if IS_ENABLED(CONFIG_NET_DSA_MV88E6131)
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 5fd42ce..a02d95a 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -57,6 +57,7 @@ struct mv88e6xxx_hw_stat {
 	int reg;
 };
 
+int mv88e6xxx_setup_common(struct dsa_switch *ds);
 int __mv88e6xxx_reg_read(struct mii_bus *bus, int sw_addr, int addr, int reg);
 int mv88e6xxx_reg_read(struct dsa_switch *ds, int addr, int reg);
 int __mv88e6xxx_reg_write(struct mii_bus *bus, int sw_addr, int addr,
-- 
2.1.0
