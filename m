From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/33] sfc: Work around unreliable strap pins
Date: Fri, 12 Dec 2008 12:51:28 +0000
Message-ID: <20081212125127.GH10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:33434 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756929AbYLLMvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:51:32 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SFC4000 has strap pins indicating the presence of SPI flash and/or
EEPROM.  These pins are also used for GPIO, and in some cases they may
be read wrongly at reset.  However, on production boards it must boot
from one or the other device, so we can assume the boot device is
present and read the board config from there.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |  110 +++++++++++++++++----------------------------
 1 files changed, 42 insertions(+), 68 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 4b2ec12..9563c13 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -70,6 +70,20 @@ static int disable_dma_stats;
 #define RX_DC_ENTRIES_ORDER 2
 #define RX_DC_BASE 0x100000
 
+static const unsigned int
+/* "Large" EEPROM device: Atmel AT25640 or similar
+ * 8 KB, 16-bit address, 32 B write block */
+large_eeprom_type = ((13 << SPI_DEV_TYPE_SIZE_LBN)
+		     | (2 << SPI_DEV_TYPE_ADDR_LEN_LBN)
+		     | (5 << SPI_DEV_TYPE_BLOCK_SIZE_LBN)),
+/* Default flash device: Atmel AT25F1024
+ * 128 KB, 24-bit address, 32 KB erase block, 256 B write block */
+default_flash_type = ((17 << SPI_DEV_TYPE_SIZE_LBN)
+		      | (3 << SPI_DEV_TYPE_ADDR_LEN_LBN)
+		      | (0x52 << SPI_DEV_TYPE_ERASE_CMD_LBN)
+		      | (15 << SPI_DEV_TYPE_ERASE_SIZE_LBN)
+		      | (8 << SPI_DEV_TYPE_BLOCK_SIZE_LBN));
+
 /* RX FIFO XOFF watermark
  *
  * When the amount of the RX FIFO increases used increases past this
@@ -2281,12 +2295,15 @@ int falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 	__le16 *word, *limit;
 	u32 csum;
 
+	spi = efx->spi_flash ? efx->spi_flash : efx->spi_eeprom;
+	if (!spi)
+		return -EINVAL;
+
 	region = kmalloc(FALCON_NVCONFIG_END, GFP_KERNEL);
 	if (!region)
 		return -ENOMEM;
 	nvconfig = region + NVCONFIG_OFFSET;
 
-	spi = efx->spi_flash ? efx->spi_flash : efx->spi_eeprom;
 	mutex_lock(&efx->spi_lock);
 	rc = falcon_spi_read(spi, 0, FALCON_NVCONFIG_END, NULL, region);
 	mutex_unlock(&efx->spi_lock);
@@ -2724,80 +2741,37 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 static void falcon_probe_spi_devices(struct efx_nic *efx)
 {
 	efx_oword_t nic_stat, gpio_ctl, ee_vpd_cfg;
-	bool has_flash, has_eeprom, boot_is_external;
+	int boot_dev;
 
 	falcon_read(efx, &gpio_ctl, GPIO_CTL_REG_KER);
 	falcon_read(efx, &nic_stat, NIC_STAT_REG);
 	falcon_read(efx, &ee_vpd_cfg, EE_VPD_CFG_REG_KER);
 
-	has_flash = EFX_OWORD_FIELD(nic_stat, SF_PRST);
-	has_eeprom = EFX_OWORD_FIELD(nic_stat, EE_PRST);
-	boot_is_external = EFX_OWORD_FIELD(gpio_ctl, BOOTED_USING_NVDEVICE);
-
-	if (has_flash) {
-		/* Default flash SPI device: Atmel AT25F1024
-		 * 128 KB, 24-bit address, 32 KB erase block,
-		 * 256 B write block
-		 */
-		u32 flash_device_type =
-			(17 << SPI_DEV_TYPE_SIZE_LBN)
-			| (3 << SPI_DEV_TYPE_ADDR_LEN_LBN)
-			| (0x52 << SPI_DEV_TYPE_ERASE_CMD_LBN)
-			| (15 << SPI_DEV_TYPE_ERASE_SIZE_LBN)
-			| (8 << SPI_DEV_TYPE_BLOCK_SIZE_LBN);
-
-		falcon_spi_device_init(efx, &efx->spi_flash,
-				       EE_SPI_FLASH, flash_device_type);
-
-		if (!boot_is_external) {
-			/* Disable VPD and set clock dividers to safe
-			 * values for initial programming.
-			 */
-			EFX_LOG(efx, "Booted from internal ASIC settings;"
-				" setting SPI config\n");
-			EFX_POPULATE_OWORD_3(ee_vpd_cfg, EE_VPD_EN, 0,
-					     /* 125 MHz / 7 ~= 20 MHz */
-					     EE_SF_CLOCK_DIV, 7,
-					     /* 125 MHz / 63 ~= 2 MHz */
-					     EE_EE_CLOCK_DIV, 63);
-			falcon_write(efx, &ee_vpd_cfg, EE_VPD_CFG_REG_KER);
-		}
-	}
-
-	if (has_eeprom) {
-		u32 eeprom_device_type;
-
-		/* If it has no flash, it must have a large EEPROM
-		 * for chip config; otherwise check whether 9-bit
-		 * addressing is used for VPD configuration
-		 */
-		if (has_flash &&
-		    (!boot_is_external ||
-		     EFX_OWORD_FIELD(ee_vpd_cfg, EE_VPD_EN_AD9_MODE))) {
-			/* Default SPI device: Atmel AT25040 or similar
-			 * 512 B, 9-bit address, 8 B write block
-			 */
-			eeprom_device_type =
-				(9 << SPI_DEV_TYPE_SIZE_LBN)
-				| (1 << SPI_DEV_TYPE_ADDR_LEN_LBN)
-				| (3 << SPI_DEV_TYPE_BLOCK_SIZE_LBN);
-		} else {
-			/* "Large" SPI device: Atmel AT25640 or similar
-			 * 8 KB, 16-bit address, 32 B write block
-			 */
-			eeprom_device_type =
-				(13 << SPI_DEV_TYPE_SIZE_LBN)
-				| (2 << SPI_DEV_TYPE_ADDR_LEN_LBN)
-				| (5 << SPI_DEV_TYPE_BLOCK_SIZE_LBN);
-		}
-
-		falcon_spi_device_init(efx, &efx->spi_eeprom,
-				       EE_SPI_EEPROM, eeprom_device_type);
-	}
-
-	EFX_LOG(efx, "flash is %s, EEPROM is %s\n",
-		(has_flash ? "present" : "absent"),
-		(has_eeprom ? "present" : "absent"));
+	if (EFX_OWORD_FIELD(gpio_ctl, BOOTED_USING_NVDEVICE)) {
+		boot_dev = (EFX_OWORD_FIELD(nic_stat, SF_PRST) ?
+			    EE_SPI_FLASH : EE_SPI_EEPROM);
+		EFX_LOG(efx, "Booted from %s\n",
+			boot_dev == EE_SPI_FLASH ? "flash" : "EEPROM");
+	} else {
+		/* Disable VPD and set clock dividers to safe
+		 * values for initial programming. */
+		boot_dev = -1;
+		EFX_LOG(efx, "Booted from internal ASIC settings;"
+			" setting SPI config\n");
+		EFX_POPULATE_OWORD_3(ee_vpd_cfg, EE_VPD_EN, 0,
+				     /* 125 MHz / 7 ~= 20 MHz */
+				     EE_SF_CLOCK_DIV, 7,
+				     /* 125 MHz / 63 ~= 2 MHz */
+				     EE_EE_CLOCK_DIV, 63);
+		falcon_write(efx, &ee_vpd_cfg, EE_VPD_CFG_REG_KER);
+	}
+
+	if (boot_dev == EE_SPI_FLASH)
+		falcon_spi_device_init(efx, &efx->spi_flash, EE_SPI_FLASH,
+				       default_flash_type);
+	if (boot_dev == EE_SPI_EEPROM)
+		falcon_spi_device_init(efx, &efx->spi_eeprom, EE_SPI_EEPROM,
+				       large_eeprom_type);
 }
 
 int falcon_probe_nic(struct efx_nic *efx)
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
