From: Jeff Hansen <x@jeffhansen.com>
Subject: [PATCH] net/unix: Allow Unix sockets to be treated like normal files.
Date: Tue, 26 Oct 2010 04:21:05 +0000
Message-ID: <1288066865-15420-1-git-send-email-x@jeffhansen.com>
Cc: netdev@vger.kernel.org, Jeff Hansen <x@jeffhansen.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:33475 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751088Ab0JZEVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 00:21:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows Unix sockets to be opened, written, read, and closed, like
normal files.  This can be especially handy from, for example, a shell
script that wants to send a short message to a Unix socket, but doesn't
want to and/or cannot create the socket itself.

This will try to open the Unix socket first in SOCK_DGRAM mode, then
SOCK_STREAM mode if that fails.

Signed-off-by: Jeff Hansen <x@jeffhansen.com>
---
 net/unix/Kconfig   |   10 +++++
 net/unix/af_unix.c |  113 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 123 insertions(+), 0 deletions(-)

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
index 0ebc777..b5a6655 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -798,6 +798,114 @@ fail:
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
+static ssize_t unix_readwrite(struct file *filp, void *buf,
+	size_t _len, loff_t *ppos, int do_write)
+{
+	struct socket *sock = filp->private_data;
+	int len = (int)_len, err;
+	struct kvec iov = {
+		.iov_base = buf,
+		.iov_len = len,
+	};
+	struct msghdr msg = {
+		/* NB: struct iovec and kvec are equal */
+		.msg_iov = (struct iovec *)&iov,
+		.msg_iovlen = 1,
+	};
+
+	if (!sock)
+		return -ENXIO;
+	if (_len > 0xffffffffLL)
+		return -E2BIG;
+
+	err = do_write ? sock_sendmsg(sock, &msg, len) :
+			 sock_recvmsg(sock, &msg, len, 0);
+	if (err > 0 && ppos)
+		*ppos += err;
+
+	return err;
+}
+
+static ssize_t unix_write(struct file *filp, const char __user *buf,
+	size_t _len, loff_t *ppos)
+{
+	return unix_readwrite(filp, (void *)buf, _len, ppos, 0);
+}
+
+static ssize_t unix_read(struct file *filp, const char __user *buf,
+	size_t _len, loff_t *ppos)
+{
+	return unix_readwrite(filp, (void *)buf, _len, ppos, 0);
+}
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
@@ -874,6 +982,11 @@ out_mknod_drop_write:
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

