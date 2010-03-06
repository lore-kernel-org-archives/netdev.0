From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC v2 00/10] snet: Security for NETwork syscalls
Date: Sat, 06 Mar 2010 19:40:02 +0100
Message-ID: <m2zl2lpa4d.fsf@ssh.synack.fr>
References: <1267561394-13626-1-git-send-email-sam@synack.fr>
	<201003030156.o231udx1023055@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, hadi@cyberus.ca, kaber@trash.net,
	zbr@ioremap.net, nhorman@tuxdriver.com, root@localdomain.pl,
	linux-security-module@vger.kernel.org,
	Serge Hallyn <serue@us.ibm.com>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <201003030156.o231udx1023055@www262.sakura.ne.jp> (Tetsuo Handa's
	message of "Wed, 03 Mar 2010 10:56:39 +0900")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Regarding [RFC v2 02/10] Revert "lsm: Remove the socket_post_accept() hook"
> @@ -1538,6 +1538,8 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
>  	fd_install(newfd, newfile);
>  	err = newfd;
>  
> +	security_socket_post_accept(sock, newsock);
> +
>  out_put:
>  	fput_light(sock->file, fput_needed);
>  out:
>
> Please move security_socket_post_accept() to before fd_install().
> Otherwise, other threads which share fd tables can use
> security-informations-not-yet-updated accept()ed sockets.

Tetsuo, what about this patch ?

>From 6bbae933058e5f0857e9d7c1a720f9d09080474e Mon Sep 17 00:00:00 2001
From: Samir Bellabes <sam@synack.fr>
Date: Fri, 1 Jan 2010 03:24:52 +0100
Subject: [PATCH] lsm: add security_post_accept() hook

snet need to reintroduce this hook, as it was designed to be: a hook for
updating security informations on objects.

This patch is the result of :
     Revert "lsm: Remove the socket_post_accept() hook"
     the revert of 8651d5c0b1f874c5b8307ae2b858bc40f9f02482.

and the comment of Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> :

> Please move security_socket_post_accept() to before fd_install().
> Otherwise, other threads which share fd tables can use
> security-informations-not-yet-updated accept()ed sockets.

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 include/linux/security.h |   13 +++++++++++++
 net/socket.c             |    2 ++
 security/capability.c    |    5 +++++
 security/security.c      |    5 +++++
 4 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 74e564b..d8ad624 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -938,6 +938,11 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@sock contains the listening socket structure.
  *	@newsock contains the newly created server socket for connection.
  *	Return 0 if permission is granted.
+ * @socket_post_accept:
+ *	This hook allows a security module to copy security
+ *	information into the newly created socket's inode.
+ *	@sock contains the listening socket structure.
+ *	@newsock contains the newly created server socket for connection.
  * @socket_sendmsg:
  *	Check permission before transmitting a message to another socket.
  *	@sock contains the socket structure.
@@ -1674,6 +1679,8 @@ struct security_operations {
 			       struct sockaddr *address, int addrlen);
 	int (*socket_listen) (struct socket *sock, int backlog);
 	int (*socket_accept) (struct socket *sock, struct socket *newsock);
+	void (*socket_post_accept) (struct socket *sock,
+				    struct socket *newsock);
 	int (*socket_sendmsg) (struct socket *sock,
 			       struct msghdr *msg, int size);
 	int (*socket_recvmsg) (struct socket *sock,
@@ -2696,6 +2703,7 @@ int security_socket_bind(struct socket *sock, struct sockaddr *address, int addr
 int security_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen);
 int security_socket_listen(struct socket *sock, int backlog);
 int security_socket_accept(struct socket *sock, struct socket *newsock);
+void security_socket_post_accept(struct socket *sock, struct socket *newsock);
 int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size);
 int security_socket_recvmsg(struct socket *sock, struct msghdr *msg,
 			    int size, int flags);
@@ -2778,6 +2786,11 @@ static inline int security_socket_accept(struct socket *sock,
 	return 0;
 }
 
+static inline void security_socket_post_accept(struct socket *sock,
+					       struct socket *newsock)
+{
+}
+
 static inline int security_socket_sendmsg(struct socket *sock,
 					  struct msghdr *msg, int size)
 {
diff --git a/net/socket.c b/net/socket.c
index b4eb361..384e23d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1533,6 +1533,8 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 			goto out_fd;
 	}
 
+	security_socket_post_accept(sock, newsock);
+
 	/* File flags are not inherited via accept() unlike another OSes. */
 
 	fd_install(newfd, newfile);
diff --git a/security/capability.c b/security/capability.c
index a9810dc..61eae40 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -641,6 +641,10 @@ static int cap_socket_accept(struct socket *sock, struct socket *newsock)
 	return 0;
 }
 
+static void cap_socket_post_accept(struct socket *sock, struct socket *newsock)
+{
+}
+
 static int cap_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size)
 {
 	return 0;
@@ -1081,6 +1085,7 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, socket_connect);
 	set_to_cap_if_null(ops, socket_listen);
 	set_to_cap_if_null(ops, socket_accept);
+	set_to_cap_if_null(ops, socket_post_accept);
 	set_to_cap_if_null(ops, socket_sendmsg);
 	set_to_cap_if_null(ops, socket_recvmsg);
 	set_to_cap_if_null(ops, socket_getsockname);
diff --git a/security/security.c b/security/security.c
index 288c3a8..673979f 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1082,6 +1082,11 @@ int security_socket_accept(struct socket *sock, struct socket *newsock)
 	return security_ops->socket_accept(sock, newsock);
 }
 
+void security_socket_post_accept(struct socket *sock, struct socket *newsock)
+{
+	security_ops->socket_post_accept(sock, newsock);
+}
+
 int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size)
 {
 	return security_ops->socket_sendmsg(sock, msg, size);
-- 
1.6.2.5

