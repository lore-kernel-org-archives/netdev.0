From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Warning in net/ipv4/af_inet.c:154
Date: Wed, 26 May 2010 12:12:56 +0200
Message-ID: <1274868776.2672.96.camel@edumazet-laptop>
References: <20100525115813.GA28063@kryten>
	 <1274801229.5020.80.camel@edumazet-laptop> <20100526031943.GA28295@kryten>
	 <20100526.005634.48509140.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: anton@samba.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:29811 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208Ab0EZKNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 06:13:00 -0400
Received: by fg-out-1718.google.com with SMTP id e12so722871fga.1
        for <netdev@vger.kernel.org>; Wed, 26 May 2010 03:12:59 -0700 (PDT)
In-Reply-To: <20100526.005634.48509140.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 26 mai 2010 =C3=A0 00:56 -0700, David Miller a =C3=A9crit :
> From: Anton Blanchard <anton@samba.org>
> Date: Wed, 26 May 2010 13:19:43 +1000
>=20
> > I notice we update sk_forward_alloc in sk_mem_charge and sk_mem_unc=
harge.
> > Since it isn't an atomic variable I went looking for a lock somewhe=
re in
> > the call chain (first thought was the socket lock). I couldn't find
> > anything, but I could easily be missing something.
>=20
> We take the lock properly for all of the skb_queue_rcv_skb() cases
> but this rule isn't followed properly for skb_queue_err_skb().
>=20
> Eric, look at even things like skb_tstamp_tx().  Nothing locks the
> socket in those cases, yet we dip down into sock_queue_err_skb() and
> thus invoke skb_set_owner_r which goes into sk_mem_charge() and does
> the non-atomic update on ->sk_forward_alloc.
>=20
> I am sure there are other cases with this problem involving
> sock_queue_err_skb()...  ip_icmp_error() (via __udp4_lib_err()),
> ipv6_icmp_error(), etc.

All these points are indeed problematic, since a loooong time, so this
is a stable material.

You are 100% right David, maybe we should add a test when changing
sk_forward_alloc to test if socket is locked (lockdep only test), but
that's for 2.6.36 :)

RAW path is not impacted (yet)

Thanks

[PATCH] net: fix sk_forward_alloc corruptions

As David found out, sock_queue_err_skb() should be called with socket
lock hold, or we risk sk_forward_alloc corruption, since we use non
atomic operations to update this field.

This patch adds bh_lock_sock()/bh_unlock_sock() pair to three spots.
(BH already disabled)

1) skb_tstamp_tx()=20
2) Before calling ip_icmp_error(), in __udp4_lib_err()=20
3) Before calling ipv6_icmp_error(), in __udp6_lib_err()

Reported-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/skbuff.c |    4 ++++
 net/ipv4/udp.c    |    2 ++
 net/ipv6/udp.c    |    6 ++++--
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c543dd2..439e3b9 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2991,7 +2991,11 @@ void skb_tstamp_tx(struct sk_buff *orig_skb,
 	memset(serr, 0, sizeof(*serr));
 	serr->ee.ee_errno =3D ENOMSG;
 	serr->ee.ee_origin =3D SO_EE_ORIGIN_TIMESTAMPING;
+
+	bh_lock_sock(sk);
 	err =3D sock_queue_err_skb(sk, skb);
+	bh_unlock_sock(sk);
+
 	if (err)
 		kfree_skb(skb);
 }
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9de6a69..1d70ff0 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -634,7 +634,9 @@ void __udp4_lib_err(struct sk_buff *skb, u32 info, =
struct udp_table *udptable)
 		if (!harderr || sk->sk_state !=3D TCP_ESTABLISHED)
 			goto out;
 	} else {
+		bh_lock_sock(sk);
 		ip_icmp_error(sk, skb, err, uh->dest, info, (u8 *)(uh+1));
+		bh_unlock_sock(sk);
 	}
 	sk->sk_err =3D err;
 	sk->sk_error_report(sk);
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3d7a2c0..f441365 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -465,9 +465,11 @@ void __udp6_lib_err(struct sk_buff *skb, struct in=
et6_skb_parm *opt,
 	if (sk->sk_state !=3D TCP_ESTABLISHED && !np->recverr)
 		goto out;
=20
-	if (np->recverr)
+	if (np->recverr) {
+		bh_lock_sock(sk);
 		ipv6_icmp_error(sk, skb, err, uh->dest, ntohl(info), (u8 *)(uh+1));
-
+		bh_unlock_sock(sk);
+	}
 	sk->sk_err =3D err;
 	sk->sk_error_report(sk);
 out:


