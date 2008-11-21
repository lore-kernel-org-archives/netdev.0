From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 08/10] tg3: Add 57780 support
Date: Fri, 21 Nov 2008 11:03:08 -0800
Message-ID: <1227295576.5626@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4265 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754244AbYKUT01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 14:26:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the 57780 ASIC revision.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |  239 +++++++++++++++++++++++++++++++++++-----------------
 drivers/net/tg3.h |   14 +++
 2 files changed, 175 insertions(+), 78 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 07bf056..d6d50a6 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -213,6 +213,10 @@ static struct pci_device_id tg3_pci_tbl[] = {
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5761S)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_5761SE)},
 	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5785)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57780)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57760)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57790)},
+	{PCI_DEVICE(PCI_VENDOR_ID_BROADCOM, TG3PCI_DEVICE_TIGON3_57720)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX)},
 	{PCI_DEVICE(PCI_VENDOR_ID_ALTIMA, PCI_DEVICE_ID_ALTIMA_AC1000)},
@@ -1036,6 +1040,9 @@ static int tg3_mdio_init(struct tg3 *tp)
 	}
 
 	switch (phydev->drv->phy_id & phydev->drv->phy_id_mask) {
+	case TG3_PHY_ID_BCM57780:
+		phydev->interface = PHY_INTERFACE_MODE_GMII;
+		break;
 	case TG3_PHY_ID_BCM50610:
 		if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)
 			phydev->dev_flags |= PHY_BRCM_STD_IBND_DISABLE;
@@ -1409,10 +1416,13 @@ static int tg3_phy_init(struct tg3 *tp)
 	switch (phydev->interface) {
 	case PHY_INTERFACE_MODE_GMII:
 	case PHY_INTERFACE_MODE_RGMII:
-		phydev->supported &= (PHY_GBIT_FEATURES |
-				      SUPPORTED_Pause |
-				      SUPPORTED_Asym_Pause);
-		break;
+		if (!(tp->tg3_flags & TG3_FLAG_10_100_ONLY)) {
+			phydev->supported &= (PHY_GBIT_FEATURES |
+					      SUPPORTED_Pause |
+					      SUPPORTED_Asym_Pause);
+			break;
+		}
+		/* fallthru */
 	case PHY_INTERFACE_MODE_MII:
 		phydev->supported &= (PHY_BASIC_FEATURES |
 				      SUPPORTED_Pause |
@@ -5991,11 +6001,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 	tg3_save_pci_state(tp);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+	    (tp->tg3_flags3 & TG3_FLG3_5755_PLUS))
 		tw32(GRC_FASTBOOT_PC, 0);
 
 	/*
@@ -7511,7 +7517,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		      RDMAC_MODE_LNGREAD_ENAB);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 		rdmac_mode |= RDMAC_MODE_BD_SBD_CRPT_ENAB |
 			      RDMAC_MODE_MBUF_RBD_CRPT_ENAB |
 			      RDMAC_MODE_MBUF_SBD_CRPT_ENAB;
@@ -7680,11 +7687,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	}
 
 	/* Enable host coalescing bug fix */
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785))
+	if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
 		val |= WDMAC_MODE_STATUS_TAG_FIX;
 
 	tw32_f(WDMAC_MODE, val);
@@ -7745,10 +7748,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	udelay(100);
 
 	tp->rx_mode = RX_MODE_ENABLE;
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+	if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
 		tp->rx_mode |= RX_MODE_IPV6_CSUM_ENABLE;
 
 	tw32_f(MAC_RX_MODE, tp->rx_mode);
@@ -9303,7 +9303,8 @@ static int tg3_set_tso(struct net_device *dev, u32 value)
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 			    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
 			     GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
-			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 				dev->features |= NETIF_F_TSO_ECN;
 		} else
 			dev->features &= ~(NETIF_F_TSO6 | NETIF_F_TSO_ECN);
