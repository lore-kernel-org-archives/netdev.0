From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/5] class: Implement support for class attrs in tagged sysfs directories.
Date: Thu, 13 Oct 2011 00:55:08 -0700
Message-ID: <m1sjmx9vhf.fsf_-_@fess.ebiederm.org>
References: <m1hb3dbae5.fsf@fess.ebiederm.org>
	<m1wrc99vjx.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, Tejun Heo <htejun@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1wrc99vjx.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 13 Oct 2011 00:53:38 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/base/class.c   |   17 +++++++++++++++--
 include/linux/device.h |    2 ++
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/base/class.c b/drivers/base/class.c
index 4f1df2e..b80d91c 100644
--- a/drivers/base/class.c
+++ b/drivers/base/class.c
@@ -47,6 +47,18 @@ static ssize_t class_attr_store(struct kobject *kobj, struct attribute *attr,
 	return ret;
 }
 
+static const void *class_attr_namespace(struct kobject *kobj,
+					const struct attribute *attr)
+{
+	struct class_attribute *class_attr = to_class_attr(attr);
+	struct subsys_private *cp = to_subsys_private(kobj);
+	const void *ns = NULL;
+
+	if (class_attr->namespace)
+		ns = class_attr->namespace(cp->class, class_attr);
+	return ns;
+}
+
 static void class_release(struct kobject *kobj)
 {
 	struct subsys_private *cp = to_subsys_private(kobj);
@@ -72,8 +84,9 @@ static const struct kobj_ns_type_operations *class_child_ns_type(struct kobject
 }
 
 static const struct sysfs_ops class_sysfs_ops = {
-	.show	= class_attr_show,
-	.store	= class_attr_store,
+	.show	   = class_attr_show,
+	.store	   = class_attr_store,
+	.namespace = class_attr_namespace,
 };
 
 static struct kobj_type class_ktype = {
diff --git a/include/linux/device.h b/include/linux/device.h
index c20dfbf..ea70bb2 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -350,6 +350,8 @@ struct class_attribute {
 			char *buf);
 	ssize_t (*store)(struct class *class, struct class_attribute *attr,
 			const char *buf, size_t count);
+	const void *(*namespace)(struct class *class,
+				 const struct class_attribute *attr);
 };
 
 #define CLASS_ATTR(_name, _mode, _show, _store)			\
-- 
1.7.2.5
