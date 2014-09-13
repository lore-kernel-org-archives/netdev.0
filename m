From: Andy Zhou <azhou@nicira.com>
Subject: [net-next v6 4/4] l2tp: Refactor l2tp core driver to make use of the common UDP tunnel functions
Date: Fri, 12 Sep 2014 19:22:00 -0700
Message-ID: <1410574920-16486-5-git-send-email-azhou@nicira.com>
References: <1410574920-16486-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:47147 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752214AbaIMC1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 22:27:38 -0400
Received: by mail-pd0-f171.google.com with SMTP id p10so2438874pdj.30
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 19:27:37 -0700 (PDT)
In-Reply-To: <1410574920-16486-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/l2tp/l2tp_core.c |   25 +++++++++++--------------
 1 file changed, 11 insertions(+), 14 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 2aa2b6c..c31b3d3 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1392,8 +1392,6 @@ static int l2tp_tunnel_sock_create(struct net *net,
 		if (err < 0)
 			goto out;
 
-		udp_set_convert_csum(sock->sk, true);
-
 		break;
 
 	case L2TP_ENCAPTYPE_IP:
@@ -1584,19 +1582,18 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
 	/* Mark socket as an encapsulation socket. See net/ipv4/udp.c */
 	tunnel->encap = encap;
 	if (encap == L2TP_ENCAPTYPE_UDP) {
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
+		struct udp_tunnel_sock_cfg udp_cfg;
+
+		udp_cfg.sock = sock;
+		udp_cfg.sk_user_data = tunnel;
+		udp_cfg.encap_type = UDP_ENCAP_L2TPINUDP;
+		udp_cfg.encap_rcv = l2tp_udp_encap_recv;
+		udp_cfg.encap_destroy = l2tp_udp_encap_destroy;
 
-	sk->sk_user_data = tunnel;
+		setup_udp_tunnel_sock(net, &udp_cfg);
+	} else {
+		sk->sk_user_data = tunnel;
+	}
 
 	/* Hook on the tunnel socket destructor so that we can cleanup
 	 * if the tunnel socket goes away.
-- 
1.7.9.5
