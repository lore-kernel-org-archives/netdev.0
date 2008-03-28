From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 8/8] e1000e: reformat register test code,
	fix some minor initialization
Date: Fri, 28 Mar 2008 09:15:42 -0700
Message-ID: <20080328161542.6562.55612.stgit@localhost.localdomain>
References: <20080328161503.6562.44329.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10478 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752113AbYC1QRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 12:17:17 -0400
In-Reply-To: <20080328161503.6562.44329.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

The register tests should be run with all the proper flags enabled
to maximize the test coverage code and make sure we are as close
as we can get to testing regular traffic.

Reformat the code for readability. Minor cleanups in the descriptor
ring setup.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/ethtool.c |  126 +++++++++++++++++++++---------------------
 1 files changed, 64 insertions(+), 62 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 8398dbc..2b660b6 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -638,10 +638,17 @@ static int e1000_set_ringparam(struct net_device *netdev,
 	tx_ring = kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
 	if (!tx_ring)
 		goto err_alloc_tx;
+	/*
+	 * use a memcpy to save any previously configured
+	 * items like napi structs from having to be
+	 * reinitialized
+	 */
+	memcpy(tx_ring, tx_old, sizeof(struct e1000_ring));
 
 	rx_ring = kzalloc(sizeof(struct e1000_ring), GFP_KERNEL);
 	if (!rx_ring)
 		goto err_alloc_rx;
+	memcpy(rx_ring, rx_old, sizeof(struct e1000_ring));
 
 	adapter->tx_ring = tx_ring;
 	adapter->rx_ring = rx_ring;
@@ -697,61 +704,54 @@ err_setup:
 	return err;
 }
 
-static bool reg_pattern_test_array(struct e1000_adapter *adapter, u64 *data,
-				   int reg, int offset, u32 mask, u32 write)
+static bool reg_pattern_test(struct e1000_adapter *adapter, u64 *data,
+			     int reg, int offset, u32 mask, u32 write)
 {
-	int i;
-	u32 read;
+	u32 pat, val;
 	static const u32 test[] =
 		{0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF};
-	for (i = 0; i < ARRAY_SIZE(test); i++) {
+	for (pat = 0; pat < ARRAY_SIZE(test); pat++) {
 		E1000_WRITE_REG_ARRAY(&adapter->hw, reg, offset,
-				      (test[i] & write));
-		read = E1000_READ_REG_ARRAY(&adapter->hw, reg, offset);
-		if (read != (test[i] & write & mask)) {
+				      (test[pat] & write));
+		val = E1000_READ_REG_ARRAY(&adapter->hw, reg, offset);
+		if (val != (test[pat] & write & mask)) {
 			e_err("pattern test reg %04X failed: got "
 			      "0x%08X expected 0x%08X\n",
-				 reg + offset,
-				 read, (test[i] & write & mask));
+			      reg + offset,
+			      val, (test[pat] & write & mask));
 			*data = reg;
-			return true;
+			return 1;
 		}
 	}
-	return false;
+	return 0;
 }
 
 static bool reg_set_and_check(struct e1000_adapter *adapter, u64 *data,
 			      int reg, u32 mask, u32 write)
 {
-	u32 read;
+	u32 val;
 	__ew32(&adapter->hw, reg, write & mask);
-	read = __er32(&adapter->hw, reg);
-	if ((write & mask) != (read & mask)) {
+	val = __er32(&adapter->hw, reg);
+	if ((write & mask) != (val & mask)) {
 		e_err("set/check reg %04X test failed: got 0x%08X"
-		      "expected 0x%08X\n", reg, (read & mask),
-			 (write & mask));
+		      "expected 0x%08X\n", reg, (val & mask), (write & mask));
 		*data = reg;
-		return true;
+		return 1;
 	}
-	return false;
+	return 0;
 }
