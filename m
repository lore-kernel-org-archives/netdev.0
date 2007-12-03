From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH] SMC911X: Fix using of dereferenced skb after netif_rx
Date: Mon, 03 Dec 2007 18:18:27 +0800
Message-ID: <4753D7F3.3050201@cn.fujitsu.com>
References: <4753B74D.4070505@cn.fujitsu.com> <20071203101141.GA23549@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Dustin McIntire <dustin@sensoria.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:58521 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751637AbXLCKVS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 05:21:18 -0500
In-Reply-To: <20071203101141.GA23549@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu said the following on 2007-12-3 18:11:
> Please send driver patches to Jeff Garzik <jgarzik@pobox.com>.
> 

Sorry. Resend the patch.

After netif_rx(), skb will be freed. So get the
skb->len before netif_rx().

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 smc911x.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

--- linux-2.6.24.rc3.org/drivers/net/smc911x.c	2007-11-19 12:38:05.000000000 +0800
+++ linux-2.6.24.rc3/drivers/net/smc911x.c	2007-11-30 15:00:53.000000000 +0800
@@ -1287,7 +1287,7 @@ smc911x_rx_dma_irq(int dma, void *data)
 	struct smc911x_local *lp = netdev_priv(dev);
 	struct sk_buff *skb = lp->current_rx_skb;
 	unsigned long flags;
-	unsigned int pkts;
+	unsigned int pkts, len;
 
 	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 	DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA, "%s: RX DMA irq handler\n", dev->name);
@@ -1299,9 +1299,10 @@ smc911x_rx_dma_irq(int dma, void *data)
 	PRINT_PKT(skb->data, skb->len);
 	dev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, dev);
+	len = skb->len;
 	netif_rx(skb);
 	dev->stats.rx_packets++;
-	dev->stats.rx_bytes += skb->len;
+	dev->stats.rx_bytes += len;
 
 	spin_lock_irqsave(&lp->lock, flags);
 	pkts = (SMC_GET_RX_FIFO_INF() & RX_FIFO_INF_RXSUSED_) >> 16;

