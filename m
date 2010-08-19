From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 14/20] ixgbe: move all Rx DMA control register
	writes to one central location
Date: Thu, 19 Aug 2010 16:38:34 -0700
Message-ID: <20100819233831.10335.23092.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:40246
	"EHLO qmta02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752580Ab0HSXiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:38:54 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change moves all of the Rx DMA control register writes to one central
location.  This should help to avoid accidentally overwriting existing
settings.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   91 +++++++++++++++++++++-------------------
 drivers/net/ixgbe/ixgbe_type.h |    2 +
 2 files changed, 50 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 841ef98..f8cdc99 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2616,25 +2616,26 @@ static void ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
  * @adapter:    address of board private structure
  * @index:      index of ring to set
  **/
-static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter, int index)
+static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter,
+				   struct ixgbe_ring *ring)
 {
-	struct ixgbe_ring *rx_ring;
 	struct ixgbe_hw *hw = &adapter->hw;
-	int j;
 	u32 rscctrl;
 	int rx_buf_len;
+	u16 reg_idx = ring->reg_idx;
+
+	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))
+		return;
 
-	rx_ring = adapter->rx_ring[index];
-	j = rx_ring->reg_idx;
-	rx_buf_len = rx_ring->rx_buf_len;
-	rscctrl = IXGBE_READ_REG(hw, IXGBE_RSCCTL(j));
+	rx_buf_len = ring->rx_buf_len;
+	rscctrl = IXGBE_READ_REG(hw, IXGBE_RSCCTL(reg_idx));
 	rscctrl |= IXGBE_RSCCTL_RSCEN;
 	/*
 	 * we must limit the number of descriptors so that the
 	 * total size of max desc * buf_len is not greater
 	 * than 65535
 	 */
-	if (rx_ring->flags & IXGBE_RING_RX_PS_ENABLED) {
+	if (ring->flags & IXGBE_RING_RX_PS_ENABLED) {
 #if (MAX_SKB_FRAGS > 16)
 		rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
 #elif (MAX_SKB_FRAGS > 8)
@@ -2652,7 +2653,7 @@ static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter, int index)
 		else
 			rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
 	}
-	IXGBE_WRITE_REG(hw, IXGBE_RSCCTL(j), rscctrl);
+	IXGBE_WRITE_REG(hw, IXGBE_RSCCTL(reg_idx), rscctrl);
 }
 
 static void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
@@ -2771,6 +2772,42 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 
 }
 
+static void ixgbe_setup_rdrxctl(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 rdrxctl = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_82598EB:
+		/*
+		 * For VMDq support of different descriptor types or
+		 * buffer sizes through the use of multiple SRRCTL
+		 * registers, RDRXCTL.MVMEN must be set to 1
+		 *
+		 * also, the manual doesn't mention it clearly but DCA hints
+		 * will only use queue 0's tags unless this bit is set.  Side
+		 * effects of setting this bit are only that SRRCTL must be
+		 * fully programmed [0..15]
+		 */
+		rdrxctl |= IXGBE_RDRXCTL_MVMEN;
+		break;
+	case ixgbe_mac_82599EB:
+		/* Disable RSC for ACK packets */
+		IXGBE_WRITE_REG(hw, IXGBE_RSCDBU,
+		   (IXGBE_RSCDBU_RSCACKDIS | IXGBE_READ_REG(hw, IXGBE_RSCDBU)));
+		rdrxctl &= ~IXGBE_RDRXCTL_RSCFRSTSIZE;
+		/* hardware requires some bits to be set by default */
+		rdrxctl |= (IXGBE_RDRXCTL_RSCACKC | IXGBE_RDRXCTL_FCOE_WRFIX);
+		rdrxctl |= IXGBE_RDRXCTL_CRCSTRIP;
+		break;
+	default:
+		/* We should do nothing since we don't know this hardware */
+		return;
+	}
+
+	IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
+}
+
 /**
  * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
  * @adapter: board private structure
@@ -2784,13 +2821,13 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	int i;
 	u32 rxctrl;
 	u32 gcr_ext;
-	u32 rdrxctl;
 
 	/* disable receives while setting up the descriptors */
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
 
 	ixgbe_setup_psrtype(adapter);
+	ixgbe_setup_rdrxctl(adapter);
 
 	/* set_rx_buffer_len must be called before ring initialization */
 	ixgbe_set_rx_buffer_len(adapter);
@@ -2803,22 +2840,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		rx_ring = adapter->rx_ring[i];
 		ixgbe_configure_rx_ring(adapter, rx_ring);
 		ixgbe_configure_srrctl(adapter, rx_ring);
-	}
-
-	if (hw->mac.type == ixgbe_mac_82598EB) {
-		/*
-		 * For VMDq support of different descriptor types or
-		 * buffer sizes through the use of multiple SRRCTL
-		 * registers, RDRXCTL.MVMEN must be set to 1
-		 *
-		 * also, the manual doesn't mention it clearly but DCA hints
-		 * will only use queue 0's tags unless this bit is set.  Side
-		 * effects of setting this bit are only that SRRCTL must be
-		 * fully programmed [0..15]
-		 */
-		rdrxctl = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
-		rdrxctl |= IXGBE_RDRXCTL_MVMEN;
-		IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
+		ixgbe_configure_rscctl(adapter, rx_ring);
 	}
 
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
@@ -2858,23 +2880,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		gcr_ext |= IXGBE_GCR_EXT_SRIOV;
 		IXGBE_WRITE_REG(hw, IXGBE_GCR_EXT, gcr_ext);
 	}
-
-	if (hw->mac.type == ixgbe_mac_82599EB) {
-		rdrxctl = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
-		rdrxctl |= IXGBE_RDRXCTL_CRCSTRIP;
-		rdrxctl &= ~IXGBE_RDRXCTL_RSCFRSTSIZE;
-		IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
-	}
-
-	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
-		/* Enable 82599 HW-RSC */
-		for (i = 0; i < adapter->num_rx_queues; i++)
-			ixgbe_configure_rscctl(adapter, i);
-
-		/* Disable RSC for ACK packets */
-		IXGBE_WRITE_REG(hw, IXGBE_RSCDBU,
-		   (IXGBE_RSCDBU_RSCACKDIS | IXGBE_READ_REG(hw, IXGBE_RSCDBU)));
-	}
 }
 
 static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 9587d97..d3cc6ce 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -871,6 +871,8 @@
 #define IXGBE_RDRXCTL_MVMEN         0x00000020
 #define IXGBE_RDRXCTL_DMAIDONE      0x00000008 /* DMA init cycle done */
 #define IXGBE_RDRXCTL_AGGDIS        0x00010000 /* Aggregation disable */
+#define IXGBE_RDRXCTL_RSCACKC       0x02000000 /* must set 1 when RSC enabled */
+#define IXGBE_RDRXCTL_FCOE_WRFIX    0x04000000 /* must set 1 when RSC enabled */
 
 /* RQTC Bit Masks and Shifts */
 #define IXGBE_RQTC_SHIFT_TC(_i)     ((_i) * 4)

