From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 15/15] drivers, connector: convert cn_callback_entry.refcnt from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 10:23:49 +0300
Message-ID: <1508484229-19706-16-git-send-email-elena.reshetova@intel.com>
References: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-rdma@vger.kernel.org,
        linux-hams@vger.kernel.org, linux-ppp@vger.kernel.org,
        ganeshgr@chelsio.com, nbd@openwrt.org, john@phrozen.org,
        sean.wang@mediatek.com, matthias.bgg@gmail.com,
        yishaih@mellanox.com, saeedm@mellanox.com, matanb@mellanox.com,
        tariqt@mellanox.com, leonro@mellanox.com,
        ajk@comnets.uni-bremen.de, paulus@samba.org, zbr@ioremap.net,
        peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508484229-19706-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable cn_callback_entry.refcnt is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 drivers/connector/cn_queue.c  | 4 ++--
 drivers/connector/connector.c | 2 +-
 include/linux/connector.h     | 4 ++--
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
index 1f8bf05..9c54fdf 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -45,7 +45,7 @@ cn_queue_alloc_callback_entry(struct cn_queue_dev *dev, const char *name,
 		return NULL;
 	}
 
-	atomic_set(&cbq->refcnt, 1);
+	refcount_set(&cbq->refcnt, 1);
 
 	atomic_inc(&dev->refcnt);
 	cbq->pdev = dev;
@@ -58,7 +58,7 @@ cn_queue_alloc_callback_entry(struct cn_queue_dev *dev, const char *name,
 
 void cn_queue_release_callback(struct cn_callback_entry *cbq)
 {
-	if (!atomic_dec_and_test(&cbq->refcnt))
+	if (!refcount_dec_and_test(&cbq->refcnt))
 		return;
 
 	atomic_dec(&cbq->pdev->refcnt);
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index 25693b0..8615594b 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -157,7 +157,7 @@ static int cn_call_callback(struct sk_buff *skb)
 	spin_lock_bh(&dev->cbdev->queue_lock);
 	list_for_each_entry(i, &dev->cbdev->queue_list, callback_entry) {
 		if (cn_cb_equal(&i->id.id, &msg->id)) {
-			atomic_inc(&i->refcnt);
+			refcount_inc(&i->refcnt);
 			cbq = i;
 			break;
 		}
diff --git a/include/linux/connector.h b/include/linux/connector.h
index f8fe863..032102b 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -22,7 +22,7 @@
 #define __CONNECTOR_H
 
 
-#include <linux/atomic.h>
+#include <linux/refcount.h>
 
 #include <linux/list.h>
 #include <linux/workqueue.h>
@@ -49,7 +49,7 @@ struct cn_callback_id {
 
 struct cn_callback_entry {
 	struct list_head callback_entry;
-	atomic_t refcnt;
+	refcount_t refcnt;
 	struct cn_queue_dev *pdev;
 
 	struct cn_callback_id id;
-- 
2.7.4
