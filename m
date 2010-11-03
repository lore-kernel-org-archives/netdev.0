From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 2/4] Ethtool: convert get_sg/set_sg calls to
	hw_features flag
Date: Wed, 3 Nov 2010 23:58:46 +0100
Message-ID: <20101103225846.GA32330@rere.qmqm.pl>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl> <9d89236b6e4ff8c66937fbd7d8ce76602e680c5b.1288496404.git.mirq-linux@rere.qmqm.pl> <20101102022438.GA4243@mcarlson.broadcom.com> <20101103222910.GA24320@rere.qmqm.pl> <20101103224247.GB9869@mcarlson.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	"linux-driver@qlogic.com" <linux-driver@qlogic.com>,
	"linux-net-drivers@solarflare.com" <linux-net-drivers@solarflare.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:38946 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752830Ab0KCW6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Nov 2010 18:58:47 -0400
Content-Disposition: inline
In-Reply-To: <20101103224247.GB9869@mcarlson.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 03, 2010 at 03:42:47PM -0700, Matt Carlson wrote:
> On Wed, Nov 03, 2010 at 03:29:10PM -0700, Micha?? Miros??aw wrote:
> > On Mon, Nov 01, 2010 at 07:24:38PM -0700, Matt Carlson wrote:
> > > On Fri, Oct 29, 2010 at 09:28:26PM -0700, Micha?? Miros??aw wrote=
:
> > > > diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
> > > > index 30ccbb6..b07e2d1 100644
> > > > --- a/drivers/net/tg3.c
> > > > +++ b/drivers/net/tg3.c
> > > > @@ -11306,7 +11306,6 @@ static const struct ethtool_ops tg3_eth=
tool_ops =3D {
> > > >         .get_rx_csum            =3D tg3_get_rx_csum,
> > > >         .set_rx_csum            =3D tg3_set_rx_csum,
> > > >         .set_tx_csum            =3D tg3_set_tx_csum,
> > > > -       .set_sg                 =3D ethtool_op_set_sg,

This is exchanged ...

> > > >         .set_tso                =3D tg3_set_tso,
> > > >         .self_test              =3D tg3_self_test,
> > > >         .get_strings            =3D tg3_get_strings,
> > > > @@ -14681,6 +14680,7 @@ static int __devinit tg3_init_one(struc=
t pci_dev *pdev,
> > > >         tp->rx_pending =3D TG3_DEF_RX_RING_PENDING;
> > > >         tp->rx_jumbo_pending =3D TG3_DEF_RX_JUMBO_RING_PENDING;
> > > >=20
> > > > +       dev->hw_features |=3D NETIF_F_SG;

=2E.. for this. (This introduces no functional changes, whatsoever.)

> > > Scatter-gather should not be enabled if TG3_FLAG_BROKEN_CHECKSUMS=
 is set.  I
> > > would do the following instead:
> > >=20
> > > 	if (!(tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS))
> > > 		dev->hw_features |=3D NETIF_F_SG;
> > >=20
> > > TG3_FLAG_BROKEN_CHECKSUMS is set in tg3_get_invariants(), so this=
 code
> > > would need to be placed later than that function call.
> >=20
> > This bug is there now, so I'll queue this as all other hints of exi=
stent
> > bugs that this patch series "uncovers".
>=20
> How so?  This patch would be introducing the bug.  From tg3_get_invar=
iants:
>=20
> 	if (tp->pci_chip_rev_id =3D=3D CHIPREV_ID_5700_B0)
> 		tp->tg3_flags |=3D TG3_FLAG_BROKEN_CHECKSUMS;
> 	else {
> 		unsigned long features =3D NETIF_F_IP_CSUM | NETIF_F_SG | NETIF_F_G=
RO;
>=20
> 		tp->tg3_flags |=3D TG3_FLAG_RX_CHECKSUMS;
> 		if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
> 			features |=3D NETIF_F_IPV6_CSUM;
> 		tp->dev->features |=3D features;
> 		vlan_features_add(tp->dev, features);
> 	}

Actually this is hidden anyway, because currently scatter-gather depend=
s
on checksumming offload. So the SG won't be enabled based on check left
in ethtool_set_sg().

Note, that hw_features flags enable toggling of the offloads but don't
enable them unless requested by a user later.

Best Regards,
Micha=B3 Miros=B3aw
