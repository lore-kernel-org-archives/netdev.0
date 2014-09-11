From: Andy Zhou <azhou@nicira.com>
Subject: [net-next v5 3/3] l2tp: Refactor l2tp core driver to make use of the common UDP tunnel functions
Date: Wed, 10 Sep 2014 20:29:53 -0700
Message-ID: <1410406193-6185-4-git-send-email-azhou@nicira.com>
References: <1410406193-6185-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog127.obsmtp.com ([74.125.149.107]:42618 "HELO
	na3sys009aog127.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751536AbaIKDff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 23:35:35 -0400
Received: by mail-pa0-f47.google.com with SMTP id ey11so10677535pad.20
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 20:35:35 -0700 (PDT)
In-Reply-To: <1410406193-6185-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/l2tp/l2tp_core.c |  208 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 128 insertions(+), 80 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 2aa2b6c..1f2bb8e 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -113,6 +113,11 @@ struct l2tp_net {
 	spinlock_t l2tp_session_hlist_lock;
 };
 
+struct l2tp_udp_tunnel {
+	struct udp_tunnel_sock uts;
+	struct l2tp_tunnel tunnel;
+};
+
 static void l2tp_tunnel_free(struct l2tp_tunnel *tunnel);
 
 static inline struct l2tp_tunnel *l2tp_tunnel(struct sock *sk)
@@ -1198,7 +1203,6 @@ static void l2tp_tunnel_destruct(struct sock *sk)
 
 	l2tp_info(tunnel, L2TP_MSG_CONTROL, "%s: closing...\n", tunnel->name);
 
-
 	/* Disable udp encapsulation */
 	switch (tunnel->encap) {
 	case L2TP_ENCAPTYPE_UDP:
@@ -1298,6 +1302,18 @@ static void l2tp_udp_encap_destroy(struct sock *sk)
 	}
 }
 
+static void free_l2tp_udp_sock_rcu(struct rcu_head *rcu)
+{
+	struct l2tp_tunnel *tunnel;
+	struct l2tp_udp_tunnel *udp_tunnel;
+
+	tunnel = container_of(rcu, struct l2tp_tunnel, rcu);
+
+	udp_tunnel = container_of(tunnel, struct l2tp_udp_tunnel, tunnel);
+
+	udp_tunnel_sock_free(&udp_tunnel->uts);
+}
+
 /* Really kill the tunnel.
  * Come here only when all sessions have been cleared from the tunnel.
  */
@@ -1306,7 +1322,19 @@ static void l2tp_tunnel_free(struct l2tp_tunnel *tunnel)
 	BUG_ON(atomic_read(&tunnel->ref_count) != 0);
 	BUG_ON(tunnel->sock != NULL);
 	l2tp_info(tunnel, L2TP_MSG_CONTROL, "%s: free...\n", tunnel->name);
-	kfree_rcu(tunnel, rcu);
+
+	switch (tunnel->encap) {
+	case L2TP_ENCAPTYPE_UDP:
+		call_rcu(&tunnel->rcu, free_l2tp_udp_sock_rcu);
+		break;
+
+	case L2TP_ENCAPTYPE_IP:
+		kfree_rcu(tunnel, rcu);
+		break;
+
+	default:
+		BUG();
+	}
 }
 
 /* Workqueue tunnel deletion function */
@@ -1342,6 +1370,35 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
 	l2tp_tunnel_sock_put(sk);
 }
 
+static void l2tp_tunnel_udp_port_conf(struct l2tp_tunnel_cfg *cfg,
+				      struct udp_port_cfg *udp_conf)
+{
+	memset(udp_conf, 0, sizeof(*udp_conf));
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (cfg->local_ip6 && cfg->peer_ip6) {
+		udp_conf->family = AF_INET6;
+		memcpy(&udp_conf->local_ip6, cfg->local_ip6,
+		       sizeof(udp_conf->local_ip6));
+		memcpy(&udp_conf->peer_ip6, cfg->peer_ip6,
+		       sizeof(udp_conf->peer_ip6));
+		udp_conf->use_udp6_tx_checksums =
+			cfg->udp6_zero_tx_checksums;
+		udp_conf->use_udp6_rx_checksums =
+			cfg->udp6_zero_rx_checksums;
+	} else
+#endif
+	{
+		udp_conf->family = AF_INET;
+		udp_conf->local_ip = cfg->local_ip;
+		udp_conf->peer_ip = cfg->peer_ip;
+		udp_conf->use_udp_checksums = cfg->use_udp_checksums;
+	}
+
+	udp_conf->local_udp_port = htons(cfg->local_udp_port);
+	udp_conf->peer_udp_port = htons(cfg->peer_udp_port);
+}
+
 /* Create a socket for the tunnel, if one isn't set up by
  * userspace. This is used for static tunnels where there is no
  * managing L2TP daemon.
@@ -1363,31 +1420,7 @@ static int l2tp_tunnel_sock_create(struct net *net,
 
 	switch (cfg->encap) {
 	case L2TP_ENCAPTYPE_UDP:
-		memset(&udp_conf, 0, sizeof(udp_conf));
-
-#if IS_ENABLED(CONFIG_IPV6)
-		if (cfg->local_ip6 && cfg->peer_ip6) {
-			udp_conf.family = AF_INET6;
-			memcpy(&udp_conf.local_ip6, cfg->local_ip6,
-			       sizeof(udp_conf.local_ip6));
-			memcpy(&udp_conf.peer_ip6, cfg->peer_ip6,
-			       sizeof(udp_conf.peer_ip6));
-			udp_conf.use_udp6_tx_checksums =
-			    cfg->udp6_zero_tx_checksums;
-			udp_conf.use_udp6_rx_checksums =
-			    cfg->udp6_zero_rx_checksums;
-		} else
-#endif
-		{
-			udp_conf.family = AF_INET;
-			udp_conf.local_ip = cfg->local_ip;
-			udp_conf.peer_ip = cfg->peer_ip;
-			udp_conf.use_udp_checksums = cfg->use_udp_checksums;
-		}
-
-		udp_conf.local_udp_port = htons(cfg->local_udp_port);
-		udp_conf.peer_udp_port = htons(cfg->peer_udp_port);
-
+		l2tp_tunnel_udp_port_conf(cfg, &udp_conf);
 		err = udp_sock_create(net, &udp_conf, &sock);
 		if (err < 0)
 			goto out;
@@ -1473,6 +1506,31 @@ out:
 
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
@@ -1480,7 +1538,7 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	struct socket *sock = NULL;
 	struct sock *sk = NULL;
 	struct l2tp_net *pn;
-	enum l2tp_encap_type encap = L2TP_ENCAPTYPE_UDP;
+	enum l2tp_encap_type encap = cfg ? cfg->encap : L2TP_ENCAPTYPE_UDP;
 
 	/* Get the tunnel socket from the fd, which was opened by
 	 * the userspace L2TP daemon. If not specified, create a
@@ -1488,9 +1546,11 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	 */
 	if (fd < 0) {
 		err = l2tp_tunnel_sock_create(net, tunnel_id, peer_tunnel_id,
-				cfg, &sock);
+					      cfg, &sock);
 		if (err < 0)
 			goto err;
