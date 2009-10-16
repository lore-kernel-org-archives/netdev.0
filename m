From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Fri, 16 Oct 2009 07:00:49 +0200
Message-ID: <4AD7FE01.1010805@gmail.com>
References: <20091014045226.GA15655@1wt.eu> <Pine.LNX.4.58.0910140912420.2714@u.domain.uli> <20091014201706.GA24298@1wt.eu> <20091014.154349.83940908.davem@davemloft.net> <20091015060834.GB29564@1wt.eu> <Pine.LNX.4.58.0910151120340.2879@u.domain.uli> <20091015124134.GB1073@1wt.eu> <Pine.LNX.4.58.0910152257410.3047@u.domain.uli> <4AD7EDB4.7060907@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Julian Anastasov <ja@ssi.bg>, Willy Tarreau <w@1wt.eu>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44326 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbZJPFCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 01:02:08 -0400
In-Reply-To: <4AD7EDB4.7060907@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
>=20
>=20
> So, it appears defer_accept value is not an inherited attribute,
> but shared by all embryons. Therefore we should not touch it.
>=20
> Of course it should be done, or add a new connection field to count n=
umber
> of pure ACKS received on each SYN_RECV embryon.
>=20

Could be something like this ? (on top of net-next-2.6 of course)

7 bits is more than enough, we could take 5 bits IMHO.


Thanks

[PATCH net-next-2.6] tcp: TCP_DEFER_ACCEPT fix

Julian Anastasov pointed out defer_accept was an attribute of listening=
 socket,
shared by all embryons. We therefore need a new per connection attribut=
e.

We can split current u8 used by cookie_ts into 7 bits used to store
number of pure ACKS received by the embryon, and 1 bit to store cookie_=
ts.

Note, I use an unsigned int field so that kmemcheck doesnt shoot,
so patch also touches cookie_v4_init_sequence()/cookie_v6_init_sequence=
()
implementations.

Reported-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/request_sock.h |    9 ++++++---
 include/net/tcp.h          |    6 ++++--
 net/ipv4/syncookies.c      |    7 ++++---
 net/ipv4/tcp_ipv4.c        |    2 +-
 net/ipv4/tcp_minisocks.c   |    4 ++--
 net/ipv6/syncookies.c      |    6 +++---
 net/ipv6/tcp_ipv6.c        |    2 +-
 7 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index c719084..3464d90 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -45,9 +45,12 @@ struct request_sock_ops {
  */
 struct request_sock {
 	struct request_sock		*dl_next; /* Must be first member! */
-	u16				mss;
-	u8				retrans;
-	u8				cookie_ts; /* syncookie: encode tcpopts in timestamp */
+	kmemcheck_bitfield_begin(flags);
+	unsigned int			mss : 16,
+					retrans : 8,
+					req_acks : 7,
+					cookie_ts : 1; /* syncookie: encode tcpopts in timestamp */
+	kmemcheck_bitfield_end(flags);
 	/* The following two fields can be easily recomputed I think -AK */
 	u32				window_clamp; /* window clamp at creation time */
 	u32				rcv_wnd;	  /* rcv_wnd offered first time */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 03a49c7..a2c0439 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -453,7 +453,7 @@ extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WO=
RDS];
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *s=
kb,=20
 				    struct ip_options *opt);
 extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *=
skb,=20
-				     __u16 *mss);
+				     struct request_sock *req);
=20
 extern __u32 cookie_init_timestamp(struct request_sock *req);
 extern void cookie_check_timestamp(struct tcp_options_received *tcp_op=
t);
@@ -461,7 +461,7 @@ extern void cookie_check_timestamp(struct tcp_optio=
ns_received *tcp_opt);
 /* From net/ipv6/syncookies.c */
 extern struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *s=
kb);
 extern __u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *=
skb,
-				     __u16 *mss);
+				     struct request_sock *req);
=20
 /* tcp_output.c */
