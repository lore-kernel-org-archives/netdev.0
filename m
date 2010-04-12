From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bonding-devel] [v3 Patch 2/3] bridge: make bridge support
 netpoll
Date: Mon, 12 Apr 2010 08:38:42 -0700
Message-ID: <20100412083842.26d71bda@nehalam>
References: <20100408062234.4499.17042.sendpatchset@localhost.localdomain>
	<20100408062246.4499.5670.sendpatchset@localhost.localdomain>
	<20100408083710.2b61ee44@nehalam>
	<4BC2F7E2.7020309@redhat.com>
	<1271068737.16881.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <amwang@redhat.com>, Jay Vosburgh <fubar@us.ibm.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Matt Mackall <mpm@selenic.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jeff Moyer <jmoyer@redhat.com>,
	Andy Gospodarek <gospo@redhat.com>,
	bonding-devel@lists.sourceforge.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1271068737.16881.18.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 12 Apr 2010 12:38:57 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le lundi 12 avril 2010 =C3=A0 18:37 +0800, Cong Wang a =C3=A9crit :
> > Stephen Hemminger wrote:
> > > There is no protection on dev->priv_flags for SMP access.
> > > It would better bit value in dev->state if you are using it as co=
ntrol flag.
> > >=20
> > > Then you could use=20
> > > 			if (unlikely(test_and_clear_bit(__IN_NETPOLL, &skb->dev->state=
)))
> > > 				netpoll_send_skb(...)
> > >=20
> > >=20
> >=20
> > Hmm, I think we can't use ->state here, it is not for this kind of =
purpose,
> > according to its comments.
> >=20
> > Also, I find other usages of IFF_XXX flags of ->priv_flags are also=
 using
> > &, | to set or clear the flags. So there must be some other things =
preventing
> > the race...
>=20
> Yes, its RTNL that protects priv_flags changes, hopefully...
>=20

The patch was not protecting priv_flags with RTNL.
=46or example..


@@ -308,7 +312,9 @@ static void netpoll_send_skb(struct netp
 		     tries > 0; --tries) {
 			if (__netif_tx_trylock(txq)) {
 				if (!netif_tx_queue_stopped(txq)) {
+					dev->priv_flags |=3D IFF_IN_NETPOLL;
 					status =3D ops->ndo_start_xmit(skb, dev);
+					dev->priv_flags &=3D ~IFF_IN_NETPOLL;
 					if (status =3D=3D NETDEV_TX_OK)
 						txq_trans_update(txq);
