From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bonding-devel] [v3 Patch 2/3] bridge: make bridge support
 netpoll
Date: Tue, 13 Apr 2010 10:33:20 -0700
Message-ID: <20100413103320.11a2a4f7@nehalam>
References: <20100408062234.4499.17042.sendpatchset@localhost.localdomain>
	<20100408062246.4499.5670.sendpatchset@localhost.localdomain>
	<20100408083710.2b61ee44@nehalam>
	<4BC2F7E2.7020309@redhat.com>
	<1271068737.16881.18.camel@edumazet-laptop>
	<20100412083842.26d71bda@nehalam>
	<4BC43214.6030009@redhat.com>
	<8304.1271177567@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <amwang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	Andy Gospodarek <gospo@redhat.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	Jeff Moyer <jmoyer@redhat.com>, Matt Mackall <mpm@selenic.com>,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8304.1271177567@death.nxdomain.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 13 Apr 2010 09:52:47 -0700
Jay Vosburgh <fubar@us.ibm.com> wrote:

> Cong Wang <amwang@redhat.com> wrote:
>=20
> >Stephen Hemminger wrote:
> >> On Mon, 12 Apr 2010 12:38:57 +0200
> >> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >>=20
> >>> Le lundi 12 avril 2010 =C3=A0 18:37 +0800, Cong Wang a =C3=A9crit=
 :
> >>>> Stephen Hemminger wrote:
> >>>>> There is no protection on dev->priv_flags for SMP access.
> >>>>> It would better bit value in dev->state if you are using it as =
control flag.
> >>>>>
> >>>>> Then you could use=20
> >>>>> 			if (unlikely(test_and_clear_bit(__IN_NETPOLL, &skb->dev->sta=
te)))
> >>>>> 				netpoll_send_skb(...)
> >>>>>
> >>>>>
> >>>> Hmm, I think we can't use ->state here, it is not for this kind =
of purpose,
> >>>> according to its comments.
> >>>>
> >>>> Also, I find other usages of IFF_XXX flags of ->priv_flags are a=
lso using
> >>>> &, | to set or clear the flags. So there must be some other thin=
gs preventing
> >>>> the race...
> >>> Yes, its RTNL that protects priv_flags changes, hopefully...
> >>>
> >>=20
> >> The patch was not protecting priv_flags with RTNL.
> >> For example..
> >>=20
> >>=20
> >> @@ -308,7 +312,9 @@ static void netpoll_send_skb(struct netp
> >>  		     tries > 0; --tries) {
> >>  			if (__netif_tx_trylock(txq)) {
> >>  				if (!netif_tx_queue_stopped(txq)) {
> >> +					dev->priv_flags |=3D IFF_IN_NETPOLL;
> >>  					status =3D ops->ndo_start_xmit(skb, dev);
> >> +					dev->priv_flags &=3D ~IFF_IN_NETPOLL;
> >>  					if (status =3D=3D NETDEV_TX_OK)
> >>  						txq_trans_update(txq);
> >
> >Hmm, but I checked the bonding case (IFF_BONDING), it doesn't
> >hold rtnl_lock. Strange.
>=20
> 	I looked, and there are a couple of cases in bonding that don't
> have RTNL for adjusting priv_flags (in bond_ab_arp_probe when no slav=
es
> are up, and a couple of cases in 802.3ad).  I think the solution ther=
e
> is to move bonding away from priv_flags for some of this (e.g., conve=
rt
> bonding to use a frame hook like bridge and macvlan, and greatly
> simplify skb_bond_should_drop), but that's a separate topic.
>=20
> 	The majority of the cases, however, do hold RTNL.  Bonding
> generally doesn't have to acquire RTNL itself, since whatever called
> into bonding is holding it already.  For example, the slave add and
> remove paths (bond_enslave, bond_release) are called either via sysfs=
 or
> ioctl, both of which acquire RTNL.  All of the set and clear operatio=
ns
> for IFF_BONDING fall into this category; look at bonding_store_slaves
> for an example.
>=20
> 	Bonding does acquire RTNL itself when performing failovers,
> e.g., bond_mii_monitor holds RTNL prior to calling bond_miimon_commit=
,
> which will change priv_flags.
>=20

All this was related to netpoll. And netpoll processing often needs to =
occur
in hard IRQ context. Therefor netpoll stuff and RTNL (which is a mutex)=
,
really don't mix well.  Keep RTNL for what it was meant for network
reconfiguration. Don't turn it into a network special BKL.



--=20
