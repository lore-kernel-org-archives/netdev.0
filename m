From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH 2/2] rtnetlink: Only supply IFLA_VF_PORTS information
 when RTEXT_FILTER_VF is set
Date: Thu, 24 Apr 2014 10:13:14 +1000
Message-ID: <20140424001314.GD31647@voom.fritz.box>
References: <1398237665-26980-1-git-send-email-david@gibson.dropbear.id.au>
 <1398237665-26980-3-git-send-email-david@gibson.dropbear.id.au>
 <20140423091715.GD2846@minipsycho.orion>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jCrbxBqMcLqd4mOl"
Cc: netdev@vger.kernel.org, ssujith@cisco.com, neepatel@cisco.com,
	benve@cisco.com, davem@davemloft.net, ben@decadent.org.uk,
	govindarajulu90@gmail.com, gregory.v.rose@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:54938 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017AbaDXAQX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 20:16:23 -0400
Content-Disposition: inline
In-Reply-To: <20140423091715.GD2846@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--jCrbxBqMcLqd4mOl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Apr 23, 2014 at 11:17:15AM +0200, Jiri Pirko wrote:
> Wed, Apr 23, 2014 at 09:21:05AM CEST, david@gibson.dropbear.id.au wrote:
> >Since 115c9b81928360d769a76c632bae62d15206a94a (rtnetlink: Fix problem w=
ith
> >buffer allocation), RTM_NEWLINK messages only contain the IFLA_VFINFO_LI=
ST
> >attribute if they were solicited by a GETLINK message containing an
> >IFLA_EXT_MASK attribute with the RTEXT_FILTER_VF flag.
> >
> >That was done because some user programs broke when they received more d=
ata
> >than expected - because IFLA_VFINFO_LIST contains information for each VF
> >it can become large if there are many VFs.
> >
> >However, the IFLA_VF_PORTS attribute, supplied for devices which impleme=
nt
> >ndo_get_vf_port (currently the 'enic' driver only), has the same problem.
> >It supplies per-VF information and can therefore become large, but it is
> >not currently conditional on the IFLA_EXT_MASK value.
> >
> >Worse, it interacts badly with the existing EXT_MASK handling.  When
> >IFLA_EXT_MASK is not supplied, the buffer for netlink replies is fixed at
> >NLMSG_GOODSIZE.  If the information for IFLA_VF_PORTS exceeds this, then
> >rtnl_fill_ifinfo() returns -EMSGSIZE on the first message in a packet.
> >netlink_dump() will misinterpret this as having finished the listing and
> >omit data for this interface and all subsequent ones.  That can cause
> >getifaddrs(3) to enter an infinite loop.
> >
> >This patch addresses the problem by only supplying IFLA_VF_PORTS when
> >IFLA_EXT_MASK is supplied with the RTEXT_FILTER_VF flag set.
> >
> >Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
> >---
> > net/core/rtnetlink.c | 16 ++++++++++------
> > 1 file changed, 10 insertions(+), 6 deletions(-)
> >
> >diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> >index 5331db2..32a1287 100644
> >--- a/net/core/rtnetlink.c
> >+++ b/net/core/rtnetlink.c
> >@@ -774,7 +774,8 @@ static inline int rtnl_vfinfo_size(const struct net_=
device *dev,
> > 		return 0;
> > }
> >=20
> >-static size_t rtnl_port_size(const struct net_device *dev)
> >+static size_t rtnl_port_size(const struct net_device *dev,
> >+			     u32 ext_filter_mask)
> > {
> > 	size_t port_size =3D nla_total_size(4)		/* PORT_VF */
> > 		+ nla_total_size(PORT_PROFILE_MAX)	/* PORT_PROFILE */
> >@@ -790,7 +791,8 @@ static size_t rtnl_port_size(const struct net_device=
 *dev)
> > 	size_t port_self_size =3D nla_total_size(sizeof(struct nlattr))
> > 		+ port_size;
> >=20
> >-	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent)
> >+	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent
> >+	    || !(ext_filter_mask & RTEXT_FILTER_VF))
>=20
> 	Do not start line with ||

Ah, sorry, I'm getting my project codingstyles mixed up.  Will fix.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--jCrbxBqMcLqd4mOl
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTWFcZAAoJEGw4ysog2bOSjvgP/1Y4GbonBPR3etIwCMI3GVE5
OG5XyjKfGC+vNfqZVkiv1gpJf2IiiJABioreokaiSsF83haTF2LP/ghhI8Od0KuR
kjFppjstEGaFMUbOR9BnwfrZKjgiUFyBUDEoYPNcassPG0JQ1p4GXICSklSdZC5a
CVziXBXb0DnJui+asElhdeUREBunTLFWOWe+2moRVz8qhOGbK7xHJzy8Th6H7HT5
Hd1dnaD4vt+NJUEJAjMvkVFsna3jQ1stHsMi+ZykcmKfLHngJhciBqla4REUo5Mo
JJts/F/lygl55HSBs+cKQ5GnbJb+mLmmoU7K4D2z82ZEpYHJb77SvED8+MxqOSz8
8ZCCNHJiF3N3YCoCVmHo5cf+1L559d0nyy8R8ciBUScn8QPgiFlX5Pg2UyDoxuY0
thkeXkfutUTpEc1uzIwEsg0mvyhUecw8EHOME2TGjbdHwPOz9Sesj9qCJeBfvWk1
9ZZIjUtIl+XnxiRrpA1QYoQiPi6uOGLrX5oCXlQBYfmVx/238opvty2nUDZ6Ubty
vnsJmKeQHRo5bClas4Wrgs+e+/7n69fxZa+xzz0SAcZBWYRq7bLvX037SwniHqF7
BmV8zBL570u7g7e89oGryZB6URfp+tb8NF3Jd2i3/DFRgr3G417eVSSZl2aAETqw
/s0LNbWbZ72K9StTKqtB
=nVLo
-----END PGP SIGNATURE-----

--jCrbxBqMcLqd4mOl--
