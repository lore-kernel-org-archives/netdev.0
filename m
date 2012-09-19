From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 04/11] sfc: Allow efx_mcdi_rpc to be called in two
 parts
Date: Wed, 19 Sep 2012 20:16:13 +0100
Message-ID: <1348082173.2636.19.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20167 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932282Ab2ISTQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 15:16:16 -0400
In-Reply-To: <1348081775.2636.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stuart Hodgson <smhodgson@solarflare.com>

For NIC/System time synchonisation efx_mcdi_rpc needs to be split in
efx_mcdi_rpc_start and efx_mcdi_rpc_finish operations.

Signed-off-by: Stuart Hodgson <smhodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   21 ++++++++++++++++++---
 drivers/net/ethernet/sfc/mcdi.h |    6 ++++++
 2 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index fc5e7bb..2707e86 100644
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
