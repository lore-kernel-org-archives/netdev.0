From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 6/7] sysfs: clean up sysfs_get_dirent()
Date: Wed, 11 Sep 2013 22:29:08 -0400
Message-ID: <1378952949-7900-7-git-send-email-tj@kernel.org>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, kay@vrfy.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, lizefan@huawei.com,
	Tejun Heo <tj@kernel.org>
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378952949-7900-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The pre-existing sysfs interfaces which take explicit namespace
argument are weird in that they place the optional @ns in front of
@name which is contrary to the established convention.  For example,
we end up forcing vast majority of sysfs_get_dirent() users to do
sysfs_get_dirent(parent, NULL, name), which is silly and error-prone
especially as @ns and @name may be interchanged without causing
compilation warning.

This renames sysfs_get_dirent() to sysfs_get_dirent_ns() and swap the
positions of @name and @ns, and sysfs_get_dirent() is now a wrapper
around sysfs_get_dirent_ns().  This makes confusions a lot less
likely.

There are other interfaces which take @ns before @name.  They'll be
updated by following patches.

This patch doesn't introduce any functional changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: Kay Sievers <kay@vrfy.org>
---
 drivers/gpio/gpiolib.c |  2 +-
 drivers/md/bitmap.c    |  4 ++--
 drivers/md/md.c        |  2 +-
 drivers/md/md.h        |  2 +-
 fs/sysfs/dir.c         |  9 +++++----
 fs/sysfs/file.c        |  4 ++--
 fs/sysfs/group.c       | 10 +++++-----
 fs/sysfs/symlink.c     |  2 +-
 fs/sysfs/sysfs.h       |  3 ---
 include/linux/sysfs.h  | 19 ++++++++++++-------
 10 files changed, 30 insertions(+), 27 deletions(-)

