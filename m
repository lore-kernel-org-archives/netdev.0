From: Jeff Hansen <x@jeffhansen.com>
Subject: [PATCH] net/unix: Allow Unix sockets to be treated like normal files.
Date: Tue, 16 Nov 2010 04:23:44 +0000
Message-ID: <1289881424-17577-1-git-send-email-x@jeffhansen.com>
Cc: Dave Miller <davem@davemloft.net>, Jeff Hansen <x@jeffhansen.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:58316 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717Ab0KPEXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Nov 2010 23:23:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an update to my previous patch that fixes crashes on systems that
used filp->private_data for their own purposes.

For some reason, it doesn't look like this will ever get main-lined.  But,
just in case someone wants to be able to write to a Unix socket with:

$ echo send_cmd > /tmp/my_socket

This is the patch that will let you do that.

This allows Unix sockets to be opened, written, read, and closed, like
normal files.  This can be especially handy from, for example, a shell
script that wants to send a short message to a Unix socket, but doesn't
want to and/or cannot create the socket itself.

Signed-off-by: Jeff Hansen <x@jeffhansen.com>
---
 net/unix/Kconfig   |   10 +++
 net/unix/af_unix.c |  177 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 187 insertions(+), 0 deletions(-)

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
index 0ebc777..81ba74d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -798,6 +798,178 @@ fail:
 	return NULL;
 }
 
+#ifdef CONFIG_UNIX_FOPS
+struct sock *unix_fops_find_by_filp(struct file *filp,
+	struct sockaddr_un *sunaddr, unsigned int *_alen)
+{
+	int hash, nlen, alen, retval;
+	struct sock *sock = NULL;
+	struct net *net = &init_net;
+	char *p;
+	struct dentry *dentry = filp->f_dentry;
+
+	retval = -EINVAL;
+	if (!filp)
+		goto error;
+	dentry = filp->f_dentry;
+
+	if (!dentry || !dentry->d_parent)
+		goto error;
+
+	sunaddr->sun_family = AF_UNIX;
+	p = d_path(&filp->f_path, sunaddr->sun_path, sizeof(sunaddr->sun_path));
+	if (IS_ERR(p))
+		return (void *)p;
+	if (!p)
+		goto error;
+	nlen = strnlen(p, sizeof(sunaddr->sun_path) -
+			  (p - sunaddr->sun_path));
+
+	memmove(sunaddr->sun_path, p, nlen);
+	alen = nlen;
+	if (nlen < sizeof(sunaddr->sun_path)) {
+		sunaddr->sun_path[nlen] = 0;
+		alen++;
+	}
+	alen += sizeof(sunaddr->sun_family);
+
+	if (_alen)
+		*_alen = alen;
+
+	hash = dentry->d_inode->i_ino & (UNIX_HASH_SIZE-1);
+	sock = unix_find_socket_byname(net, sunaddr, alen, 0, hash);
+
+error:
+	if (sock)
+		return sock;
+	else
+		return ERR_PTR(retval);
+}
+
+static int unix_open(struct inode *inode, struct file *filp)
+{
+	int err, alen;
+	struct socket *sock = NULL;
+	struct sock *usock;
+	struct unix_sock *u = NULL;
+	struct sockaddr_un sunaddr = { 0 };
+
+	usock = unix_fops_find_by_filp(filp, &sunaddr, &alen);
+	if (IS_ERR(usock))
+		return PTR_ERR(usock);
+	u = unix_sk(usock);
+	err = -EBUSY;
+	if (u->fops_socket)
+		goto error;
+
+	err = sock_create_kern(PF_UNIX, usock->sk_type, 0, &sock);
+	if (err)
+		goto error;
+
+	err = sock->ops->connect(sock, (struct sockaddr *)&sunaddr,
+				 alen, 0);
+	if (err) {
+		sock_release(sock);
+		goto error;
+	}
+	u->fops_socket = sock;
+
+	/* FALLTHROUGH */
+error:
+	sock_put(usock);
+
+	return err;
+}
+
+static int unix_frelease(struct inode *inode, struct file *filp)
+{
+	int retval;
+	struct socket *sock;
+	struct sock *usock;
+	struct unix_sock *u;
+	struct sockaddr_un sunaddr;
+
+	usock = unix_fops_find_by_filp(filp, &sunaddr, NULL);
+	if (IS_ERR(usock))
+		return PTR_ERR(usock);
+	u = unix_sk(usock);
+	sock = u->fops_socket;
+	retval = -EINVAL;
+	if (!sock)
+		goto error;
+	u->fops_socket = NULL;
+	sock_release(sock);
+	retval = 0;
+
+	/* FALLTHROUGH */
+error:
+	sock_put(usock);
+	return retval;
+}
+
+static ssize_t unix_readwrite(struct file *filp, void *buf,
+	size_t _len, loff_t *ppos, int do_write)
+{
+	int len = (int)_len, err = 0;
+	struct kvec iov = {
+		.iov_base = buf,
+		.iov_len = len,
+	};
+	struct msghdr msg = {
+		/* NB: struct iovec and kvec are equal */
+		.msg_iov = (struct iovec *)&iov,
+		.msg_iovlen = 1,
+	};
+	struct socket *sock;
+	struct sock *usock;
+	struct unix_sock *u;
+	struct sockaddr_un sunaddr;
+
+	usock = unix_fops_find_by_filp(filp, &sunaddr, NULL);
+	if (IS_ERR(usock))
+		return PTR_ERR(usock);
+	u = unix_sk(usock);
+	sock = u->fops_socket;
+	err = -EINVAL;
+	if (!sock)
+		goto error;
+
+	err = -E2BIG;
+	if (_len > 0xffffffffLL)
+		goto error;
+
+	err = do_write ? sock_sendmsg(sock, &msg, len) :
+			 sock_recvmsg(sock, &msg, len, 0);
+	if (err > 0 && ppos)
+		*ppos += err;
+
+	/* FALLTHROUGH */
+error:
+	sock_put(usock);
+
+	return err;
+}
+
+static ssize_t unix_write(struct file *filp, const char __user *buf,
+	size_t _len, loff_t *ppos)
+{
+	return unix_readwrite(filp, (void *)buf, _len, ppos, 1);
+}
+
+static ssize_t unix_read(struct file *filp, char __user *buf,
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
@@ -874,6 +1046,11 @@ out_mknod_drop_write:
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

