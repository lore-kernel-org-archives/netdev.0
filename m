From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 16/20] net: dsa: mv88e6xxx: factorize GLOBAL_CONTROL_2 setup
Date: Thu,  5 May 2016 18:41:00 -0400
Message-ID: <1462488064-1841-17-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All switch models setup the GLOBAL_CONTROL_2 register with slightly
differences.

Since the cascade mode is valid even in a single chip setup, factorize
such configuration.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6123.c | 15 ---------------
 drivers/net/dsa/mv88e6131.c | 16 ----------------
 drivers/net/dsa/mv88e6171.c | 15 ---------------
 drivers/net/dsa/mv88e6352.c | 14 --------------
 drivers/net/dsa/mv88e6xxx.c |  7 +++++++
 5 files changed, 7 insertions(+), 60 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123.c b/drivers/net/dsa/mv88e6123.c
index 98eaee1..9d3f672 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -54,17 +54,6 @@ static const char *mv88e6123_drv_probe(struct device *dsa_dev,
 				   ARRAY_SIZE(mv88e6123_table));
 }
 
-static int mv88e6123_setup_global(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
-	/* Disable remote management for now, and set the switch's
-	 * DSA device number.
-	 */
-	return mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
-				   ds->index & 0x1f);
-}
-
 static int mv88e6123_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -76,10 +65,6 @@ static int mv88e6123_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	ret = mv88e6123_setup_global(ds);
-	if (ret < 0)
-		return ret;
-
 	return mv88e6xxx_setup_ports(ds);
 }
 
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index c675070..14d0722 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -77,22 +77,6 @@ static const char *mv88e6131_drv_probe(struct device *dsa_dev,
 static int mv88e6131_setup_global(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int ret;
-
-	/* Disable cascade port functionality unless this device
-	 * is used in a cascade configuration, and set the switch's
-	 * DSA device number.
-	 */
-	if (ds->dst->pd->nr_chips > 1)
-		ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
-					  GLOBAL_CONTROL_2_MULTIPLE_CASCADE |
-					  (ds->index & 0x1f));
-	else
-		ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
-					  GLOBAL_CONTROL_2_NO_CASCADE |
-					  (ds->index & 0x1f));
-	if (ret)
-		return ret;
 
 	/* Force the priority of IGMP/MLD snoop frames and ARP frames
 	 * to the highest setting.
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index 4c14f9f..df7a810 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -86,17 +86,6 @@ static const char *mv88e6171_drv_probe(struct device *dsa_dev,
 				   ARRAY_SIZE(mv88e6171_table));
 }
 
-static int mv88e6171_setup_global(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
-	/* Disable remote management for now, and set the switch's
-	 * DSA device number.
-	 */
-	return mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
-				   ds->index & 0x1f);
-}
-
 static int mv88e6171_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -108,10 +97,6 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	ret = mv88e6171_setup_global(ds);
-	if (ret < 0)
-		return ret;
-
 	return mv88e6xxx_setup_ports(ds);
 }
 
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 52547d0..b24bae1 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -137,16 +137,6 @@ static const char *mv88e6352_drv_probe(struct device *dsa_dev,
 				   ARRAY_SIZE(mv88e6352_table));
 }
 
-static int mv88e6352_setup_global(struct dsa_switch *ds)
-{
-	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-
-	/* Disable remote management for now, and set the switch's
-	 * DSA device number.
-	 */
-	return mv88e6xxx_reg_write(ps, REG_GLOBAL, 0x1c, ds->index & 0x1f);
-}
-
 static int mv88e6352_setup(struct dsa_switch *ds)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
@@ -158,10 +148,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	ret = mv88e6352_setup_global(ds);
-	if (ret < 0)
-		return ret;
-
 	return mv88e6xxx_setup_ports(ds);
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index de37f20..2c4594b 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2949,6 +2949,13 @@ static int _mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
 	if (err)
 		return err;
 
+	/* Disable remote management, and set the switch's DSA device number. */
+	err = _mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CONTROL_2,
+				   GLOBAL_CONTROL_2_MULTIPLE_CASCADE |
+				   (ds->index & 0x1f));
+	if (err)
+		return err;
+
 	/* Set the default address aging time to 5 minutes, and
 	 * enable address learn messages to be sent to all message
 	 * ports.
-- 
2.8.2
