From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: forcedeth: convert to hw_features
Date: Fri, 15 Apr 2011 19:44:32 +0200
Message-ID: <20110415174432.GA26679@rere.qmqm.pl>
References: <20110415145049.CC33613A65@rere.qmqm.pl> <1302885588.2845.4.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:58992 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753616Ab1DORod (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 13:44:33 -0400
Content-Disposition: inline
In-Reply-To: <1302885588.2845.4.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2011 at 05:39:48PM +0100, Ben Hutchings wrote:
> On Fri, 2011-04-15 at 16:50 +0200, Micha=B3 Miros=B3aw wrote:
> > This also fixes a race around np->txrxctl_bits while changing RXCSU=
M offload.
> >=20
> > Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> > ---
> >  drivers/net/forcedeth.c |   78 +++++++++++++++--------------------=
-----------
> >  1 files changed, 26 insertions(+), 52 deletions(-)
> >=20
> > diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
> > index d5ab4da..ec9a32d 100644
> > --- a/drivers/net/forcedeth.c
> > +++ b/drivers/net/forcedeth.c
> > @@ -774,7 +774,6 @@ struct fe_priv {
> >  	u32 driver_data;
> >  	u32 device_id;
> >  	u32 register_size;
> > -	int rx_csum;
> >  	u32 mac_in_use;
> >  	int mgmt_version;
> >  	int mgmt_sema;
> > @@ -4480,58 +4479,36 @@ static int nv_set_pauseparam(struct net_dev=
ice *dev, struct ethtool_pauseparam*
> >  	return 0;
> >  }
> > =20
> > -static u32 nv_get_rx_csum(struct net_device *dev)
> > +static u32 nv_fix_features(struct net_device *dev, u32 features)
> >  {
> > -	struct fe_priv *np =3D netdev_priv(dev);
> > -	return np->rx_csum !=3D 0;
> > +	/* vlan is dependent on rx checksum offload */
> > +	if (features & (NETIF_F_HW_VLAN_TX|NETIF_F_HW_VLAN_RX))
> > +		features |=3D NETIF_F_RXCSUM;
> [...]
>=20
> Shouldn't this be done the other way round:
>=20
> 	if (!(features & NETIF_F_RXCSUM))
> 		features &=3D ~(NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
>=20
> So long as the VLAN feature flags are still set in wanted_features, t=
hey
> will be turned back on automatically if RXCSUM is re-enabled.

Yes, but this way is a direct translation from old ethtool_ops. Changin=
g
this needs implementing changing HW_VLAN features in set_features.

Best Regards,
Micha=B3 Miros=B3aw
