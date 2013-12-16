From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH] net: show protocol type in sockprotoname of fdinfo
Date: Mon, 16 Dec 2013 16:19:41 +0900
Message-ID: <1387178381-30289-1-git-send-email-yamato@redhat.com>
Cc: yamato@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859Ab3LPHTp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 02:19:45 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rBG7Jjei016429
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 02:19:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 600e177920df936d03b807780ca92c662af98990 "system.sockprotoname"
xattrs is added to sockets enumerated under /proc/$PID/fd.
It is intended mainly to be used from lsof.

The patch was accepted. However, I think using xattrs under procfs is
special hack for lsof. Normally the user of procfs may want to use cat
command(or write syscall) to retrieve informations from the fs.

This patch introduces "sockprotoname" field to /proc/PID/fdinfo of socket.
So the user can use cat command to retrieve the protocol information.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/socket.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/net/socket.c b/net/socket.c
index 879933a..5e27715 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -132,6 +132,9 @@ static ssize_t sock_sendpage(struct file *file, struct page *page,
 static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 				struct pipe_inode_info *pipe, size_t len,
 				unsigned int flags);
+#ifdef CONFIG_PROC_FS
+static int sock_show_fdinfo(struct seq_file *m, struct file *file);
+#endif
 
 /*
  *	Socket files have a set of 'special' operations as well as the generic file ones. These don't appear
@@ -155,6 +158,9 @@ static const struct file_operations socket_file_ops = {
 	.sendpage =	sock_sendpage,
 	.splice_write = generic_splice_sendpage,
 	.splice_read =	sock_splice_read,
+#ifdef CONFIG_PROC_FS
+	.show_fdinfo = sock_show_fdinfo,
+#endif
 };
 
 /*
@@ -882,6 +888,20 @@ static ssize_t sock_splice_read(struct file *file, loff_t *ppos,
 	return sock->ops->splice_read(sock, ppos, pipe, len, flags);
 }
 
+#ifdef CONFIG_PROC_FS
+static int sock_show_fdinfo(struct seq_file *m, struct file *file)
+{
+	struct socket *sock;
+	int ret;
+
+	sock = file->private_data;
+	ret = seq_printf(m, "%s: %s\n",
+			 XATTR_SOCKPROTONAME_SUFFIX,
+			 sock->sk ? sock->sk->sk_prot_creator->name : "-");
+	return ret;
+}
+#endif
+
 static struct sock_iocb *alloc_sock_iocb(struct kiocb *iocb,
 					 struct sock_iocb *siocb)
 {
-- 
1.8.3.1
