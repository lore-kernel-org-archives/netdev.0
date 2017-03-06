From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 04/29] drivers,
 connector: convert cn_callback_entry.refcnt from atomic_t to
 refcount_t
Date: Mon,  6 Mar 2017 16:20:51 +0200
Message-ID: <1488810076-3754-5-git-send-email-elena.reshetova@intel.com>
References: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: peterz@infradead.org, linux-pci@vger.kernel.org,
 target-devel@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
 Elena Reshetova <elena.reshetova@intel.com>, devel@driverdev.osuosl.org,
 linux-s390@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-serial@vger.kernel.org, fcoe-devel@open-fcoe.org,
 xen-devel@lists.xenproject.org, open-iscsi@googlegroups.com,
 linux-media@vger.kernel.org, Kees Cook <keescook@chromium.org>,
 linux-raid@vger.kernel.org, linux-bcache@vger.kernel.org,
 Hans Liljestrand <ishkamiel@gmail.com>, David Windsor <dwindsor@gmail.com>,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1488810076-3754-1-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

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
