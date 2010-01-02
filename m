From: Samir Bellabes <sam@synack.fr>
Subject: [RFC 2/9] Revert "lsm: Remove the socket_post_accept() hook"
Date: Sat,  2 Jan 2010 14:04:09 +0100
Message-ID: <1262437456-24476-3-git-send-email-sam@synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
Cc: Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1262437456-24476-1-git-send-email-sam@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This reverts commit 8651d5c0b1f874c5b8307ae2b858bc40f9f02482.

snet needs to reintroduce this hook, as it was designed to be: a hook for
updating security informations on objects.

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 include/linux/security.h |   13 +++++++++++++
 net/socket.c             |    2 ++
 security/capability.c    |    5 +++++
 security/security.c      |    5 +++++
 4 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 275dd04..c12a286 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -931,6 +931,11 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
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
@@ -1667,6 +1672,8 @@ struct security_operations {
 			       struct sockaddr *address, int addrlen);
 	int (*socket_listen) (struct socket *sock, int backlog);
 	int (*socket_accept) (struct socket *sock, struct socket *newsock);
+	void (*socket_post_accept) (struct socket *sock,
+				    struct socket *newsock);
 	int (*socket_sendmsg) (struct socket *sock,
 			       struct msghdr *msg, int size);
 	int (*socket_recvmsg) (struct socket *sock,
@@ -2689,6 +2696,7 @@ int security_socket_bind(struct socket *sock, struct sockaddr *address, int addr
 int security_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen);
 int security_socket_listen(struct socket *sock, int backlog);
 int security_socket_accept(struct socket *sock, struct socket *newsock);
+void security_socket_post_accept(struct socket *sock, struct socket *newsock);
 int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size);
 int security_socket_recvmsg(struct socket *sock, struct msghdr *msg,
 			    int size, int flags);
@@ -2771,6 +2779,11 @@ static inline int security_socket_accept(struct socket *sock,
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
index 8984973..fcd4f2b 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1557,6 +1557,8 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	fd_install(newfd, newfile);
 	err = newfd;
 
+	security_socket_post_accept(sock, newsock);
+
 out_put:
 	fput_light(sock->file, fput_needed);
 out:
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
index 7457ed5..20ae0b8 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1084,6 +1084,11 @@ int security_socket_accept(struct socket *sock, struct socket *newsock)
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
1.6.3.3

