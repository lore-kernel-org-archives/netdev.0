From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] netfilter: check duplicate config when initializing
 in ipt_CLUSTERIP
Date: Sun, 18 Dec 2016 23:02:32 -0200
Message-ID: <20161219010232.GA31360@localhost.localdomain>
References: <9b3e1f76b5670d33727e63b6e166ae416b0d65af.1481776300.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9b3e1f76b5670d33727e63b6e166ae416b0d65af.1481776300.git.lucien.xin@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 12:31:40PM +0800, Xin Long wrote:
> Now when adding an ipt_CLUSTERIP rule, it only checks duplicate config in
> clusterip_config_find_get(). But after that, there may be still another
> thread to insert a config with the same ip, then it leaves proc_create_data
> to do duplicate check.
> 
> It's more reasonable to check duplicate config by ipt_CLUSTERIP itself,
> instead of checking it by proc fs duplicate file check. Before, when proc
> fs allowed duplicate name files in a directory, It could even crash kernel
> because of use-after-free.
> 
> This patch is to check duplicate config under the protection of clusterip
> net lock when initializing a new config.
> 
> Note that it also moves proc file node creation after adding new config, as
> proc_create_data may sleep, it couldn't be called under the clusterip_net
> lock. clusterip_config_find_get returns NULL if c->pde is null to make sure
> it can't be used until the proc file node creation is done.
> 
> Suggested-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Reviewed-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/ipv4/netfilter/ipt_CLUSTERIP.c | 26 +++++++++++++++++++-------
>  1 file changed, 19 insertions(+), 7 deletions(-)
> 
> diff --git a/net/ipv4/netfilter/ipt_CLUSTERIP.c b/net/ipv4/netfilter/ipt_CLUSTERIP.c
> index 21db00d..0e71cac 100644
> --- a/net/ipv4/netfilter/ipt_CLUSTERIP.c
> +++ b/net/ipv4/netfilter/ipt_CLUSTERIP.c
> @@ -144,7 +144,7 @@ clusterip_config_find_get(struct net *net, __be32 clusterip, int entry)
>  	rcu_read_lock_bh();
>  	c = __clusterip_config_find(net, clusterip);
>  	if (c) {
> -		if (unlikely(!atomic_inc_not_zero(&c->refcount)))
> +		if (!c->pde || unlikely(!atomic_inc_not_zero(&c->refcount)))
>  			c = NULL;
>  		else if (entry)
>  			atomic_inc(&c->entries);
> @@ -166,10 +166,11 @@ clusterip_config_init_nodelist(struct clusterip_config *c,
>  
>  static struct clusterip_config *
>  clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
> -			struct net_device *dev)
> +		      struct net_device *dev)
>  {
> +	struct net *net = dev_net(dev);
>  	struct clusterip_config *c;
> -	struct clusterip_net *cn = net_generic(dev_net(dev), clusterip_net_id);
> +	struct clusterip_net *cn = net_generic(net, clusterip_net_id);
>  
>  	c = kzalloc(sizeof(*c), GFP_ATOMIC);
>  	if (!c)
> @@ -185,6 +186,17 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
>  	atomic_set(&c->refcount, 1);
>  	atomic_set(&c->entries, 1);
>  
> +	spin_lock_bh(&cn->lock);
> +	if (__clusterip_config_find(net, ip)) {
> +		spin_unlock_bh(&cn->lock);
> +		kfree(c);
> +
> +		return NULL;
> +	}
> +
> +	list_add_rcu(&c->list, &cn->configs);
> +	spin_unlock_bh(&cn->lock);
> +
>  #ifdef CONFIG_PROC_FS
>  	{
>  		char buffer[16];
> @@ -195,16 +207,16 @@ clusterip_config_init(const struct ipt_clusterip_tgt_info *i, __be32 ip,
>  					  cn->procdir,
>  					  &clusterip_proc_fops, c);
>  		if (!c->pde) {
> +			spin_lock_bh(&cn->lock);
> +			list_del_rcu(&c->list);
> +			spin_unlock_bh(&cn->lock);
>  			kfree(c);
> +
>  			return NULL;
>  		}
>  	}
>  #endif
>  
> -	spin_lock_bh(&cn->lock);
> -	list_add_rcu(&c->list, &cn->configs);
> -	spin_unlock_bh(&cn->lock);
> -
>  	return c;
>  }
>  
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
