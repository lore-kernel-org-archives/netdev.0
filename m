From: Andy Zhou <azhou@nicira.com>
Subject: [net-next v7 1/4] udp_tunnel: Seperate ipv6 functions into its own file.
Date: Mon, 15 Sep 2014 03:34:25 -0700
Message-ID: <1410777267-28237-2-git-send-email-azhou@nicira.com>
References: <1410777267-28237-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog109.obsmtp.com ([74.125.149.201]:47463 "HELO
	na3sys009aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754354AbaIOKkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 06:40:01 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so6091243pab.19
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 03:40:00 -0700 (PDT)
In-Reply-To: <1410777267-28237-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ip6_udp_tunnel.c for ipv6 UDP tunnel functions to avoid ifdefs
in udp_tunnel.c

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/net/udp_tunnel.h  |   28 +++++++++++++--
 net/ipv4/udp_tunnel.c     |   85 +++++++++++----------------------------------
 net/ipv6/Makefile         |    1 +
 net/ipv6/ip6_udp_tunnel.c |   63 +++++++++++++++++++++++++++++++++
 4 files changed, 111 insertions(+), 66 deletions(-)
 create mode 100644 net/ipv6/ip6_udp_tunnel.c

diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index ffd69cb..0b9e017 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -26,7 +26,31 @@ struct udp_port_cfg {
 				use_udp6_rx_checksums:1;
 };
 
-int udp_sock_create(struct net *net, struct udp_port_cfg *cfg,
-		    struct socket **sockp);
+int udp_sock_create4(struct net *net, struct udp_port_cfg *cfg,
+		     struct socket **sockp);
+
+#if IS_ENABLED(CONFIG_IPV6)
+int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
+		     struct socket **sockp);
+#else
+static inline int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
+				   struct socket **sockp)
+{
+	return 0;
+}
+#endif
+
+static inline int udp_sock_create(struct net *net,
+				  struct udp_port_cfg *cfg,
+				  struct socket **sockp)
+{
+	if (cfg->family == AF_INET)
+		return udp_sock_create4(net, cfg, sockp);
+
+	if (cfg->family == AF_INET6)
+		return udp_sock_create6(net, cfg, sockp);
+
+	return -EPFNOSUPPORT;
+}
 
 #endif
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 61ec1a6..7fccf6c 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -8,83 +8,40 @@
 #include <net/udp_tunnel.h>
 #include <net/net_namespace.h>
 
