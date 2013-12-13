From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 6/9] xen-netback: Handle guests with too many
 frags
Date: Fri, 13 Dec 2013 15:43:07 +0000
Message-ID: <20131213154307.GN21900@zion.uk.xensource.com>
References: <1386892097-15502-1-git-send-email-zoltan.kiss@citrix.com>
 <1386892097-15502-7-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1386892097-15502-7-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 12, 2013 at 11:48:14PM +0000, Zoltan Kiss wrote:
> Xen network protocol had implicit dependency on MAX_SKB_FRAGS. Netback has to
> handle guests sending up to XEN_NETBK_LEGACY_SLOTS_MAX slots. To achieve that:
> - create a new skb
> - map the leftover slots to its frags (no linear buffer here!)
> - chain it to the previous through skb_shinfo(skb)->frag_list
> - map them
> - copy the whole stuff into a brand new skb and send it to the stack
> - unmap the 2 old skb's pages
> 

Do you see performance regression with this approach?

> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> 
> ---
>  drivers/net/xen-netback/netback.c |   99 +++++++++++++++++++++++++++++++++++--
>  1 file changed, 94 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index e26cdda..f6ed1c8 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -906,11 +906,15 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
>  	u16 pending_idx = *((u16 *)skb->data);
>  	int start;
>  	pending_ring_idx_t index;
> -	unsigned int nr_slots;
> +	unsigned int nr_slots, frag_overflow = 0;
>  
>  	/* At this point shinfo->nr_frags is in fact the number of
>  	 * slots, which can be as large as XEN_NETBK_LEGACY_SLOTS_MAX.
>  	 */
> +	if (shinfo->nr_frags > MAX_SKB_FRAGS) {
> +		frag_overflow = shinfo->nr_frags - MAX_SKB_FRAGS;
> +		shinfo->nr_frags = MAX_SKB_FRAGS;
> +	}
>  	nr_slots = shinfo->nr_frags;
>  

It is also probably better to check whether shinfo->nr_frags is too
large which makes frag_overflow > MAX_SKB_FRAGS. I know skb should be
already be valid at this point but it wouldn't hurt to be more careful.

>  	/* Skip first skb fragment if it is on same page as header fragment. */
> @@ -926,6 +930,33 @@ static struct gnttab_map_grant_ref *xenvif_get_requests(struct xenvif *vif,
>  
>  	BUG_ON(shinfo->nr_frags > MAX_SKB_FRAGS);
>  
> +	if (frag_overflow) {
> +		struct sk_buff *nskb = alloc_skb(NET_SKB_PAD + NET_IP_ALIGN,
> +				GFP_ATOMIC | __GFP_NOWARN);
> +		if (unlikely(nskb == NULL)) {
> +			netdev_err(vif->dev,
> +				   "Can't allocate the frag_list skb.\n");
> +			return NULL;
> +		}
> +
> +		/* Packets passed to netif_rx() must have some headroom. */
> +		skb_reserve(nskb, NET_SKB_PAD + NET_IP_ALIGN);
> +

The code to call alloc_skb and skb_reserve is copied from other
location. I would like to have a dedicated function to allocate skb in
netback if possible.

Wei.
