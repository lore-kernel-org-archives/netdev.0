From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 3/8] netback: get/put module along with vif
 connect/disconnect
Date: Mon, 4 Mar 2013 15:56:14 -0500
Message-ID: <20130304205614.GD16762@phenom.dumpdata.com>
References: <1360944010-15336-1-git-send-email-wei.liu2@citrix.com>
 <1360944010-15336-4-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, annie.li@oracle.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41885 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932350Ab3CDU4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 15:56:21 -0500
Content-Disposition: inline
In-Reply-To: <1360944010-15336-4-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 15, 2013 at 04:00:04PM +0000, Wei Liu wrote:
> If there is vif running and user unloads netback, guest's network interface
> just mysteriously stops working. So we need to prevent unloading netback
> module if there is vif running.
> 
> The disconnect function of vif may get called by the generic framework even
> before vif connects, so thers is an extra check on whether we actually need to
> put module when disconnecting a vif.

Ah, I think this patch should come before the "netback: add module unload function"

> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/interface.c |   18 +++++++++++++++++-
>  1 file changed, 17 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 221f426..db638e1 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -314,6 +314,8 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  	if (vif->irq)
>  		return 0;
>  
> +	__module_get(THIS_MODULE);
> +
>  	err = xen_netbk_map_frontend_rings(vif, tx_ring_ref, rx_ring_ref);
>  	if (err < 0)
>  		goto err;
> @@ -341,6 +343,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  err_unmap:
>  	xen_netbk_unmap_frontend_rings(vif);
>  err:
> +	module_put(THIS_MODULE);
>  	return err;
>  }
>  
> @@ -358,18 +361,31 @@ void xenvif_carrier_off(struct xenvif *vif)
>  
>  void xenvif_disconnect(struct xenvif *vif)
>  {
> +	/*
> +	 * This function may get called even before vif connets, set

connects

> +	 * need_module_put if vif->irq != 0, which means vif has
> +	 * already connected, we should call module_put to balance the
> +	 * previous __module_get.
> +	 */
> +	int need_module_put = 0;
> +
>  	if (netif_carrier_ok(vif->dev))
>  		xenvif_carrier_off(vif);
>  
>  	atomic_dec(&vif->refcnt);
>  	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) == 0);
>  
> -	if (vif->irq)
> +	if (vif->irq) {
>  		unbind_from_irqhandler(vif->irq, vif);
> +		need_module_put = 1;
> +	}
>  
>  	unregister_netdev(vif->dev);
>  
>  	xen_netbk_unmap_frontend_rings(vif);
>  
>  	free_netdev(vif->dev);
> +
> +	if (need_module_put)
> +		module_put(THIS_MODULE);
>  }
> -- 
> 1.7.10.4
> 
