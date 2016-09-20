From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 1/5] r8152: move some functions
Date: Tue, 20 Sep 2016 16:22:05 +0800
Message-ID: <1394712342-15778-220-Taiwan-albertk@realtek.com>
References: <1394712342-15778-219-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-219-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move the following functions forward.

	r8152_mmd_indirect()
	r8152_mmd_read()
	r8152_mmd_write()
	r8152_eee_en()
	r8152b_enable_eee()
	r8153_eee_en()
	r8153_enable_eee()
	r8152b_enable_fc()
	r8153_aldps_en()

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 224 ++++++++++++++++++++++++------------------------
 1 file changed, 112 insertions(+), 112 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f41a8ad..ae7db46 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2552,6 +2552,77 @@ static void r8152_aldps_en(struct r8152 *tp, bool enable)
 	}
 }
 
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
+{
+	r8152_mmd_indirect(tp, dev, reg);
+	ocp_reg_write(tp, OCP_EEE_DATA, data);
+	ocp_reg_write(tp, OCP_EEE_AR, 0x0000);
+}
+
+static void r8152_eee_en(struct r8152 *tp, bool enable)
+{
+	u16 config1, config2, config3;
+	u32 ocp_data;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEE_CR);
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
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_EEE_CR, ocp_data);
+	ocp_reg_write(tp, OCP_EEE_CONFIG1, config1);
+	ocp_reg_write(tp, OCP_EEE_CONFIG2, config2);
+	ocp_reg_write(tp, OCP_EEE_CONFIG3, config3);
+}
+
+static void r8152b_enable_eee(struct r8152 *tp)
+{
+	r8152_eee_en(tp, true);
+	r8152_mmd_write(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, MDIO_EEE_100TX);
+}
+
+static void r8152b_enable_fc(struct r8152 *tp)
+{
+	u16 anar;
+
+	anar = r8152_mdio_read(tp, MII_ADVERTISE);
+	anar |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
+	r8152_mdio_write(tp, MII_ADVERTISE, anar);
+}
+
 static void rtl8152_disable(struct r8152 *tp)
 {
 	r8152_aldps_en(tp, false);
@@ -2701,6 +2772,47 @@ static void r8152b_enter_oob(struct r8152 *tp)
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
 }
 
+static void r8153_aldps_en(struct r8152 *tp, bool enable)
+{
+	u16 data;
+
+	data = ocp_reg_read(tp, OCP_POWER_CFG);
+	if (enable) {
+		data |= EN_ALDPS;
+		ocp_reg_write(tp, OCP_POWER_CFG, data);
+	} else {
+		data &= ~EN_ALDPS;
+		ocp_reg_write(tp, OCP_POWER_CFG, data);
+		msleep(20);
+	}
+}
+
+static void r8153_eee_en(struct r8152 *tp, bool enable)
+{
+	u32 ocp_data;
+	u16 config;
+
+	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEE_CR);
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
+	ocp_write_word(tp, MCU_TYPE_PLA, PLA_EEE_CR, ocp_data);
+	ocp_reg_write(tp, OCP_EEE_CFG, config);
+}
+
+static void r8153_enable_eee(struct r8152 *tp)
+{
+	r8153_eee_en(tp, true);
+	ocp_reg_write(tp, OCP_EEE_ADV, MDIO_EEE_1000T | MDIO_EEE_100TX);
+}
+
 static void r8153_hw_phy_cfg(struct r8152 *tp)
 {
 	u32 ocp_data;
@@ -2866,21 +2978,6 @@ static void r8153_enter_oob(struct r8152 *tp)
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
 }
 
-static void r8153_aldps_en(struct r8152 *tp, bool enable)
-{
-	u16 data;
-
-	data = ocp_reg_read(tp, OCP_POWER_CFG);
-	if (enable) {
-		data |= EN_ALDPS;
-		ocp_reg_write(tp, OCP_POWER_CFG, data);
-	} else {
-		data &= ~EN_ALDPS;
-		ocp_reg_write(tp, OCP_POWER_CFG, data);
-		msleep(20);
-	}
-}
-
 static void rtl8153_disable(struct r8152 *tp)
 {
 	r8153_aldps_en(tp, false);
@@ -3246,103 +3343,6 @@ static int rtl8152_close(struct net_device *netdev)
 	return res;
 }
 
