From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net] xen-netback: fix vif tx queue race in xenvif_rx_interrupt
Date: Wed, 8 Jan 2014 21:18:59 +0000
Message-ID: <52CDC0C3.2080303@citrix.com>
References: <1389209061-29494-1-git-send-email-jieyue.majy@alibaba-inc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ma JieYue <jieyue.majy@alibaba-inc.com>,
	Wang Yingbin <yingbin.wangyb@alibaba-inc.com>,
	Fu Tienan <tienan.ftn@alibaba-inc.com>,
	"Wei Liu" <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	"David Vrabel" <david.vrabel@citrix.com>
To: Ma JieYue <majieyue@gmail.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53136 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757575AbaAHVTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jan 2014 16:19:10 -0500
In-Reply-To: <1389209061-29494-1-git-send-email-jieyue.majy@alibaba-inc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

With Paul's recent flow control improvement I think this became invalid:

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=ca2f09f2b2c6c25047cfc545d057c4edfcfe561c

Zoli

On 08/01/14 19:24, Ma JieYue wrote:
> From: Ma JieYue <jieyue.majy@alibaba-inc.com>
>
> There is a race when waking up or stopping xenvif tx queue, and it leads to
> unnecessary packet drop. The problem is that the rx ring still full when entering
> into xenvif_start_xmit. In fact, in xenvif_rx_interrupt, the netif_wake_queue
> may be called not just after the ring is not full any more, so the operation
> is not atomic. Here is part of the debug log when the race scenario happened:
>
> wake_queue: req_cons_peek 2679757 req_cons 2679586 req_prod 2679841
> stop_queue: req_cons_peek 2679837 req_cons 2679757 req_prod 2679841
> [tx_queue_stopped true]
> wake_queue: req_cons_peek 2679837 req_cons 2679757 req_prod 2679841
> [tx_queue_stopped false]
> drop packet: req_cons_peek 2679837 req_cons 2679757 req_prod 2679841
>
> The debug log was written, every time right after netif_wake_queue been called
> in xenvif_rx_interrupt, every time after netif_stop_queue been called in
> xenvif_start_xmit and every time packet drop happened in xenvif_start_xmit.
> As we can see, the second wake_queue appeared in the place it should not be, and
> we believed the ring had been checked before the stop_queue, but the actual
> wake_queue action didn't follow, and took place after the stop_queue, so that when
> entering into xenvif_start_xmit the ring was full but the queue was not stopped.
>
> The patch fixes the race by checking if tx queue stopped, before trying to
> wake it up in xenvif_rx_interrupt. It only wakes the queue when it is stopped,
> as well as it is not full and schedulable.
>
> Signed-off-by: Ma JieYue <jieyue.majy@alibaba-inc.com>
> Signed-off-by: Wang Yingbin <yingbin.wangyb@alibaba-inc.com>
> Signed-off-by: Fu Tienan <tienan.ftn@alibaba-inc.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> ---
>   drivers/net/xen-netback/interface.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index fff8cdd..e099f62 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -105,7 +105,7 @@ static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
>   {
>   	struct xenvif *vif = dev_id;
>
> -	if (xenvif_rx_schedulable(vif))
> +	if (netif_queue_stopped(vif->dev) && xenvif_rx_schedulable(vif))
>   		netif_wake_queue(vif->dev);
>
>   	return IRQ_HANDLED;
>
