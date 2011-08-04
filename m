From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/6] intel drivers: repair missing flush operations
Date: Thu,  4 Aug 2011 05:18:13 -0700
Message-ID: <1312460298-20405-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:14054 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753507Ab1HDMSl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Aug 2011 08:18:41 -0400
In-Reply-To: <1312460298-20405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

after review of all intel drivers, found several instances where
drivers had the incorrect pattern of:
memory mapped write();
delay();

which should always be:
memory mapped write();
write flush(); /* aka memory mapped read */
delay();

explanation:
The reason for including the flush is that writes can be held
(posted) in PCI/PCIe bridges, but the read always has to complete
synchronously and therefore has to flush all pending writes to a
device.  If a write is held and followed by a delay, the delay
means nothing because the write may not have reached hardware
(maybe even not until the next read)

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by:  Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000/e1000_ethtool.c |    6 ++++++
 drivers/net/e1000/e1000_hw.c      |    3 +++
 drivers/net/e1000e/es2lan.c       |    2 ++
 drivers/net/e1000e/ethtool.c      |    9 +++++++++
 drivers/net/e1000e/ich8lan.c      |    4 ++++
 drivers/net/e1000e/lib.c          |    1 +
 drivers/net/e1000e/phy.c          |    2 ++
 drivers/net/igb/e1000_nvm.c       |    1 +
 drivers/net/igb/igb_ethtool.c     |    5 +++++
 drivers/net/igb/igb_main.c        |    2 ++
 drivers/net/igbvf/netdev.c        |    2 ++
 drivers/net/ixgb/ixgb_ee.c        |    9 +++++++++
 drivers/net/ixgb/ixgb_hw.c        |    2 ++
 drivers/net/ixgbe/ixgbe_common.c  |    1 +
 drivers/net/ixgbe/ixgbe_ethtool.c |    5 +++++
 drivers/net/ixgbe/ixgbe_main.c    |    1 +
 drivers/net/ixgbe/ixgbe_phy.c     |    3 +++
 drivers/net/ixgbe/ixgbe_x540.c    |    1 +
 18 files changed, 59 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index c5f0f04..5548d46 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -838,6 +838,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
+	E1000_WRITE_FLUSH();
 	msleep(10);
 
 	/* Test each interrupt */
@@ -856,6 +857,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 			adapter->test_icr = 0;
 			ew32(IMC, mask);
 			ew32(ICS, mask);
+			E1000_WRITE_FLUSH();
 			msleep(10);
 
 			if (adapter->test_icr & mask) {
@@ -873,6 +875,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		adapter->test_icr = 0;
 		ew32(IMS, mask);
 		ew32(ICS, mask);
+		E1000_WRITE_FLUSH();
 		msleep(10);
 
 		if (!(adapter->test_icr & mask)) {
@@ -890,6 +893,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 			adapter->test_icr = 0;
 			ew32(IMC, ~mask & 0x00007FFF);
 			ew32(ICS, ~mask & 0x00007FFF);
+			E1000_WRITE_FLUSH();
 			msleep(10);
 
 			if (adapter->test_icr) {
@@ -901,6 +905,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
+	E1000_WRITE_FLUSH();
 	msleep(10);
 
 	/* Unhook test interrupt handler */
@@ -1394,6 +1399,7 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 			if (unlikely(++k == txdr->count)) k = 0;
 		}
 		ew32(TDT, k);
+		E1000_WRITE_FLUSH();
 		msleep(200);
 		time = jiffies; /* set the start time for the receive */
 		good_cnt = 0;
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 1698622..8545c7a 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -446,6 +446,7 @@ s32 e1000_reset_hw(struct e1000_hw *hw)
 	/* Must reset the PHY before resetting the MAC */
 	if ((hw->mac_type == e1000_82541) || (hw->mac_type == e1000_82547)) {
 		ew32(CTRL, (ctrl | E1000_CTRL_PHY_RST));
+		E1000_WRITE_FLUSH();
 		msleep(5);
 	}
 
@@ -3752,6 +3753,7 @@ static s32 e1000_acquire_eeprom(struct e1000_hw *hw)
 		/* Clear SK and CS */
 		eecd &= ~(E1000_EECD_CS | E1000_EECD_SK);
 		ew32(EECD, eecd);
+		E1000_WRITE_FLUSH();
 		udelay(1);
 	}
 
@@ -3824,6 +3826,7 @@ static void e1000_release_eeprom(struct e1000_hw *hw)
 		eecd &= ~E1000_EECD_SK;	/* Lower SCK */
 
 		ew32(EECD, eecd);
+		E1000_WRITE_FLUSH();
 
 		udelay(hw->eeprom.delay_usec);
 	} else if (hw->eeprom.type == e1000_eeprom_microwire) {
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index c0ecb2d..e4f4225 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1313,6 +1313,7 @@ static s32 e1000_read_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset,
 	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
 	               E1000_KMRNCTRLSTA_OFFSET) | E1000_KMRNCTRLSTA_REN;
 	ew32(KMRNCTRLSTA, kmrnctrlsta);
