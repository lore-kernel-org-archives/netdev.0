From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 5/7] sfc: Support variable-length response to MCDI
 GET_BOARD_CFG
Date: Wed, 18 Jul 2012 19:21:57 +0100
Message-ID: <1342635717.2617.57.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Andrew Jackson <ajackson@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51833 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752056Ab2GRSWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:22:01 -0400
In-Reply-To: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   18 +++++++++++++-----
 drivers/net/ethernet/sfc/mtd.c  |    3 ++-
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 294df4b..9f74ab6 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -660,8 +660,8 @@ fail:
 int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 			   u16 *fw_subtype_list, u32 *capabilities)
 {
-	uint8_t outbuf[MC_CMD_GET_BOARD_CFG_OUT_LENMIN];
-	size_t outlen;
+	uint8_t outbuf[MC_CMD_GET_BOARD_CFG_OUT_LENMAX];
+	size_t outlen, src_size, dst_size;
 	int port_num = efx_port_num(efx);
 	int offset;
 	int rc;
@@ -683,11 +683,19 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 		: MC_CMD_GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT0_OFST;
 	if (mac_address)
 		memcpy(mac_address, outbuf + offset, ETH_ALEN);
-	if (fw_subtype_list)
+	if (fw_subtype_list) {
+		/* Truncate or zero-pad as necessary */
+		src_size = (outlen -
+			    MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST);
+		dst_size = (MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MAXNUM *
+			    sizeof(*fw_subtype_list));
 		memcpy(fw_subtype_list,
 		       outbuf + MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST,
-		       MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MINNUM *
-		       sizeof(fw_subtype_list[0]));
+		       min(src_size, dst_size));
+		if (dst_size < src_size)
+			memset(fw_subtype_list + src_size, 0,
+			       dst_size - src_size);
+	}
 	if (capabilities) {
 		if (port_num)
 			*capabilities = MCDI_DWORD(outbuf,
diff --git a/drivers/net/ethernet/sfc/mtd.c b/drivers/net/ethernet/sfc/mtd.c
index 7581483..8f4604d 100644
--- a/drivers/net/ethernet/sfc/mtd.c
+++ b/drivers/net/ethernet/sfc/mtd.c
@@ -627,7 +627,8 @@ static int siena_mtd_get_fw_subtypes(struct efx_nic *efx,
 				     struct efx_mtd *efx_mtd)
 {
 	struct efx_mtd_partition *part;
-	uint16_t fw_subtype_list[MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MINNUM];
+	uint16_t fw_subtype_list[
+		MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MAXNUM];
 	int rc;
 
 	rc = efx_mcdi_get_board_cfg(efx, NULL, fw_subtype_list, NULL);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
