From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: inherit listener congestion control for
 passive cnx
Date: Wed, 30 Nov 2011 12:02:41 +0100
Message-ID: <1322650961.2403.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111130003112.C04FE29005FE@tardy>
	 <1322630461.2596.61.camel@edumazet-laptop>
	 <1322631613.2596.70.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Rick Jones <raj@tardy.cup.hp.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:43163 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752807Ab1K3LCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 06:02:46 -0500
Received: by qyk4 with SMTP id 4so169253qyk.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 03:02:45 -0800 (PST)
In-Reply-To: <1322631613.2596.70.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 30 novembre 2011 =C3=A0 06:40 +0100, Eric Dumazet a =C3=A9c=
rit :
> Le mercredi 30 novembre 2011 =C3=A0 06:21 +0100, Eric Dumazet a =C3=A9=
crit :
>=20
> > So my suggestion would be to use this two lines patch instead :
> >=20
> > diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> > index 945efff..6b066e2 100644
> > --- a/net/ipv4/tcp_minisocks.c
> > +++ b/net/ipv4/tcp_minisocks.c
> > @@ -495,8 +495,6 @@ struct sock *tcp_create_openreq_child(struct so=
ck *sk, struct request_sock *req,
> >  		newtp->frto_counter =3D 0;
> >  		newtp->frto_highmark =3D 0;
> > =20
> > -		newicsk->icsk_ca_ops =3D &tcp_init_congestion_ops;
> > -
> >  		tcp_set_ca_state(newsk, TCP_CA_Open);
> >  		tcp_init_xmit_timers(newsk);
> >  		skb_queue_head_init(&newtp->out_of_order_queue);
> >=20
>=20
> Please test this change and if its OK, resubmit your patch, with
> appropriate Documentation change, as pointed out by Yuchung Cheng=20

Hmm, after taking more time on this, we have to take care of module
refcounting and proper cleanup. I hope you dont mind I submit my final
version of this patch.

Thanks !

[PATCH net-next] tcp: inherit listener congestion control for passive c=
nx

Rick Jones reported that TCP_CONGESTION sockopt performed on a listener
was ignored for its children sockets : right after accept() the
congestion control for new socket is the system default one.

This seems an oversight of the initial design (quoted from Stephen)

Based on prior investigation and patch from Rick.

Reported-by: Rick Jones <rick.jones2@hp.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Yuchung Cheng <ycheng@google.com>
---
 Documentation/networking/ip-sysctl.txt |    3 +++
 net/ipv4/tcp_ipv4.c                    |    1 +
 net/ipv4/tcp_minisocks.c               |    4 +++-
 3 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index b886706..cb2b1c6 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -175,6 +175,9 @@ tcp_congestion_control - STRING
 	connections. The algorithm "reno" is always available, but
 	additional choices may be available based on kernel configuration.
 	Default is set as part of kernel configuration.
+	For passive connections, the listener congestion control choice
+	is inherited.
+	[see setsockopt(listenfd, SOL_TCP, TCP_CONGESTION, "name" ...) ]
=20
 tcp_cookie_size - INTEGER
 	Default size of TCP Cookie Transactions (TCPCT) option, that may be
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a9db4b1..c4b8b09 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1511,6 +1511,7 @@ exit:
 	return NULL;
 put_and_exit:
 	tcp_clear_xmit_timers(newsk);
+	tcp_cleanup_congestion_control(newsk);
 	bh_unlock_sock(newsk);
 	sock_put(newsk);
 	goto exit;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 945efff..9dc146e 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -495,7 +495,9 @@ struct sock *tcp_create_openreq_child(struct sock *=
sk, struct request_sock *req,
 		newtp->frto_counter =3D 0;
 		newtp->frto_highmark =3D 0;
=20
-		newicsk->icsk_ca_ops =3D &tcp_init_congestion_ops;
+		if (newicsk->icsk_ca_ops !=3D &tcp_init_congestion_ops &&
+		    !try_module_get(newicsk->icsk_ca_ops->owner))
+			newicsk->icsk_ca_ops =3D &tcp_init_congestion_ops;
=20
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
