From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net] amd-xgbe: Use wmb before updating current descriptor
 count
Date: Fri, 23 Oct 2015 09:29:44 -0700
Message-ID: <562A6078.9070709@gmail.com>
References: <20151021203705.29412.11836.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Christoffer Dall <christoffer.dall@linaro.org>
To: Tom Lendacky <thomas.lendacky@amd.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34050 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbbJWQ3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 12:29:46 -0400
Received: by padhk11 with SMTP id hk11so122567302pad.1
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 09:29:46 -0700 (PDT)
In-Reply-To: <20151021203705.29412.11836.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2015 01:37 PM, Tom Lendacky wrote:
> The code currently uses the lightweight dma_wmb barrier before updating
> the current descriptor count. Under heavy load, the Tx cleanup routine
> was seeing the updated current descriptor count before the updated
> descriptor information. As a result, the Tx descriptor was being cleaned
> up before it was used because it was not "owned" by the hardware yet,
> resulting in a Tx queue hang.
>
> Using the wmb barrier insures that the descriptor is updated before the
> descriptor counter preventing the Tx queue hang. For extra insurance,
> the Tx cleanup routine is changed to grab the current decriptor count on
> entry and uses that initial value in the processing loop rather than
> trying to chase the current value.
>
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> Tested-by: Christoffer Dall <christoffer.dall@linaro.org>

This shouldn't be using wmb() or dma_wmb().  It looks like you are just 
using the barriers to synchronize between CPUs.  If that is the case you 
should probably be using smp_wmb()/smp_rmb().

> ---
>   drivers/net/ethernet/amd/xgbe/xgbe-dev.c |    2 +-
>   drivers/net/ethernet/amd/xgbe/xgbe-drv.c |    4 +++-
>   2 files changed, 4 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
> index a4473d8..e9ab8b9 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
> @@ -1595,7 +1595,7 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
>   				  packet->rdesc_count, 1);
>   
>   	/* Make sure ownership is written to the descriptor */
> -	dma_wmb();
> +	wmb();
>   
>   	ring->cur = cur_index + 1;
>   	if (!packet->skb->xmit_more ||

If anything you could probably just replace it with an smp_wmb() since 
the device doesn't ever read the ring->cur value.  Using a wmb() here is 
just doing unnecessary harm to  your performance as you aren't dealing 
with multiple memory domains.

> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
> index aae9d5e..d2b77d9 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
> @@ -1807,6 +1807,7 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
>   	struct netdev_queue *txq;
>   	int processed = 0;
>   	unsigned int tx_packets = 0, tx_bytes = 0;
> +	unsigned int cur;
>   
>   	DBGPR("-->xgbe_tx_poll\n");
>   
> @@ -1814,10 +1815,11 @@ static int xgbe_tx_poll(struct xgbe_channel *channel)
>   	if (!ring)
>   		return 0;
>   
> +	cur = ring->cur;
>   	txq = netdev_get_tx_queue(netdev, channel->queue_index);
>   
>   	while ((processed < XGBE_TX_DESC_MAX_PROC) &&
> -	       (ring->dirty != ring->cur)) {
> +	       (ring->dirty != cur)) {
>   		rdata = XGBE_GET_DESC_DATA(ring, ring->dirty);
>   		rdesc = rdata->rdesc;
>   
>

I believe your bug is down here.  You likely need an smp_rmb() between 
the read of ring->cur and rdata.  Otherwise there is nothing to prevent 
the compiler from reordering this so that it reads the descriptor data 
ahead of ring->cur.

Moving the read out of the loop likely resolves the issue as it becomes 
harder for the compiler to optimize the read versus the code in the 
loop.  You may want to just try reverting this patch and starting the 
loop with a smp_rmb() here and replace the dma_wmb() with an smp_wmb() 
above and you should see the race between the interrupt routine and the 
transmit path resolved as I believe the current fix is still a bit racy.

- Alex
