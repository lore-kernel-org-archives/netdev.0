From: Alex Gartrell <agartrell@fb.com>
Subject: [PATCH net-next 1/2] socket: Allow external sockets to use socket syscalls
Date: Thu, 25 Dec 2014 22:50:23 -0800
Message-ID: <1419576624-8999-2-git-send-email-agartrell@fb.com>
References: <1419576624-8999-1-git-send-email-agartrell@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>, Alex Gartrell <agartrell@fb.com>
To: <davem@davemloft.net>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:15875 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751548AbaLZGup (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 01:50:45 -0500
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id sBQ6nI3R023497
	for <netdev@vger.kernel.org>; Thu, 25 Dec 2014 22:50:45 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1rgvwbh8q4-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 25 Dec 2014 22:50:45 -0800
Received: from facebook.com (2401:db00:20:7017:face:0:13:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 833f54d28ccb11e48d1d0002c95209d8-5c5dc390 for <netdev@vger.kernel.org>;	Thu,
 25 Dec 2014 22:50:43 -0800
In-Reply-To: <1419576624-8999-1-git-send-email-agartrell@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the "is-socket" test for a file compares the ops table pointer,
which is static and local to the socket.c.  Instead, this adds a flag for
private_data_is_socket.  This is an exceptionally long commit message for a
two-line patch.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
---
 include/linux/fs.h | 2 +-
 net/socket.c       | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index bb29b02..d162476 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -809,7 +809,7 @@ struct file {
 #endif
 	/* needed for tty driver, and maybe others */
 	void			*private_data;
-
+	bool			private_data_is_socket : 1;
 #ifdef CONFIG_EPOLL
 	/* Used by fs/eventpoll.c to link all the hooks to this file */
 	struct list_head	f_ep_links;
diff --git a/net/socket.c b/net/socket.c
index 8809afc..cd853be 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -388,6 +388,7 @@ struct file *sock_alloc_file(struct socket *sock, int flags, const char *dname)
 	sock->file = file;
 	file->f_flags = O_RDWR | (flags & O_NONBLOCK);
 	file->private_data = sock;
+	file->private_data_is_socket = true;
 	return file;
 }
 EXPORT_SYMBOL(sock_alloc_file);
@@ -411,7 +412,7 @@ static int sock_map_fd(struct socket *sock, int flags)
 
 struct socket *sock_from_file(struct file *file, int *err)
 {
-	if (file->f_op == &socket_file_ops)
+	if (file->private_data_is_socket)
 		return file->private_data;	/* set in sock_map_fd */
 
 	*err = -ENOTSOCK;
-- 
Alex Gartrell <agartrell@fb.com>
