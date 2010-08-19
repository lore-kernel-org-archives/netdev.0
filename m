From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 17/20] ixgbe: pull all Tx init into
	ixgbe_configure_tx
Date: Thu, 19 Aug 2010 16:39:43 -0700
Message-ID: <20100819233940.10335.28076.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:40306
	"EHLO qmta07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752158Ab0HSXkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:40:03 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The Tx init was spread out over ixgbe_configure, ixgbe_configure_tx, and
ixgbe_up_complete.  This change combines all of that into the
ixgbe_configure_tx function in order to simplify the Tx init path.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   91 +++++++++++++++++++++++-----------------
 1 files changed, 52 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 0b23522..fd2026e 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2436,8 +2436,16 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
 	u64 tdba = ring->dma;
+	int wait_loop = 10;
+	u32 txdctl;
 	u16 reg_idx = ring->reg_idx;
 
+	/* disable queue to avoid issues while updating state */
+	txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(reg_idx));
+	IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx),
+			txdctl & ~IXGBE_TXDCTL_ENABLE);
+	IXGBE_WRITE_FLUSH(hw);
+
 	IXGBE_WRITE_REG(hw, IXGBE_TDBAL(reg_idx),
 	                (tdba & DMA_BIT_MASK(32)));
 	IXGBE_WRITE_REG(hw, IXGBE_TDBAH(reg_idx), (tdba >> 32));
@@ -2448,6 +2456,38 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 	ring->head = IXGBE_TDH(reg_idx);
 	ring->tail = IXGBE_TDT(reg_idx);
 
+	/* configure fetching thresholds */
+	if (adapter->rx_itr_setting == 0) {
+		/* cannot set wthresh when itr==0 */
+		txdctl &= ~0x007F0000;
+	} else {
+		/* enable WTHRESH=8 descriptors, to encourage burst writeback */
+		txdctl |= (8 << 16);
+	}
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+		/* PThresh workaround for Tx hang with DFP enabled. */
+		txdctl |= 32;
+	}
+
+	/* reinitialize flowdirector state */
+	set_bit(__IXGBE_FDIR_INIT_DONE, &ring->reinit_state);
+
+	/* enable queue */
+	txdctl |= IXGBE_TXDCTL_ENABLE;
+	IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(reg_idx), txdctl);
+
+	/* TXDCTL.EN will return 0 on 82598 if link is down, so skip it */
+	if (hw->mac.type == ixgbe_mac_82598EB &&
+	    !(IXGBE_READ_REG(hw, IXGBE_LINKS) & IXGBE_LINKS_UP))
+		return;
+
+	/* poll to verify queue is enabled */
+	do {
+		msleep(1);
+		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(reg_idx));
+	} while (--wait_loop && !(txdctl & IXGBE_TXDCTL_ENABLE));
+	if (!wait_loop)
+		e_err(drv, "Could not enable Tx Queue %d\n", reg_idx);
 }
 
 static void ixgbe_setup_mtqc(struct ixgbe_adapter *adapter)
@@ -2497,13 +2537,22 @@ static void ixgbe_setup_mtqc(struct ixgbe_adapter *adapter)
  **/
 static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 {
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 dmatxctl;
 	u32 i;
 
+	ixgbe_setup_mtqc(adapter);
+
+	if (hw->mac.type != ixgbe_mac_82598EB) {
+		/* DMATXCTL.EN must be before Tx queues are enabled */
+		dmatxctl = IXGBE_READ_REG(hw, IXGBE_DMATXCTL);
+		dmatxctl |= IXGBE_DMATXCTL_TE;
+		IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL, dmatxctl);
+	}
+
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 	for (i = 0; i < adapter->num_tx_queues; i++)
 		ixgbe_configure_tx_ring(adapter, adapter->tx_ring[i]);
-
-	ixgbe_setup_mtqc(adapter);
 }
 
 #define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT 2
@@ -3416,44 +3465,12 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	int i, j = 0;
 	int num_rx_rings = adapter->num_rx_queues;
 	int err;
-	u32 txdctl, rxdctl;
-	u32 dmatxctl;
+	u32 rxdctl;
 	u32 ctrl_ext;
 
 	ixgbe_get_hw_control(adapter);
 	ixgbe_setup_gpie(adapter);
 
-	if (hw->mac.type == ixgbe_mac_82599EB) {
-		/* DMATXCTL.EN must be set after all Tx queue config is done */
-		dmatxctl = IXGBE_READ_REG(hw, IXGBE_DMATXCTL);
-		dmatxctl |= IXGBE_DMATXCTL_TE;
-		IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL, dmatxctl);
-	}
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		j = adapter->tx_ring[i]->reg_idx;
-		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
-		if (adapter->rx_itr_setting == 0) {
-			/* cannot set wthresh when itr==0 */
-			txdctl &= ~0x007F0000;
-		} else {
-			/* enable WTHRESH=8 descriptors, to encourage burst writeback */
-			txdctl |= (8 << 16);
-		}
-		txdctl |= IXGBE_TXDCTL_ENABLE;
-		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
-		if (hw->mac.type == ixgbe_mac_82599EB) {
-			int wait_loop = 10;
-			/* poll for Tx Enable ready */
-			do {
-				msleep(1);
-				txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
-			} while (--wait_loop &&
-			         !(txdctl & IXGBE_TXDCTL_ENABLE));
-			if (!wait_loop)
-				e_err(drv, "Could not enable Tx Queue %d\n", j);
-		}
-	}
-
 	for (i = 0; i < num_rx_rings; i++) {
 		j = adapter->rx_ring[i]->reg_idx;
 		rxdctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(j));
@@ -3530,10 +3547,6 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 			e_err(probe, "link_config FAILED %d\n", err);
 	}
 
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		set_bit(__IXGBE_FDIR_INIT_DONE,
-		        &(adapter->tx_ring[i]->reinit_state));
-
 	/* enable transmits */
 	netif_tx_start_all_queues(adapter->netdev);
 

