From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v2 11/12] netfilter: nf_conntrack_l4proto_icmp
 cleanup
Date: Sat, 16 Jun 2012 13:08:28 +0200
Message-ID: <20120616110828.GE18251@1984>
References: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1339818083-31356-11-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1339818083-31356-11-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 16, 2012 at 11:41:22AM +0800, Gao feng wrote:
> add two functions icmp_kmemdup_sysctl_table and
> icmp_kmemdup_compat_sysctl_table to make codes more
> clearer.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/ipv4/netfilter/nf_conntrack_proto_icmp.c |   44 ++++++++++++++++++++-----
>  1 files changed, 35 insertions(+), 9 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
> index 76f7a2f..be7ae4c 100644
> --- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
> +++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
> @@ -337,34 +337,60 @@ static struct ctl_table icmp_compat_sysctl_table[] = {
>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
>  #endif /* CONFIG_SYSCTL */
>  
> -static int icmp_init_net(struct net *net, u_int16_t proto)
> +static int icmp_kmemdup_sysctl_table(struct nf_proto_net *pn)
>  {
> -	struct nf_icmp_net *in = icmp_pernet(net);
> -	struct nf_proto_net *pn = (struct nf_proto_net *)in;
> -	in->timeout = nf_ct_icmp_timeout;
> -
>  #ifdef CONFIG_SYSCTL
> +	struct nf_icmp_net *in = (struct nf_icmp_net *)pn;
> +
>  	pn->ctl_table = kmemdup(icmp_sysctl_table,
>  				sizeof(icmp_sysctl_table),
>  				GFP_KERNEL);
>  	if (!pn->ctl_table)
>  		return -ENOMEM;
> +
>  	pn->ctl_table[0].data = &in->timeout;
> +#endif
> +	return 0;
> +}
> +
> +static int icmp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
> +{
> +#ifdef CONFIG_SYSCTL
>  #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	struct nf_icmp_net *in = (struct nf_icmp_net *)pn;
> +
>  	pn->ctl_compat_table = kmemdup(icmp_compat_sysctl_table,
>  				       sizeof(icmp_compat_sysctl_table),
>  				       GFP_KERNEL);
> -	if (!pn->ctl_compat_table) {
> -		kfree(pn->ctl_table);
> -		pn->ctl_table = NULL;
> +	if (!pn->ctl_compat_table)
>  		return -ENOMEM;
> -	}
> +
>  	pn->ctl_compat_table[0].data = &in->timeout;
>  #endif
>  #endif
>  	return 0;
>  }
>  
> +

extra line unrequiered.

I'm sorry, I'm stressing a lot on this because I don't like abusing
follow-up patches that clean up extra lines / missing lines and that
sort of nitpicks...

> +static int icmp_init_net(struct net *net, u_int16_t proto)
> +{
> +	int ret;
> +	struct nf_icmp_net *in = icmp_pernet(net);
> +	struct nf_proto_net *pn = &in->pn;
> +
> +	in->timeout = nf_ct_icmp_timeout;
> +
> +	ret = icmp_kmemdup_compat_sysctl_table(pn);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = icmp_kmemdup_sysctl_table(pn);
> +	if (ret < 0)
> +		nf_ct_kfree_compat_sysctl_table(pn);
> +
> +	return ret;
> +}
> +
>  struct nf_conntrack_l4proto nf_conntrack_l4proto_icmp __read_mostly =
>  {
>  	.l3proto		= PF_INET,
> -- 
> 1.7.7.6
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
