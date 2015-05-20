From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 09/16] sfc: Initialise MCDI buffers to 0 on declaration.
Date: Wed, 20 May 2015 11:10:41 +0100
Message-ID: <555C5DA1.4050305@solarflare.com>
References: <555C5C91.4000004@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:38166 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752633AbbETKKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 06:10:49 -0400
In-Reply-To: <555C5C91.4000004@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

In order to avoid MC bugs the flags field needs to be set to 0.
Instead of explicitly clearing out the flags individually, a
better way to do this is to memset the MCDI_BUF to 0.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 28 +++++++++++++++-------------
 drivers/net/ethernet/sfc/mcdi.c |  8 ++++----
 drivers/net/ethernet/sfc/mcdi.h |  8 +++++---
 drivers/net/ethernet/sfc/ptp.c  |  6 +++---
 4 files changed, 27 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 4058626..e8d760c 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -378,7 +378,7 @@ fail1:
 
 static int efx_ef10_free_vis(struct efx_nic *efx)
 {
-	MCDI_DECLARE_BUF_OUT_OR_ERR(outbuf, 0);
+	MCDI_DECLARE_BUF_ERR(outbuf);
 	size_t outlen;
 	int rc = efx_mcdi_rpc_quiet(efx, MC_CMD_FREE_VIS, NULL, 0,
 				    outbuf, sizeof(outbuf), &outlen);
@@ -449,9 +449,9 @@ static int efx_ef10_alloc_piobufs(struct efx_nic *efx, unsigned int n)
 static int efx_ef10_link_piobufs(struct efx_nic *efx)
 {
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
-	MCDI_DECLARE_BUF(inbuf,
-			 max(MC_CMD_LINK_PIOBUF_IN_LEN,
-			     MC_CMD_UNLINK_PIOBUF_IN_LEN));
+	_MCDI_DECLARE_BUF(inbuf,
+			  max(MC_CMD_LINK_PIOBUF_IN_LEN,
+			      MC_CMD_UNLINK_PIOBUF_IN_LEN));
 	struct efx_channel *channel;
 	struct efx_tx_queue *tx_queue;
 	unsigned int offset, index;
@@ -460,6 +460,8 @@ static int efx_ef10_link_piobufs(struct efx_nic *efx)
 	BUILD_BUG_ON(MC_CMD_LINK_PIOBUF_OUT_LEN != 0);
 	BUILD_BUG_ON(MC_CMD_UNLINK_PIOBUF_OUT_LEN != 0);
 
+	memset(inbuf, 0, sizeof(inbuf));
+
 	/* Link a buffer to each VI in the write-combining mapping */
 	for (index = 0; index < nic_data->n_piobufs; ++index) {
 		MCDI_SET_DWORD(inbuf, LINK_PIOBUF_IN_PIOBUF_HANDLE,
@@ -1406,17 +1408,17 @@ static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_INIT_TXQ_IN_LEN(EFX_MAX_DMAQ_SIZE * 8 /
 						       EFX_BUF_SIZE));
-	MCDI_DECLARE_BUF(outbuf, MC_CMD_INIT_TXQ_OUT_LEN);
 	bool csum_offload = tx_queue->queue & EFX_TXQ_TYPE_OFFLOAD;
 	size_t entries = tx_queue->txd.buf.len / EFX_BUF_SIZE;
 	struct efx_channel *channel = tx_queue->channel;
 	struct efx_nic *efx = tx_queue->efx;
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
-	size_t inlen, outlen;
+	size_t inlen;
 	dma_addr_t dma_addr;
 	efx_qword_t *txd;
 	int rc;
 	int i;
+	BUILD_BUG_ON(MC_CMD_INIT_TXQ_OUT_LEN != 0);
 
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_SIZE, tx_queue->ptr_mask + 1);
 	MCDI_SET_DWORD(inbuf, INIT_TXQ_IN_TARGET_EVQ, channel->channel);
@@ -1441,7 +1443,7 @@ static void efx_ef10_tx_init(struct efx_tx_queue *tx_queue)
 	inlen = MC_CMD_INIT_TXQ_IN_LEN(entries);
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_INIT_TXQ, inbuf, inlen,
-			  outbuf, sizeof(outbuf), &outlen);
+			  NULL, 0, NULL);
 	if (rc)
 		goto fail;
 
