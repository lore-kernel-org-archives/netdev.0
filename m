From: Don Fry <pcnet32@frontier.com>
Subject: [PATCH net-next 1/2] pcnet32: fix reallocation error
Date: Mon, 17 Feb 2014 20:57:46 -0800
Message-ID: <1392699466.4020.27.camel@Linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from filter03.roch.ny.frontiernet.net ([66.133.183.233]:53697 "EHLO
	filter03.roch.ny.frontiernet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750792AbaBRFEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 00:04:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pcnet32_realloc_rx_ring() only worked on the first log2 number of
entries in the receive ring instead of the all the entries.
Replaced "1 << size" with more descriptive variable.
This is my original bug from 2006.  Found while testing another problem.
Tested on 79C972 and 79C976.

Signed-off-by: Don Fry <pcnet32@frontier.com>
---
 drivers/net/ethernet/amd/pcnet32.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 9339ccc..25cd04a 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -549,35 +549,36 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 	struct pcnet32_rx_head *new_rx_ring;
 	struct sk_buff **new_skb_list;
 	int new, overlap;
+	unsigned int entries = 1 << size;
 
 	new_rx_ring = pci_alloc_consistent(lp->pci_dev,
 					   sizeof(struct pcnet32_rx_head) *
-					   (1 << size),
+					   entries,
 					   &new_ring_dma_addr);
 	if (new_rx_ring == NULL) {
 		netif_err(lp, drv, dev, "Consistent memory allocation failed\n");
 		return;
 	}
-	memset(new_rx_ring, 0, sizeof(struct pcnet32_rx_head) * (1 << size));
+	memset(new_rx_ring, 0, sizeof(struct pcnet32_rx_head) * entries);
 
-	new_dma_addr_list = kcalloc(1 << size, sizeof(dma_addr_t), GFP_ATOMIC);
+	new_dma_addr_list = kcalloc(entries, sizeof(dma_addr_t), GFP_ATOMIC);
 	if (!new_dma_addr_list)
 		goto free_new_rx_ring;
 
-	new_skb_list = kcalloc(1 << size, sizeof(struct sk_buff *),
+	new_skb_list = kcalloc(entries, sizeof(struct sk_buff *),
 			       GFP_ATOMIC);
 	if (!new_skb_list)
 		goto free_new_lists;
 
 	/* first copy the current receive buffers */
-	overlap = min(size, lp->rx_ring_size);
+	overlap = min(entries, lp->rx_ring_size);
 	for (new = 0; new < overlap; new++) {
 		new_rx_ring[new] = lp->rx_ring[new];
 		new_dma_addr_list[new] = lp->rx_dma_addr[new];
 		new_skb_list[new] = lp->rx_skbuff[new];
 	}
 	/* now allocate any new buffers needed */
-	for (; new < size; new++) {
+	for (; new < entries; new++) {
 		struct sk_buff *rx_skbuff;
 		new_skb_list[new] = netdev_alloc_skb(dev, PKT_BUF_SKB);
 		rx_skbuff = new_skb_list[new];
@@ -612,7 +613,7 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 			    lp->rx_ring_size, lp->rx_ring,
 			    lp->rx_ring_dma_addr);
 
-	lp->rx_ring_size = (1 << size);
+	lp->rx_ring_size = entries;
 	lp->rx_mod_mask = lp->rx_ring_size - 1;
 	lp->rx_len_bits = (size << 4);
 	lp->rx_ring = new_rx_ring;
@@ -634,8 +635,7 @@ free_new_lists:
 	kfree(new_dma_addr_list);
 free_new_rx_ring:
 	pci_free_consistent(lp->pci_dev,
-			    sizeof(struct pcnet32_rx_head) *
-			    (1 << size),
+			    sizeof(struct pcnet32_rx_head) * entries,
 			    new_rx_ring,
 			    new_ring_dma_addr);
 }
-- 
1.7.2.3
