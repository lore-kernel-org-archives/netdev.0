From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v2 06/12] netfilter: merge udpv[4,6]_net_init
 into udp_net_init
Date: Tue, 19 Jun 2012 13:39:58 +0200
Message-ID: <20120619113958.GD445@1984>
References: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1339818083-31356-6-git-send-email-gaofeng@cn.fujitsu.com>
 <20120616112259.GG18251@1984>
 <4FE0337F.6030000@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58933 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751933Ab2FSLkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 07:40:01 -0400
Content-Disposition: inline
In-Reply-To: <4FE0337F.6030000@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 19, 2012 at 04:08:31PM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B406=E6=9C=8816=E6=97=A5 19:22, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > On Sat, Jun 16, 2012 at 11:41:17AM +0800, Gao feng wrote:
> >> merge udpv4_net_init and udpv6_net_init into udp_net_init to
> >> reduce the redundancy codes.
> >>
> >> and use nf_proto_net.users to identify if it's the first time
> >> we use the nf_proto_net. when it's the first time,we will
> >> initialized it.
> >>
> >> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> >> ---
> >>  net/netfilter/nf_conntrack_proto_udp.c |   56 ++++++++++---------=
------------
> >>  1 files changed, 18 insertions(+), 38 deletions(-)
> >>
> >> diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilte=
r/nf_conntrack_proto_udp.c
> >> index 2b978e6..61bca4f 100644
> >> --- a/net/netfilter/nf_conntrack_proto_udp.c
> >> +++ b/net/netfilter/nf_conntrack_proto_udp.c
> >> @@ -270,52 +270,32 @@ static int udp_kmemdup_compat_sysctl_table(s=
truct nf_proto_net *pn)
> >>  	return 0;
> >>  }
> >>
> >> -static void udp_init_net_data(struct nf_udp_net *un)
> >> +static int udp_init_net(struct net *net, u_int16_t proto)
> >>  {
> >> -	int i;
> >> -#ifdef CONFIG_SYSCTL
> >> -	if (!un->pn.ctl_table) {
> >> -#else
> >> -	if (!un->pn.users++) {
> >> -#endif
> >> +	int ret;
> >> +	struct nf_udp_net *un =3D udp_pernet(net);
> >> +	struct nf_proto_net *pn =3D &un->pn;
> >> +
> >> +	if (!pn->users) {
> >> +		int i;
> >>  		for (i =3D 0; i < UDP_CT_MAX; i++)
> >>  			un->timeouts[i] =3D udp_timeouts[i];
> >>  	}
> >> -}
> >> -
> >> -static int udpv4_init_net(struct net *net, u_int16_t proto)
> >> -{
> >> -	int ret;
> >> -	struct nf_udp_net *un =3D udp_pernet(net);
> >> -	struct nf_proto_net *pn =3D (struct nf_proto_net *)un;
> >>
> >> -	udp_init_net_data(un);
> >> +	if (proto =3D=3D AF_INET) {
> >=20
> > I think we can remove that u_int16_t proto that I proposed to make
> > something like:
> >=20
> > static int udp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
> > {
> > #ifdef CONFIG_SYSCTL
> > #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> >         struct nf_udp_net *un =3D (struct nf_udp_net *)pn;
> > +
> > +       if (pn->ctl_compat_table)
> > +               return 0;
> > +
> >         pn->ctl_compat_table =3D kmemdup(udp_compat_sysctl_table,
> >                                        sizeof(udp_compat_sysctl_tab=
le),
> >                                        GFP_KERNEL);
> >         if (!pn->ctl_compat_table)
> >                 return -ENOMEM;
> >=20
> > That should be enough to ensure that the compat is registered once.=
 No
> > matter if it's done by the IPv4 or IPv6 invocation of udp_init_net.
> >=20
> > Thus, it will look consistent with udp_kmemdup_sysctl_table.
>=20
>=20
> yes, but this will be very terrible to unregister compat sysctl
> and free compat sysctl table.
>=20
> thinking about, we may insmod nf_conntrack_ipv6 only, as your idea,
> we will allocate compat_sysctl_table.so we have to free it when
> rmmod nf_conntrack_ipv6.

You're right.

> in order to implement it, we have to change the logic of
> nf_ct_l4proto_unregister_sysctl and nf_ct_unregister_sysctl. because =
we
> only free the sysctl table when we unregister the proto.

OK, let's stick to what we have then.
