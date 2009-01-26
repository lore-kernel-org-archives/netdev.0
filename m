From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] net: add tracepoints to socket api
Date: Mon, 26 Jan 2009 14:59:30 -0500
Message-ID: <20090126195930.GA28208@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35760 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbZAZT7n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 14:59:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey all-
	I've been working for a bit with the various tracepoints that have been
developed in the lttng tree.  The infrastructure is available in the main line
kernel.  All thats missing are the tracepoints themselves.  While some seem to
be contentious for various reasons, most seem benign, and can be rather usefull,
so I was thinking we could start importing Some for the net stack.  Heres a
patch for the top level socket api tracepoints.  If these are acceptable, I'll
begin porting over the rest for the remainder of the network stack.   This patch
applies cleanly against the net-next tree.


Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 socket.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)


diff --git a/net/socket.c b/net/socket.c
index 35dd737..6cf37f8 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -95,6 +95,7 @@
 
 #include <net/sock.h>
 #include <linux/netfilter.h>
+#include <trace/socket.h>
 
 static int sock_no_open(struct inode *irrelevant, struct file *dontcare);
 static ssize_t sock_aio_read(struct kiocb *iocb, const struct iovec *iov,
@@ -155,6 +156,11 @@ static const struct net_proto_family *net_families[NPROTO] __read_mostly;
 
 static DEFINE_PER_CPU(int, sockets_in_use) = 0;
 
+DEFINE_TRACE(socket_sendmsg);
+DEFINE_TRACE(socket_recvmsg);
+DEFINE_TRACE(socket_create);
+DEFINE_TRACE(socket_call);
+
 /*
  * Support routines.
  * Move socket addresses back and forth across the kernel/user
@@ -574,6 +580,7 @@ int sock_sendmsg(struct socket *sock, struct msghdr *msg, size_t size)
 	ret = __sock_sendmsg(&iocb, sock, msg, size);
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&iocb);
+	trace_socket_sendmsg(sock, msg, size, ret);
 	return ret;
 }
 
@@ -653,10 +660,12 @@ int sock_recvmsg(struct socket *sock, struct msghdr *msg,
 	int ret;
 
 	init_sync_kiocb(&iocb, NULL);
+
 	iocb.private = &siocb;
 	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
 	if (-EIOCBQUEUED == ret)
 		ret = wait_on_sync_kiocb(&iocb);
+	trace_socket_recvmsg(sock, msg, size, flags, ret);
 	return ret;
 }
 
@@ -1242,6 +1251,7 @@ SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol)
 	if (retval < 0)
 		goto out_release;
 
+	trace_socket_create(sock, retval);
 out:
 	/* It may be already another descriptor 8) Not kernel problem. */
 	return retval;
@@ -2064,6 +2074,8 @@ SYSCALL_DEFINE2(socketcall, int, call, unsigned long __user *, args)
 	a0 = a[0];
 	a1 = a[1];
 
+	trace_socket_call(call, a0);
+
 	switch (call) {
 	case SYS_SOCKET:
 		err = sys_socket(a0, a1, a[2]);
