From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net 3/4] xen-netback: Fix releasing header slot on error
 path
Date: Fri, 18 Jul 2014 16:25:02 +0100
Message-ID: <20140718152502.GP7142@zion.uk.xensource.com>
References: <1405624192-21722-1-git-send-email-zoltan.kiss@citrix.com>
 <1405624192-21722-4-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1405624192-21722-4-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2014 at 08:09:51PM +0100, Zoltan Kiss wrote:
> This patch makes this function aware that the first frag and the header might
> share the same ring slot. That could happen if the first slot is bigger than
> MAX_SKB_LEN. Due to this the error path might release that slot twice or never,

I guess you mean PKT_PROT_LEN.

Just one question, how come that we didn't come across this with copying
backend? Comparing txreq.size against PKT_PROT_LEN is not new in mapping
backend.

> depending on the error scenario.
> xenvif_idx_release is also removed from xenvif_idx_unmap, and called separately.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Reported-by: Armin Zentai <armin.zentai@ezit.hu>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: xen-devel@lists.xenproject.org
> ---
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index e9ffb05..938d5a9 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1039,6 +1039,8 @@ static int xenvif_tx_check_gop(struct xenvif_queue *queue,
>  	 */
>  	struct skb_shared_info *first_shinfo = NULL;
>  	int nr_frags = shinfo->nr_frags;
> +	const bool sharedslot = nr_frags &&
> +				frag_get_pending_idx(&shinfo->frags[0]) == pending_idx;
>  	int i, err;
>  
>  	/* Check status of header. */
> @@ -1051,7 +1053,10 @@ static int xenvif_tx_check_gop(struct xenvif_queue *queue,
>  				   (*gopp_copy)->status,
>  				   pending_idx,
>  				   (*gopp_copy)->source.u.ref);
> -		xenvif_idx_release(queue, pending_idx, XEN_NETIF_RSP_ERROR);
> +		/* The first frag might still have this slot mapped */
> +		if (!sharedslot)
> +			xenvif_idx_release(queue, pending_idx,
> +					   XEN_NETIF_RSP_ERROR);
>  	}
>  
>  check_frags:
> @@ -1068,8 +1073,19 @@ check_frags:
>  						pending_idx,
>  						gop_map->handle);
>  			/* Had a previous error? Invalidate this fragment. */
> -			if (unlikely(err))
> +			if (unlikely(err)) {
>  				xenvif_idx_unmap(queue, pending_idx);
> +				/* If the mapping of the first frag was OK, but
> +				 * the header's copy failed, and they are
> +				 * sharing a slot, send an error
> +				 */
> +				if (i == 0 && sharedslot)
> +					xenvif_idx_release(queue, pending_idx,
> +							   XEN_NETIF_RSP_ERROR);
> +				else
> +					xenvif_idx_release(queue, pending_idx,
> +							   XEN_NETIF_RSP_OKAY);

I guess this is sort of OK, just a bit fragile. Couldn't think of a
better way to refactor this function. :-(

> +			}
>  			continue;
>  		}
>  
> @@ -1081,15 +1097,27 @@ check_frags:
>  				   gop_map->status,
>  				   pending_idx,
>  				   gop_map->ref);
> +

Stray blank line.

And did you miss a callsite of xenvif_idx_unmap in this function which
is added in your first patch?

Wei.
