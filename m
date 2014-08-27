From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Sending undersized ARP packets with VXLAN L3 interface
Date: Wed, 27 Aug 2014 11:16:02 -0700
Message-ID: <53FE2062.8060907@hp.com>
References: <CAMYYbY79hOVA5b22-gmLJTNQwprdfwa_QxKqveuwNhJMcXv9tA@mail.gmail.com> <CAHA+R7Ok6K_9U6RCZkSLCuVXtFG4Zs60FQKFZMu-v2yK581hog@mail.gmail.com> <53FE1AC3.5030409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>,
	Cong Wang <cwang@twopensource.com>,
	Martin Rusko <martin.rusko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:32582 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932413AbaH0SQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 14:16:15 -0400
Received: from g5t1627.atlanta.hp.com (g5t1627.atlanta.hp.com [15.192.137.10])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id 2B124ACB7
	for <netdev@vger.kernel.org>; Wed, 27 Aug 2014 18:16:15 +0000 (UTC)
In-Reply-To: <53FE1AC3.5030409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/27/2014 10:52 AM, Vlad Yasevich wrote:
> I think vxlan needs something like this:
>
> From: Vladislav Yasevich <vyasevich@gmail.com>
> Date: Wed, 27 Aug 2014 13:39:32 -0400
> Subject: [PATCH] vxlan: Pad short ethernet frames.
>
> If sending short ethernet frames from the vxlan device, pad
> them to minimum size so they can be forwarded after decapsulation.
>
> Reported-by: Martin Rusko <martin.rusko@gmail.com>
> Signed-off-by: Vladislav Yasevich <vyasevich@gmail.com>
> ---
>   drivers/net/vxlan.c | 8 ++++++++
>   1 file changed, 8 insertions(+)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 1fb7b37..48267d4 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1939,6 +1939,14 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct
> net_device *dev)
>   #endif
>   	}
>
> +	/* Pad short frames so they can be forwarded after decapsulation */
> +	if (skb->len < ETH_ZLEN) {
> +		if (skb_pad(skb, ETH_ZLEN - skb->len))
> +			return NETDEV_TX_OK;
> +		skb->len = ETH_ZLEN;
> +		skb_set_tail_pointer(skb, ETH_ZLEN);
> +	}
> +
>   	f = vxlan_find_mac(vxlan, eth->h_dest);
>   	did_rsc = false;
>

It is perhaps putting a stripe on the bikeshed, but should that be an 
"unlikely" on the length check?  There seem to be examples both ways in 
the handful of physical drivers I've checked.

rick jones
