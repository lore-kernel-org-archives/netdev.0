From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 16/20] sfc: Add support for QT2025C PHY
Date: Thu, 29 Jan 2009 19:21:00 +0000
Message-ID: <1233256860.3656.43.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:47626 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753946AbZA2TVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:21:02 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a new PHY supporting SFP+ modules, used in the SFN4112F
reference design.  It is similar to the QT2022C2 and shares much of
its support code.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c     |    1 +
 drivers/net/sfc/net_driver.h |    1 +
 drivers/net/sfc/phy.h        |    4 +-
 drivers/net/sfc/xfp_phy.c    |   95 ++++++++++++++++++++++++++++++++++++++----
 4 files changed, 91 insertions(+), 10 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index d9412f8..7ad5daa 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2249,6 +2249,7 @@ static int falcon_probe_phy(struct efx_nic *efx)
 		efx->phy_op = &falcon_sft9001_phy_ops;
 		break;
 	case PHY_TYPE_QT2022C2:
+	case PHY_TYPE_QT2025C:
 		efx->phy_op = &falcon_xfp_phy_ops;
 		break;
 	default:
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 8eb411a..39f1ff8 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -459,6 +459,7 @@ enum phy_type {
 	PHY_TYPE_QT2022C2 = 4,
 	PHY_TYPE_PM8358 = 6,
 	PHY_TYPE_SFT9001A = 8,
+	PHY_TYPE_QT2025C = 9,
 	PHY_TYPE_SFT9001B = 10,
 	PHY_TYPE_MAX	/* Insert any new items before this */
 };
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index f6e4722..c1cff9c 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -23,11 +23,11 @@ extern void tenxpress_phy_blink(struct efx_nic *efx, bool blink);
 extern int sft9001_wait_boot(struct efx_nic *efx);
 
 /****************************************************************************
- * Exported functions from the driver for XFP optical PHYs
+ * AMCC/Quake QT20xx PHYs
  */
 extern struct efx_phy_operations falcon_xfp_phy_ops;
 
-/* The QUAKE XFP PHY provides various H/W control states for LEDs */
+/* These PHYs provide various H/W control states for LEDs */
 #define QUAKE_LED_LINK_INVAL	(0)
 #define QUAKE_LED_LINK_STAT	(1)
 #define QUAKE_LED_LINK_ACT	(2)
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 2df467d..bb1ef77 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -7,8 +7,8 @@
  * by the Free Software Foundation, incorporated herein by reference.
  */
 /*
- * Driver for XFP optical PHYs (plus some support specific to the Quake 2022/32)
- * See www.amcc.com for details (search for qt2032)
+ * Driver for SFP+ and XFP optical PHYs plus some support specific to the
+ * AMCC QT20xx adapters; see www.amcc.com for details
  */
 
 #include <linux/timer.h>
@@ -31,6 +31,21 @@
 /* Quake-specific MDIO registers */
 #define MDIO_QUAKE_LED0_REG	(0xD006)
 
