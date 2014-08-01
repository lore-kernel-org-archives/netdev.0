From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 4/5] l2tp: Small cleanups
Date: Fri,  1 Aug 2014 14:54:44 -0700
Message-ID: <1406930085-26445-5-git-send-email-azhou@nicira.com>
References: <1406930085-26445-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog121.obsmtp.com ([74.125.149.145]:51913 "HELO
	na3sys009aog121.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756375AbaHAV7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 17:59:50 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so6230617pdj.2
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 14:59:44 -0700 (PDT)
In-Reply-To: <1406930085-26445-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No functional changes. Rearrange to improve readability.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/l2tp/l2tp_core.c |  111 ++++++++++++++++++++++++++------------------------
 1 file changed, 58 insertions(+), 53 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 1109d3b..4a68170 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1471,6 +1471,31 @@ out:
 
 static struct lock_class_key l2tp_socket_class;
 
+static int l2tp_sk_sanity_check(struct sock *sk, enum l2tp_encap_type encap,
+				u32 tunnel_id, int fd)
+{
+	unsigned int expected_protocol;
+
+	switch (encap) {
+	case L2TP_ENCAPTYPE_UDP:
+		expected_protocol = IPPROTO_UDP;
+		break;
+	case L2TP_ENCAPTYPE_IP:
+		expected_protocol = IPPROTO_L2TP;
+		break;
+	default:
+		return -EPROTONOSUPPORT;
+	}
+
+	if (sk->sk_protocol != expected_protocol) {
+		pr_err("tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
+		       tunnel_id, fd, sk->sk_protocol, expected_protocol);
+		return -EPROTONOSUPPORT;
+	}
+
+	return 0;
+}
+
 int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32 peer_tunnel_id, struct l2tp_tunnel_cfg *cfg, struct l2tp_tunnel **tunnelp)
 {
 	struct l2tp_tunnel *tunnel = NULL;
@@ -1478,7 +1503,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	struct socket *sock = NULL;
 	struct sock *sk = NULL;
 	struct l2tp_net *pn;
-	enum l2tp_encap_type encap = L2TP_ENCAPTYPE_UDP;
+	enum l2tp_encap_type encap = cfg ? cfg->encap : L2TP_ENCAPTYPE_UDP;
 
 	/* Get the tunnel socket from the fd, which was opened by
 	 * the userspace L2TP daemon. If not specified, create a
@@ -1489,6 +1514,8 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 				cfg, &sock);
 		if (err < 0)
 			goto err;
+
+		sk = sock->sk;
 	} else {
 		sock = sockfd_lookup(fd, &err);
 		if (!sock) {
@@ -1498,45 +1525,27 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 			goto err;
 		}
 
+		sk = sock->sk;
+
 		/* Reject namespace mismatches */
-		if (!net_eq(sock_net(sock->sk), net)) {
+		if (!net_eq(sock_net(sk), net)) {
 			pr_err("tunl %u: netns mismatch\n", tunnel_id);
 			err = -EINVAL;
 			goto err;
 		}
-	}
-
-	sk = sock->sk;
-
-	if (cfg != NULL)
-		encap = cfg->encap;
 
-	/* Quick sanity checks */
-	switch (encap) {
-	case L2TP_ENCAPTYPE_UDP:
-		err = -EPROTONOSUPPORT;
-		if (sk->sk_protocol != IPPROTO_UDP) {
-			pr_err("tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
-			       tunnel_id, fd, sk->sk_protocol, IPPROTO_UDP);
+		/* Quick sanity checks */
+		err = l2tp_sk_sanity_check(sk, encap, tunnel_id, fd);
+		if (err)
 			goto err;
-		}
-		break;
-	case L2TP_ENCAPTYPE_IP:
-		err = -EPROTONOSUPPORT;
-		if (sk->sk_protocol != IPPROTO_L2TP) {
-			pr_err("tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
-			       tunnel_id, fd, sk->sk_protocol, IPPROTO_L2TP);
+
+		/* Check if this socket has already been prepped */
+		tunnel = l2tp_tunnel(sk);
+		if (tunnel != NULL) {
+			/* This socket has already been prepped */
+			err = -EBUSY;
 			goto err;
 		}
-		break;
-	}
-
-	/* Check if this socket has already been prepped */
-	tunnel = l2tp_tunnel(sk);
-	if (tunnel != NULL) {
-		/* This socket has already been prepped */
-		err = -EBUSY;
-		goto err;
 	}
 
 	tunnel = kzalloc(sizeof(struct l2tp_tunnel), GFP_KERNEL);
@@ -1545,11 +1554,27 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 		goto err;
 	}
 
+	/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
+	tunnel->encap = encap;
+	if (encap == L2TP_ENCAPTYPE_UDP) {
+		/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
+		udp_sk(sk)->encap_type = UDP_ENCAP_L2TPINUDP;
+		udp_sk(sk)->encap_rcv = l2tp_udp_encap_recv;
+		udp_sk(sk)->encap_destroy = l2tp_udp_encap_destroy;
+#if IS_ENABLED(CONFIG_IPV6)
+		if (sk->sk_family == PF_INET6 && !tunnel->v4mapped)
+			udpv6_encap_enable();
+		else
+#endif
+		udp_encap_enable();
+	}
+
+	rcu_assign_sk_user_data(sk, tunnel);
+
 	tunnel->version = version;
 	tunnel->tunnel_id = tunnel_id;
 	tunnel->peer_tunnel_id = peer_tunnel_id;
-	tunnel->debug = L2TP_DEFAULT_DEBUG_FLAGS;
-
+	tunnel->debug = cfg ? cfg->debug : L2TP_DEFAULT_DEBUG_FLAGS;
 	tunnel->magic = L2TP_TUNNEL_MAGIC;
 	sprintf(&tunnel->name[0], "tunl %u", tunnel_id);
 	rwlock_init(&tunnel->hlist_lock);
@@ -1558,9 +1583,6 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	tunnel->l2tp_net = net;
 	pn = l2tp_pernet(net);
 
-	if (cfg != NULL)
-		tunnel->debug = cfg->debug;
-
 #if IS_ENABLED(CONFIG_IPV6)
 	if (sk->sk_family == PF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
@@ -1579,23 +1601,6 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	}
 #endif
 
-	/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
-	tunnel->encap = encap;
-	if (encap == L2TP_ENCAPTYPE_UDP) {
-		/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
-		udp_sk(sk)->encap_type = UDP_ENCAP_L2TPINUDP;
-		udp_sk(sk)->encap_rcv = l2tp_udp_encap_recv;
-		udp_sk(sk)->encap_destroy = l2tp_udp_encap_destroy;
-#if IS_ENABLED(CONFIG_IPV6)
-		if (sk->sk_family == PF_INET6 && !tunnel->v4mapped)
-			udpv6_encap_enable();
-		else
-#endif
-		udp_encap_enable();
-	}
-
-	sk->sk_user_data = tunnel;
-
 	/* Hook on the tunnel socket destructor so that we can cleanup
 	 * if the tunnel socket goes away.
 	 */
-- 
1.7.9.5
