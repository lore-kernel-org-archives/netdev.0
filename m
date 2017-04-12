From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,1/3] hv_netvsc: Use per socket hash when
 available
Date: Tue, 11 Apr 2017 22:12:41 -0400 (EDT)
Message-ID: <20170411.221241.2175639910931847215.davem@davemloft.net>
References: <1491699241-9944-1-git-send-email-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751951AbdDLCMn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 22:12:43 -0400
In-Reply-To: <1491699241-9944-1-git-send-email-haiyangz@exchange.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Sat,  8 Apr 2017 17:53:59 -0700

> diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
> index f24c289..0a129cb 100644
> --- a/drivers/net/hyperv/netvsc_drv.c
> +++ b/drivers/net/hyperv/netvsc_drv.c
> @@ -211,9 +211,14 @@ static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
>  	int q_idx = sk_tx_queue_get(sk);
>  
>  	if (q_idx < 0 || skb->ooo_okay || q_idx >= num_tx_queues) {
> -		u16 hash = __skb_tx_hash(ndev, skb, VRSS_SEND_TAB_SIZE);
> +		u16 hash;
>  		int new_idx;
>  
> +		if (sk)
> +			skb_set_hash_from_sk(skb, sk);
> +
> +		hash = __skb_tx_hash(ndev, skb, VRSS_SEND_TAB_SIZE);

Please do not do this.

TCP performs this operation for you for every pack it emits.

And also every socket family that uses skb_set_owner_w() either
directly or indirectly gets this done as well.

I do not want to see drivers start to get peppered with calls to this
thing.

Explain the case which is missing that matters, and we can address
that instead.

Thanks.
