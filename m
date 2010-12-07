From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: avoid a possible divide by zero
Date: Tue, 07 Dec 2010 22:28:08 +0100
Message-ID: <1291757288.5324.18.camel@edumazet-laptop>
References: <201012071639.58884.Martin@lichtvoll.de>
	 <1291738321.2695.338.camel@edumazet-laptop>
	 <1291755776.21627.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Martin Steigerwald <Martin@lichtvoll.de>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40184 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752703Ab0LGVeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 16:34:02 -0500
Received: by wwa36 with SMTP id 36so410041wwa.1
        for <netdev@vger.kernel.org>; Tue, 07 Dec 2010 13:34:01 -0800 (PST)
In-Reply-To: <1291755776.21627.13.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 d=C3=A9cembre 2010 =C3=A0 21:02 +0000, Ben Hutchings a =C3=A9=
crit :
> On Tue, 2010-12-07 at 17:12 +0100, Eric Dumazet wrote:
> > Le mardi 07 d=C3=A9cembre 2010 =C3=A0 16:39 +0100, Martin Steigerwa=
ld a =C3=A9crit :
> >=20
> > > A participant of a linux performance training I hold found a bug =
with=20
> > > window scaling which did not receive any reply as well:
> > >=20
> > > Bug 20312 -  System freeze with multiples of 32 in=20
> > > /proc/sys/net/ipv4/tcp_adv_win_scale
> > > https://bugzilla.kernel.org/show_bug.cgi?id=3D20312
> > >=20
> >=20
> > User bug ?
> >=20
> > Documentation/networking/ip-sysctl.txt
> >=20
> > tcp_adv_win_scale - INTEGER
> > 	Count buffering overhead as bytes/2^tcp_adv_win_scale=20
> > 	(if tcp_adv_win_scale > 0) or bytes-bytes/2^(-tcp_adv_win_scale),
> > 	if it is <=3D 0.
> > 	Default: 2
> >=20
> > Given we use 32bit numbers, using values outside of [-31 ... 31] ma=
kes litle sense.
> >=20
> > We could add sysctl range limit, but user should not mess with=20
> > /proc/sys/net/ipv4/parameters unless he knows what he is doing ?
> [...]
>=20
> For mere humans, the range is not quite os obvious.  Which is why thi=
s
> has been fixed in net-2.6 (as noted on that bug report now).
>=20

Thanks

Great, I feel we are going to fix all sysctls, one by one then :(

lkml removed from Cc


[PATCH] tcp: avoid a possible divide by zero

sysctl_tcp_tso_win_divisor might be set to zero while one cpu runs in
tcp_tso_should_defer(). Make sure we dont allow a divide by zero by
reading sysctl_tcp_tso_win_divisor once.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/tcp_output.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 05b1ecf..0281223 100644
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
+	win_divisor =3D sysctl_tcp_tso_win_divisor;
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


