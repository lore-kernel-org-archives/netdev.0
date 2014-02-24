From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH V5 net-next 2/5] xen-netback: Add support for multiple
 queues
Date: Mon, 24 Feb 2014 14:58:05 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD02578E6@AMSPEX01CL01.citrite.net>
References: <1393252387-17496-1-git-send-email-andrew.bennieston@citrix.com>
 <1393252387-17496-3-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andrew Bennieston <andrew.bennieston@citrix.com>
To: Andrew Bennieston <andrew.bennieston@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:65268 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752313AbaBXO6I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 09:58:08 -0500
In-Reply-To: <1393252387-17496-3-git-send-email-andrew.bennieston@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Andrew J. Bennieston [mailto:andrew.bennieston@citrix.com]
> Sent: 24 February 2014 14:33
> To: xen-devel@lists.xenproject.org
> Cc: Ian Campbell; Wei Liu; Paul Durrant; netdev@vger.kernel.org; Andrew
> Bennieston
> Subject: [PATCH V5 net-next 2/5] xen-netback: Add support for multiple
> queues
> 
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> Builds on the refactoring of the previous patch to implement multiple
> queues between xen-netfront and xen-netback.
> 
> Writes the maximum supported number of queues into XenStore, and reads
> the values written by the frontend to determine how many queues to use.
> 
> Ring references and event channels are read from XenStore on a per-queue
> basis and rings are connected accordingly.
> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>

Reviewed-by: Paul Durrant <paul.durrant@citrix.com>

