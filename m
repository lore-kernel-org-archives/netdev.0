From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH] xen-netback: fix race condition on XenBus disconnect
Date: Fri, 3 Mar 2017 09:18:11 +0000
Message-ID: <23927ef4bba04925994cb0b7acbcbbc0@AMSPEX02CL03.citrite.net>
References: <1488495410-137500-1-git-send-email-igor.druzhinin@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jgross@suse.com" <jgross@suse.com>, Wei Liu <wei.liu2@citrix.com>,
        "Igor Druzhinin" <igor.druzhinin@citrix.com>
To: Igor Druzhinin <igor.druzhinin@citrix.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:34298 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751841AbdCCJSU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Mar 2017 04:18:20 -0500
In-Reply-To: <1488495410-137500-1-git-send-email-igor.druzhinin@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Igor Druzhinin [mailto:igor.druzhinin@citrix.com]
> Sent: 02 March 2017 22:57
> To: netdev@vger.kernel.org; xen-devel@lists.xenproject.org
> Cc: Paul Durrant <Paul.Durrant@citrix.com>; jgross@suse.com; Wei Liu
> <wei.liu2@citrix.com>; Igor Druzhinin <igor.druzhinin@citrix.com>
> Subject: [PATCH] xen-netback: fix race condition on XenBus disconnect
> 
> In some cases during XenBus disconnect event handling and subsequent
> queue resource release there may be some TX handlers active on
> other processors. Use RCU in order to synchronize with them.
> 
> Signed-off-by: Igor Druzhinin <igor.druzhinin@citrix.com>
> ---
>  drivers/net/xen-netback/interface.c | 13 ++++++++-----
>  drivers/net/xen-netback/xenbus.c    | 17 +++++++----------
>  2 files changed, 15 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-
> netback/interface.c
> index a2d32676..32e2cc6 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -164,7 +164,7 @@ static int xenvif_start_xmit(struct sk_buff *skb, struct
> net_device *dev)
>  {
>  	struct xenvif *vif = netdev_priv(dev);
>  	struct xenvif_queue *queue = NULL;
> -	unsigned int num_queues = vif->num_queues;

Do you not need an rcu_read_lock() around this and use of the num_queues value (as you have below)?

> +	unsigned int num_queues = rcu_dereference(vif)->num_queues;
>  	u16 index;
>  	struct xenvif_rx_cb *cb;
> 
> @@ -221,18 +221,21 @@ static struct net_device_stats
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
> 
>  	/* Aggregate tx and rx stats from each queue */
> -	for (index = 0; index < vif->num_queues; ++index) {
> +	for (index = 0; index < num_queues; ++index) {
>  		queue = &vif->queues[index];
>  		rx_bytes += queue->stats.rx_bytes;
>  		rx_packets += queue->stats.rx_packets;
> @@ -241,7 +244,7 @@ static struct net_device_stats
> *xenvif_get_stats(struct net_device *dev)
>  	}
> 
>  out:
> -	spin_unlock(&vif->lock);
> +	rcu_read_unlock();
> 
>  	vif->dev->stats.rx_bytes = rx_bytes;
>  	vif->dev->stats.rx_packets = rx_packets;
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-
> netback/xenbus.c
> index d2d7cd9..76efb01 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -495,26 +495,23 @@ static void backend_disconnect(struct
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
>  		vif->num_queues = 0;
> -		vif->queues = NULL;
> -		spin_unlock(&vif->lock);
> +		synchronize_net();

So, num_queues is your RCU protected value, rather than the queues pointer, in which case I think you probably need to change code such as

https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/tree/drivers/net/xen-netback/netback.c?id=refs/tags/v4.10#n216

to be gated on num_queues.

Also shouldn't xenvif_up(), xenvif_down() and xenvif_get_ethtool_stats() not be using rcu_read_lock() and rcu_dereference() of num_queues as well?

  Paul

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
