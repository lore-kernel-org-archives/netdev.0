From: Andrei Vagin <avagin@openvz.org>
Subject: [PATCH net-next] unix: add ioctl to open a unix socket file with O_PATH
Date: Wed,  1 Feb 2017 11:00:45 -0800
Message-ID: <1485975645-8437-1-git-send-email-avagin@openvz.org>
Cc: netdev@vger.kernel.org, criu@openvz.org,
        Andrei Vagin <avagin@openvz.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:32903 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751029AbdBATAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 14:00:51 -0500
Received: by mail-pf0-f196.google.com with SMTP id e4so32324399pfg.0
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 11:00:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ioctl opens a file to which a socket is bound and
returns a file descriptor. The caller has to have CAP_NET_ADMIN
in the socket network namespace.

Currently it is impossible to get a path and a mount point
for a socket file. socket_diag reports address, device ID and inode
number for unix sockets. An address can contain a relative path or
a file may be moved somewhere. And these properties say nothing about
a mount namespace and a mount point of a socket file.

With the introduced ioctl, we can get a path by reading
/proc/self/fd/X and get mnt_id from /proc/self/fdinfo/X.

In CRIU we are going to use this ioctl to dump and restore unix socket.

Here is an example how it can be used:

$ strace -e socket,bind,ioctl ./test /tmp/test_sock
socket(AF_UNIX, SOCK_STREAM, 0)         = 3
bind(3, {sa_family=AF_UNIX, sun_path="test_sock"}, 11) = 0
ioctl(3, SIOCUNIXFILE, 0)           = 4
^Z

$ ss -a | grep test_sock
u_str  LISTEN     0      1      test_sock 17798                 * 0

$ ls -l /proc/760/fd/{3,4}
lrwx------ 1 root root 64 Feb  1 09:41 3 -> 'socket:[17798]'
l--------- 1 root root 64 Feb  1 09:41 4 -> /tmp/test_sock

$ cat /proc/760/fdinfo/4
pos:	0
flags:	012000000
mnt_id:	40

$ cat /proc/self/mountinfo | grep "^40\s"
40 19 0:37 / /tmp rw shared:23 - tmpfs tmpfs rw

Signed-off-by: Andrei Vagin <avagin@openvz.org>
---
 include/uapi/linux/un.h |  2 ++
 net/unix/af_unix.c      | 41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

diff --git a/include/uapi/linux/un.h b/include/uapi/linux/un.h
index 3ed3e46..4f0ab3a 100644
--- a/include/uapi/linux/un.h
+++ b/include/uapi/linux/un.h
@@ -10,4 +10,6 @@ struct sockaddr_un {
 	char sun_path[UNIX_PATH_MAX];	/* pathname */
 };
 
+#define SIOCUNIXFILE (SIOCPROTOPRIVATE + 0) /* open a socket file with O_PATH */
+
 #endif /* _LINUX_UN_H */
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index cef7987..e2d18b9 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -117,6 +117,7 @@
 #include <net/checksum.h>
 #include <linux/security.h>
 #include <linux/freezer.h>
+#include <linux/file.h>
 
 struct hlist_head unix_socket_table[2 * UNIX_HASH_SIZE];
 EXPORT_SYMBOL_GPL(unix_socket_table);
@@ -2592,6 +2593,43 @@ long unix_outq_len(struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(unix_outq_len);
 
+static int unix_open_file(struct sock *sk)
+{
+	struct path path;
+	struct file *f;
+	int fd;
+
+	if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
+		return -EPERM;
+
+	unix_state_lock(sk);
+	path = unix_sk(sk)->path;
+	if (!path.dentry) {
+		unix_state_unlock(sk);
+		return -ENOENT;
+	}
+
+	path_get(&path);
+	unix_state_unlock(sk);
+
+	fd = get_unused_fd_flags(O_CLOEXEC);
+	if (fd < 0)
+		goto out;
+
+	f = dentry_open(&path, O_PATH, current_cred());
+	if (IS_ERR(f)) {
+		put_unused_fd(fd);
+		fd = PTR_ERR(f);
+		goto out;
+	}
+
+	fd_install(fd, f);
+out:
+	path_put(&path);
+
+	return fd;
+}
+
 static int unix_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 {
 	struct sock *sk = sock->sk;
@@ -2610,6 +2648,9 @@ static int unix_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
 		else
 			err = put_user(amount, (int __user *)arg);
 		break;
+	case SIOCUNIXFILE:
+		err = unix_open_file(sk);
+		break;
 	default:
 		err = -ENOIOCTLCMD;
 		break;
-- 
2.7.4
