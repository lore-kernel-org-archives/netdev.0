From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH 10/11] avoid kobject name conflict with different namespaces
Date: Tue, 06 May 2008 19:32:10 +0200
Message-ID: <20080506173335.922289888@theryb.frec.bull.fr>
References: <20080506173030.653828076@theryb.frec.bull.fr>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Tejun Heo <htejun@gmail.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Al Viro <viro@ftp.linux.org.uk>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	"Serge E. Hallyn" <serue@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org,
	Benjamin Thery <benjamin.thery@bull.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:50286 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764980AbYEFRiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 13:38:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The renaming of a kobject will fail if there is another kobject
with the same name belonging to another namespace.

This patch makes the kobject lookup in kobject_rename to check if
the object exists _and_ belongs to the same namespace.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Acked-by: Benjamin Thery <benjamin.thery@bull.net>
---
 fs/sysfs/dir.c        |   10 ++++++++++
 include/linux/sysfs.h |    7 +++++++
 lib/kobject.c         |    2 +-
 3 files changed, 18 insertions(+), 1 deletion(-)

Index: linux-vanilla/fs/sysfs/dir.c
===================================================================
--- linux-vanilla.orig/fs/sysfs/dir.c
+++ linux-vanilla/fs/sysfs/dir.c
@@ -902,6 +902,16 @@ err_out:
 	return error;
 }
 
+int sysfs_tag_cmp(struct kobject *kobj1, struct kobject *kobj2)
+{
+	struct sysfs_dirent *sd1 = kobj1->sd;
+	struct sysfs_dirent *sd2 = kobj2->sd;
+	const void *tag1 = sysfs_dirent_tag(sd1);
+	const void *tag2 = sysfs_dirent_tag(sd2);
+
+	return tag1 != tag2;
+}
+
 int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
 {
 	struct sysfs_dirent *sd = kobj->sd;
Index: linux-vanilla/include/linux/sysfs.h
===================================================================
--- linux-vanilla.orig/include/linux/sysfs.h
+++ linux-vanilla/include/linux/sysfs.h
@@ -95,6 +95,8 @@ int sysfs_schedule_callback(struct kobje
 
 int __must_check sysfs_create_dir(struct kobject *kobj);
 void sysfs_remove_dir(struct kobject *kobj);
+int sysfs_tag_cmp(struct kobject *kobj1, struct kobject *kobj2);
+
 int __must_check sysfs_rename_dir(struct kobject *kobj, const char *new_name);
 int __must_check sysfs_move_dir(struct kobject *kobj,
 				struct kobject *new_parent_kobj);
@@ -154,6 +156,11 @@ static inline void sysfs_remove_dir(stru
 {
 }
 
+static inline int sysfs_tag_cmp(struct kobject *kobj1, struct kobject *kobj2)
+{
+	return 0;
+}
+
 static inline int sysfs_rename_dir(struct kobject *kobj, const char *new_name)
 {
 	return 0;
Index: linux-vanilla/lib/kobject.c
===================================================================
--- linux-vanilla.orig/lib/kobject.c
+++ linux-vanilla/lib/kobject.c
@@ -401,7 +401,7 @@ int kobject_rename(struct kobject *kobj,
 	if (kobj->kset) {
 		struct kobject *temp_kobj;
 		temp_kobj = kset_find_obj(kobj->kset, new_name);
-		if (temp_kobj) {
+		if (temp_kobj && !sysfs_tag_cmp(temp_kobj, kobj)) {
 			printk(KERN_WARNING "kobject '%s' cannot be renamed "
 			       "to '%s' as '%s' is already in existence.\n",
 			       kobject_name(kobj), new_name, new_name);

-- 
