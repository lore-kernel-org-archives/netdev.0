From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH net-2.6.25] Add packet filtering based on process's security context.
Date: Mon, 31 Dec 2007 15:21:43 +0900
Message-ID: <200712311521.FEJ73416.FQFFtMOHSVOOLJ@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sam@synack.fr
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

This is a repost of a patch submitted at http://lkml.org/lkml/2007/11/19/545 .

Current status is that I'm waiting for Samir Bellabes's answer
whether we can handle the following example without this patch.

Tetsuo Handa wrote:
> Hello.
> 
> Samir Bellabes wrote:
> > >> what differences between you approach and netfilter in this case ? if
> > >> it's about packet filtering, you already have all you wishes in
> > >> netfilter project.
> > > Except a hook for making decision with the name of process who picks that packet up known.
> > 
> > I think that we really don't need it, because we can catch the
> > informations as I explained.
> 
> Well, I haven't understood yet why we don't need it.
> 
> How can you know the the name of process who copies that datagram to its userspace memory?
> A socket may be shared by multiple different executable files,
> so the name of the executable file is not known until
> one of processes who share the socket issues accept()/recvmsg() syscall.
> 
> Are you saying that I should not use the name of the executable file?
> 
> Regards.
> 

Tetsuo Handa wrote:
> Hello.
> 
> I made an example.
> 
> Usage:
> 
>   Compile app1 and app2 and run /tmp/app1 .
> 
>   Run something like
>    curl http://localhost:10000/
>   to connect to /tmp/app1.
> 
> I want to know that */tmp/app2* accepts TCP connection
> so that the user can control
> whether this TCP connection from 127.0.0.1 port N
> should be accepted by */tmp/app2* or not.
> 
> How can we do this without socket_post_accept() change?
> 
> Regards.
> 
> ---------- app1.c start ----------
> /* gcc -Wall -O2 -o /tmp/app1 app1.c */
> #include <fcntl.h>
> #include <netinet/in.h>
> #include <stdio.h>
> #include <string.h>
> #include <sys/select.h>
> #include <sys/socket.h>
> #include <sys/types.h>
> #include <unistd.h>
> 
> int main(int argc, char *argv[]) {
> 	const int fd = socket(PF_INET, SOCK_STREAM, 0);
> 	struct sockaddr_in addr;
> 	char buf[16];
> 	memset(&addr, 0, sizeof(addr));
> 	addr.sin_family = AF_INET;
> 	addr.sin_addr.s_addr = htonl(INADDR_ANY);
> 	addr.sin_port = htons(10000);
> 	fprintf(stderr, "%s started.\n", argv[0]);
> 	if (bind(fd, (struct sockaddr *) &addr, sizeof(addr))) {
> 		fprintf(stderr, "Can't bind()\n");
> 		return 1;
> 	} else if (listen(fd, 5)) {
> 		fprintf(stderr, "Can't listen()\n");
> 		return 1;
> 	}
> 	while (1) {
> 		fd_set rfds;
> 		FD_ZERO(&rfds);
> 		FD_SET(fd, &rfds);
> 		select(fd + 1, &rfds, NULL, NULL, NULL);
> 		if (FD_ISSET(fd, &rfds)) break;
> 		fprintf(stderr, "Can't select()\n");
> 		return 1;
> 	}
> 	if (fcntl(fd, FD_CLOEXEC, 0)) {
> 		fprintf(stderr, "Can't fcntl()\n");
> 		return 1;
> 	}
> 	snprintf(buf, sizeof(buf), "%d", fd);
> 	execlp("/tmp/app2", "app2", buf, NULL);
> 	fprintf(stderr, "Can't execve()\n");
> 	return 1;
> }
> ---------- app1.c end ----------
> 
> ---------- app2.c start ----------
> /* gcc -Wall -O2 -o /tmp/app2 app2.c */
> #include <netinet/in.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <sys/socket.h>
> #include <sys/types.h>
> #include <unistd.h>
> 
> int main(int argc, char *argv[]) {
> 	int lfd;
> 	if (argc != 2) {
> 		fprintf(stderr, "Bad parameter.\n");
> 		return 1;
> 	}
> 	fprintf(stderr, "%s started.\n", argv[0]);
> 	lfd = atoi(argv[1]);
> 	while (1) {
> 		struct sockaddr_in addr;
> 		socklen_t size = sizeof(addr);
> 		int fd = accept(lfd, (struct sockaddr *) &addr, &size);
> 		char c;
> 		if (fd == EOF) {
> 			fprintf(stderr, "Can't accept()\n");
> 			return 1;
> 		}
> 		while (read(fd, &c, 1) == 1 && write(fd, &c, 1) == 1);
> 		close(fd);
> 	}
> 	return 0;
> }
> ---------- app2.c end ----------
> 

Regards.
----------
Subject: Add packet filtering based on process's security context.

This patch allows LSM modules filter incoming connections/datagrams
based on the process's security context who is attempting to pick up.

