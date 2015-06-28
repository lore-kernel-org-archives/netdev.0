From: Conrad Hoffmann <ch@bitfehler.net>
Subject: [PATCH RFC] net/unix: SO_REUSEPORT for AF_UNIX
Date: Sun, 28 Jun 2015 11:52:19 +0200
Message-ID: <1435485139-16866-1-git-send-email-ch@bitfehler.net>
Cc: Conrad Hoffmann <ch@bitfehler.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from osk4r.t3rror.net ([5.9.43.3]:33877 "EHLO mail.t3rror.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752167AbbF1KDt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Jun 2015 06:03:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support the SO_REUSEPORT option for AF_UNIX (aka AF_LOCAL) sockets. Note
that unlike the IP implementations, the semantics for AF_UNIX sockets are
those of the original BSD implementation, i.e. each socket that
successfully reuses a port completely takes over from the previous
listener.

The vast majority of software does an unlink() before bind() on UNIX
sockets. This also effectively takes over the socket from the previous
listener (given sufficient permissions), but leads to a short window of
time where connections are refused because the socket doesn't exist. One
can now achieve the same behaviour without dropping a single connection by
using SO_REUSEPORT and not calling unlink() before bind().

The restrictions on this are the same as for the IP implementation:
listening socket on the given path must exist, also have SO_REUSEPORT set
and have the same uid.

Signed-off-by: Conrad Hoffmann <ch@bitfehler.net>
---
 net/unix/af_unix.c | 31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 03ee4d3..ef57199 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -326,6 +326,29 @@ found:
 	return s;
 }
 
+static bool unix_port_reusable(struct sock *sk, const char *sun_path,
+			       struct path *path)
+{
+	struct sock *owner;
+	bool ret;
+
+	if (!sk->sk_reuseport)
+		return false;
+
+	if (kern_path(sun_path, LOOKUP_FOLLOW, path))
+		return false;
+
+	owner = unix_find_socket_byinode(d_backing_inode(path->dentry));
+	if (!owner)
+		return false;
+
+	ret = owner->sk_reuseport &&
+	      owner->sk_type == sk->sk_type &&
+	      uid_eq(sock_i_uid(sk), sock_i_uid(owner));
+	sock_put(owner);
+	return ret;
+}
+
 static inline int unix_writable(struct sock *sk)
 {
 	return (atomic_read(&sk->sk_wmem_alloc) << 2) <= sk->sk_sndbuf;
@@ -914,9 +937,13 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		umode_t mode = S_IFSOCK |
 		       (SOCK_INODE(sock)->i_mode & ~current_umask());
 		err = unix_mknod(sun_path, mode, &path);
-		if (err) {
-			if (err == -EEXIST)
+		if (err == -EEXIST) {
+			if (unix_port_reusable(sk, sun_path, &path))
+				err = 0;
+			else
 				err = -EADDRINUSE;
+		}
+		if (err) {
 			unix_release_addr(addr);
 			goto out_up;
 		}
-- 
2.4.4
