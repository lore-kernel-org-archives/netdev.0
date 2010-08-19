From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 08/20] ixgbe: pull ring configuration into it's
	own function
Date: Thu, 19 Aug 2010 16:36:05 -0700
Message-ID: <20100819233602.10335.80879.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:57808 "EHLO
	qmta05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751731Ab0HSXgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:36:24 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

These changes add ixgbe_configure_rx_ring which is used to setup the base
function pointers for the ring.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   33 ++++++++++++++++++++-------------
 1 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f5d8902..ddabe14 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2655,6 +2655,23 @@ static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter, int index)
 	IXGBE_WRITE_REG(hw, IXGBE_RSCCTL(j), rscctrl);
 }
 
+static void ixgbe_configure_rx_ring(struct ixgbe_adapter *adapter,
+				    struct ixgbe_ring *ring)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u64 rdba = ring->dma;
+	u16 reg_idx = ring->reg_idx;
+
+	IXGBE_WRITE_REG(hw, IXGBE_RDBAL(reg_idx), (rdba & DMA_BIT_MASK(32)));
+	IXGBE_WRITE_REG(hw, IXGBE_RDBAH(reg_idx), (rdba >> 32));
+	IXGBE_WRITE_REG(hw, IXGBE_RDLEN(reg_idx),
+			ring->count * sizeof(union ixgbe_adv_rx_desc));
+	IXGBE_WRITE_REG(hw, IXGBE_RDH(reg_idx), 0);
+	IXGBE_WRITE_REG(hw, IXGBE_RDT(reg_idx), 0);
+	ring->head = IXGBE_RDH(reg_idx);
+	ring->tail = IXGBE_RDT(reg_idx);
+}
+
 /**
  * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
  * @adapter: board private structure
@@ -2663,13 +2680,12 @@ static void ixgbe_configure_rscctl(struct ixgbe_adapter *adapter, int index)
  **/
 static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 {
-	u64 rdba;
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_ring *rx_ring;
 	struct net_device *netdev = adapter->netdev;
 	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
-	int i, j;
-	u32 rdlen, rxctrl;
+	int i;
+	u32 rxctrl;
 	u32 fctrl, hlreg0;
 	u32 rdrxctl;
 	int rx_buf_len;
@@ -2718,7 +2734,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 #endif
 	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
 
-	rdlen = adapter->rx_ring[0]->count * sizeof(union ixgbe_adv_rx_desc);
 	/* disable receives while setting up the descriptors */
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
@@ -2729,15 +2744,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	 */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		rx_ring = adapter->rx_ring[i];
-		rdba = rx_ring->dma;
-		j = rx_ring->reg_idx;
-		IXGBE_WRITE_REG(hw, IXGBE_RDBAL(j), (rdba & DMA_BIT_MASK(32)));
-		IXGBE_WRITE_REG(hw, IXGBE_RDBAH(j), (rdba >> 32));
-		IXGBE_WRITE_REG(hw, IXGBE_RDLEN(j), rdlen);
-		IXGBE_WRITE_REG(hw, IXGBE_RDH(j), 0);
-		IXGBE_WRITE_REG(hw, IXGBE_RDT(j), 0);
-		rx_ring->head = IXGBE_RDH(j);
-		rx_ring->tail = IXGBE_RDT(j);
 		rx_ring->rx_buf_len = rx_buf_len;
 
 		if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)
@@ -2758,6 +2764,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		}
 
 #endif /* IXGBE_FCOE */
+		ixgbe_configure_rx_ring(adapter, rx_ring);
 		ixgbe_configure_srrctl(adapter, rx_ring);
 	}
 