> ---
>  drivers/net/xen-netback/common.h    |    2 +
>  drivers/net/xen-netback/interface.c |    7 +++-
>  drivers/net/xen-netback/netback.c   |    8 ++++
>  drivers/net/xen-netback/xenbus.c    |   76
> ++++++++++++++++++++++++++++++-----
>  4 files changed, 82 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-
> netback/common.h
> index 4176539..e72bf38 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -261,4 +261,6 @@ void xenvif_carrier_on(struct xenvif *vif);
> 
>  extern bool separate_tx_rx_irq;
> 
> +extern unsigned int xenvif_max_queues;
> +
>  #endif /* __XEN_NETBACK__COMMON_H__ */
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-
> netback/interface.c
> index 0297980..3f623b4 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -381,7 +381,12 @@ struct xenvif *xenvif_alloc(struct device *parent,
> domid_t domid,
>  	char name[IFNAMSIZ] = {};
> 
>  	snprintf(name, IFNAMSIZ - 1, "vif%u.%u", domid, handle);
> -	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup, 1);
> +	/* Allocate a netdev with the max. supported number of queues.
> +	 * When the guest selects the desired number, it will be updated
> +	 * via netif_set_real_num_tx_queues().
> +	 */
> +	dev = alloc_netdev_mq(sizeof(struct xenvif), name, ether_setup,
> +			      xenvif_max_queues);
>  	if (dev == NULL) {
>  		pr_warn("Could not allocate netdev for %s\n", name);
>  		return ERR_PTR(-ENOMEM);
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-
> netback/netback.c
> index a32abd6..9849b63 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -54,6 +54,11 @@
>  bool separate_tx_rx_irq = 1;
>  module_param(separate_tx_rx_irq, bool, 0644);
> 
> +unsigned int xenvif_max_queues;
> +module_param(xenvif_max_queues, uint, 0644);
> +MODULE_PARM_DESC(xenvif_max_queues,
> +		"Maximum number of queues per virtual interface");
> +
>  /*
>   * This is the maximum slots a skb can have. If a guest sends a skb
>   * which exceeds this limit it is considered malicious.
> @@ -1585,6 +1590,9 @@ static int __init netback_init(void)
>  	if (!xen_domain())
>  		return -ENODEV;
> 
> +	/* Allow as many queues as there are CPUs, by default */
> +	xenvif_max_queues = num_online_cpus();
> +
>  	if (fatal_skb_slots < XEN_NETBK_LEGACY_SLOTS_MAX) {
>  		pr_info("fatal_skb_slots too small (%d), bump it to
> XEN_NETBK_LEGACY_SLOTS_MAX (%d)\n",
>  			fatal_skb_slots, XEN_NETBK_LEGACY_SLOTS_MAX);
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-
> netback/xenbus.c
> index f23ea0a..c1ae148 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -20,6 +20,7 @@
> 
>  #include "common.h"
>  #include <linux/vmalloc.h>
> +#include <linux/rtnetlink.h>
> 
>  struct backend_info {
>  	struct xenbus_device *dev;
> @@ -159,6 +160,12 @@ static int netback_probe(struct xenbus_device *dev,
>  	if (err)
>  		pr_debug("Error writing feature-split-event-channels\n");
> 
> +	/* Multi-queue support: This is an optional feature. */
> +	err = xenbus_printf(XBT_NIL, dev->nodename,
> +			"multi-queue-max-queues", "%u",
> xenvif_max_queues);
> +	if (err)
> +		pr_debug("Error writing multi-queue-max-queues\n");
> +
>  	err = xenbus_switch_state(dev, XenbusStateInitWait);
>  	if (err)
>  		goto fail;
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
> +			"guest requested %u queues, exceeding the
> maximum of %u.",
> +			requested_num_queues, xenvif_max_queues);
> +		return;
> +	}
> 
>  	err = xen_net_read_mac(dev, be->vif->fe_dev_addr);
>  	if (err) {
> @@ -500,9 +524,13 @@ static void connect(struct backend_info *be)
>  	xen_net_read_rate(dev, &credit_bytes, &credit_usec);
>  	read_xenbus_vif_flags(be);
> 
> -	be->vif->num_queues = 1;
> +	/* Use the number of queues requested by the frontend */
> +	be->vif->num_queues = requested_num_queues;
>  	be->vif->queues = vzalloc(be->vif->num_queues *
>  			sizeof(struct xenvif_queue));
> +	rtnl_lock();
> +	netif_set_real_num_tx_queues(be->vif->dev, be->vif-
> >num_queues);
> +	rtnl_unlock();
> 
>  	for (queue_index = 0; queue_index < be->vif->num_queues;
> ++queue_index) {
>  		queue = &be->vif->queues[queue_index];
> @@ -547,29 +575,52 @@ static int connect_rings(struct backend_info *be,
> struct xenvif_queue *queue)
>  	unsigned long tx_ring_ref, rx_ring_ref;
>  	unsigned int tx_evtchn, rx_evtchn;
>  	int err;
> +	char *xspath;
> +	size_t xspathsize;
> +	const size_t xenstore_path_ext_size = 11; /* sufficient for "/queue-
> NNN" */
> +
> +	/* If the frontend requested 1 queue, or we have fallen back
> +	 * to single queue due to lack of frontend support for multi-
> +	 * queue, expect the remaining XenStore keys in the toplevel
> +	 * directory. Otherwise, expect them in a subdirectory called
> +	 * queue-N.
> +	 */
> +	if (queue->vif->num_queues == 1) {
> +		xspath = (char *)dev->otherend;
> +	} else {
> +		xspathsize = strlen(dev->otherend) +
> xenstore_path_ext_size;
> +		xspath = kzalloc(xspathsize, GFP_KERNEL);
> +		if (!xspath) {
> +			xenbus_dev_fatal(dev, -ENOMEM,
> +					"reading ring references");
> +			return -ENOMEM;
> +		}
> +		snprintf(xspath, xspathsize, "%s/queue-%u", dev-
> >otherend,
> +				 queue->id);
> +	}
> 
> -	err = xenbus_gather(XBT_NIL, dev->otherend,
> +	err = xenbus_gather(XBT_NIL, xspath,
>  			    "tx-ring-ref", "%lu", &tx_ring_ref,
>  			    "rx-ring-ref", "%lu", &rx_ring_ref, NULL);
>  	if (err) {
>  		xenbus_dev_fatal(dev, err,
>  				 "reading %s/ring-ref",
> -				 dev->otherend);
> -		return err;
> +				 xspath);
> +		goto err;
>  	}
> 
>  	/* Try split event channels first, then single event channel. */
> -	err = xenbus_gather(XBT_NIL, dev->otherend,
> +	err = xenbus_gather(XBT_NIL, xspath,
>  			    "event-channel-tx", "%u", &tx_evtchn,
>  			    "event-channel-rx", "%u", &rx_evtchn, NULL);
>  	if (err < 0) {
> -		err = xenbus_scanf(XBT_NIL, dev->otherend,
> +		err = xenbus_scanf(XBT_NIL, xspath,
>  				   "event-channel", "%u", &tx_evtchn);
>  		if (err < 0) {
>  			xenbus_dev_fatal(dev, err,
>  					 "reading %s/event-channel(-tx/rx)",
> -					 dev->otherend);
> -			return err;
> +					 xspath);
> +			goto err;
>  		}
>  		rx_evtchn = tx_evtchn;
>  	}
> @@ -582,10 +633,15 @@ static int connect_rings(struct backend_info *be,
> struct xenvif_queue *queue)
>  				 "mapping shared-frames %lu/%lu port tx %u
> rx %u",
>  				 tx_ring_ref, rx_ring_ref,
>  				 tx_evtchn, rx_evtchn);
> -		return err;
> +		goto err;
>  	}
> 
> -	return 0;
> +	err = 0;
> +err: /* Regular return falls through with err == 0 */
> +	if (xspath != dev->otherend)
> +		kfree(xspath);
> +
> +	return err;
>  }
> 
>  static int read_xenbus_vif_flags(struct backend_info *be)
> --
> 1.7.10.4
