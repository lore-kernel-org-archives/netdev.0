From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/16] cxgb3: Use generic MDIO definitions and
	mdio_mii_ioctl()
Date: Wed, 29 Apr 2009 19:07:20 +0100
Message-ID: <1241028440.3246.43.camel@achroite>
References: <1241028086.3246.30.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Divy Le Ray <divy@chelsio.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:55073 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754410AbZD2SHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 14:07:22 -0400
In-Reply-To: <1241028086.3246.30.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compile-tested only.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/Kconfig            |    1 +
 drivers/net/cxgb3/ael1002.c    |  146 +++++++++++++++++++++-------------------
 drivers/net/cxgb3/common.h     |   53 ++++++--------
 drivers/net/cxgb3/cxgb3_main.c |   71 ++++----------------
 drivers/net/cxgb3/t3_hw.c      |   78 ++++++++++++----------
 drivers/net/cxgb3/vsc8211.c    |   70 +++++++++++--------
 6 files changed, 195 insertions(+), 224 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 1ccd547..435bbc9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2483,6 +2483,7 @@ config CHELSIO_T3
 	tristate "Chelsio Communications T3 10Gb Ethernet support"
 	depends on CHELSIO_T3_DEPENDS
 	select FW_LOADER
+	select MDIO
 	help
 	  This driver supports Chelsio T3-based gigabit and 10Gb Ethernet
 	  adapters.
diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
index e1b2249..bebc00d 100644
--- a/drivers/net/cxgb3/ael1002.c
+++ b/drivers/net/cxgb3/ael1002.c
@@ -33,14 +33,6 @@
 #include "regs.h"
 
 enum {
-	PMD_RSD     = 10,   /* PMA/PMD receive signal detect register */
-	PCS_STAT1_X = 24,   /* 10GBASE-X PCS status 1 register */
-	PCS_STAT1_R = 32,   /* 10GBASE-R PCS status 1 register */
-	XS_LN_STAT  = 24    /* XS lane status register */
-};
-
-enum {
-	AEL100X_TX_DISABLE = 9,
 	AEL100X_TX_CONFIG1 = 0xc002,
 	AEL1002_PWR_DOWN_HI = 0xc011,
 	AEL1002_PWR_DOWN_LO = 0xc012,
@@ -74,8 +66,8 @@ static int set_phy_regs(struct cphy *phy, const struct reg_val *rv)
 
 	for (err = 0; rv->mmd_addr && !err; rv++) {
 		if (rv->clear_bits == 0xffff)
-			err = mdio_write(phy, rv->mmd_addr, rv->reg_addr,
-					 rv->set_bits);
+			err = t3_mdio_write(phy, rv->mmd_addr, rv->reg_addr,
+					    rv->set_bits);
 		else
 			err = t3_mdio_change_bits(phy, rv->mmd_addr,
 						  rv->reg_addr, rv->clear_bits,
@@ -86,7 +78,8 @@ static int set_phy_regs(struct cphy *phy, const struct reg_val *rv)
 
 static void ael100x_txon(struct cphy *phy)
 {
-	int tx_on_gpio = phy->addr == 0 ? F_GPIO7_OUT_VAL : F_GPIO2_OUT_VAL;
+	int tx_on_gpio =
+		phy->mdio.prtad == 0 ? F_GPIO7_OUT_VAL : F_GPIO2_OUT_VAL;
 
 	msleep(100);
 	t3_set_reg_field(phy->adapter, A_T3DBG_GPIO_EN, 0, tx_on_gpio);
@@ -97,10 +90,11 @@ static int ael1002_power_down(struct cphy *phy, int enable)
 {
 	int err;
 
-	err = mdio_write(phy, MDIO_DEV_PMA_PMD, AEL100X_TX_DISABLE, !!enable);
+	err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, MDIO_PMA_TXDIS, !!enable);
 	if (!err)
-		err = t3_mdio_change_bits(phy, MDIO_DEV_PMA_PMD, MII_BMCR,
-					  BMCR_PDOWN, enable ? BMCR_PDOWN : 0);
+		err = mdio_set_flag(&phy->mdio, phy->mdio.prtad,
+				    MDIO_MMD_PMAPMD, MDIO_CTRL1,
+				    MDIO_CTRL1_LPOWER, enable);
 	return err;
 }
 
@@ -109,11 +103,11 @@ static int ael1002_reset(struct cphy *phy, int wait)
 	int err;
 
 	if ((err = ael1002_power_down(phy, 0)) ||
-	    (err = mdio_write(phy, MDIO_DEV_PMA_PMD, AEL100X_TX_CONFIG1, 1)) ||
-	    (err = mdio_write(phy, MDIO_DEV_PMA_PMD, AEL1002_PWR_DOWN_HI, 0)) ||
-	    (err = mdio_write(phy, MDIO_DEV_PMA_PMD, AEL1002_PWR_DOWN_LO, 0)) ||
-	    (err = mdio_write(phy, MDIO_DEV_PMA_PMD, AEL1002_XFI_EQL, 0x18)) ||
-	    (err = t3_mdio_change_bits(phy, MDIO_DEV_PMA_PMD, AEL1002_LB_EN,
+	    (err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, AEL100X_TX_CONFIG1, 1)) ||
+	    (err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, AEL1002_PWR_DOWN_HI, 0)) ||
+	    (err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, AEL1002_PWR_DOWN_LO, 0)) ||
+	    (err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, AEL1002_XFI_EQL, 0x18)) ||
+	    (err = t3_mdio_change_bits(phy, MDIO_MMD_PMAPMD, AEL1002_LB_EN,
 				       0, 1 << 5)))
 		return err;
 	return 0;
@@ -132,12 +126,15 @@ static int get_link_status_r(struct cphy *phy, int *link_ok, int *speed,
 {
 	if (link_ok) {
 		unsigned int stat0, stat1, stat2;
-		int err = mdio_read(phy, MDIO_DEV_PMA_PMD, PMD_RSD, &stat0);
+		int err = t3_mdio_read(phy, MDIO_MMD_PMAPMD,
+				       MDIO_PMA_RXDET, &stat0);
 
 		if (!err)
-			err = mdio_read(phy, MDIO_DEV_PCS, PCS_STAT1_R, &stat1);
+			err = t3_mdio_read(phy, MDIO_MMD_PCS,
+					   MDIO_PCS_10GBRT_STAT1, &stat1);
 		if (!err)
-			err = mdio_read(phy, MDIO_DEV_XGXS, XS_LN_STAT, &stat2);
+			err = t3_mdio_read(phy, MDIO_MMD_PHYXS,
+					   MDIO_PHYXS_LNSTAT, &stat2);
 		if (err)
 			return err;
 		*link_ok = (stat0 & stat1 & (stat2 >> 12)) & 1;
@@ -157,6 +154,7 @@ static struct cphy_ops ael1002_ops = {
 	.intr_handler = ael1002_intr_noop,
 	.get_link_status = get_link_status_r,
 	.power_down = ael1002_power_down,
+	.mmds = MDIO_DEVS_PMAPMD | MDIO_DEVS_PCS | MDIO_DEVS_PHYXS,
 };
 
 int t3_ael1002_phy_prep(struct cphy *phy, struct adapter *adapter,
@@ -171,13 +169,13 @@ int t3_ael1002_phy_prep(struct cphy *phy, struct adapter *adapter,
 
 static int ael1006_reset(struct cphy *phy, int wait)
 {
-	return t3_phy_reset(phy, MDIO_DEV_PMA_PMD, wait);
+	return t3_phy_reset(phy, MDIO_MMD_PMAPMD, wait);
 }
 
 static int ael1006_power_down(struct cphy *phy, int enable)
 {
-	return t3_mdio_change_bits(phy, MDIO_DEV_PMA_PMD, MII_BMCR,
-				   BMCR_PDOWN, enable ? BMCR_PDOWN : 0);
+	return mdio_set_flag(&phy->mdio, phy->mdio.prtad, MDIO_MMD_PMAPMD,
+			     MDIO_CTRL1, MDIO_CTRL1_LPOWER, enable);
 }
 
 static struct cphy_ops ael1006_ops = {
@@ -188,6 +186,7 @@ static struct cphy_ops ael1006_ops = {
 	.intr_handler = t3_phy_lasi_intr_handler,
 	.get_link_status = get_link_status_r,
 	.power_down = ael1006_power_down,
+	.mmds = MDIO_DEVS_PMAPMD | MDIO_DEVS_PCS | MDIO_DEVS_PHYXS,
 };
 
 int t3_ael1006_phy_prep(struct cphy *phy, struct adapter *adapter,
@@ -203,9 +202,9 @@ int t3_ael1006_phy_prep(struct cphy *phy, struct adapter *adapter,
 static int ael2005_setup_sr_edc(struct cphy *phy)
 {
 	static struct reg_val regs[] = {
-		{ MDIO_DEV_PMA_PMD, 0xc003, 0xffff, 0x181 },
-		{ MDIO_DEV_PMA_PMD, 0xc010, 0xffff, 0x448a },
-		{ MDIO_DEV_PMA_PMD, 0xc04a, 0xffff, 0x5200 },
+		{ MDIO_MMD_PMAPMD, 0xc003, 0xffff, 0x181 },
+		{ MDIO_MMD_PMAPMD, 0xc010, 0xffff, 0x448a },
+		{ MDIO_MMD_PMAPMD, 0xc04a, 0xffff, 0x5200 },
 		{ 0, 0, 0, 0 }
 	};
 	static u16 sr_edc[] = {
@@ -490,8 +489,8 @@ static int ael2005_setup_sr_edc(struct cphy *phy)
 	msleep(50);
 
 	for (i = 0; i < ARRAY_SIZE(sr_edc) && !err; i += 2)
-		err = mdio_write(phy, MDIO_DEV_PMA_PMD, sr_edc[i],
-				 sr_edc[i + 1]);
+		err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, sr_edc[i],
+				    sr_edc[i + 1]);
 	if (!err)
 		phy->priv = edc_sr;
 	return err;
@@ -500,12 +499,12 @@ static int ael2005_setup_sr_edc(struct cphy *phy)
 static int ael2005_setup_twinax_edc(struct cphy *phy, int modtype)
 {
 	static struct reg_val regs[] = {
-		{ MDIO_DEV_PMA_PMD, 0xc04a, 0xffff, 0x5a00 },
+		{ MDIO_MMD_PMAPMD, 0xc04a, 0xffff, 0x5a00 },
 		{ 0, 0, 0, 0 }
 	};
 	static struct reg_val preemphasis[] = {
-		{ MDIO_DEV_PMA_PMD, 0xc014, 0xffff, 0xfe16 },
-		{ MDIO_DEV_PMA_PMD, 0xc015, 0xffff, 0xa000 },
+		{ MDIO_MMD_PMAPMD, 0xc014, 0xffff, 0xfe16 },
+		{ MDIO_MMD_PMAPMD, 0xc015, 0xffff, 0xa000 },
 		{ 0, 0, 0, 0 }
 	};
 	static u16 twinax_edc[] = {
@@ -887,8 +886,8 @@ static int ael2005_setup_twinax_edc(struct cphy *phy, int modtype)
 	msleep(50);
 
 	for (i = 0; i < ARRAY_SIZE(twinax_edc) && !err; i += 2)
-		err = mdio_write(phy, MDIO_DEV_PMA_PMD, twinax_edc[i],
-				 twinax_edc[i + 1]);
+		err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, twinax_edc[i],
+				    twinax_edc[i + 1]);
 	if (!err)
 		phy->priv = edc_twinax;
 	return err;
@@ -899,26 +898,26 @@ static int ael2005_i2c_rd(struct cphy *phy, int dev_addr, int word_addr)
 	int i, err;
 	unsigned int stat, data;
 
-	err = mdio_write(phy, MDIO_DEV_PMA_PMD, AEL_I2C_CTRL,
-			 (dev_addr << 8) | (1 << 8) | word_addr);
+	err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, AEL_I2C_CTRL,
+			    (dev_addr << 8) | (1 << 8) | word_addr);
 	if (err)
 		return err;
 
 	for (i = 0; i < 5; i++) {
 		msleep(1);
-		err = mdio_read(phy, MDIO_DEV_PMA_PMD, AEL_I2C_STAT, &stat);
+		err = t3_mdio_read(phy, MDIO_MMD_PMAPMD, AEL_I2C_STAT, &stat);
 		if (err)
 			return err;
 		if ((stat & 3) == 1) {
-			err = mdio_read(phy, MDIO_DEV_PMA_PMD, AEL_I2C_DATA,
-					&data);
+			err = t3_mdio_read(phy, MDIO_MMD_PMAPMD, AEL_I2C_DATA,
+					   &data);
 			if (err)
 				return err;
 			return data >> 8;
 		}
 	}
 	CH_WARN(phy->adapter, "PHY %u I2C read of addr %u timed out\n",
-		phy->addr, word_addr);
+		phy->mdio.prtad, word_addr);
 	return -ETIMEDOUT;
 }
 
@@ -927,7 +926,7 @@ static int get_module_type(struct cphy *phy, int delay_ms)
 	int v;
 	unsigned int stat;
 
-	v = mdio_read(phy, MDIO_DEV_PMA_PMD, AEL2005_GPIO_CTRL, &stat);
+	v = t3_mdio_read(phy, MDIO_MMD_PMAPMD, AEL2005_GPIO_CTRL, &stat);
 	if (v)
 		return v;
 
@@ -971,48 +970,48 @@ unknown:
 
 static int ael2005_intr_enable(struct cphy *phy)
 {
-	int err = mdio_write(phy, MDIO_DEV_PMA_PMD, AEL2005_GPIO_CTRL, 0x200);
+	int err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, AEL2005_GPIO_CTRL, 0x200);
 	return err ? err : t3_phy_lasi_intr_enable(phy);
 }
 
 static int ael2005_intr_disable(struct cphy *phy)
 {
-	int err = mdio_write(phy, MDIO_DEV_PMA_PMD, AEL2005_GPIO_CTRL, 0x100);
+	int err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, AEL2005_GPIO_CTRL, 0x100);
 	return err ? err : t3_phy_lasi_intr_disable(phy);
 }
 
 static int ael2005_intr_clear(struct cphy *phy)
 {
-	int err = mdio_write(phy, MDIO_DEV_PMA_PMD, AEL2005_GPIO_CTRL, 0xd00);
+	int err = t3_mdio_write(phy, MDIO_MMD_PMAPMD, AEL2005_GPIO_CTRL, 0xd00);
 	return err ? err : t3_phy_lasi_intr_clear(phy);
 }
 
 static int ael2005_reset(struct cphy *phy, int wait)
 {
 	static struct reg_val regs0[] = {
-		{ MDIO_DEV_PMA_PMD, 0xc001, 0, 1 << 5 },
-		{ MDIO_DEV_PMA_PMD, 0xc017, 0, 1 << 5 },
-		{ MDIO_DEV_PMA_PMD, 0xc013, 0xffff, 0xf341 },
-		{ MDIO_DEV_PMA_PMD, 0xc210, 0xffff, 0x8000 },
-		{ MDIO_DEV_PMA_PMD, 0xc210, 0xffff, 0x8100 },
-		{ MDIO_DEV_PMA_PMD, 0xc210, 0xffff, 0x8000 },
-		{ MDIO_DEV_PMA_PMD, 0xc210, 0xffff, 0 },
+		{ MDIO_MMD_PMAPMD, 0xc001, 0, 1 << 5 },
+		{ MDIO_MMD_PMAPMD, 0xc017, 0, 1 << 5 },
+		{ MDIO_MMD_PMAPMD, 0xc013, 0xffff, 0xf341 },
+		{ MDIO_MMD_PMAPMD, 0xc210, 0xffff, 0x8000 },
+		{ MDIO_MMD_PMAPMD, 0xc210, 0xffff, 0x8100 },
+		{ MDIO_MMD_PMAPMD, 0xc210, 0xffff, 0x8000 },
+		{ MDIO_MMD_PMAPMD, 0xc210, 0xffff, 0 },
 		{ 0, 0, 0, 0 }
 	};
 	static struct reg_val regs1[] = {
-		{ MDIO_DEV_PMA_PMD, 0xca00, 0xffff, 0x0080 },
-		{ MDIO_DEV_PMA_PMD, 0xca12, 0xffff, 0 },
+		{ MDIO_MMD_PMAPMD, 0xca00, 0xffff, 0x0080 },
+		{ MDIO_MMD_PMAPMD, 0xca12, 0xffff, 0 },
 		{ 0, 0, 0, 0 }
 	};
 
 	int err;
 	unsigned int lasi_ctrl;
 
-	err = mdio_read(phy, MDIO_DEV_PMA_PMD, LASI_CTRL, &lasi_ctrl);
+	err = t3_mdio_read(phy, MDIO_MMD_PMAPMD, LASI_CTRL, &lasi_ctrl);
 	if (err)
 		return err;
 
-	err = t3_phy_reset(phy, MDIO_DEV_PMA_PMD, 0);
+	err = t3_phy_reset(phy, MDIO_MMD_PMAPMD, 0);
 	if (err)
 		return err;
 
@@ -1051,13 +1050,13 @@ static int ael2005_intr_handler(struct cphy *phy)
 	unsigned int stat;
 	int ret, edc_needed, cause = 0;
 
-	ret = mdio_read(phy, MDIO_DEV_PMA_PMD, AEL2005_GPIO_STAT, &stat);
+	ret = t3_mdio_read(phy, MDIO_MMD_PMAPMD, AEL2005_GPIO_STAT, &stat);
 	if (ret)
 		return ret;
 
 	if (stat & AEL2005_MODDET_IRQ) {
-		ret = mdio_write(phy, MDIO_DEV_PMA_PMD, AEL2005_GPIO_CTRL,
-				 0xd00);
+		ret = t3_mdio_write(phy, MDIO_MMD_PMAPMD, AEL2005_GPIO_CTRL,
+				    0xd00);
 		if (ret)
 			return ret;
 
@@ -1098,6 +1097,7 @@ static struct cphy_ops ael2005_ops = {
 	.intr_handler    = ael2005_intr_handler,
 	.get_link_status = get_link_status_r,
 	.power_down      = ael1002_power_down,
+	.mmds            = MDIO_DEVS_PMAPMD | MDIO_DEVS_PCS | MDIO_DEVS_PHYXS,
 };
 
 int t3_ael2005_phy_prep(struct cphy *phy, struct adapter *adapter,
@@ -1107,7 +1107,7 @@ int t3_ael2005_phy_prep(struct cphy *phy, struct adapter *adapter,
 		  SUPPORTED_10000baseT_Full | SUPPORTED_AUI | SUPPORTED_FIBRE |
 		  SUPPORTED_IRQ, "10GBASE-R");
 	msleep(125);
-	return t3_mdio_change_bits(phy, MDIO_DEV_PMA_PMD, AEL_OPT_SETTINGS, 0,
+	return t3_mdio_change_bits(phy, MDIO_MMD_PMAPMD, AEL_OPT_SETTINGS, 0,
 				   1 << 5);
 }
 
@@ -1119,12 +1119,15 @@ static int get_link_status_x(struct cphy *phy, int *link_ok, int *speed,
 {
 	if (link_ok) {
 		unsigned int stat0, stat1, stat2;
-		int err = mdio_read(phy, MDIO_DEV_PMA_PMD, PMD_RSD, &stat0);
+		int err = t3_mdio_read(phy, MDIO_MMD_PMAPMD,
+				       MDIO_PMA_RXDET, &stat0);
 
 		if (!err)
-			err = mdio_read(phy, MDIO_DEV_PCS, PCS_STAT1_X, &stat1);
+			err = t3_mdio_read(phy, MDIO_MMD_PCS,
+					   MDIO_PCS_10GBX_STAT1, &stat1);
 		if (!err)
-			err = mdio_read(phy, MDIO_DEV_XGXS, XS_LN_STAT, &stat2);
+			err = t3_mdio_read(phy, MDIO_MMD_PHYXS,
+					   MDIO_PHYXS_LNSTAT, &stat2);
 		if (err)
 			return err;
 		*link_ok = (stat0 & (stat1 >> 12) & (stat2 >> 12)) & 1;
@@ -1144,6 +1147,7 @@ static struct cphy_ops qt2045_ops = {
 	.intr_handler = t3_phy_lasi_intr_handler,
 	.get_link_status = get_link_status_x,
 	.power_down = ael1006_power_down,
+	.mmds = MDIO_DEVS_PMAPMD | MDIO_DEVS_PCS | MDIO_DEVS_PHYXS,
 };
 
 int t3_qt2045_phy_prep(struct cphy *phy, struct adapter *adapter,
@@ -1159,9 +1163,10 @@ int t3_qt2045_phy_prep(struct cphy *phy, struct adapter *adapter,
 	 * Some cards where the PHY is supposed to be at address 0 actually
 	 * have it at 1.
 	 */
-	if (!phy_addr && !mdio_read(phy, MDIO_DEV_PMA_PMD, MII_BMSR, &stat) &&
+	if (!phy_addr &&
+	    !t3_mdio_read(phy, MDIO_MMD_PMAPMD, MDIO_STAT1, &stat) &&
 	    stat == 0xffff)
-		phy->addr = 1;
+		phy->mdio.prtad = 1;
 	return 0;
 }
 
@@ -1175,15 +1180,16 @@ static int xaui_direct_get_link_status(struct cphy *phy, int *link_ok,
 {
 	if (link_ok) {
 		unsigned int status;
+		int prtad = phy->mdio.prtad;
 
 		status = t3_read_reg(phy->adapter,
-				     XGM_REG(A_XGM_SERDES_STAT0, phy->addr)) |
+				     XGM_REG(A_XGM_SERDES_STAT0, prtad)) |
 		    t3_read_reg(phy->adapter,
-				XGM_REG(A_XGM_SERDES_STAT1, phy->addr)) |
+				    XGM_REG(A_XGM_SERDES_STAT1, prtad)) |
 		    t3_read_reg(phy->adapter,
-				XGM_REG(A_XGM_SERDES_STAT2, phy->addr)) |
+				XGM_REG(A_XGM_SERDES_STAT2, prtad)) |
 		    t3_read_reg(phy->adapter,
-				XGM_REG(A_XGM_SERDES_STAT3, phy->addr));
+				XGM_REG(A_XGM_SERDES_STAT3, prtad));
 		*link_ok = !(status & F_LOWSIG0);
 	}
 	if (speed)
@@ -1211,7 +1217,7 @@ static struct cphy_ops xaui_direct_ops = {
 int t3_xaui_direct_phy_prep(struct cphy *phy, struct adapter *adapter,
 			    int phy_addr, const struct mdio_ops *mdio_ops)
 {
-	cphy_init(phy, adapter, phy_addr, &xaui_direct_ops, mdio_ops,
+	cphy_init(phy, adapter, MDIO_PRTAD_NONE, &xaui_direct_ops, mdio_ops,
 		  SUPPORTED_10000baseT_Full | SUPPORTED_AUI | SUPPORTED_TP,
 		  "10GBASE-CX4");
 	return 0;
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index e508dc3..3147789 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -39,7 +39,7 @@
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/ethtool.h>
-#include <linux/mii.h>
+#include <linux/mdio.h>
 #include "version.h"
 
 #define CH_ERR(adap, fmt, ...)   dev_err(&adap->pdev->dev, fmt, ## __VA_ARGS__)
@@ -184,10 +184,11 @@ struct cphy;
 struct adapter;
 
 struct mdio_ops {
-	int (*read)(struct adapter *adapter, int phy_addr, int mmd_addr,
-		    int reg_addr, unsigned int *val);
-	int (*write)(struct adapter *adapter, int phy_addr, int mmd_addr,
-		     int reg_addr, unsigned int val);
+	int (*read)(struct net_device *dev, int phy_addr, int mmd_addr,
+		    u16 reg_addr);
+	int (*write)(struct net_device *dev, int phy_addr, int mmd_addr,
+		     u16 reg_addr, u16 val);
+	unsigned mode_support;
 };
 
 struct adapter_info {
@@ -520,17 +521,6 @@ enum {
 	MAC_RXFIFO_SIZE = 32768
 };
 
-/* IEEE 802.3 specified MDIO devices */
-enum {
-	MDIO_DEV_PMA_PMD = 1,
-	MDIO_DEV_WIS = 2,
-	MDIO_DEV_PCS = 3,
-	MDIO_DEV_XGXS = 4,
-	MDIO_DEV_ANEG = 7,
-	MDIO_DEV_VEND1 = 30,
-	MDIO_DEV_VEND2 = 31
-};
-
 /* LASI control and status registers */
 enum {
 	RX_ALARM_CTRL = 0x9000,
@@ -583,11 +573,12 @@ struct cphy_ops {
 	int (*get_link_status)(struct cphy *phy, int *link_ok, int *speed,
 			       int *duplex, int *fc);
 	int (*power_down)(struct cphy *phy, int enable);
+
+	u32 mmds;
 };
 
 /* A PHY instance */
 struct cphy {
-	u8 addr;			/* PHY address */
 	u8 modtype;			/* PHY module type */
 	short priv;			/* scratch pad */
 	unsigned int caps;		/* PHY capabilities */
@@ -595,23 +586,23 @@ struct cphy {
 	const char *desc;		/* PHY description */
 	unsigned long fifo_errors;	/* FIFO over/under-flows */
 	const struct cphy_ops *ops;	/* PHY operations */
-	int (*mdio_read)(struct adapter *adapter, int phy_addr, int mmd_addr,
-			 int reg_addr, unsigned int *val);
-	int (*mdio_write)(struct adapter *adapter, int phy_addr, int mmd_addr,
-			  int reg_addr, unsigned int val);
+	struct mdio_if_info mdio;
 };
 
 /* Convenience MDIO read/write wrappers */
-static inline int mdio_read(struct cphy *phy, int mmd, int reg,
-			    unsigned int *valp)
+static inline int t3_mdio_read(struct cphy *phy, int mmd, int reg,
+			       unsigned int *valp)
 {
-	return phy->mdio_read(phy->adapter, phy->addr, mmd, reg, valp);
+	int rc = phy->mdio.mdio_read(phy->mdio.dev, phy->mdio.prtad, mmd, reg);
+	*valp = (rc >= 0) ? rc : -1;
+	return (rc >= 0) ? 0 : rc;
 }
 
-static inline int mdio_write(struct cphy *phy, int mmd, int reg,
-			     unsigned int val)
+static inline int t3_mdio_write(struct cphy *phy, int mmd, int reg,
+				unsigned int val)
 {
-	return phy->mdio_write(phy->adapter, phy->addr, mmd, reg, val);
+	return phy->mdio.mdio_write(phy->mdio.dev, phy->mdio.prtad, mmd,
+				    reg, val);
 }
 
 /* Convenience initializer */
@@ -620,14 +611,16 @@ static inline void cphy_init(struct cphy *phy, struct adapter *adapter,
 			     const struct mdio_ops *mdio_ops,
 			      unsigned int caps, const char *desc)
 {
-	phy->addr = phy_addr;
 	phy->caps = caps;
 	phy->adapter = adapter;
 	phy->desc = desc;
 	phy->ops = phy_ops;
 	if (mdio_ops) {
-		phy->mdio_read = mdio_ops->read;
-		phy->mdio_write = mdio_ops->write;
+		phy->mdio.prtad = phy_addr;
+		phy->mdio.mmds = phy_ops->mmds;
+		phy->mdio.mode_support = mdio_ops->mode_support;
+		phy->mdio.mdio_read = mdio_ops->read;
+		phy->mdio.mdio_write = mdio_ops->write;
 	}
 }
 
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 7ea4841..0b87fee 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -37,7 +37,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/if_vlan.h>
-#include <linux/mii.h>
+#include <linux/mdio.h>
 #include <linux/sockios.h>
 #include <linux/workqueue.h>
 #include <linux/proc_fs.h>
@@ -1593,7 +1593,7 @@ static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	}
 
 	cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
-	cmd->phy_address = p->phy.addr;
+	cmd->phy_address = p->phy.mdio.prtad;
 	cmd->transceiver = XCVR_EXTERNAL;
 	cmd->autoneg = p->link_config.autoneg;
 	cmd->maxtxpkt = 0;
@@ -2308,70 +2308,25 @@ static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 	struct mii_ioctl_data *data = if_mii(req);
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
-	int ret, mmd;
 
 	switch (cmd) {
-	case SIOCGMIIPHY:
-		data->phy_id = pi->phy.addr;
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		/* Convert phy_id from older PRTAD/DEVAD format */
+		if (is_10G(adapter) &&
+		    !mdio_phy_id_is_c45(data->phy_id) &&
+		    (data->phy_id & 0x1f00) &&
+		    !(data->phy_id & 0xe0e0))
+			data->phy_id = mdio_phy_id_c45(data->phy_id >> 8,
+						       data->phy_id & 0x1f);
 		/* FALLTHRU */
-	case SIOCGMIIREG:{
-		u32 val;
-		struct cphy *phy = &pi->phy;
-
-		if (!phy->mdio_read)
-			return -EOPNOTSUPP;
-		if (is_10G(adapter)) {
-			mmd = data->phy_id >> 8;
-			if (!mmd)
-				mmd = MDIO_DEV_PCS;
-			else if (mmd > MDIO_DEV_VEND2)
-				return -EINVAL;
-
-			ret =
-				phy->mdio_read(adapter, data->phy_id & 0x1f,
-						mmd, data->reg_num, &val);
-		} else
-			ret =
-				phy->mdio_read(adapter, data->phy_id & 0x1f,
-						0, data->reg_num & 0x1f,
-						&val);
-		if (!ret)
-			data->val_out = val;
-		break;
-	}
-	case SIOCSMIIREG:{
-		struct cphy *phy = &pi->phy;
-
-		if (!capable(CAP_NET_ADMIN))
-			return -EPERM;
-		if (!phy->mdio_write)
-			return -EOPNOTSUPP;
-		if (is_10G(adapter)) {
-			mmd = data->phy_id >> 8;
-			if (!mmd)
-				mmd = MDIO_DEV_PCS;
-			else if (mmd > MDIO_DEV_VEND2)
-				return -EINVAL;
-
-			ret =
-				phy->mdio_write(adapter,
-						data->phy_id & 0x1f, mmd,
-						data->reg_num,
-						data->val_in);
-		} else
-			ret =
-				phy->mdio_write(adapter,
-						data->phy_id & 0x1f, 0,
-						data->reg_num & 0x1f,
-						data->val_in);
-		break;
-	}
+	case SIOCGMIIPHY:
+		return mdio_mii_ioctl(&pi->phy.mdio, data, cmd);
 	case SIOCCHIOCTL:
 		return cxgb_extension_ioctl(dev, req->ifr_data);
 	default:
 		return -EOPNOTSUPP;
 	}
-	return ret;
 }
 
 static int cxgb_change_mtu(struct net_device *dev, int new_mtu)
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index e1bd690..1dd1637 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -204,35 +204,33 @@ static void mi1_init(struct adapter *adap, const struct adapter_info *ai)
 /*
  * MI1 read/write operations for clause 22 PHYs.
  */
-static int t3_mi1_read(struct adapter *adapter, int phy_addr, int mmd_addr,
-		       int reg_addr, unsigned int *valp)
+static int t3_mi1_read(struct net_device *dev, int phy_addr, int mmd_addr,
+		       u16 reg_addr)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int ret;
 	u32 addr = V_REGADDR(reg_addr) | V_PHYADDR(phy_addr);
 
-	if (mmd_addr)
-		return -EINVAL;
-
 	mutex_lock(&adapter->mdio_lock);
 	t3_set_reg_field(adapter, A_MI1_CFG, V_ST(M_ST), V_ST(1));
 	t3_write_reg(adapter, A_MI1_ADDR, addr);
 	t3_write_reg(adapter, A_MI1_OP, V_MDI_OP(2));
 	ret = t3_wait_op_done(adapter, A_MI1_OP, F_BUSY, 0, MDIO_ATTEMPTS, 10);
 	if (!ret)
-		*valp = t3_read_reg(adapter, A_MI1_DATA);
+		ret = t3_read_reg(adapter, A_MI1_DATA);
 	mutex_unlock(&adapter->mdio_lock);
 	return ret;
 }
 
-static int t3_mi1_write(struct adapter *adapter, int phy_addr, int mmd_addr,
-		     int reg_addr, unsigned int val)
+static int t3_mi1_write(struct net_device *dev, int phy_addr, int mmd_addr,
+			u16 reg_addr, u16 val)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int ret;
 	u32 addr = V_REGADDR(reg_addr) | V_PHYADDR(phy_addr);
 
-	if (mmd_addr)
-		return -EINVAL;
-
 	mutex_lock(&adapter->mdio_lock);
 	t3_set_reg_field(adapter, A_MI1_CFG, V_ST(M_ST), V_ST(1));
 	t3_write_reg(adapter, A_MI1_ADDR, addr);
@@ -244,8 +242,9 @@ static int t3_mi1_write(struct adapter *adapter, int phy_addr, int mmd_addr,
 }
 
 static const struct mdio_ops mi1_mdio_ops = {
-	t3_mi1_read,
-	t3_mi1_write
+	.read = t3_mi1_read,
+	.write = t3_mi1_write,
+	.mode_support = MDIO_SUPPORTS_C22
 };
 
 /*
@@ -268,9 +267,11 @@ static int mi1_wr_addr(struct adapter *adapter, int phy_addr, int mmd_addr,
 /*
  * MI1 read/write operations for indirect-addressed PHYs.
  */
-static int mi1_ext_read(struct adapter *adapter, int phy_addr, int mmd_addr,
-			int reg_addr, unsigned int *valp)
+static int mi1_ext_read(struct net_device *dev, int phy_addr, int mmd_addr,
+			u16 reg_addr)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int ret;
 
 	mutex_lock(&adapter->mdio_lock);
@@ -280,15 +281,17 @@ static int mi1_ext_read(struct adapter *adapter, int phy_addr, int mmd_addr,
 		ret = t3_wait_op_done(adapter, A_MI1_OP, F_BUSY, 0,
 				      MDIO_ATTEMPTS, 10);
 		if (!ret)
-			*valp = t3_read_reg(adapter, A_MI1_DATA);
+			ret = t3_read_reg(adapter, A_MI1_DATA);
 	}
 	mutex_unlock(&adapter->mdio_lock);
 	return ret;
 }
 
-static int mi1_ext_write(struct adapter *adapter, int phy_addr, int mmd_addr,
-			 int reg_addr, unsigned int val)
+static int mi1_ext_write(struct net_device *dev, int phy_addr, int mmd_addr,
+			 u16 reg_addr, u16 val)
 {
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 	int ret;
 
 	mutex_lock(&adapter->mdio_lock);
@@ -304,8 +307,9 @@ static int mi1_ext_write(struct adapter *adapter, int phy_addr, int mmd_addr,
 }
 
 static const struct mdio_ops mi1_mdio_ext_ops = {
-	mi1_ext_read,
-	mi1_ext_write
+	.read = mi1_ext_read,
+	.write = mi1_ext_write,
+	.mode_support = MDIO_SUPPORTS_C45 | MDIO_EMULATE_C22
 };
 
 /**
@@ -325,10 +329,10 @@ int t3_mdio_change_bits(struct cphy *phy, int mmd, int reg, unsigned int clear,
 	int ret;
 	unsigned int val;
 
-	ret = mdio_read(phy, mmd, reg, &val);
+	ret = t3_mdio_read(phy, mmd, reg, &val);
 	if (!ret) {
 		val &= ~clear;
-		ret = mdio_write(phy, mmd, reg, val | set);
+		ret = t3_mdio_write(phy, mmd, reg, val | set);
 	}
 	return ret;
 }
@@ -348,15 +352,16 @@ int t3_phy_reset(struct cphy *phy, int mmd, int wait)
 	int err;
 	unsigned int ctl;
 
-	err = t3_mdio_change_bits(phy, mmd, MII_BMCR, BMCR_PDOWN, BMCR_RESET);
+	err = t3_mdio_change_bits(phy, mmd, MDIO_CTRL1, MDIO_CTRL1_LPOWER,
+				  MDIO_CTRL1_RESET);
 	if (err || !wait)
 		return err;
 
 	do {
-		err = mdio_read(phy, mmd, MII_BMCR, &ctl);
+		err = t3_mdio_read(phy, mmd, MDIO_CTRL1, &ctl);
 		if (err)
 			return err;
-		ctl &= BMCR_RESET;
+		ctl &= MDIO_CTRL1_RESET;
 		if (ctl)
 			msleep(1);
 	} while (ctl && --wait);
@@ -377,7 +382,7 @@ int t3_phy_advertise(struct cphy *phy, unsigned int advert)
 	int err;
 	unsigned int val = 0;
 
-	err = mdio_read(phy, 0, MII_CTRL1000, &val);
+	err = t3_mdio_read(phy, MDIO_DEVAD_NONE, MII_CTRL1000, &val);
 	if (err)
 		return err;
 
@@ -387,7 +392,7 @@ int t3_phy_advertise(struct cphy *phy, unsigned int advert)
 	if (advert & ADVERTISED_1000baseT_Full)
 		val |= ADVERTISE_1000FULL;
 
-	err = mdio_write(phy, 0, MII_CTRL1000, val);
+	err = t3_mdio_write(phy, MDIO_DEVAD_NONE, MII_CTRL1000, val);
 	if (err)
 		return err;
 
@@ -404,7 +409,7 @@ int t3_phy_advertise(struct cphy *phy, unsigned int advert)
 		val |= ADVERTISE_PAUSE_CAP;
 	if (advert & ADVERTISED_Asym_Pause)
 		val |= ADVERTISE_PAUSE_ASYM;
-	return mdio_write(phy, 0, MII_ADVERTISE, val);
+	return t3_mdio_write(phy, MDIO_DEVAD_NONE, MII_ADVERTISE, val);
 }
 
 /**
@@ -427,7 +432,7 @@ int t3_phy_advertise_fiber(struct cphy *phy, unsigned int advert)
 		val |= ADVERTISE_1000XPAUSE;
 	if (advert & ADVERTISED_Asym_Pause)
 		val |= ADVERTISE_1000XPSE_ASYM;
-	return mdio_write(phy, 0, MII_ADVERTISE, val);
+	return t3_mdio_write(phy, MDIO_DEVAD_NONE, MII_ADVERTISE, val);
 }
 
 /**
@@ -444,7 +449,7 @@ int t3_set_phy_speed_duplex(struct cphy *phy, int speed, int duplex)
 	int err;
 	unsigned int ctl;
 
-	err = mdio_read(phy, 0, MII_BMCR, &ctl);
+	err = t3_mdio_read(phy, MDIO_DEVAD_NONE, MII_BMCR, &ctl);
 	if (err)
 		return err;
 
@@ -462,30 +467,30 @@ int t3_set_phy_speed_duplex(struct cphy *phy, int speed, int duplex)
 	}
 	if (ctl & BMCR_SPEED1000) /* auto-negotiation required for GigE */
 		ctl |= BMCR_ANENABLE;
-	return mdio_write(phy, 0, MII_BMCR, ctl);
+	return t3_mdio_write(phy, MDIO_DEVAD_NONE, MII_BMCR, ctl);
 }
 
 int t3_phy_lasi_intr_enable(struct cphy *phy)
 {
-	return mdio_write(phy, MDIO_DEV_PMA_PMD, LASI_CTRL, 1);
+	return t3_mdio_write(phy, MDIO_MMD_PMAPMD, LASI_CTRL, 1);
 }
 
 int t3_phy_lasi_intr_disable(struct cphy *phy)
 {
-	return mdio_write(phy, MDIO_DEV_PMA_PMD, LASI_CTRL, 0);
+	return t3_mdio_write(phy, MDIO_MMD_PMAPMD, LASI_CTRL, 0);
 }
 
 int t3_phy_lasi_intr_clear(struct cphy *phy)
 {
 	u32 val;
 
-	return mdio_read(phy, MDIO_DEV_PMA_PMD, LASI_STAT, &val);
+	return t3_mdio_read(phy, MDIO_MMD_PMAPMD, LASI_STAT, &val);
 }
 
 int t3_phy_lasi_intr_handler(struct cphy *phy)
 {
 	unsigned int status;
-	int err = mdio_read(phy, MDIO_DEV_PMA_PMD, LASI_STAT, &status);
+	int err = t3_mdio_read(phy, MDIO_MMD_PMAPMD, LASI_STAT, &status);
 
 	if (err)
 		return err;
@@ -3863,6 +3868,7 @@ int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 				    ai->mdio_ops);
 		if (ret)
 			return ret;
+		p->phy.mdio.dev = adapter->port[i];
 		mac_prep(&p->mac, adapter, j);
 
 		/*
@@ -3918,7 +3924,7 @@ int t3_replay_prep_adapter(struct adapter *adapter)
 			;
 
 		pti = &port_types[adapter->params.vpd.port_type[j]];
-		ret = pti->phy_prep(&p->phy, adapter, p->phy.addr, NULL);
+		ret = pti->phy_prep(&p->phy, adapter, p->phy.mdio.prtad, NULL);
 		if (ret)
 			return ret;
 		p->phy.ops->power_down(&p->phy, 1);
diff --git a/drivers/net/cxgb3/vsc8211.c b/drivers/net/cxgb3/vsc8211.c
index d071309..4f9a1c2 100644
--- a/drivers/net/cxgb3/vsc8211.c
+++ b/drivers/net/cxgb3/vsc8211.c
@@ -91,17 +91,18 @@ enum {
  */
 static int vsc8211_reset(struct cphy *cphy, int wait)
 {
-	return t3_phy_reset(cphy, 0, 0);
+	return t3_phy_reset(cphy, MDIO_DEVAD_NONE, 0);
 }
 
 static int vsc8211_intr_enable(struct cphy *cphy)
 {
-	return mdio_write(cphy, 0, VSC8211_INTR_ENABLE, INTR_MASK);
+	return t3_mdio_write(cphy, MDIO_DEVAD_NONE, VSC8211_INTR_ENABLE,
+			     INTR_MASK);
 }
 
 static int vsc8211_intr_disable(struct cphy *cphy)
 {
-	return mdio_write(cphy, 0, VSC8211_INTR_ENABLE, 0);
+	return t3_mdio_write(cphy, MDIO_DEVAD_NONE, VSC8211_INTR_ENABLE, 0);
 }
 
 static int vsc8211_intr_clear(struct cphy *cphy)
@@ -109,18 +110,20 @@ static int vsc8211_intr_clear(struct cphy *cphy)
 	u32 val;
 
 	/* Clear PHY interrupts by reading the register. */
-	return mdio_read(cphy, 0, VSC8211_INTR_STATUS, &val);
+	return t3_mdio_read(cphy, MDIO_DEVAD_NONE, VSC8211_INTR_STATUS, &val);
 }
 
 static int vsc8211_autoneg_enable(struct cphy *cphy)
 {
-	return t3_mdio_change_bits(cphy, 0, MII_BMCR, BMCR_PDOWN | BMCR_ISOLATE,
+	return t3_mdio_change_bits(cphy, MDIO_DEVAD_NONE, MII_BMCR,
+				   BMCR_PDOWN | BMCR_ISOLATE,
 				   BMCR_ANENABLE | BMCR_ANRESTART);
 }
 
 static int vsc8211_autoneg_restart(struct cphy *cphy)
 {
-	return t3_mdio_change_bits(cphy, 0, MII_BMCR, BMCR_PDOWN | BMCR_ISOLATE,
+	return t3_mdio_change_bits(cphy, MDIO_DEVAD_NONE, MII_BMCR,
+				   BMCR_PDOWN | BMCR_ISOLATE,
 				   BMCR_ANRESTART);
 }
 
@@ -130,9 +133,9 @@ static int vsc8211_get_link_status(struct cphy *cphy, int *link_ok,
 	unsigned int bmcr, status, lpa, adv;
 	int err, sp = -1, dplx = -1, pause = 0;
 
-	err = mdio_read(cphy, 0, MII_BMCR, &bmcr);
+	err = t3_mdio_read(cphy, MDIO_DEVAD_NONE, MII_BMCR, &bmcr);
 	if (!err)
-		err = mdio_read(cphy, 0, MII_BMSR, &status);
+		err = t3_mdio_read(cphy, MDIO_DEVAD_NONE, MII_BMSR, &status);
 	if (err)
 		return err;
 
@@ -142,7 +145,8 @@ static int vsc8211_get_link_status(struct cphy *cphy, int *link_ok,
 		 * once more to get the current link state.
 		 */
 		if (!(status & BMSR_LSTATUS))
-			err = mdio_read(cphy, 0, MII_BMSR, &status);
+			err = t3_mdio_read(cphy, MDIO_DEVAD_NONE, MII_BMSR,
+					   &status);
 		if (err)
 			return err;
 		*link_ok = (status & BMSR_LSTATUS) != 0;
@@ -156,7 +160,8 @@ static int vsc8211_get_link_status(struct cphy *cphy, int *link_ok,
 		else
 			sp = SPEED_10;
 	} else if (status & BMSR_ANEGCOMPLETE) {
-		err = mdio_read(cphy, 0, VSC8211_AUX_CTRL_STAT, &status);
+		err = t3_mdio_read(cphy, MDIO_DEVAD_NONE, VSC8211_AUX_CTRL_STAT,
+				   &status);
 		if (err)
 			return err;
 
@@ -170,9 +175,11 @@ static int vsc8211_get_link_status(struct cphy *cphy, int *link_ok,
 			sp = SPEED_1000;
 
 		if (fc && dplx == DUPLEX_FULL) {
-			err = mdio_read(cphy, 0, MII_LPA, &lpa);
+			err = t3_mdio_read(cphy, MDIO_DEVAD_NONE, MII_LPA,
+					   &lpa);
 			if (!err)
-				err = mdio_read(cphy, 0, MII_ADVERTISE, &adv);
+				err = t3_mdio_read(cphy, MDIO_DEVAD_NONE,
+						   MII_ADVERTISE, &adv);
 			if (err)
 				return err;
 
@@ -202,9 +209,9 @@ static int vsc8211_get_link_status_fiber(struct cphy *cphy, int *link_ok,
 	unsigned int bmcr, status, lpa, adv;
 	int err, sp = -1, dplx = -1, pause = 0;
 
-	err = mdio_read(cphy, 0, MII_BMCR, &bmcr);
+	err = t3_mdio_read(cphy, MDIO_DEVAD_NONE, MII_BMCR, &bmcr);
 	if (!err)
-		err = mdio_read(cphy, 0, MII_BMSR, &status);
+		err = t3_mdio_read(cphy, MDIO_DEVAD_NONE, MII_BMSR, &status);
 	if (err)
 		return err;
 
@@ -214,7 +221,8 @@ static int vsc8211_get_link_status_fiber(struct cphy *cphy, int *link_ok,
 		 * once more to get the current link state.
 		 */
 		if (!(status & BMSR_LSTATUS))
-			err = mdio_read(cphy, 0, MII_BMSR, &status);
+			err = t3_mdio_read(cphy, MDIO_DEVAD_NONE, MII_BMSR,
+					   &status);
 		if (err)
 			return err;
 		*link_ok = (status & BMSR_LSTATUS) != 0;
@@ -228,9 +236,10 @@ static int vsc8211_get_link_status_fiber(struct cphy *cphy, int *link_ok,
 		else
 			sp = SPEED_10;
 	} else if (status & BMSR_ANEGCOMPLETE) {
-		err = mdio_read(cphy, 0, MII_LPA, &lpa);
+		err = t3_mdio_read(cphy, MDIO_DEVAD_NONE, MII_LPA, &lpa);
 		if (!err)
-			err = mdio_read(cphy, 0, MII_ADVERTISE, &adv);
+			err = t3_mdio_read(cphy, MDIO_DEVAD_NONE, MII_ADVERTISE,
+					   &adv);
 		if (err)
 			return err;
 
@@ -270,23 +279,23 @@ static int vsc8211_set_automdi(struct cphy *phy, int enable)
 {
 	int err;
 
-	err = mdio_write(phy, 0, VSC8211_EXT_PAGE_AXS, 0x52b5);
+	err = t3_mdio_write(phy, MDIO_DEVAD_NONE, VSC8211_EXT_PAGE_AXS, 0x52b5);
 	if (err)
 		return err;
 
-	err = mdio_write(phy, 0, 18, 0x12);
+	err = t3_mdio_write(phy, MDIO_DEVAD_NONE, 18, 0x12);
 	if (err)
 		return err;
 
-	err = mdio_write(phy, 0, 17, enable ? 0x2803 : 0x3003);
+	err = t3_mdio_write(phy, MDIO_DEVAD_NONE, 17, enable ? 0x2803 : 0x3003);
 	if (err)
 		return err;
 
-	err = mdio_write(phy, 0, 16, 0x87fa);
+	err = t3_mdio_write(phy, MDIO_DEVAD_NONE, 16, 0x87fa);
 	if (err)
 		return err;
 
-	err = mdio_write(phy, 0, VSC8211_EXT_PAGE_AXS, 0);
+	err = t3_mdio_write(phy, MDIO_DEVAD_NONE, VSC8211_EXT_PAGE_AXS, 0);
 	if (err)
 		return err;
 
@@ -315,7 +324,7 @@ static int vsc8211_intr_handler(struct cphy *cphy)
 	unsigned int cause;
 	int err, cphy_cause = 0;
 
-	err = mdio_read(cphy, 0, VSC8211_INTR_STATUS, &cause);
+	err = t3_mdio_read(cphy, MDIO_DEVAD_NONE, VSC8211_INTR_STATUS, &cause);
 	if (err)
 		return err;
 
@@ -367,12 +376,13 @@ int t3_vsc8211_phy_prep(struct cphy *phy, struct adapter *adapter,
 		  SUPPORTED_TP | SUPPORTED_IRQ, "10/100/1000BASE-T");
 	msleep(20);       /* PHY needs ~10ms to start responding to MDIO */
 
-	err = mdio_read(phy, 0, VSC8211_EXT_CTRL, &val);
+	err = t3_mdio_read(phy, MDIO_DEVAD_NONE, VSC8211_EXT_CTRL, &val);
 	if (err)
 		return err;
 	if (val & VSC_CTRL_MEDIA_MODE_HI) {
 		/* copper interface, just need to configure the LEDs */
-		return mdio_write(phy, 0, VSC8211_LED_CTRL, 0x100);
+		return t3_mdio_write(phy, MDIO_DEVAD_NONE, VSC8211_LED_CTRL,
+				     0x100);
 	}
 
 	phy->caps = SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg |
@@ -380,20 +390,20 @@ int t3_vsc8211_phy_prep(struct cphy *phy, struct adapter *adapter,
 	phy->desc = "1000BASE-X";
 	phy->ops = &vsc8211_fiber_ops;
 
-	err = mdio_write(phy, 0, VSC8211_EXT_PAGE_AXS, 1);
+	err = t3_mdio_write(phy, MDIO_DEVAD_NONE, VSC8211_EXT_PAGE_AXS, 1);
 	if (err)
 		return err;
 
-	err = mdio_write(phy, 0, VSC8211_SIGDET_CTRL, 1);
+	err = t3_mdio_write(phy, MDIO_DEVAD_NONE, VSC8211_SIGDET_CTRL, 1);
 	if (err)
 		return err;
 
-	err = mdio_write(phy, 0, VSC8211_EXT_PAGE_AXS, 0);
+	err = t3_mdio_write(phy, MDIO_DEVAD_NONE, VSC8211_EXT_PAGE_AXS, 0);
 	if (err)
 		return err;
 
-	err = mdio_write(phy, 0, VSC8211_EXT_CTRL,
-			 val | VSC_CTRL_CLAUSE37_VIEW);
+	err = t3_mdio_write(phy, MDIO_DEVAD_NONE, VSC8211_EXT_CTRL,
+			    val | VSC_CTRL_CLAUSE37_VIEW);
 	if (err)
 		return err;
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

