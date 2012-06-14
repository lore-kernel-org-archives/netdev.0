From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 06/10] merge udpv[4,6]_net_init into udp_net_init
Date: Thu, 14 Jun 2012 20:13:24 +0200
Message-ID: <20120614181324.GE10633@1984>
References: <1339668445-23848-1-git-send-email-gaofeng@cn.fujitsu.com>
 <1339668445-23848-6-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1339668445-23848-6-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 14, 2012 at 06:07:21PM +0800, Gao feng wrote:
> merge udpv4_net_init and udpv6_net_init into udp_net_init to
> reduce the redundancy codes.
> 
> and use nf_proto_net.users to identify if it's the first time
> we use the nf_proto_net. when it's the first time,we will
> initialized it.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  net/netfilter/nf_conntrack_proto_udp.c |   60 ++++++++++++--------------------
>  1 files changed, 22 insertions(+), 38 deletions(-)
> 
> diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
> index 2b978e6..480126e 100644
> --- a/net/netfilter/nf_conntrack_proto_udp.c
> +++ b/net/netfilter/nf_conntrack_proto_udp.c
> @@ -239,13 +239,16 @@ static int udp_kmemdup_sysctl_table(struct nf_proto_net *pn)
>  {
>  #ifdef CONFIG_SYSCTL
>  	struct nf_udp_net *un = (struct nf_udp_net *)pn;
> +
>  	if (pn->ctl_table)
>  		return 0;
> +
>  	pn->ctl_table = kmemdup(udp_sysctl_table,
>  				sizeof(udp_sysctl_table),
>  				GFP_KERNEL);
>  	if (!pn->ctl_table)
>  		return -ENOMEM;
> +

I like this cleanup. But you have to make it in a separate patch.

>  	pn->ctl_table[0].data = &un->timeouts[UDP_CT_UNREPLIED];
>  	pn->ctl_table[1].data = &un->timeouts[UDP_CT_REPLIED];
>  #endif
> @@ -257,6 +260,7 @@ static int udp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
>  #ifdef CONFIG_SYSCTL
>  #ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
>  	struct nf_udp_net *un = (struct nf_udp_net *)pn;
> +
>  	pn->ctl_compat_table = kmemdup(udp_compat_sysctl_table,
>  				       sizeof(udp_compat_sysctl_table),
>  				       GFP_KERNEL);
> @@ -270,52 +274,32 @@ static int udp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
>  	return 0;
>  }
>  
> -static void udp_init_net_data(struct nf_udp_net *un)
> +static int udp_init_net(struct net *net, u_int16_t proto)
>  {
> -	int i;
> -#ifdef CONFIG_SYSCTL
> -	if (!un->pn.ctl_table) {
> -#else
> -	if (!un->pn.users++) {
> -#endif
> +	int ret = 0;
> +	struct nf_udp_net *un = udp_pernet(net);
> +	struct nf_proto_net *pn = (struct nf_proto_net *)un;
> +
> +	if (pn->users) {
> +		int i = 0;

redundant initialization of that i variable.

>  		for (i = 0; i < UDP_CT_MAX; i++)
>  			un->timeouts[i] = udp_timeouts[i];
>  	}
> -}
>  
> -static int udpv4_init_net(struct net *net, u_int16_t proto)
> -{
> -	int ret;
> -	struct nf_udp_net *un = udp_pernet(net);
> -	struct nf_proto_net *pn = (struct nf_proto_net *)un;
> +	if (proto == AF_INET) {
> +		ret = udp_kmemdup_compat_sysctl_table(pn);
> +		if (ret < 0)
> +			return ret;
>  
> -	udp_init_net_data(un);
> +		ret = udp_kmemdup_sysctl_table(pn);
> +		if (ret < 0)
> +			nf_ct_kfree_compat_sysctl_table(pn);
> +	} else
> +		ret = udp_kmemdup_sysctl_table(pn);
>  
> -	ret = udp_kmemdup_compat_sysctl_table(pn);
> -	if (ret < 0)
> -		return ret;
> -
> -	ret = udp_kmemdup_sysctl_table(pn);
> -#ifdef CONFIG_SYSCTL
> -#ifdef CONFIG_NF_CONNTRACK_PROC_COMPAT
> -	if (ret < 0) {
> -		kfree(pn->ctl_compat_table);
> -		pn->ctl_compat_table = NULL;
> -	}
> -#endif
> -#endif
>  	return ret;
>  }
>  
> -static int udpv6_init_net(struct net *net, u_int16_t proto)
> -{
> -	struct nf_udp_net *un = udp_pernet(net);
> -	struct nf_proto_net *pn = (struct nf_proto_net *)un;
> -
> -	udp_init_net_data(un);
> -	return udp_kmemdup_sysctl_table(pn);
> -}
> -
>  struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
>  {
>  	.l3proto		= PF_INET,
> @@ -343,7 +327,7 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp4 __read_mostly =
>  		.nla_policy	= udp_timeout_nla_policy,
>  	},
>  #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
> -	.init_net		= udpv4_init_net,
> +	.init_net		= udp_init_net,
>  };
>  EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp4);
>  
> @@ -374,6 +358,6 @@ struct nf_conntrack_l4proto nf_conntrack_l4proto_udp6 __read_mostly =
>  		.nla_policy	= udp_timeout_nla_policy,
>  	},
>  #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
> -	.init_net		= udpv6_init_net,
> +	.init_net		= udp_init_net,
>  };
>  EXPORT_SYMBOL_GPL(nf_conntrack_l4proto_udp6);
> -- 
> 1.7.7.6
> 