=20
@@ -1000,7 +1000,9 @@ static inline void tcp_openreq_init(struct reques=
t_sock *req,
 	struct inet_request_sock *ireq =3D inet_rsk(req);
=20
 	req->rcv_wnd =3D 0;		/* So that tcp_send_synack() knows! */
+	kmemcheck_annotate_bitfield(req, flags);
 	req->cookie_ts =3D 0;
+	req->req_acks =3D 0;
 	tcp_rsk(req)->rcv_isn =3D TCP_SKB_CB(skb)->seq;
 	req->mss =3D rx_opt->mss_clamp;
 	req->ts_recent =3D rx_opt->saw_tstamp ? rx_opt->rcv_tsval : 0;
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 5ec678a..8af9261 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -160,19 +160,20 @@ static __u16 const msstab[] =3D {
  * Generate a syncookie.  mssp points to the mss, which is returned
  * rounded down to the value encoded in the cookie.
  */
-__u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __=
u16 *mssp)
+__u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb,
+			      struct request_sock *req)
 {
 	const struct iphdr *iph =3D ip_hdr(skb);
 	const struct tcphdr *th =3D tcp_hdr(skb);
 	int mssind;
-	const __u16 mss =3D *mssp;
+	const __u16 mss =3D req->mss;
=20
 	tcp_synq_overflow(sk);
=20
 	/* XXX sort msstab[] by probability?  Binary search? */
 	for (mssind =3D 0; mss > msstab[mssind + 1]; mssind++)
 		;
-	*mssp =3D msstab[mssind] + 1;
+	req->mss =3D msstab[mssind] + 1;
=20
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
=20
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9971870..3a2dfc5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1286,7 +1286,7 @@ int tcp_v4_conn_request(struct sock *sk, struct s=
k_buff *skb)
 		syn_flood_warning(skb);
 		req->cookie_ts =3D tmp_opt.tstamp_ok;
 #endif
-		isn =3D cookie_v4_init_sequence(sk, skb, &req->mss);
+		isn =3D cookie_v4_init_sequence(sk, skb, req);
 	} else if (!isn) {
 		struct inet_peer *peer =3D NULL;
=20
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index e320afe..92778e6 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -642,9 +642,9 @@ struct sock *tcp_check_req(struct sock *sk, struct =
sk_buff *skb,
 		return NULL;
=20
 	/* If TCP_DEFER_ACCEPT is set, drop bare ACK. */
-	if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
+	if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept > req->req_acks=
 &&
 	    TCP_SKB_CB(skb)->end_seq =3D=3D tcp_rsk(req)->rcv_isn + 1) {
-		inet_csk(sk)->icsk_accept_queue.rskq_defer_accept--;
+		req->req_acks++;
 		inet_rsk(req)->acked =3D 1;
 		return NULL;
 	}
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index cbe55e5..60d024d 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -125,18 +125,18 @@ static __u32 check_tcp_syn_cookie(__u32 cookie, s=
truct in6_addr *saddr,
 		& COOKIEMASK;
 }
=20
-__u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb, __=
u16 *mssp)
+__u32 cookie_v6_init_sequence(struct sock *sk, struct sk_buff *skb, st=
ruct request_sock *req)
 {
 	struct ipv6hdr *iph =3D ipv6_hdr(skb);
 	const struct tcphdr *th =3D tcp_hdr(skb);
 	int mssind;
-	const __u16 mss =3D *mssp;
+	const __u16 mss =3D req->mss;
=20
 	tcp_synq_overflow(sk);
=20
 	for (mssind =3D 0; mss > msstab[mssind + 1]; mssind++)
 		;
-	*mssp =3D msstab[mssind] + 1;
+	req->mss =3D msstab[mssind] + 1;
=20
 	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
=20
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4517630..2717bcb 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1219,7 +1219,7 @@ static int tcp_v6_conn_request(struct sock *sk, s=
truct sk_buff *skb)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
=20
 	if (want_cookie) {
-		isn =3D cookie_v6_init_sequence(sk, skb, &req->mss);
+		isn =3D cookie_v6_init_sequence(sk, skb, req);
 		req->cookie_ts =3D tmp_opt.tstamp_ok;
 	} else if (!isn) {
 		if (ipv6_opt_accepted(sk, skb) ||

