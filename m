From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bridge: change the order of actions in
 addif/delif
Date: Tue, 17 Sep 2013 04:57:02 -0700
Message-ID: <1379419022.3457.8.camel@edumazet-glaptop>
References: <1379403883-16219-1-git-send-email-zhiguohong@tencent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	davem@davemloft.net, vyasevic@redhat.com,
	Hong Zhiguo <zhiguohong@tencent.com>
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34185 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340Ab3IQL5F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 07:57:05 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp13so6649771pab.7
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 04:57:04 -0700 (PDT)
In-Reply-To: <1379403883-16219-1-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-17 at 15:44 +0800, Hong Zhiguo wrote:
> From: Hong Zhiguo <zhiguohong@tencent.com>
> 
> netdev_rx_handler_register turns on the bridge traffic. It should
> be the last action of br_add_if, after the installation of fdb and
> stp staff. _Maybe_ traffic coming in before preparation of fdb and
> stp is taken care of, but we could make it easier.
> 
> Vise versa, netdev_rx_handler_unregister actually turns off bridge
> traffic from the dev. It should be the first action of br_del_if,
> before fdb and stp staff is uninstalled.
> 
> Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
> ---
>  net/bridge/br_if.c | 20 ++++++++------------
>  1 file changed, 8 insertions(+), 12 deletions(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index c41d5fb..6544154 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -133,6 +133,8 @@ static void del_nbp(struct net_bridge_port *p)
>  
>  	sysfs_remove_link(br->ifobj, p->dev->name);
>  
> +	netdev_rx_handler_unregister(dev);
> +
>  	dev_set_promiscuity(dev, -1);
>  
>  	spin_lock_bh(&br->lock);
> @@ -148,8 +150,6 @@ static void del_nbp(struct net_bridge_port *p)
>  
>  	dev->priv_flags &= ~IFF_BRIDGE_PORT;
>  
> -	netdev_rx_handler_unregister(dev);
> -
>  	netdev_upper_dev_unlink(dev, br->dev);
>  

This was really your first patch, and I 'Acked' it.
(OK, changelog can be different now we fixed the bug)

The following should be part of a different patch

>  	br_multicast_del_port(p);
> @@ -336,8 +336,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>  	if (dev->netdev_ops->ndo_start_xmit == br_dev_xmit)
>  		return -ELOOP;
>  
> -	/* Device is already being bridged */
> -	if (br_port_exists(dev))
> +	/* Device is already being bridged or registered with other handler */
> +	if (br_port_exists(dev) || dev->rx_handler)
>  		return -EBUSY;

rcu_access_pointer(dev->rx_handler)

Anyway, this is risky, because it assumes netdev_rx_handler_register()
implementation wont change.

Just leave the code as is, I don't think its worth it.
