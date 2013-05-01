From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next 2/2] xen-netback: avoid allocating variable
 size array on stack
Date: Wed, 1 May 2013 11:32:41 +0100
Message-ID: <1367404361.3142.686.camel@zakaz.uk.xensource.com>
References: <1367340644-19690-1-git-send-email-wei.liu2@citrix.com>
	 <1367340644-19690-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jbeulich@suse.com" <jbeulich@suse.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:41176 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753142Ab3EAKco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 06:32:44 -0400
In-Reply-To: <1367340644-19690-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-30 at 17:50 +0100, Wei Liu wrote:
> Tune xen_netbk_count_requests to not touch working array beyond limit, so that
> we can make working array size constant.

Is this really correct when max_skb_slots > XEN_NETIF_NR_SLOTS_MIN?
Seems like we would either overrun the array or drop frames which
max_skb_slots suggests we should accept?

If anything the array would need to be size by XEN_NETIF_NR_SLOTS_MAX
which a) doesn't exist and b) would be worse than using max_skb_slots. I
wouldn't be particularly averse to enforcing some sensible maximum on
max_skb_slots.

Other options:

Handle batches of work in <max_skb_slots sized bundles, but that gets
complex when you consider the case of an skb which crosses multiple such
bundles.

xen_netbk_get_requests() copes the tx req again into the pending_tx_info
-- any way we can arrange for this to just happen right in the first
place?

Or perhaps it is time for each vif to allocate a page of its own to
shadow the shared ring, and remove that field from pending_tx_info?
(which isn't really a net increase in memory usage, but might simplify
some things?)

One comment on the existing implementation below...

> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c |   26 +++++++++++++++++++++-----
>  1 file changed, 21 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index c44772d..c6dc084 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -934,11 +934,15 @@ static int netbk_count_requests(struct xenvif *vif,
>  	RING_IDX cons = vif->tx.req_cons;
>  	int slots = 0;
>  	int drop_err = 0;
> +	int keep_looping;
>  
>  	if (!(first->flags & XEN_NETTXF_more_data))
>  		return 0;
>  
>  	do {
> +		struct xen_netif_tx_request dropped_tx = { 0 };
> +		int cross_page = 0;
> +
>  		if (slots >= work_to_do) {
>  			netdev_err(vif->dev,
>  				   "Asked for %d slots but exceeds this limit\n",
> @@ -972,8 +976,12 @@ static int netbk_count_requests(struct xenvif *vif,
>  			drop_err = -E2BIG;
>  		}
>  
> -		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
> -		       sizeof(*txp));
> +		if (!drop_err)
> +			memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
> +			       sizeof(*txp));
> +		else
> +			memcpy(&dropped_tx, RING_GET_REQUEST(&vif->tx, cons + slots),
> +			       sizeof(dropped_tx));

Can we avoid needing to replicate if (!drop_err) txp else &dropped_tx
with a macro or some other trickery? e.g txp = &dropped_tx and then the
check is only on the txp++?

>  
>  		/* If the guest submitted a frame >= 64 KiB then
>  		 * first->size overflowed and following slots will
> @@ -995,13 +1003,21 @@ static int netbk_count_requests(struct xenvif *vif,
>  		first->size -= txp->size;
>  		slots++;
>  
> -		if (unlikely((txp->offset + txp->size) > PAGE_SIZE)) {
> +		if (!drop_err)
> +			cross_page = (txp->offset + txp->size) > PAGE_SIZE;
> +		else
> +			cross_page = (dropped_tx.offset + dropped_tx.size) > PAGE_SIZE;
> +
> +		if (unlikely(cross_page)) {
>  			netdev_err(vif->dev, "Cross page boundary, txp->offset: %x, size: %u\n",
>  				 txp->offset, txp->size);
>  			netbk_fatal_tx_err(vif);
>  			return -EINVAL;
>  		}
> -	} while ((txp++)->flags & XEN_NETTXF_more_data);
> +
> +		keep_looping = (!drop_err && (txp++)->flags & XEN_NETTXF_more_data) ||
> +			(dropped_tx.flags & XEN_NETTXF_more_data);
> +	} while (keep_looping);
>  
>  	if (drop_err) {
>  		netbk_tx_err(vif, first, cons + slots);
> @@ -1408,7 +1424,7 @@ static unsigned xen_netbk_tx_build_gops(struct xen_netbk *netbk)
>  		!list_empty(&netbk->net_schedule_list)) {
>  		struct xenvif *vif;
>  		struct xen_netif_tx_request txreq;
> -		struct xen_netif_tx_request txfrags[max_skb_slots];
> +		struct xen_netif_tx_request txfrags[XEN_NETIF_NR_SLOTS_MIN];
>  		struct page *page;
>  		struct xen_netif_extra_info extras[XEN_NETIF_EXTRA_TYPE_MAX-1];
>  		u16 pending_idx;
