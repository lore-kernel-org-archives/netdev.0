From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 17/32] sfc: Support extraction of CAPABILITIES from
 GET_BOARD_CFG response.
Date: Fri, 27 Jan 2012 20:47:37 +0000
Message-ID: <1327697257.2503.24.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63667 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751471Ab2A0Urk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:47:40 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Slattery <mslattery@solarflare.com>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c  |   10 +++++++++-
 drivers/net/ethernet/sfc/mcdi.h  |    2 +-
 drivers/net/ethernet/sfc/mtd.c   |    2 +-
 drivers/net/ethernet/sfc/siena.c |    2 +-
 4 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index e5837a6..f1cad22 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -678,7 +678,7 @@ fail:
 }
 
 int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
-			   u16 *fw_subtype_list)
+			   u16 *fw_subtype_list, u32 *capabilities)
 {
 	uint8_t outbuf[MC_CMD_GET_BOARD_CFG_OUT_LENMIN];
 	size_t outlen;
@@ -708,6 +708,14 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 		       outbuf + MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST,
 		       MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MINNUM *
 		       sizeof(fw_subtype_list[0]));
+	if (capabilities) {
+		if (port_num)
+			*capabilities = MCDI_DWORD(outbuf,
+					GET_BOARD_CFG_OUT_CAPABILITIES_PORT1);
+		else
+			*capabilities = MCDI_DWORD(outbuf,
+					GET_BOARD_CFG_OUT_CAPABILITIES_PORT0);
+	}
 
 	return 0;
 
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index c59667b..4dd39fc 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -97,7 +97,7 @@ extern void efx_mcdi_print_fwver(struct efx_nic *efx, char *buf, size_t len);
 extern int efx_mcdi_drv_attach(struct efx_nic *efx, bool driver_operating,
 			       bool *was_attached_out);
 extern int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
-				  u16 *fw_subtype_list);
+				  u16 *fw_subtype_list, u32 *capabilities);
 extern int efx_mcdi_log_ctrl(struct efx_nic *efx, bool evq, bool uart,
 			     u32 dest_evq);
 extern int efx_mcdi_nvram_types(struct efx_nic *efx, u32 *nvram_types_out);
diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
index b702862..eff49da 100644
--- a/drivers/net/ethernet/sfc/mtd.c
+++ b/drivers/net/ethernet/sfc/mtd.c
@@ -631,7 +631,7 @@ static int siena_mtd_get_fw_subtypes(struct efx_nic *efx,
 	uint16_t fw_subtype_list[MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MINNUM];
 	int rc;
 
-	rc = efx_mcdi_get_board_cfg(efx, NULL, fw_subtype_list);
+	rc = efx_mcdi_get_board_cfg(efx, NULL, fw_subtype_list, NULL);
 	if (rc)
 		return rc;
 
diff --git a/drivers/net/ethernet/sfc/siena.c b/drivers/net/ethernet/sfc/siena.c
index d681f25..65cb5e4 100644
--- a/drivers/net/ethernet/sfc/siena.c
+++ b/drivers/net/ethernet/sfc/siena.c
@@ -216,7 +216,7 @@ static int siena_reset_hw(struct efx_nic *efx, enum reset_type method)
 
 static int siena_probe_nvconfig(struct efx_nic *efx)
 {
-	return efx_mcdi_get_board_cfg(efx, efx->net_dev->perm_addr, NULL);
+	return efx_mcdi_get_board_cfg(efx, efx->net_dev->perm_addr, NULL, NULL);
 }
 
 static int siena_probe_nic(struct efx_nic *efx)
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
