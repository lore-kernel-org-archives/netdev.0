From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 06/29] drivers,
 md: convert dm_cache_metadata.ref_count from atomic_t to refcount_t
Date: Mon,  6 Mar 2017 16:20:53 +0200
Message-ID: <1488810076-3754-7-git-send-email-elena.reshetova@intel.com>
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
 drivers/md/dm-cache-metadata.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/md/dm-cache-metadata.c b/drivers/md/dm-cache-metadata.c
index e4c2c1a..6d26e71 100644
--- a/drivers/md/dm-cache-metadata.c
+++ b/drivers/md/dm-cache-metadata.c
@@ -13,6 +13,7 @@
 #include "persistent-data/dm-transaction-manager.h"
 
 #include <linux/device-mapper.h>
+#include <linux/refcount.h>
 
 /*----------------------------------------------------------------*/
 
@@ -102,7 +103,7 @@ struct cache_disk_superblock {
 } __packed;
 
 struct dm_cache_metadata {
-	atomic_t ref_count;
+	refcount_t ref_count;
 	struct list_head list;
 
 	unsigned version;
@@ -756,7 +757,7 @@ static struct dm_cache_metadata *metadata_open(struct block_device *bdev,
 	}
 
 	cmd->version = metadata_version;
-	atomic_set(&cmd->ref_count, 1);
+	refcount_set(&cmd->ref_count, 1);
 	init_rwsem(&cmd->root_lock);
 	cmd->bdev = bdev;
 	cmd->data_block_size = data_block_size;
@@ -794,7 +795,7 @@ static struct dm_cache_metadata *lookup(struct block_device *bdev)
 
 	list_for_each_entry(cmd, &table, list)
 		if (cmd->bdev == bdev) {
-			atomic_inc(&cmd->ref_count);
+			refcount_inc(&cmd->ref_count);
 			return cmd;
 		}
 
@@ -865,7 +866,7 @@ struct dm_cache_metadata *dm_cache_metadata_open(struct block_device *bdev,
 
 void dm_cache_metadata_close(struct dm_cache_metadata *cmd)
 {
-	if (atomic_dec_and_test(&cmd->ref_count)) {
+	if (refcount_dec_and_test(&cmd->ref_count)) {
 		mutex_lock(&table_lock);
 		list_del(&cmd->list);
 		mutex_unlock(&table_lock);
-- 
2.7.4
