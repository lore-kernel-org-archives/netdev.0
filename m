From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 13/20] ixgbe: Move max frame size and Rx buffer
	length configuration into a function
Date: Thu, 19 Aug 2010 16:38:11 -0700
Message-ID: <20100819233808.10335.36102.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:34704
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752580Ab0HSXib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:38:31 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change consolidates all of the Rx max frame size and Rx buffer length
configuration into a single function.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |  108 ++++++++++++++++++++++------------------
 1 files changed, 60 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 520b95f..841ef98 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2695,25 +2695,15 @@ static void ixgbe_setup_psrtype(struct ixgbe_adapter *adapter)
 				psrtype);
 }
 
-/**
- * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
- * @adapter: board private structure
- *
- * Configure the Rx unit of the MAC after a reset.
- **/
-static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
+static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	struct ixgbe_ring *rx_ring;
 	struct net_device *netdev = adapter->netdev;
 	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
-	int i;
-	u32 rxctrl;
-	u32 hlreg0, gcr_ext;
-	u32 rdrxctl;
 	int rx_buf_len;
-
-	ixgbe_setup_psrtype(adapter);
+	struct ixgbe_ring *rx_ring;
+	int i;
+	u32 mhadd, hlreg0;
 
 	/* Decide whether to use packet split mode or not */
 	/* Do not use packet split if we're in SR-IOV Mode */
@@ -2728,23 +2718,28 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		    (netdev->mtu <= ETH_DATA_LEN))
 			rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 		else
-			rx_buf_len = ALIGN(max_frame, 1024);
+			rx_buf_len = ALIGN(max_frame + VLAN_HLEN, 1024);
 	}
 
-	hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
-	if (adapter->netdev->mtu <= ETH_DATA_LEN)
-		hlreg0 &= ~IXGBE_HLREG0_JUMBOEN;
-	else
-		hlreg0 |= IXGBE_HLREG0_JUMBOEN;
 #ifdef IXGBE_FCOE
-	if (netdev->features & NETIF_F_FCOE_MTU)
-		hlreg0 |= IXGBE_HLREG0_JUMBOEN;
-#endif
-	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
+	/* adjust max frame to be able to do baby jumbo for FCoE */
+	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
+	    (max_frame < IXGBE_FCOE_JUMBO_FRAME_SIZE))
+		max_frame = IXGBE_FCOE_JUMBO_FRAME_SIZE;
 
-	/* disable receives while setting up the descriptors */
-	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
-	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
+#endif /* IXGBE_FCOE */
+	mhadd = IXGBE_READ_REG(hw, IXGBE_MHADD);
+	if (max_frame != (mhadd >> IXGBE_MHADD_MFS_SHIFT)) {
+		mhadd &= ~IXGBE_MHADD_MFS_MASK;
+		mhadd |= max_frame << IXGBE_MHADD_MFS_SHIFT;
+
+		IXGBE_WRITE_REG(hw, IXGBE_MHADD, mhadd);
+	}
+
+	hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
+	/* set jumbo enable since MHADD.MFS is keeping size locked at max_frame */
+	hlreg0 |= IXGBE_HLREG0_JUMBOEN;
+	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
 
 	/*
 	 * Setup the HW Rx Head and Tail Descriptor Pointers and
@@ -2760,7 +2755,8 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 			rx_ring->flags &= ~IXGBE_RING_RX_PS_ENABLED;
 
 #ifdef IXGBE_FCOE
-		if (netdev->features & NETIF_F_FCOE_MTU) {
+		if (netdev->features & NETIF_F_FCOE_MTU)
+		{
 			struct ixgbe_ring_feature *f;
 			f = &adapter->ring_feature[RING_F_FCOE];
 			if ((i >= f->mask) && (i < f->mask + f->indices)) {
@@ -2770,8 +2766,41 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 					        IXGBE_FCOE_JUMBO_FRAME_SIZE;
 			}
 		}
-
 #endif /* IXGBE_FCOE */
+	}
+
+}
+
+/**
+ * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
+ * @adapter: board private structure
+ *
+ * Configure the Rx unit of the MAC after a reset.
+ **/
+static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_ring *rx_ring;
+	int i;
+	u32 rxctrl;
+	u32 gcr_ext;
+	u32 rdrxctl;
+
+	/* disable receives while setting up the descriptors */
+	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
+	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
+
+	ixgbe_setup_psrtype(adapter);
+
+	/* set_rx_buffer_len must be called before ring initialization */
+	ixgbe_set_rx_buffer_len(adapter);
+
+	/*
+	 * Setup the HW Rx Head and Tail Descriptor Pointers and
+	 * the Base and Length of the Rx Descriptor Ring
+	 */
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		rx_ring = adapter->rx_ring[i];
 		ixgbe_configure_rx_ring(adapter, rx_ring);
 		ixgbe_configure_srrctl(adapter, rx_ring);
 	}
@@ -3322,13 +3351,11 @@ static inline void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
 
 static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 {
-	struct net_device *netdev = adapter->netdev;
 	struct ixgbe_hw *hw = &adapter->hw;
 	int i, j = 0;
 	int num_rx_rings = adapter->num_rx_queues;
 	int err;
-	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
-	u32 txdctl, rxdctl, mhadd;
+	u32 txdctl, rxdctl;
 	u32 dmatxctl;
 	u32 gpie;
 	u32 ctrl_ext;
@@ -3395,21 +3422,6 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
 	}
 
-#ifdef IXGBE_FCOE
-	/* adjust max frame to be able to do baby jumbo for FCoE */
-	if ((netdev->features & NETIF_F_FCOE_MTU) &&
-	    (max_frame < IXGBE_FCOE_JUMBO_FRAME_SIZE))
-		max_frame = IXGBE_FCOE_JUMBO_FRAME_SIZE;
-
-#endif /* IXGBE_FCOE */
-	mhadd = IXGBE_READ_REG(hw, IXGBE_MHADD);
-	if (max_frame != (mhadd >> IXGBE_MHADD_MFS_SHIFT)) {
-		mhadd &= ~IXGBE_MHADD_MFS_MASK;
-		mhadd |= max_frame << IXGBE_MHADD_MFS_SHIFT;
-
-		IXGBE_WRITE_REG(hw, IXGBE_MHADD, mhadd);
-	}
-
 	if (hw->mac.type == ixgbe_mac_82599EB) {
 		/* DMATXCTL.EN must be set after all Tx queue config is done */
 		dmatxctl = IXGBE_READ_REG(hw, IXGBE_DMATXCTL);
@@ -3522,7 +3534,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		        &(adapter->tx_ring[i]->reinit_state));
 
 	/* enable transmits */
-	netif_tx_start_all_queues(netdev);
+	netif_tx_start_all_queues(adapter->netdev);
 
 	/* bring the link up in the watchdog, this could race with our first
 	 * link up interrupt but shouldn't be a problem */

