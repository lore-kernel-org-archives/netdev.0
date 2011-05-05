From: y@vger.kernel.org
Subject: [RFC v4 02/11] lsm: reintroduce security_socket_post_accept()
Date: Thu,  5 May 2011 15:59:12 +0200
Message-ID: <12364.1406921253$1304604540@news.gmane.org>
References: <1304603961-2517-1-git-send-email-y>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1304603961-2517-1-git-send-email-y>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samir Bellabes <sam@synack.fr>

snet needs to reintroduce this hook, as it was designed to be: a hook for
updating security informations on objects.

Originally, This was a direct revert of commit
8651d5c0b1f874c5b8307ae2b858bc40f9f02482.

But from the comment of Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> :

> Please move security_socket_post_accept() to before fd_install().
> Otherwise, other threads which share fd tables can use
> security-informations-not-yet-updated accept()ed sockets.

Signed-off-by: Samir Bellabes <sam@synack.fr>
Acked-by: Serge Hallyn <serue@us.ibm.com>
---
 include/linux/security.h |   13 +++++++++++++
 net/socket.c             |    2 ++
 security/capability.c    |    5 +++++
 security/security.c      |    5 +++++
 4 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index da0d59e..02effe5 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -875,6 +875,11 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
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
@@ -1587,6 +1592,8 @@ struct security_operations {
 			       struct sockaddr *address, int addrlen);
 	int (*socket_listen) (struct socket *sock, int backlog);
 	int (*socket_accept) (struct socket *sock, struct socket *newsock);
+	void (*socket_post_accept) (struct socket *sock,
+				    struct socket *newsock);
 	int (*socket_sendmsg) (struct socket *sock,
 			       struct msghdr *msg, int size);
 	int (*socket_recvmsg) (struct socket *sock,
@@ -2555,6 +2562,7 @@ int security_socket_bind(struct socket *sock, struct sockaddr *address, int addr
 int security_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen);
 int security_socket_listen(struct socket *sock, int backlog);
 int security_socket_accept(struct socket *sock, struct socket *newsock);
+void security_socket_post_accept(struct socket *sock, struct socket *newsock);
 int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size);
 int security_socket_recvmsg(struct socket *sock, struct msghdr *msg,
 			    int size, int flags);
@@ -2640,6 +2648,11 @@ static inline int security_socket_accept(struct socket *sock,
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
index d588e9e..7807904 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1535,6 +1535,8 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 			goto out_fd;
 	}
 
+	security_socket_post_accept(sock, newsock);
+
 	/* File flags are not inherited via accept() unlike another OSes. */
 
 	fd_install(newfd, newfile);
diff --git a/security/capability.c b/security/capability.c
index 1f8bbe2..da68c60 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -593,6 +593,10 @@ static int cap_socket_accept(struct socket *sock, struct socket *newsock)
 	return 0;
 }
 
+static void cap_socket_post_accept(struct socket *sock, struct socket *newsock)
+{
+}
+
 static int cap_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size)
 {
 	return 0;
@@ -1022,6 +1026,7 @@ void __init security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, socket_connect);
 	set_to_cap_if_null(ops, socket_listen);
 	set_to_cap_if_null(ops, socket_accept);
+	set_to_cap_if_null(ops, socket_post_accept);
 	set_to_cap_if_null(ops, socket_sendmsg);
 	set_to_cap_if_null(ops, socket_recvmsg);
 	set_to_cap_if_null(ops, socket_getsockname);
diff --git a/security/security.c b/security/security.c
index 84187d8..eda2b75 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1038,6 +1038,11 @@ int security_socket_accept(struct socket *sock, struct socket *newsock)
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
1.7.4.1

