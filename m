From: Jeff Hansen <x@jeffhansen.com>
Subject: [PATCH] net/unix: Allow Unix sockets to be treated like normal files.
Date: Mon, 25 Oct 2010 04:35:44 +0000
Message-ID: <1287981344-23828-1-git-send-email-x@jeffhansen.com>
Cc: x@jeffhansen.com, Dave Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48660 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949Ab0JYEfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 00:35:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows Unix sockets to be opened, written, read, and closed, like normal
files.  This can be especially handy from, for example, a shell script that
wants to send a short message to a Unix socket, but doesn't want to and/or
cannot create the socket itself.

This will try to open the Unix socket first in SOCK_DGRAM mode, then
SOCK_STREAM mode if that fails.

Signed-off-by: Jeff Hansen <x@jeffhansen.com>
---
 net/unix/Kconfig   |   10 +++++
 net/unix/af_unix.c |  104 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 114 insertions(+), 0 deletions(-)

diff --git a/net/unix/Kconfig b/net/unix/Kconfig
index 5a69733..68df4f1 100644
--- a/net/unix/Kconfig
+++ b/net/unix/Kconfig
@@ -19,3 +19,13 @@ config UNIX
 
 	  Say Y unless you know what you are doing.
 
+config UNIX_FOPS
+	boolean "Allow Unix sockets to be treated like normal files"
+	depends on UNIX
+	---help---
+	  If you say Y here, Unix sockets may be opened, written, read, and
+	  closed, like normal files.  This is handy for sending short commands
+	  to Unix sockets (i.e. from shell scripts), without having to create
+	  a Unix socket.
+
+	  Say Y unless you know what you are doing.
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 0ebc777..feb5877 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -798,6 +798,105 @@ fail:
 	return NULL;
 }
 
+#ifdef CONFIG_UNIX_FOPS
+static int unix_open(struct inode *inode, struct file *filp)
+{
+	int err;
+	struct socket *sock = NULL;
+	struct dentry *dentry = filp->f_dentry;
+	struct sockaddr_un sunaddr = { 0 };
+	char *p;
+
+	if (!filp)
+		return -ENXIO;
+	dentry = filp->f_dentry;
+
+	if (!dentry || !dentry->d_parent)
+		return -ENXIO;
+
+	if (filp->private_data)
+		return -EBUSY;
+
+	sunaddr.sun_family = AF_UNIX;
+	p = d_path(&filp->f_path, sunaddr.sun_path, sizeof(sunaddr.sun_path));
+	if (IS_ERR(p))
+		return PTR_ERR(p);
+	memmove(sunaddr.sun_path, p, p[sizeof(sunaddr.sun_path) - 1] ?
+		sizeof(sunaddr.sun_path) : strlen(p));
+
+	err = sock_create(PF_UNIX, SOCK_DGRAM, 0, &sock);
+	if (err)
+		return err;
+
+	err = unix_dgram_connect(sock, (struct sockaddr *)&sunaddr,
+				 sizeof(sunaddr), 0);
+	if (err) {
+		sock_release(sock);
+
+		err = sock_create(PF_UNIX, SOCK_STREAM, 0, &sock);
+		if (err)
+			return err;
+
+		err = unix_stream_connect(sock, (struct sockaddr *)&sunaddr,
+					  sizeof(sunaddr), 0);
+
+		if (err)
+			return err;
+	}
+	filp->private_data = sock;
+
+	return err;
+}
+
+static int unix_frelease(struct inode *inode, struct file *filp)
+{
+	if (!filp->private_data)
+		return -ENXIO;
+
+	sock_release(filp->private_data);
+	filp->private_data = NULL;
+	return 0;
+}
+
+#define DECLARE_UNIX_FOP(name, buf_mod, fop) \
+static ssize_t name(struct file *filp, buf_mod char __user *buf, \
+	size_t _len, loff_t *ppos) \
+{ \
+	struct socket *sock = filp->private_data; \
+	int len = (int)_len, err; \
+	struct kvec iov = { \
+		.iov_base = (void *)buf, \
+		.iov_len = len, \
+	}; \
+	struct msghdr msg = { \
+		/* NB: struct iovec and kvec are equal */ \
+		.msg_iov = (struct iovec *)&iov, \
+		.msg_iovlen = 1, \
+	}; \
+\
+	if (!sock) \
+		return -ENXIO; \
+	if (_len > 0xffffffffLL) \
+		return -E2BIG; \
+\
+	err = sock_sendmsg(sock, &msg, len); \
+	if (err > 0 && ppos) \
+		*ppos += err; \
+\
+	return err; \
+}
+
+DECLARE_UNIX_FOP(unix_write, const, sock_sendmsg(sock, &msg, len))
+DECLARE_UNIX_FOP(unix_read, , sock_recvmsg(sock, &msg, len, 0))
+
+const struct file_operations unix_sock_fops = {
+	.owner = THIS_MODULE,
+	.open = unix_open,
+	.release = unix_frelease,
+	.write = unix_write,
+	.read = unix_read,
+};
+#endif /* CONFIG_UNIX_FOPS */
 
 static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
@@ -874,6 +973,11 @@ out_mknod_drop_write:
 		mnt_drop_write(nd.path.mnt);
 		if (err)
 			goto out_mknod_dput;
+
+#ifdef CONFIG_UNIX_FOPS
+		dentry->d_inode->i_fop = &unix_sock_fops;
+#endif
+
 		mutex_unlock(&nd.path.dentry->d_inode->i_mutex);
 		dput(nd.path.dentry);
 		nd.path.dentry = dentry;
-- 
1.7.0.4

