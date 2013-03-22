From: Geoff Levand <geoff@infradead.org>
Subject: [PATCH v2] net: Fix p3_gelic_net sparse warnings
Date: Thu, 21 Mar 2013 17:06:59 -0700
Message-ID: <1363910819.1075.60.camel@smoke>
References: <1363898133.1075.43.camel@smoke>
	 <20130321.171723.2170130040090928680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:40508
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932089Ab3CVAHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 20:07:07 -0400
In-Reply-To: <20130321.171723.2170130040090928680.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rearrange routines to avoid local declarations and remove
unnecessary inline tags.  No functional changes.

Fixes sparse warnings like these:

  ps3_gelic_net.c: error: marked inline, but without a definition

Signed-off-by: Geoff Levand <geoff@infradead.org>
---

V2: 
* Rearrange routines to avoid local declarations.
* Remove unnecessary inline tags.

Hi Dave,

Cleaned up as suggested.  Please apply.

-Geoff

---
 drivers/net/ethernet/toshiba/ps3_gelic_net.c |  240 +++++++++++++-------------
 1 file changed, 117 insertions(+), 123 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/ps3_gelic_net.c b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
index 445c059..ad32af6 100644
--- a/drivers/net/ethernet/toshiba/ps3_gelic_net.c
+++ b/drivers/net/ethernet/toshiba/ps3_gelic_net.c
@@ -58,13 +58,6 @@ MODULE_DESCRIPTION("Gelic Network driver");
 MODULE_LICENSE("GPL");
 
 
-static inline void gelic_card_enable_rxdmac(struct gelic_card *card);
-static inline void gelic_card_disable_rxdmac(struct gelic_card *card);
-static inline void gelic_card_disable_txdmac(struct gelic_card *card);
-static inline void gelic_card_reset_chain(struct gelic_card *card,
-					  struct gelic_descr_chain *chain,
-					  struct gelic_descr *start_descr);
-
 /* set irq_mask */
 int gelic_card_set_irq_mask(struct gelic_card *card, u64 mask)
 {
@@ -78,12 +71,12 @@ int gelic_card_set_irq_mask(struct gelic_card *card, u64 mask)
 	return status;
 }
 
-static inline void gelic_card_rx_irq_on(struct gelic_card *card)
+static void gelic_card_rx_irq_on(struct gelic_card *card)
 {
 	card->irq_mask |= GELIC_CARD_RXINT;
 	gelic_card_set_irq_mask(card, card->irq_mask);
 }
-static inline void gelic_card_rx_irq_off(struct gelic_card *card)
+static void gelic_card_rx_irq_off(struct gelic_card *card)
 {
 	card->irq_mask &= ~GELIC_CARD_RXINT;
 	gelic_card_set_irq_mask(card, card->irq_mask);
@@ -127,6 +120,120 @@ static int gelic_card_set_link_mode(struct gelic_card *card, int mode)
 	return 0;
 }
 
