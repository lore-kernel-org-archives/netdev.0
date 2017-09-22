From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/4] net: dsa: remove phy arg from port enable/disable
Date: Fri, 22 Sep 2017 12:17:51 -0400
Message-ID: <20170922161753.19563-3-vivien.didelot@savoirfairelinux.com>
References: <20170922161753.19563-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170922161753.19563-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The .port_enable and .port_disable functions are meant to deal with the
switch ports only, and no driver is using the phy argument anyway.
Remove it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c       |  6 +++---
 drivers/net/dsa/b53/b53_priv.h         |  4 ++--
 drivers/net/dsa/bcm_sf2.c              | 16 +++++++---------
 drivers/net/dsa/lan9303-core.c         |  6 ++----
 drivers/net/dsa/microchip/ksz_common.c |  6 ++----
 drivers/net/dsa/mt7530.c               |  8 +++-----
 drivers/net/dsa/mv88e6xxx/chip.c       |  6 ++----
 drivers/net/dsa/qca8k.c                |  6 ++----
 include/net/dsa.h                      |  6 ++----
 net/dsa/slave.c                        |  4 ++--
 10 files changed, 27 insertions(+), 41 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index d4ce092def83..e46eb29d29f0 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -502,7 +502,7 @@ void b53_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 }
 EXPORT_SYMBOL(b53_imp_vlan_setup);
 
-int b53_enable_port(struct dsa_switch *ds, int port, struct phy_device *phy)
+int b53_enable_port(struct dsa_switch *ds, int port)
 {
 	struct b53_device *dev = ds->priv;
 	unsigned int cpu_port = dev->cpu_port;
@@ -531,7 +531,7 @@ int b53_enable_port(struct dsa_switch *ds, int port, struct phy_device *phy)
 }
 EXPORT_SYMBOL(b53_enable_port);
 
-void b53_disable_port(struct dsa_switch *ds, int port, struct phy_device *phy)
+void b53_disable_port(struct dsa_switch *ds, int port)
 {
 	struct b53_device *dev = ds->priv;
 	u8 reg;
@@ -874,7 +874,7 @@ static int b53_setup(struct dsa_switch *ds)
 		if (dsa_is_cpu_port(ds, port))
 			b53_enable_cpu_port(dev, port);
 		else if (!(BIT(port) & ds->enabled_port_mask))
-			b53_disable_port(ds, port, NULL);
+			b53_disable_port(ds, port);
 	}
 
 	return ret;
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index 603c66d240d8..688d02ee6155 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -311,8 +311,8 @@ int b53_mirror_add(struct dsa_switch *ds, int port,
 		   struct dsa_mall_mirror_tc_entry *mirror, bool ingress);
 void b53_mirror_del(struct dsa_switch *ds, int port,
 		    struct dsa_mall_mirror_tc_entry *mirror);
-int b53_enable_port(struct dsa_switch *ds, int port, struct phy_device *phy);
-void b53_disable_port(struct dsa_switch *ds, int port, struct phy_device *phy);
+int b53_enable_port(struct dsa_switch *ds, int port);
+void b53_disable_port(struct dsa_switch *ds, int port);
 void b53_brcm_hdr_setup(struct dsa_switch *ds, int port);
 void b53_eee_enable_set(struct dsa_switch *ds, int port, bool enable);
 int b53_eee_init(struct dsa_switch *ds, int port, struct phy_device *phy);
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index ad96b9725a2c..77e0c43f973b 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -159,8 +159,7 @@ static inline void bcm_sf2_port_intr_disable(struct bcm_sf2_priv *priv,
 	intrl2_1_writel(priv, P_IRQ_MASK(off), INTRL2_CPU_CLEAR);
 }
 
-static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
-			      struct phy_device *phy)
+static int bcm_sf2_port_setup(struct dsa_switch *ds, int port)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	unsigned int i;
@@ -191,11 +190,10 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 	if (port == priv->moca_port)
 		bcm_sf2_port_intr_enable(priv, port);
 
