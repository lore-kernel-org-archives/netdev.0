From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 2/2] bridge: fix NULL pointer deref of br_port_get_rcu
Date: Mon, 16 Sep 2013 13:58:30 -0400
Message-ID: <523746C6.3010700@redhat.com>
References: <1379169748-767-1-git-send-email-zhiguohong@tencent.com> <1379169748-767-3-git-send-email-zhiguohong@tencent.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, Hong Zhiguo <zhiguohong@tencent.com>
To: Hong Zhiguo <honkiko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751201Ab3IPR6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 13:58:53 -0400
In-Reply-To: <1379169748-767-3-git-send-email-zhiguohong@tencent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2013 10:42 AM, Hong Zhiguo wrote:
> From: Hong Zhiguo <zhiguohong@tencent.com>
>
> The NULL deref happens when br_handle_frame is called between these
> 2 lines of del_nbp:
> 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
> 	/* --> br_handle_frame is called at this time */
> 	netdev_rx_handler_unregister(dev);
>
> In br_handle_frame the return of br_port_get_rcu(dev) is dereferenced
> without check but br_port_get_rcu(dev) returns NULL if:
> 	!(dev->priv_flags & IFF_BRIDGE_PORT)
>
> Eric Dumazet pointed out the testing of IFF_BRIDGE_PORT is not necessary
> here since we're in rcu_read_lock and we have synchronize_net() in
> netdev_rx_handler_unregister. So remove the testing of IFF_BRIDGE_PORT
> and by the previous patch, make sure br_port_get_rcu is called in
> bridging code.
>
> Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>

I think would be better to also include your initial patch to move the
call netdev_rx_handler_unregister(dev) up higher as it would reduce the
racy nature of input processing and port removal.

As it is now, up until netdev_rx_handler_unregister(dev) call, the input
process may call into the bridge code only to drop the packet.  With 
ebtables, that can consume considerable time that is wasted.  By 
performing the unregister() sooner we reduce the racy nature of the two
calls.

-vlad

> ---
>   net/bridge/br_private.h | 5 +----
>   1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 49fb43e..1aaca0e 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -202,10 +202,7 @@ struct net_bridge_port
>
>   static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *dev)
>   {
> -	struct net_bridge_port *port =
> -			rcu_dereference_rtnl(dev->rx_handler_data);
> -
> -	return br_port_exists(dev) ? port : NULL;
> +	return rcu_dereference(dev->rx_handler_data);
>   }
>
>   static inline struct net_bridge_port *br_port_get_rtnl(const struct net_device *dev)
>
