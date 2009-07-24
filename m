From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 05/13] igb: add completion timeout workaround for
	82575/82576
Date: Thu, 23 Jul 2009 21:08:35 -0700
Message-ID: <20090724040834.30709.22183.stgit@localhost.localdomain>
References: <20090724040700.30709.31473.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:36511 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751076AbZGXEIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 00:08:52 -0400
In-Reply-To: <20090724040700.30709.31473.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The 82575 and 82576 hardware can both experience data corruption issues if
a pci-e completion arrives after the timeout value.  In order to avoid this
we need to increase the timeout value while pci-e master is disabled.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c   |   58 +++++++++++++++++++++++++++++++++++++++
 drivers/net/igb/e1000_defines.h |    8 +++++
 drivers/net/igb/e1000_hw.h      |    4 ++-
 drivers/net/igb/e1000_mac.c     |   14 ---------
 drivers/net/igb/e1000_regs.h    |    1 +
 drivers/net/igb/igb_main.c      |   28 +++++++++++++++++++
 6 files changed, 98 insertions(+), 15 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index 606c25c..c4506bf 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -61,6 +61,7 @@ static void igb_release_swfw_sync_82575(struct e1000_hw *, u16);
 static bool igb_sgmii_active_82575(struct e1000_hw *);
 static s32  igb_reset_init_script_82575(struct e1000_hw *);
 static s32  igb_read_mac_addr_82575(struct e1000_hw *);
+static s32  igb_set_pcie_completion_timeout(struct e1000_hw *hw);
 
 static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 {
@@ -909,6 +910,12 @@ static s32 igb_reset_hw_82575(struct e1000_hw *hw)
 	if (ret_val)
 		hw_dbg("PCI-E Master disable polling has failed.\n");
 
+	/* set the completion timeout for interface */
+	ret_val = igb_set_pcie_completion_timeout(hw);
+	if (ret_val) {
+		hw_dbg("PCI-E Set completion timeout has failed.\n");
+	}
+
 	hw_dbg("Masking off all interrupts\n");
 	wr32(E1000_IMC, 0xffffffff);
 
@@ -1408,6 +1415,57 @@ void igb_rx_fifo_flush_82575(struct e1000_hw *hw)
 }
 
 /**
+ *  igb_set_pcie_completion_timeout - set pci-e completion timeout
+ *  @hw: pointer to the HW structure
+ *
+ *  The defaults for 82575 and 82576 should be in the range of 50us to 50ms,
+ *  however the hardware default for these parts is 500us to 1ms which is less
+ *  than the 10ms recommended by the pci-e spec.  To address this we need to
+ *  increase the value to either 10ms to 200ms for capability version 1 config,
+ *  or 16ms to 55ms for version 2.
+ **/
+static s32 igb_set_pcie_completion_timeout(struct e1000_hw *hw)
+{
+	u32 gcr = rd32(E1000_GCR);
+	s32 ret_val = 0;
+	u16 pcie_devctl2;
+
+	/* only take action if timeout value is defaulted to 0 */
+	if (gcr & E1000_GCR_CMPL_TMOUT_MASK)
+		goto out;
+
+	/*
+	 * if capababilities version is type 1 we can write the
+	 * timeout of 10ms to 200ms through the GCR register
+	 */
+	if (!(gcr & E1000_GCR_CAP_VER2)) {
+		gcr |= E1000_GCR_CMPL_TMOUT_10ms;
+		goto out;
+	}
+
+	/*
+	 * for version 2 capabilities we need to write the config space
+	 * directly in order to set the completion timeout value for
+	 * 16ms to 55ms
+	 */
+	ret_val = igb_read_pcie_cap_reg(hw, PCIE_DEVICE_CONTROL2,
+	                                &pcie_devctl2);
+	if (ret_val)
+		goto out;
+
+	pcie_devctl2 |= PCIE_DEVICE_CONTROL2_16ms;
+
+	ret_val = igb_write_pcie_cap_reg(hw, PCIE_DEVICE_CONTROL2,
+	                                 &pcie_devctl2);
+out:
+	/* disable completion timeout resend */
+	gcr &= ~E1000_GCR_CMPL_TMOUT_RESEND;
+
+	wr32(E1000_GCR, gcr);
+	return ret_val;
+}
+
+/**
  *  igb_vmdq_set_loopback_pf - enable or disable vmdq loopback
  *  @hw: pointer to the hardware struct
  *  @enable: state to enter, either enabled or disabled
diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 3bda3db..c858293 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -435,6 +435,12 @@
 /* Flow Control */
 #define E1000_FCRTL_XONE 0x80000000     /* Enable XON frame transmission */
 
