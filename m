From: Michael Stone <michael@laptop.org>
Subject: [PATCH] Security: Implement and document RLIMIT_NETWORK.
Date: Wed,  7 Jan 2009 00:48:54 -0500
Message-ID: <1231307334-9542-2-git-send-email-michael@laptop.org>
References: <1231307334-9542-1-git-send-email-michael@laptop.org>
Cc: netdev@vger.kernel.org, Michael Stone <michael@laptop.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.laptop.org ([18.85.2.145]:57355 "EHLO mail.laptop.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751695AbZAGF6B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 00:58:01 -0500
In-Reply-To: <1231307334-9542-1-git-send-email-michael@laptop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Bernstein has observed [1] that security-conscious userland processes
may benefit from the ability to irrevocably remove their ability to create,
bind, connect to, or send messages except in the case of previously connected
sockets or AF_UNIX filesystem sockets. We provide this facility by implementing
support for a new rlimit called RLIMIT_NETWORK.

This facility is particularly attractive to security platforms like OLPC
Bitfrost [2] and to isolation programs like Rainbow [3] and Plash [4].

[1]: http://cr.yp.to/unix/disablenetwork.html
[2]: http://wiki.laptop.org/go/OLPC_Bitfrost
[3]: http://wiki.laptop.org/go/Rainbow
[4]: http://plash.beasts.org/
---
 Documentation/rlimit_network.txt |   48 ++++++++++++++++++++++++++++++++
 fs/proc/base.c                   |    1 +
 include/asm-generic/resource.h   |    4 ++-
 net/socket.c                     |   57 +++++++++++++++++++++++++++++--------
 net/unix/af_unix.c               |   28 ++++++++++++++++++
 5 files changed, 124 insertions(+), 14 deletions(-)
 create mode 100644 Documentation/rlimit_network.txt

diff --git a/Documentation/rlimit_network.txt b/Documentation/rlimit_network.txt
new file mode 100644
index 0000000..e7cc3e4
--- /dev/null
+++ b/Documentation/rlimit_network.txt
@@ -0,0 +1,48 @@
+Purpose
+-------
+
+Daniel Bernstein has observed [1] that security-conscious userland processes
+may benefit from the ability to irrevocably remove their ability to create,
+bind, connect to, or send messages except in the case of previously connected
+sockets or AF_UNIX filesystem sockets.
+
+This facility is particularly attractive to security platforms like OLPC
+Bitfrost [2] and to isolation programs like Rainbow [3] and Plash [4] because:
+
+  * it integrates well with standard techniques for writing privilege-separated
+    Unix programs
+
+  * it's available to unprivileged programs
+
+  * it's a discretionary feature available to all of distributors,
+    administrators, authors, and users
+
+  * its effect is entirely local, rather than global (like netfilter)
+
+  * it's simple enough to have some hope of being used correctly
+
+Implementation
+--------------
+
+After considering implementations based on the Linux Security Module (LSM)
+framework, on SELinux in particular, and on direct modification of the kernel
+syscall and task_struct APIs, we came to the conclusion that the best way to
+implement the feature was to extend the resource limits framework with a new
+RLIMIT_NETWORK field and to modify the implementations of the relevant socket
+calls to return -EACCES when
+
+  current->signal->rlim[RLIMIT_NETWORK].rlim_cur == 0
+
+unless we are manipulating an AF_UNIX socket whose name does not begin with \0
+or, in the case of sendmsg(), unless we are manipulating a previously connected
+socket, i.e. one with
+
+  msg.msg_name == NULL && msg.msg_namelen == 0
+
+References
+----------
+
+[1]: http://cr.yp.to/unix/disablenetwork.html
+[2]: http://wiki.laptop.org/go/OLPC_Bitfrost
+[3]: http://wiki.laptop.org/go/Rainbow
+[4]: http://plash.beasts.org/
diff --git a/fs/proc/base.c b/fs/proc/base.c
index d467760..75c230a 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -455,6 +455,7 @@ static const struct limit_names lnames[RLIM_NLIMITS] = {
 	[RLIMIT_NICE] = {"Max nice priority", NULL},
 	[RLIMIT_RTPRIO] = {"Max realtime priority", NULL},
 	[RLIMIT_RTTIME] = {"Max realtime timeout", "us"},
+	[RLIMIT_NETWORK] = {"Network access permitted", "boolean"},
 };
 
 /* Display limits for a process */
diff --git a/include/asm-generic/resource.h b/include/asm-generic/resource.h
index 587566f..7930bd5 100644
--- a/include/asm-generic/resource.h
+++ b/include/asm-generic/resource.h
@@ -45,7 +45,8 @@
 					   0-39 for nice level 19 .. -20 */
 #define RLIMIT_RTPRIO		14	/* maximum realtime priority */
 #define RLIMIT_RTTIME		15	/* timeout for RT tasks in us */
-#define RLIM_NLIMITS		16
+#define RLIMIT_NETWORK		16	/* permit network access  */
+#define RLIM_NLIMITS		17
 
 /*
  * SuS says limits have to be unsigned.
@@ -87,6 +88,7 @@
 	[RLIMIT_NICE]		= { 0, 0 },				\
 	[RLIMIT_RTPRIO]		= { 0, 0 },				\
 	[RLIMIT_RTTIME]		= {  RLIM_INFINITY,  RLIM_INFINITY },	\
+	[RLIMIT_NETWORK]	= {  RLIM_INFINITY,  RLIM_INFINITY },	\
 }
 
 #endif	/* __KERNEL__ */
diff --git a/net/socket.c b/net/socket.c
index 76ba80a..550722f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -90,6 +90,7 @@
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
+#include <asm/resource.h>
 
 #include <net/compat.h>
 #include <net/wext.h>
@@ -561,6 +562,13 @@ static inline int __sock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	if (err)
 		return err;
 
+	/* See Documentation/rlimit_network.txt */
+	err = -EACCES;
+	if (sock->sk->sk_family != AF_UNIX \
+		&& !current->signal->rlim[RLIMIT_NETWORK].rlim_cur \
+		&& (msg->msg_name != NULL || msg->msg_namelen != 0))
+		return err;
+
 	return sock->ops->sendmsg(iocb, sock, msg, size);
 }
 
