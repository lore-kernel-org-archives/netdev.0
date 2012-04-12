From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: smsc911x: fix RX FIFO fastforwarding when
 dropping packets
Date: Thu, 12 Apr 2012 11:20:48 +0200
Message-ID: <1334222448.5300.6046.camel@edumazet-glaptop>
References: <1334221644-16056-1-git-send-email-will.deacon@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>
To: Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:34362 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762255Ab2DLJUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 05:20:53 -0400
Received: by bkcik5 with SMTP id ik5so1331201bkc.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 02:20:51 -0700 (PDT)
In-Reply-To: <1334221644-16056-1-git-send-email-will.deacon@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-12 at 10:07 +0100, Will Deacon wrote:
> The SMSC911x ethernet controller provides a mechanism for quickly
> skipping to the start of the next frame in the receive FIFO, however
> the current code passes the number of words to a function that expects
> the number of bytes. This can corrupt the FIFO head in the case that
> the fastforward mechanism is not used.
> 
> This patch fixes the callers of smsc911x_rx_fastforward to pass the
> correct data size.
> 
> Cc: Steve Glendinning <steve.glendinning@smsc.com>
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> ---
>  drivers/net/ethernet/smsc/smsc911x.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
> index 4a69710..b5599bc 100644
> --- a/drivers/net/ethernet/smsc/smsc911x.c
> +++ b/drivers/net/ethernet/smsc/smsc911x.c
> @@ -1228,7 +1228,7 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
>  				  "Discarding packet with error bit set");
>  			/* Packet has an error, discard it and continue with
>  			 * the next */
> -			smsc911x_rx_fastforward(pdata, pktwords);
> +			smsc911x_rx_fastforward(pdata, pktlength);
>  			dev->stats.rx_dropped++;
>  			continue;
>  		}
> @@ -1238,7 +1238,7 @@ static int smsc911x_poll(struct napi_struct *napi, int budget)
>  			SMSC_WARN(pdata, rx_err,
>  				  "Unable to allocate skb for rx packet");
>  			/* Drop the packet and stop this polling iteration */
> -			smsc911x_rx_fastforward(pdata, pktwords);
> +			smsc911x_rx_fastforward(pdata, pktlength);
>  			dev->stats.rx_dropped++;
>  			break;
>  		}

Hum, looking at this driver, I see wrong code in lines 1246/1247

skb->data = skb->head;
skb_reset_tail_pointer(skb);

I suspect its hiding a buffer overflow bug or something.

netdev_alloc_skb() reserved NET_SKB_PAD bytes. A driver should not
un-reserve this headroom, or some networking setups can be very slow.

So 

pdata->ops->rx_readfifo(pdata,
	(unsigned int *)skb->head, pktwords);

also should be fixed to use skb->data instead.
