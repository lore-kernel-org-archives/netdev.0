From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 4/4] l2tp: create tunnel sockets in the right namespace
Date: Fri,  1 Feb 2013 09:43:03 +0000
Message-ID: <1359711783-4379-5-git-send-email-tparkin@katalix.com>
References: <1359711783-4379-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:36159 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756267Ab3BAJnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 04:43:14 -0500
In-Reply-To: <1359711783-4379-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating unmanaged tunnel sockets we should honour the network namespace
passed to l2tp_tunnel_create.  Furthermore, unmanaged tunnel sockets should
not hold a reference to the network namespace lest they accidentally keep
alive a namespace which should otherwise have been released.

Unmanaged tunnel sockets now drop their namespace reference via sk_change_net,
and are released in a new pernet exit callback, l2tp_exit_net.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   87 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 54 insertions(+), 33 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 60a498a..b6ba65f 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1409,18 +1409,18 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
 	sock = sk->sk_socket;
 	BUG_ON(!sock);
 
-	/* Force the tunnel socket to close. This will eventually
-	 * cause the tunnel to be deleted via the normal socket close
-	 * mechanisms when userspace closes the tunnel socket.
+	/* If the tunnel socket was created directly by the kernel, use the
+	 * sk_* API to release the socket now.  Otherwise go through the
+	 * inet_* layer to shut the socket down, and let userspace close it.
+	 * In either case the tunnel resources are freed in the socket
+	 * destructor when the tunnel socket goes away.
 	 */
-	inet_shutdown(sock, 2);
-
-	/* If the tunnel's socket was created by the kernel,
-	 * close the socket here since the socket was not
-	 * created by userspace.
-	 */
-	if (sock->file == NULL)
-		inet_release(sock);
+	if (sock->file == NULL) {
+		kernel_sock_shutdown(sock, SHUT_RDWR);
+		sk_release_kernel(sk);
+	} else {
+		inet_shutdown(sock, 2);
+	}
 
 	l2tp_tunnel_sock_put(sk);
 }
@@ -1428,29 +1428,37 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
 /* Create a socket for the tunnel, if one isn't set up by
  * userspace. This is used for static tunnels where there is no
  * managing L2TP daemon.
+ *
+ * Since we don't want these sockets to keep a namespace alive by
+ * themselves, we drop the socket's namespace refcount after creation.
+ * These sockets are freed when the namespace exits using the pernet
+ * exit hook.
  */
