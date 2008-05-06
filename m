From: Ulrich Drepper <drepper@redhat.com>
Subject: [PATCH 03/18] flag parameters: anon_inode_getfd extension
Date: Tue, 6 May 2008 17:18:07 -0400
Message-ID: <200805062118.m46LI7E0004043@devserv.devel.redhat.com>
Cc: akpm@linux-foundation.org, davidel@xmailserver.org,
	mtk.manpages@gmail.com, torvalds@linux-foundation.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48564 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933060AbYEFVSm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 17:18:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch just extends the anon_inode_getfd interface to take an additional
parameter with a flag value.  The flag value is passed on to
get_unused_fd_flags in anticipation for a use with the O_CLOEXEC flag.

No actual semantic changes here, the changed callers all pass 0 for now.

 fs/anon_inodes.c            |    9 +++++----
 fs/eventfd.c                |    2 +-
 fs/eventpoll.c              |    2 +-
 fs/signalfd.c               |    3 ++-
 fs/timerfd.c                |    2 +-
 include/linux/anon_inodes.h |    2 +-
 6 files changed, 11 insertions(+), 9 deletions(-)


Signed-off-by: Ulrich Drepper <drepper@redhat.com>

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 977ef20..3662dd4 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -58,8 +58,9 @@ static struct dentry_operations anon_inodefs_dentry_operations = {
  *                    of the file
  *
  * @name:    [in]    name of the "class" of the new file
- * @fops     [in]    file operations for the new file
- * @priv     [in]    private data for the new file (will be file's private_data)
+ * @fops:    [in]    file operations for the new file
+ * @priv:    [in]    private data for the new file (will be file's private_data)
+ * @flags:   [in]    flags
  *
  * Creates a new file by hooking it on a single inode. This is useful for files
  * that do not need to have a full-fledged inode in order to operate correctly.
@@ -68,7 +69,7 @@ static struct dentry_operations anon_inodefs_dentry_operations = {
  * setup.  Returns new descriptor or -error.
  */
 int anon_inode_getfd(const char *name, const struct file_operations *fops,
-		     void *priv)
+		     void *priv, int flags)
 {
 	struct qstr this;
 	struct dentry *dentry;
@@ -78,7 +79,7 @@ int anon_inode_getfd(const char *name, const struct file_operations *fops,
 	if (IS_ERR(anon_inode_inode))
 		return -ENODEV;
 
-	error = get_unused_fd();
+	error = get_unused_fd_flags(flags);
 	if (error < 0)
 		return error;
 	fd = error;
diff --git a/fs/eventfd.c b/fs/eventfd.c
index 343942d..ddb543d 100644
--- a/fs/eventfd.c
+++ b/fs/eventfd.c
@@ -214,7 +214,7 @@ asmlinkage long sys_eventfd(unsigned int count)
 	 * When we call this, the initialization must be complete, since
 	 * anon_inode_getfd() will install the fd.
 	 */
-	fd = anon_inode_getfd("[eventfd]", &eventfd_fops, ctx);
+	fd = anon_inode_getfd("[eventfd]", &eventfd_fops, ctx, 0);
 	if (fd < 0)
 		kfree(ctx);
 	return fd;
diff --git a/fs/eventpoll.c b/fs/eventpoll.c
index 990c01d..7714e91 100644
--- a/fs/eventpoll.c
+++ b/fs/eventpoll.c
@@ -1068,7 +1068,7 @@ asmlinkage long sys_epoll_create(int size)
 	 * Creates all the items needed to setup an eventpoll file. That is,
 	 * a file structure and a free file descriptor.
 	 */
-	fd = anon_inode_getfd("[eventpoll]", &eventpoll_fops, ep);
+	fd = anon_inode_getfd("[eventpoll]", &eventpoll_fops, ep, 0);
 	if (fd < 0)
 		ep_free(ep);
 
diff --git a/fs/signalfd.c b/fs/signalfd.c
index 6197256..a73333b 100644
--- a/fs/signalfd.c
+++ b/fs/signalfd.c
@@ -227,7 +227,8 @@ asmlinkage long sys_signalfd(int ufd, sigset_t __user *user_mask, size_t sizemas
 		 * When we call this, the initialization must be complete, since
 		 * anon_inode_getfd() will install the fd.
 		 */
-		ufd = anon_inode_getfd("[signalfd]", &signalfd_fops, ctx);
+		ufd = anon_inode_getfd("[signalfd]", &signalfd_fops, ctx,
+				       0);
 		if (ufd < 0)
 			kfree(ctx);
 	} else {
diff --git a/fs/timerfd.c b/fs/timerfd.c
index d87d354..f998991 100644
--- a/fs/timerfd.c
+++ b/fs/timerfd.c
@@ -198,7 +198,7 @@ asmlinkage long sys_timerfd_create(int clockid, int flags)
 	ctx->clockid = clockid;
 	hrtimer_init(&ctx->tmr, clockid, HRTIMER_MODE_ABS);
 
-	ufd = anon_inode_getfd("[timerfd]", &timerfd_fops, ctx);
+	ufd = anon_inode_getfd("[timerfd]", &timerfd_fops, ctx, 0);
 	if (ufd < 0)
 		kfree(ctx);
 
diff --git a/include/linux/anon_inodes.h b/include/linux/anon_inodes.h
index 6129e58..e0a0cdc 100644
--- a/include/linux/anon_inodes.h
+++ b/include/linux/anon_inodes.h
@@ -9,7 +9,7 @@
 #define _LINUX_ANON_INODES_H
 
 int anon_inode_getfd(const char *name, const struct file_operations *fops,
-		     void *priv);
+		     void *priv, int flags);
 
 #endif /* _LINUX_ANON_INODES_H */
 
