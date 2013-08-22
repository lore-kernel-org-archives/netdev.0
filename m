From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 31/32] sfc: Fix race in completion handling
Date: Thu, 22 Aug 2013 14:10:12 +0100
Message-ID: <1377177012.1703.40.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56549 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729Ab3HVNKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 09:10:15 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When we poll for MCDI request completion, we don't hold the interface
lock while setting the response fields in struct efx_mcdi_iface.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 25 ++++++++++---------------
 1 file changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 2c5ee89..1c8bf81 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -112,16 +112,6 @@ static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
 	efx->type->mcdi_request(efx, hdr, hdr_len, inbuf, inlen);
 }
 
-static void
-efx_mcdi_copyout(struct efx_nic *efx, efx_dword_t *outbuf, size_t outlen)
-{
-	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
-
-	BUG_ON(atomic_read(&mcdi->state) == MCDI_STATE_QUIESCENT);
-
-	efx->type->mcdi_read_response(efx, outbuf, mcdi->resp_hdr_len, outlen);
-}
-
 static int efx_mcdi_errno(unsigned int mcdi_err)
 {
 	switch (mcdi_err) {
@@ -200,9 +190,11 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 	/* Check for a reboot atomically with respect to efx_mcdi_copyout() */
 	rc = efx_mcdi_poll_reboot(efx);
 	if (rc) {
+		spin_lock_bh(&mcdi->iface_lock);
 		mcdi->resprc = rc;
 		mcdi->resp_hdr_len = 0;
 		mcdi->resp_data_len = 0;
+		spin_unlock_bh(&mcdi->iface_lock);
 		return 0;
 	}
 
@@ -231,7 +223,9 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 			return -ETIMEDOUT;
 	}
 
+	spin_lock_bh(&mcdi->iface_lock);
 	efx_mcdi_read_response_header(efx);
+	spin_unlock_bh(&mcdi->iface_lock);
 
 	/* Return rc=0 like wait_event_timeout() */
 	return 0;
@@ -419,7 +413,7 @@ int efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 			  "MC command 0x%x inlen %d mode %d timed out\n",
 			  cmd, (int)inlen, mcdi->mode);
 	} else {
-		size_t resplen;
+		size_t hdr_len, data_len;
 
 		/* At the very least we need a memory barrier here to ensure
 		 * we pick up changes from efx_mcdi_ev_cpl(). Protect against
@@ -427,16 +421,17 @@ int efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 		 * acquiring the iface_lock. */
 		spin_lock_bh(&mcdi->iface_lock);
 		rc = mcdi->resprc;
-		resplen = mcdi->resp_data_len;
+		hdr_len = mcdi->resp_hdr_len;
+		data_len = mcdi->resp_data_len;
 		spin_unlock_bh(&mcdi->iface_lock);
 
 		BUG_ON(rc > 0);
 
 		if (rc == 0) {
-			efx_mcdi_copyout(efx, outbuf,
-					 min(outlen, mcdi->resp_data_len));
+			efx->type->mcdi_read_response(efx, outbuf, hdr_len,
+						      min(outlen, data_len));
 			if (outlen_actual != NULL)
-				*outlen_actual = resplen;
+				*outlen_actual = data_len;
 		} else if (cmd == MC_CMD_REBOOT && rc == -EIO)
 			; /* Don't reset if MC_CMD_REBOOT returns EIO */
 		else if (rc == -EIO || rc == -EINTR) {


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
