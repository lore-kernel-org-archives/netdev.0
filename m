From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [RFCv3 bluetooth-next 1/4] 6lowpan: add lowpan dev register
 helpers
Date: Tue, 1 Dec 2015 21:38:26 +0100
Message-ID: <565E0542.7010001@osg.samsung.com>
References: <1448796882-316-1-git-send-email-alex.aring@gmail.com>
 <1448796882-316-2-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	kernel@pengutronix.de, mcr@sandelman.ca, lukasz.duda@nordicsemi.no,
	martin.gergeleit@hs-rm.de
To: Alexander Aring <alex.aring@gmail.com>, linux-wpan@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:46657 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756971AbbLAUic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 15:38:32 -0500
In-Reply-To: <1448796882-316-2-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 29/11/15 12:34, Alexander Aring wrote:
> This patch introduces register and unregister functionality for lowpan
> interfaces. While register a lowpan interface there are several things
> which need to be initialize by the 6lowpan subsystem. Upcoming
> functionality need to register/unregister per interface components e.g.
> debugfs entry.
>
> Signed-off-by: Alexander Aring <alex.aring@gmail.com>
> ---
>   include/net/6lowpan.h         |  7 ++++++-
>   net/6lowpan/core.c            | 33 +++++++++++++++++++++++++++++++--
>   net/bluetooth/6lowpan.c       |  8 +++-----
>   net/ieee802154/6lowpan/core.c |  6 ++----
>   4 files changed, 42 insertions(+), 12 deletions(-)
>
> diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
> index cf3bc56..730211f 100644
> --- a/include/net/6lowpan.h
> +++ b/include/net/6lowpan.h
> @@ -185,7 +185,12 @@ static inline void lowpan_push_hc_data(u8 **hc_ptr, const void *data,
>   	*hc_ptr += len;
>   }
>   
> -void lowpan_netdev_setup(struct net_device *dev, enum lowpan_lltypes lltype);
> +int lowpan_register_netdevice(struct net_device *dev,
> +			      enum lowpan_lltypes lltype);
> +int lowpan_register_netdev(struct net_device *dev,
> +			   enum lowpan_lltypes lltype);
> +void lowpan_unregister_netdevice(struct net_device *dev);
> +void lowpan_unregister_netdev(struct net_device *dev);
>   
>   /**
>    * lowpan_header_decompress - replace 6LoWPAN header with IPv6 header
> diff --git a/net/6lowpan/core.c b/net/6lowpan/core.c
> index 83b19e0..80fc509 100644
> --- a/net/6lowpan/core.c
> +++ b/net/6lowpan/core.c
> @@ -15,7 +15,8 @@
>   
>   #include <net/6lowpan.h>
>   
> -void lowpan_netdev_setup(struct net_device *dev, enum lowpan_lltypes lltype)
> +int lowpan_register_netdevice(struct net_device *dev,
> +			      enum lowpan_lltypes lltype)
>   {
>   	dev->addr_len = EUI64_ADDR_LEN;
>   	dev->type = ARPHRD_6LOWPAN;
> @@ -23,8 +24,36 @@ void lowpan_netdev_setup(struct net_device *dev, enum lowpan_lltypes lltype)
>   	dev->priv_flags |= IFF_NO_QUEUE;
>   
>   	lowpan_priv(dev)->lltype = lltype;
> +
> +	return register_netdevice(dev);
> +}
> +EXPORT_SYMBOL(lowpan_register_netdevice);
> +
> +int lowpan_register_netdev(struct net_device *dev,
> +			   enum lowpan_lltypes lltype)
> +{
> +	int ret;
> +
> +	rtnl_lock();
> +	ret = lowpan_register_netdevice(dev, lltype);
> +	rtnl_unlock();
> +	return ret;
> +}
> +EXPORT_SYMBOL(lowpan_register_netdev);
> +
> +void lowpan_unregister_netdevice(struct net_device *dev)
> +{
> +	unregister_netdevice(dev);
> +}
> +EXPORT_SYMBOL(lowpan_unregister_netdevice);
> +
> +void lowpan_unregister_netdev(struct net_device *dev)
> +{
> +	rtnl_lock();
> +	lowpan_unregister_netdevice(dev);
> +	rtnl_unlock();
>   }
> -EXPORT_SYMBOL(lowpan_netdev_setup);
> +EXPORT_SYMBOL(lowpan_unregister_netdev);
>   
>   static int __init lowpan_module_init(void)
>   {
> diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
> index 9e9cca3..d040365 100644
> --- a/net/bluetooth/6lowpan.c
> +++ b/net/bluetooth/6lowpan.c
> @@ -825,9 +825,7 @@ static int setup_netdev(struct l2cap_chan *chan, struct lowpan_dev **dev)
>   	list_add_rcu(&(*dev)->list, &bt_6lowpan_devices);
>   	spin_unlock(&devices_lock);
>   
> -	lowpan_netdev_setup(netdev, LOWPAN_LLTYPE_BTLE);
> -
> -	err = register_netdev(netdev);
> +	err = lowpan_register_netdev(netdev, LOWPAN_LLTYPE_BTLE);
>   	if (err < 0) {
>   		BT_INFO("register_netdev failed %d", err);
>   		spin_lock(&devices_lock);
> @@ -890,7 +888,7 @@ static void delete_netdev(struct work_struct *work)
>   	struct lowpan_dev *entry = container_of(work, struct lowpan_dev,
>   						delete_netdev);
>   
> -	unregister_netdev(entry->netdev);
> +	lowpan_unregister_netdev(entry->netdev);
>   
>   	/* The entry pointer is deleted by the netdev destructor. */
>   }
> @@ -1348,7 +1346,7 @@ static void disconnect_devices(void)
>   		ifdown(entry->netdev);
>   		BT_DBG("Unregistering netdev %s %p",
>   		       entry->netdev->name, entry->netdev);
> -		unregister_netdev(entry->netdev);
> +		lowpan_unregister_netdev(entry->netdev);
>   		kfree(entry);
>   	}
>   }
> diff --git a/net/ieee802154/6lowpan/core.c b/net/ieee802154/6lowpan/core.c
> index 20c49c7..737c87a 100644
> --- a/net/ieee802154/6lowpan/core.c
> +++ b/net/ieee802154/6lowpan/core.c
> @@ -161,9 +161,7 @@ static int lowpan_newlink(struct net *src_net, struct net_device *ldev,
>   				wdev->needed_headroom;
>   	ldev->needed_tailroom = wdev->needed_tailroom;
>   
> -	lowpan_netdev_setup(ldev, LOWPAN_LLTYPE_IEEE802154);
> -
> -	ret = register_netdevice(ldev);
> +	ret = lowpan_register_netdevice(ldev, LOWPAN_LLTYPE_IEEE802154);
>   	if (ret < 0) {
>   		dev_put(wdev);
>   		return ret;
> @@ -180,7 +178,7 @@ static void lowpan_dellink(struct net_device *ldev, struct list_head *head)
>   	ASSERT_RTNL();
>   
>   	wdev->ieee802154_ptr->lowpan_dev = NULL;
> -	unregister_netdevice(ldev);
> +	lowpan_unregister_netdevice(ldev);
>   	dev_put(wdev);
>   }
>   

That is better compared to what you had in v2. I think this one is ready 
for a real PATCH and applying.

Reviewed-by: Stefan Schmidt <stefan@osg.samsung.com>

regards
Stefan Schmidt
