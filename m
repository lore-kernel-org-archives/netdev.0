From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 28/32] sfc: Translate MCDI error numbers received
 in events
Date: Thu, 22 Aug 2013 14:05:46 +0100
Message-ID: <1377176746.1703.35.camel@bwh-desktop.uk.level5networks.com>
References: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56403 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255Ab3HVNFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 09:05:50 -0400
In-Reply-To: <1377175392.1703.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we only translate error codes in efx_mcdi_poll(), but we
also need to do so in efx_mcdi_ev_cpl().

The reason we didn't notice before is that the MC firmware error codes
are mostly taken from Unix/Linux and no translation is necessary on
most architectures.  Make sure we notice any future failure by
changing the sign of resprc (matching the kernel convention) and BUG
if it's ever positive at command completion.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 62 +++++++++++++++++++++++------------------
 drivers/net/ethernet/sfc/mcdi.h |  4 +--
 2 files changed, 37 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index dffadb2..4f3301d 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -105,16 +105,39 @@ efx_mcdi_copyout(struct efx_nic *efx, efx_dword_t *outbuf, size_t outlen)
 	efx->type->mcdi_read_response(efx, outbuf, 4, outlen);
 }
 
+static int efx_mcdi_errno(unsigned int mcdi_err)
+{
+	switch (mcdi_err) {
+	case 0:
+		return 0;
+#define TRANSLATE_ERROR(name)					\
+	case MC_CMD_ERR_ ## name:				\
+		return -name;
+	TRANSLATE_ERROR(ENOENT);
+	TRANSLATE_ERROR(EINTR);
+	TRANSLATE_ERROR(EACCES);
+	TRANSLATE_ERROR(EBUSY);
+	TRANSLATE_ERROR(EINVAL);
+	TRANSLATE_ERROR(EDEADLK);
+	TRANSLATE_ERROR(ENOSYS);
+	TRANSLATE_ERROR(ETIME);
+#undef TRANSLATE_ERROR
+	default:
+		return -EIO;
+	}
+}
+
 static int efx_mcdi_poll(struct efx_nic *efx)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
 	unsigned long time, finish;
 	unsigned int respseq, respcmd, error;
-	unsigned int rc, spins;
+	unsigned int spins;
 	efx_dword_t reg;
+	int rc;
 
 	/* Check for a reboot atomically with respect to efx_mcdi_copyout() */
-	rc = -efx_mcdi_poll_reboot(efx);
+	rc = efx_mcdi_poll_reboot(efx);
 	if (rc)
 		goto out;
 
@@ -151,32 +174,15 @@ static int efx_mcdi_poll(struct efx_nic *efx)
 
 	if (error && mcdi->resplen == 0) {
 		netif_err(efx, hw, efx->net_dev, "MC rebooted\n");
-		rc = EIO;
+		rc = -EIO;
 	} else if ((respseq ^ mcdi->seqno) & SEQ_MASK) {
 		netif_err(efx, hw, efx->net_dev,
 			  "MC response mismatch tx seq 0x%x rx seq 0x%x\n",
 			  respseq, mcdi->seqno);
-		rc = EIO;
+		rc = -EIO;
 	} else if (error) {
 		efx->type->mcdi_read_response(efx, &reg, 4, 4);
-		switch (EFX_DWORD_FIELD(reg, EFX_DWORD_0)) {
-#define TRANSLATE_ERROR(name)					\
-		case MC_CMD_ERR_ ## name:			\
-			rc = name;				\
-			break
-			TRANSLATE_ERROR(ENOENT);
-			TRANSLATE_ERROR(EINTR);
-			TRANSLATE_ERROR(EACCES);
-			TRANSLATE_ERROR(EBUSY);
-			TRANSLATE_ERROR(EINVAL);
-			TRANSLATE_ERROR(EDEADLK);
-			TRANSLATE_ERROR(ENOSYS);
-			TRANSLATE_ERROR(ETIME);
-#undef TRANSLATE_ERROR
-		default:
-			rc = EIO;
-			break;
-		}
+		rc = efx_mcdi_errno(EFX_DWORD_FIELD(reg, EFX_DWORD_0));
 	} else
 		rc = 0;
 
@@ -271,7 +277,7 @@ static void efx_mcdi_release(struct efx_mcdi_iface *mcdi)
 }
 
 static void efx_mcdi_ev_cpl(struct efx_nic *efx, unsigned int seqno,
-			    unsigned int datalen, unsigned int errno)
+			    unsigned int datalen, unsigned int mcdi_err)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
 	bool wake = false;
@@ -287,7 +293,7 @@ static void efx_mcdi_ev_cpl(struct efx_nic *efx, unsigned int seqno,
 				  "MC response mismatch tx seq 0x%x rx "
 				  "seq 0x%x\n", seqno, mcdi->seqno);
 	} else {
-		mcdi->resprc = errno;
+		mcdi->resprc = efx_mcdi_errno(mcdi_err);
 		mcdi->resplen = datalen;
 
 		wake = true;
@@ -357,10 +363,12 @@ int efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 		 * a spurious efx_mcdi_ev_cpl() running concurrently by
 		 * acquiring the iface_lock. */
 		spin_lock_bh(&mcdi->iface_lock);
-		rc = -mcdi->resprc;
+		rc = mcdi->resprc;
 		resplen = mcdi->resplen;
 		spin_unlock_bh(&mcdi->iface_lock);
 
+		BUG_ON(rc > 0);
+
 		if (rc == 0) {
 			efx_mcdi_copyout(efx, outbuf,
 					 min(outlen, mcdi->resplen));
@@ -491,7 +499,7 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 	case MCDI_EVENT_CODE_BADSSERT:
 		netif_err(efx, hw, efx->net_dev,
 			  "MC watchdog or assertion failure at 0x%x\n", data);
-		efx_mcdi_ev_death(efx, EINTR);
+		efx_mcdi_ev_death(efx, -EINTR);
 		break;
 
 	case MCDI_EVENT_CODE_PMNOTICE:
@@ -517,7 +525,7 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 		break;
 	case MCDI_EVENT_CODE_REBOOT:
 		netif_info(efx, hw, efx->net_dev, "MC Reboot\n");
-		efx_mcdi_ev_death(efx, EIO);
+		efx_mcdi_ev_death(efx, -EIO);
 		break;
 	case MCDI_EVENT_CODE_MAC_STATS_DMA:
 		/* MAC stats are gather lazily.  We can ignore this. */
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 0bfed2a..9b536d0 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -42,7 +42,7 @@ enum efx_mcdi_mode {
  *	Serialised by @lock
  * @credits: Number of spurious MCDI completion events allowed before we
  *	trigger a fatal error. Protected by @lock
- * @resprc: Returned MCDI completion
+ * @resprc: Response error/success code (Linux numbering)
  * @resplen: Returned payload length
  */
 struct efx_mcdi_iface {
@@ -52,7 +52,7 @@ struct efx_mcdi_iface {
 	enum efx_mcdi_mode mode;
 	unsigned int credits;
 	unsigned int seqno;
-	unsigned int resprc;
+	int resprc;
 	size_t resplen;
 };
 


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
