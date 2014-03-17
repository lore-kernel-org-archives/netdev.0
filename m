From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netpoll: send arp reply on master device immediately
Date: Mon, 17 Mar 2014 07:11:49 -0400
Message-ID: <20140317111149.GA29358@hmsreliant.think-freely.org>
References: <1395042106-25179-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38373 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932526AbaCQLMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 07:12:02 -0400
Content-Disposition: inline
In-Reply-To: <1395042106-25179-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 17, 2014 at 03:41:46PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> 1. the arp queue has been moved from slave device to master, so the
> master device netpoll_info should be as input of service_arp_queue()
> 2. not need to check if ni is NULL or not, since it has been used before.
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> Cc: WANG Cong <amwang@redhat.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> ---
>  net/core/netpoll.c |   26 ++++++++++++--------------
>  1 file changed, 12 insertions(+), 14 deletions(-)
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index a664f78..dd0a796 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -229,21 +229,19 @@ static void netpoll_poll_dev(struct net_device *dev)
>  	up(&ni->dev_lock);
>  
>  	if (dev->flags & IFF_SLAVE) {
> -		if (ni) {
> -			struct net_device *bond_dev;
> -			struct sk_buff *skb;
> -			struct netpoll_info *bond_ni;
> -
> -			bond_dev = netdev_master_upper_dev_get_rcu(dev);
> -			bond_ni = rcu_dereference_bh(bond_dev->npinfo);
> -			while ((skb = skb_dequeue(&ni->neigh_tx))) {
> -				skb->dev = bond_dev;
> -				skb_queue_tail(&bond_ni->neigh_tx, skb);
> -			}
> -		}
> -	}
> +		struct net_device *bond_dev;
> +		struct sk_buff *skb;
> +		struct netpoll_info *bond_ni;
>  
> -	service_neigh_queue(ni);
> +		bond_dev = netdev_master_upper_dev_get_rcu(dev);
> +		bond_ni = rcu_dereference_bh(bond_dev->npinfo);
> +		while ((skb = skb_dequeue(&ni->neigh_tx))) {
> +			skb->dev = bond_dev;
> +			skb_queue_tail(&bond_ni->neigh_tx, skb);
> +		}

Here, instead of calling service_neigh_queue in two separate places, just set
ni = bond_ni if you fall into the if conditional.  Then you can get rid of the
else clause and have a single call site for service_neigh_queue

Other than that, looks good.

Neil

> +		service_neigh_queue(bond_ni);
> +	} else
> +		service_neigh_queue(ni);
>  
>  	zap_completion_queue();
>  }
> -- 
> 1.7.10.4
> 
> 
