From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH 3/3] ixgbe: Do not allocate too many
 netdev txqueues
Date: Sat, 27 Feb 2010 17:02:36 -0800
Message-ID: <1267318956.2052.1.camel@localhost>
References: <20100226091318.19796.70225.stgit@localhost.localdomain>
	 <20100226091519.19796.82441.stgit@localhost.localdomain>
	 <1267193054.9082.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39336 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031277Ab0B1BCi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 Feb 2010 20:02:38 -0500
In-Reply-To: <1267193054.9082.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-26 at 06:04 -0800, Eric Dumazet wrote:
> Le vendredi 26 f=C3=A9vrier 2010 =C3=A0 01:15 -0800, Jeff Kirsher a =C3=
=A9crit :
> > From: John Fastabend <john.r.fastabend@intel.com>
> >=20
> > Instead of allocating 128 struct netdev_queue per device, use the
> > minimum value between 128 and the number of possible txq's, to
> > reduce ram usage and "tc -s -d class shod dev .." output.
> >=20
> > This patch fixes Eric Dumazet's patch to set the TX queues to
> > the correct minimum.
> >=20
> > Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >=20
> >  drivers/net/ixgbe/ixgbe_main.c |   14 +++++++++++++-
> >  1 files changed, 13 insertions(+), 1 deletions(-)
> >=20
> > diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixg=
be_main.c
> > index 4a01022..a961da2 100644
> > --- a/drivers/net/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ixgbe/ixgbe_main.c
> > @@ -5996,6 +5996,7 @@ static int __devinit ixgbe_probe(struct pci_d=
ev *pdev,
> >  	const struct ixgbe_info *ii =3D ixgbe_info_tbl[ent->driver_data];
> >  	static int cards_found;
> >  	int i, err, pci_using_dac;
> > +	unsigned int indices =3D num_possible_cpus();
> >  #ifdef IXGBE_FCOE
> >  	u16 device_caps;
> >  #endif
> > @@ -6034,7 +6035,18 @@ static int __devinit ixgbe_probe(struct pci_=
dev *pdev,
> >  	pci_set_master(pdev);
> >  	pci_save_state(pdev);
> > =20
> > -	netdev =3D alloc_etherdev_mq(sizeof(struct ixgbe_adapter), MAX_TX=
_QUEUES);
> > +	if (ii->mac =3D=3D ixgbe_mac_82598EB)
> > +		indices =3D min_t(unsigned int, indices, IXGBE_MAX_RSS_INDICES);
> > +	else
> > +		indices =3D min_t(unsigned int, indices, IXGBE_MAX_FDIR_INDICES)=
;
> > +
> > +	indices =3D max_t(unsigned int, indices, IXGBE_MAX_DCB_INDICES);
> > +#ifdef IXGBE_FCOE
> > +	indices +=3D min_t(unsigned int, num_possible_cpus(),
> > +			 IXGBE_MAX_FCOE_INDICES);
> > +#endif
> > +	indices =3D min_t(unsigned int, indices, MAX_TX_QUEUES);
> > +	netdev =3D alloc_etherdev_mq(sizeof(struct ixgbe_adapter), indice=
s);
> >  	if (!netdev) {
> >  		err =3D -ENOMEM;
> >  		goto err_alloc_etherdev;
> >=20
>=20
> Thanks Jeff, but what is the reason for limiting to MAX_TX_QUEUES ?
> Is it a hardware issue ?
>=20

MAX_TX_QUEUES is 128, which is the maximum the 82599 device supports in
hardware (82598 supports 32 Tx queues).  I'm not sure why you'd ever
want to have more Tx queues than what you have in the network device.
Perhaps I don't understand the question?

Cheers,
-PJ

