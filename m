From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 43/52] sfc: Remove workaround for old firmware bug
Date: Mon, 1 Sep 2008 12:49:20 +0100
Message-ID: <20080901114919.GJ7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:43372 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759197AbYIALtX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:49:23 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was a bug in XAUI synchronisation in early 10Xpress firmware
versions.  This is fixed in released firmware and we do not need to
work around it.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c         |    1 -
 drivers/net/sfc/falcon_xmac.c |   88 +----------------------------------------
 drivers/net/sfc/net_driver.h  |    2 -
 drivers/net/sfc/sfe4001.c     |   12 ------
 drivers/net/sfc/tenxpress.c   |   51 -----------------------
 drivers/net/sfc/workarounds.h |    2 -
 drivers/net/sfc/xfp_phy.c     |    1 -
 7 files changed, 1 insertions(+), 156 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index c295ea6..ef72413 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1750,7 +1750,6 @@ static struct efx_phy_operations efx_dummy_phy_operations = {
 	.check_hw        = efx_port_dummy_op_int,
 	.fini		 = efx_port_dummy_op_void,
 	.clear_interrupt = efx_port_dummy_op_void,
-	.reset_xaui      = efx_port_dummy_op_void,
 };
 
 static struct efx_board efx_dummy_board_info = {
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 0d9f68f..d401231 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -78,79 +78,7 @@ static void falcon_setup_xaui(struct efx_nic *efx)
 	falcon_write(efx, &txdrv, XX_TXDRV_CTL_REG);
 }
 
-static void falcon_hold_xaui_in_rst(struct efx_nic *efx)
-{
-	efx_oword_t reg;
-
-	EFX_ZERO_OWORD(reg);
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDNA_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDNB_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDNC_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDND_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLAB_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLCD_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RESETA_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RESETB_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RESETC_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RESETD_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSRX_EN, 1);
-	EFX_SET_OWORD_FIELD(reg, XX_RSTXGXSTX_EN, 1);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-}
-
-static int _falcon_reset_xaui_a(struct efx_nic *efx)
-{
-	efx_oword_t reg;
-
-	falcon_hold_xaui_in_rst(efx);
-	falcon_read(efx, &reg, XX_PWR_RST_REG);
-
-	/* Follow the RAMBUS XAUI data reset sequencing
-	 * Channels A and B first: power down, reset PLL, reset, clear
-	 */
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDNA_EN, 0);
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDNB_EN, 0);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLAB_EN, 0);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	EFX_SET_OWORD_FIELD(reg, XX_RESETA_EN, 0);
-	EFX_SET_OWORD_FIELD(reg, XX_RESETB_EN, 0);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	/* Channels C and D: power down, reset PLL, reset, clear */
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDNC_EN, 0);
-	EFX_SET_OWORD_FIELD(reg, XX_PWRDND_EN, 0);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	EFX_SET_OWORD_FIELD(reg, XX_RSTPLLCD_EN, 0);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	EFX_SET_OWORD_FIELD(reg, XX_RESETC_EN, 0);
-	EFX_SET_OWORD_FIELD(reg, XX_RESETD_EN, 0);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	/* Setup XAUI */
-	falcon_setup_xaui(efx);
-	udelay(10);
-
-	/* Take XGXS out of reset */
-	EFX_ZERO_OWORD(reg);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
-
-	return 0;
-}
-
-static int _falcon_reset_xaui_b(struct efx_nic *efx)
+int falcon_reset_xaui(struct efx_nic *efx)
 {
 	efx_oword_t reg;
 	int count;
@@ -171,20 +99,6 @@ static int _falcon_reset_xaui_b(struct efx_nic *efx)
 	return -ETIMEDOUT;
 }
 
