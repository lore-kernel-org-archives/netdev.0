From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: tcp: fix TCLASS value in ACK messages sent from
 TIME_WAIT
Date: Thu, 27 Oct 2011 06:33:42 +0200
Message-ID: <1319690022.3436.10.camel@edumazet-laptop>
References: <1319611331.18883.13.camel@edumazet-laptop>
	 <20111026.155908.1133603039272144196.davem@davemloft.net>
	 <20111026.160159.696019885442921932.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38179 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704Ab1J0Edv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 00:33:51 -0400
Received: by wyg36 with SMTP id 36so2383234wyg.19
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2011 21:33:50 -0700 (PDT)
In-Reply-To: <20111026.160159.696019885442921932.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 octobre 2011 =C3=A0 16:01 -0400, David Miller a =C3=A9cr=
it :
> From: David Miller <davem@davemloft.net>
> Date: Wed, 26 Oct 2011 15:59:08 -0400 (EDT)
>=20
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Wed, 26 Oct 2011 08:42:11 +0200
> >=20
> >> commit 66b13d99d96a (ipv4: tcp: fix TOS value in ACK messages sent=
 from
> >> TIME_WAIT) fixed IPv4 only.
> >>=20
> >> This part is for the IPv6 side.
> >>=20
> >> We alias tw_tclass and tw_tos, if socket family is INET6.
> >>=20
> >> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> >=20
> > Applied.
>=20
> Nevermind...  reverted.

Oh well, sorry, here is an updated patch

[PATCH] ipv6: tcp: fix TCLASS value in ACK messages sent from TIME_WAIT

commit 66b13d99d96a (ipv4: tcp: fix TOS value in ACK messages sent from
TIME_WAIT) fixed IPv4 only.

This part is for the IPv6 side, adding a tclass param to ip6_xmit()

We alias tw_tclass and tw_tos, if socket family is INET6.

[ if sockets is ipv4-mapped, only IP_TOS socket option is used to fill
TOS field, TCLASS is not taken into account ]

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
V2: changes dccp/sctp as they use ip6_xmit()
 include/net/inet_timewait_sock.h |    1 +
 include/net/ipv6.h               |    3 ++-
 net/dccp/ipv6.c                  |    4 ++--
 net/ipv4/tcp_minisocks.c         |    1 +
 net/ipv6/inet6_connection_sock.c |    2 +-
 net/ipv6/ip6_output.c            |    7 ++-----
 net/ipv6/tcp_ipv6.c              |   17 +++++++++--------
 net/sctp/ipv6.c                  |    2 +-
 8 files changed, 19 insertions(+), 18 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewa=
it_sock.h
index 180231c..f91a1fb 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -134,6 +134,7 @@ struct inet_timewait_sock {
 	struct inet_bind_bucket	*tw_tb;
 	struct hlist_node	tw_death_node;
 };
+#define tw_tclass tw_tos
=20
 static inline void inet_twsk_add_node_rcu(struct inet_timewait_sock *t=
w,
 				      struct hlist_nulls_head *list)
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 3b5ac1f..a366a8a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -486,7 +486,8 @@ extern int			ip6_rcv_finish(struct sk_buff *skb);
 extern int			ip6_xmit(struct sock *sk,
 					 struct sk_buff *skb,
 					 struct flowi6 *fl6,
-					 struct ipv6_txoptions *opt);
+					 struct ipv6_txoptions *opt,
+					 int tclass);
=20
 extern int			ip6_nd_hdr(struct sock *sk,
 					   struct sk_buff *skb,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index b74f761..17ee85c 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -271,7 +271,7 @@ static int dccp_v6_send_response(struct sock *sk, s=
truct request_sock *req,
 							 &ireq6->loc_addr,
 							 &ireq6->rmt_addr);
 		ipv6_addr_copy(&fl6.daddr, &ireq6->rmt_addr);
-		err =3D ip6_xmit(sk, skb, &fl6, opt);
+		err =3D ip6_xmit(sk, skb, &fl6, opt, np->tclass);
 		err =3D net_xmit_eval(err);
 	}
=20
@@ -326,7 +326,7 @@ static void dccp_v6_ctl_send_reset(struct sock *sk,=
 struct sk_buff *rxskb)
 	dst =3D ip6_dst_lookup_flow(ctl_sk, &fl6, NULL, false);
 	if (!IS_ERR(dst)) {
 		skb_dst_set(skb, dst);
-		ip6_xmit(ctl_sk, skb, &fl6, NULL);
+		ip6_xmit(ctl_sk, skb, &fl6, NULL, 0);
 		DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
 		DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
 		return;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 85a2fbe..66363b6 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -345,6 +345,7 @@ void tcp_time_wait(struct sock *sk, int state, int =
timeo)
 			tw6 =3D inet6_twsk((struct sock *)tw);
 			ipv6_addr_copy(&tw6->tw_v6_daddr, &np->daddr);
 			ipv6_addr_copy(&tw6->tw_v6_rcv_saddr, &np->rcv_saddr);
+			tw->tw_tclass =3D np->tclass;
 			tw->tw_ipv6only =3D np->ipv6only;
 		}
 #endif
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connecti=
on_sock.c
index 2916200..fee46d5 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -248,7 +248,7 @@ int inet6_csk_xmit(struct sk_buff *skb, struct flow=
i *fl_unused)
 	/* Restore final destination back after routing done */
 	ipv6_addr_copy(&fl6.daddr, &np->daddr);
