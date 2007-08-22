From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/3] e1000e: Add read code and printout of PBA number (board
	identifier)
Date: Wed, 22 Aug 2007 08:08:44 -0700
Message-ID: <20070822150844.19918.66549.stgit@localhost.localdomain>
References: <20070822150839.19918.86665.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com,
	akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26576 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761397AbXHVPIq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2007 11:08:46 -0400
In-Reply-To: <20070822150839.19918.86665.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The PBA number allows customers and support to directly identify
the type of board and characteristics such as different skews.

Slightly enhance loading messages by adding module name to printout.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/defines.h |    6 ++++--
 drivers/net/e1000e/e1000.h   |    2 ++
 drivers/net/e1000e/lib.c     |   21 +++++++++++++++++++++
 drivers/net/e1000e/netdev.c  |   12 +++++++++---
 4 files changed, 36 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index ca80fde..b32ed45 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -573,9 +573,11 @@
 /* For checksumming, the sum of all words in the NVM should equal 0xBABA. */
 #define NVM_SUM                    0xBABA
 
-#define NVM_WORD_SIZE_BASE_SHIFT   6
+/* PBA (printed board assembly) number words */
+#define NVM_PBA_OFFSET_0           8
+#define NVM_PBA_OFFSET_1           9
 
-/* NVM Commands - Microwire */
+#define NVM_WORD_SIZE_BASE_SHIFT   6
 
 /* NVM Commands - SPI */
 #define NVM_MAX_RETRY_SPI          5000 /* Max wait of 5ms, for RDY signal */
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index bbe5faf..c57e35a 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -358,6 +358,8 @@ extern struct e1000_info e1000_ich8_info;
 extern struct e1000_info e1000_ich9_info;
 extern struct e1000_info e1000_es2_info;
 
+extern s32 e1000e_read_part_num(struct e1000_hw *hw, u32 *part_num);
+
 extern s32  e1000e_commit_phy(struct e1000_hw *hw);
 
 extern bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw);
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 6645c21..3bbfe60 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -2464,3 +2464,24 @@ bool e1000e_enable_mng_pass_thru(struct e1000_hw *hw)
 	return ret_val;
 }
 
+s32 e1000e_read_part_num(struct e1000_hw *hw, u32 *part_num)
+{
+	s32 ret_val;
+	u16 nvm_data;
+
+	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_0, 1, &nvm_data);
+	if (ret_val) {
+		hw_dbg(hw, "NVM Read Error\n");
+		return ret_val;
+	}
+	*part_num = (u32)(nvm_data << 16);
+
+	ret_val = e1000_read_nvm(hw, NVM_PBA_OFFSET_1, 1, &nvm_data);
+	if (ret_val) {
+		hw_dbg(hw, "NVM Read Error\n");
+		return ret_val;
+	}
+	*part_num |= nvm_data;
+
+	return 0;
+}
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 4916f7c..420e111 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3966,6 +3966,7 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
+	u32 part_num;
 
 	/* print bus type/speed/width info */
 	ndev_info(netdev, "(PCI Express:2.5GB/s:%s) "
@@ -3980,6 +3981,10 @@ static void e1000_print_device_info(struct e1000_adapter *adapter)
 	ndev_info(netdev, "Intel(R) PRO/%s Network Connection\n",
 		  (hw->phy.type == e1000_phy_ife)
 		   ? "10/100" : "1000");
+	e1000e_read_part_num(hw, &part_num);
+	ndev_info(netdev, "MAC: %d, PHY: %d, PBA No: %06x-%03x\n",
+		  hw->mac.type, hw->phy.type,
+		  (part_num >> 8), (part_num & 0xff));
 }
 
 /**
@@ -4414,9 +4419,10 @@ static struct pci_driver e1000_driver = {
 static int __init e1000_init_module(void)
 {
 	int ret;
-	printk(KERN_INFO "Intel(R) PRO/1000 Network Driver - %s\n",
-	       e1000e_driver_version);
-	printk(KERN_INFO "Copyright (c) 1999-2007 Intel Corporation.\n");
+	printk(KERN_INFO "%s: Intel(R) PRO/1000 Network Driver - %s\n",
+	       e1000e_driver_name, e1000e_driver_version);
+	printk(KERN_INFO "%s: Copyright (c) 1999-2007 Intel Corporation.\n",
+	       e1000e_driver_name);
 	ret = pci_register_driver(&e1000_driver);
 
 	return ret;
