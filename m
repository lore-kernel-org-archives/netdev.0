From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v2] Don't destroy the netdev until the vif is shut down
Date: Thu, 12 Sep 2013 16:21:22 +0100
Message-ID: <20130912152122.GC934@zion.uk.xensource.com>
References: <1378988092-15443-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:23483 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147Ab3ILPVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 11:21:25 -0400
Content-Disposition: inline
In-Reply-To: <1378988092-15443-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The title should start with "[PATCH net-next]".

On Thu, Sep 12, 2013 at 01:14:52PM +0100, Paul Durrant wrote:
> Without this patch, if a frontend cycles through states Closing
> and Closed (which Windows frontends need to do) then the netdev
> will be destroyed and requires re-invocation of hotplug scripts
> to restore state before the frontend can move to Connected. Thus
> when udev is not in use the backend gets stuck in InitWait.
> 
> With this patch, the netdev is left alone whilst the backend is
> still online and is only de-registered and freed just prior to
> destroying the vif (which is also nicely symmetrical with the
> netdev allocation and registration being done during probe) so
> no re-invocation of hotplug scripts is required.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> ---
> v2:
>  - Modify netback_remove() - bug only seemed to manifest with linux guest
> 
>  drivers/net/xen-netback/common.h    |    1 +
>  drivers/net/xen-netback/interface.c |   13 ++++++++-----
>  drivers/net/xen-netback/xenbus.c    |   17 ++++++++++++-----
>  3 files changed, 21 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index a197743..5715318 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -184,6 +184,7 @@ int xenvif_connect(struct xenvif *vif, unsigned long tx_ring_ref,
>  		   unsigned long rx_ring_ref, unsigned int tx_evtchn,
>  		   unsigned int rx_evtchn);
>  void xenvif_disconnect(struct xenvif *vif);
> +void xenvif_free(struct xenvif *vif);
>  

This can be moved a few lines above to group with xenvif_alloc() IMHO.

>  int xenvif_xenbus_init(void);
>  void xenvif_xenbus_fini(void);
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index 625c6f4..65e78f9 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -477,14 +477,17 @@ void xenvif_disconnect(struct xenvif *vif)
>  	if (vif->task)
>  		kthread_stop(vif->task);
>  
> +	xenvif_unmap_frontend_rings(vif);
> +
> +	if (need_module_put)
> +		module_put(THIS_MODULE);
> +}
> +

The original thought for this module_get/put thing is that admin can
just disconnect all frontends then replace netback module. With this
patch that doesn't work anymore. We leak memory when all frontends are
disconnected and admin runs "modprobe -r xen-netback".  That happened to
work before ecause everytime a frontend is disconnected the netdev structure
is already freed.

The ability to unload netback is still quite handy for developer / admin
so I would like to keep it. My suggestion would be, move module_get/put
to the point where netdev is allocated / freed. The impact of moving
module_get/put is that we cannot just simply disconnect all frontends
then replace netback, we need to actually shutdown / migrate all VMs
before replacing netback.

Wei.
