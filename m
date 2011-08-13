From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/4] e1000e: workaround invalid Tx/Rx tail descriptor register write
Date: Sat, 13 Aug 2011 02:23:40 -0700
Message-ID: <1313227420-9974-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313227420-9974-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:9400 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751259Ab1HMJXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Aug 2011 05:23:44 -0400
In-Reply-To: <1313227420-9974-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When the Manageability Engine (ME) is enabled on 82579, it periodically
accesses some MAC CSR registers.  There is an arbiter in hardware which
prevents simultaneous access of these registers by the host software, i.e.
the driver.  There is a hardware bug in the aribter that signals a host
access of the registers later than it actually happens.  A write of the
Transmit or Receive Descriptor Tail register could result in an incorrect
value if the driver and ME perform simultaneous accesses which could result
in an access to an invalid memory address.  This would return an
Unsupported Request which could hang the hardware.  Workaround the issue by
checking the FWSM register bit24 which is set by ME before it accesses the
MAC CSR registers.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000e/e1000.h   |    4 ++
 drivers/net/e1000e/ich8lan.c |    5 +++
 drivers/net/e1000e/netdev.c  |   80 +++++++++++++++++++++++++++++++++++++++--
 3 files changed, 85 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 35916f4..8533ad7 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -155,6 +155,9 @@ struct e1000_info;
 #define HV_M_STATUS_SPEED_1000            0x0200
 #define HV_M_STATUS_LINK_UP               0x0040
 
+#define E1000_ICH_FWSM_PCIM2PCI		0x01000000 /* ME PCIm-to-PCI active */
+#define E1000_ICH_FWSM_PCIM2PCI_COUNT	2000
+
 /* Time to wait before putting the device into D3 if there's no link (in ms). */
 #define LINK_TIMEOUT		100
 
@@ -454,6 +457,7 @@ struct e1000_info {
 #define FLAG2_DISABLE_AIM                 (1 << 8)
 #define FLAG2_CHECK_PHY_HANG              (1 << 9)
 #define FLAG2_NO_DISABLE_RX               (1 << 10)
+#define FLAG2_PCIM2PCI_ARBITER_WA         (1 << 11)
 
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 46a5277..54add27 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -814,6 +814,11 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 	    (adapter->hw.phy.type == e1000_phy_igp_3))
 		adapter->flags |= FLAG_LSC_GIG_SPEED_DROP;
 
+	/* Enable workaround for 82579 w/ ME enabled */
+	if ((adapter->hw.mac.type == e1000_pch2lan) &&
+	    (er32(FWSM) & E1000_ICH_FWSM_FW_VALID))
+		adapter->flags2 |= FLAG2_PCIM2PCI_ARBITER_WA;
+
 	/* Disable EEE by default until IEEE802.3az spec is finalized */
 	if (adapter->flags2 & FLAG2_HAS_EEE)
 		adapter->hw.dev_spec.ich8lan.eee_disable = true;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 362f703..2198e61 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -519,6 +519,63 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
 }
 
 /**
+ * e1000e_update_tail_wa - helper function for e1000e_update_[rt]dt_wa()
+ * @hw: pointer to the HW structure
+ * @tail: address of tail descriptor register
+ * @i: value to write to tail descriptor register
+ *
+ * When updating the tail register, the ME could be accessing Host CSR
+ * registers at the same time.  Normally, this is handled in h/w by an
+ * arbiter but on some parts there is a bug that acknowledges Host accesses
+ * later than it should which could result in the descriptor register to
+ * have an incorrect value.  Workaround this by checking the FWSM register
+ * which has bit 24 set while ME is accessing Host CSR registers, wait
+ * if it is set and try again a number of times.
+ **/
+static inline s32 e1000e_update_tail_wa(struct e1000_hw *hw, u8 __iomem * tail,
+					unsigned int i)
+{
+	unsigned int j = 0;
+
+	while ((j++ < E1000_ICH_FWSM_PCIM2PCI_COUNT) &&
+	       (er32(FWSM) & E1000_ICH_FWSM_PCIM2PCI))
+		udelay(50);
+
+	writel(i, tail);
+
+	if ((j == E1000_ICH_FWSM_PCIM2PCI_COUNT) && (i != readl(tail)))
+		return E1000_ERR_SWFW_SYNC;
+
+	return 0;
+}
+
+static void e1000e_update_rdt_wa(struct e1000_adapter *adapter, unsigned int i)
+{
+	u8 __iomem *tail = (adapter->hw.hw_addr + adapter->rx_ring->tail);
+	struct e1000_hw *hw = &adapter->hw;
+
+	if (e1000e_update_tail_wa(hw, tail, i)) {
+		u32 rctl = er32(RCTL);
+		ew32(RCTL, rctl & ~E1000_RCTL_EN);
+		e_err("ME firmware caused invalid RDT - resetting\n");
+		schedule_work(&adapter->reset_task);
+	}
+}
+
+static void e1000e_update_tdt_wa(struct e1000_adapter *adapter, unsigned int i)
+{
+	u8 __iomem *tail = (adapter->hw.hw_addr + adapter->tx_ring->tail);
+	struct e1000_hw *hw = &adapter->hw;
+
+	if (e1000e_update_tail_wa(hw, tail, i)) {
+		u32 tctl = er32(TCTL);
+		ew32(TCTL, tctl & ~E1000_TCTL_EN);
+		e_err("ME firmware caused invalid TDT - resetting\n");
+		schedule_work(&adapter->reset_task);
+	}
+}
+
+/**
  * e1000_alloc_rx_buffers - Replace used receive buffers; legacy & extended
  * @adapter: address of board private structure
  **/
@@ -573,7 +630,10 @@ map_skb:
 			 * such as IA-64).
 			 */
 			wmb();
-			writel(i, adapter->hw.hw_addr + rx_ring->tail);
+			if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
+				e1000e_update_rdt_wa(adapter, i);
+			else
+				writel(i, adapter->hw.hw_addr + rx_ring->tail);
 		}
 		i++;
 		if (i == rx_ring->count)
@@ -673,7 +733,11 @@ static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
 			 * such as IA-64).
 			 */
 			wmb();
-			writel(i << 1, adapter->hw.hw_addr + rx_ring->tail);
+			if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
+				e1000e_update_rdt_wa(adapter, i << 1);
+			else
+				writel(i << 1,
+				       adapter->hw.hw_addr + rx_ring->tail);
 		}
 
 		i++;
@@ -756,7 +820,10 @@ check_page:
 		 * applicable for weak-ordered memory model archs,
 		 * such as IA-64). */
 		wmb();
-		writel(i, adapter->hw.hw_addr + rx_ring->tail);
+		if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
+			e1000e_update_rdt_wa(adapter, i);
+		else
+			writel(i, adapter->hw.hw_addr + rx_ring->tail);
 	}
 }
 
@@ -4689,7 +4756,12 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 	wmb();
 
 	tx_ring->next_to_use = i;
-	writel(i, adapter->hw.hw_addr + tx_ring->tail);
+
+	if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
+		e1000e_update_tdt_wa(adapter, i);
+	else
+		writel(i, adapter->hw.hw_addr + tx_ring->tail);
+
 	/*
 	 * we need this if more than one processor can write to our tail
 	 * at a time, it synchronizes IO on IA64/Altix systems
-- 
1.7.6

