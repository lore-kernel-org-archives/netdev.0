From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: Patch to modify 82598 PCIe completion timeout
	values
Date: Mon, 03 Aug 2009 10:20:38 -0700
Message-ID: <20090803172037.21652.98159.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:34730
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752412AbZHCRU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2009 13:20:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

The default completion timeout values for 82598 should be in the
range of 50us to 50ms, however the hardware default for these
parts is 500us to 1ms which is less than the 10ms recommended by
the pcie spec. To address this we need to increase the value to
either 10ms to 250ms for capability version 1 configuration, or
16ms to 55ms for version 2.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |   67 ++++++++++++++++++++++++++++++++++++++-
 drivers/net/ixgbe/ixgbe_type.h  |    8 +++++
 2 files changed, 74 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index b992304..522c03b 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -50,6 +50,51 @@ static s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_offset,
                                        u8 *eeprom_data);
 
 /**
+ *  ixgbe_set_pcie_completion_timeout - set pci-e completion timeout
+ *  @hw: pointer to the HW structure
+ *
+ *  The defaults for 82598 should be in the range of 50us to 50ms,
+ *  however the hardware default for these parts is 500us to 1ms which is less
+ *  than the 10ms recommended by the pci-e spec.  To address this we need to
+ *  increase the value to either 10ms to 250ms for capability version 1 config,
+ *  or 16ms to 55ms for version 2.
+ **/
+void ixgbe_set_pcie_completion_timeout(struct ixgbe_hw *hw)
+{
+	struct ixgbe_adapter *adapter = hw->back;
+	u32 gcr = IXGBE_READ_REG(hw, IXGBE_GCR);
+	u16 pcie_devctl2;
+
+	/* only take action if timeout value is defaulted to 0 */
+	if (gcr & IXGBE_GCR_CMPL_TMOUT_MASK)
+		goto out;
+
+	/*
+	 * if capababilities version is type 1 we can write the
+	 * timeout of 10ms to 250ms through the GCR register
+	 */
+	if (!(gcr & IXGBE_GCR_CAP_VER2)) {
+		gcr |= IXGBE_GCR_CMPL_TMOUT_10ms;
+		goto out;
+	}
+
+	/*
+	 * for version 2 capabilities we need to write the config space
+	 * directly in order to set the completion timeout value for
+	 * 16ms to 55ms
+	 */
+	pci_read_config_word(adapter->pdev,
+	                     IXGBE_PCI_DEVICE_CONTROL2, &pcie_devctl2);
+	pcie_devctl2 |= IXGBE_PCI_DEVICE_CONTROL2_16ms;
+	pci_write_config_word(adapter->pdev,
+	                      IXGBE_PCI_DEVICE_CONTROL2, pcie_devctl2);
+out:
+	/* disable completion timeout resend */
+	gcr &= ~IXGBE_GCR_CMPL_TMOUT_RESEND;
+	IXGBE_WRITE_REG(hw, IXGBE_GCR, gcr);
+}
+
+/**
  *  ixgbe_get_pcie_msix_count_82598 - Gets MSI-X vector count
  *  @hw: pointer to hardware structure
  *
@@ -153,6 +198,26 @@ out:
 }
 
 /**
+ *  ixgbe_start_hw_82598 - Prepare hardware for Tx/Rx
+ *  @hw: pointer to hardware structure
+ *
+ *  Starts the hardware using the generic start_hw function.
+ *  Then set pcie completion timeout
+ **/
+s32 ixgbe_start_hw_82598(struct ixgbe_hw *hw)
+{
+	s32 ret_val = 0;
+
+	ret_val = ixgbe_start_hw_generic(hw);
+
+	/* set the completion timeout for interface */
+	if (ret_val == 0)
+		ixgbe_set_pcie_completion_timeout(hw);
+
+	return ret_val;
+}
+
+/**
  *  ixgbe_get_link_capabilities_82598 - Determines link capabilities
  *  @hw: pointer to hardware structure
  *  @speed: pointer to link speed
@@ -1085,7 +1150,7 @@ out:
 static struct ixgbe_mac_operations mac_ops_82598 = {
 	.init_hw		= &ixgbe_init_hw_generic,
 	.reset_hw		= &ixgbe_reset_hw_82598,
-	.start_hw		= &ixgbe_start_hw_generic,
+	.start_hw		= &ixgbe_start_hw_82598,
 	.clear_hw_cntrs		= &ixgbe_clear_hw_cntrs_generic,
 	.get_media_type		= &ixgbe_get_media_type_82598,
 	.get_supported_physical_layer = &ixgbe_get_supported_physical_layer_82598,
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index fa87309..be90eb4 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -718,6 +718,12 @@
 #define IXGBE_ECC_STATUS_82599  0x110E0
 #define IXGBE_BAR_CTRL_82599    0x110F4
 
+/* PCI Express Control */
+#define IXGBE_GCR_CMPL_TMOUT_MASK       0x0000F000
+#define IXGBE_GCR_CMPL_TMOUT_10ms       0x00001000
+#define IXGBE_GCR_CMPL_TMOUT_RESEND     0x00010000
+#define IXGBE_GCR_CAP_VER2              0x00040000
+
 /* Time Sync Registers */
 #define IXGBE_TSYNCRXCTL 0x05188 /* Rx Time Sync Control register - RW */
 #define IXGBE_TSYNCTXCTL 0x08C00 /* Tx Time Sync Control register - RW */
@@ -1521,6 +1527,7 @@
 
 /* PCI Bus Info */
 #define IXGBE_PCI_LINK_STATUS     0xB2
+#define IXGBE_PCI_DEVICE_CONTROL2 0xC8
 #define IXGBE_PCI_LINK_WIDTH      0x3F0
 #define IXGBE_PCI_LINK_WIDTH_1    0x10
 #define IXGBE_PCI_LINK_WIDTH_2    0x20
@@ -1531,6 +1538,7 @@
 #define IXGBE_PCI_LINK_SPEED_5000 0x2
 #define IXGBE_PCI_HEADER_TYPE_REGISTER  0x0E
 #define IXGBE_PCI_HEADER_TYPE_MULTIFUNC 0x80
+#define IXGBE_PCI_DEVICE_CONTROL2_16ms  0x0005
 
 /* Number of 100 microseconds we wait for PCI Express master disable */
 #define IXGBE_PCI_MASTER_DISABLE_TIMEOUT 800

