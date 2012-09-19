From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 07/11] sfc: Convert firmware subtypes to native
 byte order in efx_mcdi_get_board_cfg()
Date: Wed, 19 Sep 2012 20:17:36 +0100
Message-ID: <1348082256.2636.22.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20214 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932495Ab2ISTRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:17:39 -0400
In-Reply-To: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On big-endian systems the MTD partition names currently have mangled
subtype numbers and are not recognised by the firmware update tool
(sfupdate).

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 294df4b..578e5f7 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -661,9 +661,8 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 			   u16 *fw_subtype_list, u32 *capabilities)
 {
 	uint8_t outbuf[MC_CMD_GET_BOARD_CFG_OUT_LENMIN];
-	size_t outlen;
+	size_t outlen, offset, i;
 	int port_num = efx_port_num(efx);
-	int offset;
 	int rc;
 
 	BUILD_BUG_ON(MC_CMD_GET_BOARD_CFG_IN_LEN != 0);
@@ -683,11 +682,16 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 		: MC_CMD_GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT0_OFST;
 	if (mac_address)
 		memcpy(mac_address, outbuf + offset, ETH_ALEN);
-	if (fw_subtype_list)
-		memcpy(fw_subtype_list,
-		       outbuf + MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST,
-		       MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MINNUM *
-		       sizeof(fw_subtype_list[0]));
+	if (fw_subtype_list) {
+		offset = MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST;
+		for (i = 0;
+		     i < MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MINNUM;
+		     i++) {
+			fw_subtype_list[i] =
+				le16_to_cpup((__le16 *)(outbuf + offset));
+			offset += 2;
+		}
+	}
 	if (capabilities) {
 		if (port_num)
 			*capabilities = MCDI_DWORD(outbuf,
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
