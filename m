From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: TCP_COOKIE_TRANSACTIONS synack data
Date: Mon, 08 Mar 2010 20:28:15 +0100
Message-ID: <1268076495.2819.57.camel@edumazet-laptop>
References: <2BC93087D531FF4A98881820AFE8AE7B74C409E1C3@jklmail01.ixonos.local>
	 <1268064070.6148.104.camel@edumazet-laptop>
	 <2BC93087D531FF4A98881820AFE8AE7B74C409E1D6@jklmail01.ixonos.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	William Allen Simpson <william.allen.simpson@gmail.com>
To: =?ISO-8859-1?Q?Penttil=E4?= Mika <mika.penttila@ixonos.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:57114 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754515Ab0CHT20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 14:28:26 -0500
Received: by bwz1 with SMTP id 1so3151304bwz.21
        for <netdev@vger.kernel.org>; Mon, 08 Mar 2010 11:28:25 -0800 (PST)
In-Reply-To: <2BC93087D531FF4A98881820AFE8AE7B74C409E1D6@jklmail01.ixonos.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 08 mars 2010 =C3=A0 18:33 +0200, Penttil=C3=A4 Mika a =C3=A9cr=
it :
> >=20
> > Le lundi 08 mars 2010 =C3=A0 16:27 +0200, Penttil=C3=A4 Mika a =C3=A9=
crit :
> > > The TCP_COOKIE_TRANSACTIONS synack data seems pretty unsafe atm.
> > > >From tcp_make_synack():
> > >
> > >
> > > 	u8 *buf =3D skb_put(skb, cvp->s_data_desired);
> > >
> > > 	/* copy data directly from the listening socket. */
> > >     	memcpy(buf, cvp->s_data_payload, cvp->s_data_desired);
> > >
> > >
> > > The skb here is allocated for MAX_TCP_HEADER + 15 and synack data
> > could be as long as TCP_MSS_DEFAULT, panic():ing at the skb_put().
> > >
> >=20
> > Indeed, since start of december 2009.
> >=20
> > Do you plan to provide a patch do you prefer someone else take care=
 of
> > it ?
> >=20
>=20
> I'm not planning to provide a patch at least very soon so I think som=
eone else can provide a quicker fix.
>=20
>=20

OK thanks Mika !

I suspect following patch might be an appropriate fix for this problem.

[PATCH] tcp: Fix tcp_make_synack()

Commit 4957faad (TCPCT part 1g: Responder Cookie =3D> Initiator), part
of TCP_COOKIE_TRANSACTION implementation, forgot to correctly size
synack skb in case user data must be included.

Many thanks to Mika Pentill=C3=A4 for spotting this error.

Reported-by: Penttill=C3=A4 Mika <mika.penttila@ixonos.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_output.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4a1605d..f181b78 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2395,13 +2395,17 @@ struct sk_buff *tcp_make_synack(struct sock *sk=
, struct dst_entry *dst,
 	struct tcp_extend_values *xvp =3D tcp_xv(rvp);
 	struct inet_request_sock *ireq =3D inet_rsk(req);
 	struct tcp_sock *tp =3D tcp_sk(sk);
+	const struct tcp_cookie_values *cvp =3D tp->cookie_values;
 	struct tcphdr *th;
 	struct sk_buff *skb;
 	struct tcp_md5sig_key *md5;
 	int tcp_header_size;
 	int mss;
+	int s_data_desired =3D 0;
=20
-	skb =3D sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
+	if (cvp !=3D NULL && cvp->s_data_constant && cvp->s_data_desired)
+		s_data_desired =3D cvp->s_data_desired;
+	skb =3D sock_wmalloc(sk, MAX_TCP_HEADER + 15 + s_data_desired, 1, GFP=
_ATOMIC);
 	if (skb =3D=3D NULL)
 		return NULL;
=20
@@ -2457,16 +2461,12 @@ struct sk_buff *tcp_make_synack(struct sock *sk=
, struct dst_entry *dst,
 			     TCPCB_FLAG_SYN | TCPCB_FLAG_ACK);
=20
 	if (OPTION_COOKIE_EXTENSION & opts.options) {
-		const struct tcp_cookie_values *cvp =3D tp->cookie_values;
-
-		if (cvp !=3D NULL &&
-		    cvp->s_data_constant &&
-		    cvp->s_data_desired > 0) {
-			u8 *buf =3D skb_put(skb, cvp->s_data_desired);
+		if (s_data_desired) {
+			u8 *buf =3D skb_put(skb, s_data_desired);
=20
 			/* copy data directly from the listening socket. */
-			memcpy(buf, cvp->s_data_payload, cvp->s_data_desired);
-			TCP_SKB_CB(skb)->end_seq +=3D cvp->s_data_desired;
+			memcpy(buf, cvp->s_data_payload, s_data_desired);
+			TCP_SKB_CB(skb)->end_seq +=3D s_data_desired;
 		}
=20
 		if (opts.hash_size > 0) {


