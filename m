From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 03/12] netfilter: generic proto sysctl support for net
 namespace
Date: Tue, 17 Apr 2012 13:35:41 +0200
Message-ID: <20120417113541.GB2956@1984>
References: <1334631383-12326-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1334631383-12326-4-git-send-email-gaofeng@cn.fujitsu.com>
 <20120417085813.GD2100@1984>
 <4F8D4472.6080606@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, serge.hallyn@canonical.com,
	dlezcano@fr.ibm.com
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F8D4472.6080606@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 17, 2012 at 06:22:42PM +0800, Gao feng wrote:
> =E4=BA=8E 2012=E5=B9=B404=E6=9C=8817=E6=97=A5 16:58, Pablo Neira Ayus=
o =E5=86=99=E9=81=93:
> > On Tue, Apr 17, 2012 at 10:56:14AM +0800, Gao feng wrote:
> >> register the generic proto's sysctl in pernet_operations.init.
> >> and use net->ct.proto.sysctl_generic_timeout replaces nf_ct_generi=
c_timeout.
> >>
> >> in the after patch,the timeout_nlattr_to_obj will be modified too.
> >>
> >> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> >> ---
> >>  net/netfilter/nf_conntrack_core.c          |    6 ++
> >>  net/netfilter/nf_conntrack_proto_generic.c |   93 +++++++++++++++=
++++++++++---
> >>  2 files changed, 91 insertions(+), 8 deletions(-)
> >>
> >> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_=
conntrack_core.c
> >> index 729f157..bf11dd6 100644
> >> --- a/net/netfilter/nf_conntrack_core.c
> >> +++ b/net/netfilter/nf_conntrack_core.c
> >> @@ -1358,6 +1358,7 @@ static void nf_conntrack_cleanup_net(struct =
net *net)
> >>  	nf_conntrack_tstamp_fini(net);
> >>  	nf_conntrack_acct_fini(net);
> >>  	nf_conntrack_expect_fini(net);
> >> +	nf_conntrack_proto_generic_net_fini(net);
> >>  	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
> >>  	kfree(net->ct.slabname);
> >>  	free_percpu(net->ct.stat);
> >> @@ -1573,6 +1574,9 @@ static int nf_conntrack_init_net(struct net =
*net)
> >>  		printk(KERN_ERR "Unable to create nf_conntrack_hash\n");
> >>  		goto err_hash;
> >>  	}
> >> +	ret =3D nf_conntrack_proto_generic_net_init(net);
> >> +	if (ret < 0)
> >> +		goto err_generic;
> >>  	ret =3D nf_conntrack_expect_init(net);
> >>  	if (ret < 0)
> >>  		goto err_expect;
> >> @@ -1600,6 +1604,8 @@ err_tstamp:
> >>  err_acct:
> >>  	nf_conntrack_expect_fini(net);
> >>  err_expect:
> >> +	nf_conntrack_proto_generic_net_fini(net);
> >> +err_generic:
> >>  	nf_ct_free_hashtable(net->ct.hash, net->ct.htable_size);
> >>  err_hash:
> >>  	kmem_cache_destroy(net->ct.nf_conntrack_cachep);
> >> diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netf=
ilter/nf_conntrack_proto_generic.c
> >> index 835e24c..0d4545b 100644
> >> --- a/net/netfilter/nf_conntrack_proto_generic.c
> >> +++ b/net/netfilter/nf_conntrack_proto_generic.c
> >> @@ -42,7 +42,7 @@ static int generic_print_tuple(struct seq_file *=
s,
> >> =20
> >>  static unsigned int *generic_get_timeouts(struct net *net)
> >>  {
> >> -	return &nf_ct_generic_timeout;
> >> +	return &(net->ct.proto.sysctl_generic_timeout);
> >>  }
> >> =20
> >>  /* Returns verdict for packet, or -1 for invalid. */
> >> @@ -105,11 +105,10 @@ generic_timeout_nla_policy[CTA_TIMEOUT_GENER=
IC_MAX+1] =3D {
> >>  #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
> >> =20
> >>  #ifdef CONFIG_SYSCTL
> >> -static struct ctl_table_header *generic_sysctl_header;
> >>  static struct ctl_table generic_sysctl_table[] =3D {
> >>  	{
> >>  		.procname	=3D "nf_conntrack_generic_timeout",
> >> -		.data		=3D &nf_ct_generic_timeout,
> >> +		.data		=3D &init_net.ct.proto.sysctl_generic_timeout,
> >>  		.maxlen		=3D sizeof(unsigned int),
> >>  		.mode		=3D 0644,
> >>  		.proc_handler	=3D proc_dointvec_jiffies,
> >> @@ -120,7 +119,7 @@ static struct ctl_table generic_sysctl_table[]=
 =3D {
> >>  static struct ctl_table generic_compat_sysctl_table[] =3D {
> >>  	{
> >>  		.procname	=3D "ip_conntrack_generic_timeout",
> >> -		.data		=3D &nf_ct_generic_timeout,
> >> +		.data		=3D &init_net.ct.proto.sysctl_generic_timeout,
> >>  		.maxlen		=3D sizeof(unsigned int),
> >>  		.mode		=3D 0644,
> >>  		.proc_handler	=3D proc_dointvec_jiffies,
> >> @@ -150,11 +149,89 @@ struct nf_conntrack_l4proto nf_conntrack_l4p=
roto_generic __read_mostly =3D
> >>  		.nla_policy	=3D generic_timeout_nla_policy,
> >>  	},
> >>  #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
> >> +};
> >> +
> >> +int nf_conntrack_proto_generic_net_init(struct net *net)
> >=20
> > Please, check int nf_conntrack_ecache_init(struct net *net) for
> > instance on how we're doing the per-net registration of netfilter
> > modules.
>=20
> nf_conntrack_l4proto_generic is registered when loading nf_conntrack =
module.
> so we should register sysctl in nf_conntrack_init_net.
>=20
> I don't know what's wrong here...

Nothing wrong, just a comestic change.

I'd like that the protocol and sysctl registration happen in the same
function, like in other part of the code, for consistency.

Probably, you can use http://patchwork.ozlabs.org/patch/152096/ as
reference.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
