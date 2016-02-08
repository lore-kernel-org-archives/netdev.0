From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 2/3] macvlan: add queue selection
 functionality
Date: Sun, 07 Feb 2016 19:45:22 -0800
Message-ID: <1454903122.7627.361.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454901296-9915-1-git-send-email-vyasevic@redhat.com>
	 <1454901296-9915-3-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com, mst@redhat.com,
	Vladislav Yasevich <vyasevic@redhat.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34553 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754394AbcBHDpZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Feb 2016 22:45:25 -0500
Received: by mail-wm0-f45.google.com with SMTP id 128so138519027wmz.1
        for <netdev@vger.kernel.org>; Sun, 07 Feb 2016 19:45:24 -0800 (PST)
In-Reply-To: <1454901296-9915-3-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-02-07 at 22:14 -0500, Vladislav Yasevich wrote:
> This patch adds a simple queue selection function to macvlan
> layer.  In most cases, this will just use the standard fallback
> fuction, but when rx-queue has been recoreded we'll try to use
> that value.
> 
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/macvlan.c | 20 ++++++++++++++++++++
>  1 file changed, 20 insertions(+)
> 
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 94e6888..213d587 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -1018,6 +1018,25 @@ static int macvlan_dev_get_iflink(const struct net_device *dev)
>  	return vlan->lowerdev->ifindex;
>  }
>  
> +static u16 macvlan_select_queue(struct net_device *dev,
> +				struct sk_buff *skb,
> +				void *accel_priv,
> +				select_queue_fallback_t fallback)
> +{
> +	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
> +
> +	if (!txq)
> +		return fallback(dev, skb);
> +
> +	if (unlikely(txq >= dev->real_num_tx_queues)) {
> +		do {
> +			txq -= dev->real_num_tx_queues;
> +		} while (txq >= dev->real_num_tx_queues);
> +	}
> +	return txq;
> +}
> +
> +
>  static const struct ethtool_ops macvlan_ethtool_ops = {
>  	.get_link		= ethtool_op_get_link,
>  	.get_settings		= macvlan_ethtool_get_settings,
> @@ -1048,6 +1067,7 @@ static const struct net_device_ops macvlan_netdev_ops = {
>  	.ndo_netpoll_setup	= macvlan_dev_netpoll_setup,
>  	.ndo_netpoll_cleanup	= macvlan_dev_netpoll_cleanup,
>  #endif
> +	.ndo_select_queue	= macvlan_select_queue,
>  	.ndo_get_iflink		= macvlan_dev_get_iflink,
>  	.ndo_features_check	= passthru_features_check,
>  };

Should not it be the default behavior ?

This patch looks not needed to me.
