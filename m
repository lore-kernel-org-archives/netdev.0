From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 06/52] sfc: Reduce delays in SFE4001 initialisation
Date: Mon, 1 Sep 2008 12:45:48 +0100
Message-ID: <20080901114547.GZ7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:51967 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754703AbYIALpu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:45:50 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the board initialisation includes 2 delays of 1 second each.
Usually it is unnecessary to wait that long, so check before doing so.

Correct some of the comments and log messages while we're here.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/sfe4001.c |   57 +++++++++++++++++++++++++++-----------------
 1 files changed, 35 insertions(+), 22 deletions(-)

diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index b278495..f927281 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -145,7 +145,7 @@ MODULE_PARM_DESC(phy_flash_cfg,
 int sfe4001_init(struct efx_nic *efx)
 {
 	struct i2c_client *hwmon_client, *ioexp_client;
-	unsigned int count;
+	unsigned int i, j;
 	int rc;
 	u8 out;
 	efx_dword_t reg;
@@ -209,17 +209,24 @@ int sfe4001_init(struct efx_nic *efx)
 	if (rc)
 		goto fail_on;
 
-	/* Turn all power off then wait 1 sec. This ensures PHY is reset */
+	/* If PHY power is on, turn it all off and wait 1 second to
+	 * ensure a full reset.
+	 */
+	rc = i2c_smbus_read_byte_data(ioexp_client, P0_OUT);
+	if (rc < 0)
+		goto fail_on;
 	out = 0xff & ~((0 << P0_EN_1V2_LBN) | (0 << P0_EN_2V5_LBN) |
 		       (0 << P0_EN_3V3X_LBN) | (0 << P0_EN_5V_LBN) |
 		       (0 << P0_EN_1V0X_LBN));
-	rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
-	if (rc)
-		goto fail_on;
+	if (rc != out) {
+		EFX_INFO(efx, "power-cycling PHY\n");
+		rc = i2c_smbus_write_byte_data(ioexp_client, P0_OUT, out);
+		if (rc)
+			goto fail_on;
+		schedule_timeout_uninterruptible(HZ);
+	}
 
-	schedule_timeout_uninterruptible(HZ);
-	count = 0;
-	do {
+	for (i = 0; i < 20; ++i) {
 		/* Turn on 1.2V, 2.5V, 3.3V and 5V power rails */
 		out = 0xff & ~((1 << P0_EN_1V2_LBN) | (1 << P0_EN_2V5_LBN) |
 			       (1 << P0_EN_3V3X_LBN) | (1 << P0_EN_5V_LBN) |
@@ -238,23 +245,29 @@ int sfe4001_init(struct efx_nic *efx)
 		if (rc)
 			goto fail_on;
 
-		EFX_INFO(efx, "waiting for power (attempt %d)...\n", count);
-
-		schedule_timeout_uninterruptible(HZ);
-
-		/* Check DSP is powered */
-		rc = i2c_smbus_read_byte_data(ioexp_client, P1_IN);
-		if (rc < 0)
-			goto fail_on;
-		if (rc & (1 << P1_AFE_PWD_LBN))
-			goto done;
+		EFX_INFO(efx, "waiting for DSP boot (attempt %d)...\n", i);
 
-		/* DSP doesn't look powered in flash config mode */
-		if (sfe4001_phy_flash_cfg)
+		/* In flash config mode, DSP does not turn on AFE, so
+		 * just wait 1 second.
+		 */
+		if (sfe4001_phy_flash_cfg) {
+			schedule_timeout_uninterruptible(HZ);
 			goto done;
-	} while (++count < 20);
+		}
+
+		for (j = 0; j < 10; ++j) {
+			msleep(100);
+
+			/* Check DSP has asserted AFE power line */
+			rc = i2c_smbus_read_byte_data(ioexp_client, P1_IN);
+			if (rc < 0)
+				goto fail_on;
+			if (rc & (1 << P1_AFE_PWD_LBN))
+				goto done;
+		}
+	}
 
-	EFX_INFO(efx, "timed out waiting for power\n");
+	EFX_INFO(efx, "timed out waiting for DSP boot\n");
 	rc = -ETIMEDOUT;
 	goto fail_on;
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

