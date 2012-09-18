From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/4] ipv6: add a new namespace for nf_conntrack_reasm
Date: Tue, 18 Sep 2012 17:45:09 +0200
Message-ID: <20120918154509.GA19508@1984>
References: <1347975911-5655-1-git-send-email-amwang@redhat.com>
 <1347975911-5655-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Michal =?utf-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1347975911-5655-2-git-send-email-amwang@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 18, 2012 at 09:45:08PM +0800, Cong Wang wrote:
> As pointed by Michal, it is necessary to add a new
> namespace for nf_conntrack_reasm code, this prepares
> for the second patch.
>=20
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Michal Kube=C4=8Dek <mkubecek@suse.cz>
> Cc: David Miller <davem@davemloft.net>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: netfilter-devel@vger.kernel.org
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  include/net/net_namespace.h             |    3 +
>  include/net/netns/ipv6.h                |    8 ++
>  net/ipv6/netfilter/nf_conntrack_reasm.c |  135 +++++++++++++++++++++=
----------
>  3 files changed, 104 insertions(+), 42 deletions(-)
>=20
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.=
h
> index 5ae57f1..d61e2b3 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -93,6 +93,9 @@ struct net {
>  #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODU=
LE)
>  	struct netns_ct		ct;
>  #endif
> +#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
> +	struct netns_nf_frag	nf_frag;
> +#endif
>  	struct sock		*nfnl;
>  	struct sock		*nfnl_stash;
>  #endif
> diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
> index 0318104..214cb0a 100644
> --- a/include/net/netns/ipv6.h
> +++ b/include/net/netns/ipv6.h
> @@ -71,4 +71,12 @@ struct netns_ipv6 {
>  #endif
>  #endif
>  };
> +
> +#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
> +struct netns_nf_frag {
> +	struct netns_sysctl_ipv6 sysctl;
> +	struct netns_frags	frags;
> +};
> +#endif
> +
>  #endif
> diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfi=
lter/nf_conntrack_reasm.c
> index f94fb3a..d28c067 100644
> --- a/net/ipv6/netfilter/nf_conntrack_reasm.c
> +++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
> @@ -71,27 +71,26 @@ struct nf_ct_frag6_queue
>  };
> =20
>  static struct inet_frags nf_frags;
> -static struct netns_frags nf_init_frags;
> =20
>  #ifdef CONFIG_SYSCTL
>  static struct ctl_table nf_ct_frag6_sysctl_table[] =3D {
>  	{
>  		.procname	=3D "nf_conntrack_frag6_timeout",
> -		.data		=3D &nf_init_frags.timeout,
> +		.data		=3D &init_net.nf_frag.frags.timeout,
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec_jiffies,
>  	},
>  	{
>  		.procname	=3D "nf_conntrack_frag6_low_thresh",
> -		.data		=3D &nf_init_frags.low_thresh,
> +		.data		=3D &init_net.nf_frag.frags.low_thresh,
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec,
>  	},
>  	{
>  		.procname	=3D "nf_conntrack_frag6_high_thresh",
> -		.data		=3D &nf_init_frags.high_thresh,
> +		.data		=3D &init_net.nf_frag.frags.high_thresh,
>  		.maxlen		=3D sizeof(unsigned int),
>  		.mode		=3D 0644,
>  		.proc_handler	=3D proc_dointvec,
> @@ -99,7 +98,54 @@ static struct ctl_table nf_ct_frag6_sysctl_table[]=
 =3D {
>  	{ }
>  };
> =20
> -static struct ctl_table_header *nf_ct_frag6_sysctl_header;
> +static int __net_init nf_ct_frag6_sysctl_register(struct net *net)
> +{
> +	struct ctl_table *table;
> +	struct ctl_table_header *hdr;
> +
> +	table =3D nf_ct_frag6_sysctl_table;
> +	if (!net_eq(net, &init_net)) {
> +		table =3D kmemdup(table, sizeof(nf_ct_frag6_sysctl_table), GFP_KER=
NEL);

Sorry, you have to break lines at 80 chars.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
