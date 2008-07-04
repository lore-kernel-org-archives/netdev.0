From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 01/15] kobject: Cleanup kobject_rename and !CONFIG_SYSFS
Date: Thu, 03 Jul 2008 18:05:28 -0700
Message-ID: <m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
References: <20080618170729.808539948@theryb.frec.bull.fr>
	<20080618170731.002784342@theryb.frec.bull.fr>
	<485F04E1.70204@gmail.com> <m1y74svtff.fsf@frodo.ebiederm.org>
	<486706C9.9040303@gmail.com> <m18wwmsqdv.fsf@frodo.ebiederm.org>
	<4869D314.5030403@gmail.com> <m1ej6enep7.fsf@frodo.ebiederm.org>
	<486A0751.9080602@gmail.com> <m1wsk5hjm0.fsf@frodo.ebiederm.org>
	<486AF4FA.8020805@gmail.com> <m1ej6d9c2r.fsf@frodo.ebiederm.org>
	<486B060C.7030607@gmail.com> <m14p78s02q.fsf@frodo.ebiederm.org>
	<486C4515.1070007@gmail.com> <m1hcb7o8lv.fsf@frodo.ebiederm.org>
	<486CB051.5000507@fr.ibm.com> <m14p77m9uy.fsf@frodo.ebiederm.org>
	<486CF71F.5090405@gmail.com> <m1y74iiidz.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	<netdev@vger.kernel.org>
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:37112 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754334AbYGDBLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 21:11:46 -0400
In-Reply-To: <m1y74iiidz.fsf_-_@frodo.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 03 Jul 2008 17:48:40 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It finally dawned on me what the clean fix to sysfs_rename_dir
calling kobject_set_name is.  Move the work into kobject_rename
where it belongs.  The callers serialize us anyway so this is
safe.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/sysfs/dir.c        |    6 +-----
 include/linux/sysfs.h |    4 +---
 lib/kobject.c         |   17 +++++++++++++++--
 3 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/fs/sysfs/dir.c b/fs/sysfs/dir.c
index 8c0e4b9..146b86a 100644
--- a/fs/sysfs/dir.c
+++ b/fs/sysfs/dir.c
@@ -799,16 +799,12 @@ int sysfs_rename_dir(struct kobject * kobj, const char *new_name)
 	if (!new_dentry)
 		goto out_unlock;
 
-	/* rename kobject and sysfs_dirent */
+	/* rename sysfs_dirent */
 	error = -ENOMEM;
 	new_name = dup_name = kstrdup(new_name, GFP_KERNEL);
 	if (!new_name)
 		goto out_unlock;
 
-	error = kobject_set_name(kobj, "%s", new_name);
-	if (error)
-		goto out_unlock;
-
 	dup_name = sd->s_name;
 	sd->s_name = new_name;
 
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index 84d92bb..f7e43ed 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -20,8 +20,6 @@
 struct kobject;
 struct module;
 
-extern int kobject_set_name(struct kobject *kobj, const char *name, ...)
-			    __attribute__((format(printf, 2, 3)));
 /* FIXME
  * The *owner field is no longer used, but leave around
  * until the tree gets cleaned up fully.
@@ -140,7 +138,7 @@ static inline void sysfs_remove_dir(struct kobject *kobj)
 
 static inline int sysfs_rename_dir(struct kobject *kobj, const char *new_name)
 {
-	return kobject_set_name(kobj, "%s", new_name);
+	return 0;
 }
 
 static inline int sysfs_move_dir(struct kobject *kobj,
diff --git a/lib/kobject.c b/lib/kobject.c
index 829b839..49b3bc4 100644
--- a/lib/kobject.c
+++ b/lib/kobject.c
@@ -451,6 +451,7 @@ int kobject_rename(struct kobject *kobj, const char *new_name)
 {
 	int error = 0;
 	const char *devpath = NULL;
+	const char *dup_name = NULL, *name;
 	char *devpath_string = NULL;
 	char *envp[2];
 
@@ -474,15 +475,27 @@ int kobject_rename(struct kobject *kobj, const char *new_name)
 	envp[0] = devpath_string;
 	envp[1] = NULL;
 
+	name = dup_name = kstrdup(new_name, GFP_KERNEL);
+	if (!name) {
+		error = -ENOMEM;
+		goto out;
+	}
+
 	error = sysfs_rename_dir(kobj, new_name);
+	if (error)
+		goto out;
+
+	/* Install the new kobject name */
+	dup_name = kobj->name;
+	kobj->name = name;
 
 	/* This function is mostly/only used for network interface.
 	 * Some hotplug package track interfaces by their name and
 	 * therefore want to know when the name is changed by the user. */
-	if (!error)
-		kobject_uevent_env(kobj, KOBJ_MOVE, envp);
+	kobject_uevent_env(kobj, KOBJ_MOVE, envp);
 
 out:
+	kfree(dup_name);
 	kfree(devpath_string);
 	kfree(devpath);
 	kobject_put(kobj);
-- 
1.5.3.rc6.17.g1911

