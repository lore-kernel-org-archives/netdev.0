From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: Statically initialize init_net.dev_base_head
Date: Wed, 18 Jul 2012 16:11:49 -0400
Message-ID: <20120718201149.GB22057@hmsreliant.think-freely.org>
References: <20120718190607.22923.77935.stgit@host1-mdrustad.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	gaofeng@cn.fujitsu.com, eric.dumazet@gmail.com
To: Mark Rustad <mark.d.rustad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56105 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753015Ab2GRULy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 16:11:54 -0400
Content-Disposition: inline
In-Reply-To: <20120718190607.22923.77935.stgit@host1-mdrustad.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 18, 2012 at 12:06:07PM -0700, Mark Rustad wrote:
> This change eliminates an initialization-order hazard most
> recently seen when netprio_cgroup is built into the kernel.
> 
> With thanks to Eric Dumazet for catching a bug.
> 
> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
> ---
> 
>  net/core/dev.c           |    3 ++-
>  net/core/net_namespace.c |    4 +++-
>  2 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0f28a9e..1cb0d8a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -6283,7 +6283,8 @@ static struct hlist_head *netdev_create_hash(void)
>  /* Initialize per network namespace state */
>  static int __net_init netdev_init(struct net *net)
>  {
> -	INIT_LIST_HEAD(&net->dev_base_head);
> +	if (net != &init_net)
> +		INIT_LIST_HEAD(&net->dev_base_head);
>  
>  	net->dev_name_head = netdev_create_hash();
>  	if (net->dev_name_head == NULL)
> diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
> index dddbacb..42f1e1c 100644
> --- a/net/core/net_namespace.c
> +++ b/net/core/net_namespace.c
> @@ -27,7 +27,9 @@ static DEFINE_MUTEX(net_mutex);
>  LIST_HEAD(net_namespace_list);
>  EXPORT_SYMBOL_GPL(net_namespace_list);
>  
> -struct net init_net;
> +struct net init_net = {
> +	.dev_base_head = LIST_HEAD_INIT(init_net.dev_base_head),
> +};
>  EXPORT_SYMBOL(init_net);
>  
>  #define INITIAL_NET_GEN_PTRS	13 /* +1 for len +2 for rcu_head */
> 
> 

I think dave was going to take John Fastabends patch from earlier today, but
this works just as well.  Long term I'm going to look into delaying
initzlization for cgroups, as it creates a strange initialization state when you
have a module_init routine registered.
Neil
