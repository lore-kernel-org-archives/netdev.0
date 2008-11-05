From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] skb_free_datagram() doing something expensive ?
Date: Wed, 05 Nov 2008 06:05:08 +0100
Message-ID: <49112984.3000808@cosmosbay.com>
References: <4910D47E.4030004@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040304030707050006090507"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Corey Minyard <minyard@acm.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:39691 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbYKEFF0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 00:05:26 -0500
In-Reply-To: <4910D47E.4030004@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040304030707050006090507
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Eric Dumazet a =E9crit :
> Hi all
>=20
> I noticed high contention on udp_memory_allocated on a typical VOIP=20
> application.
>=20
> (Now that oprofile correctly runs on my machine :) )
>=20
> I can see that skb_free_datagram() is :
>=20
> void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
> {
>        kfree_skb(skb);
>        sk_mem_reclaim(sk);
> }
>=20
> So each time an UDP packet is received, we must touch udp_memory_alloca=
ted
>=20
> Each time application reads a packet, we call sk_mem_reclaim() and touc=
h=20
> again udp_memory_allocated.
>=20
> Surely this cannot be correct ?
>=20
> If this is correct, time is to resurrect a patch to make=20
> proto->memory_allocated a percpu_counter
> or something to have a percpu reserve of say 64 or 128 pages to avoid=20
> cache line trashing...
>=20
> tcp_memory_allocated do not have this problem, since tcp carefully call=
s=20
> sk_mem_reclaim(sk) only on
> selected paths, not on fast path.
>=20
> Thanks
>=20
>=20

What we can do is to avoid reclaiming space if forward_alloc is less than=
 a page

We did that in the past, when introducing sk_mem_reclaim_partial() in=20
commit 9993e7d313e80bdc005d09c7def91903e0068f07
([TCP]: Do not purge sk_forward_alloc entirely in tcp_delack_timer())

This patch gives a nice speedup on UDP, particularly for multiple
RTP flows, where each flow has a medium trafic (say VOIP trafic)

[PATCH] net: sk_free_datagram() should use sk_mem_reclaim_partial()

I noticed a contention on udp_memory_allocated on regular UDP application=
s.

While tcp_memory_allocated is seldom used, it appears each incoming UDP f=
rame
is currently touching udp_memory_allocated when queued, and when received=
 by
application.

One possible solution is to use sk_mem_reclaim_partial() instead of
sk_mem_reclaim(), so that we keep a small reserve (less than one page)
of memory for each UDP socket.

We did something very similar on TCP side in commit
9993e7d313e80bdc005d09c7def91903e0068f07
([TCP]: Do not purge sk_forward_alloc entirely in tcp_delack_timer())

A more complex solution would need to convert prot->memory_allocated to
use a percpu_counter with batches of 64 or 128 pages.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------040304030707050006090507
Content-Type: text/plain;
 name="udp_mem_reclaim.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="udp_mem_reclaim.patch"

diff --git a/net/core/datagram.c b/net/core/datagram.c
index ee63184..5e2ac0c 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -209,7 +209,7 @@ struct sk_buff *skb_recv_datagram(struct sock *sk, unsigned flags,
 void skb_free_datagram(struct sock *sk, struct sk_buff *skb)
 {
 	kfree_skb(skb);
-	sk_mem_reclaim(sk);
+	sk_mem_reclaim_partial(sk);
 }
 
 /**
@@ -248,8 +248,7 @@ int skb_kill_datagram(struct sock *sk, struct sk_buff *skb, unsigned int flags)
 		spin_unlock_bh(&sk->sk_receive_queue.lock);
 	}
 
-	kfree_skb(skb);
-	sk_mem_reclaim(sk);
+	skb_free_datagram(sk, skb);
 	return err;
 }
 

--------------040304030707050006090507--
