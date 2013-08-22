From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH RESEND net-next 10/16] sfc: Use proper macros to declare and
 access MCDI arrays
Date: Thu, 22 Aug 2013 20:28:08 +0100
Message-ID: <1377199688.1703.59.camel@bwh-desktop.uk.level5networks.com>
References: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29852 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846Ab3HVT2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 15:28:11 -0400
In-Reply-To: <1377199326.1703.49.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A few functions are using heap buffers; change them to use stack
buffers as we really don't need to resort to the heap for a 252
byte buffer in process context.

MC_CMD_MEMCPY is quite weird in that it can use inline data placed in
the request buffer after the array of records.  Thus there are two
variable-length arrays and we can't use the normal accessors for
the second.  So we have to use _MCDI_PTR() in efx_sriov_memcpy().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c        | 61 ++++++++++++++++------------------
 drivers/net/ethernet/sfc/mcdi.h        |  3 --
 drivers/net/ethernet/sfc/mcdi_mac.c    |  2 +-
 drivers/net/ethernet/sfc/mcdi_phy.c    | 25 ++++++--------
 drivers/net/ethernet/sfc/ptp.c         | 35 ++++++++++---------
 drivers/net/ethernet/sfc/siena_sriov.c | 53 ++++++++++++++---------------
 6 files changed, 85 insertions(+), 94 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index d65b562..d6d1ff1 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -668,7 +668,7 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 			   u16 *fw_subtype_list, u32 *capabilities)
 {
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_BOARD_CFG_OUT_LENMAX);
-	size_t outlen, offset, i;
+	size_t outlen, i;
 	int port_num = efx_port_num(efx);
 	int rc;
 
@@ -684,22 +684,21 @@ int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 		goto fail;
 	}
 
-	offset = (port_num)
-		? MC_CMD_GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT1_OFST
-		: MC_CMD_GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT0_OFST;
 	if (mac_address)
-		memcpy(mac_address, outbuf + offset, ETH_ALEN);
+		memcpy(mac_address,
+		       port_num ?
+		       MCDI_PTR(outbuf, GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT1) :
+		       MCDI_PTR(outbuf, GET_BOARD_CFG_OUT_MAC_ADDR_BASE_PORT0),
+		       ETH_ALEN);
 	if (fw_subtype_list) {
-		/* Byte-swap and truncate or zero-pad as necessary */
-		offset = MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_OFST;
 		for (i = 0;
-		     i < MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MAXNUM;
-		     i++) {
-			fw_subtype_list[i] =
-				(offset + 2 <= outlen) ?
-				le16_to_cpup((__le16 *)(outbuf + offset)) : 0;
-			offset += 2;
-		}
+		     i < MCDI_VAR_ARRAY_LEN(outlen,
+					    GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST);
+		     i++)
+			fw_subtype_list[i] = MCDI_ARRAY_WORD(
+				outbuf, GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST, i);
+		for (; i < MC_CMD_GET_BOARD_CFG_OUT_FW_SUBTYPE_LIST_MAXNUM; i++)
+			fw_subtype_list[i] = 0;
 	}
 	if (capabilities) {
 		if (port_num)
@@ -980,7 +979,7 @@ static int efx_mcdi_read_assertion(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_GET_ASSERTS_IN_LEN);
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_ASSERTS_OUT_LEN);
-	unsigned int flags, index, ofst;
+	unsigned int flags, index;
 	const char *reason;
 	size_t outlen;
 	int retry;
@@ -1022,12 +1021,13 @@ static int efx_mcdi_read_assertion(struct efx_nic *efx)
 		  MCDI_DWORD(outbuf, GET_ASSERTS_OUT_THREAD_OFFS));
 
 	/* Print out the registers */
-	ofst = MC_CMD_GET_ASSERTS_OUT_GP_REGS_OFFS_OFST;
-	for (index = 1; index < 32; index++) {
-		netif_err(efx, hw, efx->net_dev, "R%.2d (?): 0x%.8x\n", index,
-			MCDI_DWORD2(outbuf, ofst));
-		ofst += sizeof(efx_dword_t);
-	}
+	for (index = 0;
+	     index < MC_CMD_GET_ASSERTS_OUT_GP_REGS_OFFS_NUM;
+	     index++)
+		netif_err(efx, hw, efx->net_dev, "R%.2d (?): 0x%.8x\n",
+			  1 + index,
+			  MCDI_ARRAY_DWORD(outbuf, GET_ASSERTS_OUT_GP_REGS_OFFS,
+					   index));
 
 	return 0;
 }
@@ -1201,34 +1201,31 @@ int efx_mcdi_flush_rxqs(struct 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
