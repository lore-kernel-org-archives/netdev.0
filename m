From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/3] r8152: add functions to set EEE
Date: Thu, 25 Sep 2014 20:54:01 +0800
Message-ID: <1394712342-15778-48-Taiwan-albertk@realtek.com>
References: <1394712342-15778-46-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-46-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add functions to enable EEE and set EEE advertisement.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 101 ++++++++++++++++++++++++++++++++++++------------
 1 file changed, 76 insertions(+), 25 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index d225aa1..887b6a2 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -363,6 +363,7 @@
 #define EEE_NWAY_EN		0x1000
 #define TX_QUIET_EN		0x0200
 #define RX_QUIET_EN		0x0100
+#define sd_rise_time_mask	0x0070
 #define sd_rise_time(x)		(min(x, 7) << 4)	/* bit 4 ~ 6 */
 #define RG_RXLPI_MSK_HFDUP	0x0008
 #define SDFALLTIME		0x0007	/* bit 0 ~ 2 */
@@ -375,6 +376,7 @@
 #define RG_EEEPRG_EN		0x0010
 
 /* OCP_EEE_CONFIG3 */
+#define fast_snr_mask		0xff80
 #define fast_snr(x)		(min(x, 0x1ff) << 7)	/* bit 7 ~ 15 */
 #define RG_LFS_SEL		0x0060	/* bit 6 ~ 5 */
 #define MSK_PH			0x0006	/* bit 0 ~ 3 */
@@ -2950,43 +2952,92 @@ static int rtl8152_close(struct net_device *netdev)
 	return res;
 }
 
-static void r8152b_enable_eee(struct r8152 *tp)
+static inline void r8152_mmd_indirect(struct r8152 *tp, u16 dev, u16 reg)
+{
+	ocp_reg_write(tp, OCP_EEE_AR, FUN_ADDR | dev);
+	ocp_reg_write(tp, OCP_EEE_DATA, reg);
+	ocp_reg_write(tp, OCP_EEE_AR, FUN_DATA | dev);
+}
+
+static u16 r8152_mmd_read(struct r8152 *tp, u16 dev, u16 reg)
+{
+	u16 data;
+
+	r8152_mmd_indirect(tp, dev, reg);
+	data = ocp_reg_read(tp, OCP_EEE_DATA);
+	ocp_reg_write(tp, OCP_EEE_AR, 0x0000);
+
+	return data;
+}
+
+static void r8152_mmd_write(struct r8152 *tp, u16 dev, u16 reg, u16 data)
 {
+	r8152_mmd_indirect(tp, dev, reg);
+	ocp_reg_write(tp, OCP_EEE_DATA, data);
+	ocp_reg_write(tp, OCP_EEE_AR, 0x0000);
+}
+
+static void r8152_eee_en(struct r8152 *tp, bool enable)
+{
+	u16 config1, config2, config3;
 	u32 ocp_data;
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEE_CR);
-	ocp_data |= EEE_RX_EN | EEE_TX_EN;
+	config1 = ocp_reg_read(tp, OCP_EEE_CONFIG1) & ~sd_rise_time_mask;
+	config2 = ocp_reg_read(tp, OCP_EEE_CONFIG2);
+	config3 = ocp_reg_read(tp, OCP_EEE_CONFIG3) & ~fast_snr_mask;
+
+	if (enable) {
+		ocp_data |= EEE_RX_EN | EEE_TX_EN;
+		config1 |= EEE_10_CAP | EEE_NWAY_EN | TX_QUIET_EN | RX_QUIET_EN;
+		config1 |= sd_rise_time(1);
+		config2 |= RG_DACQUIET_EN | RG_LDVQUIET_EN;
+		config3 |= fast_snr(42);
+	} else {
+		ocp_data &= ~(EEE_RX_EN | EEE_TX_EN);
+		config1 &= ~(EEE_10_CAP | EEE_NWAY_EN | TX_QUIET_EN |
+			     RX_QUIET_EN);
+		config1 |= sd_rise_time(7);
+		config2 &= ~(RG_DACQUIET_EN | RG_LDVQUIET_EN);
+		config3 |= fast_snr(511);
+	}
+
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_EEE_CR, ocp_data);
-	ocp_reg_write(tp, OCP_EEE_CONFIG1, RG_TXLPI_MSK_HFDUP | RG_MATCLR_EN |
-					   EEE_10_CAP | EEE_NWAY_EN |
-					   TX_QUIET_EN | RX_QUIET_EN |
-					   sd_rise_time(1) | RG_RXLPI_MSK_HFDUP |
-					   SDFALLTIME);
-	ocp_reg_write(tp, OCP_EEE_CONFIG2, RG_LPIHYS_NUM | RG_DACQUIET_EN |
-					   RG_LDVQUIET_EN | RG_CKRSEL |
-					   RG_EEEPRG_EN);
-	ocp_reg_write(tp, OCP_EEE_CONFIG3, fast_snr(42) | RG_LFS_SEL | MSK_PH);
-	ocp_reg_write(tp, OCP_EEE_AR, FUN_ADDR | MDIO_MMD_AN);
-	ocp_reg_write(tp, OCP_EEE_DATA, MDIO_AN_EEE_ADV);
-	ocp_reg_write(tp, OCP_EEE_AR, FUN_DATA | MDIO_MMD_AN);
-	ocp_reg_write(tp, OCP_EEE_DATA, MDIO_EEE_100TX);
-	ocp_reg_write(tp, OCP_EEE_AR, 0x0000);
+	ocp_reg_write(tp, OCP_EEE_CONFIG1, config1);
+	ocp_reg_write(tp, OCP_EEE_CONFIG2, config2);
+	ocp_reg_write(tp, OCP_EEE_CONFIG3, config3);
 }
 
-static void r8153_enable_eee(struct r8152 *tp)
+static void r8152b_enable_eee(struct r8152 *tp)
+{
+	r8152_eee_en(tp, true);
+	r8152_mmd_write(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, MDIO_EEE_100TX);
+}
+
+static void r8153_eee_en(struct r8152 *tp, bool enable)
 {
 	u32 ocp_data;
-	u16 data;
+	u16 config;
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEE_CR);
-	ocp_data |= EEE_RX_EN | EEE_TX_EN;
+	config = ocp_reg_read(tp, OCP_EEE_CFG);
+
+	if (enable) {
+		ocp_data |= EEE_RX_EN | EEE_TX_EN;
+		config |= EEE10_EN;
+	} else {
+		ocp_data &= ~(EEE_RX_EN | EEE_TX_EN);
+		config &= ~EEE10_EN;
+	}
+
 	ocp_write_word(tp, MCU_TYPE_PLA, PLA_EEE_CR, ocp_data);
-	data = ocp_reg_read(tp, OCP_EEE_CFG);
-	data |= EEE10_EN;
-	ocp_reg_write(tp, OCP_EEE_CFG, data);
-	data = ocp_reg_read(tp, OCP_EEE_ADV);
-	data |= MDIO_EEE_1000T | MDIO_EEE_100TX;
-	ocp_reg_write(tp, OCP_EEE_ADV, data);
+	ocp_reg_write(tp, OCP_EEE_CFG, config);
+}
+
+static void r8153_enable_eee(struct r8152 *tp)
+{
+	r8153_eee_en(tp, true);
+	ocp_reg_write(tp, OCP_EEE_ADV, MDIO_EEE_1000T | MDIO_EEE_100TX);
 }
 
 static void r8152b_enable_fc(struct r8152 *tp)
-- 
1.9.3
