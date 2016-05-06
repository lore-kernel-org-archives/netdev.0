From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 17/21] net: dsa: mv88e6xxx: factorize GLOBAL_CONTROL_2 setup
Date: Fri,  6 May 2016 17:57:19 -0400
Message-ID: <1462571843-14397-18-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:43202 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759168AbcEFV60 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 17:58:26 -0400
In-Reply-To: <1462571843-14397-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
index 5df06d8..8f3a7c5 100644
--- a/drivers/net/dsa/mv88e6123.c
+++ b/drivers/net/dsa/mv88e6123.c
@@ -51,17 +51,6 @@ static const char *mv88e6123_drv_probe(struct device *dsa_dev,
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
@@ -73,10 +62,6 @@ static int mv88e6123_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	ret = mv88e6123_setup_global(ds);
-	if (ret < 0)
-		return ret;
-
 	return mv88e6xxx_setup_ports(ds);
 }
 
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index c8e3974..b6ca07b 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -61,22 +61,6 @@ static const char *mv88e6131_drv_probe(struct device *dsa_dev,
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
index a848aef..83678ad 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -58,17 +58,6 @@ static const char *mv88e6171_drv_probe(struct device *dsa_dev,
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
@@ -80,10 +69,6 @@ static int mv88e6171_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	ret = mv88e6171_setup_global(ds);
-	if (ret < 0)
-		return ret;
-
 	return mv88e6xxx_setup_ports(ds);
 }
 
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index e098870..81810dd 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -77,16 +77,6 @@ static const char *mv88e6352_drv_probe(struct device *dsa_dev,
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
@@ -98,10 +88,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	ret = mv88e6352_setup_global(ds);
-	if (ret < 0)
-		return ret;
-
 	return mv88e6xxx_setup_ports(ds);
 }
 
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 2d89829..261ca9a 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2950,6 +2950,13 @@ static int _mv88e6xxx_setup_global(struct mv88e6xxx_priv_state *ps)
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
