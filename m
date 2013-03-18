From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH 4/4] xen-netback: coalesce slots before copying
Date: Mon, 18 Mar 2013 12:07:42 +0000
Message-ID: <1363608462.30193.34.camel@zakaz.uk.xensource.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
	 <1363602955-24790-5-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"annie.li@oracle.com" <annie.li@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([46.33.159.39]:37384 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129Ab3CRMHp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 08:07:45 -0400
In-Reply-To: <1363602955-24790-5-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-03-18 at 10:35 +0000, Wei Liu wrote:
> This patch tries to coalesce tx requests when constructing grant copy
> structures. It enables netback to deal with situation when frontend's
> MAX_SKB_FRAGS is larger than backend's MAX_SKB_FRAGS.
> 
> It defines max_skb_slots, which is a estimation of the maximum number of slots
> a guest can send, anything bigger than that is considered malicious. Now it is
> set to 20, which should be enough to accommodate Linux (16 to 19) and possibly
> Windows (19?).
> 
> Also change variable name from "frags" to "slots" in netbk_count_requests.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/netback.c |  204 ++++++++++++++++++++++++++++---------
>  1 file changed, 157 insertions(+), 47 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 6e8e51a..d7bbce9 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -47,9 +47,20 @@
>  #include <asm/xen/hypercall.h>
>  #include <asm/xen/page.h>
>  
> +/*
> + * This is an estimation of the maximum possible frags a SKB might
> + * have, anything larger than this is considered malicious. Typically
> + * Linux has 16 to 19, Windows has 19(?).
> + */
> +#define MAX_SKB_SLOTS_DEFAULT 20
> +static unsigned int max_skb_slots = MAX_SKB_SLOTS_DEFAULT;
> +module_param(max_skb_slots, uint, 0444);
> +
>  struct pending_tx_info {
> -	struct xen_netif_tx_request req;
> +	struct xen_netif_tx_request req; /* coalesced tx request  */
>  	struct xenvif *vif;
> +	unsigned int nr_tx_req; /* how many tx req we have in a chain (>=1) */
> +	unsigned int start_idx; /* starting index of pending ring index */

This one should be a RING_IDX I think, not an unsigned int.

>  };
>  typedef unsigned int pending_ring_idx_t;
>  
> @@ -251,7 +262,7 @@ static int max_required_rx_slots(struct xenvif *vif)
>  	int max = DIV_ROUND_UP(vif->dev->mtu, PAGE_SIZE);
>  
>  	if (vif->can_sg || vif->gso || vif->gso_prefix)
> -		max += MAX_SKB_FRAGS + 1; /* extra_info + frags */
> +		max += max_skb_slots + 1; /* extra_info + frags */
>  
>  	return max;
>  }
> @@ -657,7 +668,7 @@ static void xen_netbk_rx_action(struct xen_netbk *netbk)
>  		__skb_queue_tail(&rxq, skb);
>  
>  		/* Filled the batch queue? */
> -		if (count + MAX_SKB_FRAGS >= XEN_NETIF_RX_RING_SIZE)
> +		if (count + max_skb_slots >= XEN_NETIF_RX_RING_SIZE)
>  			break;
>  	}
>  
> @@ -908,34 +919,34 @@ static int netbk_count_requests(struct xenvif *vif,
>  				int work_to_do)
>  {
>  	RING_IDX cons = vif->tx.req_cons;
> -	int frags = 0;
> +	int slots = 0;
>  
>  	if (!(first->flags & XEN_NETTXF_more_data))
>  		return 0;
>  
>  	do {
> -		if (frags >= work_to_do) {
> -			netdev_err(vif->dev, "Need more frags\n");
> +		if (slots >= work_to_do) {
> +			netdev_err(vif->dev, "Need more slots\n");
>  			netbk_fatal_tx_err(vif);
>  			return -ENODATA;
>  		}
>  
> -		if (unlikely(frags >= MAX_SKB_FRAGS)) {
> -			netdev_err(vif->dev, "Too many frags\n");
> +		if (unlikely(slots >= max_skb_slots)) {
> +			netdev_err(vif->dev, "Too many slots\n");
>  			netbk_fatal_tx_err(vif);
>  			return -E2BIG;
>  		}
>  
> -		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + frags),
> +		memcpy(txp, RING_GET_REQUEST(&vif->tx, cons + slots),
>  		       sizeof(*txp));
>  		if (txp->size > first->size) {
> -			netdev_err(vif->dev, "Frag is bigger than frame.\n");
> +			netdev_err(vif->dev, "Packet is bigger than frame.\n");
>  			netbk_fatal_tx_err(vif);
>  			return -EIO;
>  		}
>  
>  		first->size -= txp->size;
> -		frags++;
> +		slots++;
>  
>  		if (unlikely((txp->offset + txp->size) > PAGE_SIZE)) {
>  			netdev_err(vif->dev, "txp->offset: %x, size: %u\n",
> @@ -944,7 +955,7 @@ static int netbk_count_requests(struct xenvif *vif,
>  			return -EINVAL;
>  		}
>  	} while ((txp++)->flags & XEN_NETTXF_more_data);
> -	return frags;
> +	return slots;
>  }
>  
>  static struct page *xen_netbk_alloc_page(struct xen_netbk *netbk,
> @@ -968,48 +979,120 @@ static struct gnttab_copy *xen_netbk_get_requests(struct xen_netbk *netbk,
>  	struct skb_shared_info *shinfo = skb_shinfo(skb);
>  	skb_frag_t *frags = shinfo->frags;
>  	u16 pending_idx = *((u16 *)skb->data);
> -	int i, start;
> +	u16 head_idx = 0;
> +	int slot, start;
> +	struct page *page;
> +	pending_ring_idx_t index;
> +	uint16_t dst_offset;
> +	unsigned int nr_slots;
> +	struct pending_tx_info *first = NULL;
> +	int nr_txp;
> +	unsigned int start_idx = 0;
> +
> +	/* At this point shinfo->nr_frags is in fact the number of
> +	 * slots, which can be as large as max_skb_slots.
> +	 */
> +	nr_slots = shinfo->nr_frags;
>  
>  	/* Skip first skb fragment if it is on same page as header fragment. */
>  	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
>  
> -	for (i = start; i < shinfo->nr_frags; i++, txp++) {
> -		struct page *page;
> -		pending_ring_idx_t index;
> +	/* Coalesce tx requests, at this point the packet passed in
> +	 * should be <= 64K. Any packets larger than 64K has been
> +	 * dropped / caused fatal error early on.

Whereabouts is this? Since the size field is u16 how do we even detect
this case. Since (at least prior to your other fix in this series) it
would have overflowed when the guest constructed the request.


> @@ -1025,6 +1108,7 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
>  	struct gnttab_copy *gop = *gopp;
>  	u16 pending_idx = *((u16 *)skb->data);
>  	struct skb_shared_info *shinfo = skb_shinfo(skb);
> +	struct pending_tx_info *tx_info;
>  	int nr_frags = shinfo->nr_frags;
>  	int i, err, start;
>  
> @@ -1037,12 +1121,17 @@ static int xen_netbk_tx_check_gop(struct xen_netbk *netbk,
>  	start = (frag_get_pending_idx(&shinfo->frags[0]) == pending_idx);
>  
>  	for (i = start; i < nr_frags; i++) {
> -		int j, newerr;
> +		int j, newerr = 0, n;
>  
>  		pending_idx = frag_get_pending_idx(&shinfo->frags[i]);
> +		tx_info = &netbk->pending_tx_info[pending_idx];
>  
>  		/* Check error status: if okay then remember grant handle. */
> -		newerr = (++gop)->status;
> +		for (n = 0; n < tx_info->nr_tx_req; n++) {
struct pending_tx_info is used in some arrays which can have a fair few
elements so if there are ways to reduce the size that is worth
considering I think.

So rather than storing both nr_tx_req and start_idx can we just store
start_idx and loop while start_idx != 0 (where the first one has
start_idx == zero)?

This might fall out more naturally if you were to instead store next_idx
in each pending tx with a suitable terminator at the end? Or could be
last_idx if it is convenient to count that way round, you don't need to
respond in-order.

Ian.
