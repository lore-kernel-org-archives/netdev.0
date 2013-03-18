From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 2/4] xen-netfront: drop skb when skb->len >
 65535
Date: Mon, 18 Mar 2013 14:19:48 +0000
Message-ID: <1363616388.29093.201.camel@zion.uk.xensource.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
	 <1363602955-24790-3-git-send-email-wei.liu2@citrix.com>
	 <51471AAC.2050509@citrix.com>
	 <1363614500.30193.47.camel@zakaz.uk.xensource.com>
	 <51471DE0.9060506@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:39573 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab3CROTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 10:19:49 -0400
In-Reply-To: <51471DE0.9060506@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 14:00 +0000, David Vrabel wrote:
> On 18/03/13 13:48, Ian Campbell wrote:
> > On Mon, 2013-03-18 at 13:46 +0000, David Vrabel wrote:
> >> On 18/03/13 10:35, Wei Liu wrote:
> >>> The `size' field of Xen network wire format is uint16_t, anything bigger than
> >>> 65535 will cause overflow.
> >>
> >> The backend needs to be able to handle these bad packets without
> >> disconnecting the VIF -- we can't fix all the frontend drivers.
> > 
> > Agreed, although that doesn't imply that we shouldn't fix the frontend
> > where we can -- such as upstream as Wei does here.
> 
> Yes, frontends should be fixed where possible.
> 
> This is what I came up with for the backend.  I don't have time to look
> into it further but, Wei, feel free to use it as a starting point.
> 

Thanks for this patch.

I haven't gone through XSA-39 discussion, this is why I didn't come up
with a fix for backend -- I need to make sure dropping packet like this
won't re-exhibit the security hole.


Wei.

> David
> 
> diff --git a/drivers/net/xen-netback/netback.c
> b/drivers/net/xen-netback/netback.c
> index cd49ba9..18e2671 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -899,10 +899,11 @@ static void netbk_fatal_tx_err(struct xenvif *vif)
>  static int netbk_count_requests(struct xenvif *vif,
>  				struct xen_netif_tx_request *first,
>  				struct xen_netif_tx_request *txp,
> -				int work_to_do)
> +				int work_to_do, int idx)
>  {
>  	RING_IDX cons = vif->tx.req_cons;
>  	int frags = 0;
> +	bool drop = false;
> 
>  	if (!(first->flags & XEN_NETTXF_more_data))
>  		return 0;
> @@ -922,10 +923,20 @@ static int netbk_count_requests(struct xenvif *vif,
> 
>  		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
>  		       sizeof(*txp));
> -		if (txp->size > first->size) {
> -			netdev_err(vif->dev, "Frag is bigger than frame.\n");
> -			netbk_fatal_tx_err(vif);
> -			return -EIO;
> +
> +		/*
> +		 * If the guest submitted a frame >= 64 KiB then
> +		 * first->size overflowed and following frags will
> +		 * appear to be larger than the frame.
> +		 *
> +		 * This cannot be a fatal error as there are buggy
> +		 * frontends that do this.
> +		 *
> +		 * Consume all the frags and drop the packet.
> +		 */
> +		if (!drop && txp->size > first->size) {
> +			netdev_dbg(vif->dev, "Frag is bigger than frame.\n");
> +			drop = true;
>  		}
> 
>  		first->size -= txp->size;
> @@ -938,6 +949,12 @@ static int netbk_count_requests(struct xenvif *vif,
>  			return -EINVAL;
>  		}
>  	} while ((txp++)->flags & XEN_NETTXF_more_data);
> +
> +	if (drop) {
> +		netbk_tx_err(vif, txp, idx + frags);
> +		return -EIO;
> +	}
> +
>  	return frags;
>  }
> 
> @@ -1327,7 +1344,7 @@ static unsigned xen_netbk_tx_build_gops(struct
> xen_netbk *netbk)
>  				continue;
>  		}
> 
> -		ret = netbk_count_requests(vif, &txreq, txfrags, work_to_do);
> +		ret = netbk_count_requests(vif, &txreq, txfrags, work_to_do, idx);
>  		if (unlikely(ret < 0))
>  			continue;
> 
