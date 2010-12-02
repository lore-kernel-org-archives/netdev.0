From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 07/17] sfc: Remove broken automatic fallback
 for invalid Falcon chip/board config
Date: Thu, 02 Dec 2010 23:47:01 +0000
Message-ID: <1291333621.3259.30.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13034 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932295Ab0LBXrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:47:04 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the Falcon board config is invalid, we cannot proceed - we do not
have a valid board type to pass to falcon_probe_board(), and if we
kluge that to work with an unknown board then other initialisation
code will crash.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   57 +++++++++++++++++++--------------------------
 1 files changed, 24 insertions(+), 33 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 267019b..b2c3381 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1235,7 +1235,6 @@ static void falcon_remove_spi_devices(struct efx_nic *efx)
 static int falcon_probe_nvconfig(struct efx_nic *efx)
 {
 	struct falcon_nvconfig *nvconfig;
-	int board_rev;
 	int rc;
 
 	nvconfig = kmalloc(sizeof(*nvconfig), GFP_KERNEL);
@@ -1243,37 +1242,25 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 		return -ENOMEM;
 
 	rc = falcon_read_nvram(efx, nvconfig);
-	if (rc == -EINVAL) {
-		netif_err(efx, probe, efx->net_dev,
-			  "NVRAM is invalid therefore using defaults\n");
-		efx->phy_type = PHY_TYPE_NONE;
-		efx->mdio.prtad = MDIO_PRTAD_NONE;
-		board_rev = 0;
-		rc = 0;
-	} else if (rc) {
+	if (rc)
 		goto fail1;
-	} else {
-		struct falcon_nvconfig_board_v2 *v2 = &nvconfig->board_v2;
-		struct falcon_nvconfig_board_v3 *v3 = &nvconfig->board_v3;
-
-		efx->phy_type = v2->port0_phy_type;
-		efx->mdio.prtad = v2->port0_phy_addr;
-		board_rev = le16_to_cpu(v2->board_revision);
-
-		if (le16_to_cpu(nvconfig->board_struct_ver) >= 3) {
-			rc = falcon_spi_device_init(
-				efx, &efx->spi_flash, FFE_AB_SPI_DEVICE_FLASH,
-				le32_to_cpu(v3->spi_device_type
-					    [FFE_AB_SPI_DEVICE_FLASH]));
-			if (rc)
-				goto fail2;
-			rc = falcon_spi_device_init(
-				efx, &efx->spi_eeprom, FFE_AB_SPI_DEVICE_EEPROM,
-				le32_to_cpu(v3->spi_device_type
-					    [FFE_AB_SPI_DEVICE_EEPROM]));
-			if (rc)
-				goto fail2;
-		}
+
+	efx->phy_type = nvconfig->board_v2.port0_phy_type;
+	efx->mdio.prtad = nvconfig->board_v2.port0_phy_addr;
+
+	if (le16_to_cpu(nvconfig->board_struct_ver) >= 3) {
+		rc = falcon_spi_device_init(
+			efx, &efx->spi_flash, FFE_AB_SPI_DEVICE_FLASH,
+			le32_to_cpu(nvconfig->board_v3
+				    .spi_device_type[FFE_AB_SPI_DEVICE_FLASH]));
+		if (rc)
+			goto fail2;
+		rc = falcon_spi_device_init(
+			efx, &efx->spi_eeprom, FFE_AB_SPI_DEVICE_EEPROM,
+			le32_to_cpu(nvconfig->board_v3
+				    .spi_device_type[FFE_AB_SPI_DEVICE_EEPROM]));
+		if (rc)
+			goto fail2;
 	}
 
 	/* Read the MAC addresses */
@@ -1282,7 +1269,8 @@ static int falcon_probe_nvconfig(struct efx_nic *efx)
 	netif_dbg(efx, probe, efx->net_dev, "PHY is %d phy_id %d\n",
 		  efx->phy_type, efx->mdio.prtad);
 
-	rc = falcon_probe_board(efx, board_rev);
+	rc = falcon_probe_board(efx,
+				le16_to_cpu(nvconfig->board_v2.board_revision));
 	if (rc)
 		goto fail2;
 
@@ -1419,8 +1407,11 @@ static int falcon_probe_nic(struct efx_nic *efx)
 
 	/* Read in the non-volatile configuration */
 	rc = falcon_probe_nvconfig(efx);
-	if (rc)
+	if (rc) {
+		if (rc == -EINVAL)
+			netif_err(efx, probe, efx->net_dev, "NVRAM is invalid\n");
 		goto fail5;
+	}
 
 	/* Initialise I2C adapter */
 	board = falcon_board(efx);
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

