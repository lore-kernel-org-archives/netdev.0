From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/9] sfc: SFT9001/SFN4111T: Check PHY boot status during
	board initialisation
Date: Fri, 27 Feb 2009 23:06:45 +0000
Message-ID: <1235776005.3164.18.camel@achroite>
References: <1235775847.3164.6.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:48351 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754007AbZB0XGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 18:06:47 -0500
In-Reply-To: <1235775847.3164.6.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During SFN4111T initialisation, check whether the PHY boot status
indicates a bad firmware checksum.  If so, prepare to reflash rather
than continuing with normal initialisation.

Remove redundant PHY boot status check from tenxpress_phy_init().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/phy.h       |    4 ++
 drivers/net/sfc/sfe4001.c   |   20 +++++++---
 drivers/net/sfc/tenxpress.c |   90 ++++++++++++++++++++++++++-----------------
 3 files changed, 73 insertions(+), 41 deletions(-)

diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index 07e855c..f6e4722 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -18,6 +18,10 @@ extern struct efx_phy_operations falcon_sft9001_phy_ops;
 
 extern void tenxpress_phy_blink(struct efx_nic *efx, bool blink);
 
+/* Wait for the PHY to boot. Return 0 on success, -EINVAL if the PHY failed
+ * to boot due to corrupt flash, or some other negative error code. */
+extern int sft9001_wait_boot(struct efx_nic *efx);
+
 /****************************************************************************
  * Exported functions from the driver for XFP optical PHYs
  */
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index c0e9068..4eac5da 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -399,6 +399,7 @@ static struct i2c_board_info sfn4111t_r5_hwmon_info = {
 
 int sfn4111t_init(struct efx_nic *efx)
 {
+	int i = 0;
 	int rc;
 
 	efx->board_info.hwmon_client =
@@ -417,13 +418,20 @@ int sfn4111t_init(struct efx_nic *efx)
 	if (rc)
 		goto fail_hwmon;
 
-	if (efx->phy_mode & PHY_MODE_SPECIAL) {
-		efx_stats_disable(efx);
-		sfn4111t_reset(efx);
-	}
-
-	return 0;
+	do {
+		if (efx->phy_mode & PHY_MODE_SPECIAL) {
+			/* PHY may not generate a 156.25 MHz clock and MAC
+			 * stats fetch will fail. */
+			efx_stats_disable(efx);
+			sfn4111t_reset(efx);
+		}
+		rc = sft9001_wait_boot(efx);
+		if (rc == 0)
+			return 0;
+		efx->phy_mode = PHY_MODE_SPECIAL;
+	} while (rc == -EINVAL && ++i < 2);
 
+	device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_flash_cfg);
 fail_hwmon:
 	i2c_unregister_device(efx->board_info.hwmon_client);
 	return rc;
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 23583ba..e61dc4d 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -158,14 +158,16 @@
 #define PCS_10GBASET_BLKLK_WIDTH 1
 
 /* Boot status register */
-#define PCS_BOOT_STATUS_REG	53248
-#define PCS_BOOT_FATAL_ERR_LBN	(0)
-#define PCS_BOOT_PROGRESS_LBN	(1)
-#define PCS_BOOT_PROGRESS_WIDTH	(2)
-#define PCS_BOOT_COMPLETE_LBN	(3)
-
-#define PCS_BOOT_MAX_DELAY	(100)
-#define PCS_BOOT_POLL_DELAY	(10)
+#define PCS_BOOT_STATUS_REG		53248
+#define PCS_BOOT_FATAL_ERROR_LBN	0
+#define PCS_BOOT_PROGRESS_LBN		1
+#define PCS_BOOT_PROGRESS_WIDTH		2
+#define PCS_BOOT_PROGRESS_INIT		0
+#define PCS_BOOT_PROGRESS_WAIT_MDIO	1
+#define PCS_BOOT_PROGRESS_CHECKSUM	2
+#define PCS_BOOT_PROGRESS_JUMP		3
+#define PCS_BOOT_DOWNLOAD_WAIT_LBN	3
+#define PCS_BOOT_CODE_STARTED_LBN	4
 
 /* 100M/1G PHY registers */
 #define GPHY_XCONTROL_REG	49152
@@ -230,40 +232,62 @@ static ssize_t set_phy_short_reach(struct device *dev,
 static DEVICE_ATTR(phy_short_reach, 0644, show_phy_short_reach,
 		   set_phy_short_reach);
 
-/* Check that the C166 has booted successfully */
-static int tenxpress_phy_check(struct efx_nic *efx)
+int sft9001_wait_boot(struct efx_nic *efx)
 {
-	int phy_id = efx->mii.phy_id;
-	int count = PCS_BOOT_MAX_DELAY / PCS_BOOT_POLL_DELAY;
+	unsigned long timeout = jiffies + HZ + 1;
 	int boot_stat;
 
-	/* Wait for the boot to complete (or not) */
-	while (count) {
-		boot_stat = mdio_clause45_read(efx, phy_id,
+	for (;;) {
+		boot_stat = mdio_clause45_read(efx, efx->mii.phy_id,
 					       MDIO_MMD_PCS,
 					       PCS_BOOT_STATUS_REG);
-		if (boot_stat & (1 << PCS_BOOT_COMPLETE_LBN))
-			break;
-		count--;
-		udelay(PCS_BOOT_POLL_DELAY);
-	}
+		if (boot_stat >= 0) {
+			EFX_LOG(efx, "PHY boot status = %#x\n", boot_stat);
+			switch (boot_stat &
+				((1 << PCS_BOOT_FATAL_ERROR_LBN) |
+				 (3 << PCS_BOOT_PROGRESS_LBN) |
+				 (1 << PCS_BOOT_DOWNLOAD_WAIT_LBN) |
+				 (1 << PCS_BOOT_CODE_STARTED_LBN))) {
+			case ((1 << PCS_BOOT_FATAL_ERROR_LBN) |
+			      (PCS_BOOT_PROGRESS_CHECKSUM <<
+			       PCS_BOOT_PROGRESS_LBN)):
+			case ((1 << PCS_BOOT_FATAL_ERROR_LBN) |
+			      (PCS_BOOT_PROGRESS_INIT <<
+			       PCS_BOOT_PROGRESS_LBN) |
+			      (1 << PCS_BOOT_DOWNLOAD_WAIT_LBN)):
+				return -EINVAL;
+			case ((PCS_BOOT_PROGRESS_WAIT_MDIO <<
+			       PCS_BOOT_PROGRESS_LBN) |
+			      (1 << PCS_BOOT_DOWNLOAD_WAIT_LBN)):
+				return (efx->phy_mode & PHY_MODE_SPECIAL) ?
+					0 : -EIO;
+			case ((PCS_BOOT_PROGRESS_JUMP <<
+			       PCS_BOOT_PROGRESS_LBN) |
+			      (1 << PCS_BOOT_CODE_STARTED_LBN)):
+			case ((PCS_BOOT_PROGRESS_JUMP <<
+			       PCS_BOOT_PROGRESS_LBN) |
+			      (1 << PCS_BOOT_DOWNLOAD_WAIT_LBN) |
+			      (1 << PCS_BOOT_CODE_STARTED_LBN)):
+				return (efx->phy_mode & PHY_MODE_SPECIAL) ?
+					-EIO : 0;
+			default:
+				if (boot_stat & (1 << PCS_BOOT_FATAL_ERROR_LBN))
+					return -EIO;
+				break;
+			}
+		}
 
-	if (!count) {
-		EFX_ERR(efx, "%s: PHY boot timed out. Last status "
-			"%x\n", __func__,
-			(boot_stat >> PCS_BOOT_PROGRESS_LBN) &
-			((1 << PCS_BOOT_PROGRESS_WIDTH) - 1));
-		return -ETIMEDOUT;
-	}
+		if (time_after_eq(jiffies, timeout))
+			return -ETIMEDOUT;
 
-	return 0;
+		msleep(50);
+	}
 }
 
 static int tenxpress_init(struct efx_nic *efx)
 {
 	int phy_id = efx->mii.phy_id;
 	int reg;
-	int rc;
 
 	if (efx->phy_type == PHY_TYPE_SFX7101) {
 		/* Enable 312.5 MHz clock */
@@ -286,10 +310,6 @@ static int tenxpress_init(struct efx_nic *efx)
 				       false);
 	}
 
-	rc = tenxpress_phy_check(efx);
-	if (rc < 0)
-		return rc;
-
 	/* Set the LEDs up as: Green = Link, Amber = Link/Act, Red = Off */
 	if (efx->phy_type == PHY_TYPE_SFX7101) {
 		mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_PMAPMD,
@@ -300,7 +320,7 @@ static int tenxpress_init(struct efx_nic *efx)
 				    PMA_PMD_LED_OVERR_REG, PMA_PMD_LED_DEFAULT);
 	}
 
-	return rc;
+	return 0;
 }
 
 static int tenxpress_phy_init(struct efx_nic *efx)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

