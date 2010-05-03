From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: OOP in ip_cmsg_recv (net-next)
Date: Mon, 03 May 2010 19:21:09 +0200
Message-ID: <1272907269.2226.111.camel@edumazet-laptop>
References: <20100503094735.077c2af5@nehalam>
	 <1272906266.2226.77.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:59809 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752267Ab0ECRVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 13:21:15 -0400
Received: by bwz19 with SMTP id 19so1451992bwz.21
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 10:21:13 -0700 (PDT)
In-Reply-To: <1272906266.2226.77.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 03 mai 2010 =C3=A0 19:04 +0200, Eric Dumazet a =C3=A9crit :
> Le lundi 03 mai 2010 =C3=A0 09:47 -0700, Stephen Hemminger a =C3=A9cr=
it :
> > I am getting occasional NULL pointer references with net-next kerne=
l.
> > No test, just usual stuff (like DNS).
> >=20
> > This is a new regression in net-next only.
> >=20
> >=20
> Hmm, skb->sk is NULL
>=20
> void ip_cmsg_recv(struct msghdr *msg, struct sk_buff *skb)
> {
> 	struct inet_sock *inet =3D inet_sk(skb->sk);
> 	unsigned flags =3D inet->cmsg_flags; // CRASH
>=20
>=20
> So a skb_free_datagram_locked() is at fault here...
>=20
> commit 4b0b72f7dd617b13abd1b04c947e15873e011a24 probably
>=20
> OK, the skb_orphan() should not be done at this point, if we are not =
the
> only user (and last user)
>=20
> Oh well, sorry for the regression ;)
>=20

I'll test following patch and report results to netdev :

diff --git a/net/core/datagram.c b/net/core/datagram.c
index 95b851f..e009753 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -229,13 +229,18 @@ EXPORT_SYMBOL(skb_free_datagram);
=20
 void skb_free_datagram_locked(struct sock *sk, struct sk_buff *skb)
 {
+	if (likely(atomic_read(&skb->users) =3D=3D 1))
+		smp_rmb();
+	else if (likely(!atomic_dec_and_test(&skb->users)))
+		return;
+
 	lock_sock_bh(sk);
 	skb_orphan(skb);
 	sk_mem_reclaim_partial(sk);
 	unlock_sock_bh(sk);
=20
-	/* skb is now orphaned, might be freed outside of locked section */
-	consume_skb(skb);
+	/* skb is now orphaned, can be freed outside of locked section */
+	__kfree_skb(skb);
 }
 EXPORT_SYMBOL(skb_free_datagram_locked);
=20


