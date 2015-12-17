From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] af_unix: Revert 'lock_interruptible' in stream receive code
Date: Thu, 17 Dec 2015 23:26:23 +0000
Message-ID: <871takk674.fsf@doppelsaurus.mobileactivedefense.com>
References: <877fke6tqi.fsf@doppelsaurus.mobileactivedefense.com>
	<56727EE9.5020805@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:49621 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751815AbbLQX0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 18:26:39 -0500
In-Reply-To: <56727EE9.5020805@stressinduktion.org> (Hannes Frederic Sowa's
	message of "Thu, 17 Dec 2015 10:22:49 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:

[...]

> There is still a deadlock lingering around

[...]

> http://lists.openwall.net/netdev/2015/11/10/4

Interesting problem. Assuming the description

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
           
	B: get around to actually feeding a chunk from
	   pipe to file, try to lock the pipe.

is correct, the sequence of events could be described as

Given
	a/b	- acquire a block b (eg, get read lock on superblock
                  rwsem)

	b/a	- acquire b block a

        c	- u->readlock

        d	- pipe lock

	[*y]   - blocks waiting for y

        
B	a/b

C	b/a[*B]

A	c
A	a/b[*C]

D	d
D	c[*A]

B	d[*D]

considering that C waits for B, the situation is A blocked by B, D
blocked by A, B blocked by D. This could be avoided by making
A do the a/b[*C] before acquiring c. D then wouldn't end up blocked
waiting for A and hence, B would complete after D completed, enabling C
to complete and finally, A. The present unix_mknod is

static int unix_mknod(const char *sun_path, umode_t mode, struct path *res)
{
        struct dentry *dentry;
        struct path path;
        int err = 0;
        /*
         * Get the parent directory, calculate the hash for last
         * component.
         */
        dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
        err = PTR_ERR(dentry);
        if (IS_ERR(dentry))
                return err;

        /*
         * All right, let's create it.
         */
        err = security_path_mknod(&path, dentry, mode, 0);
        if (!err) {
                err = vfs_mknod(d_inode(path.dentry), dentry, mode, 0);
                if (!err) {
                        res->mnt = mntget(path.mnt);
                        res->dentry = dget(dentry);
                }
        }
        done_path_create(&path, dentry);
        return err;
}

The a/b[*C] is a side-effect of the kern_path_create. unix_mknod is
called with u->readlock held because an already bound socket must not
be bound (binded?) again. As far as I understand the above, the actual
filesystem manipulation is performed by vfs_mknod. It should be possible
to split this function in two so that the sequence of 'bind events'
becomes

1. kern_path_create (acquires superblock rw sem)

2. lock u->readlock

3. already bound? yes goto 5

4. create directory entry

5. done_path_create ... / unlock u->readlock

Below is a patch changing the code as described. I've tested that
creating sockets with names in the filesystem still works but nothing
else (At least not systematically. My 'workstation' didn't blow up in
the 21 minutes I've been running the modified kernel on it).

---
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 1c3c1f3..ed3d380 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -953,32 +953,30 @@ fail:
 	return NULL;
 }
 
-static int unix_mknod(const char *sun_path, umode_t mode, struct path *res)
+static struct dentry *unix_path_create(const char *sun_path, struct path *path)
 {
-	struct dentry *dentry;
-	struct path path;
-	int err = 0;
 	/*
 	 * Get the parent directory, calculate the hash for last
 	 * component.
 	 */
-	dentry = kern_path_create(AT_FDCWD, sun_path, &path, 0);
-	err = PTR_ERR(dentry);
-	if (IS_ERR(dentry))
-		return err;
 
-	/*
-	 * All right, let's create it.
-	 */
-	err = security_path_mknod(&path, dentry, mode, 0);
+	return kern_path_create(AT_FDCWD, sun_path, path, 0);
+}
+
+static int unix_mknod(struct dentry *dentry, struct path *path, umode_t mode,
+		      struct path *res)
+{
+	int err;
+
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
 
@@ -993,6 +991,8 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	unsigned int hash;
 	struct unix_address *addr;
 	struct hlist_head *list;
+	struct path parent_path;
+	struct dentry *parent;
 
 	err = -EINVAL;
 	if (sunaddr->sun_family != AF_UNIX)
@@ -1008,9 +1008,18 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	addr_len = err;
 
+	parent = NULL;
+	if (sun_path[0]) {
+		parent = unix_path_create(sun_path, &parent_path);
+
+		err = PTR_ERR(parent);
+		if (IS_ERR(parent))
+			goto out;
+	}
+
 	err = mutex_lock_interruptible(&u->readlock);
 	if (err)
-		goto out;
+		goto out_parent;
 
 	err = -EINVAL;
 	if (u->addr)
@@ -1026,11 +1035,11 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	addr->hash = hash ^ sk->sk_type;
 	atomic_set(&addr->refcnt, 1);
 
-	if (sun_path[0]) {
+	if (parent) {
 		struct path path;
 		umode_t mode = S_IFSOCK |
 		       (SOCK_INODE(sock)->i_mode & ~current_umask());
-		err = unix_mknod(sun_path, mode, &path);
+		err = unix_mknod(parent, &parent_path, mode, &path);
 		if (err) {
 			if (err == -EEXIST)
 				err = -EADDRINUSE;
@@ -1063,6 +1072,10 @@ out_unlock:
 	spin_unlock(&unix_table_lock);
 out_up:
 	mutex_unlock(&u->readlock);
+out_parent:
+	if (parent)
+		done_path_create(&parent_path, parent);
+
 out:
 	return err;
 }
