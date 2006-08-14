From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/3] myri10ge: convert to netdev_alloc_skb
Date: Mon, 14 Aug 2006 17:53:15 -0400
Message-ID: <44E0F0CB.4000407@myri.com>
References: <44E0DA08.9080304@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:43750 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S964998AbWHNVxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 17:53:32 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44E0DA08.9080304@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the myri10ge driver to use netdev_alloc_skb instead of dev_alloc_skb,
which requires to propagate the net_device across several functions.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   37 ++++++++++++++++++++-----------------
 1 file changed, 20 insertions(+), 17 deletions(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-08-14 14:21:57.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-08-14 14:22:07.000000000 -0400
@@ -798,12 +798,13 @@
  * pages directly and building a fraglist in the near future.
  */
 
-static inline struct sk_buff *myri10ge_alloc_big(int bytes)
+static inline struct sk_buff *myri10ge_alloc_big(struct net_device *dev,
+						 int bytes)
 {
 	struct sk_buff *skb;
 	unsigned long data, roundup;
 
-	skb = dev_alloc_skb(bytes + 4096 + MXGEFW_PAD);
+	skb = netdev_alloc_skb(dev, bytes + 4096 + MXGEFW_PAD);
 	if (skb == NULL)
 		return NULL;
 
@@ -821,12 +822,13 @@
 
 /* Allocate 2x as much space as required and use whichever portion
  * does not cross a 4KB boundary */
-static inline struct sk_buff *myri10ge_alloc_small_safe(unsigned int bytes)
+static inline struct sk_buff *myri10ge_alloc_small_safe(struct net_device *dev,
+							unsigned int bytes)
 {
 	struct sk_buff *skb;
 	unsigned long data, boundary;
 
-	skb = dev_alloc_skb(2 * (bytes + MXGEFW_PAD) - 1);
+	skb = netdev_alloc_skb(dev, 2 * (bytes + MXGEFW_PAD) - 1);
 	if (unlikely(skb == NULL))
 		return NULL;
 
@@ -847,12 +849,13 @@
 
 /* Allocate just enough space, and verify that the allocated
  * space does not cross a 4KB boundary */
-static inline struct sk_buff *myri10ge_alloc_small(int bytes)
+static inline struct sk_buff *myri10ge_alloc_small(struct net_device *dev,
+						   int bytes)
 {
 	struct sk_buff *skb;
 	unsigned long roundup, data, end;
 
-	skb = dev_alloc_skb(bytes + 16 + MXGEFW_PAD);
+	skb = netdev_alloc_skb(dev, bytes + 16 + MXGEFW_PAD);
 	if (unlikely(skb == NULL))
 		return NULL;
 
@@ -868,15 +871,17 @@
 		       "myri10ge_alloc_small: small skb crossed 4KB boundary\n");
 		myri10ge_skb_cross_4k = 1;
 		dev_kfree_skb_any(skb);
-		skb = myri10ge_alloc_small_safe(bytes);
+		skb = myri10ge_alloc_small_safe(dev, bytes);
 	}
 	return skb;
 }
 
 static inline int
-myri10ge_getbuf(struct myri10ge_rx_buf *rx, struct pci_dev *pdev, int bytes,
-		int idx)
+myri10ge_getbuf(struct myri10ge_rx_buf *rx, struct myri10ge_priv *mgp,
+		int bytes, int idx)
 {
+	struct net_device *dev = mgp->dev;
+	struct pci_dev *pdev = mgp->pdev;
 	struct sk_buff *skb;
 	dma_addr_t bus;
 	int len, retval = 0;
@@ -884,11 +889,11 @@
 	bytes += VLAN_HLEN;	/* account for 802.1q vlan tag */
 
 	if ((bytes + MXGEFW_PAD) > (4096 - 16) /* linux overhead */ )
-		skb = myri10ge_alloc_big(bytes);
+		skb = myri10ge_alloc_big(dev, bytes);
 	else if (myri10ge_skb_cross_4k)
-		skb = myri10ge_alloc_small_safe(bytes);
+		skb = myri10ge_alloc_small_safe(dev, bytes);
 	else
-		skb = myri10ge_alloc_small(bytes);
+		skb = myri10ge_alloc_small(dev, bytes);
 
 	if (unlikely(skb == NULL)) {
 		rx->alloc_fail++;
@@ -951,7 +956,7 @@
 	unmap_len = pci_unmap_len(&rx->info[idx], len);
 
 	/* try to replace the received skb */
-	if (myri10ge_getbuf(rx, mgp->pdev, bytes, idx)) {
+	if (myri10ge_getbuf(rx, mgp, bytes, idx)) {
 		/* drop the frame -- the old skbuf is re-cycled */
 		mgp->stats.rx_dropped += 1;
 		return 0;
@@ -968,7 +973,6 @@
 	skb_put(skb, len);
 
 	skb->protocol = eth_type_trans(skb, mgp->dev);
-	skb->dev = mgp->dev;
 	if (mgp->csum_flag) {
 		if ((skb->protocol == ntohs(ETH_P_IP)) ||
 		    (skb->protocol == ntohs(ETH_P_IPV6))) {
@@ -1439,7 +1443,7 @@
 	/* Fill the receive rings */
 
 	for (i = 0; i <= mgp->rx_small.mask; i++) {
-		status = myri10ge_getbuf(&mgp->rx_small, mgp->pdev,
+		status = myri10ge_getbuf(&mgp->rx_small, mgp,
 					 mgp->small_bytes, i);
 		if (status) {
 			printk(KERN_ERR
@@ -1451,8 +1455,7 @@
 
 	for (i = 0; i <= mgp->rx_big.mask; i++) {
 		status =
-		    myri10ge_getbuf(&mgp->rx_big, mgp->pdev,
-				    dev->mtu + ETH_HLEN, i);
+		    myri10ge_getbuf(&mgp->rx_big, mgp, dev->mtu + ETH_HLEN, i);
 		if (status) {
 			printk(KERN_ERR
 			       "myri10ge: %s: alloced only %d big bufs\n",


