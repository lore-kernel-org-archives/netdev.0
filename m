From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] SMC911X: Fix using of dereferenced skb after netif_rx
Date: Tue, 04 Dec 2007 10:01:37 +0800
Message-ID: <4754B501.7070108@cn.fujitsu.com>
References: <4753B74D.4070505@cn.fujitsu.com>	<20071203101141.GA23549@gondor.apana.org.au>	<4753D7F3.3050201@cn.fujitsu.com> <87wsrvyjob.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Dustin McIntire <dustin@sensoria.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:52983 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbXLDCEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 21:04:30 -0500
In-Reply-To: <87wsrvyjob.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Peter Korsgaard said the following on 2007-12-3 21:47:
>>>>>> "Wang" == Wang Chen <wangchen@cn.fujitsu.com> writes:
> 
> Hi,
> 
>  Wang> +	len = skb->len;
>  Wang>  	netif_rx(skb);
>  dev-> stats.rx_packets++;
>  Wang> -	dev->stats.rx_bytes += skb->len;
>  Wang> +	dev->stats.rx_bytes += len;
> 
> Why not simply update the stats before calling netif_rx as the return
> value isn't checked anyway?
> 

Even the return value of netif_rx isn't checked, dev->stats maybe
changed in netif_rx. But fortunately dev->stats isn't changed in
netif_rx.
So, I agree. 
Here is the new patch.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 smc911x.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.24.rc3.org/drivers/net/smc911x.c	2007-11-19 12:38:05.000000000 +0800
+++ linux-2.6.24.rc3/drivers/net/smc911x.c	2007-12-04 09:59:06.000000000 +0800
@@ -1299,9 +1299,9 @@ smc911x_rx_dma_irq(int dma, void *data)
 	PRINT_PKT(skb->data, skb->len);
 	dev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, dev);
-	netif_rx(skb);
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes += skb->len;
+	netif_rx(skb);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	pkts = (SMC_GET_RX_FIFO_INF() & RX_FIFO_INF_RXSUSED_) >> 16;

