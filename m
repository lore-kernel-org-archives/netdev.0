From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipvlan: fix crash
Date: Sat, 17 Dec 2016 23:54:52 -0500 (EST)
Message-ID: <20161217.235452.1604434909844387069.davem@davemloft.net>
References: <1482027379-30785-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932260AbcLREy4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 23:54:56 -0500
In-Reply-To: <1482027379-30785-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Sat, 17 Dec 2016 18:16:19 -0800

> diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
> index b4e990743e1d..4294fc1f5564 100644
> --- a/drivers/net/ipvlan/ipvlan_core.c
> +++ b/drivers/net/ipvlan/ipvlan_core.c
> @@ -660,6 +660,9 @@ rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
>  	if (!port)
>  		return RX_HANDLER_PASS;
>  
> +	if (unlikely(!pskb_may_pull(skb, sizeof(struct ethhdr))))
> +		goto out;
> +
>  	switch (port->mode) {

ipvlan only allows non-loopback ethernet devices to register
this RX handler.

Such situations being tested here should therefore be completely
impossible.

Every such device must send the SKB through eth_type_trans(), which
unconditionally accesses the ethernet header, therefore it must
be pulled into the linear SKB area already, long before this RX
handler is invoked.

If this really can legitimately happen, you must explain how so.

Just showing the crash that later happens in some (completely
unrelated BTW) ipvlan multicast workqueue handling function, is
really an insufficient commit log message for a bug like this.
