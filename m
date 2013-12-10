From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net v2] xen-netback: fix abuse of napi budget
Date: Tue, 10 Dec 2013 11:44:23 +0000
Message-ID: <1386675863.11925.60.camel@kazak.uk.xensource.com>
References: <1386674864-27703-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:20423 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab3LJLoZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 06:44:25 -0500
In-Reply-To: <1386674864-27703-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-10 at 11:27 +0000, Paul Durrant wrote:
> netback seemed to be somewhat confused about the napi budget parameter. The
> parameter is supposed to limit the number of skgs process in each poll, but

                                               skbs

> netback had this confused with grant operations.
> 
> This patch fixes that, properly limiting the work done in each poll. Note
> that this limit makes sure we do not process any more data from the shared
> ring than we intend to pass back from the poll. This is important to
> prevent tx_queue potentially growing without bound.
> 
> This patch also changes the RING_FINAL_CHECK_FOR_REQUESTS in
> xenvif_build_tx_gops to a check for RING_HAS_UNCONSUMED_REQUESTS as the
> former call has the side effect of advancing the ring event pointer and
> therefore inviting another interrupt from the frontend before the napi
> poll has actually finished, thereby defeating the point of napi.

Can you add a reminder of when/where the ring event pointer is
eventually advanced now please.

This seems like a slightly subtle change, especially when mixed in with
the budget handling changes. Please can we do it in a separate patch.

> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> ---
> v2:
> - More elaborate description of the problem and the fix in the comment.
> - Modified the check in xenvif_build_tx_gops.
> 
>  drivers/net/xen-netback/netback.c |   17 ++++++++---------
>  1 file changed, 8 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 43341b8..0c8ca76 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -1351,14 +1351,15 @@ static bool tx_credit_exceeded(struct xenvif *vif, unsigned size)
>  	return false;
>  }
>  
> -static unsigned xenvif_tx_build_gops(struct xenvif *vif)
> +static unsigned xenvif_tx_build_gops(struct xenvif *vif, int budget)
>  {
>  	struct gnttab_copy *gop = vif->tx_copy_ops, *request_gop;
>  	struct sk_buff *skb;
>  	int ret;
>  
>  	while ((nr_pending_reqs(vif) + XEN_NETBK_LEGACY_SLOTS_MAX
> -		< MAX_PENDING_REQS)) {
> +		< MAX_PENDING_REQS) &&
> +	       (skb_queue_len(&vif->tx_queue) < budget)) {
>  		struct xen_netif_tx_request txreq;
>  		struct xen_netif_tx_request txfrags[XEN_NETBK_LEGACY_SLOTS_MAX];
>  		struct page *page;
> @@ -1380,8 +1381,7 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif)
>  			continue;
>  		}
>  
> -		RING_FINAL_CHECK_FOR_REQUESTS(&vif->tx, work_to_do);

Is work_to_do now used uninitialised at various subsequent points? (in
your next reply you mentioned the decrease, but what about e.g. the call
to xenvif_get_extras?)

> -		if (!work_to_do)
> +		if (!RING_HAS_UNCONSUMED_REQUESTS(&vif->tx))
>  			break;
>  
>  		idx = vif->tx.req_cons;
> @@ -1520,14 +1520,13 @@ static unsigned xenvif_tx_build_gops(struct xenvif *vif)
>  }
>  
> 
> -static int xenvif_tx_submit(struct xenvif *vif, int budget)
> +static int xenvif_tx_submit(struct xenvif *vif)
>  {
>  	struct gnttab_copy *gop = vif->tx_copy_ops;
>  	struct sk_buff *skb;
>  	int work_done = 0;
>  
> -	while (work_done < budget &&
> -	       (skb = __skb_dequeue(&vif->tx_queue)) != NULL) {
> +	while ((skb = __skb_dequeue(&vif->tx_queue)) != NULL) {
>  		struct xen_netif_tx_request *txp;
>  		u16 pending_idx;
>  		unsigned data_len;
> @@ -1602,14 +1601,14 @@ int xenvif_tx_action(struct xenvif *vif, int budget)
>  	if (unlikely(!tx_work_todo(vif)))
>  		return 0;
>  
> -	nr_gops = xenvif_tx_build_gops(vif);
> +	nr_gops = xenvif_tx_build_gops(vif, budget);
>  
>  	if (nr_gops == 0)
>  		return 0;
>  
>  	gnttab_batch_copy(vif->tx_copy_ops, nr_gops);
>  
> -	work_done = xenvif_tx_submit(vif, nr_gops);
> +	work_done = xenvif_tx_submit(vif);
>  
>  	return work_done;
>  }
