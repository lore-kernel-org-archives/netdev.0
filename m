From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/2] sfc: Use fixed-size buffers for MCDI NVRAM requests
Date: Mon, 25 Jan 2010 19:30:52 +0000
Message-ID: <1264447852.2793.4.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:47853 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754785Ab0AYTa4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 14:30:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The low-level MCDI code always uses 32-bit MMIO operations, and
callers must pad input and output buffers to multiples of 4 bytes.
The MCDI NVRAM functions are not doing this.  Also, their buffers are
declared as variable-length arrays with no explicit maximum length.

Switch to a fixed buffer size based on the chunk size used by the
MTD driver (which is a multiple of 4).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi.c |    7 ++++---
 drivers/net/sfc/mcdi.h |    1 +
 drivers/net/sfc/mtd.c  |    5 ++---
 3 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index 0d4eba7..9f035b9 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -804,7 +804,7 @@ int efx_mcdi_nvram_read(struct efx_nic *efx, unsigned int type,
 			loff_t offset, u8 *buffer, size_t length)
 {
 	u8 inbuf[MC_CMD_NVRAM_READ_IN_LEN];
-	u8 outbuf[MC_CMD_NVRAM_READ_OUT_LEN(length)];
+	u8 outbuf[MC_CMD_NVRAM_READ_OUT_LEN(EFX_MCDI_NVRAM_LEN_MAX)];
 	size_t outlen;
 	int rc;
 
@@ -828,7 +828,7 @@ fail:
 int efx_mcdi_nvram_write(struct efx_nic *efx, unsigned int type,
 			   loff_t offset, const u8 *buffer, size_t length)
 {
-	u8 inbuf[MC_CMD_NVRAM_WRITE_IN_LEN(length)];
+	u8 inbuf[MC_CMD_NVRAM_WRITE_IN_LEN(EFX_MCDI_NVRAM_LEN_MAX)];
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, NVRAM_WRITE_IN_TYPE, type);
@@ -838,7 +838,8 @@ int efx_mcdi_nvram_write(struct efx_nic *efx, unsigned int type,
 
 	BUILD_BUG_ON(MC_CMD_NVRAM_WRITE_OUT_LEN != 0);
 
-	rc = efx_mcdi_rpc(efx, MC_CMD_NVRAM_WRITE, inbuf, sizeof(inbuf),
+	rc = efx_mcdi_rpc(efx, MC_CMD_NVRAM_WRITE, inbuf,
+			  ALIGN(MC_CMD_NVRAM_WRITE_IN_LEN(length), 4),
 			  NULL, 0, NULL);
 	if (rc)
 		goto fail;
diff --git a/drivers/net/sfc/mcdi.h b/drivers/net/sfc/mcdi.h
index de91672..10ce98f 100644
--- a/drivers/net/sfc/mcdi.h
+++ b/drivers/net/sfc/mcdi.h
@@ -111,6 +111,7 @@ extern int efx_mcdi_nvram_read(struct efx_nic *efx, unsigned int type,
 extern int efx_mcdi_nvram_write(struct efx_nic *efx, unsigned int type,
 				loff_t offset, const u8 *buffer,
 				size_t length);
+#define EFX_MCDI_NVRAM_LEN_MAX 128
 extern int efx_mcdi_nvram_erase(struct efx_nic *efx, unsigned int type,
 				loff_t offset, size_t length);
 extern int efx_mcdi_nvram_update_finish(struct efx_nic *efx,
diff --git a/drivers/net/sfc/mtd.c b/drivers/net/sfc/mtd.c
index 3a46452..407bbad 100644
--- a/drivers/net/sfc/mtd.c
+++ b/drivers/net/sfc/mtd.c
@@ -23,7 +23,6 @@
 #include "mcdi_pcol.h"
 
 #define EFX_SPI_VERIFY_BUF_LEN 16
-#define EFX_MCDI_CHUNK_LEN 128
 
 struct efx_mtd_partition {
 	struct mtd_info mtd;
@@ -428,7 +427,7 @@ static int siena_mtd_read(struct mtd_info *mtd, loff_t start,
 	int rc = 0;
 
 	while (offset < end) {
-		chunk = min_t(size_t, end - offset, EFX_MCDI_CHUNK_LEN);
+		chunk = min_t(size_t, end - offset, EFX_MCDI_NVRAM_LEN_MAX);
 		rc = efx_mcdi_nvram_read(efx, part->mcdi.nvram_type, offset,
 					 buffer, chunk);
 		if (rc)
@@ -491,7 +490,7 @@ static int siena_mtd_write(struct mtd_info *mtd, loff_t start,
 	}
 
 	while (offset < end) {
-		chunk = min_t(size_t, end - offset, EFX_MCDI_CHUNK_LEN);
+		chunk = min_t(size_t, end - offset, EFX_MCDI_NVRAM_LEN_MAX);
 		rc = efx_mcdi_nvram_write(efx, part->mcdi.nvram_type, offset,
 					  buffer, chunk);
 		if (rc)
-- 
1.5.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

