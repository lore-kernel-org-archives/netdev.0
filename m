From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [[PATCH stable <3.12]] xen-netback: fix refcnt unbalance for
 3.11 and earlier versions
Date: Thu, 28 Nov 2013 13:08:53 +0000
Message-ID: <1385644133.20209.11.camel@kazak.uk.xensource.com>
References: <1385642889-11513-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<stable@vger.kernel.org>, <tomasz.wroblewski@citrix.com>,
	Konrad Wilk <konrad.wilk@oracle.com>,
	"David Vrabel" <david.vrabel@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1385642889-11513-1-git-send-email-wei.liu2@citrix.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-11-28 at 12:48 +0000, Wei Liu wrote:
> With the introduction of "xen-netback: Don't destroy the netdev until
> the vif is shut down" (upstream commit id 279f438e36), vif disconnect
> and free are separated. However in the backported verion reference
> counting code was not correctly modified, and the reset of vif->tx_irq
> was lost. If frontend goes through vif life cycle more than once the
> reference counting is skewed.
> 
> This patch adds back the missing tx_irq reset line. It also moves
> several lines of the reference counting code to vif_free, so the moved
> code corresponds to the counterpart in vif_alloc, thus the reference
> counting is balanced.

Is this a requirement of the bugfix or just to make reasoning about
things easier?

> 3.12 and onward versions are not affected by this bug, because reference
> counting code was removed due to the introduction of 1:1 model.
> 
> This pacth should be backported to all stable verions which are lower
> than 3.12 and have 279f438e36.
> 
> Reported-and-tested-by: Tomasz Wroblewski <tomasz.wroblewski@citrix.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

> Cc: Konrad Wilk <konrad.wilk@oracle.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> ---
>  drivers/net/xen-netback/interface.c |    7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index d28324a..342d4e5 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -418,9 +418,6 @@ void xenvif_disconnect(struct xenvif *vif)
>  	if (netif_carrier_ok(vif->dev))
>  		xenvif_carrier_off(vif);
>  
> -	atomic_dec(&vif->refcnt);
> -	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) == 0);
> -
>  	if (vif->tx_irq) {
>  		if (vif->tx_irq == vif->rx_irq)
>  			unbind_from_irqhandler(vif->tx_irq, vif);
> @@ -428,6 +425,7 @@ void xenvif_disconnect(struct xenvif *vif)
>  			unbind_from_irqhandler(vif->tx_irq, vif);
>  			unbind_from_irqhandler(vif->rx_irq, vif);
>  		}
> +		vif->tx_irq = 0;
>  	}
>  
>  	xen_netbk_unmap_frontend_rings(vif);
> @@ -435,6 +433,9 @@ void xenvif_disconnect(struct xenvif *vif)
>  
>  void xenvif_free(struct xenvif *vif)
>  {
> +	atomic_dec(&vif->refcnt);
> +	wait_event(vif->waiting_to_free, atomic_read(&vif->refcnt) == 0);
> +
>  	unregister_netdev(vif->dev);
>  
>  	free_netdev(vif->dev);
