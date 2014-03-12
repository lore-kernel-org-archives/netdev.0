From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 03/10] r8169: Call dev_kfree_skby_any instead
 of dev_kfree_skb.
Date: Tue, 11 Mar 2014 19:02:53 -0700
Message-ID: <1394589773.21721.35.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	 <20140311.124907.1180556684992271103.davem@davemloft.net>
	 <87wqg0cy9d.fsf@xmission.com>
	 <20140311.160931.1395978386605601765.davem@davemloft.net>
	 <87r468bfqj.fsf_-_@xmission.com> <87a9cwbfmp.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:52562 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756460AbaCLCC4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 22:02:56 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so381742pdj.4
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 19:02:55 -0700 (PDT)
In-Reply-To: <87a9cwbfmp.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-03-11 at 14:16 -0700, Eric W. Biederman wrote:
> Replace dev_kfree_skb with dev_kfree_skb_any in functions that can
> be called in hard irq and other contexts.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index e9779653cd4c..cf947337e0d6 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -5834,7 +5834,7 @@ static void rtl8169_tx_clear_range(struct rtl8169_private *tp, u32 start,
>  					     tp->TxDescArray + entry);
>  			if (skb) {
>  				tp->dev->stats.tx_dropped++;
> -				dev_kfree_skb(skb);
> +				dev_kfree_skb_any(skb);
>  				tx_skb->skb = NULL;
>  			}
>  		}
> @@ -6059,7 +6059,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
>  err_dma_1:
>  	rtl8169_unmap_tx_skb(d, tp->tx_skb + entry, txd);
>  err_dma_0:
> -	dev_kfree_skb(skb);
> +	dev_kfree_skb_any(skb);
>  err_update_stats:
>  	dev->stats.tx_dropped++;
>  	return NETDEV_TX_OK;
> @@ -6142,7 +6142,7 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
>  			tp->tx_stats.packets++;
>  			tp->tx_stats.bytes += tx_skb->skb->len;
>  			u64_stats_update_end(&tp->tx_stats.syncp);
> -			dev_kfree_skb(tx_skb->skb);
> +			dev_kfree_skb_any(tx_skb->skb);
>  			tx_skb->skb = NULL;
>  		}
>  		dirty_tx++;

If this code can either run from softirq or hardirq, then
rtl8169_get_stats64() should block hard irq, not only soft irq.

Ie not use u64_stats_fetch_{begin|retry}_bh()
