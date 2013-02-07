From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/10] netfilter: make /proc/net/netfilter pernet
Date: Thu, 7 Feb 2013 19:33:18 +0100
Message-ID: <20130207183318.GA18359@localhost>
References: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org, ebiederm@xmission.com,
	netdev@vger.kernel.org, lve@guap.ru
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1360223390-15589-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gao,

Thanks again for improving netns support for netfilter. Comments
below:

On Thu, Feb 07, 2013 at 03:49:41PM +0800, Gao feng wrote:
> Now,only init net has directroy /proc/net/netfilter,
> this patch make this proc dentry pernet.
> 
> Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
> ---
>  include/net/netns/x_tables.h |  3 +++
>  net/netfilter/core.c         | 40 ++++++++++++++++++++++++++++++++++------
>  2 files changed, 37 insertions(+), 6 deletions(-)
> 
> diff --git a/include/net/netns/x_tables.h b/include/net/netns/x_tables.h
> index c24060e..aa6a545 100644
> --- a/include/net/netns/x_tables.h
> +++ b/include/net/netns/x_tables.h
> @@ -9,6 +9,9 @@ struct ebt_table;
>  struct netns_xt {
>  	struct list_head tables[NFPROTO_NUMPROTO];
>  	bool notrack_deprecated_warning;
> +#if defined CONFIG_PROC_FS
> +	struct proc_dir_entry *proc_netfilter;
> +#endif

This doesn't belong here to x_tables, it should be place in
include/net/net_namespace.h.

>  #if defined(CONFIG_BRIDGE_NF_EBTABLES) || \
>      defined(CONFIG_BRIDGE_NF_EBTABLES_MODULE)
>  	struct ebt_table *broute_table;
> diff --git a/net/netfilter/core.c b/net/netfilter/core.c
> index a9c488b..2038673 100644
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> @@ -281,6 +281,35 @@ struct proc_dir_entry *proc_net_netfilter;
>  EXPORT_SYMBOL(proc_net_netfilter);
>  #endif
>  
> +static int __net_init netfilter_net_init(struct net *net)
> +{
> +#ifdef CONFIG_PROC_FS
> +	net->xt.proc_netfilter = proc_net_mkdir(net,
> +						"netfilter",
> +						net->proc_net);
> +	if (net_eq(net, &init_net)) {
> +		if (!net->xt.proc_netfilter)
> +			panic("cannot create netfilter proc entry");
> +		else
> +			proc_net_netfilter = net->xt.proc_netfilter;
> +	} else if (!net->xt.proc_netfilter) {
> +		pr_err("cannot create netfilter proc entry");
> +		return -EINVAL;
> +	}
> +#endif
> +	return 0;
> +}
> +
> +static void __net_exit netfilter_net_exit(struct net *net)
> +{
> +	remove_proc_entry("netfilter", net->proc_net);
> +}
> +
> +static struct pernet_operations netfilter_net_ops = {
> +	.init = netfilter_net_init,
> +	.exit = netfilter_net_exit,
> +};
> +
>  void __init netfilter_init(void)
>  {
>  	int i, h;
> @@ -289,12 +318,11 @@ void __init netfilter_init(void)
>  			INIT_LIST_HEAD(&nf_hooks[i][h]);
>  	}
>  
> -#ifdef CONFIG_PROC_FS
> -	proc_net_netfilter = proc_mkdir("netfilter", init_net.proc_net);
> -	if (!proc_net_netfilter)
> -		panic("cannot create netfilter proc entry");
> -#endif
> +	if (register_pernet_subsys(&netfilter_net_ops) < 0)
> +		return;
>  
> -	if (netfilter_log_init() < 0)
> +	if (netfilter_log_init() < 0) {
> +		unregister_pernet_subsys(&netfilter_net_ops);
>  		panic("cannot initialize nf_log");
> +	}
>  }
> -- 
> 1.7.11.7
> 
