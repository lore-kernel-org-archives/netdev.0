From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Wed, 23 Nov 2011 15:38:44 +0100
Message-ID: <1322059124.17693.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111122181320.38a70cf8@telperion.jlyo.org>
	 <20111122.192338.1206677511966747729.davem@davemloft.net>
	 <20111122183727.01ab6f04@telperion.jlyo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Young <jlyo@jlyo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:62929 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605Ab1KWOir (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 09:38:47 -0500
Received: by qyd20 with SMTP id 20so426486qyd.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 06:38:47 -0800 (PST)
In-Reply-To: <20111122183727.01ab6f04@telperion.jlyo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 novembre 2011 =C3=A0 18:37 -0600, Jesse Young a =C3=A9crit =
:
> On Tue, 22 Nov 2011 19:23:38 -0500 (EST)
> David Miller <davem@davemloft.net> wrote:
>=20
> > From: Jesse Young <jlyo@jlyo.org>
> > Date: Tue, 22 Nov 2011 18:13:20 -0600
> >
> > > What's also puzzling, is that I see no packet drop reporting in
> > > $ ifconfig lo
> > > lo: flags=3D73<UP,LOOPBACK,RUNNING>  mtu 16436  metric 1
> > > inet 127.0.0.1  netmask 255.0.0.0
> > > inet6 ::1  prefixlen 128  scopeid 0x10<host>
> > > loop  txqueuelen 0  (Local Loopback)
> > > RX packets 276411482  bytes 15822880567 (14.7 GiB)
> > > RX errors 0  dropped 0  overruns 0  frame 0
> > > TX packets 276411482 bytes 15822880567 (14.7 GiB)
> > > TX errors 0 dropped 0 overruns 0 carrier 0 collisions
> >
> > The device driver therefore isn't even seeing the packets, they are
> > being dropped elsewhere.
> >
> > Why is this "puzzling"?
> >
> > There's layers upon layers and thousands of places where packets ca=
n
> > be dropped between the originating network stack and the actual dev=
ice
> > driver.
>=20
> Maybe puzzling isn't the best word... just some more relevant
> information.  Also, this is the loopback interface, there is no devic=
e
> driver, PHY or DLL layer in question here (just the loopback's mock
> driver/PHY/DLL).
>=20
> I presume that the drop is occuring in between the NET layer, and the=
 sys
> call interface, do you agree?  Where should I begin looking?
> --

Here is the patch to solve this IPv6 problem, thanks a lot for the
report !

[PATCH] ipv6: tcp: fix tcp_v6_conn_request()

Since linux 2.6.26 (commit c6aefafb7ec6 : Add IPv6 support to TCP SYN
cookies), we can drop a SYN packet reusing a TIME_WAIT socket.

(As a matter of fact we fail to send the SYNACK answer)

As the client resends its SYN packet after a one second timeout, we
accept it, because first packet removed the TIME_WAIT socket before
being dropped.

This probably explains why nobody ever noticed or complained.

Reported-by: Jesse Young <jlyo@jlyo.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/tcp_ipv6.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 36131d1..2dea4bb 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1255,6 +1255,13 @@ static int tcp_v6_conn_request(struct sock *sk, =
struct sk_buff *skb)
 	if (!want_cookie || tmp_opt.tstamp_ok)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
=20
+	treq->iif =3D sk->sk_bound_dev_if;
+
+	/* So that link locals have meaning */
+	if (!sk->sk_bound_dev_if &&
+	    ipv6_addr_type(&treq->rmt_addr) & IPV6_ADDR_LINKLOCAL)
+		treq->iif =3D inet6_iif(skb);
+
 	if (!isn) {
 		struct inet_peer *peer =3D NULL;
=20
@@ -1264,12 +1271,6 @@ static int tcp_v6_conn_request(struct sock *sk, =
struct sk_buff *skb)
 			atomic_inc(&skb->users);
 			treq->pktopts =3D skb;
 		}
-		treq->iif =3D sk->sk_bound_dev_if;
-
-		/* So that link locals have meaning */
-		if (!sk->sk_bound_dev_if &&
-		    ipv6_addr_type(&treq->rmt_addr) & IPV6_ADDR_LINKLOCAL)
-			treq->iif =3D inet6_iif(skb);
=20
 		if (want_cookie) {
 			isn =3D cookie_v6_init_sequence(sk, skb, &req->mss);
