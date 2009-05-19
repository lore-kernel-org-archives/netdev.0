From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] ixgbe: Cleanup feature setup code to make
	the code more readable
Date: Tue, 19 May 2009 12:19:11 -0700
Message-ID: <20090519191911.5063.75627.stgit@localhost.localdomain>
References: <20090519191819.5063.28388.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:47537 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751051AbZESTT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 15:19:26 -0400
In-Reply-To: <20090519191819.5063.28388.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This is purely a cleanup patch.  This collapses some of the code required
when we configure our Tx and Rx feature sets, and makes the code more
readable and maintainable.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   85 ++++++++++++++++++++++++----------------
 1 files changed, 50 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d342619..3d5f7f5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1747,10 +1747,11 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 	u32 srrctl;
 	int queue0 = 0;
 	unsigned long mask;
+	struct ixgbe_ring_feature *feature = adapter->ring_feature;
 
 	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			int dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+			int dcb_i = feature[RING_F_DCB].indices;
 			if (dcb_i == 8)
 				queue0 = index >> 4;
 			else if (dcb_i == 4)
@@ -1773,7 +1774,7 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 			queue0 = index;
 		}
 	} else {
-		mask = (unsigned long) adapter->ring_feature[RING_F_RSS].mask;
+		mask = (unsigned long) feature[RING_F_RSS].mask;
 		queue0 = index & mask;
 		index = index & mask;
 	}
@@ -1804,6 +1805,36 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(index), srrctl);
 }
 
+static u32 ixgbe_setup_mrqc(struct ixgbe_adapter *adapter)
+{
+	u32 mrqc = 0;
+	int mask;
+
+	if (!(adapter->hw.mac.type == ixgbe_mac_82599EB))
+		return mrqc;
+
+	mask = adapter->flags & (IXGBE_FLAG_RSS_ENABLED
+#ifdef CONFIG_IXGBE_DCB
+				 | IXGBE_FLAG_DCB_ENABLED
+#endif
+				);
+
+	switch (mask) {
+	case (IXGBE_FLAG_RSS_ENABLED):
+		mrqc = IXGBE_MRQC_RSSEN;
+		break;
+#ifdef CONFIG_IXGBE_DCB
+	case (IXGBE_FLAG_DCB_ENABLED):
+		mrqc = IXGBE_MRQC_RT8TCEN;
+		break;
+#endif /* CONFIG_IXGBE_DCB */
+	default:
+		break;
+	}
+
+	return mrqc;
+}
+
 /**
  * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
  * @adapter: board private structure
@@ -1877,8 +1908,10 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
 	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
 
-	/* Setup the HW Rx Head and Tail Descriptor Pointers and
-	 * the Base and Length of the Rx Descriptor Ring */
+	/*
+	 * Setup the HW Rx Head and Tail Descriptor Pointers and
+	 * the Base and Length of the Rx Descriptor Ring
+	 */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		rdba = adapter->rx_ring[i].dma;
 		j = adapter->rx_ring[i].reg_idx;
@@ -1922,23 +1955,8 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	}
 
 	/* Program MRQC for the distribution of queues */
-	if (hw->mac.type == ixgbe_mac_82599EB) {
-		int mask = adapter->flags & (
-				IXGBE_FLAG_RSS_ENABLED
-				| IXGBE_FLAG_DCB_ENABLED
-				);
+	mrqc = ixgbe_setup_mrqc(adapter);
 
-		switch (mask) {
-		case (IXGBE_FLAG_RSS_ENABLED):
-			mrqc = IXGBE_MRQC_RSSEN;
-			break;
-		case (IXGBE_FLAG_DCB_ENABLED):
-			mrqc = IXGBE_MRQC_RT8TCEN;
-			break;
-		default:
-			break;
-		}
-	}
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
 		/* Fill out redirection table */
 		for (i = 0, j = 0; i < 128; i++, j++) {
@@ -2842,17 +2860,15 @@ static void ixgbe_reset_task(struct work_struct *work)
 static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 {
 	bool ret = false;
+	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_DCB];
 
-	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-		adapter->ring_feature[RING_F_DCB].mask = 0x7 << 3;
-		adapter->num_rx_queues =
-		                      adapter->ring_feature[RING_F_DCB].indices;
-		adapter->num_tx_queues =
-		                      adapter->ring_feature[RING_F_DCB].indices;
-		ret = true;
-	} else {
-		ret = false;
-	}
+	if (!(adapter->flags & IXGBE_FLAG_DCB_ENABLED))
+		return ret;
+
+	f->mask = 0x7 << 3;
+	adapter->num_rx_queues = f->indices;
+	adapter->num_tx_queues = f->indices;
+	ret = true;
 
 	return ret;
 }
@@ -2869,13 +2885,12 @@ static inline bool ixgbe_set_dcb_queues(struct ixgbe_adapter *adapter)
 static inline bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 {
 	bool ret = false;
+	struct ixgbe_ring_feature *f = &adapter->ring_feature[RING_F_RSS];
 
 	if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-		adapter->ring_feature[RING_F_RSS].mask = 0xF;
-		adapter->num_rx_queues =
-		                      adapter->ring_feature[RING_F_RSS].indices;
-		adapter->num_tx_queues =
-		                      adapter->ring_feature[RING_F_RSS].indices;
+		f->mask = 0xF;
+		adapter->num_rx_queues = f->indices;
+		adapter->num_tx_queues = f->indices;
 		ret = true;
 	} else {
 		ret = false;

