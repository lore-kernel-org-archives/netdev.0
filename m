From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next v2 2/5] sfc: Handle MCDI proxy authorisation
Date: Wed, 23 Dec 2015 08:57:18 +0000
Message-ID: <567A61EE.9030909@solarflare.com>
References: <567A6170.6010104@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:5160 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932716AbbLWI53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 03:57:29 -0500
In-Reply-To: <567A6170.6010104@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For unprivileged functions operations can be authorised by an admin
function. Extra steps are introduced to the MCDI protocol in this
situation - the initial response from the MCDI tells us that the
operation has been deferred, and we must retry when told. We then
receive an event telling us to retry.

Note that this provides only the functionality for the unprivileged
functions, not the handling of the administrative side.

Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 154 +++++++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/sfc/mcdi.h |   9 +++
 2 files changed, 155 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 2509ca9..d6b8a77 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -82,6 +82,7 @@ int efx_mcdi_init(struct efx_nic *efx)
 	mcdi->logging_enabled = mcdi_logging_default;
 #endif
 	init_waitqueue_head(&mcdi->wq);
+	init_waitqueue_head(&mcdi->proxy_rx_wq);
 	spin_lock_init(&mcdi->iface_lock);
 	mcdi->state = MCDI_STATE_QUIESCENT;
 	mcdi->mode = MCDI_MODE_POLL;
@@ -622,10 +623,30 @@ efx_mcdi_check_supported(struct efx_nic *efx, unsigned int cmd, size_t inlen)
 	return 0;
 }
 
-static int _efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
+static bool efx_mcdi_get_proxy_handle(struct efx_nic *efx,
+				      size_t hdr_len, size_t data_len,
+				      u32 *proxy_handle)
+{
+	MCDI_DECLARE_BUF_ERR(testbuf);
+	const size_t buflen = sizeof(testbuf);
+
+	if (!proxy_handle || data_len < buflen)
+		return false;
+
+	efx->type->mcdi_read_response(efx, testbuf, hdr_len, buflen);
+	if (MCDI_DWORD(testbuf, ERR_CODE) == MC_CMD_ERR_PROXY_PENDING) {
+		*proxy_handle = MCDI_DWORD(testbuf, ERR_PROXY_PENDING_HANDLE);
+		return true;
+	}
+
+	return false;
+}
+
+static int _efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned int cmd,
+				size_t inlen,
 				efx_dword_t *outbuf, size_t outlen,
 				size_t *outlen_actual, bool quiet,
-				int *raw_rc)
+				u32 *proxy_handle, int *raw_rc)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
 	MCDI_DECLARE_BUF_ERR(errbuf);
@@ -659,6 +680,9 @@ static int _efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 		spin_unlock_bh(&mcdi->iface_lock);
 	}
 
+	if (proxy_handle)
+		*proxy_handle = 0;
+
 	if (rc != 0) {
 		if (outlen_actual)
 			*outlen_actual = 0;
@@ -693,6 +717,12 @@ static int _efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 			netif_err(efx, hw, efx->net_dev, "MC fatal error %d\n",
 				  -rc);
 			efx_schedule_reset(efx, RESET_TYPE_MC_FAILURE);
+		} else if (proxy_handle && (rc == -EPROTO) &&
+			   efx_mcdi_get_proxy_handle(efx, hdr_len, data_len,
+						     proxy_handle)) {
+			mcdi->proxy_rx_status = 0;
+			mcdi->proxy_rx_handle = 0;
+			mcdi->state = MCDI_STATE_PROXY_WAIT;
 		} else if (rc && !quiet) {
 			efx_mcdi_display_error(efx, cmd, inlen, errbuf, err_len,
 					       rc);
@@ -705,23 +735,119 @@ static int _efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 		}
 	}
 
-	efx_mcdi_release(mcdi);
+	if (!proxy_handle || !*proxy_handle)
+		efx_mcdi_release(mcdi);
 	return rc;
 }
 
