From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH CFT 12/30] net: fec: ensure fec_enet_free_buffers() properly
 cleans the rings
Date: Fri, 27 Jun 2014 22:48:42 +0400
Message-ID: <53ADBC8A.8070103@cogentembedded.com>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk> <E1X0XwQ-0001Na-Kg@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Fugang Duan <B38611@freescale.com>
To: Russell King <rmk+kernel@arm.linux.org.uk>,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:39466 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbaF0Ssb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 14:48:31 -0400
Received: by mail-lb0-f171.google.com with SMTP id s7so4318234lbd.16
        for <netdev@vger.kernel.org>; Fri, 27 Jun 2014 11:48:29 -0700 (PDT)
In-Reply-To: <E1X0XwQ-0001Na-Kg@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/27/2014 07:19 PM, Russell King wrote:

> Ensure that we do not double-free any allocations, and that any transmit
> skbuffs are properly freed when we clean up the rings.

> Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
> ---
>   drivers/net/ethernet/freescale/fec_main.c | 8 +++++++-
>   1 file changed, 7 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 9c5570a3e32e..8024b7a8e7f4 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -2079,8 +2079,14 @@ static void fec_enet_free_buffers(struct net_device *ndev)
>   	}
>
>   	bdp = fep->tx_bd_base;
> -	for (i = 0; i < fep->tx_ring_size; i++)
> +	for (i = 0; i < fep->tx_ring_size; i++) {
>   		kfree(fep->tx_bounce[i]);
> +		fep->tx_bounce[i] = NULL;
> +		skb = fep->tx_skbuff[i];
> +		fep->tx_skbuff[i] = NULL;
> +		if (skb)
> +			dev_kfree_skb(skb);

    dev_kfree_skb() (actually, consume_skb() that it calls) already checks 
'skb' for NULL.

WBR, Sergei
