From: Daniel Walker <dwalker@mvista.com>
Subject: [PATCH 2/3] ps3: gelic: assoc_stat_lock semaphore to mutex
Date: Thu, 22 May 2008 00:00:02 -0700
Message-ID: <20080522195406.490863853@mvista.com>
References: <20080522195404.061391772@mvista.com>
Cc: netdev@vger.kernel.org, matthew@wil.cx, rusty@rustcorp.com.au,
	mingo@elte.hu, linux-kernel@vger.kernel.org, arjan@infradead.org,
	mokuno@sm.sony.co.jp, geoffrey.levand@am.sony.com
To: jgarzik@pobox.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757882AbYEVUCp@vger.kernel.org>
Content-Disposition: inline; filename=ps3-gelic-wireless-assoc_stat_lock-semaphore-to-mutex.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Daniel Walker <dwalker@mvista.com>

---
 drivers/net/ps3_gelic_wireless.c |   22 +++++++++++-----------
 drivers/net/ps3_gelic_wireless.h |    2 +-
 2 files changed, 12 insertions(+), 12 deletions(-)

Index: linux-2.6.25/drivers/net/ps3_gelic_wireless.c
===================================================================
--- linux-2.6.25.orig/drivers/net/ps3_gelic_wireless.c
+++ linux-2.6.25/drivers/net/ps3_gelic_wireless.c
@@ -240,12 +240,12 @@ static u32 gelic_wl_get_link(struct net_
 	u32 ret;
 
 	pr_debug("%s: <-\n", __func__);
-	down(&wl->assoc_stat_lock);
+	mutex_lock(&wl->assoc_stat_lock);
 	if (wl->assoc_stat == GELIC_WL_ASSOC_STAT_ASSOCIATED)
 		ret = 1;
 	else
 		ret = 0;
-	up(&wl->assoc_stat_lock);
+	mutex_unlock(&wl->assoc_stat_lock);
 	pr_debug("%s: ->\n", __func__);
 	return ret;
 }
@@ -979,7 +979,7 @@ static int gelic_wl_get_essid(struct net
 	unsigned long irqflag;
 
 	pr_debug("%s: <- \n", __func__);
-	down(&wl->assoc_stat_lock);
+	mutex_lock(&wl->assoc_stat_lock);
 	spin_lock_irqsave(&wl->lock, irqflag);
 	if (test_bit(GELIC_WL_STAT_ESSID_SET, &wl->stat) ||
 	    wl->assoc_stat == GELIC_WL_ASSOC_STAT_ASSOCIATED) {
@@ -989,7 +989,7 @@ static int gelic_wl_get_essid(struct net
 	} else
 		data->essid.flags = 0;
 
-	up(&wl->assoc_stat_lock);
+	mutex_unlock(&wl->assoc_stat_lock);
 	spin_unlock_irqrestore(&wl->lock, irqflag);
 	pr_debug("%s: -> len=%d \n", __func__, data->essid.length);
 
@@ -1170,7 +1170,7 @@ static int gelic_wl_get_ap(struct net_de
 	unsigned long irqflag;
 
 	pr_debug("%s: <-\n", __func__);
-	down(&wl->assoc_stat_lock);
+	mutex_lock(&wl->assoc_stat_lock);
 	spin_lock_irqsave(&wl->lock, irqflag);
 	if (wl->assoc_stat == GELIC_WL_ASSOC_STAT_ASSOCIATED) {
 		data->ap_addr.sa_family = ARPHRD_ETHER;
@@ -1180,7 +1180,7 @@ static int gelic_wl_get_ap(struct net_de
 		memset(data->ap_addr.sa_data, 0, ETH_ALEN);
 
 	spin_unlock_irqrestore(&wl->lock, irqflag);
-	up(&wl->assoc_stat_lock);
+	mutex_unlock(&wl->assoc_stat_lock);
 	pr_debug("%s: ->\n", __func__);
 	return 0;
 }
@@ -2151,7 +2151,7 @@ static void gelic_wl_disconnect_event(st
 	 * As it waits with timeout, just leave assoc_done
 	 * uncompleted, then it terminates with timeout
 	 */
-	if (down_trylock(&wl->assoc_stat_lock)) {
+	if (!mutex_trylock(&wl->assoc_stat_lock)) {
 		pr_debug("%s: already locked\n", __func__);
 		lock = 0;
 	} else {
@@ -2170,7 +2170,7 @@ static void gelic_wl_disconnect_event(st
 	netif_carrier_off(port_to_netdev(wl_port(wl)));
 
 	if (lock)
-		up(&wl->assoc_stat_lock);
+		mutex_unlock(&wl->assoc_stat_lock);
 }
 /*
  * event worker
@@ -2258,7 +2258,7 @@ static void gelic_wl_assoc_worker(struct
 
 	wl = container_of(work, struct gelic_wl_info, assoc_work.work);
 
-	down(&wl->assoc_stat_lock);
+	mutex_lock(&wl->assoc_stat_lock);
 
 	if (wl->assoc_stat != GELIC_WL_ASSOC_STAT_DISCONN)
 		goto out;
@@ -2304,7 +2304,7 @@ static void gelic_wl_assoc_worker(struct
 scan_lock_out:
 	mutex_unlock(&wl->scan_lock);
 out:
-	up(&wl->assoc_stat_lock);
+	mutex_unlock(&wl->assoc_stat_lock);
 }
 /*
  * Interrupt handler
@@ -2432,7 +2432,7 @@ static struct net_device *gelic_wl_alloc
 	INIT_DELAYED_WORK(&wl->event_work, gelic_wl_event_worker);
 	INIT_DELAYED_WORK(&wl->assoc_work, gelic_wl_assoc_worker);
 	mutex_init(&wl->scan_lock);
-	init_MUTEX(&wl->assoc_stat_lock);
+	mutex_init(&wl->assoc_stat_lock);
 
 	init_completion(&wl->scan_done);
 	/* for the case that no scan request is issued and stop() is called */
Index: linux-2.6.25/drivers/net/ps3_gelic_wireless.h
===================================================================
--- linux-2.6.25.orig/drivers/net/ps3_gelic_wireless.h
+++ linux-2.6.25/drivers/net/ps3_gelic_wireless.h
@@ -266,7 +266,7 @@ struct gelic_wl_info {
 	enum gelic_wl_wpa_level wpa_level; /* wpa/wpa2 */
 
 	/* association handling */
-	struct semaphore assoc_stat_lock;
+	struct mutex assoc_stat_lock;
 	struct delayed_work assoc_work;
 	enum gelic_wl_assoc_state assoc_stat;
 	struct completion assoc_done;

-- 
