From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: [git patches] net driver updates
Date: Thu, 7 Aug 2008 13:09:51 +0300
Message-ID: <20080807100950.GH2504@deprecation.cyrius.com>
References: <20080807085009.GA31681@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:3304 "EHLO sorrow.cyrius.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756107AbYHGMa3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 08:30:29 -0400
Content-Disposition: inline
In-Reply-To: <20080807085009.GA31681@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff, it seems you missed this patch:

From: Mikael Pettersson <mikpe@it.uu.se>

The arm ixp4xx_eth driver doesn't compile in 2.6.27-rc1:

  CC [M]  drivers/net/arm/ixp4xx_eth.o
drivers/net/arm/ixp4xx_eth.c: In function 'eth_poll':
drivers/net/arm/ixp4xx_eth.c:554: warning: passing argument 1 of 'dma_mapping_error' makes pointer from integer without a cast
drivers/net/arm/ixp4xx_eth.c:554: error: too few arguments to function 'dma_mapping_error'
drivers/net/arm/ixp4xx_eth.c: In function 'eth_xmit':
drivers/net/arm/ixp4xx_eth.c:701: warning: passing argument 1 of 'dma_mapping_error' makes pointer from integer without a cast
drivers/net/arm/ixp4xx_eth.c:701: error: too few arguments to function 'dma_mapping_error'
drivers/net/arm/ixp4xx_eth.c: In function 'init_queues':
drivers/net/arm/ixp4xx_eth.c:886: warning: passing argument 1 of 'dma_mapping_error' makes pointer from integer without a cast
drivers/net/arm/ixp4xx_eth.c:886: error: too few arguments to function 'dma_mapping_error'
make[3]: *** [drivers/net/arm/ixp4xx_eth.o] Error 1
make[2]: *** [drivers/net/arm] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2

dma_mapping_error() changed in 2.6.27-rc1 to also take a device parameter,
but nobody bothered updating ixp4xx_eth.c. Fixed by passing the appropriate
device value in the dma_mapping_error() calls.

Tested on an ixp425 box.

Signed-off-by: Mikael Pettersson <mikpe@it.uu.se>
Acked-by: Krzysztof Halasa <khc@pm.waw.pl>
Signed-off-by: Martin Michlmayr <tbm@cyrius.com>

diff -rupN linux-2.6.27-rc1/drivers/net/arm/ixp4xx_eth.c linux-2.6.27-rc1.arm-ixp4xx_eth-dma_mapping_error-fix/drivers/net/arm/ixp4xx_eth.c
--- linux-2.6.27-rc1/drivers/net/arm/ixp4xx_eth.c	2008-07-29 10:40:10.000000000 +0200
+++ linux-2.6.27-rc1.arm-ixp4xx_eth-dma_mapping_error-fix/drivers/net/arm/ixp4xx_eth.c	2008-08-01 19:38:35.000000000 +0200
@@ -551,7 +551,7 @@ static int eth_poll(struct napi_struct *
 		if ((skb = netdev_alloc_skb(dev, RX_BUFF_SIZE))) {
 			phys = dma_map_single(&dev->dev, skb->data,
 					      RX_BUFF_SIZE, DMA_FROM_DEVICE);
-			if (dma_mapping_error(phys)) {
+			if (dma_mapping_error(&dev->dev, phys)) {
 				dev_kfree_skb(skb);
 				skb = NULL;
 			}
@@ -698,7 +698,7 @@ static int eth_xmit(struct sk_buff *skb,
 #endif
 
 	phys = dma_map_single(&dev->dev, mem, bytes, DMA_TO_DEVICE);
-	if (dma_mapping_error(phys)) {
+	if (dma_mapping_error(&dev->dev, phys)) {
 #ifdef __ARMEB__
 		dev_kfree_skb(skb);
 #else
@@ -883,7 +883,7 @@ static int init_queues(struct port *port
 		desc->buf_len = MAX_MRU;
 		desc->data = dma_map_single(&port->netdev->dev, data,
 					    RX_BUFF_SIZE, DMA_FROM_DEVICE);
-		if (dma_mapping_error(desc->data)) {
+		if (dma_mapping_error(&port->netdev->dev, desc->data)) {
 			free_buffer(buff);
 			return -EIO;
 		}

-- 
Martin Michlmayr
http://www.cyrius.com/