+/* PCI Express Control */
+#define E1000_GCR_CMPL_TMOUT_MASK       0x0000F000
+#define E1000_GCR_CMPL_TMOUT_10ms       0x00001000
+#define E1000_GCR_CMPL_TMOUT_RESEND     0x00010000
+#define E1000_GCR_CAP_VER2              0x00040000
+
 /* PHY Control Register */
 #define MII_CR_FULL_DUPLEX      0x0100  /* FDX =1, half duplex =0 */
 #define MII_CR_RESTART_AUTO_NEG 0x0200  /* Restart auto negotiation */
@@ -569,9 +575,11 @@
 
 /* PCI/PCI-X/PCI-EX Config space */
 #define PCIE_LINK_STATUS             0x12
+#define PCIE_DEVICE_CONTROL2         0x28
 
 #define PCIE_LINK_WIDTH_MASK         0x3F0
 #define PCIE_LINK_WIDTH_SHIFT        4
+#define PCIE_DEVICE_CONTROL2_16ms    0x0005
 
 #define PHY_REVISION_MASK      0xFFFFFFF0
 #define MAX_PHY_REG_ADDRESS    0x1F  /* 5 bit address bus (0-0x1F) */
diff --git a/drivers/net/igb/e1000_hw.h b/drivers/net/igb/e1000_hw.h
index f096ddd..eb41f3b 100644
--- a/drivers/net/igb/e1000_hw.h
+++ b/drivers/net/igb/e1000_hw.h
@@ -494,5 +494,7 @@ extern char *igb_get_hw_dev_name(struct e1000_hw *hw);
 #else
 #define hw_dbg(format, arg...)
 #endif
-
 #endif
+/* These functions must be implemented by drivers */
+s32  igb_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value);
+s32  igb_write_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value);
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 34f1a37..60343b5 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -37,20 +37,6 @@
 static s32 igb_set_default_fc(struct e1000_hw *hw);
 static s32 igb_set_fc_watermarks(struct e1000_hw *hw);
 
-static s32 igb_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
-{
-	struct igb_adapter *adapter = hw->back;
-	u16 cap_offset;
-
-	cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
-	if (!cap_offset)
-		return -E1000_ERR_CONFIG;
-
-	pci_read_config_word(adapter->pdev, cap_offset + reg, value);
-
-	return 0;
-}
-
 /**
  *  igb_get_bus_info_pcie - Get PCIe bus information
  *  @hw: pointer to the HW structure
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index 6e59245..345d144 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -305,6 +305,7 @@ enum {
 #define E1000_CCMCTL      0x05B48 /* CCM Control Register */
 #define E1000_GIOCTL      0x05B44 /* GIO Analog Control Register */
 #define E1000_SCCTL       0x05B4C /* PCIc PLL Configuration Register */
+#define E1000_GCR         0x05B00 /* PCI-Ex Control */
 #define E1000_FACTPS    0x05B30 /* Function Active and Power State to MNG */
 #define E1000_SWSM      0x05B50 /* SW Semaphore */
 #define E1000_FWSM      0x05B54 /* FW Semaphore */
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 39b3b6a..2cb5460 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -5029,6 +5029,34 @@ static int igb_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	}
 }
 
+s32 igb_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
+{
+	struct igb_adapter *adapter = hw->back;
+	u16 cap_offset;
+
+	cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
+	if (!cap_offset)
+		return -E1000_ERR_CONFIG;
+
+	pci_read_config_word(adapter->pdev, cap_offset + reg, value);
+
+	return 0;
+}
+
+s32 igb_write_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
+{
+	struct igb_adapter *adapter = hw->back;
+	u16 cap_offset;
+
+	cap_offset = pci_find_capability(adapter->pdev, PCI_CAP_ID_EXP);
+	if (!cap_offset)
+		return -E1000_ERR_CONFIG;
+
+	pci_write_config_word(adapter->pdev, cap_offset + reg, *value);
+
+	return 0;
+}
+
 static void igb_vlan_rx_register(struct net_device *netdev,
 				 struct vlan_group *grp)
 {