@@ -9558,11 +9559,7 @@ static int tg3_set_tx_csum(struct net_device *dev, u32 data)
   		return 0;
   	}
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+	if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
 		ethtool_op_set_tx_ipv6_csum(dev, data);
 	else
 		ethtool_op_set_tx_csum(dev, data);
@@ -10079,18 +10076,13 @@ static int tg3_test_memory(struct tg3 *tp)
 	int err = 0;
 	int i;
 
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
-			mem_tbl = mem_tbl_5755;
-		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
-			mem_tbl = mem_tbl_5906;
-		else
-			mem_tbl = mem_tbl_5705;
-	} else
+	if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
+		mem_tbl = mem_tbl_5755;
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
+		mem_tbl = mem_tbl_5906;
+	else if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)
+		mem_tbl = mem_tbl_5705;
+	else
 		mem_tbl = mem_tbl_570x;
 
 	for (i = 0; mem_tbl[i].offset != 0xffffffff; i++) {
@@ -10294,9 +10286,7 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (tp->tg3_flags3 & TG3_FLG3_PHY_ENABLE_APD)
 		tg3_phy_toggle_apd(tp, false);
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
+	if (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) {
 		int i;
 		u32 status;
 
@@ -10323,9 +10313,7 @@ static int tg3_test_loopback(struct tg3 *tp)
 	if (tg3_run_loopback(tp, TG3_MAC_LOOPBACK))
 		err |= TG3_MAC_LOOPBACK_FAILED;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
+	if (tp->tg3_flags & TG3_FLAG_CPMU_PRESENT) {
 		tw32(TG3_CPMU_CTRL, cpmuctrl);
 
 		/* Release the mutex */
@@ -10944,6 +10932,102 @@ static void __devinit tg3_get_5906_nvram_info(struct tg3 *tp)
 	tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
 }
 
+static void __devinit tg3_get_57780_nvram_info(struct tg3 *tp)
+{
+	u32 nvcfg1;
+
+	nvcfg1 = tr32(NVRAM_CFG1);
+
+	switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
+	case FLASH_5787VENDOR_ATMEL_EEPROM_376KHZ:
+	case FLASH_5787VENDOR_MICRO_EEPROM_376KHZ:
+		tp->nvram_jedecnum = JEDEC_ATMEL;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->nvram_pagesize = ATMEL_AT24C512_CHIP_SIZE;
+
+		nvcfg1 &= ~NVRAM_CFG1_COMPAT_BYPASS;
+		tw32(NVRAM_CFG1, nvcfg1);
+		return;
+	case FLASH_5752VENDOR_ATMEL_FLASH_BUFFERED:
+	case FLASH_57780VENDOR_ATMEL_AT45DB011D:
+	case FLASH_57780VENDOR_ATMEL_AT45DB011B:
+	case FLASH_57780VENDOR_ATMEL_AT45DB021D:
+	case FLASH_57780VENDOR_ATMEL_AT45DB021B:
+	case FLASH_57780VENDOR_ATMEL_AT45DB041D:
+	case FLASH_57780VENDOR_ATMEL_AT45DB041B:
+		tp->nvram_jedecnum = JEDEC_ATMEL;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+
+		switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
+		case FLASH_5752VENDOR_ATMEL_FLASH_BUFFERED:
+		case FLASH_57780VENDOR_ATMEL_AT45DB011D:
+		case FLASH_57780VENDOR_ATMEL_AT45DB011B:
+			tp->nvram_size = TG3_NVRAM_SIZE_128KB;
+			break;
+		case FLASH_57780VENDOR_ATMEL_AT45DB021D:
+		case FLASH_57780VENDOR_ATMEL_AT45DB021B:
+			tp->nvram_size = TG3_NVRAM_SIZE_256KB;
+			break;
+		case FLASH_57780VENDOR_ATMEL_AT45DB041D:
+		case FLASH_57780VENDOR_ATMEL_AT45DB041B:
+			tp->nvram_size = TG3_NVRAM_SIZE_512KB;
+			break;
+		}
+		break;
+	case FLASH_5752VENDOR_ST_M45PE10:
+	case FLASH_5752VENDOR_ST_M45PE20:
+	case FLASH_5752VENDOR_ST_M45PE40:
+		tp->nvram_jedecnum = JEDEC_ST;
+		tp->tg3_flags |= TG3_FLAG_NVRAM_BUFFERED;
+		tp->tg3_flags2 |= TG3_FLG2_FLASH;
+
+		switch (nvcfg1 & NVRAM_CFG1_5752VENDOR_MASK) {
+		case FLASH_5752VENDOR_ST_M45PE10:
+			tp->nvram_size = TG3_NVRAM_SIZE_128KB;
+			break;
+		case FLASH_5752VENDOR_ST_M45PE20:
+			tp->nvram_size = TG3_NVRAM_SIZE_256KB;
+			break;
+		case FLASH_5752VENDOR_ST_M45PE40:
+			tp->nvram_size = TG3_NVRAM_SIZE_512KB;
+			break;
+		}
+		break;
+	default:
+		return;
+	}
+
+	switch (nvcfg1 & NVRAM_CFG1_5752PAGE_SIZE_MASK) {
+	case FLASH_5752PAGE_SIZE_256:
+		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
+		tp->nvram_pagesize = 256;
+		break;
+	case FLASH_5752PAGE_SIZE_512:
+		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
+		tp->nvram_pagesize = 512;
+		break;
+	case FLASH_5752PAGE_SIZE_1K:
+		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
+		tp->nvram_pagesize = 1024;
+		break;
+	case FLASH_5752PAGE_SIZE_2K:
+		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
+		tp->nvram_pagesize = 2048;
+		break;
+	case FLASH_5752PAGE_SIZE_4K:
+		tp->tg3_flags3 |= TG3_FLG3_NO_NVRAM_ADDR_TRANS;
+		tp->nvram_pagesize = 4096;
+		break;
+	case FLASH_5752PAGE_SIZE_264:
+		tp->nvram_pagesize = 264;
+		break;
+	case FLASH_5752PAGE_SIZE_528:
+		tp->nvram_pagesize = 528;
+		break;
+	}
+}
+
 /* Chips other than 5700/5701 use the NVRAM for fetching info. */
 static void __devinit tg3_nvram_init(struct tg3 *tp)
 {
@@ -10984,6 +11068,8 @@ static void __devinit tg3_nvram_init(struct tg3 *tp)
 			tg3_get_5761_nvram_info(tp);
 		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 			tg3_get_5906_nvram_info(tp);
+		else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
+			tg3_get_57780_nvram_info(tp);
 		else
 			tg3_get_nvram_info(tp);
 
@@ -11304,12 +11390,8 @@ static int tg3_nvram_write_block_buffered(struct tg3 *tp, u32 offset, u32 len,
 		if (i == (len - 4))
 			nvram_cmd |= NVRAM_CMD_LAST;
 
-		if ((GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5752) &&
-		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5755) &&
-		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5787) &&
-		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784) &&
-		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761) &&
-		    (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785) &&
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5752 &&
+		    !(tp->tg3_flags3 & TG3_FLG3_5755_PLUS) &&
 		    (tp->nvram_jedecnum == JEDEC_ST) &&
 		    (nvram_cmd & NVRAM_CMD_FIRST)) {
 
@@ -11630,8 +11712,8 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		if (cfg2 & (1 << 18))
 			tp->tg3_flags2 |= TG3_FLG2_SERDES_PREEMPHASIS;
 
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
-		    GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX &&
+		if (((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
+		      GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX)) &&
 		    (cfg2 & NIC_SRAM_DATA_CFG_2_APD_EN))
 			tp->tg3_flags3 |= TG3_FLG3_PHY_ENABLE_APD;
 
@@ -12130,7 +12212,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 		pci_read_config_dword(tp->pdev, TG3PCI_PRODID_ASICREV,
 				      &prod_id_asic_rev);
-		tp->pci_chip_rev_id = prod_id_asic_rev & PROD_ID_ASIC_REV_MASK;
+		tp->pci_chip_rev_id = prod_id_asic_rev;
 	}
 
 	/* Wrong chip ID in 5752 A0. This code can be removed later
@@ -12279,14 +12361,19 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714))
 		tp->pdev_peer = tg3_find_peer(tp);
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
+	/* Intentionally exclude ASIC_REV_5906 */
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
+		tp->tg3_flags3 |= TG3_FLG3_5755_PLUS;
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906 ||
+	    (tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
 	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		tp->tg3_flags2 |= TG3_FLG2_5750_PLUS;
 
@@ -12303,11 +12390,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		     tp->pdev_peer == tp->pdev))
 			tp->tg3_flags &= ~TG3_FLAG_SUPPORT_MSI;
 
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
+		if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
 			tp->tg3_flags2 |= TG3_FLG2_HW_TSO_2;
 			tp->tg3_flags2 |= TG3_FLG2_1SHOT_MSI;
