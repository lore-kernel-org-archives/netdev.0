From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/7] myri10ge: switch to page-based skb
Date: Mon, 11 Dec 2006 11:25:42 +0100
Message-ID: <457D3226.30205@myri.com>
References: <457D31B2.30505@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:42208 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762756AbWLKK0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 05:26:00 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <457D31B2.30505@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch to physical page skb, by calling the new page-based
allocation routines and using myri10ge_page_rx_done().

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  180 +++++++++++++++++++++-------------------
 1 file changed, 97 insertions(+), 83 deletions(-)

Index: linux-git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2006-12-11 10:52:26.000000000 +0100
+++ linux-git/drivers/net/myri10ge/myri10ge.c	2006-12-11 10:52:35.000000000 +0100
@@ -1264,13 +1264,13 @@
 		rx_done->entry[idx].length = 0;
 		checksum = csum_unfold(rx_done->entry[idx].checksum);
 		if (length <= mgp->small_bytes)
-			rx_ok = myri10ge_rx_done(mgp, &mgp->rx_small,
-						 mgp->small_bytes,
-						 length, checksum);
+			rx_ok = myri10ge_page_rx_done(mgp, &mgp->rx_small,
+						      mgp->small_bytes,
+						      length, checksum);
 		else
-			rx_ok = myri10ge_rx_done(mgp, &mgp->rx_big,
-						 mgp->dev->mtu + ETH_HLEN,
-						 length, checksum);
+			rx_ok = myri10ge_page_rx_done(mgp, &mgp->rx_big,
+						      mgp->big_bytes,
+						      length, checksum);
 		rx_packets += rx_ok;
 		rx_bytes += rx_ok * (unsigned long)length;
 		cnt++;
@@ -1284,6 +1284,14 @@
 	rx_done->cnt = cnt;
 	mgp->stats.rx_packets += rx_packets;
 	mgp->stats.rx_bytes += rx_bytes;
+
+	/* restock receive rings if needed */
+	if (mgp->rx_small.fill_cnt - mgp->rx_small.cnt < myri10ge_fill_thresh)
+		myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
+					mgp->small_bytes + MXGEFW_PAD, 0);
+	if (mgp->rx_big.fill_cnt - mgp->rx_big.cnt < myri10ge_fill_thresh)
+		myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 0);
+
 }
 
 static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
@@ -1674,56 +1682,48 @@
 		goto abort_with_rx_small_info;
 
 	/* Fill the receive rings */
-
-	for (i = 0; i <= mgp->rx_small.mask; i++) {
-		status = myri10ge_getbuf(&mgp->rx_small, mgp,
-					 mgp->small_bytes, i);
-		if (status) {
-			printk(KERN_ERR
-			       "myri10ge: %s: alloced only %d small bufs\n",
-			       dev->name, i);
-			goto abort_with_rx_small_ring;
-		}
-	}
-
-	for (i = 0; i <= mgp->rx_big.mask; i++) {
-		status =
-		    myri10ge_getbuf(&mgp->rx_big, mgp, dev->mtu + ETH_HLEN, i);
-		if (status) {
-			printk(KERN_ERR
-			       "myri10ge: %s: alloced only %d big bufs\n",
-			       dev->name, i);
-			goto abort_with_rx_big_ring;
-		}
+	mgp->rx_big.cnt = 0;
+	mgp->rx_small.cnt = 0;
+	mgp->rx_big.fill_cnt = 0;
+	mgp->rx_small.fill_cnt = 0;
+	mgp->rx_small.page_offset = MYRI10GE_ALLOC_SIZE;
+	mgp->rx_big.page_offset = MYRI10GE_ALLOC_SIZE;
+	mgp->rx_small.watchdog_needed = 0;
+	mgp->rx_big.watchdog_needed = 0;
+	myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
+				mgp->small_bytes + MXGEFW_PAD, 0);
+
+	if (mgp->rx_small.fill_cnt < mgp->rx_small.mask + 1) {
+		printk(KERN_ERR "myri10ge: %s: alloced only %d small bufs\n",
+		       dev->name, mgp->rx_small.fill_cnt);
+		goto abort_with_rx_small_ring;
+	}
+
+	myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 0);
+	if (mgp->rx_big.fill_cnt < mgp->rx_big.mask + 1) {
+		printk(KERN_ERR "myri10ge: %s: alloced only %d big bufs\n",
+		       dev->name, mgp->rx_big.fill_cnt);
+		goto abort_with_rx_big_ring;
 	}
 
 	return 0;
 
 abort_with_rx_big_ring:
