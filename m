From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net 1/2] macvlan: introduce IFF_MACVLAN flag and helper
 functions
Date: Fri, 08 Nov 2013 07:06:15 -0800
Message-ID: <527CFDE7.4040405@intel.com>
References: <cover.1383915401.git.mkubecek@suse.cz> <7ca53d743ffa48f671c35335473798c66d908d56.1383915401.git.mkubecek@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:47710 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932239Ab3KHPG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Nov 2013 10:06:29 -0500
In-Reply-To: <7ca53d743ffa48f671c35335473798c66d908d56.1383915401.git.mkubecek@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/8/2013 5:41 AM, Michal Kubecek wrote:
> Introduce IFF_MACVLAN flag to recognize macvlan devices and two
> helper functions, is_macvlan_dev() and macvlan_dev_real_dev().
> These work like similar functions for 802.1q VLAN devices.
>
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
> ---
>   drivers/net/macvlan.c      |  2 +-
>   include/linux/if_macvlan.h | 26 ++++++++++++++++++++++++++
>   include/uapi/linux/if.h    |  1 +
>   3 files changed, 28 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 9bf46bd..3bdac0a 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -685,7 +685,7 @@ void macvlan_common_setup(struct net_device *dev)
>   	ether_setup(dev);
>
>   	dev->priv_flags	       &= ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
> -	dev->priv_flags	       |= IFF_UNICAST_FLT;
> +	dev->priv_flags	       |= IFF_UNICAST_FLT | IFF_MACVLAN;
>   	dev->netdev_ops		= &macvlan_netdev_ops;
>   	dev->destructor		= free_netdev;
>   	dev->header_ops		= &macvlan_hard_header_ops;
> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
> index ddd33fd..8f355f9 100644
> --- a/include/linux/if_macvlan.h
> +++ b/include/linux/if_macvlan.h
> @@ -118,4 +118,30 @@ extern int macvlan_link_register(struct rtnl_link_ops *ops);
>   extern netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
>   				      struct net_device *dev);
>
> +#if IS_ENABLED(CONFIG_MACVLAN)
> +static inline bool is_macvlan_dev(struct net_device *dev)
> +{
> +	return dev->priv_flags & IFF_MACVLAN;
> +}
> +

I just added this to netdevice.h here,

+static inline bool netif_is_macvlan(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_MACVLAN;
+}
+

although I didn't wrap it in the IS_ENABLED if/else, but a
bitmask in slow path probably doesn't matter. As a precedent
none of the other netif_is_* bitmasks are wrapped like this.

The patch is

commit 2a47fa45d4dfbc54659d28de311a1f764b296a3c
Author: John Fastabend <john.r.fastabend@intel.com>
Date:   Wed Nov 6 09:54:52 2013 -0800

     ixgbe: enable l2 forwarding acceleration for macvlans


I think you need to respin the patch with just the
macvlan_dev_real_dev() part.

Thanks,
John
