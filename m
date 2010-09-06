From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: af_packet: skb_orphan should be avoided in TX path.
Date: Mon, 06 Sep 2010 17:44:27 +0200
Message-ID: <1283787867.2654.600.camel@edumazet-laptop>
References: <AANLkTi=oXDgEhEjt7V+Z4Pk8kv9X4Z8aCg2yAJDzuJ1J@mail.gmail.com>
	 <1283708635.3402.100.camel@edumazet-laptop>
	 <20100906103505.GA15254@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48834 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752692Ab0IFPoe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 11:44:34 -0400
Received: by fxm13 with SMTP id 13so2516123fxm.19
        for <netdev@vger.kernel.org>; Mon, 06 Sep 2010 08:44:32 -0700 (PDT)
In-Reply-To: <20100906103505.GA15254@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 septembre 2010 =C3=A0 13:35 +0300, Michael S. Tsirkin a =C3=
=A9crit :

> I think there are bigger issues here.  As was pointed out, drivers mi=
ght
> orphan skbs before they transmit them.
> And at least for tun, the reason is that we might hang on
> to skbs indefinitely because userspace is not reading them.
>=20
> So in that case, if you just prevent tun from orphaning skbs, the soc=
ket
> will be prevented from sending any more packets out even if they are =
for
> a completely unrelated destinations, right?
> Further, module can't get unloaded and I think socket can not get
> closed, so user can't kill the task which has the socket?
>=20
> And thinking about this, I think I see
> another issue related to the use of the destructor callback:
>=20
> static void tpacket_destruct_skb(struct sk_buff *skb)
> {
>         struct packet_sock *po =3D pkt_sk(skb->sk);
>         void *ph;
>=20
>         BUG_ON(skb =3D=3D NULL);
>=20
>         if (likely(po->tx_ring.pg_vec)) {
>                 ph =3D skb_shinfo(skb)->destructor_arg;
>                 BUG_ON(__packet_get_status(po, ph) !=3D TP_STATUS_SEN=
DING);
>                 BUG_ON(atomic_read(&po->tx_ring.pending) =3D=3D 0);
>                 atomic_dec(&po->tx_ring.pending);
>                 __packet_set_status(po, ph, TP_STATUS_AVAILABLE);
>         }
>=20
>         sock_wfree(skb);
>=20
> <-----
> at this point we still have to execute instructions
> in this function to return from it. However
> socket and thus module reference count
> got already dropped to 0, so I think module could get unloaded
> and these instructions could get overwritten.
>=20
> }
>=20
> I conclude that destructor callback should never point to a function =
residing
> in a module, always to a function that is guaranteed to be builtin, t=
his
> function must be the one that drops the last module reference.

It would be a surprise to use tx mmap (presumably to get high
performance), and a modular af_unix ;)

>=20
> Comments?

The whole thing (packet / tx mmap) is broken, if you ask me.

skb_orphan() is not about protecting data, but doing per socket memory
accounting.

We have to skb_orphan() while data is still in use by skb, not only in
drivers but in core network stack. (loopback case for example, no need
to think about TUN being special ;) )

So I believe using mmap and tx on af_unix is racy in its current design=
=2E

We probably can remove some skb_orphan() calls (now its done in core
network, no real need to make it from some drivers), but not have a
complete solution to the problem Changli raised, without adding yet
another field into skb_shared_info...



