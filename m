From: Yinghai Lu <Yinghai.Lu@Sun.COM>
Subject: [PATCH 3/4] net: make forcedeth to use kmalloc_node and
 __netdev_alloc_skb for skb allocation
Date: Tue, 03 Jul 2007 17:34:40 -0700
Message-ID: <200707031734.40709.yinghai.lu@sun.com>
References: <200706291330.37070.yinghai.lu@sun.com> <468ABF92.5030800@sun.com>
 <20070703143407.7e4232f8@freepuppy.localdomain.hemminger.net>
Reply-To: Yinghai Lu <Yinghai.Lu@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andi Kleen <ak@suse.de>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:49246 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754320AbXGDAdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 20:33:49 -0400
In-reply-to: <20070703143407.7e4232f8@freepuppy.localdomain.hemminger.net>
Content-disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 3/4] net: make forcedeth to use kmalloc_node and __netdev_alloc_skb for skb allocation

Signed-off-by: Yinghai Lu <yinghai.lu@sun.com>

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 42ba1c0..aa188f4 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -1383,7 +1383,8 @@ static int nv_alloc_rx(struct net_device *dev)
 		less_rx = np->last_rx.orig;
 
 	while (np->put_rx.orig != less_rx) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
+		struct sk_buff *skb = __netdev_alloc_skb(dev, np->rx_buf_sz +
+						NV_RX_ALLOC_PAD, GFP_ATOMIC);
 		if (skb) {
 			np->put_rx_ctx->skb = skb;
 			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
@@ -1415,7 +1416,8 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 		less_rx = np->last_rx.ex;
 
 	while (np->put_rx.ex != less_rx) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
+		struct sk_buff *skb = __netdev_alloc_skb(dev, np->rx_buf_sz +
+						NV_RX_ALLOC_PAD, GFP_ATOMIC);
 		if (skb) {
 			np->put_rx_ctx->skb = skb;
 			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
@@ -3976,8 +3978,10 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 					    sizeof(struct ring_desc_ex) * (ring->rx_pending + ring->tx_pending),
 					    &ring_addr);
 	}
-	rx_skbuff = kmalloc(sizeof(struct nv_skb_map) * ring->rx_pending, GFP_KERNEL);
-	tx_skbuff = kmalloc(sizeof(struct nv_skb_map) * ring->tx_pending, GFP_KERNEL);
+	rx_skbuff = kmalloc_node(sizeof(struct nv_skb_map) * ring->rx_pending,
+				 GFP_KERNEL, dev_to_node(&dev->dev));
+	tx_skbuff = kmalloc_node(sizeof(struct nv_skb_map) * ring->tx_pending,
+				 GFP_KERNEL, dev_to_node(&dev->dev));
 	if (!rxtx_ring || !rx_skbuff || !tx_skbuff) {
 		/* fall back to old rings */
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
@@ -4372,7 +4376,7 @@ static int nv_loopback_test(struct net_device *dev)
 
 	/* setup packet for tx */
 	pkt_len = ETH_DATA_LEN;
-	tx_skb = dev_alloc_skb(pkt_len);
+	tx_skb = __netdev_alloc_skb(dev, pkt_len, GFP_ATOMIC);
 	if (!tx_skb) {
 		printk(KERN_ERR "dev_alloc_skb() failed during loopback test"
 			 " of %s\n", dev->name);
@@ -4976,6 +4980,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 	dev->base_addr = (unsigned long)np->base;
 
 	dev->irq = pci_dev->irq;
+	printk(KERN_INFO "nv_probe: numa_node : %02d\n",
+		dev_to_node(&pci_dev->dev));
 
 	np->rx_ring_size = RX_RING_DEFAULT;
 	np->tx_ring_size = TX_RING_DEFAULT;
@@ -4995,8 +5001,11 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 			goto out_unmap;
 		np->tx_ring.ex = &np->rx_ring.ex[np->rx_ring_size];
 	}
-	np->rx_skb = kmalloc(sizeof(struct nv_skb_map) * np->rx_ring_size, GFP_KERNEL);
-	np->tx_skb = kmalloc(sizeof(struct nv_skb_map) * np->tx_ring_size, GFP_KERNEL);
+	np->rx_skb = kmalloc_node(sizeof(struct nv_skb_map) * np->rx_ring_size,
+				  GFP_KERNEL, dev_to_node(&pci_dev->dev));
+	np->tx_skb = kmalloc_node(sizeof(struct nv_skb_map) * np->tx_ring_size,
+				  GFP_KERNEL, dev_to_node(&pci_dev->dev));
+
 	if (!np->rx_skb || !np->tx_skb)
 		goto out_freering;
 	memset(np->rx_skb, 0, sizeof(struct nv_skb_map) * np->rx_ring_size);
