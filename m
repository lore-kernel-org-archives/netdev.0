From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 3/5] tg3: Add 5761 support
Date: Wed, 10 Oct 2007 17:45:24 -0700
Message-ID: <1192063525.4878.185.camel@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3902 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756257AbXJKApa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2007 20:45:30 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds rest of the miscellaneous code required to support the
5761.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5b6c1b2..3af93b5 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -200,6 +200,8 @@ static struct pci_device_id tg3_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5906M)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5784)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5764)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5761)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5761E)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
@@ -5087,7 +5089,8 @@ static int tg3_chip_reset(struct tg3 *tp)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
 		tw32(GRC_FASTBOOT_PC, 0);
 
 	/*
@@ -6363,7 +6366,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (err)
 		return err;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784) {
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761) {
 		/* This value is determined during the probe time DMA
 		 * engine test, tg3_test_dma.
 		 */
@@ -6769,7 +6773,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	/* Enable host coalescing bug fix */
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755) ||
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784))
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784) ||
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761))
 		val |= (1 << 29);
 
 	tw32_f(WDMAC_MODE, val);
@@ -6797,7 +6802,13 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	tw32(RCVDCC_MODE, RCVDCC_MODE_ENABLE | RCVDCC_MODE_ATTN_ENABLE);
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS))
 		tw32(MBFREE_MODE, MBFREE_MODE_ENABLE);
-	tw32(SNDDATAC_MODE, SNDDATAC_MODE_ENABLE);
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+		tw32(SNDDATAC_MODE,
+		     SNDDATAC_MODE_ENABLE | SNDDATAC_MODE_CDELAY);
+	else
+		tw32(SNDDATAC_MODE, SNDDATAC_MODE_ENABLE);
+
 	tw32(SNDBDC_MODE, SNDBDC_MODE_ENABLE | SNDBDC_MODE_ATTN_ENABLE);
 	tw32(RCVBDI_MODE, RCVBDI_MODE_ENABLE | RCVBDI_MODE_RCB_ATTN_ENAB);
 	tw32(RCVDBDI_MODE, RCVDBDI_MODE_ENABLE | RCVDBDI_MODE_INV_RING_SZ);
@@ -6824,7 +6835,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	udelay(100);
 
 	tp->rx_mode = RX_MODE_ENABLE;
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755)
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
 		tp->rx_mode |= RX_MODE_IPV6_CSUM_ENABLE;
 
 	tw32_f(MAC_RX_MODE, tp->rx_mode);
@@ -8368,10 +8380,12 @@ static int tg3_set_tso(struct net_device *dev, u32 value)
 	}
 	if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) &&
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)) {
-		if (value)
+		if (value) {
 			dev->features |= NETIF_F_TSO6;
-		else
-			dev->features &= ~NETIF_F_TSO6;
+			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+				dev->features |= NETIF_F_TSO_ECN;
+		} else
+			dev->features &= ~(NETIF_F_TSO6 | NETIF_F_TSO_ECN);
 	}
 	return ethtool_op_set_tso(dev, value);
 }
@@ -8550,7 +8564,8 @@ static int tg3_set_tx_csum(struct net_device *dev, u32 data)
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
 		ethtool_op_set_tx_ipv6_csum(dev, data);
 	else
 		ethtool_op_set_tx_csum(dev, data);
@@ -9047,7 +9062,8 @@ static int tg3_test_memory(struct tg3 *tp)
 	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
 			mem_tbl = mem_tbl_5755;
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 			mem_tbl = mem_tbl_5906;
@@ -9244,6 +9260,7 @@ out:
 static int tg3_test_loopback(struct tg3 *tp)
 {
 	int err = 0;
+	u32 cpmuctrl = 0;
 
 	if (!netif_running(tp->dev))
 		return TG3_LOOPBACK_FAILED;
@@ -9252,8 +9269,40 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (err)
 		return TG3_LOOPBACK_FAILED;
 
+	if (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) {
+		int i;
+		u32 status;
+
+		tw32(TG3_CPMU_MUTEX_REQ, CPMU_MUTEX_REQ_DRIVER);
+
+		/* Wait for up to 40 microseconds to acquire lock. */
+		for (i = 0; i < 4; i++) {
+			status = tr32(TG3_CPMU_MUTEX_GNT);
+			if (status == CPMU_MUTEX_GNT_DRIVER)
+				break;
+			udelay(10);
+		}
+
+		if (status != CPMU_MUTEX_GNT_DRIVER)
+			return TG3_LOOPBACK_FAILED;
+
+		cpmuctrl = tr32(TG3_CPMU_CTRL);
+
+		/* Turn off power management based on link speed. */
+		tw32(TG3_CPMU_CTRL,
+		     cpmuctrl & ~CPMU_CTRL_LINK_SPEED_MODE);
+	}
+
 	if (tg3_run_loopback(tp, TG3_MAC_LOOPBACK))
 		err |= TG3_MAC_LOOPBACK_FAILED;
+
+	if (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) {
+		tw32(TG3_CPMU_CTRL, cpmuctrl);
+
+		/* Release the mutex */
+		tw32(TG3_CPMU_MUTEX_GNT, CPMU_MUTEX_GNT_DRIVER);
+	}
+
 	if (!(tp->tg3_flags2 & TG3_FLG2_PHY_SERDES)) {
 		if (tg3_run_loopback(tp, TG3_PHY_LOOPBACK))
 			err |= TG3_PHY_LOOPBACK_FAILED;
@@ -10192,6 +10241,7 @@ static int tg3_nvram_write_block_buffered(struct tg3 *tp, u32 offset, u32 len,
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5755) &&
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5787) &&
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784) &&
+		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761) &&
 		    (tp->nvram_jedecnum == JEDEC_ST) &&
 		    (nvram_cmd & NVRAM_CMD_FIRST)) {
 
@@ -10941,6 +10991,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906 ||
 	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		tp->tg3_flags2 |= TG3_FLG2_5750_PLUS;
@@ -10961,6 +11012,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
 			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
@@ -10979,6 +11031,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5755 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5787 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906)
 		tp->tg3_flags2 |= TG3_FLG2_JUMBO_CAPABLE;
 
