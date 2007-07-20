From: Tetsuo Handa <from-netdev@I-love.SAKURA.ne.jp>
Subject: [PATCH 1/1] Allow LSM to use IP address/port number.
Date: Sat, 21 Jul 2007 00:11:04 +0900
Message-ID: <200707210011.HBI60217.FUNOWSFPGEt@I-love.SAKURA.ne.jp>
References: <20070709.002629.28788394.davem@davemloft.net>
	<200707092213.HAC58314.WSNFtPGOFUE@I-love.SAKURA.ne.jp>
	<Line.LNX.4.64.0707091842360.9417@d.namei>
	<20070709160538.289d8ac2@freepuppy.rosehill.hemminger.net>
	<Line.LNX.4.64.0707091940450.10029@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: jmorris@namei.org, shemminger@linux-foundation.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <Line.LNX.4.64.0707091940450.10029@d.namei>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

> > Isn't it better to hook into existing netfilter infrastructure somehow?
> Yes, it has been suggested several times.
I want to use a process's context who issued
accept()/recv()/recvfrom()/recvmsg()/read() requests.

But Stephen Smalley said at http://marc.info/?l=linux-security-module&m=118459899017487&w=2 that
> The socket can be inherited by a child task or passed via local IPC to
> an unrelated task, and then used by those other tasks.  It isn't tied to
> the original allocating task's lifecycle in any way, nor is it
> guaranteed to only be used by that original allocating task.  It can
> exist in zero, one or many tasks' file tables and still be receiving
> data, and can go from completely disassociated (i.e. not present in any
> tasks' file tables) to being associated.
I can't use netfilter infrastructure because
it is too early to know who the recipant process of the packet is.
The only chance to perform ip/port based filtering
using ACLs associated with the recipant process of the packet
is post-accept() and post-recvmsg().

Therefore, I re-post my patch again.

Regards.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/security.h |   44 +++++++++++++++++++++++++++++++++++++-------
 net/socket.c             |   42 ++++++++++++++++++++++++++++++++++++------
 security/dummy.c         |   13 ++++++++++---
 3 files changed, 83 insertions(+), 16 deletions(-)

diff -upr a/include/linux/security.h b/include/linux/security.h
--- a/include/linux/security.h	2007-07-20 22:55:38.000000000 +0900
+++ b/include/linux/security.h	2007-07-20 23:15:58.000000000 +0900
@@ -749,8 +749,12 @@ struct request_sock;
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
@@ -764,6 +768,15 @@ struct request_sock;
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
@@ -1345,12 +1358,14 @@ struct security_operations {
 			       struct sockaddr * address, int addrlen);
 	int (*socket_listen) (struct socket * sock, int backlog);
 	int (*socket_accept) (struct socket * sock, struct socket * newsock);
-	void (*socket_post_accept) (struct socket * sock,
-				    struct socket * newsock);
+	int (*socket_post_accept) (struct socket *sock,
+				   struct socket *newsock);
 	int (*socket_sendmsg) (struct socket * sock,
 			       struct msghdr * msg, int size);
 	int (*socket_recvmsg) (struct socket * sock,
 			       struct msghdr * msg, int size, int flags);
+	int (*socket_post_recvmsg) (struct socket *sock, struct msghdr *msg,
+				    int size, int flags);
 	int (*socket_getsockname) (struct socket * sock);
 	int (*socket_getpeername) (struct socket * sock);
 	int (*socket_getsockopt) (struct socket * sock, int level, int optname);
@@ -2860,10 +2875,10 @@ static inline int security_socket_accept
 	return security_ops->socket_accept(sock, newsock);
 }
 
-static inline void security_socket_post_accept(struct socket * sock, 
-					       struct socket * newsock)
+static inline int security_socket_post_accept(struct socket *sock,
+					      struct socket *newsock)
 {
-	security_ops->socket_post_accept(sock, newsock);
+	return security_ops->socket_post_accept(sock, newsock);
 }
 
 static inline int security_socket_sendmsg(struct socket * sock, 
@@ -2879,6 +2894,13 @@ static inline int security_socket_recvms
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
@@ -3023,9 +3045,10 @@ static inline int security_socket_accept
 	return 0;
 }
 
