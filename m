From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] dsa: Use netdev_<level> instead of printk
Date: Sun, 09 Nov 2014 16:32:46 -0800
Message-ID: <1415579566.23530.47.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neaten and standardize the logging output.

Other miscellanea:

o Use pr_notice_once instead of a guard flag.
o Convert existing pr_<level> uses too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/dsa/dsa.c   | 28 ++++++++++++----------------
 net/dsa/slave.c | 10 +++++-----
 2 files changed, 17 insertions(+), 21 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index dd646a8..4648f12 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -192,12 +192,12 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	 */
 	drv = dsa_switch_probe(host_dev, pd->sw_addr, &name);
 	if (drv == NULL) {
-		printk(KERN_ERR "%s[%d]: could not detect attached switch\n",
-		       dst->master_netdev->name, index);
+		netdev_err(dst->master_netdev, "[%d]: could not detect attached switch\n",
+			   index);
 		return ERR_PTR(-EINVAL);
 	}
-	printk(KERN_INFO "%s[%d]: detected a %s switch\n",
-		dst->master_netdev->name, index, name);
+	netdev_info(dst->master_netdev, "[%d]: detected a %s switch\n",
+		    index, name);
 
 
 	/*
@@ -225,7 +225,8 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 
 		if (!strcmp(name, "cpu")) {
 			if (dst->cpu_switch != -1) {
-				printk(KERN_ERR "multiple cpu ports?!\n");
+				netdev_err(dst->master_netdev,
+					   "multiple cpu ports?!\n");
 				ret = -EINVAL;
 				goto out;
 			}
@@ -320,10 +321,8 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 
 		slave_dev = dsa_slave_create(ds, parent, i, pd->port_names[i]);
 		if (slave_dev == NULL) {
-			printk(KERN_ERR "%s[%d]: can't create dsa "
-			       "slave device for port %d(%s)\n",
-			       dst->master_netdev->name,
-			       index, i, pd->port_names[i]);
+			netdev_err(dst->master_netdev, "[%d]: can't create dsa slave device for port %d(%s)\n",
+				   index, i, pd->port_names[i]);
 			continue;
 		}
 
@@ -701,15 +700,13 @@ static inline void dsa_of_remove(struct platform_device *pdev)
 
 static int dsa_probe(struct platform_device *pdev)
 {
-	static int dsa_version_printed;
 	struct dsa_platform_data *pd = pdev->dev.platform_data;
 	struct net_device *dev;
 	struct dsa_switch_tree *dst;
 	int i, ret;
 
-	if (!dsa_version_printed++)
-		printk(KERN_NOTICE "Distributed Switch Architecture "
-			"driver version %s\n", dsa_driver_version);
+	pr_notice_once("Distributed Switch Architecture driver version %s\n",
+		       dsa_driver_version);
 
 	if (pdev->dev.of_node) {
 		ret = dsa_of_probe(pdev);
@@ -753,9 +750,8 @@ static int dsa_probe(struct platform_device *pdev)
 
 		ds = dsa_switch_setup(dst, i, &pdev->dev, pd->chip[i].host_dev);
 		if (IS_ERR(ds)) {
-			printk(KERN_ERR "%s[%d]: couldn't create dsa switch "
-				"instance (error %ld)\n", dev->name, i,
-				PTR_ERR(ds));
+			netdev_err(dev, "[%d]: couldn't create dsa switch instance (error %ld)\n",
+				   i, PTR_ERR(ds));
 			continue;
 		}
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 0ea466d..528380a 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -532,7 +532,7 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		 */
 		ret = of_phy_register_fixed_link(port_dn);
 		if (ret) {
-			pr_err("failed to register fixed PHY\n");
+			netdev_err(slave_dev, "failed to register fixed PHY\n");
 			return;
 		}
 		phy_is_fixed = true;
@@ -558,8 +558,8 @@ static void dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		phy_connect_direct(slave_dev, p->phy, dsa_slave_adjust_link,
 				   p->phy_interface);
 	} else {
-		pr_info("attached PHY at address %d [%s]\n",
-			p->phy->addr, p->phy->drv->name);
+		netdev_info(slave_dev, "attached PHY at address %d [%s]\n",
+			    p->phy->addr, p->phy->drv->name);
 	}
 }
 
@@ -657,8 +657,8 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 
 	ret = register_netdev(slave_dev);
 	if (ret) {
-		printk(KERN_ERR "%s: error %d registering interface %s\n",
-				master->name, ret, slave_dev->name);
+		netdev_err(master, "error %d registering interface %s\n",
+			   ret, slave_dev->name);
 		free_netdev(slave_dev);
 		return NULL;
 	}
