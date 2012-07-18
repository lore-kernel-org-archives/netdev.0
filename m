From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/7] sfc: Allow efx_mcdi_rpc to be called in two
 parts
Date: Wed, 18 Jul 2012 19:20:30 +0100
Message-ID: <1342635630.2617.55.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Andrew Jackson <ajackson@solarflare.com>,
	Richard Cochran <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51796 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751800Ab2GRSUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:20:34 -0400
In-Reply-To: <1342635392.2617.52.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For NIC/System time synchonisation efx_mcdi_rpc needs to be split in
efx_mcdi_rpc_start and efx_mcdi_rpc_finish operations.

Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   26 +++++++++++++++++++++++---
 drivers/net/ethernet/sfc/mcdi.h |    6 ++++++
 2 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index fc5e7bb..294df4b 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -320,14 +320,20 @@ static void efx_mcdi_ev_cpl(struct efx_nic *efx, unsigned int seqno,
 		efx_mcdi_complete(mcdi);
 }
 
-/* Issue the given command by writing the data into the shared memory PDU,
- * ring the doorbell and wait for completion. Copyout the result. */
 int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd,
 		 const u8 *inbuf, size_t inlen, u8 *outbuf, size_t outlen,
 		 size_t *outlen_actual)
 {
+	efx_mcdi_rpc_start(efx, cmd, inbuf, inlen);
+	return efx_mcdi_rpc_finish(efx, cmd, inlen,
+				   outbuf, outlen, outlen_actual);
+}
+
+void efx_mcdi_rpc_start(struct efx_nic *efx, unsigned cmd, const u8 *inbuf,
+			size_t inlen)
+{
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
-	int rc;
+
 	BUG_ON(efx_nic_rev(efx) < EFX_REV_SIENA_A0);
 
 	efx_mcdi_acquire(mcdi);
@@ -338,6 +344,15 @@ int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd,
 	spin_unlock_bh(&mcdi->iface_lock);
 
 	efx_mcdi_copyin(efx, cmd, inbuf, inlen);
+}
+
+int efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
+			u8 *outbuf, size_t outlen, size_t *outlen_actual)
+{
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+	int rc;
+
+	BUG_ON(efx_nic_rev(efx) < EFX_REV_SIENA_A0);
 
 	if (mcdi->mode == MCDI_MODE_POLL)
 		rc = efx_mcdi_poll(efx);
@@ -563,6 +578,11 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 	case MCDI_EVENT_CODE_FLR:
 		efx_sriov_flr(efx, MCDI_EVENT_FIELD(*event, FLR_VF));
 		break;
+	case MCDI_EVENT_CODE_PTP_RX:
+	case MCDI_EVENT_CODE_PTP_FAULT:
+	case MCDI_EVENT_CODE_PTP_PPS:
+		efx_ptp_event(efx, event);
+		break;
 
 	default:
 		netif_err(efx, hw, efx->net_dev, "Unknown MCDI event 0x%x\n",
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 0bdf3e3..dc25caa 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -71,6 +71,12 @@ extern int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd, const u8 *inbuf,
 			size_t inlen, u8 *outbuf, size_t outlen,
 			size_t *outlen_actual);
 
+extern void efx_mcdi_rpc_start(struct efx_nic *efx, unsigned cmd,
+			       const u8 *inbuf, size_t inlen);
+extern int efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
+			       u8 *outbuf, size_t outlen,
+			       size_t *outlen_actual);
+
 extern int efx_mcdi_poll_reboot(struct efx_nic *efx);
 extern void efx_mcdi_mode_poll(struct efx_nic *efx);
 extern void efx_mcdi_mode_event(struct efx_nic *efx);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
