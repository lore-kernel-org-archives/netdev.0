From: Jan Kaisrlik <kaisrja1@fel.cvut.cz>
Subject: [RFC PATCH 1/3] net/dsa: Refactor dsa_probe()
Date: Tue, 21 Apr 2015 13:26:29 +0000
Message-ID: <1429622791-7195-2-git-send-email-kaisrja1@fel.cvut.cz>
References: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz>
Cc: sojkam1@fel.cvut.cz, tkonecny@retia.cz, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jan Kaisrlik <ja.kaisrlik@gmail.com>
To: kaisrja1@fel.cvut.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429622791-7195-1-git-send-email-kaisrja1@fel.cvut.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Kaisrlik <ja.kaisrlik@gmail.com>

This patch refactors dsa_probe in order to simplify code in the patch 2/3.

---
 net/dsa/dsa.c | 82 ++++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 47 insertions(+), 35 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 3731714..e2c0703 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -699,12 +699,56 @@ static inline void dsa_of_remove(struct platform_device *pdev)
 }
 #endif
 
-static int dsa_probe(struct platform_device *pdev)
+static int dsa_probe_common(struct dsa_switch_tree *dst, struct device *parent)
 {
+	struct dsa_platform_data *pd = dst->pd;
+	struct net_device *dev = dst->master_netdev;
+	int i;
+
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
+
+	return 0;
+
+}
+
+static int dsa_probe(struct platform_device *pdev){
 	struct dsa_platform_data *pd = pdev->dev.platform_data;
 	struct net_device *dev;
 	struct dsa_switch_tree *dst;
-	int i, ret;
+	int ret;
 
 	pr_notice_once("Distributed Switch Architecture driver version %s\n",
 		       dsa_driver_version);
@@ -743,40 +787,8 @@ static int dsa_probe(struct platform_device *pdev)
 
 	dst->pd = pd;
 	dst->master_netdev = dev;
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
 
-	if (dst->link_poll_needed) {
-		INIT_WORK(&dst->link_poll_work, dsa_link_poll_work);
-		init_timer(&dst->link_poll_timer);
-		dst->link_poll_timer.data = (unsigned long)dst;
-		dst->link_poll_timer.function = dsa_link_poll_timer;
-		dst->link_poll_timer.expires = round_jiffies(jiffies + HZ);
-		add_timer(&dst->link_poll_timer);
-	}
+	dsa_probe_common(dst, &pdev->dev);
 
 	return 0;
 
-- 
2.1.3
