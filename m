From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2] net: rfs: enable RFS before first data packet is
 received
Date: Fri, 17 Jun 2011 15:45:15 +0200
Message-ID: <1308318315.2780.12.camel@edumazet-laptop>
References: <1308104128.4578.10.camel@edumazet-laptop>
	 <1308268246.2925.37.camel@bwh-desktop>
	 <20110616.233841.1893411919443027926.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bhutchings@solarflare.com, therbert@google.com,
	netdev@vger.kernel.org, hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47419 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754678Ab1FQNpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 09:45:19 -0400
Received: by wwe5 with SMTP id 5so476661wwe.1
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2011 06:45:18 -0700 (PDT)
In-Reply-To: <20110616.233841.1893411919443027926.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 juin 2011 =C3=A0 23:38 -0400, David Miller a =C3=A9crit :
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 17 Jun 2011 00:50:46 +0100
>=20
> > On Wed, 2011-06-15 at 04:15 +0200, Eric Dumazet wrote:
> >> @@ -1594,6 +1594,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk=
_buff *skb)
> >>  			goto discard;
> >> =20
> >>  		if (nsk !=3D sk) {
> >> +			sock_rps_save_rxhash(nsk, skb->rxhash);
> >>  			if (tcp_child_process(sk, nsk, skb)) {
> >>  				rsk =3D nsk;
> >>  				goto reset;
> >>=20
> >=20
> > I haven't tried this, but it looks reasonable to me.
> >=20
> > What about IPv6?  The logic in tcp_v6_do_rcv() looks very similar.
>=20
> Indeed ipv6 side needs the same fix.
>=20
> Eric please add that part and resubmit.  And in fact I might stick
> this into net-2.6 instead of net-next-2.6
>=20

OK, here is the net-2.6 based one then, thanks !

[PATCH v2] net: rfs: enable RFS before first data packet is received

=46irst packet received on a passive tcp flow is not correctly RFS
steered.

One sock_rps_record_flow() call is missing in inet_accept()

But before that, we also must record rxhash when child socket is setup.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Tom Herbert <therbert@google.com>
CC: Ben Hutchings <bhutchings@solarflare.com>
CC: Jamal Hadi Salim <hadi@cyberus.ca>
---
V2: add ipv6 support, as Ben noticed.

 net/ipv4/af_inet.c  |    1 +
 net/ipv4/tcp_ipv4.c |    1 +
 net/ipv6/tcp_ipv6.c |    1 +
 3 files changed, 3 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9c19260..eae1f67 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -676,6 +676,7 @@ int inet_accept(struct socket *sock, struct socket =
*newsock, int flags)
=20
 	lock_sock(sk2);
=20
+	sock_rps_record_flow(sk2);
 	WARN_ON(!((1 << sk2->sk_state) &
 		  (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT | TCPF_CLOSE)));
=20
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a7d6671..708dc20 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1589,6 +1589,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff=
 *skb)
 			goto discard;
=20
 		if (nsk !=3D sk) {
+			sock_rps_save_rxhash(nsk, skb->rxhash);
 			if (tcp_child_process(sk, nsk, skb)) {
 				rsk =3D nsk;
 				goto reset;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d1fd287..87551ca 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1644,6 +1644,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct =
sk_buff *skb)
 		 * the new socket..
 		 */
 		if(nsk !=3D sk) {
+			sock_rps_save_rxhash(nsk, skb->rxhash);
 			if (tcp_child_process(sk, nsk, skb))
 				goto reset;
 			if (opt_skb)


