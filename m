From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH 3/4] l2tp: don't pin network namespaces with tunnel sockets
Date: Wed,  9 Jan 2013 18:36:22 +0000
Message-ID: <1357756583-22535-4-git-send-email-tparkin@katalix.com>
References: <1357756583-22535-1-git-send-email-tparkin@katalix.com>
Cc: Tom Parkin <tparkin@katalix.com>,
	James Chapman <jchapman@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:55330 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932134Ab3AISgs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 13:36:48 -0500
In-Reply-To: <1357756583-22535-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

L2TP supports two types of tunnel: managed and unmanaged.  Managed tunnels are
dealt with by a userspace daemon, with the kernel providing user data
encapsulation and de-encapsulation for efficiency.  Unmanaged tunnels provide
a simpler interface for configuring kernelspace data encap/de-encap only.  In
the unmanaged tunnel case the kernel creates a tunnel socket which is not
exposed to userspace.

Unmanaged tunnels can be created using iproute2's "l2tp" command.

This patch prevents an unmanaged tunnel socket from keeping network namespaces
alive when they should otherwise be destroyed:

* Tunnel sockets are now created in the namespace passed to l2tp_tunnel_create.
  To achieve this, l2tp_tunnel_sock_create now takes a struct net pointer rather
  than using the namespace of the current process.

* Tunnel sockets should not hold a reference to the netns, as this
  creates a reference loop which can prevent the netns correctly freeing.  We
  now drop the socket's netns reference using sk_change_net.  To prevent
  leaking sockets when the netns exits, we now implement a pernet exit hook
  to free the tunnels and sessions in the netns before it is freed.  This
  clears up any unmanaged tunnels still alive when the netns exits.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   89 ++++++++++++++++++++++++++++++++------------------
 1 file changed, 57 insertions(+), 32 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 75b347b..5922eac 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1356,29 +1356,37 @@ static void l2tp_tunnel_free(struct l2tp_tunnel *tunnel)
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
@@ -1400,13 +1408,12 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2t
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
@@ -1433,14 +1440,13 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2t
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
@@ -1462,14 +1468,13 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2t
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
@@ -1493,8 +1498,10 @@ static int l2tp_tunnel_sock_create(u32 tunnel_id, u32 peer_tunnel_id, struct l2t
 	}
 
 out:
+	*sockp = sock;
 	if ((err < 0) && sock) {
-		sock_release(sock);
+		kernel_sock_shutdown(sock, SHUT_RDWR);
+		sk_release_kernel(sock->sk);
 		*sockp = NULL;
 	}
 
@@ -1517,7 +1524,8 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	 * kernel socket.
 	 */
 	if (fd < 0) {
-		err = l2tp_tunnel_sock_create(tunnel_id, peer_tunnel_id, cfg, &sock);
+		err = l2tp_tunnel_sock_create(net, tunnel_id, peer_tunnel_id,
+				cfg, &sock);
 		if (err < 0)
 			goto err;
 	} else {
@@ -1631,6 +1639,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	spin_unlock_bh(&pn->l2tp_tunnel_list_lock);
 
 	err = 0;
+
 err:
 	if (tunnelp)
 		*tunnelp = tunnel;
@@ -1652,19 +1661,20 @@ int l2tp_tunnel_delete(struct l2tp_tunnel *tunnel)
 	int err = 0;
 	struct socket *sock = tunnel->sock ? tunnel->sock->sk_socket : NULL;
 
-	/* Force the tunnel socket to close. This will eventually
-	 * cause the tunnel to be deleted via the normal socket close
-	 * mechanisms when userspace closes the tunnel socket.
+	/* If the tunnel socket was created directly by the kernel, use the
+	 * sk_* API to release the socket now.  Otherwise go through the
+	 * inet_* layer.
+	 * In either case, when the socket goes away the tunnel and the
+	 * sessions are removed via. the socket destructor.
 	 */
 	if (sock != NULL) {
-		err = inet_shutdown(sock, 2);
-
-		/* If the tunnel's socket was created by the kernel,
-		 * close the socket here since the socket was not
-		 * created by userspace.
-		 */
-		if (sock->file == NULL)
+		if (sock->file == NULL) {
+			kernel_sock_shutdown(sock, SHUT_RDWR);
+			sk_release_kernel(sock->sk);
+		} else {
+			err = inet_shutdown(sock, 2);
 			err = inet_release(sock);
+		}
 	}
 
 	return err;
@@ -1851,8 +1861,23 @@ static __net_init int l2tp_init_net(struct net *net)
 	return 0;
 }
 
+static __net_exit void l2tp_exit_net(struct net *net)
+{
+	struct l2tp_tunnel *tunnel = NULL;
+	struct l2tp_net *pn = l2tp_pernet(net);
+
+	rcu_read_lock_bh();
+	list_for_each_entry_rcu(tunnel, &pn->l2tp_tunnel_list, list) {
+		int err = l2tp_tunnel_delete(tunnel);
+		if (err)
+			pr_err("l2tp_tunnel_delete() returned %d\n", err);
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
