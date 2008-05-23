From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 7/8] tg3: Add shmem options.
Date: Thu, 22 May 2008 19:57:10 -0700
Message-ID: <1211511430.0@teletran1>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4999 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761546AbYEWCxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2008 22:53:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds some options obtained through shared memory.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 62e6e26..d0dd92c 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -33,6 +33,7 @@
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
+#include <linux/brcmphy.h>
 #include <linux/if_vlan.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
@@ -869,6 +870,51 @@ static int tg3_mdio_reset(struct mii_bus *bp)
 	return 0;
 }
 
+static void tg3_mdio_config(struct tg3 *tp)
+{
+	u32 val;
+
+	if (tp->mdio_bus.phy_map[PHY_ADDR]->interface !=
+	    PHY_INTERFACE_MODE_RGMII)
+		return;
+
+	val = tr32(MAC_PHYCFG1) & ~(MAC_PHYCFG1_RGMII_EXT_RX_DEC |
+				    MAC_PHYCFG1_RGMII_SND_STAT_EN);
+	if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE) {
+		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
+			val |= MAC_PHYCFG1_RGMII_EXT_RX_DEC;
+		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_TX_EN)
+			val |= MAC_PHYCFG1_RGMII_SND_STAT_EN;
+	}
+	tw32(MAC_PHYCFG1, val | MAC_PHYCFG1_RGMII_INT | MAC_PHYCFG1_TXC_DRV);
+
+	val = tr32(MAC_PHYCFG2) & ~(MAC_PHYCFG2_INBAND_ENABLE);
+	if (!(tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE))
+		val |= MAC_PHYCFG2_INBAND_ENABLE;
+	tw32(MAC_PHYCFG2, val);
+
+	val = tr32(MAC_EXT_RGMII_MODE);
+	val &= ~(MAC_RGMII_MODE_RX_INT_B |
+		 MAC_RGMII_MODE_RX_QUALITY |
+		 MAC_RGMII_MODE_RX_ACTIVITY |
+		 MAC_RGMII_MODE_RX_ENG_DET |
+		 MAC_RGMII_MODE_TX_ENABLE |
+		 MAC_RGMII_MODE_TX_LOWPWR |
+		 MAC_RGMII_MODE_TX_RESET);
+	if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE) {
+		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
+			val |= MAC_RGMII_MODE_RX_INT_B |
+			       MAC_RGMII_MODE_RX_QUALITY |
+			       MAC_RGMII_MODE_RX_ACTIVITY |
+			       MAC_RGMII_MODE_RX_ENG_DET;
+		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_TX_EN)
+			val |= MAC_RGMII_MODE_TX_ENABLE |
+			       MAC_RGMII_MODE_TX_LOWPWR |
+			       MAC_RGMII_MODE_TX_RESET;
+	}
+	tw32(MAC_EXT_RGMII_MODE, val);
+}
+
 static void tg3_mdio_start(struct tg3 *tp)
 {
 	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED) {
@@ -880,6 +926,9 @@ static void tg3_mdio_start(struct tg3 *tp)
 	tp->mi_mode &= ~MAC_MI_MODE_AUTO_POLL;
 	tw32_f(MAC_MI_MODE, tp->mi_mode);
 	udelay(80);
+
+	if (tp->tg3_flags3 & TG3_FLG3_MDIOBUS_INITED)
+		tg3_mdio_config(tp);
 }
 
 static void tg3_mdio_stop(struct tg3 *tp)
