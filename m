From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/wireless: cw1200: Convert timers to use timer_setup()
Date: Tue, 24 Oct 2017 02:29:00 -0700
Message-ID: <20171024092900.GA47129@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Solomon Peachy <pizza@shaftnet.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:53757 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751769AbdJXJ3D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:29:03 -0400
Received: by mail-pf0-f195.google.com with SMTP id t188so19256884pfd.10
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:29:02 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Solomon Peachy <pizza@shaftnet.org>
Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wireless/st/cw1200/main.c  | 3 +--
 drivers/net/wireless/st/cw1200/queue.c | 6 +++---
 drivers/net/wireless/st/cw1200/sta.c   | 5 ++---
 drivers/net/wireless/st/cw1200/sta.h   | 2 +-
 4 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/st/cw1200/main.c b/drivers/net/wireless/st/cw1200/main.c
index dc478cedbde0..a186d1df1f29 100644
--- a/drivers/net/wireless/st/cw1200/main.c
+++ b/drivers/net/wireless/st/cw1200/main.c
@@ -373,8 +373,7 @@ static struct ieee80211_hw *cw1200_init_common(const u8 *macaddr,
 	INIT_WORK(&priv->update_filtering_work, cw1200_update_filtering_work);
 	INIT_WORK(&priv->set_beacon_wakeup_period_work,
 		  cw1200_set_beacon_wakeup_period_work);
-	setup_timer(&priv->mcast_timeout, cw1200_mcast_timeout,
-		    (unsigned long)priv);
+	timer_setup(&priv->mcast_timeout, cw1200_mcast_timeout, 0);
 
 	if (cw1200_queue_stats_init(&priv->tx_queue_stats,
 				    CW1200_LINK_ID_MAX,
diff --git a/drivers/net/wireless/st/cw1200/queue.c b/drivers/net/wireless/st/cw1200/queue.c
index 0ba5ef9b3e7b..5153d2cfd991 100644
--- a/drivers/net/wireless/st/cw1200/queue.c
+++ b/drivers/net/wireless/st/cw1200/queue.c
@@ -130,11 +130,11 @@ static void __cw1200_queue_gc(struct cw1200_queue *queue,
 	}
 }
 
-static void cw1200_queue_gc(unsigned long arg)
+static void cw1200_queue_gc(struct timer_list *t)
 {
 	LIST_HEAD(list);
 	struct cw1200_queue *queue =
-		(struct cw1200_queue *)arg;
+		from_timer(queue, t, gc);
 
 	spin_lock_bh(&queue->lock);
 	__cw1200_queue_gc(queue, &list, true);
@@ -179,7 +179,7 @@ int cw1200_queue_init(struct cw1200_queue *queue,
 	INIT_LIST_HEAD(&queue->pending);
 	INIT_LIST_HEAD(&queue->free_pool);
 	spin_lock_init(&queue->lock);
-	setup_timer(&queue->gc, cw1200_queue_gc, (unsigned long)queue);
+	timer_setup(&queue->gc, cw1200_queue_gc, 0);
 
 	queue->pool = kzalloc(sizeof(struct cw1200_queue_item) * capacity,
 			GFP_KERNEL);
diff --git a/drivers/net/wireless/st/cw1200/sta.c b/drivers/net/wireless/st/cw1200/sta.c
index a52224836a2b..03687a80d6e9 100644
--- a/drivers/net/wireless/st/cw1200/sta.c
+++ b/drivers/net/wireless/st/cw1200/sta.c
@@ -2112,10 +2112,9 @@ void cw1200_multicast_stop_work(struct work_struct *work)
 	}
 }
 
-void cw1200_mcast_timeout(unsigned long arg)
+void cw1200_mcast_timeout(struct timer_list *t)
 {
-	struct cw1200_common *priv =
-		(struct cw1200_common *)arg;
+	struct cw1200_common *priv = from_timer(priv, t, mcast_timeout);
 
 	wiphy_warn(priv->hw->wiphy,
 		   "Multicast delivery timeout.\n");
diff --git a/drivers/net/wireless/st/cw1200/sta.h b/drivers/net/wireless/st/cw1200/sta.h
index a0bacaa39b31..719de34dcbfe 100644
--- a/drivers/net/wireless/st/cw1200/sta.h
+++ b/drivers/net/wireless/st/cw1200/sta.h
@@ -117,6 +117,6 @@ void cw1200_set_tim_work(struct work_struct *work);
 void cw1200_set_cts_work(struct work_struct *work);
 void cw1200_multicast_start_work(struct work_struct *work);
 void cw1200_multicast_stop_work(struct work_struct *work);
-void cw1200_mcast_timeout(unsigned long arg);
+void cw1200_mcast_timeout(struct timer_list *t);
 
 #endif
-- 
2.7.4


-- 
Kees Cook
Pixel Security
