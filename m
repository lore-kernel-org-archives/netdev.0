From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 12/41]bnx2x: Removing redundant device parameters
Date: Thu, 12 Feb 2009 20:36:49 +0200
Message-ID: <1234463809.1863.144.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2663 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758086AbZBLShM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:37:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 12/41]bnx2x: Removing redundant device parameters

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    5 -----
 drivers/net/bnx2x_main.c |   19 +++++++++----------
 2 files changed, 9 insertions(+), 15 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index a18ace0..2397a89 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -525,8 +525,6 @@ struct bnx2x_common {
 	u32			hw_config;
 
 	u32			bc_ver;
-
-	char			*name;
 };
 
 
@@ -798,7 +796,6 @@ struct bnx2x {
 #endif
 
 	u32			rx_csum;
-	u32			rx_offset;
 	u32			rx_buf_size;
 #define ETH_OVREHEAD			(ETH_HLEN + 8)	/* 8 for CRC + VLAN */
 #define ETH_MIN_PACKET_SIZE		60
@@ -819,7 +816,6 @@ struct bnx2x {
 	u16			def_att_idx;
 	u32			attn_state;
 	struct attn_route	attn_group[MAX_DYNAMIC_ATTN_GRPS];
-	u32			nig_mask;
 
 	/* slow path ring */
 	struct eth_spe		*spq;
@@ -869,7 +865,6 @@ struct bnx2x {
 	struct work_struct	reset_task;
 
 	struct timer_list	timer;
-	int			timer_interval;
 	int			current_interval;
 
 	u16			fw_seq;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index f448658..9c40b02 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -1089,8 +1089,7 @@ static void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
 
 	pci_dma_sync_single_for_device(bp->pdev,
 				       pci_unmap_addr(cons_rx_buf, mapping),
-				       bp->rx_offset + RX_COPY_THRESH,
-				       PCI_DMA_FROMDEVICE);
+				       RX_COPY_THRESH, PCI_DMA_FROMDEVICE);
 
 	prod_rx_buf->skb = cons_rx_buf->skb;
 	pci_unmap_addr_set(prod_rx_buf, mapping,
@@ -2403,6 +2402,7 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 	u32 nig_int_mask_addr = port ? NIG_REG_MASK_INTERRUPT_PORT1 :
 				       NIG_REG_MASK_INTERRUPT_PORT0;
 	u32 aeu_mask;
+	u32 nig_mask = 0;
 
 	if (bp->attn_state & asserted)
 		BNX2X_ERR("IGU ERROR\n");
@@ -2428,7 +2428,7 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 			bnx2x_acquire_phy_lock(bp);
 
 			/* save nig interrupt mask */
-			bp->nig_mask = REG_RD(bp, nig_int_mask_addr);
+			nig_mask = REG_RD(bp, nig_int_mask_addr);
 			REG_WR(bp, nig_int_mask_addr, 0);
 
 			bnx2x_link_attn(bp);
@@ -2483,7 +2483,7 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 
 	/* now set back the mask */
 	if (asserted & ATTN_NIG_FOR_FUNC) {
-		REG_WR(bp, nig_int_mask_addr, bp->nig_mask);
+		REG_WR(bp, nig_int_mask_addr, nig_mask);
 		bnx2x_release_phy_lock(bp);
 	}
 }
@@ -4358,7 +4358,7 @@ static void bnx2x_init_rx_rings(struct bnx2x *bp)
 	u16 ring_prod, cqe_ring_prod;
 	int i, j;
 
-	bp->rx_buf_size += bp->rx_offset + ETH_OVREHEAD + BNX2X_RX_ALIGN;
+	bp->rx_buf_size = bp->dev->mtu + ETH_OVREHEAD + BNX2X_RX_ALIGN;
 	DP(NETIF_MSG_IFUP,
 	   "mtu %d  rx_buf_size %d\n", bp->dev->mtu, bp->rx_buf_size);
 
@@ -7947,6 +7947,7 @@ static int __devinit bnx2x_get_hwinfo(struct bnx2x *bp)
 static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 {
 	int func = BP_FUNC(bp);
+	int timer_interval;
 	int rc;
 
 	/* Disable interrupt handling until HW is initialized */
@@ -7994,13 +7995,12 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	bp->rx_ring_size = MAX_RX_AVAIL;
 
 	bp->rx_csum = 1;
-	bp->rx_offset = 0;
 
 	bp->tx_ticks = 50;
 	bp->rx_ticks = 25;
 
-	bp->timer_interval = (CHIP_REV_IS_SLOW(bp) ? 5*HZ : HZ);
-	bp->current_interval = (poll ? poll : bp->timer_interval);
+	timer_interval = (CHIP_REV_IS_SLOW(bp) ? 5*HZ : HZ);
+	bp->current_interval = (poll ? poll : timer_interval);
 
 	init_timer(&bp->timer);
 	bp->timer.expires = jiffies + bp->current_interval;
@@ -10828,9 +10828,8 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 		goto init_one_exit;
 	}
 
-	bp->common.name = board_info[ent->driver_data].name;
 	printk(KERN_INFO "%s: %s (%c%d) PCI-E x%d %s found at mem %lx,"
-	       " IRQ %d, ", dev->name, bp->common.name,
+	       " IRQ %d, ", dev->name, board_info[ent->driver_data].name,
 	       (CHIP_REV(bp) >> 12) + 'A', (CHIP_METAL(bp) >> 4),
 	       bnx2x_get_pcie_width(bp),
 	       (bnx2x_get_pcie_speed(bp) == 2) ? "5GHz (Gen2)" : "2.5GHz",
-- 
1.5.4.3




