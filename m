From: Eran Liberty <liberty@extricom.com>
Subject: Re: [PATCH] gainfar.c : skb_over_panic
Date: Wed, 23 Jun 2010 18:03:16 +0300
Message-ID: <4C222234.60903@extricom.com>
References: <4C1A4E36.5060902@extricom.com> <20100617.122030.112600189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.extricom.com ([192.114.46.18]:56829 "HELO
	smtp.extricom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753335Ab0FWPGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 11:06:44 -0400
In-Reply-To: <20100617.122030.112600189.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Eran Liberty <liberty@extricom.com>
> Date: Thu, 17 Jun 2010 19:32:54 +0300
>
>   
>> I have demonstrated skb_over_panic with linux 2.6.32.15 on a mpc8548
>> based product.
>>     
>
> A fix for a similar bug was necessary for the ucc_geth driver,
> see below.
>
> The real problem is that skb->data assignment, the rest of the
> SKB state has to be reset, and not doing that is what results in
> the skb_over_panic calls.
>
> >From db176edc89abbf22e6db6853f8581f9475fe8ec1 Mon Sep 17 00:00:00 2001
> From: Sergey Matyukevich <geomatsi@gmail.com>
> Date: Mon, 14 Jun 2010 06:35:20 +0000
> Subject: [PATCH] ucc_geth: fix for RX skb buffers recycling
>
> This patch implements a proper modification of RX skb buffers before
> recycling. Adjusting only skb->data is not enough because after that
> skb->tail and skb->len become incorrect.
>
> Signed-off-by: Sergey Matyukevich <geomatsi@gmail.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  drivers/net/ucc_geth.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
> index 4a34833..807470e 100644
> --- a/drivers/net/ucc_geth.c
> +++ b/drivers/net/ucc_geth.c
> @@ -3215,6 +3215,8 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
>  					   __func__, __LINE__, (u32) skb);
>  			if (skb) {
>  				skb->data = skb->head + NET_SKB_PAD;
> +				skb->len = 0;
> +				skb_reset_tail_pointer(skb);
>  				__skb_queue_head(&ugeth->rx_recycle, skb);
>  			}
>  
>   
When I do go via this code this patch helps. But, I have managed to
reach the skb_over_panic without going first via __skb_queue_head()
which render this patch useless... So I am investigating this before
suggesting any patch.

doing something like this:
                if (unlikely(skb->tail + pkt_len > skb->end)) {
                    pr_err("gfar_clean_rx_ring():  skb_over_panic event avoided\n");
                    dev_kfree_skb_any(skb);
                } else {
                    skb_put(skb, pkt_len);
                    dev->stats.rx_bytes += pkt_len;

                    if (in_irq() || irqs_disabled())
                        printk("Interrupt problem!\n");
                    gfar_process_frame(dev, skb, amount_pull);
                }

successfully avoids the skb_over_panic(), But I rather find the offending skb creator then continuously defend against its arrival.

-- Liberty


