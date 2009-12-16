From: Michael Stone <michael@laptop.org>
Subject: [PATCH] Security: Implement prctl(PR_SET_NETWORK, PR_NETWORK_OFF) semantics.
Date: Wed, 16 Dec 2009 10:32:44 -0500
Message-ID: <1260977565-2379-2-git-send-email-michael@laptop.org>
References: <1260977452-2334-1-git-send-email-michael@laptop.org>
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	"Andi Kleen" <andi@firstfloor.org>, "David Lang" <david@lang.hm>,
	"Oliver Hartkopp" <socketcan@hartkopp.net>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"Valdis Kletnieks" <Valdis.Kletnieks@vt.edu>,
	"Bryan Donlan" <bdonlan@gmail.com>,
	"Evgeniy Polyakov" <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	"James Morris" <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Bernie Innocenti" <bernie@codewiz.org>,
	"Mark Seaborn" <mrs@mythic-beasts.com>
To: Ulrich Drepper <drepper@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762291AbZLPPbW@vger.kernel.org>
In-Reply-To: <1260977452-2334-1-git-send-email-michael@laptop.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return -EPERM any time we try to __sock_create(), sys_connect(), sys_bind(),
sys_sendmsg(), or __ptrace_may_access() from a process with PR_NETWORK_OFF set
in current->network unless we're working on a socket which is already connected
or on a non-abstract AF_UNIX socket.

Signed-off-by: Michael Stone <michael@laptop.org>
---
 kernel/fork.c      |    2 ++
 kernel/ptrace.c    |    2 ++
 net/socket.c       |   51 ++++++++++++++++++++++++++++++++++++++-------------
 net/unix/af_unix.c |   19 +++++++++++++++++++
 4 files changed, 61 insertions(+), 13 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index 9bd9144..01a7644 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1130,6 +1130,8 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 
 	p->bts = NULL;
 
+	p->network = current->network;
+
 	p->stack_start = stack_start;
 
 	/* Perform scheduler related setup. Assign this task to a CPU. */
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 23bd09c..5b38db0 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -151,6 +151,8 @@ int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 		dumpable = get_dumpable(task->mm);
 	if (!dumpable && !capable(CAP_SYS_PTRACE))
 		return -EPERM;
+	if (current->network)
+		return -EPERM;
 
 	return security_ptrace_access_check(task, mode);
 }
diff --git a/net/socket.c b/net/socket.c
index b94c3dd..e59f906 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -87,6 +87,7 @@
 #include <linux/wireless.h>
 #include <linux/nsproxy.h>
 #include <linux/magic.h>
+#include <linux/sched.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -576,6 +577,12 @@ static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (err)
 		return err;
 
+	err = -EPERM;
+	if (sock->sk->sk_family != AF_UNIX &&
+		current->network &&
+		(msg->msg_name != NULL || msg->msg_namelen != 0))
+		return err;
+
 	return sock->ops->sendmsg(iocb, sock, msg, size);
 }
 
@@ -1227,6 +1234,9 @@ static int __sock_create(struct net *net, int family, int type, int protocol,
 	if (err)
 		return err;
 
+	if (family != AF_UNIX && current->network)
+		return -EPERM;
+
 	/*
 	 *	Allocate the socket and allow the family to set things up. if
 	 *	the protocol is 0, the family is instructed to select an appropriate
@@ -1465,19 +1475,29 @@ SYSCALL_DEFINE3(bind, int, fd, struct sockaddr __user *, umyaddr, int, addrlen)
 	int err, fput_needed;
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
-	if (sock) {
-		err = move_addr_to_kernel(umyaddr, addrlen, (struct sockaddr *)&address);
-		if (err >= 0) {
-			err = security_socket_bind(sock,
-						   (struct sockaddr *)&address,
-						   addrlen);
-			if (!err)
-				err = sock->ops->bind(sock,
-						      (struct sockaddr *)
-						      &address, addrlen);
-		}
-		fput_light(sock->file, fput_needed);
-	}
+	if (!sock)
+		goto out;
+
+	err = move_addr_to_kernel(umyaddr, addrlen, (struct sockaddr *)&address);
+	if (err < 0)
+		goto out_fput;
+
+	err = security_socket_bind(sock,
+				   (struct sockaddr *)&address,
+				   addrlen);
+	if (err)
+		goto out_fput;
+
+	err = (((struct sockaddr *)&address)->sa_family != AF_UNIX &&
+		current->network) ? -EPERM : 0;
+	if (err)
+		goto out_fput;
+
+	err = sock->ops->bind(sock, (struct sockaddr *) &address, addrlen);
+
+out_fput:
+	fput_light(sock->file, fput_needed);
+out:
 	return err;
 }
 
@@ -1639,6 +1659,11 @@ SYSCALL_DEFINE3(connect, int, fd, struct sockaddr __user *, uservaddr,
 	if (err)
 		goto out_put;
 
+	err = (((struct sockaddr *)&address)->sa_family != AF_UNIX &&
+		current->network) ? -EPERM : 0;
+	if (err)
+		goto out_put;
+
 	err = sock->ops->connect(sock, (struct sockaddr *)&address, addrlen,
 				 sock->file->f_flags);
 out_put:
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index f255119..2d984a9 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -797,6 +797,10 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	addr_len = err;
 
+	err = (current->network && !sunaddr->sun_path[0]) ? -EPERM : 0;
+	if (err)
+		goto out;
+
 	mutex_lock(&u->readlock);
 
 	err = -EINVAL;
@@ -934,6 +938,10 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 			goto out;
 		alen = err;
 
+		err = (current->network && !sunaddr->sun_path[0]) ? -EPERM : 0;
+		if (err)
+			goto out;
+
 		if (test_bit(SOCK_PASSCRED, &sock->flags) &&
 		    !unix_sk(sk)->addr && (err = unix_autobind(sock)) != 0)
 			goto out;
@@ -1033,6 +1041,10 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 		goto out;
 	addr_len = err;
 
+	err = (current->network && !sunaddr->sun_path[0]) ? -EPERM : 0;
+	if (err)
+		goto out;
+
 	if (test_bit(SOCK_PASSCRED, &sock->flags) && !u->addr &&
 	    (err = unix_autobind(sock)) != 0)
 		goto out;
@@ -1370,6 +1382,10 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		if (err < 0)
 			goto out;
 		namelen = err;
+
+		err = -EPERM;
+		if (current->network && !sunaddr->sun_path[0])
+			goto out;
 	} else {
 		sunaddr = NULL;
 		err = -ENOTCONN;
@@ -1520,6 +1536,9 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (msg->msg_namelen) {
 		err = sk->sk_state == TCP_ESTABLISHED ? -EISCONN : -EOPNOTSUPP;
 		goto out_err;
+		/* prctl(PR_SET_NETWORK) requires no change here since
+		 * connection-less unix stream sockets are not supported.
+		 * See Documentation/prctl_network.txt for details. */
 	} else {
 		sunaddr = NULL;
 		err = -ENOTCONN;
-- 
1.5.6.5
