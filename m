From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 09/16] sfc: use MCDI epoch flag to improve MC
 reboot detection in the driver
Date: Wed, 28 Aug 2013 16:19:54 +0100
Message-ID: <1377703194.2264.31.camel@bwh-desktop.uk.level5networks.com>
References: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17250 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753134Ab3H1PT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:19:57 -0400
In-Reply-To: <1377702837.2264.21.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

The Huntington MC will reject all MCDI requests after an MC reboot until it sees
one with the NOT_EPOCH flag clear.  This flag is set by default for all requests,
and then cleared on the first request after we detect that an MC reboot has
occurred.

The old MCDI_STATUS_DELAY_COUNT gave a timeout of 10ms, which was not long enough
for the driver to detect that a reboot had occurred based on the warm boot count
while calling efx_mcdi_poll_reboot() from the loop in efx_mcdi_ev_death().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 19 +++++++++++++------
 drivers/net/ethernet/sfc/mcdi.h |  2 ++
 2 files changed, 15 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 3810634..63121ad 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -26,9 +26,10 @@
 
 /* A reboot/assertion causes the MCDI status word to be set after the
  * command word is set or a REBOOT event is sent. If we notice a reboot
- * via these mechanisms then wait 10ms for the status word to be set. */
+ * via these mechanisms then wait 20ms for the status word to be set.
+ */
 #define MCDI_STATUS_DELAY_US		100
-#define MCDI_STATUS_DELAY_COUNT		100
+#define MCDI_STATUS_DELAY_COUNT		200
 #define MCDI_STATUS_SLEEP_MS						\
 	(MCDI_STATUS_DELAY_US * MCDI_STATUS_DELAY_COUNT / 1000)
 
@@ -56,6 +57,7 @@ int efx_mcdi_init(struct efx_nic *efx)
 	mcdi->mode = MCDI_MODE_POLL;
 
 	(void) efx_mcdi_poll_reboot(efx);
+	mcdi->new_epoch = true;
 
 	/* Recover from a failed assertion before probing */
 	return efx_mcdi_handle_assertion(efx);
@@ -85,24 +87,26 @@ static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
 
 	if (efx->type->mcdi_max_ver == 1) {
 		/* MCDI v1 */
-		EFX_POPULATE_DWORD_6(hdr[0],
+		EFX_POPULATE_DWORD_7(hdr[0],
 				     MCDI_HEADER_RESPONSE, 0,
 				     MCDI_HEADER_RESYNC, 1,
 				     MCDI_HEADER_CODE, cmd,
 				     MCDI_HEADER_DATALEN, inlen,
 				     MCDI_HEADER_SEQ, seqno,
-				     MCDI_HEADER_XFLAGS, xflags);
+				     MCDI_HEADER_XFLAGS, xflags,
+				     MCDI_HEADER_NOT_EPOCH, !mcdi->new_epoch);
 		hdr_len = 4;
 	} else {
 		/* MCDI v2 */
 		BUG_ON(inlen > MCDI_CTL_SDU_LEN_MAX_V2);
-		EFX_POPULATE_DWORD_6(hdr[0],
+		EFX_POPULATE_DWORD_7(hdr[0],
 				     MCDI_HEADER_RESPONSE, 0,
 				     MCDI_HEADER_RESYNC, 1,
 				     MCDI_HEADER_CODE, MC_CMD_V2_EXTN,
 				     MCDI_HEADER_DATALEN, 0,
 				     MCDI_HEADER_SEQ, seqno,
-				     MCDI_HEADER_XFLAGS, xflags);
+				     MCDI_HEADER_XFLAGS, xflags,
+				     MCDI_HEADER_NOT_EPOCH, !mcdi->new_epoch);
 		EFX_POPULATE_DWORD_2(hdr[1],
 				     MC_CMD_V2_EXTN_IN_EXTENDED_CMD, cmd,
 				     MC_CMD_V2_EXTN_IN_ACTUAL_LEN, inlen);
@@ -373,6 +377,7 @@ int efx_mcdi_rpc_start(struct efx_nic *efx, unsigned cmd,
 	spin_unlock_bh(&mcdi->iface_lock);
 
 	efx_mcdi_copyin(efx, cmd, inbuf, inlen);
+	mcdi->new_epoch = false;
 	return 0;
 }
 
@@ -435,6 +440,7 @@ int efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 		if (rc == -EIO || rc == -EINTR) {
 			msleep(MCDI_STATUS_SLEEP_MS);
 			efx_mcdi_poll_reboot(efx);
+			mcdi->new_epoch = true;
 		}
 	}
 
@@ -530,6 +536,7 @@ static void efx_mcdi_ev_death(struct efx_nic *efx, int rc)
 				break;
 			udelay(MCDI_STATUS_DELAY_US);
 		}
+		mcdi->new_epoch = true;
 	}
 
 	spin_unlock(&mcdi->iface_lock);
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 5f67ac3..303d9e8 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -36,6 +36,7 @@ enum efx_mcdi_mode {
  * @state: Request handling state. Waited for by @wq.
  * @mode: Poll for mcdi completion, or wait for an mcdi_event.
  * @wq: Wait queue for threads waiting for @state != %MCDI_STATE_RUNNING
+ * @new_epoch: Indicates start of day or start of MC reboot recovery
  * @iface_lock: Serialises access to all the following fields
  * @seqno: The next sequence number to use for mcdi requests.
  * @credits: Number of spurious MCDI completion events allowed before we
@@ -49,6 +50,7 @@ struct efx_mcdi_iface {
 	enum efx_mcdi_mode mode;
 	wait_queue_head_t wq;
 	spinlock_t iface_lock;
+	bool new_epoch;
 	unsigned int credits;
 	unsigned int seqno;
 	int resprc;


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
