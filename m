From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH V2 net-next 2/5] xen-netback: Add support for multiple
 queues
Date: Fri, 14 Feb 2014 14:11:25 +0000
Message-ID: <20140214141125.GB18398@zion.uk.xensource.com>
References: <1392378624-6123-1-git-send-email-andrew.bennieston@citrix.com>
 <1392378624-6123-3-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <paul.durrant@citrix.com>,
	<netdev@vger.kernel.org>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45963 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752643AbaBNOL1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 09:11:27 -0500
Content-Disposition: inline
In-Reply-To: <1392378624-6123-3-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 11:50:21AM +0000, Andrew J. Bennieston wrote:
[...]
>  
> +extern unsigned int xenvif_max_queues;
> +
>  #endif /* __XEN_NETBACK__COMMON_H__ */
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 4cde112..4dc092c 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -373,7 +373,12 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  	char name[IFNAMSIZ] = {};
>  
>  	snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
> -	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup, 1);
> +	/* Allocate a netdev with the max. supported number of queues.
> +	 * When the guest selects the desired number, it will be updated
> +	 * via netif_set_real_num_tx_queues().
> +	 */
> +	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup,
> +						  xenvif_max_queues);

Indentation.

>  	if (dev == NULL) {
>  		pr_warn("Could not allocate netdev for %s\n", name);
>  		return ERR_PTR(-ENOMEM);
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 46b2f5b..aeb5ffa 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -54,6 +54,9 @@
[...]
> @@ -490,6 +497,23 @@ static void connect(struct backend_info *be)
>  	unsigned long credit_bytes, credit_usec;
>  	unsigned int queue_index;
>  	struct xenvif_queue *queue;
> +	unsigned int requested_num_queues;
> +
> +	/* Check whether the frontend requested multiple queues
> +	 * and read the number requested.
> +	 */
> +	err = xenbus_scanf(XBT_NIL, dev->otherend,
> +			"multi-queue-num-queues",
> +			"%u", &requested_num_queues);
> +	if (err < 0) {
> +		requested_num_queues = 1; /* Fall back to single queue */
> +	} else if (requested_num_queues > xenvif_max_queues) {
> +		/* buggy or malicious guest */
> +		xenbus_dev_fatal(dev, err,
> +						 "guest requested %u queues, exceeding the maximum of %u.",
> +						 requested_num_queues, xenvif_max_queues);

Indentation.

> +		return;
> +	}
>  
[...]
> @@ -547,29 +575,52 @@ static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
>  	unsigned long tx_ring_ref, rx_ring_ref;
>  	unsigned int tx_evtchn, rx_evtchn;
>  	int err;
> +	char *xspath = NULL;
> +	size_t xspathsize;
> +	const size_t xenstore_path_ext_size = 11; /* sufficient for "/queue-NNN" */
> +
> +	/* If the frontend requested 1 queue, or we have fallen back
> +	 * to single queue due to lack of frontend support for multi-
> +	 * queue, expect the remaining XenStore keys in the toplevel
> +	 * directory. Otherwise, expect them in a subdirectory called
> +	 * queue-N.
> +	 */
> +	if (queue->vif->num_queues == 1)
> +		xspath = (char *)dev->otherend;

Coding style.

> +	else {

Wei.
