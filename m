From: Felipe Balbi <balbi@ti.com>
Subject: [RFC/PATCH 13/13] net: wl12xx: main: drop unneded plat_dev
Date: Sat, 14 May 2011 00:26:30 +0300
Message-ID: <1305321990-22041-14-git-send-email-balbi@ti.com>
References: <1305321990-22041-1-git-send-email-balbi@ti.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Felipe Balbi <balbi@ti.com>
To: Luciano Coelho <coelho@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:52948 "EHLO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759756Ab1EMV1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 17:27:46 -0400
In-Reply-To: <1305321990-22041-1-git-send-email-balbi@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

now that useless plat_dev is unnecessary,
we can remove it.

Signed-off-by: Felipe Balbi <balbi@ti.com>
---
 drivers/net/wireless/wl12xx/main.c   |   48 +++-------------------------------
 drivers/net/wireless/wl12xx/wl12xx.h |    1 -
 2 files changed, 4 insertions(+), 45 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/main.c b/drivers/net/wireless/wl12xx/main.c
index d3c056d..55cedcd 100644
--- a/drivers/net/wireless/wl12xx/main.c
+++ b/drivers/net/wireless/wl12xx/main.c
@@ -315,21 +315,6 @@ static void __wl1271_op_remove_interface(struct wl1271 *wl);
 static void wl1271_free_ap_keys(struct wl1271 *wl);
 
 
-static void wl1271_device_release(struct device *dev)
-{
-
-}
-
-static struct platform_device wl1271_device = {
-	.name           = "wl1271",
-	.id             = -1,
-
-	/* device model insists to have a release function */
-	.dev            = {
-		.release = wl1271_device_release,
-	},
-};
-
 static LIST_HEAD(wl_list);
 
 static int wl1271_dev_notify(struct notifier_block *me, unsigned long what,
@@ -3389,7 +3374,6 @@ static int wl1271_init_ieee80211(struct wl1271 *wl)
 static struct ieee80211_hw *wl1271_alloc_hw(void)
 {
 	struct ieee80211_hw *hw;
-	struct platform_device *plat_dev = NULL;
 	struct wl1271 *wl;
 	int i, j, ret;
 	unsigned int order;
@@ -3401,20 +3385,12 @@ static struct ieee80211_hw *wl1271_alloc_hw(void)
 		goto err_hw_alloc;
 	}
 
-	plat_dev = kmemdup(&wl1271_device, sizeof(wl1271_device), GFP_KERNEL);
-	if (!plat_dev) {
-		wl1271_error("could not allocate platform_device");
-		ret = -ENOMEM;
-		goto err_plat_alloc;
-	}
-
 	wl = hw->priv;
 	memset(wl, 0, sizeof(*wl));
 
 	INIT_LIST_HEAD(&wl->list);
 
 	wl->hw = hw;
-	wl->plat_dev = plat_dev;
 
 	for (i = 0; i < NUM_TX_QUEUES; i++)
 		skb_queue_head_init(&wl->tx_queue[i]);
@@ -3475,23 +3451,15 @@ static struct ieee80211_hw *wl1271_alloc_hw(void)
 		goto err_hw;
 	}
 
-	/* Register platform device */
-	ret = platform_device_register(wl->plat_dev);
-	if (ret) {
-		wl1271_error("couldn't register platform device");
-		goto err_aggr;
-	}
-	dev_set_drvdata(&wl->plat_dev->dev, wl);
-
 	/* Create sysfs file to control bt coex state */
-	ret = device_create_file(&wl->plat_dev->dev, &dev_attr_bt_coex_state);
+	ret = device_create_file(wl->dev, &dev_attr_bt_coex_state);
 	if (ret < 0) {
 		wl1271_error("failed to create sysfs file bt_coex_state");
-		goto err_platform;
+		goto err_aggr;
 	}
 
 	/* Create sysfs file to get HW PG version */
-	ret = device_create_file(&wl->plat_dev->dev, &dev_attr_hw_pg_ver);
+	ret = device_create_file(wl->dev, &dev_attr_hw_pg_ver);
 	if (ret < 0) {
 		wl1271_error("failed to create sysfs file hw_pg_ver");
 		goto err_bt_coex_state;
@@ -3500,19 +3468,13 @@ static struct ieee80211_hw *wl1271_alloc_hw(void)
 	return hw;
 
 err_bt_coex_state:
-	device_remove_file(&wl->plat_dev->dev, &dev_attr_bt_coex_state);
-
-err_platform:
-	platform_device_unregister(wl->plat_dev);
+	device_remove_file(wl->dev, &dev_attr_bt_coex_state);
 
 err_aggr:
 	free_pages((unsigned long)wl->aggr_buf, order);
 
 err_hw:
 	wl1271_debugfs_exit(wl);
-	kfree(plat_dev);
-
-err_plat_alloc:
 	ieee80211_free_hw(hw);
 
 err_hw_alloc:
@@ -3522,10 +3484,8 @@ err_hw_alloc:
 
 static int wl1271_free_hw(struct wl1271 *wl)
 {
-	platform_device_unregister(wl->plat_dev);
 	free_pages((unsigned long)wl->aggr_buf,
 			get_order(WL1271_AGGR_BUFFER_SIZE));
-	kfree(wl->plat_dev);
 
 	wl1271_debugfs_exit(wl);
 
diff --git a/drivers/net/wireless/wl12xx/wl12xx.h b/drivers/net/wireless/wl12xx/wl12xx.h
index eb3d3fc..279bd82 100644
--- a/drivers/net/wireless/wl12xx/wl12xx.h
+++ b/drivers/net/wireless/wl12xx/wl12xx.h
@@ -339,7 +339,6 @@ struct wl1271_link {
 };
 
 struct wl1271 {
-	struct platform_device *plat_dev;
 	struct ieee80211_hw *hw;
 	bool mac80211_registered;
 
-- 
1.7.4.1.343.ga91df

