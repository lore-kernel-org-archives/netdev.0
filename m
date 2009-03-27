From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH 4/6] lsm: Remove the socket_post_accept() hook
Date: Fri, 27 Mar 2009 17:10:48 -0400
Message-ID: <20090327211048.17777.42267.stgit@flek.lan>
References: <20090327205520.17777.32557.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, casey@schaufler-ca.com,
	etienne.basset@numericable.fr
To: linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20090327205520.17777.32557.stgit@flek.lan>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The socket_post_accept() hook is not currently used by any in-tree modules
and its existence continues to cause problems by confusing people about
what can be safely accomplished using this hook.  If a legitimate need for
this hook arises in the future it can always be reintroduced.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---

 include/linux/security.h |   13 -------------
 net/socket.c             |    2 --
 security/capability.c    |    5 -----
 security/security.c      |    5 -----
 4 files changed, 0 insertions(+), 25 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 1f2ab63..54ed157 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -880,11 +880,6 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
  *	@sock contains the listening socket structure.
  *	@newsock contains the newly created server socket for connection.
  *	Return 0 if permission is granted.
- * @socket_post_accept:
- *	This hook allows a security module to copy security
- *	information into the newly created socket's inode.
- *	@sock contains the listening socket structure.
- *	@newsock contains the newly created server socket for connection.
  * @socket_sendmsg:
  *	Check permission before transmitting a message to another socket.
  *	@sock contains the socket structure.
@@ -1554,8 +1549,6 @@ struct security_operations {
 			       struct sockaddr *address, int addrlen);
 	int (*socket_listen) (struct socket *sock, int backlog);
 	int (*socket_accept) (struct socket *sock, struct socket *newsock);
-	void (*socket_post_accept) (struct socket *sock,
-				    struct socket *newsock);
 	int (*socket_sendmsg) (struct socket *sock,
 			       struct msghdr *msg, int size);
 	int (*socket_recvmsg) (struct socket *sock,
@@ -2537,7 +2530,6 @@ int security_socket_bind(struct socket *sock, struct sockaddr *address, int addr
 int security_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen);
 int security_socket_listen(struct socket *sock, int backlog);
 int security_socket_accept(struct socket *sock, struct socket *newsock);
-void security_socket_post_accept(struct socket *sock, struct socket *newsock);
 int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size);
 int security_socket_recvmsg(struct socket *sock, struct msghdr *msg,
 			    int size, int flags);
@@ -2616,11 +2608,6 @@ static inline int security_socket_accept(struct socket *sock,
 	return 0;
 }
 
-static inline void security_socket_post_accept(struct socket *sock,
-					       struct socket *newsock)
-{
-}
-
 static inline int security_socket_sendmsg(struct socket *sock,
 					  struct msghdr *msg, int size)
 {
diff --git a/net/socket.c b/net/socket.c
index af0205f..5d288d1 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1536,8 +1536,6 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr __user *, upeer_sockaddr,
 	fd_install(newfd, newfile);
 	err = newfd;
 
-	security_socket_post_accept(sock, newsock);
-
 out_put:
 	fput_light(sock->file, fput_needed);
 out:
diff --git a/security/capability.c b/security/capability.c
index c545bd1..21b6cea 100644
--- a/security/capability.c
+++ b/security/capability.c
@@ -620,10 +620,6 @@ static int cap_socket_accept(struct socket *sock, struct socket *newsock)
 	return 0;
 }
 
-static void cap_socket_post_accept(struct socket *sock, struct socket *newsock)
-{
-}
-
 static int cap_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size)
 {
 	return 0;
@@ -1014,7 +1010,6 @@ void security_fixup_ops(struct security_operations *ops)
 	set_to_cap_if_null(ops, socket_connect);
 	set_to_cap_if_null(ops, socket_listen);
 	set_to_cap_if_null(ops, socket_accept);
-	set_to_cap_if_null(ops, socket_post_accept);
 	set_to_cap_if_null(ops, socket_sendmsg);
 	set_to_cap_if_null(ops, socket_recvmsg);
 	set_to_cap_if_null(ops, socket_getsockname);
diff --git a/security/security.c b/security/security.c
index c3586c0..206e538 100644
--- a/security/security.c
+++ b/security/security.c
@@ -1007,11 +1007,6 @@ int security_socket_accept(struct socket *sock, struct socket *newsock)
 	return security_ops->socket_accept(sock, newsock);
 }
 
-void security_socket_post_accept(struct socket *sock, struct socket *newsock)
-{
-	security_ops->socket_post_accept(sock, newsock);
-}
-
 int security_socket_sendmsg(struct socket *sock, struct msghdr *msg, int size)
 {
 	return security_ops->socket_sendmsg(sock, msg, size);

