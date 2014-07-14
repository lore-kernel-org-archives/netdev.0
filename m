From: Tom Herbert <therbert@google.com>
Subject: [PATCH 2/4] vxlan: Call udp_sock_create
Date: Sun, 13 Jul 2014 19:49:42 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407131942180.25011@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:32811 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752588AbaGNCtn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2014 22:49:43 -0400
Received: by mail-oa0-f73.google.com with SMTP id g18so738360oah.4
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 19:49:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In vxlan driver call common function udp_sock_create to create the
listener UDP port.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/Kconfig |   1 +
 drivers/net/vxlan.c | 115 +++++++++++-----------------------------------------
 2 files changed, 25 insertions(+), 91 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 89402c3..c6f6f69 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -148,6 +148,7 @@ config VXLAN
        tristate "Virtual eXtensible Local Area Network (VXLAN)"
        depends on INET
        select NET_IP_TUNNEL
+       select NET_UDP_TUNNEL
        ---help---
 	  This allows one to create vxlan virtual interfaces that provide
 	  Layer 2 Networks over Layer 3 Networks. VXLAN is often used
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e6808f7..d3f3e5d 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -33,6 +33,7 @@
 #include <net/ip_tunnels.h>
 #include <net/icmp.h>
 #include <net/udp.h>
+#include <net/udp_tunnel.h>
 #include <net/rtnetlink.h>
 #include <net/route.h>
 #include <net/dsfield.h>
@@ -2339,102 +2340,37 @@ static void vxlan_del_work(struct work_struct *work)
 	kfree_rcu(vs, rcu);
 }
 
-#if IS_ENABLED(CONFIG_IPV6)
-/* Create UDP socket for encapsulation receive. AF_INET6 socket
- * could be used for both IPv4 and IPv6 communications, but
- * users may set bindv6only=1.
- */
-static struct socket *create_v6_sock(struct net *net, __be16 port, u32 flags)
+static struct socket *vxlan_create_sock(struct net *net, bool ipv6,
+					__be16 port, u32 flags)
 {
-	struct sock *sk;
 	struct socket *sock;
-	struct sockaddr_in6 vxlan_addr = {
-		.sin6_family = AF_INET6,
-		.sin6_port = port,
-	};
-	int rc, val = 1;
-
-	rc = sock_create_kern(AF_INET6, SOCK_DGRAM, IPPROTO_UDP, &sock);
-	if (rc < 0) {
-		pr_debug("UDPv6 socket create failed\n");
-		return ERR_PTR(rc);
-	}
-
-	/* Put in proper namespace */
-	sk = sock->sk;
-	sk_change_net(sk, net);
-
-	kernel_setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
-			  (char *)&val, sizeof(val));
-	rc = kernel_bind(sock, (struct sockaddr *)&vxlan_addr,
-			 sizeof(struct sockaddr_in6));
-	if (rc < 0) {
-		pr_debug("bind for UDPv6 socket %pI6:%u (%d)\n",
-			 &vxlan_addr.sin6_addr, ntohs(vxlan_addr.sin6_port), rc);
-		sk_release_kernel(sk);
-		return ERR_PTR(rc);
-	}
-	/* At this point, IPv6 module should have been loaded in
-	 * sock_create_kern().
-	 */
-	BUG_ON(!ipv6_stub);
-
-	/* Disable multicast loopback */
-	inet_sk(sk)->mc_loop = 0;
-
-	if (flags & VXLAN_F_UDP_ZERO_CSUM6_TX)
-		udp_set_no_check6_tx(sk, true);
-
-	if (flags & VXLAN_F_UDP_ZERO_CSUM6_RX)
-		udp_set_no_check6_rx(sk, true);
-
-	return sock;
-}
-
-#else
+	struct udp_port_cfg udp_conf;
+	int err;
 
-static struct socket *create_v6_sock(struct net *net, __be16 port, u32 flags)
-{
-		return ERR_PTR(-EPFNOSUPPORT);
-}
-#endif
+	memset(&udp_conf, 0, sizeof(udp_conf));
 
-static struct socket *create_v4_sock(struct net *net, __be16 port, u32 flags)
-{
-	struct sock *sk;
-	struct socket *sock;
-	struct sockaddr_in vxlan_addr = {
-		.sin_family = AF_INET,
-		.sin_addr.s_addr = htonl(INADDR_ANY),
-		.sin_port = port,
-	};
-	int rc;
-
-	/* Create UDP socket for encapsulation receive. */
-	rc = sock_create_kern(AF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock);
-	if (rc < 0) {
-		pr_debug("UDP socket create failed\n");
-		return ERR_PTR(rc);
+	if (ipv6) {
+		udp_conf.family = AF_INET6;
+		udp_conf.use_udp6_tx_checksums =
+		    !!(flags & VXLAN_F_UDP_ZERO_CSUM6_TX);
+		udp_conf.use_udp6_rx_checksums =
+		    !!(flags & VXLAN_F_UDP_ZERO_CSUM6_RX);
+	} else {
+		udp_conf.family = AF_INET;
+		udp_conf.local_ip.s_addr = INADDR_ANY;
+		udp_conf.use_udp_checksums =
+		    !!(flags & VXLAN_F_UDP_CSUM);
 	}
 
-	/* Put in proper namespace */
-	sk = sock->sk;
-	sk_change_net(sk, net);
+	udp_conf.local_udp_port = port;
 
-	rc = kernel_bind(sock, (struct sockaddr *) &vxlan_addr,
-			 sizeof(vxlan_addr));
-	if (rc < 0) {
-		pr_debug("bind for UDP socket %pI4:%u (%d)\n",
-			 &vxlan_addr.sin_addr, ntohs(vxlan_addr.sin_port), rc);
-		sk_release_kernel(sk);
-		return ERR_PTR(rc);
-	}
+	/* Open UDP socket */
+	err = udp_sock_create(net, &udp_conf, &sock);
+	if (err < 0)
+		return ERR_PTR(err);
 
 	/* Disable multicast loopback */
-	inet_sk(sk)->mc_loop = 0;
-
-	if (!(flags & VXLAN_F_UDP_CSUM))
-		sock->sk->sk_no_check_tx = 1;
+	inet_sk(sock->sk)->mc_loop = 0;
 
 	return sock;
 }
@@ -2460,10 +2396,7 @@ static struct vxlan_sock *vxlan_socket_create(struct net *net, __be16 port,
 
 	INIT_WORK(&vs->del_work, vxlan_del_work);
 
-	if (ipv6)
-		sock = create_v6_sock(net, port, flags);
-	else
-		sock = create_v4_sock(net, port, flags);
+	sock = vxlan_create_sock(net, ipv6, port, flags);
 	if (IS_ERR(sock)) {
 		kfree(vs);
 		return ERR_CAST(sock);
-- 
2.0.0.526.g5318336
