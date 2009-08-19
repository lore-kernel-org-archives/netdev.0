From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/7] sky2: dynamic size transmit ring
Date: Tue, 18 Aug 2009 18:17:08 -0700
Message-ID: <20090819011738.838802386@vyatta.com>
References: <20090819011704.685802801@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:50670 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152AbZHSBWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 21:22:45 -0400
Content-Disposition: inline; filename=sky2-tx-size.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate and size transmit ring based on parameters. Saves excess
space and allows configuring larger rings for testing.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-08-18 09:34:30.664368374 -0700
+++ b/drivers/net/sky2.c	2009-08-18 09:34:35.094550982 -0700
@@ -64,10 +64,12 @@
 #define RX_MAX_PENDING		(RX_LE_SIZE/6 - 2)
 #define RX_DEF_PENDING		RX_MAX_PENDING
 
-#define TX_RING_SIZE		512
-#define TX_DEF_PENDING		128
-#define MAX_SKB_TX_LE		(4 + (sizeof(dma_addr_t)/sizeof(u32))*MAX_SKB_FRAGS)
+/* This is the worst case number of transmit list elements for a single skb:
+   VLAN + TSO + CKSUM + Data + skb_frags * DMA */
+#define MAX_SKB_TX_LE	(4 + (sizeof(dma_addr_t)/sizeof(u32))*MAX_SKB_FRAGS)
 #define TX_MIN_PENDING		(MAX_SKB_TX_LE+1)
+#define TX_MAX_PENDING		4096
+#define TX_DEF_PENDING		127
 
 #define STATUS_RING_SIZE	2048	/* 2 ports * (TX + 2*RX) */
 #define STATUS_LE_BYTES		(STATUS_RING_SIZE*sizeof(struct sky2_status_le))
@@ -1000,7 +1002,7 @@ static inline struct sky2_tx_le *get_tx_
 {
 	struct sky2_tx_le *le = sky2->tx_le + *slot;
 
-	*slot = RING_NEXT(*slot, TX_RING_SIZE);
+	*slot = RING_NEXT(*slot, sky2->tx_ring_size);
 	le->ctrl = 0;
 	return le;
 }
@@ -1433,13 +1435,13 @@ static int sky2_up(struct net_device *de
 
 	/* must be power of 2 */
 	sky2->tx_le = pci_alloc_consistent(hw->pdev,
-					   TX_RING_SIZE *
+					   sky2->tx_ring_size *
 					   sizeof(struct sky2_tx_le),
 					   &sky2->tx_le_map);
 	if (!sky2->tx_le)
 		goto err_out;
 
-	sky2->tx_ring = kcalloc(TX_RING_SIZE, sizeof(struct tx_ring_info),
+	sky2->tx_ring = kcalloc(sky2->tx_ring_size, sizeof(struct tx_ring_info),
 				GFP_KERNEL);
 	if (!sky2->tx_ring)
 		goto err_out;
@@ -1491,7 +1493,7 @@ static int sky2_up(struct net_device *de
 		sky2_write16(hw, Q_ADDR(txqaddr[port], Q_AL), ECU_TXFF_LEV);
 
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
-			   TX_RING_SIZE - 1);
+			   sky2->tx_ring_size - 1);
 
 #ifdef SKY2_VLAN_TAG_USED
 	sky2_set_vlan_mode(hw, port, sky2->vlgrp != NULL);
@@ -1520,7 +1522,7 @@ err_out:
 	}
 	if (sky2->tx_le) {
 		pci_free_consistent(hw->pdev,
-				    TX_RING_SIZE * sizeof(struct sky2_tx_le),
+				    sky2->tx_ring_size * sizeof(struct sky2_tx_le),
 				    sky2->tx_le, sky2->tx_le_map);
 		sky2->tx_le = NULL;
 	}
@@ -1533,15 +1535,15 @@ err_out:
 }
 
 /* Modular subtraction in ring */
-static inline int tx_dist(unsigned tail, unsigned head)
+static inline int tx_inuse(const struct sky2_port *sky2)
 {
-	return (head - tail) & (TX_RING_SIZE - 1);
+	return (sky2->tx_prod - sky2->tx_cons) & (sky2->tx_ring_size - 1);
 }
 
 /* Number of list elements available for next tx */
 static inline int tx_avail(const struct sky2_port *sky2)
 {
-	return sky2->tx_pending - tx_dist(sky2->tx_cons, sky2->tx_prod);
+	return sky2->tx_pending - tx_inuse(sky2);
 }
 
 /* Estimate of number of transmit list elements required */
