From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: net: mvneta: fix improper tx queue usage in mvneta_tx()
Date: Mon, 15 Apr 2013 13:50:37 +0200
Message-ID: <516BE98D.2040706@free-electrons.com>
References: <20130415063537.GA26507@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	Maen Suleiman <maen@marvell.com>, netdev@vger.kernel.org,
	Lior Amsalem <alior@marvell.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Dmitri Epshtein <dima@marvell.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:47846 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607Ab3DOLvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 07:51:23 -0400
In-Reply-To: <20130415063537.GA26507@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Willy

On 04/15/2013 08:35 AM, Willy Tarreau wrote:
> From 4f2069c92a27790e6071dc2a80f92c166e0b0ca4 Mon Sep 17 00:00:00 2001
> From: Willy Tarreau <w@1wt.eu>
> Date: Thu, 11 Apr 2013 23:00:37 +0200
> Subject: net: mvneta: fix improper tx queue usage in mvneta_tx()
> 
> mvneta_tx() was using a static tx queue number causing crashes as
> soon as a little bit of traffic was sent via the interface, because
> it is normally expected that the same queue should be used as in
> dev_queue_xmit().
> 
> As suggested by Ben Hutchings, let's use skb_get_queue_mapping() to
> get the proper Tx queue number, and use alloc_etherdev_mqs() instead
> of alloc_etherdev_mq() to create the queues.
> 
> Both my Mirabox and my OpenBlocks AX3 used to crash without this patch
> and don't anymore with it. The issue appeared in 3.8 but became more
> visible after the fix allowing GSO to be enabled.
> 
> Original work was done by Dmitri Epshtein and Thomas Petazzoni. I
> just adapted it to take care of Ben's comments.

Thanks for this work. I have tested on a DB-MV784MP-GP board in SMP
with 4 CPUs. Without this patch a "iperf -P 4" lead to a kernel crash
in 80% of the case and to a hang in the remaining cases. Now after
a dozen of tests on this board, I didn't see any crash or hang.
You can add my
Tested-by: Gregory CLEMENT <gregory.clement@free-electrons.com>

Thanks,

> 
> Signed-off-by: Willy Tarreau <w@1wt.eu>
> Cc: Dmitri Epshtein <dima@marvell.com>
> Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 1e628ce..a47a097 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -374,7 +374,6 @@ static int rxq_number = 8;
>  static int txq_number = 8;
>  
>  static int rxq_def;
> -static int txq_def;
>  
>  #define MVNETA_DRIVER_NAME "mvneta"
>  #define MVNETA_DRIVER_VERSION "1.0"
> @@ -1475,7 +1474,8 @@ error:
>  static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct mvneta_port *pp = netdev_priv(dev);
> -	struct mvneta_tx_queue *txq = &pp->txqs[txq_def];
> +	u16 txq_id = skb_get_queue_mapping(skb);
> +	struct mvneta_tx_queue *txq = &pp->txqs[txq_id];
>  	struct mvneta_tx_desc *tx_desc;
>  	struct netdev_queue *nq;
>  	int frags = 0;
> @@ -1485,7 +1485,7 @@ static int mvneta_tx(struct sk_buff *skb, struct net_device *dev)
>  		goto out;
>  
>  	frags = skb_shinfo(skb)->nr_frags + 1;
> -	nq    = netdev_get_tx_queue(dev, txq_def);
> +	nq    = netdev_get_tx_queue(dev, txq_id);
>  
>  	/* Get a descriptor for the first part of the packet */
>  	tx_desc = mvneta_txq_next_desc_get(txq);
> @@ -2689,7 +2689,7 @@ static int mvneta_probe(struct platform_device *pdev)
>  		return -EINVAL;
>  	}
>  
> -	dev = alloc_etherdev_mq(sizeof(struct mvneta_port), 8);
> +	dev = alloc_etherdev_mqs(sizeof(struct mvneta_port), txq_number, rxq_number);
>  	if (!dev)
>  		return -ENOMEM;
>  
> @@ -2844,4 +2844,3 @@ module_param(rxq_number, int, S_IRUGO);
>  module_param(txq_number, int, S_IRUGO);
>  
>  module_param(rxq_def, int, S_IRUGO);
> -module_param(txq_def, int, S_IRUGO);
> 


-- 
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
