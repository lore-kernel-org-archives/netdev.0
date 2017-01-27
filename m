From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 1/9] net: dsa: variable number of ports
Date: Fri, 27 Jan 2017 15:29:36 -0500
Message-ID: <20170127202944.28598-2-vivien.didelot@savoirfairelinux.com>
References: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the ports[DSA_MAX_PORTS] array of the dsa_switch structure for a
zero-length array, allocated at the same time as the dsa_switch
structure itself. A dsa_switch_alloc() helper is provided for that.

This commit brings no functional change yet since we pass DSA_MAX_PORTS
as the number of ports for the moment. Future patches can update the DSA
drivers separately to support dynamic number of ports.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/b53/b53_common.c |  7 ++++---
 drivers/net/dsa/mv88e6xxx/chip.c |  3 +--
 drivers/net/dsa/qca8k.c          |  3 +--
 include/net/dsa.h                |  6 +++++-
 net/dsa/dsa.c                    |  5 ++---
 net/dsa/dsa2.c                   | 16 ++++++++++++++++
 6 files changed, 29 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index bb210b12ad1b..31afc4d4b68b 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1790,14 +1790,15 @@ struct b53_device *b53_switch_alloc(struct device *base,
 	struct dsa_switch *ds;
 	struct b53_device *dev;
 
-	ds = devm_kzalloc(base, sizeof(*ds) + sizeof(*dev), GFP_KERNEL);
+	ds = dsa_switch_alloc(base, DSA_MAX_PORTS);
 	if (!ds)
 		return NULL;
 
-	dev = (struct b53_device *)(ds + 1);
+	dev = devm_kzalloc(base, sizeof(*dev), GFP_KERNEL);
+	if (!dev)
+		return NULL;
 
 	ds->priv = dev;
-	ds->dev = base;
 	dev->dev = base;
 
 	dev->ds = ds;
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 921e53351786..cb7b24748336 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -4361,11 +4361,10 @@ static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip)
 	struct device *dev = chip->dev;
 	struct dsa_switch *ds;
 
-	ds = devm_kzalloc(dev, sizeof(*ds), GFP_KERNEL);
+	ds = dsa_switch_alloc(dev, DSA_MAX_PORTS);
 	if (!ds)
 		return -ENOMEM;
 
-	ds->dev = dev;
 	ds->priv = chip;
 	ds->ops = &mv88e6xxx_switch_ops;
 
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index c084aa484d2b..f67c6a3cebff 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -954,12 +954,11 @@ qca8k_sw_probe(struct mdio_device *mdiodev)
 	if (id != QCA8K_ID_QCA8337)
 		return -ENODEV;
 
-	priv->ds = devm_kzalloc(&mdiodev->dev, sizeof(*priv->ds), GFP_KERNEL);
+	priv->ds = dsa_switch_alloc(&mdiodev->dev, DSA_MAX_PORTS);
 	if (!priv->ds)
 		return -ENOMEM;
 
 	priv->ds->priv = priv;
-	priv->ds->dev = &mdiodev->dev;
 	priv->ds->ops = &qca8k_switch_ops;
 	mutex_init(&priv->reg_mutex);
 	dev_set_drvdata(&mdiodev->dev, priv);
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 92fd795e9573..24e1d935ae68 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -190,8 +190,11 @@ struct dsa_switch {
 	u32			cpu_port_mask;
 	u32			enabled_port_mask;
 	u32			phys_mii_mask;
-	struct dsa_port		ports[DSA_MAX_PORTS];
 	struct mii_bus		*slave_mii_bus;
+
+	/* Dynamically allocated ports, keep last */
+	size_t num_ports;
+	struct dsa_port ports[];
 };
 
 static inline bool dsa_is_cpu_port(struct dsa_switch *ds, int p)
@@ -386,6 +389,7 @@ static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 	return dst->rcv != NULL;
 }
 
+struct dsa_switch *dsa_switch_alloc(struct device *dev, size_t n);
 void dsa_unregister_switch(struct dsa_switch *ds);
 int dsa_register_switch(struct dsa_switch *ds, struct device *dev);
 #ifdef CONFIG_PM_SLEEP
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 07e863369e04..de3ffb421ee4 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -347,8 +347,8 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	/*
 	 * Allocate and initialise switch state.
 	 */
-	ds = devm_kzalloc(parent, sizeof(*ds), GFP_KERNEL);
-	if (ds == NULL)
+	ds = dsa_switch_alloc(parent, DSA_MAX_PORTS);
+	if (!ds)
 		return ERR_PTR(-ENOMEM);
 
 	ds->dst = dst;
@@ -356,7 +356,6 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	ds->cd = cd;
 	ds->ops = ops;
 	ds->priv = priv;
-	ds->dev = parent;
 
 	ret = dsa_switch_setup_one(ds, parent);
 	if (ret)
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 75f5d1f8554b..4b3a44bec5c8 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -666,6 +666,22 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 	return err;
 }
 
+struct dsa_switch *dsa_switch_alloc(struct device *dev, size_t n)
+{
+	size_t size = sizeof(struct dsa_switch) + n * sizeof(struct dsa_port);
+	struct dsa_switch *ds;
+
+	ds = devm_kzalloc(dev, size, GFP_KERNEL);
+	if (!ds)
+		return NULL;
+
+	ds->dev = dev;
+	ds->num_ports = n;
+
+	return ds;
+}
+EXPORT_SYMBOL_GPL(dsa_switch_alloc);
+
 int dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 {
 	int err;
-- 
2.11.0
