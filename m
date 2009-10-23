From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 27/27] sfc: Rename 'xfp' file and functions to reflect
	reality
Date: Fri, 23 Oct 2009 19:33:42 +0100
Message-ID: <1256322822.2785.57.camel@achroite>
References: <1256322441.2785.3.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:9013 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046AbZJWSdk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 14:33:40 -0400
In-Reply-To: <1256322441.2785.3.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'XFP' driver is really a driver for the QT2022C2 and QT2025C PHYs,
covering both more and less than XFP.  Rename its functions and
constants to reflect reality and to reduce namespace pollution when
sfc is a built-in driver.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/Makefile                    |    2 +-
 drivers/net/sfc/falcon.c                    |    2 +-
 drivers/net/sfc/falcon_boards.c             |   26 ++++----
 drivers/net/sfc/phy.h                       |    6 +-
 drivers/net/sfc/{xfp_phy.c => qt202x_phy.c} |   80 +++++++++++++-------------
 5 files changed, 58 insertions(+), 58 deletions(-)
 rename drivers/net/sfc/{xfp_phy.c => qt202x_phy.c} (73%)

diff --git a/drivers/net/sfc/Makefile b/drivers/net/sfc/Makefile
index 9c98d06..7b52fe1 100644
--- a/drivers/net/sfc/Makefile
+++ b/drivers/net/sfc/Makefile
@@ -1,5 +1,5 @@
 sfc-y			+= efx.o falcon.o tx.o rx.o falcon_gmac.o \
-			   falcon_xmac.o selftest.o ethtool.o xfp_phy.o \
+			   falcon_xmac.o selftest.o ethtool.o qt202x_phy.o \
 			   mdio_10g.o tenxpress.o falcon_boards.o
 sfc-$(CONFIG_SFC_MTD)	+= mtd.o
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index d9ce21e..8776432 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2239,7 +2239,7 @@ int falcon_probe_port(struct efx_nic *efx)
 		break;
 	case PHY_TYPE_QT2022C2:
 	case PHY_TYPE_QT2025C:
-		efx->phy_op = &falcon_xfp_phy_ops;
+		efx->phy_op = &falcon_qt202x_phy_ops;
 		break;
 	default:
 		EFX_ERR(efx, "Unknown PHY type %d\n",
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index f65738b..99f7372 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -612,17 +612,17 @@ static void sfe4002_init_leds(struct efx_nic *efx)
 {
 	/* Set the TX and RX LEDs to reflect status and activity, and the
 	 * fault LED off */
-	xfp_set_led(efx, SFE4002_TX_LED,
-		    QUAKE_LED_TXLINK | QUAKE_LED_LINK_ACTSTAT);
-	xfp_set_led(efx, SFE4002_RX_LED,
-		    QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACTSTAT);
-	xfp_set_led(efx, SFE4002_FAULT_LED, QUAKE_LED_OFF);
+	falcon_qt202x_set_led(efx, SFE4002_TX_LED,
+			      QUAKE_LED_TXLINK | QUAKE_LED_LINK_ACTSTAT);
+	falcon_qt202x_set_led(efx, SFE4002_RX_LED,
+			      QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACTSTAT);
+	falcon_qt202x_set_led(efx, SFE4002_FAULT_LED, QUAKE_LED_OFF);
 }
 
 static void sfe4002_set_id_led(struct efx_nic *efx, bool state)
 {
-	xfp_set_led(efx, SFE4002_FAULT_LED, state ? QUAKE_LED_ON :
-			QUAKE_LED_OFF);
+	falcon_qt202x_set_led(efx, SFE4002_FAULT_LED, state ? QUAKE_LED_ON :
+			      QUAKE_LED_OFF);
 }
 
 static int sfe4002_check_hw(struct efx_nic *efx)
@@ -677,16 +677,16 @@ static struct i2c_board_info sfn4112f_hwmon_info = {
 
 static void sfn4112f_init_leds(struct efx_nic *efx)
 {
-	xfp_set_led(efx, SFN4112F_ACT_LED,
-		    QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACT);
-	xfp_set_led(efx, SFN4112F_LINK_LED,
-		    QUAKE_LED_RXLINK | QUAKE_LED_LINK_STAT);
+	falcon_qt202x_set_led(efx, SFN4112F_ACT_LED,
+			      QUAKE_LED_RXLINK | QUAKE_LED_LINK_ACT);
+	falcon_qt202x_set_led(efx, SFN4112F_LINK_LED,
+			      QUAKE_LED_RXLINK | QUAKE_LED_LINK_STAT);
 }
 
 static void sfn4112f_set_id_led(struct efx_nic *efx, bool state)
 {
-	xfp_set_led(efx, SFN4112F_LINK_LED,
-		    state ? QUAKE_LED_ON : QUAKE_LED_OFF);
+	falcon_qt202x_set_led(efx, SFN4112F_LINK_LED,
+			      state ? QUAKE_LED_ON : QUAKE_LED_OFF);
 }
 
 static int sfn4112f_check_hw(struct efx_nic *efx)
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index c1cff9c..b5150f3 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -23,9 +23,9 @@ extern void tenxpress_phy_blink(struct efx_nic *efx, bool blink);
 extern int sft9001_wait_boot(struct efx_nic *efx);
 
 /****************************************************************************
- * AMCC/Quake QT20xx PHYs
+ * AMCC/Quake QT202x PHYs
  */
-extern struct efx_phy_operations falcon_xfp_phy_ops;
+extern struct efx_phy_operations falcon_qt202x_phy_ops;
 
 /* These PHYs provide various H/W control states for LEDs */
 #define QUAKE_LED_LINK_INVAL	(0)
@@ -39,6 +39,6 @@ extern struct efx_phy_operations falcon_xfp_phy_ops;
 #define QUAKE_LED_TXLINK	(0)
 #define QUAKE_LED_RXLINK	(8)
 
-extern void xfp_set_led(struct efx_nic *p, int led, int state);
+extern void falcon_qt202x_set_led(struct efx_nic *p, int led, int state);
 
 #endif
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/qt202x_phy.c
similarity index 73%
rename from drivers/net/sfc/xfp_phy.c
rename to drivers/net/sfc/qt202x_phy.c
index e6b3d5e..560eb18 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -7,8 +7,7 @@
  * by the Free Software Foundation, incorporated herein by reference.
  */
 /*
- * Driver for SFP+ and XFP optical PHYs plus some support specific to the
- * AMCC QT20xx adapters; see www.amcc.com for details
+ * Driver for AMCC QT202x SFP+ and XFP adapters; see www.amcc.com for details
  */
 
 #include <linux/timer.h>
@@ -18,13 +17,13 @@
 #include "phy.h"
 #include "falcon.h"
 
-#define XFP_REQUIRED_DEVS (MDIO_DEVS_PCS |	\
-			   MDIO_DEVS_PMAPMD |	\
-			   MDIO_DEVS_PHYXS)
+#define QT202X_REQUIRED_DEVS (MDIO_DEVS_PCS |		\
+			      MDIO_DEVS_PMAPMD |	\
+			      MDIO_DEVS_PHYXS)
 
