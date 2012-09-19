From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 08/11] sfc: Support variable-length response to
 MCDI GET_BOARD_CFG
Date: Wed, 19 Sep 2012 20:17:56 +0100
Message-ID: <1348082276.2636.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20224 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755985Ab2ISTR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:17:59 -0400
In-Reply-To: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |    6 ++++--
 drivers/net/ethernet/sfc/mtd.c  |    3 ++-
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 578e5f7..e855f4c 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -683,12 +683,14 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 	if (mac_address)
 		memcpy(mac_address, outbuf + offset, ETH_ALEN);
 	if (fw_subtype_list) {
+		/* Byte-swap and truncate or zero-pad as necessary */
 		offset = MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST;
 		for (i = 0;
-		     i < MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MINNUM;
+		     i < MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MAXNUM;
 		     i++) {
 			fw_subtype_list[i] =
-				le16_to_cpup((__le16 *)(outbuf + offset));
+				(offset + 2 <= outlen) ?
+				le16_to_cpup((__le16 *)(outbuf + offset)) : 0;
 			offset += 2;
 		}
 	}
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
