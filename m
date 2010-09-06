From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: net: af_packet: skb_orphan should be avoided in TX path.
Date: Mon, 6 Sep 2010 22:53:30 +0300
Message-ID: <20100906195330.GA30715@redhat.com>
References: <AANLkTi=oXDgEhEjt7V+Z4Pk8kv9X4Z8aCg2yAJDzuJ1J@mail.gmail.com>
 <1283708635.3402.100.camel@edumazet-laptop>
 <20100906103505.GA15254@redhat.com>
 <1283787867.2654.600.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36554 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754726Ab0IFT7a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Sep 2010 15:59:30 -0400
Content-Disposition: inline
In-Reply-To: <1283787867.2654.600.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 06, 2010 at 05:44:27PM +0200, Eric Dumazet wrote:
> Le lundi 06 septembre 2010 =E0 13:35 +0300, Michael S. Tsirkin a =E9c=
rit :
>=20
> > I think there are bigger issues here.  As was pointed out, drivers =
might
> > orphan skbs before they transmit them.
> > And at least for tun, the reason is that we might hang on
> > to skbs indefinitely because userspace is not reading them.
> >=20
> > So in that case, if you just prevent tun from orphaning skbs, the s=
ocket
> > will be prevented from sending any more packets out even if they ar=
e for
> > a completely unrelated destinations, right?
> > Further, module can't get unloaded and I think socket can not get
> > closed, so user can't kill the task which has the socket?
> >=20
> > And thinking about this, I think I see
> > another issue related to the use of the destructor callback:
> >=20
> > static void tpacket_destruct_skb(struct sk_buff *skb)
> > {
> >         struct packet_sock *po =3D pkt_sk(skb->sk);
> >         void *ph;
> >=20
> >         BUG_ON(skb =3D=3D NULL);
> >=20
> >         if (likely(po->tx_ring.pg_vec)) {
> >                 ph =3D skb_shinfo(skb)->destructor_arg;
> >                 BUG_ON(__packet_get_status(po, ph) !=3D TP_STATUS_S=
ENDING);
> >                 BUG_ON(atomic_read(&po->tx_ring.pending) =3D=3D 0);
> >                 atomic_dec(&po->tx_ring.pending);
> >                 __packet_set_status(po, ph, TP_STATUS_AVAILABLE);
> >         }
> >=20
> >         sock_wfree(skb);
> >=20
> > <-----
> > at this point we still have to execute instructions
> > in this function to return from it. However
> > socket and thus module reference count
> > got already dropped to 0, so I think module could get unloaded
> > and these instructions could get overwritten.
> >=20
> > }
> >=20
> > I conclude that destructor callback should never point to a functio=
n residing
> > in a module, always to a function that is guaranteed to be builtin,=
 this
> > function must be the one that drops the last module reference.
>=20
> It would be a surprise to use tx mmap (presumably to get high
> performance), and a modular af_unix ;)

Hmm, this seems to be what distros ship. If it's illegal, we should dis=
able
this in Kconfig?

> >=20
> > Comments?
>=20
> The whole thing (packet / tx mmap) is broken, if you ask me.
>=20
> skb_orphan() is not about protecting data, but doing per socket memor=
y
> accounting.

Right.

> We have to skb_orphan() while data is still in use by skb, not only i=
n
> drivers but in core network stack. (loopback case for example, no nee=
d
> to think about TUN being special ;) )
>=20
> So I believe using mmap and tx on af_unix is racy in its current desi=
gn.
>=20
> We probably can remove some skb_orphan() calls (now its done in core
> network, no real need to make it from some drivers), but not have a
> complete solution to the problem Changli raised, without adding yet
> another field into skb_shared_info...

Whouldn't that just make the problem harder to debug?

--=20
MST