-static int _efx_mcdi_rpc(struct efx_nic *efx, unsigned cmd,
+static void efx_mcdi_proxy_abort(struct efx_mcdi_iface *mcdi)
+{
+	if (mcdi->state == MCDI_STATE_PROXY_WAIT) {
+		/* Interrupt the proxy wait. */
+		mcdi->proxy_rx_status = -EINTR;
+		wake_up(&mcdi->proxy_rx_wq);
+	}
+}
+
+static void efx_mcdi_ev_proxy_response(struct efx_nic *efx,
+				       u32 handle, int status)
+{
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+
+	WARN_ON(mcdi->state != MCDI_STATE_PROXY_WAIT);
+
+	mcdi->proxy_rx_status = efx_mcdi_errno(status);
+	/* Ensure the status is written before we update the handle, since the
+	 * latter is used to check if we've finished.
+	 */
+	wmb();
+	mcdi->proxy_rx_handle = handle;
+	wake_up(&mcdi->proxy_rx_wq);
+}
+
+static int efx_mcdi_proxy_wait(struct efx_nic *efx, u32 handle, bool quiet)
+{
+	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+	int rc;
+
+	/* Wait for a proxy event, or timeout. */
+	rc = wait_event_timeout(mcdi->proxy_rx_wq,
+				mcdi->proxy_rx_handle != 0 ||
+				mcdi->proxy_rx_status == -EINTR,
+				MCDI_RPC_TIMEOUT);
+
+	if (rc <= 0) {
+		netif_dbg(efx, hw, efx->net_dev,
+			  "MCDI proxy timeout %d\n", handle);
+		return -ETIMEDOUT;
+	} else if (mcdi->proxy_rx_handle != handle) {
+		netif_warn(efx, hw, efx->net_dev,
+			   "MCDI proxy unexpected handle %d (expected %d)\n",
+			   mcdi->proxy_rx_handle, handle);
+		return -EINVAL;
+	}
+
+	return mcdi->proxy_rx_status;
+}
+
+static int _efx_mcdi_rpc(struct efx_nic *efx, unsigned int cmd,
 			 const efx_dword_t *inbuf, size_t inlen,
 			 efx_dword_t *outbuf, size_t outlen,
 			 size_t *outlen_actual, bool quiet, int *raw_rc)
 {
+	u32 proxy_handle = 0; /* Zero is an invalid proxy handle. */
 	int rc;
 
+	if (inbuf && inlen && (inbuf == outbuf)) {
+		/* The input buffer can't be aliased with the output. */
+		WARN_ON(1);
+		return -EINVAL;
+	}
+
 	rc = efx_mcdi_rpc_start(efx, cmd, inbuf, inlen);
 	if (rc)
 		return rc;
 
-	return _efx_mcdi_rpc_finish(efx, cmd, inlen, outbuf, outlen,
-				    outlen_actual, quiet, raw_rc);
+	rc = _efx_mcdi_rpc_finish(efx, cmd, inlen, outbuf, outlen,
+				  outlen_actual, quiet, &proxy_handle, raw_rc);
+
+	if (proxy_handle) {
+		/* Handle proxy authorisation. This allows approval of MCDI
+		 * operations to be delegated to the admin function, allowing
+		 * fine control over (eg) multicast subscriptions.
+		 */
+		struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
+
+		netif_dbg(efx, hw, efx->net_dev,
+			  "MCDI waiting for proxy auth %d\n",
+			  proxy_handle);
+		rc = efx_mcdi_proxy_wait(efx, proxy_handle, quiet);
+
+		if (rc == 0) {
+			netif_dbg(efx, hw, efx->net_dev,
+				  "MCDI proxy retry %d\n", proxy_handle);
+
+			/* We now retry the original request. */
+			mcdi->state = MCDI_STATE_RUNNING_SYNC;
+			efx_mcdi_send_request(efx, cmd, inbuf, inlen);
+
+			rc = _efx_mcdi_rpc_finish(efx, cmd, inlen,
+						  outbuf, outlen, outlen_actual,
+						  quiet, NULL, raw_rc);
+		} else {
+			netif_printk(efx, hw,
+				     rc == -EPERM ? KERN_DEBUG : KERN_ERR,
+				     efx->net_dev,
+				     "MC command 0x%x failed after proxy auth rc=%d\n",
+				     cmd, rc);
+
+			if (rc == -EINTR || rc == -EIO)
+				efx_schedule_reset(efx, RESET_TYPE_MC_FAILURE);
+			efx_mcdi_release(mcdi);
+		}
+	}
+
+	return rc;
 }
 
 static int _efx_mcdi_rpc_evb_retry(struct efx_nic *efx, unsigned cmd,
@@ -935,7 +1061,7 @@ int efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 			size_t *outlen_actual)
 {
 	return _efx_mcdi_rpc_finish(efx, cmd, inlen, outbuf, outlen,
-				    outlen_actual, false, NULL);
+				    outlen_actual, false, NULL, NULL);
 }
 
 int efx_mcdi_rpc_finish_quiet(struct efx_nic *efx, unsigned cmd, size_t inlen,
@@ -943,7 +1069,7 @@ int efx_mcdi_rpc_finish_quiet(struct efx_nic *efx, unsigned cmd, size_t inlen,
 			      size_t *outlen_actual)
 {
 	return _efx_mcdi_rpc_finish(efx, cmd, inlen, outbuf, outlen,
-				    outlen_actual, true, NULL);
+				    outlen_actual, true, NULL, NULL);
 }
 
 void efx_mcdi_display_error(struct efx_nic *efx, unsigned cmd,
@@ -1083,8 +1209,13 @@ static void efx_mcdi_ev_death(struct efx_nic *efx, int rc)
 	 * receiving a REBOOT event after posting the MCDI
 	 * request. Did the mc reboot before or after the copyout? The
 	 * best we can do always is just return failure.
+	 *
+	 * If there is an outstanding proxy response expected it is not going
+	 * to arrive. We should thus abort it.
 	 */
 	spin_lock(&mcdi->iface_lock);
+	efx_mcdi_proxy_abort(mcdi);
+
 	if (efx_mcdi_complete_sync(mcdi)) {
 		if (mcdi->mode == MCDI_MODE_EVENTS) {
 			mcdi->resprc = rc;
@@ -1132,6 +1263,8 @@ static void efx_mcdi_ev_bist(struct efx_nic *efx)
 
 	spin_lock(&mcdi->iface_lock);
 	efx->mc_bist_for_other_fn = true;
+	efx_mcdi_proxy_abort(mcdi);
+
 	if (efx_mcdi_complete_sync(mcdi)) {
 		if (mcdi->mode == MCDI_MODE_EVENTS) {
 			mcdi->resprc = -EIO;
@@ -1240,6 +1373,11 @@ void efx_mcdi_process_event(struct efx_channel *channel,
 			  EFX_QWORD_VAL(*event));
 		efx_schedule_reset(efx, RESET_TYPE_DMA_ERROR);
 		break;
+	case MCDI_EVENT_CODE_PROXY_RESPONSE:
+		efx_mcdi_ev_proxy_response(efx,
+				MCDI_EVENT_FIELD(*event, PROXY_RESPONSE_HANDLE),
+				MCDI_EVENT_FIELD(*event, PROXY_RESPONSE_RC));
+		break;
 	default:
 		netif_err(efx, hw, efx->net_dev, "Unknown MCDI event 0x%x\n",
 			  code);
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 397660d..c9aeb07 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -17,6 +17,8 @@
  * @MCDI_STATE_RUNNING_SYNC: There is a synchronous MCDI request pending.
  *	Only the thread that moved into this state is allowed to move out of it.
  * @MCDI_STATE_RUNNING_ASYNC: There is an asynchronous MCDI request pending.
+ * @MCDI_STATE_PROXY_WAIT: An MCDI request has completed with a response that
+ *	indicates we must wait for a proxy try again message.
  * @MCDI_STATE_COMPLETED: An MCDI request has completed, but the owning thread
  *	has not yet consumed the result. For all other threads, equivalent to
  *	%MCDI_STATE_RUNNING.
@@ -25,6 +27,7 @@ enum efx_mcdi_state {
 	MCDI_STATE_QUIESCENT,
 	MCDI_STATE_RUNNING_SYNC,
 	MCDI_STATE_RUNNING_ASYNC,
+	MCDI_STATE_PROXY_WAIT,
 	MCDI_STATE_COMPLETED,
 };
 
@@ -60,6 +63,9 @@ enum efx_mcdi_mode {
  * @async_timer: Timer for asynchronous request timeout
  * @logging_buffer: buffer that may be used to build MCDI tracing messages
  * @logging_enabled: whether to trace MCDI
+ * @proxy_rx_handle: Most recently received proxy authorisation handle
+ * @proxy_rx_status: Status of most recent proxy authorisation
+ * @proxy_rx_wq: Wait queue for updates to proxy_rx_handle
  */
 struct efx_mcdi_iface {
 	struct efx_nic *efx;
@@ -81,6 +87,9 @@ struct efx_mcdi_iface {
 	char *logging_buffer;
 	bool logging_enabled;
 #endif
+	unsigned int proxy_rx_handle;
+	int proxy_rx_status;
+	wait_queue_head_t proxy_rx_wq;
 };
 
 struct efx_mcdi_mon {
-- 
2.4.3
