From: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
Subject: [PATCH 2/6] fs: Introduce special dentries for pipes, socket, anon
 fd
Date: Thu, 27 Nov 2008 00:31:40 +0100
Message-ID: <492DDC5C.1050602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050109080206090209000305"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	linux kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Christoph Lameter <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050109080206090209000305
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Sockets, pipes and anonymous fds have interesting properties.

Like other files, they use a dentry and an inode.

But dentries for these kind of files are not hashed into dcache,
since there is no way someone can lookup such a file in the vfs tree.
(/proc/{pid}/fd/{number} uses a different mechanism)

Still, allocating and freeing such dentries are expensive processes,
because we currently take dcache_lock inside d_alloc(), d_instantiate(),
and dput(). This lock is very contended on SMP machines.

This patch defines a new DCACHE_SPECIAL flag, to mark a dentry as
a special one (for sockets, pipes, anonymous fd), and a new
d_alloc_special(const struct qstr *name, struct inode *inode)
method, called by the three subsystems.

Internally, dput() can take a fast path to dput_special() for
special dentries, avoiding an expensive atomic_dec_and_lock()

Differences betwen a special dentry and a normal one are :

1) Special dentry has the DCACHE_SPECIAL flag
2) Special dentry's parent are themselves.
   This to avoid taking a reference on 'root' dentry, shared
   by too many dentries.
3) They are not hashed into global hash table
4) Their d_alias list is empty


(socket8 bench result : from 27.5s to 24s)


Signed-off-by: Eric Dumazet <dada1-fPLkHRcR87vqlBn2x/YWAg@public.gmane.org>
---
 fs/anon_inodes.c       |   16 ------------
 fs/dcache.c            |   51 +++++++++++++++++++++++++++++++++++++++
 fs/pipe.c              |   23 +----------------
 include/linux/dcache.h |    2 +
 net/socket.c           |   24 +-----------------
 5 files changed, 58 insertions(+), 58 deletions(-)

--------------050109080206090209000305
Content-Type: text/plain;
 name="special_dentries.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="special_dentries.patch"

diff --git a/fs/anon_inodes.c b/fs/anon_inodes.c
index 3662dd4..4f20d48 100644
--- a/fs/anon_inodes.c
+++ b/fs/anon_inodes.c
@@ -33,23 +33,12 @@ static int anon_inodefs_get_sb(struct file_system_type *fs_type, int flags,
 			     mnt);
 }
 
-static int anon_inodefs_delete_dentry(struct dentry *dentry)
-{
-	/*
-	 * We faked vfs to believe the dentry was hashed when we created it.
-	 * Now we restore the flag so that dput() will work correctly.
-	 */
-	dentry->d_flags |= DCACHE_UNHASHED;
-	return 1;
-}
-
 static struct file_system_type anon_inode_fs_type = {
 	.name		= "anon_inodefs",
 	.get_sb		= anon_inodefs_get_sb,
 	.kill_sb	= kill_anon_super,
 };
 static struct dentry_operations anon_inodefs_dentry_operations = {
-	.d_delete	= anon_inodefs_delete_dentry,
 };
 
 /**
@@ -92,7 +81,7 @@ int anon_inode_getfd(const char *name, const struct file_operations *fops,
 	this.name = name;
 	this.len = strlen(name);
 	this.hash = 0;
-	dentry = d_alloc(anon_inode_mnt->mnt_sb->s_root, &this);
+	dentry = d_alloc_special(&this, anon_inode_inode);
 	if (!dentry)
 		goto err_put_unused_fd;
 
@@ -104,9 +93,6 @@ int anon_inode_getfd(const char *name, const struct file_operations *fops,
 	atomic_inc(&anon_inode_inode->i_count);
 
 	dentry->d_op = &anon_inodefs_dentry_operations;
-	/* Do not publish this dentry inside the global dentry hash table */
-	dentry->d_flags &= ~DCACHE_UNHASHED;
-	d_instantiate(dentry, anon_inode_inode);
 
 	error = -ENFILE;
 	file = alloc_file(anon_inode_mnt, dentry,
diff --git a/fs/dcache.c b/fs/dcache.c
index 42ed9fc..d73763b 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -227,6 +227,23 @@ static struct dentry *d_kill(struct dentry *dentry)
  */
 
 /*
+ * special version of dput() for pipes/sockets/anon.
+ * These dentries are not present in hash table, we can avoid
+ * taking/dirtying dcache_lock
+ */
+static void dput_special(struct dentry *dentry)
+{
+	struct inode *inode;
+
+	if (!atomic_dec_and_test(&dentry->d_count))
+		return;
+	inode = dentry->d_inode;
+	if (inode)
+		iput(inode);
+	d_free(dentry);
+}
+
+/*
  * dput - release a dentry
  * @dentry: dentry to release 
  *
@@ -242,6 +259,11 @@ void dput(struct dentry *dentry)
 {
 	if (!dentry)
 		return;
+	/*
+	 * special dentries (sockets/pipes/anon) fast path
+	 */
+	if (dentry->d_flags & DCACHE_SPECIAL)
+		return dput_special(dentry);
 
 repeat:
 	if (atomic_read(&dentry->d_count) == 1)
@@ -1130,6 +1152,35 @@ struct dentry * d_alloc_root(struct inode * root_inode)
 	return res;
 }
 
