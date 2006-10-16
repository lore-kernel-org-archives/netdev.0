From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH] bcm43xx-softmac: add PCI-E code
Date: Sun, 15 Oct 2006 23:18:11 -0500
Message-ID: <45330803.mail261110C22@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>, Stefano Brivio <st3-sGOZH3hwPm2sTnJN9+BGXg@public.gmane.org>
Return-path: <bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/bcm43xx-dev>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: bcm43xx-dev-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>

The current bcm43xx driver does not contain code to handle PCI-E interfaces
such as the BCM4311 and BCM4312. This patch, originally written by Stefano
Brivio adds the necessary code to enable these interfaces. 

Signed-off-by: Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---

John,

If possible, this patch should be pushed into 2.6.19.

Larry

 drivers/net/wireless/bcm43xx/bcm43xx_main.c               |  109 +++++++++-----
 wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h       |   29 +++
 wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c  |   34 ++++
 wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_power.c |   28 ++-
 4 files changed, 156 insertions(+), 44 deletions(-)

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -159,6 +159,7 @@
 
 /* Chipcommon registers. */
 #define BCM43xx_CHIPCOMMON_CAPABILITIES 	0x04
+#define BCM43xx_CHIPCOMMON_CTL			0x28
 #define BCM43xx_CHIPCOMMON_PLLONDELAY		0xB0
 #define BCM43xx_CHIPCOMMON_FREFSELDELAY		0xB4
 #define BCM43xx_CHIPCOMMON_SLOWCLKCTL		0xB8
@@ -172,6 +173,33 @@
 /* SBTOPCI2 values. */
 #define BCM43xx_SBTOPCI2_PREFETCH	0x4
 #define BCM43xx_SBTOPCI2_BURST		0x8
+#define BCM43xx_SBTOPCI2_MEMREAD_MULTI	0x20
+
+/* PCI-E core registers. */
+#define BCM43xx_PCIECORE_REG_ADDR      0x0130
+#define BCM43xx_PCIECORE_REG_DATA      0x0134
+#define BCM43xx_PCIECORE_MDIO_CTL      0x0128
+#define BCM43xx_PCIECORE_MDIO_DATA     0x012C
+
+/* PCI-E registers. */
+#define BCM43xx_PCIE_TLP_WORKAROUND    0x0004
+#define BCM43xx_PCIE_DLLP_LINKCTL      0x0100
+
+/* PCI-E MDIO bits. */
+#define BCM43xx_PCIE_MDIO_ST   0x40000000
+#define BCM43xx_PCIE_MDIO_WT   0x10000000
+#define BCM43xx_PCIE_MDIO_DEV  22
+#define BCM43xx_PCIE_MDIO_REG  18
+#define BCM43xx_PCIE_MDIO_TA   0x00020000
+#define BCM43xx_PCIE_MDIO_TC   0x0100
+
+/* MDIO devices. */
+#define BCM43xx_MDIO_SERDES_RX	0x1F
+
+/* SERDES RX registers. */
+#define BCM43xx_SERDES_RXTIMER	0x2
+#define BCM43xx_SERDES_CDR	0x6
+#define BCM43xx_SERDES_CDR_BW	0x7
 
 /* Chipcommon capabilities. */
 #define BCM43xx_CAPABILITIES_PCTL		0x00040000
@@ -221,6 +249,7 @@
 #define BCM43xx_COREID_USB20_HOST       0x819
 #define BCM43xx_COREID_USB20_DEV        0x81a
 #define BCM43xx_COREID_SDIO_HOST        0x81b
+#define BCM43xx_COREID_PCIE		0x820
 
 /* Core Information Registers */
 #define BCM43xx_CIR_BASE		0xf00
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -3015,6 +3015,40 @@ out:
 	return err;
 }
 