+	e1e_flush();
 
 	udelay(2);
 
@@ -1347,6 +1348,7 @@ static s32 e1000_write_kmrn_reg_80003es2lan(struct e1000_hw *hw, u32 offset,
 	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
 	               E1000_KMRNCTRLSTA_OFFSET) | data;
 	ew32(KMRNCTRLSTA, kmrnctrlsta);
+	e1e_flush();
 
 	udelay(2);
 
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index cb1a362..72756e4 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -964,6 +964,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
+	e1e_flush();
 	usleep_range(10000, 20000);
 
 	/* Test each interrupt */
@@ -996,6 +997,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 			adapter->test_icr = 0;
 			ew32(IMC, mask);
 			ew32(ICS, mask);
+			e1e_flush();
 			usleep_range(10000, 20000);
 
 			if (adapter->test_icr & mask) {
@@ -1014,6 +1016,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		adapter->test_icr = 0;
 		ew32(IMS, mask);
 		ew32(ICS, mask);
+		e1e_flush();
 		usleep_range(10000, 20000);
 
 		if (!(adapter->test_icr & mask)) {
@@ -1032,6 +1035,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 			adapter->test_icr = 0;
 			ew32(IMC, ~mask & 0x00007FFF);
 			ew32(ICS, ~mask & 0x00007FFF);
+			e1e_flush();
 			usleep_range(10000, 20000);
 
 			if (adapter->test_icr) {
@@ -1043,6 +1047,7 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 
 	/* Disable all the interrupts */
 	ew32(IMC, 0xFFFFFFFF);
+	e1e_flush();
 	usleep_range(10000, 20000);
 
 	/* Unhook test interrupt handler */
@@ -1276,6 +1281,7 @@ static int e1000_integrated_phy_loopback(struct e1000_adapter *adapter)
 			     E1000_CTRL_FD);	 /* Force Duplex to FULL */
 
 		ew32(CTRL, ctrl_reg);
+		e1e_flush();
 		udelay(500);
 
 		return 0;
@@ -1418,6 +1424,7 @@ static int e1000_set_82571_fiber_loopback(struct e1000_adapter *adapter)
 	 */
 #define E1000_SERDES_LB_ON 0x410
 	ew32(SCTL, E1000_SERDES_LB_ON);
+	e1e_flush();
 	usleep_range(10000, 20000);
 
 	return 0;
@@ -1513,6 +1520,7 @@ static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 		    hw->phy.media_type == e1000_media_type_internal_serdes) {
 #define E1000_SERDES_LB_OFF 0x400
 			ew32(SCTL, E1000_SERDES_LB_OFF);
+			e1e_flush();
 			usleep_range(10000, 20000);
 			break;
 		}
@@ -1592,6 +1600,7 @@ static int e1000_run_loopback_test(struct e1000_adapter *adapter)
 				k = 0;
 		}
 		ew32(TDT, k);
+		e1e_flush();
 		msleep(200);
 		time = jiffies; /* set the start time for the receive */
 		good_cnt = 0;
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index c175212..f7a75c1 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -283,6 +283,7 @@ static void e1000_toggle_lanphypc_value_ich8lan(struct e1000_hw *hw)
 	ctrl |= E1000_CTRL_LANPHYPC_OVERRIDE;
 	ctrl &= ~E1000_CTRL_LANPHYPC_VALUE;
 	ew32(CTRL, ctrl);
+	e1e_flush();
 	udelay(10);
 	ctrl &= ~E1000_CTRL_LANPHYPC_OVERRIDE;
 	ew32(CTRL, ctrl);