-static inline void security_socket_post_accept(struct socket * sock, 
-					       struct socket * newsock)
+static inline int security_socket_post_accept(struct socket *sock,
+					      struct socket *newsock)
 {
+	return 0;
 }
 
 static inline int security_socket_sendmsg(struct socket * sock, 
@@ -3041,6 +3064,13 @@ static inline int security_socket_recvms
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
--- a/net/socket.c	2007-07-20 22:55:53.000000000 +0900
+++ b/net/socket.c	2007-07-21 00:05:18.000000000 +0900
@@ -635,7 +635,19 @@ static inline int __sock_recvmsg(struct 
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
+		int ret;
+		ret = security_socket_post_recvmsg(sock, msg, size, flags);
+		if (ret)
+			err = ret;
+	}
+	return err;
 }
 
 int sock_recvmsg(struct socket *sock, struct msghdr *msg,
@@ -648,8 +660,17 @@ int sock_recvmsg(struct socket *sock, st
 	init_sync_kiocb(&iocb, NULL);
 	iocb.private = &siocb;
 	ret = __sock_recvmsg(&iocb, sock, msg, size, flags);
-	if (-EIOCBQUEUED == ret)
+	if (-EIOCBQUEUED == ret) {
 		ret = wait_on_sync_kiocb(&iocb);
+		/* I can now check security_socket_post_recvmsg(). */
+		if (ret >= 0) {
+			int err;
+			err = security_socket_post_recvmsg(sock, msg, size,
+							   flags);
+			if (err)
+				ret = err;
+		}
+	}
 	return ret;
 }
 
@@ -712,12 +733,14 @@ static ssize_t do_sock_read(struct msghd
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
@@ -1437,13 +1460,16 @@ asmlinkage long sys_accept(int fd, struc
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
@@ -1937,6 +1963,10 @@ asmlinkage long sys_recvmsg(int fd, stru
 		goto out_freeiov;
 	total_len = err;
 
+	/* only for security_socket_post_recvmsg() */
+	msg_sys.msg_name = addr;
+	msg_sys.msg_namelen = sizeof(addr);
+
 	cmsg_ptr = (unsigned long)msg_sys.msg_control;
 	msg_sys.msg_flags = flags & (MSG_CMSG_CLOEXEC|MSG_CMSG_COMPAT);
 
diff -upr a/security/dummy.c b/security/dummy.c
--- a/security/dummy.c	2007-07-20 22:55:54.000000000 +0900
+++ b/security/dummy.c	2007-07-20 23:15:22.000000000 +0900
@@ -741,10 +741,10 @@ static int dummy_socket_accept (struct s
 	return 0;
 }
 
-static void dummy_socket_post_accept (struct socket *sock, 
-				      struct socket *newsock)
+static int dummy_socket_post_accept(struct socket *sock,
+				    struct socket *newsock)
 {
-	return;
+	return 0;
 }
 
 static int dummy_socket_sendmsg (struct socket *sock, struct msghdr *msg,
@@ -759,6 +759,12 @@ static int dummy_socket_recvmsg (struct 
 	return 0;
 }
 
+static int dummy_socket_post_recvmsg(struct socket *sock, struct msghdr *msg,
+				     int size, int flags)
+{
+	return 0;
+}
+
 static int dummy_socket_getsockname (struct socket *sock)
 {
 	return 0;
@@ -1096,6 +1102,7 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, socket_post_accept);
 	set_to_dummy_if_null(ops, socket_sendmsg);
 	set_to_dummy_if_null(ops, socket_recvmsg);
+	set_to_dummy_if_null(ops, socket_post_recvmsg);
 	set_to_dummy_if_null(ops, socket_getsockname);
 	set_to_dummy_if_null(ops, socket_getpeername);
 	set_to_dummy_if_null(ops, socket_setsockopt);
