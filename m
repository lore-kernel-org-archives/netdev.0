From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/4][TG3]: Add 5784 and 5764 support.
Date: Fri, 05 Oct 2007 20:37:54 -0700
Message-ID: <1191641874.17453.8.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4563 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754760AbXJFCij (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 22:38:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add 5784 and 5764 support.

This patch adds the support for 5784 and 5764 devices.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 482b7df..2378ea3 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -198,6 +198,8 @@ static struct pci_device_id tg3_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5781)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5906)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5906M)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5784)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5764)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
@@ -4921,7 +4923,8 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
 		tw32(GRC_FASTBOOT_PC, 0);
 
 	/*
@@ -6146,6 +6149,12 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	tg3_write_sig_legacy(tp, RESET_KIND_INIT);
 
+	if (tp->pci_chip_rev_id == CHIPREV_ID_5784_A0) {
+		val = tr32(TG3_CPMU_CTRL);
+		val &= ~(CPMU_CTRL_LINK_AWARE_MODE | CPMU_CTRL_LINK_IDLE_MODE);
+		tw32(TG3_CPMU_CTRL, val);
+	}
+
 	/* This works around an issue with Athlon chipsets on
 	 * B3 tigon3 silicon.  This bit has no effect on any
 	 * other revision.  But do not set this on PCI Express
@@ -6180,10 +6189,12 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (err)
 		return err;
 
-	/* This value is determined during the probe time DMA
-	 * engine test, tg3_test_dma.
-	 */
-	tw32(TG3PCI_DMA_RW_CTRL, tp->dma_rwctrl);
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784) {
+		/* This value is determined during the probe time DMA
+		 * engine test, tg3_test_dma.
+		 */
+		tw32(TG3PCI_DMA_RW_CTRL, tp->dma_rwctrl);
+	}
 
 	tp->grc_mode &= ~(GRC_MODE_HOST_SENDBDS |
 			  GRC_MODE_4X_NIC_SEND_RINGS |
@@ -6417,6 +6428,11 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		      RDMAC_MODE_FIFOURUN_ENAB | RDMAC_MODE_FIFOOREAD_ENAB |
 		      RDMAC_MODE_LNGREAD_ENAB);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
+		rdmac_mode |= RDMAC_MODE_BD_SBD_CRPT_ENAB |
+			      RDMAC_MODE_MBUF_RBD_CRPT_ENAB |
+			      RDMAC_MODE_MBUF_SBD_CRPT_ENAB;
+
 	/* If statement applies to 5705 and 5750 PCI devices only */
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
 	     tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) ||
@@ -6578,7 +6594,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 
 	/* Enable host coalescing bug fix */
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787))
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787) ||
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784))
 		val |= (1 << 29);
 
 	tw32_f(WDMAC_MODE, val);
@@ -8353,7 +8370,8 @@ static int tg3_set_tx_csum(struct net_device *dev, u32 data)
   	}
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
 		ethtool_op_set_tx_ipv6_csum(dev, data);
 	else
 		ethtool_op_set_tx_csum(dev, data);
@@ -8849,7 +8867,8 @@ static int tg3_test_memory(struct tg3 *tp)
 
 	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
 			mem_tbl = mem_tbl_5755;
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 			mem_tbl = mem_tbl_5906;
@@ -9600,7 +9619,8 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 			tg3_get_5752_nvram_info(tp);
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755)
 			tg3_get_5755_nvram_info(tp);
-		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
+		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+			 GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
 			tg3_get_5787_nvram_info(tp);
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 			tg3_get_5906_nvram_info(tp);
@@ -9913,6 +9933,7 @@ static int tg3_nvram_write_block_buffered(struct tg3 *tp, u32 offset, u32 len,
 		if ((GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5752) &&
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5755) &&
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5787) &&
+		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784) &&
 		    (tp->nvram_jedecnum == JEDEC_ST) &&
 		    (nvram_cmd & NVRAM_CMD_FIRST)) {
 
@@ -10657,6 +10678,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906 ||
 	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		tp->tg3_flags2 |= TG3_FLG2_5750_PLUS;
@@ -10676,6 +10698,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
 			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
@@ -10693,6 +10716,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5752 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5755 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5787 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)
 		tp->tg3_flags2 |= TG3_FLG2_JUMBO_CAPABLE;
 
@@ -10868,6 +10892,9 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 */
 	tg3_get_eeprom_hw_cfg(tp);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
+		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
+
 	/* Set up tp->grc_local_ctrl before calling tg3_set_power_state().
 	 * GPIO1 driven high will bring 5700's external PHY out of reset.
 	 * It is also used as eeprom write protect on LOMs.
@@ -10934,7 +10961,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787) {
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784) {
 			if (tp->pdev->device != PCI_DEVICE_ID_TIGON3_5756 &&
 			    tp->pdev->device != PCI_DEVICE_ID_TIGON3_5722)
 				tp->tg3_flags2 |= TG3_FLG2_PHY_JITTER_BUG;
@@ -11077,6 +11105,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 */
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		tp->dev->hard_start_xmit = tg3_start_xmit;
 	else