-	for (i = 0; i <= mgp->rx_big.mask; i++) {
-		if (mgp->rx_big.info[i].skb != NULL)
-			dev_kfree_skb_any(mgp->rx_big.info[i].skb);
-		if (pci_unmap_len(&mgp->rx_big.info[i], len))
-			pci_unmap_single(mgp->pdev,
-					 pci_unmap_addr(&mgp->rx_big.info[i],
-							bus),
-					 pci_unmap_len(&mgp->rx_big.info[i],
-						       len),
-					 PCI_DMA_FROMDEVICE);
+	for (i = mgp->rx_big.cnt; i < mgp->rx_big.fill_cnt; i++) {
+		int idx = i & mgp->rx_big.mask;
+		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_big.info[idx],
+				       mgp->big_bytes);
+		put_page(mgp->rx_big.info[idx].page);
 	}
 
 abort_with_rx_small_ring:
-	for (i = 0; i <= mgp->rx_small.mask; i++) {
-		if (mgp->rx_small.info[i].skb != NULL)
-			dev_kfree_skb_any(mgp->rx_small.info[i].skb);
-		if (pci_unmap_len(&mgp->rx_small.info[i], len))
-			pci_unmap_single(mgp->pdev,
-					 pci_unmap_addr(&mgp->rx_small.info[i],
-							bus),
-					 pci_unmap_len(&mgp->rx_small.info[i],
-						       len),
-					 PCI_DMA_FROMDEVICE);
+	for (i = mgp->rx_small.cnt; i < mgp->rx_small.fill_cnt; i++) {
+		int idx = i & mgp->rx_small.mask;
+		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_small.info[idx],
+				       mgp->small_bytes + MXGEFW_PAD);
+		put_page(mgp->rx_small.info[idx].page);
 	}
+
 	kfree(mgp->rx_big.info);
 
 abort_with_rx_small_info:
@@ -1756,30 +1756,24 @@
 
 	mgp = netdev_priv(dev);
 
-	for (i = 0; i <= mgp->rx_big.mask; i++) {
-		if (mgp->rx_big.info[i].skb != NULL)
-			dev_kfree_skb_any(mgp->rx_big.info[i].skb);
-		if (pci_unmap_len(&mgp->rx_big.info[i], len))
-			pci_unmap_single(mgp->pdev,
-					 pci_unmap_addr(&mgp->rx_big.info[i],
-							bus),
-					 pci_unmap_len(&mgp->rx_big.info[i],
-						       len),
-					 PCI_DMA_FROMDEVICE);
-	}
-
-	for (i = 0; i <= mgp->rx_small.mask; i++) {
-		if (mgp->rx_small.info[i].skb != NULL)
-			dev_kfree_skb_any(mgp->rx_small.info[i].skb);
-		if (pci_unmap_len(&mgp->rx_small.info[i], len))
-			pci_unmap_single(mgp->pdev,
-					 pci_unmap_addr(&mgp->rx_small.info[i],
-							bus),
-					 pci_unmap_len(&mgp->rx_small.info[i],
-						       len),
-					 PCI_DMA_FROMDEVICE);
+	for (i = mgp->rx_big.cnt; i < mgp->rx_big.fill_cnt; i++) {
+		idx = i & mgp->rx_big.mask;
+		if (i == mgp->rx_big.fill_cnt - 1)
+			mgp->rx_big.info[idx].page_offset = MYRI10GE_ALLOC_SIZE;
+		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_big.info[idx],
+				       mgp->big_bytes);
+		put_page(mgp->rx_big.info[idx].page);
+	}
+
+	for (i = mgp->rx_small.cnt; i < mgp->rx_small.fill_cnt; i++) {
+		idx = i & mgp->rx_small.mask;
+		if (i == mgp->rx_small.fill_cnt - 1)
+			mgp->rx_small.info[idx].page_offset =
+			    MYRI10GE_ALLOC_SIZE;
+		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_small.info[idx],
+				       mgp->small_bytes + MXGEFW_PAD);
+		put_page(mgp->rx_small.info[idx].page);
 	}
