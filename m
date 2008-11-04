From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/6] sfc: Clean up non-volatile memory partitioning
Date: Tue, 4 Nov 2008 20:33:11 +0000
Message-ID: <20081104203310.GY7331@solarflare.com>
References: <20081104203117.GW7331@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:58993 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753925AbYKDUdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 15:33:16 -0500
Content-Disposition: inline
In-Reply-To: <20081104203117.GW7331@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move flash and EEPROM partition boundary constants into spi.h and rename
them to be consistent.

Add a comment on the partitioning.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c       |   11 ++++-------
 drivers/net/sfc/falcon.c        |    6 +++---
 drivers/net/sfc/falcon_hwdefs.h |    1 -
 drivers/net/sfc/spi.h           |   17 +++++++++++++++++
 4 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index cd0d087..df0579e 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -172,10 +172,7 @@ static struct efx_ethtool_stat efx_ethtool_stats[] = {
 /* Number of ethtool statistics */
 #define EFX_ETHTOOL_NUM_STATS ARRAY_SIZE(efx_ethtool_stats)
 
-/* EEPROM range with gPXE configuration */
 #define EFX_ETHTOOL_EEPROM_MAGIC 0xEFAB
-#define EFX_ETHTOOL_EEPROM_MIN 0x800U
-#define EFX_ETHTOOL_EEPROM_MAX 0x1800U
 
 /**************************************************************************
  *
@@ -545,8 +542,8 @@ static int efx_ethtool_get_eeprom_len(struct net_device *net_dev)
 
 	if (!spi)
 		return 0;
-	return min(spi->size, EFX_ETHTOOL_EEPROM_MAX) -
-		min(spi->size, EFX_ETHTOOL_EEPROM_MIN);
+	return min(spi->size, EFX_EEPROM_BOOTCONFIG_END) -
+		min(spi->size, EFX_EEPROM_BOOTCONFIG_START);
 }
 
 static int efx_ethtool_get_eeprom(struct net_device *net_dev,
@@ -557,7 +554,7 @@ static int efx_ethtool_get_eeprom(struct net_device *net_dev,
 	size_t len;
 	int rc;
 
-	rc = falcon_spi_read(spi, eeprom->offset + EFX_ETHTOOL_EEPROM_MIN,
+	rc = falcon_spi_read(spi, eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
 			     eeprom->len, &len, buf);
 	eeprom->magic = EFX_ETHTOOL_EEPROM_MAGIC;
 	eeprom->len = len;
@@ -575,7 +572,7 @@ static int efx_ethtool_set_eeprom(struct net_device *net_dev,
 	if (eeprom->magic != EFX_ETHTOOL_EEPROM_MAGIC)
 		return -EINVAL;
 
-	rc = falcon_spi_write(spi, eeprom->offset + EFX_ETHTOOL_EEPROM_MIN,
+	rc = falcon_spi_write(spi, eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
 			      eeprom->len, &len, buf);
 	eeprom->len = len;
 	return rc;
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 31ed1f4..3f74cef 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2253,13 +2253,13 @@ int falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 	__le16 *word, *limit;
 	u32 csum;
 
-	region = kmalloc(NVCONFIG_END, GFP_KERNEL);
+	region = kmalloc(FALCON_NVCONFIG_END, GFP_KERNEL);
 	if (!region)
 		return -ENOMEM;
 	nvconfig = region + NVCONFIG_OFFSET;
 
 	spi = efx->spi_flash ? efx->spi_flash : efx->spi_eeprom;
-	rc = falcon_spi_read(spi, 0, NVCONFIG_END, NULL, region);
+	rc = falcon_spi_read(spi, 0, FALCON_NVCONFIG_END, NULL, region);
 	if (rc) {
 		EFX_ERR(efx, "Failed to read %s\n",
 			efx->spi_flash ? "flash" : "EEPROM");
@@ -2283,7 +2283,7 @@ int falcon_read_nvram(struct efx_nic *efx, struct falcon_nvconfig *nvconfig_out)
 		limit = (__le16 *) (nvconfig + 1);
 	} else {
 		word = region;
-		limit = region + NVCONFIG_END;
+		limit = region + FALCON_NVCONFIG_END;
 	}
 	for (csum = 0; word < limit; ++word)
 		csum += le16_to_cpu(*word);
diff --git a/drivers/net/sfc/falcon_hwdefs.h b/drivers/net/sfc/falcon_hwdefs.h
index 5d584b0..040e70e 100644
--- a/drivers/net/sfc/falcon_hwdefs.h
+++ b/drivers/net/sfc/falcon_hwdefs.h
@@ -1150,7 +1150,6 @@ struct falcon_nvconfig_board_v3 {
 	(((type) >> EFX_LOW_BIT(field)) & EFX_MASK32(EFX_WIDTH(field)))
 
 #define NVCONFIG_OFFSET 0x300
-#define NVCONFIG_END 0x400
 
 #define NVCONFIG_BOARD_MAGIC_NUM 0xFA1C
 struct falcon_nvconfig {
diff --git a/drivers/net/sfc/spi.h b/drivers/net/sfc/spi.h
index feef619..b73f86c 100644
--- a/drivers/net/sfc/spi.h
+++ b/drivers/net/sfc/spi.h
@@ -63,4 +63,21 @@ int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
 int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
 		     size_t len, size_t *retlen, const u8 *buffer);
 
+/*
+ * SFC4000 flash is partitioned into:
+ *     0-0x400       chip and board config (see falcon_hwdefs.h)
+ *     0x400-0x8000  unused (or may contain VPD if EEPROM not present)
+ *     0x8000-end    boot code (mapped to PCI expansion ROM)
+ * SFC4000 small EEPROM (size < 0x400) is used for VPD only.
+ * SFC4000 large EEPROM (size >= 0x400) is partitioned into:
+ *     0-0x400       chip and board config
+ *     configurable  VPD
+ *     0x800-0x1800  boot config
+ * Aside from the chip and board config, all of these are optional and may
+ * be absent or truncated depending on the devices used.
+ */
+#define FALCON_NVCONFIG_END 0x400U
+#define EFX_EEPROM_BOOTCONFIG_START 0x800U
+#define EFX_EEPROM_BOOTCONFIG_END 0x1800U
+
 #endif /* EFX_SPI_H */
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
