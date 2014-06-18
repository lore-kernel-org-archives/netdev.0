From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Subject: Re: [PATCH net] xen-netback: bookkeep number of queues in our own
 module
Date: Wed, 18 Jun 2014 10:18:50 -0400
Message-ID: <53A19FCA.1090205@oracle.com>
References: <1403100558-12866-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37024 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752305AbaFRORS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 10:17:18 -0400
In-Reply-To: <1403100558-12866-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/18/2014 10:09 AM, Wei Liu wrote:
> The original code uses netdev->real_num_tx_queues to bookkeep number of
> queues and invokes netif_set_real_num_tx_queues to set the number of
> queues. However, netif_set_real_num_tx_queues doesn't allow
> real_num_tx_queues to be smaller than 1, which means setting the number
> to 0 will not work and real_num_tx_queues is untouched.
>
> This is bogus when xenvif_free is invoked before any number of queues is
> allocated. That function needs to iterate through all queues to free
> resources. Using the wrong number of queues results in NULL pointer
> dereference.
>
> So we bookkeep the number of queues in xen-netback to solve this
> problem. The usage of real_num_tx_queues in core driver is to cap queue
> index to a valid value. In start_xmit we've already guarded against out
> of range queue index so we should be fine.
>
> This fixes a regression introduced by multiqueue patchset in 3.16-rc1.


David sent a couple of patches earlier today that I have been testing 
and they appear to fix both netfront and netback. (I am waiting for 
32-bit to finish)

http://lists.xenproject.org/archives/html/xen-devel/2014-06/msg02308.html

-boris

