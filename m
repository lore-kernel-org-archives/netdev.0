From: Dan Carpenter <error27@gmail.com>
Subject: [patch] cpmac: use resource_size()
Date: Mon, 28 Jun 2010 23:19:33 +0200
Message-ID: <20100628211933.GL19184@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:49165 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755293Ab0F1VVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 17:21:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original code is off by one because we should start counting at
zero.  So the size of the resource is end - start + 1.  I switched it to
use resource_size() to do the calculation.

Signed-off-by: Dan Carpenter <error27@gmail.com>
---
I don't have a cross compile environment, so I can't even compile test
this.  Sorry.

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 23786ee..38de1a4 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -964,7 +964,7 @@ static int cpmac_open(struct net_device *dev)
 	struct sk_buff *skb;
 
 	mem = platform_get_resource_byname(priv->pdev, IORESOURCE_MEM, "regs");
-	if (!request_mem_region(mem->start, mem->end - mem->start, dev->name)) {
+	if (!request_mem_region(mem->start, resource_size(mem), dev->name)) {
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR "%s: failed to request registers\n",
 			       dev->name);
@@ -972,7 +972,7 @@ static int cpmac_open(struct net_device *dev)
 		goto fail_reserve;
 	}
 
-	priv->regs = ioremap(mem->start, mem->end - mem->start);
+	priv->regs = ioremap(mem->start, resource_size(mem));
 	if (!priv->regs) {
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR "%s: failed to remap registers\n",
@@ -1049,7 +1049,7 @@ fail_alloc:
 	iounmap(priv->regs);
 
 fail_remap:
-	release_mem_region(mem->start, mem->end - mem->start);
+	release_mem_region(mem->start, resource_size(mem));
 
 fail_reserve:
 	return res;
@@ -1077,7 +1077,7 @@ static int cpmac_stop(struct net_device *dev)
 	free_irq(dev->irq, dev);
 	iounmap(priv->regs);
 	mem = platform_get_resource_byname(priv->pdev, IORESOURCE_MEM, "regs");
-	release_mem_region(mem->start, mem->end - mem->start);
+	release_mem_region(mem->start, resource_size(mem));
 	priv->rx_head = &priv->desc_ring[CPMAC_QUEUES];
 	for (i = 0; i < priv->ring_size; i++) {
 		if (priv->rx_head[i].skb) {