-
 	tx = &mgp->tx;
 	while (tx->done != tx->req) {
 		idx = tx->done & tx->mask;
@@ -1847,19 +1841,18 @@
 	 */
 
 	if (dev->mtu <= ETH_DATA_LEN)
-		mgp->small_bytes = 128;	/* enough for a TCP header */
+		/* enough for a TCP header */
+		mgp->small_bytes = (128 > SMP_CACHE_BYTES)
+		    ? (128 - MXGEFW_PAD)
+		    : (SMP_CACHE_BYTES - MXGEFW_PAD);
 	else
-		mgp->small_bytes = ETH_FRAME_LEN;	/* enough for an ETH_DATA_LEN frame */
+		/* enough for an ETH_DATA_LEN frame */
+		mgp->small_bytes = ETH_FRAME_LEN;
 
 	/* Override the small buffer size? */
 	if (myri10ge_small_bytes > 0)
 		mgp->small_bytes = myri10ge_small_bytes;
 
-	/* If the user sets an obscenely small MTU, adjust the small
-	 * bytes down to nearly nothing */
-	if (mgp->small_bytes >= (dev->mtu + ETH_HLEN))
-		mgp->small_bytes = 64;
-
 	/* get the lanai pointers to the send and receive rings */
 
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_OFFSET, &cmd, 0);
@@ -1895,17 +1888,23 @@
 		mgp->rx_big.wc_fifo = NULL;
 	}
 
-	status = myri10ge_allocate_rings(dev);
-	if (status != 0)
-		goto abort_with_nothing;
-
 	/* Firmware needs the big buff size as a power of 2.  Lie and
 	 * tell him the buffer is larger, because we only use 1
 	 * buffer/pkt, and the mtu will prevent overruns.
 	 */
 	big_pow2 = dev->mtu + ETH_HLEN + MXGEFW_PAD;
-	while ((big_pow2 & (big_pow2 - 1)) != 0)
-		big_pow2++;
+	if (big_pow2 < MYRI10GE_ALLOC_SIZE / 2) {
+		while ((big_pow2 & (big_pow2 - 1)) != 0)
+			big_pow2++;
+		mgp->big_bytes = dev->mtu + ETH_HLEN + MXGEFW_PAD;
+	} else {
+		big_pow2 = MYRI10GE_ALLOC_SIZE;
+		mgp->big_bytes = big_pow2;
+	}
+
+	status = myri10ge_allocate_rings(dev);
+	if (status != 0)
+		goto abort_with_nothing;
 
 	/* now give firmware buffers sizes, and MTU */
 	cmd.data0 = dev->mtu + ETH_HLEN + VLAN_HLEN;
@@ -2888,6 +2887,21 @@
 	struct myri10ge_priv *mgp;
 
 	mgp = (struct myri10ge_priv *)arg;
+
+	if (mgp->rx_small.watchdog_needed) {
+		myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
+					mgp->small_bytes + MXGEFW_PAD, 1);
+		if (mgp->rx_small.fill_cnt - mgp->rx_small.cnt >=
+		    myri10ge_fill_thresh)
+			mgp->rx_small.watchdog_needed = 0;
+	}
+	if (mgp->rx_big.watchdog_needed) {
+		myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 1);
+		if (mgp->rx_big.fill_cnt - mgp->rx_big.cnt >=
+		    myri10ge_fill_thresh)
+			mgp->rx_big.watchdog_needed = 0;
+	}
+
 	if (mgp->tx.req != mgp->tx.done &&
 	    mgp->tx.done == mgp->watchdog_tx_done &&
 	    mgp->watchdog_tx_req != mgp->watchdog_tx_done)


