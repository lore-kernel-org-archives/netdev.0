From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [Patch net-next] ipv6: separate out procfs code from mcast.c
Date: Tue, 23 Apr 2013 17:13:08 +0100
Message-ID: <1366733588.4016.29.camel@bwh-desktop.uk.solarflarecom.com>
References: <1366701302.21136.19.camel@cr0>
	 <20130423.031805.544535198246859192.davem@davemloft.net>
	 <1366702220.21136.23.camel@cr0>
	 <20130423.033620.1101068519499870853.davem@davemloft.net>
	 <1366702893.21136.28.camel@cr0> <87d2tlv32i.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <amwang@redhat.com>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <yoshfuji@linux-ipv6.org>
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31270 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756432Ab3DWQNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 12:13:12 -0400
In-Reply-To: <87d2tlv32i.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 14:33 +0200, Bj=C3=B8rn Mork wrote:
> Cong Wang <amwang@redhat.com> writes:
>=20
> > On Tue, 2013-04-23 at 03:36 -0400, David Miller wrote:
> >> From: Cong Wang <amwang@redhat.com>
> >> Date: Tue, 23 Apr 2013 15:30:20 +0800
> >>=20
> >> > This is hard to do, as in the email I replied to Stephen. So I
> >> > prefer to just add a Kconfig dependency, at least for now.
> >>=20
> >> A Kconfig hack is exactly what I've told you is an unacceptable
> >> solution.
> >
> > Please enlighten me for a third solution. :)
>=20
> This is an completely untested idea....
>=20
> I note that vxlan_init_net requires a successful sock_create_kern().
> That implies a request_module("net-pf-...") followed by try_module_ge=
t.
>=20
> So if the sock_create_kern(PF_INET6, ..) succeeds then you *know* you
> have IPv6. If it fails with -EAFNOSUPPORT, then you could fall back t=
o
> sock_create_kern(PF_INET, ..) and set a flag indicating that runtime
> IPv6 support is disabled.  Then use this flag to allow/deny configuri=
ng
> any IPv6 destinations.
>=20
> You may also have to protect the IPv6 modular symbols you use with
> symbol_request() or similar to prevent vxlan from depending on IPv6. =
 I
> dunno...
>=20
> If nothing else, I believe this is a crazy enough hack that David may
> want to reconsider one of your other two solutions :)

A more type-safe approach would be to define something like:

/* net/ipv6.h */
struct ipv6_mcast_ops {
	...
};
extern const struct ipv6_mcast_ops *ipv6_mcast_ops;

/* net/ipv6/addrconf_core.c */
const struct ipv6_mcast_ops *ipv6_mcast_ops;
EXPORT_SYMBOL_GPL(ipv6_mcast_ops);

/* net/ipv6/af_inet6.c */
static const struct ipv6_mcast_ops ipv6_mcast_ops_impl =3D {
	...
};
static int __init inet6_init(void)
{
	...
	ipv6_mcast_ops =3D &ipv6_mcast_ops_impl;
	return 0;
	...
}
static void __exit inet6_exit(void)
{
	...
	ipv6_mcast_ops =3D NULL;
	...
}

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