@@ -1474,7 +1476,7 @@ fail:
 static void efx_ef10_tx_fini(struct efx_tx_queue *tx_queue)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_FINI_TXQ_IN_LEN);
-	MCDI_DECLARE_BUF(outbuf, MC_CMD_FINI_TXQ_OUT_LEN);
+	MCDI_DECLARE_BUF_ERR(outbuf);
 	struct efx_nic *efx = tx_queue->efx;
 	size_t outlen;
 	int rc;
@@ -1781,15 +1783,15 @@ static void efx_ef10_rx_init(struct efx_rx_queue *rx_queue)
 	MCDI_DECLARE_BUF(inbuf,
 			 MC_CMD_INIT_RXQ_IN_LEN(EFX_MAX_DMAQ_SIZE * 8 /
 						EFX_BUF_SIZE));
-	MCDI_DECLARE_BUF(outbuf, MC_CMD_INIT_RXQ_OUT_LEN);
 	struct efx_channel *channel = efx_rx_queue_channel(rx_queue);
 	size_t entries = rx_queue->rxd.buf.len / EFX_BUF_SIZE;
 	struct efx_nic *efx = rx_queue->efx;
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
-	size_t inlen, outlen;
+	size_t inlen;
 	dma_addr_t dma_addr;
 	int rc;
 	int i;
+	BUILD_BUG_ON(MC_CMD_INIT_RXQ_OUT_LEN != 0);
 
 	rx_queue->scatter_n = 0;
 	rx_queue->scatter_len = 0;
@@ -1818,7 +1820,7 @@ static void efx_ef10_rx_init(struct efx_rx_queue *rx_queue)
 	inlen = MC_CMD_INIT_RXQ_IN_LEN(entries);
 
 	rc = efx_mcdi_rpc(efx, MC_CMD_INIT_RXQ, inbuf, inlen,
-			  outbuf, sizeof(outbuf), &outlen);
+			  NULL, 0, NULL);
 	if (rc)
 		netdev_WARN(efx->net_dev, "failed to initialise RXQ %d\n",
 			    efx_rx_queue_index(rx_queue));
@@ -1827,7 +1829,7 @@ static void efx_ef10_rx_init(struct efx_rx_queue *rx_queue)
 static void efx_ef10_rx_fini(struct efx_rx_queue *rx_queue)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_FINI_RXQ_IN_LEN);
-	MCDI_DECLARE_BUF(outbuf, MC_CMD_FINI_RXQ_OUT_LEN);
+	MCDI_DECLARE_BUF_ERR(outbuf);
 	struct efx_nic *efx = rx_queue->efx;
 	size_t outlen;
 	int rc;
@@ -1989,7 +1991,7 @@ static int efx_ef10_ev_init(struct efx_channel *channel)
 static void efx_ef10_ev_fini(struct efx_channel *channel)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_FINI_EVQ_IN_LEN);
-	MCDI_DECLARE_BUF(outbuf, MC_CMD_FINI_EVQ_OUT_LEN);
+	MCDI_DECLARE_BUF_ERR(outbuf);
 	struct efx_nic *efx = channel->efx;
 	size_t outlen;
 	int rc;
diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index b44ee31..fcee761 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -406,7 +406,7 @@ static bool efx_mcdi_complete_async(struct efx_mcdi_iface *mcdi, bool timeout)
 	struct efx_mcdi_async_param *async;
 	size_t hdr_len, data_len, err_len;
 	efx_dword_t *outbuf;
