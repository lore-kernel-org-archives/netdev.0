From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: avoid a possible divide by zero
Date: Tue, 07 Dec 2010 23:03:55 +0100
Message-ID: <1291759435.5324.25.camel@edumazet-laptop>
References: <201012071639.58884.Martin@lichtvoll.de>
	 <1291738321.2695.338.camel@edumazet-laptop>
	 <1291755776.21627.13.camel@bwh-desktop>
	 <1291757288.5324.18.camel@edumazet-laptop>
	 <1291757563.21627.15.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Martin Steigerwald <Martin@lichtvoll.de>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:33193 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761Ab0LGWEB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 17:04:01 -0500
Received: by wwa36 with SMTP id 36so438348wwa.1
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 14:04:00 -0800 (PST)
In-Reply-To: <1291757563.21627.15.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 d=C3=A9cembre 2010 =C3=A0 21:32 +0000, Ben Hutchings a =C3=A9=
crit :
> On Tue, 2010-12-07 at 22:28 +0100, Eric Dumazet wrote:
> [...]
> > Thanks
> >=20
> > Great, I feel we are going to fix all sysctls, one by one then :(
> >=20
> > lkml removed from Cc
> >=20
> >=20
> > [PATCH] tcp: avoid a possible divide by zero
> >=20
> > sysctl_tcp_tso_win_divisor might be set to zero while one cpu runs =
in
> > tcp_tso_should_defer(). Make sure we dont allow a divide by zero by
> > reading sysctl_tcp_tso_win_divisor once.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> >  net/ipv4/tcp_output.c |    6 ++++--
> >  1 file changed, 4 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> > index 05b1ecf..0281223 100644
> > --- a/net/ipv4/tcp_output.c
> > +++ b/net/ipv4/tcp_output.c
> > @@ -1513,6 +1513,7 @@ static int tcp_tso_should_defer(struct sock *=
sk, struct sk_buff *skb)
> >  	struct tcp_sock *tp =3D tcp_sk(sk);
> >  	const struct inet_connection_sock *icsk =3D inet_csk(sk);
> >  	u32 send_win, cong_win, limit, in_flight;
> > +	int win_divisor;
> > =20
> >  	if (TCP_SKB_CB(skb)->flags & TCPHDR_FIN)
> >  		goto send_now;
> > @@ -1544,13 +1545,14 @@ static int tcp_tso_should_defer(struct sock=
 *sk, struct sk_buff *skb)
> >  	if ((skb !=3D tcp_write_queue_tail(sk)) && (limit >=3D skb->len))
> >  		goto send_now;
> > =20
> > -	if (sysctl_tcp_tso_win_divisor) {
> > +	win_divisor =3D sysctl_tcp_tso_win_divisor;
>=20
> You need to use ACCESS_ONCE(sysctl_tcp_tso_win_divisor).  Otherwise t=
he
> compiler may eliminate the local variable and read the global twice.

Yes, I knew that, of course :)

I wonder how many bugs like that we have in sysctls

Thanks

[PATCH v2] tcp: avoid a possible divide by zero

sysctl_tcp_tso_win_divisor might be set to zero while one cpu runs in
tcp_tso_should_defer(). Make sure we dont allow a divide by zero by
reading sysctl_tcp_tso_win_divisor exactly once.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
v2: Use ACCESS_ONCE() as Ben suggested

 net/ipv4/tcp_output.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 05b1ecf..0464d70 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1513,6 +1513,7 @@ static int tcp_tso_should_defer(struct sock *sk, =
struct sk_buff *skb)
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	const struct inet_connection_sock *icsk =3D inet_csk(sk);
 	u32 send_win, cong_win, limit, in_flight;
+	int win_divisor;
=20
 	if (TCP_SKB_CB(skb)->flags & TCPHDR_FIN)
 		goto send_now;
@@ -1544,13 +1545,14 @@ static int tcp_tso_should_defer(struct sock *sk=
, struct sk_buff *skb)
 	if ((skb !=3D tcp_write_queue_tail(sk)) && (limit >=3D skb->len))
 		goto send_now;
=20
-	if (sysctl_tcp_tso_win_divisor) {
+	win_divisor =3D ACCESS_ONCE(sysctl_tcp_tso_win_divisor);
+	if (win_divisor) {
 		u32 chunk =3D min(tp->snd_wnd, tp->snd_cwnd * tp->mss_cache);
=20
 		/* If at least some fraction of a window is available,
 		 * just use it.
 		 */
-		chunk /=3D sysctl_tcp_tso_win_divisor;
+		chunk /=3D win_divisor;
 		if (limit >=3D chunk)
 			goto send_now;
 	} else {


