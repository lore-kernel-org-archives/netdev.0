From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/4] udp: Add udp_sock_create for UDP tunnels to open listener
 socket
Date: Sun, 13 Jul 2014 19:49:37 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407131942300.25018@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f73.google.com ([209.85.216.73]:59919 "EHLO
	mail-qa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbaGNCti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2014 22:49:38 -0400
Received: by mail-qa0-f73.google.com with SMTP id s7so240170qap.2
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 19:49:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added udp_tunnel.c which can contain some common functions for UDP
tunnels. The first function in this is udp_sock_create which is used
to open the listener port for a UDP tunnel.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/udp_tunnel.h |  32 +++++++++++++++
 net/ipv4/Kconfig         |   4 ++
 net/ipv4/Makefile        |   1 +
 net/ipv4/udp_tunnel.c    | 100 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 137 insertions(+)
 create mode 100644 include/net/udp_tunnel.h
 create mode 100644 net/ipv4/udp_tunnel.c

diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
new file mode 100644
index 0000000..ffd69cb
--- /dev/null
+++ b/include/net/udp_tunnel.h
@@ -0,0 +1,32 @@
+#ifndef __NET_UDP_TUNNEL_H
+#define __NET_UDP_TUNNEL_H
+
+struct udp_port_cfg {
+	u8			family;
+
+	/* Used only for kernel-created sockets */
+	union {
+		struct in_addr		local_ip;
+#if IS_ENABLED(CONFIG_IPV6)
+		struct in6_addr		local_ip6;
+#endif
+	};
+
+	union {
+		struct in_addr		peer_ip;
+#if IS_ENABLED(CONFIG_IPV6)
+		struct in6_addr		peer_ip6;
+#endif
+	};
+
+	__be16			local_udp_port;
+	__be16			peer_udp_port;
+	unsigned int		use_udp_checksums:1,
+				use_udp6_tx_checksums:1,
+				use_udp6_rx_checksums:1;
+};
+
+int udp_sock_create(struct net *net, struct udp_port_cfg *cfg,
+		    struct socket **sockp);
+
+#endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 05c57f0..dbc10d8 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -307,6 +307,10 @@ config NET_IPVTI
 	  the notion of a secure tunnel for IPSEC and then use routing protocol
 	  on top.
 
+config NET_UDP_TUNNEL
+	tristate
+	default n
+
 config INET_AH
 	tristate "IP: AH transformation"
 	select XFRM_ALGO
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index f032688..8ee1cd4 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -22,6 +22,7 @@ obj-$(CONFIG_NET_IPIP) += ipip.o
 gre-y := gre_demux.o
 obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
+obj-$(CONFIG_NET_UDP_TUNNEL) += udp_tunnel.o
 obj-$(CONFIG_NET_IPVTI) += ip_vti.o
 obj-$(CONFIG_SYN_COOKIES) += syncookies.o
 obj-$(CONFIG_INET_AH) += ah4.o
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
new file mode 100644
index 0000000..61ec1a6
--- /dev/null
+++ b/net/ipv4/udp_tunnel.c
@@ -0,0 +1,100 @@
+#include <linux/module.h>
+#include <linux/errno.h>
+#include <linux/socket.h>
+#include <linux/udp.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <net/udp.h>
+#include <net/udp_tunnel.h>
+#include <net/net_namespace.h>
+
+int udp_sock_create(struct net *net, struct udp_port_cfg *cfg,
+		    struct socket **sockp)
+{
+	int err = -EINVAL;
+	struct socket *sock = NULL;
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (cfg->family == AF_INET6) {
+		struct sockaddr_in6 udp6_addr;
+
+		err = sock_create_kern(AF_INET6, SOCK_DGRAM, 0, &sock);
+		if (err < 0)
+			goto error;
+
+		sk_change_net(sock->sk, net);
+
+		udp6_addr.sin6_family = AF_INET6;
+		memcpy(&udp6_addr.sin6_addr, &cfg->local_ip6,
+		       sizeof(udp6_addr.sin6_addr));
+		udp6_addr.sin6_port = cfg->local_udp_port;
+		err = kernel_bind(sock, (struct sockaddr *)&udp6_addr,
+				  sizeof(udp6_addr));
+		if (err < 0)
+			goto error;
+
+		if (cfg->peer_udp_port) {
+			udp6_addr.sin6_family = AF_INET6;
+			memcpy(&udp6_addr.sin6_addr, &cfg->peer_ip6,
+			       sizeof(udp6_addr.sin6_addr));
+			udp6_addr.sin6_port = cfg->peer_udp_port;
+			err = kernel_connect(sock,
+					     (struct sockaddr *)&udp6_addr,
+					     sizeof(udp6_addr), 0);
+		}
+		if (err < 0)
+			goto error;
+
+		udp_set_no_check6_tx(sock->sk, !cfg->use_udp6_tx_checksums);
+		udp_set_no_check6_rx(sock->sk, !cfg->use_udp6_rx_checksums);
+	} else
+#endif
+	if (cfg->family == AF_INET) {
+		struct sockaddr_in udp_addr;
+
+		err = sock_create_kern(AF_INET, SOCK_DGRAM, 0, &sock);
+		if (err < 0)
+			goto error;
+
+		sk_change_net(sock->sk, net);
+
+		udp_addr.sin_family = AF_INET;
+		udp_addr.sin_addr = cfg->local_ip;
+		udp_addr.sin_port = cfg->local_udp_port;
+		err = kernel_bind(sock, (struct sockaddr *)&udp_addr,
+				  sizeof(udp_addr));
+		if (err < 0)
+			goto error;
+
+		if (cfg->peer_udp_port) {
+			udp_addr.sin_family = AF_INET;
+			udp_addr.sin_addr = cfg->peer_ip;
+			udp_addr.sin_port = cfg->peer_udp_port;
+			err = kernel_connect(sock,
+					     (struct sockaddr *)&udp_addr,
+					     sizeof(udp_addr), 0);
+			if (err < 0)
+				goto error;
+		}
+
+		sock->sk->sk_no_check_tx = !cfg->use_udp_checksums;
+	} else {
+		return -EPFNOSUPPORT;
+	}
+
+
+	*sockp = sock;
+
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
+EXPORT_SYMBOL(udp_sock_create);
+
+MODULE_LICENSE("GPL");
-- 
2.0.0.526.g5318336
