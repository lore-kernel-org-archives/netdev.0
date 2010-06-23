From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/5] sfc: Log MTD errors using partition name,
 not just net device name
Date: Wed, 23 Jun 2010 22:29:24 +0100
Message-ID: <1277328564.2101.8.camel@achroite.uk.solarflarecom.com>
References: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:18505 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752922Ab0FWV31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 17:29:27 -0400
In-Reply-To: <1277328447.2101.7.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mtd.c |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
index f3ac7f3..02e54b4 100644
--- a/drivers/net/sfc/mtd.c
+++ b/drivers/net/sfc/mtd.c
@@ -15,7 +15,6 @@
 #include <linux/slab.h>
 #include <linux/rtnetlink.h>
 
-#define EFX_DRIVER_NAME "sfc_mtd"
 #include "net_driver.h"
 #include "spi.h"
 #include "efx.h"
@@ -71,8 +70,10 @@ static int siena_mtd_probe(struct efx_nic *efx);
 
 /* SPI utilities */
 
-static int efx_spi_slow_wait(struct efx_mtd *efx_mtd, bool uninterruptible)
+static int
+efx_spi_slow_wait(struct efx_mtd_partition *part, bool uninterruptible)
 {
+	struct efx_mtd *efx_mtd = part->mtd.priv;
 	const struct efx_spi_device *spi = efx_mtd->spi;
 	struct efx_nic *efx = efx_mtd->efx;
 	u8 status;
@@ -92,7 +93,7 @@ static int efx_spi_slow_wait(struct efx_mtd *efx_mtd, bool uninterruptible)
 		if (signal_pending(current))
 			return -EINTR;
 	}
-	EFX_ERR(efx, "timed out waiting for %s\n", efx_mtd->name);
+	pr_err("%s: timed out waiting for %s\n", part->name, efx_mtd->name);
 	return -ETIMEDOUT;
 }
 
@@ -131,8 +132,10 @@ efx_spi_unlock(struct efx_nic *efx, const struct efx_spi_device *spi)
 	return 0;
 }
 
-static int efx_spi_erase(struct efx_mtd *efx_mtd, loff_t start, size_t len)
+static int
+efx_spi_erase(struct efx_mtd_partition *part, loff_t start, size_t len)
 {
+	struct efx_mtd *efx_mtd = part->mtd.priv;
 	const struct efx_spi_device *spi = efx_mtd->spi;
 	struct efx_nic *efx = efx_mtd->efx;
 	unsigned pos, block_len;
@@ -156,7 +159,7 @@ static int efx_spi_erase(struct efx_mtd *efx_mtd, loff_t start, size_t len)
 			    NULL, 0);
 	if (rc)
 		return rc;
-	rc = efx_spi_slow_wait(efx_mtd, false);
+	rc = efx_spi_slow_wait(part, false);
 
 	/* Verify the entire region has been wiped */
 	memset(empty, 0xff, sizeof(empty));
@@ -198,13 +201,14 @@ static int efx_mtd_erase(struct mtd_info *mtd, struct erase_info *erase)
 
 static void efx_mtd_sync(struct mtd_info *mtd)
 {
+	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
 	struct efx_mtd *efx_mtd = mtd->priv;
-	struct efx_nic *efx = efx_mtd->efx;
 	int rc;
 
 	rc = efx_mtd->ops->sync(mtd);
 	if (rc)
-		EFX_ERR(efx, "%s sync failed (%d)\n", efx_mtd->name, rc);
+		pr_err("%s: %s sync failed (%d)\n",
+		       part->name, efx_mtd->name, rc);
 }
 
 static void efx_mtd_remove_partition(struct efx_mtd_partition *part)
@@ -338,7 +342,7 @@ static int falcon_mtd_erase(struct mtd_info *mtd, loff_t start, size_t len)
 	rc = mutex_lock_interruptible(&efx->spi_lock);
 	if (rc)
 		return rc;
-	rc = efx_spi_erase(efx_mtd, part->offset + start, len);
+	rc = efx_spi_erase(part, part->offset + start, len);
 	mutex_unlock(&efx->spi_lock);
 	return rc;
 }
@@ -363,12 +367,13 @@ static int falcon_mtd_write(struct mtd_info *mtd, loff_t start,
 
 static int falcon_mtd_sync(struct mtd_info *mtd)
 {
+	struct efx_mtd_partition *part = to_efx_mtd_partition(mtd);
 	struct efx_mtd *efx_mtd = mtd->priv;
 	struct efx_nic *efx = efx_mtd->efx;
 	int rc;
 
 	mutex_lock(&efx->spi_lock);
-	rc = efx_spi_slow_wait(efx_mtd, true);
+	rc = efx_spi_slow_wait(part, true);
 	mutex_unlock(&efx->spi_lock);
 	return rc;
 }
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

