From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 01/07] 8139too: Support for byte queue limits
Date: Mon, 14 Oct 2013 12:11:31 -0700
Message-ID: <1381777891.2045.1.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381775183-24866-1-git-send-email-milky-kernel@mcmilk.de>
	 <1381775183-24866-2-git-send-email-milky-kernel@mcmilk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>, Jiri Pirko <jiri@resnulli.us>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Tino Reichardt <milky-kernel@mcmilk.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:60460 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884Ab3JNTLd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 15:11:33 -0400
Received: by mail-pd0-f175.google.com with SMTP id q10so7793758pdj.34
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 12:11:32 -0700 (PDT)
In-Reply-To: <1381775183-24866-2-git-send-email-milky-kernel@mcmilk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-10-14 at 20:26 +0200, Tino Reichardt wrote:
> Changes to 8139too to use byte queue limits.
> 
> This patch was not tested on real hardware currently, but compiles fine and
> should work.
> 
> 
> Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>
> 
> ---
>  drivers/net/ethernet/realtek/8139too.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
> index 3ccedeb..992ac57 100644
> --- a/drivers/net/ethernet/realtek/8139too.c
> +++ b/drivers/net/ethernet/realtek/8139too.c
> @@ -1409,6 +1409,7 @@ static void rtl8139_hw_start (struct net_device *dev)
>  	}
>  
>  	netdev_dbg(dev, "init buffer addresses\n");
> +	netdev_reset_queue(dev);
>  
>  	/* Lock Config[01234] and BMCR register writes */
>  	RTL_W8 (Cfg9346, Cfg9346_Lock);
> @@ -1638,6 +1639,7 @@ static inline void rtl8139_tx_clear (struct rtl8139_private *tp)
>  {
>  	tp->cur_tx = 0;
>  	tp->dirty_tx = 0;
> +	netdev_reset_queue(tp->dev);
>  
>  	/* XXX account for unsent Tx packets in tp->stats.tx_dropped */
>  }
> @@ -1733,6 +1735,7 @@ static netdev_tx_t rtl8139_start_xmit (struct sk_buff *skb,
>  		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));
>  
>  	tp->cur_tx++;
> +	netdev_sent_queue(dev, len);
>  

This looks wrong if len < ETH_ZLEN

>  	if ((tp->cur_tx - NUM_TX_DESC) == tp->dirty_tx)
>  		netif_stop_queue (dev);
> @@ -1750,6 +1753,7 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
>  				  void __iomem *ioaddr)
>  {
>  	unsigned long dirty_tx, tx_left;
> +	unsigned bytes_compl = 0, pkts_compl = 0;
>  
>  	assert (dev != NULL);
>  	assert (ioaddr != NULL);
> @@ -1792,6 +1796,8 @@ static void rtl8139_tx_interrupt (struct net_device *dev,
>  			u64_stats_update_begin(&tp->tx_stats.syncp);
>  			tp->tx_stats.packets++;
>  			tp->tx_stats.bytes += txstatus & 0x7ff;
> +			pkts_compl++;
> +			bytes_compl += txstatus & 0x7ff;

Because here len reported by NIC will be >= ETH_ZLEN
