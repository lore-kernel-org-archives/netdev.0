From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 8/8] sysfs: user namespaces: fix bug with clone(CLONE_NEWUSER) with fairsched
Date: Wed, 20 Aug 2008 23:40:11 -0700
Message-ID: <m1myj6zx9w.fsf_-_@frodo.ebiederm.org>
References: <m1y74iiidz.fsf_-_@frodo.ebiederm.org>
	<m1tzf6ihlz.fsf_-_@frodo.ebiederm.org>
	<m1prpuihjb.fsf_-_@frodo.ebiederm.org>
	<m1lk0iihhp.fsf_-_@frodo.ebiederm.org>
	<m1hcb6ihfz.fsf_-_@frodo.ebiederm.org>
	<m1d4luihea.fsf_-_@frodo.ebiederm.org>
	<m18wwiihbn.fsf_-_@frodo.ebiederm.org>
	<m14p76ih9a.fsf_-_@frodo.ebiederm.org>
	<m1zloyh2mb.fsf_-_@frodo.ebiederm.org>
	<m1vdzmh2jr.fsf_-_@frodo.ebiederm.org>
	<20080820021754.GA25182@kroah.com>
	<m1od3m282j.fsf_-_@frodo.ebiederm.org>
	<m1hc9e27ya.fsf_-_@frodo.ebiederm.org>
	<m1d4k227wg.fsf_-_@frodo.ebiederm.org>
	<m18wuq27uj.fsf_-_@frodo.ebiederm.org>
	<m14p5e27tb.fsf_-_@frodo.ebiederm.org>
	<m1vdxuzxco.fsf_-_@frodo.ebiederm.org>
	<m1r68izxbi.fsf_-_@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Kroah-Hartman <gregkh@suse.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tejun Heo <htejun@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	linux-kernel@vger.kernel.org, Al Viro <viro@ftp.linux.org.uk>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>,
	netdev@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:60883 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174AbYHUGoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 02:44:06 -0400
In-Reply-To: <m1r68izxbi.fsf_-_@frodo.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 20 Aug 2008 23:39:13 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Serge Hallyn <serge@us.ibm.com>

Mark the /sys/kernel/uids directory to be tagged so that processes in
different user namespaces can remount /sys and see their own uid
listings.

Without this patch, having CONFIG_FAIR_SCHED=y makes user namespaces
unusable, because when you
  clone(CLONE_NEWUSER)
it will auto-create the root userid and try to create
/sys/kernel/uids/0.  Since that already exists from the parent user
namespace, the create fails, and the clone misleadingly ends up
returning -ENOMEM.

This patch fixes the issue by allowing each user namespace to remount
/sys, and having /sys filter the /sys/kernel/uid/ entries by user
namespace.

Changelong:
v2 - Reworked for the updated sysfs api

Signed-off-by: Serge Hallyn <serue@us.ibm.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/sched.h   |    1 +
 include/linux/sysfs.h   |    1 +
 kernel/user.c           |   22 ++++++++++++++++++++++
 kernel/user_namespace.c |    1 +
 4 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 5850bfb..b0fe15a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -600,6 +600,7 @@ struct user_struct {
 	/* Hash table maintenance information */
 	struct hlist_node uidhash_node;
 	uid_t uid;
+	struct user_namespace *user_ns;
 
 #ifdef CONFIG_USER_SCHED
 	struct task_group *tg;
diff --git a/include/linux/sysfs.h b/include/linux/sysfs.h
index 6d7eb50..ac88374 100644
--- a/include/linux/sysfs.h
+++ b/include/linux/sysfs.h
@@ -83,6 +83,7 @@ struct sysfs_dirent;
 enum sysfs_tag_type {
 	SYSFS_TAG_TYPE_NONE = 0,
 	SYSFS_TAG_TYPE_NETNS,
+	SYSFS_TAG_TYPE_USERNS,
 	SYSFS_TAG_TYPES
 };
 
diff --git a/kernel/user.c b/kernel/user.c
index 865ecf5..ca29fbc 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -53,6 +53,7 @@ struct user_struct root_user = {
 	.files		= ATOMIC_INIT(0),
 	.sigpending	= ATOMIC_INIT(0),
 	.locked_shm     = 0,
+	.user_ns	= &init_user_ns,
 #ifdef CONFIG_USER_SCHED
 	.tg		= &init_task_group,
 #endif
@@ -230,16 +231,33 @@ static struct attribute *uids_attributes[] = {
 	NULL
 };
 
+static const void *uids_mount_tag(void)
+{
+	return current->nsproxy->user_ns;
+}
+
+static struct sysfs_tag_type_operations uids_tag_type_operations = {
+	.mount_tag = uids_mount_tag,
+};
+
 /* the lifetime of user_struct is not managed by the core (now) */
 static void uids_release(struct kobject *kobj)
 {
 	return;
 }
 
+static const void *uids_sysfs_tag(struct kobject *kobj)
+{
+	struct user_struct *up;
+	up = container_of(kobj, struct user_struct, kobj);
+	return up->user_ns;
+}
+
 static struct kobj_type uids_ktype = {
 	.sysfs_ops = &kobj_sysfs_ops,
 	.default_attrs = uids_attributes,
 	.release = uids_release,
+	.sysfs_tag = uids_sysfs_tag,
 };
 
 /* create /sys/kernel/uids/<uid>/cpu_share file for this user */
@@ -272,6 +290,9 @@ int __init uids_sysfs_init(void)
 	if (!uids_kset)
 		return -ENOMEM;
 
+	sysfs_register_tag_type(SYSFS_TAG_TYPE_USERNS, &uids_tag_type_operations);
+	sysfs_make_tagged_dir(&uids_kset->kobj, SYSFS_TAG_TYPE_USERNS);
+
 	return uids_user_create(&root_user);
 }
 
@@ -405,6 +426,7 @@ struct user_struct *alloc_uid(struct user_namespace *ns, uid_t uid)
 
 		new->uid = uid;
 		atomic_set(&new->__count, 1);
+		new->user_ns = ns;
 
 		if (sched_create_user(new) < 0)
 			goto out_free_user;
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index a9ab059..f67bbe0 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -71,6 +71,7 @@ void free_user_ns(struct kref *kref)
 	struct user_namespace *ns;
 
 	ns = container_of(kref, struct user_namespace, kref);
+	sysfs_exit_tag(SYSFS_TAG_TYPE_USERNS, ns);
 	release_uids(ns);
 	kfree(ns);
 }
-- 
1.5.3.rc6.17.g1911

