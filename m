From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 04/22] Subject qlge: fix sparse warnings
Date: Fri, 21 Nov 2008 15:21:42 -0800
Message-ID: <20081121232239.233383973@vyatta.com>
References: <20081121232138.343333942@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57012 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754623AbYKUXXR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 18:23:17 -0500
Content-Disposition: inline; filename=glge_sparse.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix sparse warnings and one bug:
    * Several routines can be static
    * Don't lose __iomem annotation
    * fix locking on error path (bug)

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/qlge/qlge_main.c	2008-11-21 14:51:03.000000000 -0800
+++ b/drivers/net/qlge/qlge_main.c	2008-11-21 14:56:50.000000000 -0800
@@ -642,7 +642,7 @@ static void ql_enable_all_completion_int
 
 }
 
-int ql_read_flash_word(struct ql_adapter *qdev, int offset, u32 *data)
+static int ql_read_flash_word(struct ql_adapter *qdev, int offset, u32 *data)
 {
 	int status = 0;
 	/* wait for reg to come ready */
@@ -832,7 +832,7 @@ end:
 }
 
 /* Get the next large buffer. */
-struct bq_desc *ql_get_curr_lbuf(struct rx_ring *rx_ring)
+static struct bq_desc *ql_get_curr_lbuf(struct rx_ring *rx_ring)
 {
 	struct bq_desc *lbq_desc = &rx_ring->lbq[rx_ring->lbq_curr_idx];
 	rx_ring->lbq_curr_idx++;
@@ -843,7 +843,7 @@ struct bq_desc *ql_get_curr_lbuf(struct 
 }
 
 /* Get the next small buffer. */
-struct bq_desc *ql_get_curr_sbuf(struct rx_ring *rx_ring)
+static struct bq_desc *ql_get_curr_sbuf(struct rx_ring *rx_ring)
 {
 	struct bq_desc *sbq_desc = &rx_ring->sbq[rx_ring->sbq_curr_idx];
 	rx_ring->sbq_curr_idx++;
@@ -1166,7 +1166,7 @@ map_error:
 	return NETDEV_TX_BUSY;
 }
 
-void ql_realign_skb(struct sk_buff *skb, int len)
+static void ql_realign_skb(struct sk_buff *skb, int len)
 {
 	void *temp_addr = skb->data;
 
@@ -2069,7 +2069,7 @@ err:
 	return -ENOMEM;
 }
 
-void ql_free_lbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
+static void ql_free_lbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
 	int i;
 	struct bq_desc *lbq_desc;
@@ -2132,7 +2132,7 @@ mem_error:
 	return -ENOMEM;
 }
 
-void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
+static void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
 	int i;
 	struct bq_desc *sbq_desc;
@@ -2467,7 +2467,7 @@ static int ql_start_rx_ring(struct ql_ad
 	rx_ring->sbq_base_indirect_dma = shadow_reg_dma;
 
 	/* PCI doorbell mem area + 0x00 for consumer index register */
-	rx_ring->cnsmr_idx_db_reg = (u32 *) doorbell_area;
+	rx_ring->cnsmr_idx_db_reg = (u32 __iomem *) doorbell_area;
 	rx_ring->cnsmr_idx = 0;
 	rx_ring->curr_entry = rx_ring->cq_base;
 
@@ -2475,10 +2475,10 @@ static int ql_start_rx_ring(struct ql_ad
 	rx_ring->valid_db_reg = doorbell_area + 0x04;
 
 	/* PCI doorbell mem area + 0x18 for large buffer consumer */
-	rx_ring->lbq_prod_idx_db_reg = (u32 *) (doorbell_area + 0x18);
+	rx_ring->lbq_prod_idx_db_reg = (u32 __iomem *) (doorbell_area + 0x18);
 
 	/* PCI doorbell mem area + 0x1c */
-	rx_ring->sbq_prod_idx_db_reg = (u32 *) (doorbell_area + 0x1c);
+	rx_ring->sbq_prod_idx_db_reg = (u32 __iomem *) (doorbell_area + 0x1c);
 
 	memset((void *)cqicb, 0, sizeof(struct cqicb));
 	cqicb->msix_vect = rx_ring->irq;
@@ -2609,7 +2609,7 @@ static int ql_start_tx_ring(struct ql_ad
 	 * Assign doorbell registers for this tx_ring.
 	 */
 	/* TX PCI doorbell mem area for tx producer index */
-	tx_ring->prod_idx_db_reg = (u32 *) doorbell_area;
+	tx_ring->prod_idx_db_reg = (u32 __iomem *) doorbell_area;
 	tx_ring->prod_idx = 0;
 	/* TX PCI doorbell mem area + 0x04 */
 	tx_ring->valid_db_reg = doorbell_area + 0x04;
@@ -3520,6 +3520,7 @@ static int qlge_set_mac_address(struct n
 {
 	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
 	struct sockaddr *addr = p;
+	int ret = 0;
 
 	if (netif_running(ndev))
 		return -EBUSY;
@@ -3532,11 +3533,11 @@ static int qlge_set_mac_address(struct n
 	if (ql_set_mac_addr_reg(qdev, (u8 *) ndev->dev_addr,
 			MAC_ADDR_TYPE_CAM_MAC, qdev->func)) {/* Unicast */
 		QPRINTK(qdev, HW, ERR, "Failed to load MAC address.\n");
-		return -1;
+		ret = -1;
 	}
 	spin_unlock(&qdev->hw_lock);
 
-	return 0;
+	return ret;
 }
 
 static void qlge_tx_timeout(struct net_device *ndev)
@@ -3586,7 +3587,7 @@ static void ql_release_all(struct pci_de
 		qdev->q_workqueue = NULL;
 	}
 	if (qdev->reg_base)
-		iounmap((void *)qdev->reg_base);
+		iounmap(qdev->reg_base);
 	if (qdev->doorbell_area)
 		iounmap(qdev->doorbell_area);
 	pci_release_regions(pdev);

-- 

