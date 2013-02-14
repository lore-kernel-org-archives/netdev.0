From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 1/2] xen-netback: correctly return errors from
 netbk_count_requests()
Date: Thu, 14 Feb 2013 16:39:01 +0000
Message-ID: <1360859941.20449.463.camel@zakaz.uk.xensource.com>
References: <1360847938-11185-1-git-send-email-david.vrabel@citrix.com>
	 <1360847938-11185-2-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	Jan Beulich <jbeulich@suse.com>,
	"Wei Liu (3P)" <wei.liu@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>,
	"Christopher S. Aker" <caker@theshore.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:19460 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757950Ab3BNQjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 11:39:06 -0500
In-Reply-To: <1360847938-11185-2-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-02-14 at 13:18 +0000, David Vrabel wrote:
> From: David Vrabel <david.vrabel@citrix.com>
> 
> netbk_count_requests() could detect an error, call
> netbk_fatal_tx_error() but return 0.  The vif may then be used
> afterwards (e.g., in a call to netbk_tx_error().
> 
> Since netbk_fatal_tx_error() could set vif->refcnt to 1, the vif may
> be freed immediately after the call to netbk_fatal_tx_error() (e.g.,
> if the vif is also removed).
> 
> Netback thread              Xenwatch thread
> -------------------------------------------
> netbk_fatal_tx_err()        netback_remove()
>                               xenvif_disconnect()
>                                 ...
>                                 free_netdev()
> netbk_tx_err() Oops!
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Signed-off-by: Jan Beulich <JBeulich@suse.com>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reported-by: Christopher S. Aker <caker@theshore.net>
Acked-by: Ian Campbell <ian.campbell@citrix.com>

Although I would like to add a Tested-by: Christopher too if possible.

David (M) this should go to stable please.

> ---
>  drivers/net/xen-netback/netback.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 2b9520c..cd49ba9 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -911,13 +911,13 @@ static int netbk_count_requests(struct xenvif *vif,
>  		if (frags >= work_to_do) {
>  			netdev_err(vif->dev, "Need more frags\n");
>  			netbk_fatal_tx_err(vif);
> -			return -frags;
> +			return -ENODATA;
>  		}
>  
>  		if (unlikely(frags >= MAX_SKB_FRAGS)) {
>  			netdev_err(vif->dev, "Too many frags\n");
>  			netbk_fatal_tx_err(vif);
> -			return -frags;
> +			return -E2BIG;
>  		}
>  
>  		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
> @@ -925,7 +925,7 @@ static int netbk_count_requests(struct xenvif *vif,
>  		if (txp->size > first->size) {
>  			netdev_err(vif->dev, "Frag is bigger than frame.\n");
>  			netbk_fatal_tx_err(vif);
> -			return -frags;
> +			return -EIO;
>  		}
>  
>  		first->size -= txp->size;
> @@ -935,7 +935,7 @@ static int netbk_count_requests(struct xenvif *vif,
>  			netdev_err(vif->dev, "txp->offset: %x, size: %u\n",
>  				 txp->offset, txp->size);
>  			netbk_fatal_tx_err(vif);
> -			return -frags;
> +			return -EINVAL;
>  		}
>  	} while ((txp++)->flags & XEN_NETTXF_more_data);
>  	return frags;
