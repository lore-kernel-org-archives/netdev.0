From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 08/29] drivers,
 md: convert mddev.active from atomic_t to refcount_t
Date: Mon,  6 Mar 2017 16:20:55 +0200
Message-ID: <1488810076-3754-9-git-send-email-elena.reshetova@intel.com>
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
 drivers/md/md.c | 6 +++---
 drivers/md/md.h | 3 ++-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/md/md.c b/drivers/md/md.c
index 985374f..94c8ebf 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -449,7 +449,7 @@ EXPORT_SYMBOL(md_unplug);
 
 static inline struct mddev *mddev_get(struct mddev *mddev)
 {
-	atomic_inc(&mddev->active);
+	refcount_inc(&mddev->active);
 	return mddev;
 }
 
@@ -459,7 +459,7 @@ static void mddev_put(struct mddev *mddev)
 {
 	struct bio_set *bs = NULL;
 
-	if (!atomic_dec_and_lock(&mddev->active, &all_mddevs_lock))
+	if (!refcount_dec_and_lock(&mddev->active, &all_mddevs_lock))
 		return;
 	if (!mddev->raid_disks && list_empty(&mddev->disks) &&
 	    mddev->ctime == 0 && !mddev->hold_active) {
@@ -495,7 +495,7 @@ void mddev_init(struct mddev *mddev)
 	INIT_LIST_HEAD(&mddev->all_mddevs);
 	setup_timer(&mddev->safemode_timer, md_safemode_timeout,
 		    (unsigned long) mddev);
-	atomic_set(&mddev->active, 1);
+	refcount_set(&mddev->active, 1);
 	atomic_set(&mddev->openers, 0);
 	atomic_set(&mddev->active_io, 0);
 	spin_lock_init(&mddev->lock);
diff --git a/drivers/md/md.h b/drivers/md/md.h
index b8859cb..4811663 100644
--- a/drivers/md/md.h
+++ b/drivers/md/md.h
@@ -22,6 +22,7 @@
 #include <linux/list.h>
 #include <linux/mm.h>
 #include <linux/mutex.h>
+#include <linux/refcount.h>
 #include <linux/timer.h>
 #include <linux/wait.h>
 #include <linux/workqueue.h>
@@ -360,7 +361,7 @@ struct mddev {
 	 */
 	struct mutex			open_mutex;
 	struct mutex			reconfig_mutex;
-	atomic_t			active;		/* general refcount */
+	refcount_t			active;		/* general refcount */
 	atomic_t			openers;	/* number of active opens */
 
 	int				changed;	/* True if we might need to
-- 
2.7.4
