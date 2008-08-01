From: Mikael Pettersson <mikpe@it.uu.se>
Subject: [PATCH 2.6.27-rc1] ixp4xx_eth: fix dma_mapping_error() compile errors
Date: Fri, 1 Aug 2008 20:01:34 +0200 (MEST)
Message-ID: <200808011801.m71I1YLM006716@harpo.it.uu.se>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from aun.it.uu.se ([130.238.12.36]:33862 "EHLO aun.it.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003AbYHASBo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2008 14:01:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---

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