@@ -12342,7 +12425,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 				tp->tg3_flags2 &= ~TG3_FLG2_HW_TSO_2;
 			if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761)
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
+			    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 				tp->tg3_flags3 |= TG3_FLG3_CLKREQ_BUG;
 		}
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785) {
@@ -12513,7 +12597,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 		tp->tg3_flags |= TG3_FLAG_CPMU_PRESENT;
 
 	/* Set up tp->grc_local_ctrl before calling tg3_set_power_state().
@@ -12531,7 +12616,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)
 		tp->grc_local_ctrl |= GRC_LCLCTRL_GPIO_OE3;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755)
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 		tp->grc_local_ctrl |= GRC_LCLCTRL_GPIO_UART_SEL;
 
 	if (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5761) {
@@ -12589,7 +12675,10 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5704_A0)
 		tp->tg3_flags2 |= TG3_FLG2_PHY_5704_A0_BUG;
 
-	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS) {
+	if ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_57780) {
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
@@ -12599,8 +12688,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 				tp->tg3_flags2 |= TG3_FLG2_PHY_JITTER_BUG;
 			if (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5755M)
 				tp->tg3_flags2 |= TG3_FLG2_PHY_ADJUST_TRIM;
-		} else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5906 &&
-			   GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5785)
+		} else
 			tp->tg3_flags2 |= TG3_FLG2_PHY_BER_BUG;
 	}
 
@@ -12621,7 +12709,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	    GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5700_BX)
 		tp->coalesce_mode |= HOSTCC_MODE_32BYTE;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 		tp->tg3_flags3 |= TG3_FLG3_USE_PHYLIB;
 
 	err = tg3_mdio_init(tp);
@@ -12706,6 +12795,7 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	     (tp->pdev->device == PCI_DEVICE_ID_TIGON3_5751F ||
 	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5753F ||
 	      tp->pdev->device == PCI_DEVICE_ID_TIGON3_5787F)) ||
+	    tp->pdev->device == TG3PCI_DEVICE_TIGON3_57790 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		tp->tg3_flags |= TG3_FLAG_10_100_ONLY;
 
@@ -13623,11 +13713,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		goto err_out_iounmap;
 	}
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
+	if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906)
 		dev->netdev_ops = &tg3_netdev_ops;
 	else
@@ -13700,7 +13786,8 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
 		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 &&
 		     GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5784_AX) ||
-			GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+			GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
+		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
 			dev->features |= NETIF_F_TSO_ECN;
 	}
 
@@ -13753,11 +13840,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	 */
 	if ((tp->tg3_flags & TG3_FLAG_BROKEN_CHECKSUMS) == 0) {
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
-		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5761 ||
-		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+		if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
 			dev->features |= NETIF_F_IPV6_CSUM;
 
 		tp->tg3_flags |= TG3_FLAG_RX_CHECKSUMS;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 42f60ef..6155676 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -40,6 +40,10 @@
 #define  TG3PCI_DEVICE_TIGON3_4		 0x1647 /* BCM5703 */
 #define  TG3PCI_DEVICE_TIGON3_5761S	 0x1688
 #define  TG3PCI_DEVICE_TIGON3_5761SE	 0x1689
+#define  TG3PCI_DEVICE_TIGON3_57780	 0x1692
+#define  TG3PCI_DEVICE_TIGON3_57760	 0x1690
+#define  TG3PCI_DEVICE_TIGON3_57790	 0x1694
+#define  TG3PCI_DEVICE_TIGON3_57720	 0x168c
 #define TG3PCI_COMMAND			0x00000004
 #define TG3PCI_STATUS			0x00000006
 #define TG3PCI_CCREVID			0x00000008
@@ -131,6 +135,7 @@
 #define   ASIC_REV_5784			 0x5784
 #define   ASIC_REV_5761			 0x5761
 #define   ASIC_REV_5785			 0x5785
+#define   ASIC_REV_57780		 0x57780
 #define  GET_CHIP_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 8)
 #define   CHIPREV_5700_AX		 0x70
 #define   CHIPREV_5700_BX		 0x71
@@ -1648,6 +1653,12 @@
 #define  FLASH_5761VENDOR_ST_A_M45PE40	 0x02000000
 #define  FLASH_5761VENDOR_ST_A_M45PE80	 0x02000002
 #define  FLASH_5761VENDOR_ST_A_M45PE16	 0x02000003
+#define  FLASH_57780VENDOR_ATMEL_AT45DB011D 0x00400000
+#define  FLASH_57780VENDOR_ATMEL_AT45DB011B 0x03400000
+#define  FLASH_57780VENDOR_ATMEL_AT45DB021D 0x00400002
+#define  FLASH_57780VENDOR_ATMEL_AT45DB021B 0x03400002
+#define  FLASH_57780VENDOR_ATMEL_AT45DB041D 0x00400001
+#define  FLASH_57780VENDOR_ATMEL_AT45DB041B 0x03400001
 #define  NVRAM_CFG1_5752PAGE_SIZE_MASK	 0x70000000
 #define  FLASH_5752PAGE_SIZE_256	 0x00000000
 #define  FLASH_5752PAGE_SIZE_512	 0x10000000
@@ -1655,6 +1666,7 @@
 #define  FLASH_5752PAGE_SIZE_2K		 0x30000000
 #define  FLASH_5752PAGE_SIZE_4K		 0x40000000
 #define  FLASH_5752PAGE_SIZE_264	 0x50000000
+#define  FLASH_5752PAGE_SIZE_528	 0x60000000
 #define NVRAM_CFG2			0x00007018
 #define NVRAM_CFG3			0x0000701c
 #define NVRAM_SWARB			0x00007020
@@ -2632,6 +2644,7 @@ struct tg3 {
 #define TG3_FLG3_RGMII_EXT_IBND_TX_EN	0x00000400
 #define TG3_FLG3_CLKREQ_BUG		0x00000800
 #define TG3_FLG3_PHY_ENABLE_APD		0x00001000
+#define TG3_FLG3_5755_PLUS		0x00002000
 
 	struct timer_list		timer;
 	u16				timer_counter;
@@ -2709,6 +2722,7 @@ struct tg3 {
 #define TG3_PHY_ID_BCMAC131		0x143bc70
 #define TG3_PHY_ID_RTL8211C		0x001cc910
 #define TG3_PHY_ID_RTL8201E		0x00008200
+#define TG3_PHY_ID_BCM57780		0x03625d90
 #define TG3_PHY_OUI_MASK		0xfffffc00
 #define TG3_PHY_OUI_1			0x00206000
 #define TG3_PHY_OUI_2			0x0143bc00
-- 
1.5.6.4



