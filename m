From: Daniel Walker <dwalker@mvista.com>
Subject: [PATCH 1/3] ps3: gelic: scan_lock semaphore to mutex
Date: Thu, 22 May 2008 00:00:01 -0700
Message-ID: <20080522195404.061391772@mvista.com>
Cc: netdev@vger.kernel.org, matthew@wil.cx, rusty@rustcorp.com.au,
	mingo@elte.hu, linux-kernel@vger.kernel.org, arjan@infradead.org,
	mokuno@sm.sony.co.jp, geoffrey.levand@am.sony.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:8383 "EHLO
	dwalker1.mvista.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758372AbYEVUJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2008 16:09:20 -0400
Content-Disposition: inline; filename=ps3-gelic-wireless-scan_lock-semaphore-to-mutex.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Daniel Walker <dwalker@mvista.com>

---
 drivers/net/ps3_gelic_wireless.c |   18 +++++++++---------
 drivers/net/ps3_gelic_wireless.h |    2 +-
 2 files changed, 10 insertions(+), 10 deletions(-)

Index: linux-2.6.25/drivers/net/ps3_gelic_wireless.c
===================================================================
--- linux-2.6.25.orig/drivers/net/ps3_gelic_wireless.c
+++ linux-2.6.25/drivers/net/ps3_gelic_wireless.c
@@ -695,7 +695,7 @@ static int gelic_wl_get_scan(struct net_
 	unsigned long this_time = jiffies;
 
 	pr_debug("%s: <-\n", __func__);
-	if (down_interruptible(&wl->scan_lock))
+	if (mutex_lock_interruptible(&wl->scan_lock))
 		return -EAGAIN;
 
 	switch (wl->scan_stat) {
@@ -733,7 +733,7 @@ static int gelic_wl_get_scan(struct net_
 	wrqu->data.length = ev - extra;
 	wrqu->data.flags = 0;
 out:
-	up(&wl->scan_lock);
+	mutex_unlock(&wl->scan_lock);
 	pr_debug("%s: -> %d %d\n", __func__, ret, wrqu->data.length);
 	return ret;
 }
@@ -1554,7 +1554,7 @@ static int gelic_wl_start_scan(struct ge
 	int ret = 0;
 
 	pr_debug("%s: <- always=%d\n", __func__, always_scan);
-	if (down_interruptible(&wl->scan_lock))
+	if (mutex_lock_interruptible(&wl->scan_lock))
 		return -ERESTARTSYS;
 
 	/*
@@ -1588,7 +1588,7 @@ static int gelic_wl_start_scan(struct ge
 	}
 	kfree(cmd);
 out:
-	up(&wl->scan_lock);
+	mutex_unlock(&wl->scan_lock);
 	pr_debug("%s: ->\n", __func__);
 	return ret;
 }
@@ -1610,7 +1610,7 @@ static void gelic_wl_scan_complete_event
 	DECLARE_MAC_BUF(mac);
 
 	pr_debug("%s:start\n", __func__);
-	down(&wl->scan_lock);
+	mutex_lock(&wl->scan_lock);
 
 	if (wl->scan_stat != GELIC_WL_SCAN_STAT_SCANNING) {
 		/*
@@ -1727,7 +1727,7 @@ static void gelic_wl_scan_complete_event
 			    NULL);
 out:
 	complete(&wl->scan_done);
-	up(&wl->scan_lock);
+	mutex_unlock(&wl->scan_lock);
 	pr_debug("%s:end\n", __func__);
 }
 
@@ -2282,7 +2282,7 @@ static void gelic_wl_assoc_worker(struct
 	wait_for_completion(&wl->scan_done);
 
 	pr_debug("%s: scan done\n", __func__);
-	down(&wl->scan_lock);
+	mutex_lock(&wl->scan_lock);
 	if (wl->scan_stat != GELIC_WL_SCAN_STAT_GOT_LIST) {
 		gelic_wl_send_iwap_event(wl, NULL);
 		pr_info("%s: no scan list. association failed\n", __func__);
@@ -2302,7 +2302,7 @@ static void gelic_wl_assoc_worker(struct
 	if (ret)
 		pr_info("%s: association failed %d\n", __func__, ret);
 scan_lock_out:
-	up(&wl->scan_lock);
+	mutex_unlock(&wl->scan_lock);
 out:
 	up(&wl->assoc_stat_lock);
 }
@@ -2431,7 +2431,7 @@ static struct net_device *gelic_wl_alloc
 
 	INIT_DELAYED_WORK(&wl->event_work, gelic_wl_event_worker);
 	INIT_DELAYED_WORK(&wl->assoc_work, gelic_wl_assoc_worker);
-	init_MUTEX(&wl->scan_lock);
+	mutex_init(&wl->scan_lock);
 	init_MUTEX(&wl->assoc_stat_lock);
 
 	init_completion(&wl->scan_done);
Index: linux-2.6.25/drivers/net/ps3_gelic_wireless.h
===================================================================
--- linux-2.6.25.orig/drivers/net/ps3_gelic_wireless.h
+++ linux-2.6.25/drivers/net/ps3_gelic_wireless.h
@@ -241,7 +241,7 @@ enum gelic_wl_assoc_state {
 #define GELIC_WEP_KEYS 4
 struct gelic_wl_info {
 	/* bss list */
-	struct semaphore scan_lock;
+	struct mutex scan_lock;
 	struct list_head network_list;
 	struct list_head network_free_list;
 	struct gelic_wl_scan_info *networks;

-- 
