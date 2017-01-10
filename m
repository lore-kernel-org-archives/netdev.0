From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 1/8] net: dsa: Pass device pointer to
 dsa_register_switch
Date: Tue, 10 Jan 2017 12:12:28 -0800
Message-ID: <20170110201235.21771-2-f.fainelli@gmail.com>
References: <20170110201235.21771-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 Ingo Tuchscherer <ingo.tuchscherer@linux.vnet.ibm.com>,
 Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 open list <linux-kernel@vger.kernel.org>, Russell King <linux@armlinux.org.uk>,
 Stuart Yoder <stuart.yoder@nxp.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Philippe Reynes <tremyfr@gmail.com>, "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM/Marvell Dove/MV78xx0/Orion SOC support"
 <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170110201235.21771-1-f.fainelli@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

In preparation for allowing dsa_register_switch() to be supplied with
device/platform data, pass down a struct device pointer instead of a
struct device_node.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c |  2 +-
 drivers/net/dsa/mv88e6xxx/chip.c | 11 ++++++-----
 drivers/net/dsa/qca8k.c          |  2 +-
 include/net/dsa.h                |  2 +-
 net/dsa/dsa2.c                   |  7 ++++---
 5 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 5102a3701a1a..7179eed9ee6d 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1882,7 +1882,7 @@ int b53_switch_register(struct b53_device *dev)
 
 	pr_info("found switch: %s, rev %i\n", dev->name, dev->core_rev);
 
-	return dsa_register_switch(dev->ds, dev->ds->dev->of_node);
+	return dsa_register_switch(dev->ds, dev->ds->dev);
 }
 EXPORT_SYMBOL(b53_switch_register);
 
diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index eea8e0176e33..1060597e160a 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -4407,8 +4407,7 @@ static struct dsa_switch_driver mv88e6xxx_switch_drv = {
 	.ops			= &mv88e6xxx_switch_ops,
 };
 
-static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip,
-				     struct device_node *np)
+static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip)
 {
 	struct device *dev = chip->dev;
 	struct dsa_switch *ds;
@@ -4423,7 +4422,7 @@ static int mv88e6xxx_register_switch(struct mv88e6xxx_chip *chip,
 
 	dev_set_drvdata(dev, ds);
 
-	return dsa_register_switch(ds, np);
+	return dsa_register_switch(ds, dev);
 }
 
 static void mv88e6xxx_unregister_switch(struct mv88e6xxx_chip *chip)
@@ -4507,9 +4506,11 @@ static int mv88e6xxx_probe(struct mdio_device *mdiodev)
 	if (err)
 		goto out_g2_irq;
 
-	err = mv88e6xxx_register_switch(chip, np);
-	if (err)
+	err = mv88e6xxx_register_switch(chip);
+	if (err) {
+		mv88e6xxx_mdio_unregister(chip);
 		goto out_mdio;
+	}
 
 	return 0;
 
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 54d270d59eb0..c084aa484d2b 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -964,7 +964,7 @@ qca8k_sw_probe(struct mdio_device *mdiodev)
 	mutex_init(&priv->reg_mutex);
 	dev_set_drvdata(&mdiodev->dev, priv);
 
-	return dsa_register_switch(priv->ds, priv->ds->dev->of_node);
+	return dsa_register_switch(priv->ds, &mdiodev->dev);
 }
 
 static void
diff --git a/include/net/dsa.h b/include/net/dsa.h
index b94d1f2ef912..16a502a6c26a 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -403,7 +403,7 @@ static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 }
 
 void dsa_unregister_switch(struct dsa_switch *ds);
-int dsa_register_switch(struct dsa_switch *ds, struct device_node *np);
+int dsa_register_switch(struct dsa_switch *ds, struct device *dev);
 #ifdef CONFIG_PM_SLEEP
 int dsa_switch_suspend(struct dsa_switch *ds);
 int dsa_switch_resume(struct dsa_switch *ds);
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index bad119cee2a3..f0e3212ae9d5 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -592,8 +592,9 @@ static struct device_node *dsa_get_ports(struct dsa_switch *ds,
 	return ports;
 }
 
-static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
+static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 {
+	struct device_node *np = dev->of_node;
 	struct device_node *ports = dsa_get_ports(ds, np);
 	struct dsa_switch_tree *dst;
 	u32 tree, index;
@@ -673,12 +674,12 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
 	return err;
 }
 
-int dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
+int dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 {
 	int err;
 
 	mutex_lock(&dsa2_mutex);
-	err = _dsa_register_switch(ds, np);
+	err = _dsa_register_switch(ds, dev);
 	mutex_unlock(&dsa2_mutex);
 
 	return err;
-- 
2.9.3
