From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/16] igb: add register rd/wr for surprise removal
Date: Fri, 21 Mar 2014 05:10:02 -0700
Message-ID: <1395403806-29302-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Fujinaka, Todd" <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:15182 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965524AbaCUMKO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Mar 2014 08:10:14 -0400
In-Reply-To: <1395403806-29302-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Fujinaka, Todd" <todd.fujinaka@intel.com>

Add initial register rd/wr for surprise removal (LER).

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_regs.h | 21 ++++++++++++++++++---
 drivers/net/ethernet/intel/igb/igb_main.c   | 22 ++++++++++++++++++++++
 2 files changed, 40 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_regs.h b/drivers/net/ethernet/intel/igb/e1000_regs.h
index d0f14be..bdb246e 100644
--- a/drivers/net/ethernet/intel/igb/e1000_regs.h
+++ b/drivers/net/ethernet/intel/igb/e1000_regs.h
@@ -362,12 +362,25 @@
                                                        * Filter - RW */
 #define E1000_VMVIR(_n)        (0x03700 + (4 * (_n)))
 
-#define wr32(reg, value) (writel(value, hw->hw_addr + reg))
-#define rd32(reg) (readl(hw->hw_addr + reg))
+struct e1000_hw;
+
+u32 igb_rd32(struct e1000_hw *hw, u32 reg);
+
+/* write operations, indexed using DWORDS */
+#define wr32(reg, val) \
+do { \
+	u8 __iomem *hw_addr = ACCESS_ONCE((hw)->hw_addr); \
+	if (!E1000_REMOVED(hw_addr)) \
+		writel((val), &hw_addr[(reg)]); \
+} while (0)
+
+#define rd32(reg) (igb_rd32(hw, reg))
+
 #define wrfl() ((void)rd32(E1000_STATUS))
 
 #define array_wr32(reg, offset, value) \
-	(writel(value, hw->hw_addr + reg + ((offset) << 2)))
+	wr32((reg) + ((offset) << 2), (value))
+
 #define array_rd32(reg, offset) \
 	(readl(hw->hw_addr + reg + ((offset) << 2)))
 
@@ -406,4 +419,6 @@
 #define E1000_INVM_DATA_REG(_n)	(0x12120 + 4*(_n))
 #define E1000_INVM_SIZE		64 /* Number of INVM Data Registers */
 
+#define E1000_REMOVED(h) unlikely(!(h))
+
 #endif
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index f623e6c..e8b4f7b 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -751,6 +751,28 @@ static void igb_cache_ring_register(struct igb_adapter *adapter)
 	}
 }
 
+u32 igb_rd32(struct e1000_hw *hw, u32 reg)
+{
+	struct igb_adapter *igb = container_of(hw, struct igb_adapter, hw);
+	u8 __iomem *hw_addr = ACCESS_ONCE(hw->hw_addr);
+	u32 value = 0;
+
+	if (E1000_REMOVED(hw_addr))
+		return ~value;
+
+	value = readl(&hw_addr[reg]);
+
+	/* reads should not return all F's */
+	if (!(~value) && (!reg || !(~readl(hw_addr)))) {
+		struct net_device *netdev = igb->netdev;
+		hw->hw_addr = NULL;
+		netif_device_detach(netdev);
+		netdev_err(netdev, "PCIe link lost, device now detached\n");
+	}
+
+	return value;
+}
+
 /**
  *  igb_write_ivar - configure ivar for given MSI-X vector
  *  @hw: pointer to the HW structure
-- 
1.8.3.1
