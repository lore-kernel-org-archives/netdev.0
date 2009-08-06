From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] ixgbe: Pass rx_ring directly in
	ixgbe_configure_srrctl()
Date: Thu, 06 Aug 2009 16:05:23 -0700
Message-ID: <20090806230514.28347.51172.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.westchester.pa.mail.comcast.net ([76.96.62.16]:49515
	"EHLO QMTA01.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756495AbZHFXFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 19:05:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Instead of passing the register index of the corresponding rx_ring and find
the way back to get to corresponding rx_ring in ixgbe_configure_srrctl(),
simplify the function ixgbe_configure_srrctl() by passing the rx_ring into
it. Then the register index for that rx_ring is already available from
rx_ring->reg_idx.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   55 +++++++++++-----------------------------
 1 files changed, 15 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 110c65a..e361b7f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1898,46 +1898,19 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 
 #define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT 2
 
-static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
+static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter,
+                                   struct ixgbe_ring *rx_ring)
 {
-	struct ixgbe_ring *rx_ring;
 	u32 srrctl;
-	int queue0 = 0;
-	unsigned long mask;
+	int index;
 	struct ixgbe_ring_feature *feature = adapter->ring_feature;
 
-	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
-		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			int dcb_i = feature[RING_F_DCB].indices;
-			if (dcb_i == 8)
-				queue0 = index >> 4;
-			else if (dcb_i == 4)
-				queue0 = index >> 5;
-			else
-				dev_err(&adapter->pdev->dev, "Invalid DCB "
-				        "configuration\n");
-#ifdef IXGBE_FCOE
-			if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
-				struct ixgbe_ring_feature *f;
-
-				rx_ring = &adapter->rx_ring[queue0];
-				f = &adapter->ring_feature[RING_F_FCOE];
-				if ((queue0 == 0) && (index > rx_ring->reg_idx))
-					queue0 = f->mask + index -
-					         rx_ring->reg_idx - 1;
-			}
-#endif /* IXGBE_FCOE */
-		} else {
-			queue0 = index;
-		}
-	} else {
+	index = rx_ring->reg_idx;
+	if (adapter->hw.mac.type == ixgbe_mac_82598EB) {
+		unsigned long mask;
 		mask = (unsigned long) feature[RING_F_RSS].mask;
-		queue0 = index & mask;
 		index = index & mask;
 	}
-
-	rx_ring = &adapter->rx_ring[queue0];
-
 	srrctl = IXGBE_READ_REG(&adapter->hw, IXGBE_SRRCTL(index));
 
 	srrctl &= ~IXGBE_SRRCTL_BSIZEHDR_MASK;
@@ -2002,6 +1975,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 {
 	u64 rdba;
 	struct ixgbe_hw *hw = &adapter->hw;
+	struct ixgbe_ring *rx_ring;
 	struct net_device *netdev = adapter->netdev;
 	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	int i, j;
@@ -2070,16 +2044,17 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	 * the Base and Length of the Rx Descriptor Ring
 	 */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		rdba = adapter->rx_ring[i].dma;
-		j = adapter->rx_ring[i].reg_idx;
+		rx_ring = &adapter->rx_ring[i];
+		rdba = rx_ring->dma;
+		j = rx_ring->reg_idx;
 		IXGBE_WRITE_REG(hw, IXGBE_RDBAL(j), (rdba & DMA_BIT_MASK(32)));
 		IXGBE_WRITE_REG(hw, IXGBE_RDBAH(j), (rdba >> 32));
 		IXGBE_WRITE_REG(hw, IXGBE_RDLEN(j), rdlen);
 		IXGBE_WRITE_REG(hw, IXGBE_RDH(j), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_RDT(j), 0);
-		adapter->rx_ring[i].head = IXGBE_RDH(j);
-		adapter->rx_ring[i].tail = IXGBE_RDT(j);
-		adapter->rx_ring[i].rx_buf_len = rx_buf_len;
+		rx_ring->head = IXGBE_RDH(j);
+		rx_ring->tail = IXGBE_RDT(j);
+		rx_ring->rx_buf_len = rx_buf_len;
 
 #ifdef IXGBE_FCOE
 		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
@@ -2087,12 +2062,12 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 			f = &adapter->ring_feature[RING_F_FCOE];
 			if ((rx_buf_len < IXGBE_FCOE_JUMBO_FRAME_SIZE) &&
 			    (i >= f->mask) && (i < f->mask + f->indices))
-				adapter->rx_ring[i].rx_buf_len =
+				rx_ring->rx_buf_len =
 				        IXGBE_FCOE_JUMBO_FRAME_SIZE;
 		}
 
 #endif /* IXGBE_FCOE */
-		ixgbe_configure_srrctl(adapter, j);
+		ixgbe_configure_srrctl(adapter, rx_ring);
 	}
 
 	if (hw->mac.type == ixgbe_mac_82598EB) {

