From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH 1/2] Revert "af_unix: Fix splice-bind deadlock"
Date: Fri, 2 Sep 2016 11:09:23 -0700 (PDT)
Message-ID: <alpine.LFD.2.20.1609021106060.4039@i7>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Eric Dumazet <edumazet@google.com>, willy tarreau <w@1wt.eu>,
        netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:32958 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751845AbcIBSJ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 14:09:26 -0400
Received: by mail-pa0-f68.google.com with SMTP id vy10so5814905pac.0
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 11:09:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 1 Sep 2016 14:56:49 -0700
Subject: [PATCH 1/2] Revert "af_unix: Fix splice-bind deadlock"

This reverts commit c845acb324aa85a39650a14e7696982ceea75dc1.

It turns out that it just replaces one deadlock with another one: we can
still get the wrong lock ordering with the readlock due to overlayfs
calling back into the filesystem layer and still taking the vfs locks
after the readlock.

The proper solution ends up being to just split the readlock into two
pieces: the bind lock (taken *outside* the vfs locks) and the IO lock
(taken *inside* the filesystem locks).  The two locks are independent
anyway.

Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---

This is not a completely clean revert, because other changes had happened 
in this area since that commit, but the conflicts were pretty trivial.

The next patch actually fixes the problem as described above ("proper 
solution").

Also, David, if you'd prefer I just apply these directly, you can just 
tell me so. But I really wanted some AF_UNIX people to look at the next 
patch regardless.

 net/unix/af_unix.c | 66 +++++++++++++++++++++---------------------------------
 1 file changed, 26 insertions(+), 40 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f1dffe84f0d5..433ae1bbef97 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -954,20 +954,32 @@ fail:
 	return NULL;
 }
 
-static int unix_mknod(struct dentry *dentry, const struct path *path, umode_t mode,
-		      struct path *res)
+static int unix_mknod(const char *sun_path, umode_t mode, struct path *res)
 {
-	int err;
+	struct dentry *dentry;
+	struct path path;
+	int err = 0;
+	/*
+	 * Get the parent directory, calculate the hash for last
+	 * component.
+	 */
+	dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
+	err = PTR_ERR(dentry);
+	if (IS_ERR(dentry))
+		return err;
 
-	err = security_path_mknod(path, dentry, mode, 0);
+	/*
+	 * All right, let's create it.
+	 */
+	err = security_path_mknod(&path, dentry, mode, 0);
 	if (!err) {
-		err = vfs_mknod(d_inode(path->dentry), dentry, mode, 0);
+		err = vfs_mknod(d_inode(path.dentry), dentry, mode, 0);
 		if (!err) {
-			res->mnt = mntget(path->mnt);
+			res->mnt = mntget(path.mnt);
 			res->dentry = dget(dentry);
 		}
 	}
-
+	done_path_create(&path, dentry);
 	return err;
 }
 
@@ -978,12 +990,10 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct unix_sock *u = unix_sk(sk);
 	struct sockaddr_un *sunaddr = (struct sockaddr_un *)uaddr;
 	char *sun_path = sunaddr->sun_path;
-	int err, name_err;
+	int err;
 	unsigned int hash;
 	struct unix_address *addr;
 	struct hlist_head *list;
-	struct path path;
-	struct dentry *dentry;
 
 	err = -EINVAL;
 	if (sunaddr->sun_family != AF_UNIX)
@@ -999,34 +1009,14 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	addr_len = err;
 
-	name_err = 0;
-	dentry = NULL;
-	if (sun_path[0]) {
-		/* Get the parent directory, calculate the hash for last
-		 * component.
-		 */
-		dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
-
-		if (IS_ERR(dentry)) {
-			/* delay report until after 'already bound' check */
-			name_err = PTR_ERR(dentry);
-			dentry = NULL;
-		}
-	}
-
 	err = mutex_lock_interruptible(&u->readlock);
 	if (err)
-		goto out_path;
+		goto out;
 
 	err = -EINVAL;
 	if (u->addr)
 		goto out_up;
 
-	if (name_err) {
-		err = name_err == -EEXIST ? -EADDRINUSE : name_err;
-		goto out_up;
-	}
-
 	err = -ENOMEM;
 	addr = kmalloc(sizeof(*addr)+addr_len, GFP_KERNEL);
 	if (!addr)
@@ -1037,11 +1027,11 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	addr->hash = hash ^ sk->sk_type;
 	atomic_set(&addr->refcnt, 1);
 
-	if (dentry) {
-		struct path u_path;
+	if (sun_path[0]) {
+		struct path path;
 		umode_t mode = S_IFSOCK |
 		       (SOCK_INODE(sock)->i_mode & ~current_umask());
-		err = unix_mknod(dentry, &path, mode, &u_path);
+		err = unix_mknod(sun_path, mode, &path);
 		if (err) {
 			if (err == -EEXIST)
 				err = -EADDRINUSE;
@@ -1049,9 +1039,9 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out_up;
 		}
 		addr->hash = UNIX_HASH_SIZE;
-		hash = d_real_inode(dentry)->i_ino & (UNIX_HASH_SIZE - 1);
+		hash = d_real_inode(path.dentry)->i_ino & (UNIX_HASH_SIZE - 1);
 		spin_lock(&unix_table_lock);
-		u->path = u_path;
+		u->path = path;
 		list = &unix_socket_table[hash];
 	} else {
 		spin_lock(&unix_table_lock);
@@ -1074,10 +1064,6 @@ out_unlock:
 	spin_unlock(&unix_table_lock);
 out_up:
 	mutex_unlock(&u->readlock);
-out_path:
-	if (dentry)
-		done_path_create(&path, dentry);
-
 out:
 	return err;
 }
-- 
2.10.0.rc0.2.g0a9fa47
