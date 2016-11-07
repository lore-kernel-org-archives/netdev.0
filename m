From: Cao jin <caoj.fnst@cn.fujitsu.com>
Subject: [PATCH] igb: drop field "tail" of struct igb_ring
Date: Mon, 7 Nov 2016 20:44:57 +0800
Message-ID: <1478522697-4773-1-git-send-email-caoj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <intel-wired-lan@lists.osuosl.org>, <jeffrey.t.kirsher@intel.com>,
        <izumi.taku@jp.fujitsu.com>
To: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([59.151.112.132]:18342 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753014AbcKGMm0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 07:42:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Under certain condition, I find guest will oops on writel() in
igb_configure_tx_ring(), because hw->hw_address is NULL. While other
register access won't oops kernel because they use wr32/rd32 which have
a defense against NULL pointer. The oops message are as following:

    [  141.225449] pcieport 0000:00:1c.0: AER: Multiple Uncorrected (Fatal)
    error received: id=0101
    [  141.225523] igb 0000:01:00.1: PCIe Bus Error: severity=Uncorrected
    (Fatal), type=Unaccessible, id=0101(Unregistered Agent ID)
    [  141.299442] igb 0000:01:00.1: broadcast error_detected message
    [  141.300539] igb 0000:01:00.0 enp1s0f0: PCIe link lost, device now
    detached
    [  141.351019] igb 0000:01:00.1 enp1s0f1: PCIe link lost, device now
    detached
    [  143.465904] pcieport 0000:00:1c.0: Root Port link has been reset
    [  143.465994] igb 0000:01:00.1: broadcast slot_reset message
    [  143.466039] igb 0000:01:00.0: enabling device (0000 -> 0002)
    [  144.389078] igb 0000:01:00.1: enabling device (0000 -> 0002)
    [  145.312078] igb 0000:01:00.1: broadcast resume message
    [  145.322211] BUG: unable to handle kernel paging request at
    0000000000003818
    [  145.361275] IP: [<ffffffffa02fd38d>] igb_configure_tx_ring+0x14d/0x280 [igb]
    [  145.438007] Oops: 0002 [#1] SMP

On the other hand, commit 238ac817 does some optimization which
dropped the field "head". So I think it is time to drop "tail" as well.

Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |  1 -
 drivers/net/ethernet/intel/igb/igb_main.c | 16 +++++++++-------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index d11093d..0df06bc 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -247,7 +247,6 @@ struct igb_ring {
 	};
 	void *desc;			/* descriptor ring memory */
 	unsigned long flags;		/* ring specific flags */
-	void __iomem *tail;		/* pointer to ring tail register */
 	dma_addr_t dma;			/* phys address of the ring */
 	unsigned int  size;		/* length of desc. ring in bytes */
 
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index edc9a6a..e177d0e 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3390,9 +3390,8 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
 	     tdba & 0x00000000ffffffffULL);
 	wr32(E1000_TDBAH(reg_idx), tdba >> 32);
 
-	ring->tail = hw->hw_addr + E1000_TDT(reg_idx);
 	wr32(E1000_TDH(reg_idx), 0);
-	writel(0, ring->tail);
+        wr32(E1000_TDT(reg_idx), 0);
 
 	txdctl |= IGB_TX_PTHRESH;
 	txdctl |= IGB_TX_HTHRESH << 8;
@@ -3729,9 +3728,8 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	     ring->count * sizeof(union e1000_adv_rx_desc));
 
 	/* initialize head and tail */
-	ring->tail = hw->hw_addr + E1000_RDT(reg_idx);
 	wr32(E1000_RDH(reg_idx), 0);
-	writel(0, ring->tail);
+	wr32(E1000_RDT(reg_idx), 0);
 
 	/* set descriptor configuration */
 	srrctl = IGB_RX_HDR_LEN << E1000_SRRCTL_BSIZEHDRSIZE_SHIFT;
@@ -5130,6 +5128,8 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 	u32 tx_flags = first->tx_flags;
 	u32 cmd_type = igb_tx_cmd_type(skb, tx_flags);
 	u16 i = tx_ring->next_to_use;
+        struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
+        struct e1000_hw *hw = &adapter->hw;
 
 	tx_desc = IGB_TX_DESC(tx_ring, i);
 
@@ -5223,7 +5223,7 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 	igb_maybe_stop_tx(tx_ring, DESC_NEEDED);
 
 	if (netif_xmit_stopped(txring_txq(tx_ring)) || !skb->xmit_more) {
-		writel(i, tx_ring->tail);
+                wr32(E1000_TDT(tx_ring->reg_idx), i);
 
 		/* we need this if more than one processor can write to our tail
 		 * at a time, it synchronizes IO on IA64/Altix systems
@@ -6756,7 +6756,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector, int napi_budget)
 				"  desc.status          <%x>\n",
 				tx_ring->queue_index,
 				rd32(E1000_TDH(tx_ring->reg_idx)),
-				readl(tx_ring->tail),
+				rd32(E1000_TDT(tx_ring->reg_idx)),
 				tx_ring->next_to_use,
 				tx_ring->next_to_clean,
 				tx_buffer->time_stamp,
@@ -7265,6 +7265,8 @@ void igb_alloc_rx_buffers(struct igb_ring *rx_ring, u16 cleaned_count)
 	union e1000_adv_rx_desc *rx_desc;
 	struct igb_rx_buffer *bi;
 	u16 i = rx_ring->next_to_use;
+        struct igb_adapter *adapter = netdev_priv(rx_ring->netdev);
+        struct e1000_hw *hw = &adapter->hw;
 
 	/* nothing to do */
 	if (!cleaned_count)
@@ -7313,7 +7315,7 @@ void igb_alloc_rx_buffers(struct igb_ring *rx_ring, u16 cleaned_count)
 		 * such as IA-64).
 		 */
 		wmb();
-		writel(i, rx_ring->tail);
+                wr32(E1000_RDT(rx_ring->reg_idx), i);
 	}
 }
 
-- 
2.1.0
