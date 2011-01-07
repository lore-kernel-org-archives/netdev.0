From: jeffrey.t.kirsher@intel.com
Subject: [net-next 09/12] ixgbe: make sure per Rx queue is disabled before unmapping the receive buffer
Date: Thu,  6 Jan 2011 16:29:56 -0800
Message-ID: <1294360199-9860-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Yi Zou <yi.zou@intel.com>, netdev@vger.kernel.org, gosp@redhat.com,
	bphilips@novell.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11179 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753939Ab1AGAav (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 19:30:51 -0500
To: davem@davemloft.net
In-Reply-To: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

When disable the Rx logic globally, we would also want to disable the per Rx
queue receive logic by per queue Rx control register RXDCTL so no more DMA is
happening from the packet buffer to the receive buffer associated with the Rx
ring, before we start unmapping Rx ring receive buffer. The hardware may take
max of 100us before the corresponding Rx queue is really disabled. Added
ixgbe_disable_rx_queue() for this purpose.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Tested-by: Ross Brattain <ross.b.brattain@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h         |    2 +
 drivers/net/ixgbe/ixgbe_ethtool.c |    4 +--
 drivers/net/ixgbe/ixgbe_main.c    |   40 +++++++++++++++++++++++++++++++++---
 3 files changed, 39 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 3ae30b8..bdeaa9e 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -508,6 +508,8 @@ extern void ixgbe_free_rx_resources(struct ixgbe_ring *);
 extern void ixgbe_free_tx_resources(struct ixgbe_ring *);
 extern void ixgbe_configure_rx_ring(struct ixgbe_adapter *,struct ixgbe_ring *);
 extern void ixgbe_configure_tx_ring(struct ixgbe_adapter *,struct ixgbe_ring *);
+extern void ixgbe_disable_rx_queue(struct ixgbe_adapter *adapter,
+				   struct ixgbe_ring *);
 extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 23ff23e..a8bab15 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1477,9 +1477,7 @@ static void ixgbe_free_desc_rings(struct ixgbe_adapter *adapter)
 	reg_ctl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	reg_ctl &= ~IXGBE_RXCTRL_RXEN;
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, reg_ctl);
-	reg_ctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(rx_ring->reg_idx));
-	reg_ctl &= ~IXGBE_RXDCTL_ENABLE;
-	IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(rx_ring->reg_idx), reg_ctl);
+	ixgbe_disable_rx_queue(adapter, rx_ring);
 
 	/* now Tx */
 	reg_ctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(tx_ring->reg_idx));
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 38ab4f3..e8ae311 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3024,6 +3024,36 @@ static void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
 	}
 }
 
+void ixgbe_disable_rx_queue(struct ixgbe_adapter *adapter,
+			    struct ixgbe_ring *ring)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int wait_loop = IXGBE_MAX_RX_DESC_POLL;
+	u32 rxdctl;
+	u8 reg_idx = ring->reg_idx;
+
+	rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(reg_idx));
+	rxdctl &= ~IXGBE_RXDCTL_ENABLE;
+
+	/* write value back with RXDCTL.ENABLE bit cleared */
+	IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(reg_idx), rxdctl);
+
+	if (hw->mac.type == ixgbe_mac_82598EB &&
+	    !(IXGBE_READ_REG(hw, IXGBE_LINKS) & IXGBE_LINKS_UP))
+		return;
+
+	/* the hardware may take up to 100us to really disable the rx queue */
+	do {
+		udelay(10);
+		rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(reg_idx));
+	} while (--wait_loop && (rxdctl & IXGBE_RXDCTL_ENABLE));
+
+	if (!wait_loop) {
+		e_err(drv, "RXDCTL.ENABLE on Rx queue %d not cleared within "
+		      "the polling period\n", reg_idx);
+	}
+}
+
 void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 			     struct ixgbe_ring *ring)
 {
@@ -3034,9 +3064,7 @@ void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
 
 	/* disable queue to avoid issues while updating state */
 	rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(reg_idx));
-	IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(reg_idx),
-			rxdctl & ~IXGBE_RXDCTL_ENABLE);
-	IXGBE_WRITE_FLUSH(hw);
+	ixgbe_disable_rx_queue(adapter, ring);
 
 	IXGBE_WRITE_REG(hw, IXGBE_RDBAL(reg_idx), (rdba & DMA_BIT_MASK(32)));
 	IXGBE_WRITE_REG(hw, IXGBE_RDBAH(reg_idx), (rdba >> 32));
@@ -4064,7 +4092,11 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
 
-	IXGBE_WRITE_FLUSH(hw);
+	/* disable all enabled rx queues */
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		/* this call also flushes the previous write */
+		ixgbe_disable_rx_queue(adapter, adapter->rx_ring[i]);
+
 	msleep(10);
 
 	netif_tx_stop_all_queues(netdev);
-- 
1.7.3.4