+/**
+ * d_alloc_special - allocate special dentry
+ * @name: dentry name, given in a qstr structure
+ * @inode: inode to allocate the dentry for
+ *
+ * Allocate an special dentry for the inode given. The inode is
+ * instantiated and returned. %NULL is returned if there is insufficient
+ * memory.
+ * - Special dentries have themselves as a parent.
+ * - Special dentries are not hashed into global hash table
+ * - their d_alias list is empty
+ */
+struct dentry *d_alloc_special(const struct qstr *name, struct inode *inode)
+{
+	struct dentry *entry;
+
+	entry = d_alloc(NULL, name);
+	if (entry) {
+		entry->d_sb = inode->i_sb;
+		entry->d_parent = entry;
+		entry->d_flags |= DCACHE_SPECIAL | DCACHE_DISCONNECTED;
+		entry->d_inode = inode;
+		fsnotify_d_instantiate(entry, inode);
+		security_d_instantiate(entry, inode);
+	}
+	return entry;
+}
+
+
 static inline struct hlist_head *d_hash(struct dentry *parent,
 					unsigned long hash)
 {
diff --git a/fs/pipe.c b/fs/pipe.c
index 7aea8b8..5cc132a 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -849,17 +849,6 @@ void free_pipe_info(struct inode *inode)
 }
 
 static struct vfsmount *pipe_mnt __read_mostly;
-static int pipefs_delete_dentry(struct dentry *dentry)
-{
-	/*
-	 * At creation time, we pretended this dentry was hashed
-	 * (by clearing DCACHE_UNHASHED bit in d_flags)
-	 * At delete time, we restore the truth : not hashed.
-	 * (so that dput() can proceed correctly)
-	 */
-	dentry->d_flags |= DCACHE_UNHASHED;
-	return 0;
-}
 
 /*
  * pipefs_dname() is called from d_path().
@@ -871,7 +860,6 @@ static char *pipefs_dname(struct dentry *dentry, char *buffer, int buflen)
 }
 
 static struct dentry_operations pipefs_dentry_operations = {
-	.d_delete	= pipefs_delete_dentry,
 	.d_dname	= pipefs_dname,
 };
 
@@ -918,7 +906,7 @@ struct file *create_write_pipe(int flags)
 	struct inode *inode;
 	struct file *f;
 	struct dentry *dentry;
-	struct qstr name = { .name = "" };
+	static const struct qstr name = { .name = "" };
 
 	err = -ENFILE;
 	inode = get_pipe_inode();
@@ -926,18 +914,11 @@ struct file *create_write_pipe(int flags)
 		goto err;
 
 	err = -ENOMEM;
-	dentry = d_alloc(pipe_mnt->mnt_sb->s_root, &name);
+	dentry = d_alloc_special(&name, inode);
 	if (!dentry)
 		goto err_inode;
 
 	dentry->d_op = &pipefs_dentry_operations;
-	/*
-	 * We dont want to publish this dentry into global dentry hash table.
-	 * We pretend dentry is already hashed, by unsetting DCACHE_UNHASHED
-	 * This permits a working /proc/$pid/fd/XXX on pipes
-	 */
-	dentry->d_flags &= ~DCACHE_UNHASHED;
-	d_instantiate(dentry, inode);
 
 	err = -ENFILE;
 	f = alloc_file(pipe_mnt, dentry, FMODE_WRITE, &write_pipefifo_fops);
