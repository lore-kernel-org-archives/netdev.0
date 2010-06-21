From: Eran Liberty <liberty@extricom.com>
Subject: Re: [PATCH] gainfar.c : skb_over_panic
Date: Mon, 21 Jun 2010 12:13:29 +0300
Message-ID: <4C1F2D39.9050804@extricom.com>
References: <4C1A4E36.5060902@extricom.com> <20100617.122030.112600189.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: galak@kernel.crashing.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.extricom.com ([212.235.17.194]:50401 "HELO
	smtp.extricom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with SMTP id S1753660Ab0FUJJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 05:09:59 -0400
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
David,

I have compared the suggested patch with what the function skb_recycle_check() does. Both patch and skb_recycle_check()
 have skb_reset_tail_pointer(). While the patch zero only skb->len, skb_recycle_check()
 clears the whole skb (up to tail). On top of that skb_recycle_check() preforms a whole set of other checks and cleanups. 
The question is, which action is MORE correct: the pin-point action of the patch suggested or the broader checks of skb_recycle_check() function?

-- Liberty

 
