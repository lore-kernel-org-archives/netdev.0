From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 6/9][TG3]: Add basic 5906 support.
Date: Wed, 27 Sep 2006 13:34:59 -0700
Message-ID: <1159389299.3411.23.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:23314 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030792AbWI0UiY
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 16:38:24 -0400
To: davem@davemloft.net, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add basic 5906 support.

Add support for the new 5709 device.  This is a new 10/100 Mbps chip.
The mailbox access and firmware interface are quite different from
all other tg3 chips.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index eafca2a..2b062d7 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -199,6 +199,8 @@ static struct pci_device_id tg3_pci_tbl[
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5780)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5780S)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5781)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5906)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5906M)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
@@ -426,6 +428,16 @@ static void tg3_write32_tx_mbox(struct t
 		readl(mbox);
 }
 
+static u32 tg3_read32_mbox_5906(struct tg3 *tp, u32 off)
+{
+	return (readl(tp->regs + off + GRCMBOX_BASE));
+}
+
+static void tg3_write32_mbox_5906(struct tg3 *tp, u32 off, u32 val)
+{
+	writel(val, tp->regs + off + GRCMBOX_BASE);
+}
+
 #define tw32_mailbox(reg, val)	tp->write32_mbox(tp, reg, val)
 #define tw32_mailbox_f(reg, val)	tw32_mailbox_flush(tp, (reg), (val))
 #define tw32_rx_mbox(reg, val)	tp->write32_rx_mbox(tp, reg, val)
@@ -441,6 +453,10 @@ static void tg3_write_mem(struct tg3 *tp
 {
 	unsigned long flags;
 
+	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) &&
+	    (off >= NIC_SRAM_STATS_BLK) && (off < NIC_SRAM_TX_BUFFER_DESC))
+		return;
+
 	spin_lock_irqsave(&tp->indirect_lock, flags);
 	if (tp->tg3_flags & TG3_FLAG_SRAM_USE_CONFIG) {
 		pci_write_config_dword(tp->pdev, TG3PCI_MEM_WIN_BASE_ADDR, off);
@@ -462,6 +478,12 @@ static void tg3_read_mem(struct tg3 *tp,
 {
 	unsigned long flags;
 
+	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) &&
+	    (off >= NIC_SRAM_STATS_BLK) && (off < NIC_SRAM_TX_BUFFER_DESC)) {
+		*val = 0;
+		return;
+	}
+
 	spin_lock_irqsave(&tp->indirect_lock, flags);
 	if (tp->tg3_flags & TG3_FLAG_SRAM_USE_CONFIG) {
 		pci_write_config_dword(tp->pdev, TG3PCI_MEM_WIN_BASE_ADDR, off);
@@ -491,6 +513,9 @@ static inline void tg3_cond_int(struct t
 	if (!(tp->tg3_flags & TG3_FLAG_TAGGED_STATUS) &&
 	    (tp->hw_status->status & SD_STATUS_UPDATED))
 		tw32(GRC_LOCAL_CTRL, tp->grc_local_ctrl | GRC_LCLCTRL_SETINT);
+	else
+		tw32(HOSTCC_MODE, tp->coalesce_mode |
+		     (HOSTCC_MODE_ENABLE | HOSTCC_MODE_NOW));
 }
 
 static void tg3_enable_ints(struct tg3 *tp)
@@ -656,6 +681,10 @@ static int tg3_writephy(struct tg3 *tp, 
 	unsigned int loops;
 	int ret;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906 &&
+	    (reg == MII_TG3_CTRL || reg == MII_TG3_AUX_CTRL))
+		return 0;
+
 	if ((tp->mi_mode & MAC_MI_MODE_AUTO_POLL) != 0) {
 		tw32_f(MAC_MI_MODE,
 		     (tp->mi_mode & ~MAC_MI_MODE_AUTO_POLL));
@@ -1207,7 +1236,12 @@ static int tg3_set_power_state(struct tg
 		tg3_setup_phy(tp, 0);
 	}
 
-	if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF)) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		u32 val;
+
+		val = tr32(GRC_VCPU_EXT_CTRL);
+		tw32(GRC_VCPU_EXT_CTRL, val | GRC_VCPU_EXT_CTRL_DISABLE_WOL);
+	} else if (!(tp->tg3_flags & TG3_FLAG_ENABLE_ASF)) {
 		int i;
 		u32 val;
 
@@ -4667,6 +4701,15 @@ static int tg3_poll_fw(struct tg3 *tp)
 	int i;
 	u32 val;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		for (i = 0; i < 400; i++) {
+			if (tr32(VCPU_STATUS) & VCPU_STATUS_INIT_DONE)
+				return 0;
+			udelay(10);
+		}
+		return -ENODEV;
+	}
+
 	/* Wait for firmware initialization to complete. */
 	for (i = 0; i < 100000; i++) {
 		tg3_read_mem(tp, NIC_SRAM_FIRMWARE_MBOX, &val);
@@ -4735,6 +4778,12 @@ static int tg3_chip_reset(struct tg3 *tp
 		}
 	}
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		tw32(VCPU_STATUS, tr32(VCPU_STATUS) | VCPU_STATUS_DRV_RESET);
+		tw32(GRC_VCPU_EXT_CTRL,
+		     tr32(GRC_VCPU_EXT_CTRL) & ~GRC_VCPU_EXT_CTRL_HALT_CPU);
+	}
+
 	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)
 		val |= GRC_MISC_CFG_KEEP_GPHY_POWER;
 	tw32(GRC_MISC_CFG, val);
