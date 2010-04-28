From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 02/17] sfc: Consistently report short MCDI responses as EIO
Date: Wed, 28 Apr 2010 20:27:14 +0100
Message-ID: <1272482834.2549.18.camel@achroite.uk.solarflarecom.com>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:12355 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756754Ab0D1T1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:27:17 -0400
In-Reply-To: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some cases failing functions were returning 0 which is obviously wrong.
In other cases they were returning inappropriate error codes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mcdi.c     |   22 ++++++++++++++--------
 drivers/net/sfc/mcdi_phy.c |    6 +++---
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/drivers/net/sfc/mcdi.c b/drivers/net/sfc/mcdi.c
index c48669c..1344afa 100644
--- a/drivers/net/sfc/mcdi.c
+++ b/drivers/net/sfc/mcdi.c
@@ -613,7 +613,7 @@ int efx_mcdi_fwver(struct efx_nic *efx, u64 *version, u32 *build)
 	}
 
 	if (outlength < MC_CMD_GET_VERSION_V1_OUT_LEN) {
-		rc = -EMSGSIZE;
+		rc = -EIO;
 		goto fail;
 	}
 
@@ -647,8 +647,10 @@ int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 			  outbuf, sizeof(outbuf), &outlen);
 	if (rc)
 		goto fail;
-	if (outlen < MC_CMD_DRV_ATTACH_OUT_LEN)
+	if (outlen < MC_CMD_DRV_ATTACH_OUT_LEN) {
+		rc = -EIO;
 		goto fail;
+	}
 
 	if (was_attached != NULL)
 		*was_attached = MCDI_DWORD(outbuf, DRV_ATTACH_OUT_OLD_STATE);
@@ -676,7 +678,7 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 		goto fail;
 
 	if (outlen < MC_CMD_GET_BOARD_CFG_OUT_LEN) {
-		rc = -EMSGSIZE;
+		rc = -EIO;
 		goto fail;
 	}
 
@@ -738,8 +740,10 @@ int efx_mcdi_nvram_types(struct efx_nic *efx, u32 *nvram_types_out)
 			  outbuf, sizeof(outbuf), &outlen);
 	if (rc)
 		goto fail;
-	if (outlen < MC_CMD_NVRAM_TYPES_OUT_LEN)
+	if (outlen < MC_CMD_NVRAM_TYPES_OUT_LEN) {
+		rc = -EIO;
 		goto fail;
+	}
 
 	*nvram_types_out = MCDI_DWORD(outbuf, NVRAM_TYPES_OUT_TYPES);
 	return 0;
@@ -765,8 +769,10 @@ int efx_mcdi_nvram_info(struct efx_nic *efx, unsigned int type,
 			  outbuf, sizeof(outbuf), &outlen);
 	if (rc)
 		goto fail;
-	if (outlen < MC_CMD_NVRAM_INFO_OUT_LEN)
+	if (outlen < MC_CMD_NVRAM_INFO_OUT_LEN) {
+		rc = -EIO;
 		goto fail;
+	}
 
 	*size_out = MCDI_DWORD(outbuf, NVRAM_INFO_OUT_SIZE);
 	*erase_size_out = MCDI_DWORD(outbuf, NVRAM_INFO_OUT_ERASESIZE);
@@ -968,7 +974,7 @@ static int efx_mcdi_read_assertion(struct efx_nic *efx)
 	if (rc)
 		return rc;
 	if (outlen < MC_CMD_GET_ASSERTS_OUT_LEN)
-		return -EINVAL;
+		return -EIO;
 
 	/* Print out any recorded assertion state */
 	flags = MCDI_DWORD(outbuf, GET_ASSERTS_OUT_GLOBAL_FLAGS);
@@ -1086,7 +1092,7 @@ int efx_mcdi_wol_filter_set(struct efx_nic *efx, u32 type,
 		goto fail;
 
 	if (outlen < MC_CMD_WOL_FILTER_SET_OUT_LEN) {
-		rc = -EMSGSIZE;
+		rc = -EIO;
 		goto fail;
 	}
 
@@ -1121,7 +1127,7 @@ int efx_mcdi_wol_filter_get_magic(struct efx_nic *efx, int *id_out)
 		goto fail;
 
 	if (outlen < MC_CMD_WOL_FILTER_GET_OUT_LEN) {
-		rc = -EMSGSIZE;
+		rc = -EIO;
 		goto fail;
 	}
 
diff --git a/drivers/net/sfc/mcdi_phy.c b/drivers/net/sfc/mcdi_phy.c
index 2f23546..5d34487 100644
--- a/drivers/net/sfc/mcdi_phy.c
+++ b/drivers/net/sfc/mcdi_phy.c
@@ -48,7 +48,7 @@ efx_mcdi_get_phy_cfg(struct efx_nic *efx, struct efx_mcdi_phy_cfg *cfg)
 		goto fail;
 
 	if (outlen < MC_CMD_GET_PHY_CFG_OUT_LEN) {
-		rc = -EMSGSIZE;
+		rc = -EIO;
 		goto fail;
 	}
 
@@ -111,7 +111,7 @@ static int efx_mcdi_loopback_modes(struct efx_nic *efx, u64 *loopback_modes)
 		goto fail;
 
 	if (outlen < MC_CMD_GET_LOOPBACK_MODES_OUT_LEN) {
-		rc = -EMSGSIZE;
+		rc = -EIO;
 		goto fail;
 	}
 
@@ -587,7 +587,7 @@ static int efx_mcdi_phy_test_alive(struct efx_nic *efx)
 		return rc;
 
 	if (outlen < MC_CMD_GET_PHY_STATE_OUT_LEN)
-		return -EMSGSIZE;
+		return -EIO;
 	if (MCDI_DWORD(outbuf, GET_PHY_STATE_STATE) != MC_CMD_PHY_STATE_OK)
 		return -EINVAL;
 
-- 
1.6.2.5


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

