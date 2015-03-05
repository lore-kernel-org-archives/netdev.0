From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/5] net: dsa: split dsa_switch_setup into two functions
Date: Thu,  5 Mar 2015 12:35:06 -0800
Message-ID: <1425587708-26786-4-git-send-email-f.fainelli@gmail.com>
References: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:44772 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754188AbbCEUgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 15:36:16 -0500
Received: by pdjz10 with SMTP id z10so18140459pdj.11
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 12:36:16 -0800 (PST)
In-Reply-To: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split the part of dsa_switch_setup() which is responsible for allocating
and initializing a 'struct dsa_switch' and the part which is doing a
given switch device setup and slave network device creation.

This is a preliminary change to allow a separate caller of
dsa_switch_setup_one() which may have externally initialized the
dsa_switch structure, outside of dsa_switch_setup().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 88 ++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 51 insertions(+), 37 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 79879d01488a..6f02ccc57593 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -175,43 +175,14 @@ __ATTRIBUTE_GROUPS(dsa_hwmon);
 #endif /* CONFIG_NET_DSA_HWMON */
 
 /* basic switch operations **************************************************/
-static struct dsa_switch *
-dsa_switch_setup(struct dsa_switch_tree *dst, int index,
-		 struct device *parent, struct device *host_dev)
+static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 {
-	struct dsa_chip_data *pd = dst->pd->chip + index;
-	struct dsa_switch_driver *drv;
-	struct dsa_switch *ds;
-	int ret;
-	char *name;
-	int i;
+	struct dsa_switch_driver *drv = ds->drv;
+	struct dsa_switch_tree *dst = ds->dst;
+	struct dsa_chip_data *pd = ds->pd;
 	bool valid_name_found = false;
-
-	/*
-	 * Probe for switch model.
-	 */
-	drv = dsa_switch_probe(host_dev, pd->sw_addr, &name);
-	if (drv == NULL) {
-		netdev_err(dst->master_netdev, "[%d]: could not detect attached switch\n",
-			   index);
-		return ERR_PTR(-EINVAL);
-	}
-	netdev_info(dst->master_netdev, "[%d]: detected a %s switch\n",
-		    index, name);
-
-
-	/*
-	 * Allocate and initialise switch state.
-	 */
-	ds = kzalloc(sizeof(*ds) + drv->priv_size, GFP_KERNEL);
-	if (ds == NULL)
-		return ERR_PTR(-ENOMEM);
-
-	ds->dst = dst;
-	ds->index = index;
-	ds->pd = dst->pd->chip + index;
-	ds->drv = drv;
-	ds->master_dev = host_dev;
+	int index = ds->index;
+	int i, ret;
 
 	/*
 	 * Validate supplied switch configuration.
@@ -350,13 +321,56 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	}
 #endif /* CONFIG_NET_DSA_HWMON */
 
-	return ds;
+	return ret;
 
 out_free:
 	mdiobus_free(ds->slave_mii_bus);
 out:
 	kfree(ds);
-	return ERR_PTR(ret);
+	return ret;
+}
+
+static struct dsa_switch *
+dsa_switch_setup(struct dsa_switch_tree *dst, int index,
+		 struct device *parent, struct device *host_dev)
+{
+	struct dsa_chip_data *pd = dst->pd->chip + index;
+	struct dsa_switch_driver *drv;
+	struct dsa_switch *ds;
+	int ret;
+	char *name;
+
+	/*
+	 * Probe for switch model.
+	 */
+	drv = dsa_switch_probe(host_dev, pd->sw_addr, &name);
+	if (drv == NULL) {
+		netdev_err(dst->master_netdev, "[%d]: could not detect attached switch\n",
+			   index);
+		return ERR_PTR(-EINVAL);
+	}
+	netdev_info(dst->master_netdev, "[%d]: detected a %s switch\n",
+		    index, name);
+
+
+	/*
+	 * Allocate and initialise switch state.
+	 */
+	ds = kzalloc(sizeof(*ds) + drv->priv_size, GFP_KERNEL);
+	if (ds == NULL)
+		return NULL;
+
+	ds->dst = dst;
+	ds->index = index;
+	ds->pd = pd;
+	ds->drv = drv;
+	ds->master_dev = host_dev;
+
+	ret = dsa_switch_setup_one(ds, parent);
+	if (ret)
+		return NULL;
+
+	return ds;
 }
 
 static void dsa_switch_destroy(struct dsa_switch *ds)
-- 
2.1.0