@@ -11164,7 +11217,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 				       pci_state_reg);
 	}
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
 		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
 
 	/* Set up tp->grc_local_ctrl before calling tg3_set_power_state().
@@ -11234,7 +11288,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784) {
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761) {
 			if (tp->pdev->device != PCI_DEVICE_ID_TIGON3_5756 &&
 			    tp->pdev->device != PCI_DEVICE_ID_TIGON3_5722)
 				tp->tg3_flags2 |= TG3_FLG2_PHY_JITTER_BUG;
@@ -11378,6 +11433,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		tp->dev->hard_start_xmit = tg3_start_xmit;
 	else
@@ -12002,6 +12058,7 @@ static char * __devinit tg3_phy_string(struct tg3 *tp)
 	case PHY_ID_BCM5784:	return "5784";
 	case PHY_ID_BCM5756:	return "5722/5756";
 	case PHY_ID_BCM5906:	return "5906";
+	case PHY_ID_BCM5761:	return "5761";
 	case PHY_ID_BCM8002:	return "8002/serdes";
 	case 0:			return "serdes";
 	default:		return "unknown";
@@ -12304,6 +12361,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		if ((tp->tg3_flags2 & TG3_FLG2_HW_TSO_2) &&
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906))
 			dev->features |= NETIF_F_TSO6;
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+			dev->features |= NETIF_F_TSO_ECN;
 	}
 
 
@@ -12345,7 +12404,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784)
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
 			dev->features |= NETIF_F_IPV6_CSUM;
 
 		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 632c2f0..d1f5fa3 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -666,6 +666,7 @@
 #define SNDDATAC_MODE			0x00001000
 #define  SNDDATAC_MODE_RESET		 0x00000001
 #define  SNDDATAC_MODE_ENABLE		 0x00000002
+#define  SNDDATAC_MODE_CDELAY		 0x00000010
 /* 0x1004 --> 0x1400 unused */
 
 /* Send BD ring selector */
@@ -854,7 +855,14 @@
 #define TG3_CPMU_CTRL			0x00003600
 #define  CPMU_CTRL_LINK_IDLE_MODE	 0x00000200
 #define  CPMU_CTRL_LINK_AWARE_MODE	 0x00000400
-/* 0x3604 --> 0x3800 unused */
+#define  CPMU_CTRL_LINK_SPEED_MODE	 0x00004000
+/* 0x3604 --> 0x365c unused */
+
+#define TG3_CPMU_MUTEX_REQ		0x0000365c
+#define  CPMU_MUTEX_REQ_DRIVER		 0x00001000
+#define TG3_CPMU_MUTEX_GNT		0x00003660
+#define  CPMU_MUTEX_GNT_DRIVER		 0x00001000
+/* 0x3664 --> 0x3800 unused */
 
 /* Mbuf cluster free registers */
 #define MBFREE_MODE			0x00003800
@@ -2394,6 +2402,7 @@ struct tg3 {
 #define PHY_ID_BCM5787			0xbc050ce0
 #define PHY_ID_BCM5756			0xbc050ed0
 #define PHY_ID_BCM5784			0xbc050fa0
+#define PHY_ID_BCM5761			0xbc050fd0
 #define PHY_ID_BCM5906			0xdc00ac40
 #define PHY_ID_BCM8002			0x60010140
 #define PHY_ID_INVALID			0xffffffff
@@ -2423,7 +2432,8 @@ struct tg3 {
 	 (X) == PHY_ID_BCM5752 || (X) == PHY_ID_BCM5714 || \
 	 (X) == PHY_ID_BCM5780 || (X) == PHY_ID_BCM5787 || \
 	 (X) == PHY_ID_BCM5755 || (X) == PHY_ID_BCM5756 || \
-	 (X) == PHY_ID_BCM5906 || (X) == PHY_ID_BCM8002)
+	 (X) == PHY_ID_BCM5906 || (X) == PHY_ID_BCM5761 || \
+	 (X) == PHY_ID_BCM8002)
 
 	struct tg3_hw_stats		*hw_stats;
 	dma_addr_t			stats_mapping;
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 6f5fa39..27363bf 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -1950,6 +1950,8 @@
 #define PCI_DEVICE_ID_TIGON3_5751M	0x167d
 #define PCI_DEVICE_ID_TIGON3_5751F	0x167e
 #define PCI_DEVICE_ID_TIGON3_5787F	0x167f
+#define PCI_DEVICE_ID_TIGON3_5761E	0x1680
+#define PCI_DEVICE_ID_TIGON3_5761	0x1681
 #define PCI_DEVICE_ID_TIGON3_5764	0x1684
 #define PCI_DEVICE_ID_TIGON3_5787M	0x1693
 #define PCI_DEVICE_ID_TIGON3_5782	0x1696


