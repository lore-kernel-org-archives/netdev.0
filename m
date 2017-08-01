From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 08/11] net: dsa: call phy_init_eee in DSA layer
Date: Tue,  1 Aug 2017 16:32:38 -0400
Message-ID: <20170801203241.22294-9-vivien.didelot@savoirfairelinux.com>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All DSA drivers are calling phy_init_eee if eee_enabled is true.

Move up this statement in the DSA layer to simplify the DSA drivers.
qca8k does not require to cache the ethtool_eee structures from now on.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/bcm_sf2.c        |  9 +--------
 drivers/net/dsa/mv88e6xxx/chip.c |  6 ------
 drivers/net/dsa/qca8k.c          | 31 ++-----------------------------
 drivers/net/dsa/qca8k.h          |  1 -
 net/dsa/slave.c                  |  6 ++++++
 5 files changed, 9 insertions(+), 44 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index aef475f1ce06..9d10aac8f241 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -360,14 +360,7 @@ static int bcm_sf2_sw_set_eee(struct dsa_switch *ds, int port,
 	struct ethtool_eee *p = &priv->port_sts[port].eee;
 
 	p->eee_enabled = e->eee_enabled;
-
-	if (!p->eee_enabled) {
-		bcm_sf2_eee_enable_set(ds, port, false);
-	} else {
-		p->eee_enabled = bcm_sf2_eee_init(ds, port, phydev);
-		if (!p->eee_enabled)
-			return -EOPNOTSUPP;
-	}
+	bcm_sf2_eee_enable_set(ds, port, e->eee_enabled);
 
 	return 0;
 }
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index b531d4a3bab5..647d5d45c1d6 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -855,12 +855,6 @@ static int mv88e6xxx_set_eee(struct dsa_switch *ds, int port,
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
 
-	if (e->eee_enabled) {
-		err = phy_init_eee(phydev, 0);
-		if (err)
-			return err;
-	}
-
 	mutex_lock(&chip->reg_lock);
 	err = mv88e6xxx_energy_detect_write(chip, port, e);
 	mutex_unlock(&chip->reg_lock);
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 8cd4634c6985..bfe0172ae6cc 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -655,40 +655,13 @@ qca8k_eee_enable_set(struct dsa_switch *ds, int port, bool enable)
 }
 
 static int
-qca8k_eee_init(struct dsa_switch *ds, int port,
-	       struct phy_device *phy)
-{
-	int ret;
-
-	ret = phy_init_eee(phy, 0);
-	if (ret)
-		return 0;
-
-	qca8k_eee_enable_set(ds, port, true);
-
-	return 1;
-}
-
-static int
 qca8k_set_eee(struct dsa_switch *ds, int port,
 	      struct phy_device *phydev,
 	      struct ethtool_eee *e)
 {
-	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
-	struct ethtool_eee *p = &priv->port_sts[port].eee;
-	int ret = 0;
+	qca8k_eee_enable_set(ds, port, e->eee_enabled);
 
-	p->eee_enabled = e->eee_enabled;
-
-	if (!p->eee_enabled) {
-		qca8k_eee_enable_set(ds, port, false);
-	} else {
-		p->eee_enabled = qca8k_eee_init(ds, port, phydev);
-		if (!p->eee_enabled)
-			ret = -EOPNOTSUPP;
-	}
-
-	return ret;
+	return 0;
 }
 
 static int
diff --git a/drivers/net/dsa/qca8k.h b/drivers/net/dsa/qca8k.h
index 1ed4fac6cd6d..1cf8a920d4ff 100644
--- a/drivers/net/dsa/qca8k.h
+++ b/drivers/net/dsa/qca8k.h
@@ -156,7 +156,6 @@ enum qca8k_fdb_cmd {
 };
 
 struct ar8xxx_port_status {
-	struct ethtool_eee eee;
 	int enabled;
 };
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 7df55d597740..ad5caaf384d7 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -659,6 +659,12 @@ static int dsa_slave_set_eee(struct net_device *dev, struct ethtool_eee *e)
 	if (ret)
 		return ret;
 
+	if (e->eee_enabled) {
+		ret = phy_init_eee(p->phy, 0);
+		if (ret)
+			return ret;
+	}
+
 	return phy_ethtool_set_eee(p->phy, e);
 }
 
-- 
2.13.3
