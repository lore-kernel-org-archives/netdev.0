From: Andy Zhou <azhou@nicira.com>
Subject: [v8 net-next 4/4] l2tp: Refactor l2tp core driver to make use of the common UDP tunnel functions
Date: Tue, 16 Sep 2014 17:31:19 -0700
Message-ID: <1410913879-31688-4-git-send-email-azhou@nicira.com>
References: <1410913879-31688-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aob139.obsmtp.com ([74.125.149.251]:53237 "HELO
	psmtp.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753973AbaIQAg7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 20:36:59 -0400
Received: by mail-pd0-f176.google.com with SMTP id y13so888341pdi.21
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 17:36:58 -0700 (PDT)
In-Reply-To: <1410913879-31688-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify l2tp implementation using common UDP tunnel APIs.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/l2tp/l2tp_core.c |   24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 2aa2b6c..895348e 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1392,8 +1392,6 @@ static int l2tp_tunnel_sock_create(struct net *net,
 		if (err < 0)
 			goto out;
 
-		udp_set_convert_csum(sock->sk, true);
-
 		break;
 
 	case L2TP_ENCAPTYPE_IP:
@@ -1584,19 +1582,17 @@ int l2tp_tunnel_create(struct net *net, int fd, int version, u32 tunnel_id, u32
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
+		udp_cfg.sk_user_data = tunnel;
+		udp_cfg.encap_type = UDP_ENCAP_L2TPINUDP;
+		udp_cfg.encap_rcv = l2tp_udp_encap_recv;
+		udp_cfg.encap_destroy = l2tp_udp_encap_destroy;
 
-	sk->sk_user_data = tunnel;
+		setup_udp_tunnel_sock(net, sock, &udp_cfg);
+	} else {
+		sk->sk_user_data = tunnel;
+	}
 
 	/* Hook on the tunnel socket destructor so that we can cleanup
 	 * if the tunnel socket goes away.
-- 
1.7.9.5
