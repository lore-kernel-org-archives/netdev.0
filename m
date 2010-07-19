From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: [PATCH] LSM: Add post accept() hook.
Date: Mon, 19 Jul 2010 13:25:25 +0900
Message-ID: <201007191325.IDI17618.VJStMOFOOLFFHQ@I-love.SAKURA.ne.jp>
References: <201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp>
	<1279441990.2476.26.camel@edumazet-laptop>
	<201007181949.IFC00070.OMHQVSFOLJFFOt@I-love.SAKURA.ne.jp>
	<20100718.142550.25115105.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: davem@davemloft.net, eric.dumazet@gmail.com, jmorris@namei.org,
	paul.moore@hp.com, sam@synack.fr, serge@hallyn.com
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20100718.142550.25115105.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> > Eric Dumazet wrote:
> >> I read this patch and could not find out if an SNMP counter was
> >> increased in the case a frame was not delivered but dropped in kernel
> >> land.
> > 
> > UDP_MIB_INDATAGRAMS and UDP_MIB_INERRORS will not be increased
> > if dropped by security_socket_post_recvmsg()'s decision.
> > Should we increment UDP_MIB_INDATAGRAMS and/or UDP_MIB_INERRORS?
> 
> This decision should be guided by what we do for in the case
> of the other existing security hooks.
> 
> I don't think it makes any sense to make the post recvmsg() hook
> behave any differently from the existing hooks in this regard.

I see. Thank you.

I was misunderstanding assumption on select() -> recvmsg() sequence.
I was thinking that:

  If select() said "read operation will not block", the caller of recvmsg() can
  assume that recvmsg() which is preceded by select() will not be blocked.
  (The caller cannot assume that subsequent recvmsg() preceded by previous
  recvmsg() will not be blocked.) Therefore, the kernel must not wait for next
  message if current message was discarded by post recvmsg LSM hook. (And I
  thought that returning error code to the caller is the only way because the
  caller might be assuming that recvmsg() preceded by select() will not be
  blocked.)

But I understood that:

  Even if select() said "read operation will not block", the caller of recvmsg()
  can't assume that recvmsg() which is preceded by select() will not be blocked
  unless MSG_DONTWAIT or O_NONBLOCK was set.
  Therefore, the kernel is allowed to wait for next message if current message
  was discarded by post recvmsg LSM hook unless MSG_DONTWAIT or O_NONBLOCK was
  set.

Now, I'm thinking the same thing for select() -> accept() sequence:

  Even if select() said "read operation will not block", the caller of accept()
  can't assume that accept() which is preceded by select() will not be blocked
  unless MSG_DONTWAIT or O_NONBLOCK was set.
  Therefore, the kernel is allowed to wait for next connection if current
  connection was discarded by post accept LSM hook unless MSG_DONTWAIT or
  O_NONBLOCK was set.

