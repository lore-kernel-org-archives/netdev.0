From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] af_unix: move unix_mknod() out of bindlock
Date: Mon, 23 Jan 2017 11:17:35 -0800
Message-ID: <1485199055-2342-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Al Viro <viro@zeniv.linux.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35562 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbdAWTRm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 14:17:42 -0500
Received: by mail-pg0-f67.google.com with SMTP id 204so14417518pge.2
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 11:17:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry reported a deadlock scenario:

unix_bind() path:
u->bindlock ==> sb_writer

do_splice() path:
sb_writer ==> pipe->mutex ==> u->bindlock

In the unix_bind() code path, unix_mknod() does not have to
be done with u->bindlock held, since it is a pure fs operation,
so we can just move unix_mknod() out.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Tested-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/unix/af_unix.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 127656e..cef7987 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -995,6 +995,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	unsigned int hash;
 	struct unix_address *addr;
 	struct hlist_head *list;
+	struct path path = { NULL, NULL };
 
 	err = -EINVAL;
 	if (sunaddr->sun_family != AF_UNIX)
@@ -1010,9 +1011,20 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	addr_len = err;
 
+	if (sun_path[0]) {
+		umode_t mode = S_IFSOCK |
+		       (SOCK_INODE(sock)->i_mode & ~current_umask());
+		err = unix_mknod(sun_path, mode, &path);
+		if (err) {
+			if (err == -EEXIST)
+				err = -EADDRINUSE;
+			goto out;
+		}
+	}
+
 	err = mutex_lock_interruptible(&u->bindlock);
 	if (err)
-		goto out;
+		goto out_put;
 
 	err = -EINVAL;
 	if (u->addr)
@@ -1029,16 +1041,6 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	atomic_set(&addr->refcnt, 1);
 
 	if (sun_path[0]) {
-		struct path path;
-		umode_t mode = S_IFSOCK |
-		       (SOCK_INODE(sock)->i_mode & ~current_umask());
-		err = unix_mknod(sun_path, mode, &path);
-		if (err) {
-			if (err == -EEXIST)
-				err = -EADDRINUSE;
-			unix_release_addr(addr);
-			goto out_up;
-		}
 		addr->hash = UNIX_HASH_SIZE;
 		hash = d_backing_inode(path.dentry)->i_ino & (UNIX_HASH_SIZE - 1);
 		spin_lock(&unix_table_lock);
@@ -1065,6 +1067,9 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	spin_unlock(&unix_table_lock);
 out_up:
 	mutex_unlock(&u->bindlock);
+out_put:
+	if (err)
+		path_put(&path);
 out:
 	return err;
 }
-- 
2.5.5
