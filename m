From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 8/9][BNX2]: Enable new tx ring.
Date: Thu, 20 Dec 2007 12:33:35 -0800
Message-ID: <1198182815.9163.34.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3907 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752877AbXLTTs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Dec 2007 14:48:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Enable new tx ring.

Enable new tx ring and add new MSIX handler and NAPI poll function
for the new tx ring.  Enable MSIX when the hardware supports it.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index a4ed6ca..3745fc8 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -598,7 +598,7 @@ bnx2_alloc_mem(struct bnx2 *bp)
 		for (i = 1; i < BNX2_MAX_MSIX_VEC; i++) {
 			struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
 
-			bnapi->status_blk = (void *)
+			bnapi->status_blk_msix = (void *)
 				((unsigned long) bp->status_blk +
 				 BNX2_SBLK_MSIX_ALIGN_SIZE * i);
 			bnapi->int_num = i << 24;
@@ -2388,10 +2388,11 @@ bnx2_get_hw_tx_cons(struct bnx2_napi *bnapi)
 	return cons;
 }
 
-static void
-bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi)
+static int
+bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi, int budget)
 {
 	u16 hw_cons, sw_cons, sw_ring_cons;
+	int tx_pkt = 0;
 
 	hw_cons = bnx2_get_hw_tx_cons(bnapi);
 	sw_cons = bnapi->tx_cons;
@@ -2442,6 +2443,9 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi)
 		sw_cons = NEXT_TX_BD(sw_cons);
 
 		dev_kfree_skb(skb);
+		tx_pkt++;
+		if (tx_pkt == budget)
+			break;
 
 		hw_cons = bnx2_get_hw_tx_cons(bnapi);
 	}
@@ -2463,6 +2467,7 @@ bnx2_tx_int(struct bnx2 *bp, struct bnx2_napi *bnapi)
 			netif_wake_queue(bp->dev);
 		netif_tx_unlock(bp->dev);
 	}
+	return tx_pkt;
 }
 
 static void
@@ -2875,6 +2880,23 @@ bnx2_interrupt(int irq, void *dev_instance)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t
+bnx2_tx_msix(int irq, void *dev_instance)
+{
+	struct net_device *dev = dev_instance;
+	struct bnx2 *bp = netdev_priv(dev);
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[BNX2_TX_VEC];
+
+	prefetch(bnapi->status_blk_msix);
+
+	/* Return here if interrupt is disabled. */
+	if (unlikely(atomic_read(&bp->intr_sem) != 0))
+		return IRQ_HANDLED;
+
+	netif_rx_schedule(dev, &bnapi->napi);
+	return IRQ_HANDLED;
+}
+
 #define STATUS_ATTN_EVENTS	(STATUS_ATTN_BITS_LINK_STATE | \
 				 STATUS_ATTN_BITS_TIMER_ABORT)
 
@@ -2895,6 +2917,29 @@ bnx2_has_work(struct bnx2_napi *bnapi)
 	return 0;
 }
 