Although "security_socket_post_accept() without retry loop" was proposed
in the past ( http://lkml.org/lkml/2010/3/2/297 ), I think I can propose
"security_socket_post_accept() with retry loop" (patch attached below)
if select() -> accept() case I wrote above is correct.

I can live with "security_socket_post_accept() without retry loop" by assigning
magic value to SOCK_INODE("struct socket *")->i_security field
( tomoyo_dead_sock() in http://lkml.org/lkml/2009/10/4/56 ) but below patch is
better for me because TOMOYO will not require the i_security field (which will
make it easier to realize LSM stacking/chaining) and will not need to implement
all LSM hooks for socket operations only for checking the i_security field.

May I have your opinion for below version?

Regards.
----------------------------------------
>From 54bc4ffee7998423e8c2d3a5cc9dfc647d5a892b Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 17 Jul 2010 12:04:18 +0900
Subject: [PATCH] LSM: Add post accept() hook.

Current pre accept hook (i.e. security_socket_accept()) has two problems.

One is that it will cause eating 100% of CPU time if the caller does not
close() the socket when accept() failed due to security_socket_accept(), for
subsequent select() notifies the caller of readiness for accept() since the
connection which would have been already picked up if security_socket_accept()
did not return error is remaining in the queue.

The other is that it is racy if LSM module wants to do filtering based on
"which process can pick up connections from which source" because the process
which picks up the connection is not known until sock->ops->accept() and lock
is not held between security_socket_accept() and sock->ops->accept.

This patch introduces post accept hook (i.e. security_socket_post_accept()) in
order to solve above problems at the cost of ability to pick up the connection
which would have been picked up if preceding security_socket_post_accept() did
not return error.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 include/linux/security.h |   21 +++++++++++++++++++++
 net/socket.c             |    7 +++++++
 security/capability.c    |    6 ++++++
 security/security.c      |    5 +++++
 4 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 409c44d..2ed73c1 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -866,6 +866,19 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@sock contains the listening socket structure.
  *	@newsock contains the newly created server socket for connection.
  *	Return 0 if permission is granted.
+ * @socket_post_accept:
+ *	Check permission after accepting a new connection.
+ *	The connection is discarded if permission is not granted.
+ *	Return 0 after updating security information on the socket if you want
+ *	to restrict some of socket syscalls on the connection (e.g. forbid only
+ *	sending data). But you can't use this hook for updating security
+ *	information of the socket for preventing the connection from receiving
+ *	incoming data, for the kernel already started receiving incoming data
+ *	before accept() syscall. Return error if updating security information
+ *	failed or you want to forbid all of socket syscalls on the connection.
+ *	@sock contains the listening socket structure.
+ *	@newsock contains the accepted socket structure.
+ *	Return 0 if permission is granted.
  * @socket_sendmsg:
  *	Check permission before transmitting a message to another socket.
  *	@sock contains the socket structure.
@@ -1577,6 +1590,7 @@ struct security_operations {
 			       struct sockaddr *address, int addrlen);
 	int (*socket_listen) (struct socket *sock, int backlog);
 	int (*socket_accept) (struct socket *sock, struct socket *newsock);
+	int (*socket_post_accept) (struct socket *sock, struct socket *newsock);
 	int (*socket_sendmsg) (struct socket *sock,
 			       struct msghdr *msg, int size);
 	int (*socket_recvmsg) (struct socket *sock,
@@ -2530,6 +2544,7 @@ int security_socket_bind(struct socket *sock, struct sockaddr *address, int addr
 int security_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen);
 int security_socket_listen(struct socket *sock, int backlog);
 int security_socket_accept(struct socket *sock, struct socket *newsock);
+int security_socket_post_accept(struct socket *sock, struct socket *newsock);
 int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size);
 int security_socket_recvmsg(struct socket *sock, struct msghdr *msg,
 			    int size, int flags);
@@ -2612,6 +2627,12 @@ static inline int security_socket_accept(struct socket *sock,
 	return 0;
 }
 
+static inline int security_socket_post_accept(struct socket *sock,
+					      struct socket *newsock)
+{
+	return 0;
+}
+
 static inline int security_socket_sendmsg(struct socket *sock,
 					  struct msghdr *msg, int size)
 {
diff --git a/net/socket.c b/net/socket.c
index 367d547..97d644c 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1473,6 +1473,7 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	if (!sock)
 		goto out;
 
+ retry:
 	err = -ENFILE;
 	if (!(newsock = sock_alloc()))
 		goto out_put;
@@ -1500,6 +1501,12 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	err = sock->ops->accept(sock, newsock, sock->file->f_flags);
 	if (err < 0)
 		goto out_fd;
+	err = security_socket_post_accept(sock, newsock);
+	if (unlikely(err)) {
+		fput(newfile);
+		put_unused_fd(newfd);
+		goto retry;
+	}
 
 	if (upeer_sockaddr) {
 		if (newsock->ops->getname(newsock, (struct sockaddr *)&address,
diff --git a/security/capability.c b/security/capability.c
index 709aea3..1fb88f5 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -586,6 +586,11 @@ static int cap_socket_accept(struct socket *sock, struct socket *newsock)
 	return 0;
 }
 
+static int cap_socket_post_accept(struct socket *sock, struct socket *newsock)
+{
+	return 0;
+}
+
 static int cap_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size)
 {
 	return 0;
@@ -1004,6 +1009,7 @@ void __init security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, socket_connect);
 	set_to_cap_if_null(ops, socket_listen);
 	set_to_cap_if_null(ops, socket_accept);
+	set_to_cap_if_null(ops, socket_post_accept);
 	set_to_cap_if_null(ops, socket_sendmsg);
 	set_to_cap_if_null(ops, socket_recvmsg);
 	set_to_cap_if_null(ops, socket_post_recvmsg);
diff --git a/security/security.c b/security/security.c
index 4291bd7..5c9ab0a 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1026,6 +1026,11 @@ int security_socket_accept(struct socket *sock, struct socket *newsock)
 	return security_ops->socket_accept(sock, newsock);
 }
 
+int security_socket_post_accept(struct socket *sock, struct socket *newsock)
+{
+	return security_ops->socket_post_accept(sock, newsock);
+}
+
 int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size)
 {
 	return security_ops->socket_sendmsg(sock, msg, size);
-- 
1.6.1