@@ -5066,6 +5115,12 @@ static int tg3_halt_cpu(struct tg3 *tp, 
 	BUG_ON(offset == TX_CPU_BASE &&
 	    (tp->tg3_flags2 & TG3_FLG2_5705_PLUS));
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		u32 val = tr32(GRC_VCPU_EXT_CTRL);
+
+		tw32(GRC_VCPU_EXT_CTRL, val | GRC_VCPU_EXT_CTRL_HALT_CPU);
+		return 0;
+	}
 	if (offset == RX_CPU_BASE) {
 		for (i = 0; i < 10000; i++) {
 			tw32(offset + CPU_STATE, 0xffffffff);
@@ -6070,6 +6125,13 @@ static int tg3_reset_hw(struct tg3 *tp, 
 		val = 1;
 	else if (val > tp->rx_std_max_post)
 		val = tp->rx_std_max_post;
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		if (tp->pci_chip_rev_id == CHIPREV_ID_5906_A1)
+			tw32(ISO_PKT_TX, (tr32(ISO_PKT_TX) & ~0x3) | 0x2);
+
+		if (val > (TG3_RX_INTERNAL_RING_SZ_5906 / 2))
+			val = TG3_RX_INTERNAL_RING_SZ_5906 / 2;
+	}
 
 	tw32(RCVBDI_STD_THRESH, val);
 
@@ -6984,9 +7046,10 @@ static int tg3_open(struct net_device *d
 
 		if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
 			if (tp->tg3_flags2 & TG3_FLG2_1SHOT_MSI) {
-				u32 val = tr32(0x7c04);
+				u32 val = tr32(PCIE_TRANSACTION_CFG);
 
-				tw32(0x7c04, val | (1 << 29));
+				tw32(PCIE_TRANSACTION_CFG,
+				     val | PCIE_TRANS_CFG_1SHOT_MSI);
 			}
 		}
 	}
@@ -7941,7 +8004,8 @@ static int tg3_set_tso(struct net_device
 			return -EINVAL;
 		return 0;
 	}
-	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) {
+	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) &&
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)) {
 		if (value)
 			dev->features |= NETIF_F_TSO6;
 		else
@@ -9257,6 +9321,13 @@ static void __devinit tg3_get_5787_nvram
 	}
 }
 
