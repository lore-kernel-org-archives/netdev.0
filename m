From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/17] netfilter: add struct nf_proto_net for register
 l4proto sysctl
Date: Thu, 24 May 2012 11:58:59 +0200
Message-ID: <20120524095859.GC13091@1984>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1336985547-31960-2-git-send-email-gaofeng@cn.fujitsu.com>
 <20120523101200.GA2836@1984>
 <4FBD9076.6060309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48931 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755189Ab2EXJ7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 05:59:12 -0400
Content-Disposition: inline
In-Reply-To: <4FBD9076.6060309@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 24, 2012 at 09:35:50AM +0800, Gao feng wrote:
> Hi pablo:
>=20
> =E4=BA=8E 2012=E5=B9=B405=E6=9C=8823=E6=97=A5 18:12, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > On Mon, May 14, 2012 at 04:52:11PM +0800, Gao feng wrote:
> >> From: Gao feng <gaofeng@cn.fujitus.com>
> >>
> >> the struct nf_proto_net stroes proto's ctl_table_header and ctl_ta=
ble,
> >> nf_ct_l4proto_(un)register_sysctl use it to register sysctl.
> >>
> >> there are some changes for struct nf_conntrack_l4proto:
> >> - add field compat to identify if this proto should do compat.
> >> - the net_id field is used to store the pernet_operations id
> >>   that belones to l4proto.
> >> - init_net will be used to initial the proto's pernet data
> >>
> >> and add init_net for struct nf_conntrack_l3proto too.
> >=20
> > This patchset looks bette but there are still things that we have t=
o
> > resolve.
> >=20
> > The first one (regarding this patch 1/17) changes in:
> > * include/net/netfilter/nf_conntrack_l4proto.h
> > * include/net/netns/conntrack.h
> >=20
> > should be included in:
> > [PATCH] netfilter: add namespace support for l4proto
> >=20
> > And changes in:
> > * include/net/netfilter/nf_conntrack_l3proto.h
> >=20
> > should be included in:
> > [PATCH] netfilter: add namespace support for l3proto
> >=20
> > I already told you. A patch that adds a structure without using it,
> > is not good. The structure has to go together with the code uses it=
=2E
> >=20
>=20
> It seams this patch should be merged to "netfilter: add namespace sup=
port for l4proto"
> the struct nf_proto_net is first used there.
>=20
> > More comments below.
> >=20
> >> Acked-by: Eric W. Biederman <ebiederm@xmission.com>
> >> Signed-off-by: Gao feng <gaofeng@cn.fujitus.com>
> >> ---
> >>  include/net/netfilter/nf_conntrack_l3proto.h |    3 +++
> >>  include/net/netfilter/nf_conntrack_l4proto.h |    6 ++++++
> >>  include/net/netns/conntrack.h                |   12 ++++++++++++
> >>  3 files changed, 21 insertions(+), 0 deletions(-)
> >>
> >> diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/includ=
e/net/netfilter/nf_conntrack_l3proto.h
> >> index 9699c02..9766005 100644
> >> --- a/include/net/netfilter/nf_conntrack_l3proto.h
> >> +++ b/include/net/netfilter/nf_conntrack_l3proto.h
> >> @@ -69,6 +69,9 @@ struct nf_conntrack_l3proto {
> >>  	struct ctl_table	*ctl_table;
> >>  #endif /* CONFIG_SYSCTL */
> >> =20
> >> +	/* Init l3proto pernet data */
> >> +	int (*init_net)(struct net *net);
> >> +
> >>  	/* Module (if any) which this is connected to. */
> >>  	struct module *me;
> >>  };
> >> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/includ=
e/net/netfilter/nf_conntrack_l4proto.h
> >> index 3b572bb..a90eab5 100644
> >> --- a/include/net/netfilter/nf_conntrack_l4proto.h
> >> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
> >> @@ -22,6 +22,8 @@ struct nf_conntrack_l4proto {
> >>  	/* L4 Protocol number. */
> >>  	u_int8_t l4proto;
> >> =20
> >> +	u_int8_t compat;
> >=20
> > I don't see why we need this new field.
> >=20
> > It seems to be set to 1 in each structure that has set:
> >=20
> > .ctl_compat_table
> >=20
> > to non-NULL. So, it's redundant.
> >=20
> > Moreover, you already know from the protocol tracker itself if you
> > have to allocate the compat ctl table or not.
> >=20
> > In other words: You set compat to 1 for nf_conntrack_l4proto_generi=
c.
> > Then, you pass that compat value to generic_init_net via ->inet_net
> > again, but this information (that determines if the compat has to b=
e
> > done or not) is already in the scope of the protocol tracker.
> >=20
>=20
> because some protocols such l4proto_tcp6 and l4proto_tcp use the same=
 init_net
> function. the l4proto_tcp6 doesn't need compat sysctl, so we should u=
se this new
> field to identify if we should kmemdup compat_sysctl_table.

Then, could you use two init_net functions? one for TCP for IPv4 and an=
other
for TCP for IPv6?

> and beacuse protocols will have pernet ctl_compat_table and ctl_table=
,the .ctl_compat_table
> field will be deleted in patch 15/17. so we should the new field comp=
at.
>=20
> actually, we don't need to pass compat value for generic_init_net,bea=
cuse
> we know l4proto_generic need compat. But consider there are l4proto_t=
cp(6), and in order to keep
> code readable,I prefer to add compat field and pass it to init_net.
>=20
> > You have to fix this.
> >=20
> >> +
> >>  	/* Try to fill in the third arg: dataoff is offset past network =
protocol
> >>             hdr.  Return true if possible. */
> >>  	bool (*pkt_to_tuple)(const struct sk_buff *skb, unsigned int dat=
aoff,
> >> @@ -103,6 +105,10 @@ struct nf_conntrack_l4proto {
> >>  	struct ctl_table	*ctl_compat_table;
> >>  #endif
> >>  #endif
> >> +	int	*net_id;
> >> +	/* Init l4proto pernet data */
> >> +	int (*init_net)(struct net *net, u_int8_t compat);
> >> +
> >>  	/* Protocol name */
> >>  	const char *name;
> >> =20
> >> diff --git a/include/net/netns/conntrack.h b/include/net/netns/con=
ntrack.h
> >> index a053a19..1f53038 100644
> >> --- a/include/net/netns/conntrack.h
> >> +++ b/include/net/netns/conntrack.h
> >> @@ -8,6 +8,18 @@
> >>  struct ctl_table_header;
> >>  struct nf_conntrack_ecache;
> >> =20
> >> +struct nf_proto_net {
> >> +#ifdef CONFIG_SYSCTL
> >> +	struct ctl_table_header *ctl_table_header;
> >> +	struct ctl_table        *ctl_table;
> >> +#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> >> +	struct ctl_table_header *ctl_compat_header;
> >> +	struct ctl_table        *ctl_compat_table;
> >> +#endif
> >> +#endif
> >> +	unsigned int		users;
> >> +};
> >> +
> >>  struct netns_ct {
> >>  	atomic_t		count;
> >>  	unsigned int		expect_count;
> > --
> > To unsubscribe from this list: send the line "unsubscribe netfilter=
-devel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
