From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [RFC PATCH V3 13/16] netback: stub for multi receive
 protocol support.
Date: Mon, 30 Jan 2012 16:47:10 -0500
Message-ID: <20120130214710.GC16261@phenom.dumpdata.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
 <1327934734-8908-14-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	ian.campbell@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:24505 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844Ab2A3Vtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 16:49:45 -0500
Content-Disposition: inline
In-Reply-To: <1327934734-8908-14-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2012 at 02:45:31PM +0000, Wei Liu wrote:
> Refactor netback, make stub for mutli receive protocols. Also stub

multi.

> existing code as protocol 0.

Why not 1?

Why do we need a new rework without anything using it besides
the existing framework? OR if you are, you should say which
patch is doing it...

> 
> Now the file layout becomes:
> 
>  - interface.c: xenvif interfaces
>  - xenbus.c: xenbus related functions
>  - netback.c: common functions for various protocols
> 
> For different protocols:
> 
>  - xenvif_rx_protocolX.h: header file for the protocol, including
>                           protocol structures and functions
>  - xenvif_rx_protocolX.c: implementations
> 
> To add a new protocol:
> 
>  - include protocol header in common.h
>  - modify XENVIF_MAX_RX_PROTOCOL in common.h
>  - add protocol structure in xenvif.rx union
>  - stub in xenbus.c
>  - modify Makefile
> 
> A protocol should define five functions:
> 
>  - setup: setup frontend / backend ring connections
>  - teardown: teardown frontend / backend ring connections
>  - start_xmit: host start xmit (i.e. guest need to do rx)
>  - event: rx completion event
>  - action: prepare host side data for guest rx
> 
.. snip..

> -
> -	return resp;
> -}
> -
>  static inline int rx_work_todo(struct xenvif *vif)
>  {
>  	return !skb_queue_empty(&vif->rx_queue);
> @@ -1507,8 +999,8 @@ int xenvif_kthread(void *data)
>  		if (kthread_should_stop())
>  			break;
>  
> -		if (rx_work_todo(vif))
> -			xenvif_rx_action(vif);
> +		if (rx_work_todo(vif) && vif->action)
> +			vif->action(vif);
>  	}
>  
>  	return 0;
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index 79499fc..4067286 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -415,6 +415,7 @@ static int connect_rings(struct backend_info *be)
>  	unsigned long rx_ring_ref[NETBK_MAX_RING_PAGES];
>  	unsigned int  tx_ring_order;
>  	unsigned int  rx_ring_order;
> +	unsigned int  rx_protocol;
>  
>  	err = xenbus_gather(XBT_NIL, dev->otherend,
>  			    "event-channel", "%u", &evtchn, NULL);
> @@ -510,6 +511,11 @@ static int connect_rings(struct backend_info *be)
>  		}
>  	}
>  
> +	err = xenbus_scanf(XBT_NIL, dev->otherend, "rx-protocol",

feature-rx-protocol?

> +			   "%u", &rx_protocol);
> +	if (err < 0)
> +		rx_protocol = XENVIF_MIN_RX_PROTOCOL;
> +

You should check to see if the protocol is higher than what we can support.
The guest could be playing funny games and putting in 39432...


>  	err = xenbus_scanf(XBT_NIL, dev->otherend, "request-rx-copy", "%u",
>  			   &rx_copy);
>  	if (err == -ENOENT) {
> @@ -559,7 +565,7 @@ static int connect_rings(struct backend_info *be)
>  	err = xenvif_connect(vif,
>  			     tx_ring_ref, (1U << tx_ring_order),
>  			     rx_ring_ref, (1U << rx_ring_order),
> -			     evtchn);
> +			     evtchn, rx_protocol);
>  	if (err) {
>  		int i;
>  		xenbus_dev_fatal(dev, err,
