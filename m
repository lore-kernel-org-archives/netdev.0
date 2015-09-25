From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 11/23] usb-gadget/f_mass_storage: use
	per-attribute show and store methods
Date: Fri, 25 Sep 2015 06:49:48 -0700
Message-ID: <1443189000-13398-12-git-send-email-hch@lst.de>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        Pratyush Anand <pratyush.anand@gmail.com>, Felipe Balbi <balbi@ti.com>,
        cluster-devel@redhat.com, target-devel@vger.kernel.org,
        Tejun Heo <tj@kernel.org>, ocfs2-devel@oss.oracle.com
To: Joel Becker <jlbec@evilplan.org>,
        Andrew Morton <akpm@linux-foundation.org>
Return-path: <cluster-devel-bounces@redhat.com>
In-Reply-To: <1443189000-13398-1-git-send-email-hch@lst.de>
List-Unsubscribe: <https://www.redhat.com/mailman/options/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/usb/gadget/function/f_mass_storage.c | 123 ++++++++++-----------------
 1 file changed, 46 insertions(+), 77 deletions(-)

diff --git a/drivers/usb/gadget/function/f_mass_storage.c b/drivers/usb/gadget/function/f_mass_storage.c
index a6eb537..db71ae9 100644
--- a/drivers/usb/gadget/function/f_mass_storage.c
+++ b/drivers/usb/gadget/function/f_mass_storage.c
@@ -3144,9 +3144,6 @@ static inline struct fsg_opts *to_fsg_opts(struct config_item *item)
 			    func_inst.group);
 }
 
