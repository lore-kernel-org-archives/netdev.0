From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net: systemport: Fix 64-bit stats deadlock
Date: Tue, 12 Sep 2017 14:38:13 -0700
Message-ID: <1505252293.15310.151.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1505247266-42195-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
        jqiaoulk@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:37884 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbdILViP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 17:38:15 -0400
Received: by mail-pg0-f68.google.com with SMTP id v5so6715639pgn.4
        for <netdev@vger.kernel.org>; Tue, 12 Sep 2017 14:38:15 -0700 (PDT)
In-Reply-To: <1505247266-42195-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-09-12 at 13:14 -0700, Florian Fainelli wrote:
> We can enter a deadlock situation because there is no sufficient protection
> when ndo_get_stats64() runs in process context to guard against RX or TX NAPI
> contexts running in softirq, this can lead to the following lockdep splat and
> actual deadlock was experienced as well with an iperf session in the background
> and a while loop doing ifconfig + ethtool.

> So just remove the u64_stats_update_begin()/end() pair in ndo_get_stats64()
> since it does not appear to be useful for anything. No inconsistency was
> observed with either ifconfig or ethtool, global TX counts equal the sum of
> per-queue TX counts on a 32-bit architecture.
> 
> Fixes: 10377ba7673d ("net: systemport: Support 64bit statistics")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bcmsysport.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
> index a6572b51435a..c3c53f6cd9e6 100644
> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
> @@ -1735,11 +1735,8 @@ static void bcm_sysport_get_stats64(struct net_device *dev,
>  		stats->tx_packets += tx_packets;
>  	}
>  
> -	/* lockless update tx_bytes and tx_packets */
> -	u64_stats_update_begin(&priv->syncp);

Yes, this u64_stats_update_begin()/u64_stats_update_end() is bogus

But why do we even write on tx_bytes/tx_packets here ??? 

Seems very wrong anyway.

(ethtool -S does not call bcm_sysport_get_stats64() to refresh them )

>  	stats64->tx_bytes = stats->tx_bytes;
>  	stats64->tx_packets = stats->tx_packets;
> -	u64_stats_update_end(&priv->syncp);
>  
>  	do {
>  		start = u64_stats_fetch_begin_irq(&priv->syncp);