=20
-	res =3D ip6_xmit(sk, skb, &fl6, np->opt);
+	res =3D ip6_xmit(sk, skb, &fl6, np->opt, np->tclass);
 	rcu_read_unlock();
 	return res;
 }
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 1c9bf8b..ff30047 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -180,7 +180,7 @@ int ip6_output(struct sk_buff *skb)
  */
=20
 int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
-	     struct ipv6_txoptions *opt)
+	     struct ipv6_txoptions *opt, int tclass)
 {
 	struct net *net =3D sock_net(sk);
 	struct ipv6_pinfo *np =3D inet6_sk(sk);
@@ -190,7 +190,6 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, =
struct flowi6 *fl6,
 	u8  proto =3D fl6->flowi6_proto;
 	int seg_len =3D skb->len;
 	int hlimit =3D -1;
-	int tclass =3D 0;
 	u32 mtu;
=20
 	if (opt) {
@@ -228,10 +227,8 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb,=
 struct flowi6 *fl6,
 	/*
 	 *	Fill in the IPv6 header
 	 */
-	if (np) {
-		tclass =3D np->tclass;
+	if (np)
 		hlimit =3D np->hop_limit;
-	}
 	if (hlimit < 0)
 		hlimit =3D ip6_dst_hoplimit(dst);
=20
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index c8683fc..10b2b31 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -513,7 +513,7 @@ static int tcp_v6_send_synack(struct sock *sk, stru=
ct request_sock *req,
 		__tcp_v6_send_check(skb, &treq->loc_addr, &treq->rmt_addr);
=20
 		ipv6_addr_copy(&fl6.daddr, &treq->rmt_addr);
-		err =3D ip6_xmit(sk, skb, &fl6, opt);
+		err =3D ip6_xmit(sk, skb, &fl6, opt, np->tclass);
 		err =3D net_xmit_eval(err);
 	}
=20
@@ -979,7 +979,7 @@ static int tcp6_gro_complete(struct sk_buff *skb)
 }
=20
 static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack=
, u32 win,
-				 u32 ts, struct tcp_md5sig_key *key, int rst)
+				 u32 ts, struct tcp_md5sig_key *key, int rst, u8 tclass)
 {
 	const struct tcphdr *th =3D tcp_hdr(skb);
 	struct tcphdr *t1;
@@ -1060,7 +1060,7 @@ static void tcp_v6_send_response(struct sk_buff *=
skb, u32 seq, u32 ack, u32 win,
 	dst =3D ip6_dst_lookup_flow(ctl_sk, &fl6, NULL, false);
 	if (!IS_ERR(dst)) {
 		skb_dst_set(buff, dst);
-		ip6_xmit(ctl_sk, buff, &fl6, NULL);
+		ip6_xmit(ctl_sk, buff, &fl6, NULL, tclass);
 		TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 		if (rst)
 			TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
@@ -1093,13 +1093,13 @@ static void tcp_v6_send_reset(struct sock *sk, =
struct sk_buff *skb)
 		ack_seq =3D ntohl(th->seq) + th->syn + th->fin + skb->len -
 			  (th->doff << 2);
=20
-	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, key, 1);
+	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, key, 1, 0);
 }
=20
 static void tcp_v6_send_ack(struct sk_buff *skb, u32 seq, u32 ack, u32=
 win, u32 ts,
-			    struct tcp_md5sig_key *key)
+			    struct tcp_md5sig_key *key, u8 tclass)
 {
-	tcp_v6_send_response(skb, seq, ack, win, ts, key, 0);
+	tcp_v6_send_response(skb, seq, ack, win, ts, key, 0, tclass);
 }
=20
 static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
@@ -1109,7 +1109,8 @@ static void tcp_v6_timewait_ack(struct sock *sk, =
struct sk_buff *skb)
=20
 	tcp_v6_send_ack(skb, tcptw->tw_snd_nxt, tcptw->tw_rcv_nxt,
 			tcptw->tw_rcv_wnd >> tw->tw_rcv_wscale,
-			tcptw->tw_ts_recent, tcp_twsk_md5_key(tcptw));
+			tcptw->tw_ts_recent, tcp_twsk_md5_key(tcptw),
+			tw->tw_tclass);
=20
 	inet_twsk_put(tw);
 }
@@ -1118,7 +1119,7 @@ static void tcp_v6_reqsk_send_ack(struct sock *sk=
, struct sk_buff *skb,
 				  struct request_sock *req)
 {
 	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn=
 + 1, req->rcv_wnd, req->ts_recent,
-			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr));
+			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr), 0);
 }
=20
=20
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index aabaee4..8104278 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -243,7 +243,7 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct=
 sctp_transport *transport)
 	if (!(transport->param_flags & SPP_PMTUD_ENABLE))
 		skb->local_df =3D 1;
=20
-	return ip6_xmit(sk, skb, &fl6, np->opt);
+	return ip6_xmit(sk, skb, &fl6, np->opt, np->tclass);
 }
=20
 /* Returns the dst cache entry for the given source and destination ip
