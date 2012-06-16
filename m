From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v2 09/12] netfilter:
 nf_conntrack_l4proto_generic cleanup
Date: Sat, 16 Jun 2012 13:05:22 +0200
Message-ID: <20120616110522.GD18251@1984>
References: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1339818083-31356-9-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43144 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756325Ab2FPLF1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Jun 2012 07:05:27 -0400
Content-Disposition: inline
In-Reply-To: <1339818083-31356-9-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 16, 2012 at 11:41:20AM +0800, Gao feng wrote:
> some cleanup of nf_conntrack_l4proto_generic,
> split the code to make it more clearer.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/netfilter/nf_conntrack_proto_generic.c |   41 ++++++++++++++++++++++-----
>  1 files changed, 33 insertions(+), 8 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
> index d1ed7b4..c8487d1 100644
> --- a/net/netfilter/nf_conntrack_proto_generic.c
> +++ b/net/netfilter/nf_conntrack_proto_generic.c
> @@ -135,34 +135,59 @@ static struct ctl_table generic_compat_sysctl_table[] = {
>  #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
>  #endif /* CONFIG_SYSCTL */
>  
> -static int generic_init_net(struct net *net, u_int16_t proto)
> +static int generic_kmemdup_sysctl_table(struct nf_proto_net *pn)
>  {
> -	struct nf_generic_net *gn = generic_pernet(net);
> -	struct nf_proto_net *pn = (struct nf_proto_net *)gn;
> -	gn->timeout = nf_ct_generic_timeout;
>  #ifdef CONFIG_SYSCTL
> +	struct nf_generic_net *gn = (struct nf_generic_net *)pn;
> +
>  	pn->ctl_table = kmemdup(generic_sysctl_table,
>  				sizeof(generic_sysctl_table),
>  				GFP_KERNEL);
>  	if (!pn->ctl_table)
>  		return -ENOMEM;
> +
>  	pn->ctl_table[0].data = &gn->timeout;
> +#endif
> +	return 0;
> +}
>  
> +static int generic_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
> +{
> +#ifdef CONFIG_SYSCTL
>  #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> +	struct nf_generic_net *gn = (struct nf_generic_net *)pn;
> +
>  	pn->ctl_compat_table = kmemdup(generic_compat_sysctl_table,
>  				       sizeof(generic_compat_sysctl_table),
>  				       GFP_KERNEL);
> -	if (!pn->ctl_compat_table) {
> -		kfree(pn->ctl_table);
> -		pn->ctl_table = NULL;
> +	if (!pn->ctl_compat_table)
>  		return -ENOMEM;
> -	}
> +
>  	pn->ctl_compat_table[0].data = &gn->timeout;
>  #endif
>  #endif
>  	return 0;
>  }
>  
> +static int generic_init_net(struct net *net, u_int16_t proto)
> +{
> +	int ret;
> +	struct nf_generic_net *gn = generic_pernet(net);
> +	struct nf_proto_net *pn = &gn->pn;
> +
> +	gn->timeout = nf_ct_generic_timeout;
> +
> +	ret = generic_kmemdup_compat_sysctl_table(pn);
> +	if (ret < 0)
> +		return ret;
> +
> +	ret = generic_kmemdup_sysctl_table(pn);

better pass generic_kmemdup_sysctl(pn, gn) so we can avoid the casting
above in generic_kmemdup_compat_sysctl_table to obtain gn again.

> +	if (ret < 0)
> +		nf_ct_kfree_compat_sysctl_table(pn);
> +
> +	return ret;
> +}
> +
>  struct nf_conntrack_l4proto nf_conntrack_l4proto_generic __read_mostly =
>  {
>  	.l3proto		= PF_UNSPEC,
> -- 
> 1.7.7.6
> 