-static inline void r8152_mmd_indirect(struct r8152 *tp, u16 dev, u16 reg)
-{
-	ocp_reg_write(tp, OCP_EEE_AR, FUN_ADDR | dev);
-	ocp_reg_write(tp, OCP_EEE_DATA, reg);
-	ocp_reg_write(tp, OCP_EEE_AR, FUN_DATA | dev);
-}
-
-static u16 r8152_mmd_read(struct r8152 *tp, u16 dev, u16 reg)
-{
-	u16 data;
-
-	r8152_mmd_indirect(tp, dev, reg);
-	data = ocp_reg_read(tp, OCP_EEE_DATA);
-	ocp_reg_write(tp, OCP_EEE_AR, 0x0000);
-
-	return data;
-}
-
-static void r8152_mmd_write(struct r8152 *tp, u16 dev, u16 reg, u16 data)
-{
-	r8152_mmd_indirect(tp, dev, reg);
-	ocp_reg_write(tp, OCP_EEE_DATA, data);
-	ocp_reg_write(tp, OCP_EEE_AR, 0x0000);
-}
-
-static void r8152_eee_en(struct r8152 *tp, bool enable)
-{
-	u16 config1, config2, config3;
-	u32 ocp_data;
-
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEE_CR);
-	config1 = ocp_reg_read(tp, OCP_EEE_CONFIG1) & ~sd_rise_time_mask;
-	config2 = ocp_reg_read(tp, OCP_EEE_CONFIG2);
-	config3 = ocp_reg_read(tp, OCP_EEE_CONFIG3) & ~fast_snr_mask;
-
-	if (enable) {
-		ocp_data |= EEE_RX_EN | EEE_TX_EN;
-		config1 |= EEE_10_CAP | EEE_NWAY_EN | TX_QUIET_EN | RX_QUIET_EN;
-		config1 |= sd_rise_time(1);
-		config2 |= RG_DACQUIET_EN | RG_LDVQUIET_EN;
-		config3 |= fast_snr(42);
-	} else {
-		ocp_data &= ~(EEE_RX_EN | EEE_TX_EN);
-		config1 &= ~(EEE_10_CAP | EEE_NWAY_EN | TX_QUIET_EN |
-			     RX_QUIET_EN);
-		config1 |= sd_rise_time(7);
-		config2 &= ~(RG_DACQUIET_EN | RG_LDVQUIET_EN);
-		config3 |= fast_snr(511);
-	}
-
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_EEE_CR, ocp_data);
-	ocp_reg_write(tp, OCP_EEE_CONFIG1, config1);
-	ocp_reg_write(tp, OCP_EEE_CONFIG2, config2);
-	ocp_reg_write(tp, OCP_EEE_CONFIG3, config3);
-}
-
-static void r8152b_enable_eee(struct r8152 *tp)
-{
-	r8152_eee_en(tp, true);
-	r8152_mmd_write(tp, MDIO_MMD_AN, MDIO_AN_EEE_ADV, MDIO_EEE_100TX);
-}
-
-static void r8153_eee_en(struct r8152 *tp, bool enable)
-{
-	u32 ocp_data;
-	u16 config;
-
-	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEE_CR);
-	config = ocp_reg_read(tp, OCP_EEE_CFG);
-
-	if (enable) {
-		ocp_data |= EEE_RX_EN | EEE_TX_EN;
-		config |= EEE10_EN;
-	} else {
-		ocp_data &= ~(EEE_RX_EN | EEE_TX_EN);
-		config &= ~EEE10_EN;
-	}
-
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_EEE_CR, ocp_data);
-	ocp_reg_write(tp, OCP_EEE_CFG, config);
-}
-
-static void r8153_enable_eee(struct r8152 *tp)
-{
-	r8153_eee_en(tp, true);
-	ocp_reg_write(tp, OCP_EEE_ADV, MDIO_EEE_1000T | MDIO_EEE_100TX);
-}
-
-static void r8152b_enable_fc(struct r8152 *tp)
-{
-	u16 anar;
-
-	anar = r8152_mdio_read(tp, MII_ADVERTISE);
-	anar |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
-	r8152_mdio_write(tp, MII_ADVERTISE, anar);
-}
-
 static void rtl_tally_reset(struct r8152 *tp)
 {
 	u32 ocp_data;
-- 
2.7.4
