From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [PATCH v21 071/100] Add common socket helpers to unify the security hooks
Date: Sat,  1 May 2010 10:15:53 -0400
Message-ID: <1272723382-19470-72-git-send-email-orenl@cs.columbia.edu>
References: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Cc: containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>,
	Matt Helsley <matthltc@us.ibm.com>,
	Pavel Emelyanov <xemul@openvz.org>,
	Dan Smith <danms@us.ibm.com>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tarap.cc.columbia.edu ([128.59.29.7]:64055 "EHLO
	tarap.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755042Ab0EAOgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 10:36:09 -0400
In-Reply-To: <1272723382-19470-1-git-send-email-orenl@cs.columbia.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Smith <danms@us.ibm.com>

This moves the meat out of the bind(), getsockname(), and getpeername() syscalls
into helper functions that performs security_socket_bind() and then the
sock->ops->call().  This allows a unification of this behavior between the
syscalls and the pending socket restart logic.

Cc: netdev@vger.kernel.org
Signed-off-by: Dan Smith <danms@us.ibm.com>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/net/sock.h |   48 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/socket.c       |   29 ++++++-----------------------
 2 files changed, 54 insertions(+), 23 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index b4603cd..3cf7de4 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1645,6 +1645,54 @@ extern void sock_enable_timestamp(struct sock *sk, int flag);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
 extern int sock_get_timestampns(struct sock *, struct timespec __user *);
 
+/* bind() helper shared between any callers needing to perform a bind on
+ * behalf of userspace (syscall and restart) with the security hooks.
+ */
+static inline int sock_bind(struct socket *sock,
+			    struct sockaddr *addr,
+			    int addr_len)
+{
+	int err;
+
+	err = security_socket_bind(sock, addr, addr_len);
+	if (err)
+		return err;
+	else
+		return sock->ops->bind(sock, addr, addr_len);
+}
+
+/* getname() helper shared between any callers needing to perform a getname on
+ * behalf of userspace (syscall and restart) with the security hooks.
+ */
+static inline int sock_getname(struct socket *sock,
+			       struct sockaddr *addr,
+			       int *addr_len)
+{
+	int err;
+
+	err = security_socket_getsockname(sock);
+	if (err)
+		return err;
+	else
+		return sock->ops->getname(sock, addr, addr_len, 0);
+}
+
+/* getpeer() helper shared between any callers needing to perform a getpeer on
+ * behalf of userspace (syscall and restart) with the security hooks.
+ */
+static inline int sock_getpeer(struct socket *sock,
+			       struct sockaddr *addr,
+			       int *addr_len)
+{
+	int err;
+
+	err = security_socket_getpeername(sock);
+	if (err)
+		return err;
+	else
+		return sock->ops->getname(sock, addr, addr_len, 1);
+}
+
 /* 
  *	Enable debug/info messages 
  */
diff --git a/net/socket.c b/net/socket.c
index 5e8d0af..b9f421b 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1422,15 +1422,10 @@ SYSCALL_DEFINE3(bind, int, fd, struct sockaddr __user *, umyaddr, int, addrlen)
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (sock) {
 		err = move_addr_to_kernel(umyaddr, addrlen, (struct sockaddr *)&address);
-		if (err >= 0) {
-			err = security_socket_bind(sock,
-						   (struct sockaddr *)&address,
-						   addrlen);
-			if (!err)
-				err = sock->ops->bind(sock,
-						      (struct sockaddr *)
-						      &address, addrlen);
-		}
+		if (err >= 0)
+			err = sock_bind(sock,
+					(struct sockaddr *)&address,
+					addrlen);
 		fput_light(sock->file, fput_needed);
 	}
 	return err;
@@ -1609,11 +1604,7 @@ SYSCALL_DEFINE3(getsockname, int, fd, struct sockaddr __user *, usockaddr,
 	if (!sock)
 		goto out;
 
-	err = security_socket_getsockname(sock);
-	if (err)
-		goto out_put;
-
-	err = sock->ops->getname(sock, (struct sockaddr *)&address, &len, 0);
+	err = sock_getname(sock, (struct sockaddr *)&address, &len);
 	if (err)
 		goto out_put;
 	err = move_addr_to_user((struct sockaddr *)&address, len, usockaddr, usockaddr_len);
@@ -1638,15 +1629,7 @@ SYSCALL_DEFINE3(getpeername, int, fd, struct sockaddr __user *, usockaddr,
 
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (sock != NULL) {
-		err = security_socket_getpeername(sock);
-		if (err) {
-			fput_light(sock->file, fput_needed);
-			return err;
-		}
-
-		err =
-		    sock->ops->getname(sock, (struct sockaddr *)&address, &len,
-				       1);
+		err = sock_getpeer(sock, (struct sockaddr *)&address, &len);
 		if (!err)
 			err = move_addr_to_user((struct sockaddr *)&address, len, usockaddr,
 						usockaddr_len);
-- 
1.6.3.3

