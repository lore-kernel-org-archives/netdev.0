From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next 1/5] sfc: Retry MCDI after NO_EVB_PORT error on a VF
Date: Fri, 18 Dec 2015 17:08:48 +0000
Message-ID: <56743DA0.1040900@solarflare.com>
References: <56743D6A.5020605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:42737 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932467AbbLRRI6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 12:08:58 -0500
In-Reply-To: <56743D6A.5020605@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After reboot the vswitch configuration from the PF may not be
complete before the VF attempts to restore filters. In that
case we see NO_EVB_PORT errors from the MC. Retry up to a time
limit or until a different result is seen.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 99 ++++++++++++++++++++++++++++++++++-------
 drivers/net/ethernet/sfc/mcdi.h |  1 +
 2 files changed, 85 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 41fb6b6..2509ca9 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -315,6 +315,7 @@ static void efx_mcdi_read_response_header(struct efx_nic *efx)
 	}
 #endif
 
+	mcdi->resprc_raw = 0;
 	if (error && mcdi->resp_data_len == 0) {
 		netif_err(efx, hw, efx->net_dev, "MC rebooted\n");
 		mcdi->resprc = -EIO;
@@ -325,8 +326,8 @@ static void efx_mcdi_read_response_header(struct efx_nic *efx)
 		mcdi->resprc = -EIO;
 	} else if (error) {
 		efx->type->mcdi_read_response(efx, &hdr, mcdi->resp_hdr_len, 4);
-		mcdi->resprc =
-			efx_mcdi_errno(EFX_DWORD_FIELD(hdr, EFX_DWORD_0));
+		mcdi->resprc_raw = EFX_DWORD_FIELD(hdr, EFX_DWORD_0);
+		mcdi->resprc = efx_mcdi_errno(mcdi->resprc_raw);
 	} else {
 		mcdi->resprc = 0;
 	}
@@ -623,7 +624,8 @@ efx_mcdi_check_supported(struct efx_nic *efx, unsigned int cmd, size_t inlen)
 
 static int _efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 				efx_dword_t *outbuf, size_t outlen,
-				size_t *outlen_actual, bool quiet)
+				size_t *outlen_actual, bool quiet,
+				int *raw_rc)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
 	MCDI_DECLARE_BUF_ERR(errbuf);
@@ -669,6 +671,8 @@ static int _efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 		 * acquiring the iface_lock. */
 		spin_lock_bh(&mcdi->iface_lock);
 		rc = mcdi->resprc;
+		if (raw_rc)
+			*raw_rc = mcdi->resprc_raw;
 		hdr_len = mcdi->resp_hdr_len;
 		data_len = mcdi->resp_data_len;
 		err_len = min(sizeof(errbuf), data_len);
@@ -708,27 +712,92 @@ static int _efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 static int _efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd,
 			 const efx_dword_t *inbuf, size_t inlen,
 			 efx_dword_t *outbuf, size_t outlen,
-			 size_t *outlen_actual, bool quiet)
+			 size_t *outlen_actual, bool quiet, int *raw_rc)
 {
 	int rc;
 
 	rc = efx_mcdi_rpc_start(efx, cmd, inbuf, inlen);
-	if (rc) {
-		if (outlen_actual)
-			*outlen_actual = 0;
+	if (rc)
 		return rc;
-	}
+
 	return _efx_mcdi_rpc_finish(efx, cmd, inlen, outbuf, outlen,
-				    outlen_actual, quiet);
+				    outlen_actual, quiet, raw_rc);
 }
 
