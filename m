From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 5/5] l2tp: refactor l2tp driver to use udp tunnel functions
Date: Fri,  1 Aug 2014 14:54:45 -0700
Message-ID: <1406930085-26445-6-git-send-email-azhou@nicira.com>
References: <1406930085-26445-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog132.obsmtp.com ([74.125.149.250]:42161 "HELO
	na3sys009aog132.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756392AbaHAV7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 17:59:47 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so6522851pab.28
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 14:59:46 -0700 (PDT)
In-Reply-To: <1406930085-26445-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Refactor l2tp core driver to make use of the common UDP tunnel
functions

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/l2tp/l2tp_core.c |  105 +++++++++++++++++++++++++++++---------------------
 1 file changed, 61 insertions(+), 44 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 4a68170..38faada 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1306,6 +1306,8 @@ static void l2tp_tunnel_free(struct l2tp_tunnel *tunnel)
 	BUG_ON(atomic_read(&tunnel->ref_count) != 0);
 	BUG_ON(tunnel->sock != NULL);
 	l2tp_info(tunnel, L2TP_MSG_CONTROL, "%s: free...\n", tunnel->name);
+	if (tunnel->encap == UDP_ENCAP_L2TPINUDP)
+		udp_tunnel_sock_release((struct udp_tunnel_sock *)tunnel);
 	kfree_rcu(tunnel, rcu);
 }
 
@@ -1342,6 +1344,36 @@ static void l2tp_tunnel_del_work(struct work_struct *work)
 	l2tp_tunnel_sock_put(sk);
 }
 
+/* Extract udp_port_cfg from a l2tp_tunnel_cfg */
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
+		    cfg->udp6_zero_tx_checksums;
+		udp_conf->use_udp6_rx_checksums =
+		    cfg->udp6_zero_rx_checksums;
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
@@ -1363,31 +1395,7 @@ static int l2tp_tunnel_sock_create(struct net *net,
 
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
@@ -1548,29 +1556,38 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 		}
 	}
 
-	tunnel = kzalloc(sizeof(struct l2tp_tunnel), GFP_KERNEL);
-	if (tunnel == NULL) {
-		err = -ENOMEM;
-		goto err;
-	}
+	switch (encap) {
+	case L2TP_ENCAPTYPE_UDP: {
+		struct udp_tunnel_socket_cfg l2tp_udp_cfg;
 
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
+		l2tp_udp_cfg.protocol_bit = 0;
+		l2tp_tunnel_udp_port_conf(cfg, &l2tp_udp_cfg.port);
+		l2tp_udp_cfg.encap_type = UDP_ENCAP_L2TPINUDP;
+		l2tp_udp_cfg.encap_rcv = l2tp_udp_encap_recv;
+		l2tp_udp_cfg.encap_destroy = l2tp_udp_encap_destroy;
+
+		tunnel = (struct l2tp_tunnel *)create_udp_tunnel_sock(net,
+						sizeof(l2tp_tunnel), sock,
+						&l2tp_udp_cfg);
+
+		if (!tunnel) {
+			err = -ENOMEM;
+			goto err;
+		}
+		break;
 	}
+	case L2TP_ENCAPTYPE_IP:
+		tunnel = kzalloc(sizeof(*tunnel), GFP_KERNEL);
+		if (tunnel == NULL) {
+			err = -ENOMEM;
+			goto err;
+		}
 
-	rcu_assign_sk_user_data(sk, tunnel);
+		rcu_assign_sk_user_data(sk, tunnel);
+		break;
+	}
 
+	tunnel->encap = encap;
 	tunnel->version = version;
 	tunnel->tunnel_id = tunnel_id;
 	tunnel->peer_tunnel_id = peer_tunnel_id;
-- 
1.7.9.5
