From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 09/11] net: dsa: remove PHY device argument from .set_eee
Date: Mon, 31 Jul 2017 18:17:17 -0400
Message-ID: <20170731221719.16695-10-vivien.didelot@savoirfairelinux.com>
References: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DSA switch operations for EEE are only meant to configure a port's
MAC EEE settings. The port's PHY EEE settings are accessed by the DSA
layer and must be made available via a proper PHY driver.

In order to reduce this confusion, remove the phy_device argument from
the .set_eee operation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c        |  1 -
 drivers/net/dsa/mv88e6xxx/chip.c |  2 +-
 drivers/net/dsa/qca8k.c          | 14 +++-----------
 include/net/dsa.h                |  1 -
 net/dsa/slave.c                  |  2 +-
 5 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 9d10aac8f241..ce886345d8d2 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -353,7 +353,6 @@ static int bcm_sf2_sw_get_eee(struct dsa_switch *ds, int port,
 }
 
 static int bcm_sf2_sw_set_eee(struct dsa_switch *ds, int port,
-			      struct phy_device *phydev,
 			      struct ethtool_eee *e)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 647d5d45c1d6..aaa96487f21f 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -850,7 +850,7 @@ static int mv88e6xxx_get_eee(struct dsa_switch *ds, int port,
 }
 
 static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
-			     struct phy_device *phydev, struct ethtool_eee *e)
+			     struct ethtool_eee *e)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 038a895d9a96..400333077a9f 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -637,8 +637,8 @@ qca8k_get_sset_count(struct dsa_switch *ds)
 	return ARRAY_SIZE(ar8327_mib);
 }
 
-static void
-qca8k_eee_enable_set(struct dsa_switch *ds, int port, bool enable)
+static int
+qca8k_set_eee(struct dsa_switch *ds, int port, struct ethtool_eee *eee)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
 	u32 lpi_en = QCA8K_REG_EEE_CTRL_LPI_EN(port);
@@ -646,20 +646,12 @@ qca8k_eee_enable_set(struct dsa_switch *ds, int port, bool enable)
 
 	mutex_lock(&priv->reg_mutex);
 	reg = qca8k_read(priv, QCA8K_REG_EEE_CTRL);
-	if (enable)
+	if (eee->eee_enabled)
 		reg |= lpi_en;
 	else
 		reg &= ~lpi_en;
 	qca8k_write(priv, QCA8K_REG_EEE_CTRL, reg);
 	mutex_unlock(&priv->reg_mutex);
-}
-
-static int
-qca8k_set_eee(struct dsa_switch *ds, int port,
-	      struct phy_device *phydev,
-	      struct ethtool_eee *e)
-{
-	qca8k_eee_enable_set(ds, port, e->eee_enabled);
 
 	return 0;
 }
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 88da272d20d0..ce46db323394 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -335,7 +335,6 @@ struct dsa_switch_ops {
 	 * EEE setttings
 	 */
 	int	(*set_eee)(struct dsa_switch *ds, int port,
-			   struct phy_device *phydev,
 			   struct ethtool_eee *e);
 	int	(*get_eee)(struct dsa_switch *ds, int port,
 			   struct ethtool_eee *e);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index bf71c206fe8f..6bc75ab438e8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -649,7 +649,7 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	int err = -ENODEV;
 
 	if (ds->ops->set_eee) {
-		err = ds->ops->set_eee(ds, p->dp->index, p->phy, e);
+		err = ds->ops->set_eee(ds, p->dp->index, e);
 		if (err)
 			return err;
 	}
-- 
2.13.3