@@ -1230,9 +1231,11 @@ s32 e1000_configure_k1_ich8lan(struct e1000_hw *hw, bool k1_enable)
 	ew32(CTRL, reg);
 
 	ew32(CTRL_EXT, ctrl_ext | E1000_CTRL_EXT_SPD_BYPS);
+	e1e_flush();
 	udelay(20);
 	ew32(CTRL, ctrl_reg);
 	ew32(CTRL_EXT, ctrl_ext);
+	e1e_flush();
 	udelay(20);
 
 out:
@@ -3090,6 +3093,7 @@ static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw)
 	ret_val = e1000_acquire_swflag_ich8lan(hw);
 	e_dbg("Issuing a global reset to ich8lan\n");
 	ew32(CTRL, (ctrl | E1000_CTRL_RST));
+	/* cannot issue a flush here because it hangs the hardware */
 	msleep(20);
 
 	if (!ret_val)
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 65580b4..7898a67 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -1986,6 +1986,7 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
 		/* Clear SK and CS */
 		eecd &= ~(E1000_EECD_CS | E1000_EECD_SK);
 		ew32(EECD, eecd);
+		e1e_flush();
 		udelay(1);
 
 		/*
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 2a6ee13..8666476 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -537,6 +537,7 @@ static s32 __e1000_read_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 *data,
 	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
 		       E1000_KMRNCTRLSTA_OFFSET) | E1000_KMRNCTRLSTA_REN;
 	ew32(KMRNCTRLSTA, kmrnctrlsta);
+	e1e_flush();
 
 	udelay(2);
 
@@ -609,6 +610,7 @@ static s32 __e1000_write_kmrn_reg(struct e1000_hw *hw, u32 offset, u16 data,
 	kmrnctrlsta = ((offset << E1000_KMRNCTRLSTA_OFFSET_SHIFT) &
 		       E1000_KMRNCTRLSTA_OFFSET) | data;
 	ew32(KMRNCTRLSTA, kmrnctrlsta);
+	e1e_flush();
 
 	udelay(2);
 
diff --git a/drivers/net/igb/e1000_nvm.c b/drivers/net/igb/e1000_nvm.c
index 7dcd65c..4040712 100644
--- a/drivers/net/igb/e1000_nvm.c
+++ b/drivers/net/igb/e1000_nvm.c
@@ -285,6 +285,7 @@ static s32 igb_ready_nvm_eeprom(struct e1000_hw *hw)
 		/* Clear SK and CS */
 		eecd &= ~(E1000_EECD_CS | E1000_EECD_SK);
 		wr32(E1000_EECD, eecd);
+		wrfl();
 		udelay(1);
 		timeout = NVM_MAX_RETRY_SPI;
 
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index ff244ce..414b022 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1225,6 +1225,7 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 
 	/* Disable all the interrupts */
 	wr32(E1000_IMC, ~0);
+	wrfl();
 	msleep(10);
 
 	/* Define all writable bits for ICS */
@@ -1268,6 +1269,7 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 
 			wr32(E1000_IMC, mask);
 			wr32(E1000_ICS, mask);
