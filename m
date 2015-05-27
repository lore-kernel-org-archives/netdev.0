From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCHv1] xen-netfront: properly destroy queues when removing
 device
Date: Wed, 27 May 2015 11:20:58 -0400
Message-ID: <5565E0DA.9070309@oracle.com>
References: <1432737970-31872-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:32456 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbbE0PVE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 11:21:04 -0400
In-Reply-To: <1432737970-31872-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/27/2015 10:46 AM, David Vrabel wrote:
> xennet_remove() freed the queues before freeing the netdevice which
> results in a use-after-free when free_netdev() tries to delete the
> napi instances that have already been freed.
>
> Fix this by fully destroy the queues (which includes deleting the napi
> instances) before freeing the netdevice.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>


Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>


> ---
>   drivers/net/xen-netfront.c |   15 ++-------------
>   1 file changed, 2 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 3f45afd..e031c94 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -1698,6 +1698,7 @@ static void xennet_destroy_queues(struct netfront_info *info)
>   
>   		if (netif_running(info->netdev))
>   			napi_disable(&queue->napi);
> +		del_timer_sync(&queue->rx_refill_timer);
>   		netif_napi_del(&queue->napi);
>   	}
>   
> @@ -2102,9 +2103,6 @@ static const struct attribute_group xennet_dev_group = {
>   static int xennet_remove(struct xenbus_device *dev)
>   {
>   	struct netfront_info *info = dev_get_drvdata(&dev->dev);
> -	unsigned int num_queues = info->netdev->real_num_tx_queues;
> -	struct netfront_queue *queue = NULL;
> -	unsigned int i = 0;
>   
>   	dev_dbg(&dev->dev, "%s\n", dev->nodename);
>   
> @@ -2112,16 +2110,7 @@ static int xennet_remove(struct xenbus_device *dev)
>   
>   	unregister_netdev(info->netdev);
>   
> -	for (i = 0; i < num_queues; ++i) {
> -		queue = &info->queues[i];
> -		del_timer_sync(&queue->rx_refill_timer);
> -	}
> -
> -	if (num_queues) {
> -		kfree(info->queues);
> -		info->queues = NULL;
> -	}
> -
> +	xennet_destroy_queues(info);
>   	xennet_free_netdev(info->netdev);
>   
>   	return 0;
