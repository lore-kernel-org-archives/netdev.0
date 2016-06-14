From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 3/9] liquidio:Scatter gather list per IQ
Date: Tue, 14 Jun 2016 16:54:45 -0700
Message-ID: <1465948491-10541-4-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0070.outbound.protection.outlook.com ([65.55.169.70]:49440
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751439AbcFOAKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 20:10:44 -0400
In-Reply-To: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to allocate and manage scatter gather lists per
input queue(iq's) and remove queue's interdependence.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 214 ++++++++++++++-------
 .../net/ethernet/cavium/liquidio/octeon_network.h  |   8 +-
 2 files changed, 149 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 3477a3c..0daa89a 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -166,6 +166,8 @@ struct octnic_gather {
 	 *  received from the IP layer.
 	 */
 	struct octeon_sg_entry *sg;
+
+	u64 sg_dma_ptr;
 };
 
 /** This structure is used by NIC driver to store information required
@@ -791,64 +793,116 @@ static inline struct list_head *list_delete_head(struct list_head *root)
 }
 
 /**
- * \brief Delete gather list
+ * \brief Delete gather lists
  * @param lio per-network private data
  */
-static void delete_glist(struct lio *lio)
+static void delete_glists(struct lio *lio)
 {
 	struct octnic_gather *g;
+	int i;
 
-	do {
-		g = (struct octnic_gather *)
-		    list_delete_head(&lio->glist);
-		if (g) {
-			if (g->sg)
-				kfree((void *)((unsigned long)g->sg -
-						g->adjust));
-			kfree(g);
-		}
-	} while (g);
+	if (!lio->glist)
+		return;
+
+	for (i = 0; i < lio->linfo.num_txpciq; i++) {
+		do {
+			g = (struct octnic_gather *)
+				list_delete_head(&lio->glist[i]);
+			if (g) {
+				if (g->sg) {
+					dma_unmap_single(&lio->oct_dev->
+							 pci_dev->dev,
+							 g->sg_dma_ptr,
+							 g->sg_size,
+							 DMA_TO_DEVICE);
+					kfree((void *)((unsigned long)g->sg -
+						       g->adjust));
+				}
+				kfree(g);
+			}
+		} while (g);
+	}
+
+	kfree((void *)lio->glist);
 }
 
 /**
- * \brief Setup gather list
+ * \brief Setup gather lists
  * @param lio per-network private data
  */
-static int setup_glist(struct lio *lio)
+static int setup_glists(struct octeon_device *oct, struct lio *lio, int num_iqs)
 {
-	int i;
+	int i, j;
 	struct octnic_gather *g;
 
-	INIT_LIST_HEAD(&lio->glist);
+	lio->glist_lock = kcalloc(num_iqs, sizeof(*lio->glist_lock),
+				  GFP_KERNEL);
+	if (!lio->glist_lock)
+		return 1;
 
-	for (i = 0; i < lio->tx_qsize; i++) {
-		g = kzalloc(sizeof(*g), GFP_KERNEL);
-		if (!g)
-			break;
+	lio->glist = kcalloc(num_iqs, sizeof(*lio->glist),
+			     GFP_KERNEL);
+	if (!lio->glist) {
+		kfree((void *)lio->glist_lock);
+		return 1;
+	}
 
-		g->sg_size =
-			((ROUNDUP4(OCTNIC_MAX_SG) >> 2) * OCT_SG_ENTRY_SIZE);
+	for (i = 0; i < num_iqs; i++) {
+		int numa_node = cpu_to_node(i % num_online_cpus());
 
-		g->sg = kmalloc(g->sg_size + 8, GFP_KERNEL);
-		if (!g->sg) {
-			kfree(g);
-			break;
+		spin_lock_init(&lio->glist_lock[i]);
+
+		INIT_LIST_HEAD(&lio->glist[i]);
+
+		for (j = 0; j < lio->tx_qsize; j++) {
+			g = kzalloc_node(sizeof(*g), GFP_KERNEL,
+					 numa_node);
+			if (!g)
+				g = kzalloc(sizeof(*g), GFP_KERNEL);
+			if (!g)
+				break;
+
+			g->sg_size = ((ROUNDUP4(OCTNIC_MAX_SG) >> 2) *
+				      OCT_SG_ENTRY_SIZE);
+
+			g->sg = kmalloc_node(g->sg_size + 8,
+					     GFP_KERNEL, numa_node);
+			if (!g->sg)
+				g->sg = kmalloc(g->sg_size + 8, GFP_KERNEL);
+			if (!g->sg) {
+				kfree(g);
+				break;
+			}
+
+			/* The gather component should be aligned on 64-bit
+			 * boundary
+			 */
+			if (((unsigned long)g->sg) & 7) {
+				g->adjust = 8 - (((unsigned long)g->sg) & 7);
+				g->sg = (struct octeon_sg_entry *)
+					((unsigned long)g->sg + g->adjust);
+			}
+			g->sg_dma_ptr = dma_map_single(&oct->pci_dev->dev,
+						       g->sg, g->sg_size,
+						       DMA_TO_DEVICE);
+			if (dma_mapping_error(&oct->pci_dev->dev,
+					      g->sg_dma_ptr)) {
+				kfree((void *)((unsigned long)g->sg -
+					       g->adjust));
+				kfree(g);
+				break;
+			}
+
+			list_add_tail(&g->list, &lio->glist[i]);
 		}
 
-		/* The gather component should be aligned on 64-bit boundary */
-		if (((unsigned long)g->sg) & 7) {
-			g->adjust = 8 - (((unsigned long)g->sg) & 7);
-			g->sg = (struct octeon_sg_entry *)
-				((unsigned long)g->sg + g->adjust);
+		if (j != lio->tx_qsize) {
+			delete_glists(lio);
+			return 1;
 		}
-		list_add_tail(&g->list, &lio->glist);
 	}
 
-	if (i == lio->tx_qsize)
-		return 0;
-
-	delete_glist(lio);
-	return 1;
+	return 0;
 }
 
 /**
@@ -1209,7 +1263,7 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_REGISTERED)
 		unregister_netdev(netdev);
 
-	delete_glist(lio);
+	delete_glists(lio);
 
 	free_netdev(netdev);
 
@@ -1331,6 +1385,16 @@ static int octeon_pci_os_setup(struct octeon_device *oct)
 	return 0;
 }
 
+static inline int skb_iq(struct lio *lio, struct sk_buff *skb)
+{
+	int q = 0;
+
+	if (netif_is_multiqueue(lio->netdev))
+		q = skb->queue_mapping % lio->linfo.num_txpciq;
+
+	return q;
+}
+
 /**
  * \brief Check Tx queue state for a given network buffer
  * @param lio per-network private data
@@ -1388,7 +1452,7 @@ static void free_netsgbuf(void *buf)
 	struct sk_buff *skb;
 	struct lio *lio;
 	struct octnic_gather *g;
-	int i, frags;
+	int i, frags, iq;
 
 	finfo = (struct octnet_buf_free_info *)buf;
 	skb = finfo->skb;
@@ -1410,13 +1474,13 @@ static void free_netsgbuf(void *buf)
 		i++;
 	}
 
-	dma_unmap_single(&lio->oct_dev->pci_dev->dev,
-			 finfo->dptr, g->sg_size,
-			 DMA_TO_DEVICE);
+	dma_sync_single_for_cpu(&lio->oct_dev->pci_dev->dev,
+				g->sg_dma_ptr, g->sg_size, DMA_TO_DEVICE);
 
-	spin_lock(&lio->lock);
-	list_add_tail(&g->list, &lio->glist);
-	spin_unlock(&lio->lock);
+	iq = skb_iq(lio, skb);
+	spin_lock(&lio->glist_lock[iq]);
+	list_add_tail(&g->list, &lio->glist[iq]);
+	spin_unlock(&lio->glist_lock[iq]);
 
 	check_txq_state(lio, skb);     /* mq support: sub-queue state check */
 
@@ -1434,7 +1498,7 @@ static void free_netsgbuf_with_resp(void *buf)
 	struct sk_buff *skb;
 	struct lio *lio;
 	struct octnic_gather *g;
-	int i, frags;
+	int i, frags, iq;
 
 	sc = (struct octeon_soft_command *)buf;
 	skb = (struct sk_buff *)sc->callback_arg;
@@ -1458,13 +1522,14 @@ static void free_netsgbuf_with_resp(void *buf)
 		i++;
 	}
 
-	dma_unmap_single(&lio->oct_dev->pci_dev->dev,
-			 finfo->dptr, g->sg_size,
-			 DMA_TO_DEVICE);
+	dma_sync_single_for_cpu(&lio->oct_dev->pci_dev->dev,
+				g->sg_dma_ptr, g->sg_size, DMA_TO_DEVICE);
 
-	spin_lock(&lio->lock);
-	list_add_tail(&g->list, &lio->glist);
-	spin_unlock(&lio->lock);
+	iq = skb_iq(lio, skb);
+
+	spin_lock(&lio->glist_lock[iq]);
+	list_add_tail(&g->list, &lio->glist[iq]);
+	spin_unlock(&lio->glist_lock[iq]);
 
 	/* Don't free the skb yet */
 
@@ -2683,7 +2748,8 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	struct oct_iq_stats *stats;
 	int status = 0;
 	int q_idx = 0, iq_no = 0;
-	int xmit_more;
+	int xmit_more, j;
+	u64 dptr = 0;
 	u32 tag = 0;
 
 	lio = GET_LIO(netdev);
@@ -2826,9 +2892,10 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 		struct skb_frag_struct *frag;
 		struct octnic_gather *g;
 
-		spin_lock(&lio->lock);
-		g = (struct octnic_gather *)list_delete_head(&lio->glist);
-		spin_unlock(&lio->lock);
+		spin_lock(&lio->glist_lock[q_idx]);
+		g = (struct octnic_gather *)
+			list_delete_head(&lio->glist[q_idx]);
+		spin_unlock(&lio->glist_lock[q_idx]);
 
 		if (!g) {
 			netif_info(lio, tx_err, lio->netdev,
@@ -2865,21 +2932,31 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 					     frag->size,
 					     DMA_TO_DEVICE);
 
+			if (dma_mapping_error(&oct->pci_dev->dev,
+					      g->sg[i >> 2].ptr[i & 3])) {
+				dma_unmap_single(&oct->pci_dev->dev,
+						 g->sg[0].ptr[0],
+						 skb->len - skb->data_len,
+						 DMA_TO_DEVICE);
+				for (j = 1; j < i; j++) {
+					frag = &skb_shinfo(skb)->frags[j - 1];
+					dma_unmap_page(&oct->pci_dev->dev,
+						       g->sg[j >> 2].ptr[j & 3],
+						       frag->size,
+						       DMA_TO_DEVICE);
+				}
+				dev_err(&oct->pci_dev->dev, "%s DMA mapping error 3\n",
+					__func__);
+				return NETDEV_TX_BUSY;
+			}
+
 			add_sg_size(&g->sg[(i >> 2)], frag->size, (i & 3));
 			i++;
 		}
 
-		ndata.cmd.dptr = dma_map_single(&oct->pci_dev->dev,
-						g->sg, g->sg_size,
-						DMA_TO_DEVICE);
-		if (dma_mapping_error(&oct->pci_dev->dev, ndata.cmd.dptr)) {
-			dev_err(&oct->pci_dev->dev, "%s DMA mapping error 3\n",
-				__func__);
-			dma_unmap_single(&oct->pci_dev->dev, g->sg[0].ptr[0],
-					 skb->len - skb->data_len,
-					 DMA_TO_DEVICE);
-			return NETDEV_TX_BUSY;
-		}
+		dma_sync_single_for_device(&oct->pci_dev->dev, g->sg_dma_ptr,
+					   g->sg_size, DMA_TO_DEVICE);
+		dptr = g->sg_dma_ptr;
 
 		finfo->dptr = ndata.cmd.dptr;
 		finfo->g = g;
@@ -3301,7 +3378,6 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		lio->oct_dev = octeon_dev;
 		lio->octprops = props;
 		lio->netdev = netdev;
-		spin_lock_init(&lio->lock);
 
 		dev_dbg(&octeon_dev->pci_dev->dev,
 			"if%d gmx: %d hw_addr: 0x%llx\n", i,
@@ -3331,7 +3407,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		lio->tx_qsize = octeon_get_tx_qsize(octeon_dev, lio->txq);
 		lio->rx_qsize = octeon_get_rx_qsize(octeon_dev, lio->rxq);
 
-		if (setup_glist(lio)) {
+		if (setup_glists(octeon_dev, lio, num_iqueues)) {
 			dev_err(&octeon_dev->pci_dev->dev,
 				"Gather list allocation failed\n");
 			goto setup_nic_dev_fail;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index b3abe58..0a50bac 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -48,11 +48,11 @@ struct lio {
 	 */
 	int rxq;
 
-	/** Guards the glist */
-	spinlock_t lock;
+	/** Guards each glist */
+	spinlock_t *glist_lock;
 
-	/** Linked list of gather components */
-	struct list_head glist;
+	/** Array of gather component linked lists */
+	struct list_head *glist;
 
 	/** Pointer to the NIC properties for the Octeon device this network
 	 *  interface is associated with.
-- 
1.8.3.1
