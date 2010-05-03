From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH] Comment sysfs directory tagging
Date: Mon, 3 May 2010 16:23:15 -0500
Message-ID: <20100503212315.GA4141@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>, bcrl@lhnet.ca,
	benjamin.thery@bull.net, cornelia.huck@de.ibm.com,
	eric.dumazet@gmail.com, kay.sievers@vrfy.org,
	netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:41865 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755862Ab0ECVXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 17:23:22 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o43LDWDI029359
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 15:13:32 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o43LNL32264624
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 15:23:21 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o43LNGOx016051
	for <netdev@vger.kernel.org>; Mon, 3 May 2010 15:23:18 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(against gregkh-2.6)

Add some in-line comments to explain the new infrastructure, which
was introduced to support sysfs directory tagging with namespaces.
I think an overall description someplace might be good too, but it
didn't really seem to fit into Documentation/filesystems/sysfs.txt,
which appears more geared toward users, rather than maintainers, of
sysfs.

(Tejun, please let me know if I can make anything clearer or failed
altogether to comment something that should be commented.)

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 fs/sysfs/dir.c          |    8 ++++++++
 fs/sysfs/sysfs.h        |   13 ++++++++++++-
 include/linux/kobject.h |   11 +++++++++++
 include/linux/sysfs.h   |    1 +
 lib/kobject.c           |   11 +++++++++++
 5 files changed, 43 insertions(+), 1 deletion(-)

diff -Nrup --exclude=.pc linux.orig/fs/sysfs/dir.c linux/fs/sysfs/dir.c
--- linux.orig/fs/sysfs/dir.c	2010-05-03 15:10:29.000000000 -0400
+++ linux/fs/sysfs/dir.c	2010-05-03 16:37:12.000000000 -0400
@@ -614,6 +614,14 @@ int sysfs_create_subdir(struct kobject *
 			  KOBJ_NS_TYPE_NONE, NULL, name, p_sd);
 }
 
+/**
+ *	sysfs_read_ns_type: return associated ns_type
+ *	@kobj: the kobject being queried
+ *
+ *	Each kobject can be tagged with exactly one namespace type
+ *	(i.e. network or user).  Return the ns_type associated with
+ *	this object if any
+ */
 static enum kobj_ns_type sysfs_read_ns_type(struct kobject *kobj)
 {
 	const struct kobj_ns_type_operations *ops;
diff -Nrup --exclude=.pc linux.orig/fs/sysfs/sysfs.h linux/fs/sysfs/sysfs.h
--- linux.orig/fs/sysfs/sysfs.h	2010-05-03 15:10:29.000000000 -0400
+++ linux/fs/sysfs/sysfs.h	2010-05-03 16:43:06.000000000 -0400
@@ -58,7 +58,7 @@ struct sysfs_dirent {
 	struct sysfs_dirent	*s_sibling;
 	const char		*s_name;
 
-	const void		*s_ns;
+	const void		*s_ns; /* namespace tag */
 	union {
 		struct sysfs_elem_dir		s_dir;
 		struct sysfs_elem_symlink	s_symlink;
@@ -82,6 +82,7 @@ struct sysfs_dirent {
 #define SYSFS_COPY_NAME			(SYSFS_DIR | SYSFS_KOBJ_LINK)
 #define SYSFS_ACTIVE_REF		(SYSFS_KOBJ_ATTR | SYSFS_KOBJ_BIN_ATTR)
 
+/* identify any namespace tag on sysfs_dirents */
 #define SYSFS_NS_TYPE_MASK		0xff00
 #define SYSFS_NS_TYPE_SHIFT		8
 
@@ -93,6 +94,10 @@ static inline unsigned int sysfs_type(st
 	return sd->s_flags & SYSFS_TYPE_MASK;
 }
 
+/*
+ * Return any namespace tags on this dirent.
+ * enum kobj_ns_type is defined in linux/kobject.h
+ */
 static inline enum kobj_ns_type sysfs_ns_type(struct sysfs_dirent *sd)
 {
 	return (sd->s_flags & SYSFS_NS_TYPE_MASK) >> SYSFS_NS_TYPE_SHIFT;
@@ -123,6 +128,12 @@ struct sysfs_addrm_cxt {
 /*
  * mount.c
  */
+
+/*
+ * Each sb is associated with a set of namespace tags (i.e.
+ * the network namespace of the task which mounted this sysfs
+ * instance).
+ */
 struct sysfs_super_info {
 	const void *ns[KOBJ_NS_TYPES];
 };
diff -Nrup --exclude=.pc linux.orig/include/linux/kobject.h linux/include/linux/kobject.h
--- linux.orig/include/linux/kobject.h	2010-05-03 15:10:29.000000000 -0400
+++ linux/include/linux/kobject.h	2010-05-03 16:43:50.000000000 -0400
@@ -136,12 +136,23 @@ struct kobj_attribute {
 
 extern const struct sysfs_ops kobj_sysfs_ops;
 
+/*
+ * Namespace types which are used to tag kobjects and sysfs entries.
+ * Network namespace will likely be the first.
+ */
 enum kobj_ns_type {
 	KOBJ_NS_TYPE_NONE = 0,
 	KOBJ_NS_TYPES
 };
 
 struct sock;
+
+/*
+ * Callbacks so sysfs can determine namespaces
+ *   @current_ns: return calling task's namespace
+ *   @netlink_ns: return namespace to which a sock belongs (right?)
+ *   @initial_ns: return the initial namespace (i.e. init_net_ns)
+ */
 struct kobj_ns_type_operations {
 	enum kobj_ns_type type;
 	const void *(*current_ns)(void);
diff -Nrup --exclude=.pc linux.orig/include/linux/sysfs.h linux/include/linux/sysfs.h
--- linux.orig/include/linux/sysfs.h	2010-05-03 15:10:29.000000000 -0400
+++ linux/include/linux/sysfs.h	2010-05-03 15:51:41.000000000 -0400
@@ -178,6 +178,7 @@ struct sysfs_dirent *sysfs_get(struct sy
 void sysfs_put(struct sysfs_dirent *sd);
 void sysfs_printk_last_file(void);
 
+/* Called to clear a ns tag when it is no longer valid */
 void sysfs_exit_ns(enum kobj_ns_type type, const void *tag);
 
 int __must_check sysfs_init(void);
diff -Nrup --exclude=.pc linux.orig/lib/kobject.c linux/lib/kobject.c
--- linux.orig/lib/kobject.c	2010-05-03 15:10:29.000000000 -0400
+++ linux/lib/kobject.c	2010-05-03 16:47:01.000000000 -0400
@@ -948,6 +948,17 @@ const void *kobj_ns_initial(enum kobj_ns
 	return ns;
 }
 
+/*
+ * kobj_ns_exit - invalidate a namespace tag
+ *
+ * @type: the namespace type (i.e. KOBJ_NS_TYPE_NET)
+ * @ns: the actual namespace being invalidated
+ *
+ * This is called when a tag is no longer valid.  For instance,
+ * when a network namespace exits, it uses this helper to
+ * make sure no sb's sysfs_info points to the now-invalidated
+ * netns.
+ */
 void kobj_ns_exit(enum kobj_ns_type type, const void *ns)
 {
 	sysfs_exit_ns(type, ns);
