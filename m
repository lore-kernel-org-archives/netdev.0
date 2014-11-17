From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] enic: support skb->xmit_more
Date: Sun, 16 Nov 2014 21:40:23 -0800
Message-ID: <1416202823.24093.8.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416179042-1858-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:41396 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044AbaKQFkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 00:40:20 -0500
Received: by mail-ig0-f180.google.com with SMTP id h15so4597237igd.7
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 21:40:19 -0800 (PST)
In-Reply-To: <1416179042-1858-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-17 at 04:34 +0530, Govindarajulu Varadarajan wrote:
> Update posted_index only when skb->xmit_more is 0 or tx queue is full.
> 
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>  drivers/net/ethernet/cisco/enic/enic_main.c |  8 ++++++--
>  drivers/net/ethernet/cisco/enic/vnic_wq.h   | 20 +++++++++++---------
>  2 files changed, 17 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
> index 5afe360..52bccfd 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
> @@ -533,6 +533,7 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
>  	struct vnic_wq *wq;
>  	unsigned long flags;
>  	unsigned int txq_map;
> +	struct netdev_queue *txq;
>  
>  	if (skb->len <= 0) {
>  		dev_kfree_skb_any(skb);
> @@ -541,6 +542,7 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
>  
>  	txq_map = skb_get_queue_mapping(skb) % enic->wq_count;
>  	wq = &enic->wq[txq_map];
> +	txq = netdev_get_tx_queue(netdev, skb_get_queue_mapping(skb));
>  

This is strange.

Why dont you use instead :


txq = netdev_get_tx_queue(netdev, txq_map);


>  	/* Non-TSO sends must fit within ENIC_NON_TSO_MAX_DESC descs,
>  	 * which is very likely.  In the off chance it's going to take
> @@ -558,7 +560,7 @@ static netdev_tx_t enic_hard_start_xmit(struct sk_buff *skb,
>  
>  	if (vnic_wq_desc_avail(wq) <
>  	    skb_shinfo(skb)->nr_frags + ENIC_DESC_MAX_SPLITS) {
> -		netif_tx_stop_queue(netdev_get_tx_queue(netdev, txq_map));

See here ? Its not equivalent to previous code.

> +		netif_tx_stop_queue(txq);
>  		/* This is a hard error, log it */
>  		netdev_err(netdev, "BUG! Tx ring full when queue awake!\n");
