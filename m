From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] netfilter: check duplicate config when initializing
 in ipt_CLUSTERIP
Date: Tue, 20 Dec 2016 01:48:03 +0100
Message-ID: <20161220004803.GA14656@salvia>
References: <9b3e1f76b5670d33727e63b6e166ae416b0d65af.1481776300.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>,
        netfilter-devel@vger.kernel.org, davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <9b3e1f76b5670d33727e63b6e166ae416b0d65af.1481776300.git.lucien.xin@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 15, 2016 at 12:31:40PM +0800, Xin Long wrote:
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

This is going to result in ENOMEM error report to userspace on race,
which can be confusing. Time for clusterip_config_init() to return
PTR_ERR()?

> +
> +	list_add_rcu(&c->list, &cn->configs);
> +	spin_unlock_bh(&cn->lock);
> +
>  #ifdef CONFIG_PROC_FS
>  	{
>  		char buffer[16];