diff --git a/drivers/gpio/gpiolib.c b/drivers/gpio/gpiolib.c
index 86ef346..a094356 100644
--- a/drivers/gpio/gpiolib.c
+++ b/drivers/gpio/gpiolib.c
@@ -408,7 +408,7 @@ static int gpio_setup_irq(struct gpio_desc *desc, struct device *dev,
 			IRQF_TRIGGER_FALLING : IRQF_TRIGGER_RISING;
 
 	if (!value_sd) {
-		value_sd = sysfs_get_dirent(dev->kobj.sd, NULL, "value");
+		value_sd = sysfs_get_dirent(dev->kobj.sd, "value");
 		if (!value_sd) {
 			ret = -ENODEV;
 			goto err_out;
diff --git a/drivers/md/bitmap.c b/drivers/md/bitmap.c
index a7fd821..12dc29b 100644
--- a/drivers/md/bitmap.c
+++ b/drivers/md/bitmap.c
@@ -1654,9 +1654,9 @@ int bitmap_create(struct mddev *mddev)
 	bitmap->mddev = mddev;
 
 	if (mddev->kobj.sd)
-		bm = sysfs_get_dirent(mddev->kobj.sd, NULL, "bitmap");
+		bm = sysfs_get_dirent(mddev->kobj.sd, "bitmap");
 	if (bm) {
-		bitmap->sysfs_can_clear = sysfs_get_dirent(bm, NULL, "can_clear");
+		bitmap->sysfs_can_clear = sysfs_get_dirent(bm, "can_clear");
 		sysfs_put(bm);
 	} else
 		bitmap->sysfs_can_clear = NULL;
diff --git a/drivers/md/md.c b/drivers/md/md.c
index adf4d7e..8a0d762 100644
--- a/drivers/md/md.c
+++ b/drivers/md/md.c
@@ -3555,7 +3555,7 @@ level_store(struct mddev *mddev, const char *buf, size_t len)
 			printk(KERN_WARNING
 			       "md: cannot register extra attributes for %s\n",
 			       mdname(mddev));
-		mddev->sysfs_action = sysfs_get_dirent(mddev->kobj.sd, NULL, "sync_action");
+		mddev->sysfs_action = sysfs_get_dirent(mddev->kobj.sd, "sync_action");
 	}		
 	if (mddev->pers->sync_request != NULL &&
 	    pers->sync_request == NULL) {
diff --git a/drivers/md/md.h b/drivers/md/md.h
index 608050c..b0051f2 100644
--- a/drivers/md/md.h
+++ b/drivers/md/md.h
@@ -501,7 +501,7 @@ extern struct attribute_group md_bitmap_group;
 static inline struct sysfs_dirent *sysfs_get_dirent_safe(struct sysfs_dirent *sd, char *name)
 {
 	if (sd)
-		return sysfs_get_dirent(sd, NULL, name);
+		return sysfs_get_dirent(sd, name);
 	return sd;
 }
 static inline void sysfs_notify_dirent_safe(struct sysfs_dirent *sd)
diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 1dfb4aa..3dacce0 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -630,9 +630,10 @@ struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
 }
 
 /**
- *	sysfs_get_dirent - find and get sysfs_dirent with the given name
+ *	sysfs_get_dirent_ns - find and get sysfs_dirent with the given name
  *	@parent_sd: sysfs_dirent to search under
  *	@name: name to look for
+ *	@ns: the namespace tag to use
  *
  *	Look for sysfs_dirent with name @name under @parent_sd and get
  *	it if found.
@@ -643,9 +644,9 @@ struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
  *	RETURNS:
  *	Pointer to sysfs_dirent if found, NULL if not.
  */
-struct sysfs_dirent *sysfs_get_dirent(struct sysfs_dirent *parent_sd,
-				      const void *ns,
-				      const unsigned char *name)
+struct sysfs_dirent *sysfs_get_dirent_ns(struct sysfs_dirent *parent_sd,
+					 const unsigned char *name,
+					 const void *ns)
 {
 	struct sysfs_dirent *sd;
 
diff --git a/fs/sysfs/file.c b/fs/sysfs/file.c
index e784340..0f3214a 100644
--- a/fs/sysfs/file.c
+++ b/fs/sysfs/file.c
@@ -563,7 +563,7 @@ int sysfs_add_file_to_group(struct kobject *kobj,
 	int error;
 
 	if (group)
-		dir_sd = sysfs_get_dirent(kobj->sd, NULL, group);
+		dir_sd = sysfs_get_dirent(kobj->sd, group);
 	else
 		dir_sd = sysfs_get(kobj->sd);
 
@@ -645,7 +645,7 @@ void sysfs_remove_file_from_group(struct kobject *kobj,
 	struct sysfs_dirent *dir_sd;
 
 	if (group)
-		dir_sd = sysfs_get_dirent(kobj->sd, NULL, group);
+		dir_sd = sysfs_get_dirent(kobj->sd, group);
 	else
 		dir_sd = sysfs_get(kobj->sd);
 	if (dir_sd) {
diff --git a/fs/sysfs/group.c b/fs/sysfs/group.c
index 25c78f2..2110215 100644
--- a/fs/sysfs/group.c
+++ b/fs/sysfs/group.c
@@ -207,7 +207,7 @@ void sysfs_remove_group(struct kobject *kobj,
 	struct sysfs_dirent *sd;
 
 	if (grp->name) {
-		sd = sysfs_get_dirent(dir_sd, NULL, grp->name);
+		sd = sysfs_get_dirent(dir_sd, grp->name);
 		if (!sd) {
 			WARN(!sd, KERN_WARNING
 			     "sysfs group %p not found for kobject '%s'\n",
@@ -262,7 +262,7 @@ int sysfs_merge_group(struct kobject *kobj,
 	struct attribute *const *attr;
 	int i;
 
-	dir_sd = sysfs_get_dirent(kobj->sd, NULL, grp->name);
+	dir_sd = sysfs_get_dirent(kobj->sd, grp->name);
 	if (!dir_sd)
 		return -ENOENT;
 
@@ -289,7 +289,7 @@ void sysfs_unmerge_group(struct kobject *kobj,
 	struct sysfs_dirent *dir_sd;
 	struct attribute *const *attr;
 
-	dir_sd = sysfs_get_dirent(kobj->sd, NULL, grp->name);
+	dir_sd = sysfs_get_dirent(kobj->sd, grp->name);
 	if (dir_sd) {
 		for (attr = grp->attrs; *attr; ++attr)
 			sysfs_hash_and_remove(dir_sd, NULL, (*attr)->name);
@@ -311,7 +311,7 @@ int sysfs_add_link_to_group(struct kobject *kobj, const char *group_name,
 	struct sysfs_dirent *dir_sd;
 	int error = 0;
 
-	dir_sd = sysfs_get_dirent(kobj->sd, NULL, group_name);
+	dir_sd = sysfs_get_dirent(kobj->sd, group_name);
 	if (!dir_sd)
 		return -ENOENT;
 
@@ -333,7 +333,7 @@ void sysfs_remove_link_from_group(struct kobject *kobj, const char *group_name,
 {
 	struct sysfs_dirent *dir_sd;
 
-	dir_sd = sysfs_get_dirent(kobj->sd, NULL, group_name);
+	dir_sd = sysfs_get_dirent(kobj->sd, group_name);
 	if (dir_sd) {
 		sysfs_hash_and_remove(dir_sd, NULL, link_name);
 		sysfs_put(dir_sd);
diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index 7d981ce..c96b31a 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -191,7 +191,7 @@ int sysfs_rename_link_ns(struct kobject *kobj, struct kobject *targ,
 		old_ns = targ->sd->s_ns;
 
 	result = -ENOENT;
-	sd = sysfs_get_dirent(parent_sd, old_ns, old);
+	sd = sysfs_get_dirent_ns(parent_sd, old, old_ns);
 	if (!sd)
 		goto out;
 
diff --git a/fs/sysfs/sysfs.h b/fs/sysfs/sysfs.h
index 7664d1b..6faacaf 100644
--- a/fs/sysfs/sysfs.h
+++ b/fs/sysfs/sysfs.h
@@ -164,9 +164,6 @@ void sysfs_addrm_finish(struct sysfs_addrm_cxt *acxt);
 struct sysfs_dirent *sysfs_find_dirent(struct sysfs_dirent *parent_sd,
 				       const void *ns,
 				       const unsigned char *name);
-struct sysfs_dirent *sysfs_get_dirent(struct sysfs_dirent *parent_sd,
-				      const void *ns,
-				      const unsigned char *name);
 struct sysfs_dirent *sysfs_new_dirent(const char *name, umode_t mode, int type);
 
 void release_sysfs_dirent(struct sysfs_dirent *sd);
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index c792f73..6695040 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -245,9 +245,9 @@ void sysfs_remove_link_from_group(struct kobject *kobj, const char *group_name,
 
 void sysfs_notify(struct kobject *kobj, const char *dir, const char *attr);
 void sysfs_notify_dirent(struct sysfs_dirent *sd);
-struct sysfs_dirent *sysfs_get_dirent(struct sysfs_dirent *parent_sd,
-				      const void *ns,
-				      const unsigned char *name);
+struct sysfs_dirent *sysfs_get_dirent_ns(struct sysfs_dirent *parent_sd,
+					 const unsigned char *name,
+					 const void *ns);
 struct sysfs_dirent *sysfs_get(struct sysfs_dirent *sd);
 void sysfs_put(struct sysfs_dirent *sd);
 
@@ -422,10 +422,9 @@ static inline void sysfs_notify(struct kobject *kobj, const char *dir,
 static inline void sysfs_notify_dirent(struct sysfs_dirent *sd)
 {
 }
-static inline
-struct sysfs_dirent *sysfs_get_dirent(struct sysfs_dirent *parent_sd,
-				      const void *ns,
-				      const unsigned char *name)
+static inline struct sysfs_dirent *
+sysfs_get_dirent_ns(struct sysfs_dirent *parent_sd, const unsigned char *name,
+		    const void *ns)
 {
 	return NULL;
 }
@@ -462,4 +461,10 @@ static inline int sysfs_rename_link(struct kobject *kobj, struct kobject *target
 	return sysfs_rename_link_ns(kobj, target, old_name, new_name, NULL);
 }
 
+static inline struct sysfs_dirent *
+sysfs_get_dirent(struct sysfs_dirent *parent_sd, const unsigned char *name)
+{
+	return sysfs_get_dirent_ns(parent_sd, name, NULL);
+}
+
 #endif /* _SYSFS_H_ */
-- 
1.8.3.1
