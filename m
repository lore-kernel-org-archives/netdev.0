From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH] l2tp: prevent l2tp_tunnel_delete racing with userspace close
Date: Tue, 22 Jan 2013 15:13:48 +0000
Message-ID: <1358867628-21217-1-git-send-email-tparkin@katalix.com>
Cc: celston@katalix.com, Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:41496 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753227Ab3AVPOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 10:14:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a tunnel socket is created by userspace, l2tp hooks the socket destructor
in order to clean up resources if userspace closes the socket or crashes.  It
also caches a pointer to the struct sock for use in the data path and in the
netlink interface.

While it is safe to use the cached sock pointer in the data path, where the
skb references keep the socket alive, it is not safe to use it elsewhere as
such access introduces a race with userspace closing the socket.  In
particular, l2tp_tunnel_delete is prone to oopsing if a multithreaded
userspace application closes a socket at the same time as sending a netlink
delete command for the tunnel.

This patch fixes this oops by forcing l2tp_tunnel_delete to explicitly look up
a tunnel socket held by userspace using sockfd_lookup().

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   76 ++++++++++++++++++++++++++++++++++++++++++--------
 net/l2tp/l2tp_core.h |    5 +++-
 2 files changed, 69 insertions(+), 12 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 1a9f372..06389d5 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -168,6 +168,51 @@ l2tp_session_id_hash_2(struct l2tp_net *pn, u32 session_id)
 
 }
 
+/* Lookup the tunnel socket, possibly involving the fs code if the socket is
+ * owned by userspace.  A struct sock returned from this function must be
+ * released using l2tp_tunnel_sock_put once you're done with it.
+ */
+struct sock *l2tp_tunnel_sock_lookup(struct l2tp_tunnel *tunnel)
+{
+	int err = 0;
+	struct socket *sock = NULL;
+	struct sock *sk = NULL;
+
+	if (!tunnel)
+		goto out;
+
+	if (tunnel->fd >= 0) {
+		/* Socket is owned by userspace, who might be in the process
+		 * of closing it.  Look the socket up using the fd to ensure
+		 * consistency.
+		 */
+		sock = sockfd_lookup(tunnel->fd, &err);
+		if (sock)
+			sk = sock->sk;
+	} else {
+		/* Socket is owned by kernelspace */
+		sk = tunnel->sock;
+	}
+
+out:
+	return sk;
+}
+EXPORT_SYMBOL_GPL(l2tp_tunnel_sock_lookup);
+
+/* Drop a reference to a tunnel socket obtained via. l2tp_tunnel_sock_put */
+void l2tp_tunnel_sock_put(struct sock *sk)
+{
+	struct l2tp_tunnel *tunnel = l2tp_sock_to_tunnel(sk);
+	if (tunnel) {
+		if (tunnel->fd >= 0) {
+			/* Socket is owned by userspace */
+			sockfd_put(sk->sk_socket);
+		}
+		sock_put(sk);
+	}
+}
+EXPORT_SYMBOL_GPL(l2tp_tunnel_sock_put);
+
 /* Lookup a session by id in the global session list
  */
 static struct l2tp_session *l2tp_session_find_2(struct net *net, u32 session_id)
@@ -1607,6 +1652,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	tunnel->old_sk_destruct = sk->sk_destruct;
 	sk->sk_destruct = &l2tp_tunnel_destruct;
 	tunnel->sock = sk;
+	tunnel->fd = fd;
 	lockdep_set_class_and_name(&sk->sk_lock.slock, &l2tp_socket_class, "l2tp_sock");
 
 	sk->sk_allocation = GFP_ATOMIC;
@@ -1642,24 +1688,32 @@ EXPORT_SYMBOL_GPL(l2tp_tunnel_create);
  */
 int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
 {
-	int err = 0;
-	struct socket *sock = tunnel->sock ? tunnel->sock->sk_socket : NULL;
+	int err = -EBADF;
+	struct socket *sock = NULL;
+	struct sock *sk = NULL;
+
+	sk = l2tp_tunnel_sock_lookup(tunnel);
+	if (!sk)
+		goto out;
+
+	sock = sk->sk_socket;
+	BUG_ON(!sock);
 
 	/* Force the tunnel socket to close. This will eventually
 	 * cause the tunnel to be deleted via the normal socket close
 	 * mechanisms when userspace closes the tunnel socket.
 	 */
-	if (sock != NULL) {
-		err = inet_shutdown(sock, 2);
+	err = inet_shutdown(sock, 2);
 
-		/* If the tunnel's socket was created by the kernel,
-		 * close the socket here since the socket was not
-		 * created by userspace.
-		 */
-		if (sock->file == NULL)
-			err = inet_release(sock);
-	}
+	/* If the tunnel's socket was created by the kernel,
+	 * close the socket here since the socket was not
+	 * created by userspace.
+	 */
+	if (sock->file == NULL)
+		err = inet_release(sock);
 
+	l2tp_tunnel_sock_put(sk);
+out:
 	return err;
 }
 EXPORT_SYMBOL_GPL(l2tp_tunnel_delete);
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 56d583e..e62204c 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -188,7 +188,8 @@ struct l2tp_tunnel {
 	int (*recv_payload_hook)(struct sk_buff *skb);
 	void (*old_sk_destruct)(struct sock *);
 	struct sock		*sock;		/* Parent socket */
-	int			fd;
+	int			fd;		/* Parent fd, if tunnel socket
+						 * was created by userspace */
 
 	uint8_t			priv[0];	/* private data */
 };
@@ -228,6 +229,8 @@ out:
 	return tunnel;
 }
 
+extern struct sock *l2tp_tunnel_sock_lookup(struct l2tp_tunnel *tunnel);
+extern void l2tp_tunnel_sock_put(struct sock *sk);
 extern struct l2tp_session *l2tp_session_find(struct net *net, struct l2tp_tunnel *tunnel, u32 session_id);
 extern struct l2tp_session *l2tp_session_find_nth(struct l2tp_tunnel *tunnel, int nth);
 extern struct l2tp_session *l2tp_session_find_by_ifname(struct net *net, char *ifname);
-- 
1.7.9.5
