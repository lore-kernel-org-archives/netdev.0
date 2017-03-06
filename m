From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 05/29] drivers, md,
 bcache: convert cached_dev.count from atomic_t to refcount_t
Date: Mon,  6 Mar 2017 16:20:52 +0200
Message-ID: <1488810076-3754-6-git-send-email-elena.reshetova@intel.com>
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
 drivers/md/bcache/bcache.h    | 7 ++++---
 drivers/md/bcache/super.c     | 6 +++---
 drivers/md/bcache/writeback.h | 2 +-
 3 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/md/bcache/bcache.h b/drivers/md/bcache/bcache.h
index c3ea03c..de2be28 100644
--- a/drivers/md/bcache/bcache.h
+++ b/drivers/md/bcache/bcache.h
@@ -184,6 +184,7 @@
 #include <linux/mutex.h>
 #include <linux/rbtree.h>
 #include <linux/rwsem.h>
+#include <linux/refcount.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
 
@@ -299,7 +300,7 @@ struct cached_dev {
 	struct semaphore	sb_write_mutex;
 
 	/* Refcount on the cache set. Always nonzero when we're caching. */
-	atomic_t		count;
+	refcount_t		count;
 	struct work_struct	detach;
 
 	/*
@@ -805,13 +806,13 @@ do {									\
 
 static inline void cached_dev_put(struct cached_dev *dc)
 {
-	if (atomic_dec_and_test(&dc->count))
+	if (refcount_dec_and_test(&dc->count))
 		schedule_work(&dc->detach);
 }
 
 static inline bool cached_dev_get(struct cached_dev *dc)
 {
-	if (!atomic_inc_not_zero(&dc->count))
+	if (!refcount_inc_not_zero(&dc->count))
 		return false;
 
 	/* Paired with the mb in cached_dev_attach */
diff --git a/drivers/md/bcache/super.c b/drivers/md/bcache/super.c
index 85e3f21..cc36ce4 100644
--- a/drivers/md/bcache/super.c
+++ b/drivers/md/bcache/super.c
@@ -891,7 +891,7 @@ static void cached_dev_detach_finish(struct work_struct *w)
 	closure_init_stack(&cl);
 
 	BUG_ON(!test_bit(BCACHE_DEV_DETACHING, &dc->disk.flags));
-	BUG_ON(atomic_read(&dc->count));
+	BUG_ON(refcount_read(&dc->count));
 
 	mutex_lock(&bch_register_lock);
 
@@ -1018,7 +1018,7 @@ int bch_cached_dev_attach(struct cached_dev *dc, struct cache_set *c)
 	 * dc->c must be set before dc->count != 0 - paired with the mb in
 	 * cached_dev_get()
 	 */
-	atomic_set(&dc->count, 1);
+	refcount_set(&dc->count, 1);
 
 	/* Block writeback thread, but spawn it */
 	down_write(&dc->writeback_lock);
@@ -1030,7 +1030,7 @@ int bch_cached_dev_attach(struct cached_dev *dc, struct cache_set *c)
 	if (BDEV_STATE(&dc->sb) == BDEV_STATE_DIRTY) {
 		bch_sectors_dirty_init(dc);
 		atomic_set(&dc->has_dirty, 1);
-		atomic_inc(&dc->count);
+		refcount_inc(&dc->count);
 		bch_writeback_queue(dc);
 	}
 
diff --git a/drivers/md/bcache/writeback.h b/drivers/md/bcache/writeback.h
index 629bd1a..5bac1b0 100644
--- a/drivers/md/bcache/writeback.h
+++ b/drivers/md/bcache/writeback.h
@@ -70,7 +70,7 @@ static inline void bch_writeback_add(struct cached_dev *dc)
 {
 	if (!atomic_read(&dc->has_dirty) &&
 	    !atomic_xchg(&dc->has_dirty, 1)) {
-		atomic_inc(&dc->count);
+		refcount_inc(&dc->count);
 
 		if (BDEV_STATE(&dc->sb) != BDEV_STATE_DIRTY) {
 			SET_BDEV_STATE(&dc->sb, BDEV_STATE_DIRTY);
-- 
2.7.4