+/* QT2025C only */
+#define PCS_FW_HEARTBEAT_REG	0xd7ee
+#define PCS_FW_HEARTB_LBN	0
+#define PCS_FW_HEARTB_WIDTH	8
+#define PCS_UC8051_STATUS_REG	0xd7fd
+#define PCS_UC_STATUS_LBN	0
+#define PCS_UC_STATUS_WIDTH	8
+#define PCS_UC_STATUS_FW_SAVE	0x20
+#define PMA_PMD_FTX_CTRL2_REG	0xc309
+#define PMA_PMD_FTX_STATIC_LBN	13
+#define PMA_PMD_VEND1_REG	0xc001
+#define PMA_PMD_VEND1_LBTXD_LBN	15
+#define PCS_VEND1_REG	   	0xc000
+#define PCS_VEND1_LBTXD_LBN	5
+
 void xfp_set_led(struct efx_nic *p, int led, int mode)
 {
 	int addr = MDIO_QUAKE_LED0_REG + led;
@@ -45,7 +60,49 @@ struct xfp_phy_data {
 #define XFP_MAX_RESET_TIME 500
 #define XFP_RESET_WAIT 10
 
-/* Reset the PHYXS MMD. This is documented (for the Quake PHY) as doing
+static int qt2025c_wait_reset(struct efx_nic *efx)
+{
+	unsigned long timeout = jiffies + 10 * HZ;
+	int phy_id = efx->mii.phy_id;
+	int reg, old_counter = 0;
+
+	/* Wait for firmware heartbeat to start */
+	for (;;) {
+		int counter;
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PCS,
+					 PCS_FW_HEARTBEAT_REG);
+		if (reg < 0)
+			return reg;
+		counter = ((reg >> PCS_FW_HEARTB_LBN) &
+			    ((1 << PCS_FW_HEARTB_WIDTH) - 1));
+		if (old_counter == 0)
+			old_counter = counter;
+		else if (counter != old_counter)
+			break;
+		if (time_after(jiffies, timeout))
+			return -ETIMEDOUT;
+		msleep(10);
+	}
+
+	/* Wait for firmware status to look good */
+	for (;;) {
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PCS,
+					 PCS_UC8051_STATUS_REG);
+		if (reg < 0)
+			return reg;
+		if ((reg &
+		     ((1 << PCS_UC_STATUS_WIDTH) - 1) << PCS_UC_STATUS_LBN) >=
+		    PCS_UC_STATUS_FW_SAVE)
+			break;
+		if (time_after(jiffies, timeout))
+			return -ETIMEDOUT;
+		msleep(100);
+	}
+
+	return 0;
+}
+
+/* Reset the PHYXS MMD. This is documented (for the Quake PHYs) as doing
  * a complete soft reset.
  */
 static int xfp_reset_phy(struct efx_nic *efx)
@@ -58,6 +115,12 @@ static int xfp_reset_phy(struct efx_nic *efx)
 	if (rc < 0)
 		goto fail;
 
+	if (efx->phy_type == PHY_TYPE_QT2025C) {
+		rc = qt2025c_wait_reset(efx);
+		if (rc < 0)
+			goto fail;
+	}
+
 	/* Wait 250ms for the PHY to complete bootup */
 	msleep(250);
 
@@ -131,12 +194,28 @@ static void xfp_phy_reconfigure(struct efx_nic *efx)
 {
 	struct xfp_phy_data *phy_data = efx->phy_data;
 
-	/* Reset the PHY when moving from tx off to tx on */
-	if (!(efx->phy_mode & PHY_MODE_TX_DISABLED) &&
-	    (phy_data->phy_mode & PHY_MODE_TX_DISABLED))
-		xfp_reset_phy(efx);
+	if (efx->phy_type == PHY_TYPE_QT2025C) {
+		/* There are several different register bits which can
+		 * disable TX (and save power) on direct-attach cables
+		 * or optical transceivers, varying somewhat between
+		 * firmware versions.  Only 'static mode' appears to
+		 * cover everything. */
+		mdio_clause45_set_flag(
+			efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+			PMA_PMD_FTX_CTRL2_REG, PMA_PMD_FTX_STATIC_LBN,
+			efx->phy_mode & PHY_MODE_TX_DISABLED ||
+			efx->phy_mode & PHY_MODE_LOW_POWER ||
+			efx->loopback_mode == LOOPBACK_PCS ||
+			efx->loopback_mode == LOOPBACK_PMAPMD);
+	} else {
+		/* Reset the PHY when moving from tx off to tx on */
+		if (!(efx->phy_mode & PHY_MODE_TX_DISABLED) &&
+		    (phy_data->phy_mode & PHY_MODE_TX_DISABLED))
+			xfp_reset_phy(efx);
+
+		mdio_clause45_transmit_disable(efx);
+	}
 
-	mdio_clause45_transmit_disable(efx);
 	mdio_clause45_phy_reconfigure(efx);
 
 	phy_data->phy_mode = efx->phy_mode;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

