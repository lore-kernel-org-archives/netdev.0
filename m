From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [PATCH v2 4/5] net: dsa: switch to devm_ calls and remove kfree calls
Date: Sat, 3 Oct 2015 16:26:11 +0200
Message-ID: <560FE583.7010107@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com, Andrew Lunn <andrew@lunn.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, nbd@openwrt.org,
	sergei.shtylyov@cogentembedded.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now the kfree calls exists in the the remove functions, remove them in all
places except the of_probe functions and replace allocation calls
with their devm_ counterparts.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 17 +++++------------
 1 file changed, 5 insertions(+), 12 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index f937f7a..dd171ff 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -306,7 +306,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	if (ret < 0)
 		goto out;

-	ds->slave_mii_bus = mdiobus_alloc();
+	ds->slave_mii_bus = devm_mdiobus_alloc(parent);
 	if (ds->slave_mii_bus == NULL) {
 		ret = -ENOMEM;
 		goto out;
@@ -315,7 +315,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)

 	ret = mdiobus_register(ds->slave_mii_bus);
 	if (ret < 0)
-		goto out_free;
+		goto out;


 	/*
@@ -368,10 +368,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)

 	return ret;

-out_free:
-	mdiobus_free(ds->slave_mii_bus);
 out:
-	kfree(ds);
 	return ret;
 }

@@ -401,7 +398,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	/*
 	 * Allocate and initialise switch state.
 	 */
-	ds = kzalloc(sizeof(*ds) + drv->priv_size, GFP_KERNEL);
+	ds = devm_kzalloc(parent, sizeof(*ds) + drv->priv_size, GFP_KERNEL);
 	if (ds == NULL)
 		return ERR_PTR(-ENOMEM);

@@ -461,7 +458,6 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 	}

 	mdiobus_unregister(ds->slave_mii_bus);
-	mdiobus_free(ds->slave_mii_bus);
 }

 #ifdef CONFIG_PM_SLEEP
@@ -921,7 +917,7 @@ static int dsa_probe(struct platform_device *pdev)
 		goto out;
 	}

-	dst = kzalloc(sizeof(*dst), GFP_KERNEL);
+	dst = devm_kzalloc(&pdev->dev, sizeof(*dst), GFP_KERNEL);
 	if (dst == NULL) {
 		dev_put(dev);
 		ret = -ENOMEM;
@@ -952,10 +948,8 @@ static void dsa_remove_dst(struct dsa_switch_tree *dst)
 	for (i = 0; i < dst->pd->nr_chips; i++) {
 		struct dsa_switch *ds = dst->ds[i];

-		if (ds != NULL) {
+		if (ds != NULL)
 			dsa_switch_destroy(ds);
-			kfree(ds);
-		}
 	}
 }

@@ -964,7 +958,6 @@ static int dsa_remove(struct platform_device *pdev)
 	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);

 	dsa_remove_dst(dst);
-	kfree(dst);
 	dsa_of_remove(&pdev->dev);

 	return 0;
-- 
1.9.1
