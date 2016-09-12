From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] e1000: Send XDP_TX packets using dev_queue_xmit
Date: Mon, 12 Sep 2016 09:36:45 -0700
Message-ID: <1473698205.18970.78.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473697270-3906793-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        john.fastabend@gmail.com, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33104 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751882AbcILQgs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Sep 2016 12:36:48 -0400
Received: by mail-pf0-f195.google.com with SMTP id 128so8323122pfb.0
        for <netdev@vger.kernel.org>; Mon, 12 Sep 2016 09:36:47 -0700 (PDT)
In-Reply-To: <1473697270-3906793-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-12 at 09:21 -0700, Tom Herbert wrote:
> In order to use XDP with non multi-queue drivers (such as e1000) we need
> a method to handle XDP_TX return code from xdp program. Since there is
> only one queue the XDP transmit path needs to share that queue with the
> normal stack path, and in order to do that we can't break the existing
> stack's mechanisms of locking, qdiscs, and BQL for the queue.
> 
> This patch allocates an skbuff when XDP_TX is returned from the XDP
> program and call dev_queue_xmit to transmit the skbuff.
> 
> Note that this is expected to be a performance hit (which needs to be
> quantified) relative to a MQ XDP implementation where we can reserve
> queues to be used by XDP. The first intent of these patches is
> correctness. This should not affect performance in the XDP_DROP path.
> 
> This patch needs to be applied after "e1000: add initial XDP support".
> 
> Tested: I've only built this, need to see if I can find some e1000
> machines. John, if you could try this that would be much appreciated.
> 
> Signed-off-by: Tom Herbert <tom@herbertland.com>
> ---
>  drivers/net/ethernet/intel/e1000/e1000_main.c | 29 ++++++++++++++++++++-------
>  1 file changed, 22 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> index 91d5c87..f457ea8 100644
> --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> @@ -4338,13 +4338,28 @@ static bool e1000_clean_jumbo_rx_irq(struct e1000_adapter *adapter,
>  			case XDP_PASS:
>  				break;
>  			case XDP_TX:
> -				dma_sync_single_for_device(&pdev->dev,
> -							   dma,
> -							   length,
> -							   DMA_TO_DEVICE);
> -				e1000_xmit_raw_frame(buffer_info, length,
> -						     netdev, adapter);
> -				buffer_info->rxbuf.page = NULL;
> +				/* There is only one transmit queue so we need
> +				 * to inject the packet at the qdisc layer
> +				 * to maintain sanity in the stack. We allocate
> +				 * an skbuff, set up frags with the page, and
> +				 * then do dev_queue_xmit.
> +				 */
> +				skb = alloc_skb(0, GFP_ATOMIC);
> +				if (skb) {
> +					dma_unmap_page(&pdev->dev,
> +						       buffer_info->dma,
> +						       adapter->rx_buffer_len,
> +						       DMA_FROM_DEVICE);
> +					skb->dev = netdev;
> +					skb_fill_page_desc(skb, 0,
> +						buffer_info->rxbuf.page,
> +						0, length);
> +					dev_queue_xmit(skb);
> +					goto next_desc;
> +				}
> +				/* Fallthrough, if we are unable to handle
> +				 * XDP_TX then we need to drop.
> +				 */
>  			case XDP_DROP:
>  			default:
>  				/* re-use mapped page. keep buffer_info->dma

If the intent is correctness, then you'll need to populate skb->len and
skb->data_len.

Also many drivers assume some headers are in skb->head.

e1000 seems to assume skb_headlen() can not be 0
