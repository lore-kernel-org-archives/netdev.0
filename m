From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net v2] xen-netback: fix race condition on XenBus
 disconnect
Date: Mon, 6 Mar 2017 08:58:33 +0000
Message-ID: <0b02f5c64ed74695a7025e35821147c3@AMSPEX02CL03.citrite.net>
References: <1488572587-91220-1-git-send-email-igor.druzhinin@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jgross@suse.com" <jgross@suse.com>, Wei Liu <wei.liu2@citrix.com>,
        "Igor Druzhinin" <igor.druzhinin@citrix.com>
To: Igor Druzhinin <igor.druzhinin@citrix.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:22822 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752580AbdCFI6g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 03:58:36 -0500
In-Reply-To: <1488572587-91220-1-git-send-email-igor.druzhinin@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Igor Druzhinin [mailto:igor.druzhinin@citrix.com]
> Sent: 03 March 2017 20:23
> To: netdev@vger.kernel.org; xen-devel@lists.xenproject.org
> Cc: Paul Durrant <Paul.Durrant@citrix.com>; jgross@suse.com; Wei Liu
> <wei.liu2@citrix.com>; Igor Druzhinin <igor.druzhinin@citrix.com>
> Subject: [PATCH net v2] xen-netback: fix race condition on XenBus
> disconnect
> 
> In some cases during XenBus disconnect event handling and subsequent
> queue resource release there may be some TX handlers active on
> other processors. Use RCU in order to synchronize with them.
> 
> Signed-off-by: Igor Druzhinin <igor.druzhinin@citrix.com>
> ---
> v2:
>  * Add protection for xenvif_get_ethtool_stats
>  * Additional comments and fixes
> ---
>  drivers/net/xen-netback/interface.c | 29 ++++++++++++++++++++++-------
>  drivers/net/xen-netback/netback.c   |  2 +-
>  drivers/net/xen-netback/xenbus.c    | 20 ++++++++++----------
>  3 files changed, 33 insertions(+), 18 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-
> netback/interface.c
> index a2d32676..266b7cd 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -164,13 +164,17 @@ static int xenvif_start_xmit(struct sk_buff *skb,
> struct net_device *dev)
>  {
>  	struct xenvif *vif = netdev_priv(dev);
>  	struct xenvif_queue *queue = NULL;
> -	unsigned int num_queues = vif->num_queues;
> +	unsigned int num_queues;
>  	u16 index;
>  	struct xenvif_rx_cb *cb;
> 
>  	BUG_ON(skb->dev != dev);
> 
> -	/* Drop the packet if queues are not set up */
> +	/* Drop the packet if queues are not set up.
> +	 * This handler should be called inside an RCU read section
> +	 * so we don't need to enter it here explicitly.
> +	 */
> +	num_queues = rcu_dereference(vif)->num_queues;
>  	if (num_queues < 1)
>  		goto drop;
> 
> @@ -221,18 +225,21 @@ static struct net_device_stats
> *xenvif_get_stats(struct net_device *dev)
>  {
>  	struct xenvif *vif = netdev_priv(dev);
>  	struct xenvif_queue *queue = NULL;
> +	unsigned int num_queues;
>  	u64 rx_bytes = 0;
>  	u64 rx_packets = 0;
>  	u64 tx_bytes = 0;
>  	u64 tx_packets = 0;
>  	unsigned int index;
> 
> -	spin_lock(&vif->lock);
> -	if (vif->queues == NULL)
> +	rcu_read_lock();
> +
> +	num_queues = rcu_dereference(vif)->num_queues;
> +	if (num_queues < 1)
>  		goto out;

Is this if clause worth it? All it does is jump over the for loop, which would not be executed anyway, since the initial test (0 < 0) would fail.

> 
>  	/* Aggregate tx and rx stats from each queue */
> -	for (index = 0; index < vif->num_queues; ++index) {
> +	for (index = 0; index < num_queues; ++index) {
>  		queue = &vif->queues[index];
>  		rx_bytes += queue->stats.rx_bytes;
>  		rx_packets += queue->stats.rx_packets;
> @@ -241,7 +248,7 @@ static struct net_device_stats
> *xenvif_get_stats(struct net_device *dev)
>  	}
> 
>  out:
> -	spin_unlock(&vif->lock);
> +	rcu_read_unlock();
> 
>  	vif->dev->stats.rx_bytes = rx_bytes;
>  	vif->dev->stats.rx_packets = rx_packets;
> @@ -377,10 +384,16 @@ static void xenvif_get_ethtool_stats(struct
> net_device *dev,
>  				     struct ethtool_stats *stats, u64 * data)
>  {
>  	struct xenvif *vif = netdev_priv(dev);
> -	unsigned int num_queues = vif->num_queues;
> +	unsigned int num_queues;
>  	int i;
>  	unsigned int queue_index;
> 
> +	rcu_read_lock();
> +
> +	num_queues = rcu_dereference(vif)->num_queues;
> +	if (num_queues < 1)
> +		goto out;
> +

You have introduced a semantic change with the above if clause. The xenvif_stats array was previously zeroed if num_queues < 1. It appears that ethtool does actually allocate a zeroed array to pass in here, but I wonder whether it is still safer to have this function zero it anyway. 

>  	for (i = 0; i < ARRAY_SIZE(xenvif_stats); i++) {
>  		unsigned long accum = 0;
>  		for (queue_index = 0; queue_index < num_queues;
> ++queue_index) {
> @@ -389,6 +402,8 @@ static void xenvif_get_ethtool_stats(struct
> net_device *dev,
>  		}
>  		data[i] = accum;
>  	}
> +out:
> +	rcu_read_unlock();
>  }
> 
>  static void xenvif_get_strings(struct net_device *dev, u32 stringset, u8 *
> data)
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-
> netback/netback.c
> index f9bcf4a..62fa74d 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -214,7 +214,7 @@ static void xenvif_fatal_tx_err(struct xenvif *vif)
>  	netdev_err(vif->dev, "fatal error; disabling device\n");
>  	vif->disabled = true;
>  	/* Disable the vif from queue 0's kthread */
> -	if (vif->queues)
> +	if (vif->num_queues > 0)

num_queues is unsigned so this check should not be > 0. It would be better simply to do:

if (vif->num_queues)

  Paul

>  		xenvif_kick_thread(&vif->queues[0]);
>  }
> 
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-
> netback/xenbus.c
> index d2d7cd9..a56d3ea 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -495,26 +495,26 @@ static void backend_disconnect(struct
> backend_info *be)
>  	struct xenvif *vif = be->vif;
> 
>  	if (vif) {
> +		unsigned int num_queues = vif->num_queues;
>  		unsigned int queue_index;
> -		struct xenvif_queue *queues;
> 
>  		xen_unregister_watchers(vif);
>  #ifdef CONFIG_DEBUG_FS
>  		xenvif_debugfs_delif(vif);
>  #endif /* CONFIG_DEBUG_FS */
>  		xenvif_disconnect_data(vif);
> -		for (queue_index = 0;
> -		     queue_index < vif->num_queues;
> -		     ++queue_index)
> -			xenvif_deinit_queue(&vif->queues[queue_index]);
> 
> -		spin_lock(&vif->lock);
> -		queues = vif->queues;
> +		/* At this point some of the handlers may still be active
> +		 * so we need to have additional synchronization here.
> +		 */
>  		vif->num_queues = 0;
> -		vif->queues = NULL;
> -		spin_unlock(&vif->lock);
> +		synchronize_net();
> 
> -		vfree(queues);
> +		for (queue_index = 0; queue_index < num_queues;
> ++queue_index)
> +			xenvif_deinit_queue(&vif->queues[queue_index]);
> +
> +		vfree(vif->queues);
> +		vif->queues = NULL;
> 
>  		xenvif_disconnect_ctrl(vif);
>  	}
> --
> 1.8.3.1