-CONFIGFS_ATTR_STRUCT(fsg_lun_opts);
-CONFIGFS_ATTR_OPS(fsg_lun_opts);
-
 static void fsg_lun_attr_release(struct config_item *item)
 {
 	struct fsg_lun_opts *lun_opts;
@@ -3157,110 +3154,89 @@ static void fsg_lun_attr_release(struct config_item *item)
 
 static struct configfs_item_operations fsg_lun_item_ops = {
 	.release		= fsg_lun_attr_release,
-	.show_attribute		= fsg_lun_opts_attr_show,
-	.store_attribute	= fsg_lun_opts_attr_store,
 };
 
-static ssize_t fsg_lun_opts_file_show(struct fsg_lun_opts *opts, char *page)
+static ssize_t fsg_lun_opts_file_show(struct config_item *item, char *page)
 {
-	struct fsg_opts *fsg_opts;
-
-	fsg_opts = to_fsg_opts(opts->group.cg_item.ci_parent);
+	struct fsg_lun_opts *opts = to_fsg_lun_opts(item);
+	struct fsg_opts *fsg_opts = to_fsg_opts(opts->group.cg_item.ci_parent);
 
 	return fsg_show_file(opts->lun, &fsg_opts->common->filesem, page);
 }
 
-static ssize_t fsg_lun_opts_file_store(struct fsg_lun_opts *opts,
+static ssize_t fsg_lun_opts_file_store(struct config_item *item,
 				       const char *page, size_t len)
 {
-	struct fsg_opts *fsg_opts;
-
-	fsg_opts = to_fsg_opts(opts->group.cg_item.ci_parent);
+	struct fsg_lun_opts *opts = to_fsg_lun_opts(item);
+	struct fsg_opts *fsg_opts = to_fsg_opts(opts->group.cg_item.ci_parent);
 
 	return fsg_store_file(opts->lun, &fsg_opts->common->filesem, page, len);
 }
 
-static struct fsg_lun_opts_attribute fsg_lun_opts_file =
-	__CONFIGFS_ATTR(file, S_IRUGO | S_IWUSR, fsg_lun_opts_file_show,
-			fsg_lun_opts_file_store);
-
-static ssize_t fsg_lun_opts_ro_show(struct fsg_lun_opts *opts, char *page)
+static ssize_t fsg_lun_opts_ro_show(struct config_item *item, char *page)
 {
-	return fsg_show_ro(opts->lun, page);
+	return fsg_show_ro(to_fsg_lun_opts(item)->lun, page);
 }
 
-static ssize_t fsg_lun_opts_ro_store(struct fsg_lun_opts *opts,
+static ssize_t fsg_lun_opts_ro_store(struct config_item *item,
 				       const char *page, size_t len)
 {
-	struct fsg_opts *fsg_opts;
-
-	fsg_opts = to_fsg_opts(opts->group.cg_item.ci_parent);
+	struct fsg_lun_opts *opts = to_fsg_lun_opts(item);
+	struct fsg_opts *fsg_opts = to_fsg_opts(opts->group.cg_item.ci_parent);
 
 	return fsg_store_ro(opts->lun, &fsg_opts->common->filesem, page, len);
 }
 
-static struct fsg_lun_opts_attribute fsg_lun_opts_ro =
-	__CONFIGFS_ATTR(ro, S_IRUGO | S_IWUSR, fsg_lun_opts_ro_show,
-			fsg_lun_opts_ro_store);
-
-static ssize_t fsg_lun_opts_removable_show(struct fsg_lun_opts *opts,
+static ssize_t fsg_lun_opts_removable_show(struct config_item *item,
 					   char *page)
 {
-	return fsg_show_removable(opts->lun, page);
+	return fsg_show_removable(to_fsg_lun_opts(item)->lun, page);
 }
 
-static ssize_t fsg_lun_opts_removable_store(struct fsg_lun_opts *opts,
+static ssize_t fsg_lun_opts_removable_store(struct config_item *item,
 				       const char *page, size_t len)
 {
-	return fsg_store_removable(opts->lun, page, len);
+	return fsg_store_removable(to_fsg_lun_opts(item)->lun, page, len);
 }
 
-static struct fsg_lun_opts_attribute fsg_lun_opts_removable =
-	__CONFIGFS_ATTR(removable, S_IRUGO | S_IWUSR,
-			fsg_lun_opts_removable_show,
-			fsg_lun_opts_removable_store);
-
-static ssize_t fsg_lun_opts_cdrom_show(struct fsg_lun_opts *opts, char *page)
+static ssize_t fsg_lun_opts_cdrom_show(struct config_item *item, char *page)
 {
-	return fsg_show_cdrom(opts->lun, page);
+	return fsg_show_cdrom(to_fsg_lun_opts(item)->lun, page);
 }
 
-static ssize_t fsg_lun_opts_cdrom_store(struct fsg_lun_opts *opts,
+static ssize_t fsg_lun_opts_cdrom_store(struct config_item *item,
 				       const char *page, size_t len)
 {
-	struct fsg_opts *fsg_opts;
-
-	fsg_opts = to_fsg_opts(opts->group.cg_item.ci_parent);
+	struct fsg_lun_opts *opts = to_fsg_lun_opts(item);
+	struct fsg_opts *fsg_opts = to_fsg_opts(opts->group.cg_item.ci_parent);
 
 	return fsg_store_cdrom(opts->lun, &fsg_opts->common->filesem, page,
 			       len);
 }
 
-static struct fsg_lun_opts_attribute fsg_lun_opts_cdrom =
-	__CONFIGFS_ATTR(cdrom, S_IRUGO | S_IWUSR, fsg_lun_opts_cdrom_show,
-			fsg_lun_opts_cdrom_store);
-
-static ssize_t fsg_lun_opts_nofua_show(struct fsg_lun_opts *opts, char *page)
+static ssize_t fsg_lun_opts_nofua_show(struct config_item *item, char *page)
 {
-	return fsg_show_nofua(opts->lun, page);
+	return fsg_show_nofua(to_fsg_lun_opts(item)->lun, page);
 }
 
-static ssize_t fsg_lun_opts_nofua_store(struct fsg_lun_opts *opts,
+static ssize_t fsg_lun_opts_nofua_store(struct config_item *item,
 				       const char *page, size_t len)
 {
-	return fsg_store_nofua(opts->lun, page, len);
+	return fsg_store_nofua(to_fsg_lun_opts(item)->lun, page, len);
 }
 
-static struct fsg_lun_opts_attribute fsg_lun_opts_nofua =
-	__CONFIGFS_ATTR(nofua, S_IRUGO | S_IWUSR, fsg_lun_opts_nofua_show,
-			fsg_lun_opts_nofua_store);
+CONFIGFS_ATTR(fsg_lun_opts_, file);
+CONFIGFS_ATTR(fsg_lun_opts_, ro);
+CONFIGFS_ATTR(fsg_lun_opts_, removable);
+CONFIGFS_ATTR(fsg_lun_opts_, cdrom);
+CONFIGFS_ATTR(fsg_lun_opts_, nofua);
 
 static struct configfs_attribute *fsg_lun_attrs[] = {
-	&fsg_lun_opts_file.attr,
-	&fsg_lun_opts_ro.attr,
-	&fsg_lun_opts_removable.attr,
-	&fsg_lun_opts_cdrom.attr,
-	&fsg_lun_opts_nofua.attr,
+	&fsg_lun_opts_attr_file,
+	&fsg_lun_opts_attr_ro,
+	&fsg_lun_opts_attr_removable,
+	&fsg_lun_opts_attr_cdrom,
+	&fsg_lun_opts_attr_nofua,
 	NULL,
 };
 
@@ -3352,9 +3328,6 @@ static void fsg_lun_drop(struct config_group *group, struct config_item *item)
 	config_item_put(item);
 }
 
-CONFIGFS_ATTR_STRUCT(fsg_opts);
-CONFIGFS_ATTR_OPS(fsg_opts);
-
 static void fsg_attr_release(struct config_item *item)
 {
 	struct fsg_opts *opts = to_fsg_opts(item);
@@ -3364,12 +3337,11 @@ static void fsg_attr_release(struct config_item *item)
 
 static struct configfs_item_operations fsg_item_ops = {
 	.release		= fsg_attr_release,
-	.show_attribute		= fsg_opts_attr_show,
-	.store_attribute	= fsg_opts_attr_store,
 };
 
-static ssize_t fsg_opts_stall_show(struct fsg_opts *opts, char *page)
+static ssize_t fsg_opts_stall_show(struct config_item *item, char *page)
 {
+	struct fsg_opts *opts = to_fsg_opts(item);
 	int result;
 
 	mutex_lock(&opts->lock);
@@ -3379,9 +3351,10 @@ static ssize_t fsg_opts_stall_show(struct fsg_opts *opts, char *page)
 	return result;
 }
 
-static ssize_t fsg_opts_stall_store(struct fsg_opts *opts, const char *page,
+static ssize_t fsg_opts_stall_store(struct config_item *item, const char *page,
 				    size_t len)
 {
+	struct fsg_opts *opts = to_fsg_opts(item);
 	int ret;
 	bool stall;
 
@@ -3403,13 +3376,12 @@ static ssize_t fsg_opts_stall_store(struct fsg_opts *opts, const char *page,
 	return ret;
 }
 
-static struct fsg_opts_attribute fsg_opts_stall =
-	__CONFIGFS_ATTR(stall, S_IRUGO | S_IWUSR, fsg_opts_stall_show,
-			fsg_opts_stall_store);
+CONFIGFS_ATTR(fsg_opts_, stall);
 
 #ifdef CONFIG_USB_GADGET_DEBUG_FILES
-static ssize_t fsg_opts_num_buffers_show(struct fsg_opts *opts, char *page)
+static ssize_t fsg_opts_num_buffers_show(struct config_item *item, char *page)
 {
+	struct fsg_opts *opts = to_fsg_opts(item);
 	int result;
 
 	mutex_lock(&opts->lock);
@@ -3419,9 +3391,10 @@ static ssize_t fsg_opts_num_buffers_show(struct fsg_opts *opts, char *page)
 	return result;
 }
 
-static ssize_t fsg_opts_num_buffers_store(struct fsg_opts *opts,
+static ssize_t fsg_opts_num_buffers_store(struct config_item *item,
 					  const char *page, size_t len)
 {
+	struct fsg_opts *opts = to_fsg_opts(item);
 	int ret;
 	u8 num;
 
@@ -3446,17 +3419,13 @@ end:
 	return ret;
 }
 
-static struct fsg_opts_attribute fsg_opts_num_buffers =
-	__CONFIGFS_ATTR(num_buffers, S_IRUGO | S_IWUSR,
-			fsg_opts_num_buffers_show,
-			fsg_opts_num_buffers_store);
-
+CONFIGFS_ATTR(fsg_opts_, num_buffers);
 #endif
 
 static struct configfs_attribute *fsg_attrs[] = {
-	&fsg_opts_stall.attr,
+	&fsg_opts_attr_stall,
 #ifdef CONFIG_USB_GADGET_DEBUG_FILES
-	&fsg_opts_num_buffers.attr,
+	&fsg_opts_attr_num_buffers,
 #endif
 	NULL,
 };
-- 
1.9.1
