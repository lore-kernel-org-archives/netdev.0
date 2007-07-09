From: Tetsuo Handa <from-netdev@i-love.sakura.ne.jp>
Subject: [RFC] Allow LSM to use IP address/port number. (was Re: [PATCH 1/1] Add post accept()/recvmsg() hooks.)
Date: Mon, 09 Jul 2007 14:33:01 +0900
Message-ID: <200707090533.l695X1PM059672@www262.sakura.ne.jp>
References: <200707032107.CBD30767.PtGMNNTS@I-love.SAKURA.ne.jp> <200707061114.07419.paul.moore@hp.com> <200707070225.AFC45609.MNStNTPG@I-love.SAKURA.ne.jp> <200707061343.03942.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, chrisw@sous-sol.org
To: netdev@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200707061343.03942.paul.moore@hp.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

This thread is from http://marc.info/?t=118346457000005&r=1&w=2 .

I want to use tcp_wrapper-like filtering using LSM.
But it seems that there are cases (recvmsg() and read()?) where
__sock_recvmsg() is called with msg->name == NULL and msg->msg_namelen == 0
that makes what I want to do impossible.
To make IP address and port number always available,
some changes in socket layer are needed.

Since I'm not getting objection from LSM-ml so far,
I'm now adding netdev-ml because this patch is related to socket layer.

Are there ways to receive messages other than recv()/recvfrom()/recvmsg()/read()?
If recv()/recvfrom()/recvmsg()/read() are all ways to receive messages,
the following patch seems to allow LSM to use IP address and port number.

The following patch allocates buffer for receiving IP address and port number
even if userland doesn't request them.
Is this change no problem?

Regards.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/security.h |   38 ++++++++++++++++++++++++++++++++++----
 net/socket.c             |   40 ++++++++++++++++++++++++++++++++++------
 security/dummy.c         |   11 +++++++++--
 3 files changed, 77 insertions(+), 12 deletions(-)

diff -upr a/include/linux/security.h b/include/linux/security.h
--- a/include/linux/security.h	2007-07-03 10:07:14.000000000 +0900
+++ b/include/linux/security.h	2007-07-09 10:51:04.000000000 +0900
@@ -748,8 +748,12 @@ struct request_sock;
  * @socket_post_accept:
  *	This hook allows a security module to copy security
  *	information into the newly created socket's inode.
+ *	This hook also allows a security module to filter connections
+ *	from unwanted peers.
+ *	The connection will be aborted if this hook returns nonzero.
  *	@sock contains the listening socket structure.
  *	@newsock contains the newly created server socket for connection.
+ *	Return 0 if permission is granted.
  * @socket_sendmsg:
  *	Check permission before transmitting a message to another socket.
  *	@sock contains the socket structure.
@@ -763,6 +767,15 @@ struct request_sock;
  *	@size contains the size of message structure.
  *	@flags contains the operational flags.
  *	Return 0 if permission is granted.  
+ * @socket_post_recvmsg:
+ *	Check peer's address after receiving a message from a socket.
+ *	This hook allows a security module to filter messages
+ *	from unwanted peers.
+ *	@sock contains the socket structure.
+ *	@msg contains the message structure.
+ *	@size contains the size of message structure.
+ *	@flags contains the operational flags.
+ *	Return 0 if permission is granted.
  * @socket_getsockname:
  *	Check permission before the local address (name) of the socket object
  *	@sock is retrieved.
@@ -1343,12 +1356,14 @@ struct security_operations {
 			       struct sockaddr * address, int addrlen);
 	int (*socket_listen) (struct socket * sock, int backlog);
 	int (*socket_accept) (struct socket * sock, struct socket * newsock);
-	void (*socket_post_accept) (struct socket * sock,
+	int (*socket_post_accept) (struct socket *sock,
 				    struct socket * newsock);
 	int (*socket_sendmsg) (struct socket * sock,
 			       struct msghdr * msg, int size);
 	int (*socket_recvmsg) (struct socket * sock,
 			       struct msghdr * msg, int size, int flags);
+	int (*socket_post_recvmsg) (struct socket *sock, struct msghdr *msg,
+				    int size, int flags);
 	int (*socket_getsockname) (struct socket * sock);
 	int (*socket_getpeername) (struct socket * sock);
 	int (*socket_getsockopt) (struct socket * sock, int level, int optname);
@@ -2853,10 +2868,10 @@ static inline int security_socket_accept
 	return security_ops->socket_accept(sock, newsock);
 }
 
