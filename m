From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH] bridge: fix hang on removal of bridge via netlink
Date: Thu, 06 Oct 2011 16:02:49 -0700
Message-ID: <1317942169.6433.17.camel@w-sridhar.beaverton.ibm.com>
References: <1317921532.6433.13.camel@w-sridhar.beaverton.ibm.com>
	 <20111006141941.437be127@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:51532 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755411Ab1JFXCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Oct 2011 19:02:52 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p96Mce1X022072
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 18:38:40 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p96N2pda138116
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 19:02:51 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p96N2o63032249
	for <netdev@vger.kernel.org>; Thu, 6 Oct 2011 20:02:51 -0300
In-Reply-To: <20111006141941.437be127@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-10-06 at 14:19 -0700, Stephen Hemminger wrote:
> Need to cleanup bridge device timers and ports when being bridge
> device is being removed via netlink.
> 
> This fixes the problem of observed when doing:
>  ip link add br0 type bridge
>  ip link set dev eth1 master br0
>  ip link set br0 up
>  ip link del br0
> 
> which would cause br0 to hang in unregister_netdev because
> of leftover reference count.
> 
> Reported-by: Sridhar Samudrala <sri@us.ibm.com>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Acked-by: Sridhar Samudrala <sri@us.ibm.com>

> 
> ---
> Patch is against net-next but should go to net and stable trees
> since it is an observable hang on 3.0 and later kernels.
> 
> --- a/net/bridge/br_if.c	2011-10-03 11:08:36.304168386 -0700
> +++ b/net/bridge/br_if.c	2011-10-06 11:27:47.682488755 -0700
> @@ -160,9 +160,10 @@ static void del_nbp(struct net_bridge_po
>  	call_rcu(&p->rcu, destroy_nbp_rcu);
>  }
> 
> -/* called with RTNL */
> -static void del_br(struct net_bridge *br, struct list_head *head)
> +/* Delete bridge device */
> +void br_dev_delete(struct net_device *dev, struct list_head *head)
>  {
> +	struct net_bridge *br = netdev_priv(dev);
>  	struct net_bridge_port *p, *n;
> 
>  	list_for_each_entry_safe(p, n, &br->port_list, list) {
> @@ -267,7 +268,7 @@ int br_del_bridge(struct net *net, const
>  	}
> 
>  	else
> -		del_br(netdev_priv(dev), NULL);
> +		br_dev_delete(dev, NULL);
> 
>  	rtnl_unlock();
>  	return ret;
> @@ -446,7 +447,7 @@ void __net_exit br_net_exit(struct net *
>  	rtnl_lock();
>  	for_each_netdev(net, dev)
>  		if (dev->priv_flags & IFF_EBRIDGE)
> -			del_br(netdev_priv(dev), &list);
> +			br_dev_delete(dev, &list);
> 
>  	unregister_netdevice_many(&list);
>  	rtnl_unlock();
> --- a/net/bridge/br_netlink.c	2011-09-16 13:12:58.061369744 -0700
> +++ b/net/bridge/br_netlink.c	2011-10-06 11:20:21.808911679 -0700
> @@ -210,6 +210,7 @@ static struct rtnl_link_ops br_link_ops
>  	.priv_size	= sizeof(struct net_bridge),
>  	.setup		= br_dev_setup,
>  	.validate	= br_validate,
> +	.dellink	= br_dev_delete,
>  };
> 
>  int __init br_netlink_init(void)
> --- a/net/bridge/br_private.h	2011-10-06 08:42:27.353044954 -0700
> +++ b/net/bridge/br_private.h	2011-10-06 11:25:17.845118817 -0700
> @@ -301,6 +301,7 @@ static inline int br_is_root_bridge(cons
> 
>  /* br_device.c */
>  extern void br_dev_setup(struct net_device *dev);
> +extern void br_dev_delete(struct net_device *dev, struct list_head *list);
>  extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
>  			       struct net_device *dev);
>  #ifdef CONFIG_NET_POLL_CONTROLLER
