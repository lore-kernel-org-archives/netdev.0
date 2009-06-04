From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/6] ixgbe: Add ethtool offline test support
Date: Thu, 04 Jun 2009 14:10:35 -0700
Message-ID: <20090604211034.5011.67632.stgit@localhost.localdomain>
References: <20090604210941.5011.31995.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:36525
	"EHLO QMTA14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754193AbZFDVKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 17:10:50 -0400
In-Reply-To: <20090604210941.5011.31995.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This patch adds support for the ethtool internal test engine.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    8 
 drivers/net/ixgbe/ixgbe_ethtool.c |  824 +++++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c    |   13 -
 3 files changed, 842 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 05a2405..c5f73ed 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -223,6 +223,10 @@ struct ixgbe_q_vector {
 #define IXGBE_TX_CTXTDESC_ADV(R, i)	    \
 	(&(((struct ixgbe_adv_tx_context_desc *)((R).desc))[i]))
 
+#define IXGBE_GET_DESC(R, i, type)	(&(((struct type *)((R).desc))[i]))
+#define IXGBE_TX_DESC(R, i)	IXGBE_GET_DESC(R, i, ixgbe_legacy_tx_desc)
+#define IXGBE_RX_DESC(R, i)	IXGBE_GET_DESC(R, i, ixgbe_legacy_rx_desc)
+
 #define IXGBE_MAX_JUMBO_FRAME_SIZE        16128
 #ifdef IXGBE_FCOE
 /* Use 3K as the baby jumbo frame size for FCoE */
@@ -327,6 +331,10 @@ struct ixgbe_adapter {
 	struct pci_dev *pdev;
 	struct net_device_stats net_stats;
 
+	u32 test_icr;
+	struct ixgbe_ring test_tx_ring;
+	struct ixgbe_ring test_rx_ring;
+
 	/* structs defined in ixgbe_hw.h */
 	struct ixgbe_hw hw;
 	u16 msg_enable;
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 35255b8..583cc5a 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -118,6 +118,13 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
                          IXGBE_PB_STATS_LEN + \
                          IXGBE_QUEUE_STATS_LEN)
 
+static const char ixgbe_gstrings_test[][ETH_GSTRING_LEN] = {
+	"Register test  (offline)", "Eeprom test    (offline)",
+	"Interrupt test (offline)", "Loopback test  (offline)",
+	"Link test   (on/offline)"
+};
+#define IXGBE_TEST_LEN sizeof(ixgbe_gstrings_test) / ETH_GSTRING_LEN
+
 static int ixgbe_get_settings(struct net_device *netdev,
                               struct ethtool_cmd *ecmd)
 {
@@ -743,6 +750,7 @@ static void ixgbe_get_drvinfo(struct net_device *netdev,
 	strncpy(drvinfo->fw_version, firmware_version, 32);
 	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
 	drvinfo->n_stats = IXGBE_STATS_LEN;
+	drvinfo->testinfo_len = IXGBE_TEST_LEN;
 	drvinfo->regdump_len = ixgbe_get_regs_len(netdev);
 }
 
@@ -884,6 +892,8 @@ err_setup:
 static int ixgbe_get_sset_count(struct net_device *netdev, int sset)
 {
 	switch (sset) {
+	case ETH_SS_TEST:
+		return IXGBE_TEST_LEN;
 	case ETH_SS_STATS:
 		return IXGBE_STATS_LEN;
 	default:
@@ -938,6 +948,10 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 	int i;
 
 	switch (stringset) {
+	case ETH_SS_TEST:
+		memcpy(data, *ixgbe_gstrings_test,
+		       IXGBE_TEST_LEN * ETH_GSTRING_LEN);
+		break;
 	case ETH_SS_STATS:
 		for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
 			memcpy(p, ixgbe_gstrings_stats[i].stat_string,
@@ -975,6 +989,815 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 	}
 }
 
+static int ixgbe_link_test(struct ixgbe_adapter *adapter, u64 *data)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	bool link_up;
+	u32 link_speed = 0;
+	*data = 0;
+
+	hw->mac.ops.check_link(hw, &link_speed, &link_up, true);
+	if (link_up)
+		return *data;
+	else
+		*data = 1;
+	return *data;
+}
+
+/* ethtool register test data */
+struct ixgbe_reg_test {
+	u16 reg;
+	u8  array_len;
+	u8  test_type;
+	u32 mask;
+	u32 write;
+};
+
+/* In the hardware, registers are laid out either singly, in arrays
+ * spaced 0x40 bytes apart, or in contiguous tables.  We assume
+ * most tests take place on arrays or single registers (handled
+ * as a single-element array) and special-case the tables.
+ * Table tests are always pattern tests.
+ *
+ * We also make provision for some required setup steps by specifying
+ * registers to be written without any read-back testing.
+ */
+
+#define PATTERN_TEST	1
+#define SET_READ_TEST	2
+#define WRITE_NO_TEST	3
+#define TABLE32_TEST	4
+#define TABLE64_TEST_LO	5
+#define TABLE64_TEST_HI	6
+
+/* default 82599 register test */
+static struct ixgbe_reg_test reg_test_82599[] = {
+	{ IXGBE_FCRTL_82599(0), 1, PATTERN_TEST, 0x8007FFF0, 0x8007FFF0 },
+	{ IXGBE_FCRTH_82599(0), 1, PATTERN_TEST, 0x8007FFF0, 0x8007FFF0 },
+	{ IXGBE_PFCTOP, 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ IXGBE_VLNCTRL, 1, PATTERN_TEST, 0x00000000, 0x00000000 },
+	{ IXGBE_RDBAL(0), 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFF80 },
+	{ IXGBE_RDBAH(0), 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ IXGBE_RDLEN(0), 4, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
+	{ IXGBE_RXDCTL(0), 4, WRITE_NO_TEST, 0, IXGBE_RXDCTL_ENABLE },
+	{ IXGBE_RDT(0), 4, PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ IXGBE_RXDCTL(0), 4, WRITE_NO_TEST, 0, 0 },
+	{ IXGBE_FCRTH(0), 1, PATTERN_TEST, 0x8007FFF0, 0x8007FFF0 },
+	{ IXGBE_FCTTV(0), 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ IXGBE_TDBAL(0), 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ IXGBE_TDBAH(0), 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ IXGBE_TDLEN(0), 4, PATTERN_TEST, 0x000FFF80, 0x000FFF80 },
+	{ IXGBE_RXCTRL, 1, SET_READ_TEST, 0x00000001, 0x00000001 },
+	{ IXGBE_RAL(0), 16, TABLE64_TEST_LO, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ IXGBE_RAL(0), 16, TABLE64_TEST_HI, 0x8001FFFF, 0x800CFFFF },
+	{ IXGBE_MTA(0), 128, TABLE32_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ 0, 0, 0, 0 }
+};
+
+/* default 82598 register test */
+static struct ixgbe_reg_test reg_test_82598[] = {
+	{ IXGBE_FCRTL(0), 1, PATTERN_TEST, 0x8007FFF0, 0x8007FFF0 },
+	{ IXGBE_FCRTH(0), 1, PATTERN_TEST, 0x8007FFF0, 0x8007FFF0 },
+	{ IXGBE_PFCTOP, 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ IXGBE_VLNCTRL, 1, PATTERN_TEST, 0x00000000, 0x00000000 },
+	{ IXGBE_RDBAL(0), 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ IXGBE_RDBAH(0), 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ IXGBE_RDLEN(0), 4, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
+	/* Enable all four RX queues before testing. */
+	{ IXGBE_RXDCTL(0), 4, WRITE_NO_TEST, 0, IXGBE_RXDCTL_ENABLE },
+	/* RDH is read-only for 82598, only test RDT. */
+	{ IXGBE_RDT(0), 4, PATTERN_TEST, 0x0000FFFF, 0x0000FFFF },
+	{ IXGBE_RXDCTL(0), 4, WRITE_NO_TEST, 0, 0 },
+	{ IXGBE_FCRTH(0), 1, PATTERN_TEST, 0x8007FFF0, 0x8007FFF0 },
+	{ IXGBE_FCTTV(0), 1, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ IXGBE_TIPG, 1, PATTERN_TEST, 0x000000FF, 0x000000FF },
+	{ IXGBE_TDBAL(0), 4, PATTERN_TEST, 0xFFFFFF80, 0xFFFFFFFF },
+	{ IXGBE_TDBAH(0), 4, PATTERN_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ IXGBE_TDLEN(0), 4, PATTERN_TEST, 0x000FFF80, 0x000FFFFF },
+	{ IXGBE_RXCTRL, 1, SET_READ_TEST, 0x00000003, 0x00000003 },
+	{ IXGBE_DTXCTL, 1, SET_READ_TEST, 0x00000005, 0x00000005 },
+	{ IXGBE_RAL(0), 16, TABLE64_TEST_LO, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ IXGBE_RAL(0), 16, TABLE64_TEST_HI, 0x800CFFFF, 0x800CFFFF },
+	{ IXGBE_MTA(0), 128, TABLE32_TEST, 0xFFFFFFFF, 0xFFFFFFFF },
+	{ 0, 0, 0, 0 }
+};
+
+#define REG_PATTERN_TEST(R, M, W)                                             \
+{                                                                             \
+	u32 pat, val, before;                                                 \
+	const u32 _test[] = {0x5A5A5A5A, 0xA5A5A5A5, 0x00000000, 0xFFFFFFFF}; \
+	for (pat = 0; pat < ARRAY_SIZE(_test); pat++) {                       \
+		before = readl(adapter->hw.hw_addr + R);                      \
+		writel((_test[pat] & W), (adapter->hw.hw_addr + R));          \
+		val = readl(adapter->hw.hw_addr + R);                         \
+		if (val != (_test[pat] & W & M)) {                            \
+			DPRINTK(DRV, ERR, "pattern test reg %04X failed: got "\
+					  "0x%08X expected 0x%08X\n",         \
+				R, val, (_test[pat] & W & M));                \
+			*data = R;                                            \
+			writel(before, adapter->hw.hw_addr + R);              \
+			return 1;                                             \
+		}                                                             \
+		writel(before, adapter->hw.hw_addr + R);                      \
+	}                                                                     \
+}
+
+#define REG_SET_AND_CHECK(R, M, W)                                            \
+{                                                                             \
+	u32 val, before;                                                      \
+	before = readl(adapter->hw.hw_addr + R);                              \
+	writel((W & M), (adapter->hw.hw_addr + R));                           \
+	val = readl(adapter->hw.hw_addr + R);                                 \
+	if ((W & M) != (val & M)) {                                           \
+		DPRINTK(DRV, ERR, "set/check reg %04X test failed: got 0x%08X "\
+				 "expected 0x%08X\n", R, (val & M), (W & M)); \
+		*data = R;                                                    \
+		writel(before, (adapter->hw.hw_addr + R));                    \
+		return 1;                                                     \
+	}                                                                     \
+	writel(before, (adapter->hw.hw_addr + R));                            \
+}
+
+static int ixgbe_reg_test(struct ixgbe_adapter *adapter, u64 *data)
+{
+	struct ixgbe_reg_test *test;
+	u32 value, before, after;
+	u32 i, toggle;
+
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		toggle = 0x7FFFF30F;
+		test = reg_test_82599;
+	} else {
+		toggle = 0x7FFFF3FF;
+		test = reg_test_82598;
+	}
+
+	/*
+	 * Because the status register is such a special case,
+	 * we handle it separately from the rest of the register
+	 * tests.  Some bits are read-only, some toggle, and some
+	 * are writeable on newer MACs.
+	 */
+	before = IXGBE_READ_REG(&adapter->hw, IXGBE_STATUS);
+	value = (IXGBE_READ_REG(&adapter->hw, IXGBE_STATUS) & toggle);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_STATUS, toggle);
+	after = IXGBE_READ_REG(&adapter->hw, IXGBE_STATUS) & toggle;
+	if (value != after) {
+		DPRINTK(DRV, ERR, "failed STATUS register test got: "
+		        "0x%08X expected: 0x%08X\n", after, value);
+		*data = 1;
+		return 1;
+	}
+	/* restore previous status */
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_STATUS, before);
+
+	/*
+	 * Perform the remainder of the register test, looping through
+	 * the test table until we either fail or reach the null entry.
+	 */
+	while (test->reg) {
+		for (i = 0; i < test->array_len; i++) {
+			switch (test->test_type) {
+			case PATTERN_TEST:
+				REG_PATTERN_TEST(test->reg + (i * 0x40),
+						test->mask,
+						test->write);
+				break;
+			case SET_READ_TEST:
+				REG_SET_AND_CHECK(test->reg + (i * 0x40),
+						test->mask,
+						test->write);
+				break;
+			case WRITE_NO_TEST:
+				writel(test->write,
+				       (adapter->hw.hw_addr + test->reg)
+				       + (i * 0x40));
+				break;
+			case TABLE32_TEST:
+				REG_PATTERN_TEST(test->reg + (i * 4),
+						test->mask,
+						test->write);
+				break;
+			case TABLE64_TEST_LO:
+				REG_PATTERN_TEST(test->reg + (i * 8),
+						test->mask,
+						test->write);
+				break;
+			case TABLE64_TEST_HI:
+				REG_PATTERN_TEST((test->reg + 4) + (i * 8),
+						test->mask,
+						test->write);
+				break;
+			}
+		}
+		test++;
+	}
+
+	*data = 0;
+	return 0;
+}
+
+static int ixgbe_eeprom_test(struct ixgbe_adapter *adapter, u64 *data)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	if (hw->eeprom.ops.validate_checksum(hw, NULL))
+		*data = 1;
+	else
+		*data = 0;
+	return *data;
+}
+
+static irqreturn_t ixgbe_test_intr(int irq, void *data)
+{
+	struct net_device *netdev = (struct net_device *) data;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	adapter->test_icr |= IXGBE_READ_REG(&adapter->hw, IXGBE_EICR);
+
+	return IRQ_HANDLED;
+}
+
+static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
+{
+	struct net_device *netdev = adapter->netdev;
+	u32 mask, i = 0, shared_int = true;
+	u32 irq = adapter->pdev->irq;
+
+	*data = 0;
+
+	/* Hook up test interrupt handler just for this test */
+	if (adapter->msix_entries) {
+		/* NOTE: we don't test MSI-X interrupts here, yet */
+		return 0;
+	} else if (adapter->flags & IXGBE_FLAG_MSI_ENABLED) {
+		shared_int = false;
+		if (request_irq(irq, &ixgbe_test_intr, 0, netdev->name,
+				netdev)) {
+			*data = 1;
+			return -1;
+		}
+	} else if (!request_irq(irq, &ixgbe_test_intr, IRQF_PROBE_SHARED,
+	                        netdev->name, netdev)) {
+		shared_int = false;
+	} else if (request_irq(irq, &ixgbe_test_intr, IRQF_SHARED,
+	                       netdev->name, netdev)) {
+		*data = 1;
+		return -1;
+	}
+	DPRINTK(HW, INFO, "testing %s interrupt\n",
+		(shared_int ? "shared" : "unshared"));
+
+	/* Disable all the interrupts */
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, 0xFFFFFFFF);
+	msleep(10);
+
+	/* Test each interrupt */
+	for (; i < 10; i++) {
+		/* Interrupt to test */
+		mask = 1 << i;
+
+		if (!shared_int) {
+			/*
+			 * Disable the interrupts to be reported in
+			 * the cause register and then force the same
+			 * interrupt and see if one gets posted.  If
+			 * an interrupt was posted to the bus, the
+			 * test failed.
+			 */
+			adapter->test_icr = 0;
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC,
+			                ~mask & 0x00007FFF);
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS,
+			                ~mask & 0x00007FFF);
+			msleep(10);
+
+			if (adapter->test_icr & mask) {
+				*data = 3;
+				break;
+			}
+		}
+
+		/*
+		 * Enable the interrupt to be reported in the cause
+		 * register and then force the same interrupt and see
+		 * if one gets posted.  If an interrupt was not posted
+		 * to the bus, the test failed.
+		 */
+		adapter->test_icr = 0;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, mask);
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, mask);
+		msleep(10);
+
+		if (!(adapter->test_icr &mask)) {
+			*data = 4;
+			break;
+		}
+
+		if (!shared_int) {
+			/*
+			 * Disable the other interrupts to be reported in
+			 * the cause register and then force the other
+			 * interrupts and see if any get posted.  If
+			 * an interrupt was posted to the bus, the
+			 * test failed.
+			 */
+			adapter->test_icr = 0;
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC,
+			                ~mask & 0x00007FFF);
+			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS,
+			                ~mask & 0x00007FFF);
+			msleep(10);
+
+			if (adapter->test_icr) {
+				*data = 5;
+				break;
+			}
+		}
+	}
+
+	/* Disable all the interrupts */
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, 0xFFFFFFFF);
+	msleep(10);
+
+	/* Unhook test interrupt handler */
+	free_irq(irq, netdev);
+
+	return *data;
+}
+
+static void ixgbe_free_desc_rings(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_ring *tx_ring = &adapter->test_tx_ring;
+	struct ixgbe_ring *rx_ring = &adapter->test_rx_ring;
+	struct ixgbe_hw *hw = &adapter->hw;
+	struct pci_dev *pdev = adapter->pdev;
+	u32 reg_ctl;
+	int i;
+
+	/* shut down the DMA engines now so they can be reinitialized later */
+
+	/* first Rx */
+	reg_ctl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
+	reg_ctl &= ~IXGBE_RXCTRL_RXEN;
+	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, reg_ctl);
+	reg_ctl = IXGBE_READ_REG(hw, IXGBE_RXDCTL(0));
+	reg_ctl &= ~IXGBE_RXDCTL_ENABLE;
+	IXGBE_WRITE_REG(hw, IXGBE_RXDCTL(0), reg_ctl);
+
+	/* now Tx */
+	reg_ctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(0));
+	reg_ctl &= ~IXGBE_TXDCTL_ENABLE;
+	IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(0), reg_ctl);
+	if (hw->mac.type == ixgbe_mac_82599EB) {
+		reg_ctl = IXGBE_READ_REG(hw, IXGBE_DMATXCTL);
+		reg_ctl &= ~IXGBE_DMATXCTL_TE;
+		IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL, reg_ctl);
+	}
+
+	ixgbe_reset(adapter);
+
+	if (tx_ring->desc && tx_ring->tx_buffer_info) {
+		for (i = 0; i < tx_ring->count; i++) {
+			struct ixgbe_tx_buffer *buf =
+					&(tx_ring->tx_buffer_info[i]);
+			if (buf->dma)
+				pci_unmap_single(pdev, buf->dma, buf->length,
+				                 PCI_DMA_TODEVICE);
+			if (buf->skb)
+				dev_kfree_skb(buf->skb);
+		}
+	}
+
+	if (rx_ring->desc && rx_ring->rx_buffer_info) {
+		for (i = 0; i < rx_ring->count; i++) {
+			struct ixgbe_rx_buffer *buf =
+					&(rx_ring->rx_buffer_info[i]);
+			if (buf->dma)
+				pci_unmap_single(pdev, buf->dma,
+						 IXGBE_RXBUFFER_2048,
+						 PCI_DMA_FROMDEVICE);
+			if (buf->skb)
+				dev_kfree_skb(buf->skb);
+		}
+	}
+
+	if (tx_ring->desc) {
+		pci_free_consistent(pdev, tx_ring->size, tx_ring->desc,
+		                    tx_ring->dma);
+		tx_ring->desc = NULL;
+	}
+	if (rx_ring->desc) {
+		pci_free_consistent(pdev, rx_ring->size, rx_ring->desc,
+		                    rx_ring->dma);
+		rx_ring->desc = NULL;
+	}
+
+	kfree(tx_ring->tx_buffer_info);
+	tx_ring->tx_buffer_info = NULL;
+	kfree(rx_ring->rx_buffer_info);
+	rx_ring->rx_buffer_info = NULL;
+
+	return;
+}
+
+static int ixgbe_setup_desc_rings(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_ring *tx_ring = &adapter->test_tx_ring;
+	struct ixgbe_ring *rx_ring = &adapter->test_rx_ring;
+	struct pci_dev *pdev = adapter->pdev;
+	u32 rctl, reg_data;
+	int i, ret_val;
+
+	/* Setup Tx descriptor ring and Tx buffers */
+
+	if (!tx_ring->count)
+		tx_ring->count = IXGBE_DEFAULT_TXD;
+
+	tx_ring->tx_buffer_info = kcalloc(tx_ring->count,
+	                                  sizeof(struct ixgbe_tx_buffer),
+	                                  GFP_KERNEL);
+	if (!(tx_ring->tx_buffer_info)) {
+		ret_val = 1;
+		goto err_nomem;
+	}
+
+	tx_ring->size = tx_ring->count * sizeof(struct ixgbe_legacy_tx_desc);
+	tx_ring->size = ALIGN(tx_ring->size, 4096);
+	if (!(tx_ring->desc = pci_alloc_consistent(pdev, tx_ring->size,
+						   &tx_ring->dma))) {
+		ret_val = 2;
+		goto err_nomem;
+	}
+	tx_ring->next_to_use = tx_ring->next_to_clean = 0;
+
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDBAL(0),
+			((u64) tx_ring->dma & 0x00000000FFFFFFFF));
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDBAH(0),
+			((u64) tx_ring->dma >> 32));
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDLEN(0),
+			tx_ring->count * sizeof(struct ixgbe_legacy_tx_desc));
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDH(0), 0);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDT(0), 0);
+
+	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_HLREG0);
+	reg_data |= IXGBE_HLREG0_TXPADEN;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_HLREG0, reg_data);
+
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_DMATXCTL);
+		reg_data |= IXGBE_DMATXCTL_TE;
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_DMATXCTL, reg_data);
+	}
+	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_TXDCTL(0));
+	reg_data |= IXGBE_TXDCTL_ENABLE;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_TXDCTL(0), reg_data);
+
+	for (i = 0; i < tx_ring->count; i++) {
+		struct ixgbe_legacy_tx_desc *desc = IXGBE_TX_DESC(*tx_ring, i);
+		struct sk_buff *skb;
+		unsigned int size = 1024;
+
+		skb = alloc_skb(size, GFP_KERNEL);
+		if (!skb) {
+			ret_val = 3;
+			goto err_nomem;
+		}
+		skb_put(skb, size);
+		tx_ring->tx_buffer_info[i].skb = skb;
+		tx_ring->tx_buffer_info[i].length = skb->len;
+		tx_ring->tx_buffer_info[i].dma =
+			pci_map_single(pdev, skb->data, skb->len,
+					PCI_DMA_TODEVICE);
+		desc->buffer_addr = cpu_to_le64(tx_ring->tx_buffer_info[i].dma);
+		desc->lower.data = cpu_to_le32(skb->len);
+		desc->lower.data |= cpu_to_le32(IXGBE_TXD_CMD_EOP |
+		                                IXGBE_TXD_CMD_IFCS |
+		                                IXGBE_TXD_CMD_RS);
+		desc->upper.data = 0;
+	}
+
+	/* Setup Rx Descriptor ring and Rx buffers */
+
+	if (!rx_ring->count)
+		rx_ring->count = IXGBE_DEFAULT_RXD;
+
+	rx_ring->rx_buffer_info = kcalloc(rx_ring->count,
+	                                  sizeof(struct ixgbe_rx_buffer),
+	                                  GFP_KERNEL);
+	if (!(rx_ring->rx_buffer_info)) {
+		ret_val = 4;
+		goto err_nomem;
+	}
+
+	rx_ring->size = rx_ring->count * sizeof(struct ixgbe_legacy_rx_desc);
+	rx_ring->size = ALIGN(rx_ring->size, 4096);
+	if (!(rx_ring->desc = pci_alloc_consistent(pdev, rx_ring->size,
+						   &rx_ring->dma))) {
+		ret_val = 5;
+		goto err_nomem;
+	}
+	rx_ring->next_to_use = rx_ring->next_to_clean = 0;
+
+	rctl = IXGBE_READ_REG(&adapter->hw, IXGBE_RXCTRL);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXCTRL, rctl & ~IXGBE_RXCTRL_RXEN);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDBAL(0),
+			((u64)rx_ring->dma & 0xFFFFFFFF));
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDBAH(0),
+			((u64) rx_ring->dma >> 32));
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDLEN(0), rx_ring->size);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDH(0), 0);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDT(0), 0);
+
+	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_FCTRL);
+	reg_data |= IXGBE_FCTRL_BAM | IXGBE_FCTRL_SBP | IXGBE_FCTRL_MPE;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCTRL, reg_data);
+
+	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_HLREG0);
+	reg_data &= ~IXGBE_HLREG0_LPBK;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_HLREG0, reg_data);
+
+	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_RDRXCTL);
+#define IXGBE_RDRXCTL_RDMTS_MASK    0x00000003 /* Receive Descriptor Minimum
+                                                  Threshold Size mask */
+	reg_data &= ~IXGBE_RDRXCTL_RDMTS_MASK;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDRXCTL, reg_data);
+
+	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_MCSTCTRL);
+#define IXGBE_MCSTCTRL_MO_MASK      0x00000003 /* Multicast Offset mask */
+	reg_data &= ~IXGBE_MCSTCTRL_MO_MASK;
+	reg_data |= adapter->hw.mac.mc_filter_type;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_MCSTCTRL, reg_data);
+
+	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_RXDCTL(0));
+	reg_data |= IXGBE_RXDCTL_ENABLE;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXDCTL(0), reg_data);
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB) {
+		int j = adapter->rx_ring[0].reg_idx;
+		u32 k;
+		for (k = 0; k < 10; k++) {
+			if (IXGBE_READ_REG(&adapter->hw,
+			                   IXGBE_RXDCTL(j)) & IXGBE_RXDCTL_ENABLE)
+				break;
+			else
+				msleep(1);
+		}
+	}
+
+	rctl |= IXGBE_RXCTRL_RXEN | IXGBE_RXCTRL_DMBYPS;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXCTRL, rctl);
+
+	for (i = 0; i < rx_ring->count; i++) {
+		struct ixgbe_legacy_rx_desc *rx_desc =
+					IXGBE_RX_DESC(*rx_ring, i);
+		struct sk_buff *skb;
+
+		skb = alloc_skb(IXGBE_RXBUFFER_2048 + NET_IP_ALIGN, GFP_KERNEL);
+		if (!skb) {
+			ret_val = 6;
+			goto err_nomem;
+		}
+		skb_reserve(skb, NET_IP_ALIGN);
+		rx_ring->rx_buffer_info[i].skb = skb;
+		rx_ring->rx_buffer_info[i].dma =
+			pci_map_single(pdev, skb->data, IXGBE_RXBUFFER_2048,
+			               PCI_DMA_FROMDEVICE);
+		rx_desc->buffer_addr =
+				cpu_to_le64(rx_ring->rx_buffer_info[i].dma);
+		memset(skb->data, 0x00, skb->len);
+	}
+
+	return 0;
+
+err_nomem:
+	ixgbe_free_desc_rings(adapter);
+	return ret_val;
+}
+
+static int ixgbe_setup_loopback_test(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 reg_data;
+
+	/* right now we only support MAC loopback in the driver */
+
+	/* Setup MAC loopback */
+	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_HLREG0);
+	reg_data |= IXGBE_HLREG0_LPBK;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_HLREG0, reg_data);
+
+	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_AUTOC);
+	reg_data &= ~IXGBE_AUTOC_LMS_MASK;
+	reg_data |= IXGBE_AUTOC_LMS_10G_LINK_NO_AN | IXGBE_AUTOC_FLU;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_AUTOC, reg_data);
+
+	/* Disable Atlas Tx lanes; re-enabled in reset path */
+	if (hw->mac.type == ixgbe_mac_82598EB) {
+		u8 atlas;
+
+		hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK, &atlas);
+		atlas |= IXGBE_ATLAS_PDN_TX_REG_EN;
+		hw->mac.ops.write_analog_reg8(hw, IXGBE_ATLAS_PDN_LPBK, atlas);
+
+		hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_10G, &atlas);
+		atlas |= IXGBE_ATLAS_PDN_TX_10G_QL_ALL;
+		hw->mac.ops.write_analog_reg8(hw, IXGBE_ATLAS_PDN_10G, atlas);
+
+		hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_1G, &atlas);
+		atlas |= IXGBE_ATLAS_PDN_TX_1G_QL_ALL;
+		hw->mac.ops.write_analog_reg8(hw, IXGBE_ATLAS_PDN_1G, atlas);
+
+		hw->mac.ops.read_analog_reg8(hw, IXGBE_ATLAS_PDN_AN, &atlas);
+		atlas |= IXGBE_ATLAS_PDN_TX_AN_QL_ALL;
+		hw->mac.ops.write_analog_reg8(hw, IXGBE_ATLAS_PDN_AN, atlas);
+	}
+
+	return 0;
+}
+
+static void ixgbe_loopback_cleanup(struct ixgbe_adapter *adapter)
+{
+	u32 reg_data;
+
+	reg_data = IXGBE_READ_REG(&adapter->hw, IXGBE_HLREG0);
+	reg_data &= ~IXGBE_HLREG0_LPBK;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_HLREG0, reg_data);
+}
+
+static void ixgbe_create_lbtest_frame(struct sk_buff *skb,
+                                      unsigned int frame_size)
+{
+	memset(skb->data, 0xFF, frame_size);
+	frame_size &= ~1;
+	memset(&skb->data[frame_size / 2], 0xAA, frame_size / 2 - 1);
+	memset(&skb->data[frame_size / 2 + 10], 0xBE, 1);
+	memset(&skb->data[frame_size / 2 + 12], 0xAF, 1);
+}
+
+static int ixgbe_check_lbtest_frame(struct sk_buff *skb,
+                                    unsigned int frame_size)
+{
+	frame_size &= ~1;
+	if (*(skb->data + 3) == 0xFF) {
+		if ((*(skb->data + frame_size / 2 + 10) == 0xBE) &&
+		    (*(skb->data + frame_size / 2 + 12) == 0xAF)) {
+			return 0;
+		}
+	}
+	return 13;
+}
+
+static int ixgbe_run_loopback_test(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_ring *tx_ring = &adapter->test_tx_ring;
+	struct ixgbe_ring *rx_ring = &adapter->test_rx_ring;
+	struct pci_dev *pdev = adapter->pdev;
+	int i, j, k, l, lc, good_cnt, ret_val = 0;
+	unsigned long time;
+
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RDT(0), rx_ring->count - 1);
+
+	/*
+	 * Calculate the loop count based on the largest descriptor ring
+	 * The idea is to wrap the largest ring a number of times using 64
+	 * send/receive pairs during each loop
+	 */
+
+	if (rx_ring->count <= tx_ring->count)
+		lc = ((tx_ring->count / 64) * 2) + 1;
+	else
+		lc = ((rx_ring->count / 64) * 2) + 1;
+
+	k = l = 0;
+	for (j = 0; j <= lc; j++) {
+		for (i = 0; i < 64; i++) {
+			ixgbe_create_lbtest_frame(
+					tx_ring->tx_buffer_info[k].skb,
+					1024);
+			pci_dma_sync_single_for_device(pdev,
+				tx_ring->tx_buffer_info[k].dma,
+				tx_ring->tx_buffer_info[k].length,
+				PCI_DMA_TODEVICE);
+			if (unlikely(++k == tx_ring->count))
+				k = 0;
+		}
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_TDT(0), k);
+		msleep(200);
+		/* set the start time for the receive */
+		time = jiffies;
+		good_cnt = 0;
+		do {
+			/* receive the sent packets */
+			pci_dma_sync_single_for_cpu(pdev,
+					rx_ring->rx_buffer_info[l].dma,
+					IXGBE_RXBUFFER_2048,
+					PCI_DMA_FROMDEVICE);
+			ret_val = ixgbe_check_lbtest_frame(
+					rx_ring->rx_buffer_info[l].skb, 1024);
+			if (!ret_val)
+				good_cnt++;
+			if (++l == rx_ring->count)
+				l = 0;
+			/*
+			 * time + 20 msecs (200 msecs on 2.4) is more than
+			 * enough time to complete the receives, if it's
+			 * exceeded, break and error off
+			 */
+		} while (good_cnt < 64 && jiffies < (time + 20));
+		if (good_cnt != 64) {
+			/* ret_val is the same as mis-compare */
+			ret_val = 13;
+			break;
+		}
+		if (jiffies >= (time + 20)) {
+			/* Error code for time out error */
+			ret_val = 14;
+			break;
+		}
+	}
+
+	return ret_val;
+}
+
+static int ixgbe_loopback_test(struct ixgbe_adapter *adapter, u64 *data)
+{
+	*data = ixgbe_setup_desc_rings(adapter);
+	if (*data)
+		goto out;
+	*data = ixgbe_setup_loopback_test(adapter);
+	if (*data)
+		goto err_loopback;
+	*data = ixgbe_run_loopback_test(adapter);
+	ixgbe_loopback_cleanup(adapter);
+
+err_loopback:
+	ixgbe_free_desc_rings(adapter);
+out:
+	return *data;
+}
+
+static void ixgbe_diag_test(struct net_device *netdev,
+                            struct ethtool_test *eth_test, u64 *data)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	bool if_running = netif_running(netdev);
+
+	set_bit(__IXGBE_TESTING, &adapter->state);
+	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
+		/* Offline tests */
+
+		DPRINTK(HW, INFO, "offline testing starting\n");
+
+		/* Link test performed before hardware reset so autoneg doesn't
+		 * interfere with test result */
+		if (ixgbe_link_test(adapter, &data[4]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		if (if_running)
+			/* indicate we're in test mode */
+			dev_close(netdev);
+		else
+			ixgbe_reset(adapter);
+
+		DPRINTK(HW, INFO, "register testing starting\n");
+		if (ixgbe_reg_test(adapter, &data[0]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		ixgbe_reset(adapter);
+		DPRINTK(HW, INFO, "eeprom testing starting\n");
+		if (ixgbe_eeprom_test(adapter, &data[1]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		ixgbe_reset(adapter);
+		DPRINTK(HW, INFO, "interrupt testing starting\n");
+		if (ixgbe_intr_test(adapter, &data[2]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		ixgbe_reset(adapter);
+		DPRINTK(HW, INFO, "loopback testing starting\n");
+		if (ixgbe_loopback_test(adapter, &data[3]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		ixgbe_reset(adapter);
+
+		clear_bit(__IXGBE_TESTING, &adapter->state);
+		if (if_running)
+			dev_open(netdev);
+	} else {
+		DPRINTK(HW, INFO, "online testing starting\n");
+		/* Online tests */
+		if (ixgbe_link_test(adapter, &data[4]))
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+
+		/* Online tests aren't run; pass by default */
+		data[0] = 0;
+		data[1] = 0;
+		data[2] = 0;
+		data[3] = 0;
+
+		clear_bit(__IXGBE_TESTING, &adapter->state);
+	}
+	msleep_interruptible(4 * 1000);
+}
 
 static int ixgbe_wol_exclusion(struct ixgbe_adapter *adapter,
                                struct ethtool_wolinfo *wol)
@@ -1201,6 +2024,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.set_msglevel           = ixgbe_set_msglevel,
 	.get_tso                = ethtool_op_get_tso,
 	.set_tso                = ixgbe_set_tso,
+	.self_test              = ixgbe_diag_test,
 	.get_strings            = ixgbe_get_strings,
 	.phys_id                = ixgbe_phys_id,
 	.get_sset_count         = ixgbe_get_sset_count,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 043acab..0a3e8a3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2598,12 +2598,19 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 	int err;
 
 	err = hw->mac.ops.init_hw(hw);
-	if (err && (err != IXGBE_ERR_SFP_NOT_PRESENT))
-		dev_err(&adapter->pdev->dev, "Hardware Error\n");
+	switch (err) {
+	case 0:
+	case IXGBE_ERR_SFP_NOT_PRESENT:
+		break;
+	case IXGBE_ERR_MASTER_REQUESTS_PENDING:
+		dev_err(&adapter->pdev->dev, "master disable timed out\n");
+		break;
+	default:
+		dev_err(&adapter->pdev->dev, "Hardware Error: %d\n", err);
+	}
 
 	/* reprogram the RAR[0] in case user changed it. */
 	hw->mac.ops.set_rar(hw, 0, hw->mac.addr, 0, IXGBE_RAH_AV);
-
 }
 
 /**