-#define XFP_LOOPBACKS ((1 << LOOPBACK_PCS) |		\
-		       (1 << LOOPBACK_PMAPMD) |		\
-		       (1 << LOOPBACK_NETWORK))
+#define QT202X_LOOPBACKS ((1 << LOOPBACK_PCS) |		\
+			  (1 << LOOPBACK_PMAPMD) |	\
+			  (1 << LOOPBACK_NETWORK))
 
 /****************************************************************************/
 /* Quake-specific MDIO registers */
@@ -45,18 +44,18 @@
 #define PCS_VEND1_REG	   	0xc000
 #define PCS_VEND1_LBTXD_LBN	5
 
-void xfp_set_led(struct efx_nic *p, int led, int mode)
+void falcon_qt202x_set_led(struct efx_nic *p, int led, int mode)
 {
 	int addr = MDIO_QUAKE_LED0_REG + led;
 	efx_mdio_write(p, MDIO_MMD_PMAPMD, addr, mode);
 }
 
-struct xfp_phy_data {
+struct qt202x_phy_data {
 	enum efx_phy_mode phy_mode;
 };
 
-#define XFP_MAX_RESET_TIME 500
-#define XFP_RESET_WAIT 10
+#define QT2022C2_MAX_RESET_TIME 500
+#define QT2022C2_RESET_WAIT 10
 
 static int qt2025c_wait_reset(struct efx_nic *efx)
 {
@@ -97,7 +96,7 @@ static int qt2025c_wait_reset(struct efx_nic *efx)
 	return 0;
 }
 
-static int xfp_reset_phy(struct efx_nic *efx)
+static int qt202x_reset_phy(struct efx_nic *efx)
 {
 	int rc;
 
@@ -111,8 +110,9 @@ static int xfp_reset_phy(struct efx_nic *efx)
 		/* Reset the PHYXS MMD. This is documented as doing
 		 * a complete soft reset. */
 		rc = efx_mdio_reset_mmd(efx, MDIO_MMD_PHYXS,
-					XFP_MAX_RESET_TIME / XFP_RESET_WAIT,
-					XFP_RESET_WAIT);
+					QT2022C2_MAX_RESET_TIME /
+					QT2022C2_RESET_WAIT,
+					QT2022C2_RESET_WAIT);
 		if (rc < 0)
 			goto fail;
 	}
@@ -122,7 +122,7 @@ static int xfp_reset_phy(struct efx_nic *efx)
 
 	/* Check that all the MMDs we expect are present and responding. We
 	 * expect faults on some if the link is down, but not on the PHY XS */
-	rc = efx_mdio_check_mmds(efx, XFP_REQUIRED_DEVS, MDIO_DEVS_PHYXS);
+	rc = efx_mdio_check_mmds(efx, QT202X_REQUIRED_DEVS, MDIO_DEVS_PHYXS);
 	if (rc < 0)
 		goto fail;
 
@@ -135,13 +135,13 @@ static int xfp_reset_phy(struct efx_nic *efx)
 	return rc;
 }
 