+			wrfl();
 			msleep(10);
 
 			if (adapter->test_icr & mask) {
@@ -1289,6 +1291,7 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 
 		wr32(E1000_IMS, mask);
 		wr32(E1000_ICS, mask);
+		wrfl();
 		msleep(10);
 
 		if (!(adapter->test_icr & mask)) {
@@ -1310,6 +1313,7 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 
 			wr32(E1000_IMC, ~mask);
 			wr32(E1000_ICS, ~mask);
+			wrfl();
 			msleep(10);
 
 			if (adapter->test_icr & mask) {
@@ -1321,6 +1325,7 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 
 	/* Disable all the interrupts */
 	wr32(E1000_IMC, ~0);
+	wrfl();
 	msleep(10);
 
 	/* Unhook test interrupt handler */
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index dc59905..ae3937e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1052,6 +1052,7 @@ msi_only:
 		kfree(adapter->vf_data);
 		adapter->vf_data = NULL;
 		wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
+		wrfl();
 		msleep(100);
 		dev_info(&adapter->pdev->dev, "IOV Disabled\n");
 	}
@@ -2198,6 +2199,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 		kfree(adapter->vf_data);
 		adapter->vf_data = NULL;
 		wr32(E1000_IOVCTL, E1000_IOVCTL_REUSE_VFQ);
+		wrfl();
 		msleep(100);
 		dev_info(&pdev->dev, "IOV Disabled\n");
 	}
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index 1330c8e..40ed066 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -1226,6 +1226,7 @@ static void igbvf_configure_tx(struct igbvf_adapter *adapter)
 	/* disable transmits */
 	txdctl = er32(TXDCTL(0));
 	ew32(TXDCTL(0), txdctl & ~E1000_TXDCTL_QUEUE_ENABLE);
+	e1e_flush();
 	msleep(10);
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
@@ -1306,6 +1307,7 @@ static void igbvf_configure_rx(struct igbvf_adapter *adapter)
 	/* disable receives */
 	rxdctl = er32(RXDCTL(0));
 	ew32(RXDCTL(0), rxdctl & ~E1000_RXDCTL_QUEUE_ENABLE);
+	e1e_flush();
 	msleep(10);
 
 	rdlen = rx_ring->count * sizeof(union e1000_adv_rx_desc);
diff --git a/drivers/net/ixgb/ixgb_ee.c b/drivers/net/ixgb/ixgb_ee.c
index c982ab9..38b362b 100644
--- a/drivers/net/ixgb/ixgb_ee.c
+++ b/drivers/net/ixgb/ixgb_ee.c
@@ -57,6 +57,7 @@ ixgb_raise_clock(struct ixgb_hw *hw,
 	 */
 	*eecd_reg = *eecd_reg | IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, *eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 }
 
@@ -75,6 +76,7 @@ ixgb_lower_clock(struct ixgb_hw *hw,
 	 */
 	*eecd_reg = *eecd_reg & ~IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, *eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 }
 
@@ -112,6 +114,7 @@ ixgb_shift_out_bits(struct ixgb_hw *hw,
 			eecd_reg |= IXGB_EECD_DI;
 
 		IXGB_WRITE_REG(hw, EECD, eecd_reg);
+		IXGB_WRITE_FLUSH(hw);
 
 		udelay(50);
 
@@ -206,21 +209,25 @@ ixgb_standby_eeprom(struct ixgb_hw *hw)
 	/*  Deselect EEPROM  */
 	eecd_reg &= ~(IXGB_EECD_CS | IXGB_EECD_SK);
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 
 	/*  Clock high  */
 	eecd_reg |= IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 
 	/*  Select EEPROM  */
 	eecd_reg |= IXGB_EECD_CS;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 
 	/*  Clock low  */
 	eecd_reg &= ~IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 }
 
@@ -239,11 +246,13 @@ ixgb_clock_eeprom(struct ixgb_hw *hw)
 	/*  Rising edge of clock  */
 	eecd_reg |= IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 
 	/*  Falling edge of clock  */
 	eecd_reg &= ~IXGB_EECD_SK;
 	IXGB_WRITE_REG(hw, EECD, eecd_reg);
+	IXGB_WRITE_FLUSH(hw);
 	udelay(50);
 }
 
diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 6cb2e42..3d61a9e 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -149,6 +149,7 @@ ixgb_adapter_stop(struct ixgb_hw *hw)
 	 */
 	IXGB_WRITE_REG(hw, RCTL, IXGB_READ_REG(hw, RCTL) & ~IXGB_RCTL_RXEN);
 	IXGB_WRITE_REG(hw, TCTL, IXGB_READ_REG(hw, TCTL) & ~IXGB_TCTL_TXEN);
+	IXGB_WRITE_FLUSH(hw);
 	msleep(IXGB_DELAY_BEFORE_RESET);
 
 	/* Issue a global reset to the MAC.  This will reset the chip's
@@ -1220,6 +1221,7 @@ ixgb_optics_reset_bcm(struct ixgb_hw *hw)
 	ctrl &= ~IXGB_CTRL0_SDP2;
 	ctrl |= IXGB_CTRL0_SDP3;
 	IXGB_WRITE_REG(hw, CTRL0, ctrl);
+	IXGB_WRITE_FLUSH(hw);
 
 	/* SerDes needs extra delay */
 	msleep(IXGB_SUN_PHY_RESET_DELAY);
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 777051f..fc1375f 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -2632,6 +2632,7 @@ s32 ixgbe_blink_led_start_generic(struct ixgbe_hw *hw, u32 index)
 		autoc_reg |= IXGBE_AUTOC_AN_RESTART;
 		autoc_reg |= IXGBE_AUTOC_FLU;
 		IXGBE_WRITE_REG(hw, IXGBE_AUTOC, autoc_reg);
