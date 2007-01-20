From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Fri, 19 Jan 2007 20:41:37 -0500
Message-ID: <20070120014137.GA13598@hmsreliant.homelinux.net>
References: <20070119212314.GA10748@hmsreliant.homelinux.net> <20070120.080507.25118874.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2781 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965056AbXATBm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jan 2007 20:42:56 -0500
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20070120.080507.25118874.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 20, 2007 at 08:05:07AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> Hello.
>=20
> In article <20070119212314.GA10748@hmsreliant.homelinux.net> (at Fri,=
 19 Jan 2007 16:23:14 -0500), Neil Horman <nhorman@tuxdriver.com> says:
>=20
> > Patch to Implement IPv6 RFC 4429 (Optimistic Duplicate Address Dete=
ction).  In
>=20
> Good work.  We will see if this would break core and basic ipv6 code.
> Dave, please hold on.
>=20
Thank you.  I'll implement your requested changes and repost monday aft=
ernoon
Regards
Neil

> Some quick comments.
>=20
> > --- a/include/net/ipv6.h
> > +++ b/include/net/ipv6.h
> > @@ -110,6 +110,7 @@ struct frag_hdr {
> >  /* sysctls */
> >  extern int sysctl_ipv6_bindv6only;
> >  extern int sysctl_mld_max_msf;
> > +extern int sysctl_optimistic_dad;
> > =20
> :
> > diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> > index 2a7e461..f7afb2a 100644
> > --- a/net/ipv6/addrconf.c
> > +++ b/net/ipv6/addrconf.c
> > @@ -206,6 +206,8 @@ static struct ipv6_devconf ipv6_devconf_dflt __=
read_mostly =3D {
> >  	.proxy_ndp		=3D 0,
> >  };
> > =20
> > +int sysctl_optimistic_dad =3D 1;
> > +
>=20
> Please put this into ipv6_devconf{} and make it per-interface variabl=
e.
> And I think default should be kept off (0).
>=20
> >  /* IPv6 Wildcard Address and Loopback Address defined by RFC2553 *=
/
> >  #if 0
> >  const struct in6_addr in6addr_any =3D IN6ADDR_ANY_INIT;
> > @@ -830,7 +832,8 @@ retry:
> >  	ift =3D !max_addresses ||
> >  	      ipv6_count_addresses(idev) < max_addresses ?=20
> >  		ipv6_add_addr(idev, &addr, tmp_plen,
> > -			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK, IFA_F_TEMPORA=
RY) : NULL;
> > +			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,=20
> > +				IFA_F_TEMPORARY|IFA_F_OPTIMISTIC) : NULL;
> >  	if (!ift || IS_ERR(ift)) {
> >  		in6_ifa_put(ifp);
> >  		in6_dev_put(idev);
>=20
> Please align ipv6_addr_type and IFA_F_TEMPORARY
>=20
> > @@ -1174,7 +1177,8 @@ int ipv6_get_saddr(struct dst_entry *dst,
> >  }
> > =20
> > =20
> > -int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr)
> > +int ipv6_get_lladdr(struct net_device *dev, struct in6_addr *addr,=
=20
> > +			unsigned char banned_flags)
> >  {
> >  	struct inet6_dev *idev;
> >  	int err =3D -EADDRNOTAVAIL;
>=20
> Please align "struct net_device" and "unsigned char".
>=20
> > @@ -1185,7 +1189,7 @@ int ipv6_get_lladdr(struct net_device *dev, s=
truct in6_addr *addr)
> > =20
> >  		read_lock_bh(&idev->lock);
> >  		for (ifp=3Didev->addr_list; ifp; ifp=3Difp->if_next) {
> > -			if (ifp->scope =3D=3D IFA_LINK && !(ifp->flags&IFA_F_TENTATIVE)=
) {
> > +			if (ifp->scope =3D=3D IFA_LINK && !(ifp->flags&banned_flags)) {
> >  				ipv6_addr_copy(addr, &ifp->addr);
> >  				err =3D 0;
> >  				break;
> > @@ -1742,7 +1746,7 @@ ok:
>=20
> It is not your fault, but please put a space around "&".
>=20
> >  			if (!max_addresses ||
> >  			    ipv6_count_addresses(in6_dev) < max_addresses)
> >  				ifp =3D ipv6_add_addr(in6_dev, &addr, pinfo->prefix_len,
> > -						    addr_type&IPV6_ADDR_SCOPE_MASK, 0);
> > +						    addr_type&IPV6_ADDR_SCOPE_MASK,0);
> > =20
> >  			if (!ifp || IS_ERR(ifp)) {
> >  				in6_dev_put(in6_dev);
>=20
> Please do no kill space after ",".
>=20
> > @@ -2123,7 +2132,8 @@ static void addrconf_add_linklocal(struct ine=
t6_dev *idev, struct in6_addr *addr
> >  {
> >  	struct inet6_ifaddr * ifp;
> > =20
> > -	ifp =3D ipv6_add_addr(idev, addr, 64, IFA_LINK, IFA_F_PERMANENT);
> > +	ifp =3D ipv6_add_addr(idev, addr, 64, IFA_LINK,=20
> > +		IFA_F_PERMANENT|IFA_F_OPTIMISTIC);
> >  	if (!IS_ERR(ifp)) {
> >  		addrconf_dad_start(ifp, 0);
> >  		in6_ifa_put(ifp);
>=20
> Please align idev and IFA_F_PERMANENT.
>=20
> > @@ -542,7 +556,8 @@ void ndisc_send_ns(struct net_device *dev, stru=
ct neighbour *neigh,
> >  	int send_llinfo;
> > =20
> >  	if (saddr =3D=3D NULL) {
> > -		if (ipv6_get_lladdr(dev, &addr_buf))
> > +		if (ipv6_get_lladdr(dev, &addr_buf,
> > +			(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
> >  			return;
> >  		saddr =3D &addr_buf;
> >  	}
>=20
> ditto... ("dev" and "(")
>=20
> > +			   and optimistic) are false then we can just fail
> > +			   dad now.
> > +			*/
> > +			type =3D ipv6_addr_type(saddr);		=09
> > +			if (!((ifp->flags & IFA_F_OPTIMISTIC) &&=20
> > +			    (type & IPV6_ADDR_UNICAST))) {
> > +				addrconf_dad_failure(ifp);=20
> > +				return;
> > +			}
> >  		}
> > =20
> >  		idev =3D ifp->idev;
>=20
> hmm? Here, is saddr always unicast, isn't it?!
>=20
> --yoshfuji
