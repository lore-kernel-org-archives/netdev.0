From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 05/10] if_link: Add additional parameter to
 IFLA_VF_INFO for spoof checking
Date: Sat, 24 Sep 2011 22:54:46 -0700
Message-ID: <1316930087.2182.148.camel@jtkirshe-mobl>
References: <1316855863-6091-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316855863-6091-6-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1316882459.4122.83.camel@deadeye>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-jdpc4FxmF7Yu5/Xy4t+7"
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4972 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751030Ab1IYFyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Sep 2011 01:54:49 -0400
In-Reply-To: <1316882459.4122.83.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-jdpc4FxmF7Yu5/Xy4t+7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-09-24 at 09:40 -0700, Ben Hutchings wrote:
> On Sat, 2011-09-24 at 02:17 -0700, Jeff Kirsher wrote:
> > From: Greg Rose <gregory.v.rose@intel.com>
> >=20
> > Add configuration setting for drivers to turn spoof checking on or off
> > for discrete VFs.
> >=20
> > Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  include/linux/if_link.h   |    7 +++++++
> >  include/linux/netdevice.h |    3 +++
> >  net/core/rtnetlink.c      |   25 ++++++++++++++++++++++---
> >  3 files changed, 32 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/include/linux/if_link.h b/include/linux/if_link.h
> > index 0ee969a..8bd6d6d 100644
> > --- a/include/linux/if_link.h
> > +++ b/include/linux/if_link.h
> > @@ -279,6 +279,7 @@ enum {
> >  	IFLA_VF_MAC,		/* Hardware queue specific attributes */
> >  	IFLA_VF_VLAN,
> >  	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
> > +	IFLA_VF_SPOOFCHK,	/* Spoof Checking on/off switch */
> >  	__IFLA_VF_MAX,
> >  };
> > =20
> > @@ -300,12 +301,18 @@ struct ifla_vf_tx_rate {
> >  	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
> >  };
> > =20
> > +struct ifla_vf_spoofchk {
> > +	__u32 vf;
> > +	__u32 setting;
> > +};
> > +
> >  struct ifla_vf_info {
> >  	__u32 vf;
> >  	__u8 mac[32];
> >  	__u32 vlan;
> >  	__u32 qos;
> >  	__u32 tx_rate;
> > +	__u32 spoofchk;
> >  };
>=20
> Not something you need to change now, but shouldn't this last struct
> definition be #ifdef __KERNEL__?
>=20
> >  /* VF ports management section
> > diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> > index 43b3298..a2951a0 100644
> > --- a/include/linux/netdevice.h
> > +++ b/include/linux/netdevice.h
> > @@ -781,6 +781,7 @@ struct netdev_tc_txq {
> >   * int (*ndo_set_vf_mac)(struct net_device *dev, int vf, u8* mac);
> >   * int (*ndo_set_vf_vlan)(struct net_device *dev, int vf, u16 vlan, u8=
 qos);
> >   * int (*ndo_set_vf_tx_rate)(struct net_device *dev, int vf, int rate)=
;
> > + * int (*ndo_set_vf_spoofchk)(struct net_device *dev, int vf, u8 setti=
ng);
> >   * int (*ndo_get_vf_config)(struct net_device *dev,
> >   *			    int vf, struct ifla_vf_info *ivf);
> >   * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
> > @@ -900,6 +901,8 @@ struct net_device_ops {
> >  						   int queue, u16 vlan, u8 qos);
> >  	int			(*ndo_set_vf_tx_rate)(struct net_device *dev,
> >  						      int vf, int rate);
> > +	int			(*ndo_set_vf_spoofchk)(struct net_device *dev,
> > +						       int vf, u8 setting);
>=20
> Why u8 and not bool?

This could be a bool, I believe Greg did a int just based on other
similar instances.  Greg will definitely have a better knowledge and
possible future use instances which may justify an int.

>=20
> >  	int			(*ndo_get_vf_config)(struct net_device *dev,
> >  						     int vf,
> >  						     struct ifla_vf_info *ivf);
> > diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> > index 39f8dd6..6535810 100644
> > --- a/net/core/rtnetlink.c
> > +++ b/net/core/rtnetlink.c
> > @@ -731,7 +731,8 @@ static inline int rtnl_vfinfo_size(const struct net=
_device *dev)
> >  		size +=3D num_vfs *
> >  			(nla_total_size(sizeof(struct ifla_vf_mac)) +
> >  			 nla_total_size(sizeof(struct ifla_vf_vlan)) +
> > -			 nla_total_size(sizeof(struct ifla_vf_tx_rate)));
> > +			 nla_total_size(sizeof(struct ifla_vf_tx_rate)) +
> > +			 nla_total_size(sizeof(struct ifla_vf_spoofchk)));
> >  		return size;
> >  	} else
> >  		return 0;
> > @@ -954,13 +955,19 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, =
struct net_device *dev,
> >  			struct ifla_vf_mac vf_mac;
> >  			struct ifla_vf_vlan vf_vlan;
> >  			struct ifla_vf_tx_rate vf_tx_rate;
> > +			struct ifla_vf_spoofchk vf_spoofchk;
> >  			if (dev->netdev_ops->ndo_get_vf_config(dev, i, &ivi))
> >  				break;
> > -			vf_mac.vf =3D vf_vlan.vf =3D vf_tx_rate.vf =3D ivi.vf;
> > +			vf_mac.vf =3D
> > +			vf_vlan.vf =3D
> > +			vf_tx_rate.vf =3D
> > +			vf_spoofchk.vf =3D ivi.vf;
> > +
> [...]
>=20
> The continuation lines should be indented.  Or you could just write the
> assignments as multiple statements.
>=20
> Ben.
>=20

I agree.  At least Greg and I can clean this up, if nothing else.  I
will wait for Greg's thoughts/comments on your other observations before
re-spinning this patch.

Thanks Ben.



--=-jdpc4FxmF7Yu5/Xy4t+7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJOfsImAAoJECTsCADr/EWUzokH/RJagq3iVzi0u9cRDHRVP9t/
Ff5j6qgoOc1SmWFC1l/jWnHWT0p3XfAprrwk9gH8nD55G862ioboZH0nZnb2wT9W
8gUygH4AC0893BerZRSI3mIeE8u8gXj591RbaSeyFbLqLnmLc3Jp67USgPC1NEKi
n+bZxtXoVYUGgtpspNbYWKc0o85WSz+TchZ1fcXLXmITDck3rcjhDhbn/GVvxqdr
rzvlm2xt2kkV7Fo0lHJkRmlhXpnqvgWmAcrHwca+h/MXpHnGtO5+6zKssXvFtvF+
WvoLTYF0hhp9p+ztzCjIubb5WtPJaPT7kGAPDL3FL3u8/Dc4E6i8KkHhohBwvT0=
=73zz
-----END PGP SIGNATURE-----

--=-jdpc4FxmF7Yu5/Xy4t+7--
