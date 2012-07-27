From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/7] netpoll: make __netpoll_cleanup non-block
Date: Fri, 27 Jul 2012 14:40:31 -0400
Message-ID: <20120727184031.GB20938@hmsreliant.think-freely.org>
References: <1343403484-29347-1-git-send-email-amwang@redhat.com>
 <1343403484-29347-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Cong Wang <amwang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1343403484-29347-3-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 27, 2012 at 11:37:59PM +0800, Cong Wang wrote:
> Like the previous patch, slave_disable_netpoll() and __netpoll_cleanup()
> may be called with read_lock() held too, so we should make them
> non-block, by moving the cleanup and kfree() to call_rcu_bh() callbacks.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  drivers/net/bonding/bond_main.c |    4 +--
>  include/linux/netpoll.h         |    3 ++
>  net/8021q/vlan_dev.c            |    6 +----
>  net/bridge/br_device.c          |    6 +----
>  net/core/netpoll.c              |   42 +++++++++++++++++++++++++++++---------
>  5 files changed, 38 insertions(+), 23 deletions(-)
><snip>

>  	struct netpoll_info *npinfo;
> @@ -903,20 +921,24 @@ void __netpoll_cleanup(struct netpoll *np)
>  			ops->ndo_netpoll_cleanup(np->dev);
>  
>  		RCU_INIT_POINTER(np->dev->npinfo, NULL);
> +		call_rcu_bh(&npinfo->rcu, rcu_cleanup_netpoll_info);
> +	}
> +}
> +EXPORT_SYMBOL_GPL(__netpoll_cleanup);
>  
> -		/* avoid racing with NAPI reading npinfo */
> -		synchronize_rcu_bh();
> +static void rcu_cleanup_netpoll(struct rcu_head *rcu_head)
> +{
> +	struct netpoll *np = container_of(rcu_head, struct netpoll, rcu);
>  
> -		skb_queue_purge(&npinfo->arp_tx);
> -		skb_queue_purge(&npinfo->txq);
> -		cancel_delayed_work_sync(&npinfo->tx_work);
> +	__netpoll_cleanup(np);
> +	kfree(np);
> +}
>  
> -		/* clean after last, unfinished work */
> -		__skb_queue_purge(&npinfo->txq);
> -		kfree(npinfo);
> -	}
> +void __netpoll_free_rcu(struct netpoll *np)
> +{
> +	call_rcu_bh(&np->rcu, rcu_cleanup_netpoll);
Here, and above I see you using an rcu_head to defer cleanup, until after all
pointer uses are dropped, but I don't see any modification of code points that
dereference any struct netpoll pointers to include
rcu_read_lock()/rcu_read_unlock().  Without those using rcu to defer cleanup is
pointless, as the rcu code won't know when its safe to run.  You're no better
off that you would be just calling __netpoll_cleanup directly.
Neil

>  }
> -EXPORT_SYMBOL_GPL(__netpoll_cleanup);
> +EXPORT_SYMBOL_GPL(__netpoll_free_rcu);
>  
>  void netpoll_cleanup(struct netpoll *np)
>  {
> -- 
> 1.7.7.6
> 
> 