+		IXGBE_WRITE_FLUSH(hw);
 		usleep_range(10000, 20000);
 	}
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index dc64955..82d4244 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1378,6 +1378,7 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 
 	/* Disable all the interrupts */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, 0xFFFFFFFF);
+	IXGBE_WRITE_FLUSH(&adapter->hw);
 	usleep_range(10000, 20000);
 
 	/* Test each interrupt */
@@ -1398,6 +1399,7 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 			                ~mask & 0x00007FFF);
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS,
 			                ~mask & 0x00007FFF);
+			IXGBE_WRITE_FLUSH(&adapter->hw);
 			usleep_range(10000, 20000);
 
 			if (adapter->test_icr & mask) {
@@ -1415,6 +1417,7 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 		adapter->test_icr = 0;
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, mask);
+		IXGBE_WRITE_FLUSH(&adapter->hw);
 		usleep_range(10000, 20000);
 
 		if (!(adapter->test_icr &mask)) {
@@ -1435,6 +1438,7 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 			                ~mask & 0x00007FFF);
 			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS,
 			                ~mask & 0x00007FFF);
+			IXGBE_WRITE_FLUSH(&adapter->hw);
 			usleep_range(10000, 20000);
 
 			if (adapter->test_icr) {
@@ -1446,6 +1450,7 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 
 	/* Disable all the interrupts */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, 0xFFFFFFFF);
+	IXGBE_WRITE_FLUSH(&adapter->hw);
 	usleep_range(10000, 20000);
 
 	/* Unhook test interrupt handler */
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 1be6175..26b132b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -184,6 +184,7 @@ static inline void ixgbe_disable_sriov(struct ixgbe_adapter *adapter)
 	vmdctl = IXGBE_READ_REG(hw, IXGBE_VT_CTL);
 	vmdctl &= ~IXGBE_VT_CTL_POOL_MASK;
 	IXGBE_WRITE_REG(hw, IXGBE_VT_CTL, vmdctl);
+	IXGBE_WRITE_FLUSH(hw);
 
 	/* take a breather then clean up driver data */
 	msleep(100);
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 735f686..f7ca351 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -1585,6 +1585,7 @@ static s32 ixgbe_raise_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl)
 	*i2cctl |= IXGBE_I2C_CLK_OUT;
 
 	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL, *i2cctl);
+	IXGBE_WRITE_FLUSH(hw);
 
 	/* SCL rise time (1000ns) */
 	udelay(IXGBE_I2C_T_RISE);
@@ -1605,6 +1606,7 @@ static void ixgbe_lower_i2c_clk(struct ixgbe_hw *hw, u32 *i2cctl)
 	*i2cctl &= ~IXGBE_I2C_CLK_OUT;
 
 	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL, *i2cctl);
+	IXGBE_WRITE_FLUSH(hw);
 
 	/* SCL fall time (300ns) */
 	udelay(IXGBE_I2C_T_FALL);
@@ -1628,6 +1630,7 @@ static s32 ixgbe_set_i2c_data(struct ixgbe_hw *hw, u32 *i2cctl, bool data)
 		*i2cctl &= ~IXGBE_I2C_DATA_OUT;
 
 	IXGBE_WRITE_REG(hw, IXGBE_I2CCTL, *i2cctl);
+	IXGBE_WRITE_FLUSH(hw);
 
 	/* Data rise/fall (1000ns/300ns) and set-up time (250ns) */
 	udelay(IXGBE_I2C_T_RISE + IXGBE_I2C_T_FALL + IXGBE_I2C_T_SU_DATA);
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index bec30ed..2696c78 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -162,6 +162,7 @@ mac_reset_top:
 	ctrl_ext = IXGBE_READ_REG(hw, IXGBE_CTRL_EXT);
 	ctrl_ext |= IXGBE_CTRL_EXT_PFRSTD;
 	IXGBE_WRITE_REG(hw, IXGBE_CTRL_EXT, ctrl_ext);
+	IXGBE_WRITE_FLUSH(hw);
 
 	msleep(50);
 
-- 
1.7.6

