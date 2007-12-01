From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 08/10] sysfs: Implement sysfs_delete_link and sysfs_rename_link
Date: Sat, 01 Dec 2007 02:30:52 -0700
Message-ID: <m17ijy7odv.fsf_-_@ebiederm.dsl.xmission.com>
References: <m163zi9425.fsf@ebiederm.dsl.xmission.com>
	<m11wa693t0.fsf@ebiederm.dsl.xmission.com>
	<m1wsry7p60.fsf_-_@ebiederm.dsl.xmission.com>
	<m1sl2m7p1c.fsf_-_@ebiederm.dsl.xmission.com>
	<m1odda7oxs.fsf_-_@ebiederm.dsl.xmission.com>
	<m1k5ny7oqb.fsf_-_@ebiederm.dsl.xmission.com>
	<m1fxym7omf.fsf_-_@ebiederm.dsl.xmission.com>
	<m1bq9a7oh8.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <htejun@gmail.com>,
	Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, cornelia.huck@de.ibm.com,
	stern@rowland.harvard.edu, kay.sievers@vrfy.org,
	<linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: Greg Kroah-Hartman <gregkh@suse.de>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:46569 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751698AbXLAJcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 04:32:54 -0500
In-Reply-To: <m1bq9a7oh8.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Sat, 01 Dec 2007 02:28:51 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When removing a symlink sysfs_remove_link does not provide enough
information to figure out which tagged directory the symlink falls in.
So I need sysfs_delete_link which is passed the target of the symlink
to delete.

Further half the time when we are removing a symlink the code is
actually renaming the symlink but not doing so explicitly because we
don't have a symlink rename method.  So I have added sysfs_rename_link
as well.

Both of these functions now have enough information to find a symlink
in a tagged directory.  The only restriction is that they must be
called before the target kobject is renamed or deleted.  If they are
called later I loose track of which tag the target kobject was marked
with and can no longer find the old symlink to remove it.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/symlink.c    |   31 +++++++++++++++++++++++++++++++
 include/linux/sysfs.h |   17 +++++++++++++++++
 2 files changed, 48 insertions(+), 0 deletions(-)

diff --git a/fs/sysfs/symlink.c b/fs/sysfs/symlink.c
index b0f8070..89c98cb 100644
--- a/fs/sysfs/symlink.c
+++ b/fs/sysfs/symlink.c
@@ -80,6 +80,21 @@ int sysfs_create_link(struct kobject * kobj, struct kobject * target, const char
 }
 
 /**
+ *	sysfs_delete_link - remove symlink in object's directory.
+ *	@kobj:	object we're acting for.
+ *	@targ:	object we're pointing to.
+ *	@name:	name of the symlink to remove.
+ *
+ *	Unlike sysfs_remove_link sysfs_delete_link has enough information
+ *	to successfully delete symlinks in tagged directories.
+ */
+void sysfs_delete_link(struct kobject *kobj, struct kobject *targ,
+			const char *name)
+{
+	sysfs_hash_and_remove(targ, kobj->sd, name);
+}
+
+/**
  *	sysfs_remove_link - remove symlink in object's directory.
  *	@kobj:	object we're acting for.
  *	@name:	name of the symlink to remove.
@@ -90,6 +105,22 @@ void sysfs_remove_link(struct kobject * kobj, const char * name)
 	sysfs_hash_and_remove(kobj, kobj->sd, name);
 }
 
+/**
+ *	sysfs_rename_link - rename symlink in object's directory.
+ *	@kobj:	object we're acting for.
+ *	@targ:	object we're pointing to.
+ *	@old:	previous name of the symlink.
+ *	@new:	new name of the symlink.
+ *
+ *	A helper function for the common rename symlink idiom.
+ */
+int sysfs_rename_link(struct kobject *kobj, struct kobject *targ,
+			const char *old, const char *new)
+{
+	sysfs_delete_link(kobj, targ, old);
+	return sysfs_create_link(kobj, targ, new);
+}
+
 static int sysfs_get_target_path(struct sysfs_dirent *parent_sd,
 				 struct sysfs_dirent *target_sd, char *path)
 {
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index c8d7a69..c2e8b0d 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -109,6 +109,12 @@ int __must_check sysfs_create_link(struct kobject *kobj, struct kobject *target,
 				   const char *name);
 void sysfs_remove_link(struct kobject *kobj, const char *name);
 
+int sysfs_rename_link(struct kobject *kobj, struct kobject *target,
+			const char *old_name, const char *new_name);
+
+void sysfs_delete_link(struct kobject *dir, struct kobject *targ,
+			const char *name);
+
 int __must_check sysfs_create_group(struct kobject *kobj,
 				    const struct attribute_group *grp);
 void sysfs_remove_group(struct kobject *kobj,
@@ -195,6 +201,17 @@ static inline void sysfs_remove_link(struct kobject *kobj, const char *name)
 	;
 }
 
+static inline int sysfs_rename_link(struct kobject * k, struct kobject *t,
+				    const char *old_name, const char * new_name)
+{
+	return 0;
+}
+
+static inline void sysfs_delete_link(struct kobject *k, struct kobject *t,
+				     const char *name)
+{
+}
+
 static inline int sysfs_create_group(struct kobject *kobj,
 				     const struct attribute_group *grp)
 {
-- 
1.5.3.rc6.17.g1911

