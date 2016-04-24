From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 2/6] atl1c: remove private tx lock
Date: Mon, 25 Apr 2016 00:03:53 +0200
Message-ID: <201604250731.u3P7ViLN019808@violet.fr.zoreil.com>
References: <1461526694-11367-1-git-send-email-fw@strlen.de>
 <1461526694-11367-3-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54520 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663AbcDYHbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 03:31:46 -0400
Received: from violet.fr.zoreil.com (localhost [127.0.0.1])
	by violet.fr.zoreil.com (8.14.9/8.14.5) with ESMTP id u3P7VilW019809
	for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 09:31:44 +0200
Received: (from romieu@localhost)
	by violet.fr.zoreil.com (8.14.9/8.14.5/Submit) id u3P7ViLN019808
	for netdev@vger.kernel.org; Mon, 25 Apr 2016 09:31:44 +0200
Content-Disposition: inline
In-Reply-To: <1461526694-11367-3-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Westphal <fw@strlen.de> :
[...]
> diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> index d0084d4..a3200ea 100644
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
[...]
> @@ -2217,16 +2215,10 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
>  	}
>  
>  	tpd_req = atl1c_cal_tpd_req(skb);
> -	if (!spin_trylock_irqsave(&adapter->tx_lock, flags)) {
> -		if (netif_msg_pktdata(adapter))
> -			dev_info(&adapter->pdev->dev, "tx locked\n");
> -		return NETDEV_TX_LOCKED;
> -	}
>  
>  	if (atl1c_tpd_avail(adapter, type) < tpd_req) {
>  		/* no enough descriptor, just stop queue */
>  		netif_stop_queue(netdev);
> -		spin_unlock_irqrestore(&adapter->tx_lock, flags);
>  		return NETDEV_TX_BUSY;
>  	}
>

Play it safe and keep the implicit local_irq_{save / restore} call ?

It may not be needed but it will help avoiding any unexpected regression
report pointing at the NETDEV_TX_LOCKED removal change.

-- 
Ueimor
