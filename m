From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next v2 03/12] netfilter: add
 nf_ct_kfree_compat_sysctl_table to make codes clear
Date: Sat, 16 Jun 2012 13:10:02 +0200
Message-ID: <20120616111002.GF18251@1984>
References: <1339818083-31356-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1339818083-31356-3-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1339818083-31356-3-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 16, 2012 at 11:41:14AM +0800, Gao feng wrote:
> add function nf_ct_kfree_compat_sysctl_table to kfree l4proto's
> compat sysctl table and set the sysctl table point to NULL.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  include/net/netfilter/nf_conntrack_l4proto.h |    2 ++
>  net/netfilter/nf_conntrack_proto.c           |   12 ++++++++++--
>  2 files changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
> index 5dd60f2..11fcf27 100644
> --- a/include/net/netfilter/nf_conntrack_l4proto.h
> +++ b/include/net/netfilter/nf_conntrack_l4proto.h
> @@ -124,6 +124,8 @@ extern int nf_conntrack_l4proto_register(struct net *net,
>  extern void nf_conntrack_l4proto_unregister(struct net *net,
>  					    struct nf_conntrack_l4proto *proto);
>  
> +extern void nf_ct_kfree_compat_sysctl_table(struct nf_proto_net *pn);
> +
>  /* Generic netlink helpers */
>  extern int nf_ct_port_tuple_to_nlattr(struct sk_buff *skb,
>  				      const struct nf_conntrack_tuple *tuple);
> diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
> index 5ea2d71..1033ee6 100644
> --- a/net/netfilter/nf_conntrack_proto.c
> +++ b/net/netfilter/nf_conntrack_proto.c
> @@ -327,6 +327,15 @@ static struct nf_proto_net *nf_ct_l4proto_net(struct net *net,
>  	return NULL;
>  }
>  
> +void nf_ct_kfree_compat_sysctl_table(struct nf_proto_net *pn)
> +{
> +#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
> +	kfree(pn->ctl_compat_table);
> +	pn->ctl_compat_table = NULL;
> +#endif
> +}
> +EXPORT_SYMBOL_GPL(nf_ct_kfree_compat_sysctl_table);

I know, I told you to export this symbol instead of inlining it. But I
overlooked that this will be an empty symbol if systcl is disabled.

So, please recover the ancient patch that you sent that inlines this.

Sorry.

> +
>  static
>  int nf_ct_l4proto_register_sysctl(struct net *net,
>  				  struct nf_conntrack_l4proto *l4proto)
> @@ -361,8 +370,7 @@ int nf_ct_l4proto_register_sysctl(struct net *net,
>  		if (err == 0)
>  			goto out;
>  
> -		kfree(pn->ctl_compat_table);
> -		pn->ctl_compat_table = NULL;
> +		nf_ct_kfree_compat_sysctl_table(pn);
>  		nf_ct_unregister_sysctl(&pn->ctl_table_header,
>  					&pn->ctl_table,
>  					&pn->users);
> -- 
> 1.7.7.6
> 