-static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2tp_tunnel_cfg *cfg, struct socket **sockp)
+static int l2tp_tunnel_sock_create(struct net *net,
+				u32 tunnel_id,
+				u32 peer_tunnel_id,
+				struct l2tp_tunnel_cfg *cfg,
+				struct socket **sockp)
 {
 	int err = -EINVAL;
-	struct sockaddr_in udp_addr;
+	struct socket *sock = NULL;
+	struct sockaddr_in udp_addr = {0};
+	struct sockaddr_l2tpip ip_addr = {0};
 #if IS_ENABLED(CONFIG_IPV6)
-	struct sockaddr_in6 udp6_addr;
-	struct sockaddr_l2tpip6 ip6_addr;
+	struct sockaddr_in6 udp6_addr = {0};
+	struct sockaddr_l2tpip6 ip6_addr = {0};
 #endif
-	struct sockaddr_l2tpip ip_addr;
-	struct socket *sock = NULL;
 
 	switch (cfg->encap) {
 	case L2TP_ENCAPTYPE_UDP:
 #if IS_ENABLED(CONFIG_IPV6)
 		if (cfg->local_ip6 && cfg->peer_ip6) {
-			err = sock_create(AF_INET6, SOCK_DGRAM, 0, sockp);
+			err = sock_create_kern(AF_INET6, SOCK_DGRAM, 0, &sock);
 			if (err < 0)
 				goto out;
 
-			sock = *sockp;
+			sk_change_net(sock->sk, net);
 
-			memset(&udp6_addr, 0, sizeof(udp6_addr));
 			udp6_addr.sin6_family = AF_INET6;
 			memcpy(&udp6_addr.sin6_addr, cfg->local_ip6,
 			       sizeof(udp6_addr.sin6_addr));
@@ -1472,13 +1480,12 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2t
 		} else
 #endif
 		{
-			err = sock_create(AF_INET, SOCK_DGRAM, 0, sockp);
+			err = sock_create_kern(AF_INET, SOCK_DGRAM, 0, &sock);
 			if (err < 0)
 				goto out;
 
-			sock = *sockp;
+			sk_change_net(sock->sk, net);
 
-			memset(&udp_addr, 0, sizeof(udp_addr));
 			udp_addr.sin_family = AF_INET;
 			udp_addr.sin_addr = cfg->local_ip;
 			udp_addr.sin_port = htons(cfg->local_udp_port);
@@ -1505,14 +1512,13 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2t
 	case L2TP_ENCAPTYPE_IP:
 #if IS_ENABLED(CONFIG_IPV6)
 		if (cfg->local_ip6 && cfg->peer_ip6) {
-			err = sock_create(AF_INET6, SOCK_DGRAM, IPPROTO_L2TP,
-					  sockp);
+			err = sock_create_kern(AF_INET6, SOCK_DGRAM,
+					  IPPROTO_L2TP, &sock);
 			if (err < 0)
 				goto out;
 
-			sock = *sockp;
+			sk_change_net(sock->sk, net);
 
-			memset(&ip6_addr, 0, sizeof(ip6_addr));
 			ip6_addr.l2tp_family = AF_INET6;
 			memcpy(&ip6_addr.l2tp_addr, cfg->local_ip6,
 			       sizeof(ip6_addr.l2tp_addr));
@@ -1534,14 +1540,13 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2t
 		} else
 #endif
 		{
-			err = sock_create(AF_INET, SOCK_DGRAM, IPPROTO_L2TP,
-					  sockp);
+			err = sock_create_kern(AF_INET, SOCK_DGRAM,
+					  IPPROTO_L2TP, &sock);
 			if (err < 0)
 				goto out;
 
-			sock = *sockp;
+			sk_change_net(sock->sk, net);
 
-			memset(&ip_addr, 0, sizeof(ip_addr));
 			ip_addr.l2tp_family = AF_INET;
 			ip_addr.l2tp_addr = cfg->local_ip;
 			ip_addr.l2tp_conn_id = tunnel_id;
@@ -1565,8 +1570,10 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2t
 	}
 
 out:
+	*sockp = sock;
 	if ((err < 0) && sock) {
-		sock_release(sock);
+		kernel_sock_shutdown(sock, SHUT_RDWR);
+		sk_release_kernel(sock->sk);
 		*sockp = NULL;
 	}
 
@@ -1589,7 +1596,8 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	 * kernel socket.
 	 */
 	if (fd < 0) {
-		err = l2tp_tunnel_sock_create(tunnel_id, peer_tunnel_id, cfg, &sock);
+		err = l2tp_tunnel_sock_create(net, tunnel_id, peer_tunnel_id,
+				cfg, &sock);
 		if (err < 0)
 			goto err;
 	} else {
@@ -1909,8 +1917,21 @@ static __net_init int l2tp_init_net(struct net *net)
 	return 0;
 }
 
+static __net_exit void l2tp_exit_net(struct net *net)
+{
+	struct l2tp_net *pn = l2tp_pernet(net);
+	struct l2tp_tunnel *tunnel = NULL;
+
+	rcu_read_lock_bh();
+	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
+		(void)l2tp_tunnel_delete(tunnel);
+	}
+	rcu_read_unlock_bh();
+}
+
 static struct pernet_operations l2tp_net_ops = {
 	.init = l2tp_init_net,
+	.exit = l2tp_exit_net,
 	.id   = &l2tp_net_id,
 	.size = sizeof(struct l2tp_net),
 };
-- 
1.7.9.5
