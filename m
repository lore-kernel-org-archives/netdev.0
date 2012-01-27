From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/32] sfc: Make handling of MC reboot more reliable
Date: Fri, 27 Jan 2012 20:45:07 +0000
Message-ID: <1327697107.2503.17.camel@bwh-desktop>
References: <1327696858.2503.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:63554 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753701Ab2A0UpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 15:45:10 -0500
In-Reply-To: <1327696858.2503.7.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the MC reboots, either as part of a firmware upgrade or due to a
bug, it attempts to complete (with an error) any requests that were
outstanding before the reboot.  Since there is an inherent race
condition in checking this, it will also write to a status word in
shared memory.

If we look at each of these separately, we may detect each reboot
twice, resulting in a spurious command failure after a firmware
upgrade or frustrating recovery from a firmware bug.  Instead, if a
request completion indicates a reboot, we must poll and clear the
status word.

This bug was previously masked by use of an incorrect address for the
status word.  Fix that, using the definition now included in
mcdi_pcol.h.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   33 +++++++++++++++++++++++++++------
 1 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 7c405d1..f16145d 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -27,8 +27,6 @@
 #define CMD_NOTIFY_PORT1 4
 #define CMD_PDU_PORT0    0x008
 #define CMD_PDU_PORT1    0x108
-#define REBOOT_FLAG_PORT0 0x3f8
-#define REBOOT_FLAG_PORT1 0x3fc
 
 #define MCDI_RPC_TIMEOUT       10 /*seconds */
 
@@ -36,8 +34,16 @@
 	(efx_port_num(efx) ? CMD_PDU_PORT1 : CMD_PDU_PORT0)
 #define MCDI_DOORBELL(efx)						\
 	(efx_port_num(efx) ? CMD_NOTIFY_PORT1 : CMD_NOTIFY_PORT0)
-#define MCDI_REBOOT_FLAG(efx)						\
-	(efx_port_num(efx) ? REBOOT_FLAG_PORT1 : REBOOT_FLAG_PORT0)
+#define MCDI_STATUS(efx)						\
+	(efx_port_num(efx) ? MC_SMEM_P1_STATUS_OFST : MC_SMEM_P0_STATUS_OFST)
+
+/* A reboot/assertion causes the MCDI status word to be set after the
+ * command word is set or a REBOOT event is sent. If we notice a reboot
+ * via these mechanisms then wait 10ms for the status word to be set. */
+#define MCDI_STATUS_DELAY_US		100
+#define MCDI_STATUS_DELAY_COUNT		100
+#define MCDI_STATUS_SLEEP_MS						\
+	(MCDI_STATUS_DELAY_US * MCDI_STATUS_DELAY_COUNT / 1000)
 
 #define SEQ_MASK							\
 	EFX_MASK32(EFX_WIDTH(MCDI_HEADER_SEQ))
@@ -210,7 +216,7 @@ out:
 /* Test and clear MC-rebooted flag for this port/function */
 int efx_mcdi_poll_reboot(struct efx_nic *efx)
 {
-	unsigned int addr = FR_CZ_MC_TREG_SMEM + MCDI_REBOOT_FLAG(efx);
+	unsigned int addr = FR_CZ_MC_TREG_SMEM + MCDI_STATUS(efx);
 	efx_dword_t reg;
 	uint32_t value;
 
@@ -384,6 +390,11 @@ int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd,
 			netif_dbg(efx, hw, efx->net_dev,
 				  "MC command 0x%x inlen %d failed rc=%d\n",
 				  cmd, (int)inlen, -rc);
+
+		if (rc == -EIO || rc == -EINTR) {
+			msleep(MCDI_STATUS_SLEEP_MS);
+			efx_mcdi_poll_reboot(efx);
+		}
 	}
 
 	efx_mcdi_release(mcdi);
@@ -465,10 +476,20 @@ static void efx_mcdi_ev_death(struct efx_nic *efx, int rc)
 			mcdi->resplen = 0;
 			++mcdi->credits;
 		}
-	} else
+	} else {
+		int count;
+
 		/* Nobody was waiting for an MCDI request, so trigger a reset */
 		efx_schedule_reset(efx, RESET_TYPE_MC_FAILURE);
 
+		/* Consume the status word since efx_mcdi_rpc_finish() won't */
+		for (count = 0; count < MCDI_STATUS_DELAY_COUNT; ++count) {
+			if (efx_mcdi_poll_reboot(efx))
+				break;
+			udelay(MCDI_STATUS_DELAY_US);
+		}
+	}
+
 	spin_unlock(&mcdi->iface_lock);
 }
 
-- 
1.7.7.5



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