+static int bnx2_tx_poll(struct napi_struct *napi, int budget)
+{
+	struct bnx2_napi *bnapi = container_of(napi, struct bnx2_napi, napi);
+	struct bnx2 *bp = bnapi->bp;
+	int work_done = 0;
+	struct status_block_msix *sblk = bnapi->status_blk_msix;
+
+	do {
+		work_done += bnx2_tx_int(bp, bnapi, budget - work_done);
+		if (unlikely(work_done >= budget))
+			return work_done;
+
+		bnapi->last_status_idx = sblk->status_idx;
+		rmb();
+	} while (bnx2_get_hw_tx_cons(bnapi) != bnapi->hw_tx_cons);
+
+	netif_rx_complete(bp->dev, napi);
+	REG_WR(bp, BNX2_PCICFG_INT_ACK_CMD, bnapi->int_num |
+	       BNX2_PCICFG_INT_ACK_CMD_INDEX_VALID |
+	       bnapi->last_status_idx);
+	return work_done;
+}
+
 static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
 			  int work_done, int budget)
 {
@@ -2916,7 +2961,7 @@ static int bnx2_poll_work(struct bnx2 *bp, struct bnx2_napi *bnapi,
 	}
 
 	if (bnx2_get_hw_tx_cons(bnapi) != bnapi->hw_tx_cons)
-		bnx2_tx_int(bp, bnapi);
+		bnx2_tx_int(bp, bnapi, 0);
 
 	if (bnx2_get_hw_rx_cons(bnapi) != bnapi->rx_cons)
 		work_done += bnx2_rx_int(bp, bnapi, budget - work_done);
@@ -5399,10 +5444,35 @@ bnx2_free_irq(struct bnx2 *bp)
 static void
 bnx2_enable_msix(struct bnx2 *bp)
 {
+	int i, rc;
+	struct msix_entry msix_ent[BNX2_MAX_MSIX_VEC];
+
 	bnx2_setup_msix_tbl(bp);
 	REG_WR(bp, BNX2_PCI_MSIX_CONTROL, BNX2_MAX_MSIX_HW_VEC - 1);
 	REG_WR(bp, BNX2_PCI_MSIX_TBL_OFF_BIR, BNX2_PCI_GRC_WINDOW2_BASE);
 	REG_WR(bp, BNX2_PCI_MSIX_PBA_OFF_BIT, BNX2_PCI_GRC_WINDOW3_BASE);
+
+	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
+		msix_ent[i].entry = i;
+		msix_ent[i].vector = 0;
+	}
+
+	rc = pci_enable_msix(bp->pdev, msix_ent, BNX2_MAX_MSIX_VEC);
+	if (rc != 0)
+		return;
+
+	bp->irq_tbl[BNX2_BASE_VEC].handler = bnx2_msi_1shot;
+	bp->irq_tbl[BNX2_TX_VEC].handler = bnx2_tx_msix;
+
+	strcpy(bp->irq_tbl[BNX2_BASE_VEC].name, bp->dev->name);
+	strcat(bp->irq_tbl[BNX2_BASE_VEC].name, "-base");
+	strcpy(bp->irq_tbl[BNX2_TX_VEC].name, bp->dev->name);
+	strcat(bp->irq_tbl[BNX2_TX_VEC].name, "-tx");
+
+	bp->irq_nvecs = BNX2_MAX_MSIX_VEC;
+	bp->flags |= USING_MSIX_FLAG | ONE_SHOT_MSI_FLAG;
+	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++)
+		bp->irq_tbl[i].vector = msix_ent[i].vector;
 }
 
 static void
@@ -5504,9 +5574,10 @@ bnx2_open(struct net_device *dev)
 			bnx2_enable_int(bp);
 		}
 	}
-	if (bp->flags & USING_MSI_FLAG) {
+	if (bp->flags & USING_MSI_FLAG)
 		printk(KERN_INFO PFX "%s: using MSI\n", dev->name);
-	}
+	else if (bp->flags & USING_MSIX_FLAG)
+		printk(KERN_INFO PFX "%s: using MSIX\n", dev->name);
 
 	netif_start_queue(dev);
 
@@ -5570,7 +5641,7 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 len, vlan_tag_flags, last_frag, mss;
 	u16 prod, ring_prod;
 	int i;
-	struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
+	struct bnx2_napi *bnapi = &bp->bnx2_napi[bp->tx_vec];
 
 	if (unlikely(bnx2_tx_avail(bp, bnapi) <
 	    (skb_shinfo(skb)->nr_frags + 1))) {
@@ -7253,6 +7324,8 @@ bnx2_init_napi(struct bnx2 *bp)
 		bnapi->bp = bp;
 	}
 	netif_napi_add(bp->dev, &bp->bnx2_napi[0].napi, bnx2_poll, 64);
+	netif_napi_add(bp->dev, &bp->bnx2_napi[BNX2_TX_VEC].napi, bnx2_tx_poll,
+		       64);
 }
 
 static int __devinit
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 68fb590..09bd665 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6528,7 +6528,7 @@ struct flash_spec {
 };
 
 #define BNX2_MAX_MSIX_HW_VEC	9
-#define BNX2_MAX_MSIX_VEC	1
+#define BNX2_MAX_MSIX_VEC	2
 #define BNX2_BASE_VEC		0
 #define BNX2_TX_VEC		1
 #define BNX2_TX_INT_NUM	(BNX2_TX_VEC << BNX2_PCICFG_INT_ACK_CMD_INT_NUM_SHIFT)


