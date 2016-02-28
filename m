From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 25/32] net: dsa: Setup the switches after all have been probed
Date: Sun, 28 Feb 2016 17:41:33 +0100
Message-ID: <1456677700-23027-26-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44900 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759183AbcB1QmB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:42:01 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some switches register themselves with DSA, which others are probed by
DSA itself. Move the setup call to after all switches have been
successfully probed. Similarly, finish each before releasing them.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 9acfbe7c34f7..b9b10e050927 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -426,7 +426,6 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	struct dsa_chip_data *pd = dst->pd->chip + index;
 	struct dsa_switch_driver *drv;
 	struct dsa_switch *ds;
-	int ret;
 	char *name;
 
 	/*
@@ -456,17 +455,11 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	ds->tag_protocol = drv->tag_protocol;
 	ds->master_dev = host_dev;
 
-	ret = dsa_switch_setup_one(ds, parent);
-	if (ret)
-		return ERR_PTR(ret);
-
 	return ds;
 }
 
 static void dsa_switch_finish(struct dsa_switch *ds, struct device *parent)
 {
-	dsa_switch_finish_one(ds);
-
 	devm_kfree(parent, ds);
 }
 
@@ -836,22 +829,28 @@ static inline void dsa_of_remove(struct device *dev,
 static int dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
 			 struct device *parent)
 {
-	int i;
+	int i, ret;
 	unsigned configured = 0;
+	struct dsa_switch *ds;
 	struct dsa_platform_data *pd = dst->pd;
 
 	dst->cpu_switch = -1;
 	dst->cpu_port = -1;
 
 	for (i = 0; i < pd->nr_chips; i++) {
-		struct dsa_switch *ds;
-
 		ds = dsa_switch_setup(dst, i, parent, pd->chip[i].host_dev);
 		if (IS_ERR(ds)) {
 			netdev_err(dev, "[%d]: couldn't create dsa switch instance (error %ld)\n",
 				   i, PTR_ERR(ds));
 			continue;
 		}
+	}
+
+	for (i = 0; i < pd->nr_chips; i++) {
+		ds = dst->ds[i];
+		ret = dsa_switch_setup_one(ds, parent);
+		if (ret)
+			return ret;
 
 		dst->ds[i] = ds;
 
@@ -879,6 +878,7 @@ static void dsa_finish_dst(struct dsa_switch_tree *dst, struct device *parent,
 			   struct dsa_platform_data *pd)
 {
 	struct net_device *dev = dst->master_netdev;
+	struct dsa_switch *ds;
 	int i;
 
 	dev->dsa_ptr = NULL;
@@ -888,7 +888,12 @@ static void dsa_finish_dst(struct dsa_switch_tree *dst, struct device *parent,
 	wmb();
 
 	for (i = 0; i < pd->nr_chips; i++) {
-		struct dsa_switch *ds = dst->ds[i];
+		ds = dst->ds[i];
+		dsa_switch_finish_one(ds);
+	}
+
+	for (i = 0; i < pd->nr_chips; i++) {
+		ds = dst->ds[i];
 
 		dsa_switch_finish(ds, parent);
 		dst->ds[i] = NULL;
-- 
2.7.0
