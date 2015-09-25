From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 04/23] usb-gadget/f_hid: use per-attribute
	show and store methods
Date: Fri, 25 Sep 2015 06:49:41 -0700
Message-ID: <1443189000-13398-5-git-send-email-hch@lst.de>
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
 drivers/usb/gadget/function/f_hid.c | 34 ++++++++++++++--------------------
 1 file changed, 14 insertions(+), 20 deletions(-)

diff --git a/drivers/usb/gadget/function/f_hid.c b/drivers/usb/gadget/function/f_hid.c
index 6df9715..d15b061 100644
--- a/drivers/usb/gadget/function/f_hid.c
+++ b/drivers/usb/gadget/function/f_hid.c
@@ -713,9 +713,6 @@ static inline struct f_hid_opts *to_f_hid_opts(struct config_item *item)
 			    func_inst.group);
 }
 
-CONFIGFS_ATTR_STRUCT(f_hid_opts);
-CONFIGFS_ATTR_OPS(f_hid_opts);
-
 static void hid_attr_release(struct config_item *item)
 {
 	struct f_hid_opts *opts = to_f_hid_opts(item);
@@ -725,13 +722,12 @@ static void hid_attr_release(struct config_item *item)
 
 static struct configfs_item_operations hidg_item_ops = {
 	.release	= hid_attr_release,
-	.show_attribute	= f_hid_opts_attr_show,
-	.store_attribute = f_hid_opts_attr_store,
 };
 
 #define F_HID_OPT(name, prec, limit)					\
-static ssize_t f_hid_opts_##name##_show(struct f_hid_opts *opts, char *page)\
+static ssize_t f_hid_opts_##name##_show(struct config_item *item, char *page)\
 {									\
+	struct f_hid_opts *opts = to_f_hid_opts(item);			\
 	int result;							\
 									\
 	mutex_lock(&opts->lock);					\
@@ -741,9 +737,10 @@ static ssize_t f_hid_opts_##name##_show(struct f_hid_opts *opts, char *page)\
 	return result;							\
 }									\
 									\
-static ssize_t f_hid_opts_##name##_store(struct f_hid_opts *opts,	\
+static ssize_t f_hid_opts_##name##_store(struct config_item *item,	\
 					 const char *page, size_t len)	\
 {									\
+	struct f_hid_opts *opts = to_f_hid_opts(item);			\
 	int ret;							\
 	u##prec num;							\
 									\
@@ -769,16 +766,15 @@ end:									\
 	return ret;							\
 }									\
 									\
-static struct f_hid_opts_attribute f_hid_opts_##name =			\
-	__CONFIGFS_ATTR(name, S_IRUGO | S_IWUSR, f_hid_opts_##name##_show,\
-			f_hid_opts_##name##_store)
+CONFIGFS_ATTR(f_hid_opts_, name)
 
 F_HID_OPT(subclass, 8, 255);
 F_HID_OPT(protocol, 8, 255);
 F_HID_OPT(report_length, 16, 65535);
 
-static ssize_t f_hid_opts_report_desc_show(struct f_hid_opts *opts, char *page)
+static ssize_t f_hid_opts_report_desc_show(struct config_item *item, char *page)
 {
+	struct f_hid_opts *opts = to_f_hid_opts(item);
 	int result;
 
 	mutex_lock(&opts->lock);
@@ -789,9 +785,10 @@ static ssize_t f_hid_opts_report_desc_show(struct f_hid_opts *opts, char *page)
 	return result;
 }
 
-static ssize_t f_hid_opts_report_desc_store(struct f_hid_opts *opts,
+static ssize_t f_hid_opts_report_desc_store(struct config_item *item,
 					    const char *page, size_t len)
 {
+	struct f_hid_opts *opts = to_f_hid_opts(item);
 	int ret = -EBUSY;
 	char *d;
 
@@ -818,16 +815,13 @@ end:
 	return ret;
 }
 
-static struct f_hid_opts_attribute f_hid_opts_report_desc =
-	__CONFIGFS_ATTR(report_desc, S_IRUGO | S_IWUSR,
-			f_hid_opts_report_desc_show,
-			f_hid_opts_report_desc_store);
+CONFIGFS_ATTR(f_hid_opts_, report_desc);
 
 static struct configfs_attribute *hid_attrs[] = {
-	&f_hid_opts_subclass.attr,
-	&f_hid_opts_protocol.attr,
-	&f_hid_opts_report_length.attr,
-	&f_hid_opts_report_desc.attr,
+	&f_hid_opts_attr_subclass,
+	&f_hid_opts_attr_protocol,
+	&f_hid_opts_attr_report_length,
+	&f_hid_opts_attr_report_desc,
 	NULL,
 };
 
-- 
1.9.1
