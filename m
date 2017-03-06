From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 07/29] drivers,
 md: convert dm_dev_internal.count from atomic_t to refcount_t
Date: Mon,  6 Mar 2017 16:20:54 +0200
Message-ID: <1488810076-3754-8-git-send-email-elena.reshetova@intel.com>
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
 drivers/md/dm-table.c | 6 +++---
 drivers/md/dm.h       | 3 ++-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/md/dm-table.c b/drivers/md/dm-table.c
index 3ad16d9..d2e2741 100644
--- a/drivers/md/dm-table.c
+++ b/drivers/md/dm-table.c
@@ -416,15 +416,15 @@ int dm_get_device(struct dm_target *ti, const char *path, fmode_t mode,
 			return r;
 		}
 
-		atomic_set(&dd->count, 0);
+		refcount_set(&dd->count, 1);
 		list_add(&dd->list, &t->devices);
 
 	} else if (dd->dm_dev->mode != (mode | dd->dm_dev->mode)) {
 		r = upgrade_mode(dd, mode, t->md);
 		if (r)
 			return r;
+		refcount_inc(&dd->count);
 	}
-	atomic_inc(&dd->count);
 
 	*result = dd->dm_dev;
 	return 0;
@@ -478,7 +478,7 @@ void dm_put_device(struct dm_target *ti, struct dm_dev *d)
 		       dm_device_name(ti->table->md), d->name);
 		return;
 	}
-	if (atomic_dec_and_test(&dd->count)) {
+	if (refcount_dec_and_test(&dd->count)) {
 		dm_put_table_device(ti->table->md, d);
 		list_del(&dd->list);
 		kfree(dd);
diff --git a/drivers/md/dm.h b/drivers/md/dm.h
index f298b01..63b8142 100644
--- a/drivers/md/dm.h
+++ b/drivers/md/dm.h
@@ -19,6 +19,7 @@
 #include <linux/hdreg.h>
 #include <linux/completion.h>
 #include <linux/kobject.h>
+#include <linux/refcount.h>
 
 #include "dm-stats.h"
 
@@ -38,7 +39,7 @@
  */
 struct dm_dev_internal {
 	struct list_head list;
-	atomic_t count;
+	refcount_t count;
 	struct dm_dev *dm_dev;
 };
 
-- 
2.7.4