@@ -11698,6 +11727,7 @@ static char * __devinit tg3_phy_string(struct tg3 *tp)
 	case PHY_ID_BCM5780:	return "5780";
 	case PHY_ID_BCM5755:	return "5755";
 	case PHY_ID_BCM5787:	return "5787";
+	case PHY_ID_BCM5784:	return "5784";
 	case PHY_ID_BCM5756:	return "5722/5756";
 	case PHY_ID_BCM5906:	return "5906";
 	case PHY_ID_BCM8002:	return "8002/serdes";
@@ -12042,7 +12072,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	if ((tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS) == 0) {
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787)
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
 			dev->features |= NETIF_F_IPV6_CSUM;
 
 		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 79ce68c..d8e829f 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -108,6 +108,7 @@
 #define  CHIPREV_ID_5752_A1		 0x6001
 #define  CHIPREV_ID_5714_A2		 0x9002
 #define  CHIPREV_ID_5906_A1		 0xc001
+#define  CHIPREV_ID_5784_A0		 0x5784000
 #define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
 #define   ASIC_REV_5700			 0x07
 #define   ASIC_REV_5701			 0x00
@@ -122,6 +123,7 @@
 #define   ASIC_REV_5787			 0x0b
 #define   ASIC_REV_5906			 0x0c
 #define   ASIC_REV_USE_PROD_ID_REG	 0x0f
+#define   ASIC_REV_5784			 0x5784
 #define  GET_CHIP_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 8)
 #define   CHIPREV_5700_AX		 0x70
 #define   CHIPREV_5700_BX		 0x71
@@ -843,7 +845,13 @@
 #define  RCVLSC_MODE_ATTN_ENABLE	 0x00000004
 #define RCVLSC_STATUS			0x00003404
 #define  RCVLSC_STATUS_ERROR_ATTN	 0x00000004
-/* 0x3408 --> 0x3800 unused */
+/* 0x3408 --> 0x3600 unused */
+
+/* CPMU registers */
+#define TG3_CPMU_CTRL			0x00003600
+#define  CPMU_CTRL_LINK_IDLE_MODE	 0x00000200
+#define  CPMU_CTRL_LINK_AWARE_MODE	 0x00000400
+/* 0x3604 --> 0x3800 unused */
 
 /* Mbuf cluster free registers */
 #define MBFREE_MODE			0x00003800
@@ -1023,7 +1031,10 @@
 #define  RDMAC_MODE_FIFOOREAD_ENAB	 0x00000100
 #define  RDMAC_MODE_LNGREAD_ENAB	 0x00000200
 #define  RDMAC_MODE_SPLIT_ENABLE	 0x00000800
+#define  RDMAC_MODE_BD_SBD_CRPT_ENAB	 0x00000800
 #define  RDMAC_MODE_SPLIT_RESET		 0x00001000
+#define  RDMAC_MODE_MBUF_RBD_CRPT_ENAB	 0x00001000
+#define  RDMAC_MODE_MBUF_SBD_CRPT_ENAB	 0x00002000
 #define  RDMAC_MODE_FIFO_SIZE_128	 0x00020000
 #define  RDMAC_MODE_FIFO_LONG_BURST	 0x00030000
 #define RDMAC_STATUS			0x00004804
@@ -2315,6 +2326,7 @@ struct tg3 {
 #define PHY_ID_BCM5755			0xbc050cc0
 #define PHY_ID_BCM5787			0xbc050ce0
 #define PHY_ID_BCM5756			0xbc050ed0
+#define PHY_ID_BCM5784			0xbc050fa0
 #define PHY_ID_BCM5906			0xdc00ac40
 #define PHY_ID_BCM8002			0x60010140
 #define PHY_ID_INVALID			0xffffffff
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 9ebc2c7..6f5fa39 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1950,8 +1950,10 @@
 #define PCI_DEVICE_ID_TIGON3_5751M	0x167d
 #define PCI_DEVICE_ID_TIGON3_5751F	0x167e
 #define PCI_DEVICE_ID_TIGON3_5787F	0x167f
+#define PCI_DEVICE_ID_TIGON3_5764	0x1684
 #define PCI_DEVICE_ID_TIGON3_5787M	0x1693
 #define PCI_DEVICE_ID_TIGON3_5782	0x1696
+#define PCI_DEVICE_ID_TIGON3_5784	0x1698
 #define PCI_DEVICE_ID_TIGON3_5786	0x169a
 #define PCI_DEVICE_ID_TIGON3_5787	0x169b
 #define PCI_DEVICE_ID_TIGON3_5788	0x169c


