From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v2] ipvlan: fix crash when master is set in loopback
 mode
Date: Mon, 19 Dec 2016 06:37:18 -0800
Message-ID: <1482158238.1521.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1482087625-30366-1-git-send-email-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <maheshb@google.com>
To: Mahesh Bandewar <mahesh@bandewar.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35736 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755504AbcLSOhU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 09:37:20 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so18675527pga.2
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 06:37:20 -0800 (PST)
In-Reply-To: <1482087625-30366-1-git-send-email-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-12-18 at 11:00 -0800, Mahesh Bandewar wrote:
> From: Mahesh Bandewar <maheshb@google.com>
> 
> In an IPvlan setup when master is set in loopback mode e.g.
> 
>   ethtool -K eth0 set loopback on
> 
>   where eth0 is master device for IPvlan setup.
> 
> The failure actually happens while processing mulitcast packets
> but that's a result of unconditionally queueing packets without
> ensuring ether-header is part of the linear part of skb.
> 
> This patch forces this check at the reception and drops packets
> which fail this check before queuing them.
> 
> ------------[ cut here ]------------
> kernel BUG at include/linux/skbuff.h:1737!
> Call Trace:
>  [<ffffffff921fbbc2>] dev_forward_skb+0x92/0xd0
>  [<ffffffffc031ac65>] ipvlan_process_multicast+0x395/0x4c0 [ipvlan]
>  [<ffffffffc031a9a7>] ? ipvlan_process_multicast+0xd7/0x4c0 [ipvlan]
>  [<ffffffff91cdfea7>] ? process_one_work+0x147/0x660
>  [<ffffffff91cdff09>] process_one_work+0x1a9/0x660
>  [<ffffffff91cdfea7>] ? process_one_work+0x147/0x660
>  [<ffffffff91ce086d>] worker_thread+0x11d/0x360
>  [<ffffffff91ce0750>] ? rescuer_thread+0x350/0x350
>  [<ffffffff91ce960b>] kthread+0xdb/0xe0
>  [<ffffffff91c05c70>] ? _raw_spin_unlock_irq+0x30/0x50
>  [<ffffffff91ce9530>] ? flush_kthread_worker+0xc0/0xc0
>  [<ffffffff92348b7a>] ret_from_fork+0x9a/0xd0
>  [<ffffffff91ce9530>] ? flush_kthread_worker+0xc0/0xc0
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v1->v2: commit log update
> 
>  drivers/net/ipvlan/ipvlan_core.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
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
>  	case IPVLAN_MODE_L2:
>  		return ipvlan_handle_mode_l2(pskb, port);
> @@ -672,6 +675,8 @@ rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
>  	/* Should not reach here */
>  	WARN_ONCE(true, "ipvlan_handle_frame() called for mode = [%hx]\n",
>  			  port->mode);
> +
> +out:
>  	kfree_skb(skb);
>  	return RX_HANDLER_CONSUMED;
>  }


There is something funky here.

When rx_handler() is called, we must have pulled Ethernet header
already.

Is this because RX_HANDLER_ANOTHER is returned in some cases, while it
should not ?

It looks like you added a pskb_may_pull() at a wrong place. Sure it
might fix the crash, but it looks weird here.