-
-#define REG_PATTERN_TEST(R, M, W) \
-	do { \
-		if (reg_pattern_test_array(adapter, data, R, 0, M, W)) \
-			return 1; \
+#define REG_PATTERN_TEST_ARRAY(reg, offset, mask, write)                       \
+	do {                                                                   \
+		if (reg_pattern_test(adapter, data, reg, offset, mask, write)) \
+			return 1;                                              \
 	} while (0)
+#define REG_PATTERN_TEST(reg, mask, write)                                     \
+	REG_PATTERN_TEST_ARRAY(reg, 0, mask, write)
 
-#define REG_PATTERN_TEST_ARRAY(R, offset, M, W) \
-	do { \
-		if (reg_pattern_test_array(adapter, data, R, offset, M, W)) \
-			return 1; \
-	} while (0)
-
-#define REG_SET_AND_CHECK(R, M, W) \
-	do { \
-		if (reg_set_and_check(adapter, data, R, M, W)) \
-			return 1; \
+#define REG_SET_AND_CHECK(reg, mask, write)                                    \
+	do {                                                                   \
+		if (reg_set_and_check(adapter, data, reg, mask, write))        \
+			return 1;                                              \
 	} while (0)
 
 static int e1000_reg_test(struct e1000_adapter *adapter, u64 *data)
@@ -1033,7 +1033,6 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	struct pci_dev *pdev = adapter->pdev;
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl;
-	int size;
 	int i;
 	int ret_val;
 
@@ -1042,13 +1041,13 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	if (!tx_ring->count)
 		tx_ring->count = E1000_DEFAULT_TXD;
 
-	size = tx_ring->count * sizeof(struct e1000_buffer);
-	tx_ring->buffer_info = kmalloc(size, GFP_KERNEL);
-	if (!tx_ring->buffer_info) {
+	tx_ring->buffer_info = kcalloc(tx_ring->count,
+				       sizeof(struct e1000_buffer),
+				       GFP_KERNEL);
+	if (!(tx_ring->buffer_info)) {
 		ret_val = 1;
 		goto err_nomem;
 	}
-	memset(tx_ring->buffer_info, 0, size);
 
 	tx_ring->size = tx_ring->count * sizeof(struct e1000_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
@@ -1058,21 +1057,17 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		ret_val = 2;
 		goto err_nomem;
 	}
-	memset(tx_ring->desc, 0, tx_ring->size);
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
 
-	ew32(TDBAL,
-			((u64) tx_ring->dma & 0x00000000FFFFFFFF));
+	ew32(TDBAL, ((u64) tx_ring->dma & 0x00000000FFFFFFFF));
 	ew32(TDBAH, ((u64) tx_ring->dma >> 32));
-	ew32(TDLEN,
-			tx_ring->count * sizeof(struct e1000_tx_desc));
+	ew32(TDLEN, tx_ring->count * sizeof(struct e1000_tx_desc));
 	ew32(TDH, 0);
 	ew32(TDT, 0);
-	ew32(TCTL,
-			E1000_TCTL_PSP | E1000_TCTL_EN |
-			E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT |
-			E1000_COLLISION_DISTANCE << E1000_COLD_SHIFT);
+	ew32(TCTL, E1000_TCTL_PSP | E1000_TCTL_EN | E1000_TCTL_MULR |
+	     E1000_COLLISION_THRESHOLD << E1000_CT_SHIFT |
+	     E1000_COLLISION_DISTANCE << E1000_COLD_SHIFT);
 
 	for (i = 0; i < tx_ring->count; i++) {
 		struct e1000_tx_desc *tx_desc = E1000_TX_DESC(*tx_ring, i);
@@ -1094,12 +1089,11 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 			ret_val = 4;
 			goto err_nomem;
 		}
-		tx_desc->buffer_addr = cpu_to_le64(
-					 tx_ring->buffer_info[i].dma);
+		tx_desc->buffer_addr = cpu_to_le64(tx_ring->buffer_info[i].dma);
 		tx_desc->lower.data = cpu_to_le32(skb->len);
 		tx_desc->lower.data |= cpu_to_le32(E1000_TXD_CMD_EOP |
 						   E1000_TXD_CMD_IFCS |
-						   E1000_TXD_CMD_RPS);
+						   E1000_TXD_CMD_RS);
 		tx_desc->upper.data = 0;
 	}
 
@@ -1108,13 +1102,13 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	if (!rx_ring->count)
 		rx_ring->count = E1000_DEFAULT_RXD;
 
-	size = rx_ring->count * sizeof(struct e1000_buffer);
-	rx_ring->buffer_info = kmalloc(size, GFP_KERNEL);
-	if (!rx_ring->buffer_info) {
+	rx_ring->buffer_info = kcalloc(rx_ring->count,
+				       sizeof(struct e1000_buffer),
+				       GFP_KERNEL);
+	if (!(rx_ring->buffer_info)) {
 		ret_val = 5;
 		goto err_nomem;
 	}
-	memset(rx_ring->buffer_info, 0, size);
 
 	rx_ring->size = rx_ring->count * sizeof(struct e1000_rx_desc);
 	rx_ring->desc = dma_alloc_coherent(&pdev->dev, rx_ring->size,
@@ -1123,7 +1117,6 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 		ret_val = 6;
 		goto err_nomem;
 	}
-	memset(rx_ring->desc, 0, rx_ring->size);
 	rx_ring->next_to_use = 0;
 	rx_ring->next_to_clean = 0;
 
@@ -1135,6 +1128,8 @@ static int e1000_setup_desc_rings(struct e1000_adapter *adapter)
 	ew32(RDH, 0);
 	ew32(RDT, 0);
 	rctl = E1000_RCTL_EN | E1000_RCTL_BAM | E1000_RCTL_SZ_2048 |
+		E1000_RCTL_UPE | E1000_RCTL_MPE | E1000_RCTL_LPE |
+		E1000_RCTL_SBP | E1000_RCTL_SECRC |
 		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
 		(adapter->hw.mac.mc_filter_type << E1000_RCTL_MO_SHIFT);
 	ew32(RCTL, rctl);
@@ -1198,7 +1193,8 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 
 	ctrl_reg = er32(CTRL);
 
-	if (hw->phy.type == e1000_phy_ife) {
+	switch (hw->phy.type) {
+	case e1000_phy_ife:
 		/* force 100, set loopback */
 		e1e_wphy(hw, PHY_CONTROL, 0x6100);
 
@@ -1208,9 +1204,11 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 			     E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
 			     E1000_CTRL_SPD_100 |/* Force Speed to 100 */
 			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
-	} else {
+		break;
+	default:
 		/* force 1000, set loopback */
 		e1e_wphy(hw, PHY_CONTROL, 0x4140);
+		mdelay(250);
 
 		/* Now set up the MAC to the same speed/duplex as the PHY. */
 		ctrl_reg = er32(CTRL);
@@ -1219,6 +1217,10 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 			     E1000_CTRL_FRCDPX | /* Set the Force Duplex Bit */
 			     E1000_CTRL_SPD_1000 |/* Force Speed to 1000 */
 			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
+
+		if ((adapter->hw.mac.type == e1000_ich8lan) ||
+		    (adapter->hw.mac.type == e1000_ich9lan))
+			ctrl_reg |= E1000_CTRL_SLU;	/* Set Link Up */
 	}
 
 	if (hw->phy.media_type == e1000_media_type_copper &&
@@ -1320,7 +1322,7 @@ static int e1000_set_es2lan_mac_loopback(struct e1000_adapter *adapter)
 #define KMRNCTRLSTA_OPMODE (0x1F << 16)
 #define KMRNCTRLSTA_OPMODE_1GB_FD_GMII 0x0582
 	ew32(KMRNCTRLSTA,
-		(KMRNCTRLSTA_OPMODE | KMRNCTRLSTA_OPMODE_1GB_FD_GMII));
+	     (KMRNCTRLSTA_OPMODE | KMRNCTRLSTA_OPMODE_1GB_FD_GMII));
 
 	return 0;
 }
@@ -1446,8 +1448,8 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 	l = 0;
 	for (j = 0; j <= lc; j++) { /* loop count loop */
 		for (i = 0; i < 64; i++) { /* send the packets */
-			e1000_create_lbtest_frame(
-				tx_ring->buffer_info[i].skb, 1024);
+			e1000_create_lbtest_frame(tx_ring->buffer_info[k].skb,
+						  1024);
 			pci_dma_sync_single_for_device(pdev,
 					tx_ring->buffer_info[k].dma,
 					tx_ring->buffer_info[k].length,
@@ -1482,7 +1484,7 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 			ret_val = 13; /* ret_val is the same as mis-compare */
 			break;
 		}
-		if (jiffies >= (time + 2)) {
+		if (jiffies >= (time + 20)) {
 			ret_val = 14; /* error code for time out error */
 			break;
 		}

