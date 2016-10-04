From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH v2 net-next 5/7] xen-netback: process guest
 rx packets in batches
Date: Tue, 4 Oct 2016 08:47:44 -0400
Message-ID: <20161004124744.GC30836@localhost.localdomain>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
 <1475573358-32414-6-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        Wei Liu <wei.liu2@citrix.com>,
        David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45251 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753442AbcJDMrt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 08:47:49 -0400
Content-Disposition: inline
In-Reply-To: <1475573358-32414-6-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 04, 2016 at 10:29:16AM +0100, Paul Durrant wrote:
> From: David Vrabel <david.vrabel@citrix.com>
> 
> Instead of only placing one skb on the guest rx ring at a time, process
> a batch of up-to 64.  This improves performance by ~10% in some tests.

And does it regress latency workloads?

What are those 'some tests' you speak off?

Thanks.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> [re-based]
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> ---
> Cc: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/rx.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/rx.c b/drivers/net/xen-netback/rx.c
> index 9548709..ae822b8 100644
> --- a/drivers/net/xen-netback/rx.c
> +++ b/drivers/net/xen-netback/rx.c
> @@ -399,7 +399,7 @@ static void xenvif_rx_extra_slot(struct xenvif_queue *queue,
>  	BUG();
>  }
>  
> -void xenvif_rx_action(struct xenvif_queue *queue)
> +void xenvif_rx_skb(struct xenvif_queue *queue)
>  {
>  	struct xenvif_pkt_state pkt;
>  
> @@ -425,6 +425,19 @@ void xenvif_rx_action(struct xenvif_queue *queue)
>  	xenvif_rx_complete(queue, &pkt);
>  }
>  
> +#define RX_BATCH_SIZE 64
> +
> +void xenvif_rx_action(struct xenvif_queue *queue)
> +{
> +	unsigned int work_done = 0;
> +
> +	while (xenvif_rx_ring_slots_available(queue) &&
> +	       work_done < RX_BATCH_SIZE) {
> +		xenvif_rx_skb(queue);
> +		work_done++;
> +	}
> +}
> +
>  static bool xenvif_rx_queue_stalled(struct xenvif_queue *queue)
>  {
>  	RING_IDX prod, cons;
> -- 
> 2.1.4
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> https://lists.xen.org/xen-devel
