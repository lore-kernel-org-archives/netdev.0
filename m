From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 01/16] net: dsa: mv88e6xxx: Factor out common initialization code
Date: Thu, 26 Mar 2015 18:36:28 -0700
Message-ID: <1427420203-27685-2-git-send-email-linux@roeck-us.net>
References: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:39297 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753263AbbC0Bgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 21:36:51 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YbJCc-0020UU-Pl
	for netdev@vger.kernel.org; Fri, 27 Mar 2015 01:36:51 +0000
In-Reply-To: <1427420203-27685-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code used and needed in mv886xxx.c should be initialized there as well,
so factor it out from the individual initialization files.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Tested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/dsa/mv88e6123_61_65.c |  7 +++----
 drivers/net/dsa/mv88e6171.c       |  8 +++-----
 drivers/net/dsa/mv88e6352.c       |  7 ++++---
 drivers/net/dsa/mv88e6xxx.c       | 11 +++++++++++
 drivers/net/dsa/mv88e6xxx.h       |  1 +
 5 files changed, 22 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index e9c736e1cef3..6ebe57044afc 100644
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
index 9808c860a797..2f6662c246fa 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -292,12 +292,12 @@ static int mv88e6171_setup_port(struct dsa_switch *ds, int p)
 
 static int mv88e6171_setup(struct dsa_switch *ds)
 {
-	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
 	int i;
 	int ret;
 
-	mutex_init(&ps->smi_mutex);
-	mutex_init(&ps->stats_mutex);
+	ret = mv88e6xxx_setup_common(ds);
+	if (ret < 0)
+		return ret;
 
 	ret = mv88e6171_switch_reset(ds);
 	if (ret < 0)
@@ -318,8 +318,6 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 			return ret;
 	}
 
-	mutex_init(&ps->phy_mutex);
-
 	return 0;
 }
 
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 7bc5998384c6..75cf9e1c5a44 100644
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
index c18ffc98aacc..6496beb74510 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -700,6 +700,17 @@ int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
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
index 5fd42ced9011..a02d95a9b313 100644
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