+/**
+ * gelic_card_disable_txdmac - disables the transmit DMA controller
+ * @card: card structure
+ *
+ * gelic_card_disable_txdmac terminates processing on the DMA controller by
+ * turing off DMA and issuing a force end
+ */
+static void gelic_card_disable_txdmac(struct gelic_card *card)
+{
+	int status;
+
+	/* this hvc blocks until the DMA in progress really stopped */
+	status = lv1_net_stop_tx_dma(bus_id(card), dev_id(card));
+	if (status)
+		dev_err(ctodev(card),
+			"lv1_net_stop_tx_dma failed, status=%d\n", status);
+}
+
+/**
+ * gelic_card_enable_rxdmac - enables the receive DMA controller
+ * @card: card structure
+ *
+ * gelic_card_enable_rxdmac enables the DMA controller by setting RX_DMA_EN
+ * in the GDADMACCNTR register
+ */
+static void gelic_card_enable_rxdmac(struct gelic_card *card)
+{
+	int status;
+
+#ifdef DEBUG
+	if (gelic_descr_get_status(card->rx_chain.head) !=
+	    GELIC_DESCR_DMA_CARDOWNED) {
+		printk(KERN_ERR "%s: status=%x\n", __func__,
+		       be32_to_cpu(card->rx_chain.head->dmac_cmd_status));
+		printk(KERN_ERR "%s: nextphy=%x\n", __func__,
+		       be32_to_cpu(card->rx_chain.head->next_descr_addr));
+		printk(KERN_ERR "%s: head=%p\n", __func__,
+		       card->rx_chain.head);
+	}
+#endif
+	status = lv1_net_start_rx_dma(bus_id(card), dev_id(card),
+				card->rx_chain.head->bus_addr, 0);
+	if (status)
+		dev_info(ctodev(card),
+			 "lv1_net_start_rx_dma failed, status=%d\n", status);
+}
+
+/**
+ * gelic_card_disable_rxdmac - disables the receive DMA controller
+ * @card: card structure
+ *
+ * gelic_card_disable_rxdmac terminates processing on the DMA controller by
+ * turing off DMA and issuing a force end
+ */
+static void gelic_card_disable_rxdmac(struct gelic_card *card)
+{
+	int status;
+
+	/* this hvc blocks until the DMA in progress really stopped */
+	status = lv1_net_stop_rx_dma(bus_id(card), dev_id(card));
+	if (status)
+		dev_err(ctodev(card),
+			"lv1_net_stop_rx_dma failed, %d\n", status);
+}
+
+/**
+ * gelic_descr_set_status -- sets the status of a descriptor
+ * @descr: descriptor to change
+ * @status: status to set in the descriptor
+ *
+ * changes the status to the specified value. Doesn't change other bits
+ * in the status
+ */
+static void gelic_descr_set_status(struct gelic_descr *descr,
+				   enum gelic_descr_dma_status status)
+{
+	descr->dmac_cmd_status = cpu_to_be32(status |
+			(be32_to_cpu(descr->dmac_cmd_status) &
+			 ~GELIC_DESCR_DMA_STAT_MASK));
+	/*
+	 * dma_cmd_status field is used to indicate whether the descriptor
+	 * is valid or not.
+	 * Usually caller of this function wants to inform that to the
+	 * hardware, so we assure here the hardware sees the change.
+	 */
+	wmb();
+}
+
+/**
+ * gelic_card_reset_chain - reset status of a descriptor chain
+ * @card: card structure
+ * @chain: address of chain
+ * @start_descr: address of descriptor array
+ *
+ * Reset the status of dma descriptors to ready state
+ * and re-initialize the hardware chain for later use
+ */
+static void gelic_card_reset_chain(struct gelic_card *card,
+				   struct gelic_descr_chain *chain,
+				   struct gelic_descr *start_descr)
+{
+	struct gelic_descr *descr;
+
+	for (descr = start_descr; start_descr != descr->next; descr++) {
+		gelic_descr_set_status(descr, GELIC_DESCR_DMA_CARDOWNED);
+		descr->next_descr_addr = cpu_to_be32(descr->next->bus_addr);
+	}
+
+	chain->head = start_descr;
+	chain->tail = (descr - 1);
+
+	(descr - 1)->next_descr_addr = 0;
+}
+
 void gelic_card_up(struct gelic_card *card)
 {
 	pr_debug("%s: called\n", __func__);
@@ -183,29 +290,6 @@ gelic_descr_get_status(struct gelic_descr *descr)
 }
 
 /**
- * gelic_descr_set_status -- sets the status of a descriptor
- * @descr: descriptor to change
- * @status: status to set in the descriptor
- *
- * changes the status to the specified value. Doesn't change other bits
- * in the status
- */
-static void gelic_descr_set_status(struct gelic_descr *descr,
-				   enum gelic_descr_dma_status status)
-{
-	descr->dmac_cmd_status = cpu_to_be32(status |
-			(be32_to_cpu(descr->dmac_cmd_status) &
-			 ~GELIC_DESCR_DMA_STAT_MASK));
-	/*
-	 * dma_cmd_status field is used to indicate whether the descriptor
-	 * is valid or not.
-	 * Usually caller of this function wants to inform that to the
-	 * hardware, so we assure here the hardware sees the change.
-	 */
-	wmb();
-}
-
-/**
  * gelic_card_free_chain - free descriptor chain
  * @card: card structure
  * @descr_in: address of desc
@@ -286,31 +370,6 @@ iommu_error:
 }
 
 /**
- * gelic_card_reset_chain - reset status of a descriptor chain
- * @card: card structure
- * @chain: address of chain
- * @start_descr: address of descriptor array
- *
- * Reset the status of dma descriptors to ready state
- * and re-initialize the hardware chain for later use
- */
-static void gelic_card_reset_chain(struct gelic_card *card,
-				   struct gelic_descr_chain *chain,
-				   struct gelic_descr *start_descr)
-{
-	struct gelic_descr *descr;
-
-	for (descr = start_descr; start_descr != descr->next; descr++) {
-		gelic_descr_set_status(descr, GELIC_DESCR_DMA_CARDOWNED);
-		descr->next_descr_addr = cpu_to_be32(descr->next->bus_addr);
-	}
-
-	chain->head = start_descr;
-	chain->tail = (descr - 1);
-
-	(descr - 1)->next_descr_addr = 0;
-}
-/**
  * gelic_descr_prepare_rx - reinitializes a rx descriptor
  * @card: card structure
  * @descr: descriptor to re-init
@@ -599,71 +658,6 @@ void gelic_net_set_multi(struct net_device *netdev)
 }
 
 /**
- * gelic_card_enable_rxdmac - enables the receive DMA controller
- * @card: card structure
- *
- * gelic_card_enable_rxdmac enables the DMA controller by setting RX_DMA_EN
- * in the GDADMACCNTR register
- */
-static inline void gelic_card_enable_rxdmac(struct gelic_card *card)
-{
-	int status;
-
-#ifdef DEBUG
-	if (gelic_descr_get_status(card->rx_chain.head) !=
-	    GELIC_DESCR_DMA_CARDOWNED) {
-		printk(KERN_ERR "%s: status=%x\n", __func__,
-		       be32_to_cpu(card->rx_chain.head->dmac_cmd_status));
-		printk(KERN_ERR "%s: nextphy=%x\n", __func__,
-		       be32_to_cpu(card->rx_chain.head->next_descr_addr));
-		printk(KERN_ERR "%s: head=%p\n", __func__,
-		       card->rx_chain.head);
-	}
-#endif
-	status = lv1_net_start_rx_dma(bus_id(card), dev_id(card),
-				card->rx_chain.head->bus_addr, 0);
-	if (status)
-		dev_info(ctodev(card),
-			 "lv1_net_start_rx_dma failed, status=%d\n", status);
-}
-
-/**
- * gelic_card_disable_rxdmac - disables the receive DMA controller
- * @card: card structure
- *
- * gelic_card_disable_rxdmac terminates processing on the DMA controller by
- * turing off DMA and issuing a force end
- */
-static inline void gelic_card_disable_rxdmac(struct gelic_card *card)
-{
-	int status;
-
-	/* this hvc blocks until the DMA in progress really stopped */
-	status = lv1_net_stop_rx_dma(bus_id(card), dev_id(card));
-	if (status)
-		dev_err(ctodev(card),
-			"lv1_net_stop_rx_dma failed, %d\n", status);
-}
-
-/**
- * gelic_card_disable_txdmac - disables the transmit DMA controller
- * @card: card structure
- *
- * gelic_card_disable_txdmac terminates processing on the DMA controller by
- * turing off DMA and issuing a force end
- */
-static inline void gelic_card_disable_txdmac(struct gelic_card *card)
-{
-	int status;
-
-	/* this hvc blocks until the DMA in progress really stopped */
-	status = lv1_net_stop_tx_dma(bus_id(card), dev_id(card));
-	if (status)
-		dev_err(ctodev(card),
-			"lv1_net_stop_tx_dma failed, status=%d\n", status);
-}
-
-/**
  * gelic_net_stop - called upon ifconfig down
  * @netdev: interface device structure
  *
@@ -746,7 +740,7 @@ static void gelic_descr_set_tx_cmdstat(struct gelic_descr *descr,
 	}
 }
 
-static inline struct sk_buff *gelic_put_vlan_tag(struct sk_buff *skb,
+static struct sk_buff *gelic_put_vlan_tag(struct sk_buff *skb,
 						 unsigned short tag)
 {
 	struct vlan_ethhdr *veth;
-- 
1.7.9.5