>
> Reported-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> CC: Ian Campbell <ian.campbell@citrix.com>
> ---
>   drivers/net/xen-netback/common.h    |    1 +
>   drivers/net/xen-netback/interface.c |   30 +++++++++++++-----------------
>   drivers/net/xen-netback/xenbus.c    |   20 ++++++--------------
>   3 files changed, 20 insertions(+), 31 deletions(-)
>
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index 4dd7c4a..93602a6 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -222,6 +222,7 @@ struct xenvif {
>   
>   	/* Queues */
>   	struct xenvif_queue *queues;
> +	unsigned int num_queues;
>   
>   	/* Miscellaneous private stuff. */
>   	struct net_device *dev;
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 852da34..7daf64c 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -140,7 +140,8 @@ static void xenvif_wake_queue_callback(unsigned long data)
>   static u16 xenvif_select_queue(struct net_device *dev, struct sk_buff *skb,
>   			       void *accel_priv, select_queue_fallback_t fallback)
>   {
> -	unsigned int num_queues = dev->real_num_tx_queues;
> +	struct xenvif *vif = netdev_priv(dev);
> +	unsigned int num_queues = vif->num_queues;
>   	u32 hash;
>   	u16 queue_index;
>   
> @@ -162,7 +163,7 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   {
>   	struct xenvif *vif = netdev_priv(dev);
>   	struct xenvif_queue *queue = NULL;
> -	unsigned int num_queues = dev->real_num_tx_queues;
> +	unsigned int num_queues = vif->num_queues;
>   	u16 index;
>   	int min_slots_needed;
>   
> @@ -225,7 +226,7 @@ static struct net_device_stats *xenvif_get_stats(struct net_device *dev)
>   {
>   	struct xenvif *vif = netdev_priv(dev);
>   	struct xenvif_queue *queue = NULL;
> -	unsigned int num_queues = dev->real_num_tx_queues;
> +	unsigned int num_queues = vif->num_queues;
>   	unsigned long rx_bytes = 0;
>   	unsigned long rx_packets = 0;
>   	unsigned long tx_bytes = 0;
> @@ -256,7 +257,7 @@ out:
>   static void xenvif_up(struct xenvif *vif)
>   {
>   	struct xenvif_queue *queue = NULL;
> -	unsigned int num_queues = vif->dev->real_num_tx_queues;
> +	unsigned int num_queues = vif->num_queues;
>   	unsigned int queue_index;
>   
>   	for (queue_index = 0; queue_index < num_queues; ++queue_index) {
> @@ -272,7 +273,7 @@ static void xenvif_up(struct xenvif *vif)
>   static void xenvif_down(struct xenvif *vif)
>   {
>   	struct xenvif_queue *queue = NULL;
> -	unsigned int num_queues = vif->dev->real_num_tx_queues;
> +	unsigned int num_queues = vif->num_queues;
>   	unsigned int queue_index;
>   
>   	for (queue_index = 0; queue_index < num_queues; ++queue_index) {
> @@ -379,7 +380,7 @@ static void xenvif_get_ethtool_stats(struct net_device *dev,
>   				     struct ethtool_stats *stats, u64 * data)
>   {
>   	struct xenvif *vif = netdev_priv(dev);
> -	unsigned int num_queues = dev->real_num_tx_queues;
> +	unsigned int num_queues = vif->num_queues;
>   	int i;
>   	unsigned int queue_index;
>   	struct xenvif_stats *vif_stats;
> @@ -436,10 +437,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>   	char name[IFNAMSIZ] = {};
>   
>   	snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
> -	/* Allocate a netdev with the max. supported number of queues.
> -	 * When the guest selects the desired number, it will be updated
> -	 * via netif_set_real_num_tx_queues().
> -	 */
> +	/* Allocate a netdev with the max. supported number of queues. */
>   	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup,
>   			      xenvif_max_queues);
>   	if (dev == NULL) {
> @@ -458,11 +456,9 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>   	vif->dev = dev;
>   	vif->disabled = false;
>   
> -	/* Start out with no queues. The call below does not require
> -	 * rtnl_lock() as it happens before register_netdev().
> -	 */
> +	/* Start out with no queues. */
>   	vif->queues = NULL;
> -	netif_set_real_num_tx_queues(dev, 0);
> +	vif->num_queues = 0;
>   
>   	dev->netdev_ops	= &xenvif_netdev_ops;
>   	dev->hw_features = NETIF_F_SG |
> @@ -677,7 +673,7 @@ static void xenvif_wait_unmap_timeout(struct xenvif_queue *queue,
>   void xenvif_disconnect(struct xenvif *vif)
>   {
>   	struct xenvif_queue *queue = NULL;
> -	unsigned int num_queues = vif->dev->real_num_tx_queues;
> +	unsigned int num_queues = vif->num_queues;
>   	unsigned int queue_index;
>   
>   	if (netif_carrier_ok(vif->dev))
> @@ -724,7 +720,7 @@ void xenvif_deinit_queue(struct xenvif_queue *queue)
>   void xenvif_free(struct xenvif *vif)
>   {
>   	struct xenvif_queue *queue = NULL;
> -	unsigned int num_queues = vif->dev->real_num_tx_queues;
> +	unsigned int num_queues = vif->num_queues;
>   	unsigned int queue_index;
>   	/* Here we want to avoid timeout messages if an skb can be legitimately
>   	 * stuck somewhere else. Realistically this could be an another vif's
> @@ -751,9 +747,9 @@ void xenvif_free(struct xenvif *vif)
>   	/* Free the array of queues. The call below does not require
>   	 * rtnl_lock() because it happens after unregister_netdev().
>   	 */
> -	netif_set_real_num_tx_queues(vif->dev, 0);
>   	vfree(vif->queues);
>   	vif->queues = NULL;
> +	vif->num_queues = 0;
>   
>   	free_netdev(vif->dev);
>   
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 96c63dc2..c724538 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -527,9 +527,7 @@ static void connect(struct backend_info *be)
>   	/* Use the number of queues requested by the frontend */
>   	be->vif->queues = vzalloc(requested_num_queues *
>   				  sizeof(struct xenvif_queue));
> -	rtnl_lock();
> -	netif_set_real_num_tx_queues(be->vif->dev, requested_num_queues);
> -	rtnl_unlock();
> +	be->vif->num_queues = requested_num_queues;
>   
>   	for (queue_index = 0; queue_index < requested_num_queues; ++queue_index) {
>   		queue = &be->vif->queues[queue_index];
> @@ -546,9 +544,7 @@ static void connect(struct backend_info *be)
>   			 * earlier queues can be destroyed using the regular
>   			 * disconnect logic.
>   			 */
> -			rtnl_lock();
> -			netif_set_real_num_tx_queues(be->vif->dev, queue_index);
> -			rtnl_unlock();
> +			be->vif->num_queues = queue_index;
>   			goto err;
>   		}
>   
> @@ -561,9 +557,7 @@ static void connect(struct backend_info *be)
>   			 * and also clean up any previously initialised queues.
>   			 */
>   			xenvif_deinit_queue(queue);
> -			rtnl_lock();
> -			netif_set_real_num_tx_queues(be->vif->dev, queue_index);
> -			rtnl_unlock();
> +			be->vif->num_queues = queue_index;
>   			goto err;
>   		}
>   	}
> @@ -582,13 +576,11 @@ static void connect(struct backend_info *be)
>   	return;
>   
>   err:
> -	if (be->vif->dev->real_num_tx_queues > 0)
> +	if (be->vif->num_queues > 0)
>   		xenvif_disconnect(be->vif); /* Clean up existing queues */
>   	vfree(be->vif->queues);
>   	be->vif->queues = NULL;
> -	rtnl_lock();
> -	netif_set_real_num_tx_queues(be->vif->dev, 0);
> -	rtnl_unlock();
> +	be->vif->num_queues = 0;
>   	return;
>   }
>   
> @@ -596,7 +588,7 @@ err:
>   static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
>   {
>   	struct xenbus_device *dev = be->dev;
> -	unsigned int num_queues = queue->vif->dev->real_num_tx_queues;
> +	unsigned int num_queues = queue->vif->num_queues;
>   	unsigned long tx_ring_ref, rx_ring_ref;
>   	unsigned int tx_evtchn, rx_evtchn;
>   	int err;
