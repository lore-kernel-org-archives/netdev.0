From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/33] sfc: Clean up waits for flash/EEPROM operations
Date: Fri, 12 Dec 2008 12:51:01 +0000
Message-ID: <20081212125100.GG10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:55850 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756880AbYLLMvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:51:05 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make falcon_spi_wait() ignore the write timer - it is only relevant to
write commands, it only works for the device that contains VPD, and it
might not be initialised properly at all.

Rename falcon_spi_fast_wait() to falcon_spi_wait_write(), reflecting
its use, and make it wait up to 10 ms (not 1 ms) since buffered writes
to EEPROM may take this long to complete.

Make both wait functions sleep instead of busy-waiting.

Replace wait for command completion at top of falcon_spi_cmd() with a
single poll; no command should be running when the function starts.

Correct some comments.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c |   58 +++++++++++++++++++++++++++++----------------
 drivers/net/sfc/mtd.c    |    2 +-
 drivers/net/sfc/spi.h    |    2 +-
 3 files changed, 39 insertions(+), 23 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 3af361a..4b2ec12 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1618,24 +1618,37 @@ void falcon_fini_interrupt(struct efx_nic *efx)
 
 #define FALCON_SPI_MAX_LEN sizeof(efx_oword_t)
 
+static int falcon_spi_poll(struct efx_nic *efx)
+{
+	efx_oword_t reg;
+	falcon_read(efx, &reg, EE_SPI_HCMD_REG_KER);
+	return EFX_OWORD_FIELD(reg, EE_SPI_HCMD_CMD_EN) ? -EBUSY : 0;
+}
+
 /* Wait for SPI command completion */
 static int falcon_spi_wait(struct efx_nic *efx)
 {
-	unsigned long timeout = jiffies + DIV_ROUND_UP(HZ, 10);
-	efx_oword_t reg;
-	bool cmd_en, timer_active;
+	/* Most commands will finish quickly, so we start polling at
+	 * very short intervals.  Sometimes the command may have to
+	 * wait for VPD or expansion ROM access outside of our
+	 * control, so we allow up to 100 ms. */
+	unsigned long timeout = jiffies + 1 + DIV_ROUND_UP(HZ, 10);
+	int i;
+
+	for (i = 0; i < 10; i++) {
+		if (!falcon_spi_poll(efx))
+			return 0;
+		udelay(10);
+	}
 
 	for (;;) {
-		falcon_read(efx, &reg, EE_SPI_HCMD_REG_KER);
-		cmd_en = EFX_OWORD_FIELD(reg, EE_SPI_HCMD_CMD_EN);
-		timer_active = EFX_OWORD_FIELD(reg, EE_WR_TIMER_ACTIVE);
-		if (!cmd_en && !timer_active)
+		if (!falcon_spi_poll(efx))
 			return 0;
 		if (time_after_eq(jiffies, timeout)) {
 			EFX_ERR(efx, "timed out waiting for SPI\n");
 			return -ETIMEDOUT;
 		}
-		cpu_relax();
+		schedule_timeout_uninterruptible(1);
 	}
 }
 
@@ -1654,8 +1667,8 @@ int falcon_spi_cmd(const struct efx_spi_device *spi,
 		return -EINVAL;
 	BUG_ON(!mutex_is_locked(&efx->spi_lock));
 
-	/* Check SPI not currently being accessed */
-	rc = falcon_spi_wait(efx);
+	/* Check that previous command is not still running */
+	rc = falcon_spi_poll(efx);
 	if (rc)
 		return rc;
 
@@ -1711,26 +1724,29 @@ efx_spi_munge_command(const struct efx_spi_device *spi,
 	return command | (((address >> 8) & spi->munge_address) << 3);
 }
 
-int falcon_spi_fast_wait(const struct efx_spi_device *spi)
+/* Wait up to 10 ms for buffered write completion */
+int falcon_spi_wait_write(const struct efx_spi_device *spi)
 {
+	struct efx_nic *efx = spi->efx;
+	unsigned long timeout = jiffies + 1 + DIV_ROUND_UP(HZ, 100);
 	u8 status;
-	int i, rc;
-
-	/* Wait up to 1000us for flash/EEPROM to finish a fast operation. */
-	for (i = 0; i < 50; i++) {
-		udelay(20);
+	int rc;
 
+	for (;;) {
 		rc = falcon_spi_cmd(spi, SPI_RDSR, -1, NULL,
 				    &status, sizeof(status));
 		if (rc)
 			return rc;
 		if (!(status & SPI_STATUS_NRDY))
 			return 0;
+		if (time_after_eq(jiffies, timeout)) {
+			EFX_ERR(efx, "SPI write timeout on device %d"
+				" last status=0x%02x\n",
+				spi->device_id, status);
+			return -ETIMEDOUT;
+		}
+		schedule_timeout_uninterruptible(1);
 	}
-	EFX_ERR(spi->efx,
-		"timed out waiting for device %d last status=0x%02x\n",
-		spi->device_id, status);
-	return -ETIMEDOUT;
 }
 
 int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
@@ -1784,7 +1800,7 @@ int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
 		if (rc)
 			break;
 
-		rc = falcon_spi_fast_wait(spi);
+		rc = falcon_spi_wait_write(spi);
 		if (rc)
 			break;
 
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
index a1e6c28..665cafb 100644
--- a/drivers/net/sfc/mtd.c
+++ b/drivers/net/sfc/mtd.c
@@ -76,7 +76,7 @@ static int efx_spi_unlock(const struct efx_spi_device *spi)
 	rc = falcon_spi_cmd(spi, SPI_WRSR, -1, &status, NULL, sizeof(status));
 	if (rc)
 		return rc;
-	rc = falcon_spi_fast_wait(spi);
+	rc = falcon_spi_wait_write(spi);
 	if (rc)
 		return rc;
 
diff --git a/drivers/net/sfc/spi.h b/drivers/net/sfc/spi.h
index c4aca13..4e45d54 100644
--- a/drivers/net/sfc/spi.h
+++ b/drivers/net/sfc/spi.h
@@ -69,7 +69,7 @@ struct efx_spi_device {
 
 int falcon_spi_cmd(const struct efx_spi_device *spi, unsigned int command,
 		   int address, const void* in, void *out, unsigned int len);
-int falcon_spi_fast_wait(const struct efx_spi_device *spi);
+int falcon_spi_wait_write(const struct efx_spi_device *spi);
 int falcon_spi_read(const struct efx_spi_device *spi, loff_t start,
 		    size_t len, size_t *retlen, u8 *buffer);
 int falcon_spi_write(const struct efx_spi_device *spi, loff_t start,
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
