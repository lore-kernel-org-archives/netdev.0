From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 15/16] drivers, net, intersil: convert hostap_cmd_queue.usecnt from atomic_t to refcount_t
Date: Tue, 28 Mar 2017 11:56:42 +0300
Message-ID: <1490691403-4016-16-git-send-email-elena.reshetova@intel.com>
References: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-rdma@vger.kernel.org, linux-hams@vger.kernel.org,
        linux-ppp@vger.kernel.org, linux-wireless@vger.kernel.org,
        ganeshgr@chelsio.com, nbd@openwrt.org, blogic@openwrt.org,
        matthias.bgg@gmail.com, yishaih@mellanox.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com,
        ajk@comnets.uni-bremen.de, paulus@samba.org, j@w1.fi,
        kvalo@codeaurora.org, peterz@infradead.org, keescook@chromium.org,
        gregkh@linuxfoundation.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4447 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755085AbdC1I6t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 04:58:49 -0400
In-Reply-To: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 drivers/net/wireless/intersil/hostap/hostap_hw.c   | 12 ++++++------
 drivers/net/wireless/intersil/hostap/hostap_wlan.h |  3 ++-
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/intersil/hostap/hostap_hw.c b/drivers/net/wireless/intersil/hostap/hostap_hw.c
index 04dfd040..d4f0b73 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_hw.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_hw.c
@@ -190,7 +190,7 @@ static inline void __hostap_cmd_queue_free(local_info_t *local,
 		}
 	}
 
-	if (atomic_dec_and_test(&entry->usecnt) && entry->del_req)
+	if (refcount_dec_and_test(&entry->usecnt) && entry->del_req)
 		kfree(entry);
 }
 
@@ -228,7 +228,7 @@ static void prism2_clear_cmd_queue(local_info_t *local)
 	spin_lock_irqsave(&local->cmdlock, flags);
 	list_for_each_safe(ptr, n, &local->cmd_queue) {
 		entry = list_entry(ptr, struct hostap_cmd_queue, list);
-		atomic_inc(&entry->usecnt);
+		refcount_inc(&entry->usecnt);
 		printk(KERN_DEBUG "%s: removed pending cmd_queue entry "
 		       "(type=%d, cmd=0x%04x, param0=0x%04x)\n",
 		       local->dev->name, entry->type, entry->cmd,
@@ -350,7 +350,7 @@ static int hfa384x_cmd(struct net_device *dev, u16 cmd, u16 param0,
 	if (entry == NULL)
 		return -ENOMEM;
 
-	atomic_set(&entry->usecnt, 1);
+	refcount_set(&entry->usecnt, 1);
 	entry->type = CMD_SLEEP;
 	entry->cmd = cmd;
 	entry->param0 = param0;
@@ -516,7 +516,7 @@ static int hfa384x_cmd_callback(struct net_device *dev, u16 cmd, u16 param0,
 	if (entry == NULL)
 		return -ENOMEM;
 
-	atomic_set(&entry->usecnt, 1);
+	refcount_set(&entry->usecnt, 1);
 	entry->type = CMD_CALLBACK;
 	entry->cmd = cmd;
 	entry->param0 = param0;
@@ -666,7 +666,7 @@ static void prism2_cmd_ev(struct net_device *dev)
 	if (!list_empty(&local->cmd_queue)) {
 		entry = list_entry(local->cmd_queue.next,
 				   struct hostap_cmd_queue, list);
-		atomic_inc(&entry->usecnt);
+		refcount_inc(&entry->usecnt);
 		list_del_init(&entry->list);
 		local->cmd_queue_len--;
 
@@ -718,7 +718,7 @@ static void prism2_cmd_ev(struct net_device *dev)
 			entry = NULL;
 		}
 		if (entry)
-			atomic_inc(&entry->usecnt);
+			refcount_inc(&entry->usecnt);
 	}
 	spin_unlock(&local->cmdlock);
 
diff --git a/drivers/net/wireless/intersil/hostap/hostap_wlan.h b/drivers/net/wireless/intersil/hostap/hostap_wlan.h
index ca25283..5352adb 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_wlan.h
+++ b/drivers/net/wireless/intersil/hostap/hostap_wlan.h
@@ -6,6 +6,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/mutex.h>
+#include <linux/refcount.h>
 #include <net/iw_handler.h>
 #include <net/ieee80211_radiotap.h>
 #include <net/lib80211.h>
@@ -557,7 +558,7 @@ struct hostap_cmd_queue {
 	u16 resp0, res;
 	volatile int issued, issuing;
 
-	atomic_t usecnt;
+	refcount_t usecnt;
 	int del_req;
 };
 
-- 
2.7.4
