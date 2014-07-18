From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net 1/4] xen-netback: Fix handling frag_list on grant op
 error path
Date: Fri, 18 Jul 2014 16:24:35 +0100
Message-ID: <20140718152435.GN7142@zion.uk.xensource.com>
References: <1405624192-21722-1-git-send-email-zoltan.kiss@citrix.com>
 <1405624192-21722-2-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1405624192-21722-2-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 17, 2014 at 08:09:49PM +0100, Zoltan Kiss wrote:
> The error handling for skb's with frag_list was completely wrong, it caused
> double unmap attempts to happen if the error was on the first skb. Move it to
> the right place in the loop.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Reported-by: Armin Zentai <armin.zentai@ezit.hu>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: xen-devel@lists.xenproject.org
> ---
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 1844a47..604ff71 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1030,10 +1030,16 @@ static int xenvif_tx_check_gop(struct xenvif_queue *queue,
>  {
>  	struct gnttab_map_grant_ref *gop_map = *gopp_map;
>  	u16 pending_idx = XENVIF_TX_CB(skb)->pending_idx;
> +	/* This points to the shinfo of the actually checked skb, which could be
> +	 * either the first or the one on the frag_list
> +	 */

I think "checked skb" should be "skb being checked". Feel free to
disagree as I'm not native English speaker. :-/

>  	struct skb_shared_info *shinfo = skb_shinfo(skb);
> +	/* If this is non-NULL, we are currently checking the frag_list skb, and
> +	 * this points to the shinfo of the first one
> +	 */
> +	struct skb_shared_info *first_shinfo = NULL;
>  	int nr_frags = shinfo->nr_frags;
>  	int i, err;
> -	struct sk_buff *first_skb = NULL;
>  
>  	/* Check status of header. */
>  	err = (*gopp_copy)->status;
> @@ -1086,31 +1092,28 @@ check_frags:
>  			xenvif_idx_unmap(queue, pending_idx);
>  		}
>  
> +		/* And if we found the error while checking the frag_list, unmap
> +		 * the first skb's frags
> +		 */
> +		if (first_shinfo) {
> +			for (j = 0; j < first_shinfo->nr_frags; j++) {
> +				pending_idx = frag_get_pending_idx(&first_shinfo->frags[j]);
> +				xenvif_idx_unmap(queue, pending_idx);
> +			}
> +		}
> +
>  		/* Remember the error: invalidate all subsequent fragments. */
>  		err = newerr;
>  	}
>  
> -	if (skb_has_frag_list(skb)) {
> -		first_skb = skb;
> -		skb = shinfo->frag_list;
> -		shinfo = skb_shinfo(skb);
> +	if (skb_has_frag_list(skb) && !first_shinfo) {

Will it ever come to the point that we have another skb in this skb's
frag list? Is there any reason prevents you from looping over the
(possible) subsequent skbs? I guess if the error is deep in the list
it's a bit hard to bookkeep...

> +		first_shinfo = skb_shinfo(skb);
> +		shinfo = skb_shinfo(skb_shinfo(skb)->frag_list);

In that case I would suggest you add
BUG_ON(skb_has_frag_list(skb_shinfo(skb)->frag_list)). I think having
more nested frag_list should be a bug in current design.

Wei.
