From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: OOP in ip_cmsg_recv (net-next)
Date: Tue, 04 May 2010 06:43:45 +0200
Message-ID: <1272948225.2407.170.camel@edumazet-laptop>
References: <20100503094735.077c2af5@nehalam>
	 <1272906266.2226.77.camel@edumazet-laptop>
	 <1272907269.2226.111.camel@edumazet-laptop>
	 <20100503.152351.181464355.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f217.google.com ([209.85.218.217]:35863 "EHLO
	mail-bw0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155Ab0EDEnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 00:43:50 -0400
Received: by bwz9 with SMTP id 9so1855436bwz.29
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 21:43:49 -0700 (PDT)
In-Reply-To: <20100503.152351.181464355.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 03 mai 2010 =C3=A0 15:23 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 03 May 2010 19:21:09 +0200
>=20
> > =20
> > -	/* skb is now orphaned, might be freed outside of locked section =
*/
> > -	consume_skb(skb);
> > +	/* skb is now orphaned, can be freed outside of locked section */
> > +	__kfree_skb(skb);
> >  }
> >  EXPORT_SYMBOL(skb_free_datagram_locked);
>=20
> Eric, if you do this you undo the utility of the SKB packet drop trac=
ing
> that Neil wrote.
>=20
> consome_skb() says that the application actually took in the packet a=
nd
> we didn't drop it due to some error or similar.
>=20
> Whereas __kfree_skb() is going to be tagged as a packet drop and the
> data didn't reach the application.
>=20
> So if you need to use __kfree_skb() to fix this you'll need to someho=
w
> add some appropriate annotations for the tracer.  Perhaps add a
> __consume_skb() that is marked for the tracing stuff and does what
> you need.
> --

David, if I am not mistaken (not thea yet for me this early morning) th=
e
tracer you mention is included in kfree_skb(), not in __kfree_skb() :

void kfree_skb(struct sk_buff *skb)
{
        if (unlikely(!skb))
                return;
        if (likely(atomic_read(&skb->users) =3D=3D 1))
                smp_rmb();
        else if (likely(!atomic_dec_and_test(&skb->users)))
                return;
        trace_kfree_skb(skb, __builtin_return_address(0));
        __kfree_skb(skb);
}
EXPORT_SYMBOL(kfree_skb);



I only copied part of consume_skb() which doesnt call
trace_kfree_skb() :

void consume_skb(struct sk_buff *skb)
{
        if (unlikely(!skb))
                return;
        if (likely(atomic_read(&skb->users) =3D=3D 1))
                smp_rmb();
        else if (likely(!atomic_dec_and_test(&skb->users)))
                return;
        __kfree_skb(skb);
}
EXPORT_SYMBOL(consume_skb);


So I believe my second patch is a bit better : We dont even lock the
socket in the (rare) case we should not orphan the skb ;)

We keep the two slab calls outside of sock lock, so we keep sock locked
for a very very short time period (remember we now use lock_sock_bh() :
producers now might spin on the lock instead of queueing packet in
backlog)

Thanks !

[PATCH net-next-2.6] net: skb_free_datagram_locked() fix

Commit 4b0b72f7dd617b ( net: speedup udp receive path )
introduced a bug in skb_free_datagram_locked().

We should not skb_orphan() skb if we dont have the guarantee we are the
last skb user, this might happen with MSG_PEEK concurrent users.

To keep socket locked for the smallest period of time, we split
consume_skb() logic, inlined in skb_free_datagram_locked()

Reported-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/core/datagram.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

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