+static void __devinit tg3_get_5906_nvram_info(struct tg3 *tp)
+{
+	tp->nvram_jedecnum = JEDEC_ATMEL;
+	tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+	tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
+}
+
 /* Chips other than 5700/5701 use the NVRAM for fetching info. */
 static void __devinit tg3_nvram_init(struct tg3 *tp)
 {
@@ -9293,6 +9364,8 @@ static void __devinit tg3_nvram_init(str
 			tg3_get_5755_nvram_info(tp);
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
 			tg3_get_5787_nvram_info(tp);
+		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+			tg3_get_5906_nvram_info(tp);
 		else
 			tg3_get_nvram_info(tp);
 
@@ -9766,6 +9839,12 @@ static void __devinit tg3_get_eeprom_hw_
 	/* Assume an onboard device by default.  */
 	tp->tg3_flags |= TG3_FLAG_EEPROM_WRITE_PROT;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		if (!(tr32(PCIE_TRANSACTION_CFG) & PCIE_TRANS_CFG_LOM))
+			tp->tg3_flags &= ~TG3_FLAG_EEPROM_WRITE_PROT;
+		return;
+	}
+
 	tg3_read_mem(tp, NIC_SRAM_DATA_SIG, &val);
 	if (val == NIC_SRAM_DATA_SIG_MAGIC) {
 		u32 nic_cfg, led_cfg;
@@ -10097,7 +10176,10 @@ static void __devinit tg3_read_partno(st
 	}
 
 out_not_found:
-	strcpy(tp->board_part_number, "none");
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+		strcpy(tp->board_part_number, "BCM95906");
+	else
+		strcpy(tp->board_part_number, "none");
 }
 
 static void __devinit tg3_read_fw_ver(struct tg3 *tp)
@@ -10299,6 +10381,7 @@ static int __devinit tg3_get_invariants(
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906 ||
 	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		tp->tg3_flags2 |= TG3_FLG2_5750_PLUS;
 
@@ -10308,7 +10391,8 @@ static int __devinit tg3_get_invariants(
 
 	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787) {
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
 			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
 		} else {
@@ -10325,7 +10409,8 @@ static int __devinit tg3_get_invariants(
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5750 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5752 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5755 &&
-	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5787)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5787 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)
 		tp->tg3_flags2 |= TG3_FLG2_JUMBO_CAPABLE;
 
 	if (pci_find_capability(tp->pdev, PCI_CAP_ID_EXP) != 0)
@@ -10455,6 +10540,12 @@ static int __devinit tg3_get_invariants(
 		pci_cmd &= ~PCI_COMMAND_MEMORY;
 		pci_write_config_word(tp->pdev, PCI_COMMAND, pci_cmd);
 	}
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+		tp->read32_mbox = tg3_read32_mbox_5906;
+		tp->write32_mbox = tg3_write32_mbox_5906;
+		tp->write32_tx_mbox = tg3_write32_mbox_5906;
+		tp->write32_rx_mbox = tg3_write32_mbox_5906;
+	}
 
 	if (tp->write32 == tg3_write_indirect_reg32 ||
 	    ((tp->tg3_flags & TG3_FLAG_PCIX_MODE) &&
@@ -10526,6 +10617,7 @@ static int __devinit tg3_get_invariants(
 	    ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705) &&
 	     (tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) &&
 	     (tp->pci_chip_rev_id != CHIPREV_ID_5705_A1)) ||
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) ||
 	    (tp->tg3_flags2 & TG3_FLG2_ANY_SERDES))
 		tp->tg3_flags2 |= TG3_FLG2_NO_ETH_WIRE_SPEED;
 
@@ -10539,7 +10631,7 @@ static int __devinit tg3_get_invariants(
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
 			tp->tg3_flags2 |= TG3_FLG2_PHY_JITTER_BUG;
-		else
+		else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)
 			tp->tg3_flags2 |= TG3_FLG2_PHY_BER_BUG;
 	}
 
@@ -10629,7 +10721,8 @@ static int __devinit tg3_get_invariants(
 	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5705F)) ||
 	    (tp->pdev->vendor == PCI_VENDOR_ID_BROADCOM &&
 	     (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5751F ||
-	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5753F)))
+	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5753F)) ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		tp->tg3_flags |= TG3_FLAG_10_100_ONLY;
 
 	err = tg3_phy_probe(tp);
@@ -10680,7 +10773,8 @@ static int __devinit tg3_get_invariants(
 	 * straddle the 4GB address boundary in some cases.
 	 */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		tp->dev->hard_start_xmit = tg3_start_xmit;
 	else
 		tp->dev->hard_start_xmit = tg3_start_xmit_dma_bug;
@@ -10761,6 +10855,8 @@ static int __devinit tg3_get_device_addr
 		else
 			tg3_nvram_unlock(tp);
 	}
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+		mac_offset = 0x10;
 
 	/* First try to get it from MAC address mailbox. */
 	tg3_read_mem(tp, NIC_SRAM_MAC_ADDR_HIGH_MBOX, &hi);
