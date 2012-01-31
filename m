From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [RFC PATCH V3 14/16] netback: split event channels support
Date: Tue, 31 Jan 2012 10:37:09 +0000
Message-ID: <1328006229.26983.343.camel@zakaz.uk.xensource.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
	 <1327934734-8908-15-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:56811 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752419Ab2AaKhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 05:37:11 -0500
In-Reply-To: <1327934734-8908-15-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-01-30 at 14:45 +0000, Wei Liu wrote:
> Originally, netback and netfront only use one event channel to do tx /
> rx notification. This may cause unnecessary wake-up of NAPI / kthread.
> 
> When guest tx is completed, netback will only notify tx_irq.
> 
> Also modify xenvif_protocol0 to reflect this change. Rx protocol
> only notifies rx_irq.
> 
> If split-event-channels feature is not activated, rx_irq = tx_irq, so
> RX protocol will just work as expected.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/common.h              |    9 ++-
>  drivers/net/xen-netback/interface.c           |   90 ++++++++++++++++++++-----
>  drivers/net/xen-netback/netback.c             |    2 +-
>  drivers/net/xen-netback/xenbus.c              |   52 ++++++++++++---
>  drivers/net/xen-netback/xenvif_rx_protocol0.c |    2 +-
>  5 files changed, 123 insertions(+), 32 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index f3d95b3..376f0bf 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -100,8 +100,10 @@ struct xenvif {
>  
>  	u8               fe_dev_addr[6];
>  
> -	/* Physical parameters of the comms window. */
> -	unsigned int     irq;
> +	/* when split_irq == 0, only use tx_irq */
> +	int              split_irq;
> +	unsigned int     tx_irq;
> +	unsigned int     rx_irq;

Can you get rid of split_irq by setting tx_irq == rx_irq in that case
and simplify the code by doing so?

I think this should work even for places like:

	if (!vif->split_irq)
		enable_irq(vif->tx_irq);
	else {
		enable_irq(vif->tx_irq);
		enable_irq(vif->rx_irq);
	}

Just by doing
		enable_irq(vif->tx_irq);
		enable_irq(vif->rx_irq);

Since enable/disable_irq maintain a count and so it will do the right
thing if they happen to be the same.

>  	/* The shared tx ring and index. */
>  	struct xen_netif_tx_back_ring tx;
> @@ -162,7 +164,8 @@ struct xenvif *xenvif_alloc(struct device *parent,
>  int xenvif_connect(struct xenvif *vif,
>  		   unsigned long tx_ring_ref[], unsigned int tx_ring_order,
>  		   unsigned long rx_ring_ref[], unsigned int rx_ring_order,
> -		   unsigned int evtchn, unsigned int rx_protocol);
> +		   unsigned int evtchn[], int split_evtchn,
> +		   unsigned int rx_protocol);
>  void xenvif_disconnect(struct xenvif *vif);
>  
>  int xenvif_xenbus_init(void);
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 0f05f03..afccd5d 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -46,15 +46,31 @@ int xenvif_schedulable(struct xenvif *vif)
>  	return netif_running(vif->dev) && netif_carrier_ok(vif->dev);
>  }
>  
> -static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
> +static irqreturn_t xenvif_tx_interrupt(int irq, void *dev_id)
> +{
> +	struct xenvif *vif = dev_id;
> +
> +	if (RING_HAS_UNCONSUMED_REQUESTS(&vif->tx))
> +		napi_schedule(&vif->napi);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
>  {
>  	struct xenvif *vif = dev_id;
>  
>  	if (xenvif_schedulable(vif) && vif->event != NULL)
>  		vif->event(vif);
>  
> -	if (RING_HAS_UNCONSUMED_REQUESTS(&vif->tx))
> -		napi_schedule(&vif->napi);
> +	return IRQ_HANDLED;
> +}
> +
> +static irqreturn_t xenvif_interrupt(int irq, void *dev_id)
> +{
> +	xenvif_tx_interrupt(0, dev_id);

Might as well pass irq down.
[...]
> @@ -308,13 +334,14 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  int xenvif_connect(struct xenvif *vif,
>  		   unsigned long tx_ring_ref[], unsigned int tx_ring_ref_count,
>  		   unsigned long rx_ring_ref[], unsigned int rx_ring_ref_count,
> -		   unsigned int evtchn, unsigned int rx_protocol)
> +		   unsigned int evtchn[], int split_evtchn,

Explicitly tx_evtchn and rx_evtchn would be clearer than remembering
that [0]==tx and [1]==rx I think.

> +		   unsigned int rx_protocol)
>  {
>  	int err = -ENOMEM;
>  	struct xen_netif_tx_sring *txs;
>  
>  	/* Already connected through? */
> -	if (vif->irq)
> +	if (vif->tx_irq)
>  		return 0;
>  
>  	__module_get(THIS_MODULE);
> @@ -345,13 +372,35 @@ int xenvif_connect(struct xenvif *vif,
>  	if (vif->setup(vif))
>  		goto err_rx_unmap;
>  
> -	err = bind_interdomain_evtchn_to_irqhandler(
> -		vif->domid, evtchn, xenvif_interrupt, 0,
> -		vif->dev->name, vif);
> -	if (err < 0)
> -		goto err_rx_unmap;
> -	vif->irq = err;
> -	disable_irq(vif->irq);
> +	if (!split_evtchn) {

Presumably this is one of the places where you do have to care about
split vs non. I did consider whether simply registering two handlers for
the interrupt in a shared-interrupt style would work, but I think that
way lies madness and confusion...

> +		err = bind_interdomain_evtchn_to_irqhandler(
> +			vif->domid, evtchn[0], xenvif_interrupt, 0,
> +			vif->dev->name, vif);
> +		if (err < 0)
> +			goto err_rx_unmap;
> +		vif->tx_irq = vif->rx_irq = err;
> +		disable_irq(vif->tx_irq);
> +		vif->split_irq = 0;
> +	} else {
> +		err = bind_interdomain_evtchn_to_irqhandler(
> +			vif->domid, evtchn[0], xenvif_tx_interrupt,
> +			0, vif->dev->name, vif);
> +		if (err < 0)
> +			goto err_rx_unmap;
> +		vif->tx_irq = err;
> +		disable_irq(vif->tx_irq);
> +
> +		err = bind_interdomain_evtchn_to_irqhandler(
> +			vif->domid, evtchn[1], xenvif_rx_interrupt,
> +			0, vif->dev->name, vif);
> +		if (err < 0) {
> +			unbind_from_irqhandler(vif->tx_irq, vif);
> +			goto err_rx_unmap;
> +		}
> +		vif->rx_irq = err;
> +		disable_irq(vif->rx_irq);
> +		vif->split_irq = 1;
> +	}
>  
>  	init_waitqueue_head(&vif->wq);
>  	vif->task = kthread_create(xenvif_kthread,
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 4067286..c5a3b27 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -131,6 +131,14 @@ static int netback_probe(struct xenbus_device *dev,
>  			goto abort_transaction;
>  		}
>  
> +		err = xenbus_printf(xbt, dev->nodename,
> +				    "split-event-channels",

Usually we use "feature-FOO" as the names for these sorts of nodes.

> +				    "%u", 1);
> +		if (err) {
> +			message = "writing split-event-channels";
> +			goto abort_transaction;
> +		}
> +
>  		err = xenbus_transaction_end(xbt, 0);
>  	} while (err == -EAGAIN);
>  
> @@ -408,7 +416,7 @@ static int connect_rings(struct backend_info *be)
>  {
>  	struct xenvif *vif = be->vif;
>  	struct xenbus_device *dev = be->dev;
> -	unsigned int evtchn, rx_copy;
> +	unsigned int evtchn[2], split_evtchn, rx_copy;

Another case where I think two vars is better than a small array.

>  	int err;
>  	int val;
>  	unsigned long tx_ring_ref[NETBK_MAX_RING_PAGES];

Ian.