diff --git a/include/linux/dcache.h b/include/linux/dcache.h
index a37359d..fffdcf8 100644
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -176,6 +176,7 @@ d_iput:		no		no		no       yes
 #define DCACHE_UNHASHED		0x0010	
 
 #define DCACHE_INOTIFY_PARENT_WATCHED	0x0020 /* Parent inode is watched */
+#define DCACHE_SPECIAL		0x0040 /* socket, pipe or anonfs dentry */
 
 extern spinlock_t dcache_lock;
 extern seqlock_t rename_lock;
@@ -235,6 +236,7 @@ extern void shrink_dcache_sb(struct super_block *);
 extern void shrink_dcache_parent(struct dentry *);
 extern void shrink_dcache_for_umount(struct super_block *);
 extern int d_invalidate(struct dentry *);
+extern struct dentry *d_alloc_special(const struct qstr *, struct inode *);
 
 /* only used at mount-time */
 extern struct dentry * d_alloc_root(struct inode *);
diff --git a/net/socket.c b/net/socket.c
index e9d65ea..f41b6c6 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -307,18 +307,6 @@ static struct file_system_type sock_fs_type = {
 	.kill_sb =	kill_anon_super,
 };
 
-static int sockfs_delete_dentry(struct dentry *dentry)
-{
-	/*
-	 * At creation time, we pretended this dentry was hashed
-	 * (by clearing DCACHE_UNHASHED bit in d_flags)
-	 * At delete time, we restore the truth : not hashed.
-	 * (so that dput() can proceed correctly)
-	 */
-	dentry->d_flags |= DCACHE_UNHASHED;
-	return 0;
-}
-
 /*
  * sockfs_dname() is called from d_path().
  */
@@ -329,7 +317,6 @@ static char *sockfs_dname(struct dentry *dentry, char *buffer, int buflen)
 }
 
 static struct dentry_operations sockfs_dentry_operations = {
-	.d_delete = sockfs_delete_dentry,
 	.d_dname  = sockfs_dname,
 };
 
@@ -371,20 +358,13 @@ static int sock_alloc_fd(struct file **filep, int flags)
 static int sock_attach_fd(struct socket *sock, struct file *file, int flags)
 {
 	struct dentry *dentry;
-	struct qstr name = { .name = "" };
+	static const struct qstr name = { .name = "" };
 
-	dentry = d_alloc(sock_mnt->mnt_sb->s_root, &name);
+	dentry = d_alloc_special(&name, SOCK_INODE(sock));
 	if (unlikely(!dentry))
 		return -ENOMEM;
 
 	dentry->d_op = &sockfs_dentry_operations;
-	/*
-	 * We dont want to push this dentry into global dentry hash table.
-	 * We pretend dentry is already hashed, by unsetting DCACHE_UNHASHED
-	 * This permits a working /proc/$pid/fd/XXX on sockets
-	 */
-	dentry->d_flags &= ~DCACHE_UNHASHED;
-	d_instantiate(dentry, SOCK_INODE(sock));
 
 	sock->file = file;
 	init_file(file, sock_mnt, dentry, FMODE_READ | FMODE_WRITE,

--------------050109080206090209000305--