@@ -11244,6 +11340,12 @@ static void __devinit tg3_init_bufmgr_co
 			DEFAULT_MB_MACRX_LOW_WATER_5705;
 		tp->bufmgr_config.mbuf_high_water =
 			DEFAULT_MB_HIGH_WATER_5705;
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
+			tp->bufmgr_config.mbuf_mac_rx_low_water =
+				DEFAULT_MB_MACRX_LOW_WATER_5906;
+			tp->bufmgr_config.mbuf_high_water =
+				DEFAULT_MB_HIGH_WATER_5906;
+		}
 
 		tp->bufmgr_config.mbuf_read_dma_low_water_jumbo =
 			DEFAULT_MB_RDMA_LOW_WATER_JUMBO_5780;
@@ -11288,6 +11390,7 @@ static char * __devinit tg3_phy_string(s
 	case PHY_ID_BCM5755:	return "5755";
 	case PHY_ID_BCM5787:	return "5787";
 	case PHY_ID_BCM5756:	return "5722/5756";
+	case PHY_ID_BCM5906:	return "5906";
 	case PHY_ID_BCM8002:	return "8002/serdes";
 	case 0:			return "serdes";
 	default:		return "unknown";
@@ -11590,7 +11693,8 @@ static int __devinit tg3_init_one(struct
 	 */
 	if (tp->tg3_flags2 & TG3_FLG2_HW_TSO) {
 		dev->features |= NETIF_F_TSO;
-		if (tp->tg3_flags2 & TG3_FLG2_HW_TSO_2)
+		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) &&
+		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906))
 			dev->features |= NETIF_F_TSO6;
 	}
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index feed13d..2f5e00c 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -24,6 +24,8 @@
 
 #define RX_COPY_THRESHOLD  		256
 
+#define TG3_RX_INTERNAL_RING_SZ_5906	32
+
 #define RX_STD_MAX_SIZE			1536
 #define RX_STD_MAX_SIZE_5705		512
 #define RX_JUMBO_MAX_SIZE		0xdeadbeef /* XXX */
@@ -129,6 +131,7 @@
 #define  CHIPREV_ID_5752_A0_HW		 0x5000
 #define  CHIPREV_ID_5752_A0		 0x6000
 #define  CHIPREV_ID_5752_A1		 0x6001
+#define  CHIPREV_ID_5906_A1		 0xc001
 #define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
 #define   ASIC_REV_5700			 0x07
 #define   ASIC_REV_5701			 0x00
@@ -141,6 +144,7 @@
 #define   ASIC_REV_5714			 0x09
 #define   ASIC_REV_5755			 0x0a
 #define   ASIC_REV_5787			 0x0b
+#define   ASIC_REV_5906			 0x0c
 #define  GET_CHIP_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 8)
 #define   CHIPREV_5700_AX		 0x70
 #define   CHIPREV_5700_BX		 0x71
@@ -646,7 +650,8 @@
 #define  SNDDATAI_SCTRL_FORCE_ZERO	 0x00000010
 #define SNDDATAI_STATSENAB		0x00000c0c
 #define SNDDATAI_STATSINCMASK		0x00000c10
-/* 0xc14 --> 0xc80 unused */
+#define ISO_PKT_TX			0x00000c20
+/* 0xc24 --> 0xc80 unused */
 #define SNDDATAI_COS_CNT_0		0x00000c80
 #define SNDDATAI_COS_CNT_1		0x00000c84
 #define SNDDATAI_COS_CNT_2		0x00000c88
@@ -997,11 +1002,13 @@
 #define BUFMGR_MB_MACRX_LOW_WATER	0x00004414
 #define  DEFAULT_MB_MACRX_LOW_WATER	  0x00000020
 #define  DEFAULT_MB_MACRX_LOW_WATER_5705  0x00000010
+#define  DEFAULT_MB_MACRX_LOW_WATER_5906  0x00000004
 #define  DEFAULT_MB_MACRX_LOW_WATER_JUMBO 0x00000098
 #define  DEFAULT_MB_MACRX_LOW_WATER_JUMBO_5780 0x0000004b
 #define BUFMGR_MB_HIGH_WATER		0x00004418
 #define  DEFAULT_MB_HIGH_WATER		 0x00000060
 #define  DEFAULT_MB_HIGH_WATER_5705	 0x00000060
