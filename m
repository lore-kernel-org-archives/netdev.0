From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] af_unix: Fix splice-bind deadlock
Date: Sun, 03 Jan 2016 18:56:38 +0000
Message-ID: <87d1ti1ogp.fsf@doppelsaurus.mobileactivedefense.com>
References: <87y4cftztp.fsf@doppelsaurus.mobileactivedefense.com>
	<87vb7ak08l.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <dvyukov@google.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <viro@ZenIV.linux.org.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:35105 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751345AbcACS4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 13:56:51 -0500
In-Reply-To: <87vb7ak08l.fsf@doppelsaurus.mobileactivedefense.com> (Rainer
	Weikusat's message of "Sun, 03 Jan 2016 18:04:58 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015/11/06, Dmitry Vyukov reported a deadlock involving the splice
system call and AF_UNIX sockets, 

http://lists.openwall.net/netdev/2015/11/06/24

The situation was analyzed as

(a while ago) A: socketpair()
B: splice() from a pipe to /mnt/regular_file
	does sb_start_write() on /mnt
C: try to freeze /mnt
	wait for B to finish with /mnt
A: bind() try to bind our socket to /mnt/new_socket_name
	lock our socket, see it not bound yet
	decide that it needs to create something in /mnt
	try to do sb_start_write() on /mnt, block (it's
	waiting for C).
D: splice() from the same pipe to our socket
	lock the pipe, see that socket is connected
	try to lock the socket, block waiting for A
B:	get around to actually feeding a chunk from
	pipe to file, try to lock the pipe.  Deadlock.

on 2015/11/10 by Al Viro,

http://lists.openwall.net/netdev/2015/11/10/4

The patch fixes this by removing the kern_path_create related code from
unix_mknod and executing it as part of unix_bind prior acquiring the
readlock of the socket in question. This means that A (as used above)
will sb_start_write on /mnt before it acquires the readlock, hence, it
won't indirectly block B which first did a sb_start_write and then
waited for a thread trying to acquire the readlock. Consequently, A
being blocked by C waiting for B won't cause a deadlock anymore
(effectively, both A and B acquire two locks in opposite order in the
situation described above).

Dmitry Vyukov(<dvyukov@google.com>) tested the original patch.

Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
---

This fixes two 'wrong' error returns, namely, return -EADDRINUSE if
kern_path_create returned -EEXIST but delay returning an error from
kern_path_create until after the u->addr check as the -EINVAL should IMO
take precedence here.

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index b1314c0..e6d3556 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -953,32 +953,20 @@ fail:
 	return NULL;
 }
 
-static int unix_mknod(const char *sun_path, umode_t mode, struct path *res)
+static int unix_mknod(struct dentry *dentry, struct path *path, umode_t mode,
+		      struct path *res)
 {
-	struct dentry *dentry;
-	struct path path;
-	int err = 0;
-	/*
-	 * Get the parent directory, calculate the hash for last
-	 * component.
-	 */
-	dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
-	err = PTR_ERR(dentry);
-	if (IS_ERR(dentry))
-		return err;
+	int err;
 
-	/*
-	 * All right, let's create it.
-	 */
-	err = security_path_mknod(&path, dentry, mode, 0);
+	err = security_path_mknod(path, dentry, mode, 0);
 	if (!err) {
-		err = vfs_mknod(d_inode(path.dentry), dentry, mode, 0);
+		err = vfs_mknod(d_inode(path->dentry), dentry, mode, 0);
 		if (!err) {
-			res->mnt = mntget(path.mnt);
+			res->mnt = mntget(path->mnt);
 			res->dentry = dget(dentry);
 		}
 	}
-	done_path_create(&path, dentry);
+
 	return err;
 }
 
@@ -989,10 +977,12 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	struct unix_sock *u = unix_sk(sk);
 	struct sockaddr_un *sunaddr = (struct sockaddr_un *)uaddr;
 	char *sun_path = sunaddr->sun_path;
-	int err;
+	int err, name_err;
 	unsigned int hash;
 	struct unix_address *addr;
 	struct hlist_head *list;
+	struct path path;
+	struct dentry *dentry;
 
 	err = -EINVAL;
 	if (sunaddr->sun_family != AF_UNIX)
@@ -1008,14 +998,34 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	addr_len = err;
 
+	name_err = 0;
+	dentry = NULL;
+	if (sun_path[0]) {
+		/* Get the parent directory, calculate the hash for last
+		 * component.
+		 */
+		dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
+
+		if (IS_ERR(dentry)) {
+			/* delay report until after 'already bound' check */
+			name_err = PTR_ERR(dentry);
+			dentry = NULL;
+		}
+	}
+
 	err = mutex_lock_interruptible(&u->readlock);
 	if (err)
-		goto out;
+		goto out_path;
 
 	err = -EINVAL;
 	if (u->addr)
 		goto out_up;
 
+	if (name_err) {
+		err = name_err == -EEXIST ? -EADDRINUSE : name_err;
+		goto out_up;
+	}
+
 	err = -ENOMEM;
 	addr = kmalloc(sizeof(*addr)+addr_len, GFP_KERNEL);
 	if (!addr)
@@ -1026,11 +1036,11 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	addr->hash = hash ^ sk->sk_type;
 	atomic_set(&addr->refcnt, 1);
 
-	if (sun_path[0]) {
-		struct path path;
+	if (dentry) {
+		struct path u_path;
 		umode_t mode = S_IFSOCK |
 		       (SOCK_INODE(sock)->i_mode & ~current_umask());
-		err = unix_mknod(sun_path, mode, &path);
+		err = unix_mknod(dentry, &path, mode, &u_path);
 		if (err) {
 			if (err == -EEXIST)
 				err = -EADDRINUSE;
@@ -1038,9 +1048,9 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out_up;
 		}
 		addr->hash = UNIX_HASH_SIZE;
-		hash = d_backing_inode(path.dentry)->i_ino & (UNIX_HASH_SIZE-1);
+		hash = d_backing_inode(dentry)->i_ino & (UNIX_HASH_SIZE - 1);
 		spin_lock(&unix_table_lock);
-		u->path = path;
+		u->path = u_path;
 		list = &unix_socket_table[hash];
 	} else {
 		spin_lock(&unix_table_lock);
@@ -1063,6 +1073,10 @@ out_unlock:
 	spin_unlock(&unix_table_lock);
 out_up:
 	mutex_unlock(&u->readlock);
+out_path:
+	if (dentry)
+		done_path_create(&path, dentry);
+
 out:
 	return err;
 }