-	MCDI_DECLARE_BUF_OUT_OR_ERR(errbuf, 0);
+	MCDI_DECLARE_BUF_ERR(errbuf);
 	int rc;
 
 	if (cmpxchg(&mcdi->state,
@@ -534,7 +534,7 @@ static int _efx_mcdi_rpc_finish(struct efx_nic *efx, unsigned cmd, size_t inlen,
 				size_t *outlen_actual, bool quiet)
 {
 	struct efx_mcdi_iface *mcdi = efx_mcdi(efx);
-	MCDI_DECLARE_BUF_OUT_OR_ERR(errbuf, 0);
+	MCDI_DECLARE_BUF_ERR(errbuf);
 	int rc;
 
 	if (mcdi->mode == MCDI_MODE_POLL)
@@ -1389,7 +1389,7 @@ fail1:
 static int efx_mcdi_read_assertion(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_GET_ASSERTS_IN_LEN);
-	MCDI_DECLARE_BUF_OUT_OR_ERR(outbuf, MC_CMD_GET_ASSERTS_OUT_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_ASSERTS_OUT_LEN);
 	unsigned int flags, index;
 	const char *reason;
 	size_t outlen;
@@ -1699,7 +1699,7 @@ int efx_mcdi_set_workaround(struct efx_nic *efx, u32 type, bool enabled)
 int efx_mcdi_get_workarounds(struct efx_nic *efx, unsigned int *impl_out,
 			     unsigned int *enabled_out)
 {
-	MCDI_DECLARE_BUF_OUT_OR_ERR(outbuf, MC_CMD_GET_WORKAROUNDS_OUT_LEN);
+	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_WORKAROUNDS_OUT_LEN);
 	size_t outlen;
 	int rc;
 
diff --git a/drivers/net/ethernet/sfc/mcdi.h b/drivers/net/ethernet/sfc/mcdi.h
index 5df1e98..7afab2f 100644
--- a/drivers/net/ethernet/sfc/mcdi.h
+++ b/drivers/net/ethernet/sfc/mcdi.h
@@ -176,10 +176,12 @@ void efx_mcdi_sensor_event(struct efx_nic *efx, efx_qword_t *ev);
  * 32-bit-aligned.  Also, on Siena we must copy to the MC shared
  * memory strictly 32 bits at a time, so add any necessary padding.
  */
-#define MCDI_DECLARE_BUF(_name, _len)					\
+#define _MCDI_DECLARE_BUF(_name, _len)					\
 	efx_dword_t _name[DIV_ROUND_UP(_len, 4)]
-#define MCDI_DECLARE_BUF_OUT_OR_ERR(_name, _len)			\
-	MCDI_DECLARE_BUF(_name, max_t(size_t, _len, 8))
+#define MCDI_DECLARE_BUF(_name, _len)					\
+	_MCDI_DECLARE_BUF(_name, _len) = {{{0}}}
+#define MCDI_DECLARE_BUF_ERR(_name)					\
+	MCDI_DECLARE_BUF(_name, 8)
 #define _MCDI_PTR(_buf, _offset)					\
 	((u8 *)(_buf) + (_offset))
 #define MCDI_PTR(_buf, _field)						\
diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index a2e9aee..cf8c833 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -306,7 +306,7 @@ struct efx_ptp_data {
 	struct work_struct pps_work;
 	struct workqueue_struct *pps_workwq;
 	bool nic_ts_enabled;
-	MCDI_DECLARE_BUF(txbuf, MC_CMD_PTP_IN_TRANSMIT_LENMAX);
+	_MCDI_DECLARE_BUF(txbuf, MC_CMD_PTP_IN_TRANSMIT_LENMAX);
 
 	unsigned int good_syncs;
 	unsigned int fast_syncs;
@@ -568,7 +568,7 @@ static int efx_ptp_get_timestamp_corrections(struct efx_nic *efx)
 static int efx_ptp_enable(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_ENABLE_LEN);
-	MCDI_DECLARE_BUF_OUT_OR_ERR(outbuf, 0);
+	MCDI_DECLARE_BUF_ERR(outbuf);
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_ENABLE);
@@ -596,7 +596,7 @@ static int efx_ptp_enable(struct efx_nic *efx)
 static int efx_ptp_disable(struct efx_nic *efx)
 {
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_PTP_IN_DISABLE_LEN);
-	MCDI_DECLARE_BUF_OUT_OR_ERR(outbuf, 0);
+	MCDI_DECLARE_BUF_ERR(outbuf);
 	int rc;
 
 	MCDI_SET_DWORD(inbuf, PTP_IN_OP, MC_CMD_PTP_OP_DISABLE);
