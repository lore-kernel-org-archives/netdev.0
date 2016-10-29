From: Mao Wenan <maowenan@huawei.com>
Subject: [PATCH] add one parameter wro_enable for IXGBE
Date: Sat, 29 Oct 2016 15:08:52 +0800
Message-ID: <1477724932-5440-2-git-send-email-maowenan@huawei.com>
References: <1477724932-5440-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <jeffrey.t.kirsher@intel.com>, <intel-wired-lan@lists.osuosl.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:22112 "EHLO
        szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752478AbcJ2HJe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 03:09:34 -0400
In-Reply-To: <1477724932-5440-1-git-send-email-maowenan@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c  | 29 ++++++++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_common.c | 28 +++++++++++++-----------
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   |  9 ++++++++
 4 files changed, 41 insertions(+), 26 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index b06e32d..9bc0be5 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -1027,4 +1027,5 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 				  struct ixgbe_ring *tx_ring);
 u32 ixgbe_rss_indir_tbl_entries(struct ixgbe_adapter *adapter);
 void ixgbe_store_reta(struct ixgbe_adapter *adapter);
+bool ixgbe_wro_enable(void);
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
index fb51be7..c312aaa 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82598.c
@@ -186,20 +186,23 @@ static s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
 	ret_val = ixgbe_start_hw_generic(hw);
 
 #ifndef CONFIG_SPARC
-	/* Disable relaxed ordering */
-	for (i = 0; ((i < hw->mac.max_tx_queues) &&
-	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
-		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
-		regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
-	}
+	if(likely(!ixgbe_wro_enable())) {
+
+		/* Disable relaxed ordering */
+		for (i = 0; ((i < hw->mac.max_tx_queues) &&
+		     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
+			regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
+			regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
+			IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), regval);
+		}
 
-	for (i = 0; ((i < hw->mac.max_rx_queues) &&
-	     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
-		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
-		regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
-			    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
+		for (i = 0; ((i < hw->mac.max_rx_queues) &&
+		     (i < IXGBE_DCA_MAX_QUEUES_82598)); i++) {
+			regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
+			regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
+				    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
+			IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
+		}
 	}
 #endif
 	if (ret_val)
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
index 77d3039..7115dc0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_common.c
@@ -347,22 +347,24 @@ s32 ixgbe_start_hw_gen2(struct ixgbe_hw *hw)
 	IXGBE_WRITE_FLUSH(hw);
 
 #ifndef CONFIG_SPARC
-	/* Disable relaxed ordering */
-	for (i = 0; i < hw->mac.max_tx_queues; i++) {
-		u32 regval;
-
-		regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(i));
-		regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(i), regval);
-	}
+	if(likely(!ixgbe_wro_enable())) {
+		/* Disable relaxed ordering */
+		for (i = 0; i < hw->mac.max_tx_queues; i++) {
+			u32 regval;
+
+			regval = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL_82599(i));
+			regval &= ~IXGBE_DCA_TXCTRL_DESC_WRO_EN;
+			IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL_82599(i), regval);
+		}
 
-	for (i = 0; i < hw->mac.max_rx_queues; i++) {
-		u32 regval;
+		for (i = 0; i < hw->mac.max_rx_queues; i++) {
+			u32 regval;
 
-		regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
-		regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
-			    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
+			regval = IXGBE_READ_REG(hw, IXGBE_DCA_RXCTRL(i));
+			regval &= ~(IXGBE_DCA_RXCTRL_DATA_WRO_EN |
+				    IXGBE_DCA_RXCTRL_HEAD_WRO_EN);
 		IXGBE_WRITE_REG(hw, IXGBE_DCA_RXCTRL(i), regval);
+		}
 	}
 #endif
 	return 0;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index a244d9a..79ebce3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -171,11 +171,20 @@ static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
+static bool wro_enable = 0;
+module_param(wro_enable, bool, 0);
+MODULE_PARM_DESC(wro_enable, "enable 82599 TX and RX's WRO attribute");
+
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+bool ixgbe_wro_enable(void)
+{
+	return wro_enable;
+}
+
 static struct workqueue_struct *ixgbe_wq;
 
 static bool ixgbe_check_cfg_remove(struct ixgbe_hw *hw, struct pci_dev *pdev);
-- 
2.5.0
