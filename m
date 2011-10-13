From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/5] sysfs: Implement support for tagged files in sysfs.
Date: Thu, 13 Oct 2011 00:53:38 -0700
Message-ID: <m1wrc99vjx.fsf@fess.ebiederm.org>
References: <m1hb3dbae5.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, Tejun Heo <htejun@gmail.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1hb3dbae5.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 13 Oct 2011 00:47:46 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Looking up files in sysfs is hard to understand and analyize because we
currently allow placing untagged files in tagged directories.  In the
implementation of that we have two subtly different meanings of NULL.
NULL meaning there is no tag on a directory entry and NULL meaning
we don't care which namespace the lookup is performed for.  This
multiple uses of NULL have resulted in subtle bugs (since fixed) 
in the code.

Currently it is only the bonding driver that needs to have an untagged
file in a tagged directory.

To untagle this mess I am adding support for tagged files to sysfs.
Modifying the bonding driver to implement bonding_masters as a tagged
file.  Registering bonding_masters once for each network namespace.
Then I am removing support for untagged entries in tagged sysfs
directories.

Resulting in code that is much easier to reason about.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/file.c       |   53 +++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/sysfs.h |    1 +
 2 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index 1ad8c93..07c1b4e 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -488,17 +488,56 @@ const struct file_operations sysfs_file_operations = {
 	.poll		= sysfs_poll,
 };
 
+int sysfs_attr_ns(struct kobject *kobj, const struct attribute *attr,
+		  const void **pns)
+{
+	struct sysfs_dirent *dir_sd = kobj->sd;
+	const struct sysfs_ops *ops;
+	const void *ns = NULL;
+	int err;
+
+	err = 0;
+	if (!sysfs_ns_type(dir_sd))
+		goto out;
+
+	err = -EINVAL;
+	if (!kobj->ktype)
+		goto out;
+	ops = kobj->ktype->sysfs_ops;
+	if (!ops)
+		goto out;
+	if (!ops->namespace)
+		goto out;
+
+	err = 0;
+	ns = ops->namespace(kobj, attr);
+out:
+	if (err) {
+		WARN(1, KERN_ERR "missing sysfs namespace attribute operation for "
+		     "kobject: %s\n", kobject_name(kobj));
+	}
+	*pns = ns;
+	return err;
+}
+
 int sysfs_add_file_mode(struct sysfs_dirent *dir_sd,
 			const struct attribute *attr, int type, mode_t amode)
 {
 	umode_t mode = (amode & S_IALLUGO) | S_IFREG;
 	struct sysfs_addrm_cxt acxt;
 	struct sysfs_dirent *sd;
+	const void *ns;
 	int rc;
 
+	rc = sysfs_attr_ns(dir_sd->s_dir.kobj, attr, &ns);
+	if (rc)
+		return rc;
+
 	sd = sysfs_new_dirent(attr->name, mode, type);
 	if (!sd)
 		return -ENOMEM;
+
+	sd->s_ns = ns;
 	sd->s_attr.attr = (void *)attr;
 	sysfs_dirent_init_lockdep(sd);
 
@@ -586,12 +625,17 @@ int sysfs_chmod_file(struct kobject *kobj, const struct attribute *attr,
 {
 	struct sysfs_dirent *sd;
 	struct iattr newattrs;
+	const void *ns;
 	int rc;
 
+	rc = sysfs_attr_ns(kobj, attr, &ns);
+	if (rc)
+		return rc;
+
 	mutex_lock(&sysfs_mutex);
 
 	rc = -ENOENT;
-	sd = sysfs_find_dirent(kobj->sd, NULL, attr->name);
+	sd = sysfs_find_dirent(kobj->sd, ns, attr->name);
 	if (!sd)
 		goto out;
 
@@ -616,7 +660,12 @@ EXPORT_SYMBOL_GPL(sysfs_chmod_file);
 
 void sysfs_remove_file(struct kobject * kobj, const struct attribute * attr)
 {
-	sysfs_hash_and_remove(kobj->sd, NULL, attr->name);
+	const void *ns;
+
+	if (sysfs_attr_ns(kobj, attr, &ns))
+		return;
+
+	sysfs_hash_and_remove(kobj->sd, ns, attr->name);
 }
 
 void sysfs_remove_files(struct kobject * kobj, const struct attribute **ptr)
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index d7d2f21..dac0859 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -112,6 +112,7 @@ struct bin_attribute {
 struct sysfs_ops {
 	ssize_t	(*show)(struct kobject *, struct attribute *,char *);
 	ssize_t	(*store)(struct kobject *,struct attribute *,const char *, size_t);
+	const void *(*namespace)(struct kobject *, const struct attribute *);
 };
 
 struct sysfs_dirent;
-- 
1.7.2.5
