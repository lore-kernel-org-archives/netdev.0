From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 4/6] sfc: call mcdi_reboot_detected() when MC reboots
 during an MCDI command
Date: Wed, 8 Feb 2017 16:51:33 +0000
Message-ID: <3d6ee549-3003-3426-7eb2-5b8aa288944c@solarflare.com>
References: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:35837 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751618AbdBHQze (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:55:34 -0500
In-Reply-To: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

This function wasn't being called in this particular case when the MC
 reboots. This caused resource reallocations to not be handled properly
 and often ended up disabling the interface.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 24b271b..fae647d 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -716,8 +716,11 @@ static int _efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned int cmd,
 		if (cmd == MC_CMD_REBOOT && rc == -EIO) {
 			/* Don't reset if MC_CMD_REBOOT returns EIO */
 		} else if (rc == -EIO || rc == -EINTR) {
-			netif_err(efx, hw, efx->net_dev, "MC fatal error %d\n",
-				  -rc);
+			netif_err(efx, hw, efx->net_dev, "MC reboot detected\n");
+			netif_dbg(efx, hw, efx->net_dev, "MC rebooted during command %d rc %d\n",
+				  cmd, -rc);
+			if (efx->type->mcdi_reboot_detected)
+				efx->type->mcdi_reboot_detected(efx);
 			efx_schedule_reset(efx, RESET_TYPE_MC_FAILURE);
 		} else if (proxy_handle && (rc == -EPROTO) &&
 			   efx_mcdi_get_proxy_handle(efx, hdr_len, data_len,
