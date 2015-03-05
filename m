From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/5] net: dsa: extract dsa switch tree setup and removal
Date: Thu,  5 Mar 2015 12:35:08 -0800
Message-ID: <1425587708-26786-6-git-send-email-f.fainelli@gmail.com>
References: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:40925 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754142AbbCEUgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 15:36:20 -0500
Received: by pdbfp1 with SMTP id fp1so31943207pdb.7
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 12:36:19 -0800 (PST)
In-Reply-To: <1425587708-26786-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extract the core logic that setups a 'struct dsa_switch_tree' and
removes it, update dsa_probe() and dsa_remove() to use the two helper
functions. This will be useful to allow for other callers to setup
this structure differently.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa.c | 91 ++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 52 insertions(+), 39 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 4cc995664fdf..b40f11bb419c 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -710,12 +710,55 @@ static inline void dsa_of_remove(struct device *dev)
 }
 #endif
 
+static void dsa_setup_dst(struct dsa_switch_tree *dst, struct net_device *dev,
+			  struct device *parent, struct dsa_platform_data *pd)
+{
+	int i;
+
+	dst->pd = pd;
+	dst->master_netdev = dev;
+	dst->cpu_switch = -1;
+	dst->cpu_port = -1;
+
+	for (i = 0; i < pd->nr_chips; i++) {
+		struct dsa_switch *ds;
+
+		ds = dsa_switch_setup(dst, i, parent, pd->chip[i].host_dev);
+		if (IS_ERR(ds)) {
+			netdev_err(dev, "[%d]: couldn't create dsa switch instance (error %ld)\n",
+				   i, PTR_ERR(ds));
+			continue;
+		}
+
+		dst->ds[i] = ds;
+		if (ds->drv->poll_link != NULL)
+			dst->link_poll_needed = 1;
+	}
+
+	/*
+	 * If we use a tagging format that doesn't have an ethertype
+	 * field, make sure that all packets from this point on get
+	 * sent to the tag format's receive function.
+	 */
+	wmb();
+	dev->dsa_ptr = (void *)dst;
+
+	if (dst->link_poll_needed) {
+		INIT_WORK(&dst->link_poll_work, dsa_link_poll_work);
+		init_timer(&dst->link_poll_timer);
+		dst->link_poll_timer.data = (unsigned long)dst;
+		dst->link_poll_timer.function = dsa_link_poll_timer;
+		dst->link_poll_timer.expires = round_jiffies(jiffies + HZ);
+		add_timer(&dst->link_poll_timer);
+	}
+}
+
 static int dsa_probe(struct platform_device *pdev)
 {
 	struct dsa_platform_data *pd = pdev->dev.platform_data;
 	struct net_device *dev;
 	struct dsa_switch_tree *dst;
-	int i, ret;
+	int ret;
 
 	pr_notice_once("Distributed Switch Architecture driver version %s\n",
 		       dsa_driver_version);
@@ -752,42 +795,7 @@ static int dsa_probe(struct platform_device *pdev)
 
 	platform_set_drvdata(pdev, dst);
 
-	dst->pd = pd;
-	dst->master_netdev = dev;
-	dst->cpu_switch = -1;
-	dst->cpu_port = -1;
-
-	for (i = 0; i < pd->nr_chips; i++) {
-		struct dsa_switch *ds;
-
-		ds = dsa_switch_setup(dst, i, &pdev->dev, pd->chip[i].host_dev);
-		if (IS_ERR(ds)) {
-			netdev_err(dev, "[%d]: couldn't create dsa switch instance (error %ld)\n",
-				   i, PTR_ERR(ds));
-			continue;
-		}
-
-		dst->ds[i] = ds;
-		if (ds->drv->poll_link != NULL)
-			dst->link_poll_needed = 1;
-	}
-
-	/*
-	 * If we use a tagging format that doesn't have an ethertype
-	 * field, make sure that all packets from this point on get
-	 * sent to the tag format's receive function.
-	 */
-	wmb();
-	dev->dsa_ptr = (void *)dst;
-
-	if (dst->link_poll_needed) {
-		INIT_WORK(&dst->link_poll_work, dsa_link_poll_work);
-		init_timer(&dst->link_poll_timer);
-		dst->link_poll_timer.data = (unsigned long)dst;
-		dst->link_poll_timer.function = dsa_link_poll_timer;
-		dst->link_poll_timer.expires = round_jiffies(jiffies + HZ);
-		add_timer(&dst->link_poll_timer);
-	}
+	dsa_setup_dst(dst, dev, &pdev->dev, pd);
 
 	return 0;
 
@@ -797,9 +805,8 @@ out:
 	return ret;
 }
 
-static int dsa_remove(struct platform_device *pdev)
+static void dsa_remove_dst(struct dsa_switch_tree *dst)
 {
-	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);
 	int i;
 
 	if (dst->link_poll_needed)
@@ -813,7 +820,13 @@ static int dsa_remove(struct platform_device *pdev)
 		if (ds != NULL)
 			dsa_switch_destroy(ds);
 	}
+}
+
+static int dsa_remove(struct platform_device *pdev)
+{
+	struct dsa_switch_tree *dst = platform_get_drvdata(pdev);
 
+	dsa_remove_dst(dst);
 	dsa_of_remove(&pdev->dev);
 
 	return 0;
-- 
2.1.0