-static inline void security_socket_post_accept(struct socket * sock, 
+static inline int security_socket_post_accept(struct socket *sock,
 					       struct socket * newsock)
 {
-	security_ops->socket_post_accept(sock, newsock);
+	return security_ops->socket_post_accept(sock, newsock);
 }
 
 static inline int security_socket_sendmsg(struct socket * sock, 
@@ -2872,6 +2887,13 @@ static inline int security_socket_recvms
 	return security_ops->socket_recvmsg(sock, msg, size, flags);
 }
 
+static inline int security_socket_post_recvmsg(struct socket *sock,
+					       struct msghdr *msg,
+					       int size, int flags)
+{
+	return security_ops->socket_post_recvmsg(sock, msg, size, flags);
+}
+
 static inline int security_socket_getsockname(struct socket * sock)
 {
 	return security_ops->socket_getsockname(sock);
@@ -3016,9 +3038,10 @@ static inline int security_socket_accept
 	return 0;
 }
 
-static inline void security_socket_post_accept(struct socket * sock, 
+static inline int security_socket_post_accept(struct socket *sock,
 					       struct socket * newsock)
 {
+	return 0;
 }
 
 static inline int security_socket_sendmsg(struct socket * sock, 
@@ -3034,6 +3057,13 @@ static inline int security_socket_recvms
 	return 0;
 }
 
+static inline int security_socket_post_recvmsg(struct socket *sock,
+					       struct msghdr *msg,
+					       int size, int flags)
+{
+	return 0;
+}
+
 static inline int security_socket_getsockname(struct socket * sock)
 {
 	return 0;
diff -upr a/net/socket.c b/net/socket.c
--- a/net/socket.c	2007-07-03 10:07:16.000000000 +0900
+++ b/net/socket.c	2007-07-09 10:44:25.000000000 +0900
@@ -636,7 +636,18 @@ static inline int __sock_recvmsg(struct 
 	if (err)
 		return err;
 
-	return sock->ops->recvmsg(iocb, sock, msg, size, flags);
+	err = sock->ops->recvmsg(iocb, sock, msg, size, flags);
+	/*
+	 * Filter messages from unwanted peers.
+	 * To be exact, this hook can't filter messages,
+	 * this hook just returns an error code.
+	 */
+	if (err >= 0) {
+		int ret = security_socket_post_recvmsg(sock, msg, size, flags);
+		if (ret)
+			err = ret;
+	}
+	return err;
 }
 
 int sock_recvmsg(struct socket *sock, struct msghdr *msg,
@@ -649,8 +660,16 @@ int sock_recvmsg(struct socket *sock, st
 	init_sync_kiocb(&iocb, NULL);
 	iocb.private = &siocb;
 	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
-	if (-EIOCBQUEUED == ret)
+	if (-EIOCBQUEUED == ret) {
 		ret = wait_on_sync_kiocb(&iocb);
+		/* I can now check security_socket_post_recvmsg(). */
+		if (ret >= 0) {
+			int err = security_socket_post_recvmsg(sock, msg, size,
+							       flags);
+			if (err)
+				ret = err;
+		}
+	}
 	return ret;
 }
 
@@ -713,12 +732,14 @@ static ssize_t do_sock_read(struct msghd
 	struct socket *sock = file->private_data;
 	size_t size = 0;
 	int i;
+	/* only for security_socket_post_recvmsg() */
+	char address[MAX_SOCK_ADDR];
 
 	for (i = 0; i < nr_segs; i++)
 		size += iov[i].iov_len;
 
-	msg->msg_name = NULL;
-	msg->msg_namelen = 0;
+	msg->msg_name = address;
+	msg->msg_namelen = sizeof(address);
 	msg->msg_control = NULL;
 	msg->msg_controllen = 0;
 	msg->msg_iov = (struct iovec *)iov;
@@ -1438,13 +1459,16 @@ asmlinkage long sys_accept(int fd, struc
 			goto out_fd;
 	}
 
+	/* Filter connections from unwanted peers like TCP Wrapper. */
+	err = security_socket_post_accept(sock, newsock);
+	if (err)
+		goto out_fd;
+
 	/* File flags are not inherited via accept() unlike another OSes. */
 
 	fd_install(newfd, newfile);
 	err = newfd;
 
-	security_socket_post_accept(sock, newsock);
-
 out_put:
 	fput_light(sock->file, fput_needed);
 out:
@@ -1938,6 +1962,10 @@ asmlinkage long sys_recvmsg(int fd, stru
 		goto out_freeiov;
 	total_len = err;
 
+	/* only for security_socket_post_recvmsg() */
+	msg_sys.msg_name = addr;
+	msg_sys.msg_namelen = sizeof(addr);
+
 	cmsg_ptr = (unsigned long)msg_sys.msg_control;
 	msg_sys.msg_flags = 0;
 	if (MSG_CMSG_COMPAT & flags)
diff -upr a/security/dummy.c b/security/dummy.c
--- a/security/dummy.c	2007-04-26 12:08:32.000000000 +0900
+++ b/security/dummy.c	2007-07-09 10:39:59.000000000 +0900
@@ -737,10 +737,10 @@ static int dummy_socket_accept (struct s
 	return 0;
 }
 
-static void dummy_socket_post_accept (struct socket *sock, 
+static int dummy_socket_post_accept (struct socket *sock,
 				      struct socket *newsock)
 {
-	return;
+	return 0;
 }
 
 static int dummy_socket_sendmsg (struct socket *sock, struct msghdr *msg,
@@ -755,6 +755,12 @@ static int dummy_socket_recvmsg (struct 
 	return 0;
 }
 
+static int dummy_socket_post_recvmsg (struct socket *sock, struct msghdr *msg,
+				      int size, int flags)
+{
+	return 0;
+}
+
 static int dummy_socket_getsockname (struct socket *sock)
 {
 	return 0;
@@ -1092,6 +1098,7 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, socket_post_accept);
 	set_to_dummy_if_null(ops, socket_sendmsg);
 	set_to_dummy_if_null(ops, socket_recvmsg);
+	set_to_dummy_if_null(ops, socket_post_recvmsg);
 	set_to_dummy_if_null(ops, socket_getsockname);
 	set_to_dummy_if_null(ops, socket_getpeername);
 	set_to_dummy_if_null(ops, socket_setsockopt);
