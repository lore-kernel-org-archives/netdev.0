From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: errors in alignment changes..
Date: Thu, 11 Dec 2014 01:08:07 +0300
Message-ID: <5488C447.5080906@cogentembedded.com>
References: <20141210.155203.1136471667049608187.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, mitsuhiro.kimura.kc@renesas.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:54735 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbaLJWIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 17:08:12 -0500
Received: by mail-lb0-f171.google.com with SMTP id n15so3167686lbi.30
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 14:08:10 -0800 (PST)
In-Reply-To: <20141210.155203.1136471667049608187.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2014 11:52 PM, David Miller wrote:

> I just re-reviewed this change:

> commit 4d6a949c62f123569fb355b6ec7f314b76f93735
> Author: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> Date:   Thu Nov 27 20:34:00 2014 +0900

>      sh_eth: Fix skb alloc size and alignment adjust rule.

> and it has serious problems.  Well, actually the code has
> always been broken in this area.
>
> +		/* The size of the buffer is a multiple of 16 bytes. */
> +		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
> +		dma_map_single(&ndev->dev, skb->data, rxdesc->buffer_length,
> +			       DMA_FROM_DEVICE);
>   		rxdesc->addr = virt_to_phys(PTR_ALIGN(skb->data, 4));
>   		rxdesc->status = cpu_to_edmac(mdp, RD_RACT | RD_RFP);

> It doesn't make any sense to call dma_map_single() if you aren't
> even going to use the return value.  The DMA mapping created is
> the whole point of calling this function.

    Note that this call is just moved from above, not added by this patch.

> And then later we pass:

>   			dma_sync_single_for_cpu(&ndev->dev, rxdesc->addr,
> -						mdp->rx_buf_sz,
> +						ALIGN(mdp->rx_buf_sz, 16),
>   						DMA_FROM_DEVICE);

> rxdesc->addr as the "DMA address", but that must be the return value
> from dma_map_single() not what you've actually stored there which is
> virt_to_phys() run on the skb->data.

> This code must be fixed to:

> 1) Put the return value from dma_map_single() into a local variable,

    I have already requested such change in reply to the patch fixing several 
DMA errors at once.

>     and check for mapping errors.

    This was done by that patch IIRC. It just needs to be properly split and 
resubmitted.

> 2) On success put that return value into rxdesc->addr

    I guess we can just do:

		rxdesc->addr = dma_map_single(...);

WBR, Sergei