-int falcon_reset_xaui(struct efx_nic *efx)
-{
-	int rc;
-
-	if (EFX_WORKAROUND_9388(efx)) {
-		falcon_hold_xaui_in_rst(efx);
-		efx->phy_op->reset_xaui(efx);
-		rc = _falcon_reset_xaui_a(efx);
-	} else {
-		rc = _falcon_reset_xaui_b(efx);
-	}
-	return rc;
-}
-
 static bool falcon_xgmii_status(struct efx_nic *efx)
 {
 	efx_oword_t reg;
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 567df00..be3d2ba 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -503,7 +503,6 @@ enum efx_fc_type {
  * @clear_interrupt: Clear down interrupt
  * @blink: Blink LEDs
  * @check_hw: Check hardware
- * @reset_xaui: Reset XAUI side of PHY for (software sequenced reset)
  * @mmds: MMD presence mask
  * @loopbacks: Supported loopback modes mask
  */
@@ -513,7 +512,6 @@ struct efx_phy_operations {
 	void (*reconfigure) (struct efx_nic *efx);
 	void (*clear_interrupt) (struct efx_nic *efx);
 	int (*check_hw) (struct efx_nic *efx);
-	void (*reset_xaui) (struct efx_nic *efx);
 	int (*test) (struct efx_nic *efx);
 	int mmds;
 	unsigned loopbacks;
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index b7005da..fe4e3fd 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -129,18 +129,6 @@ static int sfe4001_poweron(struct efx_nic *efx)
 	unsigned int i, j;
 	int rc;
 	u8 out;
-	efx_oword_t reg;
-
-	/* Ensure that XGXS and XAUI SerDes are held in reset */
-	EFX_POPULATE_OWORD_7(reg, XX_PWRDNA_EN, 1,
-			     XX_PWRDNB_EN, 1,
-			     XX_RSTPLLAB_EN, 1,
-			     XX_RESETA_EN, 1,
-			     XX_RESETB_EN, 1,
-			     XX_RSTXGXSRX_EN, 1,
-			     XX_RSTXGXSTX_EN, 1);
-	falcon_write(efx, &reg, XX_PWR_RST_REG);
-	udelay(10);
 
 	/* Clear any previous over-temperature alert */
 	rc = i2c_smbus_read_byte_data(hwmon_client, RSL);
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 8412dbe..77e7f3a 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -146,8 +146,6 @@ static int tenxpress_phy_check(struct efx_nic *efx)
 	return 0;
 }
 
-static void tenxpress_reset_xaui(struct efx_nic *efx);
-
 static int tenxpress_init(struct efx_nic *efx)
 {
 	int rc, reg;
@@ -428,54 +426,6 @@ void tenxpress_phy_blink(struct efx_nic *efx, bool blink)
 			    PMA_PMD_LED_OVERR_REG, reg);
 }
 
-static void tenxpress_reset_xaui(struct efx_nic *efx)
-{
-	int phy = efx->mii.phy_id;
-	int clk_ctrl, test_select, soft_rst2;
-
-	/* Real work is done on clock_ctrl other resets are thought to be
-	 * optional but make the reset more reliable
-	 */
-
-	/* Read */
-	clk_ctrl = mdio_clause45_read(efx, phy, MDIO_MMD_PCS,
-				      PCS_CLOCK_CTRL_REG);
-	test_select = mdio_clause45_read(efx, phy, MDIO_MMD_PCS,
-					 PCS_TEST_SELECT_REG);
-	soft_rst2 = mdio_clause45_read(efx, phy, MDIO_MMD_PCS,
-				       PCS_SOFT_RST2_REG);
-
-	/* Put in reset */
-	test_select &= ~(1 << CLK312_EN_LBN);
-	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
-			    PCS_TEST_SELECT_REG, test_select);
-
-	soft_rst2 &= ~((1 << XGXS_RST_N_LBN) | (1 << SERDES_RST_N_LBN));
-	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
-			    PCS_SOFT_RST2_REG, soft_rst2);
-
-	clk_ctrl &= ~(1 << PLL312_RST_N_LBN);
-	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
-			    PCS_CLOCK_CTRL_REG, clk_ctrl);
-	udelay(10);
-
-	/* Remove reset */
-	clk_ctrl |= (1 << PLL312_RST_N_LBN);
-	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
-			    PCS_CLOCK_CTRL_REG, clk_ctrl);
-	udelay(10);
-
-	soft_rst2 |= ((1 << XGXS_RST_N_LBN) | (1 << SERDES_RST_N_LBN));
-	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
-			    PCS_SOFT_RST2_REG, soft_rst2);
-	udelay(10);
-
-	test_select |= (1 << CLK312_EN_LBN);
-	mdio_clause45_write(efx, phy, MDIO_MMD_PCS,
-			    PCS_TEST_SELECT_REG, test_select);
-	udelay(10);
-}
-
 static int tenxpress_phy_test(struct efx_nic *efx)
 {
 	/* BIST is automatically run after a special software reset */
@@ -488,7 +438,6 @@ struct efx_phy_operations falcon_tenxpress_phy_ops = {
 	.check_hw         = tenxpress_phy_check_hw,
 	.fini             = tenxpress_phy_fini,
 	.clear_interrupt  = tenxpress_phy_clear_interrupt,
-	.reset_xaui       = tenxpress_reset_xaui,
 	.test             = tenxpress_phy_test,
 	.mmds             = TENXPRESS_REQUIRED_DEVS,
 	.loopbacks        = TENXPRESS_LOOPBACKS,
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index a824f59..fa7b49d 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -24,8 +24,6 @@
 #define EFX_WORKAROUND_7575 EFX_WORKAROUND_ALWAYS
 /* TX pkt parser problem with <= 16 byte TXes */
 #define EFX_WORKAROUND_9141 EFX_WORKAROUND_ALWAYS
-/* XGXS and XAUI reset sequencing in SW */
-#define EFX_WORKAROUND_9388 EFX_WORKAROUND_ALWAYS
 /* Low rate CRC errors require XAUI reset */
 #define EFX_WORKAROUND_10750 EFX_WORKAROUND_ALWAYS
 /* TX_EV_PKT_ERR can be caused by a dangling TX descriptor
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index f6edecc..276151d 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -165,7 +165,6 @@ struct efx_phy_operations falcon_xfp_phy_ops = {
 	.check_hw        = xfp_phy_check_hw,
 	.fini            = xfp_phy_fini,
 	.clear_interrupt = xfp_phy_clear_interrupt,
-	.reset_xaui      = efx_port_dummy_op_void,
 	.mmds            = XFP_REQUIRED_DEVS,
 	.loopbacks       = XFP_LOOPBACKS,
 };
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

