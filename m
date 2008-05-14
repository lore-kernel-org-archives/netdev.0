From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] Fix kobject_rename and !CONFIG_SYSFS v4
Date: Tue, 13 May 2008 21:39:45 -0700
Message-ID: <m1hcd1a48e.fsf_-_@frodo.ebiederm.org>
References: <m163tocw43.fsf_-_@frodo.ebiederm.org>
	<20080512220232.GA16914@kroah.com> <m1prrqbseh.fsf@frodo.ebiederm.org>
	<4829A4BD.3020007@bull.net> <20080513164438.GA31563@kroah.com>
	<m18wyeay1q.fsf_-_@frodo.ebiederm.org>
	<20080513201602.GA31578@kroah.com>
	<m1od7a9bmr.fsf_-_@frodo.ebiederm.org>
	<24291087.1210713535895.JavaMail.oracle@acsmt301.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>, Al Viro <viro@ftp.linux.org.uk>,
	Benjamin Thery <benjamin.thery@bull.net>,
	Greg KH <gregkh@suse.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Daniel Lezcano <dlezcano@fr.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Serge E. Hallyn" <serue@us.ibm.com>, Tejun Heo <htejun@gmail.com>
To: Randy Dunlap <RANDY.DUNLAP@ORACLE.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:37122 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752233AbYENEuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 00:50:16 -0400
In-Reply-To: <24291087.1210713535895.JavaMail.oracle@acsmt301.oracle.com>
	(Randy Dunlap's message of "Tue, 13 May 2008 16:18:55 -0500 (CDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When looking at kobject_rename I found two bugs with
that exist when sysfs support is disabled in the kernel.

kobject_rename does not change the name on the kobject when
sysfs support is not compiled in.

kobject_rename without locking attempts to check the
validity of a rename operation, which the kobject layer
simply does not have the infrastructure to do.

This patch documents the previously unstated requirement of
kobject_rename that is the responsibility of the caller to
provide mutual exclusion and to be certain that the new_name
for the kobject is valid.

This patch modifies sysfs_rename_dir in !CONFIG_SYSFS case
to call kobject_set_name to actually change the kobject_name.

This patch removes the bogus and misleading check in kobject_rename
that attempts to see if a rename is valid.  The check is bogus
because we do not have the proper locking.  The check is misleading
because it looks like we can and do perform checking at the kobject
level that we don't.

Changelog:
v4:	Documentation typo fixes

v2:	Added a declaration of kboject_set_name to sysfs.h
	so the code actually compiles with !CONFIG_SYSFS.

	Unscrambling the header dependencies so everything looks
	beautiful is a project for another day.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 Documentation/kobject.txt |    4 ++++
 drivers/base/core.c       |    5 +++++
 include/linux/sysfs.h     |    4 +++-
 lib/kobject.c             |   18 +++++-------------
 4 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/Documentation/kobject.txt b/Documentation/kobject.txt
index bf3256e..ac80d82 100644
--- a/Documentation/kobject.txt
+++ b/Documentation/kobject.txt
@@ -118,6 +118,10 @@ the name of the kobject, call kobject_rename():
 
     int kobject_rename(struct kobject *kobj, const char *new_name);
 
+Note kobject_rename does not perform any locking or have a solid notion of
+what names are valid so the caller must provide their own sanity checking
+and serialization.
+
 There is a function called kobject_set_name() but that is legacy cruft and
 is being removed.  If your code needs to call this function, it is
 incorrect and needs to be fixed.
diff --git a/drivers/base/core.c b/drivers/base/core.c
index be288b5..ad68f4c 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -1171,6 +1171,11 @@ EXPORT_SYMBOL_GPL(device_destroy);
  * device_rename - renames a device
  * @dev: the pointer to the struct device to be renamed
  * @new_name: the new name of the device
+ *
+ * It is the responsibility of the caller to provide mutual
+ * exclusion between two different calls of device_rename
+ * on the same device to ensure that new_name is valid and
+ * won't conflict with other devices.
  */
 int device_rename(struct device *dev, char *new_name)
 {
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index 7858eac..6e61033 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -20,6 +20,8 @@
 struct kobject;
 struct module;
 
+extern int kobject_set_name(struct kobject *kobj, const char *name, ...)
+			    __attribute__((format(printf, 2, 3)));
 /* FIXME
  * The *owner field is no longer used, but leave around
  * until the tree gets cleaned up fully.
@@ -137,7 +139,7 @@ static inline void sysfs_remove_dir(struct kobject *kobj)
 
 static inline int sysfs_rename_dir(struct kobject *kobj, const char *new_name)
 {
-	return 0;
+	return kobject_set_name(kobj, "%s", new_name);
 }
 
 static inline int sysfs_move_dir(struct kobject *kobj,
diff --git a/lib/kobject.c b/lib/kobject.c
index 718e510..c7fb092 100644
--- a/lib/kobject.c
+++ b/lib/kobject.c
@@ -383,6 +383,11 @@ EXPORT_SYMBOL_GPL(kobject_init_and_add);
  * kobject_rename - change the name of an object
  * @kobj: object in question.
  * @new_name: object's new name
+ *
+ * It is the responsibility of the caller to provide mutual
+ * exclusion between two different calls of kobject_rename
+ * on the same kobject and to ensure that new_name is valid and
+ * won't conflict with other kobjects.
  */
 int kobject_rename(struct kobject *kobj, const char *new_name)
 {
@@ -397,19 +402,6 @@ int kobject_rename(struct kobject *kobj, const char *new_name)
 	if (!kobj->parent)
 		return -EINVAL;
 
-	/* see if this name is already in use */
-	if (kobj->kset) {
-		struct kobject *temp_kobj;
-		temp_kobj = kset_find_obj(kobj->kset, new_name);
-		if (temp_kobj) {
-			printk(KERN_WARNING "kobject '%s' cannot be renamed "
-			       "to '%s' as '%s' is already in existence.\n",
-			       kobject_name(kobj), new_name, new_name);
-			kobject_put(temp_kobj);
-			return -EINVAL;
-		}
-	}
-
 	devpath = kobject_get_path(kobj, GFP_KERNEL);
 	if (!devpath) {
 		error = -ENOMEM;
-- 
1.5.3.rc6.17.g1911

