From: Simon Horman <horms@verge.net.au>
Subject: Re: [net-next PATCH 2/6] enic: Bug fix: try harder to fill Rx ring
 on skb allocation failures
Date: Sat, 19 Dec 2009 21:41:30 +1100
Message-ID: <20091219104128.GB20743@verge.net.au>
References: <20091219020758.2745.85264.stgit@savbu-pc100.cisco.com>
 <20091219020946.2745.7226.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:32955 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416AbZLSKlc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Dec 2009 05:41:32 -0500
Content-Disposition: inline
In-Reply-To: <20091219020946.2745.7226.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 18, 2009 at 06:09:46PM -0800, Scott Feldman wrote:
> enic: Bug fix: try harder to fill Rx ring on skb allocation failures
> 
> During probe(), make sure we get at least one skb on the Rx ring. 
> Otherwise abort the interface load.  Also, if we get skb allocation
> failures in NAPI poll while trying to replenish the ring, try again
> later so we don't end up starving out the Rx ring completely.
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> ---
>  drivers/net/enic/enic_main.c |   54 ++++++++++++++++++++++++++----------------
>  1 files changed, 33 insertions(+), 21 deletions(-)
> 
> diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
> index 496e8b6..0265b25 100644
> --- a/drivers/net/enic/enic_main.c
> +++ b/drivers/net/enic/enic_main.c
> @@ -1092,6 +1092,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
>  	unsigned int rq_work_to_do = budget;
>  	unsigned int wq_work_to_do = -1; /* no limit */
>  	unsigned int  work_done, rq_work_done, wq_work_done;
> +	int err;
>  
>  	/* Service RQ (first) and WQ
>  	 */
> @@ -1115,16 +1116,19 @@ static int enic_poll(struct napi_struct *napi, int budget)
>  			0 /* don't unmask intr */,
>  			0 /* don't reset intr timer */);
>  
> -	if (rq_work_done > 0) {
> +	err = vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
>  
> -		/* Replenish RQ
> -		 */
> +	/* Buffer allocation failed. Stay in polling
> +	 * mode so we can try to fill the ring again.
> +	 */
>  
> -		vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
> +	if (err)
> +		rq_work_done = rq_work_to_do;

Is it intentional for rq_work_done = rq_work_to_do to become the
return value?

>  
> -	} else {
> +	if (rq_work_done < rq_work_to_do) {
>  
> -		/* If no work done, flush all LROs and exit polling
> +		/* Some work done, but not enough to stay in polling,
> +		 * flush all LROs and exit polling
>  		 */
>  
>  		if (netdev->features & NETIF_F_LRO)
> @@ -1143,6 +1147,7 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
>  	struct net_device *netdev = enic->netdev;
>  	unsigned int work_to_do = budget;
>  	unsigned int work_done;
> +	int err;
>  
>  	/* Service RQ
>  	 */
> @@ -1150,25 +1155,30 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
>  	work_done = vnic_cq_service(&enic->cq[ENIC_CQ_RQ],
>  		work_to_do, enic_rq_service, NULL);
>  
> -	if (work_done > 0) {
> -
> -		/* Replenish RQ
> -		 */
> -
> -		vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
> -
> -		/* Return intr event credits for this polling
> -		 * cycle.  An intr event is the completion of a
> -		 * RQ packet.
> -		 */
> +	/* Return intr event credits for this polling
> +	 * cycle.  An intr event is the completion of a
> +	 * RQ packet.
> +	 */
>  
> +	if (work_done > 0)
>  		vnic_intr_return_credits(&enic->intr[ENIC_MSIX_RQ],
>  			work_done,
>  			0 /* don't unmask intr */,
>  			0 /* don't reset intr timer */);
> -	} else {
>  
> -		/* If no work done, flush all LROs and exit polling
> +	err = vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
> +
> +	/* Buffer allocation failed. Stay in polling mode
> +	 * so we can try to fill the ring again.
> +	 */
> +
> +	if (err)
> +		work_done = work_to_do;

Again, is it intended for this to be the return value of the function?

> +
> +	if (work_done < work_to_do) {
> +
> +		/* Some work done, but not enough to stay in polling,
> +		 * flush all LROs and exit polling
>  		 */
>  
>  		if (netdev->features & NETIF_F_LRO)
> @@ -1333,11 +1343,13 @@ static int enic_open(struct net_device *netdev)
>  	}
>  
>  	for (i = 0; i < enic->rq_count; i++) {
> -		err = vnic_rq_fill(&enic->rq[i], enic->rq_alloc_buf);
> -		if (err) {
> +		vnic_rq_fill(&enic->rq[i], enic->rq_alloc_buf);
> +		/* Need at least one buffer on ring to get going */
> +		if (vnic_rq_desc_used(&enic->rq[i]) == 0) {
>  			printk(KERN_ERR PFX
>  				"%s: Unable to alloc receive buffers.\n",
>  				netdev->name);
> +			err = -ENOMEM;
>  			goto err_out_notify_unset;
>  		}
>  	}

My brain may well have switched off for the day,
but its unclear to me how &enic->rq[i] could ever be NULL.

Also, in the case where a failure occurs for i > 0,
it it necessary to unwind the previous rq allocations?

