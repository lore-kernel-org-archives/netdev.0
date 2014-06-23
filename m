From: Joe Perches <joe@perches.com>
Subject: [PATCH] amd: Neaten and remove unnecessary OOM messages
Date: Mon, 23 Jun 2014 14:36:35 -0700
Message-ID: <1403559395.20657.8.camel@joe-AO725>
References: <cover.1403530604.git.joe@perches.com>
	 <c7cdaa8e080157cdabb92278a4c3beba89b49070.1403530604.git.joe@perches.com>
	 <1403546524.12008.2.camel@Lunix2.home>
	 <1403550950.15811.15.camel@joe-AO725> <1403557507.20657.3.camel@joe-AO725>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Don Fry <pcnet32@frontier.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403557507.20657.3.camel@joe-AO725>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the code flow a little better for 80 columns.

Use a consistent style for the RX and TX rings allocation.
Use BIT macro.
Use a temporary unsiged int entries for (1<<size).
Remove the OOM messages as they duplicate the generic
OOM and dump_stack() provided by the memory subsystem.
Reflow allocs to 80 columns.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/amd/pcnet32.c | 43 ++++++++++++++++----------------------
 1 file changed, 18 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 8099fdc..4a8fdc4 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -481,36 +481,32 @@ static void pcnet32_realloc_tx_ring(struct net_device *dev,
 	dma_addr_t *new_dma_addr_list;
 	struct pcnet32_tx_head *new_tx_ring;
 	struct sk_buff **new_skb_list;
+	unsigned int entries = BIT(size);
 
 	pcnet32_purge_tx_ring(dev);
 
-	new_tx_ring = pci_zalloc_consistent(lp->pci_dev,
-					    sizeof(struct pcnet32_tx_head) *
-					    (1 << size),
-					    &new_ring_dma_addr);
-	if (new_tx_ring == NULL) {
-		netif_err(lp, drv, dev, "Consistent memory allocation failed\n");
+	new_tx_ring =
+		pci_zalloc_consistent(lp->pci_dev,
+				      sizeof(struct pcnet32_tx_head) * entries,
+				      &new_ring_dma_addr);
+	if (new_tx_ring == NULL)
 		return;
-	}
 
-	new_dma_addr_list = kcalloc(1 << size, sizeof(dma_addr_t),
-				    GFP_ATOMIC);
+	new_dma_addr_list = kcalloc(entries, sizeof(dma_addr_t), GFP_ATOMIC);
 	if (!new_dma_addr_list)
 		goto free_new_tx_ring;
 
-	new_skb_list = kcalloc(1 << size, sizeof(struct sk_buff *),
-			       GFP_ATOMIC);
+	new_skb_list = kcalloc(entries, sizeof(struct sk_buff *), GFP_ATOMIC);
 	if (!new_skb_list)
 		goto free_new_lists;
 
 	kfree(lp->tx_skbuff);
 	kfree(lp->tx_dma_addr);
 	pci_free_consistent(lp->pci_dev,
-			    sizeof(struct pcnet32_tx_head) *
-			    lp->tx_ring_size, lp->tx_ring,
-			    lp->tx_ring_dma_addr);
+			    sizeof(struct pcnet32_tx_head) * lp->tx_ring_size,
+			    lp->tx_ring, lp->tx_ring_dma_addr);
 
-	lp->tx_ring_size = (1 << size);
+	lp->tx_ring_size = entries;
 	lp->tx_mod_mask = lp->tx_ring_size - 1;
 	lp->tx_len_bits = (size << 12);
 	lp->tx_ring = new_tx_ring;
@@ -523,8 +519,7 @@ free_new_lists:
 	kfree(new_dma_addr_list);
 free_new_tx_ring:
 	pci_free_consistent(lp->pci_dev,
-			    sizeof(struct pcnet32_tx_head) *
-			    (1 << size),
+			    sizeof(struct pcnet32_tx_head) * entries,
 			    new_tx_ring,
 			    new_ring_dma_addr);
 }
@@ -548,16 +543,14 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 	struct pcnet32_rx_head *new_rx_ring;
 	struct sk_buff **new_skb_list;
 	int new, overlap;
-	unsigned int entries = 1 << size;
+	unsigned int entries = BIT(size);
 
-	new_rx_ring = pci_zalloc_consistent(lp->pci_dev,
-					    sizeof(struct pcnet32_rx_head) *
-					    entries,
-					    &new_ring_dma_addr);
-	if (new_rx_ring == NULL) {
-		netif_err(lp, drv, dev, "Consistent memory allocation failed\n");
+	new_rx_ring =
+		pci_zalloc_consistent(lp->pci_dev,
+				      sizeof(struct pcnet32_rx_head) * entries,
+				      &new_ring_dma_addr);
+	if (new_rx_ring == NULL)
 		return;
-	}
 
 	new_dma_addr_list = kcalloc(entries, sizeof(dma_addr_t), GFP_ATOMIC);
 	if (!new_dma_addr_list)