+
+		sk = sock->sk;
 	} else {
 		sock = sockfd_lookup(fd, &err);
 		if (!sock) {
@@ -1500,58 +1560,66 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
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
 
-	sk = sock->sk;
+		/* Quick sanity checks */
+		err = l2tp_sk_sanity_check(sk, encap, tunnel_id, fd);
+		if (err)
+			goto err;
 
-	if (cfg != NULL)
-		encap = cfg->encap;
+		/* Check if this socket has already been prepped */
+		tunnel = l2tp_tunnel(sk);
+		if (tunnel != NULL) {
+			/* This socket has already been prepped */
+			err = -EBUSY;
+			goto err;
+		}
+	}
 
-	/* Quick sanity checks */
 	switch (encap) {
-	case L2TP_ENCAPTYPE_UDP:
-		err = -EPROTONOSUPPORT;
-		if (sk->sk_protocol != IPPROTO_UDP) {
-			pr_err("tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
-			       tunnel_id, fd, sk->sk_protocol, IPPROTO_UDP);
+	case L2TP_ENCAPTYPE_UDP: {
+		struct udp_tunnel_sock_cfg udp_cfg;
+		struct l2tp_udp_tunnel *udp_tunnel;
+		struct udp_tunnel_sock *uts;
+
+		udp_cfg.sock = sock;
+		udp_cfg.encap_type = UDP_ENCAP_L2TPINUDP;
+		udp_cfg.encap_rcv = l2tp_udp_encap_recv;
+		udp_cfg.encap_destroy = l2tp_udp_encap_destroy;
+
+		uts = create_udp_tunnel_sock(net, sizeof(*udp_tunnel),
+					     &udp_cfg);
+		if (!uts) {
+			err = -ENOMEM;
 			goto err;
 		}
+
+		udp_tunnel = container_of(uts, struct l2tp_udp_tunnel, uts);
+		tunnel = &udp_tunnel->tunnel;
 		break;
+	}
 	case L2TP_ENCAPTYPE_IP:
-		err = -EPROTONOSUPPORT;
-		if (sk->sk_protocol != IPPROTO_L2TP) {
-			pr_err("tunl %hu: fd %d wrong protocol, got %d, expected %d\n",
-			       tunnel_id, fd, sk->sk_protocol, IPPROTO_L2TP);
+		tunnel = kzalloc(sizeof(*tunnel), GFP_KERNEL);
+		if (tunnel == NULL) {
+			err = -ENOMEM;
 			goto err;
 		}
-		break;
 	}
 
-	/* Check if this socket has already been prepped */
-	tunnel = l2tp_tunnel(sk);
-	if (tunnel != NULL) {
-		/* This socket has already been prepped */
-		err = -EBUSY;
-		goto err;
-	}
-
-	tunnel = kzalloc(sizeof(struct l2tp_tunnel), GFP_KERNEL);
-	if (tunnel == NULL) {
-		err = -ENOMEM;
-		goto err;
-	}
+	rcu_assign_sk_user_data(sk, tunnel);
 
+	tunnel->encap = encap;
 	tunnel->version = version;
 	tunnel->tunnel_id = tunnel_id;
 	tunnel->peer_tunnel_id = peer_tunnel_id;
-	tunnel->debug = L2TP_DEFAULT_DEBUG_FLAGS;
-
+	tunnel->debug = cfg ? cfg->debug : L2TP_DEFAULT_DEBUG_FLAGS;
 	tunnel->magic = L2TP_TUNNEL_MAGIC;
 	sprintf(&tunnel->name[0], "tunl %u", tunnel_id);
 	rwlock_init(&tunnel->hlist_lock);
@@ -1560,9 +1628,6 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	tunnel->l2tp_net = net;
 	pn = l2tp_pernet(net);
 
-	if (cfg != NULL)
-		tunnel->debug = cfg->debug;
-
 #if IS_ENABLED(CONFIG_IPV6)
 	if (sk->sk_family == PF_INET6) {
 		struct ipv6_pinfo *np = inet6_sk(sk);
@@ -1581,23 +1646,6 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
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
