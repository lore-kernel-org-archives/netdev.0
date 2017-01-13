From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH] xen-netback: fix memory leaks on XenBus disconnect
Date: Fri, 13 Jan 2017 09:01:40 +0000
Message-ID: <9caa24d8838a438199ffaa5a0d69ea4a@AMSPEX02CL03.citrite.net>
References: <1484243516-141100-1-git-send-email-igor.druzhinin@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Igor Druzhinin <igor.druzhinin@citrix.com>
To: Igor Druzhinin <igor.druzhinin@citrix.com>,
        Wei Liu <wei.liu2@citrix.com>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([185.25.65.24]:3754 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751146AbdAMJBn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 04:01:43 -0500
In-Reply-To: <1484243516-141100-1-git-send-email-igor.druzhinin@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Igor Druzhinin [mailto:igor.druzhinin@citrix.com]
> Sent: 12 January 2017 17:52
> To: Wei Liu <wei.liu2@citrix.com>; xen-devel@lists.xenproject.org; Paul
> Durrant <Paul.Durrant@citrix.com>
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Igor Druzhinin
> <igor.druzhinin@citrix.com>
> Subject: [PATCH] xen-netback: fix memory leaks on XenBus disconnect
> 
> Eliminate memory leaks introduced several years ago by cleaning the queue
> resources which are allocated on XenBus connection event. Namely, queue
> structure array and pages used for IO rings.
> vif->lock is used to protect statistics gathering agents from using the
> queue structure during cleaning.
> 
> Signed-off-by: Igor Druzhinin <igor.druzhinin@citrix.com>

Reviewed-by: Paul Durrant <paul.durrant@citrix.com>

...although I was involved with discussions concerning this, so Wei should probably look it over too.

> ---
>  drivers/net/xen-netback/interface.c |  6 ++++--
>  drivers/net/xen-netback/xenbus.c    | 13 +++++++++++++
>  2 files changed, 17 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-
> netback/interface.c
> index e30ffd2..5795213 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -221,18 +221,18 @@ static struct net_device_stats
> *xenvif_get_stats(struct net_device *dev)
>  {
>  	struct xenvif *vif = netdev_priv(dev);
>  	struct xenvif_queue *queue = NULL;
> -	unsigned int num_queues = vif->num_queues;
>  	unsigned long rx_bytes = 0;
>  	unsigned long rx_packets = 0;
>  	unsigned long tx_bytes = 0;
>  	unsigned long tx_packets = 0;
>  	unsigned int index;
> 
> +	spin_lock(&vif->lock);
>  	if (vif->queues == NULL)
>  		goto out;
> 
>  	/* Aggregate tx and rx stats from each queue */
> -	for (index = 0; index < num_queues; ++index) {
> +	for (index = 0; index < vif->num_queues; ++index) {
>  		queue = &vif->queues[index];
>  		rx_bytes += queue->stats.rx_bytes;
>  		rx_packets += queue->stats.rx_packets;
> @@ -241,6 +241,8 @@ static struct net_device_stats
> *xenvif_get_stats(struct net_device *dev)
>  	}
> 
>  out:
> +	spin_unlock(&vif->lock);
> +
>  	vif->dev->stats.rx_bytes = rx_bytes;
>  	vif->dev->stats.rx_packets = rx_packets;
>  	vif->dev->stats.tx_bytes = tx_bytes;
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-
> netback/xenbus.c
> index 3124eae..85b742e 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -493,11 +493,22 @@ static int backend_create_xenvif(struct
> backend_info *be)
>  static void backend_disconnect(struct backend_info *be)
>  {
>  	if (be->vif) {
> +		unsigned int queue_index;
> +
>  		xen_unregister_watchers(be->vif);
>  #ifdef CONFIG_DEBUG_FS
>  		xenvif_debugfs_delif(be->vif);
>  #endif /* CONFIG_DEBUG_FS */
>  		xenvif_disconnect_data(be->vif);
> +		for (queue_index = 0; queue_index < be->vif-
> >num_queues; ++queue_index)
> +			xenvif_deinit_queue(&be->vif-
> >queues[queue_index]);
> +
> +		spin_lock(&be->vif->lock);
> +		vfree(be->vif->queues);
> +		be->vif->num_queues = 0;
> +		be->vif->queues = NULL;
> +		spin_unlock(&be->vif->lock);
> +
>  		xenvif_disconnect_ctrl(be->vif);
>  	}
>  }
> @@ -1034,6 +1045,8 @@ static void connect(struct backend_info *be)
>  err:
>  	if (be->vif->num_queues > 0)
>  		xenvif_disconnect_data(be->vif); /* Clean up existing
> queues */
> +	for (queue_index = 0; queue_index < be->vif->num_queues;
> ++queue_index)
> +		xenvif_deinit_queue(&be->vif->queues[queue_index]);
>  	vfree(be->vif->queues);
>  	be->vif->queues = NULL;
>  	be->vif->num_queues = 0;
> --
> 1.8.3.1