-	return b53_enable_port(ds, port, phy);
+	return b53_enable_port(ds, port);
 }
 
-static void bcm_sf2_port_disable(struct dsa_switch *ds, int port,
-				 struct phy_device *phy)
+static void bcm_sf2_port_disable(struct dsa_switch *ds, int port)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	u32 off, reg;
@@ -214,7 +212,7 @@ static void bcm_sf2_port_disable(struct dsa_switch *ds, int port,
 	else
 		off = CORE_G_PCTL_PORT(port);
 
-	b53_disable_port(ds, port, phy);
+	b53_disable_port(ds, port);
 
 	/* Power down the port memory */
 	reg = core_readl(priv, CORE_MEM_PSM_VDD_CTRL);
@@ -613,7 +611,7 @@ static int bcm_sf2_sw_suspend(struct dsa_switch *ds)
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if ((1 << port) & ds->enabled_port_mask ||
 		    dsa_is_cpu_port(ds, port))
-			bcm_sf2_port_disable(ds, port, NULL);
+			bcm_sf2_port_disable(ds, port);
 	}
 
 	return 0;
@@ -636,7 +634,7 @@ static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
 		if ((1 << port) & ds->enabled_port_mask)
-			bcm_sf2_port_setup(ds, port, NULL);
+			bcm_sf2_port_setup(ds, port);
 		else if (dsa_is_cpu_port(ds, port))
 			bcm_sf2_imp_setup(ds, port);
 	}
@@ -745,7 +743,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 		if (dsa_is_cpu_port(ds, port))
 			bcm_sf2_imp_setup(ds, port);
 		else if (!((1 << port) & ds->enabled_port_mask))
-			bcm_sf2_port_disable(ds, port, NULL);
+			bcm_sf2_port_disable(ds, port);
 	}
 
 	bcm_sf2_sw_configure_vlan(ds);
diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index 07355db2ad81..0c33b02562dc 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -799,8 +799,7 @@ static void lan9303_adjust_link(struct dsa_switch *ds, int port,
 	}
 }
 
