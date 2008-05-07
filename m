From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/9] Add phy_flash_cfg module parameter and implementation
Date: Wed, 7 May 2008 12:55:13 +0100
Message-ID: <20080507115513.GN2217@solarflare.com>
References: <20080507114121.GL2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:55732 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753869AbYEGLzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 07:55:40 -0400
Content-Disposition: inline
In-Reply-To: <20080507114121.GL2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 10Xpress PHY supports flash upgrades through MDIO, but needs to be
put in upgrade mode at power-up.  This adds a module parameter and other
logic to support that.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/boards.h      |    2 ++
 drivers/net/sfc/falcon_xmac.c |    4 ++++
 drivers/net/sfc/sfe4001.c     |   14 ++++++++++++++
 drivers/net/sfc/tenxpress.c   |   10 ++++++----
 4 files changed, 26 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/boards.h b/drivers/net/sfc/boards.h
index f56341d..695764d 100644
--- a/drivers/net/sfc/boards.h
+++ b/drivers/net/sfc/boards.h
@@ -22,5 +22,7 @@ enum efx_board_type {
 extern int efx_set_board_info(struct efx_nic *efx, u16 revision_info);
 extern int sfe4001_poweron(struct efx_nic *efx);
 extern void sfe4001_poweroff(struct efx_nic *efx);
+/* Are we putting the PHY into flash config mode */
+extern unsigned int sfe4001_phy_flash_cfg;
 
 #endif
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index aa7521b..d99efe2 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -69,6 +69,10 @@ static int falcon_reset_xmac(struct efx_nic *efx)
 		udelay(10);
 	}
 
+	/* This often fails when DSP is disabled, ignore it */
+	if (sfe4001_phy_flash_cfg != 0)
+		return 0;
+
 	EFX_ERR(efx, "timed out waiting for XMAC core reset\n");
 	return -ETIMEDOUT;
 }
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index 11fa9fb..725d1a5 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -130,6 +130,15 @@ void sfe4001_poweroff(struct efx_nic *efx)
 	(void) efx_i2c_read(i2c, MAX6647, RSL, &in, 1);
 }
 
+/* The P0_EN_3V3X line on SFE4001 boards (from A2 onward) is connected
+ * to the FLASH_CFG_1 input on the DSP.  We must keep it high at power-
+ * up to allow writing the flash (done through MDIO from userland).
+ */
+unsigned int sfe4001_phy_flash_cfg;
+module_param_named(phy_flash_cfg, sfe4001_phy_flash_cfg, uint, 0444);
+MODULE_PARM_DESC(phy_flash_cfg,
+		 "Force PHY to enter flash configuration mode");
+
 /* This board uses an I2C expander to provider power to the PHY, which needs to
  * be turned on before the PHY can be used.
  * Context: Process context, rtnl lock held
@@ -203,6 +212,8 @@ int sfe4001_poweron(struct efx_nic *efx)
 		out = 0xff & ~((1 << P0_EN_1V2_LBN) | (1 << P0_EN_2V5_LBN) |
 			       (1 << P0_EN_3V3X_LBN) | (1 << P0_EN_5V_LBN) |
 			       (1 << P0_X_TRST_LBN));
+		if (sfe4001_phy_flash_cfg)
+			out |= 1 << P0_EN_3V3X_LBN;
 
 		rc = efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
 		if (rc)
@@ -226,6 +237,9 @@ int sfe4001_poweron(struct efx_nic *efx)
 		if (in & (1 << P1_AFE_PWD_LBN))
 			goto done;
 
+		/* DSP doesn't look powered in flash config mode */
+		if (sfe4001_phy_flash_cfg)
+			goto done;
 	} while (++count < 20);
 
 	EFX_INFO(efx, "timed out waiting for power\n");
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index a2e9f79..d8df031 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -199,10 +199,12 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 
 	tenxpress_set_state(efx, TENXPRESS_STATUS_NORMAL);
 
-	rc = mdio_clause45_wait_reset_mmds(efx,
-					   TENXPRESS_REQUIRED_DEVS);
-	if (rc < 0)
-		goto fail;
+	if (!sfe4001_phy_flash_cfg) {
+		rc = mdio_clause45_wait_reset_mmds(efx,
+						   TENXPRESS_REQUIRED_DEVS);
+		if (rc < 0)
+			goto fail;
+	}
 
 	rc = mdio_clause45_check_mmds(efx, TENXPRESS_REQUIRED_DEVS, 0);
 	if (rc < 0)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