@@ -895,6 +944,7 @@ static int tg3_mdio_init(struct tg3 *tp)
 {
 	int i;
 	u32 reg;
+	struct phy_device *phydev;
 	struct mii_bus *mdio_bus = &tp->mdio_bus;
 
 	tg3_mdio_start(tp);
@@ -928,13 +978,34 @@ static int tg3_mdio_init(struct tg3 *tp)
 		tg3_bmcr_reset(tp);
 
 	i = mdiobus_register(mdio_bus);
-	if (!i)
-		tp->tg3_flags3 |= TG3_FLG3_MDIOBUS_INITED;
-	else
+	if (i) {
 		printk(KERN_WARNING "%s: mdiobus_reg failed (0x%x)\n",
 			tp->dev->name, i);
+		return i;
+	}
 
-	return i;
+	tp->tg3_flags3 |= TG3_FLG3_MDIOBUS_INITED;
+
+	phydev = tp->mdio_bus.phy_map[PHY_ADDR];
+
+	switch (phydev->phy_id) {
+	case TG3_PHY_ID_BCM50610:
+		phydev->interface = PHY_INTERFACE_MODE_RGMII;
+		if (tp->tg3_flags3 & TG3_FLG3_RGMII_STD_IBND_DISABLE)
+			phydev->dev_flags |= PHY_BRCM_STD_IBND_DISABLE;
+		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_RX_EN)
+			phydev->dev_flags |= PHY_BRCM_EXT_IBND_RX_ENABLE;
+		if (tp->tg3_flags3 & TG3_FLG3_RGMII_EXT_IBND_TX_EN)
+			phydev->dev_flags |= PHY_BRCM_EXT_IBND_TX_ENABLE;
+		break;
+	case TG3_PHY_ID_BCMAC131:
+		phydev->interface = PHY_INTERFACE_MODE_MII;
+		break;
+	}
+
+	tg3_mdio_config(tp);
+
+	return 0;
 }
 
 static void tg3_mdio_fini(struct tg3 *tp)
@@ -1238,8 +1309,8 @@ static int tg3_phy_init(struct tg3 *tp)
 	phydev = tp->mdio_bus.phy_map[PHY_ADDR];
 
 	/* Attach the MAC to the PHY. */
-	phydev = phy_connect(tp->dev, phydev->dev.bus_id,
-			     tg3_adjust_link, 0, phydev->interface);
+	phydev = phy_connect(tp->dev, phydev->dev.bus_id, tg3_adjust_link,
+			     phydev->dev_flags, phydev->interface);
 	if (IS_ERR(phydev)) {
 		printk(KERN_ERR "%s: Could not attach to PHY\n", tp->dev->name);
 		return PTR_ERR(phydev);
@@ -11219,7 +11290,7 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 	tg3_read_mem(tp, NIC_SRAM_DATA_SIG, &val);
 	if (val == NIC_SRAM_DATA_SIG_MAGIC) {
 		u32 nic_cfg, led_cfg;
-		u32 nic_phy_id, ver, cfg2 = 0, eeprom_phy_id;
+		u32 nic_phy_id, ver, cfg2 = 0, cfg4 = 0, eeprom_phy_id;
 		int eeprom_phy_serdes = 0;
 
 		tg3_read_mem(tp, NIC_SRAM_DATA_CFG, &nic_cfg);
@@ -11233,6 +11304,9 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 		    (ver > 0) && (ver < 0x100))
 			tg3_read_mem(tp, NIC_SRAM_DATA_CFG_2, &cfg2);
 
+		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+			tg3_read_mem(tp, NIC_SRAM_DATA_CFG_4, &cfg4);
+
 		if ((nic_cfg & NIC_SRAM_DATA_CFG_PHY_TYPE_MASK) ==
 		    NIC_SRAM_DATA_CFG_PHY_TYPE_FIBER)
 			eeprom_phy_serdes = 1;
@@ -11357,6 +11431,13 @@ static void __devinit tg3_get_eeprom_hw_cfg(struct tg3 *tp)
 			if (cfg3 & NIC_SRAM_ASPM_DEBOUNCE)
 				tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
 		}
+
+		if (cfg4 & NIC_SRAM_RGMII_STD_IBND_DISABLE)
+			tp->tg3_flags3 |= TG3_FLG3_RGMII_STD_IBND_DISABLE;
+		if (cfg4 & NIC_SRAM_RGMII_EXT_IBND_RX_EN)
+			tp->tg3_flags3 |= TG3_FLG3_RGMII_EXT_IBND_RX_EN;
+		if (cfg4 & NIC_SRAM_RGMII_EXT_IBND_TX_EN)
+			tp->tg3_flags3 |= TG3_FLG3_RGMII_EXT_IBND_TX_EN;
 	}
 }
 
diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
new file mode 100644
index 0000000..9b64b6d
--- /dev/null
+++ b/include/linux/brcmphy.h
@@ -0,0 +1,6 @@
+#define PHY_BRCM_WIRESPEED_ENABLE	0x00000001
+#define PHY_BRCM_AUTO_PWRDWN_ENABLE	0x00000002
+#define PHY_BRCM_APD_CLK125_ENABLE	0x00000004
+#define PHY_BRCM_STD_IBND_DISABLE	0x00000008
+#define PHY_BRCM_EXT_IBND_RX_ENABLE	0x00000010
+#define PHY_BRCM_EXT_IBND_TX_ENABLE	0x00000020
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 95ac4c9..df07842 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -529,7 +529,23 @@
 #define MAC_SERDES_CFG			0x00000590
 #define  MAC_SERDES_CFG_EDGE_SELECT	 0x00001000
 #define MAC_SERDES_STAT			0x00000594
-/* 0x598 --> 0x5b0 unused */
+/* 0x598 --> 0x5a0 unused */
+#define MAC_PHYCFG1			0x000005a0
+#define  MAC_PHYCFG1_RGMII_INT		 0x00000001
+#define  MAC_PHYCFG1_RGMII_EXT_RX_DEC	 0x02000000
+#define  MAC_PHYCFG1_RGMII_SND_STAT_EN	 0x04000000
+#define  MAC_PHYCFG1_TXC_DRV		 0x20000000
+#define MAC_PHYCFG2			0x000005a4
+#define  MAC_PHYCFG2_INBAND_ENABLE	 0x00000001
+#define MAC_EXT_RGMII_MODE		0x000005a8
+#define  MAC_RGMII_MODE_TX_ENABLE	 0x00000001
+#define  MAC_RGMII_MODE_TX_LOWPWR	 0x00000002
+#define  MAC_RGMII_MODE_TX_RESET	 0x00000004
+#define  MAC_RGMII_MODE_RX_INT_B	 0x00000100
+#define  MAC_RGMII_MODE_RX_QUALITY	 0x00000200
+#define  MAC_RGMII_MODE_RX_ACTIVITY	 0x00000400
+#define  MAC_RGMII_MODE_RX_ENG_DET	 0x00000800
+/* 0x5ac --> 0x5b0 unused */
 #define SERDES_RX_CTRL			0x000005b0	/* 5780/5714 only */
 #define  SERDES_RX_SIG_DETECT		 0x00000400
 #define SG_DIG_CTRL			0x000005b0
@@ -1715,6 +1731,12 @@
 #define NIC_SRAM_DATA_CFG_3		0x00000d3c
 #define  NIC_SRAM_ASPM_DEBOUNCE		 0x00000002
 
+#define NIC_SRAM_DATA_CFG_4		0x00000d60
+#define  NIC_SRAM_GMII_MODE		 0x00000002
+#define  NIC_SRAM_RGMII_STD_IBND_DISABLE 0x00000004
+#define  NIC_SRAM_RGMII_EXT_IBND_RX_EN	 0x00000008
+#define  NIC_SRAM_RGMII_EXT_IBND_TX_EN	 0x00000010
+
 #define NIC_SRAM_RX_MINI_BUFFER_DESC	0x00001000
 
 #define NIC_SRAM_DMA_DESC_POOL_BASE	0x00002000
@@ -2486,6 +2508,9 @@ struct tg3 {
 #define TG3_FLG3_MDIOBUS_INITED		0x00000020
 #define TG3_FLG3_MDIOBUS_PAUSED		0x00000040
 #define TG3_FLG3_PHY_CONNECTED		0x00000080
+#define TG3_FLG3_RGMII_STD_IBND_DISABLE	0x00000100
+#define TG3_FLG3_RGMII_EXT_IBND_RX_EN	0x00000200
+#define TG3_FLG3_RGMII_EXT_IBND_TX_EN	0x00000400
 
 	struct timer_list		timer;
 	u16				timer_counter;
@@ -2556,6 +2581,9 @@ struct tg3 {
 #define PHY_REV_BCM5401_B2		0x3
 #define PHY_REV_BCM5401_C0		0x6
 #define PHY_REV_BCM5411_X0		0x1 /* Found on Netgear GA302T */
+#define TG3_PHY_ID_BCM50610		0x143bd60
+#define TG3_PHY_ID_BCMAC131		0x143bc70
+
 
 	u32				led_ctrl;
 	u32				phy_otp;