-static int lan9303_port_enable(struct dsa_switch *ds, int port,
-			       struct phy_device *phy)
+static int lan9303_port_enable(struct dsa_switch *ds, int port)
 {
 	struct lan9303 *chip = ds->priv;
 
@@ -817,8 +816,7 @@ static int lan9303_port_enable(struct dsa_switch *ds, int port,
 	return -ENODEV;
 }
 
-static void lan9303_port_disable(struct dsa_switch *ds, int port,
-				 struct phy_device *phy)
+static void lan9303_port_disable(struct dsa_switch *ds, int port)
 {
 	struct lan9303 *chip = ds->priv;
 
diff --git a/drivers/net/dsa/microchip/ksz_common.c b/drivers/net/dsa/microchip/ksz_common.c
index 56cd6d365352..4095c50ae111 100644
--- a/drivers/net/dsa/microchip/ksz_common.c
+++ b/drivers/net/dsa/microchip/ksz_common.c
@@ -418,8 +418,7 @@ static int ksz_phy_write16(struct dsa_switch *ds, int addr, int reg, u16 val)
 	return 0;
 }
 
-static int ksz_enable_port(struct dsa_switch *ds, int port,
-			   struct phy_device *phy)
+static int ksz_enable_port(struct dsa_switch *ds, int port)
 {
 	struct ksz_device *dev = ds->priv;
 
@@ -429,8 +428,7 @@ static int ksz_enable_port(struct dsa_switch *ds, int port,
 	return 0;
 }
 
-static void ksz_disable_port(struct dsa_switch *ds, int port,
-			     struct phy_device *phy)
+static void ksz_disable_port(struct dsa_switch *ds, int port)
 {
 	struct ksz_device *dev = ds->priv;
 
diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index faa3b88d2206..0a7f6209767f 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -693,8 +693,7 @@ mt7530_cpu_port_enable(struct mt7530_priv *priv,
 }
 
 static int
-mt7530_port_enable(struct dsa_switch *ds, int port,
-		   struct phy_device *phy)
+mt7530_port_enable(struct dsa_switch *ds, int port)
 {
 	struct mt7530_priv *priv = ds->priv;
 
@@ -719,8 +718,7 @@ mt7530_port_enable(struct dsa_switch *ds, int port,
 }
 
 static void
-mt7530_port_disable(struct dsa_switch *ds, int port,
-		    struct phy_device *phy)
+mt7530_port_disable(struct dsa_switch *ds, int port)
 {
 	struct mt7530_priv *priv = ds->priv;
 
@@ -1006,7 +1004,7 @@ mt7530_setup(struct dsa_switch *ds)
 		if (dsa_is_cpu_port(ds, i))
 			mt7530_cpu_port_enable(priv, i);
 		else
-			mt7530_port_disable(ds, i, NULL);
+			mt7530_port_disable(ds, i);
 	}
 
 	/* Flush the FDB table */
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index c6678aa9b4ef..e47898fb7dbc 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -1862,8 +1862,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	return mv88e6xxx_port_write(chip, port, MV88E6XXX_PORT_DEFAULT_VLAN, 0);
 }
 
-static int mv88e6xxx_port_enable(struct dsa_switch *ds, int port,
-				 struct phy_device *phydev)
+static int mv88e6xxx_port_enable(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 	int err;
@@ -1875,8 +1874,7 @@ static int mv88e6xxx_port_enable(struct dsa_switch *ds, int port,
 	return err;
 }
 
-static void mv88e6xxx_port_disable(struct dsa_switch *ds, int port,
-				   struct phy_device *phydev)
+static void mv88e6xxx_port_disable(struct dsa_switch *ds, int port)
 {
 	struct mv88e6xxx_chip *chip = ds->priv;
 
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 82f09711ac1a..622ee9b8e72b 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -743,8 +743,7 @@ qca8k_port_bridge_leave(struct dsa_switch *ds, int port, struct net_device *br)
 }
 
 static int
-qca8k_port_enable(struct dsa_switch *ds, int port,
-		  struct phy_device *phy)
+qca8k_port_enable(struct dsa_switch *ds, int port)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
 
@@ -755,8 +754,7 @@ qca8k_port_enable(struct dsa_switch *ds, int port,
 }
 
 static void
-qca8k_port_disable(struct dsa_switch *ds, int port,
-		   struct phy_device *phy)
+qca8k_port_disable(struct dsa_switch *ds, int port)
 {
 	struct qca8k_priv *priv = (struct qca8k_priv *)ds->priv;
 
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 8dee216a5a9b..65b031a69c19 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -337,10 +337,8 @@ struct dsa_switch_ops {
 	/*
 	 * Port enable/disable
 	 */
-	int	(*port_enable)(struct dsa_switch *ds, int port,
-			       struct phy_device *phy);
-	void	(*port_disable)(struct dsa_switch *ds, int port,
-				struct phy_device *phy);
+	int	(*port_enable)(struct dsa_switch *ds, int port);
+	void	(*port_disable)(struct dsa_switch *ds, int port);
 
 	/*
 	 * Port's MAC EEE settings
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 606812160fd5..6290741e496a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -100,7 +100,7 @@ static int dsa_slave_open(struct net_device *dev)
 	}
 
 	if (ds->ops->port_enable) {
-		err = ds->ops->port_enable(ds, p->dp->index, p->phy);
+		err = ds->ops->port_enable(ds, p->dp->index);
 		if (err)
 			goto clear_promisc;
 	}
@@ -155,7 +155,7 @@ static int dsa_slave_close(struct net_device *dev)
 		dev_uc_del(master, dev->dev_addr);
 
 	if (ds->ops->port_disable)
-		ds->ops->port_disable(ds, p->dp->index, p->phy);
+		ds->ops->port_disable(ds, p->dp->index);
 
 	dsa_port_set_state_now(p->dp, BR_STATE_DISABLED);
 
-- 
2.14.1
