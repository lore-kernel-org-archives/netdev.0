From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] Use sk_mark for IPv6 routing lookups
Date: Fri, 02 Oct 2009 14:19:05 -0400
Message-ID: <4AC64419.6020202@hp.com>
References: <200910011814.47689.atis@mikrotik.com> <4AC4D90E.3040008@gmail.com>	 <20091001.151823.263194343.davem@davemloft.net>	 <4AC58C46.8080408@gmail.com> <4AC598D7.9080900@gmail.com> <55a4f86e0910021025u7523029av1e4ee917d1fb1ee5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, atis@mikrotik.com,
	panther@balabit.hu, netdev@vger.kernel.org
To: =?UTF-8?B?TWFjaWVqIMW7ZW5jenlrb3dza2k=?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0185.atlanta.hp.com ([15.193.32.62]:37284 "EHLO
	g6t0185.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756976AbZJBSTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 14:19:06 -0400
In-Reply-To: <55a4f86e0910021025u7523029av1e4ee917d1fb1ee5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maciej =C5=BBenczykowski wrote:
> Cool!
>=20
> As I've already pointed out in a post 2 or so weeks ago, we need the
> exact same treatment in a ton of places throughout the code (tcp,
> ipv6, decnet, etc...).

Here's a try at the IPv6 part...


Add support for IPv6 route lookups using sk_mark.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index e2bdc6d..a615b4d 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -147,6 +147,7 @@ ipv4_connected:
 	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 	fl.oif =3D sk->sk_bound_dev_if;
+	fl.mark =3D sk->sk_mark;
 	fl.fl_ip_dport =3D inet->dport;
 	fl.fl_ip_sport =3D inet->sport;
=20
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connecti=
on_sock.c
index cc4797d..a9f4a21 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -194,6 +194,7 @@ int inet6_csk_xmit(struct sk_buff *skb, int ipfrago=
k)
 	fl.fl6_flowlabel =3D np->flow_label;
 	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
 	fl.oif =3D sk->sk_bound_dev_if;
+	fl.mark =3D sk->sk_mark;
 	fl.fl_ip_sport =3D inet->sport;
 	fl.fl_ip_dport =3D inet->dport;
 	security_sk_classify_flow(sk, &fl);
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 7161539..d98df54 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1523,6 +1523,7 @@ static int ip6mr_forward2(struct sk_buff *skb, st=
ruct mfc6_cache *c, int vifi)
=20
 	fl =3D (struct flowi) {
 		.oif =3D vif->link,
+		.mark =3D skb->mark,
 		.nl_u =3D { .ip6_u =3D
 				{ .daddr =3D ipv6h->daddr, }
 		}
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 14f54eb..dc0f736 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -424,6 +424,7 @@ sticky_done:
=20
 		fl.fl6_flowlabel =3D 0;
 		fl.oif =3D sk->sk_bound_dev_if;
+		fl.mark =3D sk->sk_mark;
=20
 		if (optlen =3D=3D 0)
 			goto update;
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index dbd19a7..03a64c1 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -629,6 +629,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff=
 *skb,
 						.saddr =3D tiph->saddr,
 						.tos =3D RT_TOS(tos) } },
 				    .oif =3D tunnel->parms.link,
+				    .mark =3D skb->mark,
 				    .proto =3D IPPROTO_IPV6 };
 		if (ip_route_output_key(dev_net(dev), &rt, &fl)) {
 			stats->tx_carrier_errors++;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 21d100b..321aafd 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -243,6 +243,7 @@ static int tcp_v6_connect(struct sock *sk, struct s=
ockaddr *uaddr,
 	ipv6_addr_copy(&fl.fl6_src,
 		       (saddr ? saddr : &np->saddr));
 	fl.oif =3D sk->sk_bound_dev_if;
+	fl.mark =3D sk->sk_mark;
 	fl.fl_ip_dport =3D usin->sin6_port;
 	fl.fl_ip_sport =3D inet->sport;
=20
@@ -383,6 +384,7 @@ static void tcp_v6_err(struct sk_buff *skb, struct =
inet6_skb_parm *opt,
 			ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
 			ipv6_addr_copy(&fl.fl6_src, &np->saddr);
 			fl.oif =3D sk->sk_bound_dev_if;
+			fl.mark =3D sk->sk_mark;
 			fl.fl_ip_dport =3D inet->dport;
 			fl.fl_ip_sport =3D inet->sport;
 			security_skb_classify_flow(skb, &fl);
@@ -477,6 +479,7 @@ static int tcp_v6_send_synack(struct sock *sk, stru=
ct request_sock *req)
 	ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
 	fl.fl6_flowlabel =3D 0;
 	fl.oif =3D treq->iif;
+	fl.mark =3D sk->sk_mark;
 	fl.fl_ip_dport =3D inet_rsk(req)->rmt_port;
 	fl.fl_ip_sport =3D inet_rsk(req)->loc_port;
 	security_req_classify_flow(req, &fl);
@@ -1345,6 +1348,7 @@ static struct sock * tcp_v6_syn_recv_sock(struct =
sock *sk, struct sk_buff *skb,
 		}
 		ipv6_addr_copy(&fl.fl6_src, &treq->loc_addr);
 		fl.oif =3D sk->sk_bound_dev_if;
+		fl.mark =3D sk->sk_mark;
 		fl.fl_ip_dport =3D inet_rsk(req)->rmt_port;
 		fl.fl_ip_sport =3D inet_rsk(req)->loc_port;
 		security_req_classify_flow(req, &fl);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3a60f12..3842c55 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -879,6 +879,8 @@ do_udp_sendmsg:
 	if (!fl.oif)
 		fl.oif =3D np->sticky_pktinfo.ipi6_ifindex;
=20
+	fl.mark =3D sk->sk_mark;
+
 	if (msg->msg_controllen) {
 		opt =3D &opt_space;
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
