From: Boris Brezillon <boris.brezillon@free-electrons.com>
Subject: Re: [PATCH 1/4] net/macb: only probe queues once and use stored
 values
Date: Fri, 27 Mar 2015 23:36:04 +0100
Message-ID: <20150327233604.79dfdef3@bbrezillon>
References: <cover.1427469791.git.nicolas.ferre@atmel.com>
	<09960ba7389058e026b73409018fe1ee61d6dc57.1427469791.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	<monstr@monstr.eu>, <michal.simek@xilinx.com>, <punnaia@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:53154 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752684AbbC0WgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 18:36:09 -0400
In-Reply-To: <09960ba7389058e026b73409018fe1ee61d6dc57.1427469791.git.nicolas.ferre@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nicolas,

On Fri, 27 Mar 2015 16:34:09 +0100
Nicolas Ferre <nicolas.ferre@atmel.com> wrote:

> When merging at91_ether and macb driver during 421d9df0628b (net/macb: merge
> at91_ether driver into macb driver) the probe function has been split. The code
> dealing with initialization of queues is now moved in macb_init() which needs
> information computed in the parent macb_probe() function.
> So, add the queue_mask information to the private structure and use it when
> needed in macb_init().

Just to be sure: this is not a bug fix, right ?
It just improves the initialization process by calling
macb_probe_queues only once (in macb_probe).

Anyway, once you've addressed Cyrille's comment, you can add my

Acked-by: Boris Brezillon <boris.brezillon@free-electrons.com>

> 
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> Cc: Cyrille Pitchen <cyrille.pitchen@atmel.com>
> Cc: Boris Brezillon <boris.brezillon@free-electrons.com>
> ---
>  drivers/net/ethernet/cadence/macb.c | 9 ++++-----
>  drivers/net/ethernet/cadence/macb.h | 1 +
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index a0a04b3638e6..b710768172d9 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2180,7 +2180,7 @@ static void macb_probe_queues(void __iomem *mem,
>  static int macb_init(struct platform_device *pdev)
>  {
>  	struct net_device *dev = platform_get_drvdata(pdev);
> -	unsigned int hw_q, queue_mask, q, num_queues;
> +	unsigned int hw_q, q;
>  	struct macb *bp = netdev_priv(dev);
>  	struct macb_queue *queue;
>  	int err;
> @@ -2226,10 +2226,8 @@ static int macb_init(struct platform_device *pdev)
>  	 * register mapping but we don't want to test the queue index then
>  	 * compute the corresponding register offset at run time.
>  	 */
> -	macb_probe_queues(bp->regs, &queue_mask, &num_queues);
> -
> -	for (hw_q = 0, q = 0; hw_q < MACB_MAX_QUEUES; ++hw_q) {
> -		if (!(queue_mask & (1 << hw_q)))
> +	for (hw_q = 0, q = 0; hw_q < bp->num_queues; ++hw_q) {
> +		if (!(bp->queue_mask & (1 << hw_q)))
>  			continue;
>  
>  		queue = &bp->queues[q];
> @@ -2715,6 +2713,7 @@ static int macb_probe(struct platform_device *pdev)
>  	bp->dev = dev;
>  	bp->regs = mem;
>  	bp->num_queues = num_queues;
> +	bp->queue_mask = queue_mask;
>  	spin_lock_init(&bp->lock);
>  
>  	platform_set_drvdata(pdev, dev);
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index bc6e35c40822..0b6afac91bfe 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -785,6 +785,7 @@ struct macb {
>  	size_t			rx_buffer_size;
>  
>  	unsigned int		num_queues;
> +	unsigned int		queue_mask;
>  	struct macb_queue	queues[MACB_MAX_QUEUES];
>  
>  	spinlock_t		lock;



-- 
Boris Brezillon, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