There are already hooks to filter incoming connections/datagrams
based on the socket's security context, but these hooks are not
applicable when one wants to do TCP Wrapper-like filtering
(e.g. App1 is permitted to accept TCP connections from 192.168.0.0/16).

Precautions: This approach has a side effect which unlikely occurs.

If a socket is shared by multiple processes with differnt policy,
the process who should be able to accept this connection
will not be able to accept this connection
because socket_post_accept() aborts this connection.
But if socket_post_accept() doesn't abort this connection,
the process who must not be able to accept this connection
will repeat accept() forever, which is a worse side effect.

Similarly, if a socket is shared by multiple processes with differnt policy,
the process who should be able to pick up this datagram
will not be able to pick up this datagram
because socket_post_recv_datagram() discards this datagram.
But if socket_post_recv_datagram() doesn't discard this datagram,
the process who must not be able to pick up this datagram
will repeat recvmsg() forever, which is a worse side effect.

So, don't give different permissions between processes who shares one socket.
Otherwise, some connections/datagrams cannot be delivered to intended process.

Signed-off-by: Kentaro Takeda <takedakn@nttdata.co.jp>
Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/security.h |   34 +++++++++++++++++++++++++++++-----
 net/core/datagram.c      |   29 ++++++++++++++++++++++++++++-
 net/socket.c             |    7 +++++--
 security/dummy.c         |   13 ++++++++++---
 security/security.c      |   10 ++++++++--
 5 files changed, 80 insertions(+), 13 deletions(-)

--- net-2.6.25.orig/include/linux/security.h
+++ net-2.6.25/include/linux/security.h
@@ -781,8 +781,12 @@ struct request_sock;
  * @socket_post_accept:
  *	This hook allows a security module to copy security
  *	information into the newly created socket's inode.
+ *	This hook also allows a security module to filter connections
+ *	from unwanted peers based on the process accepting this connection.
+ *	The connection will be aborted if this hook returns nonzero.
  *	@sock contains the listening socket structure.
  *	@newsock contains the newly created server socket for connection.
+ *	Return 0 if permission is granted.
  * @socket_sendmsg:
  *	Check permission before transmitting a message to another socket.
  *	@sock contains the socket structure.
@@ -796,6 +800,15 @@ struct request_sock;
  *	@size contains the size of message structure.
  *	@flags contains the operational flags.
  *	Return 0 if permission is granted.  
+ * @socket_post_recv_datagram:
+ *	Check permission after receiving a datagram.
+ *	This hook allows a security module to filter packets
+ *	from unwanted peers based on the process receiving this datagram.
+ *	The packet will be discarded if this hook returns nonzero.
+ *	@sk contains the socket.
+ *	@skb contains the socket buffer.
+ *	@flags contains the operational flags.
+ *	Return 0 if permission is granted.
  * @socket_getsockname:
  *	Check permission before the local address (name) of the socket object
  *	@sock is retrieved.
@@ -1387,12 +1400,13 @@ struct security_operations {
 			       struct sockaddr * address, int addrlen);
 	int (*socket_listen) (struct socket * sock, int backlog);
 	int (*socket_accept) (struct socket * sock, struct socket * newsock);
-	void (*socket_post_accept) (struct socket * sock,
-				    struct socket * newsock);
+	int (*socket_post_accept) (struct socket *sock, struct socket *newsock);
 	int (*socket_sendmsg) (struct socket * sock,
 			       struct msghdr * msg, int size);
 	int (*socket_recvmsg) (struct socket * sock,
 			       struct msghdr * msg, int size, int flags);
+	int (*socket_post_recv_datagram) (struct sock *sk, struct sk_buff *skb,
+					  unsigned int flags);
 	int (*socket_getsockname) (struct socket * sock);
 	int (*socket_getpeername) (struct socket * sock);
 	int (*socket_getsockopt) (struct socket * sock, int level, int optname);
@@ -2297,10 +2311,12 @@ int security_socket_bind(struct socket *
 int security_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen);
 int security_socket_listen(struct socket *sock, int backlog);
 int security_socket_accept(struct socket *sock, struct socket *newsock);
-void security_socket_post_accept(struct socket *sock, struct socket *newsock);
+int security_socket_post_accept(struct socket *sock, struct socket *newsock);
 int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size);
 int security_socket_recvmsg(struct socket *sock, struct msghdr *msg,
 			    int size, int flags);
+int security_socket_post_recv_datagram(struct sock *sk, struct sk_buff *skb,
+				       unsigned int flags);
 int security_socket_getsockname(struct socket *sock);
 int security_socket_getpeername(struct socket *sock);
 int security_socket_getsockopt(struct socket *sock, int level, int optname);
@@ -2376,9 +2392,10 @@ static inline int security_socket_accept
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
@@ -2394,6 +2411,13 @@ static inline int security_socket_recvms
 	return 0;
 }
 
