From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 5/8] netback: multi-page ring support
Date: Tue, 5 Mar 2013 10:41:41 +0000
Message-ID: <5135CBE5.2040902@citrix.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com> <1360944010-15336-6-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>,
	<annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:49676 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab3CEKlo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 05:41:44 -0500
In-Reply-To: <1360944010-15336-6-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/02/13 16:00, Wei Liu wrote:
> [nothing]

You need to describe the protocol used to negotiate this.  What happens
when a frontend without such support connects to a backend with support?
And vice-versa?

> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -45,6 +45,12 @@
>  #include <xen/grant_table.h>
>  #include <xen/xenbus.h>
>  
> +#define NETBK_MAX_RING_PAGE_ORDER XENBUS_MAX_RING_PAGE_ORDER
> +#define NETBK_MAX_RING_PAGES      (1U << NETBK_MAX_RING_PAGE_ORDER)
> +
> +#define NETBK_MAX_TX_RING_SIZE XEN_NETIF_TX_RING_SIZE(NETBK_MAX_RING_PAGES)
> +#define NETBK_MAX_RX_RING_SIZE XEN_NETIF_RX_RING_SIZE(NETBK_MAX_RING_PAGES)

See comment below.

> @@ -105,15 +113,19 @@ static inline struct xenbus_device *xenvif_to_xenbus_device(struct xenvif *vif)
>  	return to_xenbus_device(vif->dev->dev.parent);
>  }
>  
> -#define XEN_NETIF_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
> -#define XEN_NETIF_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
> +#define XEN_NETIF_TX_RING_SIZE(_nr_pages)		\
> +	__CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE * (_nr_pages))

Ring size is no longer const.

Would these be better as inline functions with a struct xenvif parameter?

Would need to fixup the MAX_XX_RING_SIZE macros above.

> index db638e1..fa4d46d 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -305,10 +305,16 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  	return vif;
>  }
>  
> -int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
> -		   unsigned long rx_ring_ref, unsigned int evtchn)
> +int xenvif_connect(struct xenvif *vif,
> +		   unsigned long *tx_ring_ref, unsigned int tx_ring_ref_count,
> +		   unsigned long *rx_ring_ref, unsigned int rx_ring_ref_count,
> +		   unsigned int evtchn)
>  {
>  	int err = -ENOMEM;
> +	void *addr;
> +	struct xen_netif_tx_sring *txs;
> +	struct xen_netif_rx_sring *rxs;
> +	int tmp[NETBK_MAX_RING_PAGES], i;

grant_ref_t, and elsewhere probably -- I didn't check.

> @@ -382,7 +413,8 @@ void xenvif_disconnect(struct xenvif *vif)
>  
>  	unregister_netdev(vif->dev);
>  
> -	xen_netbk_unmap_frontend_rings(vif);
> +	xen_netbk_unmap_frontend_rings(vif, (void *)vif->tx.sring);
> +	xen_netbk_unmap_frontend_rings(vif, (void *)vif->rx.sring);

Don't need the casts here.

> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -47,6 +47,19 @@
>  #include <asm/xen/hypercall.h>
>  #include <asm/xen/page.h>
>  
> +unsigned int MODPARM_netback_max_rx_ring_page_order = NETBK_MAX_RING_PAGE_ORDER;
> +module_param_named(netback_max_rx_ring_page_order,
> +		   MODPARM_netback_max_rx_ring_page_order, uint, 0);

Please don't prefix new module parameters with "netback",
"max_rx_ring_page_order" is fine.

> +MODULE_PARM_DESC(netback_max_rx_ring_page_order,
> +		 "Maximum supported receiver ring page order");
> +
> +unsigned int MODPARM_netback_max_tx_ring_page_order = NETBK_MAX_RING_PAGE_ORDER;
> +module_param_named(netback_max_tx_ring_page_order,
> +		   MODPARM_netback_max_tx_ring_page_order, uint, 0);

Ditto.

> +MODULE_PARM_DESC(netback_max_tx_ring_page_order,
> +		 "Maximum supported transmitter ring page order");
> +
> +
[...]
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
[...]
> +	err = xenbus_scanf(XBT_NIL, dev->otherend, "tx-ring-order", "%u",
> +			   &tx_ring_order);
> +	if (err < 0) {
> +		tx_ring_order = 0;
> +
> +		err = xenbus_scanf(XBT_NIL, dev->otherend, "tx-ring-ref", "%lu",
> +				   &tx_ring_ref[0]);
> +		if (err < 0) {
> +			xenbus_dev_fatal(dev, err, "reading %s/tx-ring-ref",
> +					 dev->otherend);
> +			return err;
> +		}
> +	} else {
> +		unsigned int i;
> +
> +		if (tx_ring_order > MODPARM_netback_max_tx_ring_page_order) {
> +			err = -EINVAL;
> +			xenbus_dev_fatal(dev, err,
> +					 "%s/tx-ring-page-order too big",
> +					 dev->otherend);
> +			return err;
> +		}
> +
> +		for (i = 0; i < (1U << tx_ring_order); i++) {
> +			char ring_ref_name[sizeof("tx-ring-ref") + 2];
> +
> +			snprintf(ring_ref_name, sizeof(ring_ref_name),
> +				 "tx-ring-ref%u", i);
> +
> +			err = xenbus_scanf(XBT_NIL, dev->otherend,
> +					   ring_ref_name, "%lu",
> +					   &tx_ring_ref[i]);
> +			if (err < 0) {
> +				xenbus_dev_fatal(dev, err,
> +						 "reading %s/%s",
> +						 dev->otherend,
> +						 ring_ref_name);
> +				return err;
> +			}
> +		}

Refactor this whole if/else block and the similar code below for rx into
a common library function?

It will be useful for blkback etc. as well.

> @@ -454,11 +566,28 @@ static int connect_rings(struct backend_info *be)
>  	vif->csum = !val;
>  
>  	/* Map the shared frame, irq etc. */
> -	err = xenvif_connect(vif, tx_ring_ref, rx_ring_ref, evtchn);
> +	err = xenvif_connect(vif, tx_ring_ref, (1U << tx_ring_order),
> +			     rx_ring_ref, (1U << rx_ring_order),
> +			     evtchn);
>  	if (err) {
> +		/* construct 1 2 3 / 4 5 6 */

This comment doesn't make sense to me.

David
