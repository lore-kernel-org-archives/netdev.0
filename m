From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: fix throughtput regression with TSO
 autosizing
Date: Thu, 26 Feb 2015 09:27:35 -0800
Message-ID: <1424971655.5565.172.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424948758-48244-1-git-send-email-jaedon.shin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Jaedon Shin <jaedon.shin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:38556 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667AbbBZR1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 12:27:38 -0500
Received: by iecrd18 with SMTP id rd18so18194872iec.5
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 09:27:38 -0800 (PST)
In-Reply-To: <1424948758-48244-1-git-send-email-jaedon.shin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-02-26 at 20:05 +0900, Jaedon Shin wrote:
> This patch prevents the performance degradation of xmit after
> 605ad7f ("tcp: refine TSO autosizing").
> 
> Signed-off-by: Jaedon Shin <jaedon.shin@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/genet/bcmgenet.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> index ff83c46b..87eeff0 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
> @@ -1310,6 +1310,9 @@ static netdev_tx_t bcmgenet_xmit(struct sk_buff *skb, struct net_device *dev)
>  out:
>  	spin_unlock_irqrestore(&ring->lock, flags);
>  
> +	if (index != DESC_INDEX)
> +		skb_orphan(skb);
> +

Hmpff...

Can you elaborate on the regression ?

Is it because NIC delays TX completion irq or something ?

bcmgenet_poll() only drains TX packets on ring16 (DESC_INDEC)

Other tx completions seem to run from hard irq context (bcmgenet_isr1())

Your patch seems to imply a bug in hard irq signaling/handling.