+static inline int security_socket_post_recv_datagram(struct sock *sk,
+						     struct sk_buff *skb,
+						     unsigned int flags)
+{
+	return 0;
+}
+
 static inline int security_socket_getsockname(struct socket * sock)
 {
 	return 0;
--- net-2.6.25.orig/net/socket.c
+++ net-2.6.25/net/socket.c
@@ -1454,13 +1454,16 @@ asmlinkage long sys_accept(int fd, struc
 			goto out_fd;
 	}
 
+	/* Filter connections from unwanted peers. */
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
--- net-2.6.25.orig/security/dummy.c
+++ net-2.6.25/security/dummy.c
@@ -748,10 +748,10 @@ static int dummy_socket_accept (struct s
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
@@ -766,6 +766,12 @@ static int dummy_socket_recvmsg (struct 
 	return 0;
 }
 
+static int dummy_socket_post_recv_datagram(struct sock *sk, struct sk_buff *skb,
+					   unsigned int flags)
+{
+	return 0;
+}
+
 static int dummy_socket_getsockname (struct socket *sock)
 {
 	return 0;
@@ -1099,6 +1105,7 @@ void security_fixup_ops (struct security
 	set_to_dummy_if_null(ops, socket_post_accept);
 	set_to_dummy_if_null(ops, socket_sendmsg);
 	set_to_dummy_if_null(ops, socket_recvmsg);
+	set_to_dummy_if_null(ops, socket_post_recv_datagram);
 	set_to_dummy_if_null(ops, socket_getsockname);
 	set_to_dummy_if_null(ops, socket_getpeername);
 	set_to_dummy_if_null(ops, socket_setsockopt);
--- net-2.6.25.orig/net/core/datagram.c
+++ net-2.6.25/net/core/datagram.c
@@ -55,6 +55,7 @@
 #include <net/checksum.h>
 #include <net/sock.h>
 #include <net/tcp_states.h>
+#include <linux/security.h>
 
 /*
  *	Is a socket 'connection oriented' ?
@@ -148,6 +149,7 @@ struct sk_buff *__skb_recv_datagram(stru
 {
 	struct sk_buff *skb;
 	long timeo;
+	unsigned long cpu_flags;
 	/*
 	 * Caller is allowed not to check sk->sk_err before skb_recv_datagram()
 	 */
@@ -165,7 +167,6 @@ struct sk_buff *__skb_recv_datagram(stru
 		 * Look at current nfs client by the way...
 		 * However, this function was corrent in any case. 8)
 		 */
-		unsigned long cpu_flags;
 
 		spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
 		skb = skb_peek(&sk->sk_receive_queue);
@@ -179,6 +180,14 @@ struct sk_buff *__skb_recv_datagram(stru
 		}
 		spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
 
+		/* Filter packets from unwanted peers. */
+		if (skb) {
+			error = security_socket_post_recv_datagram(sk, skb,
+								   flags);
+			if (error)
+				goto force_dequeue;
+		}
+
 		if (skb)
 			return skb;
 
@@ -191,6 +200,24 @@ struct sk_buff *__skb_recv_datagram(stru
 
 	return NULL;
 
+force_dequeue:
+	/* Drop this packet because LSM says "Don't pass it to the caller". */
+	if (!(flags & MSG_PEEK))
+		goto no_peek;
+	/*
+	 * If this packet is MSG_PEEK'ed, dequeue it forcibly
+	 * so that this packet won't prevent the caller from picking up
+	 * next packet.
+	 */
+	spin_lock_irqsave(&sk->sk_receive_queue.lock, cpu_flags);
+	if (skb == skb_peek(&sk->sk_receive_queue)) {
+		__skb_unlink(skb, &sk->sk_receive_queue);
+		atomic_dec(&skb->users);
+		/* Do I have something to do with skb->peeked ? */
+	}
+	spin_unlock_irqrestore(&sk->sk_receive_queue.lock, cpu_flags);
+no_peek:
+	kfree_skb(skb);
 no_packet:
 	*err = error;
 	return NULL;
--- net-2.6.25.orig/security/security.c
+++ net-2.6.25/security/security.c
@@ -869,9 +869,9 @@ int security_socket_accept(struct socket
 	return security_ops->socket_accept(sock, newsock);
 }
 
-void security_socket_post_accept(struct socket *sock, struct socket *newsock)
+int security_socket_post_accept(struct socket *sock, struct socket *newsock)
 {
-	security_ops->socket_post_accept(sock, newsock);
+	return security_ops->socket_post_accept(sock, newsock);
 }
 
 int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size)
@@ -885,6 +885,12 @@ int security_socket_recvmsg(struct socke
 	return security_ops->socket_recvmsg(sock, msg, size, flags);
 }
 
+int security_socket_post_recv_datagram(struct sock *sk, struct sk_buff *skb,
+				       unsigned int flags)
+{
+	return security_ops->socket_post_recv_datagram(sk, skb, flags);
+}
+
 int security_socket_getsockname(struct socket *sock)
 {
 	return security_ops->socket_getsockname(sock);
