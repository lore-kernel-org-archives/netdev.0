From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] Check for skb_put_padto return value
Date: Mon, 08 May 2017 15:03:54 -0400 (EDT)
Message-ID: <20170508.150354.183149674519514018.davem@davemloft.net>
References: <0102015be3e8a656-6cd75d31-ac07-4255-80d9-3c481165dfaa-000000@eu-west-1.amazonses.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mail@pheise.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751750AbdEHTDz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 8 May 2017 15:03:55 -0400
In-Reply-To: <0102015be3e8a656-6cd75d31-ac07-4255-80d9-3c481165dfaa-000000@eu-west-1.amazonses.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Heise <mail@pheise.de>
Date: Sun, 7 May 2017 17:15:26 +0000

> Return value of skb_put_padto is now checked as
> reported by Dan Carpenter. skb might be freed in
> case of error in skb_put_padto.
> ---
>  net/hsr/hsr_device.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
> index c73160fb11e7..a1545d09a3c9 100644
> --- a/net/hsr/hsr_device.c
> +++ b/net/hsr/hsr_device.c
> @@ -314,7 +314,8 @@ static void send_hsr_supervision_frame(struct hsr_port *master,
>  	hsr_sp = (typeof(hsr_sp)) skb_put(skb, sizeof(struct hsr_sup_payload));
>  	ether_addr_copy(hsr_sp->MacAddressA, master->dev->dev_addr);
>  
> -	skb_put_padto(skb, ETH_ZLEN + HSR_HLEN);
> +	if (skb_put_padto(skb, ETH_ZLEN + HSR_HLEN))
> +		return;
>  
>  	hsr_forward_skb(skb, master);
>  	return;

You're adding a more serious bug than the one you are fixing.

Now, if skb_put_padto() fails, we leak the SKB.
