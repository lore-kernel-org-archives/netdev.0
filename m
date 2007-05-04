From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 34/40] sock: safely expose kernel sockets to userspace
Date: Fri, 04 May 2007 12:27:25 +0200
Message-ID: <20070504103203.418277742@chello.nl>
References: <20070504102651.923946304@chello.nl>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>,
	James Bottomley <James.Bottomley@SteelEye.com>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Andrew Morton <akpm@linux-foundation.org>,
	Daniel Phillips <phillips@google.com>,
	Mike Christie <mchristi@redhat.com>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:46698 "EHLO
	amsfep12-int.chello.nl" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754248AbXEDKgB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 06:36:01 -0400
Content-Disposition: inline; filename=net-SOCK_KERNEL.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SOCK_KERNEL - avoids user-space from actually using this socket for anything.
This enables sticking kernel sockets into the files_table for identifying and
reference counting purposes.

(iSCSI wants to do this)

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Mike Christie <mchristi@redhat.com>
---
 include/net/sock.h |    1 +
 net/socket.c       |   10 +++++++++-
 2 files changed, 10 insertions(+), 1 deletion(-)

Index: linux-2.6-git/include/net/sock.h
===================================================================
--- linux-2.6-git.orig/include/net/sock.h	2007-03-22 11:29:07.000000000 +0100
+++ linux-2.6-git/include/net/sock.h	2007-03-22 11:29:08.000000000 +0100
@@ -394,6 +394,7 @@ enum sock_flags {
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
 	SOCK_VMIO, /* the VM depends on us - make sure we're serviced */
+	SOCK_KERNEL, /* userspace cannot touch this socket */
 };
 
 static inline void sock_copy_flags(struct sock *nsk, struct sock *osk)
Index: linux-2.6-git/net/socket.c
===================================================================
--- linux-2.6-git.orig/net/socket.c	2007-03-22 11:28:58.000000000 +0100
+++ linux-2.6-git/net/socket.c	2007-03-26 12:00:36.000000000 +0200
@@ -353,7 +353,7 @@ static int sock_alloc_fd(struct file **f
 	return fd;
 }
 
-static int sock_attach_fd(struct socket *sock, struct file *file)
+static noinline int sock_attach_fd(struct socket *sock, struct file *file)
 {
 	struct qstr this;
 	char name[32];
@@ -381,6 +381,10 @@ static int sock_attach_fd(struct socket 
 	file->f_op = SOCK_INODE(sock)->i_fop = &socket_file_ops;
 	file->f_mode = FMODE_READ | FMODE_WRITE;
 	file->f_flags = O_RDWR;
+	if (unlikely(sock->sk && sock_flag(sock->sk, SOCK_KERNEL))) {
+		file->f_mode = 0;
+		file->f_flags = 0;
+	}
 	file->f_pos = 0;
 	file->private_data = sock;
 
@@ -806,6 +810,10 @@ static long sock_ioctl(struct file *file
 	int pid, err;
 
 	sock = file->private_data;
+
+	if (unlikely(sock_flag(sock->sk, SOCK_KERNEL)))
+		return -EBADF;
+
 	if (cmd >= SIOCDEVPRIVATE && cmd <= (SIOCDEVPRIVATE + 15)) {
 		err = dev_ioctl(cmd, argp);
 	} else

--