-static int xfp_phy_init(struct efx_nic *efx)
+static int qt202x_phy_init(struct efx_nic *efx)
 {
-	struct xfp_phy_data *phy_data;
+	struct qt202x_phy_data *phy_data;
 	u32 devid = efx_mdio_read_id(efx, MDIO_MMD_PHYXS);
 	int rc;
 
-	phy_data = kzalloc(sizeof(struct xfp_phy_data), GFP_KERNEL);
+	phy_data = kzalloc(sizeof(struct qt202x_phy_data), GFP_KERNEL);
 	if (!phy_data)
 		return -ENOMEM;
 	efx->phy_data = phy_data;
@@ -152,7 +152,7 @@ static int xfp_phy_init(struct efx_nic *efx)
 
 	phy_data->phy_mode = efx->phy_mode;
 
-	rc = xfp_reset_phy(efx);
+	rc = qt202x_reset_phy(efx);
 
 	EFX_INFO(efx, "PHY init %s.\n",
 		 rc ? "failed" : "successful");
@@ -167,28 +167,28 @@ static int xfp_phy_init(struct efx_nic *efx)
 	return rc;
 }
 
-static void xfp_phy_clear_interrupt(struct efx_nic *efx)
+static void qt202x_phy_clear_interrupt(struct efx_nic *efx)
 {
 	/* Read to clear link status alarm */
 	efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_STAT);
 }
 
-static int xfp_link_ok(struct efx_nic *efx)
+static int qt202x_link_ok(struct efx_nic *efx)
 {
-	return efx_mdio_links_ok(efx, XFP_REQUIRED_DEVS);
+	return efx_mdio_links_ok(efx, QT202X_REQUIRED_DEVS);
 }
 
-static void xfp_phy_poll(struct efx_nic *efx)
+static void qt202x_phy_poll(struct efx_nic *efx)
 {
-	int link_up = xfp_link_ok(efx);
+	int link_up = qt202x_link_ok(efx);
 	/* Simulate a PHY event if link state has changed */
 	if (link_up != efx->link_up)
 		falcon_sim_phy_event(efx);
 }
 
-static void xfp_phy_reconfigure(struct efx_nic *efx)
+static void qt202x_phy_reconfigure(struct efx_nic *efx)
 {
-	struct xfp_phy_data *phy_data = efx->phy_data;
+	struct qt202x_phy_data *phy_data = efx->phy_data;
 
 	if (efx->phy_type == PHY_TYPE_QT2025C) {
 		/* There are several different register bits which can
@@ -207,7 +207,7 @@ static void xfp_phy_reconfigure(struct efx_nic *efx)
 		/* Reset the PHY when moving from tx off to tx on */
 		if (!(efx->phy_mode & PHY_MODE_TX_DISABLED) &&
 		    (phy_data->phy_mode & PHY_MODE_TX_DISABLED))
-			xfp_reset_phy(efx);
+			qt202x_reset_phy(efx);
 
 		efx_mdio_transmit_disable(efx);
 	}
@@ -215,18 +215,18 @@ static void xfp_phy_reconfigure(struct efx_nic *efx)
 	efx_mdio_phy_reconfigure(efx);
 
 	phy_data->phy_mode = efx->phy_mode;
-	efx->link_up = xfp_link_ok(efx);
+	efx->link_up = qt202x_link_ok(efx);
 	efx->link_speed = 10000;
 	efx->link_fd = true;
 	efx->link_fc = efx->wanted_fc;
 }
 
-static void xfp_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+static void qt202x_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
 	mdio45_ethtool_gset(&efx->mdio, ecmd);
 }
 
-static void xfp_phy_fini(struct efx_nic *efx)
+static void qt202x_phy_fini(struct efx_nic *efx)
 {
 	/* Clobber the LED if it was blinking */
 	efx->board_info.blink(efx, false);
@@ -236,15 +236,15 @@ static void xfp_phy_fini(struct efx_nic *efx)
 	efx->phy_data = NULL;
 }
 
-struct efx_phy_operations falcon_xfp_phy_ops = {
+struct efx_phy_operations falcon_qt202x_phy_ops = {
 	.macs		 = EFX_XMAC,
-	.init            = xfp_phy_init,
-	.reconfigure     = xfp_phy_reconfigure,
-	.poll            = xfp_phy_poll,
-	.fini            = xfp_phy_fini,
-	.clear_interrupt = xfp_phy_clear_interrupt,
-	.get_settings    = xfp_phy_get_settings,
+	.init		 = qt202x_phy_init,
+	.reconfigure	 = qt202x_phy_reconfigure,
+	.poll	     	 = qt202x_phy_poll,
+	.fini	  	 = qt202x_phy_fini,
+	.clear_interrupt = qt202x_phy_clear_interrupt,
+	.get_settings	 = qt202x_phy_get_settings,
 	.set_settings	 = efx_mdio_set_settings,
-	.mmds            = XFP_REQUIRED_DEVS,
-	.loopbacks       = XFP_LOOPBACKS,
+	.mmds            = QT202X_REQUIRED_DEVS,
+	.loopbacks       = QT202X_LOOPBACKS,
 };

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

