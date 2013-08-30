From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 02/16] sfc: Refactor efx_mcdi_rpc_start() and
 efx_mcdi_copyin()
Date: Fri, 30 Aug 2013 04:38:31 +0100
Message-ID: <1377833911.2552.28.camel@deadeye.wl.decadent.org.uk>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:34935 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941Ab3H3Dif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 23:38:35 -0400
In-Reply-To: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Preparation for asynchronous MCDI requests.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c |   49 ++++++++++++++++++++++++---------------
 1 file changed, 30 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 63121ad..89bc194 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -70,8 +70,8 @@ void efx_mcdi_fini(struct efx_nic *efx)
 	kfree(efx->mcdi);
 }
 
-static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
-			    const efx_dword_t *inbuf, size_t inlen)
+static void efx_mcdi_send_request(struct efx_nic *efx, unsigned cmd,
+				  const efx_dword_t *inbuf, size_t inlen)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
 	efx_dword_t hdr[2];
@@ -80,6 +80,11 @@ static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
 
 	BUG_ON(atomic_read(&mcdi->state) == MCDI_STATE_QUIESCENT);
 
+	/* Serialise with efx_mcdi_ev_cpl() and efx_mcdi_ev_death() */
+	spin_lock_bh(&mcdi->iface_lock);
+	++mcdi->seqno;
+	spin_unlock_bh(&mcdi->iface_lock);
+
 	seqno = mcdi->seqno & SEQ_MASK;
 	xflags = 0;
 	if (mcdi->mode == MCDI_MODE_EVENTS)
@@ -114,6 +119,8 @@ static void efx_mcdi_copyin(struct efx_nic *efx, unsigned cmd,
 	}
 
 	efx->type->mcdi_request(efx, hdr, hdr_len, inbuf, inlen);
+
+	mcdi->new_epoch = false;
 }
 
 static int efx_mcdi_errno(unsigned int mcdi_err)
@@ -340,6 +347,22 @@ static void efx_mcdi_ev_cpl(struct efx_nic *efx, unsigned int seqno,
 		efx_mcdi_complete(mcdi);
 }
 
+static int
+efx_mcdi_check_supported(struct efx_nic *efx, unsigned int cmd, size_t inlen)
+{
+	if (efx->type->mcdi_max_ver < 0 ||
+	     (efx->type->mcdi_max_ver < 2 &&
+	      cmd > MC_CMD_CMD_SPACE_ESCAPE_7))
+		return -EINVAL;
+
+	if (inlen > MCDI_CTL_SDU_LEN_MAX_V2 ||
+	    (efx->type->mcdi_max_ver < 2 &&
+	     inlen > MCDI_CTL_SDU_LEN_MAX_V1))
+		return -EMSGSIZE;
+
+	return 0;
+}
+
 int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd,
 		 const efx_dword_t *inbuf, size_t inlen,
 		 efx_dword_t *outbuf, size_t outlen,
@@ -358,26 +381,14 @@ int efx_mcdi_rpc_start(struct efx_nic *efx, unsigned cmd,
 		       const efx_dword_t *inbuf, size_t inlen)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+	int rc;
 
-	if (efx->type->mcdi_max_ver < 0 ||
-	     (efx->type->mcdi_max_ver < 2 &&
-	      cmd > MC_CMD_CMD_SPACE_ESCAPE_7))
-		return -EINVAL;
-
-	if (inlen > MCDI_CTL_SDU_LEN_MAX_V2 ||
-	    (efx->type->mcdi_max_ver < 2 &&
-	     inlen > MCDI_CTL_SDU_LEN_MAX_V1))
-		return -EMSGSIZE;
+	rc = efx_mcdi_check_supported(efx, cmd, inlen);
+	if (rc)
+		return rc;
 
 	efx_mcdi_acquire(mcdi);
-
-	/* Serialise with efx_mcdi_ev_cpl() and efx_mcdi_ev_death() */
-	spin_lock_bh(&mcdi->iface_lock);
-	++mcdi->seqno;
-	spin_unlock_bh(&mcdi->iface_lock);
-
-	efx_mcdi_copyin(efx, cmd, inbuf, inlen);
-	mcdi->new_epoch = false;
+	efx_mcdi_send_request(efx, cmd, inbuf, inlen);
 	return 0;
 }
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
