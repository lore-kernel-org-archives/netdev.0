From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 08/17] sfc: Expose Falcon BootROM config
 through MTD, not ethtool
Date: Thu, 02 Dec 2010 23:47:10 +0000
Message-ID: <1291333630.3259.31.camel@bwh-desktop>
References: <1291333490.3259.23.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:13040 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932186Ab0LBXrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 18:47:13 -0500
In-Reply-To: <1291333490.3259.23.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool EEPROM interface is really meant for exposing chip
configuration, not BootROM configuration.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |   59 ----------------------------------
 drivers/net/sfc/mtd.c     |   77 +++++++++++++++++++++++++++++++-------------
 2 files changed, 54 insertions(+), 82 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index edb9d16..00fb674 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -17,7 +17,6 @@
 #include "efx.h"
 #include "filter.h"
 #include "nic.h"
-#include "spi.h"
 #include "mdio_10g.h"
 
 struct ethtool_string {
@@ -629,61 +628,6 @@ static u32 efx_ethtool_get_link(struct net_device *net_dev)
 	return efx->link_state.up;
 }
 
-static int efx_ethtool_get_eeprom_len(struct net_device *net_dev)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-	struct efx_spi_device *spi = efx->spi_eeprom;
-
-	if (!spi)
-		return 0;
-	return min(spi->size, EFX_EEPROM_BOOTCONFIG_END) -
-		min(spi->size, EFX_EEPROM_BOOTCONFIG_START);
-}
-
-static int efx_ethtool_get_eeprom(struct net_device *net_dev,
-				  struct ethtool_eeprom *eeprom, u8 *buf)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-	struct efx_spi_device *spi = efx->spi_eeprom;
-	size_t len;
-	int rc;
-
-	rc = mutex_lock_interruptible(&efx->spi_lock);
-	if (rc)
-		return rc;
-	rc = falcon_spi_read(efx, spi,
-			     eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
-			     eeprom->len, &len, buf);
-	mutex_unlock(&efx->spi_lock);
-
-	eeprom->magic = EFX_ETHTOOL_EEPROM_MAGIC;
-	eeprom->len = len;
-	return rc;
-}
-
-static int efx_ethtool_set_eeprom(struct net_device *net_dev,
-				  struct ethtool_eeprom *eeprom, u8 *buf)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-	struct efx_spi_device *spi = efx->spi_eeprom;
-	size_t len;
-	int rc;
-
-	if (eeprom->magic != EFX_ETHTOOL_EEPROM_MAGIC)
-		return -EINVAL;
-
-	rc = mutex_lock_interruptible(&efx->spi_lock);
-	if (rc)
-		return rc;
-	rc = falcon_spi_write(efx, spi,
-			      eeprom->offset + EFX_EEPROM_BOOTCONFIG_START,
-			      eeprom->len, &len, buf);
-	mutex_unlock(&efx->spi_lock);
-
-	eeprom->len = len;
-	return rc;
-}
-
 static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 				    struct ethtool_coalesce *coalesce)
 {
@@ -1116,9 +1060,6 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.set_msglevel		= efx_ethtool_set_msglevel,
 	.nway_reset		= efx_ethtool_nway_reset,
 	.get_link		= efx_ethtool_get_link,
-	.get_eeprom_len		= efx_ethtool_get_eeprom_len,
-	.get_eeprom		= efx_ethtool_get_eeprom,
-	.set_eeprom		= efx_ethtool_set_eeprom,
 	.get_coalesce		= efx_ethtool_get_coalesce,
 	.set_coalesce		= efx_ethtool_set_coalesce,
 	.get_ringparam		= efx_ethtool_get_ringparam,
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
index 02e54b4..d44c745 100644
--- a/drivers/net/sfc/mtd.c
+++ b/drivers/net/sfc/mtd.c
@@ -387,35 +387,66 @@ static struct efx_mtd_ops falcon_mtd_ops = {
 
 static int falcon_mtd_probe(struct efx_nic *efx)
 {
-	struct efx_spi_device *spi = efx->spi_flash;
+	struct efx_spi_device *spi;
 	struct efx_mtd *efx_mtd;
-	int rc;
+	int rc = -ENODEV;
 
 	ASSERT_RTNL();
 
-	if (!spi || spi->size <= FALCON_FLASH_BOOTCODE_START)
-		return -ENODEV;
-
-	efx_mtd = kzalloc(sizeof(*efx_mtd) + sizeof(efx_mtd->part[0]),
-			  GFP_KERNEL);
-	if (!efx_mtd)
-		return -ENOMEM;
-
-	efx_mtd->spi = spi;
-	efx_mtd->name = "flash";
-	efx_mtd->ops = &falcon_mtd_ops;
+	spi = efx->spi_flash;
+	if (spi && spi->size > FALCON_FLASH_BOOTCODE_START) {
+		efx_mtd = kzalloc(sizeof(*efx_mtd) + sizeof(efx_mtd->part[0]),
+				  GFP_KERNEL);
+		if (!efx_mtd)
+			return -ENOMEM;
+
+		efx_mtd->spi = spi;
+		efx_mtd->name = "flash";
+		efx_mtd->ops = &falcon_mtd_ops;
+
+		efx_mtd->n_parts = 1;
+		efx_mtd->part[0].mtd.type = MTD_NORFLASH;
+		efx_mtd->part[0].mtd.flags = MTD_CAP_NORFLASH;
+		efx_mtd->part[0].mtd.size = spi->size - FALCON_FLASH_BOOTCODE_START;
+		efx_mtd->part[0].mtd.erasesize = spi->erase_size;
+		efx_mtd->part[0].offset = FALCON_FLASH_BOOTCODE_START;
+		efx_mtd->part[0].type_name = "sfc_flash_bootrom";
+
+		rc = efx_mtd_probe_device(efx, efx_mtd);
+		if (rc) {
+			kfree(efx_mtd);
+			return rc;
+		}
+	}
 
-	efx_mtd->n_parts = 1;
-	efx_mtd->part[0].mtd.type = MTD_NORFLASH;
-	efx_mtd->part[0].mtd.flags = MTD_CAP_NORFLASH;
-	efx_mtd->part[0].mtd.size = spi->size - FALCON_FLASH_BOOTCODE_START;
-	efx_mtd->part[0].mtd.erasesize = spi->erase_size;
-	efx_mtd->part[0].offset = FALCON_FLASH_BOOTCODE_START;
-	efx_mtd->part[0].type_name = "sfc_flash_bootrom";
+	spi = efx->spi_eeprom;
+	if (spi && spi->size > EFX_EEPROM_BOOTCONFIG_START) {
+		efx_mtd = kzalloc(sizeof(*efx_mtd) + sizeof(efx_mtd->part[0]),
+				  GFP_KERNEL);
+		if (!efx_mtd)
+			return -ENOMEM;
+
+		efx_mtd->spi = spi;
+		efx_mtd->name = "EEPROM";
+		efx_mtd->ops = &falcon_mtd_ops;
+
+		efx_mtd->n_parts = 1;
+		efx_mtd->part[0].mtd.type = MTD_RAM;
+		efx_mtd->part[0].mtd.flags = MTD_CAP_RAM;
+		efx_mtd->part[0].mtd.size =
+			min(spi->size, EFX_EEPROM_BOOTCONFIG_END) -
+			EFX_EEPROM_BOOTCONFIG_START;
+		efx_mtd->part[0].mtd.erasesize = spi->erase_size;
+		efx_mtd->part[0].offset = EFX_EEPROM_BOOTCONFIG_START;
+		efx_mtd->part[0].type_name = "sfc_bootconfig";
+
+		rc = efx_mtd_probe_device(efx, efx_mtd);
+		if (rc) {
+			kfree(efx_mtd);
+			return rc;
+		}
+	}
 
-	rc = efx_mtd_probe_device(efx, efx_mtd);
-	if (rc)
-		kfree(efx_mtd);
 	return rc;
 }
 
-- 
1.7.3.2



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