+#define  DEFAULT_MB_HIGH_WATER_5906	 0x00000010
 #define  DEFAULT_MB_HIGH_WATER_JUMBO	 0x0000017c
 #define  DEFAULT_MB_HIGH_WATER_JUMBO_5780 0x00000096
 #define BUFMGR_RX_MB_ALLOC_REQ		0x0000441c
@@ -1138,7 +1145,12 @@
 #define TX_CPU_STATE			0x00005404
 #define TX_CPU_PGMCTR			0x0000541c
 
+#define VCPU_STATUS			0x00005100
+#define  VCPU_STATUS_INIT_DONE		 0x04000000
+#define  VCPU_STATUS_DRV_RESET		 0x08000000
+
 /* Mailboxes */
+#define GRCMBOX_BASE			0x00005600
 #define GRCMBOX_INTERRUPT_0		0x00005800 /* 64-bit */
 #define GRCMBOX_INTERRUPT_1		0x00005808 /* 64-bit */
 #define GRCMBOX_INTERRUPT_2		0x00005810 /* 64-bit */
@@ -1398,7 +1410,10 @@
 #define GRC_EEPROM_CTRL			0x00006840
 #define GRC_MDI_CTRL			0x00006844
 #define GRC_SEEPROM_DELAY		0x00006848
-/* 0x684c --> 0x6c00 unused */
+/* 0x684c --> 0x6890 unused */
+#define GRC_VCPU_EXT_CTRL		0x00006890
+#define GRC_VCPU_EXT_CTRL_HALT_CPU	 0x00400000
+#define GRC_VCPU_EXT_CTRL_DISABLE_WOL	 0x20000000
 #define GRC_FASTBOOT_PC			0x00006894	/* 5752, 5755, 5787 */
 
 /* 0x6c00 --> 0x7000 unused */
@@ -1485,7 +1500,11 @@
 #define NVRAM_WRITE1			0x00007028
 /* 0x702c --> 0x7400 unused */
 
-/* 0x7400 --> 0x8000 unused */
+/* 0x7400 --> 0x7c00 unused */
+#define PCIE_TRANSACTION_CFG		0x00007c04
+#define PCIE_TRANS_CFG_1SHOT_MSI	 0x20000000
+#define PCIE_TRANS_CFG_LOM		 0x00000020
+
 
 #define TG3_EEPROM_MAGIC		0x669955aa
 
@@ -2283,6 +2302,7 @@ struct tg3 {
 #define PHY_ID_BCM5755			0xbc050cc0
 #define PHY_ID_BCM5787			0xbc050ce0
 #define PHY_ID_BCM5756			0xbc050ed0
+#define PHY_ID_BCM5906			0xdc00ac40
 #define PHY_ID_BCM8002			0x60010140
 #define PHY_ID_INVALID			0xffffffff
 #define PHY_ID_REV_MASK			0x0000000f
@@ -2310,7 +2330,7 @@ struct tg3 {
 	 (X) == PHY_ID_BCM5752 || (X) == PHY_ID_BCM5714 || \
 	 (X) == PHY_ID_BCM5780 || (X) == PHY_ID_BCM5787 || \
 	 (X) == PHY_ID_BCM5755 || (X) == PHY_ID_BCM5756 || \
-	 (X) == PHY_ID_BCM8002)
+	 (X) == PHY_ID_BCM5906 || (X) == PHY_ID_BCM8002)
 
 	struct tg3_hw_stats		*hw_stats;
 	dma_addr_t			stats_mapping;
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index d9e75be..2cead40 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1945,6 +1945,8 @@
 #define PCI_DEVICE_ID_TIGON3_5901	0x170d
 #define PCI_DEVICE_ID_BCM4401B1		0x170c
 #define PCI_DEVICE_ID_TIGON3_5901_2	0x170e
+#define PCI_DEVICE_ID_TIGON3_5906	0x1712
+#define PCI_DEVICE_ID_TIGON3_5906M	0x1713
 #define PCI_DEVICE_ID_BCM4401		0x4401
 #define PCI_DEVICE_ID_BCM4401B0		0x4402
 


