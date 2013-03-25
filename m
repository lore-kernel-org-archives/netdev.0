From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH 6/6] xen-netback: don't disconnect frontend
 when seeing oversize frame
Date: Mon, 25 Mar 2013 12:58:34 -0400
Message-ID: <20130325165834.GC25740@phenom.dumpdata.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com>
 <1364209702-12437-7-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	annie.li@oracle.com, david.vrabel@citrix.com,
	ian.campbell@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:25664 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932231Ab3CYQ6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 12:58:46 -0400
Content-Disposition: inline
In-Reply-To: <1364209702-12437-7-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 25, 2013 at 11:08:22AM +0000, Wei Liu wrote:
> Some buggy frontends may generate frames larger than 64 KiB. We should
> aggresively consume all slots and drop the packet instead of disconnecting the
> frontend.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

CC stable@vger.kernel.org ?

> ---
>  drivers/net/xen-netback/netback.c |   32 ++++++++++++++++++++++++++------
>  1 file changed, 26 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index a634dc5..1971623 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -924,10 +924,12 @@ static void netbk_fatal_tx_err(struct xenvif *vif)
>  static int netbk_count_requests(struct xenvif *vif,
>  				struct xen_netif_tx_request *first,
>  				struct xen_netif_tx_request *txp,
> -				int work_to_do)
> +				int work_to_do,
> +				RING_IDX first_idx)
>  {
>  	RING_IDX cons = vif->tx.req_cons;
>  	int slots = 0;
> +	bool drop = false;
>  
>  	if (!(first->flags & XEN_NETTXF_more_data))
>  		return 0;
> @@ -947,10 +949,21 @@ static int netbk_count_requests(struct xenvif *vif,
>  
>  		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
>  		       sizeof(*txp));
> -		if (txp->size > first->size) {
> -			netdev_err(vif->dev, "Packet is bigger than frame.\n");
> -			netbk_fatal_tx_err(vif);
> -			return -EIO;
> +
> +		/* If the guest submitted a frame >= 64 KiB then
> +		 * first->size overflowed and following slots will
> +		 * appear to be larger than the frame.
> +		 *
> +		 * This cannot be fatal error as there are buggy
> +		 * frontends that do this.
> +		 *
> +		 * Consume all slots and drop the packet.
> +		 */
> +		if (!drop && txp->size > first->size) {
> +			if (net_ratelimit())
> +				netdev_dbg(vif->dev,
> +					   "Packet is bigger than frame.\n");
> +			drop = true;
>  		}
>  
>  		first->size -= txp->size;
> @@ -963,6 +976,12 @@ static int netbk_count_requests(struct xenvif *vif,
>  			return -EINVAL;
>  		}
>  	} while ((txp++)->flags & XEN_NETTXF_more_data);
> +
> +	if (drop) {
> +		netbk_tx_err(vif, first, first_idx + slots);
> +		return -EIO;
> +	}
> +
>  	return slots;
>  }
>  
> @@ -1429,7 +1448,8 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
>  				continue;
>  		}
>  
> -		ret = netbk_count_requests(vif, &txreq, txfrags, work_to_do);
> +		ret = netbk_count_requests(vif, &txreq, txfrags,
> +					   work_to_do, idx);
>  		if (unlikely(ret < 0))
>  			continue;
>  
> -- 
> 1.7.10.4
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> http://lists.xen.org/xen-devel
> 
