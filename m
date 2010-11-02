From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH 4/4] Ethtool: convert get_tx_csum/set_tx_csum calls to
	hw_features flags
Date: Tue, 2 Nov 2010 02:23:45 +0100
Message-ID: <20101102012345.GE15848@rere.qmqm.pl>
References: <cover.1288496404.git.mirq-linux@rere.qmqm.pl> <904bc8c98062fc793573ee6bc120ed0b8af292d2.1288496405.git.mirq-linux@rere.qmqm.pl> <1288647537.2231.81.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Steve Glendinning <steve.glendinning@smsc.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	linux-driver@qlogic.com, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:34860 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750999Ab0KBBXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Nov 2010 21:23:46 -0400
Content-Disposition: inline
In-Reply-To: <1288647537.2231.81.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 01, 2010 at 09:38:57PM +0000, Ben Hutchings wrote:
> On Sun, 2010-10-31 at 02:09 +0200, Micha=B3 Miros=B3aw wrote:
> [...]
> > diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
> > index 9f6aeef..5ba4535 100644
> > --- a/drivers/net/dm9000.c
> > +++ b/drivers/net/dm9000.c
> > @@ -132,7 +132,6 @@ typedef struct board_info {
> >  	u32		wake_state;
> > =20
> >  	int		rx_csum;
> > -	int		can_csum;
> >  	int		ip_summed;
> >  } board_info_t;
> > =20
> > @@ -480,7 +479,7 @@ static int dm9000_set_rx_csum_unlocked(struct n=
et_device *dev, uint32_t data)
> >  {
> >  	board_info_t *dm =3D to_dm9000_board(dev);
> > =20
> > -	if (dm->can_csum) {
> > +	if (dev->hw_features & NETIF_F_IP_CSUM) {
>=20
> This is a bit ugly because can_csum is being used to indicate RX
> checksum offload capability whereas the checksum feature flags logica=
lly
> indicate TX checksum offload capability.  Of course, the two hardware
> features are highly correlated!

I briefly looked over the code. can_csum looked like "can do both TX
and RX checksum", so (dev->hw_features & NETIF_F_IP_CSUM) duplicates
information in this case. I can remove this change or just add a commen=
t
that we abuse hw_features a bit.

> [...]
> > diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> > index 9b0e598..95e8b7a 100644
> > --- a/net/core/ethtool.c
> > +++ b/net/core/ethtool.c
> [...]
> > @@ -1077,12 +1039,18 @@ static int __ethtool_set_sg(struct net_devi=
ce *dev, u32 data)
> >  	return 0;
> >  }
> > =20
> > +static u32 ethtool_get_tx_csum(struct net_device *dev)
> > +{
> > +	return (dev->features & (NETIF_F_ALL_CSUM|NETIF_F_SCTP_CSUM)) !=3D=
 0;
> > +}
> > +
> [...]
>=20
> It seems to me that NETIF_F_SCTP_CSUM should be added to
> NETIF_F_ALL_CSUM, though that may cause problems in some other places
> NETIF_F_ALL_CSUM is used.

This would need auditing NETIF_F_ALL_CSUM usage across the kernel, so
definitely a further patch material.

Best Regards,
Micha=B3 Miros=B3aw