+static u32 bcm43xx_pcie_reg_read(struct bcm43xx_private *bcm, u32 address)
+{
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_REG_ADDR, address);
+	return bcm43xx_read32(bcm, BCM43xx_PCIECORE_REG_DATA);
+}
+
+static void bcm43xx_pcie_reg_write(struct bcm43xx_private *bcm, u32 address,
+				    u32 data)
+{
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_REG_ADDR, address);
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_REG_DATA, data);
+}
+
+static void bcm43xx_pcie_mdio_write(struct bcm43xx_private *bcm, u8 dev, u8 reg,
+				    u16 data)
+{
+	int i;
+
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_MDIO_CTL, 0x0082);
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_MDIO_DATA, BCM43xx_PCIE_MDIO_ST |
+			BCM43xx_PCIE_MDIO_WT | (dev << BCM43xx_PCIE_MDIO_DEV) |
+			(reg << BCM43xx_PCIE_MDIO_REG) | BCM43xx_PCIE_MDIO_TA |
+			data);
+	udelay(10);
+
+	for (i = 0; i < 10; i++) {
+		if (bcm43xx_read32(bcm, BCM43xx_PCIECORE_MDIO_CTL) &
+		    BCM43xx_PCIE_MDIO_TC)
+			break;
+		msleep(1);
+	}
+	bcm43xx_write32(bcm, BCM43xx_PCIECORE_MDIO_CTL, 0);
+}
+
 /* Make an I/O Core usable. "core_mask" is the bitmask of the cores to enable.
  * To enable core 0, pass a core_mask of 1<<0
  */
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2595,8 +2595,9 @@ static int bcm43xx_probe_cores(struct bc
 	/* fetch sb_id_hi from core information registers */
 	sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
 
-	core_id = (sb_id_hi & 0xFFF0) >> 4;
-	core_rev = (sb_id_hi & 0xF);
+	core_id = (sb_id_hi & 0x8FF0) >> 4;
+	core_rev = (sb_id_hi & 0x7000) >> 8;
+	core_rev |= (sb_id_hi & 0xF);
 	core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
 
 	/* if present, chipcommon is always core 0; read the chipid from it */
@@ -3690,7 +3691,7 @@ static int bcm43xx_read_phyinfo(struct b
 		bcm->ieee->freq_band = IEEE80211_24GHZ_BAND;
 		break;
 	case BCM43xx_PHYTYPE_G:
-		if (phy_rev > 7)
+		if (phy_rev > 8)
 			phy_rev_ok = 0;
 		bcm->ieee->modulation = IEEE80211_OFDM_MODULATION |
 					IEEE80211_CCK_MODULATION;
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2707,6 +2707,7 @@ static int bcm43xx_probe_cores(struct bc
 		core = NULL;
 		switch (core_id) {
 		case BCM43xx_COREID_PCI:
+		case BCM43xx_COREID_PCIE:
 			core = &bcm->core_pci;
 			if (core->available) {
 				printk(KERN_WARNING PFX "Multiple PCI cores found.\n");
@@ -2745,6 +2746,7 @@ static int bcm43xx_probe_cores(struct bc
 			case 6:
 			case 7:
 			case 9:
+			case 10:
 				break;
 			default:
 				printk(KERN_ERR PFX "Error: Unsupported 80211 core revision %u\n",
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2866,16 +2866,11 @@ static int bcm43xx_wireless_core_init(st
 	u32 sbimconfiglow;
 	u8 limit;
 
-	if (bcm->chip_rev < 5) {
+	if (bcm->core_pci.rev <= 5 && bcm->core_pci.id != BCM43xx_COREID_PCIE) {
 		sbimconfiglow = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
 		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
-		if (bcm->bustype == BCM43xx_BUSTYPE_PCI)
-			sbimconfiglow |= 0x32;
-		else if (bcm->bustype == BCM43xx_BUSTYPE_SB)
-			sbimconfiglow |= 0x53;
-		else
-			assert(0);
+		sbimconfiglow |= 0x32;
 		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, sbimconfiglow);
 	}
 
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2749,10 +2749,9 @@ static int bcm43xx_probe_cores(struct bc
 			case 10:
 				break;
 			default:
-				printk(KERN_ERR PFX "Error: Unsupported 80211 core revision %u\n",
+				printk(KERN_WARNING PFX
+				       "Unsupported 80211 core revision %u\n",
 				       core_rev);
-				err = -ENODEV;
-				goto out;
 			}
 			bcm->nr_80211_available++;
 			core->priv = ext_80211;
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_power.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_power.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_power.c
@@ -153,8 +153,6 @@ int bcm43xx_pctl_init(struct bcm43xx_pri
 	int err, maxfreq;
 	struct bcm43xx_coreinfo *old_core;
 
-	if (!(bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL))
-		return 0;
 	old_core = bcm->current_core;
 	err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
 	if (err == -ENODEV)
@@ -162,11 +160,27 @@ int bcm43xx_pctl_init(struct bcm43xx_pri
 	if (err)
 		goto out;
 
-	maxfreq = bcm43xx_pctl_clockfreqlimit(bcm, 1);
-	bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_PLLONDELAY,
-			(maxfreq * 150 + 999999) / 1000000);
-	bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_FREFSELDELAY,
-			(maxfreq * 15 + 999999) / 1000000);
+	if (bcm->chip_id == 0x4321) {
+		if (bcm->chip_rev == 0)
+			bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_CTL, 0x03A4);
+		if (bcm->chip_rev == 1)
+			bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_CTL, 0x00A4);
+	}
+
+	if (bcm->chipcommon_capabilities & BCM43xx_CAPABILITIES_PCTL) {
+		if (bcm->current_core->rev >= 10) {
+			/* Set Idle Power clock rate to 1Mhz */
+			bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_SYSCLKCTL,
+				       (bcm43xx_read32(bcm, BCM43xx_CHIPCOMMON_SYSCLKCTL)
+				       & 0x0000FFFF) | 0x40000);
+		} else {
+			maxfreq = bcm43xx_pctl_clockfreqlimit(bcm, 1);
+			bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_PLLONDELAY,
+				       (maxfreq * 150 + 999999) / 1000000);
+			bcm43xx_write32(bcm, BCM43xx_CHIPCOMMON_FREFSELDELAY,
+				       (maxfreq * 15 + 999999) / 1000000);
+		}
+	}
 
 	err = bcm43xx_switch_core(bcm, old_core);
 	assert(err == 0);
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2996,18 +2996,26 @@ static void bcm43xx_pcicore_broadcast_va
 
 static int bcm43xx_pcicore_commit_settings(struct bcm43xx_private *bcm)
 {
-	int err;
-	struct bcm43xx_coreinfo *old_core;
+	int err = 0;
 
-	old_core = bcm->current_core;
-	err = bcm43xx_switch_core(bcm, &bcm->core_pci);
-	if (err)
-		goto out;
+	bcm->irq_savedstate = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
 
-	bcm43xx_pcicore_broadcast_value(bcm, 0xfd8, 0x00000000);
+	if (bcm->core_chipcommon.available) {
+		err = bcm43xx_switch_core(bcm, &bcm->core_chipcommon);
+		if (err)
+			goto out;
+
+		bcm43xx_pcicore_broadcast_value(bcm, 0xfd8, 0x00000000);
+
+		/* this function is always called when a PCI core is mapped */
+		err = bcm43xx_switch_core(bcm, &bcm->core_pci);
+		if (err)
+			goto out;
+	} else
+		bcm43xx_pcicore_broadcast_value(bcm, 0xfd8, 0x00000000);
+
+	bcm43xx_interrupt_enable(bcm, bcm->irq_savedstate);
 
-	bcm43xx_switch_core(bcm, old_core);
-	assert(err == 0);
 out:
 	return err;
 }
@@ -3065,7 +3073,8 @@ static int bcm43xx_setup_backplane_pci_c
 	if (err)
 		goto out;
 
-	if (bcm->core_pci.rev < 6) {
+	if (bcm->current_core->rev < 6 ||
+		bcm->current_core->id == BCM43xx_COREID_PCI) {
 		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBINTVEC);
 		value |= (1 << backplane_flag_nr);
 		bcm43xx_write32(bcm, BCM43xx_CIR_SBINTVEC, value);
@@ -3083,21 +3092,46 @@ static int bcm43xx_setup_backplane_pci_c
 		}
 	}
 
-	value = bcm43xx_read32(bcm, BCM43xx_PCICORE_SBTOPCI2);
-	value |= BCM43xx_SBTOPCI2_PREFETCH | BCM43xx_SBTOPCI2_BURST;
-	bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
-
-	if (bcm->core_pci.rev < 5) {
-		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
-		value |= (2 << BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_SHIFT)
-			 & BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
-		value |= (3 << BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_SHIFT)
-			 & BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
-		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, value);
-		err = bcm43xx_pcicore_commit_settings(bcm);
-		assert(err == 0);
+	if (bcm->current_core->id == BCM43xx_COREID_PCI) {
+		value = bcm43xx_read32(bcm, BCM43xx_PCICORE_SBTOPCI2);
+		value |= BCM43xx_SBTOPCI2_PREFETCH | BCM43xx_SBTOPCI2_BURST;
+		bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
+
+		if (bcm->current_core->rev < 5) {
+			value = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
+			value |= (2 << BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_SHIFT)
+				 & BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
+			value |= (3 << BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_SHIFT)
+				 & BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
+			bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, value);
+			err = bcm43xx_pcicore_commit_settings(bcm);
+			assert(err == 0);
+		} else if (bcm->current_core->rev >= 11) {
+			value = bcm43xx_read32(bcm, BCM43xx_PCICORE_SBTOPCI2);
+			value |= BCM43xx_SBTOPCI2_MEMREAD_MULTI;
+			bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
+		}
+	} else {
+		if (bcm->current_core->rev == 0 || bcm->current_core->rev == 1) {
+			value = bcm43xx_pcie_reg_read(bcm, BCM43xx_PCIE_TLP_WORKAROUND);
+			value |= 0x8;
+			bcm43xx_pcie_reg_write(bcm, BCM43xx_PCIE_TLP_WORKAROUND,
+					       value);
+		}
+		if (bcm->current_core->rev == 0) {
+			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
+						BCM43xx_SERDES_RXTIMER, 0x8128);
+			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
+						BCM43xx_SERDES_CDR, 0x0100);
+			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
+						BCM43xx_SERDES_CDR_BW, 0x1466);
+		} else if (bcm->current_core->rev == 1) {
+			value = bcm43xx_pcie_reg_read(bcm, BCM43xx_PCIE_DLLP_LINKCTL);
+			value |= 0x40;
+			bcm43xx_pcie_reg_write(bcm, BCM43xx_PCIE_DLLP_LINKCTL,
+					       value);
+		}
 	}
-
 out_switch_back:
 	err = bcm43xx_switch_core(bcm, old_core);
 out:
Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -130,6 +130,10 @@ MODULE_PARM_DESC(fwpostfix, "Postfix for
 	{ PCI_VENDOR_ID_BROADCOM, 0x4301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4307 802.11b */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4307, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	/* Broadcom 4311 802.11(a)/b/g */
+	{ PCI_VENDOR_ID_BROADCOM, 0x4311, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	/* Broadcom 4312 802.11a/b/g */
+	{ PCI_VENDOR_ID_BROADCOM, 0x4312, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4318 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4318, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4319 802.11a/b/g */


----
