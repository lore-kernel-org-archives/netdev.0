From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH 1/3] ucc_geth: Fix empty TX queue processing
Date: Mon, 11 Jan 2010 13:52:48 +0300
Message-ID: <20100111105248.GA28580@oksana.dev.rtsoft.ru>
References: <0A1FE637C2C7E148B9573BB60CC630E56C3E90@zch01exm26.fsl.freescale.net>
 <100CB1A1877FF245BDB7AF83A0E73FFE26BE4D@zch01exm28.fsl.freescale.net>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	lsorense@csclub.uwaterloo.ca, davem@davemloft.net
To: Wu Jiajun-B06378 <B06378@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:51113 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751247Ab0AKKwz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2010 05:52:55 -0500
Content-Disposition: inline
In-Reply-To: <100CB1A1877FF245BDB7AF83A0E73FFE26BE4D@zch01exm28.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 11, 2010 at 11:47:37AM +0800, Wu Jiajun-B06378 wrote:
>  
> 'bd == ugeth->txBd[txQ]' has two possible statuses: 1)full queue.
> 2)empty queue.
> Removing 'netif_queue_stopped() == 0' will make transmitting stopping
> when the queue is full. 
> 
> I made a new patch for this oops.
[...]
> +		if ((bd == ugeth->txBd[txQ]) && (skb == NULL))
>  			break;

Hm. I wonder why do we need the 'bd == ugeth->txBd[txQ]' check
at all? The null skb will cause a kernel oops anyway.

I think the patch below should be sufficient for the fix.
Can you try it? Or if you tell me how to reproduce the issue
you observe, I can try it myself.

Thanks a lot!

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 41ad2f3..a1a6d06 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3279,13 +3279,12 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 		/* Handle the transmitted buffer and release */
 		/* the BD to be used with the current frame  */
 
-		if (bd == ugeth->txBd[txQ]) /* queue empty? */
+		skb = ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]];
+		if (!skb)
 			break;
 
 		dev->stats.tx_packets++;
 
-		skb = ugeth->tx_skbuff[txQ][ugeth->skb_dirtytx[txQ]];
-
 		if (skb_queue_len(&ugeth->rx_recycle) < RX_BD_RING_LEN &&
 			     skb_recycle_check(skb,
 				    ugeth->ug_info->uf_info.max_rx_buf_length +
