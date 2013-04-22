From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] sfc: Fix naming of MTD partitions for FPGA bitfiles
Date: Mon, 22 Apr 2013 22:40:07 +0100
Message-ID: <1366666807.4016.18.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35401 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628Ab3DVVkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 17:40:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_mcdi_get_board_cfg() uses a buffer for the firmware response that
is only large enough to hold subtypes for the originally defined set
of NVRAM partitions.  Longer responses are truncated, and we may read
off the end of the buffer when copying out subtypes for additional
partitions.  In particular, this can result in the MTD partition for
an FPGA bitfile being named e.g. 'eth5 sfc_fpga:00' when it should be
'eth5 sfc_fpga:01'.  This means the firmware update tool (sfupdate)
can't tell which bitfile should be written to the partition.

Correct the response buffer size.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This fix is required for full support of boards with PTP hardware
clocks.  Please apply to net and queue it up for stable (only needed for
3.8.y and/or 3.9.y, depending on when this gets to Linus).

Ben.

 drivers/net/ethernet/sfc/mcdi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 0095ce9..97dd8f18 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -667,7 +667,7 @@ fail:
 int efx_mcdi_get_board_cfg(struct efx_nic *efx, u8 *mac_address,
 			   u16 *fw_subtype_list, u32 *capabilities)
 {
-	uint8_t outbuf[MC_CMD_GET_BOARD_CFG_OUT_LENMIN];
+	uint8_t outbuf[MC_CMD_GET_BOARD_CFG_OUT_LENMAX];
 	size_t outlen, offset, i;
 	int port_num = efx_port_num(efx);
 	int rc;
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