-int udp_sock_create(struct net *net, struct udp_port_cfg *cfg,
-		    struct socket **sockp)
+int udp_sock_create4(struct net *net, struct udp_port_cfg *cfg,
+		     struct socket **sockp)
 {
 	int err = -EINVAL;
 	struct socket *sock = NULL;
+	struct sockaddr_in udp_addr;
 
-#if IS_ENABLED(CONFIG_IPV6)
-	if (cfg->family == AF_INET6) {
-		struct sockaddr_in6 udp6_addr;
+	err = sock_create_kern(AF_INET, SOCK_DGRAM, 0, &sock);
+	if (err < 0)
+		goto error;
 
-		err = sock_create_kern(AF_INET6, SOCK_DGRAM, 0, &sock);
-		if (err < 0)
-			goto error;
-
-		sk_change_net(sock->sk, net);
-
-		udp6_addr.sin6_family = AF_INET6;
-		memcpy(&udp6_addr.sin6_addr, &cfg->local_ip6,
-		       sizeof(udp6_addr.sin6_addr));
-		udp6_addr.sin6_port = cfg->local_udp_port;
-		err = kernel_bind(sock, (struct sockaddr *)&udp6_addr,
-				  sizeof(udp6_addr));
-		if (err < 0)
-			goto error;
-
-		if (cfg->peer_udp_port) {
-			udp6_addr.sin6_family = AF_INET6;
-			memcpy(&udp6_addr.sin6_addr, &cfg->peer_ip6,
-			       sizeof(udp6_addr.sin6_addr));
-			udp6_addr.sin6_port = cfg->peer_udp_port;
-			err = kernel_connect(sock,
-					     (struct sockaddr *)&udp6_addr,
-					     sizeof(udp6_addr), 0);
-		}
-		if (err < 0)
-			goto error;
-
-		udp_set_no_check6_tx(sock->sk, !cfg->use_udp6_tx_checksums);
-		udp_set_no_check6_rx(sock->sk, !cfg->use_udp6_rx_checksums);
-	} else
-#endif
-	if (cfg->family == AF_INET) {
-		struct sockaddr_in udp_addr;
-
-		err = sock_create_kern(AF_INET, SOCK_DGRAM, 0, &sock);
-		if (err < 0)
-			goto error;
+	sk_change_net(sock->sk, net);
 
-		sk_change_net(sock->sk, net);
+	udp_addr.sin_family = AF_INET;
+	udp_addr.sin_addr = cfg->local_ip;
+	udp_addr.sin_port = cfg->local_udp_port;
+	err = kernel_bind(sock, (struct sockaddr *)&udp_addr,
+			  sizeof(udp_addr));
+	if (err < 0)
+		goto error;
 
+	if (cfg->peer_udp_port) {
 		udp_addr.sin_family = AF_INET;
-		udp_addr.sin_addr = cfg->local_ip;
-		udp_addr.sin_port = cfg->local_udp_port;
-		err = kernel_bind(sock, (struct sockaddr *)&udp_addr,
-				  sizeof(udp_addr));
+		udp_addr.sin_addr = cfg->peer_ip;
+		udp_addr.sin_port = cfg->peer_udp_port;
+		err = kernel_connect(sock, (struct sockaddr *)&udp_addr,
+				     sizeof(udp_addr), 0);
 		if (err < 0)
 			goto error;
-
-		if (cfg->peer_udp_port) {
-			udp_addr.sin_family = AF_INET;
-			udp_addr.sin_addr = cfg->peer_ip;
-			udp_addr.sin_port = cfg->peer_udp_port;
-			err = kernel_connect(sock,
-					     (struct sockaddr *)&udp_addr,
-					     sizeof(udp_addr), 0);
-			if (err < 0)
-				goto error;
-		}
-
-		sock->sk->sk_no_check_tx = !cfg->use_udp_checksums;
-	} else {
-		return -EPFNOSUPPORT;
 	}
 
+	sock->sk->sk_no_check_tx = !cfg->use_udp_checksums;
 
 	*sockp = sock;
-
 	return 0;
 
 error:
@@ -95,6 +52,6 @@ error:
 	*sockp = NULL;
 	return err;
 }
-EXPORT_SYMBOL(udp_sock_create);
+EXPORT_SYMBOL(udp_sock_create4);
 
 MODULE_LICENSE("GPL");
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 2fe6836..45f830e 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -35,6 +35,7 @@ obj-$(CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION) += xfrm6_mode_ro.o
 obj-$(CONFIG_INET6_XFRM_MODE_BEET) += xfrm6_mode_beet.o
 obj-$(CONFIG_IPV6_MIP6) += mip6.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
+obj-$(CONFIG_NET_UDP_TUNNEL) += ip6_udp_tunnel.o
 
 obj-$(CONFIG_IPV6_VTI) += ip6_vti.o
 obj-$(CONFIG_IPV6_SIT) += sit.o
diff --git a/net/ipv6/ip6_udp_tunnel.c b/net/ipv6/ip6_udp_tunnel.c
new file mode 100644
index 0000000..bcfbb4b
--- /dev/null
+++ b/net/ipv6/ip6_udp_tunnel.c
@@ -0,0 +1,63 @@
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/socket.h>
+#include <linux/udp.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/in6.h>
+#include <net/udp.h>
+#include <net/udp_tunnel.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/ip6_tunnel.h>
+#include <net/ip6_checksum.h>
+
+int udp_sock_create6(struct net *net, struct udp_port_cfg *cfg,
+		     struct socket **sockp)
+{
+	struct sockaddr_in6 udp6_addr;
+	int err;
+	struct socket *sock = NULL;
+
+	err = sock_create_kern(AF_INET6, SOCK_DGRAM, 0, &sock);
+	if (err < 0)
+		goto error;
+
+	sk_change_net(sock->sk, net);
+
+	udp6_addr.sin6_family = AF_INET6;
+	memcpy(&udp6_addr.sin6_addr, &cfg->local_ip6,
+	       sizeof(udp6_addr.sin6_addr));
+	udp6_addr.sin6_port = cfg->local_udp_port;
+	err = kernel_bind(sock, (struct sockaddr *)&udp6_addr,
+			  sizeof(udp6_addr));
+	if (err < 0)
+		goto error;
+
+	if (cfg->peer_udp_port) {
+		udp6_addr.sin6_family = AF_INET6;
+		memcpy(&udp6_addr.sin6_addr, &cfg->peer_ip6,
+		       sizeof(udp6_addr.sin6_addr));
+		udp6_addr.sin6_port = cfg->peer_udp_port;
+		err = kernel_connect(sock,
+				     (struct sockaddr *)&udp6_addr,
+				     sizeof(udp6_addr), 0);
+	}
+	if (err < 0)
+		goto error;
+
+	udp_set_no_check6_tx(sock->sk, !cfg->use_udp6_tx_checksums);
+	udp_set_no_check6_rx(sock->sk, !cfg->use_udp6_rx_checksums);
+
+	*sockp = sock;
+	return 0;
+
+error:
+	if (sock) {
+		kernel_sock_shutdown(sock, SHUT_RDWR);
+		sk_release_kernel(sock->sk);
+	}
+	*sockp = NULL;
+	return err;
+}
+EXPORT_SYMBOL_GPL(udp_sock_create6);
-- 
1.7.9.5