@@ -1126,6 +1134,12 @@ static int __sock_create(struct net *net, int family, int type, int protocol,
 	if (err)
 		return err;
 
+	/* See Documentation/rlimit_network.txt */
+	err = (family == AF_UNIX \
+		|| current->signal->rlim[RLIMIT_NETWORK].rlim_cur) ? 0 : -EACCES;
+	if (err)
+		return err;
+
 	/*
 	 *	Allocate the socket and allow the family to set things up. if
 	 *	the protocol is 0, the family is instructed to select an appropriate
@@ -1371,19 +1385,30 @@ asmlinkage long sys_bind(int fd, struct sockaddr __user *umyaddr, int addrlen)
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
+	/* See Documentation/rlimit_network.txt */
+	err = (((struct sockaddr *)&address)->sa_family == AF_UNIX \
+		|| current->signal->rlim[RLIMIT_NETWORK].rlim_cur) ? 0 : -EACCES;
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
 
@@ -1547,6 +1572,12 @@ asmlinkage long sys_connect(int fd, struct sockaddr __user *uservaddr,
 	if (err)
 		goto out_put;
 
+	/* See Documentation/rlimit_network.txt */
+	err = (((struct sockaddr *)&address)->sa_family == AF_UNIX \
+		|| current->signal->rlim[RLIMIT_NETWORK].rlim_cur) ? 0 : -EACCES;
+	if (err)
+		goto out_put;
+
 	err = sock->ops->connect(sock, (struct sockaddr *)&address, addrlen,
 				 sock->file->f_flags);
 out_put:
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 66d5ac4..e536d15 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -99,6 +99,7 @@
 #include <linux/fs.h>
 #include <linux/slab.h>
 #include <asm/uaccess.h>
+#include <asm/resource.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
 #include <net/net_namespace.h>
@@ -789,6 +790,12 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 		goto out;
 	addr_len = err;
 
+	/* See Documentation/rlimit_network.txt */
+	err = (current->signal->rlim[RLIMIT_NETWORK].rlim_cur \
+		|| sunaddr->sun_path[0]) ? 0 : -EACCES;
+	if (err)
+		goto out;
+
 	mutex_lock(&u->readlock);
 
 	err = -EINVAL;
@@ -922,6 +929,12 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 			goto out;
 		alen = err;
 
+		/* See Documentation/rlimit_network.txt */
+		err = (current->signal->rlim[RLIMIT_NETWORK].rlim_cur \
+			|| sunaddr->sun_path[0]) ? 0 : -EACCES;
+		if (err)
+			goto out;
+
 		if (test_bit(SOCK_PASSCRED, &sock->flags) &&
 		    !unix_sk(sk)->addr && (err = unix_autobind(sock)) != 0)
 			goto out;
@@ -1021,6 +1034,12 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 		goto out;
 	addr_len = err;
 
+	/* See Documentation/rlimit_network.txt */
+	err = (current->signal->rlim[RLIMIT_NETWORK].rlim_cur \
+		|| sunaddr->sun_path[0]) ? 0 : -EACCES;
+	if (err)
+		goto out;
+
 	if (test_bit(SOCK_PASSCRED, &sock->flags)
 		&& !u->addr && (err = unix_autobind(sock)) != 0)
 		goto out;
@@ -1357,6 +1376,12 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 		if (err < 0)
 			goto out;
 		namelen = err;
+
+		/* See Documentation/rlimit_network.txt */
+		err = -EACCES;
+		if (!current->signal->rlim[RLIMIT_NETWORK].rlim_cur \
+			&& !sunaddr->sun_path[0])
+			goto out;
 	} else {
 		sunaddr = NULL;
 		err = -ENOTCONN;
@@ -1506,6 +1531,9 @@ static int unix_stream_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (msg->msg_namelen) {
 		err = sk->sk_state == TCP_ESTABLISHED ? -EISCONN : -EOPNOTSUPP;
 		goto out_err;
+		/* RLIMIT_NETWORK requires no change here since connection-less
+		 * unix stream sockets are not supported.
+		 * See Documentation/rlimit_network.txt for details. */
 	} else {
 		sunaddr = NULL;
 		err = -ENOTCONN;
-- 
1.5.6.6