@@ -1717,7 +1719,7 @@ static int sky2_xmit_frame(struct sk_buf
 	return NETDEV_TX_OK;
 
 mapping_unwind:
-	for (i = sky2->tx_prod; i != slot; i = RING_NEXT(i, TX_RING_SIZE)) {
+	for (i = sky2->tx_prod; i != slot; i = RING_NEXT(i, sky2->tx_ring_size)) {
 		le = sky2->tx_le + i;
 		re = sky2->tx_ring + i;
 
@@ -1760,10 +1762,10 @@ static void sky2_tx_complete(struct sky2
 	struct pci_dev *pdev = sky2->hw->pdev;
 	unsigned idx;
 
-	BUG_ON(done >= TX_RING_SIZE);
+	BUG_ON(done >= sky2->tx_ring_size);
 
 	for (idx = sky2->tx_cons; idx != done;
-	     idx = RING_NEXT(idx, TX_RING_SIZE)) {
+	     idx = RING_NEXT(idx, sky2->tx_ring_size)) {
 		struct sky2_tx_le *le = sky2->tx_le + idx;
 		struct tx_ring_info *re = sky2->tx_ring + idx;
 
@@ -1799,7 +1801,7 @@ static void sky2_tx_complete(struct sky2
 			else
 				dev_kfree_skb_any(skb);
 
-			sky2->tx_next = RING_NEXT(idx, TX_RING_SIZE);
+			sky2->tx_next = RING_NEXT(idx, sky2->tx_ring_size);
 		}
 	}
 
@@ -1907,7 +1909,7 @@ static int sky2_down(struct net_device *
 	kfree(sky2->rx_ring);
 
 	pci_free_consistent(hw->pdev,
-			    TX_RING_SIZE * sizeof(struct sky2_tx_le),
+			    sky2->tx_ring_size * sizeof(struct sky2_tx_le),
 			    sky2->tx_le, sky2->tx_le_map);
 	kfree(sky2->tx_ring);
 
@@ -2517,7 +2519,6 @@ static int sky2_status_intr(struct sky2_
 
 		case OP_TXINDEXLE:
 			/* TX index reports status for both ports */
-			BUILD_BUG_ON(TX_RING_SIZE > 0x1000);
 			sky2_tx_done(hw->dev[0], status & 0xfff);
 			if (hw->dev[1])
 				sky2_tx_done(hw->dev[1],
@@ -3669,7 +3670,7 @@ static int sky2_set_coalesce(struct net_
 	    ecmd->rx_coalesce_usecs_irq > tmax)
 		return -EINVAL;
 
-	if (ecmd->tx_max_coalesced_frames >= TX_RING_SIZE-1)
+	if (ecmd->tx_max_coalesced_frames >= sky2->tx_ring_size-1)
 		return -EINVAL;
 	if (ecmd->rx_max_coalesced_frames > RX_MAX_PENDING)
 		return -EINVAL;
@@ -3713,7 +3714,7 @@ static void sky2_get_ringparam(struct ne
 	ering->rx_max_pending = RX_MAX_PENDING;
 	ering->rx_mini_max_pending = 0;
 	ering->rx_jumbo_max_pending = 0;
-	ering->tx_max_pending = TX_RING_SIZE - 1;
+	ering->tx_max_pending = TX_MAX_PENDING;
 
 	ering->rx_pending = sky2->rx_pending;
 	ering->rx_mini_pending = 0;
@@ -3728,14 +3729,15 @@ static int sky2_set_ringparam(struct net
 
 	if (ering->rx_pending > RX_MAX_PENDING ||
 	    ering->rx_pending < 8 ||
-	    ering->tx_pending < MAX_SKB_TX_LE ||
-	    ering->tx_pending > TX_RING_SIZE - 1)
+	    ering->tx_pending < TX_MIN_PENDING ||
+	    ering->tx_pending > TX_MAX_PENDING)
 		return -EINVAL;
 
 	sky2_detach(dev);
 
 	sky2->rx_pending = ering->rx_pending;
 	sky2->tx_pending = ering->tx_pending;
+	sky2->tx_ring_size = roundup_pow_of_two(sky2->tx_pending+1);
 
 	return sky2_reattach(dev);
 }
@@ -4105,8 +4107,8 @@ static int sky2_debug_show(struct seq_fi
 
 	/* Dump contents of tx ring */
 	sop = 1;
-	for (idx = sky2->tx_next; idx != sky2->tx_prod && idx < TX_RING_SIZE;
-	     idx = RING_NEXT(idx, TX_RING_SIZE)) {
+	for (idx = sky2->tx_next; idx != sky2->tx_prod && idx < sky2->tx_ring_size;
+	     idx = RING_NEXT(idx, sky2->tx_ring_size)) {
 		const struct sky2_tx_le *le = sky2->tx_le + idx;
 		u32 a = le32_to_cpu(le->addr);
 
@@ -4315,7 +4317,9 @@ static __devinit struct net_device *sky2
 	sky2->wol = wol;
 
 	spin_lock_init(&sky2->phy_lock);
+
 	sky2->tx_pending = TX_DEF_PENDING;
+	sky2->tx_ring_size = roundup_pow_of_two(TX_DEF_PENDING+1);
 	sky2->rx_pending = RX_DEF_PENDING;
 
 	hw->dev[port] = dev;
--- a/drivers/net/sky2.h	2009-08-18 09:33:15.491426771 -0700
+++ b/drivers/net/sky2.h	2009-08-18 09:34:35.095551088 -0700
@@ -2011,6 +2011,7 @@ struct sky2_port {
 
 	struct tx_ring_info  *tx_ring;
 	struct sky2_tx_le    *tx_le;
+	u16		     tx_ring_size;
 	u16		     tx_cons;		/* next le to check */
 	u16		     tx_prod;		/* next le to use */
 	u16		     tx_next;		/* debug only */

-- 