+static int _efx_mcdi_rpc_evb_retry(struct efx_nic *efx, unsigned cmd,
+				   const efx_dword_t *inbuf, size_t inlen,
+				   efx_dword_t *outbuf, size_t outlen,
+				   size_t *outlen_actual, bool quiet)
+{
+	int raw_rc = 0;
+	int rc;
+
+	rc = _efx_mcdi_rpc(efx, cmd, inbuf, inlen,
+			   outbuf, outlen, outlen_actual, true, &raw_rc);
+
+	if ((rc == -EPROTO) && (raw_rc == MC_CMD_ERR_NO_EVB_PORT) &&
+	    efx->type->is_vf) {
+		/* If the EVB port isn't available within a VF this may
+		 * mean the PF is still bringing the switch up. We should
+		 * retry our request shortly.
+		 */
+		unsigned long abort_time = jiffies + MCDI_RPC_TIMEOUT;
+		unsigned int delay_us = 10000;
+
+		netif_dbg(efx, hw, efx->net_dev,
+			  "%s: NO_EVB_PORT; will retry request\n",
+			  __func__);
+
+		do {
+			usleep_range(delay_us, delay_us + 10000);
+			rc = _efx_mcdi_rpc(efx, cmd, inbuf, inlen,
+					   outbuf, outlen, outlen_actual,
+					   true, &raw_rc);
+			if (delay_us < 100000)
+				delay_us <<= 1;
+		} while ((rc == -EPROTO) &&
+			 (raw_rc == MC_CMD_ERR_NO_EVB_PORT) &&
+			 time_before(jiffies, abort_time));
+	}
+
+	if (rc && !quiet && !(cmd == MC_CMD_REBOOT && rc == -EIO))
+		efx_mcdi_display_error(efx, cmd, inlen,
+				       outbuf, outlen, rc);
+
+	return rc;
+}
+
+/**
+ * efx_mcdi_rpc - Issue an MCDI command and wait for completion
+ * @efx: NIC through which to issue the command
+ * @cmd: Command type number
+ * @inbuf: Command parameters
+ * @inlen: Length of command parameters, in bytes.  Must be a multiple
+ *	of 4 and no greater than %MCDI_CTL_SDU_LEN_MAX_V1.
+ * @outbuf: Response buffer.  May be %NULL if @outlen is 0.
+ * @outlen: Length of response buffer, in bytes.  If the actual
+ *	response is longer than @outlen & ~3, it will be truncated
+ *	to that length.
+ * @outlen_actual: Pointer through which to return the actual response
+ *	length.  May be %NULL if this is not needed.
+ *
+ * This function may sleep and therefore must be called in an appropriate
+ * context.
+ *
+ * Return: A negative error code, or zero if successful.  The error
+ *	code may come from the MCDI response or may indicate a failure
+ *	to communicate with the MC.  In the former case, the response
+ *	will still be copied to @outbuf and *@outlen_actual will be
+ *	set accordingly.  In the latter case, *@outlen_actual will be
+ *	set to zero.
+ */
 int efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd,
 		 const efx_dword_t *inbuf, size_t inlen,
 		 efx_dword_t *outbuf, size_t outlen,
 		 size_t *outlen_actual)
 {
-	return _efx_mcdi_rpc(efx, cmd, inbuf, inlen, outbuf, outlen,
-			     outlen_actual, false);
+	return _efx_mcdi_rpc_evb_retry(efx, cmd, inbuf, inlen, outbuf, outlen,
+				       outlen_actual, false);
 }
 
 /* Normally, on receiving an error code in the MCDI response,
@@ -744,8 +813,8 @@ int efx_mcdi_rpc_quiet(struct efx_nic *efx, unsigned cmd,
 		       efx_dword_t *outbuf, size_t outlen,
 		       size_t *outlen_actual)
 {
-	return _efx_mcdi_rpc(efx, cmd, inbuf, inlen, outbuf, outlen,
-			     outlen_actual, true);
+	return _efx_mcdi_rpc_evb_retry(efx, cmd, inbuf, inlen, outbuf, outlen,
+				       outlen_actual, true);
 }
 
 int efx_mcdi_rpc_start(struct efx_nic *efx, unsigned cmd,
@@ -866,7 +935,7 @@ int efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 			size_t *outlen_actual)
 {
 	return _efx_mcdi_rpc_finish(efx, cmd, inlen, outbuf, outlen,
-				    outlen_actual, false);
+				    outlen_actual, false, NULL);
 }
 
 int efx_mcdi_rpc_finish_quiet(struct efx_nic *efx, unsigned cmd, size_t inlen,
@@ -874,7 +943,7 @@ int efx_mcdi_rpc_finish_quiet(struct efx_nic *efx, unsigned cmd, size_t inlen,
 			      size_t *outlen_actual)
 {
 	return _efx_mcdi_rpc_finish(efx, cmd, inlen, outbuf, outlen,
-				    outlen_actual, true);
+				    outlen_actual, true, NULL);
 }
 
 void efx_mcdi_display_error(struct efx_nic *efx, unsigned cmd,
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 025d504..397660d 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -71,6 +71,7 @@ struct efx_mcdi_iface {
 	unsigned int credits;
 	unsigned int seqno;
 	int resprc;
+	int resprc_raw;
 	size_t resp_hdr_len;
 	size_t resp_data_len;
 	spinlock_t async_lock;
-- 
2.4.3
